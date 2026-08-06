---
Title: STD-0011 — Phased, Dependency-Gated Build-Guides Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0015` via `ADR-0043`. In force.
Version: 1.0
---

# STD-0011 — Phased, Dependency-Gated Build-Guides

> **At a glance.** A Build-Guide mirrors its Roadmap 1:1, every phase opens with a 🔴 GATE (deps healthy · machines exist · prior phase ✅), future phases are gated stubs, and cross-device order is decided **once** in the estate build-order doc — never a second sequence.

| Item | Value |
|---|---|
| Layer | **Standard** — the structure of build-execution docs; binds every `Build-Guide` + the estate build-order |
| Governing policy | [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) — Engineering & Build Discipline (+ [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) doc-type) |
| Requirement, in one line | Build-Guide mirrors Roadmap · phase-opening 🔴 GATEs · gated stubs for the future · one estate build-order owner |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0043`](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Detailed spec | [`Build-Order-and-Dependencies`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md) + [`Build-Guide-Template`](../Templates/Build-Guide-Template.md) |
| Applies to | every device `Build-Guide` (+ `Build-Guide/` subfolders); the estate build-order |
| Feeds / fed by | **fed by** [`STD-0005`](./STD-0005-Device-Documentation.md) (Build-Guide is part of the page-set) + [`STD-0010`](./STD-0010-Incremental-Test-Gated-Build.md) (the phase GATE = the test-gate at phase scale) · **feeds** [`STD-0012`](./STD-0012-Automation-and-IaC.md) (the Automation-onboarding phase hook) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | dependency-gated release methodology · the Atlas Standard Build-Guide doc-type (→ v1.3) |

---

## Scope & applicability

Binds the *shape* of a Build-Guide and the *single ownership* of cross-device sequence. It makes `STD-0010`'s test-gate explicit at phase granularity.

**Boundary with adjacent standards:** *the unit-level gate* is [`STD-0010`](./STD-0010-Incremental-Test-Gated-Build.md); *the rest of the page-set* is [`STD-0005`](./STD-0005-Device-Documentation.md); this standard owns the *Build-Guide structure + the build-order consolidation*.

## Why a standard, not left in a guide

A build that can start before its dependencies are healthy is how a rebuild recreates a broken device. Phase-opening gates make "don't start until…" impossible to skip, and a single build-order owner means cross-device sequence is decided once — not re-derived (and drifting) in three docs.

---

## The requirements

Each is citable as `STD-0011 R#`.

### R1 — The Build-Guide mirrors the Roadmap 1:1

Phases mirror `Roadmap.md` rows in the **same order**; the Roadmap owns the **sequence + dependency graph** (Needs/Unblocks). The guide is the *how*, never a second sequence.

### R2 — Every phase opens with a 🔴 GATE

Each phase begins: *"do not start until: [dependencies healthy] + [these machines exist] + [prior phase ✅]."* This is `STD-0010`'s test-gate at phase scale.

### R3 — Standard recurring sections in fixed places

Each phase carries, where applicable: **Certificate-application** (request → enroll → install → verify from ICA01), **Service-setup** (per the `Roles/` pattern), and an **Automation-onboarding** hook ([`STD-0012`](./STD-0012-Automation-and-IaC.md)).

### R4 — Future phases are gated stubs; scaling is append-only

Not-yet-reached (e.g. cloud) phases present **now as a gate + outline + hooks**; full steps are written only when reached. New capability = a **new gated phase section**, never a rewrite. The guide **links, never restates** (`POL-0008`).

### R5 — One estate build-order owner

[`Operations/Build-Order-and-Dependencies.md`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md) is the **single owner** of cross-device sequence + the dependency map; `Build-Progress-Tracker` is a status log only; `Atlas-Service-Architecture` stays design-only.

---

## Adopting & amending decisions

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0043`](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md) | Accepted | the phased/gated Build-Guide structure + the estate build-order consolidation (amended the [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) Build-Guide doc-type → v1.3) |

(Originals in the legacy snapshot.)

## Verification (how conformance is proven)

- [ ] **R2** — `git grep` every device Build-Guide: each phase heading carries a 🔴 GATE (deps + machines + prior-phase ✅).
- [ ] **R1** — a device's Build-Guide phase order matches its `Roadmap.md` (Roadmap wins on conflict).
- [ ] **R5** — [`Build-Order-and-Dependencies`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md) is the *only* doc asserting cross-device sequence (Master-Build-Order/Checklist folded in; tracker is status-only).
- [ ] **Meta** — a new capability arrives as a new gated phase, not a rewrite.

## Learn it — the source of truth for the *how*

- 🗺️ **The build-order:** [`Build-Order-and-Dependencies`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md) (the single sequence owner)
- 🧩 **The template + a worked spine:** [`Build-Guide-Template`](../Templates/Build-Guide-Template.md) · the [DC `Build-Guide/` subfolder](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Guide/) (phased sub-guides)
- 📘 **The doc-type:** [`Atlas-Documentation-Standard`](../Documentation/Atlas-Documentation-Standard.md) (Build-Guide doc-type, v1.3) · [`STD-0005`](./STD-0005-Device-Documentation.md)
- 📋 **Program:** [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md)

## What a violation looks like

A Build-Guide phase with no GATE · phase order that disagrees with the Roadmap · cross-device sequence asserted in two docs · a future phase written out in full before it's reachable · a capability bolted on by rewriting the guide instead of appending a phase.

## Related

[`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) (governing) · [`STD-0010`](./STD-0010-Incremental-Test-Gated-Build.md) · [`STD-0005`](./STD-0005-Device-Documentation.md) · [`STD-0012`](./STD-0012-Automation-and-IaC.md) · [`ADR-0043`](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0043` into a testable standard** (#39 (B)→STD): Build-Guide-mirrors-Roadmap, phase-opening 🔴 GATEs, the recurring sections, gated-stub/append-only scaling, and the single estate-build-order owner — each with a `git grep`/structure read-back. Cut from `STD-Template`. |
