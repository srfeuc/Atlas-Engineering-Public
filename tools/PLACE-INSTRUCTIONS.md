# Placing the Tier-3 batch

Two files:
- `atlas-tier3-batch-2026-07-15.zip` — the 9 corrected documents, at their real repo paths.
- `Place-Tier3-Batch.ps1` — the placement script (wraps your `Tools\Place-AtlasFiles.ps1`).

Put the **zip in Downloads**. Put the **script in the repo root** (or anywhere; it takes the paths as arguments).

## Why a wrapper and not just the tool

Seven of the nine files place cleanly through `Place-AtlasFiles.ps1`. Two are `README.md`
(the Change-Management index and the Book 1 landing page). Your tool **refuses `README.md`
by design** — and one `[FAIL]` aborts the *entire* batch, so if the READMEs went in the zip
they'd take the other seven down with them. The wrapper feeds the seven to the tool and
hand-places the two READMEs (with a backup) exactly as `PLACEMENT-CHEATSHEET.md` prescribes.

It also enforces the step people skip: it `Select-String`-verifies a phrase that exists only
in the **new** version of all nine files, and **refuses to commit if any verify misses**.

## Run it

```powershell
cd C:\Users\Seth\Atlas\Atlas-Engineering-Repository
Unblock-File .\Place-Tier3-Batch.ps1          # it was downloaded — strip Mark of the Web

# 1. DRY RUN — writes nothing. Read the plan and the two README previews.
.\Place-Tier3-Batch.ps1 -BatchZip C:\Users\Seth\Downloads\atlas-tier3-batch-2026-07-15.zip

# 2. PLACE + VERIFY, staged but not committed (review the diff yourself):
.\Place-Tier3-Batch.ps1 -BatchZip C:\Users\Seth\Downloads\atlas-tier3-batch-2026-07-15.zip -Apply
git diff --cached
git commit -m "..."   ;  git push

# — or do it all at once:
.\Place-Tier3-Batch.ps1 -BatchZip C:\Users\Seth\Downloads\atlas-tier3-batch-2026-07-15.zip -Push
```

The tree must be clean first (`git status --short` empty) — the script and the tool both
refuse a dirty tree, and they are right to.

## What you should see

- Tool plan: seven `[chg ]` lines (021, 023, 024, 029, 001, 020, Build-Order), each `why: existing file`.
- README preview: two `[chg ]` lines with line-count deltas.
- Verification: nine `[ ok ]` lines. If any is `[FAIL]`, **nothing is committed** — run
  `git checkout -- .` to undo and tell me which one missed.

## If verify fails

Nothing was committed. `git checkout -- .` restores everything (all nine are overwrites of
tracked files). The tool's backups also sit in `99-Archive\replaced\<timestamp>\`.

## You do NOT need to upload anything else to me

The script runs on your machine against your local repo. You only need the two files above.
If you'd already applied the earlier Chunk-1 zip (024, 029), those two will simply show
`[chg ]` again (the consolidated versions differ slightly) — harmless; the tool backs them up.
