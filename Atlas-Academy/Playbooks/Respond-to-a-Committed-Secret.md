---
Title: Playbook — Respond to a Committed Secret (rotate first — a blob is not a file)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked. Grounded in the real frozen **Lab-01** incident (`CM-0014`, the `git add .` scar), current-design-reconciled (`ADR-0022`/`ADR-0010`). Searchable/ticket-ready per Backlog **#32**.
Version: 1.1
Date: 2026-08-02
---

# Playbook — Respond to a Committed Secret

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: incident / secrets. **A password, key, token, or passphrase has been committed to the Atlas repository (and maybe pushed to GitHub) — what do you actually do?** The instinct is to delete the file and force-push. That is the *wrong first move*. **Rotate first**: a rotated secret makes every leaked copy — local, on GitHub's disks, in forks, in a chat export — worthless everywhere, permanently, and it's the only step that doesn't depend on anyone else's cooperation.

**Why this is the most portfolio-relevant incident (Backlog `#32`).** It's the `git add .` scar the estate's house rule exists for. In frozen Lab-01, `Archive passphrase.txt` was committed by `ac2182f` — **the same commit that shipped the runbook forbidding it** — via `git add .`. That one passphrase gated the entire PKI (Root + Intermediate CA keys), plaintext RADIUS secrets, and the whole vault. And Atlas is a **portfolio repo** (`PORTFOLIO.md`): the single most likely future action is *making it public*, which would disclose the leaked commit **the instant the toggle flips** (`CM-0014`, `ADR-0010`).

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **what a committed secret really is** — why `git rm` / force-push don't delete it, and why rotation is step 1.
3. **① Pin it down** — what leaked, what it gates, where it exists now, repo visibility & intent.
4. **The response path** — rotate + verify → inventory every copy → destroy → `filter-repo` purge → force-push + GitHub GC → verify from a fresh clone → mechanical enforcement.
5. **Prove it's handled** · **If still broken**.
6. **Worked example → `CM-0014`** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- "*scanned … no leaks found*" from gitleaks — but the secret is still there (a bare high-entropy string has no shape to match).
- "*The ampersand (&) character is not allowed*" / "*event not found*" — a secret with shell-breaking chars failing during recovery.
- a filename like `Archive passphrase.txt`, `*.key`, `.env`, `vaultwarden-container-env.txt` tracked at a repo path.
- "*git rm*" / "*git filter-repo*" / "*git push --force*" in your command history right after finding it.

**Plain-language symptom phrases**

- "I committed a password / key / .env to the repo."
- "I ran `git add .` and it swept in a secret."
- "there's a secret in the git history — how do I remove it?"
- "I pushed a credential to GitHub by accident."
- "can I just delete the file and force-push?" (no — read this first).
- "is it safe to make the repo public?" (not until this is Closed).
- "the leaked secret is in an old commit / a fork / a zip I exported."

**Aliases / also-known-as**

- committed secret · leaked credential · secret in git history · exposed key/passphrase/token · secret sprawl.
- `git filter-repo` · BFG · history rewrite · force-push · GitHub Support cache purge · rotate-then-purge.
- `git add .` scar · `.gitignore` miss · gitleaks / trufflehog · pre-commit secret scan · a blob is not a file.
- repo-going-public disclosure · `ADR-0010` publication precondition.

**Keywords line**

`git add .` · `CM-0014` · `ac2182f` · `git filter-repo` · `git rm` (insufficient) · force-push · gitleaks · `.gitleaks.toml` · rotate-first · Vaultwarden · `POL-0002` · `ADR-0010` · private-repo-is-pending · fresh mirror clone · GitHub Support GC · portfolio repo.

## Cert anchor

- CompTIA **Security+** (incident response; secrets management; key rotation) — the primary anchor.
- **CySA+** (containment/eradication/recovery), git/DevSecOps practice.
- *(Grounding index: `POL-0002` Secrets-and-Credentials + `ADR-0010` publication preconditions; `../Concepts/README.md` — the repository is a production system, and a blob is not a file.)*

## Grounded in — what a committed secret really is (and the estate's rule)

Know the mechanics before you react (`POL-0008` — the policies own these facts; this page links):

- **`git rm` deletes a *name*, not a *blob*.** The value stays in history at its commit SHA. `git push --force` after a rewrite makes old commits unreachable from branches but **does not delete them from GitHub's servers** — they remain fetchable by direct SHA until GitHub garbage-collects (not on your schedule), and in a **fork** they can't be deleted at all.
- **Rotation is the only step that doesn't need anyone's cooperation.** Once the secret is rotated, every leaked copy is inert — that's why it's step 1, not deletion.
- **A private repo is not "safe" — it's *pending*.** Its protection is one account staying uncompromised, and one settings click (going public) from full disclosure. So the history purge is a **hard precondition of publication** (`ADR-0010`).
- **The estate's mechanical controls (current design):** never `git add .` (the `CM-0014` scar); **LF** endings; **`gitleaks` runs in CI + a pre-commit hook** and must be clean; live secrets live in **Vaultwarden**, never in a doc or commit (`POL-0002`). A doc may *name where* a secret lives; it must never contain a working one.
- **The `.gitignore`/scanner gap:** denylisting extensions protects the extensions you thought of; a bare high-entropy passphrase has **no shape** for a content scanner to match — the *filename* was the only signal, so the estate added a **name-based** gitleaks rule and **tested it against the real leaked file** (`CM-0014`).

Command detail: this is a git/secrets procedure (no device Command-Library page owns it); the owners are `POL-0002`, `ADR-0010`, and `CM-0014`. Why-it-works: `../Concepts/README.md` (the repository is a production system; rotate-before-purge).

## ① Pin it down (capture these first — they're the ticket)

- a. **What leaked** — which secret, and **what it gates** (one host password? a CA key? a whole vault?). The blast radius sets the urgency.
- b. **Where it exists now** — working tree only, or committed? pushed to GitHub? in a chat/zip export? on other media? (You'll rotate first regardless, then purge every copy.)
- c. **Which commit + filename** introduced it (`git log --oneline -- <path>` / search history). Note the SHA — you'll verify it's gone later.
- d. **Repo visibility & intent** — private now, but is it a **portfolio repo destined to go public**? (Then the purge is a publication precondition — `ADR-0010`.)
- e. **Was it `git add .`?** — if so, check what *else* got swept in (a twin leak, like the co-located env file in `CM-0019`).

## The response path — rotate first, always

> 🔴 **Do not destroy the old artifact before its rotated replacement verifies.** While the old value is the only thing that opens the archive/CA, it's your only recovery point (`049` Phase 0).

**1. ROTATE the secret (step 1, non-negotiable).**

- a. Generate a new value — long, **ASCII letters/digits + `-`/`_` only** (entropy is length, not tool-breaking chars like `! ^ & @` — those failed *during* the Lab-01 recovery in bash, PowerShell, and paste; `CM-0014`). Store it in Vaultwarden or on paper per its class (`POL-0002`), **never in the repo, never in a chat, never on a command line**.
- b. **Re-key/re-encrypt** whatever the secret protected under the new value.
- c. 🔴 **Prove the replacement works** — decrypt/authenticate with the *new* value. `gpg`/`set` exiting 0 is a claim; opening the result with the new secret is evidence (`Confirm-a-Config-Change-Actually-Took.md`). Only a verified replacement counts as a rotation.

**2. Inventory EVERY copy before destroying any (the `CM-0010` line).**

- a. Sweep for all copies: `git log -p -- <path>`, a filesystem sweep (`find / -name '<pattern>'` / `Get-ChildItem -Recurse`), external drives, chat/zip exports, other clones.
- b. 🔴 Rotating one copy and missing a second = a beautiful change record and **zero** security improvement (the leaked value still opens the PKI from another drive).

**3. Destroy the old copies — only after step 1 verified.**

- a. `shred -u` (Linux) / secure-delete every old encrypted artifact and stray file, on every medium.

**4. Purge the value from git history (deletion, done right).**

- a. `git filter-repo --path '<file>' --invert-paths` (or BFG) — on a **throwaway mirror clone**. `git rm` alone is **not** sufficient.
- b. Confirm the blob is unreachable locally: `git cat-file -e <blob>` → non-zero; `git rev-list --all --objects | grep <path>` → empty.

**5. Force-push, then close the server-side gap.**

- a. Force-push the rewritten history.
- b. 🔴 A force-push does **not** delete the blob from GitHub — the old SHA may still be fetchable. **Contact GitHub Support** to purge cached views/objects (mandatory before any visibility change).
- c. Check the **collaborator/fork** list; delete any clone made before the purge.

**6. Verify the purge from a FRESH mirror clone of the remote (not your local).**

- a. `git clone --mirror <remote>` into a new dir, then `git cat-file -e <blob>` → exit 1, `git rev-list --all --objects | grep <path>` → empty.
- b. 🔴 A server-side check your local objects cannot fake — this is the evidence the purge actually landed.

**7. Add mechanical enforcement so it can't recur — and test it against the real leak.**

- a. Pre-commit + CI **gitleaks**; add a **name-based** rule (`passphrase|secret|credential|\.key$|\.pem$|\.env$`) — a bare high-entropy string has no content shape (`CM-0014`).
- b. 🔴 **Test the scanner against the actual leaked file**, not a textbook AWS key — the default ruleset let the real passphrase through. A control that passes on the wrong input proves nothing.
- c. Never `git add .`; stage explicit paths (the scar this rule comes from).

## Prove it's handled

- a. The old value opens **nothing that exists** (rotation verified in step 1c).
- b. A **fresh mirror clone** of the remote shows the blob unreachable and no log/object match (step 6).
- c. gitleaks blocks a test commit of the real pattern (step 7b).
- d. If this is the portfolio repo: `ADR-0010`'s publication precondition is recorded — **do not make the repo public until this is Closed**.
- e. 📸 the fresh-clone `EXIT: 1` + the gitleaks block. Mark ✅ only with the pasted evidence (`POL-0001`); **never reproduce the secret value** in any doc (`POL-0002`).

## If still broken

- The repo was already public / forked before the purge → the blob may be unrecoverable-to-delete; **rotation is your only real protection** — confirm the value is inert everywhere and treat the leak as permanent-but-worthless.
- The scanner still misses it → the leak has no shape *and* an unremarkable name; add an explicit path/pattern rule and re-test on the real file.
- You destroyed the old artifact before verifying the new one → you may have no recovery point; restore from another backup copy before proceeding (this is why step 1c precedes step 3).
- Docs cite the now-rewritten commit SHA (`ac2182f`) → that's **correct and intended** (the purge rewrote history); do not "fix" them by restoring history (`ADR-0012`).

## Worked example — the real Lab-01 case (`CM-0014`, closed 2026-07-14)

> The `git add .` scar this Playbook is drawn from — the response carried out on the real Atlas repository. **Authoritative record: [`Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0014-Archive-Passphrase-Committed-to-Repository.md`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0014-Archive-Passphrase-Committed-to-Repository.md).** Read-backs are quoted from the frozen record; **the secret value is never reproduced** (`POL-0002`).

- **① Pin it down.** `Archive passphrase.txt` was committed by `ac2182f` — *the same commit that shipped the runbook forbidding it* — via `git add .`. It gated the entire PKI (Root + Intermediate CA keys), the plaintext RADIUS secrets, and the whole vault. Remote confirmed (`github.com/srfeuc/…`, pushed); visibility **private — but the repo is a portfolio project**, so the real finding was that making it public would disclose `ac2182f` instantly (`ADR-0010`). → `CM-0014` §Status / §v3.0.
- **Step 1 — rotate + verify.** The archive passphrase was rotated and the replacement **proven by opening the re-encrypted archive with the new value**, not by a zero exit: *"`gpg` exiting 0 on an ENCRYPT is a claim. Opening the result with the new passphrase is evidence."* → `CM-0014` §rotation.
- **Steps 2–3 — inventory, then destroy.** Every copy swept and the old encrypted artifacts destroyed **only after** the new value verified (the `CM-0010` create-without-a-destroy-step line). → `CM-0014`.
- **Step 4 — purge, done right.** `git filter-repo --invert-paths --path "Archive passphrase.txt"` on a **throwaway mirror clone** (never `git rm`). Blob `be76535…` confirmed unreachable: `git cat-file -e` → **`EXIT: 1`**; `rev-list --all --objects` → empty; `count-objects` → `garbage: 0`. → `CM-0014` §Closeout.
- **Step 6 — verify from a FRESH `--mirror` clone of GitHub.** `EXIT: 1`, no log entries, no matching objects — *"a server-side check that local objects cannot fake."* → `CM-0014` §Closeout.
- **Step 7 — enforce, tested against the real leak.** The gitleaks pre-commit hook installed **and proven to block a commit** — and the finding that matters: 🔴 **the default ruleset did NOT catch it** (*"scanned ~25 bytes… no leaks found"* — a bare high-entropy string has no shape); a **name-based** rule blocked it. → `CM-0014` §finding + `.gitleaks.toml`.
- **Gap / what this closed.** A live credential to the whole PKI sitting in Git history → rotated (now a dead string), purged, and verified gone from a fresh clone, with publication gated on it (`ADR-0010`). The history rewrite means `ac2182f` no longer resolves — *that is correct and intended* (`ADR-0012`); don't "fix" the citations by restoring history.

## Related

- **Decisions / owners:** `POL-0002` (Secrets-and-Credentials — the rule) · `ADR-0010` (Atlas repository publication preconditions — purge-before-public) · `POL-0009` (Incident Response) · `Security-Program/Incident-Response-Playbook.md`.
- **Concepts:** `../Concepts/README.md` (the repository is a production system; `git push` is a change to a system you don't own; a blob is not a file).
- **Sibling playbooks:** `Rotate-a-Leaked-Key-Before-You-Back-It-Up.md` (rotate-before-backup, the CA-key twin) · `Purge-a-Secret-Shaped-File-from-the-Backup-Directory.md` (`CM-0019`, the co-located env file) · `Make-a-Control-Survive-a-git-clone.md` (`CM-0020`, the hook that lived on one laptop) · `Choose-a-Passphrase-That-Survives-Recovery.md` (the tool-breaking-chars lesson) · `Confirm-a-Config-Change-Actually-Took.md` (prove the rotation took).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).
- **Real lineage:** frozen Lab-01 `Change-Management/CM-0014` (the archive passphrase committed by `ac2182f`; rotate → inventory → destroy → filter-repo → force-push → verify-from-fresh-clone → name-based scanner tested on the real file) · `CM-0010` (the create-step-without-a-destroy-step pattern) · `CM-0019`/`CM-0020` (the twins) — `ADR-0022`-reconciled.

## Worked log

| Date | Who | Time | Secret class | Rotated? | Purge verified from fresh clone? | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-08-02 | **Format-alignment (audit register row 3):** added the **On this page** quick-nav and a dedicated **Worked example → `CM-0014`** section quoting the frozen read-backs (the fresh-clone `EXIT: 1`, the `count-objects garbage: 0`, and the gitleaks default-missed-it / name-rule-blocked finding) — **never reproducing the secret** (`POL-0002`). DOCS-ONLY complete. |
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the new **Symptoms & search terms** element `#32`). The estate's committed-secret incident response, rotate-first: rotate + verify the replacement → inventory every copy → destroy the old → `git filter-repo` purge → force-push + GitHub Support GC → **verify from a fresh mirror clone** → mechanical enforcement (gitleaks name-based rule tested against the real leak). Carries the core lessons: a blob is not a file, `git rm`/force-push don't delete it from GitHub, a private portfolio repo is one click from public (`ADR-0010`), never `git add .`. Grounded in the frozen Lab-01 `CM-0014` (`ac2182f`) — `ADR-0022`-reconciled. Never reproduces a secret value (`POL-0002`). 🟡 until worked. |
