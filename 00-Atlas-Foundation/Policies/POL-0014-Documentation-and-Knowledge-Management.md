---
Title: POL-0014 — Documentation & Knowledge Management Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework) via `ADR-0054` (reconciliation). In force.
Version: 1.0
---

# POL-0014 — Documentation & Knowledge Management

> **At a glance.** One fact, one home — and this page tells you *which* home. Never delete; quarantine. Author from the device, never from imagination. The Documentation Standard and its conventions are the rules, not suggestions. This policy folds **nine decisions** into five requirements you can cite by number (`POL-0014 R1`…`R5`), and doubles as a **directory of the decisions that govern documentation** (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the Standards, ADRs, Changes, and Procedures beneath it |
| Requirement, in one line | Every fact has one owner document; documentation is preserved not deleted; content is authored from evidence not invented; the Documentation Standard and its conventions are binding. |
| Owner | 🔴 the operator / documentation function ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md) (defined the fold) → adopted under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (2026-08-03) |
| Builds on | [`POL-0004`](./POL-0004-Source-of-Truth.md) (one source of truth) · [`POL-0008`](./POL-0008-Naming-and-Addressing.md) (one home per fact) · [`POL-0006`](./POL-0006-Evidence-and-Verification.md) (evidence) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below, one line per requirement |
| Framework mapping | ISO 9001 §7.5 (documented information) · CIS Controls v8 (asset/config documentation) · CompTIA Project+ Domain 3 (tools & documentation) |

---

## Scope & applicability

This policy applies to **every document in the Atlas estate** — the [Foundation](../README.md), both technology Books, and the [Academy](../../Atlas-Academy/) — and to every session (human or AI) that authors, edits, retires, or publishes a document. It governs *where a fact lives, how it is written, how it is verified, how it is retired, and how the documentation rules themselves change.* It does **not** dictate the line-level content of any specific standard (that lives in the standard's own document); it dictates that those standards are authoritative and how they are amended.

**Boundary with [`POL-0004`](./POL-0004-Source-of-Truth.md):** POL-0004 governs the *data* source of truth — device/network facts, target **NetBox**, *"generated, never hand-typed."* POL-0014 governs the *documentation* source of truth — which **document** owns which kind of fact. They meet at the shared rule *one home per fact* ([`POL-0008`](./POL-0008-Naming-and-Addressing.md)); a data fact's home is NetBox, a documentation fact's home is its owner doc.

## Why this is a policy, not a note

Atlas's single most recurring defect is *"the document disagrees with the device."* The rules that prevent it were written as **decisions** — [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) (the Standard), [`ADR-0012`](../Decisions/ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md) (preserve history), [`ADR-0049`](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md) (the handoff) — so they could not be cited *as policy* when a new document broke them. A rule that is not enumerable is not auditable. Raising these nine decisions into one standing requirement turns *"did this follow the documentation rules?"* into a question with a short, checkable answer.

---

## The standing requirements

Each is citable as `POL-0014 R#`. The decision(s) each one absorbs are linked inline; the full trace is in *[Decisions governed by this policy](#decisions-governed-by-this-policy)*.

### R1 — One fact, one home

A fact is asserted **once**, in its owner document; every other mention **links** to that owner instead of restating it. Two homes for one fact is the defect, not redundancy.

- **The right home for process vs. technology** ([`ADR-0008`](../Decisions/ADR-0008-Foundation-Holds-Process-Only.md)): the Foundation holds process only — Charter, Workflow, ADRs, policies, templates, inventories. > *"If a document names a product or a protocol, it is not a Foundation document."* Product/protocol content belongs to its technology Book.
- **Fact-ownership is mapped** ([`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md)): each device/service documentation set names one owner per fact. > *"Every other mention links to the owner rather than restating it — this is `POL-0008` made enforceable."*
- **Onboarding maps point, never copy** ([`ADR-0052`](../Decisions/ADR-0052-AI-Context-Folder.md)): the `AI-Context/` folder is built only from pointers (a link + one line of *why*) and genuinely new navigation content. > *"Curated multi-paragraph summaries of other docs are explicitly out of scope."*

The concrete owner documents are enumerated in *[Sources of truth](#sources-of-truth--where-each-documentation-fact-lives)* below.

### R2 — Preserve, don't delete; the repository is the record

Wrong, superseded, or unverified content is **quarantined and annotated with its specific defect — never deleted** ([`ADR-0012`](../Decisions/ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md)). > *"A page is never deleted for being wrong."* Historical citations (frozen Lab-01 `018-`, `CM-####`) are never silently "corrected." The **repository is the source of record; any published copy is downstream** — > *"The repository is the source of record. Confluence is the published copy."* The repo file is written first, then published. Retired material moves to `99-Archive/` with a banner and a live-home pointer.

### R3 — The Atlas Documentation Standard is the canonical architecture

[`Atlas-Documentation-Standard.md`](../Documentation/Atlas-Documentation-Standard.md) (adopted by [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md), in effect as the estate standard) is authoritative for how every device and service is documented: the fixed named doc-types in a fixed folder shape, authored checklist-first in lifecycle order, `Roles/` for multi-service hosts, and a written fact-ownership map. Four conventions extend it and are equally binding:

- **R3a — ADR discipline** ([`ADR-0033`](../Decisions/ADR-0033-ADR-Scope-Field-and-Index.md)): every ADR carries a `Scope` field (Global / Lab-01 / Lab-02), numbering stays global, and every ADR appears in [`ADR-Index.md`](../Decisions/ADR-Index.md). > *"Every ADR carries a `Scope` field… numbering stays global."*
- **R3b — Build-Guides are phased and gated** ([`ADR-0043`](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md)): each Build-Guide is the complete, dependency-gated path mirroring the device `Roadmap.md` 1:1; the cross-device order lives in exactly one owner, `Operations/Build-Order-and-Dependencies.md`. > *"Every phase opens with a 🔴 GATE."*
- **R3c — Diagnostics are authored as you build** ([`ADR-0032`](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md)): verification commands go into the device's `Diagnostics.md` as work proceeds — command + when-to-run + expected result — marked 🟡 lab-unverified until a device read-back confirms them.
- **R3d — The Academy follows its own standard** ([`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md)): everything under [`Atlas-Academy/`](../../Atlas-Academy/) uses problem-name-keyed Playbooks, a cert-grounded spine, and the 3-click rule. > *"Every Academy doc is reachable in ≤ 3 clicks from the repo front door, via exactly one middle index."*

### R4 — Author from evidence, never invent

Documentation content — above all command output — is authored from knowledge and official documentation and **verified against the device before it is trusted**; it is never assumed or fabricated ([`ADR-0032`](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md)). > *"Commands are authored from knowledge and official documentation; their outputs are never assumed or invented."* A claim stays 🟡 lab-unverified until a device read-back proves it. This is the documentation face of [`POL-0006`](./POL-0006-Evidence-and-Verification.md) and of Charter Rule 13 — *the device outranks the document.*

### R5 — Planning and handoff continuity

Open design decisions are surfaced as explicit questions and resolved at a device's **planning moment** ([`ADR-0049`](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md)). > *"Deferring to a sweep is the exception, not the default."* Continuity across sessions is carried by `SESSION-HANDOFF.md`: a pinned Living `📍 CURRENT STATE` block above an append-only log, which > *"a fresh session must read… in full before acting."* The `AI-Context/` folder ([`ADR-0052`](../Decisions/ADR-0052-AI-Context-Folder.md)) is the durable map **above** the per-session handoff — structure and governance, never "where we are now."

---

## Sources of truth — where each documentation fact lives

The descriptive answer to R1: for a given kind of fact, *this* is the document that owns it; everything else links here.

> ⚠️ **This table is navigational, not authoritative.** The authoritative owner of the fact-ownership map is the Documentation Standard's own *"Where each kind of fact is owned"* table ([`Atlas-Documentation-Standard.md`](../Documentation/Atlas-Documentation-Standard.md)). This copy exists to orient the reader and is kept in sync with it — if the two ever disagree, the Standard wins (R1 applied to this very page).

| Kind of fact | Owner document | Authoritative for |
|---|---|---|
| Where a new doc goes / how to add or move one | [`Contributing-Adding-Docs.md`](../Documentation/Contributing-Adding-Docs.md) | the placement rule |
| Per-device/service doc architecture + the fact-ownership map | [`Atlas-Documentation-Standard.md`](../Documentation/Atlas-Documentation-Standard.md) | doc structure & who-owns-what |
| Doc writing/style (secrets rule, screenshots, callouts) | [`Atlas-Documentation-Style-and-Conventions.md`](../Documentation/Atlas-Documentation-Style-and-Conventions.md) | house style |
| A decision + its rationale | the relevant **ADR** in [`Decisions/`](../Decisions/), indexed by [`ADR-Index.md`](../Decisions/ADR-Index.md) | the decision record |
| A standing rule | the relevant **POL** in [`Policies/`](./) | the requirement |
| Addresses / VLANs / data facts | [`POL-0004`](./POL-0004-Source-of-Truth.md) → NetBox / `IP-Addressing-Plan-VLSM` | the *data* SoT (cross-domain) |
| Where the build is right now | the active lab's `SESSION-HANDOFF.md` | current state (never in a policy/ADR) |
| Estate build order + dependencies | `Operations/Build-Order-and-Dependencies.md` | the sequence |
| Reusable verify commands | [`Atlas-Academy/Command-Library/`](../../Atlas-Academy/) | the command reference |
| The AI onboarding / navigation map | `AI-Context/` | orientation (pointers only) |
| Retired material | `99-Archive/` | history — *never* current guidance |

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0014 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0008 — Foundation Holds Process Only; Technology Content Belongs…](../Decisions/ADR-0008-Foundation-Holds-Process-Only.md) | ✅ Accepted — and EXECUTED. Both moves are complete: 303-W… | POL-0014 R1 |
| [ADR-0012 — Unverified Published Content Is Quarantined, Not Deleted](../Decisions/ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md) | Accepted | POL-0014 R2 |
| [ADR-0015 — Atlas Pack Sequencing and Scope Expansion](../Decisions/ADR-0015-Atlas-Pack-Sequencing-and-Scope-Expansion.md) | Accepted | POL-0014 (+POL-0003) |
| [ADR-0032 — Diagnostics & Verification Documentation Architecture](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) | Accepted (operator, 2026-07-28). | POL-0014 (+POL-0006) |
| [ADR-0033 — ADRs Carry a Scope (Global / Lab-01 / Lab-02) + a Scope I…](../Decisions/ADR-0033-ADR-Scope-Field-and-Index.md) | Accepted (operator, 2026-07-28). | POL-0014 |
| [ADR-0037 — Adopt the Atlas Documentation Standard (per-device & per-…](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) | Accepted (operator, 2026-07-28); amended 2026-07-29 (v1.1… | POL-0014 |
| [ADR-0043 — Scalable, Phased, Dependency-Gated Build-Guides (and the …](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md) | Accepted (operator, 2026-07-29). Governs Build-Guide stru… | POL-0015 (+POL-0014) |
| [ADR-0049 — Documentation-Session Planning & Handoff Protocol (Ask-at…](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md) | Accepted (operator, 2026-07-30) — the *process* for the d… | POL-0014 |
| [ADR-0052 — The AI-Context Folder (a Durable Onboarding Map for AI Se…](../Decisions/ADR-0052-AI-Context-Folder.md) | Accepted (operator, 2026-07-31) — home, name, pointer-rul… | POL-0014 |
| [ADR-0053 — How the Atlas Academy Documents & Is Navigated (the Acade…](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) | Accepted (operator, 2026-07-31) — the doc-types, the cert… | POL-0014 |
<!-- END AUTOGEN:decisions POL-0014 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail** of how it got there. No standing rule changes by editing this policy silently.

- **To change a rule, an ADR amends it.** The amending ADR carries `Governing Policy: POL-0014`, states *"amends `POL-0014` R#"* in its Decision, and this policy's Change Log gains a row citing that ADR and date. (Integrated change control — the baseline/change-request pattern of [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md).)
- **The (C) decisions** ([`ADR-0008`](../Decisions/ADR-0008-Foundation-Holds-Process-Only.md), [`ADR-0012`](../Decisions/ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md)) are re-scoped to *the decision that adopted this rule* — kept, never deleted, with originals preserved in the `2026-08-03` legacy ADR snapshot.
- **The (B) decisions** are recognised in place as the estate standard for their domain and carry a *"Doc-type: Standard-in-effect"* note — **not** renumbered to `STD-xxxx` (the reference blast-radius buys nothing the `Governing Policy:` line doesn't).
- **The Standard's own version history** ([`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) v1.1–v1.7) stays in that document. This policy governs *that* the Standard is authoritative — not its line-level content.

## Verification (how compliance is proven)

One check per requirement — the [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit runs this list.

- [ ] **R1** — each asserted fact has a single owner; a moved fact `git grep`s to one home; no Foundation document names a specific product or protocol.
- [ ] **R2** — retirements carry a quarantine banner + live-home pointer; `git grep` of the old form returns 0 outside `99-Archive`; no historical citation has been "corrected."
- [ ] **R3** — devices/services follow the Standard's doc-types and folder shape; **R3a** every ADR has a `Scope` + an index row; **R3b** Build-Guides open each phase on a 🔴 GATE and mirror the `Roadmap.md`; **R3c** `Diagnostics.md` commands are 🟡 until read-back; **R3d** every Academy doc is ≤ 3 clicks via one middle index.
- [ ] **R4** — no invented or assumed command output; unverified claims carry 🟡.
- [ ] **R5** — open decisions were raised at planning; `SESSION-HANDOFF.md` has a current `📍 CURRENT STATE` block; the session recorded reading it before acting.
- [ ] **Meta** — every structural change to a governed standard traces to an amending ADR + a Change Log row.

## What a violation looks like

A second copy of a fact that drifts from its owner · a product- or protocol-named page filed in the Foundation · a deleted (not quarantined) retired doc · a "corrected" historical citation · an ADR with no `Scope` or missing from the index · a Build-Guide with no phase gates · an invented or assumed command output · a Standard changed in-place with no amending ADR.

## Related

[`Atlas-Governance-Framework.md`](../Governance/Atlas-Governance-Framework.md) · [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md) (reconciliation) · [`POL-0004`](./POL-0004-Source-of-Truth.md) · [`POL-0008`](./POL-0008-Naming-and-Addressing.md) · [`POL-0006`](./POL-0006-Evidence-and-Verification.md) · the nine folded decisions (directory above) · [`Governance-Reconciliation-Triage.md`](../Governance/Governance-Reconciliation-Triage.md) · the legacy snapshot `99-Archive/Legacy-ADRs-2026-08-03/`.

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-07-31. Proposed stub, drafted with [`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md). |
| 1.0 | 2026-08-03. Adopted under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (via `ADR-0054`). Folded nine decisions into five citable requirements (R1–R5); promoted the rules of `ADR-0008` and `ADR-0012`; recognised `ADR-0032`/`0033`/`0037`/`0043`/`0049`/`0053` as standards-in-effect; absorbed `ADR-0052`'s pointers-not-copies rule. Added the descriptive *Sources of truth* table, the *Decisions governed by this policy* directory, inline citations, and estate-relative links throughout. **Established as the golden template for the remaining POL folds.** |
