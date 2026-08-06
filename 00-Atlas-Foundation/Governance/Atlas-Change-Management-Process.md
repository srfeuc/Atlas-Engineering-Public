---
Title: Change Management
Path: 00-Atlas-Foundation/Governance
---

# Change Management

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Target Design |
| Evidence Source | [Charter](Atlas-Charter.md) Locked Rules 7, 12, 15; [`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) |
| Version | 2.2 |
| Last Verified | 2026-07-17 |

> **📋 Templates & governing rule.** This process is *operationalized by a policy*, *filled in with a template*, and *explained by a concept*:
>
> - **The template you fill** — [`Change-Record-Template.md`](../Templates/Change-Record-Template.md) for an ordinary, in-silo change; [`Major-Change-Record-Template.md`](../Templates/Major-Change-Record-Template.md) for a high-risk, multi-system, or boundary-crossing change. Both carry the `Silo(s) / boundary crossed` field this page requires.
> - **The policy that governs** — [`POL-0003 — Change Control`](../Policies/POL-0003-Change-Control.md): boundary-crossing → record · [count the OLD text to zero](../Policies/POL-0003-Change-Control.md) · fix the doing-doc first · close only on a read-back. This page is the *how*; `POL-0003` is the *standing requirement*, sitting on the silo model of [`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md).
> - **The concept that explains the why** — [`A Completed Command Is Not Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md): a green prompt is not a confirmed change, which is why step 8 (read-back) and the closeout exist.

## When a Change Record is required — the silo boundary

**Per [`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) (the Atlas operating model): a change that CROSSES a silo boundary requires a Change Record. A change WITHIN a silo, inside an already-accepted design, does not.**

The silos — 🔵 Network, 🟢 Systems/Compute, 🔴 Security/PKI, 🟡 Network Services, ⚪ Platform/DevOps — are roles, not people. The operator plays all of them, so a boundary crossing is a deliberate act by the same pair of hands, and the Change Record is what makes it deliberate instead of invisible. **Every disaster in Book 1 was a boundary crossing nobody paused at** (`CM-0011` — Network hardening on a stale baseline; `CM-0014` — a Platform `git add .` that committed a Security passphrase; the RADIUS-on-MKT01 mis-file).

**The boundary is around the function, not the box.** Pi01 hosts both Services and Security functions on one host; touching the CA on it crosses into Security even though you never left the machine. See [`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) for the ownership table and the worked *"add a VLAN"* example — four silos, one VLAN, and exactly one Change Record: the step that crosses into firewall policy.

Record the crossing explicitly. The [Change Record template](../Templates/Change-Record-Template.md) carries a **`Silo(s) / boundary crossed: X → Y`** field. If the change stays inside one silo, say so — `within <silo>, accepted design` — so the *absence* of a crossing is on the record too, not just assumed.

## Lightweight Workflow

1. State the objective and target state.
2. Identify affected systems and dependencies.
3. Capture current-state evidence.
4. Create and verify backups.
5. Define rollback and stop conditions.
6. Apply one logical change at a time.
7. Validate the changed function **and** the unaffected critical paths.
8. **Read the resulting state back.** A command that returned no error is not a confirmed change ([why: *A Completed Command Is Not Evidence*](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md)).
9. Export the final configuration.
10. Update the **Build Record**, Source of Truth, lessons, and revision history.
11. **Reconcile the Build Guides.** See below. This is a separate step from 10, on purpose.
12. Publish to Atlas and close the change.

> **Step 11 exists because step 10 was silently doing all the work.** Build Records were updated after every incident, because that is where incidents get written down. Build Guides were not — and a Build Guide is only read when someone is rebuilding, which is exactly when a stale one does the most damage.

## Step 11 — Guide Reconciliation

This step is the standing requirement [`POL-0003 R5`](../Policies/POL-0003-Change-Control.md) — guide reconciliation is *required, not conditional*. Before a Change Record can close, answer this **in writing**, for every guide touching the affected system:

> **Does any guide now contain an instruction that would recreate this problem, or a claim that this change disproves?**

Then record one of these outcomes. **A tick is not an answer. State the outcome.**

| Outcome | Meaning |
|---|---|
| **Updated** | Guide changed. Name the file and what changed. |
| **Reviewed — no change needed** | Guide read, and it does not teach the problem. **Say why.** |
| **Not applicable** | No guide covers this system or procedure. Rare. Be sure. |

### Why the old checkbox failed

The previous template asked: *"Build Guide, **if target procedure changed**."*

That conditional is the defect. **The target does not have to move for a guide to become dangerous.** In every case below, the honest answer to "did the target procedure change?" was **no** — and in every case the guide was actively harmful:

| Change | Did the target change? | What the guide still said |
|---|---|---|
| `testing`/`password` account deleted from FreeRADIUS once it became a live device credential | **No** | *"Create a `testing` account with password `password`"* — and its checklist listed that account working as a ticked success criterion |
| Combined PEM rebuilt with `sudo sh -c` after `cat \| sudo tee` silently wrote a keyless cert into production | **No** | Three guides still taught the exact broken pipeline |
| Pi-hole DNS records moved to `pihole.toml` after `custom.list` proved inert on v6 | **No** | *"Edit `/etc/pihole/custom.list`"* |
| MKT01 RADIUS built from scratch after being found never to have existed | **No** | The MikroTik build guide had no RADIUS section at all |
| Lab CA certificate installed on MKT01 `www-ssl` | **No** | The MikroTik build guide had no certificate section at all |

CM-0001 ticked *"Build Guide — not applicable, target design already specified this description."* **That was true, and the guide was still wrong.** The question was the wrong question.

## Evidence Precedence

When sources disagree during a change, resolve by **[Charter](Atlas-Charter.md) Locked Rule 13**, not by recency or confidence:

**live output → config export → incident records → Build Records → Build Guides → handoffs**

A session summary does not outrank the device. Neither does this page.

## Initial Required Changes

Carried forward:

- ✅ **Closed — MKT01 identity is live** (`006` confirms `MKT01`; deviation closed 2026-07-13).
- ✅ **Closed — the Cisco switch is live as `SW01`**, device-verified 2026-07-16 (`show version`, `CM-0022`). The earlier *"rename from CoreSwitch still open"* was stale — the rename happened long ago, and `027` had been building the old name as the target, which is why nothing flagged it to close.
- Reconcile stale Pi-hole policies and address objects against the Windows DNS target design. *(Still open.)*
- Confirm PVE01 link speed and resolve the 100 Mbps negotiation. *(SW01 Build Record reports 1 Gbps confirmed post-reboot — verify and close. Still open; note SW01's `Gi1/0/4`→PVE01 read down/down on 2026-07-16, `057`.)*

Use a separate short Change Record for each. **Do not combine unrelated changes.**

## Related

- **Governs this process:** [`POL-0003 — Change Control`](../Policies/POL-0003-Change-Control.md) (the standing requirement) · [`POL-0006 — Evidence & Verification`](../Policies/POL-0006-Evidence-and-Verification.md) (the read-back that closes a record).
- **Fill in with:** [`Change-Record-Template.md`](../Templates/Change-Record-Template.md) · [`Major-Change-Record-Template.md`](../Templates/Major-Change-Record-Template.md).
- **Decision behind it:** [`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) (the silo operating model) · the [Charter](Atlas-Charter.md) Locked Rules 7/12/13/15/16.
- **The why (Academy):** [`A Completed Command Is Not Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) · framed by the [`Atlas-Governance-Framework`](Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial lightweight workflow. |
| 2.0 | Split guide reconciliation out of "update documentation" into its own required step (11). Removed the *"if target procedure changed"* conditional, which was the escape hatch that let five real defects survive. Added evidence precedence and the read-back rule. |
| 2.1 | Added *"When a Change Record is required — the silo boundary"* ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)): a boundary crossing is the trigger for a Change Record, and the Change Record templates ([standard](../Templates/Change-Record-Template.md) · [major](../Templates/Major-Change-Record-Template.md)) now carry a `Silo(s) / boundary crossed` field. Wires `ADR-0018`'s core rule into the process that enforces it. |
| 2.2 | 2026-08-04 (#43 Pass A). **Wired the process into its governance layer** — added the *Templates & governing rule* callout (the template · the policy · the concept) and a *Related* section; turned the bare `ADR-0018`, Charter, template, and `POL-0003`/`POL-0006` references into real links, and linked the read-back rule to the [`A-Completed-Command-Is-Not-Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) concept. No normative change — the process is unchanged; it now points at its templates, policy, and why-layer. |
