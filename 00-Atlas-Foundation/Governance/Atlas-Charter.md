---
Title: Atlas Charter
Path: 00-Atlas-Foundation/Governance
Status: 🟢 Living — the operating constitution; the standing rules every other doc answers to.
Version: 1.0
Date: 2026-08-02
---

# Atlas Charter

## Mission

Atlas must be sufficient for an engineer to rebuild, operate, troubleshoot, and recover the environment without relying on chat history or memory.

## Design Requirements

**DR-001 — Documentation should reduce work, not create work.** If documentation becomes something to avoid because it's painful to write or use, Atlas has failed at its actual purpose.

**Completion bar for any page:** *Could Future Seth solve the problem quickly using Atlas?* Not "has this been documented," but "would this actually work under pressure." A page that's technically complete but slow to use under real conditions isn't done. Success is measured by this, not by page count.

## Locked rules

1. **One pack at a time.** Finish, publish, review, reconcile, and freeze the active pack before beginning another.
2. **One page at a time.** Save completed work immediately in its permanent repository path.
3. **Three-click rule.** Common operational information must be reachable within three clicks in Confluence.
4. **One authoritative home.** A fact has one canonical page. Other pages may summarize and link to it.
5. **Build Guides describe the target state.** They explain how to build from factory defaults to the approved architecture.
6. **Build Records describe verified reality.** They record what is running now, including deviations.
7. **Change records move reality toward the target.** Keep changes small, testable, reversible, and documented.
8. **Verify; do not guess.** Prefer live command output, configuration exports, and successful testing over recollection.
9. **Optimize for the engineer.** Pages must be actionable and easy to navigate, not merely well organized for the author.
10. **No rabbit holes during execution.** Record improvement ideas, but do not redesign the repository or documentation model until the active pack is frozen.
11. **Confluence review is required.** Drafts are judged in the published hierarchy before consolidation or deletion decisions.
12. **Atlas is part of production.** A change is incomplete until documentation matches the verified environment.

---

### 13. Evidence has a precedence order.

When two Atlas sources disagree, the higher one wins. Do not resolve a conflict by picking the more recent, the more confident, or the more detailed page.

| Rank | Source |
|---|---|
| 1 | Live device output, captured now |
| 2 | Configuration export from the device |
| 3 | Troubleshooting / incident records written at the time · 🆕 **Change Records — the *executed and read-back* sections** |
| 4 | Build Records |
| 5 | Build Guides |
| 6 | Handoffs, summaries, and session narratives · 🆕 **Change Records — the `Status` field and the closeout ticks** |

### 🔴 A Change Record's OBSERVATION is Rank 3. Its SELF-ASSESSMENT is Rank 6.

**Added 2026-07-14. The original table had NO ROW FOR CHANGE RECORDS AT ALL — which is exactly why nobody could tell whether `022` or `CM-0009` won.**

**The two halves of a change record are not the same kind of evidence, and they must not be ranked the same:**

| | Rank | Why |
|---|---|---|
| **The OBSERVATION** — *"`/ip firewall filter print count-only` returns `22`"* | **3** | **It is a device read-back, written by someone who was looking at the device.** **It outranks the Build Record and settles the conflict.** |
| 🔴 **The `Status` FIELD and the CLOSEOUT TICKS** — *"✅ Closed — implemented and verified"* | 🔴 **6** | 🔴 **It is a CLAIM ABOUT WORK. It has been wrong TWELVE times.** |

**This is not theoretical. It resolves real conflicts, in both directions:**

| Conflict | Resolution |
|---|---|
| `021` said the FGT01 factory interfaces were *"left at factory defaults rather than disabled."* `CM-0004` said all four were `set status down` — **and pasted the command output.** | 🟢 **`CM-0004` wins.** Rank 3. **The device later confirmed it.** |
| `023` said `Gi1/0/1` was still mislabelled *"Raspberry-Pi."* `CM-0001` said *"confirmed live: `Gi1/0/1` shows `Trunk-to-MKT01`."* | 🟢 **`CM-0001` wins.** Rank 3. **The device later confirmed it.** |
| `022` said MKT01 had **24** firewall rules. `CM-0009` said the device returned **22**. | 🟢 **`CM-0009` wins.** Rank 3. |
| 🔴 `CM-0009` said `Status: ✅ Closed — implemented and verified` — with **three closeout boxes unticked**, including *"Build Record updated."* | 🔴 **THE STATUS FIELD LOSES.** Rank 6. **`022` described a firewall that no longer existed for a full day.** |
| 🔴 `CM-0018` ticked *"Guide reconciliation complete — `026` §12 REWRITTEN."* | 🔴 **THE TICK LOSES.** **The rewrite happened AND IT WAS WRONG** — it set `mac-winbox=RECOVERY` and then `none` six lines later. |
| 🔴 `CM-0010` — Risk **HIGH**, Root CA key material — `Status: ✅ Closed`. | 🔴 **Its last closeout box is `[ ] Mark this record Closed`. UNTICKED.** |
| 🔴 `CM-0014` — the highest-severity record in Book 1 — `Status: ✅ CLOSED`. | 🔴 **It has NO Closeout section at all** — only a pre-execution plan, with 15 unticked boxes. **And its own Risk row says *"It does not return it to Closed."*** |

> 🔴 **A TICKED BOX IS NOT EVIDENCE THAT AN EDIT EXISTS.**
>
> 🔴 **GREP THE FILE.** *(`016` rule **R1** — verify by COUNTING the OLD string.)*

**Corollary:** 🔴 **A `Draft` record is a HYPOTHESIS, not a work order.** **`CM-0011` was read as a to-do list, executed against a stale baseline, and it DEGRADED A BMC.** **Read the device BEFORE you execute a record. And read the record next to it that says `Blocks:`.**

**Corollary:** a session summary written at 3am is rank 6. It does not outrank the device. Neither does this Charter.

**Corollary, added 2026-07-14:** 🔴 **The device also beats the ANALYSIS — including a confident one. Including yours.**

**Four times in this project, a confident conclusion was drawn from a LISTING and the device disproved it:** an *"open MAC-WinBox security hole"* inferred from a Neighbors list *(false — and it produced an ADR and two change records)* · an *"NTP server"* inferred from `ss -ulnp` *(false — a client)* · *"two undocumented services"* inferred from `/ip service print` *(false — both carried the `D` flag, **in the output being read**)* · an *"unrestricted WinBox service"* inferred from a dynamic row *(false — it was the operator's own session; **`print detail` shows `remote=`, plain `print` does not**)*.

> 🔴 **BEING LISTED IS NOT BEING REACHABLE. BEING PRESENT IS NOT BEING ENABLED. A SOCKET IS NOT A SERVICE. A CONFIG LINE IS NOT A WORKING SERVICE.**
>
> **Every single time, the device was already telling the truth.**

**Corollary:** "no error was returned" is not evidence. A command completing without an error is not a confirmed change. This was the actual root cause of at least five separate failures in a single session — a silently unbound certificate, a certificate signed with no SAN, a config line written to the wrong section, a DNS record saved to a file nothing reads, and a setting that did not persist. Every one was caught only by reading the resulting state back.

### 14. Every technical page declares its own reliability.

A reader must be able to tell, without leaving the page, what kind of claim they are looking at. Every Build Guide, Build Record, Runbook, and Troubleshooting Guide carries an **Evidence Status** block:

```
Evidence Status: Verified | Historical | Reconstructed | Target Design | Unverified
Evidence Source:  live CLI output | config export | session transcript | inference
Last Verified:    YYYY-MM-DD
```

| Status | Means |
|---|---|
| **Verified** | Confirmed against a live system or an authoritative export. |
| **Historical** | Supported by contemporaneous notes, logs, or a transcript. Was true; not re-checked. |
| **Reconstructed** | Inferred from the resulting configuration and sound practice. Nobody watched this happen. |
| **Target Design** | Approved desired state. **Not necessarily deployed.** |
| **Unverified** | A claim exists. Evidence has not been collected. |

**"Verified" is a claim about a date, not a property of the page.** A page verified in June and untouched since is not Verified today; it is Historical. Re-verification is what makes it Verified again.

The most dangerous page in Atlas is one marked Verified that no longer is. Pi-hole was documented as using a Lab CA certificate — Verified — from its original build until someone finally read the `issuer` field and found the factory self-signed cert. Nothing had gone wrong. The page had simply never been true.

### 15. A change is not closed until the Guides it invalidates are reconciled.

Build Records learn from incidents, because that is where the incident gets written down. **Build Guides do not** — and a Build Guide is only read when someone is rebuilding, which is precisely the moment a stale one does maximum damage.

Closing a Change Record therefore requires answering, **in writing, for every guide touching the affected system:**

> *Does any guide now contain an instruction that would recreate this problem, or a claim that this change disproves?*

**This question is not conditional on the target having changed.** The target does not have to move for a guide to become dangerous:

- The FreeRADIUS Build Guide told you to create a `testing`/`password` account. The target never changed. The account became a live network-device admin credential the moment RADIUS started working, was deliberately deleted — and the guide still told you to create it.
- Three guides taught `cat file1 file2 | sudo tee out`. The target never changed. That pipeline silently wrote a keyless certificate into production, because `sudo` applied only to `tee`.
- The Pi-hole guide told you to add DNS records to `custom.list`. The target never changed. That file does nothing on v6.

In each case the honest answer to *"did the target procedure change?"* was **no** — and in each case the guide was actively harmful. **Ask the question above instead. It has no correct "no" that lets you skip the check.**

### 🔴 15a. The question applies to EVERY document type — and to ARTEFACTS.

**Added 2026-07-14 (`ADR-0019`, `051`). Rule 15 said *"Build Guides."* That was not enough.**

| Type | The question |
|---|---|
| **Build Guide** | Would a rebuild from this guide recreate the problem? |
| **Build Record** | Does this still describe the device's verified current state? |
| **Troubleshooting Guide** | Does this still describe a symptom, cause, or fix that is real? |
| 🔴 **Runbook** | 🔴 **Does this still describe a path that WORKS?** *(`048` — the teardown runbook — was rebuilding the unencrypted archive `CM-0010` had destroyed.)* |
| **Source of Truth** | Did any MAC, IP, port or interface change? |
| 🔴 **ARTEFACT** | 🔴 **Does the FILE a rebuild reads match the thing the device is SERVING?** |

> 🔴 **AND THE RECONCILIATION MUST BE MADE FROM VERIFIED FACT — NOT FROM MEMORY OF WHAT WAS DONE.**
>
> **Read the state back off the device and write down what it says. NOT what the change record said you would do. NOT what you remember doing.**

### 🔴 15b. **ASK: WHICH DOCUMENT DOES THE WORK? FIX THAT ONE FIRST.**

🔴 **The audit found the same failure FOUR times: the correction reached every document that DESCRIBES a thing, and missed the one that DOES it.**

| Corrected | 🔴 Missed | The missed document… |
|---|---|---|
| `006`, `012`, `023`, `016` — *the ARP ACL* | 🔴 **`027`** | …**BUILDS** the ACL. **It built four entries. Pi01 was missing.** |
| `031`, `029`, `049`, `043` — *the CA backup* | 🔴 **`048`** | …**TAKES** the backup. |
| `031` — *SAN, bundle, revocation* | 🔴 **`035`, `042`** | …**ISSUE** and **REISSUE** certificates. **`035` set no SAN at all.** |
| `013`, `017` — *"Pi-hole is optional"* | 🔴 **`001`, `Build-Order`** | …are the **landing pages**. |

> 🔴 **`031` IS READ ONCE, WHEN THE CA IS BUILT. `035` IS READ EVERY TIME A DEVICE NEEDS A CERTIFICATE.**
>
> 🔴 **`031` WAS CORRECTED FIVE TIMES. `035` WAS NEVER OPENED.**
>
> **A Build Guide is read ONCE — in the worst hour of the project, when the device is gone.** **It is the last document to get fixed and the first one that matters.**

**See `016` rule R2.**

---

### 16. 🔴 Verify a correction by COUNTING the OLD text. Not by confirming the new one is present.

**Added 2026-07-14. `ADR-0019` audited all 76 Book 1 documents and found EIGHT rebuild-fatal defects.**

> 🔴 **EVERY ONE OF THEM IS A CONSEQUENCE OF ONE MECHANICAL HABIT:**
>
> # 🔴 THE CORRECTION IS APPENDED. THE ERROR IS NOT DELETED.

**TWELVE documents contained BOTH. Six of them are change records. Two are the two highest-severity records in Book 1.**

```powershell
# 🔴 WRONG — this is what was done, twelve times:
Select-String -Path .\026-MKT01-Build-Guide.md -Pattern "mac-winbox.*RECOVERY"
#   It hits. The fix landed. The document looks correct.

# ✅ RIGHT — the OLD string must be GONE:
(Select-String -Path .\026-MKT01-Build-Guide.md -Pattern "mac-winbox.*=none").Count
#   MUST return 0.
```

🔴 **`026` §12 carried a header saying *"✅ REWRITTEN 2026-07-14 to fix the missing recovery path"* — and it set `mac-winbox=RECOVERY` on one line and `none` SIX LINES LATER.** **RouterOS `set` is last-write-wins. The block written to BUILD the recovery path DESTROYED it.**

🔴 **`018` v3.0 declared two sentences FALSE — and reprinted both, verbatim, as its own recommendation, 21 lines later.** **`ADR-0010` gates publication of this repository on the control `018` names, and `018` names the one that PROVABLY FAILED.**

🔴 **`CM-0009` wrote a section titled *"Closeout defect — this record was marked `Closed` with two boxes unticked"* — and left THREE of its own boxes unticked, twenty lines above it.**

### Why it survives review

**Appending feels safe. Deleting requires certainty.** **And the placement tool's line-count delta goes UP, which reads as a plausible edit** — the OPPOSITE of the `496 → 12` shape `Tools/README.md` teaches you to catch.

### 🔴 The precondition

🔴 **A count-check only works if the dangerous string appears ONLY where it is dangerous.** **If your own commentary quotes it verbatim, the check returns `1` forever, and an ambiguous check is one that gets ignored.** **Paraphrase in commentary.**

### 🔴 The silent failure only a count-check catches

🔴 **`.gitattributes` says `*.md text eol=lf`. Several files have CRLF anyway.** **A multi-line pattern built with `\n` matches ZERO in a CRLF file — and edit tools fail SILENTLY on a miss.**

**The first edit pass on `027` applied ZERO of 16 edits. `497 → 497` lines. No error.** 🔴 **A commit message describing sixteen fixes would have shipped an unchanged file.**

> 🔴 **AFTER EVERY BATCH: `git status --short` AND COUNT THE FILES.** **If it is empty, nothing landed — regardless of what anything printed.**

**See `016` rule R1.**

---

### 17. 🔴 Where the configuration IS the lesson, the operator writes it. The assistant designs, validates, and names the failure modes.

**Added 2026-07-17 (`ADR-0018`). This rule operated on the honor system for three days before it was filed.** It was proposed in `ADR-0018` as *"Locked Rule 16,"* collided with the count-the-OLD-text rule that took slot 16 the **same day** (2026-07-14), and fell through the gap — never entered into this list. **That is the exact failure `ADR-0008` and `ADR-0012` exist to stop: a rule that lives only in an ADR is not a rule.** It is Rule 17 now.

Atlas exists to teach. Where a configuration is itself the learning objective — a router, a switch, a service the operator is studying — the assistant provides **the design, the validation method, and the failure modes**, and the **operator writes the configuration.** The assistant does not hand over finished config to paste, on the systems the operator is trying to learn.

**This does NOT apply to remediation under time pressure** — a passphrase rotation, a git-history purge, an incident restore. Those are operations, not lessons; the fastest correct hands should execute them. The rule binds where learning is the point: the Cisco 1941 core migration, SNMP, QoS, the Windows/identity build (Book 10 and beyond). **There, the assistant is the senior engineer who reviews and explains — not the one who types.**

> **Corollary — this rule and Locked Rule 8 ("verify; do not guess") are not in tension.** The operator writing the config does not weaken verification; it strengthens it. The hands that typed it are the hands that must read the state back.

---

## Evidence and secrets

A **Build Guide never contains a value you would actually type.** A **Build Record may name a value that no longer works.**

This is the whole rule, and it resolves what looks like a conflict:

- `snmp-server community homelab` — **live, and SNMP v2c sends it in cleartext.** Redact *and rotate*.
- `testing` / `password` — **deleted.** Keep it, named, in the Build Record and Troubleshooting Guide. It is the best lesson in the project. Remove it only from any guide that instructs you to *create* it.
- `testing123` — **FreeRADIUS's published stock default.** Not a secret. Redacting it makes the guide unusable, and the actual lesson is that *two* client blocks ship with it and both need rotating.

Documentation names where a secret is stored. It does not reveal one that still works.

## Documentation types

Architecture, Standard, Build Guide, Build Record, Operations Guide, Validation Guide, Troubleshooting Guide, Change Record, Engineering Decision, Lessons Learned, and Reference.

## Definition of done for a pack

- All required pages exist.
- **Every page carries an Evidence Status block, and no page claims Verified on stale evidence.**
- Build Guides match the target architecture.
- Build Records match verified production.
- **Every closed Change Record in the pack has a written answer to the Rule 15 question.**
- Validation and rollback are usable.
- The pack has been published and reviewed in Confluence.
- **Exactly one Confluence home exists per fact.** No competing page in another space or an older tree.
- Reconciliation corrections are complete.
- The pack is frozen.

## Amendment history

| Date | Change |
|---|---|
| 2026-07-13 | Added Locked Rules 13 (evidence precedence), 14 (evidence status), and 15 (guide reconciliation at change closeout). Added the Evidence and Secrets section. Extended the pack definition of done. All three rules were derived from real defects found while publishing Book 1 — not from theory. |
| **2026-07-14** | 🔴 **Amended after the full Book 1 audit (`ADR-0019`, `051`) — 76 of 76 documents, plus a live device pass on MKT01, SW01, Pi01 and FGT01.** <br><br>🔴 **Rule 13 gains TWO ROWS FOR CHANGE RECORDS — and they are at OPPOSITE ENDS of the table.** **The original precedence list had NO ROW FOR THEM AT ALL, which is why nobody could tell whether `022` or `CM-0009` won.** **A Change Record's OBSERVATION is Rank 3 — a device read-back, written by someone looking at the device. Its `Status` FIELD is Rank 6 — a claim about work, and it has been WRONG TWELVE TIMES.** *(`CM-0010`, Risk HIGH, is `Closed` with `[ ] Mark this record Closed` unticked. `CM-0014`, the highest-severity record in Book 1, has NO closeout section at all.)* <br><br>🔴 **Rule 15 EXTENDED — 15a: the question applies to EVERY document type, and to ARTEFACTS.** *(`048` — a RUNBOOK, not a guide — was rebuilding the unencrypted archive `CM-0010` destroyed. And four documents truthfully verified Pi-hole's certificate on the WIRE while the FILE a rebuild reads carried a pre-VLAN SAN.)* **15b: ASK WHICH DOCUMENT DOES THE WORK, AND FIX THAT ONE FIRST.** *(`031` was corrected five times. `035` — the runbook used EVERY time — was never opened, and set no SAN at all.)* <br><br>🔴 **NEW LOCKED RULE 16 — verify a correction by COUNTING the OLD text.** **All EIGHT rebuild-fatal defects the audit found are a consequence of ONE mechanical habit: THE CORRECTION IS APPENDED AND THE ERROR IS NOT DELETED.** **Twelve documents contained both.** |
| **2026-07-17** | 🔴 **NEW LOCKED RULE 17 (`ADR-0018`) — where the configuration is the lesson, the operator writes it; the assistant provides the design, the validation method, and the failure modes.** The rule had been operating since 2026-07-14 but was **never filed**: `ADR-0018` proposed it as *"Rule 16,"* a slot the count-the-OLD-text rule had already claimed the same day. It is filed now, as Rule 17. <br><br>Same amendment **accepts `ADR-0018`** (the silo operating model) and wires its *boundary-crossing = Change Record* rule out of the ADR and into the artefacts that enforce it: the **Change Management Process** now names a boundary crossing as a Change-Record trigger, and the **Change Record templates** carry a `Silo(s) / boundary crossed` field. |
