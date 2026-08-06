---
Title: ICA01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 🟡 Seeded (ADR-0032). ICA01 = enterprise issuing CA, `10.20.0.4` (Tier 0). Host reachable ✅ 07-22; **CA role NOT yet installed** — role checks are ⏳/📋 until the ceremony runs.
Version: 0.1
Date: 2026-07-28
---

# ICA01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **ICA01** (Windows Server 2025, domain-joined member) — Role: **AD CS Enterprise Issuing (Subordinate) CA**, `10.20.0.4` (Tier 0). RCA01 (offline root) is a separate host, never networked — see the AD-CS guide.

> **State:** ICA01 is **online/reachable (✅ 07-22)** but is **not a CA yet** — the sub-CA install waits on the RCA01 offline-root ceremony (AD-CS guide Part 1→2.5). So CA-role checks below are ⏳/📋 until then; host/identity checks are runnable now. **Markers:** ✅ · 🟡 · ⏳ · 📋 (`POL-0001`).

## 1. Installation / role verification
| Check | When | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|---|
| Reachable on the network | now | `Test-NetConnection 10.20.0.4` | reachable | ✅ (07-22) | IP set |
| Domain-joined | after join | `Get-ComputerInfo -Property CsDomain` | `atlas.lab` | 📋 | AD-CS guide §2.1 |
| AD CS role installed | after role | `Get-WindowsFeature ADCS-Cert-Authority` | Installed | ⏳ pending ceremony | guide §2.4 |
| CA service running | after config | `Get-Service certsvc` | Running | ⏳ | guide §2.6 |
| CA type / name | after config | `certutil -cainfo` | Enterprise Subordinate, CN `Atlas Issuing CA` | ⏳ | guide §0.3 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Hostname | `hostname` | ICA01 | 🟡 | rename-before-role (§0.3) |
| IP / mask / gw / DNS | `Get-NetIPConfiguration` | `10.20.0.4 /26 gw 10.20.0.1 DNS 10.20.0.2` | ✅ (07-22) | `IP-Addressing-Plan-VLSM` |
| Time from domain | `w32tm /query /source` | DC01 (DOMHIER) | 📋 | `ADR-0020` |

## 3. Service-up checks (CA — after build)
| Service | Command | Expected | Verified? |
|---|---|---|---|
| CA chains to root | `certutil -verify -urlfetch` on the CA cert | chains to **Atlas Root CA**, no errors | ⏳ |
| CDP/AIA registered | `certutil -getreg CA\CRLPublicationURLs` / `…CACertPublicationURLs` | HTTP `pki.atlas.lab` entries present | ⏳ | guide §2.6 |
| PKI health | `pkiview.msc` (Enterprise PKI) | every CDP/AIA/CRL = OK (no red) | ⏳ | guide Part 4 (revocation gate) |

## 4. Inter-device link checks (reciprocal)
| Link | From ICA01 | From the OTHER device | Expected | Verified? |
|---|---|---|---|---|
| → CRL host (SRV01 nginx) | `curl http://pki.atlas.lab/pki/` | (SRV01) file present | 📋 gated on SRV01 | 
| ↔ DC01 (domain) | `nltest /dsgetdc:atlas.lab` | — | locates a DC | 📋 |
| ← enrollee (NPS01 RAS/IAS, non-domain devices) | (CA issues) | `certreq -submit` from enrollee | request issued | ⏳ | guide §3.5 / Part 3B |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| `pki.atlas.lab` resolves | `Resolve-DnsName pki.atlas.lab` | → SRV01 (CRL host) | 📋 |

## 6. IP / connectivity entry points
| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| L3 gateway | `Test-NetConnection 10.20.0.1` | gw reachable | ✅ (07-22) |
| DC reachable | `Test-NetConnection 10.20.0.2 -Port 389` | LDAP to DC01 | 🟡 |

## 7. Logging & event sources
| Source | How to view | Look for | Verified? |
|---|---|---|---|
| CA operations | Event Viewer → Applications and Services → AD CS | issuance/revocation, service start | ⏳ |
| CA audit (ESC) | Security log (after §3.1 auditing on) | cert issuance / template changes | ⏳ |

## If you built or changed ICA01 solo (ADR-0032)
Paste the read-backs (domain-join, role install, `certutil -cainfo`, `pkiview`) as the ceremony progresses; flip ⏳→✅. Mirror into `SESSION-HANDOFF.md` → Solo-work sync.

## Related
- `AD-CS-Two-Tier-Build-Guide.md` (build — the source of "expected") · `Troubleshooting.md` (if present) · **Atlas Academy** `Concepts/` (PKI two-tier) · `ADR-0027`/`ADR-0031`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Seeded (`ADR-0032`). Host/identity checks runnable now (✅ reachable/addressing 07-22); CA-role checks (`Get-Service certsvc`, `certutil -cainfo`, `pkiview`, CDP/AIA) marked ⏳ pending the RCA01→ICA01 ceremony. Links to SRV01 CRL host + enrollees noted per the AD-CS guide §3.5 / Part 3B. |
