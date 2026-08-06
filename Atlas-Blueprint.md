# Atlas — Master Blueprint

> 🔴 **Historical planning snapshot (~2026-07-13) — NOT the front door.** The repo front door is the root [`README.md`](README.md); *where we are now* is the [Lab-02 handoff](Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md); the *current plan* is the [Roadmap](00-Atlas-Foundation/Roadmap/Atlas-Roadmap.md) + [Master-Build-Order](Labs/Lab-02-Cisco-Core/Architecture/Master-Build-Order.md). This page is kept for its **session-sequencing reasoning** and the record of that pass — several specifics below are now stale (marked inline where noticed).

This page maps a set of files and the order to do the work in **as of that pass**. Everything referenced here was a real file at the time — this is the map of how they fit together and the order the work was planned in.

## What Changed This Pass

New files, all referenced below, none of them speculative — each is grounded in either this session's live-validated work or real external research (Microsoft Learn documentation, Cisco's own exam blueprints, and actual research on what makes an infrastructure portfolio land with hiring managers):

| File | Home |
|---|---|
| `PORTFOLIO.md` | Repo root |
| `303-Windows-Design-Standards.md` | `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/` — 🔴 **moved from Foundation per `ADR-0008`. This table listed it at the old path.** |
| `304-Microsoft-Architecture-Reference.md` | `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/` — 🔴 **same: moved, never updated here.** |
| `VM-and-Services-Inventory.md` | `00-Atlas-Foundation/` |
| `ADR-0001` through `ADR-0004` | `00-Atlas-Foundation/Decisions/` |
| `NETWORK-PACK-MANIFEST.md` | `Labs/Lab-01-Mikrotik-Core/` |
| Populated `README.md` (replacing "Deferred" stubs) | `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/`, `04-Identity-and-PKI/`, `08-Labs/` |
| `README.md` (new book) | `Atlas-Academy/` |

## The Core Idea, Stated Plainly

A hiring manager doesn't care that a rack exists. They care whether you can diagnose a real problem, whether you document like an engineer instead of a hobbyist, and whether what you built actually maps to skills their job needs. Everything in this pass is built around that — not "more stuff," but the same stuff, organized so it proves something.

Three things had to happen for that to be true, and this pass does all three:

1. **The engineering process has to be real, not decorative.** ADRs, Change Management, evidence-status tagging — these aren't bureaucracy for its own sake, they're the difference between "I have a homelab" and "I run something the way a team would." `ADR-0001` through `ADR-0004` exist because real decisions were sitting unresolved across five different documents; now they have one home each.
2. **The plan has to be sized against real hardware, not aspiration.** `VM-and-Services-Inventory.md` isn't a wishlist — it's checked against PVE01's actual 16 cores / 64 GB / ~793 GB, confirmed live this session, with real Microsoft sizing guidance for WSUS/AD DS/Desktop Experience baked in.
3. **The learning has to connect to something real, and be provable to a stranger.** `08-Labs` and `Atlas-Academy` exist because "I studied CCNA/CCNP material and some MCSA/MCSE content" doesn't communicate what you can *do*. A lab that says "802.1X against the FreeRADIUS instance that's actually running on Pi01" does.

## Recommended Order — Several Sessions, Not One

Not everything here needs doing at once, and per the Charter's own "no rabbit holes" rule, doing it all in a single burst would be exactly the mistake this whole exercise is trying to avoid. Suggested sequence:

### Session A — Finish Network (Book 1)

🔴 **Corrected 2026-07-13. This paragraph was stale.** CM-0001, CM-0002, CM-0004 and CM-0005 are all **resolved** (Closed or Superseded), and both MikroTik items are **Closed** — `reverse-proxy` disabled (`CM-0006`, device-verified) and `www-ssl` certificate installed (`CM-0008`/`MC-0002`).

**The real blockers are four different records.** Per `Labs/Lab-01-Mikrotik-Core/Pack-Manifest.md`: **CM-0010** (reconciliation open), **CM-0011** (iDRAC/BMC hardening, Draft — never executed), **CM-0012** (CMOS battery, pending hardware), and 🔴 **CM-0014** (the backup archive passphrase, committed to the repository and pushed to GitHub). **CM-0014 is the one that matters.**

### Session A.5 — Confirmed Immediately After Freeze, Before Book 2 Resumes

Three things, in this order, per direct confirmation (2026-07-13):

1. **Device deployment checklists** (Book 6 seed already written in `06-Security/README.md`) — CIS Benchmarks as the primary per-product reference, NIST NCP/SCAP as the secondary/automation path, OWASP scoped specifically to future web-facing app work. This turns the FGT01-validation pattern (find undocumented drift by manually checking everything) into something checklist-driven instead of luck-of-a-thorough-pass-driven. **The three-tier structure (Global / Technology-Specific / Procedure) is now decided — see `06-Security/README.md` — the checklists themselves still need building.**
2. **Reconcile Atlas's own directory/naming conventions** — Book 1 uses one continuous number sequence across Architecture/Standards/Build Guides/Build Records/Services; Book 2 restarts numbering per-section. Pick one and apply it consistently, per the open item already flagged in the Network pack manifest's Deferred Improvements.
3. **Write an actual Phase 2 (Enterprise Virtualization) execution plan** — a `Labs/Lab-02-Cisco-Core/Virtualization/VIRTUALIZATION-PACK-MANIFEST.md` equivalent to Book 1's, since the Build Guides already exist but there's no single document stating what's actually left to do (Build Records/Reference still need the naming reconciliation from item 2, the DC01 VLAN question, the Sysprep-history recovery attempt, etc.).

**Already done, ahead of schedule, per `ADR-0006`:** a second-tier Major Change template (`MC-XXXX`) now exists alongside the standard `CM-XXXX` one; `DR-001` and the "Future Seth" completion bar are in the Charter; the Screenshot Standard and callout system are in Documentation Standards; `ADR-0005` has the real FGT01 firewall policy history. These were pulled forward because they're purely additive — see `ADR-0006` for the reasoning and the boundary on what did *not* get pulled forward with them.

### Session B — Adopt the Remaining Foundation Mechanisms

From the Atlas Structure Improvement Proposals: create `90-Source-Evidence` and `99-Archive`, move today's raw material (the recovered chat transcripts, the old MikroTik/Proxmox planning docs) into them. Cheap, mostly filing, prevents this session's research from evaporating the way earlier sessions' research did.

### Session C — Execute the Phase 2 Plan

Work the `Labs/Lab-02-Cisco-Core/Virtualization/VIRTUALIZATION-PACK-MANIFEST.md` written in Session A.5: re-verify the still-open items inside the 14 Build Guides (the DC01 VLAN 10-vs-20 question, the exact Sysprep invocation if it's ever recoverable), and bring Book 2's Build Records/Reference material up to whichever naming convention got chosen in A.5.

### Session D — Start Book 3 (Windows Infrastructure)

Only after Book 1 is actually frozen. `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/README.md` and the Windows Environment Roadmap are both ready to execute against. Real first milestone: DC01 actually promoted, DC02 stood up, KDS root key created.

### Session E — Book 4, Then Books 5-7 in Whatever Order Makes Sense

`04-Identity-and-PKI` depends on Book 3 existing. `ADR-0003`/`ADR-0004` should get formally accepted (or overridden) before implementation starts, not decided mid-build.

### Session F — Book 8 and 9, Continuously

Unlike the others, Labs and Academy aren't really "finish and move on" books — they grow every time something new gets built elsewhere. Treat `08-Labs/README.md` and `Atlas-Academy/README.md` as living documents that gain a new entry whenever a Build Guide finishes, not a one-time project.

### Ongoing — Portfolio Polish

`PORTFOLIO.md` should get a new "Real Diagnostic Work" entry every time something genuinely interesting gets solved — the CMOS battery/VT-x/DIMM chain and the VLAN tagging mismatch are strong examples already; there will be more. Keep it to 3-5 sharp examples, not a running list of everything — per the actual research on this, hiring managers reward depth over volume.

## One Honest Caveat

A lot of this pass is genuinely new structure, and the Charter's own rules (one pack at a time, no rabbit holes) argue against building it all in one sitting the way this response just did. That tension is real, and it's the same one `ADR-0001` already names. The resolution isn't "don't do this work" — it's "do it, then actually go finish Book 1 next, instead of finding a new rabbit hole to fall into."

## Related Pages

- Atlas Structure Improvement Proposals — the mechanism-level detail behind items 2 and B above
- `00-Atlas-Foundation/Roadmap/Atlas-Roadmap.md` — the original phase-by-phase plan this blueprint refines, not replaces
