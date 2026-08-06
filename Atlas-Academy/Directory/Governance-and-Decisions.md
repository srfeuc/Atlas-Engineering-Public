---
Title: Governance and Decisions — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §9. How Atlas governs itself: the hierarchy, the registers, and how a rule changes without ever being edited silently.
Version: 0.1
Date: 2026-08-04
---

# Governance and Decisions — Full Directory

> **The deep version of [Source-of-Truth §9](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#9-governance-and-decisions).** The router gives you the one-glance answer — *where's the rule for X?* This page is the *encyclopedia*: the layer hierarchy, the full Policy and Standard registers, how a decision becomes a rule, and how the estate keeps 54 ADRs navigable without losing a word. Keep the router in a tab for speed; come here when you want the whole model.
>
> How Atlas governs itself is grounded in [`Atlas-Governance-Framework`](../../00-Atlas-Foundation/Governance/Atlas-Governance-Framework.md) (the model + the `Governance/` front door); this page is its Academy twin — it *describes and links*, it doesn't restate (`POL-0004`).

## On this page

1. [The hierarchy](#1-the-hierarchy) — Charter → Policy → Standard → ADR → Change → Procedure
2. [The Policy register](#2-the-policy-register) — the 16 standing rules
3. [The Standards register](#3-the-standards-register) — the 12 concrete *hows*
4. [The decisions (ADRs)](#4-the-decisions-adrs) — the index + the navigator
5. [How a rule changes](#5-how-a-rule-changes) — the amendment model + generated directories
6. [Nothing is lost](#6-nothing-is-lost) — the legacy snapshot + the reconciliation
7. [The standing controls](#7-the-standing-controls) — audit + the currency rule
8. [Templates, tooling and the Academy](#8-templates-tooling-and-the-academy)

---

## 1. The hierarchy

Atlas governs itself with a strict precedence — the higher layer wins, and when two conflict the lower one is the defect ([`Atlas-Governance-Framework` §1](../../00-Atlas-Foundation/Governance/Atlas-Governance-Framework.md)).

| Layer | What it is | Changes… | Owner doc |
|---|---|---|---|
| **Charter** | The constitution — locked meta-rules about how Atlas operates (Rule 13 evidence precedence; Rule 16 learning) | Almost never | [`Atlas-Charter`](../../00-Atlas-Foundation/Governance/Atlas-Charter.md) |
| **Policy (`POL-####`)** | A standing requirement — what must always be true; vendor/lab-agnostic | Rarely, by an adopting/amending ADR | [`Policies/`](../../00-Atlas-Foundation/Policies/README.md) |
| **Standard (`STD-####`)** | *How* a policy is met — specific, technical, testable | When technology/design changes | [`Standards/`](../../00-Atlas-Foundation/Standards/README.md) |
| **ADR (`ADR-####`)** | A point-in-time decision, chosen among options, that must conform to policy | Superseded/amended by a later ADR | [`ADR-Index`](../../00-Atlas-Foundation/Decisions/ADR-Index.md) |
| **Change (`CM`/`MC`)** | An implementation on a specific date | Closed, not changed | each device's `Changes/` |
| **Procedure / Runbook** | *How to perform a task* | As the task evolves | `Operations/` runbooks |

> **Precedence, plainly:** a Change may not violate an ADR; an ADR may not violate a Standard; a Standard may not violate a Policy; a Policy may not violate the Charter. This is orthogonal to Charter **Rule 13** (evidence precedence: *device > record > guide > status-field*) — Rule 13 says *which observation to believe*; the hierarchy says *which requirement to obey*.

## 2. The Policy register

The core standing rules — kept **small and defect-earned** (a policy is added only when a real defect proves one was missing). Full register + the ★ golden-shape marker: [`Policies/README`](../../00-Atlas-Foundation/Policies/README.md).

| Policy | Requirement (one line) | Academy why-layer |
|---|---|---|
| [`POL-0001`](../../00-Atlas-Foundation/Policies/POL-0001-Atlas-Audit-Policy.md) Audit | Audit on a cadence; a claim needs a command + its output | [A Completed Command Is Not Evidence](../Concepts/A-Completed-Command-Is-Not-Evidence.md) |
| [`POL-0002`](../../00-Atlas-Foundation/Policies/POL-0002-Secrets-and-Credentials.md) Secrets & Credentials | No secret in git; vaulted, rotated on exposure | [Secrets & Credential Custody](../Concepts/Secrets-and-Credential-Custody.md) |
| [`POL-0003`](../../00-Atlas-Foundation/Policies/POL-0003-Change-Control.md) Change Control | A silo-crossing change needs a record; nothing closes without a read-back | [A Completed Command Is Not Evidence](../Concepts/A-Completed-Command-Is-Not-Evidence.md) |
| [`POL-0004`](../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) Source of Truth ★ | One home per fact, generated not hand-typed; device outranks doc | — (the rule this page obeys) |
| [`POL-0005`](../../00-Atlas-Foundation/Policies/POL-0005-Backup-and-Recovery.md) Backup & Recovery | 3-2-1; not a backup until a restore proves it | [A Backup Is Not a Backup…](../Concepts/A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md) |
| [`POL-0006`](../../00-Atlas-Foundation/Policies/POL-0006-Evidence-and-Verification.md) Evidence & Verification | Every build/change ends with a read-back — wire *and* file | [A Completed Command Is Not Evidence](../Concepts/A-Completed-Command-Is-Not-Evidence.md) |
| [`POL-0007`](../../00-Atlas-Foundation/Policies/POL-0007-Hardening-Baseline.md) Hardening Baseline | A named CIS-informed baseline per device; unused interfaces disabled | [Hardening from a Tested Baseline](../Concepts/Hardening-from-a-Tested-Baseline.md) |
| [`POL-0008`](../../00-Atlas-Foundation/Policies/POL-0008-Naming-and-Addressing.md) Naming & Addressing | One addressing plan, consistent naming, no flat fossils as current | — |
| [`POL-0009`](../../00-Atlas-Foundation/Policies/POL-0009-Incident-Response.md) Incident Response | A defined lifecycle; closes with a lesson that reaches the working doc | [Risk as a Living Register](../Concepts/Risk-as-a-Living-Register.md) |
| [`POL-0010`](../../00-Atlas-Foundation/Policies/POL-0010-Acceptable-Use.md) Acceptable Use | Authorized use only; each user accountable; no informal exceptions | [Tiered-Admin Model](../Concepts/Tiered-Admin-Model.md) |
| [`POL-0011`](../../00-Atlas-Foundation/Policies/POL-0011-Data-Governance-Classification-Privacy.md) Data Governance & Privacy | Every data set has an owner, a class, handling rules | [Encryption & PKI in Atlas](../Concepts/Encryption-and-PKI-in-Atlas.md) |
| [`POL-0012`](../../00-Atlas-Foundation/Policies/POL-0012-Risk-Management.md) Risk Management | Identify/assess/treat/review; an accepted risk carries an owner + a trigger | [Risk as a Living Register](../Concepts/Risk-as-a-Living-Register.md) |
| [`POL-0013`](../../00-Atlas-Foundation/Policies/POL-0013-Business-Continuity.md) Business Continuity | Critical functions keep running or degrade knowingly; written + tested | [A Backup Is Not a Backup…](../Concepts/A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md) |
| [`POL-0014`](../../00-Atlas-Foundation/Policies/POL-0014-Documentation-and-Knowledge-Management.md) Documentation & KM ★ | One fact one home; preserved not deleted; authored from evidence | — |
| [`POL-0015`](../../00-Atlas-Foundation/Policies/POL-0015-Engineering-and-Build-Discipline.md) Engineering & Build ★ | One test-gated unit at a time; phased build-guides; IaC | [Ansible IaC Device Provisioning](../Concepts/Ansible-IaC-Device-Provisioning.md) |
| [`POL-0016`](../../00-Atlas-Foundation/Policies/POL-0016-Realism-and-Learning.md) Realism & Learning ★ | Build to the real enterprise model; certs anchor skills; drills test docs | the whole Academy |

> **★** = already in the golden shape. The pre-golden policies (`POL-0001..0013` minus `0004`) are correct and in force; the reshape-to-golden pass is tracked in the backlog.

## 3. The Standards register

The concrete, testable *how* under a policy — 12 `STD-####`, full register: [`Standards/README`](../../00-Atlas-Foundation/Standards/README.md).

- **Security (estate-grounded, v2.0):** [`STD-0001`](../../00-Atlas-Foundation/Standards/STD-0001-Password-and-Authentication.md) Password/Auth · [`STD-0002`](../../00-Atlas-Foundation/Standards/STD-0002-Access-Control.md) Access Control · [`STD-0003`](../../00-Atlas-Foundation/Standards/STD-0003-Physical-Security.md) Physical/OOB · [`STD-0004`](../../00-Atlas-Foundation/Standards/STD-0004-Encryption.md) Encryption.
- **Documentation (materialized from the doc-shaped ADRs):** [`STD-0005`](../../00-Atlas-Foundation/Standards/STD-0005-Device-Documentation.md) Device Docs · [`STD-0006`](../../00-Atlas-Foundation/Standards/STD-0006-Academy-Documentation.md) Academy · [`STD-0007`](../../00-Atlas-Foundation/Standards/STD-0007-Diagnostics-and-Verification.md) Diagnostics · [`STD-0008`](../../00-Atlas-Foundation/Standards/STD-0008-ADR-Governance-and-Scope.md) ADR Governance · [`STD-0009`](../../00-Atlas-Foundation/Standards/STD-0009-Session-Planning-and-Handoff.md) Session/Handoff.
- **Build:** [`STD-0010`](../../00-Atlas-Foundation/Standards/STD-0010-Incremental-Test-Gated-Build.md) Test-Gated · [`STD-0011`](../../00-Atlas-Foundation/Standards/STD-0011-Phased-Build-Guides.md) Phased Build-Guides · [`STD-0012`](../../00-Atlas-Foundation/Standards/STD-0012-Automation-and-IaC.md) Automation/IaC.

Every standard is cut from [`STD-Template`](../../00-Atlas-Foundation/Templates/STD-Template.md) and carries a read-back per requirement + a Learn-it section (*pages feed pages*).

## 4. The decisions (ADRs)

- **The live index** — [`ADR-Index`](../../00-Atlas-Foundation/Decisions/ADR-Index.md): every decision by scope (Global / Lab-01 / Lab-02) + status, each naming its `Governing Policy:`.
- **The navigator** — `AI-Context/ADR-Navigation`: the supersession chains, the (B)→STD / (C)→POL reconciliation map, and how to add a new ADR.
- **Scope & shape** — every ADR carries a `Scope` field and appears in the index ([`STD-0008`](../../00-Atlas-Foundation/Standards/STD-0008-ADR-Governance-and-Scope.md) ← `ADR-0033`); cut from [`ADR-Template`](../../00-Atlas-Foundation/Templates/ADR-Template.md).

## 5. How a rule changes

A policy holds the **current** rule; the ADRs behind it are the **dated trail**. No standing rule is ever edited silently — the PM baseline-and-change-request model ([`ADR-0054`](../../00-Atlas-Foundation/Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)):

- **To change a rule, an ADR amends it** — it carries `Governing Policy: POL-xxxx`, states *"amends POL-xxxx R#"*, and the policy's Change Log gains a row.
- **The Decisions directory in each policy is *generated*** from those `Governing Policy:` lines by [`tools/Build-Policy-Directories.ps1`](../../tools/Build-Policy-Directories.ps1) between `AUTOGEN` markers — never hand-typed (this is `POL-0004` applied to governance itself). Add an ADR's line, re-run the builder, the directory rebuilds.
- **Three dispositions** when reconciling an ADR ([`ADR-0054` §3](../../00-Atlas-Foundation/Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)): **(A) Decision** (keep as-is, add the `Governing Policy:` line) · **(B) Standard-in-effect** (materialize as a `STD-####`) · **(C) Policy-shaped** (promote the rule into its policy; keep the ADR as the adopting decision).

## 6. Nothing is lost

Preserve, never delete ([`ADR-0012`](../../00-Atlas-Foundation/Decisions/ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md) / [`POL-0014`](../../00-Atlas-Foundation/Policies/POL-0014-Documentation-and-Knowledge-Management.md) R2). Immediately before the #39/`ADR-0054` reconciliation re-scoped the policy- and standard-shaped ADRs, **all 54 ADRs + the index were frozen byte-exact**:

- 📇 **[`Legacy-ADR-Index`](../../00-Atlas-Foundation/Decisions/Legacy-ADR-Index.md)** — the one-click door from the live index to the frozen trail; summarizes the before/after.
- 📁 **`99-Archive/Legacy-ADRs-2026-08-03/`** — the snapshot: 54 ADRs, the frozen index (v1.30), and a README, byte-exact.
- 📋 **The working list** — [`Governance-Reconciliation-Triage`](../../00-Atlas-Foundation/Governance/Governance-Reconciliation-Triage.md): the per-ADR disposition. The **(B) → STD** materializations (`ADR-0037`→`STD-0005`, `ADR-0053`→`STD-0006`, `ADR-0032`→`STD-0007`, `ADR-0033`→`STD-0008`, `ADR-0049`→`STD-0009`, `ADR-0041`→`STD-0010`, `ADR-0043`→`STD-0011`, `ADR-0048`→`STD-0012`) and the **(C) → POL** promotions (`ADR-0008`/`0012`→`POL-0014`, `ADR-0011`→`POL-0005`, `ADR-0019`→`POL-0001`, `ADR-0034`→`POL-0004` R5, `ADR-0044`→`POL-0016`) all preserve the originating ADR.

## 7. The standing controls

- **The audit** ([`Atlas-Governance-Framework` §7](../../00-Atlas-Foundation/Governance/Atlas-Governance-Framework.md) · [`POL-0001`](../../00-Atlas-Foundation/Policies/POL-0001-Atlas-Audit-Policy.md)) — the control against the estate's central defect, *"the document disagrees with the device."* A freeze audit gates any "done" lab; findings need a command + its output; a fix is verified by counting the OLD text to zero. Owner: the Security silo ([`ADR-0018`](../../00-Atlas-Foundation/Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)).
- **The currency rule** ([`Atlas-Governance-Framework` §8](../../00-Atlas-Foundation/Governance/Atlas-Governance-Framework.md)) — *"done" isn't done until it's generated, grounded, and logged*: regenerate the affected policy directories, refresh `AI-Context/`, log to the [Backlog](../../00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md), update the `SESSION-HANDOFF`.
- **How work + a change get done** — [`Atlas-Workflow`](../../00-Atlas-Foundation/Governance/Atlas-Workflow.md) (write → verify → publish → freeze) · [`Atlas-Change-Management-Process`](../../00-Atlas-Foundation/Governance/Atlas-Change-Management-Process.md) (`POL-0003` in practice).

## 8. Templates, tooling and the Academy

- 📋 **Templates** — [`POL-Template`](../../00-Atlas-Foundation/Templates/POL-Template.md) · [`STD-Template`](../../00-Atlas-Foundation/Templates/STD-Template.md) · [`ADR-Template`](../../00-Atlas-Foundation/Templates/ADR-Template.md) · [`Change-Record-Template`](../../00-Atlas-Foundation/Templates/Change-Record-Template.md).
- 🔧 **Tooling** — [`tools/Build-Policy-Directories.ps1`](../../tools/Build-Policy-Directories.ps1) (the generator behind every policy's Decisions directory).
- 🎓 **Concepts + cert alignment** — the governance-adjacent why-layer: [Risk as a Living Register](../Concepts/Risk-as-a-Living-Register.md) (accepted-risk-needs-a-trigger) · [A Completed Command Is Not Evidence](../Concepts/A-Completed-Command-Is-Not-Evidence.md) (the audit's read-back rule) · the [Concepts index](../Concepts/); cert-adjacent to **CompTIA Project+ / ITIL** governance practice — [Project+ map](../Certification/Atlas-CompTIA-Project-Plus-Lab-Map.md).
- 🤖 **Machine-first counterpart** — `AI-Context/Directory-Map` (the tree) + `AI-Context/ADR-Navigation` (the ADR navigator).

## Related

[Source-of-Truth router §9](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#9-governance-and-decisions) (the quick view) · [`Atlas-Governance-Framework`](../../00-Atlas-Foundation/Governance/Atlas-Governance-Framework.md) (the model) · [`Policies/README`](../../00-Atlas-Foundation/Policies/README.md) · [`Standards/README`](../../00-Atlas-Foundation/Standards/README.md) · [`ADR-Index`](../../00-Atlas-Foundation/Decisions/ADR-Index.md) · the other twins: [Security & Perimeter](./Security-and-Perimeter.md) · [Identity & Access](./Identity-and-Access.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-04. First cut — the exhaustive twin of Source-of-Truth §9: the layer hierarchy (Charter→Policy→Standard→ADR→Change→Procedure), the full 16-policy register (with each policy's Academy why-layer) + the 12-standard register, the ADR index/navigator, the amendment / A-B-C reconciliation model + the generated Decisions directories, the "nothing is lost" legacy-ADR snapshot + the (B)→STD / (C)→POL mapping, the audit + currency standing controls, and the templates/tooling/Academy. Built to complete the Academy Directory (the per-domain twins of the SoT router). |
