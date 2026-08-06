---
Title: SRV01 / nginx-CRL — Build Checklist (CRL/AIA host)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services/Roles/nginx-CRL
Status: 📋 Planned — 🔴 the PKI critical-path deliverable. Host build = `../../Build-Checklist.md`; the how = `../../Build-Guide.md` Part 3.
Version: 1.0
Date: 2026-07-29
---

# SRV01 / nginx-CRL — the CRL/AIA host (`pki.atlas.lab`)

> 🔴 **The estate's revocation endpoint.** ICA01 publishes its CRL + root cert here; every relying party fetches revocation from `http://pki.atlas.lab/pki/`. On the AD CS critical path.

## Deps
- [ ] Host (SRV01) built + hardened · `pki.atlas.lab` A-record on DC01 · **ICA01** producing a CRL to publish.

## Steps (detail in `../../Build-Guide.md` Part 3)
- [ ] Install `nginx`; create the web root `/pki/`.
- [ ] Server block with the correct **media types (RFC 2585)** — `.crl` = `application/pkix-crl`, `.crt` = `application/pkix-cert`.
- [ ] Publish the CA files (AD CS §2.7 lands here) + the offline-root CRL-refresh workflow (Part 4).
- [ ] Role firewall: open port 80.

## Accept (`POL-0001`)
- [ ] `curl -I http://pki.atlas.lab/pki/<root>.crl` = 200 + correct content-type; a relying party fetches **and parses** the CRL.
- [ ] CRL freshness (`nextUpdate`) check passes.

## Related
- `../../Build-Guide.md` Parts 3–4 · `../../../RCA01-ICA01-ADCS/` (the CA that publishes here) · `../../Considerations.md` (PKI-grade availability).
