---
Title: SRV01 / SFTP-TFTP — Build Checklist (IOS image/config transfer)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services/Roles/SFTP-TFTP
Status: 📋 Planned — file transfer. Host build = `../../Build-Checklist.md`.
Version: 1.0
Date: 2026-07-29
---

# SRV01 / SFTP-TFTP — IOS image/config transfer

> `tftpd-hpa` for IOS image/config transfer (CCNA + device backups); **SFTP** as the secure equivalent — prefer it for anything sensitive.

## Deps
- [ ] Host built + role firewall (TFTP/SFTP ports, scoped to the mgmt/lab segments).

## Steps
- [ ] Install `tftpd-hpa`; set the TFTP root; restrict source networks.
- [ ] Enable SFTP (chrooted account) for secure transfers.

## Accept (`POL-0001`)
- [ ] A TFTP transfer succeeds (e.g., copy an IOS config off a device); an SFTP `put/get` succeeds.

## Related
- `../../Build-Checklist.md` §3 · `../../Considerations.md`.
