# Pack Manifest — Enterprise Network

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Pack-Manifest.md

## Status

✅ **BOOK 1 IS FROZEN — 2026-07-14.**

**Every blocker is closed and verified, or explicitly deferred by an accepted ADR.** Nothing is ticked that is not true.

| Record | State |
|---|---|
| `CM-0010` | ✅ **Closed** — CA passphrase rotation; two exposed `.bak` key copies destroyed; guides reconciled |
| `CM-0014` | ✅ **Closed** — 🔴 **the rotation had NEVER happened.** Now rotated, **proven by opening the new archive**, both copies hash-matched, old copies destroyed. **Git history purged and verified from a fresh clone of GitHub.** **Scanner proven against the real incident — and the default ruleset FAILED it.** |
| `CM-0016` | ✅ **Closed** — MKT01's recovery network no longer labelled *"Legacy"* |
| `CM-0017` / `CM-0018` | ✅ **Closed** — 🔴 **MKT01's documented recovery path had NEVER worked.** Now built and tested (`ether4`). Remainder deferred by `ADR-0016`. |
| `CM-0012` | 🟡 **DEFERRED by `ADR-0017`** — CMOS battery. Hardware. **Still dead. Said out loud, not ticked.** |
| `CM-0019` | 🟡 Open — stray Vaultwarden env file. **Not Book 1 scope; does not block.** |
| `CM-0020` | 🟡 Open — **the pre-commit hook is not portable.** Does not block. |

*(CM-0011 — closed, disproven on the device. CM-0015 — closed, `ether2` disabled and verified, guides reconciled.)*

> **Corrected 2026-07-13.** This page previously read *"All Change Management work complete. Every CM/MC record in this pack is Closed."* **That was false.** It was written when CM-0010 was the highest-numbered record, and was never revisited when CM-0011 through CM-0014 were raised. The Session Handoff repeats the same false claim, having been built from this page.
>
> **The statuses below were read from the record files themselves, not carried forward from this page's own history.** That distinction is the entire reason this correction was needed.

## Change Record Status — verified against the record files, 2026-07-13

| Record | Status | Blocks freeze? |
|---|---|---|
| CM-0001 | Closed | No |
| CM-0002 | Closed | No |
| CM-0003 | Closed | No |
| CM-0004 | Closed | No |
| CM-0005 | **Superseded by MC-0001** | No |
| CM-0006 | Closed | No |
| CM-0007 | **Superseded by MC-0002 / CM-0008** | No |
| CM-0008 | Closed | No |
| CM-0009 | Closed — implemented and verified 2026-07-13 | No |
| CM-0010 | **Implemented — verification complete, reconciliation open** | 🔴 **Yes** |
| CM-0011 | **Closed — substantially FALSE** (iDRAC findings disproven on the device) | No |
| CM-0012 | **Open — pending hardware** (CMOS battery). Risk corrected High → Low. | 🔴 **Yes — hardware** |
| CM-0013 | Closed — implemented and verified 2026-07-13 | No |
| CM-0014 | 🔴 **Open — remediation not started** (archive passphrase committed to the repository) | 🔴 **Yes** |
| CM-0015 | ✅ **Closed — device-verified** (MKT01 `ether2` disabled, `X` flag confirmed; `022`/`026` reconciled) | No |
| MC-0001 | Closed | No |
| MC-0002 | Closed | No |

**Four records are open. Ten are closed, two superseded.**

## Freeze Blockers

Per the Charter's pack lifecycle, a pack is frozen when its work is complete — **not when its documentation says it is.** Each item below must be closed, or explicitly deferred by an accepted ADR, before Book 1 freezes:

| # | Blocker | Path to resolution |
|---|---|---|
| 1 | **CM-0014** — archive passphrase in the repo, in Git history, and **on GitHub** | Rotate, re-encrypt, purge history, install a pre-commit secret scan. **Highest severity: it gates the CA keys, the RADIUS secrets, and the vault.** 🔴 **Remote confirmed PRIVATE — but Atlas is a portfolio project. The repo must not be made public until this is Closed.** |
| 2 | **CM-0012** — PVE01 CMOS battery physically dead | Replace the CR2032, power-cycle, prove the board holds config. Then `050-iDRAC-Onboarding` becomes runnable. **Hardware-blocked; needs a decision, not silence.** |
| 3 | **CM-0010** — reconciliation open | Destroy the superseded `pi01-full-backup-2026-07-12.tar.gz`, complete guide reconciliation, tick the closeout. |

## Current Milestone

**Not publication. Remediation.** The Confluence pipeline (publish → review → reconcile → freeze) cannot begin its final step while the pack contains unexecuted changes.

**Confluence status (checked live 2026-07-13):** the `Atlas` space holds **110 pages**, not 85. The Pi01, Lab CA, PKI, FreeRADIUS, and Vaultwarden trees **do exist** — contrary to the Session Handoff, which was written before they were built. What remains is reconciliation, and three known desyncs are already confirmed:

| Confluence page | Says | Repo says |
|---|---|---|
| `Architecture Decision Records (ADRs)` | ADR-0004 — **Proposed** | ADR-0004 v2.0 — **Accepted** |
| `Change Records` | CM-0004/0005/0006/0007 **Draft**, CM-0009 **not executed** | All five resolved |
| `Change Records` | *(absent)* | **CM-0011, CM-0012, CM-0013, CM-0014 not listed at all** |

## Pages

- [x] Architecture (6 pages)
- [x] Standards (8 pages)
- [x] Build Guides (9 pages: FGT01, MKT01, SW01, PVE01 Network, plus 5 Pi01 service guides)
- [x] Build Records (5 pages: FGT01, MKT01, SW01, PVE01 Network, Pi01)
- [x] Operations (13 pages: Validation Guide, Lessons Learned, Future Expansion, Documentation Standards, Change Management process, Revision History, Lab CA Certificate Issuance and Trust Runbook, plus 6 Troubleshooting Guides: PVE01, FGT01, Pi01, SW01, MKT01, Remote Access/Workflow)
- [x] Validation — all four devices (FGT01, MKT01, SW01, PVE01) have a confirmed live validation pass
- [x] Troubleshooting — 5 guides written 2026-07-13, built entirely from real incidents encountered this session and one recovered from an archived prior session, not hypothetical scenarios
- [x] Revision History (020)
- [x] Change Management — process documented (019), landing page and index exist. **14 CM records + 2 Major Change records. Ten Closed, two Superseded, four Open.** See the status table above. *(This line previously read "8 CM records, all Closed… Nothing outstanding." It was written when eight was the true count and never updated.)*

## Outstanding Verification

*(This section previously read "none." It was wrong.)*

| Item | Status |
|---|---|
| ~~Whether the Atlas repository has ever been pushed to a Git remote~~ | ✅ **ANSWERED 2026-07-13.** `github.com/srfeuc/Atlas-Engineering-Repository` — **pushed, and PRIVATE.** Contained, not public. 🔴 **But Atlas is a portfolio project: publication is the most likely future action, and it would disclose `ac2182f` instantly.** See `ADR-0010`. |
| CM-0011 — iDRAC/BMC hardening | Not executed |
| CM-0012 — PVE01 CMOS battery | Hardware replacement outstanding |
| MikroTik's 5 Confluence pages | Spot-checked only; never formally reconciled |
| FortiGate Confluence tree (~35 child pages) | **Visible duplication** — e.g. both "FortiGate Troubleshooting" and "FortiGate Troubleshooting Guide"; four overlapping build/config guides. Never reconciled. |
| "Network Standards" vs "Networking Standards" (Confluence) | Near-duplicate titles, both live |

## Deferred Improvements

- Reconciling this pack's numbering/naming conventions against the ones adopted for Enterprise Virtualization (see the Atlas Structure Improvement Proposals)
- FGT01 firewall policy narrowing — deliberately deferred per ADR-0005, revisit once network redundancy exists

## Next Action

> *This section previously read "All device-level work is done. What's left is entirely the publication pipeline." **It is not.** Four change records are open, one of them a live credential exposure.*

> 🔴 **THIS SECTION WAS DANGEROUS AND SURVIVED AN ENTIRE SESSION.** Step 2 read: ***"CM-0011 — execute the iDRAC/BMC hardening."***
>
> **`CM-0011` is CLOSED — DISPROVEN ON THE DEVICE. Executing it is what DEGRADED a correctly-hardened BMC.** This page's own status table said so, four screens above. **The Next Action told the next session to run the exact command that broke the hardware.**
>
> **`016` lesson 10: a stale index does not merely fail to help — it actively tells you the work is done.** **This one told you to break something.**

## ✅ Book 1 is FROZEN. Next work is Book 10.

1. ✅ ~~CM-0010, CM-0014, CM-0016, CM-0017, CM-0018~~ — **all closed and verified**
2. 🟡 **CM-0012** — deferred by `ADR-0017`. **Buy a CR2032.** Then `050` unblocks and the iDRAC finally becomes out-of-band.
3. **Confluence:** `017`, `018` v3.0, `Build Order`, `Network Standards`, and 🔴 **the Charter — every published page cites it and it has NO Confluence home.**
4. **Then Book 10 — Network Services** (`ADR-0015`). **Discovery scoping on MKT01 is its first job** (`ADR-0016`).

## Certificate Verification

**CLOSED 2026-07-13 (evening).** Pi-hole's and FortiGate's live-served certificates were verified directly (`openssl s_client`, checking `issuer` as well as SAN). Both are correct and both are issued by the Lab CA. FortiGate's predates the `copy_extensions` fix and was never affected — it was built via `-extfile`, which supplies extensions at signing time and bypasses `copy_extensions` entirely, confirming what `029` claimed. **The CA-wide `copy_extensions` gap is fully closed across every device.**
