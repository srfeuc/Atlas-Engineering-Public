---
Title: Install Windows Server 2025
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Install Windows Server 2025

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — key steps confirmed against a recovered build session transcript |
| Version | 1.1 |
| Applies To | PVE01 |

## Purpose

Install Windows Server 2025 into the Proxmox build VM without joining a domain or embedding environment-specific configuration.

## Confirmed Historical Facts

From a recovered build session transcript (real `systeminfo`/`Get-ComputerInfo` output, not reconstructed):

| Item | Confirmed value |
|---|---|
| Edition | Windows Server 2025 **Standard, Evaluation license** |
| Build | 10.0.26100 |
| Original install date | 6/29/2026 |
| Hostname immediately post-install | `WIN-QBDOACQH9LR` (Windows default), before rename to `WIN2025-BUILD` |
| Domain | WORKGROUP — confirms no premature domain join |
| Disk bus used | **IDE — VirtIO storage drivers were never installed or needed.** Confirmed via a direct driver/service audit later in the same build (only VirtIO Balloon and Serial drivers were ever present) |

> **Evaluation license note:** evaluation editions have a limited activation window (commonly ~180 days) before the server begins periodic forced shutdowns. Run `slmgr /dlv` on any VM built from this image to check remaining evaluation time before it becomes an outage rather than a paperwork item.

## Implementation

### 1. Installation

1. Boot from the Windows Server 2025 ISO.
2. Select language, time, keyboard, and regional settings.
3. Select **Install now**.
4. Choose the edition — **Standard** confirmed as the edition actually used.
5. For a reusable administrative template, use the Desktop Experience edition when GUI management is required.
6. Accept the license.
7. Choose **Custom installation**.
8. Select the 32 GB virtual disk. **The disk was visible without loading a VirtIO storage driver — the build used the IDE controller throughout, confirmed historically, not just inferred from the final template config.**
9. Install Windows.
10. Allow the VM to reboot.
11. Do not boot from the ISO again after the first reboot.
12. Set the local Administrator password.
13. Log in locally.

### 2. Initial Identity

Use a temporary computer name during image construction, such as `WIN2025-BUILD`.

Do not: join the domain, use `DC01` as the image name, assign a production static IP, install AD DS, create environment-specific DNS records.

### 3. Confirm UEFI and Secure Boot

```powershell
Confirm-SecureBootUEFI
Get-Tpm
Get-ComputerInfo | Select-Object BiosFirmwareType
```

Expected: Secure Boot True (when enabled and supported), TPM present and ready, firmware type UEFI.

### 4. Update Boot Order

After installation, make the system disk first in the Proxmox boot order. Keep network boot only when required.

## Validation

- Windows reaches the desktop
- Local Administrator login works
- System disk is healthy
- UEFI confirmed
- TPM visible
- No domain membership
- No production identity embedded

## Common Mistakes

- Assuming a VirtIO storage driver load step is required — it wasn't, for this baseline. Don't add unnecessary steps to the procedure based on a generic VirtIO guide rather than what this environment actually needs.
- Renaming or joining the domain too early, before Sysprep — breaks the reusability of the template.

## Lessons Learned from Actual Deployment

The build VM briefly held IP `10.10.0.50` during installation, per the recovered session's `systeminfo` capture. That's the same address later documented elsewhere as the admin workstation / FreeRADIUS `laptop` client address. No confirmed conflict, but worth a sanity check before assigning any permanent static address in that range to a Windows VM going forward.

## Rollback

Delete and recreate the build VM — nothing is committed until Sysprep and template conversion.

## Completion Checklist

- [x] Windows Server 2025 Standard Evaluation installed
- [x] Reaches desktop, local Administrator login works
- [x] UEFI and TPM confirmed
- [x] No domain membership
- [ ] Evaluation license remaining time — check via `slmgr /dlv` before this image is relied on long-term

## Next Guide

Install VirtIO Drivers and QEMU Guest Agent.
