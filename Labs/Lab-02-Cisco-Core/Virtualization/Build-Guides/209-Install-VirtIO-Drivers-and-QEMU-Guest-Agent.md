---
Title: Install VirtIO Drivers and QEMU Guest Agent
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Install VirtIO Drivers and QEMU Guest Agent

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — confirmed against a recovered build session driver audit |
| Version | 1.1 |
| Applies To | PVE01 |

## Purpose

Install the Proxmox-optimized Windows drivers and guest integration services.

## Confirmed Historical Fact

A driver/service audit captured in a recovered build session confirms **only the VirtIO Balloon Driver and VirtIO Serial Driver were ever installed**, both running, with their corresponding services (VirtIO Balloon Service, VirtIO Serial Service) also running. VirtIO storage and network drivers were never installed — consistent with the final template's IDE disk and E1000 NIC.

## Prerequisites

- Windows Server 2025 installed (`208-Install-Windows-Server-2025.md`)
- VirtIO ISO mounted as a CD/DVD device

## Implementation

### 1. Verify the VirtIO ISO

The VM should have `virtio-win.iso` mounted as a CD/DVD device.

### 2. Install Drivers

From Windows:

1. Open the VirtIO CD.
2. Run the guest tools installer when available.
3. Install: Balloon driver (confirmed used), Serial driver (confirmed used, required by the guest agent), QEMU Guest Agent.

**Do not install the network or SCSI/storage drivers for the current baseline** — the verified template intentionally uses E1000 and IDE. The VirtIO ISO remains mounted for driver availability and possible future migration, not because those drivers are in active use.

### 3. Install QEMU Guest Agent

```powershell
Get-Service QEMU-GA
```

Expected: `Status: Running`, `StartType: Automatic`.

From Proxmox:

```bash
qm agent <VMID> ping
```

### 4. Device Manager Validation

```powershell
Get-PnpDevice | Where-Object Status -ne 'OK'
```

Investigate unknown or failed devices before generalizing the image.

### 5. Proxmox Setting

The VM configuration must include:

```text
agent: 1,type=virtio
```

## Validation

- QEMU Guest Agent running
- `qm agent <VMID> ping` succeeds
- No unknown devices
- Balloon and Serial drivers installed and running
- Reboot succeeds

## Common Mistakes

- Installing the full VirtIO driver suite "to be safe" instead of only what the verified baseline actually uses — adds untested surface area to the template for no confirmed benefit.

## Lessons Learned from Actual Deployment

This is one of the few places where a real historical audit changed the plan mid-build: VirtIO network and storage driver installation was originally planned, then explicitly dropped once the Balloon/Serial audit confirmed the integration Windows actually needed was already present and working. Document what's installed and why, rather than reflexively installing every available driver.

## Optional Future Migration — Not Part of the Current Baseline

### To VirtIO NIC

Only after the VirtIO network driver is installed: add a second VirtIO NIC temporarily, boot Windows, confirm the driver loads, record network adapter changes, remove the E1000 NIC only after connectivity is verified, generalize again if the hardware change affects the image. Do not change the production template merely for theoretical performance improvement — test a clone first.

### To SCSI Disk

Only after storage drivers are installed and boot recovery is available: clone the template or source VM, change the disk bus on the clone, confirm Windows boots, confirm Device Manager and event logs, run performance and restart tests, adopt through Change Management.

## Rollback

Uninstall the driver via Device Manager or Programs and Features if a driver causes instability; QEMU Guest Agent can be reinstalled from the same ISO.

## Completion Checklist

- [x] QEMU Guest Agent running
- [x] `qm agent <VMID> ping` succeeds
- [x] Balloon and Serial drivers confirmed installed and running
- [x] No VirtIO storage/network drivers installed (by design, confirmed)
- [x] No unknown devices

## Next Guide

Windows Server Base Configuration.
