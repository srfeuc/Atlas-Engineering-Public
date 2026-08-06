# CM-0019 — Vaultwarden Container Env File in the Backup Directory

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

| Item | Value |
|---|---|
| Status | **Implemented — reconciliation open** |
| Risk | **Low.** The token is **Argon2-hashed**, not plaintext. **World-readable permissions have been closed.** |
| Affected systems | Pi01 — `~/atlas-backup/vaultwarden-container-env.txt` |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — read off the device |
| Related | `CM-0014`, `018-Atlas-Documentation-Standards.md` v2.0, `049` |

> **Found during `CM-0014`'s Phase 0 inventory. It was not what we were looking for, which is exactly why it is worth a record.**

## What was found

```text
-rw-r--r-- 1 dnsadmin dnsadmin 320 Jul 13 14:07 vaultwarden-container-env.txt
```

**A hand-made copy of Vaultwarden's container environment, in plaintext, `world-readable`, sitting in `~/atlas-backup/` — the one directory on Pi01 whose entire purpose is to be preserved and shipped off-device.**

**Created `14:07` on 2026-07-13. The archive it sits beside was created at `14:16`. Nine minutes apart, in the same session.**

## Severity — verified, not assumed

**The live container's token is Argon2-hashed:**

```text
docker inspect vaultwarden --format '{{.Config.Env}}'
[DOMAIN=https://vault.lab:8443 ADMIN_TOKEN=$argon2id$v=19$m=65540,t=3,p=4$...
```

**And so is the copy in the `.txt`** — confirmed by counting `argon2` occurrences without reading the file.

> 🟢 **This is NOT a plaintext credential exposure.** An Argon2 hash is verified against, not replayed. **The severity is materially lower than it first appeared**, and this record says so rather than inflating it.

**It is still a secret-shaped file, in the backup directory, that should not be there.**

## 🔴 Why it matters anyway — it is `CM-0014`'s twin

**`018-Atlas-Documentation-Standards.md` v2.0, written the same day:**

> *"`.gitignore` denylists **extensions**… and a passphrase in a `.txt` walks straight through."*

| | File | Where |
|---|---|---|
| **`CM-0014`** | `Archive passphrase.txt` | Repository root |
| **`CM-0019`** | `vaultwarden-container-env.txt` | Backup directory |

**Same blind spot. Same file extension. Same instinct — *"I'd better keep a copy of this somewhere safe."***

> 🔴 **The backup directory is the worst place to keep a secret, precisely because it is the safest place to keep everything else.** **Its whole job is to survive, be copied, and travel.**

## Actions taken

| Action | State |
|---|---|
| `chmod 600` — close the world-readable permission | ✅ **Done 2026-07-14.** Confirmed: `-rw-------` |
| Confirm the token is hashed, not plaintext | ✅ **Done.** Argon2 in both the live container and the copy. |
| Confirm the file is a **copy**, not the live config | ✅ **Done.** The live env is in the container (`docker inspect`). **This `.txt` is a stray.** |

## Outstanding

- [ ] **Delete `~/atlas-backup/vaultwarden-container-env.txt`.** The real config lives in the container. **This copy protects nothing and travels with every backup.**
- [ ] **Decide how Vaultwarden's config is actually preserved for a rebuild** — a `docker-compose.yml` in the repo (with the token *referenced*, never embedded), or the env inside the encrypted archive. **Not a loose `.txt` beside it.**
- [ ] **Rotate the admin token** if there is any chance the `.txt` predates the hashing.
- [ ] `018` — add: *"a secret-shaped file in a backup directory is a secret you are actively preserving and shipping off-device."*
- [ ] Closed

> 🔴 **Does not move to `Closed` while any box is unticked.**

## Note

**This is not a Book 1 blocker** — Vaultwarden is not Book 1 scope, and the freeze does not wait on it.

**It is recorded because it was found, and because the honest severity is "low, and it is the same mistake we made twice today."**

> **We went looking for one secret in a `.txt` and found a second one, nine minutes older, in the directory designed to keep things forever.** **`CM-0014` was not a one-off. It was a habit** — the same habit `CM-0010` named when it found **three** `.bak` files from a single date: *"three `.bak` files from one date is a habit, not an accident."*

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 during `CM-0014`'s Phase 0 inventory. World-readable permission closed immediately. Token confirmed Argon2-hashed in both the live container and the copy — **severity verified as low rather than assumed high.** Deletion and config-preservation decisions outstanding. |
