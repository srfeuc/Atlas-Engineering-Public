# CM-0014 — Backup Archive Passphrase Committed to the Repository

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | ✅ **CLOSED 2026-07-14.** Rotation proven. History purged and **verified from a fresh clone of GitHub**. Scanner installed **and proven against the real incident** — which exposed that the default ruleset would NOT have caught it. |
| Risk | 🔴 **High** *(v2.0 raised it to Critical on the assumption of a public repo; v3.0 confirms **private** and returns it to High. It does not return it to Closed.)* |
| Affected systems | Lab CA (Root + Intermediate), FreeRADIUS, Vaultwarden, Atlas repository, Git history, **GitHub remote** |
| Date raised | 2026-07-13 |
| Evidence Status | **`Verified`** — file present at `HEAD` and in Git history from `ac2182f`; **remote confirmed and pushed** |
| Remote | 🔴 **`https://github.com/srfeuc/Atlas-Engineering-Repository.git`** — pushed. Confirmed 2026-07-13. |
| Remote visibility | **PRIVATE** — confirmed 2026-07-13. 🔴 **See "The visibility trap" below. This is the finding, not the reassurance.** |
| Raised by | Repository review, 2026-07-13 |

> **The file `Archive passphrase.txt` sits in the root of this repository, in plaintext, tracked by Git.**
>
> It was introduced by commit **`ac2182f`** — *"Root CA backup and credential rotation: 049-Runbook, CM-0010, Pi01 guide reconciliation"*. **The same commit that wrote the runbook forbidding this also committed the value the runbook forbids.**

**The passphrase value is not reproduced in this record, in any other Atlas document, or in any chat session. It is treated as burned regardless.**

## What the value is

It is **value 3** from `049-Root-CA-and-Credential-Backup-Runbook.md`, Phase 1 — the GPG symmetric passphrase for `atlas-pi01-<date>.tar.gz.gpg`.

`049` marks it, in its own table, as the one value that must **never** be stored digitally:

| # | Value | Also in Vaultwarden? |
|---|---|---|
| 1 | Root CA passphrase | ✅ Yes |
| 2 | Intermediate CA passphrase | ✅ Yes |
| 3 | **Archive passphrase** | 🔴 **NEVER** |

And in Phase 4: *"Archive passphrase from the PAPER — not from Vaultwarden. That distinction is the whole test."*

## Reason — what this passphrase actually gates

The archive it opens is not one secret. It is **every secret in the lab, in one file**:

| Inside the archive | Consequence if opened |
|---|---|
| `root-ca.key` + `intermediate-ca.key` | **The entire PKI.** Attacker can mint a trusted certificate for any device in the lab. |
| FreeRADIUS `clients.conf` | **Plaintext shared secrets** for FGT01, MKT01, localhost |
| Vaultwarden `data/` | Every credential in the vault, including the CA passphrases themselves |

`049` states it plainly: *"The archive holds plaintext RADIUS secrets and your entire PKI."*

**One passphrase, one file, total compromise.** That is precisely why `049` put it on paper and nowhere else.

## 🔴 The compounding failure — passphrase and media are co-located

`049` Phase 1: *"**NEVER in the same container as the media.** Media plus passphrase in one envelope is not two factors. It is one envelope that owns your entire PKI."*

Walk where both objects now live:

| Object | Location | How it got there |
|---|---|---|
| `atlas-pi01-2026-07-13.tar.gz.gpg` | Admin workstation | `049` §3.7 — `scp` off Pi01, by design |
| `Archive passphrase.txt` | Admin workstation, **inside the Atlas repo** | `ac2182f` |

**They are on the same machine.** The two-factor separation `049` was built to create was dissolved by the commit that created it. Anyone with that workstation has both halves.

## 🔴 Blast radius — the repository is on GitHub

**v1.0 of this record left the remote as an open question. It is now answered.**

The Atlas repository has a GitHub remote and is actively pushed to it. **The passphrase left the workstation the first time `git push` ran after `ac2182f`, and it has been on GitHub's servers ever since.**

| Where the value exists | Under your control? |
|---|---|
| Working tree at repo root | ✅ Yes |
| Local Git object store, `ac2182f` onward | ✅ Yes — via history rewrite |
| 🔴 **GitHub, in the repo tree at `HEAD`** | ❌ **No** — it is in the current file listing, not merely in history |
| 🔴 **GitHub, in the object store at `ac2182f`** | ❌ **No** — survives a force-push (see below) |
| 🔴 **Any fork of this repository** | ❌ **No** — permanent, and unknowable if the repo is public |
| **`Atlas-Engineering-Repository.zip`**, exported to an AI chat session 2026-07-13 | ❌ **No** — already left the machine |

### Visibility: PRIVATE — confirmed 2026-07-13

**This is genuinely better. It is not "fine."**

| Ruled out by private | 🔴 Still true |
|---|---|
| Public secret-harvesting crawlers reading the GitHub event firehose | The value is on GitHub's disks, at `HEAD`, and in `ac2182f` |
| Public forks holding the object permanently | Readable by every collaborator on the repo |
| Search-engine and code-search indexing | Readable by anything holding a PAT or SSH key for this account |
| The "assume already harvested" worst case | Readable by anyone who ever compromises the GitHub account |

**Private is a control that depends entirely on one account staying uncompromised, forever.** That is not a property of the secret. It is a property of a password on a third-party website.

### 🔴 The visibility trap — this is the actual finding

**Atlas is a portfolio project.** `PORTFOLIO.md` sits in the repository root. The entire purpose of this repo is to be **shown to people** — recruiters, hiring managers, engineers.

> **The single most likely future action on this repository is making it public.**

**If that toggle is flipped while `ac2182f` is still in history, the passphrase becomes world-readable in the same instant.** Not gradually. Not with a warning. The crawlers that were ruled out one section above are watching for exactly that event, and a repo going from private to public with 400 commits of history is a *richer* target than a fresh one, not a poorer one.

**Nothing in this repository currently records that constraint.** A future session — or a future Seth, six months from now, polishing the portfolio for a job application — has no reason to know that "make repo public" is a destructive action.

🔴 **THE HISTORY PURGE MUST COMPLETE BEFORE ANY VISIBILITY CHANGE.** Not after. Not at the same time.

**This inverts the priority of the whole record.** Private means the exposure is *contained*, so rotation is no longer an emergency — it is merely mandatory. But it also means the repository is now **one checkbox away from full public disclosure**, and that checkbox is one a portfolio project is *designed* to be clicked.

### 🔴 A force-push does NOT remove it from GitHub

**This is the trap in the obvious fix.**

Rewriting history with `git filter-repo` and force-pushing makes the old commits unreachable from any branch — **it does not delete them from GitHub.** They remain on GitHub's servers, retrievable by direct SHA:

```
https://github.com/srfeuc/Atlas-Engineering-Repository/commit/ac2182f
```

That URL keeps serving the file until GitHub garbage-collects the object, which is not guaranteed and not on your schedule. **GitHub's own guidance is that after rewriting history you must contact GitHub Support to purge cached views and references to the sensitive data.** If the repo is public and has been forked, the object persists in the fork network and **cannot be deleted at all.**

> **A repository is not a filesystem. `git rm` deletes a name. It does not delete a blob, and `git push --force` does not delete a blob from someone else's server.**

**This is why rotation — not deletion — is step 1.** A rotated passphrase makes every leaked copy worthless, everywhere, permanently, and it is the only step that does not depend on anyone else's cooperation.

## Why `.gitignore` did not catch it

Current ignore rules:

```
*.token
*.secret
.env
AtlasConfig.local.json
*.backup
*.conf
*.cfg
*.rsc
```

**A file named `Archive passphrase.txt` matches none of them.** The ignore list enumerates *extensions that usually hold secrets*. It cannot catch a secret in a `.txt` — and `.txt` is the single most likely extension for a human writing a passphrase down "temporarily."

**Denylisting file extensions does not protect secrets. It protects the extensions you thought of.**

## The rule already existed

`018-Atlas-Documentation-Standards.md`, line 29:

> *"Never include passwords, API tokens, private keys, or reusable secrets."*

**This was not an unwritten rule that nobody had gotten around to.** It was written, published, and in force. The failure was not a missing standard — it was that **nothing mechanically enforced it**, and a standard with no enforcement is a preference.

## Remediation — required, in this order

> 🔴 **Do not destroy the current archive before the replacement verifies.** `049` Phase 0 already carries this warning and it applies here unchanged: while the old archive is the only thing that opens, it is the only recovery point that exists.

| # | Step | Notes |
|---|---|---|
| 1 | **Invent a new archive passphrase.** 24+ ASCII, paper only, two copies, one off-site. | Per `049` Phase 1. Do **not** put it in Vaultwarden. Do **not** put it in the repo. |
| 2 | **Re-encrypt the archive** under the new passphrase. Verify by decrypting **from the paper**. | `049` Phase 4 is the test. A re-encrypt you have not decrypted is a hope. |
| 3 | **Destroy the old `.gpg` archive** — only after step 2 verifies. | `shred -u`. Every copy, including the workstation and any USB media. |
| 4 | **Purge the value from Git history.** `git filter-repo --path 'Archive passphrase.txt' --invert-paths` | `git rm` is **not sufficient.** |
| 5 | **Force-push the rewritten history to GitHub.** | Necessary. **Not sufficient — see the force-push section above.** |
| 6 | **Contact GitHub Support** to purge cached views of `ac2182f`. | **Recommended, not urgent, while the repo is private** — a dangling commit in a private repo is only reachable by someone who already has read access. **Becomes mandatory before any visibility change.** |
| 7 | **Check the collaborator list.** Delete any clone made before the purge. | Private repos can only be forked by collaborators. If it is just you, this is short. |
| 8 | 🔴 **Raise an ADR: the repository MUST NOT go public until CM-0014 is Closed.** | See below. **This is the step that protects you from the visibility trap.** |
| 9 | **Add mechanical enforcement.** | See below. |

### Step 8 — why this needs an ADR, not a note

**A constraint that lives only in a change record is a constraint nobody reads before clicking a button in a GitHub settings page.**

The decision *"Atlas is a portfolio project and will eventually be published"* has never been written down, even though it is obviously true and `PORTFOLIO.md` presupposes it. **An unwritten intention cannot have a precondition attached to it.**

Proposed: **ADR-0010 — Atlas repository publication and its preconditions.**

- Records that publication is the intended end state
- Records that **`ac2182f` makes publication an act of disclosure**, and that the history purge is a hard precondition
- Records what may never enter the repository at all, enforced by the pre-commit scanner from step 9

> **`ADR-0008` says Foundation holds process, not technology.** Repository publication is process. This belongs there.

### Step 6 — enforcement, because the standard alone did not hold

| Control | Purpose |
|---|---|
| `.gitignore`: add `*passphrase*`, `*secret*`, `*.key`, `*.pem` | Catches the *name*, not just the extension. Still a denylist — a backstop, not the control. |
| **Pre-commit secret scan** (`gitleaks` / `trufflehog`) | 🔴 **This is the actual control.** It reads *content*, not filenames, and it fails the commit. Nothing else in this list would have stopped `ac2182f`. |
| `Tools/New-Atlas-Commit.ps1` — call the scanner before `git commit` | Puts the check on the path everyone actually uses. |

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| `049-Root-CA-and-Credential-Backup-Runbook.md` | 🔴 **Must update** | Phase 1 correctly says *paper only* and *never in the same container as the media* — **and the person following it still put the value in the repo on the same workstation as the archive.** The runbook states the rule but has **no closeout step that verifies the value exists nowhere digital.** Add one: *"Confirm the archive passphrase appears in no file, no repo, no vault, no chat. `git log -p \| grep` the repo to prove it."* **A rule with no verification step is advice.** |
| `018-Atlas-Documentation-Standards.md` | 🔴 **Must update** | Line 29's rule was correct and was violated anyway. Add: **the standard is enforced by a pre-commit secret scan, not by the author remembering it.** |
| `044-Vaultwarden-Password-Storage-Convention.md` | **Reviewed — no change needed** | `044`'s rule (*archive passphrase never goes in Vaultwarden*) **held perfectly.** The value did not go in the vault. It went somewhere `044` never contemplated, because `044` was scoped to the vault. **The rule was right and still insufficient — it named one forbidden container, not all of them.** |
| `CM-0010` | **Reviewed** | Same family. `CM-0010` destroyed CA key backups wrapped in a leaked passphrase. **This record is the sequel: the passphrase protecting the *replacement* was then written to disk and committed.** The remediation created its own exposure. |
| `Tools/New-Atlas-Commit.ps1`, `Tools/README.md` | 🔴 **Must update** | Add the secret scan to the commit path. |
| `048-Teardown-and-Rebuild-Runbook.md` | **Not yet reviewed** | Check whether it instructs the reader to retrieve the archive passphrase from anywhere other than paper. |

## The pattern

**`CM-0013` named it:** *a security fix created a blind spot* — deleting `testing`/`password` was correct and left RADIUS unverifiable.

**`CM-0010` named it:** *a procedure with a create step and no destroy step leaves the thing it created lying around.*

**This one is the third face of the same shape:**

> **The document that defines a rule is not a control. The commit that publishes the rule can violate it in the same breath, and nothing will notice.**

`ac2182f` shipped `049` — an unusually careful runbook, whose entire Phase 1 is a warning about this exact value — **and shipped the value.** Both changes were staged by `git add .`, both were committed, and the commit message describes only the good half.

**Every prior finding in this pack was caught by reading live device state.** This one was caught by reading the repository — the one system nobody had thought to point the discipline at. **Charter Rule 13 says: when a document and a device disagree, the device is right.** This record adds a corollary: **the repository is also a device, and nobody was reading it back.**

**And a second corollary, added in v2.0:**

> **`git push` is a change to a production system.**
>
> It moves data to a machine you do not own, whose retention policy you do not set, whose deletion you must *request*. **Every other such action in this lab gets a change record.** Pushing to GitHub got none — it was treated as saving a file. `049` correctly forbade putting this value on a USB stick. **Nobody thought to forbid putting it on the internet, because `git push` does not feel like an export.**

**And in v3.0, the sharpest one:**

> **A private repository is not a place where secrets are safe. It is a place where secrets are *pending*.**
>
> Every other control in this lab was checked by reading live state. **Repository visibility is the one control whose failure mode is a single click by its own owner, acting entirely in good faith, on the day the project succeeds.**

## ROTATION — COMPLETED AND VERIFIED 2026-07-14

> 🔴 **The rotation this record demanded had NEVER HAPPENED.** **The mtime proved it:** `ac2182f` committed the passphrase at **14:09:41**; the archive was written at **14:16** and **never rewritten**. **There was no window in which it was re-encrypted.**
>
> **Confirmed 2026-07-14:** `git show ac2182f:"Archive passphrase.txt"` returned **the value on the paper**. **They were identical. The archive was sealed with the leaked passphrase for a full day, while the records implied otherwise.**

### Phase 0 — Inventory. Every copy, before touching any.

| Copy | Found by |
|---|---|
| `~/atlas-backup/atlas-pi01-2026-07-13.tar.gz.gpg` (Pi01) | `find / -name "*.gpg"` — whole-filesystem sweep |
| **`E:\atlas-pi01-2026-07-13.tar.gz.gpg`** | `Get-ChildItem E:\ -Recurse -Filter *.gpg` — **137,946 bytes, byte-identical** |

**Workstation user profile swept — clean.** **Also found:** `vaultwarden-container-env.txt` → **`CM-0019`**.

> 🔴 **Rotating Pi01's copy and forgetting the second one would have produced a beautifully documented change record and ZERO security improvement.** **The leaked value would still have opened the PKI — from a different drive.**
>
> **This is `CM-0010`'s lesson exactly: *a narrative has no line that asks "and did you destroy them?"* Phase 0 IS that line.**

### Phases 1–5 — executed and proven

| Phase | Evidence |
|---|---|
| **1. New passphrase** | Generated **in Vaultwarden**. **Never typed into a chat. Never placed on a command line.** |
| **2. Decrypt + re-encrypt** | Old archive opened; listing confirmed **`etc/ssl/lab-ca/intermediate/private/intermediate-ca.key`**. Re-encrypted AES256. **Plaintext `shred -u`'d immediately.** |
| **3. 🔴 PROVE IT** | ✅ **New archive DECRYPTED with the NEW passphrase. Listing showed `intermediate-ca.key` again.** |
| **4. Second copy + hash-match** | `scp` to the external drive. **`9e49f01f…95bc3` on both sides. Byte-for-byte.** |
| **5. Destroy old copies** | `shred -u` on Pi01; `Remove-Item` on the external drive. **One `.gpg` each side, both `07-14`.** |

> 🔴 **Phase 3 is the step whose absence let the previous rotation be recorded as done when it never happened.**
>
> **`gpg` exiting 0 on an ENCRYPT is a claim. Opening the result with the new passphrase is evidence. They are different acts, and only the second one is a rotation.**

### 🔴 The passphrase itself was a defect

**The rotated-out value contained `!`, `^`, `&`, `@`. It failed three different ways, in three different tools, during the very operation it existed for:**

| Failure | Cause |
|---|---|
| `-bash: !JA: event not found` — **twice** | bash history expansion on `!` |
| `The ampersand (&) character is not allowed` — **twice** | PowerShell parser |
| `gpg: decryption failed: Bad session key` | **Paste mangling. Typing it by hand worked.** |

> 🔴 **A passphrase you cannot reliably type or paste is a passphrase that will fail during a recovery — the one moment it exists for.**
>
> 🔴 **And bash rejecting the `!` is the ONLY reason that value never landed in the shell history in plaintext, on the host holding the archive it unlocks. That was luck, not a control.**
>
> **STANDARD ADOPTED: long, ASCII, letters and digits, `-` and `_` only.** **Entropy comes from LENGTH — not from characters that break the tools you need.**

### Result

**The value in `ac2182f` now opens NOTHING that exists.**

🔴 **`CM-0014` has CHANGED SHAPE, not closed.** It was: *a live credential to the entire PKI is in Git history.* It is now: **a dead string is in Git history, and `ADR-0010` forbids publishing this repository until it is gone.** **Same purge. Completely different stakes.**

## HISTORY PURGE — COMPLETED AND VERIFIED 2026-07-14

- [x] ✅ `git filter-repo --invert-paths --path "Archive passphrase.txt"` on a **throwaway mirror clone**
- [x] ✅ **Blob `be76535…` confirmed unreachable** — `git cat-file -e` → **`EXIT: 1`**; `rev-list --all --objects` → empty; `count-objects` → `garbage: 0`
- [x] ✅ **Force-pushed.** No branch protection existed (rulesets require a paid org — the Danger Zone button is a kill-switch, not evidence of a rule).
- [x] ✅ **VERIFIED FROM A FRESH `--mirror` CLONE OF GITHUB** — `EXIT: 1`, no log entries, no matching objects. **A server-side check that local objects cannot fake.**
- [x] ✅ **Working copy reset to the purged history** (`git fetch` + `reset --hard origin/main` + `gc --prune=now`). **`EXIT: 1` locally too.**
- [x] ✅ **All local clones enumerated** — exactly **one** `.git` on the machine. `Atlas-2-Publisher`, `Atlas-2-Publisher-v1.2` and `Atlas2\NetworkArchitecture-v1.0-Draft` are **not repos**. **No stray copies.**
- [x] ✅ **gitleaks pre-commit hook installed AND PROVEN to block a commit**
- [x] 🔴 **`.gitleaks.toml` custom rule added — see the finding below. THE DEFAULT RULESET DID NOT CATCH IT.**
- [x] ✅ `.gitignore` name-based backstops
- [ ] 🔴 **GitHub-side garbage collection NOT requested.** Unreachable objects persist on GitHub's servers until they GC. **`ac2182f` may still be fetchable by direct SHA via the API.** **Deferred — the value is inert, so this is hygiene, not risk.**
- [ ] 🔴 **The pre-commit hook is NOT portable** — see `CM-0020`.
- [x] ✅ **Closed 2026-07-14**

## 🔴 THE FINDING — the scanner we installed would NOT have caught this leak

**We tested the control against the actual incident instead of a textbook example. It failed.**

| Test | Result |
|---|---|
| AWS access key (`AKIAZZ5G4XYQ…`) | ✅ **BLOCKED.** `RuleID: aws-access-token` |
| 🔴 **`Archive passphrase.txt` containing the REAL leaked value** | 🔴 **COMMITTED CLEANLY.** *"scanned ~25 bytes… no leaks found."* |

**Gitleaks is pattern-based.** It matches `AKIA…` prefixes, `-----BEGIN RSA PRIVATE KEY-----`, `github_pat_…` — **shapes it recognises.**

🔴 **A bare high-entropy passphrase has NO SHAPE.** No prefix. No `key = value`. No delimiter. **There is nothing for a pattern matcher to match.** **The FILENAME was the only signal — and it was screaming.**

### The fix — and it inverts what `018` v2.0 said

```toml
[extend]
useDefault = true

[[rules]]
id = "atlas-secret-filename"
description = "Any file whose NAME suggests it holds a secret - CM-0014"
regex = '''(?s).{8,}'''
path = '''(?i)(passphrase|secret|credential|password|\.env$|\.key$|\.pem$)'''
```

**Re-tested with the real file and the real value: `RuleID: atlas-secret-filename` → `BLOCKED`.** ✅

> 🔴 **`018` v2.0 — written the same day — said the CONTENT scanner *"is the control"* and dismissed name-based rules as *"a backstop, not a control."*
>
> **We had it exactly backwards, and we proved it on the exact file.**
>
> **`016` lesson 4 has a twin, earned tonight:**
> **A test that cannot fail proves nothing. And a test that PASSES ON THE WRONG INPUT proves nothing either.**
> **Test your control against the thing that actually happened.**

### 🔴 The purge rewrote every commit hash

**`ac2182f` no longer exists.** The pre-purge history is gone **by design** — that is what remediation looks like. **Documents citing `ac2182f` (this record, `018`, `049`, the Session Handoff) now reference an unresolvable commit. That is correct and intended.** Do not "fix" them by restoring the history.


## Original Closeout

- [ ] New archive passphrase generated — paper only, 24+ ASCII, two copies, one off-site
- [ ] Archive re-encrypted under the new passphrase
- [ ] **Re-encrypted archive decrypted from the paper — verified, not assumed**
- [ ] Old `.gpg` archive destroyed on every medium — **only after the above verified**
- [ ] Value purged from local Git history (`git filter-repo`), not merely `git rm`-ed
- [ ] Rewritten history force-pushed to GitHub
- [x] **Repository visibility established: PRIVATE** — confirmed 2026-07-13
- [ ] GitHub Support contacted — cached views of `ac2182f` purged *(mandatory before any visibility change)*
- [ ] Collaborator list checked; any pre-purge clone destroyed
- [ ] 🔴 **ADR-0010 raised — repository must not go public until this record is Closed**
- [ ] `.gitignore` name-based rules added
- [ ] **Pre-commit secret scan installed and proven to block a test commit**
- [ ] Guide reconciliation completed for `049`, `018`, `048`, `Tools/`
- [ ] Closed

## Change Log

| Version | Changes |
|---|---|
| **3.0** | **2026-07-13 — Visibility confirmed PRIVATE. Risk returned Critical → High.** The "assume already harvested" worst case is ruled out; the exposure is contained to the GitHub account. **But this surfaced the real finding: Atlas is a portfolio project (`PORTFOLIO.md`), so the most likely future action on this repo is making it public — which would disclose `ac2182f` instantly.** The history purge is now a hard precondition of publication, and nothing in the repo recorded that. Added the visibility trap, ADR-0010 (publication preconditions), and the private-repo corollary. |
| **2.0** | **2026-07-13 — Risk raised High → CRITICAL.** The open question in v1.0 ("has this repo ever been pushed to a remote?") is **answered: yes.** Remote is `github.com/srfeuc/Atlas-Engineering-Repository`, actively pushed. The value is on GitHub's servers, at `HEAD`, and in the object store at `ac2182f`. Added: the force-push trap (a rewrite does **not** delete the blob from GitHub — Support must purge it), public-vs-private triage, and two new remediation steps. Added the `git push` corollary to the pattern section. |
| 1.0 | Raised 2026-07-13. `Archive passphrase.txt` found tracked at repo root, introduced by `ac2182f` — the same commit that published `049`, the runbook forbidding it. Value gates the CA keys, plaintext RADIUS secrets, and the Vaultwarden database. Passphrase and archive media confirmed co-located on the admin workstation, dissolving the two-factor separation `049` exists to create. Remediation not started. |
