---
Title: RDS01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop
Status: ⬜ NOT BUILT — planned. `POL-0001` evidence home; every row ⬜ until read-back. Records outrank guides.
Version: 0.2
Date: 2026-07-30
---

# RDS01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** `POL-0001` evidence home. Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

| Attribute | As-built target | Status | Evidence |
|---|---|---|---|
| Host / OS | RDS01 · Win Server 2025 | ⬜ | `Diagnostics.md` §1 |
| Placement | PVE02/EQR6 — always-on (`ADR-0036` v1.2) | ⬜ | `ADR-0036` |
| Domain / OU | member `atlas.lab` · `OU=Servers,OU=Devices` | ⬜ | `Diagnostics.md` §2 |
| Addressing | `10.20.0.17` / VLAN 20 *(proposed)* | ⬜ | `IP-Addressing-Plan-VLSM` |
| RDS roles | RD Session Host + Licensing + Gateway/Web | ⬜ | `Get-WindowsFeature RDS-*` |
| Session collection | created; access by AD group (standard, no T0) | ⬜ | Server Manager / `Get-RDSessionCollection` |
| Licensing | license server activated; CALs installed | ⬜ | RD Licensing Diagnoser |
| TLS cert (gateway/RDP) | ICA01-issued, correct SAN, bound (`ADR-0027`) | ⬜ | Deployment Properties → Certificates |
| Gateway CAP/RAP | on NPS01, deny-by-default, AD-group keyed (`ADR-0029`) | ⬜ | NPS console + a test auth |
| Session GPOs | redirection/limits/hardening applied | ⬜ | RSoP |
| Tier separation | Tier-0 denied via RDS (`ADR-0021`) | ⬜ | negative test |
| Acceptance | published app via gateway/TLS + NPS log | ⬜ | `Diagnostics.md` §3 |

> 🔴 **Nothing built yet.** Flip rows ✅ as read-backs land (`POL-0001`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-30. Placement → **PVE02/EQR6 always-on** (`ADR-0036` v1.2); RDS roles now include **Gateway/Web** (operator decisions). Still all ⬜ — not built. |
| 0.1 | 2026-07-30. Created — empty as-built record for RDS01; all rows ⬜. |
