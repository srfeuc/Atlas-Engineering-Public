---
Title: How To Make a Windows Build Record
Path: Atlas-Academy
Status: 🟢 Living guide — the command-first walkthrough for the Windows build-record template.
Version: 1.0
Date: 2026-08-03
---

# How To Make a Windows Build Record

> **What this is.** The step-by-step for turning a live Windows host into a verified [Build Record](../00-Atlas-Foundation/Templates/Build-Record-Windows-Template.md). Run the command, read the output, paste the *observed* value, stamp the date. **You are recording reality, not intent** — never type a value you didn't read back (`POL-0006`), and if the host disagrees with the guide, the host wins (Rule 13).
>
> Fills the Windows template section-for-section. Run these **read-only** from an elevated PowerShell on (or remoting to) the host.

## On this page

0. [Before you start](#0-before-you-start)
1. [Platform identity](#1-platform-identity)
2. [Identity / AD](#2-identity--ad)
3. [Roles & features](#3-roles--features)
4. [Group Policy](#4-group-policy)
5. [Services](#5-services)
6. [Networking](#6-networking)
7. [Storage & BitLocker](#7-storage--bitlocker)
8. [Security & hardening](#8-security--hardening)
9. [Patching & activation](#9-patching--activation)
10. [Time](#10-time)
11. [Finish — deviations, change log, reconcile](#11-finish--deviations-change-log-reconcile)

---

## 0. Before you start

1. Copy [`Build-Record-Windows-Template.md`](../00-Atlas-Foundation/Templates/Build-Record-Windows-Template.md) → `Devices/<HOST>/Build-Record.md`.
2. Open elevated PowerShell on the host (or `Enter-PSSession <HOST>`).
3. As you go: paste the **observed** value + the command + **today's date** into each row. Anything you can't verify yet → mark 🟡.

> 💡 Capture everything at once for the file: `Get-ComputerInfo | Out-File C:\buildrecord.txt` then work from it — but the tables below still cite the *specific* command per fact so the record is auditable.

## 1. Platform identity

```powershell
hostname
Get-ComputerInfo -Property CsName,OsName,OsVersion,OsBuildNumber,WindowsProductName
slmgr /dlv        # activation state
```

→ fills **§2 Platform** (hostname, OS + build, activation). Management IP: record the observed value, link the addressing plan as its home (don't restate it).

## 2. Identity / AD

*(DCs and domain members — skip AD-role rows on a workgroup box.)*

```powershell
Get-ADDomain ; Get-ADForest                 # domain/forest + functional levels
netdom query fsmo                            # which DC holds the 5 FSMO roles
repadmin /replsummary                        # replication health (want 0 failures)
dcdiag /q                                    # only failures print
Get-DnsServerZone                            # AD-integrated zones (on a DNS server)
```

→ fills **§3.1**. 🔴 If `repadmin` shows failures or `dcdiag` prints anything, that's a finding — record it in §4 Deviations with a `CM-####`.

## 3. Roles & features

```powershell
Get-WindowsFeature | Where-Object Installed | Select-Object Name,DisplayName
```

→ fills **§3.2**. List only what's installed; that *is* the role of the box.

## 4. Group Policy

```powershell
gpresult /r /scope computer                  # applied + denied GPOs, security groups
gpresult /h C:\gpo.html                       # full HTML RSoP if you want detail
```

→ fills **§3.3**. Note the applied baseline / tier-deny GPOs (`ADR-0021`); if an expected GPO is *denied* or missing, that's a deviation.

## 5. Services

```powershell
Get-Service | Where-Object Status -eq Running | Select-Object Name,DisplayName,StartType
Get-Service NTDS,DNS,DHCPServer,MSSQLSERVER   # the ones this host's role depends on
```

→ fills **§3.4**. Record the role-critical services as Running · Auto. A key service set to Manual/Stopped is a finding.

## 6. Networking

```powershell
Get-NetIPConfiguration                        # IP, gateway, DNS, adapter in one view
Get-NetIPAddress -AddressFamily IPv4
Get-DnsClientServerAddress
Get-NetAdapter | Select-Object Name,Status,LinkSpeed,MacAddress
```

→ fills **§3.5**. The observed IP/VLAN is reality; its *intent* home is the addressing plan → NetBox (`POL-0004`).

## 7. Storage & BitLocker

```powershell
Get-Disk ; Get-Volume
Get-PhysicalDisk | Select-Object FriendlyName,MediaType,Size,HealthStatus
manage-bde -status                            # BitLocker per volume
```

→ fills **§3.6**.

## 8. Security & hardening

```powershell
Get-MpComputerStatus | Select RealTimeProtectionEnabled,IsTamperProtected,AMServiceEnabled
Get-LocalGroupMember Administrators           # who is local admin (should be tight)
Get-LapsADPassword -Identity <HOST> -AsPlainText   # LAPS in effect (AD LAPS)
auditpol /get /category:*                     # audit policy
secedit /export /cfg C:\secpol.cfg            # local security policy baseline
```

→ fills **§3.7**. Record the baseline (`POL-0007`) and **every deliberate deviation** from CIS — an undocumented deviation is the defect, not the deviation itself.

## 9. Patching & activation

```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10
# WSUS source (if managed):
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -EA SilentlyContinue
```

→ fills **§3.8**.

## 10. Time

```powershell
w32tm /query /status                          # source, stratum, last sync
w32tm /query /configuration
```

→ fills **§3.9**. 🔴 The classic Atlas trap (`CM-0030` / `ADR-0020`): a host *configured* for a time source but **never synced** (stratum unsynced). "Configured" is not "synced" — read the status, don't assume.

## 11. Finish — deviations, change log, reconcile

1. **§4 Deviations** — every place reality ≠ the Build Guide: target vs current + a `CM-####`/`ADR-####`. A recorded, justified deviation is fine; a guide still teaching the old way is a defect — reconcile it (Rule 15).
2. **§1 Document control** — set *Last Live Verification* = today; set Status.
3. **§5 Change log** — what you verified, and **what you did NOT change and why** (gated on a rotation, an operator call, a device you couldn't reach). This honesty is what keeps the record trustworthy.
4. **Commit** one logical change ([`Atlas-Workflow` §6](../00-Atlas-Foundation/Governance/Atlas-Workflow.md#6-git-workflow)).

## Related

[`Build-Record-Windows-Template`](../00-Atlas-Foundation/Templates/Build-Record-Windows-Template.md) · [`Atlas-Workflow` §1 source priority](../00-Atlas-Foundation/Governance/Atlas-Workflow.md#1-source-priority--read-this-first) · [`POL-0006` Evidence & Verification](../00-Atlas-Foundation/Policies/POL-0006-Evidence-and-Verification.md) · [`POL-0004` Source of Truth](../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) · the [Source-of-Truth router](../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. First cut — the command-first walkthrough for the Windows build-record template (identity/AD · roles · GPO · services · networking · storage · hardening · patching · time), each step citing the read-only command that proves it. Grounded in the Atlas read-it-back discipline. |
