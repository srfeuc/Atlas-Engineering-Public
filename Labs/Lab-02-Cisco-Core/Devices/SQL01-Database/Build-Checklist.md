---
Title: SQL01 — Build Checklist (SQL Server)
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database
Status: 📋 Target design — line-item, dated, evidence-backed (`POL-0001`). Mirrors `Roadmap.md`. Supersedes the v0.1 stub.
Version: 1.0
Date: 2026-07-30
---

# SQL01 — Build Checklist (SQL Server)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** MS SQL Server on Win Server 2025 member. Placement **PVE01/R410**, data/log on a vdisk, VLAN 20 `10.20.0.16` *(proposed)*. Detail: `Build-Guide.md`.

## Phase 0 — Gate
- [ ] 🔴 DC healthy (AD+DNS) · **KDS root key** present (for the gMSA).

## Phase 1 — Host stand-up
- [ ] Clone Win Server 2025 → **SQL01**; domain-join → `OU=Servers,OU=Devices` → `gpupdate`; add a **data/log vdisk**.
- **🎯 Gate:** domain-joined, correct OU, vdisk online.

## Phase 2 — gMSA (Tier-A A1)
- [ ] Create **`svc-gmsa-sql`**; grant SQL01 retrieval; `Install-ADServiceAccount` on SQL01; confirm the SPN.
- **🎯 Gate:** `Test-ADServiceAccount svc-gmsa-sql` = True.

## Phase 3 — SQL Server install
- [ ] Install SQL Server (2022/2025, **Developer** for lab); **Windows auth**; engine + Agent under the **gMSA**; **max-server-memory cap** set; TempDB per MS guidance; data/log on the vdisk.
- [ ] Scope **TCP 1433** on the host firewall (app/admin sources only).
- **🎯 Gate:** engine + Agent running under the gMSA (no stored password).

## Phase 4 — TLS (ICA01)
- [ ] Enrol a **Server-Auth cert** from ICA01; bind it; **Force Encryption**.
- **🎯 Gate:** a client connects **over TLS**, cert trusted (chains to ICA01→RCA01).

## Phase 5 — Databases + backups
- [ ] App DBs; **logins by AD group**, least-privilege roles; `sysadmin` near-empty.
- [ ] 🔴 **Native backups + Agent jobs → BKP01**; **test a restore** (`POL-0005`).
- **🎯 Gate:** a DB **restores** from the BKP01 path.

## Phase 6 — Acceptance
- [ ] 🎯 Windows-auth-over-TLS connect works; engine under the gMSA; a restore succeeds.

## Phase 7 — Always On AG (later, `ADR-0046`)
- [ ] SQL01 = one AG replica; 2nd node on the other host; **listener VIP + CNO** into the IP plan.

## Phase 8 — Automation onboarding (`ADR-0048`)
- [ ] DSC/DBATools install+config + backup jobs → `Automation/`.

## Failure modes
- 🔴 **No tested restore** — backups you never restored aren't backups (`POL-0005`).
- 🔴 **gMSA SPN wrong** → Kerberos/Windows-auth fails; `setspn`/`Test-ADServiceAccount`.
- 🔴 **No max-memory cap** → SQL starves the R410 host.
- 🟡 **Mixed-mode + `sa` in git** → credential risk (`POL-0002`); Windows-auth, vault any SQL logins.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Rebuilt to the standard (DC-template replication, Batch A) — phased with 🎯 gates (host → gMSA/A1 → install/Win-auth/1433 → ICA01 TLS → DBs/backups → acceptance → Always On AG → automation), and the backup/gMSA-SPN/memory-cap/mixed-mode failure modes. Supersedes the v0.1 stub. |
