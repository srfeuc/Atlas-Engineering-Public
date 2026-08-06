---
Title: BKP01 / Vaultwarden — Build Checklist (secrets vault)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/Roles/Vaultwarden
Status: 📋 Planned — the estate secrets vault (`ADR-0031` A3a relocation). Host build = `../../Build-Checklist.md`; the how = `../../Build-Guide.md` Parts 5–6.
Version: 0.1
Date: 2026-07-30
---

# BKP01 / Vaultwarden — the secrets vault

> 🔴 **Every credential + CA-passphrase custody rides on this (`ADR-0009`, `POL-0002`).** It replaces the OpenSSL CA's role as secret home (`ADR-0031`, the "A3a relocation") and must stand up **before any CA-passphrase handling**.

## Deps
- [ ] Host (BKP01) built + hardened · **ICA01** issuing a TLS cert · DNS for the vault FQDN (→ `10.20.0.13`).

## Steps (detail in `../../Build-Guide.md` Parts 5–6)
- [ ] 📋 Install **Vaultwarden** (standalone web console) on `10.20.0.13`, VLAN 20.
- [ ] 📋 **ICA01 TLS** — request/bind the web cert (HTTPS-only; `pki.atlas.lab` chain).
- [ ] 📋 **Admin token** set + kept **offline** (`POL-0002`) — never in git.
- [ ] 🔴 📋 **`049` master-password recovery gate** — resolve the recovery path **before** trusting it as the vault. *(`049` is a design-question ref, NOT ADR-0049.)*
- [ ] 📋 **Back the vault into PBS** — the vault data itself becomes a PBS backup source (and thus off-site too).

## Accept (`POL-0001`)
- [ ] 📋 HTTPS via the **ICA01-chained** cert (no browser warning); `openssl s_client` confirms the chain.
- [ ] 🔴 📋 The `049` recovery path is decided + documented offline — else the vault is a single point of unrecoverable loss.
- [ ] 📋 A vault backup appears in PBS and restores.

## Related
- `../../Build-Guide.md` Parts 5–6 · `../../../RCA01-ICA01-ADCS/` (the CA that issues the cert) · `../../Considerations.md` (the `049` gate + co-location blast radius) · `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-07-30 | Created — Vaultwarden install, ICA01 TLS, offline admin token, 🔴 the OPEN `049` master-password recovery gate, and backing the vault into PBS. |
