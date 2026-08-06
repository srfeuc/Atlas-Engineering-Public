# Atlas — Placement Cheat Sheet

The commands. Nothing else.

---

## The loop

```powershell
cd C:\Users\Seth\Atlas\Atlas-Engineering-Repository

# 1. Tree must be clean. The tool refuses a dirty tree.
git status --short

# 2. Dry run. Writes nothing.
.\Tools\Place-AtlasFiles.ps1 -Source C:\Users\Seth\Downloads\<batch>.zip

# 3. Apply.
.\Tools\Place-AtlasFiles.ps1 -Source C:\Users\Seth\Downloads\<batch>.zip -Apply

# 4. Verify (see below — this is the step people skip)

# 5. Commit and push.
git add -A
git commit -m "<what changed>"
git push
```

A single file works as `-Source` too:

```powershell
.\Tools\Place-AtlasFiles.ps1 -Source C:\Users\Seth\Downloads\ADR-0012-Something.md -Apply
```

---

## 🔴 Step 4 — verify the content, not the header

**The tool tells you what it did. `git` tells you it committed. Neither reads the file.**

Grep for a phrase that **only exists in the new version**:

```powershell
Select-String -Path .\<path>\<file>.md -Pattern "<phrase only in the new version>"
```

**Must hit.** If it doesn't, the file didn't land — regardless of what the tool or `git` said.

**Do not** verify with `Get-Content -TotalCount 1`. The first line rarely changes, so it proves nothing.

---

## Reading the output

| Line | Meaning |
|---|---|
| `[ new]` | Didn't exist. Created. |
| `[chg ]` | Existed. **Overwritten**, old version saved to `99-Archive\replaced\<timestamp>\` |
| `[same]` | **Identical — skipped.** ⚠️ If you expected a change, **you fed it the wrong file.** |
| `[FAIL]` | Refused. It won't guess. Read the reason. |

### `[same]` when you expected `[chg ]`

Windows saves re-downloads as `Foo_1.md`. You placed the *old* one.

```powershell
Get-ChildItem C:\Users\Seth\Downloads\<name>*
```

Newest / largest is the one you want. Point at it by its real name — the tool strips the `_1` itself:

```powershell
.\Tools\Place-AtlasFiles.ps1 -Source "C:\Users\Seth\Downloads\Foo_1.md" -Apply
```

### `AMBIGUOUS: 'README.md' exists in several packs`

Correct behaviour. `README.md` is per-directory — one README per pack is correct design, so the name alone cannot place it.

```powershell
Copy-Item C:\Users\Seth\Downloads\README.md .\07-Backup-and-Recovery\README.md -Force
Get-Content .\07-Backup-and-Recovery\README.md -TotalCount 1    # confirm it's the right one
```

**One explicit copy. No rename, no move through the repo root.**

### `AMBIGUOUS: no other Book N document exists`

The first numbered file in a new book. The tool has nothing to learn from. Place by hand, once — after that it self-resolves.

### `Contested document numbers` (the 001–014 block)

Book 1 and Book 2 both use `001`–`014`. Those numbers can't place anything.

**Harmless for everything you're doing now.** It goes away when Book 2 is renumbered to `201`–`214`.

---

## The tree must be clean

```powershell
git status --short     # empty = go
```

Not empty? Commit or stash first. `-AllowDirty` exists but don't — you won't be able to tell what the tool changed from what you already had.

---

## After editing the script

```powershell
[void][ScriptBlock]::Create((Get-Content .\Tools\Place-AtlasFiles.ps1 -Raw))
```

**Silence = it parses.** An error names the line.

---

## Nothing is ever destroyed

Every overwrite is copied to `99-Archive\replaced\<timestamp>\` before it's replaced, and logged to `99-Archive\placement-log.md`.

Undo an overwrite:

```powershell
Copy-Item .\99-Archive\replaced\<timestamp>\<full\path\file.md> .\<full\path\file.md> -Force
```

Undo everything since the last commit:

```powershell
git checkout -- .
```

---

## Rules

1. **Everything goes through the tool.** Four documents were lost this project by being placed — or not placed — by hand. `044`'s rewrite, `044` v2.0, `049` v1.0, and a hand-copied file that overwrote nothing. **The tool only protects files that go through it.**
2. **Verify with `Select-String`, not with a header.** Check the thing that would be different if you were wrong.
3. **Never commit before the verify hits.**
4. **`[same]` is a warning, not a success.**
