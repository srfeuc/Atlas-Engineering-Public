# MC-0001 — FGT01 Lab CA Certificate Installation (Full Diagnostic Record)

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

| Item | Value |
|---|---|
| **Status** | ✅ **Closed** — certificate installed, bound, and verified on the wire (`openssl s_client`: `issuer=CN=Home Lab Intermediate CA`, `DNS:fortigate.lab, IP:10.10.0.254, IP:172.16.0.1`, valid to 2027-06-20) |
| Change ID | MC-0001 |
| Engineer | Seth |
| Date | 2026-07-13 |
| Maintenance Window | Ad hoc, evening session |
| Estimated Time | Originally estimated ~20 minutes (per CM-0005); actual time significantly longer due to four distinct, compounding issues |
| Priority | Medium |
| Risk | Low (admin GUI certificate only — never affected firewall policy, routing, or traffic passing through FGT01) |
| Affected Systems | FGT01, Pi01, admin workstation |
| Approval Required | No (single-engineer lab) |

## Why This Is a Tier 2 Record

What started as CM-0005 (a routine certificate install, lightweight template) turned into a genuine multi-layered diagnostic problem — four separate, independent issues stacked on top of each other, each one masking the next until it was individually found and fixed. This record exists specifically to preserve *how* that diagnosis actually happened, not just the final state, because the process is more valuable than the conclusion here. CM-0005 remains the short-form pointer in the Change Management index; this is the full record.

## Phase 1 — Planning

**Objective** — Replace FGT01's factory self-signed admin GUI certificate with one issued by the Atlas Lab CA (Pi01), per `ADR-0003` (Pi CA, not AD CS, for non-domain infrastructure).

**Scope** — FGT01 (certificate import and binding), Pi01 (source of the certificate, key, and CA chain), the admin workstation (root CA trust store).

**Dependencies** — `fortigate.crt` and `fortigate.key` already existed on Pi01, issued during the original Lab CA buildout but never installed. The Lab CA's root and intermediate structure already existed and was assumed complete.

**Risks identified in advance** — Admin GUI access could theoretically be disrupted if a bad certificate got bound with no fallback. Mitigated by FortiGate's own behavior: a failed/invalid cert binding does not lock out HTTP(S) access entirely in practice, and console/CLI access via SSH remained available throughout as a fallback path regardless of GUI certificate state.

**Rollback plan** — Revert `admin-server-cert` to `Fortinet_GUI_Server` (factory default) if needed at any point. Not needed — no rollback was performed.

## Phase 2 — Pre-Implementation

- [x] Build Guide reviewed (`031-Pi01-Lab-CA-Build-Guide.md`)
- [x] Build Record reviewed (`021-FGT01-Build-Record.md` — confirmed no cert previously installed)
- [x] Related ADR reviewed (`ADR-0003`)
- [x] Backup: `show vpn certificate local` captured before any change, confirming only factory Fortinet certificates present

## Phase 3 — Implementation (Full Chronological Record)

This is the actual sequence as it happened, including the parts that didn't work — preserved deliberately, per direct instruction that failed attempts get documented too, not just the eventual fix.

| Step | Action | Result | Notes |
|---|---|---|---|
| 1 | `scp` attempted directly from `/etc/ssl/lab-ca/issued/fortigate/` on Pi01 | **Failed** — `Permission denied` | `dnsadmin` lacks direct read access to that path |
| 2 | Staged copies via `sudo cp` + `sudo chown dnsadmin:dnsadmin` into `/tmp/` on Pi01 | Succeeded | Real friction encountered here: repeated attempts to run `ssh pihole` from *inside* Pi01's own shell rather than from Windows — resolved once the prompt distinction (`dnsadmin@pihole:~ $` vs. `PS C:\...`) was pointed out |
| 3 | `scp pihole:/tmp/fortigate.crt` / `.key` from Windows | Succeeded | Files landed on workstation |
| 4 | Attempted `System > Certificates` in FGT01 GUI | **Not present at all** | Initially suspected to be a FortiCare licensing restriction |
| 5 | Verified against Fortinet's own current documentation | Confirmed: **not a licensing issue.** Certificates is a GUI-only visibility toggle, hidden by default. Functionality is never gated by feature visibility, only the menu's presence | Corrected a real, reasonable misconception before acting on it |
| 6 | `System > Feature Visibility` → enabled Certificates | Succeeded | Menu appeared |
| 7 | `System > Certificates > Import > Local Certificate` — uploaded `fortigate.crt` + `fortigate.key`, named `FortiGate-Lab-CA` | Succeeded | |
| 8 | `config system global / set admin-server-cert "FortiGate-Lab-CA"` | *Appeared* to succeed | **This step silently did not take effect — discovered much later at Step 19** |
| 9 | Workstation root CA trust checked | **Not present** | Separate, previously unaddressed gap, caught proactively before testing rather than discovered via failure |
| 10 | Retrieved `root-ca.crt` via the same Pi01 staging method, installed to Windows Trusted Root store | Succeeded | |
| 11 | First browser test: `https://10.10.0.254` | **Failed** — `ERR_CERT_AUTHORITY_INVALID` | |
| 12 | Diagnosed as a missing intermediate chain; imported `ca-chain.crt` as a `CA Certificate` object on FGT01 | Succeeded as an import, but... | ...this was **not the actual fix** — a `CA Certificate` object tells FortiGate to trust that intermediate for validating *other* connections, it does not get automatically attached to what FGT01 *presents* as its own server certificate |
| 13 | Retest | **Still failed** | |
| 14 | Ran `openssl s_client -connect 10.10.0.254:443 -showcerts \| grep -c "BEGIN CERTIFICATE"` | Returned **1** | First hard evidence — proved only the leaf certificate was being served, no chain, confirming Step 12 didn't solve it |
| 15 | Built a proper bundle on Pi01: `cat fortigate.crt ca-chain.crt > fortigate-bundle.crt` | Succeeded | This is the correct pattern — matches how Pi-hole's own certificate was already bundled in the original Lab CA build |
| 16 | Deleted old `FortiGate-Lab-CA` local cert; imported the bundle as a new Local Certificate named `fortigate-bundle` | Succeeded | |
| 17 | Re-ran the `openssl s_client` chain count | **Still 1** | This is what triggered checking the actual binding rather than the certificate itself |
| 18 | `show system global \| grep admin-server-cert` | **Empty output** | `show` only displays settings that differ from factory default — this alone doesn't prove default, needed the next step to confirm |
| 19 | `get system global \| grep admin-server-cert` | **`Fortinet_GUI_Server`** | **Root cause found.** Step 8's apparent success never actually took — the admin GUI had been serving the factory certificate this entire time, regardless of every correct step taken with the certificates themselves |
| 20 | `config system global / set admin-server-cert "fortigate-bundle"` | Succeeded | |
| 21 | `get system global \| grep admin-server-cert` | Confirmed: `fortigate-bundle` | |
| 22 | `openssl s_client` chain count re-run | **3** | Leaf + intermediate + root, correct complete chain |
| 23 | Browser test, normal Chrome window | **Still failed** — showed factory cert details (Issued 2026-07-09, serial `FGT60ETK18099YR2`) | Server-side was now provably correct per Step 22; this pointed to the browser, not the server |
| 24 | Diagnosed as Chrome TLS session caching, not a real remaining server issue | | |
| 25 | Tested via Incognito window | **Success — clean, no warning** | Confirmed the fix was complete and correct; normal-window Chrome was serving cached state |

## Phase 4 — Validation

**Network**
- [x] FGT01 admin GUI reachable throughout — no access disruption at any point

**Certificate chain**
- [x] `openssl s_client` confirms 3 certificates served (leaf, intermediate, root)
- [x] `get system global | grep admin-server-cert` confirms `fortigate-bundle` bound
- [x] Windows `certmgr.msc` confirms Lab CA root shows "This certificate is OK"
- [x] Incognito browser test passes clean with no certificate warning

## Phase 5 — Documentation

- [x] FGT01 Build Record — certificate item to be updated from Known Deviations to installed
- [x] Pi01 Build Record — FortiGate certificate status to be updated from "issued, not installed" to installed
- [x] New Operations Guide written: `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` — captures the correct process end-to-end so this sequence doesn't need re-discovering for MikroTik (CM-0007) or any future device
- [x] Runbook's Common Mistakes section updated with the binding-verification lesson and the bundle requirement
- [x] Runbook's Part C updated with a 🔵 Why? callout on trust-store semantics
- [x] This record (MC-0001)

## Phase 6 — Closeout

**Did the change succeed?** Yes.

**Unexpected Issues**

Four independent, compounding problems, each masking the next:

1. FortiOS hides the Certificates menu by default (feature visibility, not licensing — easy to misdiagnose as the latter).
2. A `CA Certificate` import does not get automatically attached to what a device presents as its own server certificate — a proper leaf+intermediate bundle must be built and imported as the *Local Certificate* instead.
3. `set admin-server-cert` can silently fail to take effect (or simply wasn't actually applied despite appearing to succeed) — the only reliable way to confirm is `get`, never `show` (which only displays non-default values) and never by assuming a prior `set` command worked.
4. Browser TLS session caching can outlast closing all windows — Incognito or a full process kill is the only reliable way to validate a server-side certificate change from Chrome.

**Improvements for Next Time**

The new Runbook (`035`) exists specifically so CM-0007 (the equivalent MikroTik certificate work) and any future device don't have to rediscover any of these four issues. Recommend reviewing that runbook's Part B and the Common Mistakes section before starting CM-0007.

**Lessons Learned**

The most valuable one: **a successful-looking `set` command is not the same as a confirmed active configuration.** Every single certificate-side step in this process was done correctly on the first attempt. The actual defect was an unrelated, silent binding failure that nothing about the certificate work itself would ever have surfaced — only checking the live state directly (`get`, not assumption) found it.

**Final Status** — Production Accepted.

## Related Pages

- `CM-0005-Install-Lab-CA-Certificate-on-FGT01.md` — the original short-form record this expands on
- `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` — the operational guide this incident directly produced
- `ADR-0003-AD-CS-vs-OpenSSL-Lab-CA.md` — the decision this change implements
