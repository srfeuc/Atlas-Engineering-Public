<!--
  ATLAS BUILD-RECORD TEMPLATE — WINDOWS SERVER  ·  copy to  Devices/<HOST>/Build-Record.md
  ────────────────────────────────────────────────────────────────────
  A Build RECORD is VERIFIED REALITY — what is actually running on this host, read back from it.
  It OUTRANKS the Build Guide (Atlas-Workflow §1); the HOST outranks the record (Charter Rule 13).
  This is the WINDOWS variant of the family — a Windows record does not look like a Cisco one
  (roles/AD/GPO/services vs VLANs/ports/STP). The spine is shared; §3 is Windows-specific.

  📘 HOW TO FILL THIS: the guided walkthrough — the exact read-back command for every subsystem below —
     is How-To-Make-a-Windows-Build-Record.md. Run each command, paste the output, mark the date.
  Never invent output (POL-0006). Unverified → 🟡. Don't restate an addressing fact whose home is the
  plan/NetBox — record the OBSERVED value and link the intent home (POL-0004).
  Delete this comment block in the finished record.
-->
---
Title: ‹HOST› Build Record
Path: Labs/‹Lab›/Devices/‹HOST›
---

# ‹HOST› Build Record

<!-- provenance -->
> **‹Lab, e.g. Lab-02-Cisco-Core› (‹🟢 ACTIVE / 🔒 FROZEN ‹date››)** — Host: ‹HOST› — Role: ‹e.g. Domain Controller / File Server / SQL›

> **What this is.** The verified Windows state of ‹HOST› — read back from the host, not intended. **Outranks the Build Guide** ([source priority](../../../../00-Atlas-Foundation/Governance/Atlas-Workflow.md#1-source-priority--read-this-first)). Host disagrees → the host wins (Rule 13). **How to fill each section:** [How-To-Make-a-Windows-Build-Record](../../../../Atlas-Academy/How-To-Make-a-Windows-Build-Record.md).

## On this page

1. [Document control](#1-document-control)
2. [Platform](#2-platform)
3. [Verified state](#3-verified-state) — 3.1 Identity/AD · 3.2 Roles & features · 3.3 GPO · 3.4 Services · 3.5 Networking · 3.6 Storage & BitLocker · 3.7 Security & hardening · 3.8 Patching & activation · 3.9 Time
4. [Known deviations](#4-known-deviations)
5. [Change log](#5-change-log)

---

## 1. Document control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ‹Verified — reconciled to live ‹YYYY-MM-DD›; residual items: ‹CM-####…›› |
| Version | ‹n.n› |
| Applies To | ‹Atlas 2.0› |
| Last Live Verification | ‹YYYY-MM-DD› |
| Last Reconciled | ‹YYYY-MM-DD› |

> **"Verified" is a claim about a date** (Rule 14). Not re-read since *Last Live Verification* → treat as **Historical**.

## 2. Platform

| Item | Value | Read-back |
|---|---|---|
| Hostname | ‹DC01› | `hostname` / `Get-ComputerInfo CsName` |
| OS + build | ‹Windows Server 2022, 20348.####› | `Get-ComputerInfo OsName,OsVersion` |
| Host / hypervisor | ‹PVE02 · EQR6› | [`Service-Server-Build-Plan`](../../Service-Server-Build-Plan.md) |
| Management IP | ‹10.10.0.x› | intent home: [`IP-Addressing-Plan-VLSM`](../../Architecture/IP-Addressing-Plan-VLSM.md) → NetBox |
| Domain / role | ‹atlas.lab · Domain Controller› | `Get-ADDomain` / `systeminfo` |
| Activation | ‹KMS / MAK, licensed› | `slmgr /dlv` |

---

## 3. Verified state

> Fill only the subsystems this host has. Every row = **observed value + read-back command + date**. Commands are in the [guided walkthrough](../../../../Atlas-Academy/How-To-Make-a-Windows-Build-Record.md).

### 3.1 Identity / AD (DCs and domain members)

| Item | Observed | Read-back | Verified |
|---|---|---|---|
| Domain / forest | ‹atlas.lab, 2016 FL› | `Get-ADDomain` · `Get-ADForest` | ‹date/🟡› |
| FSMO roles | ‹DC01 holds all 5› | `netdom query fsmo` | |
| Replication | ‹0 failures› | `repadmin /replsummary` · `dcdiag` | |
| DNS role | ‹AD-integrated› | `Get-DnsServerZone` | |

### 3.2 Roles & features

| Role / feature | State | Read-back | Verified |
|---|---|---|---|
| ‹AD DS / DNS / DHCP / …› | Installed | `Get-WindowsFeature \| ? Installed` | |

### 3.3 Group Policy (applied)

| GPO / setting area | Observed | Read-back | Verified |
|---|---|---|---|
| ‹Applied GPOs› | ‹list› | `gpresult /r /scope computer` | |
| ‹Tier-deny / baseline› | ‹enforced› | `Get-GPResultantSetOfPolicy` | |

### 3.4 Services (running / enabled)

| Service | State | Read-back | Verified |
|---|---|---|---|
| ‹NTDS / DNS / DHCPServer / MSSQLSERVER / …› | Running · Auto | `Get-Service <name>` | |

### 3.5 Networking

| Item | Observed | Read-back | Verified |
|---|---|---|---|
| IP / mask / gw | ‹…› | `Get-NetIPConfiguration` | |
| DNS servers | ‹…› | `Get-DnsClientServerAddress` | |
| Adapter / VLAN | ‹…› | `Get-NetAdapter` | |

### 3.6 Storage & BitLocker

| Item | Observed | Read-back | Verified |
|---|---|---|---|
| Disks / volumes | ‹…› | `Get-Disk` · `Get-Volume` | |
| BitLocker | ‹On, TPM› | `manage-bde -status` | |

### 3.7 Security & hardening

| Item | Observed | Read-back | Verified |
|---|---|---|---|
| Defender | ‹RTP on, Tamper on› | `Get-MpComputerStatus` | |
| Local admins | ‹…› | `Get-LocalGroupMember Administrators` | |
| LAPS | ‹enabled› | `Get-LapsADPassword` | |
| Audit policy | ‹…› | `auditpol /get /category:*` | |
| Baseline (`POL-0007`) | ‹CIS-informed; deviations recorded› | `secedit /export` | |

### 3.8 Patching & activation

| Item | Observed | Read-back | Verified |
|---|---|---|---|
| Patch level | ‹latest KB› | `Get-HotFix` | |
| WSUS source | ‹WSUS01› | `Get-WUSettings` / registry | |

### 3.9 Time (DOMHIER — `ADR-0020`)

| Item | Observed | Read-back | Verified |
|---|---|---|---|
| Time source | ‹PDC → external; members → DOMHIER› | `w32tm /query /status` · `/configuration` | |

---

## 4. Known deviations

Reality vs the [Build Guide](./Build-Guide.md). Recorded + justified = fine; a stale guide = a defect (Rule 15).

| Item | Target | Current (reality) | Action |
|---|---|---|---|
| ‹…› | ‹…› | 🔴 ‹…› | ‹`CM-####` / `ADR-####`› |

## 5. Change log

> **How this log works.** Newest session on top. Each session is a dated block: a **Notes** line (what you did and why, plainly), then the changes — each tagged so they're easy to tell apart at a glance:
>
> - 🔴 **MAJOR** — a role/feature added, a structural or security-posture change. Also gets a **Major Change record** ([`MC-####`](./Changes/)).
> - 🟢 **Normal** — an account, a password, a description, a routine setting. A standard **Change record** ([`CM-####`](./Changes/)).
> - 🟡 **Unverified** — done, but not yet read back.

<!-- ▼▼▼ EXAMPLE — delete this block and record this device's real sessions ▼▼▼ -->
### Session 2 — 2026-08-05 (operator)
**Notes:** Promoted DC02 to a working replica and set up the SQL service account. Replication came back clean on the read-back.

- 🔴 **MAJOR** — Added the **AD DS role** and promoted to replica DC (`MC-0101`). Verified: `repadmin /replsummary` = 0 failures (2026-08-05).
- 🟢 Normal — Created the `svc-gmsa-sql` gMSA + stored its secret in Vaultwarden (`CM-0142`). Verified: `Test-ADServiceAccount svc-gmsa-sql` = True.
- 🟢 Normal — Set the DNS forwarder to the Pi-hole and updated the description. Verified: `Get-DnsServerForwarder`.

### Session 1 — 2026-08-04 (operator)
**Notes:** Base build from the golden image; domain-joined; first hardening pass.

- 🔴 **MAJOR** — Domain-joined to `atlas.lab` (`MC-0100`).
- 🟢 Normal — Set the local admin password (stored in Vaultwarden) and disabled the built-in Administrator.
- 🟡 Unverified — Applied the CIS baseline GPO; `gpresult` read-back pending.
<!-- ▲▲▲ END EXAMPLE ▲▲▲ -->

### Session ‹n› — ‹YYYY-MM-DD› (‹who›)
**Notes:** ‹what you did this session, plainly›

- 🔴 **MAJOR** — ‹…› (`MC-####`) — verified `‹command›` (‹date›)
- 🟢 Normal — ‹…› (`CM-####`) — verified (‹date›)

## Related

📘 [How-To-Make-a-Windows-Build-Record](../../../../Atlas-Academy/How-To-Make-a-Windows-Build-Record.md) · [Build Guide](./Build-Guide.md) · [device README](./README.md) · [`Considerations`](./Considerations.md) · [`Changes/`](./Changes/) · [`Atlas-Workflow` §1](../../../../00-Atlas-Foundation/Governance/Atlas-Workflow.md#1-source-priority--read-this-first) · [`POL-0004`](../../../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) · [`POL-0006`](../../../../00-Atlas-Foundation/Policies/POL-0006-Evidence-and-Verification.md) · [Source-of-Truth router](../../../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md).
