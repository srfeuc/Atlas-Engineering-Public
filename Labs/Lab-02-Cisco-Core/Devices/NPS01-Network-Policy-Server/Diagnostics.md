---
Title: NPS01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server
Status: 📋 Seeded (`ADR-0032`). NPS01 = RADIUS member server, VLAN 20, `10.20.0.12` (proposed). Commands authored from docs; **📋 not built** — every row 🟡/📋 until a read-back is pasted. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-29
---

# NPS01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **NPS01** (Win Server 2025) — Role: RADIUS for MKT01/SW01/1941 admin AAA (`ADR-0029`).

> **What this is (`ADR-0032`):** the quick "is NPS01 built + does a real login actually work?" checks — the distinctive NPS discipline is proving **both** the accept **and** the reject. Break-fix → `Troubleshooting.md`; the deep set → Academy `Command-Library/PowerShell-Tier0.md`.

## 1. Role / install
| Check | When | Command | Expected (healthy) | Verified? |
|---|---|---|---|---|
| NPS role installed | after install | `Get-WindowsFeature NPAS` | Installed | 📋 |
| NPS service up | anytime | `Get-Service IAS` | Running | 📋 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Domain / OU | `Get-ComputerInfo -Property CsDomain` + `Get-ADComputer NPS01 -Properties DistinguishedName` | `atlas.lab` · `OU=Servers,OU=Devices` | 📋 |
| IP / VLAN | `Get-NetIPConfiguration` | `10.20.0.12` /VLAN 20 · gw `10.20.0.1` (proposed) | 📋 |
| Clock | `w32tm /query /source` | DC (DOMHIER) | 📋 |

## 3. NPS configuration
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| Registered in AD | `Get-ADGroupMember "RAS and IAS Servers"` | NPS01 present | 📋 |
| RADIUS clients | NPS console → RADIUS Clients (or `netsh nps show config`) | MKT01, SW01, 1941 (secrets not shown) | 📋 |
| Network policies | NPS console → Policies | AD-group→privilege; **deny-by-default last** | 📋 |
| Server cert (PEAP) | `Get-ChildItem Cert:\LocalMachine\My` | RAS-and-IAS-Server cert (EKU Server Auth) — gated on AD CS | 📋 |

## 4. The real-login proof (accept AND reject)
| Test | From | Expected | Verified? |
|---|---|---|---|
| Admin login accepted | MKT01 (then SW01, 1941) with a test admin AD account | accepted, correct privilege level | 📋 |
| Unknown user rejected | any client with a non-authorized account | **rejected** (deny-by-default proven) | 📋 |
| 🔴 Break-glass with NPS down | stop `IAS`; local admin on MKT01/SW01/1941 | local login **still works** | 📋 |
| NPS event log | `Get-WinEvent -LogName Security` → **6272** (granted) / **6273** (denied) | the accept + the reject events present | 📋 |

## 5. Inter-device link checks
| Link | From NPS01 | Expected | Verified? |
|---|---|---|---|
| ↔ DC (AD) | `Test-NetConnection 10.20.0.2 -Port 389` | LDAP reachable (validates creds) | 📋 |
| ← RADIUS client | (listen 1812/1813) · from MKT01 send a test auth | request arrives; reply sent | 📋 |
| ← ICA01 cert path | `certutil -verify` the RAS-IAS cert | chains to ICA01→RCA01; CRL OK | 📋 (gated on AD CS) |

## If you built or changed NPS01 solo (`ADR-0032`)
Paste the read-backs (NPAS installed, RAS-and-IAS membership, the 6272 accept + 6273 reject, the break-glass proof) so the next session flips 📋/🟡 → ✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync + `Operations/Device-Confirmation-Commands.md`.

## Related
- `Troubleshooting.md` (NPS) · Academy `Command-Library/PowerShell-Tier0.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md` (the accept/reject + break-glass proofs) · `ADR-0029`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded from the `Diagnostics-Show-Commands-Template` (`ADR-0032`) for the NPS01 replication: role/install, identity/addressing, NPS config (RAS-and-IAS registration, clients, policies, PEAP cert), the **accept-AND-reject** real-login proof + break-glass + the 6272/6273 events, and the DC/client/ICA01 links. All 📋; flips to ✅ on read-back (`POL-0001`). |
