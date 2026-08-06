---
Title: Lab CA — Certificate Reissuance and Renewal Guide
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Lab CA — Certificate Reissuance and Renewal Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Verified |
| Evidence Source | `MC-0002` / `CM-0008` live reissue, 2026-07-13 |
| Last Verified | 2026-07-13 |
| Version | 1.1 |
| Applies To | Any device with a Lab CA certificate that needs to change |

## Purpose

`035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` covers a device getting its **first** certificate.

This covers something different: **an existing certificate that is wrong, expiring, or compromised, and needs to be replaced.** These are not the same problem. Issuing is *"create an identity."* Reissuing is *"that identity is no longer accurate, or no longer safe to trust."*

## The Core Concept

> 🔵 **You cannot edit a certificate.**
>
> A certificate is a signed, cryptographically sealed statement — *"this key belongs to this identity, and the CA vouches for it."* Changing anything inside it (the SAN, the expiration, anything) would break the signature. **There is no update operation.**
>
> **Reissuing always means generating a brand-new certificate with a new serial number** — even if the underlying private key stays the same.

### Key reuse is a real decision, not a technicality

A certificate and its private key are two separate things. You *can* generate a new certificate for the same existing key, or you can generate a brand-new key too.

**Reusing the key is fine, security-wise — as long as the key itself was never exposed or compromised.** The MikroTik case is the good example: the *certificate* was wrong (stale SAN), but the key was never leaked, so reuse was the reasonable, lower-effort choice.

**If a key was ever exposed** — pasted into a chat log, sitting in a world-readable temp folder, committed to git — **generate a completely new key.** Reusing a possibly-compromised key just means the same problem follows you into the new certificate.

## When to Reissue

| Trigger | Reuse existing key? | 🔴 What actually removes the old certificate |
|---|---|---|
| **SAN is wrong** (IP/hostname changed — the MikroTik case) | Yes, usually | **Nothing needed.** Superseded, not dangerous. |
| **Approaching expiration** (routine renewal) | Yes, usually | **Nothing needed.** |
| 🔴 **Key or certificate file was EXPOSED** (chat log, repo, `/tmp`) | 🔴 **NO — generate a NEW key** | 🔴 **REMOVE THE OLD CERTIFICATE OBJECT FROM EVERY DEVICE THAT HOLDS IT.** **`openssl ca -revoke` DOES NOT DO THIS. See Step 5.** |
| 🔴 **Device itself was compromised** | 🔴 **NO — new key** | 🔴 **Same. Physical removal. There is no remote kill switch.** |

> 🟡 **That right-hand column is not theoretical.** This project has had **two near-misses with private keys in a git repo folder and in `/tmp` on Pi01** — and one real one: **`CM-0010` found two CA private key copies wrapped in a leaked passphrase, sitting in the CA's own private directory for fifteen hours.**
>
> 🔴 **AND IF IT EVER HAPPENS FOR REAL, `openssl ca -revoke` WILL NOT SAVE YOU. READ STEP 5 BEFORE YOU NEED IT — NOT DURING.**

## 🔴 Reusing a key is fine. Reusing an EXPOSED key is not — and here is the sharp edge.

**A certificate and its private key are two separate things.**

🔴 **A CERTIFICATE WITHOUT ITS PRIVATE KEY IS INERT.** It is a public document. **Anyone can hold one. It proves nothing.** *(This is why a stale, superseded certificate sitting on disk is a housekeeping problem, not a security incident.)*

🔴 **A KEY WITHOUT ITS CERTIFICATE IS THE WHOLE PROBLEM.** **If the key leaks, the certificate it belongs to can be re-presented by anyone — and this CA cannot revoke it.** **Generate a new key. Every time. No exceptions.**

## Step 1 — Generate the New CSR

**Reusing the existing key (the common case):**

```bash
ssh pihole
cd /etc/ssl/lab-ca/intermediate
sudo openssl req -config openssl.cnf -key /etc/ssl/lab-ca/issued/<device>/<device>.key \
  -new -sha256 -out csr/<device>.csr \
  -addext "subjectAltName=DNS:<hostname>,IP:<correct-ip>"
```

**Generating a new key too (compromise scenario):**

```bash
sudo openssl genrsa -out /etc/ssl/lab-ca/issued/<device>/<device>.key 2048
sudo openssl req -config openssl.cnf -key /etc/ssl/lab-ca/issued/<device>/<device>.key \
  -new -sha256 -out csr/<device>.csr \
  -addext "subjectAltName=DNS:<hostname>,IP:<correct-ip>"
```

> 🟡 **`-addext "subjectAltName=..."` is what actually sets the SAN** at CSR creation time. This is the step that was implicitly skipped or wrong the first time on MikroTik.
>
> **Check the IP/hostname list against what is *actually current*** — not what an old build guide says, and not what habit assumes.
>
> It is also silently ignored unless `copy_extensions = copy` is set in `[ CA_default ]` — see `031-Pi01-Lab-CA-Build-Guide.md`.

## Step 2 — Sign the New CSR (this is the reissue)

```bash
sudo openssl ca -config openssl.cnf -extensions server_cert \
  -days 365 -notext -md sha256 \
  -in csr/<device>.csr \
  -out /etc/ssl/lab-ca/issued/<device>/<device>.crt
```

This produces a genuinely new certificate — new serial number, new validity window — signed by the same intermediate CA, so it inherits the same trust chain your workstations already have. **No need to redo the workstation trust step.**

**Verify the SAN on the resulting file immediately. A clean sign log proves nothing:**

```bash
openssl x509 -in /etc/ssl/lab-ca/issued/<device>/<device>.crt -noout -text \
  | grep -A1 "Subject Alternative Name"
```

## Step 3 — Rebuild the Bundle

```bash
sudo sh -c 'cat /etc/ssl/lab-ca/issued/<device>/<device>.crt \
    /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
    > /etc/ssl/lab-ca/issued/<device>/<device>-bundle.crt'
```

> 🔴 **Note the `sudo sh -c '...'` wrapping the whole pipeline.**
>
> The previous version of this guide used `cat ... | sudo tee`. **That pattern silently writes incomplete files** — `sudo` applies only to `tee`, not to the `cat` reading root-owned inputs. `cat` prints `Permission denied`, **the pipeline keeps running anyway**, and `tee` writes a file missing whatever couldn't be read.
>
> **This exact pattern put a keyless certificate into production on Pi-hole.** See `038-Pi01-Troubleshooting-Guide.md`.

## Step 4 — Install on the Device

Same as `035` Part B, device-specific:

**FortiGate:** delete the old Local Certificate object, import the new bundle, **re-bind `admin-server-cert`.**

> Importing a certificate does **not** bind it to anything. `MC-0001` lost real time to an `admin-server-cert` that silently remained pointed at the factory self-signed certificate while every `set` command returned success.

**MikroTik:** remove the old certificate objects, import the new bundle and key, **note the newly-assigned object name.**

```routeros
/certificate remove [find name~"<old-name>"]
```

> **RouterOS renames the object on import** (e.g. `mikrotik-bundle.crt_0`) — it does not keep your filename. Binding commands need the *new* name.

> 🔴 **Remove the old certificate object before importing the new one.** Leaving both in place invites binding to the wrong one later by accident — exactly the kind of small oversight that turns into an hour of confused troubleshooting.

## 🔴🔴 Step 5 — Revocation. **READ THIS BEFORE YOU RELY ON IT.**

> # 🔴 REVOCATION DOES NOT WORK IN THIS CA.

**Confirmed 2026-07-13, and it has been true since the CA was built:**

```bash
grep -r crlDistributionPoints /etc/ssl/lab-ca/ Labs/Lab-01-Mikrotik-Core/
# -> ZERO occurrences.
```

**No certificate this CA issues carries a CRL Distribution Point extension. No CRL is served over HTTP.**

> 🔴 **NO CLIENT IS EVER TOLD WHERE TO LOOK — SO NO CLIENT EVER LOOKS.**
>
> **`openssl ca -revoke` updates `index.txt` on Pi01 and CHANGES NOTHING ANYWHERE ELSE.**

### 🔴 This has already happened. Twice.

**1. `MC-0002` revoked the broken MikroTik certificate — serial `1000`, the one with the empty SAN.**

🔴 **That revocation reached NOTHING.** Serial `1000` is marked `R` in `index.txt` and **remains FULLY TRUSTED by every device and browser holding the Root CA.** **Anyone holding that certificate and its key could present it today.**

**2. 🔴 And TWO certificates cannot be revoked AT ALL — the CA has no record of them.**

```
$ sudo cat /etc/ssl/lab-ca/intermediate/index.txt      # 2026-07-14
R  ...  1000  CN=mikrotik.lab      <- revoked. Still trusted by everything.
V  ...  1001  CN=mikrotik.lab
V  ...  1002  CN=vault.lab
V  ...  1003  CN=pihole.lab
```

**Four rows. This CA has signed SIX certificates that devices trust.** 🔴 **FGT01's — LIVE RIGHT NOW — and Pi-hole's original were signed with `openssl x509 -req -extfile`, which does not write to `index.txt`.**

🔴 **`openssl ca -revoke` on either one FAILS: *the CA has no record of it.*** **You cannot revoke — not even as bookkeeping — a certificate the database has never heard of.** (`CM-0032`)

---

### 🔴 SO WHAT DO YOU ACTUALLY DO WHEN A KEY IS EXPOSED?

**The only real remedy is PHYSICAL** (`ADR-0009`):

| # | Do this | Why |
|---|---|---|
| **1** | **Generate a NEW KEY.** Reissue the certificate. | Reusing a compromised key carries the problem into the new certificate. |
| **2** | **Install it on the device.** | |
| 🔴 **3** | 🔴 **REMOVE THE OLD CERTIFICATE OBJECT FROM THE DEVICE.** `/certificate remove` on RouterOS. Delete the Local Certificate on FortiOS. | 🔴 **THIS IS THE STEP THAT ACTUALLY REVOKES IT — because it is the only one anything OBSERVES.** |
| **4** | **Run `openssl ca -revoke` anyway.** | 🔴 **`index.txt` is the CA's ONLY record of what it has issued, and `ADR-0009` makes it the ONLY way to detect an unauthorised issuance.** **Bookkeeping, not enforcement. Know which one you are doing.** |

```bash
cd /etc/ssl/lab-ca/intermediate
sudo openssl ca -config openssl.cnf -revoke /etc/ssl/lab-ca/issued/<device>/<old-cert>
sudo openssl ca -config openssl.cnf -gencrl -out crl/intermediate-ca.crl

# 🔴 CONFIRM the CA actually knew about it. "Not present in database" = it did not.
sudo openssl ca -config openssl.cnf -status <old-serial>
```

> 🔴 **IF THE *INTERMEDIATE CA* IS COMPROMISED, NONE OF THE ABOVE HELPS.** **The attacker mints their own certificates.** **The only remedy is a NEW Intermediate, a reissue of all four device certificates, and REMOVING THE OLD INTERMEDIATE OBJECT FROM EVERY DEVICE.** **There is no partial measure and no remote kill switch.** **See `ADR-0009`.**

### 🔴 To make revocation REAL (it is not, today)

1. Add to `[ server_cert ]` in `intermediate/openssl.cnf`:
   ```
   crlDistributionPoints = URI:http://pihole.lab/crl/intermediate.crl
   ```
2. **Serve the CRL over HTTP** (Pi-hole's own web server, or nginx).
3. 🔴 **REISSUE EVERY CERTIFICATE.** **A CDP cannot be added to a certificate that already exists.**

> **Until then: this CA has revocation MACHINERY that NOTHING CONSULTS.** **`031` creates `crl/` directories and `crlnumber` files, and the commands run cleanly. They are decorative.**
>
> 🔴 **A CA that APPEARS to support revocation and does not is the same defect class as `033` teaching a deleted credential, and Pi-hole serving a factory certificate while three documents claimed otherwise.**

## Step 6 — Validate

**Check what the device is *actually serving* — not what you think you installed.**

```bash
openssl s_client -connect <device-ip>:443 -showcerts </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -text | grep -A1 "Subject Alternative Name"
```

> **Include `-issuer`.** Checking the issuer field is what caught Pi-hole serving its factory self-signed certificate while every document claimed a Lab CA certificate was in active use. A correct-looking SAN on a cert signed by the *wrong CA* is still wrong.

Confirm the chain still serves correctly after the swap:

```bash
openssl s_client -connect <device-ip>:443 -showcerts </dev/null 2>/dev/null \
  | grep -c "BEGIN CERTIFICATE"
```

Then a browser test — should load with no name-mismatch warning, from a workstation that already trusts the Lab CA root.

### 🔴 Step 6b — AND CHECK THE FILE THE REBUILD USES. It is a different object.

```bash
diff <(openssl s_client -connect <device-ip>:443 </dev/null 2>/dev/null \
        | openssl x509 -noout -serial -text | grep -A1 "Subject Alternative Name") \
     <(sudo openssl x509 -in /etc/ssl/lab-ca/issued/<device>/<device>.crt \
        -noout -serial -text | grep -A1 "Subject Alternative Name")
```
🔴 **EXPECT NO OUTPUT.**

> 🔴 **`openssl ca` writes the new certificate to `newcerts/`. IT DOES NOT UPDATE `issued/<device>/<device>.crt` UNLESS `-out` POINTS THERE.**
>
> 🔴 **THIS FAILS ON PI-HOLE TODAY.** The wire serves serial `1003` with `IP:10.10.0.5`. **`issued/pihole/pihole.crt` is a year-old certificate with `IP:10.0.0.5`** — and **`032` Step 7 rebuilds `tls.pem` from exactly that file.** (`CM-0032`)
>
> 🔴 **A REISSUE THAT DOES NOT LAND IN `issued/` IS A REISSUE THAT SURVIVES ONLY UNTIL THE NEXT REBUILD.**

## Common Mistakes

- **Attempting to reissue for an identity that already has a valid entry in the CA's database.** Fails with `ERROR: There is already a certificate for ...` — **even if the existing certificate is known to be broken or unused.** The CA's uniqueness policy doesn't know it's broken, only that it's still marked valid. **Revoke the old one first (Step 5), then reissue.**
- **Trusting a clean `openssl ca` sign log as proof the certificate is correct.** Always verify the resulting file's SAN directly. This caught real defects a clean-looking log missed entirely — twice in one session.
- **Assuming an old certificate's SAN is still correct just because the certificate is otherwise valid and trusted.** Validity and accuracy are different things.
- **Using `cat ... | sudo tee` to rebuild the bundle.** Writes a silently incomplete file.
- Leaving Common Name blank at the CSR prompt, assuming it's optional like the other fields with defaults — it isn't; the sign step fails outright and no certificate is written.
- Forgetting that RouterOS renames certificate objects on import.
- **Reusing a key that was actually exposed**, because reusing "worked fine" for a routine SAN fix. The two scenarios need different responses.
- 🔴 **Believing `openssl ca -revoke` removes a certificate from service.** **It does not. This CA has no CRL Distribution Point and serves no CRL. Serial `1000` was revoked and is still trusted by every device today.** **Step 5.**
- 🔴 **Reissuing without writing the result into `issued/<device>/`.** **The SERVICE is correct. THE REBUILD IS NOT.** **Step 6b.**
- 🔴 **Signing with `openssl x509 -req -extfile`.** **It produces a valid certificate the CA has NO RECORD of — unrevocable, and invisible to `ADR-0009`'s only detection control.** **Two certificates in this lab were signed that way.** **`035` A.3.**
- **Skipping validation because "it's just the same process as last time."** The whole reason this guide exists is that the SAN was wrong *despite* the original process seeming to work.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/MC-0001-FGT01-Lab-CA-Certificate-Installation.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0008-Reissue-MikroTik-Certificate-Correct-SAN.md`


## Change Log

| Version | Changes |
|---|---|
| 1.0 | Written ahead of the `CM-0008` MikroTik reissue. |
| 1.1 | **Step 3 bundle command rewritten** from `cat \| sudo tee` to `sudo sh -c`. **`-issuer` added to Step 6 validation.** Post-signing SAN verification added to Step 2. |
| **2.0** | 🔴 **2026-07-14 — `CM-0027` / `CM-0032`.** <br><br>🔴 **STEP 5 WAS DANGEROUS. It told you to `openssl ca -revoke` an exposed certificate — and this CA CANNOT REVOKE ANYTHING.** **No `crlDistributionPoints`, no CRL served, no client ever looks. `031` v0.7 and `ADR-0009` established this on 2026-07-13. `042` never got the correction** — **the same P2 pattern that left `035` without a SAN: the fix reached the document that DESCRIBES the CA and missed the ones that OPERATE it.** <br><br>**`042` is the document you open when a key has been exposed. It was handing you a command that does nothing, at the worst possible moment.** <br><br>**Step 5 replaced with what ACTUALLY works: new key → install → 🔴 REMOVE THE OLD CERTIFICATE OBJECT FROM EVERY DEVICE (the only step anything observes) → `openssl ca -revoke` as bookkeeping, knowing it is bookkeeping.** Plus how to make revocation real *(add a CDP, serve the CRL, **reissue everything** — a CDP cannot be added to an existing certificate)*. <br><br>🔴 **Added: TWO certificates in this lab CANNOT be revoked at all — FGT01's and Pi-hole's original were signed with `openssl x509 -req -extfile`, which writes no row to `index.txt`.** `openssl ca -revoke` on either fails outright. (`CM-0032`) <br><br>🔴 **Added Step 6b — DIFF THE WIRE AGAINST THE `issued/` FILE.** **`openssl ca` writes to `newcerts/`; it does not update `issued/` unless `-out` points there.** **A reissue that does not land in `issued/` survives only until the next rebuild — which is exactly Pi-hole's state today.** <br><br>**Sharpened the key-reuse rule:** a certificate without its key is **inert**; a key without its certificate is **the whole problem.** |
