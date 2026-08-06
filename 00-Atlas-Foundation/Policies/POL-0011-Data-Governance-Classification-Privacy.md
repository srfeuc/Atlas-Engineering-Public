---
Title: POL-0011 — Data Governance, Classification & Privacy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force. Extends 305's classification with roles, privacy, and retention.
Version: 2.0
---

# POL-0011 — Data Governance, Classification & Privacy

> **At a glance.** Every piece of Atlas data has a named **owner**, a **classification**, and **handling rules that follow it everywhere it goes** — and personal data additionally carries privacy obligations (lawful basis, retention limit, the data subject's rights). This policy folds data governance into citable requirements (`POL-0011 R1`…), carries the classification + roles reference tables, and doubles as a directory of the decisions that govern data (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the Standards, ADRs, and Changes beneath it |
| Requirement, in one line | Every data set has an owner, a class, and class-based handling; personal data carries privacy obligations; a data inventory + retention exist. |
| Owner | 🔴 Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)); **data owners** are the department heads (`301`) |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) — elevating `305` Part 1 (classification) with roles + privacy |
| Builds on | [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) (secrets = the top data class) · [`POL-0005`](./POL-0005-Backup-and-Recovery.md) (retention of backups) · [`POL-0010`](./POL-0010-Acceptable-Use.md) (users protect the class they touch) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 **GV.RR / ID.AM / PR.DS** · CIS Controls v8 **3** · Security+ SY0-701 **3.3, 5.1, 5.4** |

---

## Scope & applicability

Governs every data set in the estate — its owner, class, handling, retention, and (for personal data) privacy obligations.

**Boundary with [`POL-0002`](./POL-0002-Secrets-and-Credentials.md):** secrets are the *top data class* — POL-0002 owns their specific handling; POL-0011 owns *all* data classification and the roles/privacy layers. **Boundary with `305`:** `305` originated the four-level classification as the firewall-matrix input; POL-0011 makes it standing and adds the two layers `305` didn't — **roles** and **privacy**.

## Why this is a policy, not a note

`305` proved you can't write a firewall rule until you've classified what's on the server tier — but the classification lived only as the matrix input. This policy makes it standing and adds *who owns/handles each class* (5.1 roles) and *the privacy rules for personal data* (5.4). Without them, `svc-scanner` (Restricted access on a sticky-note password), the five ghosts (personal data with no retention/deletion), and the order portal (regulated cardholder data) are ungoverned.

---

## The standing requirements

Each is citable as `POL-0011 R#`.

### R1 — Every data set has an owner and a classification

Restricted / Confidential / Internal / Public (the `305` four-level scheme, reference table below); the **data owner** (the department head) sets the class and who may access. Format is not classification — `NTDS.dit` and the CA key are *non-human-readable* and the **most** Restricted things Atlas holds.

### R2 — Handling rules follow the class everywhere

Encryption at rest + in transit, media rules, access-by-named-role, and destruction are set **by class** and travel with the data — to a laptop, a share, a backup ([`POL-0005`](./POL-0005-Backup-and-Recovery.md)), or a chat ([`POL-0002`](./POL-0002-Secrets-and-Credentials.md)/[`POL-0010`](./POL-0010-Acceptable-Use.md)). See the handling column of the classification table.

### R3 — Owner ≠ custodian; custody may not exceed the owner's intent

The **data owner** (accountable, sets class) is distinct from the **custodian** (IT/DBA, implements controls). When IT granted `svc-scanner` CFO-level share access the owner never sanctioned, **custody overstepped intent** — an access-governance finding, not just a password one. (Roles reference table below; controller/processor for privacy.)

### R4 — Personal data carries privacy obligations

A **data subject** has rights: **erasure** ("right to be forgotten") — you must be *able* to find and delete a person's data (requires the inventory in R5 + offboarding), balanced against **legal retention holds** (you can't delete records tax law requires). Atlas is a **controller** for staff/customer PII, a **processor** when running an MSP tenant (act only on documented instructions — DPAs). Legal scope is not just local: one online **EU** order pulls the portal into **GDPR** (lawful basis, breach-notification windows).

### R5 — A data inventory and retention exist

Maintain a **data inventory** (what personal/regulated data exists, where, its class, its owner, its retention) — the `AtlasHR` DB + the gap-report query is the seed. Each class gets a **retention limit** and disposal rule: cardholder data minimized/tokenized (PCI: don't store what you don't need); payroll kept per tax law then destroyed; ex-employee PII deleted on schedule unless under hold.

---

## Reference — the classification scheme (`305`, reconciled to Security+ 3.3)

| Atlas label (`305`) | Exam synonyms | Examples | Handling (storage / transit / media / destruction) |
|---|---|---|---|
| **Restricted** | Sensitive, Private, Critical | CA keys, `NTDS.dit`, cardholder data, payroll/PII | Encrypted at rest + in transit; **vaulted** secrets ([`POL-0002`](./POL-0002-Secrets-and-Credentials.md)); no removable media without approval; named-role access, logged; crypto-shred on destruction |
| **Confidential** | Sensitive, Proprietary | AtlasERP, CAD/IP, `AtlasHR` | Encrypted where feasible; dept + app-tier only; approved media; secure wipe |
| **Internal** | Internal use only | General shares, intranet, print | Staff-wide; no external sharing; standard disposal |
| **Public** | Public | Order-portal marketing front end | No restriction; integrity still matters |

> **"Critical" is an *availability* label, not a confidentiality one** — AtlasERP and the OT line are Critical-for-availability even though their confidentiality class differs; the BIA ([`POL-0012`](./POL-0012-Risk-Management.md)) tiers by criticality separately. **Roles (5.1):** owner (dept head) · controller (Atlas Industrial) · processor (payment processor / an MSP tenant) · custodian (IT/DBA).

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0011 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0010 — Atlas Repository Publication and Its Preconditions](../Decisions/ADR-0010-Atlas-Repository-Publication-Preconditions.md) | Accepted | POL-0011 (+POL-0010) |
| [ADR-0050 — FGT01 TLS/SSL Deep-Inspection Scope + ICA01 Inspection-CA…](../Decisions/ADR-0050-FGT01-TLS-Deep-Inspection-Scope-and-ICA01-Inspection-CA.md) | Accepted (operator, 2026-07-30) — the K1 disposition reco… | POL-0011 (+POL-0007) |
<!-- END AUTOGEN:decisions POL-0011 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. To change a rule, an ADR carries `Governing Policy: POL-0011`, states *"amends `POL-0011` R#"*, and a Change Log row is added ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)); preserved, never deleted (legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — every Restricted/Confidential data set has a named owner + a class label.
- [ ] **R2** — handling rules are enforced by class (encryption, media, access, destruction) — spot-checked in audits.
- [ ] **R3** — no custody exceeds the owner's intent (`svc-scanner`-style); access grants trace to the owner's sanction.
- [ ] **R4** — processor relationships have a contract instructing them; erasure requests can be fulfilled.
- [ ] **R5** — a data inventory exists; retention/disposal runs on schedule.
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

Restricted data on an unapproved USB/personal cloud · a data set with no owner · `svc-scanner`-style custody exceeding the owner's intent · personal data kept forever with no retention or ability to delete · treating "non-human-readable" (a DB, a key) as unclassified · taking an EU order with no privacy basis.

## Related

`305` (classification origin) · `301` (owners, the data, the ghosts) · [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) · [`POL-0005`](./POL-0005-Backup-and-Recovery.md) · [`POL-0009`](./POL-0009-Incident-Response.md) (a data breach) · [`Third-Party-Risk-Management`](../Security-Program/Third-Party-Risk-Management.md) (processors/DPAs) · [`POL-0012`](./POL-0012-Risk-Management.md) (data-loss risks) · the [Security-Program & Compliance directory](../../Atlas-Academy/Directory/Security-Program-and-Compliance.md).

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [Encryption & PKI in Atlas](../../Atlas-Academy/Concepts/Encryption-and-PKI-in-Atlas.md) (what protection a data class demands — encryption at rest/in transit, the CA that issues the certs) · [Secrets & Credential Custody](../../Atlas-Academy/Concepts/Secrets-and-Credential-Custody.md) (the top data class).
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (3.3 data types · 5.1 roles · 5.4 privacy).
- 📋 **Security program:** [Compliance Program](../Security-Program/Atlas-Compliance-Program.md) · [Third-Party-Risk-Management](../Security-Program/Third-Party-Risk-Management.md) (DPAs).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First data-governance policy — data types (3.3), the 4-level classification + Critical=availability axis, owner/controller/processor/custodian roles (5.1), privacy (5.4: erasure vs retention, data inventory, local→global scope). |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the rules distilled into citable `R1–R5` with the classification + roles kept as this policy's reference content (compacted); boundaries with `POL-0002`/`305`; the amendment model; per-`R#` Verification; a **Learn it (Academy)** section (Encryption-PKI / Secrets concepts); status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
