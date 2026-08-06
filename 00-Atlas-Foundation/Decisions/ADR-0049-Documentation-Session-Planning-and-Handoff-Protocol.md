# ADR-0049 — Documentation-Session Planning & Handoff Protocol (Ask-at-Planning · Living-STATE Handoff · Edge-Labelled Diagrams)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-30) — the *process* for the documentation-replication work; adopted mid-wave and applied to RDS01 (the first device built under it). |
| Governing Policy | POL-0014 |
| Materialized as | [STD-0009 — Session Planning & Handoff](../Standards/STD-0009-Session-Planning-and-Handoff.md) · this ADR is the adopting decision; the standing requirements now live in that standard (`ADR-0054` (B)→standard) |
| Scope | **Global** — an estate-wide documentation *process* + handoff practice. |
| Date | 2026-07-30 |
| Amends / builds on | **Amends `ADR-0037`** (Documentation Standard → **v1.6**: connections-diagram edges labelled with protocol/port) · **extends `ADR-0032`** (the continuous-handoff protocol → the `SESSION-HANDOFF` becomes a pinned *Living STATE* block + an append-only log with a read rule) · operationalizes `Operations/Device-Page-Set-Replication-Prompt.md`. |
| Related | `ADR-0037` (Doc Standard) · `ADR-0032` (Diagnostics + continuous handoff) · `ADR-0043`/`ADR-0044`/`ADR-0041` (phased-gated / enterprise-first / test-gated) · `POL-0008` (one home per fact) · `POL-0001` (device is truth) · `Atlas-Improvement-Backlog` #20/#22/#23. |
| Evidence Status | **Process decision** — adopted this session; RDS01 is the first device built under it (placement/gateway/VLAN asked + resolved at planning). |

## Context

The active work is replicating the DC-Domain-Controllers page-set across the estate (`Operations/Device-Page-Set-Replication-Prompt.md`). Two things surfaced (operator, 2026-07-30) that, left informal, would be re-litigated every session and would inflate the later estate sweeps:

1. **Design decisions are cheaper to make at a device's planning moment than in a sweep.** On RDS01, asking the operator three questions at planning (host placement, whether to include the RD Gateway, which VLAN) resolved them immediately and correctly, instead of leaving three 🟡 "decide in #20/#22" holes. The operator's words: *"The questions help a lot… and should be a big part of this planning phase… so the next sweep doesn't have as much to do."*
2. **The handoff must stay a reliable landing spot as it grows.** `SESSION-HANDOFF.md` gains a block per device and is already ~66 KB. A fresh session needs a deterministic "where are we / what must I read" without parsing the whole history. The operator wants everything tracked **for bots, for other sessions, and for himself**, and is fine formalizing the process (*"whatever makes things easier for you bots"*), including giving the handoff its own ADR and archiving retired parts to `99-Archive`.

The operator also flagged that the **connections mermaid diagrams are one of the most important artifacts** for understanding the estate — so they should carry more of the "how connected" story.

## Decision

Adopt the following protocol for all documentation-replication sessions (Global).

### 1. Ask design questions at planning (the question norm)
During a device's **planning moment** (README/Roadmap/Checklist/Considerations authoring), surface that device's open design decisions to the operator as **explicit questions** and resolve them *then* — placement/uptime tier, role scope, VLAN/addressing, tiering & access, and which optional services are in scope. Record each resolution in the device `Considerations.md` **"Decided"** section and propagate to the fact-owner (`POL-0008`: IP plan, flows matrix, estate index, an ADR). **Deferring to a sweep is the exception, not the default.** The operator may answer directly or point at the owner doc that already answers it.

### 2. Handoff = a pinned *Living STATE* block + an append-only log
`SESSION-HANDOFF.md` carries a **`📍 CURRENT STATE`** block pinned at the top — always kept current — above the existing **append-only, newest-first session log**. STATE holds: the read rule, the wave position + next device, the standing protocol, the governing-doc pointers, and the open cross-device items. The session blocks below are the durable history.

### 3. Handoff read rule
A fresh session **must read the `📍 CURRENT STATE` block + the most recent session block in full before acting.** Older session blocks are history — read on demand. (This extends `ADR-0032`'s continuous-handoff protocol with an explicit "read-to-state" contract.)

### 4. Update cadence
Update the handoff (**refresh STATE + append a session block**) **after each device's folder is created/updated** — the operator's cadence.

### 5. Archiving
When the log passes **~8 session blocks or ~80 KB**, move the oldest blocks to **`99-Archive/Lab-02-SESSION-HANDOFF-archive-<date>.md`** and leave a one-line pointer. Keeps the landing fast; `99-Archive` is the estate's home for retired/oversized content.

### 6. Per-device narrowing
The DC template is a **starting shape, not the final one** (`ADR-0037`; Backlog #22). Tailor each device to its real roles/services/connections; prune template carry-over. Anything that belongs in `Considerations.md` or Atlas Academy is **added inline when it doesn't disrupt the current device, else captured as a placeholder or a backlog entry (#22)** — never dropped.

### 7. Connections diagrams label edges with protocol/port (Standard → v1.6)
The README connections mermaid diagram labels each **edge** with the service/protocol+port it carries (e.g. `LDAPS/636`, `RDP/3389`, `RADIUS/1812`, `HTTPS/443`); **nodes keep short role labels, never IPs** (`POL-0008`). Existing device diagrams gain edge labels as each device is next touched or in the **#22** audit.

## Alternatives Considered
- **Defer all design calls to the #20/#22 sweeps.** Rejected — that is exactly the sweep-debt this avoids; the operator confirmed asking at planning "helps a lot."
- **Leave the handoff as one growing narrative.** Rejected — no deterministic landing state; unbounded growth buries "where we are."
- **A separate always-current `STATE.md` file** (split from the handoff). Considered, deferred — one file = one place to look; revisit if the handoff still bloats after archiving.
- **Keep node-only diagrams.** Rejected — the operator relies on the diagram to *understand* the estate; the connection semantics belong on the picture.
- **Not writing an ADR (just doc edits).** Rejected — this is a standing, estate-wide process change; the operator explicitly wanted it recorded durably so it isn't re-litigated ("keep track of everything for you, other sessions, and me").

## Consequences
- **`Operations/Device-Page-Set-Replication-Prompt.md`** gains a **Planning & Handoff Protocol** section (the norm every successor reads on arrival); §10 reading order points at the STATE block first.
- **`SESSION-HANDOFF.md`** restructured to the **STATE + append-log** shape; the read rule lives in STATE.
- **Documentation Standard → v1.6 / Workflow → v1.6** — connections-diagram edges labelled with protocol/port (amends `ADR-0037`).
- **`ADR-Index` → new Global row** + version bump.
- **Applied to RDS01** already (placement → EQR6, gateway included, VLAN 20 — all asked + resolved at planning); every subsequent device inherits the protocol.
- **Backlog:** edge-label backfill of the 8 existing device READMEs folds into **#22** (no new sweep created). The ask-at-planning norm is expected to *shrink* #20/#22.
