---
Title: NPS01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server
Status: ⬜ NOT BUILT — NPS01 is planned. The `POL-0001` evidence home; every row ⬜ until a real read-back is captured. Records outrank guides.
Version: 0.1
Date: 2026-07-29
---

# NPS01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** The single "what is actually true right now" snapshot for the RADIUS host — the `POL-0001` evidence home. Outranks the Build-Guide (guide = target; this = reality). Each row cites where the evidence lives (`POL-0008`). Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

| Attribute | As-built target | Status | Evidence (when built) |
|---|---|---|---|
| Host / OS | NPS01 · Win Server 2025 (Desktop Experience) | ⬜ | `Diagnostics.md` §1 |
| Domain state / OU | member of `atlas.lab` · `OU=Servers,OU=Devices` | ⬜ | `Diagnostics.md` §2 |
| Addressing | `10.20.0.12` /VLAN 20 · gw `10.20.0.1` *(proposed)* | ⬜ | `IP-Addressing-Plan-VLSM` |
| Placement | PVE02/EQR6 (always-on core) | ⬜ | `ADR-0036` v1.2 |
| NPS role | `NPAS` installed; NPS service running | ⬜ | `Get-WindowsFeature NPAS` |
| AD registration | member of **RAS and IAS Servers** | ⬜ | `Diagnostics.md` §3 |
| RADIUS clients | MKT01 · SW01 · 1941 (secrets → Vaultwarden) | ⬜ | NPS console |
| Network policies | AD-group → privilege; deny-by-default | ⬜ | NPS console |
| Server cert (PEAP) | RAS-and-IAS-Server cert from ICA01 | ⬜ (gated on AD CS) | `Diagnostics.md` §3 |
| LAPS (local admin) | LAPS-managed (the member-server test) | ⬜ | `Get-LapsADPassword` |
| Break-glass proven | local admin works with NPS stopped | ⬜ | `Diagnostics.md` §4 |
| Acceptance (F14) | real device→NPS login OK + unknown rejected | ⬜ | `Diagnostics.md` §4 |

> 🔴 **Nothing here is built yet.** As each stage lands, capture the read-back in `Diagnostics.md`, flip the row ✅, and tick the `Build-Checklist.md` gate (`POL-0001`).

## Related
- `Build-Checklist.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md` · `ADR-0029`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the (empty) as-built record for NPS01 — all rows ⬜ (not built); fills in as each stage is device-verified. |
