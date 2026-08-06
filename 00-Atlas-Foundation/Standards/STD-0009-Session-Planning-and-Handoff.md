---
Title: STD-0009 — Session Planning & Handoff Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0014` via `ADR-0049`. In force.
Version: 1.0
---

# STD-0009 — Session Planning & Handoff

> **At a glance.** Design questions are asked and resolved at planning; the handoff keeps one pinned `📍 CURRENT STATE` block above a newest-first append log; a session reads STATE + the latest block before acting and refreshes them after each piece — so no work is lost and no decision is silently deferred.

| Item | Value |
|---|---|
| Layer | **Standard** — the session process + handoff shape; binds every documentation session |
| Governing policy | [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) — Documentation & Knowledge Management |
| Requirement, in one line | Ask-at-planning · pinned CURRENT-STATE handoff + append log · the read rule · edge-labelled diagrams |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0049`](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Detailed spec | [`Device-Page-Set-Replication-Prompt`](../../Labs/Lab-02-Cisco-Core/Operations/Device-Page-Set-Replication-Prompt.md) + the live [`SESSION-HANDOFF`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) (the worked exemplar) |
| Applies to | every documentation/build session; the handoff; every device README diagram |
| Feeds / fed by | **feeds** [`STD-0005`](./STD-0005-Device-Documentation.md) (the edge-label rule → Standard v1.6) · **fed by** the replication prompt |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | change/handoff discipline · the Atlas Standard v1.6 |

---

## Scope & applicability

Binds how a session plans, records decisions, and hands off — the ask-at-planning discipline, the handoff structure and read rule, and the edge-labelled diagram amendment.

**Boundary with adjacent standards:** *the page-set the session produces* is [`STD-0005`](./STD-0005-Device-Documentation.md); *how a change is controlled* is [`POL-0003`](../Policies/POL-0003-Change-Control.md); this standard owns the *session process* around them.

## Why a standard, not left in a guide

The estate reverses decisions often and work spans many sessions — so "where are we, and what did the last session leave owed?" must be answerable in two blocks, and design calls must be made *at planning* (not silently deferred into a giant sweep). This standard is why the handoff you're reading has the shape it does.

---

## The requirements

Each is citable as `STD-0009 R#`.

### R1 — Ask design questions at planning

At a device's planning moment, open design calls (placement/uptime tier, role scope, VLAN/addressing, tiering/access, optional services) MUST be **surfaced as explicit questions and resolved then**, recorded in `Considerations.md` **"Decided"** + propagated to the fact-owner. Deferring to a sweep is the exception, not the default.

### R2 — The handoff is a pinned STATE block + an append log

`SESSION-HANDOFF.md` MUST carry a pinned **`📍 CURRENT STATE`** block (read rule, wave position + next device, open cross-device items) **above** a newest-first, append-only session log.

### R3 — The read rule

A fresh session MUST read the **`📍 CURRENT STATE` block + the most recent session block in full before acting**; older blocks are read on demand.

### R4 — The update cadence

Refresh **STATE + append a session block after each logical piece**; when the log passes **~8 blocks / ~80 KB**, archive the oldest to `99-Archive/Lab-02-SESSION-HANDOFF-archive-<date>.md` with a pointer.

### R5 — Edge-labelled connections diagrams (Standard → v1.6)

A README Mermaid diagram MUST **label each edge with protocol/port**; nodes stay role-labelled, never IPs. (This is the `ADR-0049` amendment to [`STD-0005`](./STD-0005-Device-Documentation.md) R3.)

### R6 — Per-device narrowing

The DC template is a **starting** shape — tailor/prune per device; nothing is dropped silently (inline, placeholder, or a Backlog #22 note).

---

## Adopting & amending decisions

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0049`](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md) | Accepted | ask-at-planning, the Living-STATE handoff + read rule, the edge-label amendment (all R#) |

(Originals in the legacy snapshot.)

## Verification (how conformance is proven)

- [ ] **R2/R3** — `SESSION-HANDOFF.md` has exactly one `📍 CURRENT STATE` block at the top, followed by a newest-first session log.
- [ ] **R4** — the live log is ≤ ~8 blocks / ~80 KB (older archived to `99-Archive/` with a pointer).
- [ ] **R5** — device README Mermaid edges all carry a `|proto/port|` label (backfill tracked in #22).
- [ ] **R1** — each recently-built device's `Considerations.md` has a "Decided" section.
- [ ] **Meta** — a change to the protocol traces to an amending ADR.

## Learn it — the source of truth for the *how*

- 🧭 **The operational prompt:** [`Device-Page-Set-Replication-Prompt`](../../Labs/Lab-02-Cisco-Core/Operations/Device-Page-Set-Replication-Prompt.md) (the doc-wave protocol this codifies)
- 📘 **How to document:** `AI-Context/How-To-Document` · `What-To-Check-First` (the cold-start read-order)
- 📎 **The worked exemplar:** the live [`SESSION-HANDOFF`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md)
- 📋 **Program:** [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md)

## What a violation looks like

A bulk restructure with no planning questions · a handoff with no `📍 CURRENT STATE` block or a buried latest state · a session acting without reading STATE + the latest block · a 12-block handoff that was never archived · a README diagram with unlabelled edges.

## Related

[`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (governing) · [`STD-0005`](./STD-0005-Device-Documentation.md) (the page-set + edge labels) · [`ADR-0049`](../Decisions/ADR-0049-Documentation-Session-Planning-and-Handoff-Protocol.md) · [`SESSION-HANDOFF`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0049` into a testable standard** (#39 (B)→STD): ask-at-planning, the pinned-STATE handoff + read rule + archive cadence, the edge-labelled-diagram amendment, and per-device narrowing — each with a structure read-back. Cut from `STD-Template`. |
