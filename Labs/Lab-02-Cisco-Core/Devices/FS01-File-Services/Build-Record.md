---
Title: FS01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services
Status: ⬜ NOT BUILT — planned. The `POL-0001` evidence home; every row ⬜ until a real read-back. Records outrank guides.
Version: 0.1
Date: 2026-07-30
---

# FS01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** The "what is actually true now" snapshot for the file server (`POL-0001`; outranks the Build-Guide). Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

| Attribute | As-built target | Status | Evidence (when built) |
|---|---|---|---|
| Host / OS | FS01 · Win Server 2025 | ⬜ | `Diagnostics.md` §1 |
| Placement | PVE02/EQR6; data on the 8 TB external | ⬜ | `ADR-0036` v1.2 |
| Domain / OU | member `atlas.lab` · `OU=Servers,OU=Devices` | ⬜ | `Diagnostics.md` §2 |
| Addressing | `10.20.0.14` / VLAN 20 *(proposed)* | ⬜ | `IP-Addressing-Plan-VLSM` |
| Sizing (🟡 proposed) | 2 vCPU / 4 GB / 60 GB OS / data-on-8TB | ⬜ | Backlog #20 finalizes |
| Roles | File Server · FSRM · DFS NS+R | ⬜ | `Get-WindowsFeature` |
| Shares (AGDLP) | groups-only ACLs; HR/ENG/IT/... | ⬜ | `Get-SmbShareAccess` |
| DFS namespace | `\\atlas.lab\<ns>` + targets | ⬜ | `Get-DfsnRoot` |
| VSS | Shadow Copies on the data volume | ⬜ | `vssadmin list shadows` |
| FSRM | quotas + file-screens | ⬜ | FSRM console |
| GPO drive maps | users mapped to the DFS path | ⬜ | `gpresult` / a client |
| Backed up (BKP01) + restore tested | data protected, restore proven | ⬜ (🔴 `POL-0005`) | BKP01 job + restore |
| HR→HR ✓ / HR→IT ✗ | the `ADR-0042` access proof | ⬜ | `../../Operations/Validation-and-Adversarial-Testing.md` |

> 🔴 **Nothing built yet.** As each stage lands, capture the read-back in `Diagnostics.md`, flip the row ✅, tick the `Build-Checklist.md` gate (`POL-0001`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created as the (empty) as-built record for FS01 — all rows ⬜; fills in as each stage is device-verified. |
