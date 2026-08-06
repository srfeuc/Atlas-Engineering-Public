---
Title: Lab-02 Offline-Root CA — Build Design & Checklist
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Target Design — checklist, not a command script. You write the openssl (Charter Locked Rule 17).
Version: 1.0
---

# Lab-02 — Offline-Root CA Build Design & Checklist

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **A greenfield PKI, built clean.** This is *not* a migration of the live Pi01 CA — that stays frozen with Lab-01. Lab-02 stands up its own trust root, **offline from day one, with revocation working from the first certificate.** Design + validation + failure modes only; you run the openssl. Grounds: `Atlas-Service-Architecture.md` Part 4, `ADR-0003` (OpenSSL for non-domain infra; AD CS travels with the Windows track), `ADR-0009` (why revocation must be real, not decorative), and the two decisions taken this session — **rebuild fresh; fix CRL as part of hardening.**

## Why greenfield changes the shape (read first)

Because we build new rather than migrate, the `ADR-0009` tangle drops away: **no reissuing the four frozen Lab-01 certs, no "key in two places" hazard.** The one thing we carry *forward* from `ADR-0009` is its hardest lesson — **a CA that appears to support revocation but doesn't is worse than one that admits it can't.** So revocation is designed in from certificate #1, not retrofitted.

## Architecture

| Tier | Lives | Online? | Signs |
|---|---|---|---|
| **Root CA** | LUKS-encrypted removable media, air-gapped | 🔴 **No — powered off in a drawer** | Only the Intermediate. Roughly once. |
| **Intermediate CA** | CA01 (VM on PVE01, its own segment) | Yes | Every device/service certificate |
| **Issued certs** | The devices/services | — | — |

**Scope (`ADR-0003`):** this OpenSSL PKI serves **non-domain** infrastructure (network devices, Linux services, Proxmox, Vaultwarden). Domain-joined Windows resources get **AD CS**, which is built with the identity track — same domain-membership boundary as RADIUS and DNS.

## Gates — true before you generate a single key

- [ ] **VAULT01 is up** (Vaultwarden off Pi01) to hold passphrases — a CA passphrase never lands in git or a `.txt` (`POL-0002`, `CM-0014`).
- [ ] **An air-gapped signing machine** exists (a spare box or a live-USB boot, never on the network during signing).
- [ ] **Two LUKS-encrypted USB devices** on hand — one working copy, one off-site (this also closes the Tier-1 "both copies in the same room" risk, `POL-0005`).
- [ ] **A CRL/AIA publication point decided** — an HTTP URL you control that will still resolve at validation time (SRV01 or Pi-hole's nginx). The URL must be baked into certs *before* issuance.
- [ ] **Naming/addressing settled** (`POL-0008`) — the `.lab` suffix reality (`ADR-0007`: certs are `<device>.lab` on the wire), so SANs are right the first time.

## Config-design checklist

### Root (on the air-gapped machine, once)

- [ ] **Generate the Root key + self-signed Root cert** with a long validity; strong key (design choice: RSA-4096 or EC-P384 — pick and record why). Passphrase-protected; passphrase → VAULT01.
- [ ] **Define the Root's openssl config** so it can *only* sign CA certs (basicConstraints CA:true, pathlen as chosen; keyCertSign+cRLSign only).
- [ ] **Bake the CRL Distribution Point + AIA URL** into the Intermediate it will sign — *the whole point of fixing `ADR-0009`.*
- [ ] **Initialize the Root's CA database** (`index.txt`, `crlnumber`, `serial`) — `index.txt` is a **control**, not a file (`ADR-0009`): it is the record of everything ever signed.
- [ ] **Generate the first Root CRL** (even if empty) and copy it out to the publication point — a CRL that's never published is the `ADR-0009` defect.
- [ ] 🔴 **Air-gap discipline:** the Root key never touches a networked machine. Sign, unmount, power down, drawer. Two copies, one off-site.

### Intermediate (on CA01, online)

- [ ] **Generate the Intermediate key + CSR** on CA01; carry the CSR to the air-gapped machine; sign with the Root; carry the cert back. **The Root key never comes to CA01.**
- [ ] **Define the Intermediate's issuing profile** — and 🔴 **every issued cert carries `crlDistributionPoints` (and AIA)** pointing at the publication URL. This is the line that was missing for the entire life of the Pi01 CA (`ADR-0009`).
- [ ] **Separate profiles** for server certs (serverAuth, SANs mandatory — `035` set none, once) vs any client/device certs.
- [ ] **Build the trust bundle** (Root + Intermediate) for distribution; the **Root cert** (public) goes into device trust stores — the Root *key* never does.
- [ ] **Stand up CRL publication over HTTP** (SRV01/Pi-hole nginx); schedule Intermediate CRL regeneration before expiry.
- [ ] **Document the issue + reissue + revoke runbooks** — and fix the doc that *does* the work, not just the one that describes it (`016` R2: `035`/`042` are read every issuance; `031` once).

## Validation

- [ ] **Chain verifies:** an issued cert validates against the Intermediate+Root bundle (`openssl verify`), and the SAN matches what's served **on the wire** (`ADR-0009` R-A2: check the wire *and* the file).
- [ ] 🔴 **Revocation actually works** — the check the Pi01 CA failed: issue a test cert, revoke it, regenerate+publish the CRL, and confirm a client **rejects** it (and that the cert carried a reachable CRL DP in the first place: `openssl x509 -text | grep -A2 "CRL Distribution"` returns a URL, not nothing).
- [ ] **Root is offline** — verify no copy of the Root *key* exists on any networked host (grep, `ls` the CA dirs; `POL-0002` pre-archive check).
- [ ] **`index.txt` reconciles** with what's actually deployed — the only way to detect an unauthorized issuance (`ADR-0009`).
- [ ] **Off-site copy exists and restores** — a Game Day that mounts the off-site LUKS device and reads the key back (`POL-0005`: a backup isn't one until restored).

## Failure modes

- 🔴 **Revocation that reaches nothing** — the `ADR-0009` defect: `crlDistributionPoints` absent from issued certs, or a CRL never served. `MC-0002` revoked a cert that stayed trusted everywhere. Bake the DP in from cert #1 and *test a real revocation*.
- 🔴 **Root key exposure** — the `ADR-0009` convergence: key + passphrase on one machine. Air-gap the key; vault the passphrase; a procedure that copies key material names its destroy step (`POL-0002`).
- 🔴 **A clean `openssl` command that didn't do what you think** — a silently unbound cert, a SAN-less cert after a clean sign (`035`), a keyless PEM from `cat | sudo tee`. Read the artefact back; never trust exit code 0 (Charter).
- **Both copies in one room** — a single fire takes the whole PKI. One copy off-site (`POL-0005`).
- **AD CS scope creep** — this CA is non-domain only; don't let it drift into issuing for domain machines (that's AD CS, `ADR-0003`).

## Related

`Atlas-Service-Architecture.md` Part 4 · `ADR-0003` · `ADR-0009` · `POL-0002` (Secrets) · `POL-0005` (Backup & Recovery) · the future *POL — PKI & Trust* flagged in the Governance Framework

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Greenfield offline-Root / online-Intermediate OpenSSL PKI for Lab-02's non-domain estate, with revocation (CRL DP + AIA + published CRL) designed in from the first certificate — fixing the `ADR-0009` "revocation reaches nothing" defect at the root. Checklist format: gates, Root (air-gapped) and Intermediate (CA01) build steps, validation (including a real revocation test and an off-site restore Game Day), and failure modes. You write the openssl (Rule 17). |
