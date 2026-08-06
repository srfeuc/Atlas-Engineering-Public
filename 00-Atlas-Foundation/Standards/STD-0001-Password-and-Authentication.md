---
Title: STD-0001 — Password & Authentication Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0002` via `ADR-0021`. In force; per-control conformance tracked in Verification.
Version: 2.1
---

# STD-0001 — Password & Authentication

> **At a glance.** Passphrases get their strength from length (ASCII, unique); Finance/HR carry a stricter fine-grained policy; local-admin and DSRM passwords are LAPS-managed; admins log on with per-tier accounts (and Tier-0 is in Protected Users); network-device secrets are scrypt — each pinned to a real target and provable with a read-back.

| Item | Value |
|---|---|
| Layer | **Standard** — the concrete auth settings the estate must run; binds real accounts/hosts/values |
| Governing policy | [`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md) — Secrets & Credentials (+ [`POL-0010`](../Policies/POL-0010-Acceptable-Use.md) access) |
| Requirement, in one line | Length-based unique passphrases · PSO for Finance/HR · LAPS for local/DSRM · per-tier accounts + Protected Users · scrypt device secrets |
| Owner | Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) (tiered identity) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md); device secrets per the `CIS-Hardening-*` baselines ([`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md)) |
| Applies to | DC (PSO/LAPS/tier accounts) · every domain member (LAPS) · SW01/1941 (IOS secrets) · the CA (passphrases) |
| Feeds / fed by | **feeds** [`STD-0002`](./STD-0002-Access-Control.md) (the accounts it defines are what STD-0002 authorizes) · **fed by** the DC [`Build-Checklist`](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md) + the `CIS-Hardening-*` baselines |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* read-backs below |
| Framework mapping | CIS v8 Ctl 5/6 · NIST 800-63B · Security+ 5.1 · AZ-800/801 (identity) |

---

## Scope & applicability

Binds how identities authenticate across the estate: the password/passphrase rules, the fine-grained policy for sensitive departments, managed local-admin secrets, the per-tier admin accounts, and device secret storage.

**Boundary with adjacent standards/policies:** *what an authenticated identity may then do* is [`STD-0002`](./STD-0002-Access-Control.md) (access control) — this standard ends at "who you are." *Crypto/algorithm* (how a secret is hashed/encrypted at rest) is [`STD-0004`](./STD-0004-Encryption.md). *The secret-storage rule itself* is [`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md).

## Why a standard, not left in a guide

Auth that varies per box is how the estate got its scars: a passphrase with a `£` in it **broke bare-metal recovery** (`049`/`CM-0014`), and IOS boxes shipped **Type-5/MD5** secrets until hardened. A standard makes "strong, uniform, provable" auditable instead of per-host habit.

---

## The requirements

Each is citable as `STD-0001 R#`. Real values on named targets; the owner doc carries the running detail.

### R1 — Passphrase strength is length-first and ASCII

Passphrases are **long, ASCII, unique, never reused**; entropy comes from **length, not exotic characters** — *"24+ ASCII characters beats 19 with a `£` in it"*; the CA uses **different passphrases for Root vs Issuing**. **Applies to:** every vaulted credential; the CA passphrases especially. **Owner doc:** [`049` §Paper/passphrase standard](../../Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md) (`POL-0002`). *(Rationale: OpenSSL reads the passphrase as **bytes** — a non-ASCII glyph is a different byte sequence on a rescue console and won't unlock the key.)*

### R2 — Finance/HR carry a fine-grained password policy (PSO)

**`PSO-FinanceHR`** — precedence **10**, **min length 15**, **lockout threshold 3** — applied to **`G-FinanceHR-Users`**; the domain baseline (via the root **"Domain Security"** GPO) covers everyone else. **Applies to:** the DC. **Owner doc:** [DC `Build-Checklist` §6](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md). **Status: ✅ built (Stage 7b)** — the resultant-policy proof waits on the user population (Stage 8).

### R3 — Local-admin and DSRM passwords are LAPS-managed

**Windows LAPS** — self-permission on the **`Devices` OU**, the `LAPS` GPO linked to it, so every domain member's local admin password is rotated and escrowed; the **DCs' DSRM password is LAPS-managed too** (which retired the `POL-0002` manual DSRM record). **Applies to:** every domain member + the DCs. **Owner doc:** [DC `Build-Checklist` §1/§6](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md). **Status: ✅ built (Stage 7c).**

### R4 — Admins use per-tier accounts; Tier-0 is in Protected Users

Three separate identities — **`t0-seth`** (DC/PKI only), **`t1-seth`** (member servers), **`seth`** (daily); the built-in **Administrator** is secured as break-glass, not used; **`t0-seth` is in Protected Users** (no NTLM, so a Tier-0 credential can't be replayed to a lower tier — `ADR-0021`). **Applies to:** the admin accounts. **Owner doc:** [DC `Build-Checklist` §8](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md). **Status: ✅ device-verified 2026-07-22.**

### R5 — Network-device secrets are scrypt; service accounts are gMSA-first

IOS secrets are **Type 9 (scrypt)** (`STD-0004 R2`), never Type 7/5. Windows service accounts are **gMSA-first** (`svc-gmsa-<purpose>`), falling back to sMSA/user only when a service can't use one (document why); the **KDS root key exists** (prereq ✅). **Applies to:** SW01, 1941 (scrypt); service accounts (gMSA). **Owner docs:** the [`CIS-Hardening-*`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) baselines + [DC `Build-Checklist` §7](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md). **Status:** scrypt ✅; gMSA ⬜ per-service (KDS key ✅).

### R6 — Privileged & remote auth is strengthened (target)

Privileged/remote authentication is tightened beyond a password — today via **tiering + Protected Users + the PAW** (`STD-0002`). **📋 Gap:** no **MFA** control is built yet; the planned home is **Entra Conditional Access** once hybrid identity lands ([`ADR-0040`](../Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md), Phase H1). FGT01 admin auth is direct-LDAPS with **no FortiToken** today ([`ADR-0028`](../Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md)). Marked honestly as the standing target, not a current ✅.

---

## Adopting & amending decisions

The dated trail (kept, never deleted; originals in the legacy snapshot).

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) | Accepted | the tiered-identity model — per-tier accounts, Protected Users (R4) |
| [`ADR-0028`](../Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md) | Accepted | FGT01 admin auth via LDAPS (R6 — the no-MFA reality) |
| [`ADR-0040`](../Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md) | Accepted | Entra PHS → the planned Conditional-Access/MFA home (R6) |
| the `CIS-Hardening-*` baselines | in force (`POL-0007`) | Type-9 scrypt device secrets, device-verified (R5) |

## Verification (how conformance is proven)

Real read-backs — the [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit runs these; the device wins over the doc (Charter Rule 13).

- [x] **R1** — the recorded passphrase opens the key: `openssl rsa -in <ca-key> -noout` → `RSA key ok` (`049`); ASCII-only by inspection.
- [x] **R2** — `Get-ADFineGrainedPasswordPolicy PSO-FinanceHR` → precedence 10, minPasswordLength 15, lockoutThreshold 3 (✅ built; RSOP on a real user pending Stage 8).
- [x] **R3** — `Get-LapsADPassword -Identity DC01 -AsPlainText` returns a managed value; DSRM under LAPS.
- [x] **R4** — `Get-ADGroupMember "Protected Users"` includes `t0-seth`; `whoami /groups` on each admin shows its tier only.
- [x] **R5** — `show run | include secret 9` → `secret 9 $9$…` (SW01/1941); `Get-KdsRootKey` present; `Test-ADServiceAccount <svc>` → True (per gMSA when built).
- [ ] **R6** — 📋 Conditional-Access/MFA policy exists (gated on Entra, Phase H1).
- [ ] **Meta** — any change to a value here traces to an amending ADR + a Change Log row.

> Markers are honest (`POL-0006`): R1–R5 are built/✅ where a read-back exists; R6 (MFA) is a 📋 target, not a claim.

## Learn it — the Academy (the source of truth for the *why* + the commands)

- 🎓 **Concept (why it works):** [The Credential Layer — PSOs, LAPS & gMSA](../../Atlas-Academy/Concepts/The-Credential-Layer-PSOs-LAPS-and-gMSA.md) (the credential mechanics this standard sets) · [Tiered-Admin Model](../../Atlas-Academy/Concepts/Tiered-Admin-Model.md) (why a Tier-0 credential must never touch a lower tier) · [Concepts index](../../Atlas-Academy/Concepts/)
- 🖥️ **Commands (run the read-backs):** [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) (`Get-ADFineGrainedPasswordPolicy`, `Get-LapsADPassword`, `Get-ADGroupMember`) · [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) (`show run | include secret 9`)
- 🏅 **Cert objective:** [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (identity/PSO/LAPS/gMSA) · [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (5.1)
- 📋 **Security program:** [Security Awareness](../Security-Program/Security-Awareness-Program.md) (passphrase hygiene, the human layer) · [Compliance Program](../Security-Program/Atlas-Compliance-Program.md) (the control mapping)

## What a violation looks like

A shared/reused password · a `£`/non-ASCII CA passphrase · Finance/HR on the domain baseline instead of `PSO-FinanceHR` · a local admin password *not* under LAPS · admining a DC with the `seth` daily account · `t0-seth` **absent** from Protected Users · a Type-7/Type-5 IOS secret.

## Related

[`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md) (governing) · [`STD-0002`](./STD-0002-Access-Control.md) (what these accounts may do) · [`STD-0004`](./STD-0004-Encryption.md) (how secrets are hashed) · [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) · the DC [`Build-Checklist`](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 2.1 | 2026-08-04. **Learn-it:** added the new dedicated why-layer Concept [`The Credential Layer — PSOs, LAPS & gMSA`](../../Atlas-Academy/Concepts/The-Credential-Layer-PSOs-LAPS-and-gMSA.md) (the credential mechanics — PSO/LAPS/gMSA/ASCII passphrases — that `Tiered-Admin-Model` doesn't cover). No normative change to any requirement. |
| 2.0 | 2026-08-03. **Rewrote the thin v1.0 into an estate-grounded, testable standard** (#39/#42): the real `PSO-FinanceHR` (prec 10 / len 15 / lockout 3), Windows LAPS on the `Devices` OU + DSRM, the `t0/t1/t2-seth` tier accounts + Protected Users, Type-9 scrypt device secrets, gMSA-first, and the honest MFA gap — each with a read-back and honest markers, plus the **Learn it (Academy)** source-of-truth section and explicit feeds/fed-by links. Cut from `STD-Template`. |
| 1.0 | 2026-07-22. Thin Standard — named the requirement for Security+ 5.1; added no new control. (Superseded by v2.0.) |
