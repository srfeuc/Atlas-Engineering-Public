---
Title: Playbook — Rotate a Leaked Key Before You Back It Up (rotate → inventory → destroy after verify)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on the live secret store. Grounded in the real frozen **Lab-01** `CM-0010` (device-verified 2026-07-13), current-design-reconciled (`ADR-0022`; the OpenSSL Lab CA → **AD CS** + secrets on **BKP01/Vaultwarden**, `ADR-0031`/`ADR-0029`). Command-first, searchable/ticket-ready per Backlog **#32** (`ADR-0053` §5).
Version: 1.0
Date: 2026-08-01
---

# Playbook — Rotate a Leaked Key Before You Back It Up

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: key/secret incident response — an **action-layer** page (the commands + the doc that owns the fix, not the theory). **A private key or its passphrase was exposed (a chat log, a screenshot, a committed file) — what's the safe order of operations?** **Rotate first, inventory every copy, and destroy the exposed material only *after* the replacement verifies** — never back up first, never destroy the last rollback before the new one is proven. *(The verify-before-you-destroy reflex is the same discipline as [`../Concepts/A-Completed-Command-Is-Not-Evidence.md`](../Concepts/A-Completed-Command-Is-Not-Evidence.md), aimed at order-of-operations: a command run out of order is not the command you meant to run.)*

**The one-line problem.** Exposed key material where the intuitive order ("back up the emergency first, then fix it") **silently ships the compromised key off-site, permanently** — and where destroying the old copy too early can leave you with no recovery point at all.

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **the why → the Concept**.
3. **Why "back up first" is wrong** — the mechanism (defense-in-depth on disk vs the only control off-site) + the non-ASCII passphrase trap.
4. **① Pin it down** — passphrase-exposed vs key-material-exposed; every copy, every location.
5. **The commands — the procedure** (command-first):
   - 5.1 Inventory **every copy** and **every location** (before you touch anything).
   - 5.2 Verify the key opens (baseline), then **rotate → verify `.new` → swap → verify live**.
   - 5.3 If the **key material** leaked (not just the passphrase) → new keypair + reissue.
   - 5.4 **Destroy after verify** — every location, never the last rollback.
   - 5.5 Round-trip the new secret from the vault; read the final state back.
6. **The fix — where it's documented** · **If still broken**.
7. **Gap / what this closes** · **Worked example → `CM-0010`** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type** (one per line — each is its own searchable symptom)

- "*the CA passphrase / private key was posted in a chat log / screenshot / pasted somewhere*" — the trigger (rotate, step 5.2).
- "*should I back up the CA first or rotate first?*" — the ordering question this page answers (**rotate first**, step 3).
- "*I found a `.bak` / `.key.new` / key copy I didn't document*" — an undocumented exposed copy (inventory, step 5.1).
- "*the passphrase has a `£` / special character and won't type on the recovery console*" — the non-ASCII byte trap (step 3).
- 🟡 (real read-back — `POL-0001`): `openssl rsa -in <key> -noout -check` → `RSA key ok` (the proof a key opens, before and after).
- 🟡 `cd /etc/ssl/lab-ca/.../private` → `Permission denied` (a `0700 root` dir; use absolute paths — the shell isn't root).
- 🟡 `shred -u <file>` → `No such file or directory` (a destroy run **out of order**, before the file it was gated on existed).

**Plain-language symptom phrases**

- "my key / passphrase leaked — what do I do first?"
- "is it safe to back up a key whose passphrase got exposed?"
- "I don't know how many copies of this key exist."
- "the backup tarball has the old key in it."
- "can I delete the old key now, or do I need it as a rollback?"
- "the recovery passphrase might not type on bare metal."

**Aliases / also-known-as**

- key rotation · passphrase rotation · re-encrypt a private key · exposed key material · leaked secret · rotate-before-backup · inventory-every-copy · destroy-after-verify · never destroy the rollback first.
- lock change vs rebuild · re-wrap vs re-key · non-ASCII passphrase · `openssl rsa -aes256` · `shred -u` · defense-in-depth vs only-control · two-tier CA passphrase separation.

**Keywords line**

`CM-0010` · `openssl rsa -aes256` · `openssl rsa -noout -check` · `RSA key ok` · `shred -u` · `ls -la` private dir · `.bak` · `tar -tzf | grep private` · `chmod 600` · Vaultwarden round-trip · rotate-before-backup · ASCII-only passphrase · Root≠Intermediate passphrase · `ADR-0031` · `049` runbook · `031` Build-Guide.

## Cert anchor

- CompTIA **Security+** (key management, rotation, cryptographic hygiene) — the primary anchor.
- **CySA+** (incident response — containment/eradication/recovery ordering), **Linux+** (`openssl`, `shred`, file permissions, umask).
- *(Grounding index: `../Atlas-Certification-Lab-Map.md` · `../Atlas-Security-Plus-Domain5-Coverage-Map.md`.)*

## Why "back up first" is wrong (the mechanism — where the misconception bites)

The intuitive order is **back up the CA first (it's the emergency), then rotate.** It is wrong, and it silently rebuilds the exact defect you're fixing. The reason is *where the passphrase does its job*:

| On disk (Pi01) | On removable media, off-site |
|---|---|
| The passphrase is **defense in depth** — the key file is already `0600`, root-owned, inside a `0700` directory. | The passphrase is **the only control that exists** — the sole thing between a lost bag and every certificate in the lab. |

**The passphrase's real job begins the moment the key leaves the building.** Back up first and you ship the Root CA key, wrapped in a **chat-logged** passphrase, to a second location — permanently, and beyond recall. So: **if a key's passphrase is exposed, rotate before any backup. Never the reverse** (`CM-0010`).

Two more mechanisms that make this bite harder:

- **A passphrase is bytes, not characters.** OpenSSL reads the passphrase as raw bytes; a `£` (U+00A3) is `0xC2 0xA3` over a UTF-8 SSH session, but a *different* byte sequence — or unreachable — on a rescue initramfs, a legacy console, a KVM, or a US keymap. **The one moment you must type it is a bare-metal recovery on unfamiliar hardware** — the environment least likely to reproduce that byte. Rotate to an **ASCII-only** passphrase (and it's about length, not exotic characters). → `Recover-the-Lab-from-a-Bare-Metal-Teardown.md`.
- **Re-encrypting is a lock change, not a rebuild.** `openssl rsa -aes256` changes only the *wrapper* around the same key (identical RSA modulus) — **no certificate is invalidated, nothing needs reissuing.** *That is only true if the passphrase leaked. If the **key material itself** leaked, the lock is irrelevant — you need a **new keypair** and must reissue everything (step 5.3).*

## ① Pin it down (capture these first — they're the ticket)

- a. **What actually leaked** — the **passphrase** (→ re-encrypt, a lock change) or the **key material / the key file** (→ new keypair + reissue)? This decides everything downstream.
- b. **Which key(s)** — Root, Intermediate, a service key, an SSH/API key? For a two-tier CA, Root and Intermediate are separate blast radii (separate passphrases).
- c. **Every copy** — not just the live key: `.bak`/`.new`/`.exposed` strays in the private dir, and **every backup location** (removable media, an off-site tarball, a cloud sync, the workstation the passphrase file was on).
- d. **The rollback you must not destroy yet** — which existing copy is currently your *only* recovery point? Name it; it dies **last**, after the replacement verifies.
- e. **Where the new secret will live** — the vault (BKP01/Vaultwarden), plus paper (two copies, one off-site) for the CA passphrases.

## The commands — the procedure (rotate → inventory → destroy after verify)

> Command-first. Real device-verified reads from `CM-0010`; each step tagged with the `CM-0010` section that proved it. Commands link down to `../Command-Library/Linux.md` (`POL-0008`).

**1. Inventory every copy and every location — before you touch anything.**

```bash
sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/
```
- Healthy: **one** `.key` per directory, `0600`, no `.bak`/`.new`/`.exposed`.
- 🔴 Broken: a `*.key.bak-*` / stray — an undocumented copy of the same key material (a *different wrapper around the same key*). 📸 the listing.
- Then check **off-device** backups for the key (read-only):
  ```bash
  tar -tzf <backup>.tar.gz | grep 'private'
  ```
  - 🔴 If the key is already in a backup that shipped off-site, shredding it on the host clears **only one of two locations** (the real `CM-0010` finding — all four key files were on `E:\`).
  - → *`CM-0010` §Finding (two `.bak` copies) + §Open (the `E:\` tarball tested with `tar -tzf`).*

**2. Rotate before backup — verify `.new`, swap, verify the live file.**

```bash
sudo openssl rsa -in <key> -noout -check                 # baseline: RSA key ok (proves the stored passphrase opens it)
sudo openssl rsa -aes256 -in <key> -out <key>.new        # old passphrase in, NEW ASCII-only passphrase out
sudo openssl rsa -in <key>.new -noout -check             # verify the NEW file BEFORE the swap — live key still untouched
sudo mv <key>.new <key>
sudo chmod 600 <key>                                     # openssl -out obeys umask (often 0644); 0600 is not optional
sudo openssl rsa -in <key> -noout -check                 # verify again ON THE LIVE FILE, in place
```
- 🔵 **Root and Intermediate get *different* passphrases** — a shared one collapses the two-tier design (a compromised Intermediate must be replaceable without touching the Root). Repeat the block per key with a distinct passphrase.
- 🔵 **Absolute paths only — never `cd` into a `0700` private dir.** The `cd` fails (`Permission denied`, your shell isn't root), leaves you in `~`, and the next `sudo` runs against the wrong path. `sudo` elevates the command, not the shell that resolved the path.
- Healthy: `RSA key ok` on the `.new` *and* on the live file. Broken: any check fails → **stop**, the live key is still the old one (you verified before the swap). 📸 both `RSA key ok`.
- → *`CM-0010` §Root key rotation (verify-before-swap) + §Mistakes 1 (the `cd`/absolute-path trap).*

**3. If the *key material* leaked (not just the passphrase) — re-encryption is not enough.**

- A new wrapper on the same modulus doesn't help if the key bytes are out. Generate a **new keypair**, **reissue every certificate** it signed, and **remove the old cert from every device that trusts it** — then treat the old key as destroyed material (steps 4–5). Reissue: `Read-the-Cert-Not-the-Sign-Log.md`.
- 🔴 **Revocation ≠ removal (`ADR-0009`):** without a served CRL/CDP, `openssl ca -revoke` only edits `index.txt`; the old cert stays trusted until you physically replace it everywhere. Revocation is bookkeeping, not enforcement.

**4. Destroy the exposed copies — only after verification, every location, never the last rollback.**

```bash
sudo shred -u <key>.bak-<date>          # and the same for every stray copy found in step 1
```
- 🔴 **Order gate:** run the destroy **only after** step 2's live-file `RSA key ok`. In `CM-0010` a `shred` was issued *before* the `mv` that would create its target — it failed `No such file or directory`, i.e. it destroyed nothing **only by luck of the filename**. A command run out of order is not the command you meant.
- 🔴 **Never destroy the last rollback first.** The compromised off-site tarball was Atlas's *only* recovery point until a new backup was proven end-to-end — it was destroyed **last** (`049` Phase 6), after the replacement verified. Also destroy the off-site copies (the `E:\` tarball) — a file that can't help (its passphrase is gone) and can hurt has no reason to exist.
- Watch for **config `.bak`s too**: `CM-0010` also found `openssl.cnf.bak-2026-07-12` — the **pre-`copy_extensions`** config; restoring it would silently reintroduce the SAN defect (`Read-the-Cert-Not-the-Sign-Log.md`). *Three `.bak`s from one date = a habit, not an accident.*
- → *`CM-0010` §Destruction (shred after verify) + §Open (`E:\`) + §Closeout (config `.bak`).*

**5. Round-trip the new secret from the vault; read the final state back.**

```bash
sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/   # one file per dir, 0600, no strays
```
- 🔴 **Round-trip test:** read each new passphrase **back out of Vaultwarden** and re-run `openssl rsa -noout -check` → `RSA key ok`. Storing a secret is not proof you can retrieve it — `CM-0010` closed the gap that made a prior rotation untrustworthy by actually reading the stored value back.
- Also: passphrases to **paper**, two copies, one off-site (`049` Phase 1); a real backup taken **and restore-tested** (`049` Phases 3–4).
- → *`CM-0010` §Final state + §Closeout (round-trip test).*

## The fix — where it's documented (point down, don't re-derive)

- **The incident + full transcript:** [`CM-0010`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0010-CA-Passphrase-Rotation-and-Exposed-Key-Destruction.md) — the exact command sequence, the mistakes, and the closeout. *The doc that owns this fix.*
- **The CA backup/rotation runbook:** `Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md` — Phase 0.3 (the pre-flight `ls`), the rotate-before-backup ordering, Phase 6 (destroy the old rollback last).
- **The CA build fix (key-gen hygiene):** [Lab-CA Build-Guide](../../Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md) — the Intermediate key now generated **with `-aes256`**, the key-backup **destruction** rule, and the pre-archive `ls -la` check (all from `CM-0010`).
- **Reconciled to today (`ADR-0031`/`ADR-0029`):** on Lab-02 the CA keys live in **AD CS** (offline root RCA01 → issuing ICA01) and secrets in **Vaultwarden on BKP01** — key protection is the Windows key store, backup is `certutil -backupKey` / the CA export, and rotation of a compromised issuing CA is a reissue/rebuild of ICA01. **The three rules are platform-independent and carry unchanged:** rotate-before-backup, inventory-every-copy-and-location, destroy-after-verify. *(AD CS is 📋 not yet built — until then this is the discipline, exercised on the frozen record.)*

Then re-prove: step 5's round-trip `RSA key ok` from the vault + a restore-tested backup. Never mark ✅ on "rotated" alone — ✅ needs the pasted read-back (`POL-0001`).

## If still broken

- The new passphrase won't open the key on recovery hardware → the non-ASCII byte trap (step 3) — you rotated to a value that doesn't reproduce on that console; rotate again to plain ASCII, re-test on the target console.
- You shredded a copy and now can't open the key → you destroyed a rollback before the replacement verified (step 4) — restore from the *last* proven backup; this is why the old rollback dies last.
- A backup still contains the exposed key → you cleared one location, not all (step 1) — enumerate every backup target (`tar -tzf … | grep private`) and destroy/replace each.
- Certs started failing after rotation → you re-keyed (new keypair), not just re-wrapped — every cert must be reissued (step 5.3 → `Read-the-Cert-Not-the-Sign-Log.md`).
- The stored passphrase doesn't match the key → the vault value was never round-trip-tested (step 5) — recover from paper/the other copy, re-store, re-test.

## Gap / what this closes (`ADR-0053` §5 · `#37`)

- **The gap:** a **create step with no destroy step** — the prior rotation (`043` Part 9) *backed up* the key files and never recorded destroying them, leaving two CA private keys wrapped in a **known-exposed** passphrase in the CA's own directory for ~15 hours, and one `tar` from being shipped off-site (they were — all four key files sat on `E:\`). A **security gap** (exposed Root CA material, off-device) and a **process gap** (a narrative with no closeout can be entirely truthful and still leave the door open). Closed by the rotate-before-backup ordering, the pre-archive `ls`, and the destroy-after-verify rule — all now baked into `049`/`031` (device-verified).
- **Reconciled state (`ADR-0031`):** AD CS + BKP01/Vaultwarden move secrets off the single Pi and give first-class key backup/rotation — but **still designed-only until built** (⬜/📋): the AD CS ceremony and a **restore-tested** backup are unbuilt, so "secrets are safe" is a plan, not a verified-running control (`POL-0001`). Track it in `../Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md` (the Pi/PKI + backup rows) + the Review-Flag-Register.

## Worked example — the real Lab-01 case (`CM-0010`, device-verified 2026-07-13)

> The actual incident this Playbook is drawn from — on the live Pi01 Lab CA (frozen Lab-01). **Authoritative record: [`CM-0010`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0010-CA-Passphrase-Rotation-and-Exposed-Key-Destruction.md)** (owns the incident). Read-backs quoted from the frozen record (`POL-0001`).

- **① Pin it down.** The Root CA passphrase was exposed **in a chat log**, and it contained a `£` (non-ASCII) — rotation required regardless of exposure. Passphrase leaked, not key material → re-encrypt (a lock change). → `CM-0010` §Reason.
- **Step 1 — inventory found two undocumented copies.** `ls -la` of the private dirs (before archiving) showed `root-ca.key.bak-2026-07-12` and `intermediate-ca.key.bak-2026-07-12` — same key material, wrapped in the **pre-rotation exposed** passphrase. `tar -tzf pi01-full-backup-2026-07-12.tar.gz | grep private` then confirmed **all four key files** were already off-device on `E:\`. → `CM-0010` §Finding / §Open.
- **Step 2 — rotate, verify-before-swap.** `openssl rsa -aes256` to a `.new` (ASCII-only), `openssl rsa -noout -check` → `RSA key ok` on the `.new` **before** `mv`, then `chmod 600`, then `RSA key ok` again on the live file. Root and Intermediate got **different** passphrases. → `CM-0010` §Root key rotation.
- **Step 4 — destroy after verify.** `shred -u` both `.bak` files **only after** the live keys verified; the compromised `E:\` tarball destroyed **last** (2026-07-14), after a proven backup — `dir E:\…tar.gz` → `PathNotFound` with `E:\` mounted (a valid negative). → `CM-0010` §Destruction / §Closeout.
- **Step 5 — round-trip.** Both new passphrases read back **out of Vaultwarden** and re-verified → `RSA key ok` ×2 — closing the gap that made the prior rotation untrustworthy. Final `ls -la`: one `0600` key per dir, no strays. → `CM-0010` §Closeout.
- **Gap closed.** The create-with-no-destroy defect fixed at source (`031`/`049` reconciled); the off-site exposure cleared; the non-ASCII passphrase retired. *(Reconcile: keys move to AD CS + BKP01; the three rules are unchanged.)*

## Related

- **The fix docs (link down):** [`CM-0010`](../../Labs/Lab-01-Mikrotik-Core/Change-Management/CM-0010-CA-Passphrase-Rotation-and-Exposed-Key-Destruction.md) (the incident) · `Labs/Lab-01-Mikrotik-Core/Operations/049-Root-CA-and-Credential-Backup-Runbook.md` (the runbook) · [Lab-CA Build-Guide](../../Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md) (key-gen hygiene + the destroy rule).
- **Command-Library:** `../Command-Library/Linux.md` (`openssl`, `shred`, file perms / umask, `tar -tzf`).
- **Concept (the why):** [`../Concepts/A-Completed-Command-Is-Not-Evidence.md`](../Concepts/A-Completed-Command-Is-Not-Evidence.md) (verify before you act — and its order-of-operations twin: *a command run out of order is not the command you meant*).
- **Sibling playbooks:** `Respond-to-a-Committed-Secret.md` (the git-committed-secret twin — `CM-0014`: rotate-first there too) · `Read-the-Cert-Not-the-Sign-Log.md` (reissue after a re-key) · `Recover-the-Lab-from-a-Bare-Metal-Teardown.md` (the one moment the passphrase must type — the ASCII rule).
- **Reconciliation & gap map:** `../Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md` (the Pi four-services split — CA → AD CS, Vaultwarden → BKP01, `#37`).
- **Backlog:** `#32` (searchable / ticket-ready) · `#37` (gap analysis) · `ADR-0009` (revocation ≠ removal without a CDP).

## Worked log

| Date | Who | Time | Key(s) rotated | Passphrase-only or re-key? | Every copy + location cleared? | Round-trip `RSA key ok` from the vault? | Outcome |
|---|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-08-01 | Created (§4 queue row 7, Lab-01 Playbook Project) — the first Playbook built under the locked command-first mold (`ADR-0053` §5). Rotate a leaked key/passphrase safely: **rotate before any backup** (on disk the passphrase is defense-in-depth; off-site it's the only control — back up first and you ship the compromised key beyond recall), **inventory every copy and every location** (the two undocumented `.bak`s + all four key files on `E:\`), **destroy only after the replacement verifies** and **never the last rollback first**, with the passphrase-vs-key-material fork, the ASCII-only (bytes-not-chars) rule, Root≠Intermediate separation, and the round-trip-from-the-vault proof. Command-first with per-step `CM-0010` provenance; points to the fix docs (`CM-0010` + `049` + the Lab-CA Build-Guide); one-error-per-bullet Symptoms; Gap note; Worked example → `CM-0010`. Reconciled OpenSSL Lab CA → AD CS + BKP01/Vaultwarden (`ADR-0022`/`ADR-0031`/`ADR-0029`); the three rules are platform-independent. 🟡 until run. |
