---
Title: Convert the Golden Image to Template
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Convert the Golden Image to Template

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — matches live `qm config 9000` |
| Version | 1.0 |
| Applies To | PVE01 |

## Purpose

Convert the generalized Windows Server 2025 VM into the reusable Atlas template.

## Target

| Item | Value |
|---|---|
| VMID | 9000 |
| Name | `TPL-WIN2025` |
| Type | Proxmox VM template |

## Prerequisites

- Sysprep completed (`211-Prepare-the-Golden-Image-Sysprep.md`)
- VM is stopped
- VM has not booted after Sysprep
- Build VM configuration recorded
- Archive or rollback copy retained (VMID 100)
- VMID 9000 available

## Implementation

### 1. Rename and Assign VMID

If the source VM does not already use VMID 9000, clone or move it according to the approved process. Avoid risky manual manipulation of `/etc/pve/qemu-server` files when GUI or `qm` operations can accomplish the task safely.

### 2. Convert (GUI)

1. Confirm VM is stopped.
2. Right-click the VM.
3. Select **Convert to template**.
4. Confirm.
5. Rename to `TPL-WIN2025` if required.

### 3. Convert (CLI)

```bash
qm template 9000
```

Use the correct VMID for the generalized source.

## Validation

```bash
qm list
qm config 9000
```

Expected: `template: 1`, `name: TPL-WIN2025`.

### Verified Current Template Configuration

```text
agent: 1,type=virtio
bios: ovmf
boot: order=ide0;net0
cores: 2
cpu: x86-64-v2-AES
efidisk0: local-lvm:base-9000-disk-0,efitype=4m,ms-cert=2023k,pre-enrolled-keys=1,size=4M
ide0: local-lvm:base-9000-disk-1,size=32G
ide1: local:iso/virtio-win.iso,media=cdrom
machine: pc-q35-9.2+pve1
memory: 8192
name: TPL-WIN2025
net0: e1000=<template-mac>,bridge=vmbr0,firewall=1
numa: 0
ostype: win11
scsihw: virtio-scsi-single
sockets: 1
template: 1
tpmstate0: local-lvm:base-9000-disk-2,size=4M,version=v2.0
```

The live MAC, UUID, VM generation ID, and creation timestamps are instance identifiers and should not be copied into a new build.

## Common Mistakes

- Editing `/etc/pve/qemu-server/*.conf` directly instead of using `qm` or the GUI — risk of a malformed config with no safety checks.
- Converting before confirming the VM never rebooted after Sysprep — even one boot begins specialization.

## Lessons Learned from Actual Deployment

The `ostype: win11` setting is used for this Windows Server 2025 template — worth periodically re-checking whether a dedicated Server 2025 guest type becomes available in a future Proxmox version, since `win11` is currently the closest match, not necessarily the ideal one.

## Rollback

Convert the template back to a regular VM (`qm set 9000 --template 0` is not directly supported by Proxmox in all versions — check current `qm` documentation, or restore from the retained archive VMID 100 and redo the golden-image process).

## Completion Checklist

- [x] VMID 9000 appears as a template
- [x] Template cannot be started directly
- [x] EFI and TPM state disks exist
- [x] Main disk exists
- [x] QEMU Agent enabled
- [x] Template configuration archived (see above)

## Next Guide

Clone the Windows Server Template.
