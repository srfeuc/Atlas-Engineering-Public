---
Title: Playbook — Diagnose a Host Silently Dropped by DAI (the healthy device that looks dead)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on SW01 (🔧 **device-needed** — the `ACL Drops` counter + `show arp access-list` read-backs need an SW01 run under Lab-02 VLSM). Grounded in the real frozen **Lab-01** SW01 incident (`CM-0022` + SW01 `Troubleshooting`), current-design-reconciled (`ADR-0022`). Searchable/ticket-ready per Backlog **#32**. Format-aligned to the locked `ADR-0053` §5 mold.
Version: 1.1
Date: 2026-08-01
---

# Playbook — Diagnose a Host Silently Dropped by DAI

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: problem / silent-drop. **A static-IP host on a DAI-protected VLAN is unreachable — no ping, no SSH — yet the switch port shows `connected` and the device itself is healthy.** Dynamic ARP Inspection is dropping its ARP because its IP/MAC pair isn't in the switch's ARP ACL. There is **no error and no warning** — the host just *looks dead*. This page proves that's what's happening and puts the host back.

**Why this is a first-tier playbook (Backlog `#32`).** This is the canonical *"healthy device that looks dead."* In frozen Lab-01 the exact omission — Pi01 missing from the `STATIC-HOSTS` ACL — produced a phantom *"Pi01 is unreachable"* mystery that **survived three handoffs** before anyone thought to suspect the switch instead of the host (`016` lesson 6, `CM-0022`). It's the drop class that fails *silently*: everything you'd normally check on the host is green.

> 🔎 **Often first seen in monitoring.** A DAI-dropped host has its ARP dropped, so **LibreNMS can't reach it and shows it *down*** — even though it's physically up. That's the "up but shows down" hand-off from `Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md`: when its ladder finds *ping fails → it's connectivity, not SNMP*, DAI is a prime cause — you land **here**.

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **Grounded in** — Atlas's L2 protection + the real Lab-01 scar.
3. **① Pin it down** — the host's IP/MAC + port/VLAN; is the port even up.
4. **The diagnosis path** — host up + port `connected` → is DAI dropping ARP (`DHCP Permits: 0`) → is the IP/MAC in the ARP ACL → is it *supposed* to be blocked.
5. **Fix** (from the device, not memory) · **Prove it's recovered** · **If still broken**.
6. **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- "*Destination host unreachable*" / "*Request timed out*" pinging a host you know is up.
- "*ssh: connect to host … port 22: No route to host*" / connection times out.
- On the switch: the `ACL Drops` counter climbing under `show ip arp inspection` for that VLAN.
- 🟡 (real read-backs land on-device): `show interfaces status` for the port reads `connected`; `show arp access-list STATIC-HOSTS` does **not** list the host's IP/MAC.

**Plain-language symptom phrases**

- "the switch port is up but the host is dead."
- "looks connected but I can't reach it — ping and SSH both fail."
- "the device is fine, I can see it's powered and linked, but nothing can talk to it."
- "one host on the VLAN is unreachable and I have no idea why — no error anywhere."
- "it worked before we re-added it / rebuilt the switch and now it's gone."
- "the host shows **down / red in LibreNMS** but it's physically up and linked."
- "a phantom 'this host should be unreachable' mystery nobody can explain."

**Aliases / also-known-as**

- Dynamic ARP Inspection drop · DAI drop · ARP inspection blocking a host · ARP ACL drop.
- silent drop / dropped full stop / drops with no error / black-holed host.
- `STATIC-HOSTS` ACL missing an entry · ARP access-list missing a host · DHCP snooping binding missing.
- "arp-inspection killed my host" · "no snooping fallback."

**Keywords line**

`DAI` · `ip arp inspection` · `arp access-list` · `STATIC-HOSTS` · `DHCP Permits: 0` · `show ip arp inspection` · `show interfaces status` · `show arp access-list` · Catalyst 2960X · SW01 · VLAN 10 · IP/MAC binding · `CM-0022` · `016` lesson 6 · silent drop · healthy-device-looks-dead.

## Cert anchor

- **CCNA 5.0 Security Fundamentals** (DHCP snooping · Dynamic ARP Inspection) — the primary anchor.
- CompTIA **Security+** (Layer-2 attacks & mitigations; availability).
- *(Grounding index: `../Atlas-Certification-Lab-Map.md` — SW01's DAI is a real Atlas troubleshooting lab; `../Concepts/README.md` N2 DAI/DHCP-snooping is the why-it-works.)*

## Grounded in — Atlas's Layer-2 protection (and the real Lab-01 scar)

Know the mechanism before you diagnose (`POL-0008` — SW01's page owns these facts; this page links):

- **SW01** is the Catalyst 2960X access switch. DAI is enforced on the protected VLAN with an **ARP ACL** (`STATIC-HOSTS`); the uplink/trunk to PVE01 is the **trusted** port, everything else is untrusted (`../Command-Library/Cisco-IOS.md` §Security — DAI). Owner: `Devices/SW01-Access-Switch/`.
- 🔴 **The load-bearing detail:** when `show ip arp inspection` reports **`DHCP Permits: 0`**, there is **no DHCP-snooping fallback**. A host whose IP/MAC pair is *not* in the ARP ACL has its ARP **dropped, full stop** — no log on the host, no error, nothing. It simply appears to be a dead device.
- **The real incident (frozen Lab-01, `CM-0022` / `016` lesson 6):** a switch rebuild from a stale Build Guide produced a **four-entry** `STATIC-HOSTS` ACL where **five** were required — **Pi01 (`10.10.0.5` / `0000.5e00.5300`) was missing.** Pi01 (Root CA, vault, DNS, RADIUS) went dark with the port showing `connected`. The current design keeps the same switch and the same DAI mechanism; the addressing/VLAN layout is Lab-02's VLSM plan (frozen Lab-01 loses on addresses where it disagrees — `ADR-0022`). *The lesson is identical; only the IP/MAC list is today's.*

Command detail (link down — `POL-0008`): `../Command-Library/Cisco-IOS.md` §Security (DAI/DHCP-snooping) + §Interfaces (port state) + §Connectivity. Why-it-works: `../Concepts/README.md` (N2 — DHCP snooping → DAI binding chain).

## ① Pin it down (capture these first — they're the ticket)

- a. **The host** — which device, its **IP and MAC**, and which **switch port + VLAN** it lands on. (You'll compare this exact pair against the ACL.)
- b. **Expected vs actual** — it should ping/SSH; instead: total silence, or `Destination host unreachable` / timeout. No error on the host itself.
- c. **Scope** — just this one host, or several on the VLAN? (One host missing from the ACL = this page; a whole VLAN dark = a trunk/VLAN/gateway problem, not DAI — see *If still broken*.)
- d. **Timing / recent change** — did it start after a **switch rebuild**, an ACL edit, a host **NIC/MAC change**, or the host being re-IP'd? DAI silent drops almost always trace to "the binding no longer matches the host."
- e. **Is the port actually up?** — confirm `show interfaces status` says `connected` for that port. If it's `notconnect`/`err-disabled`, this is a different playbook (link/port-security), not DAI.

## The diagnosis path — cheapest, most-likely cause first

Run from an admin session on **SW01** unless noted. Read the runtime, never `show run` (`POL-0001`).

**1. Confirm the host is up and the port is connected (rule out the obvious).**

- a. On the host (or its console): it's powered, linked, and has its expected IP.
- b. On SW01, confirm the port state:
  - Command: `show interfaces status`
  - Reference: `../Command-Library/Cisco-IOS.md` §Interfaces.
  - Healthy: the host's port reads **`connected`**, correct access VLAN, 1 Gbps.
  - Broken (different problem): `notconnect` / `err-disabled` → not DAI; go to *If still broken*.
- → If the host is healthy **and** the port is `connected` but nothing can reach it, suspect DAI next. 📸 the `connected` port line (the "it's not the link" proof).

**2. Is DAI dropping ARP on this VLAN — and is there a snooping fallback?**

- a. Command: `show ip arp inspection`
  - Reference: `../Command-Library/Cisco-IOS.md` §Security (DAI).
  - Look for: DAI **enabled** on the host's VLAN, and the **`DHCP Permits`** value.
  - 🔴 Broken pattern: **`DHCP Permits: 0`** — there is *no* snooping fallback, so an unlisted IP/MAC is dropped with no error.
- b. Command: `show ip arp inspection statistics`
  - Broken: the VLAN's **`ACL Drops`** counter is **climbing** while the host tries to talk. That's the smoking gun — DAI is actively dropping it.
- → A rising `ACL Drops` for this VLAN + `DHCP Permits: 0` says: the host's pair isn't permitted. 📸 the statistics with the climbing `ACL Drops` (the finding).

**3. Is the host's exact IP/MAC pair in the ARP ACL?**

- a. Command: `show arp access-list STATIC-HOSTS`
  - Reference: `../Command-Library/Cisco-IOS.md` §Security.
  - Healthy: an entry `permit ip host <the-host-IP> mac host <the-host-MAC>` is present and **matches the device exactly**.
  - Broken: the host is **absent**, or present with the **wrong MAC** (e.g. after a NIC swap) — so DAI drops it.
- b. Read the host's real MAC off the **device itself**, never off a doc (the whole class of bug is a doc/device mismatch):
  - the host's own `ip link` / `ipconfig /all` / appliance interface page, or SW01 `show mac address-table interface <port>`.
- → A missing or mismatched entry is the cause. 📸 the ACL listing next to the host's real MAC (missing/mismatch = the answer).

**4. Confirm it's *supposed* to be reachable (don't "fix" a correct block).**

- a. Check the source-of-truth host/port table (`006`-style; today: `Devices/SW01-Access-Switch/` + the IP plan). If this host is *deliberately* not permitted, that's a change-request, not a fault (`ADR-0053` §5 Pin-it e).

## Fix — add (or correct) the binding, from the device, not from memory

- a. **Read the host's real IP + MAC off the live device** (step 3b). Never guess or copy an old doc value — a stale MAC is how this bug is born.
- b. Add (or correct) the ARP ACL entry on SW01:
  - `arp access-list STATIC-HOSTS`
  - ` permit ip host <host-IP> mac host <host-MAC>`
  - `exit`
  - (If an entry with the wrong MAC exists, remove it first with `no permit ip host <host-IP> …`.)
  - The exact commands are SW01's to run + read back (🟡 until pasted).
- c. **Save** so a reboot doesn't reintroduce the outage: `write memory` (and confirm `show archive` / startup == running).
- d. If today's design uses DHCP-snooping bindings instead of a static ACL for this host, add/repair the snooping binding rather than a static ACL line (`../Command-Library/Cisco-IOS.md` §Security) — same principle, the binding must match the host.

## Prove it's recovered

- a. From another host: `ping <host>` replies; the real service (SSH/HTTPS) connects — not just ICMP (`Test-a-Connection.md`, the ICMP≠TCP trap).
- b. On SW01: `show arp access-list STATIC-HOSTS` now lists the host with the **correct** MAC; `show ip arp inspection statistics` — the VLAN's **`ACL Drops` stops climbing**.
- c. 📸 the recovered ACL entry + the flat `ACL Drops` counter + the successful service test. Mark ✅ only with the pasted read-backs (`POL-0001`).

## If still broken

- **Several hosts / the whole VLAN dark, not just one** → not a single missing ACL entry. Suspect the **trunk/native-VLAN**, the SVI/gateway, or the E-W firewall → `Trace-a-Blocked-Flow.md`; work L1→up (`../Command-Library/Cisco-IOS.md` §Connectivity).
- **The pair is in the ACL and correct, but ARP still drops** → the port may be **untrusted where it should be trusted** (or vice-versa) — check DAI trust on the uplink/trunk; or DHCP snooping is mangling the binding.
- **Ping (ICMP) works but the service still fails** → it was never DAI; it's a service/port block → `Test-a-Connection.md` then `Trace-a-Blocked-Flow.md`.
- **It comes back, then dies again after a reboot** → the ACL edit wasn't saved, or the host's MAC changes (DHCP-assigned NIC / teaming) — pin the MAC.

## Related

- **Command-Library:** `../Command-Library/Cisco-IOS.md` (§Security DAI/DHCP-snooping · §Interfaces · §Connectivity).
- **Concepts:** `../Concepts/README.md` (N2 — DHCP snooping → DAI binding chain, why-it-works).
- **Decisions / owners:** `Devices/SW01-Access-Switch/` (the switch's facts + `Troubleshooting.md` silent-DAI entry) · the IP-Addressing plan (the host/port table).
- **Sibling playbooks:** `Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md` (**the monitoring hand-off** — a DAI-dropped host shows *down* in LibreNMS; that page's ping-fails branch points here) · `Trace-a-Blocked-Flow.md` (whole-path enforcement trace) · `Test-a-Connection.md` (ping ≠ service — the reachability fallacy) · `Domain-Join-Fails.md` (cites this silent-drop class as a join cause) · `Reconcile-a-Build-Guide-That-Rebuilds-a-Broken-Device.md` (the `CM-0022` cause: a rebuild that omits the entry) · `Recover-the-Lab-from-a-Bare-Metal-Teardown.md` (build the ACL from the source-of-truth, not a stale record).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal this page is optimised for).
- **Real lineage:** frozen Lab-01 `Devices/SW01-Access-Switch/Changes/CM-0022` (the rebuild that dropped Pi01 four ways) · `Devices/SW01-Access-Switch/Troubleshooting.md` (the silent-DAI-drop incident) · `Operations/016-Network-Lessons-Learned.md` lesson 6 (the phantom that survived three handoffs) — `ADR-0022`-reconciled.

## Worked log

| Date | Who | Time | Host | IP/MAC | Cause found | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-08-01 | **Format-aligned to the locked mold + SNMP cross-link** (Playbook Format-Alignment Audit, row 7; the SNMP-paired page). Added the **On this page** index and the **monitoring hand-off** — a DAI-dropped host shows *down* in LibreNMS, so `Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device` (its ping-fails branch) points here; added the "down in LibreNMS but physically up" symptom + the sibling link. Flagged 🔧 device-needed (the `ACL Drops` read-back needs an SW01 run under Lab-02 VLSM). Content otherwise unchanged. |
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, the golden mold + the new **Symptoms & search terms** element `#32`). The canonical "healthy device that looks dead" — a static host silently dropped by DAI because its IP/MAC pair is absent from SW01's `STATIC-HOSTS` ARP ACL with `DHCP Permits: 0` (no snooping fallback). Diagnosis path: confirm host up + port `connected` → `show ip arp inspection` (+ statistics `ACL Drops`) → `show arp access-list` vs the host's real MAC → is-it-supposed-to-be-blocked; fix by reading the real IP/MAC off the device and adding the binding, save, prove with a service test + flat `ACL Drops`. Grounded in the frozen Lab-01 `CM-0022`/`016` lesson-6 Pi01 incident (`ADR-0022`-reconciled). 🟡 until worked on SW01. |
