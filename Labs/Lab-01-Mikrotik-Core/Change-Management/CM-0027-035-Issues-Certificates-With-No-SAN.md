# CM-0027 — `035` Issues Certificates With No SAN and Installs Bare Leafs. `042` Teaches a Revocation That Reaches Nobody.

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | **Draft** |
| Risk | 🔴 **HIGH — `035` is the runbook used EVERY time a device needs a certificate.** *(No live device change.)* |
| Affected systems | **Documentation.** `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`, `042-Certificate-Reissuance-and-Renewal-Guide.md`. |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — read directly from `035` and `042` as committed |
| Related | `MC-0001`, `MC-0002`, `CM-0008`, `ADR-0009`, `031`, `037`, `041`, `051-Book-1-Audit-Report.md` (findings H1–H4) |

> **`031` is the one-time CA build. `035` is the task you actually repeat.** `035` says so itself: *"This document covers the task you'll actually repeat every time a new device or service needs HTTPS."*
>
> 🔴 **`MC-0001`, `MC-0002` and `CM-0008` fixed `031`. Not one of them touched `035`.**

---

## 🔴 Finding 1 — `035` Part A issues a certificate with **no SAN**

**`035` Part A, verbatim:**

```bash
sudo openssl req -config openssl.cnf -key .../<device-name>.key \
  -new -sha256 -out csr/<device-name>.csr
```

```
grep -c "addext\|subjectAltName" 035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md   →   0
```

🔴 **There is no `-addext "subjectAltName=..."` anywhere in `035`.** A certificate issued by following this runbook **has no Subject Alternative Name at all.**

**Every other PKI document in Atlas knows this:**

| Document | Says |
|---|---|
| `031` Step 3 | ✅ `-addext "subjectAltName=DNS:<device>.lab,IP:<ip>"` — and: *"🔵 **`-addext` is what sets the SAN.**"* |
| `042` Step 1 | 🟡 *"**`-addext "subjectAltName=..."` is what actually sets the SAN** at CSR creation time. **This is the step that was implicitly skipped or wrong the first time on MikroTik.**"* |
| `041` | *"the certificate's SAN referenced `10.0.0.1` — a pre-VLAN address — instead of the current `10.10.0.1`"* |
| `CM-0008` / `MC-0002` | **The entire reason both records exist.** |

> 🔴 **Modern browsers ignore Common Name entirely. A certificate with no SAN is rejected outright.**
>
> **`035` is the document that produced `mikrotik.lab` serial `1000` — the SAN-less certificate that had to be revoked and reissued under `MC-0002`.** **It still produces it.**

## 🔴 Finding 2 — `035` has no SAN verification and no `copy_extensions` warning

```
grep -ci "Subject Alternative Name" 035   →   0
```

**`031`, `042` and `016` all carry the same rule, in the same words:**

> 🔴 *"**Always verify the SAN after signing. A clean sign log proves nothing.**"*

**And the reason:** `copy_extensions` was unset in `[ CA_default ]` from the CA's original build until 2026-07-13. **OpenSSL silently discards any SAN requested via `-addext` without it — and the sign log looks clean either way** (`MC-0002`).

🔴 **`035` mentions neither.** A reader following it has **no SAN**, **no check that there is no SAN**, and **no idea that a clean log means nothing.**

## 🔴 Finding 3 — `035` Part B installs the **bare leaf**. That is the `MC-0001` incident, verbatim.

```
grep -ci "bundle" 035   →   0
```

**`035` Part B, FortiGate:** *"`System > Certificates > Import > Local Certificate` → **upload the `.crt` as certificate, `.key` as key**."*
**`035` Part B, MikroTik:** *"Drag the `.crt` and `.key` files into WinBox's Files window."*

🔴 **Both install the leaf certificate alone, with no chain.**

**`037-FGT01-Troubleshooting-Guide.md`, `MC-0001`, `016` and `042` all say the same thing:**

> *"**Symptom:** A device certificate was imported and bound, but the browser still shows `ERR_CERT_AUTHORITY_INVALID`.*
> ***Root cause:** the certificate chain is incomplete. FGT01 was only presenting its own leaf certificate — no intermediate.*
> ***Actual resolution:** build a proper bundle (leaf + CA chain, concatenated) and import **that** as the Local Certificate.*
> ***Verify:** `openssl s_client … | grep -c "BEGIN CERTIFICATE"` **must return 3**."*

🔴 **`035` teaches the method that fails.** And it has **no chain-count check** and **no binding verification** — no `get system global | grep admin-server-cert`, which is the silently-unbound defect that cost `MC-0001` hours and became **Charter Rule 13's corollary.**

> **`035`'s own "Worked Example" section describes the `MC-0001` incident — the hidden Feature Visibility menu and the missing workstation trust step — and does not mention the leaf-vs-bundle failure or the unbound certificate, which were the other two.**

## 🔴 Finding 4 — `042` teaches a revocation that reaches nobody. `031` knows better.

**`042` "When to Reissue":**

| Trigger | Revoke the old certificate? |
|---|---|
| **Key or certificate file was exposed** (chat log, repo, unprotected temp file) | 🔴 **"Yes — revoke. Do not just let it expire."** |

**`042` Step 5** then gives `openssl ca -revoke` + `-gencrl` as the remedy.

```
grep -ci "crlDistributionPoints|CRL Distribution|does not work|decorative" 042   →   0
```

**`031` v0.7, and `ADR-0009`, both say — as a `Verified` finding:**

> 🔴 *"**REVOCATION DOES NOT WORK IN THIS CA.** No certificate this CA issues carries a CRL Distribution Point extension. `grep -r crlDistributionPoints` across the entire repository returns **zero** occurrences. **No client is ever told where to look, so no client ever looks.***
>
> *"**`MC-0002` revoked the broken MikroTik certificate — serial `1000`.** That revocation **reached nothing.** It remains **fully trusted by every device and browser holding the Root CA.***
>
> *"**A revocation nobody checks is a filing action, not a security control.**"*

> 🔴 **`042` is the document you open when a key has been exposed — the worst moment to be told to run a command that does nothing.**
>
> **`031` v0.7 got this correction. `042` did not.** **Same pattern as `026`, `018`, `027`, `035`: the correction reaches the document that DESCRIBES the thing and misses the one that PERFORMS it.**

**`ADR-0009` states the only real remedy:** *"build a new Intermediate, reissue all four certificates, and **remove the old Intermediate object from every device.** There is no partial measure."*

*(🟢 `042` is otherwise excellent — the `sudo sh -c` fix, `-issuer` in validation, the key-reuse decision, the CA-uniqueness trap. **This one section is the defect.**)*

---

## Implementation — documentation only

### Edit 1 — 🔴 `035` Part A: add the SAN. **This is the whole point of the runbook.**

```bash
sudo openssl req -config openssl.cnf -key /etc/ssl/lab-ca/issued/<device>/<device>.key \
  -new -sha256 -out csr/<device>.csr \
  -addext "subjectAltName=DNS:<device>.lab,IP:<current-device-ip>"
```

> 🔴 **`-addext "subjectAltName=..."` IS the certificate.** Modern browsers **ignore Common Name entirely.** **A certificate with no SAN is rejected outright.**
>
> 🔴 **Use the CURRENT IP.** Not what an old guide says. Not what habit assumes. **`mikrotik.lab` was issued with `10.0.0.1` — a pre-VLAN address — and the browser refused it** (`CM-0008`, `041`).
>
> 🔴 **`-addext` is SILENTLY IGNORED unless `copy_extensions = copy` is set in `[ CA_default ]`** of `intermediate/openssl.cnf`. That gap affected **every certificate this CA issued** from its build until 2026-07-13. **The sign log looks clean either way** (`MC-0002`).

### Edit 2 — `035` Part A: verify the SAN before you go any further

```bash
openssl x509 -in /etc/ssl/lab-ca/issued/<device>/<device>.crt -noout -text \
  | grep -A1 "Subject Alternative Name"
```

> 🔴 **A clean `openssl ca` sign log proves NOTHING.** The CA silently issued a completely SAN-less certificate once, with no error anywhere. **If this returns nothing, STOP** — `copy_extensions` is unset. **Do not install it.**

### Edit 3 — 🔴 `035` Part B: build a BUNDLE. Never install the bare leaf.

**Insert before the device-specific steps:**

> ## 🔴 Part B.0 — Build the bundle. **Installing the bare leaf does not work.**
>
> ```bash
> sudo sh -c 'cat /etc/ssl/lab-ca/issued/<device>/<device>.crt \
>     /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
>     > /etc/ssl/lab-ca/issued/<device>/<device>-bundle.crt'
>
> grep -c "BEGIN CERTIFICATE" /etc/ssl/lab-ca/issued/<device>/<device>-bundle.crt   # expect 3
> ```
>
> 🔴 **`sudo sh -c '...'` wraps the WHOLE pipeline.** **Do NOT use `cat … | sudo tee`** — `sudo` applies only to `tee`, the `cat` fails on the root-owned key, **and the pipeline keeps running**, writing a file missing whatever it could not read. **That exact pattern put a keyless certificate into production TLS on Pi-hole** (`038`, `032`, `016`).
>
> 🔴 **Install the BUNDLE as the Local Certificate. Not the leaf.**
>
> **Importing the intermediate separately as a "CA Certificate" object does NOT attach it to what the device SERVES.** That only changes what the device *trusts*. **The browser still shows `ERR_CERT_AUTHORITY_INVALID` and `s_client` still returns `1`.** (`MC-0001`, `037`.)

### Edit 4 — `035` Part B FortiGate: verify the binding

```text
get system global | grep admin-server-cert
```

> 🔴 **`get`, not `show`.** `show` prints only non-default values — **an unbound certificate looks like "nothing to see."**
>
> 🔴 **`set admin-server-cert` has run, returned no error, and silently not taken effect.** `MC-0001` lost hours to it. **This is the origin of Charter Rule 13's corollary: a command that returns no error is not a confirmed change.**
>
> 🔴 **And enable the menu first:** `System > Feature Visibility > Certificates`. **It is hidden by default — a visibility toggle, not a licence.**

### Edit 5 — `035` Validation: check the wire, not the file

```bash
openssl s_client -connect <device-ip>:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -subject -dates

openssl s_client -connect <device-ip>:443 -showcerts </dev/null 2>/dev/null \
  | grep -c "BEGIN CERTIFICATE"     # MUST return 3
```

> 🔴 **Check `issuer`, not just SAN.** **Checking `issuer` is what caught Pi-hole serving its FACTORY self-signed certificate (`issuer=CN=pi.hole, O=Pi-hole, C=DE`) while three documents claimed a Lab CA certificate was "in active use" — from its original build onward.**
>
> **A correct SAN on a self-signed certificate is still a self-signed certificate.**

### Edit 6 — 🔴 `042` "When to Reissue" + Step 5: **REPLACE the revocation advice**

**Replace the table's right-hand column and Step 5 entirely:**

> ## 🔴 Step 5 — Revocation. **READ THIS BEFORE YOU RELY ON IT.**
>
> 🔴 **REVOCATION DOES NOT WORK IN THIS CA.** Confirmed 2026-07-13: `grep -r crlDistributionPoints` across the entire repository returns **zero** occurrences.
>
> **No certificate this CA issues carries a CRL Distribution Point. No CRL is served over HTTP. No client is ever told where to look — so no client ever looks.**
>
> **`openssl ca -revoke` updates `index.txt` on Pi01 and changes NOTHING anywhere else.**
>
> 🔴 **This has already happened.** `MC-0002` revoked the broken MikroTik certificate (serial `1000`, empty SAN). **That certificate remains fully trusted by every device and browser holding the Root CA.** Anyone holding it and its key could present it today.
>
> > **A revocation nobody checks is a filing action, not a security control.**
>
> ### 🔴 So what do you ACTUALLY do when a key is exposed?
>
> **The only real remedy is physical** (`ADR-0009`):
>
> 1. **Generate a new key** and reissue the certificate.
> 2. **Install it on the device.**
> 3. 🔴 **REMOVE the old certificate object from the device.** `/certificate remove` on RouterOS; delete the Local Certificate on FortiOS. **This is the step that actually revokes it, because it is the only one anything observes.**
> 4. **Run `openssl ca -revoke` anyway** — `index.txt` is the CA's only record of what it has issued, and it is the **only** way to detect an unauthorised issuance (`ADR-0009`). **Bookkeeping, not enforcement. Know which one you are doing.**
>
> **If the INTERMEDIATE is compromised, none of the above helps** — the attacker mints their own certificates. **See `ADR-0009`.**
>
> **To make revocation real:** add `crlDistributionPoints = URI:http://pihole.lab/crl/intermediate.crl` to `[ server_cert ]`, serve the CRL over HTTP, **and reissue every certificate** — a CDP cannot be added to a certificate that already exists.

---

## Validation

```powershell
# 035 must now set a SAN - expect at least ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md `
              -Pattern "subjectAltName"

# 035 must now build a bundle - expect at least ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md `
              -Pattern "bundle.crt"

# 035 must verify the binding with GET - expect ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md `
              -Pattern "get system global"

# 042 must carry the revocation truth - expect at least ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\042-Certificate-Reissuance-and-Renewal-Guide.md `
              -Pattern "REVOCATION DOES NOT WORK"

# 🔴 COUNT-CHECK (CM-0026's rule): the OLD advice must be GONE. Expect ZERO:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\042-Certificate-Reissuance-and-Renewal-Guide.md `
              -Pattern "Yes — revoke. Do not just let it expire"
```

> 🔴 **Note the last check.** Per **`CM-0026`**: **verify a correction by counting the OLD text, not by confirming the NEW text is present.** **Three documents in this audit contain both.**

## Rollback

`git checkout -- Labs/Lab-01-Mikrotik-Core/Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md Labs/Lab-01-Mikrotik-Core/Operations/042-Certificate-Reissuance-and-Renewal-Guide.md`

---

## Reconciliation — all document types

| Document | Outcome | Detail |
|---|---|---|
| 🔴 **`035`** (Runbook) | **Updated** | Edits 1–5. **`MC-0001`, `MC-0002` and `CM-0008` all closed without touching it.** |
| 🔴 **`042`** (Guide) | **Updated** | Edit 6. `031` v0.7's revocation finding never reached it. |
| **`031`** (Build Guide) | **Reviewed — no change needed** | 🟢 **`031` is correct on all four points**: `-addext`, SAN verification, `copy_extensions`, `sudo sh -c`, and revocation-is-decorative. **It is the source `035` should have been reconciled against.** |
| **`037`**, **`041`** (Troubleshooting) | **Reviewed — no change needed** | 🟢 Both correctly document the leaf-vs-bundle failure and the unbound `admin-server-cert`. **They record the incidents `035` still causes.** |
| **`016`** (Lessons) | 🔴 **MUST UPDATE** | Add: 🔴 **a correction that reaches the BUILD GUIDE and not the RUNBOOK has not landed.** `031` was fixed five times. **`035` — the document you use every time — was never opened.** |
| 🔴 **`ADR-0009`** | **Reviewed — reinforced** | Its *"revocation is decorative"* finding is now in `042` too. **`ADR-0009`'s Review Trigger — *"a certificate appears that this CA did not knowingly issue"* — depends on `index.txt` being maintained. `042` Step 5 is what maintains it.** |
| **`MC-0001`, `MC-0002`, `CM-0008`** | 🔴 **ANNOTATE** | All three closed with `035` unreconciled. *(Deferred to the status-hygiene pass.)* |

---

## The lesson — for `016`

> 🔴 **`031` is read ONCE, when the CA is built. `035` is read EVERY TIME a device needs a certificate.**
>
> **`031` was corrected five times across `MC-0001`, `MC-0002`, `CM-0008` and `CM-0010`. `035` was never opened.**

**The correction pass consistently finds the Build Guide and misses the Runbook** — and the Runbook is the one that gets used.

**Three instances of the identical failure, in one audit:**

| Corrected | Missed | The missed one is… |
|---|---|---|
| `006`, `012`, `023`, `016` (the ACL) | 🔴 **`027`** | …the guide that **builds** the ACL |
| `031`, `029`, `049`, `043` (the CA backup) | 🔴 **`048`** | …the runbook that **takes** the backup |
| `031` (SAN, bundle, revocation) | 🔴 **`035`, `042`** | …the runbooks that **issue and reissue** |

> **Ask, at every closeout: *which document does the WORK?* Fix that one first.**

---

## Closeout

- [ ] Edit 1 — `035` Part A sets a **SAN**
- [ ] Edit 2 — `035` verifies the SAN after signing
- [ ] Edit 3 — `035` builds a **bundle**; never installs the bare leaf
- [ ] Edit 4 — `035` verifies the FortiGate binding with **`get`**
- [ ] Edit 5 — `035` validates on the wire, checking **`issuer`**
- [ ] Edit 6 — `042` Step 5 **REPLACED** — revocation does not work in this CA
- [ ] Validated — **count-check: the old `042` revocation advice returns ZERO hits** (`CM-0026`)
- [ ] 🔴 **`016` updated** with the runbook-vs-guide lesson — **blocks closure**
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`), findings H1–H4. 🔴 **`035` — the runbook used EVERY time a device needs a certificate — sets NO SAN (`grep -c subjectAltName` → 0), never verifies one, and installs the BARE LEAF instead of a bundle. All three are documented incidents (`MC-0001`, `MC-0002`, `CM-0008`), and all three fixes went to `031` and never to `035`.** 🔴 **`042` still teaches `openssl ca -revoke` as the remedy for an exposed key — while `031` v0.7 and `ADR-0009` establish that this CA has NO CRL Distribution Point, serves NO CRL, and that `MC-0002`'s revocation of serial `1000` reached nobody.** |
