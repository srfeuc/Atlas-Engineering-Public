# ADR-0024 — Atlas Industrial IT Headcount: Eight in the Scenario, One at the Keyboard

| Item | Value |
|---|---|
| Status | **Proposed** |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-17 |
| Related | `301-Atlas-Company-Profile.md` (IT: 8), `303-Windows-Design-Standards.md` (IT: 1), `ADR-0008` (flagged this as needing an ADR, not a silent overwrite), `ADR-0018` (silos are roles, not people), `ADR-0021` (tiered identity) |
| Governing Policy | *(none yet — candidate once the Governance Framework is adopted)* |
| Evidence Status | **`Target Design`** — a scenario decision; the company is fictional. |

> **This settles a conflict `ADR-0008` explicitly refused to resolve silently.** `303`'s reconciliation notes flagged it: *"This is a real decision and needs an ADR, not a silent overwrite."* No ADR was ever written. This is it.

## Context

The bound scenario disagrees with itself on how many IT staff Atlas Industrial has:

- **`301` says IT: 8** — and builds its whole identity lab on it: the Tier 0/1/2 split, delegated helpdesk scoped to one OU, AGDLP, "twenty-plus accounts for eight humans." **None of that is teachable with one admin.**
- **`303` says IT: 1** — arguing, correctly, that ~1–3 IT per 100 employees is realistic at this size, that *solo IT is itself realistic, not a simplification*, and that **a 150-person company with one IT person is exactly the company that hires an MSP.**

Both are right about different things, which is why `ADR-0008` refused to overwrite one with the other and demanded a decision on the record.

`ADR-0018` (accepted 2026-07-17) now supplies the lens that dissolves the conflict: **"The silos are roles, not people. You will play all of them."** The same distinction applies to the fiction.

## Alternatives Considered

1. **Take `303`'s IT: 1.** Rejected — it makes the identity lab's entire point (tiering, delegation, AGDLP, the Tier-0 test) unteachable. The scenario exists to force those design decisions; one admin forces none of them.
2. **Silently keep `301`'s IT: 8 and delete `303`'s note.** Rejected — that is the exact "silent overwrite" `ADR-0008` forbade, and it throws away `303`'s genuine insight (the MSP premise).
3. **Split the concept: 8 *roles* in the fiction, 1 *operator* at the keyboard, and preserve the MSP framing.** Chosen.

## Decision

**The fictional Atlas Industrial employs 8 IT staff (`301` stands).** This is the scenario headcount, and every downstream identity design — tiering, delegation, AGDLP, the Helpdesk-can't-touch-Tier-0 test — is sized against it.

**`303`'s "IT: 1" is retired as the company headcount** — superseded by `301` for scenario purposes — **but its two truths are preserved, not discarded:**

1. 🔵 **The real Atlas homelab is operated by one person playing all silos** (`ADR-0018`). Eight *roles*, one operator. The fiction's 8 humans and the lab's 1 human are not in conflict; they are the scenario and the operator of it.
2. 🟡 **The MSP premise is kept as scenario colour:** *a 150-person manufacturer with a thin IT team is exactly who engages an MSP* — which is the frame for the advanced/MSP scenarios (`Atlas-Roadmap-Advanced-Scenarios.md`). It is a story about Atlas's *relationship to outside help*, not about its headcount.

## Rationale

The headcount only matters because it decides what the lab can *teach*. Tiering, delegated administration, and AGDLP are the identity lab's core lessons, and they are meaningful only when there are enough distinct roles to separate — which `301`'s 8 provides and `303`'s 1 cannot. `ADR-0018` already established that Atlas deliberately manufactures role boundaries a solo operator would otherwise skip; adopting 8 IT *roles* in the fiction is the same move, one layer out. Nothing of `303`'s argument is lost: solo operation is true of the *lab*, and the MSP framing is true of the *scenario's* market position.

## Consequences

- **`303` must be corrected on the move/reconcile:** its "IT: 1" line is updated to point here, noting `301`'s 8 is the scenario headcount and this ADR records why. (Per Charter Rule 16, verify the old "IT: 1" claim is *gone*, not merely annotated.)
- **`301`'s IT table (Tier 0/1/2, 20+ accounts for 8 humans) is authoritative** for the OU/group/tiering design.
- **The operator-is-one framing (`ADR-0018`) governs how the lab is *built*;** the eight-roles framing governs what the *fiction* contains. Documents should not conflate "who works at Atlas Industrial" (8) with "who operates the Atlas lab" (1).
- **The MSP scenario keeps its premise** without needing the company to have only one admin.

## Review Trigger

- If the identity lab's scope changes such that tiering/delegation are dropped, revisit whether 8 is still warranted.
- If an MSP/multi-tenant scenario is built, confirm this ADR's MSP-premise framing still matches it.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-17. Resolves the `301` (IT: 8) vs `303` (IT: 1) conflict that `ADR-0008` flagged and left open. Decision: 8 IT *roles* in the fiction (`301` stands, retires `303`'s headcount), 1 operator playing all silos in the lab (`ADR-0018`), MSP premise preserved as scenario framing. |
