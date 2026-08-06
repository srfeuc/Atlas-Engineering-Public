# What a Batch Is

*The short version, in plain English.*

---

## The idea

A **batch** is just **a zip file full of finished documents.**

You drop the zip on the placement tool, and it puts each document in the right folder
for you.

That's it. That's the whole thing.

---

## Why bother?

Because your repo has a lot of folders:

```
Labs/Lab-01-Mikrotik-Core\
    Architecture\
    Standards\
    Build-Guides\
    Build-Records\
    Operations\
    Change-Management\
```

Six folders in one book. Nine more books. Filing things by hand is how a document ends
up in the wrong place — and a document in the wrong place is a document nobody finds.

The tool never gets it wrong, never gets bored, and never overwrites something without
keeping a copy first.

---

## The one rule you need

> **The name of the file decides where it goes.**

Nothing else. No settings, no config, no list to maintain.

The tool looks at what's already in your repo and copies the pattern. It sees that
`045`, `046`, and `047` all live in `Operations\`, so it knows `048` goes there too.

**Get the name right and the file files itself.**

---

## The simplest example there is

You've written one new document. It's the next Operations guide.

### 1. Look at what's already there

Open `Labs/Lab-01-Mikrotik-Core\Operations\` and look at the last few:

```
045-SW01-CIS-Hardening-Checklist.md
046-Pi01-CIS-Hardening-Checklist.md
047-FGT01-CIS-Hardening-Checklist.md
```

The next number is **048**. Follow the same shape.

### 2. Name your file

```
048-Network-Backup-and-Restore.md
```

### 3. Zip it

Right-click the file → **Send to** → **Compressed (zipped) folder**.

That's a batch. One file in it. Still a batch.

### 4. Ask the tool what it would do

```powershell
.\Tools\Place-AtlasFiles.ps1 -Source ~\Downloads\048-Network-Backup-and-Restore.zip
```

**This writes nothing.** It just tells you what it *would* do:

```
[ new] .\Labs/Lab-01-Mikrotik-Core\Operations\048-Network-Backup-and-Restore.md
       why:  extends the sequence after 047
```

Read that `why:` line. It's the tool explaining itself. If it says something you didn't
expect, **your filename is wrong** — not the tool.

### 5. If it looks right, do it for real

```powershell
.\Tools\Place-AtlasFiles.ps1 -Source ~\Downloads\048-Network-Backup-and-Restore.zip -Apply
```

`-Apply` is the "actually do it" switch. Done.

---

## Updating a document you already have

Even easier. **Give the file the exact name it already has.**

Want to fix `033-Pi01-FreeRADIUS-Build-Guide.md`? Edit it, keep the name, zip it, run the
tool. It recognises the name, **saves a copy of the old version** into `99-Archive\`, and
puts your new one in.

The old version is never gone. It's just moved out of the way.

---

## The three things it prints

| You see | It means |
|---|---|
| `[ new]` | This file doesn't exist yet. It'll be added. |
| `[chg ]` | This file exists. It'll be replaced — **and backed up first.** |
| `[same]` | This file is already identical. Nothing to do. |

On `[chg ]` it also shows a line count, like `(OVERWRITE: 496 lines -> 494 lines)`.

**Glance at that number.** `496 -> 494` is a normal edit. `496 -> 12` means you zipped the
wrong file, and you just caught it before it ate a 500-line document.

---

## When it stops and refuses

Sometimes it prints `[FAIL]` and writes **nothing at all** — not even the files that were
fine.

That's on purpose. It means it wasn't sure, and **it would rather stop than guess.**

Two common reasons:

**"AMBIGUOUS: 047 lives here but 049 lives there."**
Your number sits between two files that live in different folders, so there's no obvious
answer. Pick a different number, or move the file yourself.

**"'README.md' exists in several packs."**
You have eleven README files, one per book. The name alone can't say which one you mean.
Copy it in by hand.

---

## Two things to never put in a batch

**Secrets.** No passwords, no keys, no certificates. If a document needs to mention a
password, it says *where the password is stored* — not what it is.

**Anything you haven't read.** The tool checks *where* a file goes. It has no idea whether
what's *inside* it is true. A wrong document gets filed perfectly.

---

## That's genuinely all of it

1. Name the file to match its neighbours
2. Zip it
3. Run the tool with no switches — see what it would do
4. Run it again with `-Apply` — let it happen

If something looks off at step 3, nothing has happened yet. **You can always just not
run step 4.**
