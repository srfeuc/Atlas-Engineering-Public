---
Title: Playbook — Recover from a DNS Outage (Pi01) + the Game-Day drill
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — the drill is a deliberate `ADR-0011` Game-Day; per-step read-backs + the RTO land when it's run. DNS split per `ADR-0003`/`ADR-0009`/`ADR-0051`.
Version: 1.0
Date: 2026-07-31
---

# Playbook — Recover from a DNS Outage (Pi01)

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`) — the golden-standard exemplar + an `ADR-0011` Game-Day drill.** Kind: problem / failure-recovery. **DNS resolution fails and everything "feels down" — though packets still flow.** This page both **recovers a real DNS outage** and runs it as a **deliberate break-and-recover drill**.

**Why DNS is the golden first drill.** It's the most common "the whole network is down" that *isn't*: packets flow, but nothing resolves by name, so every app fails at once. Nailing the **"is it DNS, or is it connectivity?"** split is the highest-leverage first move in troubleshooting — so we make it the reference page.

## Symptoms / when you'd use this

- Users report "the internet is down" / "nothing works" — but the network is actually up.
- The tell-tale: `ping 1.1.1.1` (an **IP**) succeeds, while `ping google.com` (a **name**) fails.
- New connections *by name* fail across a segment or the estate; existing IP-based sessions may keep working.
- Or: you're running the scheduled Game-Day drill.

## Cert anchor

- CCNA 4.0 IP Services (DNS).
- CompTIA **Linux+** (services, name resolution).
- Security+ / CySA+ (availability, BCP/DR, RTO/RPO).
- AZ-800/801 (AD-DNS).
- Drill discipline: `ADR-0011` (Game-Day). *(Grounding index: the cert maps + the DR catalogue in `Atlas-Roadmap-Advanced-Scenarios`.)*

## Grounded in — the Atlas DNS architecture (know the split before you break it)

Two resolvers, split by domain membership (`ADR-0003` / `ADR-0051`):

- **Domain-joined machines** → resolver = **AD-DNS on the DCs** (DC01 `10.20.0.2`, DC02 `10.20.0.3`). AD-DNS answers `atlas.lab` authoritatively and forwards external queries.
- **Non-domain devices** → resolver = **Pi-hole on Pi01** (VLAN 10). Pi-hole filters + forwards external, and conditional-forwards `atlas.lab` → the DCs.
- **Pi01 is a single box** (Pi-hole + chrony on one host, `ADR-0009`) — a known **SPOF** (`Atlas-Improvement-Backlog` Tier-1 #2). That's *why* this drill matters.

Command detail (link down — `POL-0008`): `../Command-Library/Linux.md` §DNS (Pi-hole) + `../Command-Library/PowerShell-Tier0.md` §DNS (AD-DNS). Why-it-works: `../Concepts/README.md` (the DNS resolution chain).

> 🔴 **Blast radius depends on what you break.** Stopping **Pi-hole** kills DNS for **non-domain** devices immediately; **domain** machines keep resolving `atlas.lab` (AD-DNS) but lose **external** names *if* AD-DNS forwards through Pi-hole. Breaking **AD-DNS** is a bigger, different drill (that's the DC-down page). **This page breaks the Pi01 resolver.**

## ① Pin it down (capture these first — they're the ticket)

- a. **What fails** — resolution by *name* fails while by *IP* works? (confirm in Detect step 1.)
- b. **Scope** — everyone, or only non-domain devices / one VLAN? (points at Pi-hole vs AD-DNS.)
- c. **Which resolver** the affected client is configured to use — Pi01 (`10.10.0.x`) or a DC (`10.20.0.2/3`).
- d. **Timing / recent change** — when it started; did Pi01 reboot, a service restart, or a blocklist update land?
- e. **Drill or real?** — if it's the Game-Day, note the **start time** (the RTO clock).

## The Game-Day drill — break it safely (`ADR-0011`)

> Run only in a maintenance window; it's your lab, but treat it like change control (`POL-0003`). Reversible — you're stopping a service, not deleting data.

- a. **Restore path ready *first*.** Confirm you can reach Pi01 out-of-band **by IP** (SSH/console) *before* you break DNS — if your SSH target is a *name*, you'll lock yourself out.
  - 📸 the healthy baseline: `pihole status` + `systemctl status pihole-FTL` **before** the break. *(Store in `images/`; no secrets — `POL-0002`/SS-001.)*
- b. **Note current state** — a Pi01 VM snapshot if available, or simply that this is a service stop.
- c. **Start the clock** — RTO begins now.
- d. **Break it** — stop the resolver on Pi01:
  - `sudo systemctl stop pihole-FTL`
  - Reference: `../Command-Library/Linux.md` §DNS.
  - This simulates the resolver process dying — the common real failure — without touching config.

## Detect & diagnose — is it DNS, and which resolver?

Run from an affected client.

**1. Prove it's name-not-network (the reflex).**

- a. `ping 1.1.1.1` — an **IP**. → Healthy: replies (the network is fine).
- b. `ping google.com` — a **name**. → Broken: "cannot resolve" / no reply.
- → If (a) works and (b) fails, it's **DNS**, not connectivity. (Cross-ref `Test-a-Connection.md` — rung 3 vs rung 5.)
- 📸 the two pings side by side (IP works, name fails) — the classic proof.

**2. Which resolver is the client using?**

- Linux: `resolvectl status` (or `cat /etc/resolv.conf`).
- Windows: `Get-DnsClientServerAddress`.
- → Is it Pi01 (non-domain) or a DC (domain)? This tells you which resolver to interrogate.

**3. Is that resolver answering?**

- Linux: `dig @<resolver-ip> google.com`.
- Windows: `Resolve-DnsName google.com -Server <resolver-ip>`.
- Reference: `../Command-Library/Linux.md` §DNS / `../Command-Library/PowerShell-Tier0.md` §DNS.
- Broken: `SERVFAIL` / timeout from Pi01 → the Pi-hole resolver is down (confirms the break).

**4. Confirm on Pi01 itself.**

- `systemctl status pihole-FTL` → `inactive`/`failed` — the break.
- `pihole status` → not blocking / FTL offline.
- `journalctl -u pihole-FTL -e` → *why* it stopped (hand off to `Read-the-Logs-with-journalctl.md`).
- Reference: `../Command-Library/Linux.md` §DNS/§Services.
- 📸 the failed `systemctl status pihole-FTL`.

## Recover

- a. **Immediate mitigation (buy time).** Point affected clients at a still-working resolver — a DC (`10.20.0.2`) for domain machines, or a temporary trusted public resolver for non-domain — so users work while you fix Pi01.
  - Note: this **bypasses Pi-hole filtering** — revert it in step d.
- b. **Fix the resolver.** On Pi01:
  - `sudo systemctl start pihole-FTL`
  - `systemctl is-active pihole-FTL` → `active`.
  - If it won't start, read `journalctl -u pihole-FTL -e` for the cause — config error, **port 53 already in use** (→ `Port-Already-In-Use.md`), disk full, or an unreachable upstream.
- c. **Re-enable at boot** if it was disabled: `systemctl is-enabled pihole-FTL` → `enabled` (so a reboot doesn't reintroduce the outage).
- d. **Revert the mitigation** — put clients back on Pi01 as their resolver.

## Prove it's recovered

- a. From the affected client: `ping google.com` resolves; `dig @<pi01> atlas.lab` **and** an external name both answer.
- b. On Pi01: `pihole status` = blocking/active; `systemctl is-active pihole-FTL` = `active (running)`.
- c. **Stop the clock — record the RTO** (the Game-Day metric): break → full recovery. File it against the DR catalogue (`Atlas-Roadmap-Advanced-Scenarios`) / `ADR-0011`.
- d. 📸 the recovered `pihole status` + the resolving `ping`.
- e. Mark ✅ only with the pasted read-backs.

## What this teaches (the SPOF lesson — don't skip it)

- **Pi01 is a single box** holding DNS (+ NTP); its loss takes DNS with it (`Atlas-Improvement-Backlog` Tier-1 #2). The real fix isn't faster recovery — it's **removing the SPOF**: a second resolver (a Pi-hole secondary, or clients configured with a DC as a backup resolver) so a Pi01 outage **degrades gracefully** instead of going dark.
- The reflex you just drilled — **"by-IP works, by-name fails ⇒ DNS"** — is the single highest-value first move when "the whole network is down."

## If still broken

- `pihole-FTL` starts but names still fail → an **upstream/forwarder** problem (Pi-hole → its upstream, or AD-DNS's forwarder). Test the upstream on `:53` (`Test-a-Connection.md`).
- Only `atlas.lab` fails → the **conditional-forward to the DCs**, not Pi-hole itself → the DC-down / AD-DNS path (📋).
- Everything including *by-IP* fails → it's **not DNS**; it's connectivity/gateway → the MKT01 gateway path + `Trace-a-Blocked-Flow.md`.

## Related

- Command-Library: `../Command-Library/Linux.md` (§DNS/§Services) · `../Command-Library/PowerShell-Tier0.md` (§DNS).
- Concepts: `../Concepts/README.md` (the DNS resolution chain — why-it-works).
- Decisions/owners: `ADR-0003` (DNS boundary) · `ADR-0009` (Pi01 reduced role) · `ADR-0051` (Pi-hole owns filtering) · `ADR-0011` (Game-Day drills) · `Atlas-Improvement-Backlog` Tier-1 #2 (the Pi01 SPOF).
- Sibling playbooks: `Test-a-Connection.md` (the IP-vs-name split) · `Read-the-Logs-with-journalctl.md` (why FTL stopped) · `Port-Already-In-Use.md` (port 53 conflict) · `Domain-Join-Fails.md` (DNS is its #1 cause) · the DC-down / AD-DNS drill (📋).
- **Checklist (reciprocal, `ADR-0053` §8):** `00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx` — **Phase 2 "Point DNS at the DCs"** + **Phase 3 "Verify DNS resolution"** hand off here when name resolution fails mid-build.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created (`ADR-0053`) — the **golden-standard, high-detail exemplar**: a common whole-network DNS outage run as an `ADR-0011` Game-Day break-and-recover drill, grounded in the real Pi01 + AD-DNS split. Pin-it intake · granular list steps · 📸 at each proof · the SPOF lesson + RTO capture. 🟡 until run on Pi01. |
