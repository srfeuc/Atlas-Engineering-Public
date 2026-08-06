---
Title: STD-0005 — Device Documentation Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0014` via `ADR-0037` (amended by `ADR-0049` → v1.6; detail doc at v1.7). In force.
Version: 1.0
---

# STD-0005 — Device Documentation

> **At a glance.** Every device folder carries the same fixed page-set with the same analytical elements — a role-labelled Mermaid diagram with protocol/port on every edge, a Services map, a cert-alignment slice — and every fact has exactly one owner doc. Provable by a tree/grep check, not opinion.

| Item | Value |
|---|---|
| Layer | **Standard** — the concrete shape of a device's documentation; binds every `Devices/<host>/` folder |
| Governing policy | [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) — Documentation & Knowledge Management |
| Requirement, in one line | The fixed per-device page-set + required analytical elements + one-home-per-fact |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md); amended by [`ADR-0049`](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md) (→ v1.6) |
| Detailed spec | [`Atlas-Documentation-Standard.md`](../Documentation/Atlas-Documentation-Standard.md) (**v1.7** — the living detail: folder tree, elements, fact-ownership table) |
| Applies to | every `Devices/<host>/` folder in the active lab (Lab-01 is frozen) |
| Feeds / fed by | **feeds** every device folder + [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md) (Diagnostics/Troubleshooting) + [`STD-0009`](./STD-0009-Session-Planning-and-Handoff.md) (edge labels) · **fed by** the v1.7 detail doc + [`Contributing-Adding-Docs`](../Documentation/Contributing-Adding-Docs.md) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | ISO/IEC 26514 (doc) · the Atlas Documentation Standard v1.7 |

---

## Scope & applicability

Binds the *shape* of per-device (and per-service) documentation — which files exist, which analytical elements they carry, and who owns which fact. It does not dictate the *content* of a device's design (that's the device's own docs + the ADRs).

**Boundary with adjacent standards:** *where a doc goes / how it's added* is [`Contributing-Adding-Docs`](../Documentation/Contributing-Adding-Docs.md); *how a doc is written* (voice, frontmatter, secrets) is [`Atlas-Documentation-Style-and-Conventions`](../Documentation/Atlas-Documentation-Style-and-Conventions.md); *the Academy's shape* is [`STD-0006`](./STD-0006-Academy-Documentation.md); *diagnostics pages* are [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md).

## Why a standard, not left in a guide

Uniform structure is what makes 24 devices navigable and auditable — a reader (or an AI session) knows exactly where a fact lives on any device. Drift here (a missing Services map, an IP hard-coded where the plan should own it) is a `POL-0004` source-of-truth defect waiting to mislead a build.

---

## The requirements

Each is citable as `STD-0005 R#`. The [v1.7 detail doc](../Documentation/Atlas-Documentation-Standard.md) carries the full templates.

### R1 — The fixed per-device page-set

Every `Devices/<host>/` MUST carry, named verbatim: **`README` · `Roadmap` · `Build-Checklist` · `Considerations` · `Build-Guide` · `Build-Record` · `Diagnostics` · `Troubleshooting` · `Changes/`** (+ `Automation/`). The **planning subset** (README + Roadmap + Build-Checklist + Considerations) exists from the planning moment; the rest by the bench.

### R2 — Multi-service hosts document each service under `Roles/`

A host running several services MUST document each under **`Roles/<Service>/`** — the host owns the box, the role owns the service, each fact in exactly one place.

### R3 — The required README analytical elements

Every README MUST carry: a **connections map + a Mermaid diagram whose edges are labelled protocol/port** and whose nodes are **role-labelled (never IPs)**; and a **Services map** table (*Service · Purpose · Consumed-by + port · Depends-on · Status*).

### R4 — Roadmap cert-alignment + build elements

`Roadmap.md` MUST carry a **certification-alignment** table (role → objective → cert) and a staged **traffic-flow** slice + validation link; Build-Guides MUST carry **📸 capture markers** at each decision/acceptance screen (never capturing a live secret, `POL-0002`).

### R5 — One home per fact; everything else links

Every fact has **one owner doc**; every other mention **links, never restates** — addresses → the IP plan, a decision → its ADR, allowed flows → the flows matrix, commands → the Academy, "where we are" → the handoff (`POL-0004`/`POL-0008`).

### R6 — Rollout is per-wave, never bulk; Lab-01 stays frozen

The page-set rolls out **per wave**, reviewed one device at a time (`ADR-0049`); the frozen Lab-01 set is not restructured (`ADR-0022`).

---

## Adopting & amending decisions

The dated trail (originals in the legacy snapshot).

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) | Accepted | adopted the per-device page-set + analytical elements (all R#) |
| [`ADR-0049`](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md) | Accepted | amended the Standard → v1.6 (edge-labelled diagrams — R3) |

> ⚠️ **Note:** `ADR-0037`'s own body is stale (stops at v1.2); the **[detail doc](../Documentation/Atlas-Documentation-Standard.md) is authoritative at v1.7** (Services map, `Automation/`, gated Build-Guide, Mermaid edge labels). This standard tracks v1.7.

## Verification (how conformance is proven)

Structure checks — the [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit runs these.

- [ ] **R1** — for every `Devices/<host>/`, the planning subset exists: `git ls-files 'Labs/**/Devices/*/README.md'` count == device count; same for Roadmap/Build-Checklist/Considerations.
- [ ] **R3** — every README contains a ` ```mermaid ` block; `grep` its edges for any lacking a `|proto/port|` label (edge-label backfill tracked in #22).
- [ ] **R3** — every README contains a `## Services map` table.
- [ ] **R5** — a sampled fact class (an IP) appears in exactly one authoritative home (`git grep` the value → one owner, the rest links).
- [ ] **Meta** — any change to a required element traces to an amending ADR + a Change Log row on the [v1.7 doc](../Documentation/Atlas-Documentation-Standard.md).

## Learn it — the source of truth for the *how*

- 📘 **How to apply it:** `AI-Context/How-To-Document` (which doc answers which question) · [`Contributing-Adding-Docs`](../Documentation/Contributing-Adding-Docs.md) (placement)
- 🧩 **The templates:** [`Templates/`](../Templates/) — Build-Guide/Record, Considerations, Diagnostics, the page-set skeletons
- 🎓 **The voice:** [`Atlas-Teaching-Patterns-and-House-Style`](../../Atlas-Academy/Atlas-Teaching-Patterns-and-House-Style.md)
- 📋 **Program:** [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (the governing policy) · the per-device audit is Backlog #22

## What a violation looks like

A device folder missing `Diagnostics.md`/`Troubleshooting.md` · a Mermaid edge with no protocol/port · an IP restated instead of linked to the plan · a multi-service host with facts outside `Roles/` · a bulk page-set drop with no review.

## Related

[`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (governing) · [`Atlas-Documentation-Standard`](../Documentation/Atlas-Documentation-Standard.md) (detail, v1.7) · [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md) · [`STD-0009`](./STD-0009-Session-Planning-and-Handoff.md) · [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0037` into a testable standard** (#39 (B)→STD): the fixed page-set, the required analytical elements (edge-labelled Mermaid, Services map, cert slice), and one-home-per-fact — each with a structure-check read-back; links the v1.7 detail doc as the running spec and flags the ADR-body/doc version drift. Cut from `STD-Template`. |
