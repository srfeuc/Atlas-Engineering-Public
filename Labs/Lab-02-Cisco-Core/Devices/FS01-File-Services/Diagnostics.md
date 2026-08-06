---
Title: FS01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services
Status: 📋 Seeded (`ADR-0032`). FS01 = file server, VLAN 20 `10.20.0.14` (proposed), data on the 8 TB. Commands authored from docs; **📋 not built** — 🟡/📋 until read-backs land. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# FS01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **FS01** (Win Server 2025) — Role: SMB/AGDLP · DFS/DFSR · FSRM · VSS.

> **What this is (`ADR-0032`):** "is FS01 built + does access control actually hold?" The distinctive FS01 discipline is proving the **AGDLP allow *and* deny** (HR→HR ✓ / HR→IT ✗) and that a **restore** works. Break-fix → `Troubleshooting.md`; deep set → Academy `Command-Library/PowerShell-Tier0.md`.

## 1. Roles / host
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Roles installed | `Get-WindowsFeature FS-FileServer,FS-Resource-Manager,FS-DFS-Namespace,FS-DFS-Replication` | all Installed | 📋 |
| Data volume (8 TB) | `Get-Volume` | the 8 TB data volume online, healthy | 📋 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Domain / OU | `Get-ADComputer FS01 -Properties DistinguishedName` | `atlas.lab` · `OU=Servers,OU=Devices` | 📋 |
| IP / VLAN | `Get-NetIPConfiguration` | `10.20.0.14` / VLAN 20 · gw `.1` · DNS `.2` | 📋 |

## 3. Shares / access control (the point)
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Shares exist | `Get-SmbShare` | the dept shares | 📋 |
| ACLs are AGDLP (groups) | `Get-SmbShareAccess <share>` + `(Get-Acl <path>).Access` | **domain-local groups only**, no direct users | 📋 |
| 🔴 HR→HR allowed | (from WS-HR01, as an HR user) open the HR share | read/write works | 📋 |
| 🔴 HR→IT denied | (from WS-HR01) open the IT share | **access denied** (the `ADR-0042` proof) | 📋 |

## 4. DFS / VSS / FSRM
| Check | Command | Expected | Verified? |
|---|---|---|---|
| DFS namespace | `Get-DfsnRoot` + `Get-DfsnFolderTarget` | `\\atlas.lab\<ns>` resolves; targets listed | 📋 |
| DFS failover | stop one target; access continues | fails over to the other target | 📋 |
| VSS present | `vssadmin list shadows` | shadow copies on the data volume | 📋 |
| VSS restore | right-click a file → Previous Versions → restore | a prior version comes back | 📋 |
| FSRM quota/screen | FSRM console / `Get-FsrmQuota` | quotas + screens applied | 📋 |

## 5. Protection (`POL-0005`)
| Check | Where | Expected | Verified? |
|---|---|---|---|
| 🔴 BKP01 backs it up | BKP01 job history | recent successful backup of the data volume | 📋 |
| 🔴 Restore tested | a BKP01 restore of a test file | restored (VSS ≠ backup) | 📋 |

## If you built or changed FS01 solo (`ADR-0032`)
Paste the read-backs (roles, the AGDLP allow+deny, DFS resolve/failover, a VSS restore, a BKP01 restore) so the next session flips 📋 → ✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync.

## Related
- `Troubleshooting.md` · Academy `Command-Library/PowerShell-Tier0.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md` (the HR→IT deny proof) · `../DC-Domain-Controllers/...Tiered-Admin-and-Groups-Build.md` (the AGDLP groups).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded (`ADR-0032`) for the FS01 replication: roles/volume, identity/addressing, the **AGDLP allow+deny** proof (HR→HR ✓ / HR→IT ✗), DFS resolve/failover, VSS present+restore, FSRM, and the **BKP01 backup+restore** (`POL-0005`). All 📋; flips ✅ on read-back (`POL-0001`). |
