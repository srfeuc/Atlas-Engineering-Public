---
Title: SQL01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database
Status: 📋 Seeded (`ADR-0032`). SQL01 = SQL Server, VLAN 20 `10.20.0.16` (proposed). **📋 not built** — 🟡/📋 until read-backs. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# SQL01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **SQL01** (Win Server 2025 + SQL Server) — Role: database host.

> **What this is (`ADR-0032`):** "is SQL built + is it running under the gMSA, TLS-encrypted, and restorable?" The distinctive SQL discipline is proving the **gMSA (no password)**, **TLS**, and a **restore**. Break-fix → `Troubleshooting.md`; deep set → Academy `Command-Library/PowerShell-Tier0.md`.

## 1. Install / service
| Check | Command | Expected | Verified? |
|---|---|---|---|
| SQL services | `Get-Service MSSQLSERVER, SQLSERVERAGENT` | Running | 📋 |
| Runs under the gMSA | `Get-CimInstance Win32_Service -Filter "Name='MSSQLSERVER'" \| Select StartName` | `ATLAS\svc-gmsa-sql$` | 📋 |
| Version/edition | `SELECT @@VERSION` | SQL 2022/2025, Developer (lab) | 📋 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Domain / OU | `Get-ADComputer SQL01 -Properties DistinguishedName` | `atlas.lab` · `OU=Servers,OU=Devices` | 📋 |
| IP / VLAN | `Get-NetIPConfiguration` | `10.20.0.16` / VLAN 20 | 📋 |
| gMSA healthy | `Test-ADServiceAccount svc-gmsa-sql` | True | 📋 |

## 3. Security posture
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| TLS bound | SQL Config Manager → Certificate; `Force Encryption=Yes` | ICA01 Server-Auth cert bound | 📋 (gated on AD CS) |
| A client connects over TLS | `sqlcmd -S sql01.atlas.lab -E -N` | connects; `ENCRYPT_OPTION`=TRUE | 📋 |
| Auth mode | `SELECT SERVERPROPERTY('IsIntegratedSecurityOnly')` | 1 (Windows-only) | 📋 |
| AD-group logins | `SELECT name,type_desc FROM sys.server_principals` | AD groups, not per-user/SQL logins | 📋 |
| sysadmin membership | `SELECT ... sysadmin role members` | near-empty (named admins only) | 📋 |
| Max memory cap | `sp_configure 'max server memory'` | a cap set (not default 2 PB) | 📋 |
| 1433 scoped | `Get-NetFirewallRule`/`Test-NetConnection sql01 -Port 1433` | reachable from app/admin only | 📋 |

## 4. Backups / restore (`POL-0005`)
| Check | Where | Expected | Verified? |
|---|---|---|---|
| Native backups run | `msdb.dbo.backupset` / Agent job history | recent successful backups | 📋 |
| Copied to BKP01 | BKP01 job | backups landed off-box | 📋 |
| 🔴 Restore tested | restore a test DB from the BKP01 copy | restores cleanly | 📋 |

## If you built/changed SQL01 solo (`ADR-0032`)
Paste read-backs (services under the gMSA, `Test-ADServiceAccount`, a TLS connect, a restore) → next session flips 📋→✅; mirror into `SESSION-HANDOFF.md`.

## Related
- `Troubleshooting.md` · Academy `Command-Library/PowerShell-Tier0.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md` · Tier-A A1 (gMSA).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded (`ADR-0032`) for the SQL01 replication: install/service (+running-under-the-gMSA), identity/addressing/gMSA-health, security posture (TLS, Windows-only auth, AD-group logins, sysadmin, memory cap, 1433 scope), and backups+restore (`POL-0005`). All 📋; flips ✅ on read-back (`POL-0001`). |
