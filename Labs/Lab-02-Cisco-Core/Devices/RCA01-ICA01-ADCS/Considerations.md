---
Title: RCA01/ICA01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 🟠 LIVING — the open risks, gates, and unsettled decisions for the estate PKI. Closed items move to the Build-Record / Change Log.
Version: 1.1
Date: 2026-07-29
---

# RCA01 / ICA01 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled" list for the PKI — separate from the steps (`AD-CS-Two-Tier-Build-Guide.md`) and the checks (`Diagnostics-ICA01.md`).

## Open gates
- 🔴 **The offline-root ceremony gates everything.** No cert issues — LDAPS, RADIUS, every TLS — until RCA01 is built and signs ICA01, and ICA01 is installed. This is the estate's tallest critical-path dependency.
- 🔴 **Revocation must actually work (`ADR-0009` / Part 4).** The CDP/AIA endpoint (SRV01 `nginx`, `pki.atlas.lab`) must be reachable or revocation checks fail — sometimes *open* (accept a revoked cert), sometimes *closed* (break auth). The Part-4 acceptance gate — publish, revoke a test cert, prove it reads as revoked — is **mandatory**, not optional.
- 🔴 **CA key / passphrase custody (`ADR-0009`).** Vaultwarden holds it — but the **Vaultwarden master-password recovery path is an open blocker** (`ADR-049` / register **E2**). Do **not** trust the vault with CA secrets until recovery is proven.

## Standing risks (design)
- 🔴 **ESC1–ESC8 template misconfig = domain compromise.** AD CS is a top real-world escalation surface; harden the templates **before** publishing any (Part 3.1). This is also a PenTest+ learning target — attack it in the validation pass.
- 🔴 **SAN / `copy_extensions` defect (Lab-01 `CM-0027`).** The old OpenSSL CA issued certs with **no SAN**; ensure ICA01 templates issue correct SANs — verify a real issued cert, don't assume.
- **OpenSSL retired (`ADR-0031`) — reissue cost.** Pi-hole, MKT01, FGT01 must trust the new AD CS root and be **reissued** certs (Part 3B); plan the reinstall on each.
- **Single issuing CA — no CA redundancy.** RCA01 (offline) is the recovery anchor; a lost ICA01 is rebuilt + re-signed from RCA01. Backups + the offline-root media are the safety net.
- **Offline-root media custody.** RCA01 lives air-gapped on encrypted removable media with its **own off-site copy** (Part 5); losing it means a full PKI rebuild.

## Open decisions (need a call / ADR when reached)
- **OCSP + KRA placement (A2)** — on ICA01 vs a dedicated member server (`Pre-Build-Decisions` E1; recommend on/adjacent to ICA01).
- **Key Recovery Agent policy** — which templates archive keys, who can recover (KRA custody, ties to the `ADR-0009` separation discipline).
- **Pi01 conditional-forward / DNS for `pki.atlas.lab`** — confirm resolution for non-domain devices reaching the CRL host.

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27) — the two-tier CA rows (offline root · issuing CA · templates/autoenroll · CRL/AIA · OCSP/KRA) + protocol/port on the ICA01 edges (`LDAPS cert`, `CDP/AIA · HTTP/80`, `RADIUS/PEAP cert`, …); the RCA01 edge keeps its `signs, then air-gapped` label. Status honest ⬜ (only ICA01 host reachability ✅, `POL-0001`).
- **No separate `Networking-Build-Guide.md` for RCA01/ICA01** *(operator policy — appliances point, hosts get new)*. ICA01 is a standard tagged-VLAN-20 VM; RCA01 is offline/air-gapped (no network). The one flat-structure call (two tiers of one PKI, staged Parts not `Roles/`) is already documented in the README structure note — no Standard tweak.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Diagnostics-ICA01.md` · `../../Operations/Validation-and-Adversarial-Testing.md` (ESC/PKI attack tests) · `ADR-0009` (revocation objectives).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** added a **Decided** section — Services map + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27, all ⬜ bar ICA01 host reachability); no separate `Networking-Build-Guide.md` (ICA01 = VLAN-20 VM; RCA01 = offline/air-gapped). |
| 1.0 | 2026-07-29. Created — open gates (offline-root ceremony, revocation-must-work, CA-key custody vs the Vaultwarden-recovery blocker), standing risks (ESC1–ESC8, SAN/`copy_extensions`, OpenSSL-reissue cost, single-issuing-CA, offline-root media custody), open decisions (OCSP/KRA placement, KRA policy, `pki.atlas.lab` DNS). |
