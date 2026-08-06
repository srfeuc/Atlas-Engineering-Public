---
Title: SQL01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database
Status: ⬜ NOT BUILT — planned. `POL-0001` evidence home; every row ⬜ until read-back. Records outrank guides.
Version: 0.1
Date: 2026-07-30
---

# SQL01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** `POL-0001` evidence home. Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

| Attribute | As-built target | Status | Evidence |
|---|---|---|---|
| Host / OS | SQL01 · Win Server 2025 | ⬜ | `Diagnostics.md` §1 |
| Placement | PVE01/R410; data/log on a vdisk | ⬜ | `ADR-0036` v1.2 |
| Domain / OU | member `atlas.lab` · `OU=Servers,OU=Devices` | ⬜ | `Diagnostics.md` §2 |
| Addressing | `10.20.0.16` / VLAN 20 *(proposed)* | ⬜ | `IP-Addressing-Plan-VLSM` |
| gMSA (A1) | `svc-gmsa-sql`; `Test-ADServiceAccount`=True; SPN ok | ⬜ | `Diagnostics.md` §3 |
| SQL Server | installed; Windows-auth; engine+Agent under the gMSA | ⬜ | `Get-Service MSSQL*` |
| Memory cap | max-server-memory set | ⬜ | `sp_configure` |
| TLS (ICA01) | Server-Auth cert bound; Force Encryption | ⬜ (gated on AD CS) | `Diagnostics.md` §3 |
| Firewall | TCP 1433 scoped to app/admin | ⬜ | `Get-NetFirewallRule` |
| DBs + logins | app DBs; AD-group logins; least-priv; sysadmin near-empty | ⬜ | SSMS |
| Backups → BKP01 + restore tested | native backups shipped; a restore proven | ⬜ (🔴 `POL-0005`) | BKP01 + restore |
| Always On AG (later) | SQL01 = one replica; listener VIP | ⬜ | `ADR-0046` |

> 🔴 **Nothing built yet.** Flip rows ✅ as read-backs land (`POL-0001`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — empty as-built record for SQL01; all rows ⬜. |
