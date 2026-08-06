# ADR-0033 — ADRs Carry a Scope (Global / Lab-01 / Lab-02) + a Scope Index

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-28). |
| Governing Policy | POL-0014 |
| Materialized as | [STD-0008 — ADR Governance & Scope](../Standards/STD-0008-ADR-Governance-and-Scope.md) · this ADR is the adopting decision; the standing requirements now live in that standard (`ADR-0054` (B)→standard) |
| Scope | **Global** — estate-wide documentation convention (applies across labs) |
| Date | 2026-07-28 |
| Supersedes | — (new convention). |
| Related | `ADR-0008` (Foundation holds process; ADRs are global-numbered), `ADR-0026` (governance framework), `ADR-0032` (diagnostics doc architecture), `Atlas-Documentation-Style-and-Conventions` (frontmatter/provenance; renamed from `Atlas-Documentation-Standards`, `ADR-0052` §7), `POL-0008` (one home per fact). |
| Evidence Status | **Decision** (operator, 2026-07-28). Applies to every ADR from now on; the backfill of ADR-0001…0032 is done in the same change. |

## Context

The ADRs live in one **global namespace** (`00-Atlas-Foundation/Decisions/`, sequentially numbered — `ADR-0008`'s "Foundation holds process" rule keeps numbering estate-wide, not per-lab). They were written when Atlas had **one lab**, so none of them says *which estate a decision applies to*. Now there are two — **Lab-01-Mikrotik-Core** (frozen) and **Lab-02-Cisco-Core** (active) — and the applicability is genuinely mixed: some decisions are Lab-01-specific (MKT01 recovery posture), some are Lab-02-specific (1941/MKT01 topology, DHCP-on-DC01), and many are estate-wide principles (the PKI-custody lesson, the NTP architecture, the governance framework). Reading an ADR today, you can't tell which — and a Lab-01 device decision shouldn't silently drive a Lab-02 build, or vice-versa. (Operator, 2026-07-28: *"Some of the decisions are for Lab-01 … I wasn't planning the next lab when the ADRs were made."*)

## Decision

**Every ADR carries a `Scope` field in its header table, and a scope+status index lists them all. Numbering stays global.**

1. **`Scope` field** — a row in each ADR's `| Item | Value |` header table, immediately after `Status`, with one of:
   - **Global** — the decision's *principle* is estate-wide (process, governance, or a technical standard that applies to any lab), **even if it was first made in a lab**.
   - **Lab-01-Mikrotik-Core** — scoped to the Lab-01 estate (its devices, its Book-1 events).
   - **Lab-02-Cisco-Core** — scoped to the Lab-02 estate.
2. **The scoping rule (operator, 2026-07-28): _"Global if the principle is estate-wide."_** A PKI-custody lesson (`ADR-0009`), an AAA boundary (`ADR-0004`), the domain suffix (`ADR-0007`), the time architecture (`ADR-0020`) — all born in Lab-01 but estate-wide in principle — are **Global**. A decision that only makes sense against one lab's specific devices/topology is scoped to that lab. A **cross-lab reversal** (e.g. Lab-01's `ADR-0003` coexist → Lab-02's `ADR-0031` retire) stays honest because each ADR carries its own scope and the `Supersedes`/`Related` fields link them.
3. **Numbering unchanged** — ADRs keep the single global sequence (`ADR-0008`); Scope is metadata, not a renumber or a move. No file is renamed.
4. **Index** — `00-Atlas-Foundation/Decisions/ADR-Index.md` lists every ADR by **Scope → number → title → status**, so "which decisions govern Lab-02?" is one lookup. (Also answers the Review-Flag-Register **B1** "no index" learnability flag for the Decisions namespace.)

## Alternatives Considered

- **Per-lab ADR folders / renumbering.** Rejected — breaks every existing `ADR-00NN` cross-reference in the repo and contradicts `ADR-0008`'s global-numbering rule. A metadata field achieves the same clarity non-destructively.
- **Scope only going forward, don't backfill.** Rejected — the ambiguity is worst on the *old* ADRs (the ones written single-lab); leaving 32 untagged defeats the point. Backfill is cheap (one header row each).
- **Two fields (Origin + Applies-to).** Considered; rejected as heavier than needed. `Scope` with the "Global if estate-wide" rule captures applicability; where a Global decision was *born* in a lab, the Context already says so.

## Consequences

- **Backfill (this change):** `Scope` added to all of ADR-0001…0032. Initial assignment: **Global** = 0003, 0004, 0007, 0008, 0009, 0010, 0011, 0012, 0015, 0018, 0020, 0024, 0026, 0032; **Lab-01** = 0001, 0002, 0005, 0006, 0013, 0014, 0016, 0017, 0019, 0022; **Lab-02** = 0021, 0023, 0025, 0027, 0028, 0029, 0030, 0031. A few were judgment calls the operator can re-tag (**0005** FGT egress, **0021** tiered identity, **0024** headcount scenario) — the index is the one place to change them.
- **New ADRs** set `Scope` at creation (add it to the ADR template/standard).
- **`ADR-Index.md`** is maintained alongside the ADRs (a new ADR adds a row); it is the navigational entry point for the Decisions namespace.

## Review Trigger

- If a third lab or a shared-services tier appears, revisit whether `Scope` needs more values than Global/Lab-01/Lab-02.
- If the index drifts from the ADRs (a new ADR not listed), tighten the "add a row when you add an ADR" habit or generate the index from the headers.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Accepted. Establishes the **`Scope` header field** (Global / Lab-01 / Lab-02) on every ADR with the **"Global if the principle is estate-wide"** rule, keeps **global numbering** (`ADR-0008`), and adds **`ADR-Index.md`** (scope→status index; answers register B1 for the Decisions namespace). Backfilled ADR-0001…0032 in the same change; flagged 0005/0021/0024 as re-taggable judgment calls. |
