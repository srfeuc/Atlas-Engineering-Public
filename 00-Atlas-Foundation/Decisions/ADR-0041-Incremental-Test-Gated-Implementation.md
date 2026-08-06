# ADR-0041 — Incremental, Test-Gated Implementation

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29). Estate build discipline. |
| Governing Policy | POL-0015 (+POL-0006) |
| Materialized as | [STD-0010 — Incremental, Test-Gated Build](../Standards/STD-0010-Incremental-Test-Gated-Build.md) · this ADR is the adopting decision; the standing requirements now live in that standard (`ADR-0054` (B)→standard) |
| Scope | **Global** — how every build/change in the estate is executed and proven. |
| Date | 2026-07-29 |
| Supersedes | — (names/elevates an existing practice to an estate rule) |
| Related | `POL-0006` (Evidence & Verification — the read-back requirement this sequences) · `POL-0001` (the device is the source of truth) · `ADR-0037` (the Build-Checklist + its acceptance gate) · `ADR-0032` (Diagnostics) · `Operations/Validation-and-Adversarial-Testing.md` (the adversarial/negative-test home) · `Devices/MKT01-East-West-Firewall/Incremental-East-West-Firewall-Build-Worksheet.md` (the worked exemplar). |
| Governing docs | `Atlas-Documentation-Workflow.md` (the build moments) · every device `Build-Checklist.md`. |
| Evidence Status | **Decision** (operator, 2026-07-29). Governs process; builds nothing itself. |

## Context

The estate's failure history is not mostly "we picked the wrong design" — it is "we changed several things at once and then could not tell which one broke it." `POL-0006` already fixes *evidence quality* (every change ends with a read-back; a tick needs command + output; check the wire **and** the file). What it does **not** state is the **sequencing** rule.

The operator already runs the correct pattern on the east-west firewall — implement **one** rule, test it with real machines (the allowed pair succeeds; the disallowed pair is refused **and** logged), and only then move to the next rule. The ask (2026-07-29) is to make that the estate-wide default — "nothing is implemented and not tested somehow" — so it applies to GPO rollout, PKI, segmentation, Intune, and every future build, not just MKT01. This ADR names the rule.

## Decision

**Every build and change is implemented in the smallest testable unit, and each unit's acceptance test must pass before the next unit begins.** Load-bearing choices:

1. **One unit at a time.** A *unit* is one firewall rule, one GPO, one CA template, one share/ACL, one role/service — never a batch. No big-bang cutover.
2. **Each unit carries an explicit acceptance gate** in its `Build-Checklist.md`: the **positive** test (it does what it should) and, when the unit is a control, the **negative** test (the thing it must block is blocked) — both captured per `POL-0006` (command + output; wire *and* file).
3. **A unit is not ✅ until its gate passes.** It stays 🟡/📋 until the read-back exists (`POL-0001`). A failing or un-run gate **stops the sequence** — you fix or roll back that unit; you do not proceed past it.
4. **Adversarial gates live in the Validation matrix.** When the unit is a security control, its negative test is a row in `Operations/Validation-and-Adversarial-Testing.md` (control → attack → evidence); the device links to its rows rather than restating them (`POL-0008`).
5. **Rollback is per-unit.** Because units are small and proven in isolation, a failure is localized and reversible — which is exactly what makes incremental building safe.

## Alternatives Considered

- **Rely on `POL-0006` alone.** Rejected — POL-0006 governs *evidence per change*; it does not require small units or a test-gate-before-proceed *sequence*. The two are complementary, not redundant.
- **Big-bang, then verify at the end.** Rejected — this is the documented failure mode (five false ticks in one session; the "which of the twelve rules broke reachability?" problem the E-W worksheet exists to avoid).
- **Leave it an informal habit (the MKT01 worksheet only).** Rejected — an unwritten habit is skipped under time pressure and doesn't transfer to a successor; the operator wants it applied estate-wide.
- **A new policy instead of an ADR.** Considered — it *elevates* `POL-0006`/`POL-0001` and Charter Rule 8; recorded as an ADR (a decision with alternatives) and cross-linked to those policies rather than duplicating them.

## Consequences

- **Build-Checklists are authored as ordered, per-unit steps, each with its own acceptance gate** — not a wall of actions with a single gate at the end. (The DC/PKI/SRV01 checklists already trend this way; the standard makes it explicit, and the per-device Build-Checklist template gains a per-step gate column/line.)
- **The Validation matrix is the estate's negative-test home** — every control unit gets a control→attack→evidence row, and each device's page links to its rows. This is where "what traffic is blocked/allowed" is *proven*, one flow at a time.
- **Slower to "done", faster to "trustworthy."** More gates = more read-backs = more evidence a successor can rebuild and trust — the successor-readiness goal.
- **Traffic-flow understanding falls out of the discipline** — proving each allowed/blocked flow one at a time is how the per-device + estate **traffic-flow diagrams** (the Phase-1 documentation element) get filled in cell by cell instead of asserted.

## Review Trigger

- If per-unit gating measurably stalls genuinely low-risk bulk work (e.g., linking one identical GPO to 50 client objects), a **documented** batch with one representative positive test + a spot-check is allowed — but the per-unit gate stays the default, and the batch exception is recorded on the checklist.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Accepted. Names the estate's **incremental, test-gated** build discipline: one unit at a time; each unit's acceptance gate (positive + negative test, `POL-0006` evidence) must pass before the next; ✅ only on a passing gate; adversarial gates live in the Validation matrix; per-unit rollback. Elevates the MKT01 east-west one-rule-at-a-time pattern to a Global rule and complements `POL-0006` (evidence) with the missing *sequencing* rule. |
