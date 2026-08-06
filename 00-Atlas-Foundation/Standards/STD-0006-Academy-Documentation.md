---
Title: STD-0006 — Academy Documentation Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0014` via `ADR-0053`. In force.
Version: 1.0
---

# STD-0006 — Academy Documentation

> **At a glance.** The Academy is organized in fixed layers, every page is ≤ 3 clicks from the front door, Playbooks are named for the problem they solve and follow one mold, and everything is grounded in a real cert objective and a real incident — provable by a grep + a click-depth check.

| Item | Value |
|---|---|
| Layer | **Standard** — the shape of `Atlas-Academy/`; binds Concepts, Command-Library, Playbooks, cert maps |
| Governing policy | [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) — Documentation & Knowledge Management |
| Requirement, in one line | Fixed layers · the 3-click rule · problem-named Playbooks on the §5 mold · a cert-grounded spine |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Detailed spec | [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) §5/§8 (self-contained) + [`Academy-Vision-and-Scope`](../../Atlas-Academy/Academy-Vision-and-Scope.md) |
| Applies to | every doc under [`Atlas-Academy/`](../../Atlas-Academy/) |
| Feeds / fed by | **feeds** every Academy page + the [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md) Command-Library · **fed by** [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) + [`Academy-Vision-and-Scope`](../../Atlas-Academy/Academy-Vision-and-Scope.md) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | the Atlas Academy standard (`ADR-0053`) · the briefcase principle |

---

## Scope & applicability

Binds how the teaching/operational-knowledge layer is structured and navigated: the layers, the click-depth, the Playbook mold, and the cert spine. Device-specific facts stay on the device (`STD-0005`); the Academy is the cross-cutting learn-it layer.

**Boundary with adjacent standards:** *per-device diagnostics* are [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md) (which links *up* into the Academy Command-Library); *the writing voice* is the [Teaching-Patterns house style](../../Atlas-Academy/Atlas-Teaching-Patterns-and-House-Style.md).

## Why a standard, not left in a guide

The Academy is the estate's **offline, searchable-by-problem briefcase** — usable when AI isn't. That only holds if a page is findable fast and a Playbook is trustworthy (real incident, real commands). A standard makes "≤ 3 clicks, on the mold, cert-grounded" auditable instead of aspirational.

---

## The requirements

Each is citable as `STD-0006 R#`. [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) carries the full mold.

### R1 — The Academy is organized in the fixed layers

Content lives in its layer, each answering one question: **Cert-maps** (what to test) · **Concepts** (why it works) · **Command-Library** (how to check) · **Playbooks** (what to do when broken) · Runbooks (deferred → automation) · **House-style** (voice).

### R2 — The 3-click rule

Every Academy doc MUST be reachable in **≤ 3 clicks** from the repo front door through exactly one middle index (root → layer index → doc). A needed 4th click is a Review Trigger.

### R3 — Playbooks are problem-named and write-when-real

A Playbook's **filename is the problem name (= a ticket title)**, it is **scenario-first**, and it is written **only when the fix is real** (device-verified or reconciled from a frozen Lab-01 incident) — never speculative.

### R4 — Playbooks follow the §5 mold

Every Playbook MUST carry the `ADR-0053` §5 elements — **Symptoms & search terms · On this page · cert anchor · pin-it-down · diagnosis with per-step `CM`/`MC` provenance · fix (+prove it) · Worked example → the fix-doc · Worked log** — command-first, pointing to the fix-owner, never inventing output. Golden reference: [`Read-the-Cert-Not-the-Sign-Log`](../../Atlas-Academy/Playbooks/Read-the-Cert-Not-the-Sign-Log.md).

### R5 — The cert-grounded spine

Every exam objective decomposes into Academy entries; the [Playbooks index](../../Atlas-Academy/Playbooks/README.md) carries a **cert-objective column** (objective → Command-Library · Playbook · Concept).

### R6 — §8 two-way checklist ↔ Playbook links

A commissioning checklist links **down** to the Playbook for a symptom-at-a-step; the Playbook links **back** to the checklist phase — one home per fact.

---

## Adopting & amending decisions

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) | Accepted (heavily amended 2026-07-31→08-01) | the Academy layers, 3-click rule, the §5 Playbook mold, §8 checklist↔Playbook, the cert spine |

(Originals in the legacy snapshot.)

## Verification (how conformance is proven)

- [ ] **R2** — every Playbook is linked from [`Playbooks/README`](../../Atlas-Academy/Playbooks/README.md) (no orphan leaf deeper than one index).
- [ ] **R4** — `grep` each `Playbooks/*.md` (except README) for `Symptoms & search terms`, `On this page`, `Worked log` — all present.
- [ ] **R3** — no Playbook describes an unbuilt/speculative fix (each anchors a real `CM`/`MC` or a device-verified state).
- [ ] **Meta** — any mold change traces to an amending ADR + `ADR-Index` bump.

## Learn it — the source of truth for the *how*

- 🧭 **What the Academy is for:** [`Academy-Vision-and-Scope`](../../Atlas-Academy/Academy-Vision-and-Scope.md) (the briefcase principle)
- 🖋️ **The voice:** [`Atlas-Teaching-Patterns-and-House-Style`](../../Atlas-Academy/Atlas-Teaching-Patterns-and-House-Style.md)
- 🔧 **The mold, worked:** [`Read-the-Cert-Not-the-Sign-Log`](../../Atlas-Academy/Playbooks/Read-the-Cert-Not-the-Sign-Log.md) (golden template) · the [Playbooks index](../../Atlas-Academy/Playbooks/README.md)
- 📋 **Program:** [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md)

## What a violation looks like

A Playbook named for a tool instead of a problem · a page 4+ clicks deep · a Playbook missing Symptoms/On-this-page/Worked-log · invented command output · a checklist step with a symptom but no Playbook link.

## Related

[`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (governing) · [`STD-0005`](./STD-0005-Device-Documentation.md) · [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md) · [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0053` into a testable standard** (#39 (B)→STD): the Academy layers, the 3-click rule, the problem-named/write-when-real Playbooks on the §5 mold, the cert-grounded spine, and the §8 two-way links — each with a grep/click-depth read-back. Cut from `STD-Template`. |
