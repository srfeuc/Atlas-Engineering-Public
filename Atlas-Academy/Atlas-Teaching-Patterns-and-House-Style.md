---
Title: Atlas Teaching Patterns & House Style — the writing moves worth repeating
Path: Atlas-Academy
Status: 🟢 LIVING house-style guide (register B4/F30). Names the pedagogical patterns Atlas already does well so new docs replicate them on purpose.
Version: 1.0
Date: 2026-07-28
---

# Atlas Teaching Patterns & House Style

<!-- provenance -->
> **Book 9 — Atlas Academy.** Not a concept module and not a policy — a **house-style guide**: the specific *writing moves* that make some Atlas docs teach well, captured so the next doc uses them deliberately instead of by luck. When a new guide/record/ADR is written, reach for these patterns.

> **Why this exists (register B4/F30):** a handful of Atlas pages are unusually good at building understanding, not just recording steps. Those moves are a reusable asset — this page preserves them as the standard, with the exemplar doc named for each.

## The patterns (with their exemplars)

### 1. The mental model *before* the steps — "GPO Part-1 mental model"
Open a procedure with a short **model of how the thing actually works** before any command. A reader who holds the model can debug a step that fails; a reader who only has the steps is stuck the moment reality diverges.
- **Exemplar:** the GPO build's Part-1 mental model (precedence, LSDOU, link order) before the first `New-GPO`.
- **Do it like this:** 2–4 sentences of "here's the model," then the steps. Name the model's failure mode ("if precedence is wrong, the last-writer wins silently").

### 2. Measure first, then change — "PSO §7b measure-first"
Before applying a setting, **read the current state and state what you expect to change**, so the change is verifiable and reversible — and so you notice if it was already set.
- **Exemplar:** the Finance/HR PSO section (§7b) — `Get-ADUserResultantPasswordPolicy` *before* and *after*, so the PSO's effect is proven, not assumed.
- **Do it like this:** pair every "set X" with a "read X back" (`POL-0001`). The before/after delta *is* the evidence.

### 3. Name what the thing does **not** buy you — "DC02: what a second DC doesn't buy"
Set expectations by stating the **limits** of a component, not just its benefits. Prevents the reader from over-trusting it.
- **Exemplar:** the DC02 write-up — a second DC buys **redundancy of the directory**, but **not** a second forest, not a magic HA button, and it still depends on replication + time being healthy.
- **Do it like this:** add a "what this does *not* give you" line to any component that's easy to over-read (a second DC, a firewall rule, a backup, UTM profiles).

### 4. The field-guide for reading signals — "FGT Logging & Flow-Tracing field guide"
For anything that emits logs/telemetry, write a **field guide to reading the output** (what a healthy vs unhealthy line looks like, which fields matter), separate from the build steps.
- **Exemplar:** `FGT01-Perimeter-Firewall/Logging-and-Flow-Tracing-Field-Guide.md` — how to actually read a FortiGate session/flow, not just how to turn logging on.
- **Do it like this:** healthy-vs-broken side by side; call out the one field that tells you the answer. This is the model for the per-device `Diagnostics.md` "expected (healthy)" columns.

## The standing conventions (already estate-wide — repeated here so a new doc inherits them)

- **Evidence over intent (`POL-0001`):** a `[x]` needs a command **and its output**, not a config line. Read state back with the *runtime* view (`get`/`show status`/`print detail`), never the config.
- **One home per fact (`POL-0008`):** if a fact lives in two docs, one owns it and the other links. (See `ADR-0034` for the frozen-vs-active ownership rule.)
- **Markers:** ✅ device-verified · 🟡 operator-reported / lab-unverified · ⏳ in build · 📋 planned — used consistently (`ADR-0032`).
- **Honest status lines:** "outcome confirmed; exact historical invocation not independently verified" beats a false ✅ (Charter Rule 14 — the Virtualization pack does this well).
- **Real examples only (Academy rule):** teach a concept through a **named Atlas artifact**, never a generic tutorial.
- **What went wrong is teaching material:** record the real troubleshooting history — the tagging-mismatch bug, the `bridge-vids` miss, the `==`-vs-`:=` RADIUS bug — because a real failure teaches more than a clean success.

## Related
- `Atlas-Academy/README.md` (the 4-part module format) · `Concepts/README.md` (the concept modules these patterns are written into).
- `00-Atlas-Foundation/Decisions/ADR-0032` (diagnostics/verification architecture — where the "expected healthy" field-guide pattern lands) · Charter Rule 14 (honest status lines).
