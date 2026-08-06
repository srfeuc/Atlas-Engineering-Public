---
Title: Foundation Overhaul — Execution Brief (Backlog #41)
Path: 00-Atlas-Foundation/Governance
Status: ✅ **DONE** (`ADR-0012`) — the #41 structural overhaul is COMPLETE (session 31, 2026-08-03). Kept as the historical execution record; **do not re-run.** The turnkey what/where/order for the `00-Atlas-Foundation` structural overhaul + the `Atlas-Academy` rename. The durable *how-to* is `AI-Context/Foundation-Restructure-Playbook.md`; this is the concrete file-by-file plan. Retire with a ✅ DONE banner (`ADR-0012`) when complete.
Version: 1.0
Date: 2026-08-03
---

# Foundation Overhaul — Execution Brief (`#41`)

> ✅ **DONE — 2026-08-03 (session 31).** This overhaul is complete and committed: **Piece A** (loose Foundation-root files → `Documentation/`·`Reference/`·`Public-Release/`·`Governance/`, VM-inventory → `99-Archive/`) · **Piece B** (`09-` → `Atlas-Academy`, 542 refs) · **`Atlas-Academy/Certification/`** (operator add — the 7 cert tracks) · **Piece C** (Foundation `README` rebuilt around the situation/role findability router; `99-Archive` organized with a signpost). Gates: G1 overhaul-first-then-push · G2 Academy-only · G3 Charter→`Governance/` · G4 archive frozen. 0 new broken links throughout. This page is preserved as history (`ADR-0012`); the durable how-to remains `AI-Context/Foundation-Restructure-Playbook.md`. **Successor brief (the #41 follow-ons):** [`Policy-Golden-Reshape-and-Concepts-Brief.md`](./Policy-Golden-Reshape-and-Concepts-Brief.md).

> 🤖 **You are the next session, doing the Foundation *structural* overhaul.** The governance **content** (policies + standards) is already done and correct (Stage 1, session 30) — **this pass changes *where things live and how they link*, not what they say.** It is a large, high-precision **link rewrite**; go slowly, verify every move.

## 0. Orient first (cold start)

**Read-order (do this before touching anything):**
1. `AI-Context/README.md` + `What-To-Check-First.md` — the estate map + the house rules.
2. [`SESSION-HANDOFF.md`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) — the `📍 CURRENT STATE` + latest block.
3. **This brief** — the plan. It operationalizes Backlog **#41** (read that item in full).
4. `AI-Context/Foundation-Restructure-Playbook.md` — the durable how-to (phases, guardrails).

**House rules, in one breath:** docs-only · **Seth runs all git** (you write files + print a PowerShell block; never `git add .`; LF). Evidence over intent. **One home per fact; point, don't copy.** Never a live secret. **Plan → ask at planning → one piece at a time → refresh the handoff after each.** Bridge-down = say so loudly. **Preserve history (`ADR-0012`) — retire with a banner, never delete; `git mv` keeps history.**

🔴 **Single-writer session** — no parallel agent editing the Foundation during this (moves collide). Plan a **full link re-check at the end** (the CI link-check + a tree `git grep`).

## 1. The north star

> **Anyone finds the rule/decision that governs their situation and acts — fast, self-service, no manager.** A clean, navigable Foundation; the findability layer as its spine; **nothing lost**. The published form is a future Atlas website.

## 🔴 Phase 0 — the gates (operator decisions; settle these before moving a file)

| # | Decision | Options | Recommendation |
|---|---|---|---|
| **G1** | Public push **before or after** the overhaul? | (a) push the current clean state, overhaul after · (b) overhaul, then push | **(a)** — a reorg reopens the navigation/links you just cleaned for release (`ADR-0010`); lock the release first, then reshape. |
| **G2** | Rename scope | (a) **Academy only** (`09-` → `Atlas-Academy`; keep `00-`/`99-`) · (b) drop numbers on **all three** tops | **(a)** — `00-`/`99-` sort the tree top→bottom; Academy is the one whose number reads as clutter. |
| **G3** | Where does the **Charter** anchor? | root (stays) · `Governance/` | operator call — it's constitutive (above governance), so **root** is defensible; `Governance/` is tidier. |

## 2. Phase A — reorganize the loose Foundation-root files

Move each loose root `.md` into a folder; **`git mv` preserves history**, then rewrite inbound links. Counts are **inbound `.md` references** (the link-rewrite size per file).

| File (at `00-Atlas-Foundation/` root) | → New home | Inbound refs | Note |
|---|---|---|---|
| `Atlas-Documentation-Standard.md` | **`Documentation/`** | 27 | the per-device doc architecture (`STD-0005`/`ADR-0037`) |
| `Atlas-Documentation-Style-and-Conventions.md` | **`Documentation/`** | 15 | writing style / secrets rule |
| `Atlas-Documentation-Workflow.md` | **`Documentation/`** | 15 | write→verify→publish→freeze |
| `Contributing-Adding-Docs.md` | **`Documentation/`** | 21 | where a doc goes |
| `Atlas-Firewall-Architecture.md` | **`Reference/`** (or `Security-Program/`) | **45** ⚠ | biggest blast radius — rewrite carefully |
| `Atlas-Public-Release-Sanitization-Plan.md` | **`Public-Release/`** | 6 | pairs with `ADR-0010` |
| `Public-Release-Manifest.md` | **`Public-Release/`** | 2 | — |
| `VM-and-Services-Inventory.md` | **`99-Archive/`** (+ a pointer) | 30 | already **RETIRED** (`ADR-0036` v1.3); most refs are historical/annotation — verify each before repointing |
| `Atlas-Charter.md` | **root** or `Governance/` (G3) | — | decide at Phase 0 |
| `README.md` | **stays** (redone — see Phase C) | — | the front door |

Folders that **stay**: `AI-Context/` · `Decisions/` · `Policies/` · `Standards/` · `Templates/` · `Governance/` · `Roadmap/` · `Security-Program/` · `Company-Profile/`.

## 3. Phase B — the `Atlas-Academy/` → `Atlas-Academy/` rename (if G2 = a)

**Blast radius: ~160 tracked `.md` files** contain the string `Atlas-Academy` — **60 in `Labs/`, 53 Academy-internal, 26 in `00-Atlas-Foundation/`** (incl. the 12 STDs + the router + AI-Context), 16 in `99-Archive/`, 5 root front-doors.

**Mechanics (operator runs git; you provide the edits + the block):**
1. **Operator:** `git mv Atlas-Academy Atlas-Academy` (one move, history preserved).
2. **Rewrite the links:** replace `Atlas-Academy/` → `Atlas-Academy/` across all **live** tracked `.md`. Do this as a **scripted** pass (a `sed`/PowerShell one-liner the operator runs, or edit via `device_bash` on the working tree), never 160 hand-edits. Also catch prose mentions (`Atlas-Academy` without a trailing slash).
3. 🔴 **The `99-Archive/` question:** those 16 files are frozen history. The folder genuinely moved, so their links would 404 — but "correcting" frozen citations is normally forbidden (`ADR-0012`). **Decide once:** either rewrite them too (the path really changed — recommended, it's a path not a claim) **or** leave them and exclude `99-Archive/` from the link-check as known-historical. Record the choice.
4. **Verify:** `git grep -n "Atlas-Academy"` → **0 outside the chosen exclusions**; the CI link-check is green.

## 4. Phase C — the findability README + the archive

1. **Redo the Foundation [`README.md`](../README.md)** around the **situation/role findability model** — the `AI-Context/Situation-Router.md` is the first cut and the intended **spine**; promote it (a human opens the Foundation, picks their situation/role, lands on the governing doc). Wire it from the root [`README`](../../README.md) + [`INDEX`](../../INDEX.md).
2. **Organize `99-Archive/`** into a described, navigable structure — the [`Decisions/Legacy-ADR-Index.md`](../Decisions/Legacy-ADR-Index.md) (built session 30) is the model; give the rest of the archive the same signposting. **Nothing is deleted.**
3. Confirm the **registers** ([`Policies/README`](../Policies/README.md) · [`Standards/README`](../Standards/README.md)) and the **[`Atlas-Source-of-Truth`](./Atlas-Source-of-Truth.md)** router still resolve after the moves (they link many of the moved files).

## 5. Per-move recipe (repeat for every move / the rename)

1. **Operator** `git mv` the file/folder (history preserved).
2. **Scripted link rewrite** of the old path → new path across live `.md`.
3. `git grep` the **old** form → **0 outside `99-Archive`** (or the recorded exclusion).
4. Update the maps that name structure: [`INDEX.md`](../../INDEX.md) · Foundation [`README`](../README.md) · `AI-Context/Directory-Map` · [`Contributing-Adding-Docs`](../Documentation/Contributing-Adding-Docs.md).
5. **CI link-check green** (`.github/workflows/atlas-checks.yml`).
6. Refresh [`SESSION-HANDOFF`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) + tick this brief; print the commit block for Seth.

## 6. Done when

- [ ] Phase-0 gates decided (G1/G2/G3) and recorded.
- [ ] Loose root files moved to their folders; every inbound link rewritten; `git grep` old paths = 0 (outside archive).
- [ ] `09-` → `Atlas-Academy` (if G2=a): 0 stale references; CI green.
- [ ] Foundation `README` rebuilt around the findability router; `99-Archive` organized.
- [ ] The 12 STDs + 16 POLs + the router + AI-Context all resolve (0 broken).
- [ ] `INDEX` · Directory-Map · Contributing updated; handoff + Backlog #41 refreshed.
- [ ] This brief retired with a ✅ DONE banner (`ADR-0012`).

## Related

Backlog **#41** ([`Atlas-Improvement-Backlog`](../Roadmap/Atlas-Improvement-Backlog.md)) · `AI-Context/Foundation-Restructure-Playbook` (durable how-to) · `AI-Context/Situation-Router` (the findability spine) · [`Governance-Reconciliation-Triage`](./Governance-Reconciliation-Triage.md) (the #39 sibling, now done) · [`ADR-0010`](../Decisions/ADR-0010-Atlas-Repository-Publication-Preconditions.md) (publication gate) · [`ADR-0012`](../Decisions/ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md) (preserve).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. Turnkey execution brief for #41 — the Phase-0 gates (public-push · rename-scope · Charter), the per-file disposition table (with real inbound-ref counts), the `Atlas-Academy` rename plan (~160-file blast radius + the 99-Archive nuance), the findability-README + archive phase, the per-move recipe, and done-when. Written session 30 so a fresh single-writer session picks up #41 cold. |
