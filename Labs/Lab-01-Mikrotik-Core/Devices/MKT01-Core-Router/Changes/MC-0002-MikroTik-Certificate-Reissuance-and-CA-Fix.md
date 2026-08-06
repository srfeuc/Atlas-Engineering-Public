# MC-0002 — MikroTik Certificate Reissuance and CA-Wide `copy_extensions` Fix

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| **Status** | ✅ **Closed** — certificate reissued with correct SAN (`mikrotik-bundle.crt_0`, serial `1001`, `DNS:mikrotik.lab, IP:10.10.0.1`), and the CA-wide `copy_extensions` defect fixed. **Follow-up closed 2026-07-13:** FGT01 and Pi-hole certificates independently re-verified on the wire — both correct, both Lab CA-issued. |
| Change ID | MC-0002 |
| Engineer | Seth |
| Date | 2026-07-13 |
| Maintenance Window | Ad hoc, evening session |
| Estimated Time | Originally scoped as a routine SAN correction (~15 min); actual scope expanded to a CA-wide configuration defect |
| Priority | Medium |
| Risk | Low (admin GUI certificate only) — but the root cause found has Medium implications for other already-issued certificates |
| Affected Systems | MKT01, Pi01 (Lab CA config — affects all future and possibly all past issuances) |
| Approval Required | No (single-engineer lab) |

## Why This Is a Tier 2 Record

What started as CM-0008 (reissue one certificate with a corrected SAN) uncovered a defect in the Lab CA's core configuration — present since the CA was originally built, affecting every certificate it has ever signed under the `server_cert` profile. This is the second time a "simple" certificate task has revealed a deeper systemic issue (MC-0001 was the first) — worth recording the same way, in full.

## Phase 1 — Planning

**Objective** — Reissue MKT01's `www-ssl` certificate with a corrected SAN (`10.10.0.1` instead of the stale `10.0.0.1`/`172.31.4.144`).

**Scope** — Pi01 (certificate issuance), MKT01 (installation and binding).

**Dependencies** — Root CA already trusted on the admin workstation from the FGT01 work (MC-0001) — Part C of the issuance runbook did not need repeating.

**Risks identified in advance** — Low; admin GUI certificate only, no traffic-path impact. WinBox remained available as a fallback management path throughout, since HTTP/HTTPS GUI access is currently disabled on this device.

## Phase 2 — Pre-Implementation

- [x] `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` and `042-Certificate-Reissuance-and-Renewal-Guide.md` reviewed
- [x] Backup: `openssl x509 ... -serial -subject` and SAN content of the existing certificate captured before any change
- [x] Backup: `/certificate print detail` on MKT01 captured before any change

## Phase 3 — Implementation (Full Chronological Record)

| Step | Action | Result | Notes |
|---|---|---|---|
| 1 | Generated new CSR on Pi01 with `-addext "subjectAltName=DNS:mikrotik.lab,IP:10.10.0.1"` | Completed, but **Common Name left blank** at the interactive prompt | First real mistake — easy to do, the field looks optional like the others |
| 2 | Signed the CSR | **Failed** — `The commonName field needed to be supplied and was missing` | The CA's policy requires CN; correctly refused to sign, no file written |
| 3 | Regenerated CSR, this time supplying `Common Name: mikrotik.lab` | Succeeded | |
| 4 | Signed the CSR | **Appeared to succeed** — clean sign, no errors | |
| 5 | Verified the resulting certificate directly (`openssl x509 ... -text \| grep SAN`) | **Empty — no SAN at all** | This is the moment that mattered — checking the actual file instead of trusting a clean-looking sign log caught a real defect immediately |
| 6 | Investigated root cause: checked `copy_extensions` in the CA config | **Missing entirely** — not set anywhere in `[ CA_default ]` | Confirmed via direct `grep`, not assumption |
| 7 | Checked the `[ server_cert ]` extension profile | **No `subjectAltName` defined there either** | Confirms this CA has had no reliable SAN mechanism since it was originally built — not a new regression, a pre-existing gap |
| 8 | Located `[ CA_default ]` via `grep -n`, attempted to insert `copy_extensions = copy` via a line-number-based `sed` edit | **Landed in the wrong section** | The assumed line number was off by one; the line ended up inside `[ ca ]` instead of `[ CA_default ]` |
| 9 | Corrected using a content-anchored `sed` command (`/\[ CA_default \]/a ...`) instead of a line number | Still produced a duplicate — the old misplaced line hadn't been removed yet | |
| 10 | Deleted the misplaced line, confirmed final state with `sed -n` | **Correct** — exactly one `copy_extensions = copy` line, directly under `[ CA_default ]` | |
| 11 | Regenerated the CSR a third time, with CN supplied correctly this time | Succeeded | |
| 12 | Signed the CSR | **Failed** — `ERROR: There is already a certificate for .../CN=mikrotik.lab` | The Step 4 certificate (the one with no SAN) had actually been issued successfully and was sitting in the CA's database as a valid, active entry — the CA correctly refused to issue a second certificate for the same identity while the first was still valid |
| 13 | Revoked the broken certificate (serial `1000`) via `openssl ca -revoke` | Succeeded | Correct resolution — that certificate was genuinely useless (no SAN) and should not have stayed active |
| 14 | Regenerated the CRL | Succeeded | Housekeeping — keeps the CA's revocation record current |
| 15 | Signed the CSR again | **Succeeded, new serial `1001`** | |
| 16 | Verified SAN directly on the new certificate file | **Correct** — `DNS:mikrotik.lab, IP Address:10.10.0.1` | First real proof the config fix worked |
| 17 | Rebuilt the bundle (leaf + intermediate chain), staged for retrieval | Succeeded | |
| 18 | Retrieved files to Windows workstation, saved to `C:\Temp` (not the Git repo) | Succeeded | Applying the lesson from MC-0001 up front this time |
| 19 | WinBox file upload — initial attempt | **Failed** — `not enough permissions for file` | Same class of issue as MC-0001, different device |
| 20 | Re-ran WinBox as Administrator | Succeeded | Confirmed root cause without needing to test the OneDrive/repo-folder theories this time — elevation alone fixed it |
| 21 | Removed old certificate objects before importing (`/certificate remove [find name~"mikrotik-bundle"]`) | Succeeded | Applying the "don't leave old and new certificate objects both present" lesson from the Reissuance Guide |
| 22 | Attempted `/certificate import file-name=mikrotik-bundle.crt` before the file transfer had actually completed | **Failed** — `input does not match any value of file-name` | Command run out of sequence; not a real error once retried after the transfer finished |
| 23 | Re-ran import after confirming the transfer completed | **Succeeded** — `certificates-imported: 3` | |
| 24 | Imported the key separately | **Succeeded** — `private-keys-imported: 1` | |
| 25 | Checked actual assigned object name via `/certificate print detail` | `mikrotik-bundle.crt_0`, serial `1001`, SAN correct, `trusted=yes` | RouterOS renamed on import, same behavior as MC-0001 predicted |
| 26 | Bound the certificate: `/ip service set www-ssl certificate=mikrotik-bundle.crt_0` | Succeeded | |
| 27 | Verified live-served certificate: `openssl s_client ... \| grep SAN` | **Confirmed:** `DNS:mikrotik.lab, IP Address:10.10.0.1`, served live, not just present in the local file | Final proof — the live device is actually presenting the corrected certificate |

## Phase 4 — Validation

- [x] New certificate has correct SAN (`10.10.0.1`) — confirmed on the file
- [x] New certificate has correct SAN — confirmed on the **live served** connection via `openssl s_client`
- [x] `www-ssl` bound to the new certificate object (`mikrotik-bundle.crt_0`, serial `1001`)
- [x] Old broken certificate (serial `1000`, no SAN) formally revoked, not just abandoned
- [x] CRL regenerated to reflect the revocation
- [ ] Browser test — not performed; HTTP/HTTPS GUI access is currently disabled on this device (WinBox-only management), so this validation step isn't available. The `openssl s_client` checks are the substitute proof of correctness here.

## Phase 5 — Documentation

- [x] MKT01 Build Record — certificate details updated to the new serial and correct SAN
- [x] Pi01 Build Record — Lab CA configuration change (`copy_extensions = copy`) documented as a permanent baseline change
- [x] `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md` — updated with the missing config step and a Lessons Learned entry
- [x] `042-Certificate-Reissuance-and-Renewal-Guide.md` — Common Mistakes updated with the identity-conflict/revoke-before-reissue lesson
- [x] `041-MKT01-Troubleshooting-Guide.md` — cross-referenced
- [x] This record (MC-0002)
- [ ] **Open action, not yet done:** verify whether Pi-hole's and FortiGate's existing certificates have the same defect — see Closeout

## Phase 6 — Closeout

**Did the change succeed?** Yes.

**Unexpected Issues**

The real finding here isn't the MikroTik certificate — it's that **the Lab CA's configuration has been missing `copy_extensions` since it was originally built**, meaning this defect is not specific to this one reissuance. Two open questions this raises, not yet answered:

1. **Were Pi-hole's and FortiGate's original certificates affected the same way?** Their SANs were never directly verified against the live-served certificate this session — FGT01's browser test passed, which implies its SAN is probably fine, but that was never explicitly confirmed by reading the SAN field directly, only inferred from the absence of a warning. Worth a direct check, not an assumption.
2. **Was the original MikroTik certificate's SAN (before tonight) actually produced via `copy_extensions`, or some other mechanism?** It had a SAN (albeit stale) despite the config gap existing the whole time — meaning the original issuance process may have used a different method (e.g., a config-file-embedded SAN block) that doesn't depend on `copy_extensions` at all. Understanding this would explain why this bug went unnoticed until now.

**Improvements for Next Time**

- The Reissuance Guide (`042`) needs the identity-conflict lesson: reissuing a certificate for an identity that already has a valid entry will fail until the old one is explicitly revoked, even if the old certificate is known to be broken/unused.
- Always verify a CSR's Common Name was actually supplied before signing — an empty CN fails cleanly, but it's an easy field to skip since every other field in the prompt shows a default.
- Always verify SAN content by reading the actual certificate file (`openssl x509 ... -text`), never trust a clean-looking `openssl ca` sign log alone — this is what caught the missing SAN immediately in Step 5, before wasted effort went into the install step.

**Lessons Learned**

The most valuable one, and it echoes MC-0001's lesson from a different angle: **checking the actual resulting artifact (the certificate file, the live-served connection) caught two real defects that a "the command ran without error" read would have missed entirely** — the missing SAN in Step 5, and the config file misplacement in Step 8-9. Every verification step in this record earned its place.

**Final Status** — Production Accepted, with one open follow-up action (verify Pi-hole/FortiGate certificate SANs) not yet scheduled.

## Related Pages

- `CM-0007-Install-Lab-CA-Certificate-on-MikroTik.md`, `CM-0008-Reissue-MikroTik-Certificate-Correct-SAN.md` — the original short-form records this expands on
- `042-Certificate-Reissuance-and-Renewal-Guide.md` — the general process this record's real-world edge cases now inform
- `031-Pi01-Lab-CA-Build-Guide.md` — updated with the permanent config fix
- `MC-0001-FGT01-Lab-CA-Certificate-Installation.md` — the earlier, related diagnostic record
