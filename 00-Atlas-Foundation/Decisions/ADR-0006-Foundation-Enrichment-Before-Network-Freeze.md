# ADR-0006 — Foundation Enrichment Proceeded Before Network Freeze

| Item | Value |
|---|---|
| Status | Accepted (retroactive) |
| Governing Policy | POL-0003 |
| Scope | **Lab-01-Mikrotik-Core** |
| Date | 2026-07-13 |

## Context

The Charter's Rule 1 and Rule 10 both argue against doing Foundation-level work (Session A.5/B in the Blueprint) before Network (Book 1) is frozen. A review of an archived prior session surfaced several genuinely valuable, already-agreed-but-never-written Foundation items: a second-tier Change Management template, two Charter design requirements (DR-001, the "Future Seth" completion bar), a screenshot/callout documentation standard, and enriched historical context for ADR-0005. Implementing these now is a second instance of the same tension named in `ADR-0001`.

## Alternatives Considered

1. **Hold everything until Network is frozen**, strictly per the Blueprint's session ordering. Rejected — these items are small, additive, and don't touch any active pack's structure or content; deferring them risks losing them the same way the original material sat unused in an old chat export for weeks.
2. **Implement everything found in the archived session review**, including the heavier per-topic page structure and the full lab-material mining. Rejected — already flagged as a genuine rabbit hole in the findings report; would be real scope creep, not a small addition.
3. **Implement only the items that are purely additive** — new template files, new Charter sections, enrichment of an already-open ADR — and explicitly exclude anything that would require touching or restructuring existing pack content. Chosen.

## Decision

Proceed with: the Major Change Record Template, the two-tier Change Management explanation, DR-001 and the completion-bar addition to the Charter, the Screenshot/Callout standard addition to Documentation Standards, the ADR-0005 historical enrichment, and formalizing the three-tier checklist framework in the Book 6 seed (framework only, not the checklists themselves).

Explicitly **not** doing right now: mining the archived school lab material into Book 3/4 content, adopting the elaborate per-topic page structure, or building any actual device checklists — those remain Session A.5/B/C work, done after Network freeze.

## Rationale

The test applied: does this change require touching, restructuring, or adding meaningful new content to any pack that's currently active (Network)? If no — it's a Foundation-only addition — it's safe to do without violating the spirit of "one pack at a time," since it doesn't create parallel unfinished work inside Book 1. If yes, it waits.

## Consequences

- Future sessions should apply the same test before treating "Foundation work" as automatically exempt from the freeze-first rule — this is a narrow, reasoned exception, not a general license.
- The Blueprint's Session A.5/B still stand for everything that didn't pass this test.

## Review Trigger

If this pattern gets invoked a third time, it's worth writing the test itself into the Charter as an explicit rule, rather than re-justifying it per ADR each time.
