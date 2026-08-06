---
Title: Policies (POL-####) — the register + how the layer works
Path: 00-Atlas-Foundation/Policies
Status: 🟢 Living register (`ADR-0026` framework · `ADR-0054` reconciliation). The front door to the Policy layer.
Version: 1.0
---

# Policies — `POL-####`

> **A policy is the standing rule — the *why* that must always be true.** A [standard](../Standards/README.md) is the concrete, testable *how* beneath it; an ADR is the dated decision that adopted or amended it. Policy > Standard > ADR. A policy is cited by number and clause — `POL-0014 R3` — and doubles as a **generated directory** of the decisions that govern its domain.

This is the register and the working rules for the layer. Cut a new policy from [`POL-Template`](../Templates/POL-Template.md); the model is [`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md).

## The register

Status: **✅** in force (adopted under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md)). **★** = in the golden shape (at-a-glance · R# clauses · Sources-of-truth · generated directory · Learn-it). **As of 2026-08-04 all 16 policies are ★ — the #42 golden-reshape is complete.**

| Policy | Governs (domain) | Status |
|---|---|---|
| [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) | Audit — the cadence + the mechanical stale-`Verified` check | ✅ ★ |
| [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) | Secrets & credentials (the `CM-0014` scar) | ✅ ★ |
| [`POL-0003`](./POL-0003-Change-Control.md) | Change control | ✅ ★ |
| [`POL-0004`](./POL-0004-Source-of-Truth.md) | Source of truth — one home per fact, generated-not-typed | ✅ ★ |
| [`POL-0005`](./POL-0005-Backup-and-Recovery.md) | Backup & recovery (3-2-1, restore-tested) | ✅ ★ |
| [`POL-0006`](./POL-0006-Evidence-and-Verification.md) | Evidence & verification — the read-back rule | ✅ ★ |
| [`POL-0007`](./POL-0007-Hardening-Baseline.md) | Hardening baseline | ✅ ★ |
| [`POL-0008`](./POL-0008-Naming-and-Addressing.md) | Naming & addressing | ✅ ★ |
| [`POL-0009`](./POL-0009-Incident-Response.md) | Incident response | ✅ ★ |
| [`POL-0010`](./POL-0010-Acceptable-Use.md) | Acceptable use / access | ✅ ★ |
| [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md) | Data governance, classification & privacy | ✅ ★ |
| [`POL-0012`](./POL-0012-Risk-Management.md) | Risk management | ✅ ★ |
| [`POL-0013`](./POL-0013-Business-Continuity.md) | Business continuity | ✅ ★ |
| [`POL-0014`](./POL-0014-Documentation-and-Knowledge-Management.md) | Documentation & knowledge management | ✅ ★ |
| [`POL-0015`](./POL-0015-Engineering-and-Build-Discipline.md) | Engineering & build discipline | ✅ ★ |
| [`POL-0016`](./POL-0016-Realism-and-Learning.md) | Realism & learning | ✅ ★ |

## How the layer works

- **A policy folds its decisions.** The *Decisions governed by this policy* directory in each policy is **generated** from the ADRs' `Governing Policy:` lines by [`tools/Build-Policy-Directories.ps1`](../../tools/Build-Policy-Directories.ps1) — never hand-edited. Add an ADR's `Governing Policy: POL-xxxx` line, re-run the tool.
- **A policy points down to its standards.** Where a policy has a concrete *how*, it names the [`STD-####`](../Standards/README.md) that carries it (e.g. `POL-0015` → `STD-0010/0011/0012`).
- **Amend via an ADR.** To change a rule, an ADR carries `Governing Policy: POL-xxxx`, states *"amends POL-xxxx R#"*, and the policy's Change Log gains a row (`ADR-0054`). Nothing changes by silent edit.
- **Preserve.** A promoted rule keeps its originating ADR as the adopting decision; the pre-reconciliation set is frozen in the [Legacy-ADR snapshot](../Decisions/Legacy-ADR-Index.md) (`ADR-0012`).

## Related

[`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md) (the Policy > Standard > ADR model) · [`Atlas-Source-of-Truth` §9](../Governance/Atlas-Source-of-Truth.md#9-governance-and-decisions) · the [`Standards/` register](../Standards/README.md) · [`Governance-Reconciliation-Triage`](../Governance/Governance-Reconciliation-Triage.md) · [`POL-Template`](../Templates/POL-Template.md).

## Change Log

| Version | Changes |
|---|---|
| 1.1 | 2026-08-04. Began the golden-shape reshape of the pre-golden policies (#42, concepts-first): **`POL-0001` (Audit)** reshaped to the `POL-0014` shape — at-a-glance · citable `R1–R5` · amendment model · a **Learn-it** section pointing at the now-built `A-Completed-Command` + `Risk-as-a-Living-Register` concepts → ★. Then **`POL-0002`** (Secrets → Secrets-Custody), **`POL-0005`** (Backup → A-Backup-Is-Not-a-Backup), **`POL-0012`** (Risk → Risk-as-a-Living-Register) reshaped + ★ (each: citable R#, Learn-it → its concept, AUTOGEN intact, no normative change). Then **`POL-0003`/`0006`/`0007`** (Change-Control / Evidence / Hardening) + **`POL-0008`/`0009`/`0010`/`0011`/`0013`** (Naming / IR / Acceptable-Use / Data-Governance / Business-Continuity) reshaped + ★ (each: citable R#, Learn-it → its concept, AUTOGEN intact, no normative change). **✅ All 12 pre-golden policies reshaped — 16/16 ★, #42 reshape COMPLETE.** |
| 1.0 | 2026-08-03. Established the Policies register + front door (parity with the Standards register — the layer had no README). States the layer model, the honest register (16 policies in force; ★ = golden-shape), and how the layer works (generated directories, points-down-to-standards, amend-via-ADR, preserve). |
