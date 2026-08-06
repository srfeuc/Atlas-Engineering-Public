---
Title: Prepare the Windows Server 2025 Golden Image
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Prepare the Windows Server 2025 Golden Image

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Outcome confirmed; exact historical invocation not independently verified |
| Version | 1.1 |
| Applies To | PVE01 |

## Purpose

Prepare the standardized Windows Server 2025 source VM for Sysprep and template conversion.

## Evidence Status

Sysprep did complete successfully on the original build — this is now treated as confirmed, on two grounds:

1. Direct confirmation from the engineer who performed the build.
2. Strong independent circumstantial evidence: template 9000 (`TPL-WIN2025`) exists, carries `template: 1`, and was itself successfully cloned to produce VMID 101 (`DC01`) — confirmed via actual Proxmox `qmclone` task log evidence, not inference. A non-generalized source could not have produced a working, independently-clonable template with a genuinely distinct clone that went on to have real interactive console sessions (confirmed via `vncproxy`/`qmstart` task history on VMID 101).

**What remains unconfirmed:** the exact invocation. A recovered build session transcript's last progress checkpoint still showed Sysprep as an open item, not a completed one — so whether the actual run used the GUI (System Cleanup Action / Generalize / Shutdown, as described below) or an `unattend.xml` answer file was never captured in that transcript. Treat the procedure below as the correct, standard way to have done it — and the way to do it going forward — not a verbatim record of the exact historical run.

## Prerequisites

- Windows Server Base Configuration complete (`210-Windows-Server-Base-Configuration.md`)

## Implementation

### 1. Pre-Generalization Checklist

- Windows Update complete
- Reboot pending: No
- VirtIO drivers installed (Balloon, Serial — confirmed baseline, see `009`)
- QEMU Guest Agent running
- No unknown devices
- Workgroup membership
- No production static IP
- No domain certificates or secrets
- No mapped drives
- No workload-specific roles
- No sensitive files in user profiles
- Event logs reviewed
- Component health checked
- Temporary files cleaned
- Proxmox hardware settings documented

### 2. Verify Pending Reboot State

```powershell
$paths = @(
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
)
$paths | ForEach-Object {
    [pscustomobject]@{ Path = $_; Exists = Test-Path $_ }
}
```

Reboot if required.

### 3. Record the Source VM

```powershell
Get-ComputerInfo
Get-Service QEMU-GA
Get-PnpDevice | Where-Object Status -ne 'OK'
Get-NetIPConfiguration
Get-WindowsFeature | Where-Object InstallState -eq 'Installed'
```

From Proxmox:

```bash
qm config <BUILD-VMID>
```

### 4. Remove Environment-Specific Configuration

- Remove production VLAN tag unless the template deliberately carries one.
- Remove static IP configuration.
- Remove domain references.
- Remove installation media not needed after conversion.
- Keep VirtIO media only when the operational standard calls for it.

### 5. Sysprep

```text
C:\Windows\System32\Sysprep\Sysprep.exe
```

Choose: System Cleanup Action **Enter System Out-of-Box Experience (OOBE)**, Generalize **Checked**, Shutdown Options **Shutdown**.

Do not boot the VM again after successful Sysprep if the next action is template conversion. Booting begins specialization and defeats the clean template state.

### 6. Sysprep Logs

If Sysprep fails, inspect:

```text
C:\Windows\System32\Sysprep\Panther\setuperr.log
C:\Windows\System32\Sysprep\Panther\setupact.log
```

Resolve the cause; do not repeatedly retry without understanding the failure.

### 7. Proxmox-Side Verification After Shutdown

```bash
qm status <BUILD-VMID>
qm config <BUILD-VMID>
```

Expected: `status: stopped`.

## Validation

- Sysprep completed successfully
- VM shut down
- VM not restarted
- No domain-specific state
- Final hardware configuration documented
- Rollback copy or archive retained

## Common Mistakes

- Booting a Sysprepped image "just to check something" before template conversion — this begins specialization and invalidates the generalized state.
- Retrying a failed Sysprep repeatedly without reading the Panther logs first.

## Lessons Learned from Actual Deployment

The original build's Sysprep run itself was never captured in the recovered session transcript — a reminder that progress-tracking checklists and actual command transcripts are not the same evidence, and one can exist without the other. Going forward, capture the actual Sysprep console output or a screenshot at the moment of completion, not just a checklist checkmark, if exact historical reproducibility matters.

## Rollback

The archive VM (VMID 100, `WIN2025-BUILD-ARCHIVE`) is retained specifically as a pre-generalization rollback point. Do not boot it to "check" anything — inspect it offline (disk mount, log extraction) if historical evidence is needed, per the Verification Plan in the Golden Image Historical Record.

## Completion Checklist

- [x] Sysprep outcome confirmed (via engineer confirmation + independent clone-chain evidence)
- [ ] Exact Sysprep invocation (GUI vs. unattend.xml) — unconfirmed, treat this guide's procedure as standard practice going forward, not historical record
- [x] VM shut down, not restarted post-Sysprep
- [x] Rollback archive (VMID 100) retained

## Next Guide

Convert the Golden Image to Template.
