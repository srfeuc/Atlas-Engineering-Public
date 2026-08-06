---
Title: POL-0016 — Realism & Learning Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework) via `ADR-0054` (reconciliation). In force.
Version: 1.0
---

# POL-0016 — Realism & Learning

> **At a glance.** Atlas is built to the **real-world enterprise model**, its skills **anchored to certifications**, and it **learns by doing** — build by hand then automate, drill failure before it happens, run the full scope a real enterprise runs. Every scope/design choice answers one question: *is this how a real enterprise would do it, and what does it teach?*

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs *why* the estate is shaped as it is |
| Requirement, in one line | Mirror a real enterprise · anchor skills to certs · learn by doing · drill failure · run the faithful full scope |
| Owner | 🔴 the operator ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md) (defined the fold) → adopted under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (2026-08-03) |
| Builds on | [`Atlas-Charter`](../Governance/Atlas-Charter.md) **Rule 16** (the Learning Rule — the framework §2 anticipated this policy) · [`STD-0012`](../Standards/STD-0012-Automation-and-IaC.md) R2 (learn-then-automate) · [`POL-0005`](./POL-0005-Backup-and-Recovery.md) (a restore proves a backup) |
| Governs (decisions) | `ADR-0044` (enterprise model; certs) · `ADR-0039` (full hybrid scope) · `ADR-0011` (Game Days) · `ADR-0024` (headcount) · `ADR-0025` (both tracks) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | the estate's purpose — a real-world-faithful, cert-anchored learning environment |

---

## Scope & applicability

Applies to **every scope and design decision** in the estate — what to build, how much of it, and why. It is the standing test a decision conforms to; it does not dictate a specific technical design (that's the ADR/device docs), it dictates that the design be **defensible as enterprise-real** and **legible as a learning artifact**.

**Boundary with [`POL-0015`](./POL-0015-Engineering-and-Build-Discipline.md):** POL-0015 governs *how* work is built (gated, phased, automated); POL-0016 governs *why* it's built this way and *what it must teach*. Learn-by-hand-then-automate is the seam — POL-0016 requires it as a learning principle, POL-0015/`STD-0012` execute it.

## Why this is a policy, not a note

The realism principle is the estate's *reason to exist*, but it was scattered across decisions ([`ADR-0044`](../Decisions/ADR-0044-Enterprise-Model-Standard-Certs-Anchor-Skills.md) enterprise model · [`ADR-0039`](../Decisions/ADR-0039-Commit-Full-Hybrid-Enterprise-Scope.md) full scope · [`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) Game Days · `ADR-0025` both tracks). As a policy it becomes the standing test every scope/design decision conforms to — *"is this how a real enterprise would do it, and what does it teach?"* — the question that has driven the estate's best calls.

---

## The standing requirements

Each is citable as `POL-0016 R#`.

### R1 — Built to the real-world enterprise model; certs anchor the skills

The estate **mirrors a real hybrid enterprise** (a ~150-person industrial org, `ADR-0024`); **certifications anchor the skills** (CCNA/CCNP · AZ-800/801 · FortiGate-FCP · Security+ · Project+ · Linux+) — they *anchor* competence, they do **not** drive artificial complexity for its own sake. Decision: [`ADR-0044`](../Decisions/ADR-0044-Enterprise-Model-Standard-Certs-Anchor-Skills.md).

### R2 — Learn by doing (the Learning Rule)

**Do it by hand, understand it, then automate/document** ([`Atlas-Charter`](../Governance/Atlas-Charter.md) Rule 16). Plumbing is automated; a learning-target is hand-typed the first time and captured only once understood — the Build-Guide still teaches the manual first pass ([`STD-0012`](../Standards/STD-0012-Automation-and-IaC.md) R2).

### R3 — Drill failure before it happens

Recoverability is **proven, not assumed**: Game Days test the *documentation* against reality — *a backup isn't a backup until a restore proves it* ([`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) / [`POL-0005`](./POL-0005-Backup-and-Recovery.md)). A drill's findings must reach the doc that does the work.

### R4 — Faithful scope

Run **what a real enterprise runs**: the network and identity tracks proceed **together** ([`ADR-0039`](../Decisions/ADR-0039-Commit-Full-Hybrid-Enterprise-Scope.md) / `ADR-0025`), not one lab-only slice — because segmentation, identity, PKI, monitoring, and backup are a *system*, and the estate teaches the system.

---

## Decisions governed by this policy

> Generated from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0016 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0011 — Game Days: Unannounced Failure Drills That Test the Docum…](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) | Proposed — captured 2026-07-13, deliberately NOT scheduled | POL-0005 (+POL-0013, +POL-0016) |
| [ADR-0039 — Commit the Estate to a Full Hybrid Enterprise (scope)](../Decisions/ADR-0039-Commit-Full-Hybrid-Enterprise-Scope.md) | Accepted (operator, 2026-07-29). Scope commitment; phased… | POL-0016 |
| [ADR-0044 — Built to the Real-World Enterprise Model; Certifications …](../Decisions/ADR-0044-Enterprise-Model-Standard-Certs-Anchor-Skills.md) | Accepted (operator, 2026-07-29). Framing / priority decis… | POL-0016 |
<!-- END AUTOGEN:decisions POL-0016 -->

## The amendment model

This policy holds the **current** rule; the decisions are the **dated trail**. To change it, an ADR amends it (carrying `Governing Policy: POL-0016`) and this Change Log gains a row. `ADR-0044` is a **(C) policy-shaped** decision — its standing rule now lives here, the ADR kept as the adopting decision (`ADR-0054`; originals in the legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — a new scope/design decision names the **real-world pattern** it follows (or the deliberate lab deviation + why).
- [ ] **R1** — cert alignment is recorded where a build exercises an objective (the per-device `Roadmap` cert slice, `STD-0005`).
- [ ] **R2** — automation exists only where the manual path is documented (`STD-0012`).
- [ ] **R3** — Game Days are run and their findings reach the doc that does the work (`ADR-0011`/`POL-0005`).
- [ ] **Meta** — every amendment traces to an ADR + a Change Log row.

## Learn it — the Academy (the source of truth for the *why*)

- 🧭 **What the estate is for:** [`Academy-Vision-and-Scope`](../../Atlas-Academy/Academy-Vision-and-Scope.md) · [`Atlas-Academy/README`](../../Atlas-Academy/README.md)
- 🏅 **The cert anchors:** the [cert lab-maps](../../Atlas-Academy/) (CCNA · CCNP · AZ-800/801 · FortiGate-FCP · Security+)
- 🎓 **The realism scars, taught:** [`A Completed Command Is Not Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) (a "tested" backup that was never restored)
- 📚 **The build face:** [`POL-0015`](./POL-0015-Engineering-and-Build-Discipline.md) + [`STD-0012`](../Standards/STD-0012-Automation-and-IaC.md) (learn-then-automate)

## What a violation looks like

A lab-only shortcut presented as the enterprise pattern · complexity added for a cert with no real-world analogue · a "tested" backup never restored · a design choice with no stated real-world basis · one track built in isolation because the other was "too much."

## Related

[`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md) (§2 anticipated this) · [`Atlas-Charter`](../Governance/Atlas-Charter.md) (Rule 16) · [`POL-0015`](./POL-0015-Engineering-and-Build-Discipline.md) · [`POL-0005`](./POL-0005-Backup-and-Recovery.md) · [`ADR-0044`](../Decisions/ADR-0044-Enterprise-Model-Standard-Certs-Anchor-Skills.md)/[`0039`](../Decisions/ADR-0039-Commit-Full-Hybrid-Enterprise-Scope.md)/[`0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) · [triage](../Governance/Governance-Reconciliation-Triage.md) · [`Atlas-Academy/`](../../Atlas-Academy/).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Folded the stub into a full policy in force** (#39/#42 Increment 4): the four requirements grounded in the real estate (the enterprise model + certs, the Learning Rule, Game-Day drilling, faithful scope), a Learn-it (Academy) source-of-truth section, and the amendment model. Adopted under `ADR-0026` via `ADR-0054`. |
| 0.1 | 2026-07-31. Proposed stub (drafted with `ADR-0054`). |
