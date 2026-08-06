---
Title: Root CA and Credential Backup Runbook
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# 049 — Root CA and Credential Backup Runbook

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| **Evidence Status** | **`Verified` — every command below was executed on the live device on 2026-07-13 and its real output recorded.** This is not a plan. It is a transcript with explanations. |
| Version | 2.0 |
| Last Verified | 2026-07-13 |
| Applies To | Pi01 — Lab CA, Vaultwarden, Pi-hole, FreeRADIUS |
| Related | `CM-0010` (the rotation this ran alongside), `031`, `034`, `043`, `048` |

> **Version 1.0 of this page was written before the work was done. It was wrong in four places.** Every one of those errors is preserved below under *"What Went Wrong When We Ran This"* — because the corrections are the most valuable content on the page, and a runbook that hides its own failures will let you repeat them.

---

## 🔴 OPEN — This Backup Is Not Finished

**Executed 2026-07-13: the archive exists, and it has been fully restore-tested. But both copies are in the same room.**

| Copy | Location | Survives |
|---|---|---|
| `~/atlas-backup/` on Pi01 | The desk | Nothing. It is *on* the machine it protects. |
| `E:\` on the workstation | **The same room** | A dead SSD. **Not a fire, a flood, or a theft.** |
| **Off-site** | ❌ **DOES NOT EXIST** | — |

**Two copies in one room is redundancy, not a backup.** The single event this entire exercise exists to survive — losing that room — is still unsurvivable.

**Phase 5 is the whole point. It is ten minutes. Do it.**

---

## What You Are Actually Protecting

Five things live on one Raspberry Pi. **Four of them cannot be rebuilt.**

| Thing | Where | If lost |
|---|---|---|
| **Root CA private key** | `/etc/ssl/lab-ca/root/private/root-ca.key` | **Unrecoverable.** Every certificate in the lab becomes untrustable. Every device reissued, every trust store re-imported by hand. |
| **Intermediate CA private key** | `/etc/ssl/lab-ca/intermediate/private/intermediate-ca.key` | Same. This is the key that signs day-to-day certificates. |
| **CA database** | `index.txt`, `serial`, `crlnumber`, `openssl.cnf` | **A CA without these cannot issue or revoke.** A key alone is not a CA. |
| **Vaultwarden vault** | `~/vaultwarden/data/` | Every RADIUS secret, every device credential, both CA passphrases. |
| **Config** | `pihole.toml`, `clients.conf`, nginx site | Rebuildable, but hours of work you have already done once. |

That Pi had an **unexplained hard hang** requiring a physical power cycle. Root cause never found.

---

## 🔴 The Circular Dependency — Read This Before Anything Else

This is the single idea the whole runbook is built around.

```
Root CA key  --encrypted by-->  a passphrase
                                     |
                                stored in Vaultwarden
                                     |
                                running on Pi01
                                     |
                            ...which is the thing that dies.
```

**Copying the CA and the vault onto the same USB stick does not break this loop. It just moves it.**

To read the passphrase back out of a restored Vaultwarden you need: a working Docker host, the right image, the data volume restored correctly, a container that starts, and your master password. **Five dependencies, at the worst moment of the year, possibly on a borrowed laptop.**

**The loop is broken by one thing that depends on nothing: paper.**

That is not a lab shortcut. It is what commercial PKI does — a key ceremony ends with passphrases in a sealed envelope in a safe, precisely because *every electronic store is another dependency.*

> **Vaultwarden is a convenience store, not a recovery store.** In the disaster this backup exists for, Vaultwarden is the thing that died.

---

## 🔴 Ordering — Rotate Before You Back Up

**If a passphrase is exposed, rotate it BEFORE taking the backup. Never the other way round.**

| On Pi01 | On removable media, off-site |
|---|---|
| The passphrase is **defense in depth.** The key file is `0600`, root-owned, in a `0700` directory. | The passphrase is **the only control that exists.** It is the sole thing between a lost bag and every certificate in the lab. |

**A passphrase's real job begins the moment the key leaves the building.** Back up first and you ship the Root CA key — wrapped in a compromised passphrase — to a second location, permanently, beyond recall.

This is not hypothetical. It is exactly the defect in `pi01-full-backup-2026-07-12.tar.gz`. See `CM-0010`.

---

## Command Glossary

**Read this once and the rest of the page stops looking like magic.**

### `tar` — the archiver

`tar` bundles many files into one. It does **not** encrypt.

| Flag | Meaning |
|---|---|
| `-c` | **c**reate an archive |
| `-x` | e**x**tract an archive |
| `-t` | lis**t** contents — **reads it back without extracting. This is how you prove what's inside.** |
| `-z` | compress with g**z**ip |
| `-f <file>` | use this **f**ile |
| `-p` | **p**reserve permissions — **without this you restore a world-readable Root CA key** |
| `--numeric-owner` | store ownership as numbers, not names. Restores correctly on a fresh machine that has no `dnsadmin` user yet. |
| `-C <dir>` | **c**hange to this directory first |

**`-C /` matters more than it looks.** It makes paths *relative* (`etc/ssl/...` with no leading slash). On restore you then choose where they land — instead of them being forced back over your live system.

### `sudo` — run as root

The CA keys are root-only. **Without `sudo`, `tar` silently skips what it cannot read.** Same failure family as the `cat | sudo tee` bug that put a keyless certificate into production (`031`, `043` Part 6): the command succeeds, the output is incomplete.

### `gpg --symmetric` — encryption by passphrase

`--symmetric` means **passphrase only**, no key pairs. Produces a `.gpg` file. `--decrypt` reverses it.

### `sha256sum` — a fingerprint

Produces a hash of a file's contents. If one byte changes, the hash changes completely. **This is how you prove a file survived a copy intact.** `sha256sum -c <file>.sha256` checks a file against a saved fingerprint.

### `shred -u` — delete properly

Overwrites the file's contents, *then* deletes it. `-u` = remove after overwriting. Plain `rm` only unlinks — the data stays on disk. **Use `shred` for anything holding a key or a secret.**

### `docker`

| Command | Meaning |
|---|---|
| `docker stop <name>` | stop a container gracefully |
| `docker start <name>` | start it again |
| `docker ps` | list running containers. `-a` includes stopped ones. |
| `docker run -d` | create and start a new container, **d**etached |
| `-v <host path>:/data` | mount a host folder into the container |
| `-p 127.0.0.1:8223:80` | publish container port 80 on the host's loopback port 8223 |
| `-e NAME="value"` | set an environment variable |
| `docker rm -f <name>` | force-remove a container |

---

# Phase 0 — Prove What You Have

**Read-only. Nothing is written, deleted, or changed. Run this before you buy media, before you plug anything in.**

## 0.1 Does the recorded passphrase actually open the live key?

**This had never been tested.** `043` Part 9 verified the passphrase *at the moment of rotation*, then stored it in Vaultwarden. **The stored value had never been read back out and used.** A transcription error, a truncated paste, a trailing space — all invisible, all fatal, all discovered at the worst possible moment.

Open Vaultwarden. **Copy the passphrase from there** — not from memory, not from a note. That is the point of the test.

```bash
sudo openssl rsa -in /etc/ssl/lab-ca/root/private/root-ca.key -noout -check
```

- `openssl rsa` — work with an RSA key
- `-in <file>` — read this key
- `-noout` — don't print the key itself to the screen
- `-check` — verify the key's internal mathematical consistency

To read the key at all, OpenSSL must first *decrypt* it — so it prompts for the passphrase. **A wrong passphrase cannot produce `RSA key ok`.**

**Expected:** `RSA key ok`
**Actual, 2026-07-13:** `RSA key ok` ✅

## 0.2 Same test — Intermediate key

```bash
sudo openssl rsa -in /etc/ssl/lab-ca/intermediate/private/intermediate-ca.key -noout -check
```

**Actual, 2026-07-13:** `RSA key ok` ✅

> 🔴 **If either fails, STOP. That is an incident, not a backup task.**
>
> The only recorded copy of the passphrase does not open the key. The key on disk is still good — *something* opens it — but the recorded value is wrong and the correct one exists nowhere. **Do not reboot Pi01. Do not let it lose power.** The window to recover is exactly as long as that key file survives. Raise a change record.

## 0.3 🔴 List the private directories BEFORE you archive them

**This single command found the most serious problem of the night.**

```bash
sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/
```

**Expected:** exactly **one** `.key` file per directory, mode `0600`.

**Actual, 2026-07-13:**

```text
-rw------- 1 root root 3446 Jul 13 13:28 root-ca.key
-r-------- 1 root root 3446 Jul 12 22:12 root-ca.key.bak-2026-07-12          <-- !!
-rw------- 1 root root 3446 Jul 13 13:31 intermediate-ca.key
-r-------- 1 root root 3446 Jul 12 22:13 intermediate-ca.key.bak-2026-07-12  <-- !!
```

**Those `.bak` files are your CA private keys wrapped in the OLD, EXPOSED passphrase.** Created by `043` Part 9 step 1 — *"Backed up both key files first"* — and **never destroyed, because that procedure had no destroy step.**

**Phase 3 archives `/etc/ssl/lab-ca` whole.** Had we not run this `ls`, both files would have been tarred, encrypted, and **shipped off-site** — a CA key wrapped in a known-leaked passphrase, in a building you don't control, permanently.

**Anything that is not exactly one `0600` `.key` per directory is key material you are about to copy somewhere you cannot recall it from.** Destroy it first (after verifying the live key opens):

```bash
sudo shred -u /etc/ssl/lab-ca/root/private/root-ca.key.bak-<date>
sudo shred -u /etc/ssl/lab-ca/intermediate/private/intermediate-ca.key.bak-<date>
```

> **A key backup is a rollback with an expiry measured in minutes.** Create it, verify the replacement, destroy it. **Never leave it in the private directory.**

## 0.4 Check any existing backup for the same defect

```bash
tar -tzf E:\pi01-full-backup-<date>.tar.gz | findstr private     # Windows
```

**Actual, 2026-07-13:**

```text
etc/ssl/lab-ca/intermediate/private/intermediate-ca.key.bak-2026-07-12
etc/ssl/lab-ca/intermediate/private/intermediate-ca.key
etc/ssl/lab-ca/root/private/root-ca.key.bak-2026-07-12
etc/ssl/lab-ca/root/private/root-ca.key
```

**Four copies of the CA keys, all wrapped in the exposed passphrase, already off-device on `E:\`.** Shredding them on Pi01 had cleared only one of two locations.

> 🔴 **Do not destroy an old backup until the new one is proven.** However compromised, while it is the *only* thing that opens, it is the only recovery point that exists. **Never destroy the rollback before the replacement verifies.** Destroy it at Phase 6.

---

# Phase 1 — Paper

**Three values. Handwritten. Two copies.**

| # | Value | Also in Vaultwarden? |
|---|---|---|
| 1 | **Root CA passphrase** | ✅ Yes — vault is the *daily* copy, paper is the *recovery* copy |
| 2 | **Intermediate CA passphrase** | ✅ Yes — same |
| 3 | **Archive passphrase** (invent now, ASCII, 24+ chars) | 🔴 **NEVER** |

**Why 1 and 2 need paper even though they are in the vault:** walk the disaster. The SSD is dead, you have a USB stick. Opening the archive needs value 3 (paper ✅). Inside is the encrypted CA key — which needs value 1, **stored in the Vaultwarden database that is inside the archive you just opened.** Recoverable only via Docker + image + volume + container + master password. **Paper collapses five dependencies to zero.**

**Why value 3 must never go in Vaultwarden:** the archive *contains* Vaultwarden. Putting its passphrase inside the thing it protects rebuilds the exact loop you are breaking.

### Passphrase rules — learned the hard way

> 🔴 **ASCII only. No `£`, no `€`, no accents, no emoji.**
>
> OpenSSL reads a passphrase as **bytes**, not characters. Over a UTF-8 SSH session `£` is `0xC2 0xA3`. On a rescue initramfs, a legacy console, a KVM, or a US keymap it is a *different byte sequence* — or unreachable entirely.
>
> **The one moment you must type this is a bare-metal recovery on unfamiliar hardware** — the environment least likely to reproduce that byte. You could hold a perfect backup and a correct paper passphrase and still be locked out, permanently, by a currency symbol.
>
> **Length, not exotic characters.** 24+ ASCII characters beats 19 with a `£` in it.

> **Different passphrases for Root and Intermediate.** A shared passphrase silently collapses the two-tier design in `031` — the whole point of which is that a compromised Intermediate can be revoked and replaced *without touching the Root*.

### Write it so future-you can use it

```text
ATLAS LAB — CERTIFICATE AUTHORITY RECOVERY
Written 2026-07-13

Root CA passphrase:          <value 1>
Intermediate CA passphrase:  <value 2>
Backup archive passphrase:   <value 3>   [use: gpg --decrypt]

CA lives at:      /etc/ssl/lab-ca/
Vault data at:    ~/vaultwarden/data
Full procedure:   Atlas repo, 049-Root-CA-and-Credential-Backup-Runbook.md
Archive file:     atlas-pi01-<date>.tar.gz.gpg
```

**Six months from now, in an emergency, three unlabelled strings tell you nothing.**

- **Copy 1** — home. Not the desk the Pi sits on.
- **Copy 2** — 🔴 **off-site.** Different building.
- 🔴 **NEVER in the same container as the media.** Media plus passphrase in one envelope is not two factors. It is one envelope that owns your entire PKI.

### Decision you still owe

**The Vaultwarden master password exists only in your head.** The archive contains the vault; the vault is useless without it. The CA is now covered by paper — the rest of the vault is not.

A solo lab where the master password lives only in your head is a defensible choice. **But it should be a decision, not an oversight.** If the paper is already going into a safe and a sealed off-site envelope, the case for a fourth line is strong. Worth an ADR either way.

---

# Phase 2 — Confirm the Paths

**Do not trust the paths below — including from this document. Confirm each one.**

```bash
sudo find /etc/freeradius -name clients.conf
sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/
ls -la ~/vaultwarden/data
ls -la /etc/pihole/pihole.toml /etc/nginx/sites-available/vaultwarden
```

**Confirmed live, 2026-07-13:**

| Path | Note |
|---|---|
| `/etc/ssl/lab-ca/` | Whole tree — keys **and** `index.txt`, `serial`, `crlnumber`, `openssl.cnf`, `certs/` |
| `~/vaultwarden/data/` | = `/home/dnsadmin/vaultwarden/data` |
| `/etc/pihole/pihole.toml` | All local DNS. **Not `custom.list`** — inert on Pi-hole v6 (`043` Part 5) |
| **`/etc/freeradius/3.0/clients.conf`** | **The `3.0/` was not recorded in any Atlas document before this run.** Four RADIUS secrets, **plaintext** — this is why the archive gets encrypted. |
| `/etc/nginx/sites-available/vaultwarden` | The `8443` proxy. Pi-hole owns 443 on this host. |

**A CA restored without `index.txt` and `serial` cannot issue or revoke.** A key alone is not a CA. Confirm the whole tree, not just the keys.

## 🔴 The SQLite discovery — why Phase 3 stops the container

The `ls -la ~/vaultwarden/data` returned this:

```text
-rw-r--r-- 1 root root 278528 Jul 12 22:09 db.sqlite3
-rw-r--r-- 1 root root  32768 Jul 13 14:04 db.sqlite3-shm
-rw-r--r-- 1 root root 836392 Jul 13 14:04 db.sqlite3-wal
```

**Look at the dates.** `db.sqlite3` had not been modified since **22:09 the previous day**. The `-wal` file was **836 KB — three times the size of the database — and modified minutes ago.**

**Vaultwarden runs SQLite in WAL mode (Write-Ahead Log).** New writes go into `db.sqlite3-wal`, not into `db.sqlite3`. The main database is only updated at a *checkpoint*.

**The database is not one file. It is three.** Together they are the database. Individually they are fragments.

> 🔴 **Copy `db.sqlite3` alone and you restore a vault frozen at yesterday evening** — one that does not contain the passphrases you rotated today. **Which means the recorded passphrases would not open the CA in your own backup.**

**`docker stop` makes Vaultwarden close cleanly so the files are quiescent, and `tar` captures all three together.** That is the entire reason the stop is in the procedure.

> **Note — v1.0 of this page said the `-wal` file would disappear on stop. It did not, and that expectation was wrong.** SQLite removes it only when the last connection closes cleanly, and Docker's 10-second grace period often ends in `SIGKILL`. **It does not matter.** The rule is *capture all three files together with the writer stopped* — not *expect the WAL to vanish*. Phase 4 proves it worked.

---

# Phase 3 — Take the Archive

## 3.1 Capture the container's environment

```bash
mkdir -p ~/atlas-backup
TS=$(date +%Y-%m-%d)

docker inspect vaultwarden --format '{{range .Config.Env}}{{println .}}{{end}}' \
  > ~/atlas-backup/vaultwarden-container-env.txt
```

`TS` holds today's date so filenames are dated automatically — `$TS` expands to `2026-07-13`.

This captures `ADMIN_TOKEN` (an Argon2id **hash**, not the secret) and `DOMAIN`. **These exist nowhere but inside the running container.** You will need them to rebuild it — **including in Phase 4.**

## 3.2 🔴 Stop the container

```bash
docker stop vaultwarden
docker ps -a --filter name=vaultwarden
```

**Expected:** `Exited (0)` — exit code 0, a clean shutdown.
**Actual, 2026-07-13:** `Exited (0) 6 minutes ago` ✅

**Thirty seconds of downtime on a single-user lab vault costs nothing. Skipping it can cost the vault.**

## 3.3 Build the archive

```bash
sudo tar -czpf ~/atlas-backup/atlas-pi01-$TS.tar.gz \
  --numeric-owner \
  -C / \
  etc/ssl/lab-ca \
  etc/pihole/pihole.toml \
  etc/freeradius/3.0/clients.conf \
  etc/nginx/sites-available/vaultwarden \
  home/dnsadmin/vaultwarden/data \
  home/dnsadmin/atlas-backup/vaultwarden-container-env.txt
```

Every flag is explained in the glossary above. **`sudo`, `-p`, and `--numeric-owner` are not optional.**

## 3.4 Restart the vault — before anything else

```bash
docker start vaultwarden && docker ps
```

🔴 **Confirm it is back up.** A backup procedure that leaves the vault down is worse than no backup procedure.

## 3.5 🔴 Prove the archive is complete

**A `tar` that exits 0 is not evidence. Read it back.**

```bash
tar -tzf ~/atlas-backup/atlas-pi01-$TS.tar.gz | grep -E 'root-ca.key$|intermediate-ca.key$|db.sqlite3|pihole.toml|clients.conf'
```

**Actual, 2026-07-13:**

```text
etc/ssl/lab-ca/intermediate/private/intermediate-ca.key
etc/ssl/lab-ca/root/private/root-ca.key
etc/pihole/pihole.toml
etc/freeradius/3.0/clients.conf
home/dnsadmin/vaultwarden/data/db.sqlite3-wal
home/dnsadmin/vaultwarden/data/db.sqlite3-shm
home/dnsadmin/vaultwarden/data/db.sqlite3
```

✅ All five, **plus both SQLite sidecars**, **and no `.bak` anywhere.**

## 3.6 Checksum and encrypt

```bash
cd ~/atlas-backup
sudo chown dnsadmin:dnsadmin atlas-pi01-$TS.tar.gz
```

`tar` ran under `sudo`, so the archive is owned by `root`. Hand it back so `gpg` and `scp` work without `sudo` — and so the file you copy to a USB stick isn't root-owned.

```bash
sha256sum atlas-pi01-$TS.tar.gz > atlas-pi01-$TS.sha256

gpg --symmetric --cipher-algo AES256 atlas-pi01-$TS.tar.gz
```

**Archive passphrase — from the paper.** Typed twice.

**The archive holds plaintext RADIUS secrets and your entire PKI.** Unencrypted on a stick in a bag is total compromise of the lab to whoever finds the bag.

```bash
shred -u atlas-pi01-$TS.tar.gz
ls -la ~/atlas-backup/
```

**Expected:** `.tar.gz.gpg`, `.sha256`, and the env `.txt`. **No plaintext `.tar.gz`.**

## 3.7 Get it off the Pi immediately

**Until this runs, the backup is on the machine it protects. That is not a backup.**

```powershell
scp -P 2222 dnsadmin@10.10.0.5:~/atlas-backup/atlas-pi01-2026-07-13.tar.gz.gpg .
scp -P 2222 dnsadmin@10.10.0.5:~/atlas-backup/atlas-pi01-2026-07-13.sha256 .
```

`scp` = secure copy over SSH. `-P 2222` — SSH is on a non-standard port here. The trailing `.` = into the current directory.

**Then prove the copy is byte-identical:**

```powershell
Get-FileHash atlas-pi01-2026-07-13.tar.gz.gpg -Algorithm SHA256
```
```bash
sha256sum ~/atlas-backup/atlas-pi01-2026-07-13.tar.gz.gpg
```

**Actual, 2026-07-13:** `79b50d2c0adb1681…` on both. ✅ *(PowerShell prints uppercase — same hash.)*

---

# Phase 4 — Restore It

> **A backup you have not restored is a hope.** This phase is the entire point of the runbook. Everything before it was preparation.

> **Ideally run this on a machine that is NOT Pi01** — you are simulating *"the Pi is dead."* On 2026-07-13 it was run on Pi01 (the workstation lacked `gpg`/`openssl`). **That still proves the archive, the keys, and the vault — but it does not prove independence from the Pi.** Use WSL or Gpg4win next time.

## 4.1 Decrypt and verify integrity

```bash
gpg --decrypt atlas-pi01-2026-07-13.tar.gz.gpg > atlas-pi01-2026-07-13.tar.gz
sha256sum -c atlas-pi01-2026-07-13.sha256
```

🔴 **Archive passphrase from the PAPER — not from Vaultwarden.** That distinction is the whole test. In the scenario this exists for, Vaultwarden is on the dead SSD.

**Actual:** `atlas-pi01-2026-07-13.tar.gz: OK` ✅ — bytes survived encrypt → decrypt intact.

## 4.2 Extract into a sandbox

```bash
mkdir restore-test
tar -xzpf atlas-pi01-2026-07-13.tar.gz -C restore-test
```

**`-C restore-test` extracts *into that folder*, not over your live filesystem.** Because of `-C /` at creation, paths are relative — they land inside `restore-test/`, harmlessly.

## 4.3 🔴 Confirm the CA is *operable*, not just present

```bash
ls -la restore-test/etc/ssl/lab-ca/root/ restore-test/etc/ssl/lab-ca/intermediate/
```

**Expected in both:** `index.txt`, `serial`, `crlnumber`, `openssl.cnf`, `certs/`, `private/`.

**A key without the database and serial files restores a CA that cannot revoke or issue.** Confirmed present, 2026-07-13. ✅

> **Also found here: a third stray — `openssl.cnf.bak-2026-07-12`.** No key material, so not an exposure — but it is the *pre-fix* config, i.e. the one **without `copy_extensions`**. Someone restoring in a panic could copy the wrong file back and **silently reintroduce the SAN defect.** Third `.bak` from the same date. **This project creates `.bak` files during fixes and never removes them — that is a habit, not three accidents.** See `CM-0010`.

## 4.4 🔴 Open both keys with the paper passphrases

```bash
openssl rsa -in restore-test/etc/ssl/lab-ca/root/private/root-ca.key -noout -check
openssl rsa -in restore-test/etc/ssl/lab-ca/intermediate/private/intermediate-ca.key -noout -check
```

**Actual:** `RSA key ok` ×2 ✅

**This is the moment the file becomes a backup.**

## 4.5 Prove the vault opens — and that tonight's writes survived

**This is the WAL test. It is the one that could still have failed.**

```bash
gpg --decrypt atlas-pi01-2026-07-13.tar.gz.gpg > /tmp/restore.tar.gz
mkdir -p /tmp/vw-restore
tar -xzpf /tmp/restore.tar.gz -C /tmp/vw-restore home/dnsadmin/vaultwarden/data
```

*(Naming a path after the archive extracts only that path.)*

```bash
sudo apt install sqlite3 -y

sqlite3 /tmp/vw-restore/home/dnsadmin/vaultwarden/data/db.sqlite3 \
  "SELECT COUNT(*) FROM ciphers; SELECT COUNT(*) FROM users;"
```

**Actual:** `21` ciphers, `1` user ✅

**Then ask the database for its schema — do not guess column names:**

```bash
sqlite3 .../db.sqlite3 ".schema ciphers"
sqlite3 .../db.sqlite3 "SELECT datetime(updated_at) FROM ciphers ORDER BY updated_at DESC LIMIT 5;"
```

**Actual:**

```text
2026-07-13 18:04:52
2026-07-13 17:31:56
2026-07-13 17:31:45
2026-07-13 17:28:59
2026-07-13 17:28:17
```

🔴 **This is the proof.** SQLite stores UTC; `ls` shows local. The `17:28` rows land on the exact minute `root-ca.key` was rotated (13:28 local); the `17:31` rows on the minute `intermediate-ca.key` was (13:31). **Those rows *are* the new passphrases.**

**`db.sqlite3` on disk had not been written since 22:09 the previous day.** Every one of those rows lived **only in the WAL** when we archived it. **The WAL replayed. The vault in the backup is current.**

| Newest row | Meaning |
|---|---|
| **Today** | ✅ The WAL replayed. Backup is current. |
| **Yesterday or older** | 🔴 **The backup captured a stale vault. Re-run Phase 3.** |

## 4.6 🔴 Destroy the restore-test debris

**The restore test creates plaintext copies of everything. They are a new exposure.**

```bash
docker rm -f vw-restoretest
shred -u atlas-pi01-2026-07-13.tar.gz
shred -u /tmp/restore.tar.gz
rm -rf restore-test /tmp/vw-restore
ls -la ~/atlas-backup/
```

The extraction runs as your user, not root — so `restore-test/` holds a **readable copy of `clients.conf`**, with all four RADIUS secrets, plus an unencrypted vault database.

> **A restore test that leaves its own debris behind is a new exposure.** This step is mandatory, not tidy-up.

---

# Phase 5 — 🔴 Media (NOT DONE — 2026-07-13)

| Copy | Status |
|---|---|
| **Copy 1** — external drive, on-site, not in the desk the Pi sits on | ✅ `E:\` |
| **Copy 2** — 🔴 **OFF-SITE. Different building.** | ❌ **DOES NOT EXIST** |
| **Paper** — separate from **at least one** media copy | ✅ |

**Copy 2 is the copy that survives fire, theft, and flood — the events that take the Pi *and* the drive next to it.**

```powershell
Copy-Item E:\atlas-pi01-2026-07-13.tar.gz.gpg <USB>:\
Copy-Item E:\atlas-pi01-2026-07-13.sha256     <USB>:\

Get-FileHash <USB>:\atlas-pi01-2026-07-13.tar.gz.gpg -Algorithm SHA256
```

**Must return:** `79B50D2C0ADB1681BDF752ECC5CB27B7D8A369065298061FE0CA675929F09AAA`

**A copy you have not hash-checked is a copy you have not made.**

Both copies get the `.gpg` **and** the `.sha256`. A checksum you cannot find is a checksum you do not have.

🔴 **The paper does not travel with the stick.**

**Flash media degrades unpowered.** This is a point-in-time capture, not an archive. **Re-run after any CA change, any credential rotation, any new vault entry — and at minimum every 6 months.**

---

# Phase 6 — Close Out

- [x] Phase 0 passphrase round-trip — both keys `RSA key ok` from Vaultwarden-stored values
- [x] Two exposed `.bak` key copies found and destroyed (`CM-0010`)
- [x] Passphrases rotated to ASCII-only, separate values (`CM-0010`)
- [x] Archive built, contents verified by listing, encrypted, plaintext shredded
- [x] Copied to `E:\`, hash-matched byte-for-byte
- [x] **Restore-tested** — both keys opened with paper passphrases; CA operable; vault 21/1 with today's writes
- [x] Restore-test debris destroyed
- [ ] 🔴 **Phase 5 — off-site copy of the MEDIA.** *(Paper: ✅ two copies, one off-site — operator-confirmed 2026-07-14. **The encrypted archive itself still has no off-site copy. Both media copies are in the same room.** Roadmap Critical Risk #1.)*
- [x] 🔴 **Destroy `pi01-full-backup-2026-07-12.tar.gz`** — ✅ **CONFIRMED GONE 2026-07-14**, verified on `E:\` with the drive mounted. (`CM-0010`)
- [ ] 🔴 **Hunt the plaintext passphrase file** `043` Part 9 flagged on the desktop. **STILL NOT DONE.** 🔴 **The desktop is OneDrive-redirected — if that file was ever there, it SYNCED TO MICROSOFT, and a local delete did not touch the cloud recycle bin or version history.** The original search used `$env:USERPROFILE\Desktop`, **a different folder**, so its clean result **proved nothing**.
- [x] ✅ **ROTATION COMPLETE AND PROVEN 2026-07-14 (`CM-0014`).** 🔴 **The rotation this runbook assumed had happened had NEVER happened** — the archive was sealed with the leaked passphrase for a full day. **Both copies re-encrypted under a new Vaultwarden-generated value; the new archive OPENED to prove it; hash-matched byte-for-byte (`9e49f01f…95bc3`); both old copies destroyed.**
- [ ] Decide: does the Vaultwarden master password get a paper copy? (ADR)
- [x] `029-Pi01-Build-Record.md` — ✅ **corrected.** It now states the tarball was never a backup and no longer exists.
- [x] `07-Backup-and-Recovery/README.md` — ✅ **corrected.** 🔴 **But a STALE DUPLICATE survives at `Labs/Lab-01-Mikrotik-Core/Operations/07-Backup-and-Recovery-README.md`, which still calls the destroyed tarball *"the first real backup."* Two homes for one fact. DELETE IT — it was about to be published to Confluence as truth.**
- [ ] `Session-Handoff.md` open item 1 — **close it, with the restore-test result**

---

# What Went Wrong When We Ran This

**Recorded because a runbook that only shows the happy path will let you repeat every one of these.**

| # | What | Lesson |
|---|---|---|
| 1 | **`cd /etc/ssl/lab-ca/root/private` → `Permission denied`.** The dir is `0700 root`; the shell is not root. The `cd` failed, the shell stayed in `~`, and the next `sudo cp` ran **against the wrong path**. | **Use absolute paths. Never `cd` into the CA's private directories.** `sudo` elevates the *command*, not the shell that resolved the path. |
| 2 | **`shred` was run before the `cp` it depended on.** It failed with *"No such file"* — **only because the file didn't exist, not because anything protected it.** Had the `cp` succeeded, it would have destroyed a rollback before its replacement was verified. | `043` says *a command completing without an error is not a confirmed change*. **This is its twin: a command run out of order is not the command you meant to run.** Both look identical in a clean terminal. |
| 3 | **v1.0 predicted the WAL file would vanish on `docker stop`. It didn't.** | The rule is **capture all three SQLite files together with the writer stopped** — not *expect the WAL to vanish*. **Phase 4 settles it by observation.** |
| 4 | **The restore container was launched with a bare `docker run` and Vaultwarden refused: `Insecure URL not allowed`.** It defaults `DOMAIN` to `https://localhost` and enforces it. | **Restore the container with its captured environment (`-e DOMAIN=...`), not a bare `docker run`.** `vaultwarden-container-env.txt` exists for exactly this — and was ignored. |
| 5 | **A SQL query used `revision_date`. No such column.** | **Ask the database for its schema (`.schema ciphers`); don't recall it.** Same family as everything else here: **read the source, don't remember it.** |
| 6 | **Three `.bak` files from 2026-07-12** — two CA keys, one `openssl.cnf` — none recorded, none cleaned up. | **This project creates `.bak` files during fixes and never removes them.** A habit, not an accident. `ls` before you archive. |

> **Every one of these was caught by reading actual output instead of trusting that a command had worked.** That is the single lesson of this entire runbook, and it is the same one `043` learned five separate times in one night.

---

## Why This Is Hard (And Why AD CS Would Not Have Been Easier)

**Almost none of the difficulty here was OpenSSL.**

| What actually bit us | Is it an OpenSSL problem? |
|---|---|
| SQLite WAL semantics | ❌ No |
| Docker `DOMAIN` enforcement | ❌ No |
| `tar` permissions, ownership, relative paths | ❌ No |
| The circular dependency | ❌ **No — AD CS has this too** |
| Three uncleaned `.bak` files | ❌ No — a *process* defect |
| `openssl rsa -check` | ✅ Worked first time, every time |

**Backup engineering is tool-agnostic.** AD CS backup is `certutil -backup` **plus** a registry export **plus** AD state **plus** DPAPI — and restoring to different hardware is genuinely worse.

**And note what OpenSSL's supposed weakness bought you:** the CA is plain files on disk, so `ls` found two exposed key copies. **In AD CS the private key lives inside the OS key store — you cannot `ls` it. That exposure would have been invisible.**

Where AD CS genuinely wins is **issuance**: templates, auto-enrolment, every domain machine getting a certificate without you touching it. That is a real advantage and it is why **`ADR-0003` decided *coexist*, not *replace*.**

---

## Quick Reference — The 10-Minute Version

**Once. Then never from memory.**

```bash
# 0. PROVE — read-only
sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/   # one 0600 .key each, NO .bak
sudo openssl rsa -in /etc/ssl/lab-ca/root/private/root-ca.key -noout -check       # RSA key ok

# 3. TAKE
TS=$(date +%Y-%m-%d)
docker inspect vaultwarden --format '{{range .Config.Env}}{{println .}}{{end}}' > ~/atlas-backup/vaultwarden-container-env.txt
docker stop vaultwarden
sudo tar -czpf ~/atlas-backup/atlas-pi01-$TS.tar.gz --numeric-owner -C / \
  etc/ssl/lab-ca etc/pihole/pihole.toml etc/freeradius/3.0/clients.conf \
  etc/nginx/sites-available/vaultwarden home/dnsadmin/vaultwarden/data \
  home/dnsadmin/atlas-backup/vaultwarden-container-env.txt
docker start vaultwarden && docker ps
tar -tzf ~/atlas-backup/atlas-pi01-$TS.tar.gz | grep -E 'root-ca.key$|db.sqlite3|clients.conf'
cd ~/atlas-backup && sudo chown dnsadmin:dnsadmin atlas-pi01-$TS.tar.gz
sha256sum atlas-pi01-$TS.tar.gz > atlas-pi01-$TS.sha256
gpg --symmetric --cipher-algo AES256 atlas-pi01-$TS.tar.gz    # paper passphrase
shred -u atlas-pi01-$TS.tar.gz

# 4. PROVE IT OPENS — or it isn't a backup
# 5. OFF-SITE — or it isn't a backup either
```

## Related Pages

- `CM-0010` — the rotation and the exposed-key destruction this ran alongside
- `031-Pi01-Lab-CA-Build-Guide.md` — how the CA was built; **v0.5 carries the fixes found here**
- `034-Pi01-Vaultwarden-Build-Guide.md` — the vault, the `8443` port conflict
- `043-PKI-and-Credential-Security-Overhaul-Session-Summary.md` — **Part 9 is why Phase 0 exists**
- `048-Teardown-and-Rebuild-Runbook.md` — bare-metal rebuild; Phase 0 first
- `ADR-0003-AD-CS-vs-OpenSSL-Lab-CA.md` — the coexist decision

## Change Log

| Version | Changes |
|---|---|
| 2.0 | **Rewritten from execution, not from plan.** Every command carries its real output. Six execution errors recorded in full. New content that only emerged by running it: the SQLite **WAL** discovery (the vault's writes were not in `db.sqlite3`), the `/etc/freeradius/**3.0**/clients.conf` path (unrecorded anywhere in Atlas), Vaultwarden's `DOMAIN` enforcement on restore, the mandatory restore-test cleanup, and a **third** `.bak` file. Full command glossary added. **Phase 5 (off-site) flagged as NOT DONE.** |
| 1.0 | Written from the committed repo before execution. **Wrong in four places.** Superseded. |

## 🔴 CORRECTION 2026-07-14 — this runbook recorded a restore test that did not prove what it claimed

**Phase 4 was ticked: *"Restore-tested — both keys opened with paper passphrases; CA operable."*** **That tested the CA private keys INSIDE the archive. It did not test the ARCHIVE'S OWN passphrase — because the archive had never been rotated, and nobody checked.**

**The mtime told the truth all along:** the passphrase was committed at **14:09:41**; the archive was written at **14:16** and never rewritten. **A file that has been re-encrypted has a new mtime. This one did not.**

> 🔴 **A restore test that does not test the thing that changed is not a restore test. It is a test that cannot fail** — `016` lesson 4, reproduced inside the one document written to prevent it.

## 🔴 PASSPHRASE CHARACTER STANDARD — adopted 2026-07-14

**The rotated-out passphrase contained `!`, `^`, `&`, `@`. It failed three ways, in three tools, during the very operation it existed for:**

- **`-bash: !JA: event not found`** — twice. History expansion.
- **`The ampersand (&) character is not allowed`** — twice. PowerShell parser.
- **`gpg: decryption failed: Bad session key`** — paste mangling. **Typing it by hand worked.**

> 🔴 **A passphrase you cannot reliably type or paste is a passphrase that will fail during a recovery — the one moment it exists for.**
>
> **STANDARD: long, ASCII, letters and digits, `-` and `_` only. Entropy comes from LENGTH, not from characters that break the tools you need.**

🔴 **And bash rejecting the `!` is the only reason that value never landed in the shell history in plaintext, on the host holding the archive it unlocks. That was luck, not a control.**

## 🔴 Phase 5 — STILL OPEN

✅ **Paper: two copies, one off-site.** 🔴 **The MEDIA has no off-site copy — both are in the same room.** **Roadmap Critical Risk #1: a single fire takes the Root CA, the Intermediate CA, every RADIUS secret and the vault, in one event.**
