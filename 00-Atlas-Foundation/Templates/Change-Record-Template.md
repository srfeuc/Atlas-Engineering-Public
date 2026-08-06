# CM-XXXX — Change Title

| Item | Value |
|---|---|
| Status | Draft |
| Risk | Low / Medium / High |
| Affected systems | |
| Silo(s) / boundary crossed | *e.g. `Network → Security`; or `within Network, accepted design`* |
| Date | |

> **`Silo(s) / boundary crossed`** — per `ADR-0018`, a change that crosses a silo boundary is *why* this record has to exist. Name the crossing (`Network → Security`), or state that the change stays within one silo's accepted design. **A blank here means nobody decided which silo owns this** — which is itself the problem the boundary is meant to expose.

## Purpose

## Reason

## Prerequisites

## Backup

## Implementation

## Validation

**Read the resulting state back.** A command that returned no error is not a confirmed change.

## Rollback

## Documentation updates

- [ ] Build Record updated
- [ ] Revision History updated
- [ ] Confluence published and reviewed

## Guide Reconciliation — required, not conditional

> **Does any guide now contain an instruction that would recreate this problem, or a claim that this change disproves?**

Answer for **every guide touching the affected system**. **Do not tick — state the outcome.**

| Guide | Outcome | Detail |
|---|---|---|
| *e.g. `033-Pi01-FreeRADIUS-Build-Guide.md`* | Updated / Reviewed — no change needed / Not applicable | *What changed, or why nothing needed to.* |
| | | |

**"The target didn't change" is not a valid reason to skip this.** The target does not have to move for a guide to become dangerous. A guide can keep describing a correct target while teaching a step that is now known to be harmful, ineffective, or a credential you just deleted.

## Closeout

- [ ] Implemented
- [ ] Validated — resulting state read back, not inferred from exit code
- [ ] Build Record updated
- [ ] **Guide reconciliation answered in writing above**
- [ ] Closed

> 🔴 **A record does NOT move to `Closed` while any box above is unticked.** If a box cannot be ticked, the status is **`Implemented — reconciliation open`** — `CM-0010` uses this correctly.
>
> **`CM-0009` was marked `Closed` with its "Build Record updated" box unticked.** The Build Record then described a firewall that no longer existed **for a full day**, and nobody noticed until the pack was being published.
>
> **The closeout was invented to catch exactly this class of defect — and then the closeout itself was not completed. A checklist nobody verifies reports success by default.**

---

*Per Charter Locked Rule 15. The previous version of this template asked for "Build Guide, if target procedure changed" — that conditional let five real defects survive into published documentation, including a guide instructing you to recreate a deleted network-device credential.*
