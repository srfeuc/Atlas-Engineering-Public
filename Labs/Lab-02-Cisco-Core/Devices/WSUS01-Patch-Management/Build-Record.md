---
Title: WSUS01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management
Status: ⬜ NOT BUILT — planned. `POL-0001` evidence home; every row ⬜ until read-back. Records outrank guides.
Version: 0.1
Date: 2026-07-30
---

# WSUS01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** `POL-0001` evidence home. Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

| Attribute | As-built target | Status | Evidence |
|---|---|---|---|
| Host / OS | WSUS01 · Win Server 2025 | ⬜ | `Diagnostics.md` §1 |
| Placement | PVE01/R410 (spin-up) | ⬜ | `ADR-0036` v1.2 |
| Domain / OU | member `atlas.lab` · `OU=Servers,OU=Devices` | ⬜ | `Diagnostics.md` §2 |
| Addressing | `10.20.0.15` / VLAN 20 *(proposed)* | ⬜ | `IP-Addressing-Plan-VLSM` |
| Content store | own vdisk (100 GB+) | ⬜ | `Get-Volume` |
| WSUS role + DB | UpdateServices installed; WID (or SQL01) | ⬜ | `Get-WindowsFeature UpdateServices` |
| First sync | products/classifications synced | ⬜ | WSUS console |
| Target groups (GPO) | Servers/Clients/Tier-0 by OU | ⬜ | GPO + a client check-in |
| Approval rings | pilot → broad + cleanup schedule | ⬜ | WSUS console |
| Acceptance | pilot install + compliance report | ⬜ | `Diagnostics.md` §3 |

> 🔴 **Nothing built yet.** Flip rows ✅ as read-backs land (`POL-0001`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — empty as-built record for WSUS01; all rows ⬜. |
