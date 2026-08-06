---
Title: [Device] Diagnostics — Show Commands & Verification
Path: [Labs/Lab-02-Cisco-Core/Devices/<Device>]
Status: Template (ADR-0032). Copy per device; author commands as the device is built, mark each 🟡 until a read-back confirms it.
Version: 0.1
---

# [Device] — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **What this page is (ADR-0032):** the quick per-device **"is it built and connected correctly?"** commands — install/role verification, addressing, service-up, links to other devices, DNS/IP tests, and where the logs are. **Not** break-fix — for symptom → fix, see this device's **`Troubleshooting.md`**. **Not** the exhaustive list — for the full command library (by service, platform, and failure-category), see **Atlas Academy** (linked at the bottom).
>
> **Marker convention (ADR-0032):** ✅ device-verified (command run, output pasted) · 🟡 operator-reported / lab-unverified · ⏳ in build · 📋 planned. **Nothing is ✅ without a read-back (`POL-0001`).** Author commands from knowledge/official docs; **never assume output.**

## How to read each entry
Every check below is: **When to run** → **Command** → **Expected (healthy)** → **Verified?** (✅/🟡 + date) → **Grounds** (the doc/claim it confirms). If a check is failing, jump to the matching symptom in `Troubleshooting.md`.

---

## 1. Installation / role verification
*When: right after building the VM or installing a role/feature/service — before ticking any build-checklist box.*

| Check | When to run | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|---|
| [VM up / guest agent] | after clone + first boot | `[cmd]` | `[healthy output]` | 📋 | [Build-Guide step] |
| [role/feature installed] | after install | `[cmd]` | `[healthy output]` | 📋 | [Build-Guide step] |
| [service running/enabled] | after config | `[cmd]` | `[healthy output]` | 📋 | [Build-Checklist item] |

## 2. Identity & addressing
*When: after setting hostname / IP / DNS / gateway / domain-join — confirm the box is who and where the IP plan says.*

| Check | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| Hostname | `[cmd]` | `[name]` | 📋 | — |
| IP / mask / gateway | `[cmd]` | `[10.x / /26 / .1]` | 📋 | `IP-Addressing-Plan-VLSM` |
| DNS resolver(s) | `[cmd]` | `[10.20.0.2 …]` | 📋 | — |
| Domain membership (if joined) | `[cmd]` | `[atlas.lab]` | 📋 | — |
| VLAN / mgmt interface | `[cmd]` | `[VLAN 20 / tagged 10]` | 📋 | — |

## 3. Service-up checks (this device's own services)
*When: after the service is configured, and any time you suspect it's down. For "it's down," cross-link to `Troubleshooting.md` → Service Down.*

| Service | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| [service] | `[cmd]` | `[listening / active / synced]` | 📋 | — |

## 4. Inter-device link checks (reciprocal — test BOTH ends)
*When: after a dependency is wired (this device ↔ another). If a link is in doubt, run the check on **both** devices and note which side fails — that localizes the fault.*

| Link | From THIS device | From the OTHER device | Expected (healthy) | Verified? |
|---|---|---|---|---|
| [→ DC01 DNS/LDAPS] | `[cmd from here]` | `[cmd from DC01]` | `[both succeed]` | 📋 |
| [→ MKT01 gateway] | `[cmd]` | `[cmd on MKT01]` | `[reachable both ways]` | 📋 |
| [→ NPS01 RADIUS 1812/1813] | `[cmd]` | `[cmd on NPS01]` | `[auth flow completes]` | 📋 |

## 5. DNS tests
*When: any name-resolution doubt; after DNS/conditional-forwarder changes.*

| Test | Command | Expected (healthy) | Verified? |
|---|---|---|---|
| Resolve a domain host | `[cmd]` | `[A record / IP]` | 📋 |
| Resolve external | `[cmd]` | `[resolves via forwarder]` | 📋 |
| Reverse / SRV (AD) | `[cmd]` | `[expected record]` | 📋 |

## 6. IP / connectivity troubleshooting entry points
*When: no/partial connectivity. Work L1 → up (link, VLAN/ARP, gateway/route, firewall, service).*

| Layer | Command | What it tells you | Verified? |
|---|---|---|---|
| L1/L2 link + VLAN | `[cmd]` | [link/speed/VLAN] | 📋 |
| L3 gateway/route | `[cmd]` | [reachable gw / route present] | 📋 |
| Firewall/path (MKT01 east-west) | `[cmd]` | [allowed by the flow matrix] | 📋 |

## 7. Logging & event sources
*Where this device's logs live and how to pull them; how they reach MON01.*

| Source | How to view | What to look for | Verified? |
|---|---|---|---|
| [local log / Event Viewer channel] | `[cmd / path]` | `[key events]` | 📋 |
| Ships to MON01? | `[cmd]` | `[syslog/SNMP delivered]` | 📋 |

---

## If you built or changed this device solo (ADR-0032 handoff protocol)
Paste the read-backs for whatever you changed (VM / role / IP / DNS / mgmt-interface / service) so the next session can flip the 🟡s to ✅ from evidence. Mirror the summary into **`SESSION-HANDOFF.md` → Solo-work sync** and **`Operations/Device-Confirmation-Commands.md`**.

## Related
- **`Troubleshooting.md`** (this device) — symptom → fix.
- **Atlas Academy** (`Atlas-Academy/…`) — the master command library (by service, platform, and failure-category).
- **`Build-Guide` / `Build-Checklist`** (this device) — how it was built (the source of the "expected" values).
- **`Build-Progress-Tracker.md`** — Connectivity matrix + Verify-on-resume.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Template created under `ADR-0032` — per-device show/verify quick-reference (install/role verification, identity+addressing, service-up, reciprocal inter-device link checks, DNS tests, IP troubleshooting entry points, logging sources) with the ✅/🟡/⏳/📋 marker convention and the solo-work handoff hook. Companion to the per-device `Troubleshooting.md` and the Atlas Academy command library. |
