---
Title: WAC01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center
Status: ⬜ NOT BUILT — planned. `POL-0001` evidence home; every row ⬜ until read-back. Records outrank guides.
Version: 0.1
Date: 2026-07-30
---

# WAC01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** `POL-0001` evidence home. Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

| Attribute | As-built target | Status | Evidence |
|---|---|---|---|
| Host / OS | WAC01 · Win Server 2025 | ⬜ | `Diagnostics.md` §1 |
| Placement | PVE02/EQR6 — always-on (`ADR-0036` v1.2) | ⬜ | `ADR-0036` |
| Domain / OU | member `atlas.lab` · `OU=Servers,OU=Devices` | ⬜ | `Diagnostics.md` §2 |
| Addressing | `10.10.0.5` / **VLAN 10 (mgmt)** *(proposed)* | ⬜ | `IP-Addressing-Plan-VLSM` |
| WAC gateway | installed, gateway mode, listening 443 | ⬜ | `Get-Service ServerManagementGateway` |
| Gateway TLS cert | ICA01-issued, correct SAN, bound (`ADR-0027`) | ⬜ | WAC settings → certificate |
| Access lockdown | PAW01-only (Tier-0 group role + 443 ACL) | ⬜ | WAC access + firewall/ACL + negative test |
| Managed nodes | DC01/DC02 + member servers over WinRM | ⬜ | WAC connections list |
| Delegation posture | Kerberos; no unconstrained CredSSP | ⬜ | config review |
| Acceptance | PAW-only TLS console + a managed action + non-PAW denied | ⬜ | `Diagnostics.md` §3 |
| Azure Arc (Phase 11) | onboarded (future) | ⬜ | deferred |

> 🔴 **Nothing built yet.** Flip rows ✅ as read-backs land (`POL-0001`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — empty as-built record for WAC01; all rows ⬜. Placement PVE02/EQR6, VLAN 10 (proposed). |
