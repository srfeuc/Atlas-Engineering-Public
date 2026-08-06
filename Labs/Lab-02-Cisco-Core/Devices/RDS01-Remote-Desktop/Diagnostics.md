---
Title: RDS01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop
Status: 📋 Seeded (`ADR-0032`). RDS01 = RD Session Host/Gateway, VLAN 20 `10.20.0.17` (proposed). **📋 not built** — 🟡/📋 until read-backs. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# RDS01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **RDS01** (Win Server 2025) — Role: RD Session Host / Gateway.

> **What this is (`ADR-0032`):** "is RDS built + can a standard user actually reach a published app through the gateway, authorized by NPS, with Tier-0 blocked?" Break-fix → `Troubleshooting.md`; deep set → Academy `Command-Library/PowerShell-Tier0.md`.

## 1. Roles / host
| Check | Command | Expected | Verified? |
|---|---|---|---|
| RDS roles | `Get-WindowsFeature RDS-*` | RD-Server (+ Licensing; + Gateway/Web) Installed | 📋 |
| Session collection | `Get-RDSessionCollection` | the collection present | 📋 |
| Licensing health | RD Licensing Diagnoser (`lsdiag.msc`) / `Get-RDLicenseConfiguration` | license server reachable, CALs installed, no grace warning | 📋 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Domain / OU | `Get-ADComputer RDS01 -Properties DistinguishedName` | `atlas.lab` · `OU=Servers,OU=Devices` | 📋 |
| IP / VLAN | `Get-NetIPConfiguration` | `10.20.0.17` / VLAN 20 *(proposed)* | 📋 |

## 3. RDS operation (the point)
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| Published resources | `Get-RDRemoteApp` / RD Web page | the published app/desktop present | 📋 |
| Gateway TLS cert | Deployment Properties → Certificates / `Get-RDCertificate` | ICA01-issued, correct SAN, Trusted (no warning) | 📋 |
| CAP/RAP (on NPS01) | NPS console → Connection Request / Network Policies | deny-by-default; AD-group CAP+RAP present (`ADR-0029`) | 📋 |
| End-to-end launch | a standard user via RD Web/gateway | published desktop/app opens over TLS | 📋 |
| Tier separation | a Tier-0 account attempts RDS | **denied** (not in collection/CAP) — the negative test | 📋 |

## 4. Links
| Link | From RDS01 | Expected | Verified? |
|---|---|---|---|
| → NPS01 (RADIUS) | a gateway connection | CAP/RAP authorization **logged on NPS01** | 📋 |
| → ICA01 / CRL | cert chain | cert chains to the issuing CA; CRL reachable | 📋 |
| → DC01 (auth/GPO) | `gpresult /r` | session/hardening GPOs applied | 📋 |
| ← client 443 (gateway) | a user connects | RD Gateway reachable over TLS (E-W) | 📋 |

## If you built/changed RDS01 solo (`ADR-0032`)
Paste read-backs (roles + collection, licensing health, the bound ICA01 cert, an end-to-end launch, the NPS CAP/RAP log, the Tier-0-denied test) → next session flips 📋→✅; mirror into `SESSION-HANDOFF.md`.

## Related
- `Troubleshooting.md` · Academy `Command-Library/PowerShell-Tier0.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded (`ADR-0032`) for the RDS01 replication: roles/collection/licensing, identity/addressing, published-resources + gateway-cert + CAP/RAP + end-to-end-launch + the Tier-0-denied negative test, and the NPS/ICA01/DC/client links. All 📋; flips ✅ on read-back (`POL-0001`). |
