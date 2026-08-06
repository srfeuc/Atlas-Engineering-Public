---
Title: Create the Windows Server 2025 Build VM
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Create the Windows Server 2025 Build VM

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified target state — hardware spec confirmed against live `qm config 9000` |
| Version | 1.0 |
| Applies To | PVE01 |

## Purpose

Create the source VM used to install, standardize, generalize, and convert Windows Server 2025 into the Atlas golden template.

## Naming and VMID

| VM | VMID | Name |
|---|---:|---|
| Build VM (recommended) | temporary | `WIN2025-BUILD` |
| Completed template | 9000 | `TPL-WIN2025` |
| Retained archive (this environment's actual first build) | 100 | `WIN2025-BUILD-ARCHIVE` |

## Prerequisites

- Windows Server 2025 ISO
- VirtIO Windows driver ISO
- Proxmox Storage guide complete, both ISOs uploaded to `local`

## Target Template Hardware

The live template 9000 uses:

| Setting | Value |
|---|---|
| BIOS | OVMF |
| Machine | `pc-q35-9.2+pve1` |
| CPU type | `x86-64-v2-AES` |
| Sockets | 1 |
| Cores | 2 |
| Memory | 8192 MB |
| Main disk | 32 GB, IDE (`ide0`) |
| EFI disk | 4 MB, Microsoft 2023 keys |
| Secure Boot | Pre-enrolled keys |
| TPM | Version 2.0 |
| NIC | E1000 |
| Bridge | `vmbr0` |
| Firewall | `firewall=1` set on the interface — note the global Proxmox firewall service is currently disabled (`pve-firewall status` = `disabled/running`), so this flag is presently inert |
| QEMU Agent | Enabled |
| Guest type | Windows 11 / Server 2022+ profile |

## Implementation

### 1. Create the VM (GUI)

**General:** Node `pve01`, temporary build VM ID, Name `WIN2025-BUILD`, Start at boot: No during construction.

**OS:** Select the Windows Server 2025 ISO. Guest OS type: Microsoft Windows. Version/profile: Windows 11 / Server 2022 or later. Add the VirtIO driver ISO as a second CD/DVD device.

**System:** Machine: Q35. BIOS: OVMF (UEFI). Add EFI Disk on `local-lvm`. Pre-enroll keys: Yes. Microsoft 2023 keys: use the setting matching the current template. Add TPM 2.0 on `local-lvm`. Enable QEMU Guest Agent.

**Disks:** The verified baseline uses a 32 GB IDE disk. A VirtIO SCSI disk may be preferable for a future improved template after driver validation — do not silently change the baseline without clone-boot and Sysprep testing first.

**CPU:** Type `x86-64-v2-AES`, 1 socket, 2 cores, NUMA off for this small VM.

**Memory:** 8192 MB. Ballooning only if Atlas adopts and validates it.

**Network:** Bridge `vmbr0`. Model: E1000 for the verified baseline. VLAN tag: leave unset during generic template creation unless build access requires one. Firewall: enabled (see note above on current inert status).

### 2. Review Hardware Before Starting

Verify: Windows ISO mounted, VirtIO ISO mounted, EFI disk present, TPM 2.0 present, OVMF selected, Q35 selected, boot order includes the installation ISO for first boot, disk and NIC present.

### 3. Start the VM

Open the console and boot into Windows Setup.

## Validation

- VM boots in UEFI mode
- Windows Setup starts
- Disk is visible or can be made visible with VirtIO drivers
- TPM and Secure Boot settings are present
- Network hardware is available after drivers are installed

## Common Mistakes

- Enabling ballooning without validating it first — leave off unless there's a specific, tested reason to use it.
- Changing the disk bus from IDE to VirtIO SCSI on the production template without testing a clone first — the verified baseline intentionally uses IDE.

## Lessons Learned from Actual Deployment

The live template's `firewall=1` setting on the network interface does nothing on its own — the global Proxmox firewall (`pve-firewall`) is disabled at the datacenter level on this host. Don't assume a per-VM firewall flag is providing protection without checking the global service state.

## Rollback

Delete the build VM and start over — nothing is committed until conversion to template.

## Completion Checklist

- [x] Hardware profile matches verified template baseline
- [x] VM boots to Windows Setup in UEFI mode
- [ ] Confirm VirtIO ISO driver availability during install (see next guide)

## Next Guide

Install Windows Server 2025.
