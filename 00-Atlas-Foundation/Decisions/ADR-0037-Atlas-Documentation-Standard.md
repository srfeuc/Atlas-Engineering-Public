# ADR-0037 — Adopt the Atlas Documentation Standard (per-device & per-service doc architecture)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-28); **amended 2026-07-29 (v1.1)** — added the `Roadmap.md` doc-type + the connections-map requirement (see Change Log); **amended 2026-07-29 (v1.2)** — +📸 capture markers, per-device Certification alignment, staged Traffic-flow diagram, and a Validation link; fact-ownership map extended to `Operations/`. |
| Governing Policy | POL-0014 |
| Materialized as | [STD-0005 — Device Documentation](../Standards/STD-0005-Device-Documentation.md) · this ADR is the adopting decision; the standing requirements now live in that standard (`ADR-0054` (B)→standard) |
| Scope | **Global** — estate-wide principle (applies across labs; Lab-01 already conforms, frozen) |
| Date | 2026-07-28 |
| Supersedes | — (new standard). Complements `ADR-0032` (which defined the Diagnostics/Troubleshooting split + Academy command library); this ADR generalizes to the **whole** per-device/per-service document set and the order it is authored in. |
| Related | `POL-0008` (one source of truth per fact), `POL-0001` (the device is the source of truth), `ADR-0032` (Diagnostics/Troubleshooting + Command-Library), `ADR-0033` (ADR Scope field), `Atlas-Academy/Atlas-Teaching-Patterns-and-House-Style.md` (writing voice), the Lab-01 device folders (the exemplar the standard is generalized from). |
| Governing doc | `00-Atlas-Foundation/Atlas-Documentation-Standard.md` (the living standard this ADR adopts). |
| Evidence Status | **Decision** (operator, 2026-07-28). Governs *how* the estate is documented; it does not itself build or verify anything. |

## Context

Two recurring failures motivate a written documentation standard:

1. **Decisions get made but documents don't get updated.** A fact lives in several places; one gets changed; the others rot. This is the operator's single most-stated concern. The estate already has `POL-0008` (one source of truth) as a principle, but no concrete rule for *which* document owns *which* fact, so the principle wasn't enforceable.
2. **Every device was documented a little differently, and a lot was never recorded.** Lab-01's own history shows information that existed on the device but never made it into a doc — which is fatal for a lab whose whole point is to be **torn down and rebuilt from the guides.** Lab-01 evolved a good per-device pattern late (README front-door · Build-Guide · Build-Record · Verification · Considerations · Troubleshooting · `Changes/` · `Roles/` for multi-service hosts), but it was never written down as *the* standard, so Lab-02 drifted to a lighter, inconsistent set.

Lab-02 is about to go deep (AD CS ceremony, service estate, segmentation). Getting the documentation shape right **before** that depth is the point — retrofitting consistency across a half-built estate is exactly the bulk-change failure mode the operator wants to avoid.

## Decision

**Adopt `Atlas-Documentation-Standard.md` as the estate's canonical documentation architecture.** Its load-bearing choices:

1. **A fixed per-device folder shape** — the same document types, named identically, on every device: `README` (front-door + doc index + **connections map**) · **`Roadmap` (per-role build path + dependency graph)** · `Build-Checklist` · `Considerations` · `Build-Guide` · `Build-Record` · `Diagnostics` · `Troubleshooting` · `Changes/`. A reader always knows which page answers which question.
2. **The document lifecycle is ordered by *when* it is authored**, not alphabetically: `README` + **`Roadmap`** + `Build-Checklist` + `Considerations` at planning; `Build-Guide` / `Build-Record` / `Diagnostics` at the bench as the device is actually built. This encodes the operator's **checklist-first** workflow (plan the *what* now; capture the *how* while hands are on the device).
3. **The `Roles/` pattern for multi-service hosts** — each service on a host is documented as its own unit under `Roles/<Service>/`, so "a build checklist for each service" is literal. The host folder owns the box (OS/IP/hardening/backup); each role folder owns one service. A fact lives in exactly one of them. Lab-02 multi-service hosts: DC, SRV01, MON01, BKP01, NETBOX01, RCA01/ICA01.
4. **Fact ownership is written down** — addresses → the IP plan (+ NetBox); a decision → its ADR; flows → the flows matrix; reusable commands → the Academy Command-Library; "where we are" → the handoff. Every other mention **links** to the owner rather than restating it. This is `POL-0008` made enforceable.
5. **Standard per-document elements** — YAML frontmatter, a provenance banner (`Lab-02 · Cisco-Core (ACTIVE) · Host · Role`), a Document Control table, a Change Log, and the estate marker convention (✅ device-verified · 🟡 lab-unverified · 📋 planned · 🔴 blocker).
6. **Roll out one device (or service group) at a time**, as each build/checklist wave runs — explicitly **not** a mass restructure. Lab-01 stays frozen and is not retrofitted.

> **Amendment (2026-07-29, v1.1).** Two additions proven on the **DC-Domain-Controllers** worked exemplar and now folded into the standard: (a) a **`Roadmap.md`** doc-type — the per-role build path (each role/service in build order with **Needs** / **Unblocks**), authored at planning alongside README/Checklist/Considerations; and (b) an explicit **connections-map** requirement on `README` — what the host **depends on**, what **depends on it**, and which **services it touches**. Both are in `Atlas-Documentation-Standard.md` v1.1 + `Atlas-Documentation-Workflow.md` v1.1.

> **Amendment (2026-07-29, v1.2).** Four per-device **analytical elements** — each a slice that links to an estate owner (`POL-0008`): (a) **📸 capture markers** in the Build-Guide (a first-class element — a capture at each decision/confirmation/acceptance screen, never a live secret); (b) a **Certification alignment** table in `Roadmap.md` (role → objective → cert + learning-focus, the device's slice of the estate device×cert matrix); (c) a **staged Traffic-flow diagram** (allowed vs blocked, drawn stage-by-stage as tested units are applied — mirrors `ADR-0041`; visualizes the flows matrix); (d) a **Validation link** to `Operations/Validation-and-Adversarial-Testing.md` + `Diagnostics.md`. The **fact-ownership map** is extended to name **`Operations/`** as the home for estate-level operational artifacts (validation, build-order/dependencies, backup/DR, confirmation), with device folders holding linking slices. All in `Atlas-Documentation-Standard.md` v1.2 + `Atlas-Documentation-Workflow.md` v1.2.

## Alternatives Considered

- **Keep Lab-02's lighter ad-hoc pattern.** Rejected — it is the source of the inconsistency and the "never recorded" gap this ADR exists to close.
- **Bulk-restructure every existing device now to match.** Rejected — mass changes leave docs behind (the operator's stated scar); the standard is applied per-wave instead.
- **Fold everything into one big per-device page.** Rejected — mixes "how to build," "as-built state," and "how to verify," which have different authoring times and different readers. Separate documents, separate lifecycles.
- **One flat checklist per host (no `Roles/`).** Rejected — multi-service hosts then bury each service's facts together; the operator explicitly wants a checklist per service.
- **Leave `POL-0008` as an unqualified principle.** Rejected — without a written fact-ownership map, "one source of truth" isn't enforceable, and drift recurs.

## Consequences

- **Create** `00-Atlas-Foundation/Atlas-Documentation-Standard.md` (done) as the living governing doc; this ADR records the decision to adopt it.
- Each build/checklist wave **adds the missing pieces** (`README`, `Considerations`, `Roles/`, `Build-Record`) for the device it touches; existing `Build-Checklist`/`Build-Guide`/`Diagnostics`/`Troubleshooting` conform as-is.
- The **Build-Guide becomes a first-class rebuild contract** — it must capture enough that the device can be rebuilt from it after teardown (the Lab-01 gap). A companion **capture workflow** (how/when each doc is touched during a build; how the Academy is fed show + config commands) will be authored next and referenced from the standard.
- **Atlas Academy** remains the command-library owner (`ADR-0032`); the standard reinforces that device pages link up rather than copy — Academy still needs a dedicated pass (deferred, tracked in the register B-series / Academy track).
- **CIS-Hardening** stays central in `Architecture/CIS-Hardening-<device>.md` for now; a per-device move is optional-future, not required by this ADR.
- **(v1.1, 2026-07-29)** Every device folder now also carries a **`Roadmap.md`** (per-role build path + dependency graph) and a **connections map** in its `README`; proven on the DC exemplar and codified into the standard + workflow. Per-wave rollout adds these alongside `README`/`Considerations`.
- **(v1.2, 2026-07-29)** Each device also carries four **analytical elements** — 📸 capture markers (Build-Guide), a **Certification alignment** table + a **staged Traffic-flow** slice (`Roadmap`), and a **Validation link** (`Operations/`) — and the fact-ownership map now routes estate-level operational artifacts to **`Operations/`**. This is what fills `Operations/` out as the cross-device operations index.

## Review Trigger

- If applying the standard per-wave proves too slow and devices are shipping without their `README`/`Considerations`, revisit whether a lightweight scaffolding pass (empty templated files) should run ahead of the builds.
- If the `Roles/` split causes host- vs role-level facts to be duplicated in practice, tighten the "host owns the box, role owns the service" boundary in the standard.

## Change Log

| Version | Changes |
|---|---|
| 1.2 | 2026-07-29. **Amended** — added four per-device **analytical elements** (📸 capture markers · `Roadmap` **Certification alignment** · **staged Traffic-flow** diagram per `ADR-0041` · **Validation link** to `Operations/`), and extended the **fact-ownership map** to give `Operations/` the estate-level operational artifacts with device folders holding linking slices. Governing docs → `Atlas-Documentation-Standard.md` v1.2 + `Atlas-Documentation-Workflow.md` v1.2. |
| 1.1 | 2026-07-29. **Amended** — added the **`Roadmap.md`** doc-type (per-role build path with Needs/Unblocks, authored at planning) and the **connections-map** requirement on `README` (depends-on / depended-on-by / services-touched), from the **DC-Domain-Controllers** exemplar. Governing docs updated: `Atlas-Documentation-Standard.md` v1.1 + `Atlas-Documentation-Workflow.md` v1.1. Closes the register pending-propagation flag. |
| 1.0 | 2026-07-28. Accepted. Adopts `Atlas-Documentation-Standard.md`: the fixed per-device folder shape, the author-in-this-order document lifecycle (checklist-first), the `Roles/` pattern for multi-service hosts, a written fact-ownership map (`POL-0008` made enforceable), the standard per-doc elements + marker convention, and per-wave (not bulk) rollout with Lab-01 frozen. Notes the Build-Guide as the rebuild contract and a forthcoming capture-workflow companion. |
