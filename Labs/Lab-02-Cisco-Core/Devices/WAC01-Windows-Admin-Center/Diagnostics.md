---
Title: WAC01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center
Status: 📋 Seeded (`ADR-0032`). WAC01 = Windows Admin Center gateway, VLAN 10 `10.10.0.5` (proposed). **📋 not built** — 🟡/📋 until read-backs. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# WAC01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **WAC01** (Win Server 2025) — Role: Windows Admin Center gateway (Tier-0 management surface).

> **What this is (`ADR-0032`):** "is the WAC gateway up, TLS-trusted, reachable **only from PAW01**, and actually managing the estate?" Break-fix → `Troubleshooting.md`; deep set → Academy `Command-Library/PowerShell-Tier0.md`.

## 1. Gateway / host
| Check | Command | Expected | Verified? |
|---|---|---|---|
| WAC service | `Get-Service ServerManagementGateway` | Running | 📋 |
| Listening 443 | `Get-NetTCPConnection -LocalPort 443 -State Listen` | WAC bound on 443 | 📋 |
| Gateway cert | WAC settings → Certificate / `netsh http show sslcert` | **ICA01-issued**, correct SAN, Trusted | 📋 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Domain / OU | `Get-ADComputer WAC01 -Properties DistinguishedName` | `atlas.lab` · `OU=Servers,OU=Devices` | 📋 |
| IP / VLAN | `Get-NetIPConfiguration` | `10.10.0.5` / **VLAN 10** *(proposed)* | 📋 |

## 3. Access + management (the point)
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| PAW-only role | WAC → Settings → Access | gateway admin/user = **Tier-0 group** only | 📋 |
| PAW-only network | from a **non-PAW** host: `Test-NetConnection WAC01 -Port 443` | **refused** (ACL deny + log) — the negative test | 📋 |
| Console from PAW01 | browse `https://wac01.atlas.lab` from PAW01 | loads over TLS, **no cert warning** | 📋 |
| Managed node | WAC → a connection (DC01) → Services/Events | reads back live state over WinRM | 📋 |
| Delegation posture | connection settings | Kerberos; **no unconstrained CredSSP** | 📋 |

## 4. Links
| Link | From WAC01 | Expected | Verified? |
|---|---|---|---|
| → managed nodes (WinRM) | `Test-NetConnection DC01 -Port 5985` (/5986) | WinRM reachable to the estate | 📋 |
| → ICA01 / CRL | cert chain | gateway cert chains to the issuing CA; CRL reachable | 📋 |
| → DC01 (auth/GPO) | `gpresult /r` | domain-join + management GPOs applied | 📋 |
| ← PAW01 443 | from PAW01 | reachable; **all other sources denied** | 📋 |

## If you built/changed WAC01 solo (`ADR-0032`)
Paste read-backs (service+443, the bound ICA01 cert, the PAW-only role + the non-PAW-denied negative test, a managed action on DC01) → next session flips 📋→✅; mirror into `SESSION-HANDOFF.md`.

## Related
- `Troubleshooting.md` · Academy `Command-Library/PowerShell-Tier0.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded (`ADR-0032`) for WAC01: gateway service/443/cert, identity/addressing, the **PAW-only** access proofs (role + the non-PAW-denied negative test) + a managed-node read-back + delegation posture, and the WinRM/ICA01/DC/PAW links. All 📋; flips ✅ on read-back (`POL-0001`). |
