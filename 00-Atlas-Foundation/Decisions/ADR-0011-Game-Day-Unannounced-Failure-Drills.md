# ADR-0011 — Game Days: Unannounced Failure Drills That Test the Documentation

| Item | Value |
|---|---|
| Status | **Proposed — captured 2026-07-13, deliberately NOT scheduled** |
| Governing Policy | POL-0005 (+POL-0013, +POL-0016) |
| Rule promoted to | [POL-0005 — Backup & Recovery](../Policies/POL-0005-Backup-and-Recovery.md) · this ADR is the adopting decision; the standing rule now lives in that policy (`ADR-0054` (C)→policy) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-13 |
| Related | `048-Teardown-and-Rebuild-Runbook.md`, `049-Root-CA-and-Credential-Backup-Runbook.md`, `Atlas-Roadmap-Advanced-Scenarios.md` (Incident response simulation), `ADR-0010` (repo publication preconditions) |
| Evidence Status | **`Target Design`** — nothing here has been run |

> **Captured per the Charter: record ideas, defer them, do not redesign Atlas mid-pack.** This ADR exists so the idea survives the session. **It is not a plan and nothing should be built from it until Book 1 is frozen.**

## Context

Atlas is built on one claim: **the documentation is good enough to rebuild the lab from.** Every Build Guide, every Build Record, every Change Record is written as if a stranger will one day use it to reconstruct a system they have never seen.

**That claim has never been tested.**

`048-Teardown-and-Rebuild-Runbook.md` exists and describes the rebuild. `049` proved the *backup* restores — Phase 4, run 2026-07-13, archive decrypted and vault opened. **Both were run by the person who wrote them, on a system that was working, with the documents open in front of him.**

**That is a rehearsal, not a test.** It cannot fail in the way that matters.

## Proposal — the drill

A drill has three moves, and the third is the point.

| # | Move | What it tests |
|---|---|---|
| 1 | **A failure is declared, unannounced.** *"SW01 is dead."* The operator destroys the device's configuration for real — not a snapshot rollback, an actual wipe. | Nothing yet. This is the setup. |
| 2 | **Restore from backup.** | Whether the backup exists, is current, is reachable, and actually restores. `049` tests this for the CA. **Nothing tests it for SW01, FGT01, MKT01, or PVE01.** |
| 3 | 🔴 **If the backup fails — rebuild from the documentation alone.** No chat log. No memory. No "I remember I set that." **Only what is written down.** | 🔴 **Whether Atlas is what it claims to be.** |

**Move 3 is the entire value.** Moves 1 and 2 are a backup test, which is worth doing and is not novel. **Move 3 is a documentation test, and it is the only one that can falsify the project's central claim.**

### Why the failure must be declared by someone other than the operator

**A drill you design is a drill you unconsciously scope to what you know you can do.**

If the operator picks the target, he picks a device he is confident about, on a day he has time, and the drill passes. **The value is in being told `SW01 has failed` on a target and at a moment he did not choose** — because that is the only condition under which the *gaps* get selected instead of the *strengths*.

> An assistant, a random draw, or a sealed envelope can supply the target. **The mechanism does not matter. The unpredictability does.**

## What this would have caught

**Every one of these was found by accident. A drill would have found them on purpose.**

| Finding | How it was actually found | A drill would have found it because… |
|---|---|---|
| **FreeRADIUS was unauthenticatable** for a full day — `testing`/`password` deleted, nothing replacing it (`CM-0013`) | Only because `CM-0009` happened to need to prove itself | Restoring MKT01 requires proving RADIUS auth works. **It could not have been proven.** |
| **MKT01's RADIUS integration was never actually completed** — `use-radius` off, no client entry (`043`) | Stumbled into during unrelated work | A rebuild from `026` would have produced a router that could not authenticate, and the drill would have said so. |
| **Pi01's UFW was completely inactive** — zero rules, entire project life (`029`) | Noticed during a hardening pass | A rebuild-from-documentation of Pi01 would have asked "what are the firewall rules?" and found the guide had none. |
| **The Lab CA's `copy_extensions` defect** — every certificate issued without a SAN (`MC-0002`) | Found while fixing an unrelated MikroTik cert | Reissuing a cert from `031` during a drill produces a broken cert **immediately and visibly.** |
| 🔴 **`CM-0014` — the archive passphrase in the repo** | Found by reading the repo, weeks late | **Move 3 forbids the chat log and the workstation.** The drill would have forced the question *"where does the passphrase actually live?"* on day one. |

**Five real defects. Every one of them a gap between what a document said and what a rebuild would produce.** That is precisely the class of defect a drill is designed to surface, and precisely the class that reading the document cannot.

## The uncomfortable part, stated plainly

> **The drill is only worth running if it is allowed to fail.**

If the rule is *"rebuild from the docs, and if you get stuck, check the old config"* — **the drill teaches nothing.** The moment the escape hatch opens, the documentation stops being tested and starts being supplemented.

**A drill that cannot fail is a ceremony.**

So the honest version has a cost: **a device may be genuinely unrecoverable for a while, and the recovery may be a real, unpleasant afternoon.** That is not a bug in the drill. **That is the drill.** The alternative is discovering the same gap on a day it was not scheduled.

## Preconditions — 🔴 do not run this yet

| # | Precondition | Why |
|---|---|---|
| 1 | **Book 1 frozen.** | Four change records are open (`CM-0010`, `0011`, `0012`, `0014`). **Do not test documentation you already know is wrong.** The drill's findings would be indistinguishable from the defects you have already logged. |
| 2 | **`CM-0014` closed.** | Move 3 forbids the chat log and the workstation. **If the archive passphrase still lives only in Git history, the CA is not recoverable under drill conditions** — the drill would fail for a reason you already know, teaching nothing. |
| 3 | **A verified, restorable backup exists for the target device.** | Move 2 must be able to succeed, or Move 3 is not a fallback — it is the only path, every time. |
| 4 | **Start with SW01.** | Lowest blast radius. It holds no keys, no DNS, no vault. **Do not start with Pi01** — it holds the CA, Vaultwarden, Pi-hole, and FreeRADIUS, and it has an unexplained hard hang whose root cause was never found. |

## Decision

**Deferred.** Captured now so it is not lost; **not scheduled, not designed, not started.**

Revisit when Book 1 is frozen. At that point this ADR should be either **Accepted** (and promoted into `Atlas-Roadmap-Advanced-Scenarios.md`, which already carries an adjacent *Incident response simulation* entry) or **Rejected** with a reason.

> **Note on where it belongs:** `Atlas-Roadmap-Advanced-Scenarios.md` line 141 already proposes an *incident response simulation* — contain a compromised workstation, investigate, remediate, write a post-incident report. **That is a different thing.** It tests whether **the operator** can respond. **This tests whether the documentation can.** They should not be merged.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-13. Captured mid-session and deliberately deferred per the Charter's "record ideas, do not redesign mid-pack" rule. Not scheduled. |
