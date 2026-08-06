# Tools — Making a Batch

A **batch** is a zip of finished Atlas documents. You hand it to `Place-AtlasFiles.ps1`,
which works out where each file belongs and puts it there.

**The filename is the placement instruction.** There is no manifest, no config, no map to
maintain. The tool reads the repo, sees where `045` and `047` already live, and knows that
`046` goes with them. Name the file correctly and it files itself.

Name it wrong and the tool stops and tells you. It will never guess.

---

## 1. The simplest possible batch

One file. You've written a new operations guide and it's the next in the sequence.

**Step 1 — name it.** Look at what's already there:

```
Labs/Lab-01-Mikrotik-Core/Operations/
    045-SW01-CIS-Hardening-Checklist.md
    046-Pi01-CIS-Hardening-Checklist.md
    047-FGT01-CIS-Hardening-Checklist.md
```

So the next one is `048`. Follow the shape: `NNN-Subject-Document-Type.md`

```
048-Network-Backup-and-Restore.md
```

**Step 2 — zip it.**

```powershell
Compress-Archive -Path 048-Network-Backup-and-Restore.md `
                 -DestinationPath ~\Downloads\Atlas-Backup-Runbook-Batch.zip
```

**Step 3 — dry run.** This writes nothing.

```powershell
.\Tools\Place-AtlasFiles.ps1 -Source ~\Downloads\Atlas-Backup-Runbook-Batch.zip
```

```
[ new] .\Labs/Lab-01-Mikrotik-Core\Operations\048-Network-Backup-and-Restore.md
       why:  extends the sequence after 047
```

That `why:` line is the tool showing its working. **Read it.** If the reason doesn't match
your intent, the name is wrong — not the tool.

**Step 4 — apply.**

```powershell
.\Tools\Place-AtlasFiles.ps1 -Source ~\Downloads\Atlas-Backup-Runbook-Batch.zip -Apply
```

That's the whole loop. Everything below is just more of the same.

---

## 2. How names map to places

| Name pattern | Where it lands | Learned from |
|---|---|---|
| `048-Foo.md` | Whatever folder `047` and `049` are in | Its numeric neighbours |
| `ADR-0008-Foo.md` | `00-Atlas-Foundation/Decisions/` | Where `ADR-0007` lives |
| `CM-0009-Foo.md` | `Labs/Lab-01-Mikrotik-Core/Change-Management/` | Where `CM-0008` lives |
| `MC-0003-Foo.md` | Same | Where `MC-0002` lives |
| `Foo-Template.md` | `00-Atlas-Foundation/Templates/` | Where the other templates live |
| *An existing filename* | **Back where it came from** | It's already in the repo |

That last row is the important one. **To update a document, give the file its existing
name.** The tool recognises it, backs up the old version, and replaces it.

---

## 3. A realistic batch — several files, mixed new and updated

Say you closed a change record. Per Charter Rule 15, that means the Build Guide it
invalidated also had to be fixed. So the batch is:

```
CM-0009-Rotate-SW01-SNMP-to-v3.md        <- new change record
023-SW01-Build-Record.md                 <- updated: SNMP now v3
027-SW01-Build-Guide.md                  <- updated: Step 17 no longer teaches v2c
045-SW01-CIS-Hardening-Checklist.md      <- updated: SNMP item now closed
```

Put all four in one folder and zip the *contents*, not the folder:

```powershell
Compress-Archive -Path .\batch\* -DestinationPath ~\Downloads\Atlas-SW01-SNMP-Batch.zip
```

Dry run:

```
[ new] .\Labs/Lab-01-Mikrotik-Core\Change-Management\CM-0009-Rotate-SW01-SNMP-to-v3.md
       why:  change record
[chg ] .\Labs/Lab-01-Mikrotik-Core\Build-Records\023-SW01-Build-Record.md  (OVERWRITE: 128 lines -> 131 lines)
       why:  existing file
[chg ] .\Labs/Lab-01-Mikrotik-Core\Build-Guides\027-SW01-Build-Guide.md  (OVERWRITE: 496 lines -> 494 lines)
       why:  existing file
[chg ] .\Labs/Lab-01-Mikrotik-Core\Operations\045-SW01-CIS-Hardening-Checklist.md  (OVERWRITE: 83 lines -> 84 lines)
       why:  existing file
```

**Look at the line counts before you apply.** `496 -> 494` is a plausible edit. `496 -> 12`
means you grabbed a stub by mistake, and the dry run just saved you.

One batch, one commit, one coherent change. That's the shape to aim for.

---

## 4. The cases where it stops

### A number with no neighbours, or neighbours that disagree

```
[FAIL] 099-Something.md
       AMBIGUOUS: 047 lives in .\Labs/Lab-01-Mikrotik-Core\Operations but
                  101 lives in .\Labs/Lab-02-Cisco-Core/Virtualization\Build-Guides
```

The tool has no basis to choose, so it refuses. **Nothing in the batch is written** — not
even the files that resolved fine. Fix the name, or place that one file by hand, then re-run.

### `README.md`

```
[FAIL] README.md
       AMBIGUOUS: 'README.md' exists in several packs.
```

Every pack has one. The name alone cannot say which. **README files are always placed by hand.**

> ✅ **`PACK-MANIFEST.md` used to be in this category. It is not any more.**
>
> **The manifests were renamed on 2026-07-13** to `NETWORK-PACK-MANIFEST.md` and `VIRTUALIZATION-PACK-MANIFEST.md`. Unique names, so the tool places them like anything else — **with a backup, a `[chg ]` report, and a placement-log entry.**
>
> 🔴 **Why it mattered:** hand-copying bypasses every safety net the tool provides. Twice in one session, a `Copy-Item` grabbed a **stale download** (`PACK-MANIFEST.md` vs `PACK-MANIFEST_1.md`) — once overwriting **Book 1's manifest into Book 2's folder.** Recoverable only because everything was committed.
>
> **A name the tool cannot resolve is a name a human will eventually resolve wrongly.** The tool was right to refuse. **The bug was the name.**

### 🔴 `.ps1` files placed by hand need `Unblock-File`

A script downloaded from a browser carries **Mark of the Web**, and `RemoteSigned` execution policy refuses it:

```
File ... cannot be loaded. The file ... is not digitally signed.
```

**That error is misleading — it is not a code-signing problem.** Strip the mark:

```powershell
Unblock-File .\Tools\<script>.ps1
```

**Do not change the execution policy.** `Unblock-File` fixes the one file; `Set-ExecutionPolicy Bypass` disables the check for everything you ever download.

### A collision suffix

```
[chg ] .\...\CM-0001-SW01-Gi1-0-1-Description-Fix.md
       note: collision suffix stripped from 'CM-0001-SW01-Gi1-0-1-Description-Fix_1.md'
```

Your browser renamed a duplicate download. The tool strips the `_1` and tells you — but
**stop and check which copy you actually have.** This is exactly how a stale *Draft* `CM-0001`
ended up living next to the *Closed* one for weeks.

---

## 5. What not to put in a batch

- **Secrets.** No keys, no certificates, no `.conf` files with live shared secrets, no vault
  exports. A Build Guide never contains a value you'd actually type.
- **PDFs of licensed benchmarks.** CIS PDFs are not redistributable. Cite them by category
  and title; don't ship them.
- **Anything you haven't read.** The tool checks *where* a file goes. It cannot check whether
  the contents are true. Every defect found in Book 1 would have been placed perfectly.

---

## 6. Before you send a batch

- [ ] Every filename matches a pattern in section 2, or is deliberately hand-placed
- [ ] Updated files use their **exact existing name**
- [ ] New numbers are actually free — check the folder first
- [ ] No secrets, no licensed PDFs
- [ ] Working tree is committed (the tool refuses to run otherwise, and it's right to)
- [ ] Dry run read, including every `why:` line and every line-count delta

---

## 7. Reference

```powershell
# Dry run. Default. Writes nothing.
.\Tools\Place-AtlasFiles.ps1 -Source <zip-or-folder>

# Write. Backs up anything it overwrites to 99-Archive\replaced\<timestamp>\
.\Tools\Place-AtlasFiles.ps1 -Source <zip> -Apply

# Write, then stage and commit.
.\Tools\Place-AtlasFiles.ps1 -Source <zip> -Apply -Commit
```

Every run appends to `99-Archive/placement-log.md`: what was written, what it replaced, and
where the previous version went. **Nothing is ever destroyed silently.** That is the entire
reason this tool exists — the one it replaced overwrote without a backup, and a rewrite of
`044` was lost that way without anyone noticing for weeks.
