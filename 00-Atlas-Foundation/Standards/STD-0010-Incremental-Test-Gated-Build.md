---
Title: STD-0010 — Incremental, Test-Gated Build Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0015` via `ADR-0041`. In force.
Version: 1.0
---

# STD-0010 — Incremental, Test-Gated Build

> **At a glance.** Build one unit at a time — one firewall rule, one GPO, one CA template — each with an explicit acceptance gate in its checklist; a unit isn't ✅ until its read-back passes, and a failed or un-run gate stops the sequence. No big-bang cutovers.

| Item | Value |
|---|---|
| Layer | **Standard** — how every build/change is executed and proven; binds every Build-Checklist |
| Governing policy | [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) — Engineering & Build Discipline (+ [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) evidence) |
| Requirement, in one line | One unit at a time · an acceptance gate per unit · no ✅ without the read-back · a failed gate stops the line |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0041`](../Decisions/ADR-0041-Incremental-Test-Gated-Implementation.md) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Detailed spec | every device [`Build-Checklist.md`] + the [`Validation-and-Adversarial-Testing`](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md) matrix |
| Applies to | every build/change on every device |
| Feeds / fed by | **feeds** [`STD-0011`](./STD-0011-Phased-Build-Guides.md) (the phase GATE makes this explicit) + [`STD-0012`](./STD-0012-Automation-and-IaC.md) (the idempotency gate) · **fed by** [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | CI/CD test-gating · change-management · `POL-0006` evidence |

---

## Scope & applicability

Binds the *sequencing* of build/change work — the unit size, the per-unit gate, and the stop-on-fail rule. It is the missing "how fast, in what order" rule that pairs with `POL-0006`'s "what counts as proof."

**Boundary with adjacent standards:** *what counts as evidence* is [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) / [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md); *the phase structure of a Build-Guide* is [`STD-0011`](./STD-0011-Phased-Build-Guides.md); this standard owns the *unit granularity + the gate*.

## Why a standard, not left in a guide

The estate's rule is "large bulks get me in trouble." A batch cutover hides which change broke things; a proven-in-isolation unit makes a failure localized and reversible. This standard makes "one unit, gated, stop-on-fail" auditable — it's the discipline behind the MKT01 one-rule-at-a-time firewall build.

---

## The requirements

Each is citable as `STD-0010 R#`.

### R1 — One unit at a time

A **unit** = one firewall rule / one GPO / one CA template / one share-ACL / one role-service — never a batch, never a big-bang cutover.

### R2 — Each unit carries an explicit acceptance gate

The unit's [`Build-Checklist.md`] step MUST carry its **positive test**, plus — when the unit is a **control** — its **negative test** (the thing it should block), each captured per `POL-0006` (command + output; wire *and* file).

### R3 — Not ✅ until the gate passes; a failed gate stops the line

A unit stays **🟡/📋 until its read-back exists** (`POL-0001`); a **failing or un-run gate blocks the sequence** — fix or roll back that unit before proceeding.

### R4 — Adversarial gates live in the Validation matrix

A security control's negative test is a **control → attack → evidence** row in [`Validation-and-Adversarial-Testing`](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md); device pages **link**, never restate (`POL-0008`).

### R5 — Rollback is per-unit

Because each unit is small and proven in isolation, a failure is **localized and reversible** — roll back the one unit, not the wave.

---

## Adopting & amending decisions

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0041`](../Decisions/ADR-0041-Incremental-Test-Gated-Implementation.md) | Accepted | elevated one-unit-at-a-time + the per-unit gate + stop-on-fail to a Global rule |

(Originals in the legacy snapshot.)

## Verification (how conformance is proven)

- [ ] **R2** — `git grep` each device `Build-Checklist.md`: every build step carries its own acceptance gate (positive; + negative for controls).
- [ ] **R3** — no step is ✅ without a `POL-0006` read-back (a bare ✅ is a finding → downgrade 🟡).
- [ ] **R4** — every security-control negative test resolves to a row in [`Validation-and-Adversarial-Testing`](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md).
- [ ] **Meta** — a change touching >1 unit is split into gated steps.

## Learn it — the source of truth for the *why* + the how

- 🎓 **Concept (why):** [`A Completed Command Is Not Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md)
- 🔧 **Worked example:** the [MKT01 incremental east-west firewall worksheet](../../Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/Incremental-East-West-Firewall-Build-Worksheet.md) (one rule, one gate, at a time)
- 🛡️ **The adversarial matrix:** [`Validation-and-Adversarial-Testing`](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md)
- 📋 **Program:** [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) · [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md)

## What a violation looks like

A batch of firewall rules pushed together · a ✅ with no read-back · a control with no negative test · proceeding past a failed/un-run gate · a wave-wide rollback because units weren't isolated.

## Related

[`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) / [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) (governing) · [`STD-0011`](./STD-0011-Phased-Build-Guides.md) · [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md) · [`ADR-0041`](../Decisions/ADR-0041-Incremental-Test-Gated-Implementation.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0041` into a testable standard** (#39 (B)→STD): one-unit-at-a-time, the per-unit acceptance gate (positive + negative), stop-on-fail, the adversarial-matrix home, per-unit rollback — each with a `git grep`/evidence read-back. Cut from `STD-Template`. |
