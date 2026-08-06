# ADR-0019 — The Book 1 Audit Mandate: Coverage, Not Threads

| Item | Value |
|---|---|
| Status | **Accepted — 2026-07-14** |
| Governing Policy | POL-0001 |
| Rule promoted to | [POL-0001 — Audit](../Policies/POL-0001-Atlas-Audit-Policy.md) · this ADR is the adopting decision; the standing rule now lives in that policy (`ADR-0054` (C)→policy) |
| Scope | **Lab-01-Mikrotik-Core** |
| Related | `ADR-0012`, `019-Change-Management.md`, `016-Network-Lessons-Learned.md`, Charter Rule 15 |
| Evidence Status | **`Verified`** — the coverage numbers below were counted, not estimated |

## Why this exists

**Book 1 is frozen. It has NOT been audited.** Those are different claims, and only the first one has been earned.

**The freeze means: every change record is closed or ADR-deferred.** That is what the Charter's freeze criteria require. **It does not mean 72 documents have been checked against each other or against the devices.**

### 🔴 The 2026-07-14 session read 25 of 72 documents

**31 documents were never opened at all** (~3,900 lines). **13 CM/MC records were seen only as rows in an index table.** Several of the 25 were read only via `grep`.

**And the defect rate in what WAS read approached 100%:**

| Document | Defect |
|---|---|
| `003` | Wrong on two rows; two connections missing entirely |
| `013` | Called Pi-hole *"optional, not authoritative."* It is the resolver. |
| `015` | Listed commands; never said what to do with the output |
| `017` | 🔴 **Proposed deleting the recovery network** |
| `022` | Never recorded `mac-server`. Never recorded the 64 GB SSD. |
| `026` | 🔴 **Builds a router `048` cannot bootstrap. Contradicts itself internally.** |
| `048` | Called MAC-connect *"your single most important bootstrap tool."* **It had never worked.** |
| `049` | Recorded a restore test that did not test the thing that changed |
| `018` | 🔴 **Named the wrong control. Proven backwards by test.** |
| `NETWORK-PACK-MANIFEST` | 🔴 **Told the next session to run the command that degraded the BMC** |
| `Session-Handoff` v6.0 | Wrong in six places |

> 🔴 **The defects clustered WHERE WE LOOKED, not where they are.**
>
> **The session followed threads. It did not do coverage.** If that hit rate holds across the 31 unread documents — and there is no reason to think it does not — **Book 1 still contains a substantial number of undiscovered defects.**

## Decision

**Book 1 receives a full-coverage audit by a reader who did not write it.**

### The mandate — read it literally

> **Read all 72 documents in Book 1. For each one, produce a row:**
>
> | Doc | Contradicts another document? | Contradicts a device? | Any claim untested? |
>
> 🔴 **Do not follow interesting threads. Do not stop when you find something. FINISH THE TABLE FIRST, THEN RANK.**

**The instruction to finish the table first is the entire point.** A defect is *interesting*, and interest is what destroys coverage. **The 2026-07-14 session found the MikroTik problem and spent six hours on it — which was valuable, and which is why 31 documents were never opened.**

### Priority targets

| Target | Why |
|---|---|
| 🔴 **`006-Network-Source-of-Truth.md`** | **Declares itself authoritative for every MAC and port assignment. Has already been wrong** (`016` lesson 6 — four `STATIC-HOSTS` entries where five are required; **Pi01 simply missing**; three handoffs of a false *"Pi01 should be unreachable"* mystery). 🔴 **And as of 2026-07-14 it contains ZERO MAC addresses for MKT01 — the core router.** |
| 🔴 **`021` / `023` / `024`** — the FGT01, SW01, PVE01 **Build Records** | **This is the "verified reality" layer, and it has NEVER been audited.** The one Build Record that *was* opened (`022`) turned out to be missing an entire category of administrative state **and** a 64 GB SSD. |
| 🔴 **Every document rewritten on 2026-07-14** | `003`, `009`, `013`, `015`, `017`, `018`, `022`, `026`, `048`, `049`, the manifest, `CM-0014`–`CM-0020`, `ADR-0012`–`ADR-0018`. **The author cannot be trusted to check their own work.** |

## 🔴 Why the author cannot audit their own work

**The 2026-07-14 session was wrong, repeatedly, and only the DEVICE caught it:**

- **Invented a MAC-WinBox security hole** from an inference, then built an ADR and two change records on it. **The export disproved all of it.**
- **"Corrected" the repo's model number** — the repo was right.
- **Doubted a real, mounted 64 GB SSD** on a misread of a `128 MiB` NAND figure.
- **Told the operator to expect an error** from `git cat-file -e`, which is **silent on success** — a test that could not fail, on the irreversible step.
- **Chose an AWS documentation key as the scanner canary** — a value gitleaks *deliberately allowlists.* It passed, and proved nothing.

> **Re-reading your own reasoning and finding it persuasive is not an audit. It is how `026` §12 survived — three unexplained lines that made perfect sense to whoever wrote them.**

## 🔴 Companion rule — reconciliation covers ALL document types, and only from verified fact

**`019` step 11 requires Build Guide reconciliation. That is not enough.** Extend it:

> **A Change Record does not close until every affected document type is reconciled:**
>
> | Type | Question |
> |---|---|
> | **Build Guide** | Would a rebuild from this guide recreate the problem? |
> | **Build Record** | Does this still describe the device's verified current state? |
> | **Troubleshooting Guide** | Does this still describe a symptom, cause, or fix that is real? |
> | **Runbook** | Does this still describe a path that works? |
> | **Source of Truth** | Did any MAC, IP, port or interface change? |
>
> 🔴 **AND — the reconciliation must be made FROM VERIFIED FACT, NOT FROM MEMORY OF WHAT WAS DONE.**
>
> **Read the state back off the device and write down what it says.** **Not what the change record said you would do. Not what you remember doing.**

**This is `CM-0009`'s failure, generalised.** `CM-0009` was marked `Closed — implemented and verified` while `022` still described **24 firewall rules** on a device that had **22**. **The record described the intent. The device had the outcome. Nobody compared them.**

**And `048` is the sharpest case:** it is a **runbook**, not a guide, and it told you MAC-connect was *"your single most important bootstrap tool"* **for as long as it existed** — while `026` §12 disabled it. **A runbook that has never been executed is a runbook full of untested claims.** Runbooks were not in the old reconciliation list at all.

## Consequences

- **An audit that finds Book 1 wanting is not a failure. It is the pack lifecycle working.**
- **The audit report is a document, not a chat.** It goes in the repo.
- **Anything the audit finds becomes a Change Record**, and Book 1 may need to *unfreeze* to accept the fixes. **That is fine. A freeze that cannot be revisited is a monument, not a baseline.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-14. Mandates a full-coverage audit of all 72 Book 1 documents by a reader who did not write them. **Coverage, not threads. Finish the table before ranking.** Extends `019`'s reconciliation to Build Records, Troubleshooting Guides, Runbooks and the Source of Truth — **and requires that reconciliation be made from verified device state, not from memory of what was done.** |
