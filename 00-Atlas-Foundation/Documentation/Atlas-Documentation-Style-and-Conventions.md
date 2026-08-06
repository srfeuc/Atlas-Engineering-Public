---
Title: Atlas Documentation Style & Conventions
Path: 00-Atlas-Foundation/Documentation
Status: Reference — doc *writing/formatting* conventions (secrets rule, screenshots, callouts, pack lifecycle). Renamed from `Atlas-Documentation-Standards.md` (`ADR-0052` §7) to end the name collision with the singular `Atlas-Documentation-Standard.md` (doc *architecture*).
Version: 3.1
Date: 2026-07-31
---

# Atlas Documentation Style & Conventions

> ⚠️ **Not to be confused with `Atlas-Documentation-Standard.md` (singular).** This doc governs **how a doc is written & formatted** — frontmatter, provenance, the secrets rule, screenshots, callouts, the pack lifecycle. The **singular** `Atlas-Documentation-Standard.md` (`ADR-0037`) governs **doc architecture** — the per-device folder shape and elements. They are a deliberate split; the near-identical old names caused confusion, so the plural was renamed here (`ADR-0052` §7). *(Historical citations of the frozen Lab-01 `018-Atlas-Documentation-Standards.md` are a different, retained document — do not repoint them.)*

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | **Draft for Confluence Review** |
| Version | **3.0** |
| Applies To | Atlas |
| Last Reconciled | 2026-07-14 |

## Working Rules

- One pack at a time.
- Write or update the pack, publish it, review in Confluence, correct it, freeze it, then move on.
- Do not redesign Atlas while a pack is in execution.
- **Build Guides describe target state.**
- **Build Records describe verified current state.**
- **Change Records move current state toward target state.**
- Optimize navigation for the engineer; common tasks should be within three clicks.
- **One authoritative home per technical fact**; summary duplication is allowed when it improves execution.
- Include purpose, prerequisites, commands, validation, common mistakes, lessons learned, rollback, and next step where applicable.
- 🔴 **Never include passwords, API tokens, private keys, or reusable secrets.**

## 🔴 The secrets rule is not enforced by this page

**Added in v2.0, because this document's own rule was published, in force, and violated anyway.**

Commit **`ac2182f`** shipped `049-Root-CA-and-Credential-Backup-Runbook.md` — a runbook whose **entire Phase 1** is a warning that the archive passphrase must **never** exist digitally — **and committed the passphrase, in the same commit, in a file called `Archive passphrase.txt`.** `git add .` staged both halves. The commit message describes only the good one. **It is in Git history and on GitHub.** (`CM-0014`)

> 🔴 **The document that defines a rule is not a control.**
>
> **The commit that publishes a rule can violate it in the same breath, and nothing will notice.**

### 🔴 v3.0 CORRECTION — v2.0 NAMED THE WRONG CONTROL. WE PROVED IT.

**v2.0 of this page said:**

> *"🔴 **Pre-commit secret scan — THIS is the control.** It reads **content**, not filenames, and it **fails the commit**. **Nothing else in this list would have stopped `ac2182f`.**"*
>
> *"`.gitignore` — denylists **extensions**… **A backstop, not a control.**"*

🔴 **BOTH SENTENCES ARE FALSE. Tested 2026-07-14 against the exact file and the exact leaked value:**

| Control | Would it have stopped the real leak? |
|---|---|
| **Gitleaks — default ruleset** | 🔴 **NO.** It scanned all 25 bytes of `Archive passphrase.txt` and reported **"no leaks found."** The commit went through. |
| **A NAME-based rule (`*passphrase*`)** | ✅ **YES.** Blocked immediately. |

**Why:** gitleaks is **pattern-based**. It matches `AKIA…`, `-----BEGIN RSA PRIVATE KEY-----`, `github_pat_…` — **shapes.** 🔴 **A bare high-entropy passphrase has no shape.** No prefix, no `key = value`, no delimiter. **Nothing to match.**

**The filename was the only signal, and it was screaming.**

> 🔴 **We dismissed the control that would have worked, and canonised the one that would not.**
>
> **And we only found out because we tested against the incident that actually happened, instead of a textbook AWS key — which passed, and told us nothing.**

### The control is mechanical, or it does not exist

| Control | What it actually does |
|---|---|
| **This page** | States the rule. **Stops nothing.** |
| `.gitignore` | Denylists **extensions** (`*.token`, `*.secret`, `*.conf`). **A passphrase in a `.txt` walks straight through** — and `.txt` is the single most likely extension for a human writing a value down "temporarily." **A backstop, not a control.** |
| 🔴 **Pre-commit secret scan** (`gitleaks` / `trufflehog`) | **This is the control.** It reads **content**, not filenames, and it **fails the commit.** **Nothing else in this list would have stopped `ac2182f`.** |
| `Tools/New-Atlas-Commit.ps1` | Calls the scanner before `git commit` — puts the check on the path actually used. |

**Required, per `CM-0014` and `ADR-0010`:**

- The pre-commit scanner is installed **and proven to block a test commit.** *(Deliberately attempt to commit a dummy secret. **It must fail.** A scanner you have not seen refuse something is not a scanner — it is a hope. See `016` lesson 4: a test that cannot fail proves nothing.)*
- `.gitignore` gains **name-based** rules (`*passphrase*`, `*secret*`, `*.key`, `*.pem`) — a backstop, still not the control.
- 🔴 **The repository must not be made public until `CM-0014` is Closed.** `ADR-0010`.

### What documentation may say about a secret

**A Build Guide never contains a value you would actually type. A Build Record may name a value that no longer works.**

| Value | Treatment | Why |
|---|---|---|
| `snmp-server community homelab` | **Redact *and* rotate.** | **Live**, and SNMP v2c sends it in cleartext. |
| `testing` / `password` | **Keep it, named, in the Build Record and Troubleshooting Guide.** Remove it only from any guide that instructs you to *create* it. | **Deleted.** It is the best lesson in the project — it became a live network-device admin login the moment RADIUS started working. |
| `testing123` | **Keep.** Not a secret. | FreeRADIUS's published stock default. Redacting it makes the guide unusable — **and the actual lesson is that *two* client blocks ship with it and both need rotating.** |

> **Documentation names where a secret is stored. It does not reveal one that still works.**

## 🔴 The repository is the source of record. Confluence is the published copy.

**Write the repo file first. Then publish it. Never the reverse.**

Anything written to Confluence and nowhere else is **one wiki outage away from never having existed** — and a rebuild from the repository silently loses it. See `ADR-0012`.

## Screenshot Standard (SS-001)

**Screenshot decision points, not every click.** Text ages slower than screenshots — a page of twenty click-by-click screenshots stops getting read; a handful placed where they matter keeps getting used.

**Screenshot:** first navigation into an unfamiliar area; any dialog box that commonly confuses people; the final successful result; anything destructive; anything a vendor tends to move between versions.

**Everything else: text.**

## Callout System

Use these four consistently, so the visual language means the same thing on every page:

- 🟢 **Engineering Tip** — something learned from experience.
- 🟡 **Important** — something not obvious from the steps alone.
- 🔴 **Warning** — potential outage or destructive action.
- 🔵 **Why?** — the engineering reason behind a choice, not just the step.

## Current Pack Lifecycle

`Draft` → `Published` → `Reviewed` → `Reconciled` → `Verified` → `Frozen`

> **A pack is frozen when its work is complete — not when its documentation says it is.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial standards: working rules, screenshot standard, callouts, pack lifecycle. |
| **2.0** | 🔴 **2026-07-14.** v1.0's line 29 — *"Never include passwords, API tokens, private keys, or reusable secrets"* — **was published, in force, and violated by `ac2182f`, the very commit that shipped the runbook forbidding it.** Added *"The secrets rule is not enforced by this page"*: the control is a **pre-commit secret scanner that reads content and fails the commit**, not this page, not `.gitignore`, and not the author's memory. Added the evidence-and-secrets table (what a guide may name vs. what it must never contain) and the **repo-is-authoritative / Confluence-is-published** rule. Required by `CM-0014`'s guide reconciliation and `ADR-0010`. |

## 🔴 The rule this page now teaches about itself

> **A control you have not watched refuse something is a hope.**
>
> **And a control you have only watched refuse the WRONG thing is worse — because you have evidence, and the evidence is misleading.**

**The AWS-key canary passed. We nearly closed `CM-0014` on it.** **The real file walked straight through the same scanner, thirty seconds later.**

**TEST YOUR CONTROL AGAINST THE INCIDENT THAT ACTUALLY HAPPENED.**

| Version | Changes |
|---|---|
| **3.1** | 2026-07-31. **Renamed** `Atlas-Documentation-Standards.md` → `Atlas-Documentation-Style-and-Conventions.md` and fixed the stale `Path` frontmatter (`Infrastructure/Network Architecture` → `00-Atlas-Foundation`), per `ADR-0052` §7 — ending the name collision with the singular `Atlas-Documentation-Standard.md` (doc architecture). Added the disambiguation banner. No rule content changed. Live references repointed; frozen Lab-01 `018-` citations left intact (`ADR-0012`). |
| **3.0** | 🔴 **2026-07-14. v2.0's central claim was FALSE and was disproven by test.** The content scanner **did not** catch `Archive passphrase.txt`; a **name-based rule did.** Both are now required. **v2.0 dismissed the control that would have worked.** |
