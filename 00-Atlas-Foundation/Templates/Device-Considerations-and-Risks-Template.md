---
Title: [Device] Considerations and Risks
Path: [Path in Confluence]
---

# [Device] Considerations and Risks

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 0.1 |
| Applies To | [Device] ([role/IP]) |
| Last Reviewed | [Date] |

## Purpose

The standing list of **what could bite you on [Device]** — design risks, known-weak spots, and unverified assumptions — each with **a way to check it**. This is the "read before you trust, rebuild, or harden this device" page. It complements the Troubleshooting Guide (reactive — after something breaks) and the CIS Checklist (hardening posture).

## How to read this

Each item is typed:

- 🟩 **Recommendation** — a best practice to adopt. Not necessarily wrong today; a way to make it better/safer.
- 🟨 **Hole** — an unverified assumption or a known-weak spot. Needs the check in its row run to settle it.
- 🟥 **Device-gated** — a confirmed issue whose fix requires a live device read/write (usually tied to a change record). Not resolvable by editing docs.

**Verify, don't assume.** Every row carries the command that settles it — run that, don't trust the status column (Rule 13).

## Considerations & Risks

| # | Consideration / Risk | Type | How to verify | Current status | Ref |
|---|---|---|---|---|---|
| 1 | [what could bite you] | 🟨 Hole | `[read-only command]` | [what the device shows / "unchecked"] | [doc / CM / ADR] |

## Open holes — summary

The rows above still unresolved, most consequential first:

1. [item] — [one line on why it matters + what closes it]

## For the next build (Device Role Plan / Service Architecture)

Carry-forward lessons — what to do *right* on this class of device next time, so the hole never exists:

- [lesson]

## Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | [date] | Created. |

## Related pages

- **Verification Procedure: [NNN]-[Device]-Verification-Procedure.md**
- Build Guide(s): [NNN] · Build Record: [NNN] · Troubleshooting: [NNN] · CIS: [NNN]
- Change records: [CM-/MC- as relevant]
