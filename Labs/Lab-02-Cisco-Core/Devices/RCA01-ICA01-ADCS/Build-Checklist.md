---
Title: RCA01/ICA01 — Build Checklist (two-tier AD CS)
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 📋 Planned — the ordered action list for the two-tier PKI. Decision-free; the *how* (commands/screens) is `AD-CS-Two-Tier-Build-Guide.md`. Every `[ ]`→`[x]` needs a command + output (`POL-0001`).
Version: 1.0
Date: 2026-07-29
---

# RCA01 / ICA01 — Build Checklist (two-tier AD CS)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The sequence to stand up the estate PKI. Build **from this**; capture the *how* live into the Build-Guide + Diagnostics as you go. 🔴 The offline-root ceremony gates the rest.

## Gate
- [ ] ICA01 host reachable + IP set (`10.20.0.4`) — ✅ 07-22. DC reachable (domain-join target). The `pki.atlas.lab` CDP/AIA URL decided (Build-Guide §0.5).

## RCA01 — offline root
- [ ] Isolated Win Svr 2025, **workgroup, no network**; rename **before** the role (§0.3).
- [ ] `CAPolicy.inf` (root) in `C:\Windows\` **before** install (§1.2); install standalone root role (§1.3).
- [ ] Post-install registry: HTTP-only CDP/AIA + sub-CA validity (§1.4); export root cert + CRL to sneakernet (§1.5). 🎯 Accept: root cert + CRL in hand.

## ICA01 — enterprise subordinate
- [ ] Domain-join `atlas.lab`; trust the root forest-wide (§2.2); `CAPolicy.inf` (issuing) before the role (§2.3).
- [ ] Install role → generate request (§2.4); **sign on RCA01** (§2.5); install sub-CA cert + CDP/AIA; start `certsvc` (§2.6). 🎯 Accept: `certutil -cainfo` = Enterprise Subordinate, chain valid.
- [ ] **Publish CRL + root** to `http://pki.atlas.lab/pki/` on SRV01 (§2.7). 🎯 Accept: `curl -I` = 200.

## Templates, LDAPS, RADIUS
- [ ] **ESC1–ESC8 harden** before publishing anything (§3.1).
- [ ] Publish DC template + autoenroll (§3.2–3.3); 🎯 **verify LDAPS 636** (§3.4).
- [ ] NPS server cert (§3.5) for NPS01 PEAP.

## Revocation gate + non-domain
- [ ] 🔴 **Revocation acceptance gate** (§Part 4) — revoke a test cert, prove it reads revoked via the CDP. **Mandatory.**
- [ ] Distribute root trust + issue certs to Pi-hole / MKT01 / FGT01 (§3B, `ADR-0031`).

## Recovery
- [ ] CA backup + offline-root media off-site copy; break-glass documented (§Part 5). Vaultwarden custody **after** its recovery path is proven (E2).

## Related
- `AD-CS-Two-Tier-Build-Guide.md` (the how) · `Diagnostics-ICA01.md` (verify) · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created — the ordered two-tier AD CS checklist (RCA01 root → ICA01 sub-CA → SRV01 CRL host → templates/ESC/LDAPS → NPS cert → revocation gate → non-domain → recovery), pointing to the Build-Guide Parts for the how. Not executed. |
