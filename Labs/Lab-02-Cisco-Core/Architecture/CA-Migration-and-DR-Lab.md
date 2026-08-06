---
Title: Lab — OpenSSL CA Migration & Disaster Recovery
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Target Design — a documented lab exercise. You run the openssl; nothing production is at stake.
Version: 1.0
---

# Lab — OpenSSL CA Migration & Disaster Recovery

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **The exercise:** migrate the **old Pi01 OpenSSL CA** onto a proper host as a documented lab — *and then* restore it from backup as a disaster‑recovery drill. You're retiring that CA for the greenfield one anyway (`Lab-02-Offline-Root-CA-Build-Design.md`), so it's the **perfect practice subject: a real CA with real key material and nothing to lose.** Teaches PKI internals and DR at a level "Install AD CS → Next" never does. Grounds: `ADR-0009` (secure key handling), `POL-0005` (backup/restore), `ADR-0011` (Game Days). An advanced scenario — do it after the Lab‑02 core is stable.

## Part 1 — A CA is just files (this is the whole insight)

An OpenSSL CA is not magic; it's a directory:

| File / dir | What it is | Why it matters to migration/DR |
|---|---|---|
| `private/ca.key.pem` | 🔴 **the CA private key** (passphrase‑encrypted) | the crown jewel — lose it and the CA is dead; expose it and the CA is compromised (`ADR-0009`) |
| `certs/ca.cert.pem` | the CA certificate (public) | goes in trust stores; safe to copy |
| `openssl.cnf` | the CA config (paths, policies, extensions) | must be repointed at the new host's paths |
| `index.txt` | 🔴 **the database of every cert ever issued** | your **only** record of what's out there and what's revoked — lose it and revocation is blind |
| `serial` / `crlnumber` | next serial / next CRL number | lose them and you get **serial collisions** (two certs, same serial) |
| `newcerts/`, `issued/`, `crl/` | issued cert archive, published CRLs | the working history |

> **Migration = copy these files, repoint `openssl.cnf`, done.** DR = the same thing, from a backup, onto new hardware. The "hard" part is never the copy — it's doing it **securely** and **completely.**

## Part 2 — The migration lab

**Gate:** the old Pi01 CA backup on `E:\` (the `.tar.gz.gpg`) + its passphrase (offline). An isolated target — a VM on **VLAN 70 (Testing)**, so a mistake touches nothing real.

- [ ] **Decrypt the backup locally** (not in any cloud/networked context — `ADR-0009`): `gpg --decrypt … | tar -xz` into the target host.
- [ ] **Confirm the backup was complete** — the key, cert, `index.txt`, `serial`, `crlnumber`, and `newcerts/` are all there. 🔴 A backup missing the key material is the `048`/`CM-0010` failure — better to find that here than in a real outage.
- [ ] **Recreate the CA directory layout** on the new host and **repoint `openssl.cnf`** at the new paths.
- [ ] **Fix permissions** — the key `600`, owned by the CA user; the dir not world‑readable.
- [ ] 🔴 **Secure the key in transit and destroy intermediate copies** — the decrypted tar, any scratch copies (`ADR-0009`'s missing‑destroy‑step lesson). On a *real* production CA this is an air‑gapped operation; on this retired practice CA it's lower stakes, but **practice the discipline anyway** — that's the point.
- [ ] **Prove the CA operates from the migrated state:** issue a **test** cert, then **revoke** it, then **regenerate the CRL** — all continuing from the preserved `index.txt`/`serial`.

**Validate:** the migrated CA issues a cert that validates against the existing chain (`openssl verify`); the new serial is the *next* one (no collision with history); the revoked test cert appears in the CRL; `index.txt` reconciles with what's deployed.

## Part 3 — Disaster Recovery (the same skill, framed as an outage)

**The scenario:** *"the CA host is gone — a dead disk, a lost VM. Restore it from backup onto new hardware, fast, and prove it still works."* That is Part 2, under time pressure, and it's an `ADR-0011` Game Day.

- [ ] **RPO — how fresh?** How old is the newest backup? Any cert issued *after* it is unknown to the restored `index.txt`. Decide your acceptable data‑loss window.
- [ ] **RTO — how fast?** Time yourself. From "host is dead" to "CA issuing again" — that number is your RTO, and it's a real interview answer.
- [ ] **Run the restore blind** — from the backup + the offline passphrase only, as if the original is truly gone. 🔴 **This is where you learn whether the passphrase survived** — if it lived only in the Vaultwarden on the box you lost, the backup is a brick (`ADR-0009`; and why VAULT01 + an offline copy exist).
- [ ] **Prove the restored CA is the same CA** — same subject, same key, issues/revokes, chain validates. A restore that produces a *different* CA hasn't recovered anything.

**Validate (the DR pass):** issue + revoke + CRL from the restored host; `index.txt` matches deployed certs; the restored CA cert fingerprint equals the original. Record the RTO.

## Failure modes
- 🔴 **Key exposed** — decrypting/copying on a networked box, or leaving the decrypted tar around (`ADR-0009`). Air‑gap for real CAs; destroy scratch copies always.
- 🔴 **`index.txt`/`serial` lost** — serial collisions and a blind revocation history. The database is as important as the key.
- 🔴 **Passphrase gone** — it lived only in the vault you also lost. Keep it offline; that's the `ADR-0009` convergence lesson in reverse.
- 🔴 **Backup was incomplete** — no key, or a pre‑change `index.txt` (`048`). DR is the test that proves the backup was real (`POL-0005`).
- **Doing it on production without an isolated dry run** — always rehearse on the VLAN‑70 copy first.

## Portfolio note
"CA migration and disaster recovery — RTO/RPO, secure key handling, and a tested restore" is a genuinely strong write‑up. Capture the RTO number and a screenshot of the restored CA issuing a cert.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Advanced-scenario lab: migrate the retired Pi01 OpenSSL CA to a proper host, then restore it from backup as an `ADR-0011` DR Game Day. Part 1 (a CA is just files: key, cert, config, index.txt/serial/crlnumber), Part 2 (the migration, with secure handling per `ADR-0009`), Part 3 (DR framing with RPO/RTO and the passphrase-survival test). Practice subject is the retired CA, so nothing production is at risk. Referenced from `Atlas-Roadmap-Advanced-Scenarios.md`. |
