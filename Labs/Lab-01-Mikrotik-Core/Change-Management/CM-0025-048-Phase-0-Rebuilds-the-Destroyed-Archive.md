# CM-0025 — `048` Phase 0 Rebuilds the Exact Archive `CM-0010` Destroyed

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Change-Management

| Item | Value |
|---|---|
| Status | **Draft** |
| Risk | 🔴 **HIGH — security.** *(No live device change.)* |
| Affected systems | **Documentation.** `048-Teardown-and-Rebuild-Runbook.md`. |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — read directly from `048` Phase 0 as committed |
| Related | `CM-0010`, `CM-0014`, `029`, `031`, `049`, `ADR-0009`, `ADR-0010`, `051-Book-1-Audit-Report.md` (finding F1) |

> **`048` is a good runbook.** Its bootstrap table is current and correct, its `STATIC-HOSTS` list is the right five entries, and its iDRAC warning is accurate. **`CM-0012`, `CM-0017` and `CM-0018` all listed `048` as needing reconciliation, and all three were done properly.**
>
> 🔴 **`CM-0014` listed `048` as *"Not yet reviewed"* — and closed anyway.** **This is that review.**

---

## 🔴 Finding 1 — `048` Phase 0.3 recreates `pi01-full-backup-2026-07-12.tar.gz`

**`048` Phase 0.3, as committed:**

```bash
sudo tar -czvf pi01-full-$(date +%F).tar.gz \
  /etc/ssl/lab-ca /etc/pihole /etc/freeradius /etc/nginx /etc/ufw \
  ~/vaultwarden/data /etc/systemd/system/dnscrypt-proxy-doh.service
```

**That command produces an UNENCRYPTED tarball containing:**

- The **Root CA** and **Intermediate CA** private keys
- The **entire Vaultwarden database** — every credential in the lab
- **`clients.conf`** — every FreeRADIUS shared secret
- Pi-hole's DNS records, the nginx config, the UFW ruleset

**`029-Pi01-Build-Record.md`, on the archive of that exact name:**

> 🔴 *"**`pi01-full-backup-2026-07-12.tar.gz` no longer exists and was never a valid recovery point.** … `tar -tzf` confirmed it contained **both `.bak-2026-07-12` key copies** — four copies of the CA private keys in total, all openable with a credential that had leaked. **It could not save you, and it could hurt you.** Destroyed after its replacement was proven."*

> 🔴 **`048` Phase 0.3 is the command that made it.** Same shape, same contents, same name pattern. **A teardown performed today, following the runbook, recreates the artefact `CM-0010` was raised to destroy.**

## 🔴 Finding 2 — `048` has no pre-archive `ls`. That check exists because of this exact tarball.

**`048` Phase 0.2:**

```bash
sudo tar -czvf lab-ca-$(date +%F).tar.gz /etc/ssl/lab-ca
```

**`031` v0.5 and `CM-0010` both mandate a check before this:**

> **"Before archiving or backing up the CA — always list the private directories first:**
> ```bash
> sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/
> ```
> **Expect exactly one `.key` file in each, mode `0600`.** Anything else — `.bak`, `.new`, `.old` — is key material you are about to copy somewhere you cannot recall it from."

**`049` Phase 0.2 exists for the same reason and says so:**

> *"**Phase 3 archives `/etc/ssl/lab-ca` whole.** Had we not run this `ls`, both files would have been tarred, encrypted, and **shipped off-site** — a CA key wrapped in a known-leaked passphrase, in a building you don't control, permanently."*

🔴 **`048` archives `/etc/ssl/lab-ca` whole and has no `ls`.** `CM-0010`'s reconciliation reached `031`, `029`, `049`, `07-Backup` and `043`. **It did not reach `048`.**

## 🔴 Finding 3 — `048` and `049` are two incompatible backup schemes, and `048` does not know `049` exists

```
grep -c "049" 048-Teardown-and-Rebuild-Runbook.md   →   0
```

**`048` references `049` ZERO times.** Its Related Pages lists `003`, `Build-Order-and-Dependencies`, the Build Guides, and `035`. **Not `049`.**

| | `048` Phase 0 | `049` (the real procedure) |
|---|---|---|
| Encryption | 🔴 **None.** Plain `tar -czvf`. | ✅ **`gpg --symmetric`, AES256** |
| Passphrase | 🔴 **None — there is no passphrase.** | ✅ **Paper only. Never in Vaultwarden** — *"the archive contains Vaultwarden"* |
| Pre-archive `.bak` check | 🔴 **Absent** | ✅ Phase 0.2 `ls -la`, mandatory |
| Vault export | 🔴 **`.json`** via the web UI — **plaintext** | ✅ Inside the encrypted archive |
| Restore-tested | 🔴 Never | ✅ Phase 4, proven end to end |
| Copies | *"offline media, two copies, one off-site"* | Pi01, `E:\`, off-site — hash-verified |

> 🔴 **`CM-0014`'s question was: *"Check whether `048` instructs the reader to retrieve the archive passphrase from anywhere other than paper."***
>
> 🔴 **The answer is worse than the question anticipated. `048` does not use an encrypted archive at all — so it never needs a passphrase.** The question assumed the runbook followed `049`. **It does not know `049` exists.**

## 🔴 Finding 4 — Phase 0.1 exports the vault to plaintext JSON

```
# Vaultwarden: use the web UI export, not a file copy.
# https://vault.lab:8443 -> Tools -> Export Vault -> .json
```
> *"Store on offline media. Two copies. One off-site."*

**A `.json` vault export is every credential in the lab, in cleartext, on a USB stick, in a building you don't control.** **Vaultwarden offers an encrypted export. `048` does not say to use it.**

**`ADR-0009`'s threat model turns on the payoff to an attacker being low.** *"If the payoff changes, the decision changes."* **A plaintext vault export on off-site media changes it.**

## 🔴 Finding 5 — `048` §3.1 points at `027`, and `027` builds the wrong ACL

**`048` §3.1 is CORRECT.** It carries the full five-entry `STATIC-HOSTS` table including Pi01, and says: *"**Build the ACL from this list, not from a stale record.**"*

🔴 **And its step 7 says: *"Per `027-SW01-Build-Guide.md` … Access ports, DHCP snooping, ARP inspection, `STATIC-HOSTS`."*** **`027` builds FOUR entries and omits Pi01** (`CM-0022`).

> **The runbook is right, it warns you about the stale record, and it hands you the stale record.** The warning is a callout; `027` is the procedure. **A rebuilder executing `027` step-by-step gets four.**

**No change needed to `048` for this** — `CM-0022` fixes `027`. **Recorded here because it is the reason `048`'s warning has never been enough.**

---

## Implementation — documentation only

### Edit 1 — `048` Phase 0.2 and 0.3: replace with a pointer to `049`

**Delete both `tar -czvf` commands. Replace Phase 0.2 + 0.3 with:**

> ## 🔴 0.2 — Back up Pi01. **Do NOT invent a tar command. Use `049`.**
>
> **`049-Root-CA-and-Credential-Backup-Runbook.md` is the procedure.** Follow it end to end. It is **GPG AES256-encrypted**, its passphrase is **paper only**, and it is the **only backup in this lab that has ever been restore-tested.**
>
> 🔴 **Do not write your own `tar -czvf` of `/etc/ssl/lab-ca`.** A previous version of this runbook did, and it produced **`pi01-full-backup-2026-07-12.tar.gz`** — an **unencrypted** archive holding the Root CA key, the Intermediate CA key, every RADIUS secret and the whole Vaultwarden database. It also swept up two `.bak` key copies wrapped in a **leaked** passphrase. **`029`: *"It could not save you, and it could hurt you."*** It was destroyed under `CM-0010`.
>
> 🔴 **`049` Phase 0.2 is mandatory and is why:**
> ```bash
> sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/
> ```
> **Expect exactly ONE `.key` per directory, mode `0600`.** A `.bak`, `.new` or `.old` is key material you are about to ship off-site permanently.
>
> **The CA restore-vs-rebuild decision (below) still stands. Only the mechanism changes.**

### Edit 2 — `048` Phase 0.1: the vault export

**Replace with:**

> ### 0.1 — Get the credentials off Pi01
>
> **The vault is inside `049`'s encrypted archive. That is your machine-readable copy.**
>
> 🔴 **Do NOT take a plaintext `.json` export to offline media.** That is every credential in the lab, in cleartext, in a building you do not control. If you export at all, use Vaultwarden's **password-protected** export.
>
> ✅ **Print the device admin passwords on paper.** You will be at a serial console with no computer that can open a JSON file. **`049` Phase 1 is the paper procedure — follow it.**
>
> 🔴 **The archive passphrase NEVER goes in Vaultwarden.** The archive *contains* Vaultwarden. **Paper only** (`049` Phase 1).

### Edit 3 — `048` Phase 0.6 checklist

```markdown
- [ ] 🔴 **`049` executed in full** — archive built, **restore-TESTED**, hashes matched
- [ ] 🔴 **Pre-archive `ls -la` run** — exactly ONE `.key` per private directory
- [ ] 🔴 **Archive passphrase on PAPER, not in Vaultwarden, not in the repo** (`CM-0014`)
- [ ] Device admin passwords on paper
- [ ] 🔴 **NO plaintext vault export exists on any medium**
- [ ] 🔴 **Off-site copy physically verified** — *not "believed to exist." `029` claims one; four documents say both copies are in the same room.*
```

### Edit 4 — `048` §3.5 step 3 and Related Pages

- §3.5 step 3: *"Restore `/etc/ssl/lab-ca`"* → **"Restore per `049` — `gpg --decrypt`, then extract. The archive passphrase is on paper."**
- **Related Pages: add `Operations/049-Root-CA-and-Credential-Backup-Runbook.md` — the backup and restore procedure. `048` currently does not reference it at all.**

---

## Validation

```powershell
# The unencrypted tar must be GONE - expect ZERO hits:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\048-Teardown-and-Rebuild-Runbook.md `
              -Pattern "tar -czvf pi01-full"

# 048 must now know 049 exists - expect MULTIPLE hits:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\048-Teardown-and-Rebuild-Runbook.md `
              -Pattern "049"

# The pre-archive ls must be present - expect ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Operations\048-Teardown-and-Rebuild-Runbook.md `
              -Pattern "lab-ca/root/private"
```

## Rollback

`git checkout -- Labs/Lab-01-Mikrotik-Core/Operations/048-Teardown-and-Rebuild-Runbook.md`

---

## Reconciliation — all document types (`ADR-0019`)

| Document | Outcome | Detail |
|---|---|---|
| 🔴 **`048`** (Runbook) | **Updated** | This record. Edits 1–4. |
| **`049`** (Runbook) | **Reviewed — no change needed** | 🟢 **`049` is correct and complete.** GPG AES256, paper passphrase, mandatory pre-archive `ls`, restore-tested. **It is the only backup in Atlas that has ever been proven.** *(Its Phase 5 off-site step is contradicted by `029` — see **B12**. Separate finding.)* |
| **`029`** (Build Record) | 🔴 **MUST UPDATE** | Still names the destroyed `2026-07-13` archive as *"the real backup"* and claims an off-site copy four documents deny. **B12/B13.** **Handled in the audit's reconciliation batch.** |
| **`031`** (Build Guide) | **Reviewed — no change needed** | 🟢 Already carries the destruction rule and the pre-archive `ls`. **`031` was right; `048` never got it.** |
| **`016`** (Lessons) | 🔴 **MUST UPDATE** | Add: **a correction that reaches every document DESCRIBING a procedure, and not the RUNBOOK that performs it, has not landed.** `CM-0010` reached `031`, `029`, `049` and `043` — **and not `048`.** |
| **`043`** (Session Summary) | 🔴 **NOT YET REVIEWED** | Chunk 4 remainder. |
| **`044`** (Vaultwarden convention) | 🔴 **NOT YET REVIEWED** | Chunk 4 remainder. **`CM-0014` said `044`'s rule *"held perfectly"* — confirm against `048` Phase 0.1's JSON export.** |

---

## The lesson

> 🔴 **`CM-0010`'s correction reached every document that DESCRIBES the CA backup — and not the RUNBOOK that TAKES one.**

`031` (the guide), `029` (the record), `049` (the backup runbook) and `043` (the summary) were all fixed. **`048` — the teardown runbook, the one document guaranteed to be executed on the worst day of the project — was never opened.**

**This is `CM-0022`'s lesson at the operations layer:** *the correction pass finds the documents that describe a thing and misses the one that does it.*

> **And `CM-0014` asked the right question about `048` — *"does it retrieve the passphrase from anywhere other than paper?"* — wrote *"Not yet reviewed,"* and closed.** **The question was never answered until now, and the answer was worse than the question.**

---

## Closeout

- [ ] Edit 1 — Phase 0.2/0.3 replaced; **`tar -czvf pi01-full` is GONE**
- [ ] Edit 2 — Phase 0.1 plaintext JSON export removed
- [ ] Edit 3 — Phase 0.6 checklist rebuilt around `049`
- [ ] Edit 4 — §3.5 restore + Related Pages point at `049`
- [ ] Validated — `Select-String` confirms the tar command is **GONE**, not merely that `049` is mentioned
- [ ] 🔴 **`029` corrected** (destroyed archive + off-site claim) — **blocks closure**
- [ ] 🔴 **`016` updated** — **blocks closure**
- [ ] 🔴 **`043`, `044` read and reconciled** — **blocks closure**
- [ ] 🔴 **`CM-0014` reopened or annotated** — its `048` row said *"Not yet reviewed"* and it closed. **The row is now answered. Record that.**
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`), finding F1. 🔴 **`048` Phase 0.3 rebuilds `pi01-full-backup-2026-07-12.tar.gz` — the unencrypted archive holding both CA keys, every RADIUS secret and the whole vault, which `CM-0010` destroyed as *"it could not save you, and it could hurt you."*** 🔴 **`048` has no pre-archive `.bak` check** — the check that exists *because of* that tarball. 🔴 **`048` references `049` ZERO times** — two incompatible backup schemes, and `048` teaches the destroyed one. 🔴 **Phase 0.1 exports the vault to plaintext JSON and ships it off-site.** **`CM-0014` marked `048` "Not yet reviewed" and closed. This is that review.** 🟢 `048`'s bootstrap table, `STATIC-HOSTS` list and iDRAC warning are all correct — `CM-0012`, `CM-0017` and `CM-0018` reconciled it properly. |
