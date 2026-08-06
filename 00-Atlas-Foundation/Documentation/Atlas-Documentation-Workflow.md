---
Title: Atlas Documentation Workflow — how & when to document, and which docs to touch
Path: 00-Atlas-Foundation/Documentation
Status: 🟢 ADOPTED companion to the Atlas Documentation Standard ([`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md)). The Standard is the *what shape*; this is the *how & when*. 2026-07-28.
Version: 1.7
Date: 2026-07-30
Scope: Global
---

# Atlas Documentation Workflow

<!-- provenance -->
> **Companion to [`Atlas-Documentation-Standard.md`](./Atlas-Documentation-Standard.md).** The Standard defines the fixed folder shape and the document set. This doc defines the **operating procedure**: at each moment of a build, *what you write and which documents you touch* — so nothing is lost between sessions and the estate can be rebuilt from its own docs.

## The one principle everything hangs on

**The Build-Guide is a rebuild contract.** Lab-02 will be torn down and rebuilt *from these documents*. If a step is not in the Build-Guide — the exact command or click, the actual value used, the order it happened in — then after teardown it is gone. The Lab-01 lesson was blunt: a lot of what was actually done to the devices never made it into a doc, so the docs could describe *a* build but not reproduce *the* build. This workflow exists to close that gap.

Two rules follow:

1. **Write the Build-Guide at the bench, in real time — not from memory afterward.** Memory drops the gotchas, and the gotchas are the valuable part.
2. **If it changed device state, it goes in the guide.** Every IP, every account name, every feature toggle, every "I had to do X first or Y failed."

## The four moments of a build — what to write, which docs to touch

### 1. Before the bench (planning) — author the plan you'll build from
The current planning waves (Wave D+) do this. For the device/service:
- **`README.md`** — the front-door + document index + the **connections map** (what this host depends on, what depends on it, and which services it touches) **+ a `mermaid` connections diagram** rendering that map (Standard v1.6 — use the canonical template, **edges labelled with protocol/port**; keep it matching the prose). Create it first; it lists what exists.
- **`Roadmap.md`** — the per-role build path: each role/service in build order with **Needs** (what must be healthy first) and **Unblocks** (what proceeds once it's done). The host's own dependency graph — the piece that makes cross-device sequencing legible. It also carries the **Certification alignment** table (role → objective → cert + learning-focus) and a **staged traffic-flow** slice (allowed/blocked, drawn stage-by-stage as tested units are applied — [`ADR-0041`](../Decisions/ADR-0041-Incremental-Test-Gated-Implementation.md)), each linking up to its estate owner.
- **`Build-Checklist.md`** — the ordered, terse, decision-free action list + the acceptance gate. **You build from this.**
- **`Considerations.md`** — the decisions, risks, and open holes that shape it (link each decision to its ADR; don't restate it). Link the device to its rows in [`Operations/Validation-and-Adversarial-Testing.md`](../../Labs/Lab-02-Cisco-Core/Operations/Validation-and-Adversarial-Testing.md) — the negative-test home (prove the wrong thing is blocked).

*No Build-Guide yet — it can't be real until your hands are on the device.*

### 2. At the bench (building) — capture the how as it happens
This is the moment that fails silently if skipped. As you work the checklist:
- **`Build-Guide.md`** — author it live. **Work it phase by phase against the `Roadmap`, each phase behind its 🔴 GATE** ([`ADR-0043`](../Decisions/ADR-0043-Scalable-Phased-Dependency-Gated-Build-Guides.md) — don't start until deps + machines + prior-phase ✅); add the **Certificate-application / Service-setup / Automation-onboarding** sections where the phase needs them; keep future/cloud phases as **gated stubs** until reached. Each state-changing step, **in the order it happened**, with:
  - the **actual value used** (the real IP, hostname, group name, template name — not a placeholder),
  - a required **📸 capture** at each **decision point, confirmation screen, and acceptance/read-back** — naming *what* to capture (the screen + the value that proves the step); GUI-primary; **never a live secret** ([`POL-0002`](../Policies/POL-0002-Secrets-and-Credentials.md)). *(A first-class standard element — `ADR-0037` v1.2.)*,
  - the **CLI/PowerShell** alongside the GUI where it grounds the step,
  - and **what went wrong**, inline — the ordering dependency, the error and its fix, the thing that wasn't obvious. This is the content that makes a rebuild succeed on the first try.
- **`Diagnostics.md`** — as each role / feature / IP / service comes up, add the **show/verify command** for it (command + when-to-run + expected healthy result), marked **🟡 lab-unverified**. ([`ADR-0032`](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) anti-assumption rule: author the check now, never invent its output.)
- **[`Atlas-Academy/Command-Library/<platform>.md`](../../Atlas-Academy/Command-Library/README.md)** — drop the **reusable** commands you just used into the master library: both the **show/verify** commands *and* the **config/set** commands that actually built the thing. The device `Diagnostics.md` links *up* to here; the library is the one home for a command that recurs across devices.

### 3. On read-back (proving it) — flip claims to verified
When you run the verification and paste the output:
- **`Diagnostics.md`** — flip the proven checks **🟡 → ✅** ([`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md): a ✅ needs command + output).
- **`Build-Record.md`** — record the **as-built state** (the verified platform/interfaces/roles/addresses as they actually are). This is the POL-0001 evidence home and the thing a future audit trusts over any guide.
- **`Build-Checklist.md`** — tick the acceptance gate.

### 4. Ongoing (after it's built) — keep it true
- **`Troubleshooting.md`** — add symptom → cause → fix entries as real issues occur.
- **`Changes/CM-####-*.md`** — one file per post-build change (what changed, why, evidence). Never silently edit the Build-Record; record the change, then update the record.
- **`Automation/`** — once you've done a task **by hand** and understand it, capture the repeatable form ([`ADR-0048`](../Decisions/ADR-0048-Automation-and-IaC-Model.md)): a how-to (purpose → what it automates → how to run → expected result → **what it does NOT automate**) + the device-specific script/playbook, linking to the shared estate modules (the self-hosted git / `Operations/Automation/`, not copied). **Authored after the manual pass, never before** — automate what you've learned, don't paste past the learning (Learning Rule, [Charter](../Governance/Atlas-Charter.md) 16/17). 🟡 until it runs **idempotently** on the device (`ADR-0041`). Early on, this may be just the Oxidized config-backup hook (a gated stub).

## When a DECISION is made — the propagation checklist (the anti-drift move)

This is the estate's #1 failure mode — a decision made, the docs left behind. Every decision follows the **same five-step propagation**, in order:

1. **ADR** — author the decision (context / decision / alternatives / consequences), with its **`Scope`** ([`ADR-0033`](../Decisions/ADR-0033-ADR-Scope-Field-and-Index.md)).
2. **[`ADR-Index.md`](../Decisions/ADR-Index.md)** — add the row + a change-log entry; bump the index version.
3. **The single owner doc for each affected fact** — update *only* the owner (`ADR-0037` fact-ownership map: IP plan, flows matrix, the device's Build-Guide/Record, etc.). Everything else links to the owner, so there's nothing else to change.
4. **[`Review-Flag-Register.md`](../../Labs/Lab-02-Cisco-Core/Review-Flag-Register.md)** — log it in the Decisions table + a change-log row; bump the register version.
5. **[`SESSION-HANDOFF.md`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md)** — add/refresh the top session block + bump the handoff version.

If you can't complete all five in the same session, the handoff records the decision as **pending propagation** so the next session finishes it — the decision is never "half-recorded."

## Feeding Atlas Academy (keep it light for now)

Academy has two layers; only one is fed by this workflow today:
- **Command-Library (feed it as you build):** every recurring show/verify and config/set command goes here, on its platform page, written as *purpose → command → healthy result → broken result → what it grounds*. Device pages link up; the command lives here once.
- **Concepts / "why it works" (deferred — needs its own pass):** the concept modules still reference retired artifacts (OpenSSL Lab CA, FreeRADIUS) and need rethinking against the current AD CS / NPS estate. **Do not** expand Concepts opportunistically during builds; it gets a dedicated session. (Tracked as its own item.)

## Working solo / away from the lab (the common case)

Lab work often happens **solo, without the assistant alongside** — the exact condition that let Lab-01 drift. Two guards (`ADR-0032`):
- **At the bench, capture into the Build-Guide + Diagnostics as you go** — even rough notes beat reconstructed memory. Rough-but-real is upgraded to clean prose next docs session.
- **In the handoff, record what changed and point at the read-back** — so the next session (or the assistant) can confirm device state from evidence, not memory. A 🟡 marker means "claimed, not yet device-proven"; it stays 🟡 until an output is pasted.

## Quick reference — "I'm documenting device/service X"

```
Planning:   README ▸ Roadmap ▸ Build-Checklist ▸ Considerations   (author the plan)
At bench:   Build-Guide — phase by phase, each behind its 🔴 GATE (live values, 📸, gotchas; cert/service/automation sections)
            + Diagnostics (🟡 checks)  + Academy Command-Library (show + config)
Read-back:  Diagnostics 🟡→✅  ▸ Build-Record (as-built)  ▸ Checklist gate ✅
Ongoing:    Troubleshooting  ▸ Changes/CM-####  ▸ Automation/ (after the manual pass; idempotent; links to shared modules)
Decision?:  ADR ▸ ADR-Index ▸ owner doc ▸ Register ▸ Handoff     (all five)
Elements:   📸 captures · Cert-alignment + staged Traffic-flow (Roadmap) · Validation link  -> each links to its estate owner
```

## Related

- [`Atlas-Documentation-Standard.md`](./Atlas-Documentation-Standard.md) (the folder shape this workflow fills) · [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) (adopts both) · [`ADR-0032`](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) (Diagnostics/Troubleshooting + Command-Library + anti-assumption rule) · [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) (device is the source of truth) · [`POL-0008`](../Policies/POL-0008-Naming-and-Addressing.md) (one source of truth per fact) · [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (the governing policy) · [`Atlas-Academy/Atlas-Teaching-Patterns-and-House-Style.md`](../../Atlas-Academy/Atlas-Teaching-Patterns-and-House-Style.md) (voice).

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.7 | 2026-08-04 | **Wired the bare governance references into links (#43 Pass A)** — the Documentation Standard, `ADR-0037/0041/0043/0032/0048/0033`, `POL-0001/0002`, `ADR-Index`, the Academy `Command-Library`, the `Validation-and-Adversarial-Testing` matrix, the `Review-Flag-Register`, and `SESSION-HANDOFF`; rebuilt the Related section into links (+`POL-0014`) and corrected its stale `00-Atlas-Foundation/Atlas-Documentation-Standard.md` path (was missing `/Documentation/`). No content change. |
| 1.6 | 2026-07-30 | **Connections-diagram edges labelled with protocol/port** (Standard v1.6 / `ADR-0049`) — mirrors the Standard; the *how connected* story on the picture. |
| 1.5 | 2026-07-30 | **Added the Mermaid connections diagram to the planning-moment README authoring** (Standard v1.5) — author it with the connections map, from the canonical template, matching the prose. Mirrors Standard v1.5. |
| 1.4 | 2026-07-29 | **Added the `Automation/` doc-type to the Ongoing moment** (`ADR-0048`) — authored **after the manual first pass** (automate what you've learned by hand; Learning Rule Charter 16/17): a how-to + device script/playbook, linking to the shared estate modules (self-hosted git / `Operations/Automation/`), 🟡 until idempotent (`ADR-0041`). Quick-reference updated. Mirrors Standard v1.4. |
| 1.3 | 2026-07-29 | **Build-Guide authored phase-by-phase against the Roadmap gates** (`ADR-0043`) — each phase behind its 🔴 GATE; standard Certificate-application / Service-setup / Automation-onboarding sections; future/cloud phases as gated stubs. Quick-reference updated. Mirrors Standard v1.3. |
| 1.2 | 2026-07-29 | **Added the four per-device analytical elements to the moments** — 📸 captures (required, at decision/confirmation/acceptance screens), the `Roadmap` **Certification alignment** + **staged traffic-flow** slice, and the **Validation link** to `Operations/Validation-and-Adversarial-Testing`. Quick-reference updated. Mirrors Standard v1.2 / ADR-0037 v1.2. |
| 1.1 | 2026-07-29 | **Added `Roadmap.md` to the planning moment + the README connections-map requirement** (from the DC exemplar; mirrors the Standard v1.1). Quick-reference updated. |
| 1.0 | 2026-07-28 | Created — the capture workflow companion to the Documentation Standard. Establishes the Build-Guide-as-rebuild-contract principle; the four build moments (planning / at-bench / read-back / ongoing) and which docs each touches; the five-step decision-propagation checklist; the Academy Command-Library feed (Concepts deferred); the solo/away-from-lab capture guards; and a copy-paste per-device quick reference. |
