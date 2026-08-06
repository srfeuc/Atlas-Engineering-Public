---
Title: 1941 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: 🟢 LIVING — the verified as-built state of the routed core. Phase-2 core device-verified (07-21/07-22). Records outrank guides (POL-0001); evidence = the Diagnostics show-read-backs.
Version: 0.1
Date: 2026-07-30
---

# 1941 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The "what is actually true right now" snapshot for the core router. It **outranks the Build-Guide** (guide = target state; this = reality). Each row cites where the evidence lives (`POL-0008`). Markers: ✅ device-verified · 🟡 lab-unverified · ⬜ not built.

## 1941 — Cisco 1941 ISR G2 · IOS 15.5(3)M4 universalk9  (routed core, `ADR-0023`)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Platform / IOS | Cisco 1941 ISR G2, IOS 15.5(3)M4 universalk9 | ✅ | `show version` (`Build-Guide.md`) |
| SSH mgmt plane | SSHv2-only, CTR ciphers, DH ≥ 2048; vty `MGMT-SSH` access-class | ✅ (07-22) | `Diagnostics.md` §1 · `CIS-Hardening-1941` |
| Named admin / secrets | `ciscoadmin` priv 15, Type-9 secrets; no http/telnet | ✅ (07-22) | `Diagnostics.md` §1/§3 |
| Interfaces | Gi0/1 `10.255.255.2` (→FGT), Gi0/0 `10.255.255.5` (→MKT), Lo0 `10.255.0.1`; no VLANs/SVI | 🟡 up/up read-back pending | `Diagnostics.md` §2/§6 |
| OSPF | area 0, RID `10.255.0.1`, two /30s only, `passive-interface Gi0/1`; **adjacency MKT01 FULL** | ✅ (07-21) | `Diagnostics.md` §4 |
| Default route | static → FGT01 `10.255.255.1`, `default-information originate` | 🟡 read-back pending | `Diagnostics.md` §3 |
| NTP | client → `ADR-0020` source; **converging** | ✅ converging (07-22) | `Diagnostics.md` §2 |
| Pass-2 RADIUS (NPS01) | not applied | ⬜ | — (gated, `ADR-0029`) |
| SNMPv3 / syslog / NetFlow → MON01 | not built | 📋 | — (Phase 4/6) |

> 🔴 **Outstanding read-backs to flip 🟡→✅:** `show ip interface brief` (up/up), `show ip route` (VLANs via `10.255.255.6` + default via `10.255.255.1`), `show ip protocols` (OSPF transit-only). Paste into `Diagnostics.md` (`POL-0001`).

## Related
- `Diagnostics.md` (the verify commands + ✅ evidence) · `Build-Guide.md` (target) · `Build-Checklist.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — consolidated the 1941's device-verified as-built state from the Build-Guide/Diagnostics (platform/IOS, SSH crypto/vty/secrets, OSPF FULL with MKT01, NTP converging — 07-21/07-22) into the single as-built snapshot; interface up/up + routing-table + default-route rows 🟡 pending read-back; Pass-2 RADIUS ⬜ gated; MON01 telemetry 📋 Phase 4/6. Records outrank guides (`POL-0001`). |
