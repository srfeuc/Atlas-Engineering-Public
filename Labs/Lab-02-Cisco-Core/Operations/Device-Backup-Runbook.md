---
Title: Lab-02 Device Backup Runbook
Path: Labs/Lab-02-Cisco-Core/Operations
Status: Operational runbook — real commands, run as-is. Reusable, not one-time.
Version: 1.1
---

# Device Backup Runbook — How to Back Up Every Atlas Device

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Two artifacts per device, every time:** a **binary/full backup** (restores the device) and a **text config export** (readable, diffable — the reference your future *build guides* are written from). Real commands here — backup is an operation, not the learning-objective config. Governs: `POL-0005` (Backup & Recovery). Secrets stay out of git (`POL-0002`) — these live on `E:\` + one off-site copy, never in the repo.

## Naming & storage convention
- **Name:** `atlas-<device>-YYYY-MM-DD.<ext>` (today: `2026-07-17`).
- **Store:** `E:\Atlas-Backups\<device>\` — and **one copy off-site** (3-2-1, `POL-0005`).
- **Verify:** after every backup, generate a SHA-256 and confirm the file opens/lists. A backup you haven't opened isn't one.

## File transfer (how bytes reach `E:\`)
- **MKT01 / Pi01 / PVE01** — **WinSCP** (SFTP) from your Windows box: connect to the device IP, drag the file to `E:\`.
- **SW01 / FGT01** — **tftpd64** (run it on your Windows box, point it at `E:\`), or a **USB stick** in the device, or **GUI download** (FortiGate).

---

## 1. MKT01 — MikroTik RouterOS

**On the device (Winbox terminal or SSH):**
```
# Binary full backup (restorable, includes secrets) — encrypt it
/system backup save name=atlas-mkt01-2026-07-17 password=<choose-a-strong-pw>

# Text export (readable reference; RouterOS 7 hides secrets by default)
/export file=atlas-mkt01-2026-07-17

# (Optional) fully-restorable text WITH secrets — this is a SECRET FILE, handle per POL-0002
# /export show-sensitive file=atlas-mkt01-2026-07-17-full
```
This creates `atlas-mkt01-2026-07-17.backup` and `atlas-mkt01-2026-07-17.rsc` in the device's Files.

**Retrieve:** WinSCP (SFTP) to MKT01 → drag both files to `E:\Atlas-Backups\MKT01\`. (Or in Winbox: Files → select → drag to your desktop.)

**Verify:** `Get-FileHash E:\Atlas-Backups\MKT01\atlas-mkt01-2026-07-17.backup -Algorithm SHA256` (PowerShell); open the `.rsc` in a text editor and confirm it's your config.

---

## 2. SW01 — Cisco IOS switch

**Simplest (session log = backup):** in PuTTY enable *Session → Logging → All session output* to `E:\Atlas-Backups\SW01\atlas-sw01-2026-07-17.log`, then:
```
terminal length 0
show running-config
show version
show vlan brief
show interfaces status
show mac address-table
```
The log file now holds the full config + the reference state (VLANs, ports, MACs — also your NetBox seed).

**Also save to NVRAM and export a clean copy:**
```
copy running-config startup-config

# to your TFTP server (tftpd64 pointed at E:\):
copy running-config tftp:
#   Address of remote host: <your-PC-IP>
#   Destination filename: atlas-sw01-2026-07-17.cfg

# OR to a USB stick in the switch:
copy running-config usbflash0:atlas-sw01-2026-07-17.cfg
```

**Verify:** open the `.cfg`/`.log` — it's plain text; confirm it ends with `end` and shows your interfaces.

---

## 3. FGT01 — FortiGate

**GUI (easiest):** *System → Configuration → Backup* → scope **Global**, toggle **Encryption** on (set a password), **Download** to `E:\Atlas-Backups\FGT01\atlas-fgt01-2026-07-17.conf`.

**CLI alternative:**
```
# to TFTP (tftpd64 on your PC):
execute backup config tftp atlas-fgt01-2026-07-17.conf <your-PC-IP>

# or to a USB stick:
execute backup config usb atlas-fgt01-2026-07-17.conf

# version reference:
get system status
```

**Verify:** the `.conf` is text (FortiOS CLI format); open it and confirm it starts with `#config-version=`. If you encrypted it, note the password offline (`POL-0002`).

---

## 4. Pi01 — Raspberry Pi (DNS + NTP)

> 🔴 **Pi01 is reduced to DNS + NTP** (`ADR-0009`; `Pi01-DNS-NTP` checklist). FreeRADIUS (`ADR-0029`) and the OpenSSL Lab CA (`ADR-0031`) are **retired**, and Vaultwarden moves off. The steady-state backup below covers **only** what still lives here — Pi‑hole + chrony + host files. **But retirement ≠ migrated yet:** the OpenSSL CA / RADIUS / Vault may still be physically on this SD card until the **D5 migrate‑and‑test** lab completes, so take the **pre‑migration full backup (A0)** first and only drop to the steady‑state backup once you've device‑confirmed they're gone.

**A0) Pre‑migration full backup — ONLY while the old roles still live on Pi01.** Until you've confirmed (Pi01 checklist gate: *"nothing still points at Pi01 for RADIUS/Vault/CA"*) that FreeRADIUS, the Lab CA, and Vaultwarden have moved off, back them up **before any wipe** so you don't destroy live CA keys / RADIUS secrets:
```
sudo tar -czvf /tmp/atlas-pi01-premigration-2026-07-17.tar.gz \
  /etc/pihole /etc/dnsmasq.d /etc/chrony* /etc/hostname /etc/hosts /etc/network \
  $( [ -d /etc/freeradius ] && echo /etc/freeradius ) \
  $( [ -d /etc/ssl/lab-ca ]  && echo /etc/ssl/lab-ca )
#   -v lists what went in; the `[ -d … ]` guards include a path only if it exists (no silent miss).
#   add the Vaultwarden data dir / docker volume if the vault still lives here.
gpg -c --cipher-algo AES256 /tmp/atlas-pi01-premigration-2026-07-17.tar.gz   # secrets: encrypt (POL-0002)
```
Plus the **SD‑card image (B)** below — the true pre‑wipe safety net for CA keys. **After migration is device‑confirmed, this A0 block is done** — use A) as the steady‑state backup.

**A) Config + data tarball (steady‑state — the reduced DNS+NTP Pi01).** On the Pi:
```
sudo tar -czvf /tmp/atlas-pi01-2026-07-17.tar.gz \
  /etc/pihole /etc/dnsmasq.d /etc/chrony* \
  /etc/hostname /etc/hosts /etc/network
#   -v (not 2>/dev/null): a missing path is VISIBLE, not silently swallowed. Adjust to what's installed.

# encrypt (Pi‑hole config can still hold upstream resolver creds/tokens):
gpg -c --cipher-algo AES256 /tmp/atlas-pi01-2026-07-17.tar.gz     # -> .tar.gz.gpg

# checksum:
sha256sum /tmp/atlas-pi01-2026-07-17.tar.gz.gpg > /tmp/atlas-pi01-2026-07-17.sha256
```
**Retrieve:** WinSCP the `.tar.gz.gpg` + `.sha256` to `E:\Atlas-Backups\Pi01\`.

**B) Full SD-card image (the real "put it all back" safety net — recommended before a wipe).**
- Shut the Pi down, pull the SD card, put it in your Windows PC.
- **Win32DiskImager** → *Read* → save to `E:\Atlas-Backups\Pi01\atlas-pi01-2026-07-17.img`. (Or in WSL/Linux: `sudo dd if=/dev/sdX of=atlas-pi01-2026-07-17.img bs=4M status=progress`.)
- This is a bit-for-bit clone you can reflash — the ultimate rollback.

**Verify:** `gpg --decrypt atlas-pi01-2026-07-17.tar.gz.gpg | tar -tz` lists the contents cleanly; the SHA-256 matches. **Do the decrypt test on your machine, never in a cloud session** (`ADR-0009`).

---

## 5. PVE01 — Proxmox (NOT being torn down; back it up anyway)

**Host config:** on PVE01:
```
tar -czf /root/atlas-pve01-etc-2026-07-17.tar.gz /etc/pve /etc/network/interfaces /etc/hostname /etc/hosts
```
**VMs (e.g. DC01):**
```
vzdump <vmid> --mode snapshot --compress zstd --dumpdir /var/lib/vz/dump
#   then WinSCP the resulting vzdump-*.vma.zst off to E:\
```
**Verify:** `vzdump` prints "Backup finished successfully"; the `.tar.gz` lists `/etc/pve`.

---

## 6. 1941 — new device
Nothing to back up yet. **After** you configure it, back it up the IOS way: `copy running-config startup-config` + `copy running-config tftp:` / USB (same as SW01).

---

## After every backup — the close-out
- [ ] Both artifacts (binary + text) on `E:\Atlas-Backups\<device>\`.
- [ ] SHA-256 generated and recorded.
- [ ] The file **opened/listed/decrypted** at least once — restore-verified, not assumed (`POL-0005`, `ADR-0011`).
- [ ] One copy **off-site**.
- [ ] Passphrases written **offline**, never in git or beside the archive (`POL-0002`).

## Change Log

| Version | Changes |
|---|---|
| 1.1 | 2026-07-28. **C1 backup-path safety fix (Review-Flag-Register).** §4 Pi01 header reduced from "DNS/NTP/RADIUS/CA/Vault" to **DNS + NTP** (the `ADR-0009` reduction). The steady-state tarball (A) **drops the dead `/etc/freeradius` + `/etc/ssl/lab-ca` paths** and replaces `2>/dev/null` with `-v` so a missing path is visible, not silently swallowed. Added a **gated pre-migration full backup (A0)** that still captures FreeRADIUS/Lab-CA/Vault **only while they physically remain on Pi01** (retirement per `ADR-0029`/`ADR-0031` is gated on the D5 migrate-and-test lab) — `[ -d … ]` guards include a path only if it exists — so a wipe can't destroy live CA keys before migration is device-confirmed. Pi01 checklist needed no change (already the reduced DNS+NTP build). |
| 1.0 | 2026-07-17. Reusable per-device backup procedures (binary full backup + readable text export) for MKT01, SW01, FGT01, Pi01, PVE01, and the future 1941 — with the transfer method, naming/storage convention, verification, and the 3-2-1/off-site close-out. Real commands; backup is an operation, not the learning-objective config. |
