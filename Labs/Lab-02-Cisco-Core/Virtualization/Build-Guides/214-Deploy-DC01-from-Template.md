---
Title: Deploy DC01 from TPL-WIN2025
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Deploy DC01 from `TPL-WIN2025`

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft — DC01 exists but has not been promoted to a domain controller; VLAN placement unresolved |
| Version | 1.1 |
| Applies To | PVE01 |

## Purpose

Create and prepare DC01 as the first Windows Server infrastructure VM. This guide stops at the point where the server is ready for AD DS deployment; the Windows Infrastructure book owns forest and domain creation.

## Current Live State (as of last validation)

| Item | Value |
|---|---|
| VMID | 101 |
| Name | `DC01` |
| Status | **Stopped** |
| VLAN | Untagged (VLAN 10) — see the open item in `213-Clone-the-Windows-Server-Template.md` |
| AD DS promoted | **No** |
| Domain/forest | Not created |
| Real console session history | Confirmed via Proxmox `vncproxy`/`qmstart` task logs — someone has interactively logged into and worked on this VM post-clone, so it is not a fresh, untouched clone even though AD DS was never installed |

Do not represent DC01 as a verified domain controller until AD DS promotion is actually performed and validated.

## Prerequisites

- Template converted and cloned per `012` and `013`
- The VLAN 10 vs. 20 question resolved for DC01 specifically before assigning a permanent static IP

## Implementation

### 1. Clone

Full clone: Source VMID 9000 (`TPL-WIN2025`), New VMID 101, Name `DC01`, Storage `local-lvm`.

### 2. Target Resource Baseline

| Resource | Value |
|---|---|
| Sockets | 1 |
| Cores | 2 |
| Memory | 4096–8192 MB |
| Disk | 32 GB minimum; expand based on role and logs |
| Bridge | `vmbr0` |
| VLAN | 20, target design — **not yet applied on the live VM, see above** |
| Firewall | Enabled (per-VM flag; global Proxmox firewall currently disabled) |
| QEMU Agent | Enabled |

Do not reduce resources below supported Windows Server and operational requirements.

### 3. Network Target

```text
IP: 10.20.0.<approved-address>/24
Gateway: 10.20.0.1
Preferred DNS before promotion: deployment-specific
Preferred DNS after first DC promotion: its own approved address
```

The final DC01 IP and DNS sequence must be set by the Windows Infrastructure design — do not invent them during deployment. Given VLAN 20 has no DHCP service yet, use a **static** IP for this test rather than DHCP, so a failed lease doesn't get mistaken for a broken network path.

### 4. Rename

```powershell
Rename-Computer -NewName "DC01" -Restart
```

After restart:

```powershell
hostname
```

### 5. Static IP

```powershell
Get-NetAdapter
Get-NetIPConfiguration
```

```powershell
New-NetIPAddress `
  -InterfaceAlias "Ethernet" `
  -IPAddress "10.20.0.X" `
  -PrefixLength 24 `
  -DefaultGateway "10.20.0.1"

Set-DnsClientServerAddress `
  -InterfaceAlias "Ethernet" `
  -ServerAddresses @("APPROVED-DNS-IP")
```

Replace placeholders before execution.

### 6. Update and Health Check

```powershell
Get-Service QEMU-GA
Get-WindowsUpdateLog
Get-NetIPConfiguration
Test-NetConnection 10.20.0.1
```

### 7. Time

Before domain promotion, verify the VM has correct time and time zone. After AD DS deployment, follow the Active Directory time hierarchy.

## Validation

- VM name is DC01
- Correct VLAN — pending resolution
- Approved static IP
- Gateway reachable
- QEMU Guest Agent running
- Windows patched
- No domain membership yet
- No unexplained event or device errors
- Backup or snapshot decision documented

## Common Mistakes

- Treating DC01's current untagged/VLAN 10 placement as final without deliberately deciding it — it may have been a workaround for a missing DHCP scope, not an actual design decision.
- Promoting to a domain controller before the network placement question is settled — moving VLANs after promotion is far more disruptive than before.

## Lessons Learned from Actual Deployment

DC01 already has real interactive session history (confirmed console logins) despite never being promoted to a domain controller — this VM has been worked on, not just cloned and left alone. Worth checking what state it's actually in (Windows Update level, any manual configuration already applied) before assuming it's a clean, untouched clone.

## Rollback

Delete VMID 101 and re-clone from `TPL-WIN2025` — no domain state exists yet to complicate a clean restart.

## Completion Checklist

- [x] VM cloned as VMID 101
- [ ] VLAN 10 vs. 20 decision made and applied
- [ ] Static IP assigned and tested
- [ ] Windows fully patched
- [ ] AD DS role installed — explicitly out of scope for this guide, owned by the Windows Infrastructure book

## Next Guide

Continue in the Windows Infrastructure / Active Directory book: install AD DS, create the forest and domain, configure DNS, validate SYSVOL, NETLOGON, replication, and time.
