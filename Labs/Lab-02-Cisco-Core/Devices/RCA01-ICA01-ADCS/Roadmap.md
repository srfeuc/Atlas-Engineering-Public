---
Title: RCA01/ICA01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 🟢 LIVING roadmap — the build path for the two-tier PKI + what each stage depends on and unblocks. Status mirrors `Build-Checklist.md` / `Build-Record.md` (`POL-0001`).
Version: 1.0
Date: 2026-07-29
---

# RCA01 / ICA01 — Roadmap (build path + connections)

> **How to read this.** Each row is a stage of the PKI. **Needs** = what must be healthy first; **Unblocks** = what proceeds once it's done. The PKI is a **critical-path chain** — most of the estate's certs wait on it. Detail: `AD-CS-Two-Tier-Build-Guide.md`.

## The build path (the PKI critical path)

- [ ] 📋 **RCA01 — offline root ceremony.** CAPolicy.inf → install standalone root role → export root cert + CRL (sneakernet). *Needs:* an isolated Win Svr 2025 box (workgroup, no network). *Unblocks:* **everything** — ICA01 can't be signed without it. → Build-Guide Part 1.
- [ ] 📋 **ICA01 — Enterprise Subordinate CA.** Trust the root forest-wide → CAPolicy.inf → install role + generate request → **sign on RCA01** (sneakernet) → install sub-CA cert → CDP/AIA → start `certsvc`. *Needs:* RCA01 done + DC (domain-join) + the CDP/AIA URL decided. *Unblocks:* all certificate issuance. → Part 2.
- [ ] 📋 **SRV01 — CRL/AIA host** (`nginx`, `pki.atlas.lab`). Publish the CRL + root cert over HTTP. *Needs:* SRV01 built + the `pki.atlas.lab` DNS record. *Unblocks:* **revocation checking** (the Part-4 gate). → Part 2.7.
- [ ] 📋 **Templates + ESC hardening.** Harden ESC1–ESC8 *before* publishing any template. *Needs:* ICA01 running. → Part 3.1.
- [ ] 📋 **DC LDAPS cert** (publish DC template + autoenroll). *Needs:* ICA01 + templates. *Unblocks:* **LDAPS (636)** → FGT01 admin auth (`ADR-0028`), secure LDAP. → Part 3.2–3.4.
- [ ] 📋 **NPS server cert** (A4a). *Needs:* ICA01 + RAS/IAS template. *Unblocks:* **NPS01** PEAP/EAP-TLS (`ADR-0029`). → Part 3.5.
- [ ] 🔴 📋 **Revocation acceptance gate** (mandatory — the `ADR-0009` correction). Prove a revoked cert is *seen as revoked* via the CRL/CDP. *Needs:* CRL published on SRV01. → Part 4.
- [ ] 📋 **Non-domain trust + certs** (Pi-hole / MKT01 / FGT01). Distribute the root anchor; issue each a cert (`ADR-0031`). → Part 3B.

## Future — extensions (later)

- [ ] 📋 **Tier-A A2 — OCSP Online Responder + KRA** (key archival/recovery). Extends ICA01; a new Part in the Build-Guide. *Certs:* 70-742 Ch8. Placement (on ICA01 vs member server) = `Pre-Build-Decisions` E1.
- [ ] 📋 **Consumer certs as hosts build** — Vaultwarden, SQL01, RDS01, MON01, and the future **Exchange / AD FS / Entra Connect / Wazuh**.

## Certification alignment

| Stage | Exercises | Cert |
|---|---|---|
| Two-tier hierarchy, CDP/AIA, offline root | CA install/config, hierarchy design, revocation infra | 70-742 Ch8 · AZ-800/801 (→AZ-802 2026-09-30) · Security+ (PKI) |
| Templates + autoenrollment | certificate templates, GPO autoenroll | 70-742 Ch8 |
| ESC1–ESC8 hardening | AD CS attack paths / misconfig | Security+ · PenTest+ (offensive) |
| OCSP + KRA (A2) | Online Responder, key archival/recovery | 70-742 Ch8 |

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | RCA01 (offline root) | trust anchor / signs ICA01 |
| ⬆ Depends on | DC (AD DS) · DNS (`pki.atlas.lab`) | enterprise CA / autoenroll |
| ⬆ Depends on | SRV01 (`nginx` `pki.atlas.lab`) | CRL/AIA publishing → revocation |
| ⬇ Serves | DC (LDAPS) · NPS01 (RADIUS) · non-domain (Pi/MKT/FGT) | certs / trust |
| ⬇ Serves | Vaultwarden · SQL01 · RDS01 · MON01 · (future Exchange/ADFS/Entra/Wazuh) | TLS certs |

## Related
- `Build-Checklist.md` · `Build-Record.md` · `README.md` · `Considerations.md` · Build-Guide `AD-CS-Two-Tier-Build-Guide.md`. Estate index: `../../Service-Server-Build-Plan.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-29. Standard-audit pass (during the replication wave): trued up the bare **AZ-802** cert tag → **AZ-800/801 (→AZ-802 2026-09-30)** per the cert-label convention; added this Change Log. Build path unchanged. (Companion: `Automation/` added, `ADR-0048`; ICA01 host → PVE02/EQR6, `ADR-0036` v1.2, recorded in README + Build-Record.) |
| 1.0 | 2026-07-29. Created — build path + connections + cert lens for the two-tier PKI critical path. |
