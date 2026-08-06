---
Title: SW01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch
Status: 🟢 LIVING — the verified as-built state of the L2 access switch. Pass-1 + core L2 device-verified (07-22). Records outrank guides (POL-0001); evidence = the Diagnostics show-read-backs.
Version: 0.1
Date: 2026-07-30
---

# SW01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The "what is actually true right now" snapshot for the access switch. It **outranks the Build-Guide** (guide = target; this = reality). Each row cites where the evidence lives (`POL-0008`). Markers: ✅ device-verified · 🟡 lab-unverified · ⬜ not built.

## SW01 — Cisco Catalyst 2960X · IOS 15.x  (L2 access/distribution, `ADR-0023`)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Platform / mode | Catalyst 2960X, IOS 15.x; **pure L2** (no `ip routing`) | ✅ (07-22) | `Diagnostics.md` §1 |
| SSH mgmt plane | SSHv2-only, CTR ciphers, DH 2048; named admin `ciscoadmin`; no http/telnet; no v2c SNMP | ✅ (07-22) | `Diagnostics.md` §1/§3 · `CIS-Hardening-SW01` |
| Mgmt SVI | `Vlan10 = 10.10.0.2` up/up; `Vlan1` admin-down | ✅ (07-22) | `Diagnostics.md` §2 |
| NTP | synchronized, stratum 3 (`*~10.20.0.2`) | ✅ (07-22, `CM-0030`) | `Diagnostics.md` §2 |
| VLANs | 10–90 + native 999 defined | 🟡 read-back pending | `Diagnostics.md` §2 (`show vlan brief`) |
| Trunks | `Gi1/0/1`→MKT01 (all VLANs); `Gi1/0/4`→PVE01 (native 999) | 🟡 read-back pending | `Diagnostics.md` §4 |
| SPAN | `Gi1/0/5` monitor session → MON01 (mirror of MKT01 trunk) | 🟡 / 📋 (with MON01) | `ADR-0032` |
| DHCP snooping / DAI | snooping enabled; DAI list hand-typed (→ NetBox Phase 4) | 🟡 | `Diagnostics.md` §3 |
| Port security / unused shut | MAC limits; unused ports shut; Pi01 `Gi1/0/7` never shut | 🟡 read-back pending | `Diagnostics.md` §6 |
| Pass-2 RADIUS (NPS01) | not applied | ⬜ | — (gated, `ADR-0029`) |
| SNMPv3 / syslog → MON01 | not built | 📋 | — (Phase 4/6) |

> 🔴 **Outstanding read-backs to flip 🟡→✅:** `show vlan brief`, `show interfaces trunk`, `show monitor session all`, `show ip dhcp snooping`, `show interfaces status`. Paste into `Diagnostics.md` (`POL-0001`).

## Related
- `Diagnostics.md` (the verify commands + ✅ evidence) · `Build-Guide.md` (target) · `Build-Checklist.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — consolidated SW01's device-verified as-built state from the Build-Guide/Diagnostics (pure-L2, SSH crypto/named-admin/no-cleartext, `Vlan10` SVI up + `Vlan1` down, NTP stratum-3 — 07-22) into the single as-built snapshot; VLANs/trunks/SPAN/DAI/port rows 🟡 pending read-back; Pass-2 RADIUS ⬜ gated; MON01 telemetry 📋 Phase 4/6. Records outrank guides (`POL-0001`). |
