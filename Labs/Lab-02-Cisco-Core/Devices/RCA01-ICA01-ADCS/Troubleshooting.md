---
Title: RCA01/ICA01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS
Status: 🟡 Seeded — real PKI failure modes to expect; fill with actual incidents as the build runs. Links up to Academy where a concept explains the *why*.
Version: 0.1
Date: 2026-07-29
---

# RCA01 / ICA01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** Symptom → cause → fix for the two-tier PKI. Seeded with the known AD CS traps; add real incidents (with evidence) as they occur.

| Symptom | Likely cause | Fix / check |
|---|---|---|
| Issued cert has **no SAN** / clients reject it | template `copy_extensions`/SAN not set — the Lab-01 `CM-0027` bug | verify the *issued* cert's SAN (`certutil -dump`); fix the template, reissue. Don't trust "it enrolled." |
| **Revocation check fails** / cert shows revoked-unknown | CDP/AIA endpoint (`pki.atlas.lab` on SRV01) unreachable, or CRL expired/not published | `curl -I http://pki.atlas.lab/pki/`; republish CRL (§2.7); check CRL validity + overlap |
| **LDAPS (636) won't bind** | DC has no valid KDC/LDAPS cert, or chain not trusted | confirm DC autoenrolled the cert; `certutil -verify`; check the DC trusts the root |
| Sub-CA won't start (`certsvc`) | sub-CA cert not installed, or chain/CDP invalid at install | re-run §2.6; verify the RCA01-signed cert + CRL are present and valid |
| **Autoenrollment not issuing** | template perms (Enroll/Autoenroll) or GPO not applied | template security; `gpupdate`; `certutil -pulse`; check the autoenroll GPO scope |
| Root/sub **time skew** breaks validity | RCA01 clock drifted (offline box), or ICA01 not on DOMHIER time | set RCA01 time at ceremony; ICA01 `w32tm /query /source` = DC |
| ESC finding in the validation pass | over-permissive template (ESC1–8) | harden per §3.1 **before** publishing; re-test in `Validation-and-Adversarial-Testing.md` |

## Related
- `AD-CS-Two-Tier-Build-Guide.md` · `Diagnostics-ICA01.md` · `Considerations.md` · `Atlas-Academy/Concepts/` (PKI "why it works", when written).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded with the known AD CS failure modes (no-SAN, revocation/CDP unreachable, LDAPS bind, sub-CA start, autoenroll, time skew, ESC). Fill with real incidents as the ceremony + issuance run. |
