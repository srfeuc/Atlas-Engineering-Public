---
Title: STD-0008 — ADR Governance & Scope Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0014` via `ADR-0033`. In force.
Version: 1.0
---

# STD-0008 — ADR Governance & Scope

> **At a glance.** Every ADR carries a Scope tag (Global / Lab-01 / Lab-02) right after its Status, ADR numbers are one global never-reset sequence, and every ADR appears as a row in the index — so the decision trail stays navigable and complete. Provable by two greps.

| Item | Value |
|---|---|
| Layer | **Standard** — the meta-shape of the decision record; binds every `Decisions/ADR-*.md` + the index |
| Governing policy | [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) — Documentation & Knowledge Management |
| Requirement, in one line | Scope tag on every ADR · one global number sequence · every ADR indexed |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0033`](../Decisions/ADR-0033-ADR-Scope-Field-and-Index.md) (+ `ADR-0008` global numbering) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Detailed spec | [`Decisions/ADR-Index.md`](../Decisions/ADR-Index.md) (the living index) + [`Atlas-Documentation-Style-and-Conventions`](../Documentation/Atlas-Documentation-Style-and-Conventions.md) |
| Applies to | every `00-Atlas-Foundation/Decisions/ADR-*.md` |
| Feeds / fed by | **feeds** the `AI-Context/ADR-Navigation` navigator + the Legacy-ADR index · **fed by** the [`ADR-Template`](../Templates/ADR-Template.md) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | ADR practice (Nygard) · the Atlas Style/Conventions |

---

## Scope & applicability

Binds the *metadata and completeness* of the ADR set — the Scope field, the global numbering, and the index. It does not govern an ADR's content (that's each decision).

**Boundary with adjacent standards:** *how any doc is written* is [`Atlas-Documentation-Style-and-Conventions`](../Documentation/Atlas-Documentation-Style-and-Conventions.md); *how you move through the ADRs* is the `ADR-Navigation` navigator (Increment 5); this standard is the rule those rely on.

## Why a standard, not left in a guide

With 50+ ADRs across a frozen lab and an active one, "which lab does this decision bind, and is it even in the index?" has to be answerable at a glance. A missing Scope tag or an un-indexed ADR is how a reversed decision gets cited as current. A standard makes completeness grep-able.

---

## The requirements

Each is citable as `STD-0008 R#`.

### R1 — Every ADR carries a Scope tag

Every ADR's header table MUST carry a **`Scope`** row immediately after `Status`, valued **Global / Lab-01-Mikrotik-Core / Lab-02-Cisco-Core**.

### R2 — The scoping rule

**Global if the principle is estate-wide.** A lab-born lesson that generalizes is Global; a decision only meaningful against one lab's devices is scoped to that lab.

### R3 — One global number sequence

ADR numbers are a **single global sequence** (`ADR-0008`) — never reset per lab, never renamed, never split into per-lab folders; Scope is metadata only.

### R4 — Every ADR is indexed

[`ADR-Index.md`](../Decisions/ADR-Index.md) MUST list **every ADR by Scope → number → title → status**; adding an ADR MUST add its index row (and bump the index version).

---

## Adopting & amending decisions

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0033`](../Decisions/ADR-0033-ADR-Scope-Field-and-Index.md) | Accepted | the Scope field + the index-a-row rule (R1/R2/R4) |
| `ADR-0008` | Accepted | one global ADR number sequence (R3) |

(Originals in the legacy snapshot.)

## Verification (how conformance is proven)

- [ ] **R1** — `git grep -L '^| Scope |' 00-Atlas-Foundation/Decisions/ADR-0*.md` returns **nothing** (every ADR has a Scope row).
- [ ] **R4** — the ADR file count in `Decisions/` equals the row count in `ADR-Index.md` (no ADR missing from the index).
- [ ] **R3** — no duplicate or per-lab-reset ADR numbers; no `Decisions/Lab-*/` subfolders.
- [ ] **Meta** — a new ADR adds an index row + bumps the index version.

## Learn it — the source of truth for the *how*

- 🧭 **Navigate the ADRs:** `AI-Context/ADR-Navigation` (the index, supersession chains, how to add one) · the [`ADR-Index`](../Decisions/ADR-Index.md)
- 🧩 **The template:** [`Templates/ADR-Template`](../Templates/ADR-Template.md)
- 🖋️ **The conventions:** [`Atlas-Documentation-Style-and-Conventions`](../Documentation/Atlas-Documentation-Style-and-Conventions.md)
- 📋 **Program:** [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md)

## What a violation looks like

An ADR with no Scope row · an ADR file that isn't in the index (or vice-versa) · a per-lab ADR-number reset · a `Decisions/Lab-01/` folder · citing a superseded ADR because the Scope/status wasn't checked.

## Related

[`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (governing) · `AI-Context/ADR-Navigation` · [`ADR-0033`](../Decisions/ADR-0033-ADR-Scope-Field-and-Index.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0033` into a testable standard** (#39 (B)→STD): the Scope tag, the global-numbering rule, and index completeness — each with a `git grep` read-back. Cut from `STD-Template`. |
