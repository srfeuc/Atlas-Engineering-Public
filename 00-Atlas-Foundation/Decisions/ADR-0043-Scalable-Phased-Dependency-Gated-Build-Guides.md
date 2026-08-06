# ADR-0043 — Scalable, Phased, Dependency-Gated Build-Guides (and the estate build-order consolidation)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29). Governs Build-Guide structure + the estate build-order. |
| Governing Policy | POL-0015 (+POL-0014) |
| Materialized as | [STD-0011 — Phased Dependency-Gated Build-Guides](../Standards/STD-0011-Phased-Build-Guides.md) · this ADR is the adopting decision; the standing requirements now live in that standard (`ADR-0054` (B)→standard) |
| Scope | **Global** — build-execution documentation methodology (the Lab-02 estate-order consolidation is its first application). |
| Date | 2026-07-29 |
| Supersedes | — (amends the `ADR-0037` Build-Guide doc-type; consolidates the Lab-02 order docs) |
| Related | `ADR-0037` (doc standard — Build-Guide doc-type → v1.3) · `ADR-0041` (incremental, test-gated — the per-phase gate) · `ADR-0032` (Diagnostics) · `POL-0008` (one home per fact) · `POL-0001` · the per-device `Roadmap.md` (the map this guide mirrors) · register **E1/E2** (the drift this fixes) · the docs consolidated (`Architecture/Master-Build-Order`, `Master-Implementation-Checklist`, `Build-Progress-Tracker`, `Architecture/Atlas-Service-Architecture`). |
| Governing docs | `00-Atlas-Foundation/Atlas-Documentation-Standard.md` (Build-Guide doc-type, to amend → v1.3) · a new `Operations/Build-Order-and-Dependencies.md`. |
| Evidence Status | **Decision** (operator, 2026-07-29). Governs *how* builds are documented and sequenced; builds nothing itself. |

## Context

The estate's build repeatedly stalled because the **build order and per-device roadmap were decided at the bench, mid-build.** Three overlapping order docs — `Master-Build-Order` (plan + why + gates), `Master-Implementation-Checklist` (the decision-free sequence), and `Build-Progress-Tracker` (order + status + log) — drifted apart, and each device's forward path (when to apply certs, when to add a service, whether a cloud phase is even doable yet) was assembled on the fly. That improvisation is precisely what produced the cleanup this whole effort is unwinding.

The operator has a **fixed window before device access** and wants the *entire* path pre-decided so building is mechanical, and wants the guides to **scale** as new capabilities land (Ansible/automation, a WLC from an autonomous AP, more services) — without another rewrite.

## Decision

Two coupled decisions.

### (1) Build-Guides become the complete, phased, dependency-gated executable path for their device — mirroring the `Roadmap.md` 1:1.

- **Phases mirror the Roadmap's rows.** The Roadmap owns the sequence + dependency graph (Needs/Unblocks); the Build-Guide is the *how* for each of those phases, **in the same order**. There is no second sequence to drift.
- **Every phase opens with a 🔴 GATE** — *"do not start until: [dependencies healthy] + [these machines exist] + [prior phase ✅]."* This is the anti-improvisation control; it makes `ADR-0041`'s test-gate explicit at phase granularity, and it is how future/cloud phases are fenced off.
- **Standard recurring sections**, in a fixed place, wherever the device needs them: **Certificate application (from ICA01 / AD CS)** — request → enroll → install → verify the device's cert(s); **Service setup** — per service (the `Roles/` pattern on multi-service hosts); **Automation onboarding** — the Oxidized / Ansible / config-management hook (a slot, filled when automation lands).
- **Future/cloud phases are present as GATED STUBS now** — each carries its gate (deps + machines + prior-phase), a step **outline**, and its cert/service hooks. **Full click-by-click steps are written when the phase is reached** (the tenant/hardware exists). You see the whole path; you cannot jump ahead; nothing speculative rots.
- **Append-only scaling.** A new capability (Ansible, WLC-from-AP, a new service) enters as a **new gated phase section**, not a rewrite. The structure absorbs growth.
- **Detailed per-phase sub-guides nest under the guide.** When a phase's steps warrant their own document (the DC's OU / GPO / Tiered-Admin builds; a service's deep setup), that sub-guide lives **nested under the device's Build-Guide** — a **`Build-Guide/` subfolder** holding the **spine** (the top-level guide that indexes the phases) plus its **phase sub-guides** — not flat alongside the device's top-level docs. Rule of thumb (mirrors the `Roles/` pattern): a device with a single guide keeps a top-level `Build-Guide.md`; a device with a spine + multiple phase sub-guides gets the `Build-Guide/` subfolder. This keeps the folder navigable as phases multiply.
- **The guide links, never restates.** It points to the Roadmap (per-device map) and the estate `Build-Order-and-Dependencies` (cross-device order); it does not redraw the dependency graph (`POL-0008`).

### (2) Consolidate the estate build-order to one owner.

`Master-Build-Order` + `Master-Implementation-Checklist` → a single **`Operations/Build-Order-and-Dependencies.md`** (the Lab-01 model; register **E2**) that owns the **cross-device sequence + the chicken-and-egg dependency map**. `Build-Progress-Tracker` trims to a pure **execution/status log** that links to it. `Atlas-Service-Architecture` stays as the **service/role design** (why each service exists / where it lands) with a scope banner + links. **Cross-device order is decided once, in one place.**

## Alternatives Considered

- **Keep Build-Guides core-only; the Roadmap holds the future.** Rejected — leaves the future path un-sequenced, so it gets assembled at the bench (the exact failure mode).
- **Write full future/cloud procedures now.** Rejected — speculative against portals/tenants that do not exist yet; they would drift before execution. Gated stubs capture the *when/what* without the rot.
- **One giant estate build-guide instead of per-device.** Rejected — does not scale, mixes device concerns, and is what the device-by-device move already replaced.
- **Leave the three order docs with scope banners.** Rejected — three near-identical owners is the drift source; one owner is the fix (`POL-0008`).

## Consequences

- The Documentation Standard's **Build-Guide doc-type is amended (→ v1.3)** to specify the gated-phase structure + the Certificate-application / Service-setup / Automation-onboarding sections + the future-phase gated-stub rule.
- A new **`Operations/Build-Order-and-Dependencies.md`** is authored (consolidating the two order docs); the tracker + service-architecture are re-scoped to it. (Fills out `Operations/` per the `ADR-0037` v1.2 fact-ownership extension.)
- Every device Build-Guide is (re)authored to the phased/gated model as its wave runs; the **DC guide is the worked exemplar** — gate headers per stage + a **Certificate-application phase** (its LDAPS cert from ICA01) + the **H1–H4 hybrid phases as gated stubs**. Its phase sub-guides (`DC01/DC02-Build-Guide.md` + `OU-`/`GPO-`/`Tiered-Admin-and-Groups-Build.md`) move into a **`Build-Guide/`** subfolder with all cross-links fixed (README / Roadmap / Build-Checklist), reversing the earlier flat-staged call now that the phase set is growing.
- **Building becomes mechanical:** read the estate order → open the device guide → execute gate-by-gate. The "what's next?" deliberation is removed — the stated goal.
- **Scales cleanly:** Ansible, a WLC-from-AP, and new services enter as new gated phases.

## Review Trigger

- If a device's guide and its Roadmap ever disagree on phase order, **the Roadmap wins** (it owns the sequence) and the guide is corrected — never a third sequence.
- If gated stubs accumulate without ever being filled, that phase is really out-of-scope — demote it from the guide to the Roadmap's future section.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Accepted. **(1)** Build-Guides become complete, phased, dependency-gated executables mirroring the `Roadmap` 1:1 — per-phase 🔴 GATE, standard **Certificate-application / Service-setup / Automation-onboarding** sections, future/cloud phases as **gated stubs** (full steps when reached), append-only scaling, link-don't-restate; **detailed per-phase sub-guides nest under a `Build-Guide/` subfolder** (spine + phase docs, mirroring the `Roles/` pattern). **(2)** Estate build-order consolidated to one **`Operations/Build-Order-and-Dependencies`** (register E2); tracker → execution log; `Atlas-Service-Architecture` → design + links. Fixes the decide-at-the-bench drift; the DC guide is the exemplar. Standard Build-Guide doc-type → v1.3 (pending propagation). |
