---
Title: Atlas Governance Framework — How Atlas Governs Itself
Path: 00-Atlas-Foundation/Governance
Status: ✅ Adopted by `ADR-0026` — recorded 2026-07-17, operator-confirmed (`ADR-0026` → Accepted) 2026-08-03. In force.
Version: 2.0
---

# Atlas Governance Framework — How Atlas Governs Itself

> 🧭 **Read this first.** This is the front door to how Atlas governs itself. If you want to know *what the standing rules are*, *how a decision becomes a rule*, or *where to go to change something* — start here, then follow the map below. Everything else in `Governance/` (and in `Policies/`, `Decisions/`, `Standards/`) hangs off the model on this page.

## The `Governance/` folder — what's here, in read order

| # | Document | What it's for |
|---|---|---|
| 1 | **`Atlas-Governance-Framework.md`** *(this page)* | The model — the hierarchy, the shape of a policy, how decisions become amendments, the audit process. **Start here.** |
| 2 | [`../Policies/`](../Policies/) | The **standing rules** (`POL-xxxx`) — what must always be true. Each is a rule + a directory to the decisions behind it. |
| 3 | [`../Decisions/ADR-Index.md`](../Decisions/ADR-Index.md) | Every **decision** (`ADR-xxxx`), each naming its `Governing Policy:`. |
| 4 | [`Atlas-Change-Management-Process.md`](./Atlas-Change-Management-Process.md) | How a **change** is raised, recorded, and closed (`POL-0003` in practice). |
| 5 | [`Atlas-Workflow.md`](./Atlas-Workflow.md) | The write → verify → publish → freeze working loop. |
| 6 | [`Governance-Reconciliation-Triage.md`](./Governance-Reconciliation-Triage.md) | The working list behind `ADR-0054` — per-ADR disposition for the ongoing reconciliation. |

---

## 0. What this document grounds

Atlas has decisions (ADRs), standards, changes, and procedures. This framework is the layer **above** them: the standing requirements they must all conform to, and the rules for how that layer is written, cited, changed, and kept current. One page, one model, everything grounded in it:

- **The hierarchy** — which layer wins when two conflict (§1).
- **The Policy Register** — the small, enumerable set of standing rules (§2).
- **What a policy looks like** — the shape every policy takes (§3).
- **The generated Decisions directory** — how a policy always knows which decisions serve it (§4).
- **Decisions as amendments** — how a rule changes without ever being edited silently (§5).
- **Findability** — the point of it all: anyone can find the rule for their situation, fast (§6).
- **The audit process** — the standing control that keeps the estate honest (§7).
- **Keeping it live** — the rule that stops any of this from going stale (§8).

## 1. The hierarchy (top governs bottom)

| Layer | What it is | Changes… | Example |
|---|---|---|---|
| **Charter** | The constitution — the locked meta-rules about how Atlas itself operates | Almost never | Rule 13 (evidence precedence), Rule 16 (learning) |
| 🔴 **Policy (`POL-xxxx`)** | A **standing requirement** — what must always be true. Vendor- and lab-agnostic. | Rarely, by a deliberate act (an ADR that adopts/amends it) | "No secret is ever committed to git." |
| **Standard (`STD-xxxx`)** | *How* a policy is met — specific, technical, testable | When technology/design changes | "Certs are signed with `openssl ca`, never `x509 -req`." |
| **ADR (`ADR-xxxx`)** | A **point-in-time decision**, chosen among options, that **must conform to policy** | Superseded/amended by a later ADR | "Keep FGT01 `srcaddr all` until redundancy exists." |
| **Change (`CM/MC`)** | An **implementation** on a specific date | Closed, not changed | "Disable MKT01 ether5-13." |
| **Procedure / Runbook** | *How to perform a task* | As the task evolves | "035 — issue a certificate." |

> **Precedence, plainly:** a Change may not violate an ADR; an ADR may not violate a Standard; a Standard may not violate a Policy; a Policy may not violate the Charter. **When two conflict, the higher layer wins — and the lower one is the defect.**
>
> 🔴 Orthogonal to Charter Rule 13 (evidence precedence: device > record > guide > status-field). Rule 13 says *which observation to believe*; this hierarchy says *which requirement to obey*.

## 2. The Policy Register

The core standing rules. Kept **small and defect-earned** — a policy is added only when a real defect proves one was missing.

| ID | Policy | Requirement (one line) |
|---|---|---|
| [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) | **Audit** | Atlas audits itself on a defined cadence; a claim requires a command and its output (`R-A1`). |
| [`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md) | **Secrets & Credentials** | No secret is ever committed to git; secrets are vaulted, rotated on exposure, redacted (not bypassed) in docs. |
| [`POL-0003`](../Policies/POL-0003-Change-Control.md) | **Change Control** | A silo-crossing change needs a Change Record; a correction counts the OLD text to zero (`R1`) and reaches the doc that does the work (`R2`); nothing closes without a read-back. |
| [`POL-0004`](../Policies/POL-0004-Source-of-Truth.md) | **Source of Truth** | One SoT per fact (target NetBox), generated not hand-typed; the device outranks the document (Rule 13). |
| [`POL-0005`](../Policies/POL-0005-Backup-and-Recovery.md) | **Backup & Recovery** | 3-2-1; a backup is not a backup until a Game Day restores it. |
| [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) | **Evidence & Verification** | Every build/change ends with a read-back; a clean command is not a correct artefact — check the wire *and* the file. |
| [`POL-0007`](../Policies/POL-0007-Hardening-Baseline.md) | **Hardening Baseline** | Every device meets a named CIS-informed baseline; unused interfaces disabled, kept-enabled ones justified. |
| [`POL-0008`](../Policies/POL-0008-Naming-and-Addressing.md) | **Naming & Addressing** | One addressing plan, consistent naming, no pre-VLAN/flat fossils presented as current. |
| [`POL-0009`](../Policies/POL-0009-Incident-Response.md) | **Incident Response** | Every suspected incident runs a defined lifecycle and closes with a lesson that reaches the working doc. |
| [`POL-0010`](../Policies/POL-0010-Acceptable-Use.md) | **Acceptable Use** | Authorized use only; each user accountable; no informal exceptions. |
| [`POL-0011`](../Policies/POL-0011-Data-Governance-Classification-Privacy.md) | **Data Governance & Privacy** | Every data set has an owner, a class, and handling rules; personal data carries privacy obligations. |
| [`POL-0012`](../Policies/POL-0012-Risk-Management.md) | **Risk Management** | Identify/assess/treat/review; an accepted risk carries an owner and a reversal trigger. |
| [`POL-0013`](../Policies/POL-0013-Business-Continuity.md) | **Business Continuity** | Critical functions keep running or degrade knowingly; the plan is written and tested. |
| [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) | **Documentation & Knowledge Management** | One fact one home; preserved not deleted; authored from evidence not invented; the Documentation Standard is binding. |
| [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) | **Engineering & Build Discipline** | One test-gated unit at a time; phased, dependency-gated build-guides; automation per the IaC model. |
| [`POL-0016`](../Policies/POL-0016-Realism-and-Learning.md) | **Realism & Learning** | Build to the real enterprise model; certifications anchor the skills; drills test what's documented. |

> **Standards register (12 `STD-####` — the *How* under a Policy; full list: [`Standards/README`](../Standards/README.md)):** security — `STD-0001` Password/Auth · `STD-0002` Access Control · `STD-0003` Physical/OOB · `STD-0004` Encryption (estate-grounded, v2.0); documentation — `STD-0005`–`0009` (device-docs · Academy · diagnostics · ADR-governance · session/handoff); build — `STD-0010`–`0012` (test-gated · Build-Guides · Automation/IaC).
>
> **Owed as the lab grows** (write when a defect earns it): **Access & AAA** · **Logging & Time** · **PKI & Trust**. Keep the core set small.

## 3. What a policy looks like (the golden shape)

Every policy is **a standing rule + a directory to the decisions behind it** — and it reads like something you'd open daily, not a compliance artifact. Cut every new or refolded policy from [`Templates/POL-Template.md`](../Templates/POL-Template.md). The required shape:

- **At a glance** — the rule in one or two scannable lines.
- **Metadata** — layer, one-line requirement, owner, adopting decision, what it builds on, how it's verified.
- **Scope & applicability** — including the **boundary** with any adjacent policy (so no two policies claim the same fact).
- **Citable requirements `R1…Rn`** — each a short rule, the decision(s) it comes from (linked), and a **quoted citation**.
- **Sources of truth** *(where the policy is about fact-ownership)* — a table naming the owner document for each kind of fact, marked *navigational, not authoritative*.
- **The generated Decisions directory** (§4).
- **The amendment model** (§5), **Verification** (checkboxes, one per `R#`), **What a violation looks like**, **Related**, **Change Log**.

**House style:** direct and engaging. Short lines, bullets, checkboxes, and the real war-story *why* up front. A policy nobody wants to read is a policy nobody follows.

## 4. The generated Decisions directory

Every ADR carries one line — `Governing Policy: POL-xxxx` — naming the standing requirement it serves or amends. From those lines, each policy's **"Decisions governed by this policy"** table is **generated** by [`tools/Build-Policy-Directories.ps1`](../../tools/Build-Policy-Directories.ps1) between `AUTOGEN` markers.

- It is **generated, never hand-typed** — this is `POL-0004` applied to governance itself: the directory can't drift, and can't look "slapped together."
- Ask *"which decisions serve the Secrets policy?"* → it's the directory, always current.
- Add a decision, add its `Governing Policy:` line, re-run the builder — the directory rebuilds.

## 5. Decisions become amendments (integrated change control)

A policy holds the **current** rule; the ADRs behind it are the **dated trail** of how it got there. This is the PM baseline-and-change-request model (`ADR-0054`): the baseline is never edited silently.

- **To change a rule, an ADR amends it** — carries `Governing Policy: POL-xxxx`, says *"amends POL-xxxx R#"*, and the policy's Change Log gains a row.
- **Three dispositions** when reconciling an ADR to the layer (`ADR-0054` §3):
  - **(A) Decision** — a genuine chose-X-over-Y. *Add the `Governing Policy:` line; otherwise leave as-is.* (The majority.)
  - **(B) Standard-in-effect** — defines *how*, estate-wide + testable. *Recognise in place + a "Doc-type: Standard-in-effect" note. No renumber.*
  - **(C) Policy-shaped** — a standing rule wearing an ADR's clothes. *Promote the rule into its policy; keep the ADR, re-scoped as the decision that adopted it.*
- **Preserve, never delete** (`ADR-0012`). A promoted or superseded ADR is kept; its original text is frozen in the dated **legacy ADR snapshot** (`99-Archive/Legacy-ADRs-YYYY-MM-DD/`).

## 6. Findability — the point of all this

A **small, enumerable** rule set exists so that *anyone in a situation can find the rule or decision that governs it, and act — fast, self-service, without going through a manager.* The mechanism:

- **The Foundation front door is a situation router** — *"you're doing X / you're role Y → here is the policy, ADR, checklist, or template that governs it."* (Not a policy — it's how the Foundation is framed.)
- **The policies are the destinations** — each a rule + its generated Decisions directory.
- **The registers ground the data** — the written `Network-Source-of-Truth` + `Server-Source-of-Truth` (the NetBox seed), governed by `POL-0004`.

Engineers first, everyone eventually. This model is also the intended backbone of a future published Atlas site.

## 7. The audit process

Atlas's central recurring defect is *"the document disagrees with the device."* The audit is the standing control against it.

- **Cadence:** 🔴 a **freeze audit** gates any "done"/frozen lab (mandatory); **reconcile-to-live** periodically; a **triggered audit** after an incident, a role change, or an Oxidized drift; **continuous** once Oxidized runs.
- **Method (normative):** device > record > guide > status-field (Rule 13) · a finding needs a command + its output · verify a fix by counting the OLD text to zero (`R1`) · fix the doc that does the work first (`R2`) · read the artefact back — wire *and* file · read-only first, writes become change records.
- **Evidence store:** the per-device Verification Procedure + Considerations & Risks pages, the Divergence Register, and the triggered Change Records.
- **Sign-off (owner: Security silo, `ADR-0018`):** every Verification page 🟢 (or its gaps recorded), every triggered change closed with a read-back, the Divergence Register empty or every item a dated accepted risk.

## 8. Keeping it live — the currency rule

Governance is only trustworthy if it's current. **After every governance page (a policy folded, an ADR added or re-scoped), the working session must:**

- [ ] **Regenerate** the affected policy Decisions directories (run the builder).
- [ ] **Refresh `AI-Context/`** where structure or governance changed (`ADR-0052`) — pointers, not copies.
- [ ] **Log to the Backlog** (`Roadmap/Atlas-Improvement-Backlog.md`) — the operator's primary dashboard.
- [ ] **Update the SESSION-HANDOFF** `📍 CURRENT STATE` block.

"Done" isn't done until it's generated, grounded, and logged.

## 9. How this plugs into what exists

- **ADRs** gain the `Governing Policy:` line and populate the policy directories.
- **The Charter** keeps the meta-rules; where a locked rule is really a standing estate requirement, the policy layer *references* it rather than duplicating it.
- **The Foundation front door** routes by situation into this layer.

## Adoption status

- ✅ **Adopted.** Recorded 2026-07-17; **operator-confirmed 2026-08-03** (`ADR-0026` → Accepted), closing the prior Proposed/adopted status gap.
- 🔄 **Reconciliation executing** (Backlog #39, per `ADR-0054` / [`Governance-Reconciliation-Triage.md`](./Governance-Reconciliation-Triage.md)): `Governing Policy:` backfill across the ADR set; `POL-0014`/`POL-0015`/`POL-0016` folded to the golden shape; policy-shaped ADRs promoted; the legacy snapshot frozen first.

## Related pages

[`Atlas-Charter.md`](Atlas-Charter.md) · [`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) (silos) · [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (adopts this framework) · [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md) (the reconciliation) · [`Templates/POL-Template.md`](../Templates/POL-Template.md) · [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) (the seed).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-16. Proposed the hierarchy, the core Policy Register, the audit process, the adoption path. |
| 1.1 | 2026-07-17. Recorded as adopted by `ADR-0026`; register numbering confirmed authoritative; `POL-0002`/`POL-0004` drafted; `POL-0001` adopted. |
| 2.0 | 2026-08-03. **Reframed as the grounding doc + the `Governance/` front door** (read-first + folder map). Operator-confirmed the `ADR-0026` adoption (closed the status gap). Added: **§3 the golden policy shape** (+ the template), **§4 the generated Decisions directory**, **§5 the amendment / A-B-C reconciliation model**, **§6 findability (Foundation-as-router)**, **§8 the currency rule**. Register extended to `POL-0014`–`POL-0016`. |
