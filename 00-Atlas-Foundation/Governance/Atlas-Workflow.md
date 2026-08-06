---
Title: Atlas Workflow — How Work Gets Done and Verified
Path: 00-Atlas-Foundation/Governance
Status: 🟢 Living — the page lifecycle, the source-priority rule, and the governance change loop.
Version: 3.2
Date: 2026-08-03
---

# Atlas Workflow — How Work Gets Done and Verified

> **The one rule that outranks the rest:** when two sources disagree, **the higher one wins — and observation beats intent.** A live device beats a config export beats a record beats a *guide*. Read §1 before anything else; every stale-doc defect Atlas has ever had came from getting this backwards.
>
> 🔗 **Paired with the [Source-of-Truth router](./Atlas-Source-of-Truth.md).** This page is *how* work gets done and verified; the router is *where* everything lives. Need a doc, device, or rule? → the router. Doing the work? → you're in the right place.

## On this page

1. [Source priority](#1-source-priority--read-this-first) — 🔴 **read this first**
2. [The page lifecycle](#2-the-page-lifecycle) — plan → write → verify → freeze
3. [Evidence status](#3-evidence-status) — what kind of claim a page makes
4. [Change closeout](#4-change-closeout) — a change isn't done until the guides are reconciled
5. [Governance change workflow](#5-governance-change-workflow) — fold a policy / reconcile an ADR
6. [Git workflow](#6-git-workflow) — commits + placing files
7. [The deferred-work rule](#7-the-deferred-work-rule) — stop writing process, go build
8. [Why written rules keep failing here](#8-why-written-rules-keep-failing-here)

---

## 1. Source priority — 🔴 READ THIS FIRST

When two sources disagree, the higher one wins. **This ordering is authoritative and matches [Charter](./Atlas-Charter.md) Locked Rule 13.**

| Rank | Source | Why |
|---|---|---|
| **1** | **Live device or system output, captured now** | The only thing that cannot be out of date. |
| **2** | **Current configuration export** | A snapshot of rank 1. Ages the moment it is taken. |
| **3** | **Troubleshooting / incident records** | Written at the time, by someone looking at the problem. |
| **4** | **Build Records** | *Verified reality* — what is actually running, including deviations. |
| **5** | **Build Guides** | *Target state* — what we intend. **A guide describes what should be, not what is.** |
| **6** | **Handoffs, summaries, narratives** | Prose written from memory, usually late, usually tired. |

> **A Build Guide is a plan. A Build Record is an observation. Observations outrank plans.**

### 1.1 Why the old ordering was actively harmful

The previous version placed *"Tested Build Guide"* above *"Current Build Record"* — **instructing you to trust intent over observation.** That produced real, live defects:

- The FreeRADIUS guide kept telling you to create a `testing`/`password` account **after it had been deleted for being a live credential.** The record said it was gone; the guide outranked it.
- Three guides kept teaching a `cat | sudo tee` pipeline that had already written a **keyless certificate** into production.
- The Pi-hole guide kept telling you to edit `custom.list` — **a file that does nothing.**

In every case the record was right, the guide was wrong, and the rule said believe the guide.

### 1.2 Corollary — "no error" is not evidence

A command that completes without an error is **not** a confirmed change. This was the root cause **at least five times in one session**: a silently unbound certificate, a cert signed with an empty SAN after a clean log, a config line written to the wrong section, a DNS record saved to a file nothing reads, and a setting that didn't persist on the first `set`.

Every one was caught **only** by reading the resulting state back. **Read it back. Every time.** ([why: *A Completed Command Is Not Evidence*](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md).)

---

## 2. The page lifecycle

No page skips this. **"Verify Against Live Environment" sits before the page is saved, not after it's published** — a page that reaches the published copy unverified is a page someone will believe.

```text
Plan → Write → Verify Against Live Environment → Capture Lessons → Save to Repo → Git Commit → Publish → Engineering Review → Reconcile → Freeze
```

- 📋 **Templates for the artifacts you'll write** — [`Build-Record-Template`](../Templates/Build-Record-Template.md) (verified reality) · [`Build-Guide-Template`](../Templates/Build-Guide-Template.md) (target state) · [`Device-Verification-Procedure-Template`](../Templates/Device-Verification-Procedure-Template.md) · [`Device-Considerations-and-Risks-Template`](../Templates/Device-Considerations-and-Risks-Template.md) · [`ADR-Template`](../Templates/ADR-Template.md).
- Where a doc goes is governed by [`Contributing-Adding-Docs`](../Documentation/Contributing-Adding-Docs.md); how it's shaped by [`Atlas-Documentation-Standard`](../Documentation/Atlas-Documentation-Standard.md); the rule is [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md).

---

## 3. Evidence status

Every technical page declares what kind of claim it is making ([Charter](./Atlas-Charter.md) Locked Rule 14; the evidence rule it serves is [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md)).

```text
Evidence Status: Verified | Historical | Reconstructed | Target Design | Unverified
Evidence Source:  live CLI output | config export | session transcript | inference
Last Verified:    YYYY-MM-DD
```

> **"Verified" is a claim about a date, not a property of the page.** A page verified in June and untouched since is **Historical**, not Verified.

A build record here once opened *"all values confirmed directly from the running system via SSH"* — and asserted 32 GB RAM / 32 vCPUs. The live host reports **62 GiB and 16**. It was almost certainly true when written. Dates matter.

---

## 4. Change closeout

A change is not closed until the **Guides** it invalidates are reconciled — not just the Record ([Charter](./Atlas-Charter.md) Locked Rule 15; the change process is [`POL-0003`](../Policies/POL-0003-Change-Control.md)).

> **The target does not have to change for a guide to become dangerous.**

- The process + its templates live in the router: [Make a change →](./Atlas-Source-of-Truth.md#7-make-a-change) ([`Atlas-Change-Management-Process`](./Atlas-Change-Management-Process.md) · [`Change-Record-Template`](../Templates/Change-Record-Template.md) · [`POL-0003`](../Policies/POL-0003-Change-Control.md)).

---

## 5. Governance change workflow

> The *model* lives in [`Atlas-Governance-Framework.md`](./Atlas-Governance-Framework.md); this is the *executable loop* for changing it. Use it whenever you fold a policy, promote an ADR, or backfill `Governing Policy:` lines. **Single-writer** — governance edits are cross-cutting; no second agent works the estate during a pass.

1. **Freeze first.** Before re-scoping *any* ADR, snapshot the current ADR set to `99-Archive/Legacy-ADRs-YYYY-MM-DD/` — preserve, never delete (`ADR-0012`). Its own commit, before anything else.
2. **Fold the policy** from [`../Templates/POL-Template.md`](../Templates/POL-Template.md) — the golden shape (at-a-glance rule · citable `R#` · Sources-of-truth · generated directory). Disposition per ADR comes from [`Governance-Reconciliation-Triage.md`](./Governance-Reconciliation-Triage.md): **(A)** add the line · **(B)** recognize-in-place · **(C)** promote the rule, keep the ADR.
3. **Backfill the line.** Add `Governing Policy: POL-xxxx` to each governed ADR. For **(C)**, re-scope the ADR to *"the decision that adopted this rule."*
4. **Regenerate, don't type.** Rebuild the policy's Decisions directory with [`../../tools/Build-Policy-Directories.ps1`](../../tools/Build-Policy-Directories.ps1) — never hand-edit it (`POL-0004`: generated, not typed).
5. **The currency checklist** (framework §8 — do not skip):
   - [ ] Decisions directories regenerated
   - [ ] `AI-Context/` refreshed where structure or governance changed (`ADR-0052`) — pointers, not copies
   - [ ] Backlog updated (`Roadmap/Atlas-Improvement-Backlog.md` — the operator's dashboard)
   - [ ] SESSION-HANDOFF `📍 CURRENT STATE` block updated
6. **Commit** — one logical change per commit (§6).

**Why this is a workflow, not a note:** the same reason the rest of this page exists — *a rule survives only if something enforces it.* The enforcers here are the **generator** (the directory can't be wrong) and the **checklist** (the page isn't done until it's logged).

---

## 6. Git workflow

Every completed page is committed. **One logical change per commit.** Commit messages name the book, then the action:

```text
Network: Add Cisco Build Guide
Virtualization: Add Golden Image
Foundation: Correct source priority in Atlas-Workflow
```

A commit message describes **what the commit actually did**, not what you intended.

> A commit here once read *"Tools: retire superseded placement scripts"* while retiring nothing — the `git mv` had failed and the commit ran anyway. **Read the commit output before you move on.** Same rule as reading state back from a device.

### 6.1 Placing files

Use `tools/Place-AtlasFiles.ps1`. It derives destinations from the repo, refuses to guess when placement is ambiguous, backs up every overwrite to `99-Archive/replaced/`, and logs what it did. **It will not run on an uncommitted working tree** — deliberate: if it writes onto uncommitted changes, you can't tell what the tool changed from what you changed.

---

## 7. The deferred-work rule

New process ideas, templates, and reorganisations are recorded for later. **They must not interrupt completion of the current work.**

> **Read that again.** This project has, at times, spent more effort on documentation *about* documentation than on the infrastructure it documents. [Charter](./Atlas-Charter.md) **DR-001:** *documentation should reduce work, not create work.* When the process is mature, **stop writing process — go build.**

---

## 8. Why written rules keep failing here

Three rules existed, in writing, and all three failed the same way:

| Rule | Where it lived | Why it failed |
|---|---|---|
| *"Update the dashboard first, every session"* | `Atlas-Roadmap.md` | Nothing enforced it. It drifted 90 points from reality. |
| The evidence hierarchy | This page | **It was backwards**, and nothing enforced it either. |
| *"Build Guide, if target procedure changed"* | Change Record template | The conditional was an escape hatch — always answered "not applicable," truthfully. |

**A rule that lives only in a document, with nothing forcing it, is not a rule.** That's why Locked Rule 15 removes the conditional and demands a written outcome, why the placement tool **refuses to run** rather than warning, and why the governance directories (§5) are **generated**, not trusted to a human. The only rules that survive are the ones something enforces.

## Change Log

| Version | Changes |
|---|---|
| 2.0 | **Source priority corrected** — Build Records now outrank Build Guides; added the read-back corollary, evidence status, change-closeout rule. |
| 2.1 | Restored the page-lifecycle diagram + git commit convention (dropped from `Atlas-Roadmap.md`). Added "why written rules keep failing." |
| 2.2 | 2026-08-03. Added the **Governance change workflow** (the executable loop for the framework). |
| 3.0 | 2026-08-03. **Reworked to the house format** (operator): numbered on-this-page index + numbered sections with hard breaks; **Source priority pulled to the top and highlighted** (§1, read-first); **Pack lifecycle removed** (no longer how work runs); templates linked inline in the page lifecycle + change-closeout; cross-linked to the Source-of-Truth router. |
| 3.1 | 2026-08-03. Reciprocal tie-in with the Source-of-Truth router — added the 🔗 pairing callout (the router says *where*, this says *how*). The router now surfaces this doc in its Fast-path, on-this-page index, and §7–§9 deep-links. |
| 3.2 | 2026-08-04 (#43 Pass A). Wired the bare governance references into links — the [`Charter`](./Atlas-Charter.md) at the Locked-Rule 13/14/15 + DR-001 mentions, [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) at §3 and [`POL-0003`](../Policies/POL-0003-Change-Control.md) at §4, and the [`A-Completed-Command-Is-Not-Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) concept at the §1.2 corollary. No content change. |
