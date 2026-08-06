---
Title: STD-0004 — Encryption Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0002` via `ADR-0027`/`ADR-0031` (+ the `CIS-Hardening-*` baselines). In force; per-control conformance tracked in Verification.
Version: 2.1
---

# STD-0004 — Encryption

> **At a glance.** Every internal service presents a certificate issued by the estate's own CA (ICA01), management planes speak strong SSH/TLS only, secrets and disks are encrypted with named algorithms, and the CA's keys are held offline and vaulted — each pinned to a real device and provable with a read-back.

| Item | Value |
|---|---|
| Layer | **Standard** — the concrete crypto settings the estate must run; binds real devices/configs/values |
| Governing policy | [`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md) — Secrets & Credentials (keys/crypto) |
| Requirement, in one line | Approved algorithms only, estate-CA certificates (never self-signed), secrets/disks/backups encrypted, CA keys offline + vaulted |
| Owner | Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | the two-tier PKI [`ADR-0027`](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) + [`ADR-0031`](../Decisions/ADR-0031-Retire-OpenSSL-Lab-CA.md) (unify on AD CS) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md); device crypto per the `CIS-Hardening-*` baselines ([`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md)) |
| Applies to | SW01 · 1941 · MKT01 · FGT01 (SSH/mgmt) · DC (LDAPS) · NPS01 (PEAP) · RCA01/ICA01 (PKI) · BKP01/Vaultwarden + clients (data at rest) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* read-backs below |
| Framework mapping | CIS v8 Ctl 3 · NIST 800-57 (key mgmt) / 800-52 (TLS) · Security+ 5.1 · CIS Cisco IOS Benchmark |

---

## Scope & applicability

Binds the cryptographic settings on Atlas devices and services: SSH/TLS on the management planes, the certificates internal services present, secret storage, data at rest, and CA key custody. It governs *how* crypto is configured and proven.

**Boundary with adjacent standards/policies:** *what data must be encrypted* is owned by [`POL-0011`](../Policies/POL-0011-Data-Governance-Classification-Privacy.md) (classification) — this standard says *how* once something is in scope. *Passwords/MFA/account crypto* are [`STD-0001`](./STD-0001-Password-and-Authentication.md). *The device hardening pass as a whole* is [`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md); this standard owns only its crypto clauses.

## Why a standard, not left in a guide

Crypto that drifts per device is how the silent failures happen: SW01 shipped a **cleartext SNMP v2c community** and both switches offered **CBC/3DES/1024-bit DH** until hardened; the retired OpenSSL CA issued a cert with **no SAN** (`CM-0027`) and its issuance DB was **40% blind** (`CM-0032`). A standard makes "the same strong settings, everywhere, provable" auditable instead of per-box folklore.

---

## The requirements

Each is citable as `STD-0004 R#`. Real values on named targets; the owner doc carries the running detail.

### R1 — Management-plane transport is strong SSH/TLS only

SSH **v2 only**; **CTR ciphers only** (`aes256-ctr, aes192-ctr, aes128-ctr` — CBC + 3DES removed); **DH modulus floor ≥ 2048**; auth-retries ≤ 2; **no cleartext management** (`no ip http server` / `no ip http secure-server`, no telnet). TLS **1.2+** on web/admin services. **Applies to:** SW01, 1941, MKT01, FGT01. **Owner docs:** [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) · [`CIS-Hardening-SW01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) (`POL-0007`).

- **R1a — documented deviation (accepted):** on the 1941 ISR G2 and Catalyst 2960X IOS images, SSH **MACs are `hmac-sha1` only** (no SHA2 offered) and **KEX cannot be pinned**. Mitigation in force: `ip ssh dh min size 2048` floors the modulus so the weak `group1` (768-bit) can't negotiate. This is a hardware/image ceiling, not a config gap — SHA2 MACs need a newer image (`POL-0007` allows a documented deviation, not a silent one).

### R2 — Device secrets are stored with a memory-hard hash

IOS secrets are **Type 9 (scrypt)** — never Type 7/Type 5/MD5; the working password lives in **Vaultwarden**, never in the config in the clear (`POL-0002`). **Applies to:** SW01, 1941 (every IOS device). **Owner docs:** the `CIS-Hardening-*` baselines + [`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md).

### R3 — Internal services present an estate-CA certificate, never self-signed

Every internal TLS/LDAPS/PEAP endpoint presents a certificate **issued by ICA01** (the enterprise issuing CA), chaining to the **offline Root RCA01** — **not** the retired OpenSSL Lab CA (`ADR-0031`), and **not** self-signed. Certificates carry a **correct SAN** (the `CM-0027` lesson) and **SHA-256**; keys per the AD CS templates. **Applies to:** DC LDAPS, NPS01 PEAP, HTTPS services, device mgmt certs. **Owner:** [`RCA01-ICA01-ADCS`](../../Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/) (`ADR-0027`). **Status: 📋 gated** on the AD CS root ceremony (the PKI is authored, not yet built — no ✅ until a real issued cert is read back).

### R4 — Data at rest is encrypted with named algorithms

**BitLocker** on Windows clients/laptops (and the PAW); **LUKS** on the offline CA media; **AES-256** on backup archives (`gpg --cipher-algo AES256`, `049`); the **Vaultwarden DB** encrypted. **Applies to:** clients + [`PAW01`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/) (BitLocker), the CA offline media (LUKS), [`BKP01`](../../Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/) (archives + vault). **Owner:** [`POL-0005`](../Policies/POL-0005-Backup-and-Recovery.md) (backups) + the workstation baseline (Backlog #40). **Status:** mixed — 📋 for hosts not yet built.

### R5 — CA keys are offline, vaulted, and their issuance is a control

The **Root CA is air-gapped** (signs the issuing CA once, then powered off); passphrases are **vaulted (Vaultwarden) + on paper**, with **separate passphrases for Root vs Issuing** (`CM-0010`); the issuance database (`index.txt`) is an **integrity control** (`ADR-0009`) that must match the certs actually issued (`CM-0032`); and **rotation precedes any backup** (`CM-0010`). **Applies to:** RCA01/ICA01, BKP01/Vaultwarden. **Owner:** [`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md) + [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md).

---

## Adopting & amending decisions

The dated trail (kept, never deleted; originals in the legacy snapshot).

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0027`](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) | Accepted | established the two-tier PKI that issues every estate cert (R3, R5) |
| [`ADR-0031`](../Decisions/ADR-0031-Retire-OpenSSL-Lab-CA.md) | Accepted | retired the OpenSSL Lab CA → unify on AD CS; non-domain devices reissued/re-trust (R3) |
| [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) | Accepted | `index.txt` as the issuance-integrity control; the destroy-step lesson (R5) |
| the `CIS-Hardening-*` baselines | in force (`POL-0007`) | the device SSH/secret crypto values, device-verified 2026-07-22 (R1, R2) |

## Verification (how conformance is proven)

Real read-backs — the [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit runs these; the device wins over the doc (Charter Rule 13).

- [x] **R1** — `show ip ssh` → `version 2.0`, `Encryption Algorithms: aes256-ctr,aes192-ctr,aes128-ctr`, DH ≥ 2048 (✅ SW01 + 1941, 2026-07-22).
- [x] **R1a** — `show ip ssh` shows `hmac-sha1` MACs on the IOS boxes = the documented ceiling; the `ip ssh dh min size 2048` mitigation present.
- [x] **R2** — `show run | include secret 9` → `secret 9 $9$…` (scrypt); no `secret 5`/`password 7` (✅ SW01 + 1941).
- [ ] **R3** — 📋 `openssl s_client -connect <svc>:636 </dev/null | openssl x509 -noout -issuer -ext subjectAltName` → issuer = ICA01, SAN present (gated on the PKI build; the wire-vs-file check per `CM-0032`/`015`).
- [ ] **R4** — `manage-bde -status` → `Protection On` (clients/PAW); a backup archive decrypts on the paper passphrase (`049` Phase 4).
- [ ] **R5** — the CA DB completeness check (`index.txt` rows == certs issued, `CM-0032`); a restored key `openssl rsa -in <key> -noout -check` → `RSA key ok` (`049`).
- [ ] **Meta** — any change to a value here traces to an amending ADR + a Change Log row.

> Markers are honest (`POL-0006`): the built device-crypto controls (R1/R2) are ✅ device-verified; the PKI and disk controls (R3/R4/R5) are 📋 until the AD CS ceremony and the clients exist. A ✅ needs the read-back.

## Learn it — the Academy (the source of truth for the *why* + the commands)

Verification above gives the command; these give the meaning and the how-to-run. The Academy is the *learn-it* layer (`POL-0004`) — linked, not restated.

- 🎓 **Concept (why it works):** ✅ [Encryption & PKI in Atlas](../../Atlas-Academy/Concepts/Encryption-and-PKI-in-Atlas.md) — this standard's why-layer (the two-tier trust chain · SAN/`copy_extensions` · why scrypt · the SHA1-MAC ceiling); the ⭐ golden reference Concept (`ADR-0053`). Also the [Concepts index](../../Atlas-Academy/Concepts/).
- 🖥️ **Commands (run the read-backs):** [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) (`show ip ssh`) · [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) (`manage-bde -status`, `certutil`) · [Linux](../../Atlas-Academy/Command-Library/Linux.md) (`openssl x509`/`rsa -check`, `gpg`)
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (5.1 crypto / 3.3 data protection) · [CCNA lab map](../../Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md) (IOS SSH crypto hardening)
- 📋 **Security program:** [Compliance Program](../Security-Program/Atlas-Compliance-Program.md) (the CIS/NIST control mapping this standard satisfies) · [Security Awareness](../Security-Program/Security-Awareness-Program.md) (handling Confidential data — the human layer)

## What a violation looks like

A `v2c` SNMP community or a Type-7 secret in a config · SSH offering `aes256-cbc`/`3des`/`group1` · a service presenting a **self-signed** or **OpenSSL-Lab-CA** cert (R3) · a cert with **no SAN** · BitLocker `Protection Off` on a domain laptop · a CA private-key `.bak` wrapped in an exposed passphrase (`CM-0010`) · `index.txt` rows ≠ certs issued (`CM-0032`).

## Related

[`POL-0002` Secrets & Credentials](../Policies/POL-0002-Secrets-and-Credentials.md) (governing) · [`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md) · [`POL-0011`](../Policies/POL-0011-Data-Governance-Classification-Privacy.md) · [`STD-0001`](./STD-0001-Password-and-Authentication.md) · [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) / [`SW01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 2.1 | 2026-08-04. **Learn-it:** the flagged `Concepts/Encryption-and-PKI-in-Atlas` why-layer Concept is now **built** (#30-F/#31, nailed as the ⭐ golden reference Concept) — the 📋 "warranted, to build" flag flips to the ✅ live link. No normative change to any requirement. |
| 2.0 | 2026-08-03. **Rewrote the thin v1.0 into an estate-grounded, testable standard** (#39/#42): real device-verified SSH crypto (CTR-only ciphers, DH-2048 floor, the documented SHA1-MAC ceiling) from the `CIS-Hardening-1941`/`SW01` baselines, Type-9 scrypt secrets, the estate-CA-cert rule **reconciled from the retired OpenSSL Lab CA → ICA01** (`ADR-0031`), data-at-rest (BitLocker/LUKS/AES-256), and CA key custody (`CM-0010`/`CM-0032`/`ADR-0009`) — each with a read-back and honest markers, plus a **Learn it (Academy)** section linking the Concept / Command-Library / cert-map / Security-Program source-of-truth (and flagging the missing Encryption-and-PKI Concept). Cut from the new `STD-Template`. |
| 1.0 | 2026-07-22. Thin Standard — named the requirement for Security+ 5.1; added no new control; deferred to the PKI/backup docs. (Superseded by v2.0.) |
