---
Title: SQL01 — SQL Server Build Guide (phased, gated)
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database
Status: 📋 Target design — phased, gated rebuild contract (`ADR-0043`); mirrors `Roadmap.md`. NOT executed. Author live values + 📸 + gotchas at the bench (`POL-0001`). You write the config (Charter Rule 17).
Version: 0.1
Date: 2026-07-30
---

# SQL01 — SQL Server Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — MS SQL Server on Win Server 2025, PVE01/R410. Work **phase by phase, each behind its 🔴 GATE**. Secrets → Vaultwarden (`POL-0002`).

## Phase 0 — Gate 🔴
**GATE:** DC healthy (AD+DNS) · **KDS root key** present (gMSA).

## Phase 1 — Host stand-up 🔴
**GATE:** Phase 0 ✅.
- **Service-setup:** clone Win Server 2025 → SQL01 → domain-join → `OU=Servers,OU=Devices` → `gpupdate`; add a **data/log vdisk**. 📸 domain/OU, vdisk.

## Phase 2 — gMSA (Tier-A A1) 🔴
**GATE:** Phase 1 ✅.
- **Service-setup:** `New-ADServiceAccount svc-gmsa-sql` → grant SQL01 retrieval → `Install-ADServiceAccount` on SQL01 → `Test-ADServiceAccount` = True; confirm the **SPN**. 📸 the test result.

## Phase 3 — SQL Server install 🔴
**GATE:** Phase 2 ✅ (gMSA ready).
- **Service-setup:** install SQL Server (Developer edition for lab); **Windows auth**; run engine + Agent under **`svc-gmsa-sql`**; set **max server memory**; TempDB per MS guidance; data/log → the vdisk; scope **TCP 1433** on the host firewall. 📸 the services running as the gMSA.

## Phase 4 — Certificate application (from ICA01) 🔴
**GATE:** AD CS ceremony complete.
- **Certificate-application:** enrol a **Server-Auth** cert from ICA01 → SQL Configuration Manager → bind + **Force Encryption**. 📸 the cert bound; a TLS connection.

## Phase 5 — Databases + backups 🔴
**GATE:** Phase 3 ✅; BKP01 built for the backup copy.
- App DBs; **logins by AD group**, least-privilege; `sysadmin` near-empty. Native **backups + Agent jobs → BKP01**; 🔴 **test a restore** (`POL-0005`). 📸 the restore.

## Phase 6 — Acceptance + automation-onboarding (`ADR-0048`) 🔴
- 🎯 Windows-auth-over-TLS connect; engine under the gMSA; a BKP01 restore. Then DSC/DBATools → `../Automation/`.

## Phase 7 — Always On AG (later, `ADR-0046`) 🔴
**GATE:** the failover-cluster lab.
- SQL01 = one AG replica; 2nd node on the other host; **listener VIP + CNO** into the IP plan; quorum/witness per `ADR-0046`.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Diagnostics.md` · `ADR-0046` (AG) · Tier-A A1 (gMSA) · `../RCA01-ICA01-ADCS/` (the TLS cert) · `Atlas-Academy/Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — phased, gated Build-Guide (`ADR-0043`) mirroring `Roadmap.md`: gate → host+vdisk → gMSA/A1 → install/Win-auth/memory-cap/1433 → ICA01 TLS → DBs/backups+restore → acceptance+automation → Always On AG. 📸 points; click-by-click at the bench. |
