---
Title: WSUS01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management
Status: 📋 Seeded (`ADR-0032`). WSUS01 = patch mgmt, VLAN 20 `10.20.0.15` (proposed). **📋 not built** — 🟡/📋 until read-backs. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# WSUS01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **WSUS01** (Win Server 2025) — Role: WSUS patch management.

> **What this is (`ADR-0032`):** "is WSUS built + are clients actually reporting + patching?" Break-fix → `Troubleshooting.md`; deep set → Academy `Command-Library/PowerShell-Tier0.md`.

## 1. Role / host
| Check | Command | Expected | Verified? |
|---|---|---|---|
| WSUS role | `Get-WindowsFeature UpdateServices` | Installed | 📋 |
| WSUS service | `Get-Service WsusService` | Running | 📋 |
| Content store vol | `Get-Volume` | the content vdisk online, headroom | 📋 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Domain / OU | `Get-ADComputer WSUS01 -Properties DistinguishedName` | `atlas.lab` · `OU=Servers,OU=Devices` | 📋 |
| IP / VLAN | `Get-NetIPConfiguration` | `10.20.0.15` / VLAN 20 | 📋 |

## 3. WSUS operation (the point)
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| Sync status | WSUS console → Synchronizations (or `Get-WsusServer`) | last sync succeeded | 📋 |
| Target groups | WSUS console → Computers | Servers/Clients/Tier-0 populated by GPO | 📋 |
| A client checked in | `Get-WsusComputer` | pilot host present, correct group | 📋 |
| Test approval installed | on the pilot: `Get-HotFix` / Update history | the approved KB present | 📋 |
| Compliance report | WSUS report | patch state across groups | 📋 |

## 4. Links
| Link | From WSUS01 | Expected | Verified? |
|---|---|---|---|
| → Microsoft Update (egress) | sync succeeds | FGT01 permits the N-S egress (UTM-inspected once `ADR-0047`) | 📋 |
| ← client 8530/8531 | a client `wuauclt /detectnow` (or `UsoClient`) | client contacts WSUS + reports | 📋 |
| DB backend | WID (default) or SQL01 | as configured | 📋 |

## If you built/changed WSUS01 solo (`ADR-0032`)
Paste read-backs (role, sync success, a client check-in + a test install, the compliance report) → next session flips 📋→✅; mirror into `SESSION-HANDOFF.md`.

## Related
- `Troubleshooting.md` · Academy `Command-Library/PowerShell-Tier0.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded (`ADR-0032`) for the WSUS01 replication: role/service/content-vol, identity/addressing, sync + target-groups + client-check-in + test-install + compliance report, and the egress/client links. All 📋; flips ✅ on read-back (`POL-0001`). |
