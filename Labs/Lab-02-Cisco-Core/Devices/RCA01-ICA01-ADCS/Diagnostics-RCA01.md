---
Title: RCA01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 🟡 Seeded (ADR-0032). RCA01 = offline standalone Root CA (workgroup, air-gapped). **Ceremony NOT yet run** — every check is 📋 until the offline-root build executes (AD-CS guide Part 1). Verified once, at the ceremony; then the box is powered off and stored.
Version: 0.1
Date: 2026-07-29
---

# RCA01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build)** — Host: **RCA01** (Windows Server 2025, **workgroup**, no NIC / air-gapped) — Role: **AD CS Standalone Root CA** (offline). Signs exactly one thing — ICA01\'s sub-CA cert — then is powered off and stored. ICA01 (issuing) is a separate host — see `Diagnostics-ICA01.md`.

> **State:** the offline-root **ceremony has not run** (AD-CS guide Part 1). Every check below is **📋** until the build; they are run **once, at the ceremony**, captured as evidence, then RCA01 is air-gapped and stored. These checks differ from ICA01\'s on purpose — RCA01 verifies *standalone-root correctness + offline custody*, not online issuance. **Markers:** ✅ device-verified · 🟡 lab-unverified · 📋 planned (`POL-0001`).

## 1. Identity & isolation (verify BEFORE the role)
| Check | When | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|---|
| Hostname set (rename **before** the CA role — a CA cannot be renamed after) | pre-role | `hostname` | `RCA01` | 📋 | guide §0.3 |
| Workgroup, **not** domain-joined | pre-role | `Get-ComputerInfo -Property CsDomain,CsWorkgroup` | workgroup; no `atlas.lab` | 📋 | offline root is standalone |
| No network / air-gapped | pre-role | `Get-NetAdapter` · `Get-NetRoute -DestinationPrefix 0.0.0.0/0` | NIC disabled / no default gateway | 📋 | air-gap custody |
| Clock sane for the ceremony | pre-role | `Get-Date` · `w32tm /query /status` | correct time (cert validity dates depend on it) | 📋 | offline box has no time source |
| `CAPolicy.inf` present before install | pre-role | `Test-Path C:\\Windows\\CAPolicy.inf` | exists (root CAPolicy) | 📋 | guide §1.2 |

## 2. Root CA role & artifacts (verify AT the ceremony)
| Check | When | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|---|
| CA type = **Standalone Root** | at role | `certutil -getreg CA\\CAType` | `3` (Standalone Root CA) | 📋 | guide §1.3 |
| Root cert present + validity | at role | `certutil -store My` / `certutil -dump` | self-signed root, ~20-yr NotAfter, **SHA-256** | 📋 | guide §1.3 / §0 |
| HTTP-only CDP/AIA (no LDAP/file on an offline root) | post-install | `certutil -getreg CA\\CRLPublicationURLs` · `CACertPublicationURLs` | HTTP `pki.atlas.lab` only | 📋 | guide §1.4 |
| Root CRL generated + exported to sneakernet | at role | `certutil -CRL`, then check the `.crl` on removable media | fresh CRL exported (long validity/overlap) | 📋 | guide §1.5 |
| ICA01 request signed (after guide §2.5) | at signing | `certutil -view` (issued log) | exactly **one** issued cert = the ICA01 sub-CA | 📋 | guide §2.5 |

## 3. Offline custody (verify AFTER the ceremony)
| Check | When | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|---|
| Key + media backed up, one copy **off-site** | post-ceremony | (manual) encrypted-media inventory | 2 copies, one off-site (`ADR-0009`) | 📋 | guide Part 5 |
| Box powered off / stored | post-ceremony | (manual) | RCA01 offline until the next scheduled CRL re-sign | 📋 | offline-root posture |

> 🔴 **Never networked.** RCA01 is verified once at the ceremony, then air-gapped. It comes back online **only** to re-sign the CRL on schedule (`ADR-0009` overlap) — re-run §2\'s CRL check at each re-sign, then power off again.

## Related
- `AD-CS-Two-Tier-Build-Guide.md` (Part 1 = the ceremony these checks prove) · `Diagnostics-ICA01.md` (the online issuing CA) · `Troubleshooting.md` · `Atlas-Academy/Command-Library/PowerShell-Tier0.md` (the command home).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded — offline standalone-root verify battery (identity/isolation before the role · CA type / root cert / CDP-AIA / CRL export at the ceremony · offline custody after). Split from `Diagnostics-ICA01.md` because the offline root and the online issuer verify on entirely different things (operator note, 2026-07-29). All 📋 until the ceremony runs. |
