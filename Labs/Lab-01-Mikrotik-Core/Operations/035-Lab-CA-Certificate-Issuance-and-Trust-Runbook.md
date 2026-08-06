---
Title: Lab CA — Certificate Issuance and Trust Runbook
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Lab CA — Certificate Issuance and Trust Runbook

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | **`Verified`** — every command below was run on Pi01 or read off a live TLS connection. **Rebuilt 2026-07-14 against the device.** |
| Evidence Source | Live CA config, `openssl s_client` against all four devices, `index.txt` |
| Last Verified | 2026-07-14 |
| Version | **2.0** |
| Applies To | Any device or service that needs a certificate from the Atlas Lab CA |

> 🔴 **v1.0 OF THIS RUNBOOK WAS DANGEROUS. `CM-0027` / `CM-0032`.**
>
> **It was written during the very session that discovered four PKI defects (`MC-0001`, `MC-0002`, `CM-0007`, `CM-0008`) — and it contained NONE of them.**
>
> | v1.0 did | Which is |
> |---|---|
> | 🔴 **Never set a SAN** (`grep -c subjectAltName` → **0**) | **The `MC-0002` incident.** Browsers ignore Common Name entirely. **A certificate with no SAN is REJECTED OUTRIGHT.** |
> | 🔴 **Never verified the SAN after signing** | **`copy_extensions` was unset from the CA's build until 2026-07-13. Every certificate was silently issued without a SAN — and the sign log looked CLEAN.** |
> | 🔴 **Installed the BARE LEAF** | **The `MC-0001` incident.** `ERR_CERT_AUTHORITY_INVALID`. |
> | 🔴 **Never verified the binding** | **`set admin-server-cert` ran, returned no error, and never took effect.** **This is the ORIGIN of Charter Rule 13's corollary.** |
> | 🔴 **Never wrote the certificate into `issued/`** | **`CM-0032`.** The guides read from `issued/`. `openssl ca` writes to `newcerts/`. **Pi-hole's `issued/` file is a year-old certificate with a pre-VLAN SAN, and `032` rebuilds from it.** |
>
> 🔴 **`MC-0001` Phase 5 ticked: *"Runbook's Common Mistakes updated with the binding-verification lesson and the bundle requirement."*** **It contained neither. The box was ticked against a document that did not contain what it claimed.**

## Purpose

`031-Pi01-Lab-CA-Build-Guide.md` covers building the CA itself — a one-time task, already done. This document covers the task you'll actually repeat every time a new device or service needs HTTPS: **issue it a certificate, install that certificate, and make sure the machines that connect to it actually trust it.** Those are three separate steps, and skipping the third one is the most common way this goes wrong — the certificate can be installed correctly and a browser will still show a warning, because trusting the *root* is a separate action from installing a *device* certificate.

If you can follow this document end to end and explain in your own words what each step is actually doing — not just what to type — that's the bar. Going fast without understanding it is exactly what led to wanting this document in the first place.

## 🔴 The five things that have silently broken this before

**Every one happened. Every one produced a clean-looking success.**

| # | The trap | What it looks like |
|---|---|---|
| 1 | **No SAN** — `-addext` omitted, or `copy_extensions` unset | 🔴 **A clean sign log. An empty SAN. A browser that refuses the certificate.** |
| 2 | **Installing the bare leaf** instead of a bundle | 🔴 **`ERR_CERT_AUTHORITY_INVALID`, with a perfectly valid certificate.** |
| 3 | **The binding never takes** | 🔴 **`set` returns no error. The device serves the FACTORY certificate for hours.** |
| 4 | 🔴 **The certificate never gets written into `issued/`** | 🔴 **The service is correct. THE REBUILD IS NOT.** `openssl ca` writes to `newcerts/`. **The guides read `issued/`.** |
| 5 | 🔴 **Signing with `openssl x509 -req -extfile` instead of `openssl ca`** | 🔴 **It works. And the CA has NO RECORD of the certificate — it cannot be revoked, and `ADR-0009`'s only detection control goes blind.** |

> 🔴 **THE RULE THAT COVERS ALL FIVE: A CLEAN COMMAND IS NOT A CORRECT ARTEFACT. READ THE ARTEFACT BACK — AND READ BOTH OF THEM: THE ONE ON THE WIRE, AND THE ONE THE REBUILD USES.**

## The Three Things That Have to Happen, Conceptually

Before any commands: a certificate proves a device's identity, but only to something that already trusts whoever *signed* that certificate. That's the whole model.

1. **Issue** — the Lab CA (on Pi01) creates a certificate for the specific device, cryptographically signed by the CA's intermediate key. This is Pi01's job.
2. **Install** — the certificate gets loaded onto the target device (FGT01, MikroTik, whatever it is), so that device presents it to anyone connecting.
3. **Trust** — every machine that will *connect* to that device (your workstation's browser, for example) needs the Lab CA's **root certificate** installed in its own trust store. Without this step, every device certificate the CA ever issues will show a browser warning, forever — it's not a per-device problem, it's a one-time setup per admin machine.

Step 3 is easy to forget because it only has to be done once per workstation, not once per device — which makes it feel optional. It isn't. It's the reason CM-0005 needed a workstation-side step that wasn't in the original plan.

## Part A — Issue a Certificate (on Pi01)

This is the CA doing its job — creating and signing a new certificate for a specific device. Every device gets its own certificate; never reuse one.

### A.1 — Generate the key and the CSR. **The SAN goes in HERE.**

```bash
ssh pihole
sudo mkdir -p /etc/ssl/lab-ca/issued/<device>
cd /etc/ssl/lab-ca/intermediate

sudo openssl genrsa -out /etc/ssl/lab-ca/issued/<device>/<device>.key 2048

sudo openssl req -config openssl.cnf \
  -key /etc/ssl/lab-ca/issued/<device>/<device>.key \
  -new -sha256 -out csr/<device>.csr \
  -addext "subjectAltName=DNS:<device>.lab,IP:<CURRENT-DEVICE-IP>"
```

> 🔴 **`-addext "subjectAltName=..."` IS THE CERTIFICATE.**
>
> **Modern browsers IGNORE Common Name entirely.** **A certificate with no SAN is not "weaker." It is REJECTED OUTRIGHT.**
>
> 🔴 **THIS RUNBOOK HAD NO `-addext` UNTIL 2026-07-14.** **Every certificate issued by following it had no SAN.**

> 🔴 **USE THE *CURRENT* IP. Not what a build guide says. Not what habit assumes.**
>
> **`mikrotik.lab` was issued with `IP:10.0.0.1` — a pre-VLAN address — and the browser refused it** (`CM-0008`, `041`). **Pi-hole's `issued/` file STILL carries `IP:10.0.0.5` today** (`CM-0032`). **Check `ip a` on the device. Right now.**

> 🟡 **Common Name must actually be typed in.** Every other DN field shows a default in brackets — press Enter. **CN does not.** Leaving it blank fails the sign step with `The commonName field needed to be supplied and was missing`, **and no certificate is written** (`MC-0002` step 1).

### A.2 — 🔴 Confirm `copy_extensions` BEFORE you sign. It silently discards your SAN.

```bash
sed -n '1,12p' /etc/ssl/lab-ca/intermediate/openssl.cnf
```

**REQUIRED — device-verified 2026-07-14:**

```
[ ca ]
default_ca = CA_default
[ CA_default ]
copy_extensions = copy        <-- 🔴 IT MUST BE IN [ CA_default ]. NOT [ ca ].
```

> 🔴 **Without this line, OpenSSL SILENTLY DISCARDS every SAN requested by `-addext`.** It is a deliberate OpenSSL security default. **The sign log looks identical either way.**
>
> 🔴 **This gap affected EVERY certificate this CA issued, from its original build until 2026-07-13** (`MC-0002`).
>
> 🔴 **And `[ ca ]` sits DIRECTLY ABOVE `[ CA_default ]`.** **`MC-0002` step 8 put the line in the wrong section on the first attempt, using a line-number edit.** **Read the section header, not the line number.**

### A.3 — Sign it. 🔴 **`openssl ca`. NEVER `openssl x509 -req`.**

```bash
sudo openssl ca -config openssl.cnf -extensions server_cert \
  -days 365 -notext -md sha256 \
  -in csr/<device>.csr \
  -out /etc/ssl/lab-ca/issued/<device>/<device>.crt
```

> 🔴🔴 **DO NOT SIGN WITH `openssl x509 -req -extfile`. IT WORKS, AND IT BREAKS THE CA.**
>
> | | `openssl ca` | 🔴 `openssl x509 -req -extfile` |
> |---|---|---|
> | Produces a valid certificate | ✅ | ✅ **Yes — that is the trap.** |
> | **Writes a row to `index.txt`** | ✅ | 🔴 **NO.** |
> | Takes the next serial (`1000`, `1001`…) | ✅ | 🔴 **NO** — random 20-byte serial |
> | Writes to `newcerts/` | ✅ | 🔴 **NO** |
> | **Can be revoked** | ✅ *(bookkeeping — see `042`)* | 🔴 **NOT EVEN THAT.** `openssl ca -revoke` fails: *the CA has no record of it.* |
>
> 🔴 **TWO CERTIFICATES IN THIS LAB WERE SIGNED THIS WAY — FGT01's, WHICH IS LIVE RIGHT NOW, AND PI-HOLE'S ORIGINAL.** **Neither appears in `index.txt`.** (`CM-0032`)
>
> 🔴 **`ADR-0009` accepted the risk of a possibly-compromised Intermediate CA explicitly on the strength of `index.txt` — *"the ONLY way to detect an unauthorised issuance."*** **A certificate the CA has no row for is indistinguishable from a rogue one.**
>
> **If you see a `<device>.ext` file in an `issued/` directory, that is the fingerprint of an `-extfile` signing. Treat it as a finding.**

### A.4 — 🔴 VERIFY THE SAN. A clean sign log proves NOTHING.

```bash
sudo openssl x509 -in /etc/ssl/lab-ca/issued/<device>/<device>.crt -noout -text \
  | grep -A1 "Subject Alternative Name"

sudo openssl x509 -in /etc/ssl/lab-ca/issued/<device>/<device>.crt -noout -serial -dates
```

> 🔴 **IF THE SAN IS EMPTY, STOP.** **`copy_extensions` is unset, or it is in the wrong section.** **DO NOT INSTALL IT.** **Go back to A.2.**
>
> **The CA signed a completely SAN-less certificate once, with no error anywhere, and it took a browser failure to find it** (`MC-0002` step 5).

> 🔴 **The serial must be a SMALL NUMBER (`1004`, `1005`…), taken from `intermediate/serial`.** **A long random hex serial means you signed with `x509 -req`. Go back to A.3.**

### A.5 — 🔴 CONFIRM IT IS IN THE DATABASE. This is `ADR-0009`'s only control.

```bash
sudo openssl ca -config /etc/ssl/lab-ca/intermediate/openssl.cnf -status <serial-from-A.4>
sudo cat /etc/ssl/lab-ca/intermediate/index.txt
```

> 🔴 **A `V` row must exist for this certificate.** **"Not present in database" means it can never be revoked, and `ADR-0009`'s detection control is blind to it.**

**What each piece actually is:**
- `genrsa` — generates a private key. This never leaves Pi01 except to be installed on the target device — it's not a secret shared with anyone else.
- `req -new` — creates a Certificate Signing Request: "here's who I am, please sign this." You'll be prompted for identity fields (Common Name should be the device's hostname, e.g. `fortigate.lab`).
- `openssl ca` — this is the actual signing step. The intermediate CA's key signs the CSR, producing the `.crt` file. This is the moment the certificate becomes real and trusted by anything that trusts the Lab CA.

Both FGT01's and MikroTik's certificates were already generated this way, earlier in Atlas's history, sitting in `/etc/ssl/lab-ca/issued/fortigate/` and `/etc/ssl/lab-ca/issued/mikrotik/` — this session's work was Parts B and C below, not this part, for those two devices specifically.

## 🔴 Part B.0 — BUILD THE BUNDLE. Installing the bare leaf DOES NOT WORK.

```bash
sudo sh -c 'cat /etc/ssl/lab-ca/issued/<device>/<device>.crt \
    /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
    > /etc/ssl/lab-ca/issued/<device>/<device>-bundle.crt'

grep -c "BEGIN CERTIFICATE" /etc/ssl/lab-ca/issued/<device>/<device>-bundle.crt
```
🔴 **MUST return `3`** — leaf + intermediate + root.

> 🔴 **`sudo sh -c '...'` WRAPS THE WHOLE PIPELINE. DO NOT USE `cat ... | sudo tee`.**
>
> **`sudo` applies only to `tee`. The `cat` fails on the root-owned input, prints `Permission denied` — and THE PIPELINE KEEPS RUNNING.** `tee` writes successfully. **It just writes a file missing whatever `cat` could not read.**
>
> 🔴 **That exact pattern put a KEYLESS certificate into production TLS on Pi-hole**, and it was only caught by an unrelated handshake failure (`038`, `032`, `016` lesson 1).

> 🔴 **INSTALL THE BUNDLE AS THE LOCAL/SERVER CERTIFICATE. NOT THE LEAF.**
>
> **Importing the intermediate SEPARATELY as a "CA Certificate" object does NOT attach it to what the device SERVES.** That only changes what the device **trusts**. **The browser still shows `ERR_CERT_AUTHORITY_INVALID`, and `s_client` still returns `1`.** (`MC-0001` steps 12–14, `037`.)

---

## Part B — Install the Certificate (on the target device)

Varies by device. Retrieve the **bundle** and the `.key` from Pi01 first:

```bash
ssh pihole
sudo cp /etc/ssl/lab-ca/issued/<device-name>/<device-name>.crt /etc/ssl/lab-ca/issued/<device-name>/<device-name>.key /tmp/
sudo chown dnsadmin:dnsadmin /tmp/<device-name>.crt /tmp/<device-name>.key
exit
```
```powershell
scp pihole:/tmp/<device-name>.crt .
scp pihole:/tmp/<device-name>.key .
```
Clean up the `/tmp/` copies on Pi01 afterward — the key shouldn't sit somewhere world-readable longer than needed.

**FortiGate:**
1. `System > Feature Visibility` → enable **Certificates**. 🔴 **It is HIDDEN BY DEFAULT. This is a visibility toggle, NOT a licence.** *(Misdiagnosed as a FortiCare restriction during `MC-0001`.)*
2. `System > Certificates > Import > Local Certificate` → 🔴 **upload `<device>-bundle.crt` (NOT the bare `.crt`)** + the `.key` → name it clearly.
3. Bind it: `System > Settings > Administration Settings > HTTPS Certificate`, or from the CLI.
4. 🔴 **VERIFY THE BINDING. THIS IS THE STEP THAT SILENTLY FAILS.**

```text
get system global | grep admin-server-cert
```
🔴 **EXPECT: your new certificate's name. Device-verified 2026-07-14: `admin-server-cert : fortigate-bundle`.**

> 🔴 **`get`, NOT `show`.** **`show` prints only NON-DEFAULT values — an unbound certificate looks like *"nothing to see."*** **`show system global | grep admin-server-cert` returned EMPTY while the device served the factory certificate** (`MC-0001` step 18).
>
> 🔴 **`set admin-server-cert` RAN, RETURNED NO ERROR, AND NEVER TOOK EFFECT.** **The device served `Fortinet_GUI_Server` for hours while every certificate step was correct.**
>
> **THIS IS THE ORIGIN OF CHARTER RULE 13's COROLLARY: *a command that returns no error is not a confirmed change.***

**MikroTik:**
1. 🔴 **Run WinBox AS ADMINISTRATOR** or the file upload fails with a misleading RouterOS-path permission error (`041`).
2. 🔴 **Remove the OLD certificate objects FIRST** — two objects invites binding to the wrong one later:
   ```routeros
   /certificate remove [find name~"<old-name>"]
   ```
3. Drag `<device>-bundle.crt` **and** `<device>.key` into **Files**, then `System > Certificates` → Import (both).
4. 🔴 **ROUTEROS RENAMES THE OBJECT ON IMPORT.** `mikrotik-bundle.crt` becomes **`mikrotik-bundle.crt_0`**. **Read the real name — do not assume it:**
   ```routeros
   /certificate print detail
   ```
5. Bind it:
   ```routeros
   /ip service set www-ssl certificate=<ACTUAL-NAME-FROM-print-detail>
   /ip service print detail
   ```
   🔴 **Read it back.** *(Device-verified 2026-07-14: `www-ssl ... certificate=mikrotik-bundle.crt_0`.)*

## Part C — Establish Trust (on every admin workstation)

Done once per workstation, not once per device. Retrieve the **root** certificate (not a device certificate):

```bash
ssh pihole
sudo cp /etc/ssl/lab-ca/root/certs/root-ca.crt /tmp/
sudo chown dnsadmin:dnsadmin /tmp/root-ca.crt
exit
```
```powershell
scp pihole:/tmp/root-ca.crt .
```

**Windows:**
1. Double-click `root-ca.crt`.
2. **Install Certificate...** → **Local Machine** (requires admin/UAC — this trusts it for the whole workstation, not just one Windows user account).
3. **Place all certificates in the following store** → **Trusted Root Certification Authorities** → Next → Finish.
4. Confirm the security warning (expected for any CA import).
5. Close and reopen your browser — some cache the trust store and won't pick up the change in an already-open window.

## Validation — 🔴 CHECK THE WIRE **AND** THE FILE. THEY ARE TWO DIFFERENT OBJECTS.

### 1. What is the device ACTUALLY SERVING?

```bash
openssl s_client -connect <device-ip>:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -subject -serial -dates -text | grep -A1 "Subject Alternative Name"

openssl s_client -connect <device-ip>:443 -showcerts </dev/null 2>/dev/null \
  | grep -c "BEGIN CERTIFICATE"
```
🔴 **The chain count MUST return `3`.** `1` = you installed the bare leaf. **Go back to B.0.**

> 🔴 **CHECK `issuer`, NOT JUST THE SAN.**
>
> **Checking `issuer` is what caught Pi-hole serving its FACTORY self-signed certificate** (`issuer=CN=pi.hole, O=Pi-hole, C=DE`) **while THREE documents claimed a Lab CA certificate was "in active use" — from its original build onward.**
>
> **A correct SAN on a certificate signed by the WRONG CA is still the wrong certificate.**

### 2. 🔴 DOES THE `issued/` FILE MATCH THE WIRE? **THIS IS WHAT A REBUILD USES.**

```bash
diff <(openssl s_client -connect <device-ip>:443 </dev/null 2>/dev/null \
        | openssl x509 -noout -serial -text | grep -A1 "Subject Alternative Name") \
     <(sudo openssl x509 -in /etc/ssl/lab-ca/issued/<device>/<device>.crt \
        -noout -serial -text | grep -A1 "Subject Alternative Name")
```
🔴 **EXPECT NO OUTPUT.** **Any output means the rebuild will serve a DIFFERENT certificate than production does.**

> 🔴🔴 **THIS CHECK DID NOT EXIST UNTIL 2026-07-14, AND IT FAILS ON PI-HOLE TODAY.**
>
> **`031` v0.6, `029`, `MC-0002` and `NETWORK-PACK-MANIFEST` all record — TRUTHFULLY — that Pi-hole's SAN was *"verified directly on the live-served connection."* ALL FOUR ARE RIGHT.**
>
> 🔴 **And `/etc/ssl/lab-ca/issued/pihole/pihole.crt` carries `IP:10.0.0.5` — the PRE-VLAN address — to this day.** **`032` Step 7 rebuilds `tls.pem` from EXACTLY that file.** **A rebuild serves the wrong certificate on the lab's DNS server.** (`CM-0032`)
>
> 🔴 **THE VERIFICATION CHECKED THE WIRE. THE REBUILD USES THE FILE. NOBODY CHECKED THE FILE.**

### 3. Browser — from a workstation that has completed Part C

Should load with **no warning**. If it does not:
- **Confirm Part C was done on THIS workstation.** Trust does not transfer between machines.
- 🔴 **Chrome's TLS session cache OUTLIVES closing the window.** **Use Incognito, then kill every browser process.** *(`MC-0001` step 23: `s_client` proved the server correct while the browser still showed the old certificate.)*
- **Confirm the certificate is BOUND, not merely imported** — §B step 4.

## 🔴 Worked Example — FGT01 (`MC-0001`). FOUR compounding failures, each masking the next.

> 🔴 **v1.0 of this runbook listed TWO of these four. It omitted the two that actually cost the time — and it omitted them while claiming to *"capture the correct process end-to-end so this sequence doesn't need re-discovering."*** (`MC-0001` Phase 5.)

| # | What happened | Caught by |
|---|---|---|
| 1 | **`System > Certificates` did not appear in the GUI at all.** Suspected a FortiCare licence restriction. **It is a Feature Visibility toggle. Certificate functionality is NEVER paywalled.** | Reading Fortinet's own docs before acting |
| 2 | 🔴 **Certificate imported and bound — browser STILL showed `ERR_CERT_AUTHORITY_INVALID`.** **Only the LEAF was being served. Importing the intermediate separately as a "CA Certificate" object did NOTHING** — that changes what FortiGate *trusts*, not what it *presents*. | 🔴 **`openssl s_client \| grep -c "BEGIN CERTIFICATE"` returned `1`.** **The first HARD EVIDENCE in the whole incident.** |
| 3 | 🔴 **Bundle built and imported. Chain count STILL `1`.** | Re-running the same check — **not assuming the fix worked** |
| 4 | 🔴🔴 **`set admin-server-cert` HAD RUN, RETURNED NO ERROR, AND NEVER TOOK EFFECT.** **The device had been serving the factory `Fortinet_GUI_Server` the entire time — through every correct certificate step.** | 🔴 **`get system global \| grep admin-server-cert`.** **`show` returned EMPTY — because `show` only prints non-default values.** |
| 5 | Server provably correct (`s_client` = 3). **Browser still showed the OLD certificate.** | **Chrome's TLS session cache. Incognito.** |

> 🔴 **THE LESSON, AND IT IS CHARTER RULE 13's COROLLARY:**
>
> **Every certificate-side step was done correctly on the first attempt. The actual defect was a silent binding failure that NOTHING about the certificate work would ever have surfaced.**
>
> **Only checking the LIVE STATE directly — `get`, not assumption — found it.**

## 🔴 Worked Example — MikroTik (`MC-0002`). The CA itself was broken.

**What began as *"reissue one certificate with a corrected SAN"* uncovered a defect present since the CA was BUILT:**

1. CSR generated with a correct SAN. **CN left blank** → sign failed cleanly, **no certificate written.** *(Correct behaviour.)*
2. CN supplied. **Sign appeared to succeed. CLEAN LOG.**
3. 🔴 **Verified the file anyway — the SAN was COMPLETELY EMPTY.** Not stale. **Missing.**
4. 🔴 **`copy_extensions` was not set ANYWHERE in `[ CA_default ]`.** **OpenSSL silently discards every `-addext` SAN without it.** **This meant EVERY certificate the CA had ever issued may have been affected.**
5. 🔴 **The fix landed in `[ ca ]` instead of `[ CA_default ]`** on the first attempt — a line-number assumption.
6. 🔴 **Reissue then failed: `There is already a certificate for .../CN=mikrotik.lab`.** **The BROKEN, SAN-less certificate had been issued successfully and was sitting in the database as VALID.** **Revoke first, then reissue.**
7. Serial `1001`. SAN verified **on the file** *and* **on the live-served connection.**

> 🔴 **Step 3 is the whole lesson: *verifying the file anyway, per habit,* is what found a CA-wide defect that a clean sign log had hidden since day one.**

## Common Mistakes

| Mistake | What it looks like | The fix |
|---|---|---|
| 🔴 **No `-addext` / no SAN** | **Clean sign. Browser refuses the certificate.** | **A.1** — the SAN goes in the CSR |
| 🔴 **`copy_extensions` unset, or in `[ ca ]`** | 🔴 **Clean sign. EMPTY SAN. No error anywhere.** | **A.2** — read the section header, not the line number |
| 🔴 **Signing with `openssl x509 -req -extfile`** | 🔴 **It WORKS — and the CA has no record. It can never be revoked, and `ADR-0009`'s detection control goes blind.** | **A.3** — `openssl ca`, always |
| 🔴 **Trusting a clean `openssl ca` sign log** | 🔴 **The CA issued a completely SAN-less certificate once, silently.** | **A.4** — read the artefact |
| 🔴 **The certificate never reaches `issued/`** | 🔴 **The SERVICE is correct. THE REBUILD IS NOT.** | **A.3** — `-out` writes to `issued/` |
| 🔴 **Installing the BARE LEAF** | 🔴 **`ERR_CERT_AUTHORITY_INVALID` with a perfectly valid certificate.** | **B.0** — build the bundle. `s_client` must return **3** |
| 🔴 **Importing the intermediate as a "CA Certificate"** | 🔴 **Looks right. Changes what the device TRUSTS, not what it SERVES. Chain count stays `1`.** | **B.0** |
| 🔴 **Trusting a `set` that returned no error** | 🔴 **The device served the FACTORY certificate for hours.** | **B step 4** — `get`, never `show` |
| 🔴 **`cat ... \| sudo tee`** | 🔴 **Silently writes an INCOMPLETE file. Put a keyless cert into production.** | **B.0** — `sudo sh -c '...'` |
| 🔴 **Using a STALE IP in the SAN** | **Browser name-mismatch with a perfect chain.** | **A.1** — check `ip a` on the device NOW |
| **Leaving CN blank** | `commonName field needed to be supplied` — **no certificate written** | **A.1** |
| **Skipping Part C** | A warning that looks like Part B failed | **Part C** — once per workstation |
| **RouterOS renaming the object** | Binding to a name that does not exist | **B** — `/certificate print detail` |
| 🔴 **Leaving `.key` files in `/tmp/` or Downloads** | **Private key material outside its `0700` directory.** | **Clean up. `shred -u`.** |
| 🔴 **Reusing an EXPOSED key on reissue** | **The same problem follows you into the new certificate.** | **`042`** — new key + replace |

## Related Pages

- `031-Pi01-Lab-CA-Build-Guide.md` — how the CA itself was built (one-time, already done)
- `CM-0005-Install-Lab-CA-Certificate-on-FGT01.md` and `CM-0007-Install-Lab-CA-Certificate-on-MikroTik.md` — the specific change records this runbook supports
- Atlas Academy, Book 9 — planned module "PKI, Taught Through Atlas's Two Certificate Authorities" uses this document's real, worked example as its teaching material once that book is built

---

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Written 2026-07-13 from the live FGT01/MikroTik certificate work. |
| **2.0** | 🔴 **2026-07-14 — `CM-0027` / `CM-0032`. REBUILT AGAINST THE DEVICE.** <br><br>🔴 **v1.0 was written DURING the session that discovered four PKI defects — and contained NONE of them.** `grep -c subjectAltName` on v1.0 returned **0**. `grep -ci bundle` returned **0**. **It set no SAN, never verified one, installed the BARE LEAF, and never checked the binding.** **`MC-0001` Phase 5 ticked *"Common Mistakes updated with the binding-verification lesson and the bundle requirement."* It contained neither.** <br><br>**Added — every one of them a documented incident:** **A.1** `-addext "subjectAltName=..."` *(no SAN = rejected outright)* · **A.2** `copy_extensions` must be in `[ CA_default ]`, **not `[ ca ]`** *(`MC-0002` put it in the wrong section)* · 🔴 **A.3** **`openssl ca`, NEVER `openssl x509 -req -extfile`** — the latter produces a valid certificate the CA has **no record of**, which cannot be revoked and blinds `ADR-0009`'s only detection control *(**two certificates in this lab were signed that way** — `CM-0032`)* · **A.4** verify the SAN and the serial *(a small serial = `openssl ca`; a random hex serial = `x509 -req`)* · 🔴 **A.5** confirm the row in `index.txt` · **B.0** build the bundle with `sudo sh -c`, chain count must be **3** · **B** verify the binding with **`get`, never `show`** · 🔴 **Validation §2 — DIFF THE WIRE AGAINST THE `issued/` FILE.** <br><br>🔴 **Validation §2 is the one that matters and it FAILS ON PI-HOLE TODAY.** **Four documents record — truthfully — that Pi-hole's SAN was *"verified on the live-served connection."* All four are right. And `issued/pihole/pihole.crt` still carries the pre-VLAN `IP:10.0.0.5`, and `032` rebuilds `tls.pem` from exactly that file.** **THE VERIFICATION CHECKED THE WIRE. THE REBUILD USES THE FILE. NOBODY CHECKED THE FILE.** <br><br>**Worked Examples rewritten** — v1.0 listed 2 of `MC-0001`'s 4 compounding failures, omitting the leaf-vs-bundle trap and the silently-unbound `admin-server-cert` **which is the origin of Charter Rule 13's corollary.** |
