---
Title: POL-0015 — Engineering & Build Discipline Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework) via `ADR-0054` (reconciliation). In force.
Version: 1.0
---

# POL-0015 — Engineering & Build Discipline

> **At a glance.** The estate is built **one unit at a time**, each unit gated by a passing verification before the next; builds are **phased and dependency-ordered**; automation follows **learn-by-hand-then-automate** and must be idempotent. Never a bulk, unverified change. The concrete *how* lives in three standards ([`STD-0010`](../Standards/STD-0010-Incremental-Test-Gated-Build.md)/[`0011`](../Standards/STD-0011-Phased-Build-Guides.md)/[`0012`](../Standards/STD-0012-Automation-and-IaC.md)); this policy is the standing requirement they answer to.

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the build Standards, ADRs, and Changes beneath it |
| Requirement, in one line | Build one gated unit at a time, in dependency order, automating only what's been learned by hand — never a bulk unverified change |
| Owner | 🔴 the operator / engineering function ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md) (defined the fold) → adopted under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (2026-08-03) |
| Standards (the *how*) | [`STD-0010`](../Standards/STD-0010-Incremental-Test-Gated-Build.md) (incremental, test-gated) · [`STD-0011`](../Standards/STD-0011-Phased-Build-Guides.md) (phased Build-Guides) · [`STD-0012`](../Standards/STD-0012-Automation-and-IaC.md) (Automation & IaC) |
| Builds on | [`POL-0006`](./POL-0006-Evidence-and-Verification.md) (a gate needs a passing read-back) · [`POL-0004`](./POL-0004-Source-of-Truth.md) (generated, not hand-typed) · [`POL-0003`](./POL-0003-Change-Control.md) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST SSDF · CIS v8 (secure config / change management) · CompTIA Project+ Dom 2 (life-cycle) / Dom 4 (CI/CD) |

---

## Scope & applicability

Applies to **every build and change** on every device in the estate, and to every session that executes one. It governs *how work lands* — the unit size, the gate, the order, and the automation model — not the technical design of any one device (that's the device's docs + its ADRs).

**Boundary with [`POL-0006`](./POL-0006-Evidence-and-Verification.md):** POL-0006 owns *what counts as evidence* (a read-back, not a completed command); POL-0015 owns *the sequencing* that evidence gates — one unit, proven, before the next. They meet at the gate.

## Why this is a policy, not a note

The build discipline was written as three decisions ([`ADR-0041`](../Decisions/ADR-0041-Incremental-Test-Gated-Implementation.md) test-gated · [`ADR-0043`](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md) phased · [`ADR-0048`](../Decisions/ADR-0048-Automation-and-IaC-Model.md) automation) but it is really a *standing requirement about how any work lands*. The reason the estate's big sweeps could be trusted is that **each unit passed its gate**. As a policy, "was this built to discipline?" becomes auditable, and every future build ADR has an explicit home to conform to — its rule made concrete in a standard.

---

## The standing requirements

Each is citable as `POL-0015 R#`. Each names the **standard** that makes it concrete (the *how*) and the **decision** that adopted it (the *why*).

### R1 — Incremental & test-gated

Build **one unit at a time** — one firewall rule, one GPO, one CA template, one ACL; each unit carries a **positive and (for a control) negative acceptance gate**, and is **✅ only on a passing read-back** (`POL-0006`); a failed or un-run gate **stops the line**. Standard: [`STD-0010`](../Standards/STD-0010-Incremental-Test-Gated-Build.md). Decision: [`ADR-0041`](../Decisions/ADR-0041-Incremental-Test-Gated-Implementation.md). > *"large bulks get me in trouble"* — the MKT01 one-rule-at-a-time firewall build is the worked case.

### R2 — Phased & dependency-gated

Build in the estate's **dependency order** — no step before its prerequisites; each Build-Guide **mirrors its `Roadmap.md` 1:1** and opens each phase with a 🔴 GATE; cross-device sequence lives in **one owner**, [`Operations/Build-Order-and-Dependencies.md`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md). Standard: [`STD-0011`](../Standards/STD-0011-Phased-Build-Guides.md). Decision: [`ADR-0043`](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md).

### R3 — Automation follows learn-by-hand-then-automate

Automate **what you've already learned to do by hand**; automation has **two homes** (a per-device `Automation/` doc-type ↔ the shared estate git/CI capability), and every artifact must be **idempotent before ✅**; generated config beats hand-typed (`POL-0004`). Standard: [`STD-0012`](../Standards/STD-0012-Automation-and-IaC.md). Decision: [`ADR-0048`](../Decisions/ADR-0048-Automation-and-IaC-Model.md).

### R4 — No bulk restructure; silo-crossing changes are recorded

No bulk multi-device change without per-unit gates; a change crossing a silo boundary raises a Change Record (`POL-0003`). Rollback is per-unit (`STD-0010 R5`).

---

## Sources of truth — where each build fact lives

> ⚠️ **Navigational, not authoritative.** The owner wins if this map drifts (R-applied-to-this-page).

| Kind of fact | Owner document |
|---|---|
| Cross-device build order + dependencies | [`Operations/Build-Order-and-Dependencies.md`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md) |
| A unit's acceptance gate | that device's `Build-Checklist.md` |
| A control's negative/adversarial test | [`Operations/Validation-and-Adversarial-Testing.md`](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md) |
| Per-device automation how-to | the device's `Automation/` folder |
| Shared runnable code + CI | the estate capability (`CNT01`, Backlog #19) |

## Decisions governed by this policy

> Generated from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0015 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0041 — Incremental, Test-Gated Implementation](../Decisions/ADR-0041-Incremental-Test-Gated-Implementation.md) | Accepted (operator, 2026-07-29). Estate build discipline. | POL-0015 (+POL-0006) |
| [ADR-0043 — Scalable, Phased, Dependency-Gated Build-Guides (and the …](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md) | Accepted (operator, 2026-07-29). Governs Build-Guide stru… | POL-0015 (+POL-0014) |
| [ADR-0048 — Automation & Infrastructure-as-Code Model (Per-Device `Au…](../Decisions/ADR-0048-Automation-and-IaC-Model.md) | Accepted in principle (operator, 2026-07-29) — the *model… | POL-0015 |
<!-- END AUTOGEN:decisions POL-0015 -->

## The amendment model

This policy holds the **current** rule; the standards below it hold the **concrete how**; the decisions are the **dated trail**. To change a rule, an ADR amends it (carrying `Governing Policy: POL-0015`) and this Change Log gains a row; the three build ADRs are **(B) standards-in-effect** — materialized into `STD-0010/0011/0012`, the ADR kept as the adopting decision (`ADR-0054`; originals in the legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — each build unit has a recorded acceptance gate (command + output) before the next started; no ✅ without a read-back (`STD-0010`).
- [ ] **R2** — build order follows [`Build-Order-and-Dependencies.md`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md); every Build-Guide phase carries a GATE (`STD-0011`).
- [ ] **R3** — automation lands only where the manual path is understood/documented; each artifact is idempotent on re-run (`STD-0012`).
- [ ] **Meta** — every change to a governed standard traces to an amending ADR + a Change Log row.

## Learn it — the Academy (the source of truth for the *why*)

- 🎓 **Concept:** [`A Completed Command Is Not Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) (why the gate exists) · [`Ansible IaC Device Provisioning`](../../Atlas-Academy/Concepts/Ansible-IaC-Device-Provisioning.md)
- 🔧 **Worked:** the [MKT01 incremental firewall worksheet](../../Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/Incremental-East-West-Firewall-Build-Worksheet.md) · the [adversarial matrix](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md)
- 🏅 **Cert:** CompTIA **Project+** (life-cycle / CI-CD) · **AZ-400** (DevOps, automation)
- 📚 **The standards:** [`STD-0010`](../Standards/STD-0010-Incremental-Test-Gated-Build.md) · [`STD-0011`](../Standards/STD-0011-Phased-Build-Guides.md) · [`STD-0012`](../Standards/STD-0012-Automation-and-IaC.md) (the [register](../Standards/README.md))

## What a violation looks like

A ✅ with no proving command · a unit built before its dependency · a bulk multi-device change with no per-unit gate · automation shipped for a step never done by hand · a non-idempotent playbook marked ✅ · cross-device order asserted in two docs.

## Related

[`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md) · the build standards [`STD-0010`](../Standards/STD-0010-Incremental-Test-Gated-Build.md)/[`0011`](../Standards/STD-0011-Phased-Build-Guides.md)/[`0012`](../Standards/STD-0012-Automation-and-IaC.md) · [`POL-0006`](./POL-0006-Evidence-and-Verification.md) · [`POL-0003`](./POL-0003-Change-Control.md) · [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md) · [triage](../Governance/Governance-Reconciliation-Triage.md) · Backlog #7/#19 (automation execution).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Folded the stub into a full policy in force** (#39/#42 Increment 4): the four requirements each wired to their materialized **standard** (`STD-0010/0011/0012`) + adopting ADR, a Sources-of-truth map, a Learn-it (Academy) source-of-truth section, and the amendment model. Adopted under `ADR-0026` via `ADR-0054`. |
| 0.1 | 2026-07-31. Proposed stub (drafted with `ADR-0054`). |
