---
Title: Playbook — Read the Cert, Not the Sign Log (a clean issuance ≠ a correct certificate)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — the per-step read-backs land the first time this is worked on the live AD CS stack. Grounded in the real frozen **Lab-01** `MC-0002` (device-verified 2026-07-13) + the CA fix in the Lab-01 **Lab-CA Build-Guide**, current-design-reconciled (`ADR-0022`; OpenSSL Lab CA → **AD CS** two-tier, `ADR-0031`). Searchable/ticket-ready per Backlog **#32**. 🥇 **The golden-template reference** (`ADR-0053` §5).
Version: 1.2
Date: 2026-08-01
---

# Playbook — Read the Cert, Not the Sign Log

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: PKI / certificate-issuance verification — an **action-layer** page: the commands you run and the doc that owns the fix, not the theory. **You issued or reissued a certificate, the CA reported success — is the certificate it handed back actually correct?** Read the SAN (and the chain, and the issuer) off the **issued file** and off the **served connection**, never off the CA's "issued OK". *(The **why** — a completed command is a claim, not evidence — lives in the Concept it links up to; this page is the procedure.)*

**The one-line problem.** A certificate that **signed with a clean log and is still wrong** — no SAN, a stale SAN, a bare leaf, or a self-signed cert masquerading as CA-issued — caught only by reading the artifact.

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **Read the artifact (why → the Concept)**.
3. **How a SAN is actually configured in OpenSSL** — and why there's no safe default.
4. **① Pin it down** — the facts to capture first.
5. **The commands — the diagnosis path** (command-first):
   - 5.1 Read the SAN + issuer off the **issued file**.
   - 5.2 SAN empty/wrong → check the **CA carries it** (`copy_extensions` / `-extfile` / the template).
   - 5.3 Reissue blocked by an **identity conflict** → revoke (+ the CRL caveat).
   - 5.4 Install/bind → the object is **renamed on import**; read it back.
   - 5.5 Prove it **on the wire** — `s_client`, chain = 3, issuer checked.
6. **The fix — where it's documented** (point down, don't re-derive) · **If still broken**.
7. **Gap / what this closes** · **Worked example → `MC-0002`** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type** (one per line — each is its own searchable symptom)

- "`ERR_CERT_AUTHORITY_INVALID`" — a client rejects the chain (usually a **bare leaf**, step 5).
- "`NET::ERR_CERT_COMMON_NAME_INVALID`" — the hostname isn't in the SAN (**empty/stale SAN**, step 1).
- "*the name on the security certificate does not match*" — same as above, the classic name-mismatch wording.
- "*your connection is not private*" — the generic browser interstitial that fronts either of the above.
- "*the CA says issued but the SAN is empty / stale / still the old IP*" — the clean-log-lied case (step 1–2).
- "*the device is serving a self-signed / factory cert*" — wrong object bound / a masquerade (check the **issuer**, step 5).
- 🟡 (real read-back, quoted from the frozen record — `POL-0001`): `openssl x509 ... -text | grep -A1 "Subject Alternative Name"` returns **nothing** after a clean `openssl ca` sign.
- 🟡 `openssl ca ...` → `ERROR: There is already a certificate for .../CN=<name>` on a reissue (**identity conflict**, step 3).

**Plain-language symptom phrases**

- "the cert issued fine but it's wrong / has no SAN / the SAN is the old address."
- "the sign log was clean — why is the cert bad?"
- "the browser rejects a cert I just issued."
- "I can't reissue — the CA says one already exists."
- "the device is still serving the old / factory certificate after I imported the new one."

**Aliases / also-known-as**

- clean sign log · empty SAN · missing/stale SAN · no subjectAltName · CN-only cert · `copy_extensions` · bare leaf vs full chain · name mismatch · self-signed-masquerade · check the **issuer** not just the SAN.
- read the artifact not the log · verify the issued cert · verify the served cert · identity conflict · revoke-before-reissue · renamed-on-import · AD CS template SAN.

**Keywords line**

`MC-0002` · `openssl x509 -text` · `subjectAltName` · `-addext` · `copy_extensions = copy` · `[ CA_default ]` · `-extfile` · `openssl ca -revoke` · CRL/CDP · `openssl s_client -showcerts` · `grep -c "BEGIN CERTIFICATE"` = 3 · issuer · `mikrotik-bundle.crt_0` · `/certificate print detail` · `/ip service print detail` · AD CS · ICA01 · `certutil -dump` · `ADR-0031`.

## Cert anchor

- CompTIA **Security+** (PKI: SAN, chain of trust, CRL/revocation) — the primary anchor.
- **Linux+** (`openssl` x509/ca/s_client), **FCP** / **CCNA** (install + bind a device cert), **AD CS** in **AZ-800/801** (templates, SAN source, auto-enrolment).
- *(Grounding index: `../Atlas-Certification-Lab-Map.md` · `../Atlas-Security-Plus-Domain5-Coverage-Map.md`.)*

## Read the artifact (the why is in the Concept)

The certificate the CA hands back is the only evidence — not the issuance log, not the CA's "Issued" view (`POL-0001`). **Why a completed command isn't proof** is the mentality module this page applies: [`../Concepts/A-Completed-Command-Is-Not-Evidence.md`](../Concepts/A-Completed-Command-Is-Not-Evidence.md). This page is the certificate-specific procedure — the three ways a cleanly-signed cert is still wrong, and the exact reads that catch each:

| Failure mode | The tell (read the artifact) | Where it shows |
|---|---|---|
| **Empty SAN** (CA never carried the extension) | `openssl x509 -text` SAN line is **absent** | the file |
| **Stale SAN** (real, but the old identity/IP) | SAN shows `10.0.0.1` not the live `10.10.0.1` | the file |
| **Bare leaf** (no intermediate+root installed) | `grep -c "BEGIN CERTIFICATE"` = **1**, not 3 | the wire |
| **Self-signed masquerade** (a factory cert, not CA-issued) | `issuer` is the device itself, not the CA | the wire |

## How a SAN is actually configured in OpenSSL (and why there's no safe default)

This is the mechanism behind the most common failure above — and the reason "trust the default" is not an option.

**There is no usable default SAN.** A certificate with no `subjectAltName` is rejected by every modern client: browsers and most libraries **ignore the Common Name for hostname validation** (deprecated by RFC 2818 / the CA-Browser-Forum) and match **only** the SAN. So a SAN must be *explicitly requested and explicitly carried* — and OpenSSL, by a deliberate security default, **does neither for you**.

Two things have to be true:

1. **The CSR must request the SAN.** Supply it at request time — `-addext` (or `[ req ] req_extensions = v3_req` + a `[ v3_req ] subjectAltName = ...` block in the config):
   ```bash
   openssl req -config openssl.cnf -key <device>.key -new -sha256 \
     -out csr/<device>.csr \
     -addext "subjectAltName=DNS:mikrotik.lab,IP:10.10.0.1"
   ```
2. **The CA must carry it into the signed cert.** This is the step people miss: **`openssl ca` silently discards any SAN requested in the CSR unless the CA is told to copy it.** Set it once in the CA config, in the **right section**:
   ```text
   # /etc/ssl/lab-ca/intermediate/openssl.cnf   →  [ CA_default ]
   copy_extensions = copy
   ```
   > 🔴 **Why it defaults to off:** `copy_extensions` is unset by design — you don't want an untrusted CSR smuggling arbitrary extensions (extra SANs, key usages) past the CA operator. The safe-by-default behaviour is to **drop** them. That safety is also the foot-gun: with it unset, `-addext` is **silently ignored** and every cert the CA issues has **no SAN** — and the sign log looks clean either way (`MC-0002`).
   > 🔵 **Confirm it landed in `[ CA_default ]`, not `[ ca ]`** (which sits directly above it — a line-number edit lands one section high): `sudo sed -n '/\[ CA_default \]/,/^\[/p' openssl.cnf | grep copy_extensions`.

**The alternative that bypasses `copy_extensions` entirely:** supply extensions at signing with **`-extfile`** — `openssl ca ... -extfile san.ext`. A cert signed this way carries its SAN regardless of `copy_extensions`. *(This is why FGT01's cert — issued three weeks before the fix with `-extfile` — was correct anyway; `MC-0001`/the Build-Guide.)*

**Reconciled to AD CS (`ADR-0031`).** On Lab-02's AD CS, the SAN comes from the **certificate template's** configured source — the request (with the SAN in the CSR / INF) or built from the AD object — **never** the dangerous CA flag `EDITF_ATTRIBUTESUBJECTALTNAME2` (the AD CS equivalent of a wide-open `copy_extensions`, a known privilege-escalation anti-pattern). The discipline is identical: configure the SAN source deliberately, then **read it back off the issued cert**.

> **The takeaway:** you never *trust* a SAN — you *configure* it (request + carry) and then *verify* it, on the file and the wire. There is no default to fall back on.

## ① Pin it down (capture these first — they're the ticket)

- a. **The certificate identity** — the CN and the **intended SAN(s)** (DNS + IPs) it must carry, and the host/service it's for.
- b. **The CA + method** — which CA/template signed it (AD CS ICA01 / the retired OpenSSL Lab CA in a frozen record), and *what told you it "worked"* (a clean `openssl ca` log? an AD CS "Issued" row?). That is the claim you're about to test.
- c. **Verified where so far** — do you have a **read-back of the issued file** and of the **served connection** (SAN, chain, **issuer**), or only the log?
- d. **Expected vs actual** — the exact client error (`ERR_CERT_AUTHORITY_INVALID` = chain; name-mismatch = SAN) points at which failure mode.
- e. **Rollback ready** — the previous cert object still present/exported; a management path back in if you're changing the management GUI's own cert (`Recover-a-Locked-Out-Router-Out-of-Band.md`).

## The commands — the diagnosis path (read the artifact, never the log)

> Command-first. Each step: the exact command · Healthy · Broken · 📸 · the `MC-0002` step that proved it. Commands link down to the Command-Library (`POL-0008`), never restated there.

**1. Read the SAN + issuer off the issued *file*.**

```bash
openssl x509 -in <device>.crt -noout -text | grep -A1 "Subject Alternative Name"
openssl x509 -in <device>.crt -noout -issuer -subject
```
- AD CS equivalent: `certutil -dump <cert>` (or `certlm.msc` → the cert → *Details → Subject Alternative Name*).
- Ref: `../Command-Library/Linux.md` §Web / CRL host · `../Command-Library/PowerShell-Tier0.md` (AD CS).
- Healthy: the SAN lists **every** intended name/IP (`DNS:mikrotik.lab, IP Address:10.10.0.1`); issuer = the CA.
- 🔴 Broken: **empty** SAN (the CN-only trap) · a **stale** value · issuer = the device itself (a self-signed masquerade).
- 📸 the `grep` output (empty-vs-correct). Do this **before** installing — it saves the whole install effort. → *`MC-0002` Step 5 (empty SAN caught here) / Step 16 (correct SAN).*

**2. Empty/wrong SAN → confirm the CA is actually carrying it.**

```bash
sudo sed -n '/\[ CA_default \]/,/^\[/p' openssl.cnf | grep copy_extensions   # expect: copy_extensions = copy
```
- If unset → that's the defect (see *How a SAN is configured* above): set `copy_extensions = copy` in `[ CA_default ]` (or sign with `-extfile`), then reissue. AD CS: fix the **template's** SAN source, not a CA-wide flag.
- Healthy: the policy carries the SAN for every issuance. Broken: it doesn't — fix the CA/template, don't just re-request.
- → *`MC-0002` Steps 6–10 (root cause = `copy_extensions` unset; the misplaced-`sed` sub-lesson).*

**3. Reissue blocked by an identity conflict → revoke first (mind the CRL caveat).**

```bash
openssl ca -config openssl.cnf -revoke <old>.pem        # then regenerate the CRL:
openssl ca -config openssl.cnf -gencrl -out <crl>.pem
```
- The broken cert may be **validly issued** and still active; the CA refuses a second valid cert for the same identity (`ERROR: There is already a certificate for .../CN=<name>`). Revoke it, then reissue.
- 🔴 **CRL caveat (`MC-0002`/`ADR-0009`):** without a **CDP + a served CRL**, `openssl ca -revoke` only edits `index.txt` — the revoked cert stays **trusted by every device holding the Root**. Revocation here is *bookkeeping, not enforcement*; the real remedy is reissue **and remove the old object from every trusting device**.
- → *`MC-0002` Steps 12–15 (conflict → revoke serial `1000` → CRL → reissue as serial `1001`).*

**4. Install / bind → the object is renamed on import; read the real name back.**

```
/certificate print detail          # RouterOS renames on import — read the assigned name/serial
/ip service set www-ssl certificate=mikrotik-bundle.crt_0
/ip service print detail           # confirm which cert www-ssl is actually bound to
```
- Build the **full-chain** bundle (leaf + intermediate + root), stage to a **non-repo** folder (`POL-0002`); remove old objects before importing.
- Healthy: `print detail` shows the new object, `trusted=yes`, correct serial, and `www-ssl` bound to it. Broken: bound to a name that doesn't exist / the old object.
- 📸 `print detail`. Ref: `../Command-Library/RouterOS.md` §Mgmt. → *`MC-0002` Steps 21–26 (renamed `mikrotik-bundle.crt_0`; bound `www-ssl`).*

**5. Prove it on the wire — the served connection, SAN + chain + issuer.**

```bash
openssl s_client -connect 10.10.0.1:443 -showcerts </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -ext subjectAltName
openssl s_client -connect 10.10.0.1:443 -showcerts </dev/null 2>/dev/null \
  | grep -c "BEGIN CERTIFICATE"        # expect 3 (leaf + intermediate + root)
```
- Healthy: SAN served correct · chain count **3** · **issuer = the CA** (not the device).
- 🔴 Broken: SAN wrong on the wire (bind/rename → step 4) · count **1** (bare leaf → rebuild the bundle) · issuer = the device (a **self-signed masquerade** — the real Pi-hole trap: a correct SAN on a self-signed cert is still self-signed; check `issuer`).
- Browser still warns though the wire is correct → **TLS session cache**; retest in Incognito / a fresh process.
- 📸 the served SAN + `= 3` + issuer. → *`MC-0002` Step 27 (live `s_client` confirmed `DNS:mikrotik.lab, IP Address:10.10.0.1`).*

## The fix — where it's documented (point down, don't re-derive)

The authoritative fix lives in the docs that own it (`POL-0008`) — this Playbook routes you there, it doesn't restate the procedure:

- **The CA-config fix (the `copy_extensions` SAN gap):** [`Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md`](../../Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md) — **Step 2 (the required `copy_extensions = copy` step)**, the "Common Mistakes", and the "Closed Item — Certificate SANs Verified" table (the device-verified end state). This is *the doc that shows the fix.*
- **The incident record (the full chronological fix):** [`.../Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md) — Phase 3 is the exact command sequence that resolved it; Phase 4 is the validation.
- **Reconciled to today (AD CS, `ADR-0031`):** the SAN source is fixed on the **certificate template** (supply-in-request / build-from-AD), not a CA-wide flag; the issuing CA is ICA01. *(The AD CS ceremony is 📋 not yet built — until it is, "SAN handled by the CA" is designed, not verified-running.)*

Then re-prove: re-run step 1 (file) and step 5 (wire). Never mark ✅ on the sign log or the "Issued" row — ✅ needs the pasted **served-cert** read-back (`POL-0001`).

## If still broken

- SAN correct on the file, wrong on the wire → bound the wrong/old object (step 4) or the service didn't reload — re-read `print detail`, re-bind.
- `ERR_CERT_AUTHORITY_INVALID` with a correct SAN → **bare leaf** (chain = 1) — rebuild the bundle with intermediate+root, reinstall (step 5).
- Reissue keeps failing "already a certificate for …" → the prior cert isn't actually revoked / the CRL wasn't regenerated (step 3).
- Wire is correct, browser still warns → TLS session cache — retest in a clean process.
- Issuer is the device, not the CA → the service is serving a **self-signed** cert; you fixed the wrong object / a different service holds the real binding (the Pi-hole trap).
- New issuances still come out SAN-less → the CA/template fix (step 2) didn't take — verify it on the CA the same way (`Confirm-a-Config-Change-Actually-Took.md`).

## Gap / what this closes (`ADR-0053` §5 · `#37`)

- **The gap:** the Lab-01 CA shipped **no reliable SAN mechanism from the day it was built** (`copy_extensions` unset CA-wide) — every cert it signed under `server_cert` risked a silent empty SAN; and revocation was **non-functional** (no CDP/served CRL, `ADR-0009`), so a "revoked" cert stayed trusted. A **reliability** gap (certs that fail despite a clean issuance) and a **security/audit** gap (an active-but-useless cert; revocation that reaches nobody).
- **Reconciled state (`ADR-0031`):** AD CS re-teaches it — SAN from a controlled template source, first-class revocation + CRL/OCSP publication, auto-enrolment removing the hand-CSR foot-guns. **Still designed-only until built** (⬜/📋): the AD CS ceremony (RCA01 → ICA01) is the estate's tallest dependency, so "SAN handled by the CA" is a *plan*, not a verified-running control (`POL-0001`). Track it in `../Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md` (the PKI rows) + the Review-Flag-Register.

## Worked example — the real Lab-01 case (`MC-0002`, device-verified 2026-07-13)

> The actual incident this Playbook is drawn from — on the live MKT01 (frozen Lab-01). **Authoritative record: [`MC-0002`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md)** (owns the incident) + the fix baked into the [Lab-CA Build-Guide](../../Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md). Read-backs quoted from the frozen record (`POL-0001`).

- **① Pin it down.** Reissue MKT01's `www-ssl` cert with the correct SAN (`10.10.0.1`, not stale `10.0.0.1`/`172.31.4.144`); WinBox kept as the fallback path. → `MC-0002` Phase 1.
- **Step 1 — read the file.** After a **clean** `openssl ca` sign, `openssl x509 … -text | grep SAN` → **empty**. The clean log lied; reading the file caught it in one command. → `MC-0002` Step 5.
- **Step 2 — the CA, not the cert.** `copy_extensions` **missing** from `[ CA_default ]`, `[ server_cert ]` had no `subjectAltName` — a defect present **since the CA was built**. Fixed with a content-anchored edit (a line-number `sed` first landed in `[ ca ]`). → `MC-0002` Steps 6–10; Build-Guide Step 2.
- **Step 3 — conflict → revoke.** Reissue failed: `ERROR: There is already a certificate for .../CN=mikrotik.lab` — the no-SAN cert (serial `1000`) had issued and was valid. Revoked `1000`, regenerated the CRL, re-signed → **serial `1001`**. *(The revocation reached no client — no CDP; bookkeeping, `ADR-0009`.)* → `MC-0002` Steps 12–15.
- **Step 4 — renamed on import.** Imported the bundle (`certificates-imported: 3`) + key (`private-keys-imported: 1`); RouterOS assigned **`mikrotik-bundle.crt_0`** (serial `1001`, `trusted=yes`), confirmed via `/certificate print detail`; bound `www-ssl`. → `MC-0002` Steps 21–26.
- **Step 5 — proved on the wire.** `openssl s_client … | grep SAN` → **`DNS:mikrotik.lab, IP Address:10.10.0.1`**, served live. → `MC-0002` Step 27.
- **Gap closed.** One cert fixed *and* the CA-wide SAN defect fixed at source (`copy_extensions = copy`, a permanent Build-Guide change); a known-bad cert revoked. *(Reconcile: OpenSSL Lab CA → AD CS `ADR-0031`; the read-the-artifact discipline is unchanged.)*

## Related

- **The fix docs (link down):** [Lab-CA Build-Guide](../../Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md) (Step 2 — the `copy_extensions` fix; the SAN-verify checklist) · [`MC-0002`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md) (the full incident) · `MC-0001` (the bare-leaf / `get`-not-`show` companion).
- **Command-Library:** `../Command-Library/Linux.md` (§Web / CRL host — `openssl verify`/`s_client`) · `../Command-Library/RouterOS.md` (§Mgmt — `/certificate print detail`, `/ip service`) · `../Command-Library/PowerShell-Tier0.md` (AD CS — `certutil -dump`).
- **Concept (the why):** [`../Concepts/A-Completed-Command-Is-Not-Evidence.md`](../Concepts/A-Completed-Command-Is-Not-Evidence.md) (a command completing is a claim, not evidence — this cert case is one instance).
- **Sibling playbooks:** `Confirm-a-Config-Change-Actually-Took.md` (the general read-back drill) · `Recover-a-Locked-Out-Router-Out-of-Band.md` (if binding the GUI cert locks you out).
- **Checklist (`ADR-0053` §8 reciprocal):** the machine-certificate step on `../../00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx` (ICA01 machine cert).
- **Reconciliation & gap map:** `../Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md` (the OpenSSL-CA → AD CS PKI rows, `#37`).
- **Backlog:** `#32` (searchable / ticket-ready / offline) · `#37` (gap analysis) · `ADR-0009` (the CRL/CDP gap).

## Worked log

| Date | Who | Time | Cert / identity | SAN read off file? | SAN + chain(=3) + issuer proven on the wire? | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.2 | 2026-08-01 | **Operator review → one verbatim error string per bullet** (Symptoms & search terms). Split the `·`-joined error lines so each error (`ERR_CERT_AUTHORITY_INVALID`, `NET::ERR_CERT_COMMON_NAME_INVALID`, the name-mismatch/interstitial wordings, the empty-SAN and self-signed-masquerade phrasings) is its **own bullet**, and tagged each with the failure mode + the step that resolves it — so a pasted error lands on a distinct, narrowed symptom. Folded the one-error-per-bullet rule into `ADR-0053` §5 (the `#32` element). |
| 1.1 | 2026-08-01 | **Operator review → made it a true command-first Playbook** (was reading part design-doc). Foregrounded the exact `openssl`/`/certificate`/`s_client` reads as copy-paste command blocks with Healthy/Broken + per-step `MC-0002` provenance; added **"How a SAN is actually configured in OpenSSL (and why there's no safe default)"** — the `-addext` request + the `copy_extensions = copy` carry (and the `-extfile` bypass), why OpenSSL defaults it **off** (a security default, hence the silent-empty-SAN foot-gun), and the AD CS template-SAN reconcile; replaced the re-derived prose fix with **"where the fix is documented"** pointing to the Lab-CA **Build-Guide Step 2** + `MC-0002` Phase 3 (`POL-0008`); added the **issuer-check / self-signed-masquerade** read (the Pi-hole trap) and the **CRL-is-bookkeeping-without-a-CDP** caveat (`ADR-0009`). Moved the conceptual "why" out to the linked Concept (`A-Completed-Command-Is-Not-Evidence`). |
| 1.0 | 2026-08-01 | Created as the 🥇 golden-template reference (`ADR-0053` §5), from the device-verified `MC-0002`: a cert that signs cleanly and is still wrong — read the SAN off the file + the wire, never the log; fix an empty SAN at the CA policy; revoke-before-reissue; renamed-on-import. Demonstrated the On-this-page index, per-step provenance, the optional Gap note, and the Worked-example→CM. Reconciled OpenSSL Lab CA → AD CS (`ADR-0022`/`ADR-0031`). 🟡 until run. |
