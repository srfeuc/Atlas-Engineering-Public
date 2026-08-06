---
Title: DC01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 Seeded (ADR-0032). DC01 = PDCe / AD-DNS / forest root `atlas.lab`, `10.20.0.2`. Commands authored; ✅ only where a prior-session read-back exists, else 🟡 lab-unverified.
Version: 0.1
Date: 2026-07-28
---

# DC01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **DC01** (Windows Server 2025) — Role: PDC Emulator, AD-DNS, forest root `atlas.lab`, `10.20.0.2` (Tier 0).

> **What this is (`ADR-0032`):** the quick "is DC01 built and connected right?" checks. Break-fix → `Troubleshooting.md`; the deep command set → **Atlas Academy**. **Markers:** ✅ device-verified (output pasted) · 🟡 lab-unverified · ⏳ in build · 📋 planned. Author from knowledge/official docs; **never assume output** (`POL-0001`).

## 1. Installation / role verification
| Check | When | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|---|
| AD DS installed | after promo | `Get-WindowsFeature AD-Domain-Services` | Installed | ✅ prior (07-21) | DC promo |
| Is a DC / which roles | anytime | `Get-ADDomainController -Identity DC01 \| fl Name,IsGlobalCatalog,OperationMasterRoles` | DC01; GC; all 5 FSMO | ✅ prior (07-21) | forest root |
| One forest, one domain | after DC02 | `Get-ADForest \| Select Domains` | **one** domain `atlas.lab` | 🟡 | no 2nd forest |
| Core services up | anytime | `Get-Service NTDS,ADWS,DNS,Netlogon,W32Time \| ft Name,Status` | all Running | 🟡 | — |

## 2. Identity & addressing
| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Hostname / domain | `Get-ComputerInfo -Property CsName,CsDomain` | DC01 / atlas.lab | 🟡 | — |
| IP / mask / gw | `Get-NetIPConfiguration` | `10.20.0.2 /26 gw 10.20.0.1` | ✅ prior (mask fix 07-22) | `IP-Addressing-Plan-VLSM` |
| DNS resolver | `Get-DnsClientServerAddress -AddressFamily IPv4` | self / `127.0.0.1` or `10.20.0.2` | 🟡 | — |
| Time source (PDCe) | `w32tm /query /source` | **external** NTP (PDCe bridges the hierarchy) | ✅ prior | `ADR-0020` |

## 3. Service-up checks
| Service | Command | Expected | Verified? |
|---|---|---|---|
| AD DNS zone | `Get-DnsServerZone atlas.lab` | Primary, AD-integrated | 🟡 |
| External forwarder | `Get-DnsServerForwarder` | forwarder set (not root hints only) | 🟡 |
| Directory responds | `Get-ADDomain` | returns `atlas.lab` | ✅ prior |

## 4. Inter-device link checks (reciprocal)
| Link | From DC01 | From the OTHER device | Expected | Verified? |
|---|---|---|---|---|
| ↔ DC02 replication | `repadmin /replsummary` | `repadmin /showrepl` on DC02 | 0 failures both ways | 🟡 (DC02 pending) |
| ← client LDAPS 636 | (listen) | `ldp.exe` → dc01.atlas.lab:636 SSL from PAW | successful bind (needs DC cert) | 📋 gated on AD CS |
| ← gateway | `Test-NetConnection 10.20.0.1` | ping DC01 from MKT01 | reachable both ways | 🟡 |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| Resolve a DC record | `Resolve-DnsName dc01.atlas.lab` | `10.20.0.2` | 🟡 |
| AD SRV records | `Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.atlas.lab` | DC SRV present | 🟡 |
| External via forwarder | `Resolve-DnsName microsoft.com` | resolves | 🟡 |

## 6. IP / connectivity entry points
| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| L3 gateway | `Test-NetConnection 10.20.0.1 -InformationLevel Detailed` | gw reachable | 🟡 |
| Firewall/path | `Test-NetConnection 10.20.0.3 -Port 389` | DC02 reachable on LDAP (E-W allows Identity) | 🟡 |

## 7. Logging & event sources
| Source | How to view | Look for | Verified? |
|---|---|---|---|
| Directory Service log | `Get-WinEvent -LogName 'Directory Service' -Max 50` | no red; NTDS errors | 🟡 |
| DNS Server log | Event Viewer → DNS Server | zone-load/xfer errors | 🟡 |
| Kerberos / logon | Security log 4768/4769/4625 | auth failures | 🟡 |
| Ships to MON01? | (Phase 6) | WEF/syslog once MON01 exists | 📋 |

## If you built or changed DC01 solo (ADR-0032)
Paste the read-backs (role/IP/DNS/time/replication) so the next session flips 🟡→✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync + `Operations/Device-Confirmation-Commands.md`.

## Related
- `Troubleshooting.md` (DC) · **Atlas Academy** `Concepts/` (FSMO W1, DFSR W2, SCT W3, VBS W4, DSRM W5) · `Windows-Infrastructure/303` · `Build-Progress-Tracker.md` (Verify-on-resume).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Seeded from `Diagnostics-Show-Commands-Template` (`ADR-0032`): role/FSMO, addressing, AD-DNS/time, DC02 replication + client-LDAPS links, DNS/SRV tests, event sources. ✅ marks the prior-session device-verified facts (promotion, `/26` mask, PDCe time); everything else 🟡 until read-back. |
