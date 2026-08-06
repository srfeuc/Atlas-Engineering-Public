---
Title: DC02 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 Seeded (ADR-0032). DC02 = replica DC / GC / DNS, `10.20.0.3`. **DC02 is the live read-back item** — operator-reported promoted 2026-07-28, `repadmin`/`dcdiag` PENDING. Everything here 🟡 until run.
Version: 0.1
Date: 2026-07-28
---

# DC02 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **DC02** (Windows Server 2025) — Role: **replica** DC / Global Catalog / DNS, `10.20.0.3` (Tier 0).

> 🔴 **DC02 is the one live lab item.** It is **operator-reported promoted (2026-07-28)** but not device-verified — run §1–§4 below to flip its 🟡 → ✅. **It is a *replica*** — promoted with `Install-ADDSDomainController`, **never** `Install-ADDSForest` (that would create a second forest). **Markers:** ✅ verified · 🟡 lab-unverified · ⏳ in build · 📋 planned (`POL-0001`).

## 1. Installation / role verification — 🔴 the read-back that flips DC02 to ✅
| Check | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| Is DC02 a DC in the domain | `Get-ADDomainController -Identity DC02 \| fl Name,Domain,IsGlobalCatalog,Site` | DC02, `atlas.lab`, GC=True | 🟡 | promotion |
| Still ONE forest (no 2nd) | `Get-ADForest \| Select Domains` | **one** domain `atlas.lab` | 🟡 | replica, not forest |
| Replication healthy | `repadmin /replsummary` | **0 failures**, both directions | 🟡 | replica |
| DC health | `dcdiag /s:DC02` | all tests pass (esp. Replications, SysVol, Advertising) | 🟡 | — |
| Time from hierarchy | `w32tm /query /source` | **DC01 (DOMHIER)** — not CMOS/external | 🟡 | `ADR-0020` |

## 2. Identity & addressing
| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Hostname / domain | `Get-ComputerInfo -Property CsName,CsDomain` | DC02 / atlas.lab | 🟡 | — |
| IP / mask / gw | `Get-NetIPConfiguration` | `10.20.0.3 /26 gw 10.20.0.1` | 🟡 | `IP-Addressing-Plan-VLSM` |
| DNS resolver | `Get-DnsClientServerAddress -AddressFamily IPv4` | DC01 `10.20.0.2` (during/after promo), then self | 🟡 | promo prereq |

## 3. Service-up checks
| Service | Command | Expected | Verified? |
|---|---|---|---|
| Core DC services | `Get-Service NTDS,ADWS,DNS,Netlogon,W32Time \| ft Name,Status` | all Running | 🟡 |
| SYSVOL/NETLOGON shared | `net share` (or `dcdiag /test:sysvol`) | SYSVOL + NETLOGON present | 🟡 |
| GC responding | `Get-ADDomainController -Discover -Service GlobalCatalog` | returns DC02 (and DC01) | 🟡 |

## 4. Inter-device link checks (reciprocal)
| Link | From DC02 | From DC01 | Expected | Verified? |
|---|---|---|---|---|
| ↔ DC01 replication | `repadmin /showrepl` | `repadmin /replsummary` | inbound/outbound OK, 0 fail | 🟡 |
| ↔ DC01 SYSVOL (DFSR) | `dcdiag /test:sysvol` | same | SYSVOL replicated (GPOs match) | 🟡 |
| ← gateway | `Test-NetConnection 10.20.0.1` | ping DC02 from MKT01 | reachable both ways | 🟡 |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| Resolve self | `Resolve-DnsName dc02.atlas.lab` | `10.20.0.3` | 🟡 |
| AD zone replicated | `Get-DnsServerZone atlas.lab` (on DC02) | Primary, AD-integrated | 🟡 |

## 6. IP / connectivity entry points
| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| L3 to DC01 | `Test-NetConnection 10.20.0.2 -Port 389` | LDAP path to DC01 | 🟡 |

## 7. Logging & event sources
| Source | How to view | Look for | Verified? |
|---|---|---|---|
| Directory Service / DFS Replication | `Get-WinEvent -LogName 'DFS Replication' -Max 50` | SYSVOL replication state | 🟡 |
| Security / Kerberos | Security log 4768/4769 | auth serviced by DC02 | 🟡 |

## If you built or changed DC02 solo (ADR-0032)
🔴 **This is the priority read-back.** Paste `Get-ADDomainController DC02`, `repadmin /replsummary`, `dcdiag`, `w32tm /query /source` → flip §1 to ✅, update DC02's status in the IP plan register + `SESSION-HANDOFF.md` (currently 🟡 operator-reported).

## Related
- `Troubleshooting.md` (DC) · **Atlas Academy** `Concepts/` (DFSR/SYSVOL W2, FSMO W1) · `DC01` `Diagnostics.md` · `Build-Progress-Tracker.md` (Verify-on-resume).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Seeded (`ADR-0032`) as the **live read-back checklist** for DC02 (operator-reported promoted, unverified): the `Get-ADDomainController`/`repadmin`/`dcdiag`/`w32tm` set that flips its 🟡→✅, plus addressing, service-up, DC01 replication/SYSVOL links. All 🟡 until run. |
