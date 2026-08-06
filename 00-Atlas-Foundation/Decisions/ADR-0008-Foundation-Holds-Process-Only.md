---
Title: ADR-0008 — Foundation Holds Process Only; Technology Content Belongs to Its Book
Path: Atlas Foundation/Decisions
---

# ADR-0008 — Foundation Holds Process Only; Technology Content Belongs to Its Book

| Item | Value |
|---|---|
| Status | ✅ **Accepted — and EXECUTED.** Both moves are complete: `303-Windows-Design-Standards.md` and `304-Microsoft-Architecture-Reference.md` exist in Book 3. **This ADR sat at `Proposed` for the entire period after its own decision had been carried out.** Corrected 2026-07-13. |
| Governing Policy | POL-0014 R1 |
| Rule promoted to | [POL-0014 — Documentation & Knowledge Mgmt](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) · this ADR is the adopting decision; the standing rule now lives in that policy (`ADR-0054` (C)→policy) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-13 |

> ## ⚠️ Correction — 2026-07-13 (evening)
>
> **An earlier claim in this session that this ADR "was never filed" was WRONG.** It was filed, and had been for hours.
>
> The claim came from reading a **stale snapshot** of the repository — a zip taken at the start of the session, before this ADR was placed. `ls`, `find`, and `git log` all ran correctly. **They ran correctly against the wrong copy.**
>
> **That is a Charter Rule 13 failure, committed while enforcing Charter Rule 13.** A document — even a git repo — is not the source. The source is the live thing.
>
> **The genuine unfiled-document count for 2026-07-13 is three, not four:** `044`'s original rewrite, `044` v2.0 (published to Confluence, never committed), and `049` v1.0 (placed into the wrong folder and left there). **This ADR was not among them.**

## Context

> ✅ **RESOLVED 2026-07-13.** The file described below **no longer sits in Foundation.** It moved to `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/303-Windows-Design-Standards.md`, and `Microsoft-Architecture-Reference.md` moved to `304-`. **The decision in this ADR was executed — and the ADR was never updated to say so, which is the same class of drift it exists to prevent.**

**The situation as found (historical):** `00-Atlas-Foundation/Windows-Environment-Roadmap.md` (211 lines) contained detailed **Windows design content** — forest/domain design, a role-based OU structure, AGDLP group strategy, tiered administration, a GPO baseline, and a build order.

It sat in Foundation, which otherwise contains only **process**: the Charter, the Workflow, ADRs, templates, and inventories.

**Consequence:** during the Book 3 planning session, a second document — `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/302-Windows-Environment-Build-Roadmap.md` — was written **without anyone finding the first one.** It was linked in that document's own Related Pages. It was seen and duplicated anyway.

That is a Locked Rule 4 violation (*one authoritative home*), authored during the session that was enforcing Locked Rule 4.

**The root cause is not carelessness. It is misfiling.** Nobody looked for Windows design in Book 3 because it was not in Book 3.

## Alternatives Considered

**Delete one of the two roadmaps.** Rejected — **they are not duplicates.** Foundation's is a *design* document (what the AD should look like). `302` is a *schedule* (what to build, when, in what order, with what capacity and cost). Both are needed. Deleting either loses real work.

**Leave Foundation's where it is and cross-link.** Rejected. It does not fix the reason the duplicate happened, and it leaves technology content in a process book — which invites the same failure for Books 4–9.

**Move Windows design content to Book 3. Foundation holds process only. — Chosen.**

## Decision

**Foundation contains process, not technology.**

| Belongs in Foundation | Belongs in its Book |
|---|---|
| Charter, Workflow, ADRs, Templates | Design standards for a technology |
| Roadmap (the dashboard), Session Handoff | Build guides, build records |
| VM & Services Inventory *(cross-cutting fact register)* | Anything naming a specific product or protocol |

**Move:**

```
00-Atlas-Foundation/Windows-Environment-Roadmap.md
    -> Labs/Lab-02-Cisco-Core/Windows-Infrastructure/303-Windows-Design-Standards.md
```

✅ **`Microsoft-Architecture-Reference.md` moved too**, for the same reason — it is now `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/304-Microsoft-Architecture-Reference.md`. **Both moves are complete.**

## Resulting Ownership — Book 3

| Doc | Owns |
|---|---|
| **`301-Atlas-Company-Profile.md`** | **Who works at Atlas.** The company, the departments, the deliberate mess. |
| **`302-Windows-Environment-Build-Roadmap.md`** | **When things get built.** 12-week schedule, capacity, licence clocks, Azure cost. |
| **`303-Windows-Design-Standards.md`** | **What the design should be.** Forest/domain, OU tree, AGDLP, tiering, GPO baseline. |

## Reconciliation Required On Move

`303` carries content that is now superseded or contradicted. **Fix on the move, not later.**

### 🔴 Domain name — contradicts a committed ADR

`303` Part 2 specifies **`atlas.corp`**.

**ADR-0007 decided `atlas.lab`.** ADR-0007 is committed and is the authoritative decision. **`303` must be corrected to `atlas.lab`.**

*(ADR-0007's reasoning still holds — and `303`'s own warning is correct: never use an internally-resolving name that also resolves publicly. `.lab` satisfies that.)*

> ⚠️ **Note added 2026-07-13 (evening):** `ADR-0007` is **committed but NOT implemented.** The live CA is branded `Home Lab`, and every certificate is `<device>.lab`, not `<device>.atlas.lab` — verified on the wire. The decision stands; only the schedule changed. See `ADR-0007`'s implementation-status note and `029-Pi01-Build-Record.md`.

### Part 1 (company) — superseded by `301`

`303` Part 1 proposes a department table and explicitly says *"decide what Atlas actually does."*

**`301` decided it:** Atlas Industrial, a regional manufacturer, 156 people. **Delete Part 1 from `303`; link to `301`.**

> ⚠️ **One genuine conflict to settle, not silently drop.** `303` Part 1 says **IT: 1 person** — arguing, correctly, that ~1–3 IT staff per 100 employees is realistic at this size, and that *solo IT is itself realistic, not a simplification.*
>
> **`301` says IT: 8** — because Tier 0/1/2 separation, delegated helpdesk, and AGDLP are **not teachable with one admin.**
>
> Both are right about different things. **This is a real decision and needs an ADR, not a silent overwrite.** Note that `303`'s point is also the MSP premise: *a 150-person company with one IT person is exactly the company that hires an MSP.*

### Part 7 (build order) — superseded by `302`

`303` Part 7 lists an 11-step build order. **`302` supersedes it** — it is more current (nested Hyper-V, Azure Arc, Azure Update Manager, AZ-802) and includes capacity, licence clocks, and cost.

**Delete Part 7 from `303`; link to `302`.**

### Part 8 (labs) — belongs to Book 8

`303` Part 8 contains a full lab catalogue that **duplicates `08-Labs/README.md`.**

**Move anything unique into `08-Labs`; delete from `303`.**

### AZ-801/AZ-802 references

`303` cites **AZ-801** in several places. **AZ-801 retires 2026-09-30**, consolidated into **AZ-802**. Update.

## Consequences

- Foundation drops from 24 documents to ~22 and becomes **purely process** — which is what Locked Rule 10 has been telling you it should be.
- **Books 4–9 inherit the rule.** No AD CS design in Foundation, no monitoring design in Foundation.
- `303` shrinks substantially once Parts 1, 7, and 8 are removed. **What remains — forest/domain, OU structure, groups, tiering, GPO baseline — is the actual, valuable core**, and it is content `302` does not have.

## Review Trigger

Applies immediately, and to every future book. If a document names a product or a protocol, it is not a Foundation document.

## Note

**This ADR exists because Locked Rule 4 was violated by the session enforcing Locked Rule 4.** The rule was known, written down, and being actively applied to five other documents at the time.

That is consistent with the pattern already recorded in `Atlas-Workflow.md`: **a rule that lives only in a document, with nothing enforcing it, is not a rule.** Filing discipline is the enforcement mechanism here — content in the wrong book will be duplicated by someone who could not find it.

> **And then this ADR was not filed.** Which is the same failure, one level up: **a rule that lives only in a chat attachment is not even a document.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Authored 2026-07-13. |
| 1.1 | **`ADR-0007` implementation-status correction added** — that decision is committed but NOT implemented; the live CA is branded `Home Lab` and every certificate is `<device>.lab`, verified on the wire. |
| 1.2 | **Correction.** A v1.1 filing note claimed this ADR had never been placed. **That was false** — it came from reading a stale copy of the repository. Note replaced with an accurate one. **The error is left visible rather than deleted, because the failure mode is the point.** |
