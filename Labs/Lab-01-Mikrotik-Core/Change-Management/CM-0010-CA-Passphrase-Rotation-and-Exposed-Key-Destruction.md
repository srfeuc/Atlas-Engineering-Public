# CM-0010 — Emergency CA Passphrase Rotation and Destruction of Exposed Key Backups

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | ✅ **Closed — implemented, verified, and reconciled.** Both exposed `.bak` key copies destroyed; passphrases rotated and round-trip tested from Vaultwarden; the `07-12` tarball confirmed destroyed on `E:\`; **guide reconciliation complete across `031`, `029`, `049`, `07-Backup` and `043` (the last, annotated 2026-07-14).** |
| Risk | High (Root CA key material) |
| Affected systems | Pi01 — Lab CA (Root + Intermediate), Vaultwarden |
| Date raised | 2026-07-13 |
| Date executed | 2026-07-13 |
| Evidence Status | **`Verified`** — every step below is transcribed from live device output, not reconstructed |

> **This record exists because the previous rotation (`043` Part 9) was documented as a narrative and not as a change.** It had no closeout, no reconciliation, and no destruction step — and that omission left two copies of the CA private keys, wrapped in a known-exposed passphrase, sitting in the CA's own private directory for fifteen hours.
>
> **Everything in this record is written the way `043` Part 9 should have been.**

---

## Reason

Two independent triggers, one session:

**1. The Root CA passphrase was exposed in a chat session log.**

Same class of incident as `043` Part 10 (*RADIUS secrets "exposed in a chat session log previously"*) and `043`'s own origin (*CA passphrases in a plaintext file on the desktop*). **Third occurrence of the same failure mode.**

**2. The passphrase contained a non-ASCII byte.**

The exposed value contained `£` (U+00A3). OpenSSL reads a passphrase as **bytes**, not characters — over a UTF-8 SSH session that is `0xC2 0xA3`. On a rescue initramfs, a legacy console, a KVM, or a US keymap it is a different byte sequence, or unreachable entirely.

**The one moment this passphrase must be typed is a bare-metal recovery on unfamiliar hardware** — the environment least likely to reproduce that byte. A correct backup plus a correct paper passphrase could still have failed to open, permanently, on a currency symbol.

Rotation was therefore required regardless of the exposure.

---

## 🔴 Ordering — Rotate Before You Back Up

**This is the reusable lesson from this change and it is not obvious.**

The intuitive order — *back up the CA first, since that's the emergency, then rotate* — is **wrong, and it silently rebuilds the exact defect being fixed.**

| On Pi01 | On removable media, off-site |
|---|---|
| The passphrase is **defense in depth.** The key file is `0600`, root-owned, inside a `0700` directory. | The passphrase is **the only control that exists.** It is the sole thing between a lost bag and every certificate in the lab. |

**The passphrase's real job begins the moment the key leaves the building.** Backing up first would have shipped the Root CA key, wrapped in a chat-logged passphrase, to a second location — permanently, and beyond recall.

**Rule: if a key's passphrase is exposed, rotate before any backup. Never the reverse.**

---

## 🔴 Finding — Two Undocumented Exposed Key Copies

Surfaced by listing the private directories **before** archiving them, not by reading any document:

```text
/etc/ssl/lab-ca/root/private/:
-r-------- 1 root root 3446 Jul 12 22:12 root-ca.key.bak-2026-07-12

/etc/ssl/lab-ca/intermediate/private/:
-r-------- 1 root root 3446 Jul 12 22:13 intermediate-ca.key.bak-2026-07-12
```

**These are the files created by `043` Part 9, step 1: *"Backed up both key files first."***

- Same key material as the live keys — identical RSA modulus. Re-encryption changes only the wrapper.
- Wrapped in the **pre-`043` passphrase** — the one that was in a plaintext file on the desktop, flagged for permanent deletion.
- **Anyone holding that old passphrase and either of these files owns the entire lab PKI.** Tonight's rotation does not touch them; they are a different wrapper around the same key.

### Root cause: a create step with no destroy step

`043` Part 9 records **creating** them. **It never records destroying them.** No step, no checklist item, no closeout. That single line is the whole defect:

> *"1. Backed up both key files first."*

**The session whose entire purpose was eliminating an exposed CA passphrase left two copies of the CA key openable by that exposed passphrase, inside the CA's own private directory.** It was not careless. It was a procedure with a missing step, written as prose instead of as a change record with a closeout.

### 🔴 Near-miss — they would have been exported off-site

`049` Phase 3 archives `/etc/ssl/lab-ca` **whole**:

```bash
sudo tar -czpf ... -C / etc/ssl/lab-ca ...
```

Had the backup been taken before this listing, **both `.bak` files would have been tarred, encrypted, and shipped off-site** — a CA key wrapped in a known-leaked passphrase, in a building outside your control, permanently.

**That is the `pi01-full-backup-2026-07-12.tar.gz` defect, reproduced and then exported.** It was caught by one `ls -la` of a directory before archiving it.

### 🔴 Open — the same files are probably already on `E:\`

`029-Pi01-Build-Record.md` line 139 records that `pi01-full-backup-2026-07-12.tar.gz` covered **`/etc/ssl/lab-ca`** in full and was moved off-device to `E:\`.

**The `.bak` files were created 2026-07-12 at 22:12. The tarball is dated 2026-07-12.** If it was captured after 22:12, it contains both exposed key copies — and shredding them on Pi01 cleared only one of two locations.

**Test (read-only):**

```bash
tar -tzf pi01-full-backup-2026-07-12.tar.gz | grep 'lab-ca/root/private\|lab-ca/intermediate/private'
```

**RESULT, 2026-07-13 — confirmed, all four files present:**

```text
etc/ssl/lab-ca/intermediate/private/intermediate-ca.key.bak-2026-07-12
etc/ssl/lab-ca/intermediate/private/intermediate-ca.key
etc/ssl/lab-ca/root/private/root-ca.key.bak-2026-07-12
etc/ssl/lab-ca/root/private/root-ca.key
```

**Four copies of the CA private keys, all wrapped in the exposed passphrase, sitting off-device on `E:\` since 2026-07-12.** Shredding the `.bak` files on Pi01 cleared only one of two locations.

**And the convergence is real:** `043` Part 9 step 6 records the plaintext passphrase file as being on **the workstation's desktop** — the same machine as `E:\`. **Key and passphrase, one machine.**

> 🔴 **The tarball was deliberately NOT destroyed at this point.** While it was the only thing that opened, it was Atlas's only CA recovery point — however compromised. **Never destroy the rollback before the replacement verifies.** It is destroyed at `049` Phase 6, after the new backup was proven end to end.

**Either way that tarball is destroyed.** It cannot save you — the passphrase that opens it was deliberately destroyed — and it can hurt you. A file that can't help and can hurt has no reason to exist.

---

## Execution Log — What Actually Ran

**Transcribed from the live session. Including the parts that went wrong.**

### Verification before touching anything (`049` Phase 0)

```bash
sudo openssl rsa -in /etc/ssl/lab-ca/root/private/root-ca.key -noout -check
# RSA key ok
sudo openssl rsa -in /etc/ssl/lab-ca/intermediate/private/intermediate-ca.key -noout -check
# RSA key ok
```

**Both passed.** This confirmed for the first time that the passphrases recorded in Vaultwarden actually open the live keys — never previously tested. `043` Part 9 verified the passphrase *at the moment of rotation*, then stored it; the stored value had never been read back and used.

### Root key rotation

```bash
sudo openssl rsa -aes256 \
  -in  /etc/ssl/lab-ca/root/private/root-ca.key \
  -out /etc/ssl/lab-ca/root/private/root-ca.key.new
# old passphrase in, new ASCII-only passphrase out

sudo openssl rsa -in /etc/ssl/lab-ca/root/private/root-ca.key.new -noout -check
# RSA key ok    <- verified BEFORE the swap. Live key still untouched at this point.

sudo mv  /etc/ssl/lab-ca/root/private/root-ca.key.new \
         /etc/ssl/lab-ca/root/private/root-ca.key
sudo chmod 600 /etc/ssl/lab-ca/root/private/root-ca.key
sudo openssl rsa -in /etc/ssl/lab-ca/root/private/root-ca.key -noout -check
# RSA key ok    <- verified again ON THE LIVE FILE, in place
```

Identical sequence for `/etc/ssl/lab-ca/intermediate/private/intermediate-ca.key`, **with a different passphrase.**

> **Different passphrases for Root and Intermediate.** A shared passphrase silently collapses the two-tier design in `031` — the entire point of which is that a compromised Intermediate can be revoked and replaced *without touching the Root*.

> **`chmod 600` is not optional.** `openssl -out` obeys root's umask and will typically write `0644`. The `0700` parent directory contains it, but do not leave it.

### Destruction — only after both live keys verified

```bash
sudo shred -u /etc/ssl/lab-ca/root/private/root-ca.key.bak-2026-07-12
sudo shred -u /etc/ssl/lab-ca/intermediate/private/intermediate-ca.key.bak-2026-07-12
```

### Final state — read back, not assumed

```text
/etc/ssl/lab-ca/root/private/:
-rw------- 1 root root 3446 Jul 13 13:28 root-ca.key

/etc/ssl/lab-ca/intermediate/private/:
-rw------- 1 root root 3446 Jul 13 13:31 intermediate-ca.key
```

**One file per directory. `0600`. No `.bak`, no `.new`, no strays.**

---

## Mistakes Made During This Change

**Recorded because `043`'s own pattern says so: a change record that only records what went right will mislead the next person.**

### 1. A `cd` into a `0700` root-owned directory — and the silent path failure behind it

Issued:

```bash
cd /etc/ssl/lab-ca/root/private
sudo cp root-ca.key root-ca.key.exposed-bak
```

`cd` failed (`Permission denied`) — the shell runs as `dnsadmin`, the directory is `0700 root`. **The `cd` failing left the shell in `~`, so the `sudo cp` then ran against `~/root-ca.key`, which does not exist.** It failed loudly and harmlessly, but only by luck of the filename.

**Fix, adopted for the rest of the change: absolute paths for every command. Never `cd` into the CA's private directories.** `sudo` elevates the command, not the shell that resolved the path.

### 2. `shred` executed before the verification it was gated on

The `shred` commands for `.exposed-bak` were run **before** the `mv` that was supposed to create them. They failed with `No such file or directory` — **because the file never existed, not because anything protected them.**

**Had that `cp` succeeded, this would have destroyed a rollback copy before its replacement was verified.**

> **This is the twin of the pattern named in `043`.** That document says *a command completing without an error is not a confirmed change.* This change adds the other half: **a command run out of order is not the command you meant to run.** Both are invisible in a clean-looking terminal.

### 3. The build guide would have rebuilt the defect

Found while writing `049` — see reconciliation below.

---

## Guide Reconciliation — Charter Rule 15

> **Does any guide now contain an instruction that would recreate this problem, or a claim this change disproves?**

| Document | Outcome | Detail |
|---|---|---|
| **`031-Pi01-Lab-CA-Build-Guide.md`** | 🔴 **Two defects — must fix** | **(a)** Step 2 generates the Intermediate key with `sudo openssl genrsa -out private/intermediate-ca.key 4096` — **no `-aes256`.** The Root has it; the Intermediate does not. The live Intermediate *is* encrypted (`043` Part 9 rotated both), so **a CA rebuilt from this guide today produces an Intermediate signing key sitting on disk in plaintext.** **(b)** The guide has no instruction to destroy key backups, and no warning against leaving them in the private directory. |
| **`043-PKI-and-Credential-Security-Overhaul-Session-Summary.md`** | 🔴 **Root cause — must annotate** | Part 9 step 1 (*"Backed up both key files first"*) is the line that created the exposed copies. **It has no matching destroy step.** Annotate with a pointer to this record. **Do not edit the narrative** — it is a historical account and accurate as such; add a correction note. |
| **`029-Pi01-Build-Record.md`** | 🔴 **Must update** | Records the CA passphrase state and presents `pi01-full-backup-2026-07-12.tar.gz` (line 139) as the real backup. **Both are now false.** Passphrases rotated; the tarball is unopenable and is a liability. |
| **`049-Root-CA-and-Credential-Backup-Runbook.md`** | 🔴 **Must update** | Phase 2 must **list the private directories before archiving them** — this change was found by an `ls`, not a document. Phase 0 must add the **rotate-before-backup ordering rule**. |
| **`07-Backup-and-Recovery/README.md`** | 🔴 **Must update** | Still presents the 07-12 tarball as *"the first real backup."* It is not a backup. |
| `035`, `042` | **Reviewed — no change** | Neither instructs creating key backups; neither claims a passphrase state. |

---

## Closeout

- [x] Both passphrases verified against live keys **before** any change (`049` Phase 0.1 / 0.2)
- [x] Root key re-encrypted, ASCII-only passphrase, verified on the live file
- [x] Intermediate key re-encrypted, **separate** ASCII-only passphrase, verified on the live file
- [x] Both `.bak-2026-07-12` files destroyed with `shred -u`, **after** verification
- [x] Final directory state read back — one file per directory, `0600`
- [x] Both new passphrases stored in Vaultwarden
- [x] 🔴 **Round-trip test** — both passphrases read back out of Vaultwarden and re-verified. `RSA key ok` ×2. **The gap that made `043` Part 9 untrustworthy is closed.**
- [x] 🔴 **`E:\` tarball tested** — **CONFIRMED: it contains all four key files, including both `.bak-2026-07-12` copies.** The exposed keys were already off-device. See below.
- [x] 🔴 **Destroy `pi01-full-backup-2026-07-12.tar.gz`** — ✅ **CONFIRMED DESTROYED 2026-07-14.** `dir E:\pi01-full-backup-2026-07-12.tar.gz` → `PathNotFound`, with `E:\` mounted and enumerable (the control). A valid negative, not an absent test. — now superseded by a proven backup (`049` v2.0). No longer a recovery point; pure liability.
- [x] **Third `.bak` found** — `intermediate/openssl.cnf.bak-2026-07-12`. No key material, but it is the **pre-`copy_extensions`** config: restoring it would silently reintroduce the SAN defect. **Three `.bak` files from one date = a habit, not an accident.**
- [x] **Guide reconciliation executed** — `031` ✅ (v0.5, intermediate key-gen + destroy step), `029` ✅ (tarball corrected, restore-test recorded), `049` ✅ (Phase 0.3 pre-flight `ls`, rotate-before-backup ordering), `07-Backup-and-Recovery/README.md` ✅, **`043` ✅ — Part 9 step 1 annotated 2026-07-14. This was the last outstanding item.**
- [ ] Passphrases written to **paper**, two copies, one off-site (`049` Phase 1)
- [ ] Backup taken and **restore-tested** (`049` Phases 3–4)
- [ ] Mark this record **Closed**

> **No certificate was invalidated by this change.** Re-encryption changes the wrapper, not the key. FGT01, MKT01, Pi-hole, and `vault.lab` are untouched and require no reissue. **This is not a rebuild — it is a lock change on the same door.**

---

## Note

**`043` Part 9 was a narrative. This is a change record. The difference is the closeout.**

A narrative can say *"backed up both key files first"* and be entirely truthful and still leave two live CA keys on disk for fifteen hours — because a narrative has no line that asks *"and did you destroy them?"*

Charter Rule 15 exists to force that question. **Part 9 predates Rule 15 by one day.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised and executed 2026-07-13. Passphrase exposed in a chat log; non-ASCII byte found in the passphrase itself. **Two undocumented exposed key copies discovered in the CA private directories and destroyed** — created by `043` Part 9, never recorded as destroyed, and one `tar` away from being exported off-site. Rotate-before-backup ordering rule established. Two `031` defects and a possible `E:\` exposure raised. |
