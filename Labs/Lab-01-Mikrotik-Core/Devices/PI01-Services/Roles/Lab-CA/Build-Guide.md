---
Title: Pi01 Lab Certificate Authority Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA
---

# Pi01 Lab Certificate Authority Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Lab-CA

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Verified (build) / Unverified (FGT01 + Pi-hole SAN) |
| Evidence Source | Live CA config, `MC-0002` |
| Last Verified | 2026-07-13 |
| Version | 0.7 |
| Applies To | Pi01 |

> **Building the CA is a one-time task and it is already done.** This page exists so it can be rebuilt from scratch if lost. For the task you will actually repeat — issuing a certificate to a new device — see `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`.

## Purpose

Build a private two-tier OpenSSL Certificate Authority on Pi01 so every lab service can serve trusted HTTPS using internal hostnames (`pihole.lab`, `vault.lab`) and private IPs — which **no public CA, Let's Encrypt included, can issue for.**

## Design Philosophy

Two-tier architecture, industry standard for PKI:

- **Root CA** — created once, signs only the Intermediate CA certificate, private key never leaves the Pi, valid 10 years. Used as rarely as possible.
- **Intermediate CA** — signs all day-to-day device/service certificates, valid 5 years. If compromised, it can be revoked and replaced **without touching the Root CA**.
- **Issued certificates** — one year validity per device/service.

The Root CA private key is the single most sensitive file in this build. If compromised, an attacker can issue certificates that every lab device trusts.

## Prerequisites

- Base system build complete (`030-Pi01-Base-System-Build-Guide.md`)
- OpenSSL installed (standard on Debian-based distros)
- **Vaultwarden already running** (`034-Pi01-Vaultwarden-Build-Guide.md`)

> 🔴 **Build Vaultwarden first.** You are about to generate a passphrase with **no recovery path**. It needs somewhere real to live from the moment it exists. If you build the CA first, that passphrase ends up in a text file — which is exactly what happened here, and correcting it is what drove the entire 2026-07-13 overhaul.

## Directory Structure

```text
/etc/ssl/lab-ca/
├── root/
│   ├── private/root-ca.key      4096-bit RSA, AES-256 encrypted, chmod 700
│   ├── certs/root-ca.crt        Self-signed, valid 10 years
│   ├── crl/  newcerts/
│   ├── index.txt                Database of all signed certificates
│   ├── serial  crlnumber
│   └── openssl.cnf
├── intermediate/
│   ├── private/intermediate-ca.key   chmod 700
│   ├── certs/
│   │   ├── intermediate-ca.crt
│   │   └── ca-chain.crt         Root + Intermediate, distributed to clients
│   ├── csr/intermediate-ca.csr
│   ├── crl/  newcerts/
│   ├── index.txt  serial  crlnumber
│   └── openssl.cnf
└── issued/
    └── <device>/
        ├── <device>.key         No passphrase (services start unattended)
        └── <device>.crt
```

## 1. Create the Root CA

```bash
sudo mkdir -p /etc/ssl/lab-ca/root/{private,certs,crl,newcerts}
sudo chmod 700 /etc/ssl/lab-ca/root/private
cd /etc/ssl/lab-ca/root
sudo touch index.txt
echo 1000 | sudo tee serial
```

Generate the Root CA key (AES-256 encrypted — you will be prompted for a passphrase) and the self-signed certificate:

```bash
sudo openssl genrsa -aes256 -out private/root-ca.key 4096
sudo openssl req -config openssl.cnf -key private/root-ca.key -new -x509 \
  -days 3650 -sha256 -extensions v3_ca -out certs/root-ca.crt
```

> 🔴 **Put that passphrase in Vaultwarden now.** Not in a text file "for now." There is no recovery path — lose it and the only option is rebuilding the entire CA and reissuing every certificate in the lab.

## 2. Create the Intermediate CA

```bash
sudo mkdir -p /etc/ssl/lab-ca/intermediate/{private,certs,csr,crl,newcerts}
sudo chmod 700 /etc/ssl/lab-ca/intermediate/private
cd /etc/ssl/lab-ca/intermediate
sudo touch index.txt
echo 1000 | sudo tee serial
```

```bash
sudo openssl genrsa -aes256 -out private/intermediate-ca.key 4096
sudo openssl req -config openssl.cnf -new -sha256 \
  -key private/intermediate-ca.key -out csr/intermediate-ca.csr

cd /etc/ssl/lab-ca/root
sudo openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
  -days 1825 -notext -md sha256 \
  -in ../intermediate/csr/intermediate-ca.csr \
  -out ../intermediate/certs/intermediate-ca.crt
```

> 🔴 **Note `-aes256` on the Intermediate key. Until 2026-07-13 this guide did not have it.**
>
> The Root key in Step 1 was encrypted; the Intermediate was not. **A CA rebuilt from the old guide produced an Intermediate signing key sitting on disk in plaintext** — and the Intermediate is the key that signs every day-to-day certificate. The live Intermediate *is* encrypted (`043` Part 9 rotated both), so the guide was teaching a defect the device did not have.
>
> **Use a different passphrase from the Root's.** A shared passphrase silently collapses the two-tier design — the whole point is that a compromised Intermediate can be revoked and replaced *without touching the Root*. Same passphrase, one compromise, both tiers.
>
> Found and fixed under `CM-0010`.

> 🔴 **If you ever back up a key file before re-encrypting it, destroy the backup the moment the new key verifies.**
>
> ```bash
> # ONLY after: sudo openssl rsa -in <live-key> -noout -check   ->   RSA key ok
> sudo shred -u /etc/ssl/lab-ca/root/private/root-ca.key.bak-<date>
> ```
>
> **This is not hypothetical.** `043` Part 9 re-encrypted both CA keys and recorded step 1 as *"Backed up both key files first."* It never recorded destroying them. **Both copies sat in the CA's own private directories for fifteen hours, wrapped in the passphrase that had just been declared compromised** — and `049`'s backup archives `/etc/ssl/lab-ca` whole, so one `tar` would have shipped them off-site permanently. Found by `ls -la`, not by any document.
>
> **A key backup is a rollback with an expiry measured in minutes.** Create it, verify the replacement, destroy it. Never leave it in the private directory. See `CM-0010`.

**Before archiving or backing up the CA — always list the private directories first:**

```bash
sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/
```

**Expect exactly one `.key` file in each, mode `0600`.** Anything else — `.bak`, `.new`, `.old` — is key material you are about to copy somewhere you cannot recall it from.

> 🔴 **REQUIRED STEP — missing from this guide, and from the original CA build, until 2026-07-13.**
>
> OpenSSL's CA signing step **silently discards any Subject Alternative Name requested at CSR time** unless `copy_extensions` is set. It is a deliberate OpenSSL security default.
>
> Without the line below, **every certificate this CA issues will have a missing or incomplete SAN** — and the sign log looks completely clean either way. Found the hard way during a MikroTik reissue (`MC-0002`).
>
> Add this to `[ CA_default ]` in `/etc/ssl/lab-ca/intermediate/openssl.cnf`, **before issuing any device certificate:**
>
> ```text
> copy_extensions = copy
> ```
>
> Then confirm it landed in the **right section** — `[ CA_default ]`, **not** `[ ca ]`, which sits directly above it and is very easy to hit with a line-number-based edit:
>
> ```bash
> sed -n '1,10p' /etc/ssl/lab-ca/intermediate/openssl.cnf
> ```

### Build the chain file distributed to clients

```bash
sudo sh -c 'cat /etc/ssl/lab-ca/intermediate/certs/intermediate-ca.crt \
    /etc/ssl/lab-ca/root/certs/root-ca.crt \
    > /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt'
```

> 🔴 **Note the `sudo sh -c '...'` wrapping the entire pipeline.**
>
> The previous version of this guide used `cat file1 file2 | sudo tee out`. **That pattern silently writes incomplete files.** `sudo` applies only to `tee`, not to the `cat` reading the inputs. When `cat` hits a root-owned file it cannot read, it prints `Permission denied` — **and the pipeline keeps running anyway.** `tee` writes successfully. It just writes a file missing whatever `cat` couldn't read.
>
> **This exact pattern put a certificate-only PEM with no private key into production on Pi-hole**, and it was only caught later by an unrelated TLS handshake failure. See `038-Pi01-Troubleshooting-Guide.md`.
>
> Applying `sudo` to one command in a pipe does not extend root to the others in that pipe.

## 3. Issue a Device Certificate

Repeat per device (`pihole`, `mikrotik`, `fortigate`, `vaultwarden`):

```bash
sudo mkdir -p /etc/ssl/lab-ca/issued/<device>
cd /etc/ssl/lab-ca/intermediate

sudo openssl genrsa -out /etc/ssl/lab-ca/issued/<device>/<device>.key 2048

sudo openssl req -config openssl.cnf -key /etc/ssl/lab-ca/issued/<device>/<device>.key \
  -new -sha256 -out csr/<device>.csr \
  -addext "subjectAltName=DNS:<device>.lab,IP:<current-device-ip>"

sudo openssl ca -config openssl.cnf -extensions server_cert \
  -days 365 -notext -md sha256 \
  -in csr/<device>.csr \
  -out /etc/ssl/lab-ca/issued/<device>/<device>.crt
```

> 🟡 **Common Name must actually be typed in.** At the interactive DN prompt every field *except* Common Name shows a default in brackets — press Enter to accept those. Leaving CN blank fails the sign step with `The commonName field needed to be supplied and was missing`, and **no certificate is written.**

> 🔵 **`-addext` is what sets the SAN** — the list of hostnames/IPs the certificate is valid for. Without `copy_extensions = copy` (Step 2), this flag is **silently ignored** and the certificate has no SAN at all.

**Always verify the SAN after signing. A clean sign log proves nothing:**

```bash
openssl x509 -in /etc/ssl/lab-ca/issued/<device>/<device>.crt -noout -text \
  | grep -A1 "Subject Alternative Name"
```

### Bundle the leaf with the chain

Installing the bare leaf produces an incomplete chain and browser trust errors even when everything else is correct.

```bash
sudo sh -c 'cat /etc/ssl/lab-ca/issued/<device>/<device>.crt \
    /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
    > /etc/ssl/lab-ca/issued/<device>/<device>-bundle.crt'
```

Verify the result actually contains what you expect — do not assume:

```bash
grep -c "BEGIN CERTIFICATE" /etc/ssl/lab-ca/issued/<device>/<device>-bundle.crt
```

## 4. Distribute the Root CA to Trust Stores

Every device/browser that will trust lab HTTPS needs `root-ca.crt` imported into its trusted root store. Windows: `certmgr.msc` → Trusted Root Certification Authorities → Import.

**This is once per workstation, not once per device — and it is the step everyone skips.** See `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` Part C.

## Validation

```bash
openssl verify -CAfile /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
  /etc/ssl/lab-ca/issued/pihole/pihole.crt
```

Should return `OK`.

## Common Mistakes

- **Losing or forgetting the Root CA key passphrase** — there is no recovery path, only rebuilding the entire CA and reissuing every certificate.
- **Leaving a key backup (`.bak`, `.new`, `.old`) in the private directory after re-encrypting.** It is the same key wrapped in the *old* passphrase — the one you just declared compromised. `043` Part 9 left two for fifteen hours. `CM-0010`.
- **A non-ASCII character in a CA passphrase.** OpenSSL reads passphrase **bytes**, not characters. A `£` is `0xC2 0xA3` over UTF-8 SSH and something else — or nothing — on a rescue console or a foreign keymap. **The one time you must type it is a bare-metal recovery on unfamiliar hardware.** Length, not exotic characters. `CM-0010`.
- **Generating the Intermediate key without `-aes256`**, or with the same passphrase as the Root. Both defeat the two-tier design.
- **`cd`-ing into `/etc/ssl/lab-ca/*/private/`.** It is `0700 root`; your shell is not root. The `cd` fails, you stay in `~`, and the next `sudo` command runs against the wrong path. **Use absolute paths.** `sudo` elevates the command, not the shell that resolved the path.
- **Leaving `copy_extensions` unset in `[ CA_default ]`** — every certificate issued will silently lack a proper SAN, even if `-addext` is used correctly. Affected this CA from initial build through 2026-07-13.
- **Using `cat ... | sudo tee` to build a combined file** — writes a silently incomplete file when any input is root-owned. Wrap the whole pipeline: `sudo sh -c '...'`.
- Issuing device certificates with a passphrase on the key — most services need to start unattended and will fail.
- Distributing `intermediate-ca.crt` alone instead of the full `ca-chain.crt`.
- Leaving Common Name blank at the CSR prompt.
- **Reissuing for an identity that already has a valid entry in the CA database** — fails with `ERROR: There is already a certificate for ...`, *even if the existing certificate is known to be broken.* The CA's uniqueness policy doesn't know it's broken, only that it's still marked valid. Revoke first.

## Lessons Learned from Actual Deployment

- **Pi-hole was never actually using the Lab CA certificate.** Directly verified 2026-07-13 — `/etc/pihole/tls.crt` was Pi-hole's own factory self-signed certificate (`issuer=CN=pi.hole, O=Pi-hole, C=DE`). This guide *and* the Pi01 Build Record both claimed "in active use" from the original build onward. **Caught only by checking the `issuer` field rather than trusting the claim.** Since corrected — Pi-hole now serves a real Lab CA certificate.
- **FortiGate:** issued and installed via `MC-0001` — an involved diagnostic (hidden Feature Visibility menu, leaf-vs-bundle confusion, a silently unbound `admin-server-cert`).
- **MikroTik:** issued, installed, then properly reissued with a correct SAN once the `copy_extensions` gap surfaced — `MC-0002`.

## Closed Item — Certificate SANs Verified

> ✅ **CLOSED 2026-07-13 (evening).** Every device's *live-served* certificate was read directly, checking `issuer` as well as SAN:
>
> | Device | Issuer | SAN |
> |---|---|---|
> | FGT01 | `CN=Home Lab Intermediate CA` | `DNS:fortigate.lab, IP:10.10.0.254, IP:172.16.0.1` |
> | Pi-hole | `CN=Home Lab Intermediate CA` | `DNS:pihole.lab, DNS:pi.hole, IP:10.10.0.5` |
> | MikroTik | Lab CA | `DNS:mikrotik.lab, IP:10.10.0.1` (`MC-0002`) |
>
> **`029` was right and this guide was stale.** FGT01's certificate was issued 2026-06-20 — **three weeks before the `copy_extensions` fix — and is correct anyway.** It was built with `-extfile`, which supplies extensions at signing time and **never consults `copy_extensions`.** The gate it would have failed was never in its path.
>
> **The CA-wide `copy_extensions` gap is closed across every device.**
>
> **Keep the habit that closed it:** read the certificate the device is *actually serving*, and **check `issuer`, not just SAN.** That is what caught Pi-hole serving a factory certificate while every document claimed otherwise. A correct SAN on a self-signed certificate is still a self-signed certificate.
>
> ```bash
> openssl s_client -connect <ip>:443 </dev/null 2>/dev/null | openssl x509 -noout -issuer -subject -dates
> ```

## Rollback

> 🔴 **REVOCATION DOES NOT WORK IN THIS CA. Read this before relying on the commands below.**
>
> **No certificate this CA issues carries a CRL Distribution Point extension.** Confirmed 2026-07-13 — `grep -r crlDistributionPoints` across the entire repository returns **zero** occurrences. This guide creates `crl/` directories and `crlnumber` files, and the commands below run cleanly — **but no client is ever told where to fetch the CRL, so no client ever fetches it.**
>
> **`openssl ca -revoke` updates `index.txt` on Pi01 and changes nothing anywhere else.**
>
> **This has already happened.** `MC-0002` revoked the broken MikroTik certificate (serial `1000`, empty SAN). That certificate remains **fully trusted by every device holding the Root CA.** The revocation reached nobody.
>
> **Until a CDP is configured and a CRL is actually served, the only real remedy for a compromised certificate is to replace it AND remove the old object from every device that trusts it.** Revocation here is a filing action, not a security control.
>
> **To fix:** add `crlDistributionPoints = URI:http://pihole.lab/crl/intermediate.crl` to `[ server_cert ]` in `intermediate/openssl.cnf`, serve the CRL over HTTP, and **reissue every certificate** — a CDP cannot be added to a certificate that already exists. See `ADR-0009`.

Revoke a compromised device certificate rather than rebuilding the CA — **noting the above, this is bookkeeping, not enforcement:**

```bash
cd /etc/ssl/lab-ca/intermediate
sudo openssl ca -config openssl.cnf -revoke /etc/ssl/lab-ca/issued/<device>/<device>.crt
sudo openssl ca -config openssl.cnf -gencrl -out crl/intermediate-ca.crl
```

Rebuilding the Root CA is a last resort — every issued certificate becomes invalid and must be reissued.

## Completion Checklist

- [ ] **Vaultwarden running before the CA is built**
- [ ] Root CA created, key encrypted, passphrase stored in Vaultwarden (**not a text file**)
- [ ] Intermediate CA created and signed by Root, **key encrypted with `-aes256`, separate passphrase from the Root**
- [ ] **No key backups left in either private directory** — `ls -la` shows exactly one `0600` `.key` per directory
- [x] `copy_extensions = copy` confirmed set in `[ CA_default ]` — fixed 2026-07-13
- [ ] `ca-chain.crt` built with `sudo sh -c`, contents verified
- [ ] Root CA imported into the trust store of every admin machine/browser
- [ ] Device certificates issued and **SANs verified on the file, not assumed from a clean sign log**
- [x] **Closed 2026-07-13:** Pi-hole's and FortiGate's *live-served* certificate SANs **and issuers** verified directly. Both correct, both Lab CA-issued.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`
- `Labs/Lab-01-Mikrotik-Core/Operations/042-Certificate-Reissuance-and-Renewal-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Operations/043-PKI-and-Credential-Security-Overhaul-Session-Summary.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`
- `00-Atlas-Foundation/Decisions/ADR-0003-AD-CS-vs-OpenSSL-Lab-CA.md`

## Change Log

| Version | Changes |
|---|---|
| 0.3 | `copy_extensions` gap found and fixed 2026-07-13. |
| 0.7 | 🔴 **Revocation confirmed non-functional.** No `crlDistributionPoints` anywhere in the repo — no issued certificate carries a CDP, no CRL is served. `MC-0002`'s revocation of the broken MikroTik certificate **reached no client and that certificate is still trusted.** Rollback section corrected; fix documented. See `ADR-0009`. |
| 0.6 | **`copy_extensions` open item CLOSED.** All live-served certificates verified directly — FGT01, Pi-hole, MikroTik. **FGT01's predates the fix and is correct anyway: `-extfile` bypasses `copy_extensions`.** `029` was right; this guide was stale. |
| 0.5 | **Intermediate key now generated with `-aes256`** — this guide would otherwise rebuild a CA whose day-to-day signing key sits on disk in plaintext. Added the key-backup destruction rule and the pre-archive `ls -la` check: `043` Part 9 created two exposed key copies and never recorded destroying them, and `049`'s backup would have exported them off-site. Added non-ASCII passphrase and absolute-path warnings. All from `CM-0010`. |
| 0.4 | **Two `cat \| sudo tee` pipelines rewritten as `sudo sh -c`.** This guide was still teaching the exact pattern that silently wrote a keyless PEM into Pi-hole's production TLS config. Vaultwarden added as a prerequisite — the CA passphrase has no recovery path and needs somewhere real to live from the moment it exists. The Pi-hole certificate correction and the open FGT01/Pi-hole SAN verification both recorded explicitly. |
