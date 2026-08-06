---
Title: Windows Server 2025 Base Configuration
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Windows Server 2025 Base Configuration

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified target state |
| Version | 1.0 |
| Applies To | PVE01 |

## Purpose

Standardize Windows Server 2025 before it becomes a golden image.

## Prerequisites

- VirtIO drivers and QEMU Guest Agent installed (`209-Install-VirtIO-Drivers-and-QEMU-Guest-Agent.md`)

## Implementation

### 1. Identity and Workgroup

Keep the image in a workgroup. Do not join the domain. Use a temporary build name. Use DHCP or a temporary build address. Do not retain production DNS settings.

```powershell
Get-ComputerInfo | Select-Object CsName,CsDomain,CsDomainRole
```

### 2. Time and Region

```powershell
Set-TimeZone -Id "Central Standard Time"
Get-TimeZone
```

Configure required regional and keyboard settings.

### 3. Windows Update

Use Settings, Server Manager, or approved PowerShell tooling to install all applicable updates. Repeat until no required updates remain. Reboot between cycles.

```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 20
```

> A recovered build session captured only 3 hotfixes (`KB5066131`, `KB5073379`, `KB5072725`) at a mid-build snapshot — that is not confirmed as the final update level at Sysprep. Re-run this step to current before generalizing rather than assuming the historical snapshot is complete.

### 4. Power Configuration

For a server VM, avoid sleep and hibernation.

```powershell
powercfg /hibernate off
powercfg /change standby-timeout-ac 0
powercfg /getactivescheme
```

### 5. Remote Management

Enable only what Atlas requires: Remote Desktop, PowerShell Remoting, Windows Remote Management, Windows Firewall rules, Server Manager remote management. Do not permanently open broad firewall access in a generic image — prefer domain policy after deployment.

### 6. Local Accounts

The verified Proxmox named account is `seth-admin@pve`; that is not automatically a Windows account.

For the Windows image: retain the built-in local Administrator for deployment and recovery; create a named local administrator only if Atlas has formally approved the naming and password-management approach; do not embed a shared long-lived password in the template; plan Windows LAPS after domain deployment.

> **Open question, not yet resolved:** whether a Windows local account named `seth-admin` (or similar) was actually created on the real build is unconfirmed — a historical record referencing it was planned but never actually written with evidence. Do not assume it exists; check the archive VM (VMID 100) offline if this needs to be settled.

### 7. Base Software

Install only universally required components — VirtIO drivers, QEMU Guest Agent, approved management tools, required Windows servicing components. Do not install AD DS, DNS, DHCP, CA roles, monitoring server roles, or workload-specific applications.

### 8. Defender and Firewall

Keep Microsoft Defender and Windows Firewall enabled. Do not weaken security merely to simplify deployment.

```powershell
Get-MpComputerStatus
Get-NetFirewallProfile
```

### 9. Event Log and Health Review

```powershell
Get-WinEvent -LogName System -MaxEvents 100 |
  Where-Object LevelDisplayName -in 'Critical','Error'

DISM /Online /Cleanup-Image /CheckHealth
sfc /scannow
```

Resolve unexplained critical issues before generalization.

### 10. Cleanup

```powershell
Dism.exe /Online /Cleanup-Image /StartComponentCleanup
```

Clear temporary files through supported tools. Do not use aggressive cleanup scripts that could damage servicing.

## Validation

- Fully patched
- Correct time zone
- No sleep or hibernation
- Defender and firewall enabled
- QEMU Guest Agent healthy
- No domain membership
- No production static IP
- No unexplained device or event errors

## Common Mistakes

- Treating a mid-build Windows Update snapshot as the final patch level — always re-verify current before Sysprep.
- Assuming the `seth-admin` local account exists on the image without checking — it's genuinely unconfirmed, not just undocumented.

## Rollback

Revert individual settings via the same PowerShell cmdlets used to set them; a full rollback means discarding the build VM and starting from a fresh install.

## Completion Checklist

- [x] Workgroup, no domain join
- [ ] Windows fully patched — re-verify current level before Sysprep, don't rely on the historical 3-hotfix snapshot
- [x] Time zone correct
- [x] No sleep/hibernation
- [x] Defender and firewall enabled
- [ ] `seth-admin` local account existence — unresolved, check offline if needed

## Next Guide

Prepare the Golden Image.
