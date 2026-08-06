# ADR-0054 — Governance Reconciliation: Promote Policy-/Standard-Shaped ADRs; ADRs Become Amendments; Backfill `Governing Policy`

| Item | Value |
|---|---|
| Status | **Proposed** (operator accepts by moving to Accepted). Drafted 2026-07-31. |
| Scope | **Global** — a governance/meta decision about how the whole ADR set relates to the Policy layer. |
| Governing Policy | **`Atlas-Governance-Framework` §4/§5** (the reconcile mandate this executes) · **`POL-0001` (Audit)** — a governance reconcile pass *is* an audit (device/record/doc precedence applied to the doc-type hierarchy). |
| Amends / builds on | **Executes `ADR-0026`** (which adopted the Governance Framework) — this is the point-in-time decision that finally runs the framework's §4/§5-step-4 reconcile. Applies **`POL-0004`/`POL-0008`** (one home per fact; promote-don't-copy) and **`ADR-0012`** (quarantine/preserve, never delete history). |
| Related | `Atlas-Governance-Framework.md` · `ADR-0026` · `POL-0001`–`POL-0013` · proposed `POL-0014`/`POL-0015`/`POL-0016` (stubbed with this ADR) · `Governance-Reconciliation-Triage.md` (the working list) · `Atlas-Improvement-Backlog` **#32** (the execution item) · CompTIA **Project+ PK0-005** Domain 1 (integrated change control — the PM model this mirrors). |
| Evidence Status | **Governance decision** — no device evidence. The claim it rests on ("the policy layer is written; the ADRs don't yet point up to it") is verifiable by `ls 00-Atlas-Foundation/Policies/` (POL-0001–0013 exist) and `grep -L "Governing Policy" Decisions/ADR-*.md` (none carry the line). |

## Context

The operator asked, plainly: *"I do think we have a lot of ADRs and some things could be made as policies. I think policies should supersede ADRs. Is there a clean way to make some of those ADRs policy and have the ADRs be sort of amendments? Is that how project management works?"*

The answer is yes on all three counts — and the estate is **already built for it**. The `Atlas-Governance-Framework` (adopted in principle by `ADR-0026`) puts **Policy above ADR** by design (`Charter > Policy > Standard > ADR > Change`), and its §1 hierarchy table already says a Policy changes *"by a deliberate act — **an ADR that adopts/amends it**."* That sentence **is** the "ADRs become amendments" model. What's missing is not the mechanism; it's the **execution**. Three concrete gaps:

1. **The policy layer exists but is not wired to the ADRs.** `POL-0001`–`POL-0013` are written files. But the framework's **§4** ("every ADR gains one line: `Governing Policy: POL-xxxx`") and **§5-step-4** ("backfill `Governing Policy:` on existing ADRs during the next reconcile pass") were **never run** — *no* ADR currently carries the line. So the precedence exists on paper but can't be traced or enforced.

2. **A live status contradiction.** The Governance Framework header says *"✅ Adopted 2026-07-17 by `ADR-0026`. In force."* — but `ADR-Index.md` still lists **`ADR-0026` as `Proposed`**, and every `POL-000x` header still says *"Proposed — adopt with the Governance Framework (`ADR-0026`)."* Either the layer is in force or it isn't. This must be resolved first, because everything below depends on it (an operator acceptance act — see §1 of the Decision).

3. **Several ADRs are standing rules or standards wearing an ADR's clothes.** An ADR is supposed to be *a point-in-time choice among options.* But `ADR-0037` literally **is** the Documentation Standard; `ADR-0012` ("quarantine, don't delete") is a **standing rule that must always be true**; `ADR-0041`/`ADR-0043`/`ADR-0048` are the estate's **build discipline**. These aren't decisions-among-options any more — they're the rule now. The framework's §4 names exactly this case: *"An ADR that conforms to no policy is either missing its policy or is really a policy itself."* And there is **no policy** yet that governs the *documentation*, *build/engineering*, or *realism/learning* domains — so those ~10 ADRs have nowhere to point even if we ran the backfill today.

## Decision

Adopt a **promote-and-relink** reconciliation — never a rename-and-delete — executed in coordinated phases against a written triage. Six parts.

### 1. Resolve the adoption status first (operator act, gates everything else)
Before any relinking, the operator confirms **`ADR-0026` → Accepted** (or explicitly re-opens it). On acceptance: flip the `ADR-0026` index row to Accepted, and flip each `POL-000x` header from *"Proposed"* to *"Adopted by `ADR-0026`."* This ADR **does not** flip them unilaterally — adoption is an operator decision (`ADR-0049` ask-at-planning). It only records that the reconciliation is **blocked on** that confirmation.

### 2. Every ADR gains a `Governing Policy:` line (the §4 backfill)
Each ADR names the standing requirement it serves. Format (in the metadata table): `Governing Policy | POL-xxxx (+ POL-yyyy)`. This is the single mechanical change that makes precedence *traceable* — you can now ask "which decisions serve the Secrets policy?" and `grep` the answer. The per-ADR assignments are the working list in `Governance-Reconciliation-Triage.md`.

### 3. Three dispositions, decided per ADR (not a blanket conversion)
The triage tags every ADR as exactly one of:

- **(A) Genuinely a decision** — a real chose-X-over-Y (e.g. `ADR-0030` DHCP-on-DC01, `ADR-0051` Pi-hole-owns-DNS). *Action:* add the `Governing Policy:` line; **otherwise leave it exactly as-is.** This is the large majority.
- **(B) Standard-shaped** — it defines *how* something is done, estate-wide and testable (e.g. `ADR-0037` Documentation Standard, `ADR-0032` diagnostics architecture, `ADR-0048` automation model). *Action:* **recognize it in place as the estate standard for its domain** and point it at a governing policy. We do **not** physically renumber it to `STD-xxxx` — the reference blast-radius is huge and renaming buys nothing the `Governing Policy:` line and a one-word "Doc-type: Standard-in-effect" note don't. (A thin `STD-xxxx` *citation* may be registered later if a cert objective needs a `STD` home, exactly as `STD-0001`–`STD-0004` already do.)
- **(C) Policy-shaped** — a standing rule that must *always* be true (e.g. `ADR-0012` preserve-history, `ADR-0008` process-only-Foundation, `ADR-0044` build-to-the-enterprise-model). *Action:* the **standing rule is promoted into a `POL-xxxx`** (a new policy, or absorbed into an existing one). The **ADR is kept** and re-scoped to what it actually was: *the point-in-time decision that **adopted** that policy.* It is not deleted (`ADR-0012`), and any later ADR that changes the rule is an **amendment** to the policy.

### 4. The amendment model (the operator's exact question), stated as a rule
When a standing rule changes, you **do not silently edit the policy.** You write (or already have) an ADR that **amends** it, and:

- the **ADR** carries `Governing Policy: POL-xxxx` and says, in its Decision, *"amends `POL-xxxx` §N";*
- the **policy's Change Log** gains a row citing the amending ADR and date.

So the Policy holds the *current standing rule*; the ADRs behind it are the *dated trail of how it got there.* Nothing is lost, and the top layer always wins (framework §1: *"the higher layer wins; the lower is the defect"*).

### 5. Fill the governance gap — three proposed policies (stubbed with this ADR)
The doc/build/learning domains have no governing policy, which is why their ADRs can't be relinked yet. This ADR proposes three, **stubbed now as `Proposed` skeletons** (not adopted — they ride the operator's §1 confirmation or a later act):

- **`POL-0014` — Documentation & Knowledge Management.** Governs `ADR-0008`, `ADR-0012`, `ADR-0032`, `ADR-0033`, `ADR-0037`, `ADR-0043` (doc-type half), `ADR-0049`, `ADR-0052`, `ADR-0053`. Absorbs the standing rules: one-home-per-fact (with `POL-0004`/`POL-0008`), quarantine-not-delete, the Documentation Standard's authority, the handoff protocol.
- **`POL-0015` — Engineering & Build Discipline.** Governs `ADR-0041`, `ADR-0043` (build half), `ADR-0048`. Absorbs: incremental test-gated implementation, phased dependency-gated builds, the automation/IaC model. Ties to `POL-0006` (evidence).
- **`POL-0016` — Realism & Learning.** Governs `ADR-0011`, `ADR-0024`, `ADR-0025`, `ADR-0039`, `ADR-0044`. Absorbs: build-to-the-real-enterprise-model, certifications-anchor-skills, Game-Day drills, learn-by-doing. The framework's §2 *already anticipates a "POL — Learning (Rule 16)"* — this is that policy, widened to realism.

Per the framework's own caution (*"keep the core set small; grow only when a real defect proves a policy was missing"*), each of the three is **earned**: without it, ~10 standing-rule ADRs have no governing home. If the operator prefers fewer, `POL-0016` is the most foldable (its content could live in the Charter as a meta-rule).

### 6. Execution is phased, coordinated, and audit-tracked
The actual sweep (touching the metadata table of ~50 ADRs, three policy headers, and the index) is **one coordinated single-writer session** — governance edits are cross-cutting and collide badly with a second agent working the repo in parallel. It runs **one policy-domain at a time** (`POL-0008` propagation: ADR → index row → any `Pre-Build-Decisions`/`Considerations` "Decided" → handoff), against `Governance-Reconciliation-Triage.md` as the checklist, and closes like any `POL-0001` audit (every ADR either carries its line or is recorded as an exception). Backlog **#32** owns the execution.

### Is this how project management works? Yes — it's integrated change control.
The model maps one-to-one onto the PM baseline-and-change-request pattern (CompTIA **Project+ PK0-005**, Domain 1, *Change Control*):

| Project management | Atlas governance |
|---|---|
| **Charter / baseline** — the approved standing plan everything must conform to | **Policy (`POL-xxxx`)** — the standing requirement |
| **Approved change request** — the formal, dated act that modifies the baseline | **ADR** — the dated decision that adopts/amends a policy |
| **Integrated change control** — the baseline is never edited silently; every change is logged and traceable | **The `Governing Policy:` line + the policy Change Log** — no standing rule changes without an ADR behind it |
| **Configuration management** — the current baseline + its change history are both kept | **Policy holds the current rule; ADRs (`ADR-0012`-preserved) hold the history** |

## Alternatives Considered

- **Physically convert the policy-shaped ADRs into `POL-xxxx`/`STD-xxxx` files and delete the ADRs.** Rejected. It violates `ADR-0012` (history is quarantined, never erased) and would break the dozens of cross-references (`ADR-0037` alone is cited across the Standard, Workflow, Index, and most device folders). The `Governing Policy:` line achieves the precedence without the blast radius.
- **Leave it as-is; the framework is "adopted" on paper.** Rejected. This is the status quo, and it's exactly the enumerable-vs-buried defect the policy layer was created to fix (`POL-0002`'s "a rule that is not enumerable is not auditable"). The §4 line is the whole point.
- **Promote everything standing into a policy (maximise the policy layer).** Rejected — violates the framework's "keep the core set small." Most ADRs are genuine decisions and should stay decisions with a single `Governing Policy:` pointer.
- **Do the full 50-ADR backfill in this session, now.** Rejected for *this* session — it's a large cross-cutting sweep with real multi-agent collision risk, and the operator flagged a second agent working the repo. This ADR + the triage + the three policy stubs are the *design*; #32 is the *execution*, run in a coordinated window.

## Consequences

- **New:** this ADR; `Governance-Reconciliation-Triage.md` (the per-ADR working list); three `Proposed` policy stubs (`POL-0014`/`POL-0015`/`POL-0016`).
- **`ADR-Index.md`** gains the `ADR-0054` row (Global) + a changelog row + version bump.
- **`Atlas-Improvement-Backlog`** gains **#32** (execute the reconciliation) and **#33** (the CompTIA Project+ cert track, which supplies the PM vocabulary this ADR borrows).
- **Blocked-on-operator:** §1 (confirm `ADR-0026` → Accepted and flip the `POL` headers). Until then the three new policy stubs stay `Proposed` and the backfill doesn't run.
- **Deferred to #32 (a coordinated single-writer session):** the actual `Governing Policy:` backfill across the ADR set, the three policy stubs fleshed out and adopted, and the standing-rule absorption from the (C)-tagged ADRs into their policies.
- **No device impact.** This is pure governance wiring; nothing on hardware changes.

## Review Trigger

Revisit if: the operator re-opens rather than accepts `ADR-0026` (the whole layer's status changes); the three proposed policies prove to overlap an existing `POL` (fold instead of add); the backfill reveals an ADR that fits *no* policy and *is not* itself policy-shaped (a genuine gap — a missing policy); or a future agent starts editing policies **in place** without an amending ADR (the anti-pattern this ADR exists to prevent — re-fence §4).
