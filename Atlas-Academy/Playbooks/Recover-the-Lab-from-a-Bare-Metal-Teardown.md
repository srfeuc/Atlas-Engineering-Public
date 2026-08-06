---
Title: Playbook — Recover the Lab from a Bare-Metal Teardown (your credentials are on the box you're about to wipe)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — the drill's read-backs + RTO land when it's run (an `ADR-0011` Game-Day). Grounded in the real frozen **Lab-01** teardown runbook (`048`), current-design-reconciled (`ADR-0022`). Searchable/ticket-ready per Backlog **#32**.
Version: 1.0
Date: 2026-07-31
---

# Playbook — Recover the Lab from a Bare-Metal Teardown

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`) — the worst-day runbook + an `ADR-0011` Game-Day drill.** Kind: disaster recovery. **Every device is factory-reset, there is no network — no DHCP, no DNS, no management VLAN, nothing by name — and you must rebuild the estate from documentation alone.** This is *the test* of the Charter's mission: that Atlas is *"sufficient to rebuild, operate, troubleshoot, and recover without relying on chat history or memory."* Everything else is an opinion.

**Why this is a first-tier playbook (Backlog `#32`).** It's the one runbook guaranteed to run on the worst possible day, and it contains the estate's single most dangerous trap: **your credentials live on the machine you are about to wipe.** In frozen Lab-01, Vaultwarden ran on Pi01 — so wiping Pi01 deleted every device password *and* the CA keys, leaving you at a factory-reset FortiGate with no way to look up the admin password (`048`). Extract first, wipe second.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- factory-reset device prompts: FortiGate blank-then-forced admin password; MikroTik factory defaults; Cisco initial-config dialog.
- "*no route to host*" / "*could not resolve*" everywhere — because there is no network yet.
- serial console blank/garbage (wrong baud — 9600 vs 115200).
- WinBox by IP fails; only Neighbors/MAC works.

**Plain-language symptom phrases**

- "I need to rebuild the whole lab from scratch."
- "everything is factory reset and there's no network."
- "how do I get into a device when there's no DHCP/DNS/management VLAN?"
- "I wiped the box that had all my passwords."
- "where do I even start rebuilding — what order?"
- "disaster recovery / bare-metal rebuild / start from nothing."
- "the credentials were on the machine I just reset."

**Aliases / also-known-as**

- teardown and rebuild · bare-metal recovery · disaster recovery · DR drill · Game-Day rebuild · rebuild-from-docs · bootstrap access · cold-start.
- credential-on-the-wiped-host · offline credential extraction · restore-vs-rebuild the CA · layer-by-layer rebuild order.

**Keywords line**

`048` · teardown · rebuild order · bootstrap · Vaultwarden export · offline media · paper passwords · SW01 9600 8N1 · MKT01 MAC-WinBox `ether4` · FGT01 `192.168.1.99` · `STATIC-HOSTS` · `hw=no` · FGT `/8` route · restore-vs-rebuild CA · `ADR-0011` Game-Day · RTO · leave-the-docs log.

## Cert anchor

- CompTIA **Security+ / CySA+** (BCP/DR, recovery, RTO/RPO) — the primary anchor.
- **CCNA** (console bootstrap, VLAN/trunk/DAI rebuild), CompTIA **Server+** (bare-metal recovery).
- Drill discipline: `ADR-0011` (Game-Day). *(Grounding index: `../Atlas-Roadmap-Advanced-Scenarios` DR catalogue + the cert maps.)*

## Grounded in — the two problems `048` exists to solve

Most rebuild guides assume a working network and reachable devices. This one doesn't (`POL-0008` — the build guides + topology own the steps; this page links):

- 🔴 **The extraction problem — your credentials are on the host you wipe.** In frozen Lab-01, Pi01 held Vaultwarden (every device password), the Root + Intermediate CA keys, all RADIUS secrets, Pi-hole's records, the nginx/UFW config — *one Raspberry Pi, all of it.* **Current-design mapping (`ADR-0022`):** the estate now splits these — Vaultwarden on **BKP01**, the PKI is **AD CS** (RCA01 offline root → ICA01 sub-CA), DNS is Pi-hole (Pi01) **+ AD-DNS** (DCs). The *lesson is unchanged*: enumerate where every credential/key lives and extract it to offline media **before** you wipe anything.
- 🔴 **The bootstrap problem — a factory-reset device has no IP.** You have *no* network, not a degraded one. Each device has a documented way in with nothing (below).

Command detail (link down — `POL-0008`): the per-device Build Guides + `Architecture/` topology; `../Command-Library/*` for the per-platform read-backs. Why-it-works: `../Concepts/README.md` (bootstrap access; recovery paths are load-bearing).

## ① Pin it down (capture these first — they're the ticket)

- a. **Scope** — full estate teardown, or one device? (This page is the full cold-start; a single locked device → `Recover-a-Locked-Out-Router-Out-of-Band.md`.)
- b. **Where every credential + key lives** — the vault host, the CA host, the RADIUS/secret stores. **List them before touching anything** (the extraction inventory).
- c. **Restore or rebuild the CA?** — restore = every existing cert stays valid (fast); rebuild = new Root, reissue everything (slow, = a real post-compromise). For a *first* rebuild: **restore**; rebuild the CA as a separate later exercise.
- d. **Bootstrap kit ready?** — console cable **tested** (right baud), WinBox/PuTTY, a **static-IP profile**, the port map **on paper**, physical access to reset buttons/console ports/keyboard.
- e. **Drill or real?** — if a Game-Day, note the **start time** (the RTO clock) and treat it like change control (`POL-0003`).

## Phase 0 — Extraction (do this days before, not on the day)

- a. **Export the vault** (Vaultwarden web-UI export → `.json`) to **offline media — two copies, one off-site**. Verify it's openable.
- b. 🔴 **Print the device admin passwords on paper.** You'll be at a serial console with no computer that can open a JSON file — this is the actual failure mode, not paranoia.
- c. **Back up the CA** as a directory/artifact; decide restore-vs-rebuild now (Pin-it c).
- d. **Export every device config** (FGT `execute backup config`; MKT `/export` + `/system backup save`; Cisco `show running-config` capture; PVE `/etc/network/interfaces` + `qm config`) and **pull them all off-device** onto offline media.
- e. **Print the port map on paper** (you'll be behind a rack with no network).
- f. Run the Phase-0 checklist: vault exported+openable, passwords on paper, CA restore path decided, configs pulled, port map printed, **console cable tested now** (not at 2am), static-IP profile ready, reset buttons/console ports located.

## Phase 1 — Bootstrap access (talk to each device with nothing)

| Device | How to reach it with nothing | Watch out |
|---|---|---|
| **SW01** (Catalyst) | **Serial console — 9600 8N1**, no flow control. | 🔴 **9600, not 115200** (the 2960X); this has bitten before. |
| **MKT01** (RouterOS) | **WinBox → Neighbors → connect by MAC**, cable into **`ether4`**; select **one** row, click the **MAC** not the IP. | 🔴 **No serial console** historically (`ADR-0016`); **drops after ~15 s** — know your commands, set an IP, switch to a real session. Run WinBox as admin. → `Recover-a-Locked-Out-Router-Out-of-Band.md`. |
| **FGT01** (FortiGate) | `https://192.168.1.99` on the `internal` hard-switch ports (**internal3–7**); laptop static `192.168.1.10/24`. | The break-glass path — the very ports a careless hardening pass would shut (`Enumerate-Every-Enabled-Interface-Before-Hardening.md`). Console is the fallback. |
| **PVE01** (Proxmox) | **Physical keyboard + monitor FIRST.** | 🔴 iDRAC is **not** independent — shared LOM on the same NIC as the data path; it dies with SW01. Not available mid-teardown. |
| **Pi01 / Linux hosts** | Physical keyboard + monitor. | SSH is key-only on a non-standard port and won't exist yet. |

> 🔴 **Plug your workstation into MKT01's recovery segment (`bridgeLocal`, `ether4`) with a static IP — that's the recovery network; it exists precisely for this.** Don't rely on the VLAN-10 management network during a rebuild; it doesn't exist yet — you're building it.

## Phase 2 — Physical layer

- a. Cable per the **corrected, printed** port map; verify link lights **before** configuring anything.
- b. Confirm the deliberately-different natives (e.g. SW01 `Gi1/0/1` native 999 to MKT01, `Gi1/0/4` native 10 to PVE01) — making them "consistent" breaks PVE01.

## Phase 3 — Rebuild order (strict; validate each layer before the next)

1. **SW01 (Layer 2) — console only, no IP yet.** Real enable secret from the paper; VLANs (`show vlan brief`, not `show vlan`); mgmt SVI + gateway; STP root; trunks (native 999 vs 10); access ports, DHCP snooping, DAI, `STATIC-HOSTS`. 🔴 **Build the `STATIC-HOSTS` ACL from the source-of-truth host list, not a stale record** — a missing entry silently drops that host (`Diagnose-a-Host-Silently-Dropped-by-DAI.md`). Validate: `show interfaces trunk`, `show spanning-tree`, `show vlan brief`.
2. **MKT01 (Layer 3) — WinBox via MAC.** Password (real), identity; 🔴 **`bridge-trunk` on the SW01 trunk with `hw=no ingress-filtering=no`** — the single most critical line (get it wrong and the VLAN interfaces receive zero traffic while the link shows up); transit + default route; `bridgeLocal` (now your workstation has a route); the VLAN interfaces/gateways (no duplicates); the interface list *before* any firewall rule that references it; the full firewall ruleset incl. both catch-all drops. Validate: `/interface bridge port print detail` → `hw=no`; ping the transit peer.
3. **FGT01 (Perimeter).** Firmware, VDOM, hostname, timezone (string); split internal1/2 out of the hardware switch (purge DHCP+policy first or it won't parse); interfaces; 🔴 **static route `10.0.0.0/8` — not `/24`, or every VLAN silently loses its return path**; policy + NAT; **trusted hosts (keep console access first)**; DNS/NTP. Validate: ping the transit peer, then a public IP.
4. **Management plane.** All devices reachable from the mgmt VLAN before going further — if any fail, **stop; don't build on a broken layer.**
5. **Services + restore (Pi01 / the vault + CA hosts).** Base OS + static IP + key-only SSH; build the host firewall **while inactive**, verify, then enable and test a *fresh* session in a second window before closing the first; **restore the CA** (now every existing cert is valid again); restore DNS records (edit the file the service actually reads — `pihole.toml`, not `custom.list`); restore the vault + secrets (don't recreate deleted test accounts).
6. **Certificates + auth back on the devices.** Because you *restored* the CA, device certs are still valid but must be re-imported and re-bound — 🔴 **verify the FortiGate binding with `get`, not `show`** (`Confirm-a-Config-Change-Actually-Took.md`); on RouterOS note the cert gets renamed on import; for RADIUS, the client-side enable (`use-radius=yes`) didn't persist first time — re-check.
7. **PVE01.** Bridge VLAN-aware, mgmt IP, native VLAN on the uplink; **add the host's `STATIC-HOSTS` entries** or DAI silently drops it.

## Phase 4 — The real deliverable (the drill's whole point)

- a. **Keep a running log of every single time you had to leave the documentation** — every "wait, what was the…" where you reached for a chat log, a memory, or a guess. Each one is a documentation defect.
- b. At the end, that log becomes a batch of Change Records — worth more than the rebuild itself.
- c. If this was a Game-Day: **stop the clock, record the RTO**, file it against the DR catalogue (`ADR-0011`).

## Prove it's recovered

- a. Management plane: every device answers on its mgmt IP; inter-VLAN routing works; DNS resolves (`Recover-from-a-DNS-Outage.md` reflexes); time syncs (`Fix-the-SW01-Clock.md`).
- b. Certs served correctly on the wire (`openssl s_client` chain = 3); auth works end-to-end.
- c. The "left the docs" log is captured and turned into Change Records.
- d. 📸 the validated management-plane pings + a served cert chain. Mark ✅ only with the pasted read-backs (`POL-0001`); **no live secrets in captures** (`POL-0002`).

## If still broken

- Nothing works after MKT01 in a way that "looks like everything" → the `hw=no` line on the SW01 trunk (the #1 rebuild biter).
- A single VLAN-10 host is dark → `STATIC-HOSTS` missing its entry (`Diagnose-a-Host-Silently-Dropped-by-DAI.md`).
- Every VLAN loses its return path → the FGT `/24`-instead-of-`/8` route.
- A device is unreachable during bootstrap → its out-of-band path (`Recover-a-Locked-Out-Router-Out-of-Band.md`); check baud (9600 SW01), the MAC-WinBox port (`ether4`), the `192.168.1.99` FGT path.
- You can't find a credential → it was on the wiped host and wasn't extracted → this is exactly why Phase 0 exists; restore from the offline export.

## Related

- **Command-Library:** `../Command-Library/Cisco-IOS.md` · `../Command-Library/RouterOS.md` · `../Command-Library/FortiOS.md` · `../Command-Library/Linux.md` (the per-layer read-backs).
- **Concepts:** `../Concepts/README.md` (bootstrap access; recovery paths are load-bearing).
- **Decisions / owners:** frozen Lab-01 `Operations/048-Teardown-and-Rebuild-Runbook.md` (the anchor) + `Architecture/003-Physical-Topology` (the port map) · `ADR-0011` (Game-Day) · today's owners: `Devices/BKP01-Backup/` (Vaultwarden), `Devices/RCA01-ICA01-ADCS/` (the PKI), the DC pages (AD-DNS).
- **Sibling playbooks:** `Recover-a-Locked-Out-Router-Out-of-Band.md` · `Diagnose-a-Host-Silently-Dropped-by-DAI.md` · `Confirm-a-Config-Change-Actually-Took.md` · `Rotate-a-Leaked-Key-Before-You-Back-It-Up.md` · `Recover-from-a-DNS-Outage.md` · `Fix-the-SW01-Clock.md`.
- **Checklist (reciprocal, `ADR-0053` §8):** the commissioning checklists (`00-Atlas-Foundation/Templates/`) build a single device right; this rebuilds the estate — they share the "verify each read-back" discipline.
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).

## Worked log

| Date | Who | Time (RTO if a drill) | Scope | Left-the-docs count | Outcome |
|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the new **Symptoms & search terms** element `#32`). The estate's worst-day DR runbook / `ADR-0011` Game-Day: the two problems `048` solves — extraction (your credentials live on the host you wipe → extract to offline media + paper first) and bootstrap (a factory-reset device has no IP → per-device console/MAC/`192.168.1.99` access). Phase 0 extraction → Phase 1 bootstrap → Phase 2 physical → Phase 3 strict layer-by-layer rebuild (SW01→MKT01→FGT01→mgmt→services/restore→certs→PVE01) with the real biters called out (`hw=no`, `STATIC-HOSTS`, FGT `/8` route, 9600 baud, `get`-not-`show`) → Phase 4 the leave-the-docs log + RTO. Current-design-reconciled (`ADR-0022`): vault→BKP01, PKI→AD CS, DNS split. Grounded in frozen Lab-01 `048`. 🟡 until run. |
