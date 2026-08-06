# ADR-0010 — Atlas Repository Publication and Its Preconditions

| Item | Value |
|---|---|
| Status | **Accepted** |
| Governing Policy | POL-0011 (+POL-0010) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-13 |
| Related | `CM-0014` (the archive passphrase in Git history), `018-Atlas-Documentation-Standards.md`, `049-Root-CA-and-Credential-Backup-Runbook.md` |
| Evidence Status | **`Verified`** — repository visibility confirmed **private** 2026-07-13; `ac2182f` confirmed present in history |
| Repository | `https://github.com/srfeuc/Atlas-Engineering-Repository` — **currently PRIVATE** |

> **Raised because a decision everyone assumed had been made had never been written down.**

## Context

**Atlas is a portfolio project.** `PORTFOLIO.md` sits in the repository root. The entire purpose of the project is to be **shown to people** — recruiters, hiring managers, engineers.

**So the intent to publish is obvious, universally assumed, and recorded nowhere.**

That is a problem, because **an unwritten intention cannot have a precondition attached to it.** There is no document a future session — or a future Seth, six months from now, polishing the portfolio the night before an interview — would read before clicking the button.

## 🔴 The button is destructive, and nothing says so

`CM-0014` established that commit **`ac2182f`** committed `Archive passphrase.txt` to the repository. That value is the GPG passphrase for the encrypted Root CA backup archive — which contains:

- The **Root and Intermediate CA private keys**
- The **plaintext RADIUS shared secrets** for FGT01, MKT01, and localhost
- The **entire Vaultwarden database**

**Deleting the file did not remove it.** It is in Git history, it is on GitHub, and it will remain retrievable by SHA until the history is purged and GitHub Support clears the cached objects.

> **Today the repository is private, so this is contained.**
>
> 🔴 **The instant it is made public, that passphrase is world-readable.** Not gradually. Not after a crawler finds it. **In the same instant.** Automated secret-harvesting crawlers monitor GitHub's public event firehose in near-real-time, and a repository flipping private→public with hundreds of commits of history is a **richer** target than a fresh one, not a poorer one.

**Making this repository public is currently an act of disclosure.** Nothing in the repository says so.

## Decision

**Publication is the intended end state of Atlas. It is explicitly gated.**

### The repository MUST NOT be made public until all of the following are true

| # | Precondition | Verify by |
|---|---|---|
| 1 | 🔴 **`CM-0014` is Closed.** Archive passphrase rotated, archive re-encrypted, **history purged**, GitHub Support has cleared cached objects. | `git log -p --all \| grep -i <no hits>`, and `github.com/.../commit/ac2182f` returns 404 |
| 2 | **A pre-commit secret scanner is installed and proven to block a test commit.** | Deliberately attempt to commit a dummy secret. **It must fail.** |
| 3 | **A full-history secret scan returns clean.** `gitleaks detect --log-opts="--all"` across every commit, not just `HEAD`. | Scanner output |
| 4 | **No live credential, key, token, or passphrase exists anywhere in the working tree.** | Scanner + manual review |

**Any one of these failing means publication is deferred. There is no "publish now, clean up after."** Once it is public, it is public, and forks are permanent.

### What may never enter the repository

Restating `018-Atlas-Documentation-Standards.md` line 29, which **was already in force and was violated anyway**:

> *"Never include passwords, API tokens, private keys, or reusable secrets."*

**The rule was not missing. Enforcement was.** Per `CM-0014`, the control is the **pre-commit scanner**, not the author's memory. `.gitignore` is a backstop and a weak one — it denylists *extensions*, and a passphrase in a `.txt` walks straight through.

## Consequences

**Accepted:**

- Publication is **delayed** until `CM-0014` closes. That is the cost, and it is small.
- Every future commit passes a secret scan. Mild friction, permanent benefit.

**Rejected — "just make it public and delete the file first":**

🔴 **This does not work and it is the trap this ADR exists to prevent.** `git rm` deletes a *name*, not a *blob*. The passphrase would remain fully readable via `git log -p` and via the direct commit URL, on a repository that is now public. **The most intuitive action is the wrong one.**

**Rejected — "keep it private forever":**

That defeats the purpose of a portfolio. **The answer to a risk is not to abandon the goal. It is to fix the risk and then proceed.**

## The pattern

> **A decision so obvious that nobody wrote it down is a decision with no preconditions attached.**

Everyone knew Atlas would be published. **Precisely because everyone knew, nobody recorded it** — and so there was no document in which to write *"and before you do, purge the history."*

**`ADR-0008` says content in the wrong place gets duplicated by someone who could not find it.** This is the sibling failure: **content in no place at all gets acted on by someone who never knew there was a condition.**

**The most dangerous assumptions are the ones nobody would think to argue with.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-13. Raised after `CM-0014` established that the backup archive passphrase is in Git history and on GitHub. Records that publication is the intended end state, that it is currently an act of disclosure, and that it is gated on four preconditions. Promised by `CM-0014` step 8. |
