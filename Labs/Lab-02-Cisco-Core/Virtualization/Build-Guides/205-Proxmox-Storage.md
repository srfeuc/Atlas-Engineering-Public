---
Title: Proxmox Storage Configuration
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Proxmox Storage Configuration

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 Procedure (target-state). The **verified state** lives in `../Build-Records/PVE01-Storage.md` (authoritative, `POL-0008`); wired in the #22 audit 2026-07-30. |
| Version | 1.1 |
| Applies To | PVE01 — Proxmox VE 8.4.19 (Debian 12) |

## Purpose

Document and validate PVE01's storage layout for ISO/template content and VM disks.

> 🔴 **Authoritative verified state = `../Build-Records/PVE01-Storage.md` (`POL-0008`).** This guide is the **procedure**; the record holds the device-verified reality (`local` ~94 GB dir, `local-lvm` ~793 GB LVM-thin + 8 GiB swap, from `pvesm status` 2026-07-16). 🟡 **Still to read back** (per the record + `Reference/217-Verified-Facts`): the **Dell PERC RAID controller + virtual-disk layout** (RAID level, disk count/size backing the datastores) and current free-space / thin-pool data% — capture on the device, flip 🟡→✅ in the record (`POL-0001`).

## Current Baseline

| Storage | Type | Approximate size | Purpose |
|---|---|---:|---|
| `local` | Directory | 94 GB | ISOs, snippets, templates, optional local backups |
| `local-lvm` | LVM-thin | 793 GB | VM and template disks |

## Prerequisites

- Proxmox VE installed

## Implementation

### 1. Content Placement

`local` — use for ISO images, the VirtIO driver ISO, container templates, snippets, temporary or explicitly approved backups.

`local-lvm` — use for VM disks, template disks, EFI disks, TPM state disks.

### 2. Upload Installation Media

From the Proxmox UI:

1. Select `pve01`.
2. Select `local`.
3. Select **ISO Images**.
4. Upload Windows Server 2025 ISO and `virtio-win.iso`.

Or use a controlled copy method and verify checksums.

### 3. Storage Standards

- Keep sufficient free space in the thin pool.
- Do not treat snapshots as backups.
- Monitor thin-pool data and metadata usage.
- Do not store the only copy of backups on PVE01.
- Future PBS and TrueNAS integration must be documented separately — not part of this baseline.

## Validation

```bash
lsblk
df -h
pvesm status
lvs
vgs
pvs
pvesm list local
pvesm list local-lvm
```

- `local` active
- `local-lvm` active
- Windows and VirtIO ISOs present
- Thin pool has adequate capacity
- No storage errors

## Common Mistakes

- Confusing a Proxmox snapshot with an actual backup — snapshots share the same underlying storage and don't protect against storage-level failure.
- Letting the thin-pool metadata volume fill up silently — monitor it explicitly, not just the data volume.

## Rollback

Not applicable at the storage-layout level — restoring from backup is the recovery path for storage failures, not a rollback of this guide.

## Completion Checklist

- [x] `local` and `local-lvm` both active
- [x] Windows Server 2025 and VirtIO ISOs uploaded
- [x] Thin pool capacity confirmed adequate
- [ ] PBS/TrueNAS integration — explicitly out of scope for this baseline, tracked separately

## Change Log

| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit — wired to the authoritative record.** Added the `PVE01-Storage.md` (`POL-0008`) pointer + the 🟡 RAID-controller/virtual-disk + free-space/thin-pool read-backs still owed (`217-Verified-Facts`); fixed the `pvsm`→**`pvesm`** command typo in Validation. The `local` (~94 GB) / `local-lvm` (~793 GB LVM-thin) baseline was already correct and unchanged. |
| 1.0 | Initial storage-layout guide (baseline: `local` dir + `local-lvm` thin). |

## Next Guide

Proxmox Authentication and Named Administration.
