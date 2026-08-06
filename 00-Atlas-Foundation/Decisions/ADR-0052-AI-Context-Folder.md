# ADR-0052 — The AI-Context Folder (a Durable Onboarding Map for AI Sessions)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-31) — home, name, pointer-rule, and reconciliation direction resolved at planning (`ADR-0049` ask-at-planning norm). |
| Governing Policy | POL-0014 |
| Scope | **Global** — an estate-wide onboarding/legibility artifact; every lab and every future AI session inherits it. |
| Date | 2026-07-31 |
| Amends / builds on | **Extends `ADR-0049`** (the `SESSION-HANDOFF` Living-STATE protocol) — this folder is the *durable* layer that sits **above** the per-session handoff · **applies `POL-0004`** (one source of truth; pointers, not copies) · **applies `POL-0008`** (one home per fact). |
| Related | `ADR-0049` (handoff protocol) · `ADR-0037` (Documentation Standard) · `ADR-0032` (Diagnostics/Command-Library) · `POL-0001` (Audit Policy) · `POL-0004` (Source of Truth) · `POL-0006` (Evidence) · `Atlas-Improvement-Backlog` **#31** (the originating ask) · `#30` (Academy development) · `#19` (self-hosted git/CI — the home for *runnable* tooling). |
| Evidence Status | **Structure decision** — the folder + its first-slice contents are authored this session; this ADR is their rationale home. |

## Context

A fresh AI session (or a returning human) currently has to **spelunk the tree** to orient: there is a strong front door (root `README.md`), a strong "where we are now" (`SESSION-HANDOFF.md`, `ADR-0049`), a strong Foundation index, and a strong per-device Standard — but no single place that says, to a *machine reader specifically*, "here is the map, here is what to read first, here is how to navigate the 50+ ADRs, here is how we document, and here is how we run our audits." The operator named the gap directly (Backlog **#31**, 2026-07-31):

> *"We need to get a Claude folder going that makes the AI not have to work as hard to find and reconcile things. We need a ton of context storage, pointers to useful files, ADR navigation, what to check first, a map of the directory, how to document"* — and (mid-planning) *"they should store ways to do audits."*

The tension this ADR resolves: a curated context pack is high-value, but a pack that **copies** content from the docs it points at will **drift** — which is precisely the failure class `POL-0004`/`POL-0008` exist to prevent (`006`'s silently-wrong table; three-handoff mysteries). So the folder must be built as **pointers + genuinely-new navigation content**, never as duplicated source-of-truth.

The folder is also **not** the handoff. `ADR-0049`'s `SESSION-HANDOFF` owns *where we are right now* (a living STATE that changes every session). This folder owns *the durable onboarding map* (how the estate is shaped and governed — changes only when the estate's structure/governance changes). Keeping those two concerns in two homes is itself a `POL-0008` application.

## Decision

Adopt a dedicated **AI-Context folder** with the following shape and rules (Global).

### 1. Home and name
The folder lives at **`00-Atlas-Foundation/AI-Context/`** — inside the Foundation, so it rides the estate's existing "everything cross-lab lives in the Foundation" placement rule (`Contributing-Adding-Docs.md`) and its governance, rather than as a vendor-named top-level folder. (Working name in #31 was `Claude/`; the vendor-neutral `AI-Context/` was chosen so the pack serves *any* AI session, not one product.)

### 2. Pointers, not copies — plus genuinely-new navigation content (`POL-0004`)
Two kinds of content are allowed, and only two:
- **Pointers** — for anything **owned elsewhere**, the entry is a **link + a one-line "why this matters to a session"** note. It never restates the target's content (`POL-0004`/`POL-0008`). If the target moves, the pointer is updated; the fact is never copied.
- **New navigation content** — synthesized orientation material that **lives nowhere else**: the annotated directory map, the "what to check first" read-order, the ADR-navigation guide, the "how we document" digest, and the audit playbooks. This is the "context storage" the operator asked for. Where such a page needs a fact that *is* owned elsewhere (an IP, a decision, a command), it **links** to the owner instead of restating it.

Curated multi-paragraph **summaries** of other docs are explicitly **out of scope** — they are the drift class this rule exists to avoid.

### 3. First-slice contents
```
00-Atlas-Foundation/AI-Context/
├── README.md               # the start-here front door for an AI session — read this first
├── Pointers.md             # the categorized pointer set (link + one-line "why it matters to a session")
├── Directory-Map.md        # annotated map of the repo tree — what lives where, and who owns which fact
├── What-To-Check-First.md  # the orientation runbook: read-order + the house rules (docs-only · Seth runs git · evidence discipline)
├── ADR-Navigation.md       # how to navigate the ADRs: the index, supersession chains, how to add one
├── How-To-Document.md      # the "how we document" digest — pointers to the Standard/Style/Workflow/Contributing + the core rules
└── Audit-Playbooks.md      # "ways to do audits" — the repeatable audit procedures the estate runs (POL-0001)
```
The set grows in later slices (the operator has additional files/ideas to fold in; the Academy Linux section and tools/scripts are a separate #31(b)/#30 track).

### 4. Refresh rule (in the spirit of `ADR-0049`)
The AI-Context folder is a **durable onboarding map, not a living STATE.** It is **not** updated every session and it **never** records "where we are now" (the handoff owns that — no overlapping fact, `POL-0008`). It is refreshed **when the estate's structure or governance changes**: a top-level folder or governing doc is added/moved/renamed, a new policy/standard is adopted, or the ADR-navigation shape changes. Treat `README.md` + `Directory-Map.md` like the Foundation index — **regenerate when the tree changes**. Each page carries a frontmatter `Status`/`Date` so staleness is visible.

### 5. Runnable tooling lives elsewhere; this folder points at it
Per `ADR-0048` and Backlog **#19**, **runnable** code (scripts, playbooks, CI) is owned by the estate automation capability (the self-hosted git/CI on CNT01) and by each device's `Automation/` folder. The AI-Context folder holds **pointers to that tooling and procedural playbooks** (e.g. the audit playbooks, which are *procedures*, not programs) — it is **not** a code home. This keeps the #31 "tools/scripts" ask on its correct owner and avoids a second code home.

### 6. Relationship to the `SESSION-HANDOFF` (no overlap)
`AI-Context/` = the **durable map** (read once to orient; how the estate is shaped and governed). `SESSION-HANDOFF.md` = the **living STATE** (read every session for where-we-are, `ADR-0049`). The folder's `What-To-Check-First.md` **points at** the handoff as step 1 of the read-order; it does not duplicate its content.

### 7. Reconcile the Documentation-Standard(s) name collision (direction set here; executed as a follow-on slice)
`Atlas-Documentation-Standard.md` (singular, v1.7, `ADR-0037`) and `Atlas-Documentation-Standards.md` (plural, v3.0) are **not duplicates** — they are a legitimate split (per-device **architecture** vs doc **writing/formatting style**) with a colliding name. Decision: **keep the split, rename the plural** to `Atlas-Documentation-Style-and-Conventions.md`, fix its stale frontmatter (`Path: Infrastructure/Network Architecture`), and cross-link the two. Only **live** references are repointed; **historical citations of the frozen Lab-01 `018-Atlas-Documentation-Standards.md`** (in CM-0014/0019/0026, POL-0001's history, ADR-0010/0012 Related lines) are **left intact** — rewriting them would corrupt the `CM-0014` audit trail (`ADR-0012`: quarantine/preserve, don't erase history).

## Alternatives Considered
- **A top-level `Claude/` or `AI/` folder.** Considered (both were offered at planning). Rejected in favour of `00-Atlas-Foundation/AI-Context/` — the operator chose to keep it under Foundation governance rather than as a prominent vendor-named peer to `Labs/`.
- **Pure pointers, no new content.** Rejected — thin; an AI still has to assemble the directory map, read-order, and ADR-navigation itself every time, which is the labour this folder exists to remove.
- **Rich curated summaries of each target doc.** Rejected — the summaries drift from their sources (`POL-0004`), reintroducing the exact defect class the estate keeps hitting.
- **Fold the pack into the existing handoff or Foundation README.** Rejected — the handoff is a living STATE (`ADR-0049`) and the Foundation README is a human section-index; neither is a machine-first onboarding map, and overloading them blurs `POL-0008` ownership.
- **Merge the two Documentation-Standard docs into one.** Considered (offered at planning). Rejected — they cover different things; merging loses the clean architecture-vs-style separation. Renaming kills the name collision without losing the split.

## Consequences
- A new `00-Atlas-Foundation/AI-Context/` folder (7 files this slice) becomes the machine-first onboarding map.
- `Decisions/ADR-Index.md` gains this row (Global) + a version bump (**v1.22 → v1.23**).
- `00-Atlas-Foundation/README.md` gains an `AI-Context/` entry in the tree so a human can find it too.
- `Atlas-Improvement-Backlog` **#31(a)** advances from *capture-only* to *first slice built*; #31(b)/(c) (Academy Linux section, tools/scripts, ops-knowledge base) remain their own track.
- **Follow-on slice (this session, separate commit):** execute the §7 rename of the plural Documentation-Standards doc and repoint the live references.
- `SESSION-HANDOFF.md` STATE + a new session block record the folder's creation.

## Review Trigger
Revisit this ADR if: the estate adopts a top-level AI folder after all (re-home); the folder starts **copying** content from its pointer targets (drift — tighten §2); the folder begins tracking "where we are now" (overlap with the handoff — re-fence §6); or runnable code lands here instead of in the #19 capability / device `Automation/` (re-fence §5).
