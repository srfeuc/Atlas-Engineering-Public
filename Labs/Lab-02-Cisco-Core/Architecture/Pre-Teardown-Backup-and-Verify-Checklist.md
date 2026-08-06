---
Title: Lab-02 Pre-Teardown Backup & Restore-Verify Checklist
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Target Design — do this BEFORE wiping any device. You run the commands (Charter Locked Rule 17).
Version: 1.0
---

# Lab-02 — Pre-Teardown Backup & Restore-Verify Checklist

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **The plan:** tear down every device and rebuild from scratch **except PVE01**, then build Lab-02 greenfield. **This checklist is the gate before the first wipe.** Grounds: `POL-0005` (Backup & Recovery — 3-2-1, restore-tested), `ADR-0011` (Game Days), `ADR-0009` (never converge the CA key with a networked box), `POL-0002` (secrets). Design + validation only — you run it.

## 🔴 The one rule

> **Do not wipe a device until its irreplaceable data is (1) backed up, (2) restore‑*verified*, and (3) copied to a second location. A backup you have not opened is not a backup.**

Greenfield changes what the backups are *for*: **you will NOT restore old configs onto the new build** (new roles, new CA, corrected design). The backups are the **safety net** (rollback if the rebuild fails), the **secret source** (vault data to carry forward), and the **reference** (what it was). Nothing here gets restored *onto* Lab-02.

## Crown-jewels handling (read first)

- 🔴 **Decrypt and verify the Pi01 backup only on a local, ideally air‑gapped machine — never in a cloud session or on a networked box.** It contains the Root CA private key; `ADR-0009` exists because that key and its passphrase once sat on one networked machine for fifteen hours.
- 🔴 **Confirm you have the passphrase in a place that survives the teardown** (VAULT01 isn't built yet, and Vaultwarden is *on the Pi you're about to wipe*). Write it down offline, or you will encrypt a backup you can never open.
- **The passphrase never goes in git, a `.txt` by the archive, or a chat** (`POL-0002`).

## Per-device pre-teardown checklist

### Pi01 — the crown jewels
- [ ] **Verify the 07‑13 archive against its checksum:** `Get-FileHash -Algorithm SHA256 atlas-pi01-2026-07-13.tar.gz` must equal `c46039c3b9e55b733485d25a66fcd95b576443ee9f64277bc0dbbc7064a4219e`. *(You uploaded only the `.sha256`, not the archive — find the archive on `E:\` and confirm it exists first.)*
- [ ] 🔴 **Decrypt the 07‑14 `.gpg` locally and confirm it opens** — `gpg --decrypt ...0714.tar.gz.gpg | tar -tz` should list the contents without error. **If it doesn't decrypt, Pi01 cannot be wiped yet.**
- [ ] **Extract what carries forward** — the Vaultwarden data (so stored passwords survive into the new VAULT01), and any secrets you still need. Do this from the *decrypted* copy, locally.
- [ ] **Confirm the archive actually contains the CA tree** (`/etc/ssl/lab-ca` or equivalent) and the vault — `tar -tz` the decrypted stream and eyeball it. A backup missing the key material is the `048`/`CM-0010` failure.

### MKT01 — binary backup is not enough
- [ ] **You have `Final Core router backup.backup`** (binary, restore‑only‑to‑RouterOS). **Also export a text `/export`** (`.rsc`) — readable, diffable, and the only form you can actually *reference* while rebuilding. A `.backup` you can't read teaches you nothing.
- [ ] **Note: you will NOT restore this.** MKT01's new role is the east‑west firewall (`ADR-0023`), not the core router — its old config is wrong for the new role. Reference only.

### SW01 — 🔴 no backup exists
- [ ] **Export the running config before you touch it** — `show running-config` captured to a file, and `copy running-config` to TFTP/USB. Without this, the record of SW01's VLANs, DHCP‑snooping, DAI, and SPAN is gone.
- [ ] **Capture `show vlan`, `show interfaces status`, `show mac address-table`** — the live state the new build reconciles against (and the seed for NetBox).

### FGT01 — 🔴 no backup exists
- [ ] **Take a full config backup** (GUI: System → Configuration → Backup, or CLI `execute backup config`). Encrypt it — it holds policy and secrets.
- [ ] **Record the break‑glass details** (`192.168.1.99`, console) so you can recover the rebuilt unit.

### 1941 — new device
- [ ] **After racking, capture its factory/starting `show version` + `show run`** so there's a known baseline before you configure it.

## 3‑2‑1 and off‑site (`POL-0005`)
- [ ] **`E:\` is one copy.** Good — but if every backup lives only on `E:\`, one event (fire, theft, drive failure) loses everything, including the Root CA. **Make one more copy off‑site** (a second encrypted drive taken elsewhere, or an encrypted upload) before the teardown.
- [ ] **A backup is not real until a restore has succeeded** — the Pi01 decrypt test above *is* that restore test. Do it now, while the source still exists.

## Safe teardown sequence
1. **Export/verify everything above.** SW01 + FGT01 configs out; Pi01 backups decrypt‑tested; vault data extracted; one off‑site copy made.
2. **Only then** begin wiping.
3. **Rebuild network‑first** (1941 core, MKT01 east‑west, SW01, FGT01 per the role/checklist docs), then **PVE01 services — NetBox first** (source of truth from the start), then the **greenfield offline‑Root CA**, then the **identity track** (DC).
4. During rebuild the old backups stay on `E:\` as the rollback path until Lab-02 is verified and frozen.

## Failure modes
- 🔴 **Wiping Pi01 with an unopened `.gpg`** — if the passphrase is wrong/lost (and it lived in the Vaultwarden you just erased), the CA and every stored secret are gone permanently.
- 🔴 **No SW01/FGT01 export** — you rebuild from memory, and memory is Rank 6 (Charter Rule 13).
- 🔴 **Restoring the old MKT01 `.backup`** onto the new east‑west firewall — wrong role, wrong config; reference only.
- **All copies on `E:\`** — not 3‑2‑1; one event is total loss.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Pre-teardown gate for the full Lab-01→Lab-02 rebuild (all devices except PVE01). Inventories the three existing backups (Pi01 encrypted + checksum, MKT01 binary), flags the two devices with NO backup (SW01, FGT01) and the untested Pi01 restore, and sets the safe sequence: export/verify/off-site before the first wipe; decrypt the CA backup locally only (`ADR-0009`); greenfield means reference-not-restore. |
