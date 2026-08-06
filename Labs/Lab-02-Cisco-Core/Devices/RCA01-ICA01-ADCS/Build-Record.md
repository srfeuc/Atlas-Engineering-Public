---
Title: RCA01/ICA01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 🟡 LIVING — verified as-built state of the PKI. **Not built yet** — ICA01 host is reachable; the CA role and RCA01 ceremony are pending. Records outrank guides (`POL-0001`).
Version: 1.0
Date: 2026-07-29
---

# RCA01 / ICA01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The "what is actually true now" snapshot for the PKI (`POL-0001` evidence home; outranks the Build-Guide). Markers: ✅ device-verified · 🟡 operator-reported · ⏳ in build · ⬜ not built.

## ICA01 — Enterprise Issuing CA (PVE02/EQR6 · `10.20.0.4` · VLAN 20 T0)
| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Reachable on the network | yes | ✅ (07-22) | `Test-NetConnection 10.20.0.4` (Diagnostics-ICA01 §1) |
| IP / mask / gw / DNS | `10.20.0.4` /26 gw `10.20.0.1` DNS `10.20.0.2` | ✅ (07-22) | `Get-NetIPConfiguration` |
| Domain-joined | pending | ⬜ | Build-Guide §2.1 |
| AD CS role installed | pending (ceremony gates it) | ⬜ | §2.4 |
| CA type / name | Enterprise Subordinate, `Atlas Issuing CA` | ⬜ | §0.3 |
| CDP/AIA + CRL published (SRV01) | pending | ⬜ | §2.7 |

## RCA01 — offline standalone Root CA (offline, powered off)
| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Ceremony (root built + signs ICA01) | **not run** — gates the PKI | ⬜ | Build-Guide Part 1 |
| Root cert + CRL exported | pending | ⬜ | §1.5 |

## Consumers (pending the CA)
| Consumer | Cert | Status |
|---|---|---|
| DC01/DC02 LDAPS · NPS01 RADIUS · non-domain (Pi/MKT/FGT) · Vaultwarden | issued from ICA01 | ⬜ all pending |

> 🔴 **Nothing here is device-verified beyond ICA01's host reachability + addressing.** The two-tier ceremony (Build-Guide Parts 1–2) is the next build action; rows flip ✅ as each `POL-0001` read-back is captured.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-29. **ICA01 host = PVE02/EQR6** (was PVE01) per `ADR-0036` v1.2 — the always-on core (a CA doing CRL publishing + autoenroll must stay up). IP/VLAN unchanged (`10.20.0.4` /VLAN 20). *(The `✅ 07-22` reachability read-back predates the acquisition; re-confirm on the EQR6 when ICA01 is stood up there — `POL-0001`.)* |
| 1.0 | 2026-07-29. Created — records ICA01 host reachable + addressed (✅ 07-22); CA role, RCA01 ceremony, CRL publishing, and all consumer certs **⬜ not built**. The offline-root ceremony is the gating next action. |
