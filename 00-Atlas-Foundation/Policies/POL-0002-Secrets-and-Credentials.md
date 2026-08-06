---
Title: POL-0002 — Secrets & Credentials Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force.
Version: 2.0
---

# POL-0002 — Secrets & Credentials

> **At a glance.** No secret is ever committed to git. Secrets live in the vault, are rotated the moment they are exposed, and are redacted — not bypassed — in documentation. A secret in the wrong place is *burned, not hidden*: rotation, not deletion, is the first move. This policy folds the estate's hardest-won secrets lessons into citable requirements (`POL-0002 R1`…) and doubles as a directory of the decisions that govern secrets (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the Standards, ADRs, Changes, and Procedures beneath it |
| Requirement, in one line | No secret in git; secrets vaulted, rotated on exposure (+ copies destroyed), redacted not bypassed in docs; a backup that captures a secret carries a destroy step. |
| Owner | 🔴 Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (adopts the framework) — elevating the buried rule (`018` line 29) that `CM-0014`/`CM-0019`/`CM-0023` violated |
| Builds on | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) (how this gets checked) · [`POL-0006`](./POL-0006-Evidence-and-Verification.md) (prove the removal) |
| Governs the standard | [`STD-0004` Encryption](../Standards/STD-0004-Encryption.md) R2/R5 (how secrets are hashed + CA key custody) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 `PR.AA` / `PR.DS` · CIS Controls v8 **3** (Data Protection) · Security+ 3.x |

---

## Scope & applicability

Governs every reusable secret in the estate — passwords, passphrases, API tokens, private keys, RADIUS/SNMP shared secrets, vault contents — and every act that stores, moves, documents, or retires one. When unsure whether something is a secret, treat it as one.

**Boundary with [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md):** POL-0011 classifies *what data is sensitive* and its handling; POL-0002 governs *credentials specifically* — the reusable secrets that grant access. **Boundary with [`STD-0004`](../Standards/STD-0004-Encryption.md):** STD-0004 is *how* a secret is encrypted/hashed at rest (the algorithm); POL-0002 is *that* it is never exposed and how it's handled.

## Why this is a policy, not a note

The rule already existed, **buried in a Standards document** (`018` line 29), un-enumerable — and was **violated by the very commit that shipped the runbook forbidding it** (`CM-0014`). A rule that is not enumerable is not auditable, and this one cost real incidents: `CM-0014` (archive passphrase in git — a `.txt` the extension-based `.gitignore` and the default content scanner both missed), `CM-0019` (a secret-shaped `.txt` in the backup dir), `CM-0023` (a live cleartext SNMP community), and the `ADR-0009` convergence (key + passphrase on one workstation for 15 hours **because a backup procedure had no destroy step**). Raising it to a policy makes it findable, ownable, and checkable.

---

## The standing requirements

Each is citable as `POL-0002 R#`.

### R1 — What counts as a secret (and the default)

A **secret** is anything reusable to gain access: passwords, passphrases, API tokens, private keys, RADIUS/SNMP shared secrets, vault contents. **When unsure, treat it as one.** A passphrase is composed **length-first, ASCII-only** — entropy from length, not from glyphs that break a rescue console ([`STD-0001` R1](../Standards/STD-0001-Password-and-Authentication.md); the `£`-that-broke-recovery lesson).

### R2 — Never in git, and the control is mechanical

No secret in a doc, a script, a `.txt` beside a backup, or a commit "to be fixed later." The `.gitignore` and the **`gitleaks` CI check** are guards, not the policy — and because a bare high-entropy passphrase **has no shape**, the guard includes a **name-based rule** (`.gitleaks.toml`), since the content scanner provably missed the real file (`CM-0014`). Never `git add .`; verify a removal by **counting the old string to zero** (Charter Rule 16), not by appending a redaction.

### R3 — Vaulted; a doc names where, never the value

Secrets live in **Vaultwarden**. Documentation *names where* a secret is stored; it **never contains one that still works** (Charter). A *dead* value may be kept, named, as a lesson.

### R4 — Rotate on exposure — and rotation is not the whole remedy

Rotating changes the wrapper on the live key; **it does not un-expose a copy that already existed** ([`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md)). So exposure also requires: **find and destroy every copy** (a Phase-0 inventory — the second copy on `E:` in `CM-0014`), and **assess blast radius**. Rotation is the *first* move because it's the only remedy that needs no one else's cooperation; the purge is cleanup after.

### R5 — A backup that captures a secret carries a destroy step

Any procedure that copies secret material names, **in the same procedure, who removes the copy and when** ([`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md)'s missing-destroy-step lesson). Decrypt/verify crown-jewel archives **on a local, air-gapped box — never in a cloud session**; the passphrase that opens a backup lives on **paper**, off-site, never with the media ([`STD-0004` R5](../Standards/STD-0004-Encryption.md)).

### R6 — Redact, don't bypass, in docs

A Build Guide never contains a value you'd type; a Build Record may name a value that no longer works. Redacting a *live* value and rotating it is the fix; deleting a *deleted-credential lesson* is not — keep the dead value as the lesson, remove only the instruction to create it.

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0002 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0009 — Intermediate CA Not Treated as Compromised](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) | Proposed | POL-0009 (+POL-0002) |
<!-- END AUTOGEN:decisions POL-0002 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. No standing rule changes by editing this policy silently.

- **To change a rule, an ADR amends it** — it carries `Governing Policy: POL-0002`, states *"amends `POL-0002` R#"*, and this policy's Change Log gains a row ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)).
- **Preserve, never delete** ([`ADR-0012`](../Decisions/ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md)); the pre-reconciliation set is frozen in the legacy snapshot. Historical `CM-####` citations of a now-dead secret stay exactly as written (the `CM-0014` audit trail; no value reproduced).

## Verification (how compliance is proven)

One check per requirement — the [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit runs this list.

- [ ] **R1** — passphrases are ASCII, length-first, unique; the CA uses separate Root/Issuing passphrases.
- [ ] **R2** — `gitleaks` CI (content **+** the name-based rule) passes on every push; a `git grep` of a removed secret's old form returns 0; no `git add .` in the commit path.
- [ ] **R3** — no working value appears in any doc; the vault holds it; a doc that names a secret names only its *location*.
- [ ] **R4** — every exposure has, dated in a Change Record, the **rotation** *and* the **copy-destruction** (with a Phase-0 inventory) *and* the **blast-radius** note.
- [ ] **R5** — secret-bearing backups show the destroy step + the local-only decrypt; the passphrase has an off-site paper copy; a pre-archive `ls` / post-archive `tar -tzf` proves nothing rode along.
- [ ] **R6** — no live value in a Build Guide; a redaction never coexists with the live value elsewhere in the file.
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

A passphrase in a commit · a private key in a tarball on the workstation · an SNMP/RADIUS secret typed into a guide · a rotation with no search for pre-rotation copies · a backup that captures a key with no destroy step · a crown-jewel archive decrypted on a networked/cloud box · a redaction appended while the live value still appears elsewhere.

## Related

[`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md) · [`STD-0004` Encryption](../Standards/STD-0004-Encryption.md) (governed standard) · [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) · [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md) · [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) · [`ADR-0010`](../Decisions/ADR-0010-Atlas-Repository-Publication-Preconditions.md) (the publication precondition) · the [Security-Program & Compliance directory](../../Atlas-Academy/Directory/Security-Program-and-Compliance.md) · the legacy snapshot.

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [Secrets & Credential Custody](../../Atlas-Academy/Concepts/Secrets-and-Credential-Custody.md) (a secret in the wrong place is burned, not hidden; rotate-not-delete; a shapeless passphrase defeats a content scanner — the `CM-0014`/`CM-0010` scars) · [Encryption & PKI in Atlas](../../Atlas-Academy/Concepts/Encryption-and-PKI-in-Atlas.md) (what the vaulted CA keys protect).
- 🖥️ **Commands:** [Linux](../../Atlas-Academy/Command-Library/Linux.md) (`gpg`, `shred`, `git filter-repo`) · [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md).
- 🔧 **Playbooks:** [Respond-to-a-Committed-Secret](../../Atlas-Academy/Playbooks/Respond-to-a-Committed-Secret.md) · [Rotate-a-Leaked-Key-Before-You-Back-It-Up](../../Atlas-Academy/Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md).
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First written form of the referenced-but-missing `POL-0002` (never-in-git · vaulted · rotate-on-exposure · destroy-step · redact-not-bypass). |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the requirement-in-detail distilled into citable `R1–R6`; the boundary with `POL-0011`/`STD-0004`; the amendment model; per-`R#` Verification; a **Learn it (Academy)** section pointing at the now-built [`Secrets & Credential Custody`](../../Atlas-Academy/Concepts/Secrets-and-Credential-Custody.md) concept; status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
