---
Title: Network Revision History
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Network Revision History

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft for Confluence Review |
| Version | 1.0 |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07-14 |

## Version 1.0 Draft

Initial Confluence review edition containing:

- verified architecture and addressing;
- VLAN, routing, security, and management standards;
- current Source of Truth;
- validation and lessons learned;
- device Build Records;
- target Build Guides for FGT01, MKT01, SW01, and PVE01 networking.

## Revision History

🔴 **Populated 2026-07-14 (051 / F5).** This page previously contained **no revision entries at all** — which is why `CM-0001`, `CM-0002`, `CM-0003` and `CM-0008` each carry an unticked `[ ] Revision History` box: they point at a log that had never been written.

**Book 1 (Enterprise Network) was FROZEN on 2026-07-14** (`NETWORK-PACK-MANIFEST.md`, authoritative). The per-record and per-document history now lives in the authoritative sources below; this page indexes them rather than duplicating them (one authoritative home — Charter Rule 4):

| Source | What it records |
|---|---|
| `NETWORK-PACK-MANIFEST.md` | Pack status, the freeze, and the verified Change-Record status table. |
| `Change-Management/README.md` | The full CM/MC index (CM-0001–CM-0033, MC-0001/0002) with per-record status. |
| Each document's own `## Change Log` | Per-document version history (e.g. `001`, `016` v3.0, `021`, `023`, `024` v2.2, `029` v2.2). |
| `00-Atlas-Foundation/Decisions/` | The ADRs (ADR-0001–ADR-0019) — the *why* behind structural changes. |

> **Still owed:** a consolidated per-version table for every Book 1 document. Building it is a discrete task (author it from the Change Logs above); it was never done, and until it is, the four unticked Revision-History boxes above cannot be cleanly ticked. Flagged here so it stops being invisible.

## Freeze Criteria

Version 1.0 froze after publication, whole-book Confluence review, correction of factual conflicts, reconciliation with live devices, completion (or explicit ADR-deferral) of required change records, and rebuild-oriented review. 🔴 **Book 1 met these and was FROZEN on 2026-07-14** (`NETWORK-PACK-MANIFEST.md`). *(The rebuild-oriented review is the `051` audit; the one remaining rebuild-oriented step nobody has performed is an actual Game-Day rebuild — `ADR-0011`.)*
