---
Title: Windows Logon Scripts & Network Drive Mapping
Path: Atlas-Academy/Concepts
Status: 🟢 Full module (D6 Academy / `ADR-0032` concept layer). Taught through the operator's real `BATlogin.txt` (preserved at `examples/BATlogin.bat`). Anchored to **FS01**.
Version: 1.0
Date: 2026-07-29
---

# Windows Logon Scripts & Network Drive Mapping

<!-- provenance -->
> **Book 9 — Atlas Academy.** The third kind of doc: *why it works and how it fits.* Format: **The Concept · The Atlas Example · What Went Wrong · How to Explain This in an Interview.** Real artifact: the operator's **`BATlogin.txt`** (a classic `net use` logon script), preserved verbatim at **`examples/BATlogin.bat`** and dissected below. Anchor host: **FS01** (`Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services/`).

## The Concept

A **logon script** runs in the *user's* security context at sign-in and connects network shares to drive letters with **`net use`**. For decades this is how enterprises gave every employee the same lettered drives — a department share on `P:`, a scans folder on `S:`, and the user's own private home folder on `U:` — without touching each machine by hand.

The mechanics that matter:

- **`net use <letter>: \\server\share`** maps a UNC path to a drive letter. **`/d`** (delete) unmaps it. **`/persistent:yes|no`** decides whether the mapping reconnects at the next logon.
- **`%username%`** is the environment variable for the signed-in account. One line — `\\server\users\%username%` — gives *every* user *their own* home folder, because the variable expands per user at run time.
- **Deployment:** the `.bat`/`.cmd` lives in the domain's **`NETLOGON`** share and is attached to the user's AD **Logon Script** attribute (or pushed by a logon GPO), so it runs for everyone in scope.

**The modern replacement — know both.** Active Directory now prefers **Group Policy Preferences → Drive Maps**: each drive is a declarative GPO item with **item-level targeting** (map `P:` only to members of `RES-Accounting`, etc.). It needs no scripting, is easier to target, and recreates cleanly each logon. But `net use` logon scripts are *still everywhere in the field* — inherited environments, small shops, quick fixes — so you keep this in your head even after you deploy GPP.

## The Atlas Example — the operator's `BATlogin.txt`

The real script (`examples/BATlogin.bat`):

```bat
@ECHO OFF
net use n: /d
net use n: \\server1\common
net use p: /d
net use p: \\Server2\Accounting
net use s: /d
net use s: \\server1\Scans
net use u: /d
net use U: \\server2\users\%username% /persistent:yes
```

Line by line, mapped onto Atlas:

| Line | What it does | In Atlas |
|---|---|---|
| `@ECHO OFF` | Suppresses command echo so the user doesn't watch each line scroll by. | Cosmetic, but standard. |
| `net use n: /d` → `net use n: \\server1\common` | **Delete-first, then map** `N:` to the *Common* share. | A shared "everyone" area on **FS01**; read/write governed by an **AGDLP** group, not per-user ACLs (see `Tiered-Admin-Model`). |
| `net use p: /d` → `net use p: \\Server2\Accounting` | Maps `P:` to a **departmental** share. | Access = one AGDLP group (e.g. `RES-Accounting-Modify`). This is the textbook "only Finance sees `P:`" case for **item-level targeting** under GPP. |
| `net use s: /d` → `net use s: \\server1\Scans` | Maps `S:` to a **scanner drop** folder. | A multifunction-printer scan target on FS01. |
| `net use u: /d` → `net use U: \\server2\users\%username% /persistent:yes` | The **home-drive pattern** — each user's *private* folder by username, set persistent so it survives logoff. | The AD user's **home folder**; in Atlas the path is a **DFS namespace** (`\\atlas.lab\users\%username%`) so the letter follows the data if the server is ever replaced. |

**Where "server1 / server2" actually live:** in Atlas these collapse onto **FS01** — the SMB + DFS file server (`Devices/FS01-File-Services/`). The `\\server1\...` UNC becomes a **DFS namespace** path (`\\atlas.lab\...`) so a drive letter is bound to *data*, not to a physical box. Atlas will **deploy these as GPP Drive Maps** (the GPO "A3 depth" work), keeping this `.bat` preserved here as the "know the old way" reference.

## What Went Wrong — the gotchas (this is the teaching)

- **Why the `/d` before every map.** Without delete-first, a stale mapping on the same letter throws `System error 85 — the local device name is already in use`, and the script half-fails silently. The delete-first pattern in this script is deliberate defensive scripting.
- **`/persistent:yes` bites back.** Persistent maps reconnect with *cached* state; a renamed share or an offline server leaves a red-X "disconnected" drive and **slow logons** while Windows retries. Rule of thumb: persistent only for the *stable* home drive; make volatile/departmental drives **non-persistent** (or GPP, which recreates them each logon).
- **A mapped drive is not a permission.** The script runs as the *user*, so the map succeeds with the user's rights — but whether they can *open* anything is still decided by **share + NTFS (AGDLP)**. Mapping `P:` for everyone does not grant Accounting access; the group membership does.
- **Hardcoded `\\server1` is a landmine.** When the box is replaced, every script and every user's muscle memory breaks. A **DFS namespace** decouples the letter from the server — the reason Atlas maps `\\atlas.lab\...`, not `\\FS01\...`.
- **Drive-letter collisions.** A USB stick or an old persistent map can already own `U:`; again, the `/d` guards it.
- **Context matters.** Logon scripts run as the user, so `%username%` resolves. The same command run from a **SYSTEM**-context tool won't have `%username%` — a classic "works at logon, fails in a scheduled task" surprise.

## How to Explain This in an Interview

> "A logon script maps network drives at sign-in with `net use` — you point a drive letter at a UNC share, and `%username%` lets one line give every user their own home folder. You delete the letter first so a stale mapping doesn't error out, and you're careful with persistent maps because a dead server turns into slow logons and red-X drives. In a modern AD I'd deploy these as Group Policy Preferences Drive Maps with item-level targeting instead of a batch file — declarative, per-group, no scripting — and I'd map to a DFS namespace rather than a specific server so the drive letter follows the data. But I still know the `net use` script cold, because you inherit them constantly in the field."

## Related
- **`Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services/`** — the file server that hosts these shares (SMB + DFS).
- `Concepts/Tiered-Admin-Model.md` — AGDLP, the group model that actually governs who can open each mapped drive.
- GPO "A3 depth" (GPP Drive Maps) in `Service-Server-Build-Plan.md` / the DC GPO build — the modern deployment of exactly this.
- `Windows-Infrastructure/303-Windows-Design-Standards.md` — where file-services + drive-mapping standards land.
- Source artifact: **`examples/BATlogin.bat`** (operator-provided, 2026-07-29).
