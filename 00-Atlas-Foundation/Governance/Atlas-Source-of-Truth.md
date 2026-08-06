---
Title: Atlas Source of Truth — Where Everything Lives
Path: 00-Atlas-Foundation/Governance
Status: 🟢 Living quick-reference router — paired with `Atlas-Workflow`. Expand as docs are added.
Version: 0.11
Date: 2026-08-04
---

# Atlas Source of Truth — Where Everything Lives

> **Keep this open in a tab.** You're doing something in Atlas and need the *one doc that governs it* — fast. Scan the index, jump to your situation, follow the link. Every section lists the **authoritative docs**, then 🔧 **when it breaks** (playbooks + command guides) and 📋 **the template** to use, right there. No scrolling hunts.
>
> This is the *router*. It is **governed by** [`POL-0004`](../Policies/POL-0004-Source-of-Truth.md) (the rule: one home per fact) — it points, it never restates. If a link and the target disagree, the target wins.
>
> 🔗 **Paired with [`Atlas-Workflow`](./Atlas-Workflow.md).** This page says *where* everything lives; the Workflow says *how* work gets done and verified (source priority · the page lifecycle · making a change · the governance loop). The process routes below (§7–§9) deep-link into its sections.

## ⚡ Fast path — the most common needs

| I need to… | Go straight to |
|---|---|
| **Make a change** on a device (the right way) | [§7 Make a change](#7-make-a-change) — process + template |
| **Trace why a flow is blocked** | [Trace-a-Blocked-Flow](../../Atlas-Academy/Playbooks/Trace-a-Blocked-Flow.md) ([§1](#1-security-and-perimeter)) |
| **Build / commission a new server** | [§4](#4-servers-and-compute) + the [commissioning checklist](../Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx) |
| **Write a build record** | [§8](#8-document-something) — [`Build-Record-Template`](../Templates/Build-Record-Template.md) |
| **Find an IP / VLAN / address** | [§3](#3-network-and-addressing) — [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) → NetBox |
| **Understand the firewall / segmentation** | [§1](#1-security-and-perimeter) — [`Atlas-Firewall-Architecture`](../Reference/Atlas-Firewall-Architecture.md) |
| **Fix a failing domain join** | [Domain-Join-Fails](../../Atlas-Academy/Playbooks/Domain-Join-Fails.md) ([§2](#2-identity-and-access)) |
| **Recover from an outage** | [§5](#5-backup-recovery-and-continuity) — recovery playbooks |
| **Read logs / find an event** | [Trace-It-in-the-Logs](../../Atlas-Academy/Playbooks/Trace-It-in-the-Logs.md) ([§6](#6-monitoring-and-logging)) |
| **Add or move a doc** | [`Contributing-Adding-Docs`](../Documentation/Contributing-Adding-Docs.md) ([§8](#8-document-something)) |
| **Look up why a decision was made** | [`ADR-Index`](../Decisions/ADR-Index.md) ([§9](#9-governance-and-decisions)) |
| **Find the standing rule for X** | the [`Policies/`](../Policies/) register ([§9](#9-governance-and-decisions)) |
| **Know how Atlas governs itself** | [`Atlas-Governance-Framework`](./Atlas-Governance-Framework.md) ([§9](#9-governance-and-decisions)) |
| **Understand how work gets done + verified** | [`Atlas-Workflow`](./Atlas-Workflow.md) — the process loop (source priority · lifecycle · change) |

## On this page

1. [Security and perimeter](#1-security-and-perimeter) — firewall · IPS · segmentation · hardening
2. [Identity and access](#2-identity-and-access) — AD · PKI · AAA
3. [Network and addressing](#3-network-and-addressing) — IPs · VLANs · flows · NetBox
4. [Servers and compute](#4-servers-and-compute) — hosts · placement · virtualization
5. [Backup, recovery and continuity](#5-backup-recovery-and-continuity)
6. [Monitoring and logging](#6-monitoring-and-logging)
7. [Make a change](#7-make-a-change) — change management + its template
8. [Document something](#8-document-something) — standards + build-record/guide templates
9. [Governance and decisions](#9-governance-and-decisions) — policies · ADRs · the framework
10. [Troubleshooting and the Academy](#10-troubleshooting-and-the-academy) — every playbook + command guide
11. [Automation and IaC](#11-automation-and-iac) — scripts · CI · the container host
12. [Security program and compliance](#12-security-program-and-compliance) — IR · risk · privacy · awareness

**⚙️ Paired:** [`Atlas-Workflow`](./Atlas-Workflow.md) — *how* work gets done + verified (source priority · page lifecycle · making a change · the governance loop); deep-linked from §7–§9.

---

## 1. Security and perimeter

**Go here for:** the firewall, IPS, segmentation model, and hardening.

> 📖 **Full directory:** [Security and Perimeter (Academy)](../../Atlas-Academy/Directory/Security-and-Perimeter.md) — every device, the segmentation model, the CIS baselines, and the real frozen-Lab-01 firewall records, described.

- **The pattern** — [`Atlas-Firewall-Architecture.md`](../Reference/Atlas-Firewall-Architecture.md) (the segmentation teaching reference)
- **Perimeter (FortiGate)** — [`FGT01-Perimeter-Firewall/`](../../Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/) · [`ADR-0047` FortiGuard UTM](../Decisions/ADR-0047-FGT01-FortiGuard-UTM.md) · [`ADR-0050` TLS deep-inspection](../Decisions/ADR-0050-FGT01-TLS-Deep-Inspection-Scope-and-ICA01-Inspection-CA.md)
- **Inline IPS (pfSense)** — [`PFSENSE01-IPS/`](../../Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS/) · [`ADR-0038` pfSense inline IPS](../Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md)
- **East-west firewall (MikroTik)** — [`MKT01-East-West-Firewall/`](../../Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/) · [`ADR-0023` core & segmentation topology](../Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md)
- **Allowed flows** — [`Atlas-East-West-Allowed-Flows-Matrix`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md)
- **Hardening** — the `CIS-Hardening-*` baselines in [`Architecture/`](../../Labs/Lab-02-Cisco-Core/Architecture/) · the rule: [`POL-0007` Hardening Baseline](../Policies/POL-0007-Hardening-Baseline.md)
- 📚 **Academy (learn it)** — concept: [Identity-Aware vs Zone Firewall Policy](../../Atlas-Academy/Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md) · commands: [FortiOS](../../Atlas-Academy/Command-Library/FortiOS.md) · [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [RouterOS](../../Atlas-Academy/Command-Library/RouterOS.md) · cert map: [FortiGate FCP](../../Atlas-Academy/Certification/Atlas-FortiGate-FCP-Lab-Map.md)
<details>
<summary>🔧 <b>Troubleshooting by symptom</b></summary>

- **A flow is blocked / traffic won't pass** → [Trace-a-Blocked-Flow](../../Atlas-Academy/Playbooks/Trace-a-Blocked-Flow.md) · [MikroTik-EastWest-Inspect](../../Atlas-Academy/Playbooks/MikroTik-EastWest-Inspect-and-Troubleshoot.md) · [Prove-Exactly-Which-MikroTik-Rule-Acted](../../Atlas-Academy/Playbooks/Prove-Exactly-Which-MikroTik-Rule-Acted.md)
- **A firewall rule looks dead / stale** → [Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched](../../Atlas-Academy/Playbooks/Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched.md)
- **Auditing live ports before hardening** → [Enumerate-Every-Enabled-Interface](../../Atlas-Academy/Playbooks/Enumerate-Every-Enabled-Interface-Before-Hardening.md)
- **Platform commands** → [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [RouterOS](../../Atlas-Academy/Command-Library/RouterOS.md) · [FortiOS](../../Atlas-Academy/Command-Library/FortiOS.md)
- **Per-device** → each device folder's `Troubleshooting.md`

</details>

<details>
<summary>📚 <b>Go deeper — runbooks · Academy · records · decisions</b></summary>

- **Runbooks / hardening** → the `CIS-Hardening-*` baselines in [`Architecture/`](../../Labs/Lab-02-Cisco-Core/Architecture/) · the FGT01 Build-Guide (UTM profiles) in [`FGT01-Perimeter-Firewall/`](../../Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/)
- **Learn it (Academy)** → [Concepts](../../Atlas-Academy/Concepts/) · Command-Library ([FortiOS](../../Atlas-Academy/Command-Library/FortiOS.md) · [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [RouterOS](../../Atlas-Academy/Command-Library/RouterOS.md)) · the FortiGate **FCP** cert map
- **Build records (verified state)** → e.g. [FGT01](../../Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/) — each device folder has its own (browse [`Devices/`](../../Labs/Lab-02-Cisco-Core/Devices/))
- **Related decisions** → [ADR-0047](../Decisions/ADR-0047-FGT01-FortiGuard-UTM.md) (UTM) · [ADR-0050](../Decisions/ADR-0050-FGT01-TLS-Deep-Inspection-Scope-and-ICA01-Inspection-CA.md) (deep-inspect) · [ADR-0038](../Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md) (IPS) · [ADR-0023](../Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) (topology) · [ADR-0051](../Decisions/ADR-0051-DNS-Filtering-Ownership-Pi-hole-Not-FortiGuard.md) (DNS)

</details>

---

## 2. Identity and access

**Go here for:** Active Directory, PKI, and authentication.

> 📖 **Full directory:** [Identity and Access (Academy)](../../Atlas-Academy/Directory/Identity-and-Access.md) — AD tiered identity, the two-tier PKI, AAA/NPS, and the real frozen-Lab-01 certificate records, described.

- **AD as the backbone** — [`ADR-0021` AD tiered identity](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) · [`DC-Domain-Controllers/`](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/) · [`PAW01-Tier0-Admin/`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/)
- **PKI** — [`RCA01-ICA01-ADCS/`](../../Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/) · [`ADR-0027` two-tier PKI](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) · [`ADR-0031` unify on AD CS](../Decisions/ADR-0031-Retire-OpenSSL-Lab-CA.md)
- **AAA / RADIUS** — [`NPS01-Network-Policy-Server/`](../../Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server/) · [`ADR-0029` NPS](../Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md) · [`ADR-0028` FGT LDAPS](../Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md) · [`ADR-0040` Entra PHS](../Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md)
- **The rules** — [`POL-0010` Acceptable Use](../Policies/POL-0010-Acceptable-Use.md) · `STD-0001` / `STD-0002`
- 📚 **Academy (learn it)** — concepts: [Tiered-Admin Model](../../Atlas-Academy/Concepts/Tiered-Admin-Model.md) · [Windows Logon Scripts & Drive Mapping](../../Atlas-Academy/Concepts/Windows-Logon-Scripts-and-Drive-Mapping.md) · commands: [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) · cert map: [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md)
<details>
<summary>🔧 <b>Troubleshooting by symptom</b></summary>

- **Domain join failing** → [Domain-Join-Fails](../../Atlas-Academy/Playbooks/Domain-Join-Fails.md)
- **Certificate / PKI issues** → [Read-the-Cert-Not-the-Sign-Log](../../Atlas-Academy/Playbooks/Read-the-Cert-Not-the-Sign-Log.md) · [Rotate-a-Leaked-Key](../../Atlas-Academy/Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md)
- **Locked out of a device** → [Recover-a-Locked-Out-Router](../../Atlas-Academy/Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md)
- **Platform commands** → [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md)
- **Per-device** → each host's `Troubleshooting.md` (e.g. [DC-Domain-Controllers](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/), [NPS01](../../Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server/))

</details>

<details>
<summary>📚 <b>Go deeper — records · Academy · decisions</b></summary>

- **Build records (verified state)** → e.g. [DC-Domain-Controllers](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/) — each device folder has its own
- **Learn it (Academy)** → [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) · [Concepts](../../Atlas-Academy/Concepts/)
- **Related decisions** → [ADR-0021](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) (tiered identity) · [ADR-0027](../Decisions/ADR-0027-AD-CS-Two-Tier-Microsoft-PKI.md) (PKI) · [ADR-0029](../Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md) (NPS) · [ADR-0028](../Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md) (LDAPS) · [ADR-0040](../Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md) (Entra PHS)

</details>

---

## 3. Network and addressing

**Go here for:** IPs, VLANs, topology, and the data source of truth.

> 📖 **Full directory:** [Network and Addressing (Academy)](../../Atlas-Academy/Directory/Network-and-Addressing.md) — real Lab-01 build records + the change-management goldmine, described.

- **Addressing plan** — [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) · [`IPv6-Addressing-Plan`](../../Labs/Lab-02-Cisco-Core/Architecture/IPv6-Addressing-Plan.md) · [`Cabling-and-Port-Map`](../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md)
- **Core devices** — [`1941-Core-Router/`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/) · [`SW01-Access-Switch/`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/)
- **The data SoT (NetBox)** — target home for every device/IP/VLAN fact → [`NETBOX01-Source-of-Truth/`](../../Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth/). 📋 *The written **Network Source-of-Truth register** (the NetBox seed) — coming.*
- **The rules** — [`POL-0008` Naming & Addressing](../Policies/POL-0008-Naming-and-Addressing.md) · [`POL-0004` Source of Truth](../Policies/POL-0004-Source-of-Truth.md)
- 📚 **Academy (learn it)** — full directory above · commands: [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [RouterOS](../../Atlas-Academy/Command-Library/RouterOS.md) · [Linux](../../Atlas-Academy/Command-Library/Linux.md) · cert map: [CCNP](../../Atlas-Academy/Certification/Atlas-CCNP-Lab-Map.md)
<details>
<summary>🔧 <b>Troubleshooting by symptom</b></summary>

- **A host is unreachable** → [Diagnose-a-Host-Silently-Dropped-by-DAI](../../Atlas-Academy/Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md) · [Test-a-Connection](../../Atlas-Academy/Playbooks/Test-a-Connection.md)
- **DNS / name resolution failing** → [Recover-from-a-DNS-Outage](../../Atlas-Academy/Playbooks/Recover-from-a-DNS-Outage.md)
- **Clock / time drift** → [Fix-the-SW01-Clock](../../Atlas-Academy/Playbooks/Fix-the-SW01-Clock.md)
- **Read the logs** → [Trace-It-in-the-Logs](../../Atlas-Academy/Playbooks/Trace-It-in-the-Logs.md) · [Read-the-Logs-with-journalctl](../../Atlas-Academy/Playbooks/Read-the-Logs-with-journalctl.md)
- **Platform commands** → [Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [RouterOS](../../Atlas-Academy/Command-Library/RouterOS.md) · [Linux](../../Atlas-Academy/Command-Library/Linux.md)
- **Per-device** → each device folder's `Troubleshooting.md`

</details>

<details>
<summary>📚 <b>Go deeper — records · Academy · decisions</b></summary>

- **Build records (verified state)** → e.g. [SW01](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/) — each device folder has its own
- **Learn it (Academy)** → Command-Library ([Cisco-IOS](../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [RouterOS](../../Atlas-Academy/Command-Library/RouterOS.md)) · [Concepts](../../Atlas-Academy/Concepts/)
- **Related decisions** → [ADR-0023](../Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) (topology) · [ADR-0030](../Decisions/ADR-0030-DHCP-on-DC01.md) (DHCP) · [ADR-0007](../Decisions/ADR-0007-Adopt-atlas-lab-Domain-Suffix.md) (suffix) · [ADR-0020](../Decisions/ADR-0020-NTP-Time-Source-Architecture.md) (time)

</details>

---

## 4. Servers and compute

**Go here for:** hosts, placement, sizing, and virtualization.

> 📖 **Full directory:** [Servers and Compute (Academy)](../../Atlas-Academy/Directory/Servers-and-Compute.md) — every host + doc, described.

- **Placement + sizing** — [`Service-Server-Build-Plan`](../../Labs/Lab-02-Cisco-Core/Service-Server-Build-Plan.md) · [`ADR-0036` compute topology](../Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md) · [`ADR-0046` failover cluster + S2D](../Decisions/ADR-0046-Two-Node-Failover-Cluster-and-S2D.md)
- **Hypervisors** — [`PVE01-Hypervisor/`](../../Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor/) · [`PVE02-Hypervisor/`](../../Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor/) · [`ADR-0034` PVE01 networking home](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md)
- **Every device** — the full roster (24) lives under [`Devices/`](../../Labs/Lab-02-Cisco-Core/Devices/). 📋 *The written **Server Source-of-Truth register** (the NetBox seed) — coming.*
- 📋 **Building a server?** — [`New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx`](../Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx) (the golden master)
- 📚 **Academy (learn it)** — full directory above · concept: [Proxmox VM Migration & Host Bring-Up](../../Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md) · commands: [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) · [Linux](../../Atlas-Academy/Command-Library/Linux.md) · cert map: [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md)
<details>
<summary>🔧 <b>Troubleshooting by symptom</b></summary>

- **Proxmox / VM host issue** → [Proxmox-Inspect-and-Troubleshoot](../../Atlas-Academy/Playbooks/Proxmox-Inspect-and-Troubleshoot.md)
- **Rebuild from bare metal** → [Recover-the-Lab-from-a-Bare-Metal-Teardown](../../Atlas-Academy/Playbooks/Recover-the-Lab-from-a-Bare-Metal-Teardown.md)
- **Read the logs** → [Read-the-Logs-with-journalctl](../../Atlas-Academy/Playbooks/Read-the-Logs-with-journalctl.md) · [Trace-It-in-the-Logs](../../Atlas-Academy/Playbooks/Trace-It-in-the-Logs.md)
- **Platform commands** → Windows [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) · Linux [Linux](../../Atlas-Academy/Command-Library/Linux.md)
- **Per-device** → each host's `Troubleshooting.md`

</details>

<details>
<summary>📚 <b>Go deeper — records · Academy · decisions</b></summary>

- **Build records (verified state)** → e.g. [PVE01-Hypervisor](../../Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor/) — each device folder has its own
- **Learn it (Academy)** → Command-Library ([PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) · [Linux](../../Atlas-Academy/Command-Library/Linux.md)) · [Concepts](../../Atlas-Academy/Concepts/) · the **AZ-800/801** cert map
- **Related decisions** → [ADR-0036](../Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md) (topology) · [ADR-0046](../Decisions/ADR-0046-Two-Node-Failover-Cluster-and-S2D.md) (failover cluster) · [ADR-0034](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md) (PVE01 networking) · [ADR-0045](../Decisions/ADR-0045-AZ800-801-Compute-Additions-WAC-Container-RODC.md) (AZ compute)

</details>

---

## 5. Backup, recovery and continuity

**Go here for:** backups, restores, and keeping running through a failure.

> 📖 **Full directory:** [Backup, Recovery and Continuity (Academy)](../../Atlas-Academy/Directory/Backup-Recovery-and-Continuity.md) — the backup host, the recovery objectives, and the real frozen-Lab-01 recovery record, described.

- **Backup host** — [`BKP01-Backup/`](../../Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/)
- **The rules** — [`POL-0005` Backup & Recovery](../Policies/POL-0005-Backup-and-Recovery.md) · [`POL-0013` Business Continuity](../Policies/POL-0013-Business-Continuity.md) · [`ADR-0011` Game-Day drills](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) *(a backup isn't real until a restore proves it)*
- 🔧 **When it breaks:** [Recover-from-a-DNS-Outage](../../Atlas-Academy/Playbooks/Recover-from-a-DNS-Outage.md) · [Recover-the-Lab-from-a-Bare-Metal-Teardown](../../Atlas-Academy/Playbooks/Recover-the-Lab-from-a-Bare-Metal-Teardown.md)
- 📚 **Academy (learn it)** — concept: [A Backup Is Not a Backup Until a Restore Proves It](../../Atlas-Academy/Concepts/A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md) *(the restore-testing · 3-2-1 · RPO/RTO · Game-Day why-layer)* · [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) · the recovery playbooks are in the 🔧 line above

---

## 6. Monitoring and logging

**Go here for:** telemetry, syslog, SNMP, and the SIEM.

> 📖 **Full directory:** [Monitoring and Logging (Academy)](../../Atlas-Academy/Directory/Monitoring-and-Logging.md) — the sinks, the telemetry model, the syslog/SNMP tooling, and the real frozen-Lab-01 telemetry-hygiene records, described.

- **The sinks** — [`MON01-Monitoring/`](../../Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/) · [`SIEM01-Wazuh/`](../../Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh/)
- **The rule** — [`POL-0006` Evidence & Verification](../Policies/POL-0006-Evidence-and-Verification.md)
- 📚 **Academy (learn it)** — commands: [Syslog-and-SNMP](../../Atlas-Academy/Command-Library/Syslog-and-SNMP.md) · [Linux](../../Atlas-Academy/Command-Library/Linux.md) · concept: [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md)
<details>
<summary>🔧 <b>Troubleshooting by symptom</b></summary>

- **Find an event in the logs** → [Trace-It-in-the-Logs](../../Atlas-Academy/Playbooks/Trace-It-in-the-Logs.md) · [Read-the-Logs-with-journalctl](../../Atlas-Academy/Playbooks/Read-the-Logs-with-journalctl.md)
- **SNMP polling / a device missing from LibreNMS** → [Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device](../../Atlas-Academy/Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md)
- **Platform commands** → [Syslog-and-SNMP](../../Atlas-Academy/Command-Library/Syslog-and-SNMP.md) · [Linux](../../Atlas-Academy/Command-Library/Linux.md)
- **Per-device** → [MON01](../../Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/) · [SIEM01](../../Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh/) `Troubleshooting.md`

</details>

<details>
<summary>📚 <b>Go deeper — Academy · decisions</b></summary>

- **Learn it (Academy)** → [`Syslog-and-SNMP`](../../Atlas-Academy/Command-Library/Syslog-and-SNMP.md) command library · [Concepts](../../Atlas-Academy/Concepts/)
- **Related decisions** → [ADR-0032](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) — the diagnostics/verification architecture *(backlog #34 = syslog + SNMP as first-class tools)*

</details>

---

## 7. Make a change

**Go here for:** changing anything on a device the right way.

- **The process** — [`Atlas-Change-Management-Process`](./Atlas-Change-Management-Process.md)
- 📋 **The templates** — [`Change-Record-Template`](../Templates/Change-Record-Template.md) · [`Major-Change-Record-Template`](../Templates/Major-Change-Record-Template.md)
- **The rule** — [`POL-0003` Change Control](../Policies/POL-0003-Change-Control.md) *(a silo-crossing change needs a record; nothing closes without a read-back)*
- ⚙️ **The workflow** — [`Atlas-Workflow` §4 change closeout](./Atlas-Workflow.md#4-change-closeout) *(not done until the guides it invalidates are reconciled)* + [§1 source priority](./Atlas-Workflow.md#1-source-priority--read-this-first)
- 🔧 **Prove it took:** [Confirm-a-Config-Change-Actually-Took](../../Atlas-Academy/Playbooks/Confirm-a-Config-Change-Actually-Took.md)
- 📚 **Academy (learn it)** — concept: [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) *(a green prompt is not proof)* · playbook: [Confirm-a-Config-Change-Actually-Took](../../Atlas-Academy/Playbooks/Confirm-a-Config-Change-Actually-Took.md)

---

## 8. Document something

**Go here for:** writing a doc, a build record, or a build guide.

- **The architecture** — [`Atlas-Documentation-Standard`](../Documentation/Atlas-Documentation-Standard.md)
- ⚙️ **The workflow** — [`Atlas-Workflow`](./Atlas-Workflow.md): [§1 source priority](./Atlas-Workflow.md#1-source-priority--read-this-first) · [§2 page lifecycle](./Atlas-Workflow.md#2-the-page-lifecycle) · [§3 evidence status](./Atlas-Workflow.md#3-evidence-status) · [§6 git](./Atlas-Workflow.md#6-git-workflow)
- 📋 **The templates** — [`Build-Record-Template`](../Templates/Build-Record-Template.md) · [`Build-Guide-Template`](../Templates/Build-Guide-Template.md) · [`ADR-Template`](../Templates/ADR-Template.md) · [`Device-Verification-Procedure-Template`](../Templates/Device-Verification-Procedure-Template.md) · [`Device-Considerations-and-Risks-Template`](../Templates/Device-Considerations-and-Risks-Template.md)
- **The rule** — [`POL-0014` Documentation & Knowledge Management](../Policies/POL-0014-Documentation-and-Knowledge-Management.md)
- 📋 **Writing a policy?** — [`POL-Template`](../Templates/POL-Template.md)
- 📚 **Academy (learn it)** — the teaching voice: [Atlas Teaching Patterns & House Style](../../Atlas-Academy/Atlas-Teaching-Patterns-and-House-Style.md) · worked example: [How to Make a Windows Build Record](../../Atlas-Academy/How-To-Make-a-Windows-Build-Record.md) · what the Academy is for: [Academy Vision & Scope](../../Atlas-Academy/Academy-Vision-and-Scope.md)

---

## 9. Governance and decisions

**Go here for:** how Atlas governs itself and why things were decided.

> 📖 **Full directory:** [Governance and Decisions (Academy)](../../Atlas-Academy/Directory/Governance-and-Decisions.md) — the layer hierarchy, the full Policy + Standard registers, the amendment model, and the preserved legacy-ADR trail, described.

- **Start here** — [`Atlas-Governance-Framework`](./Atlas-Governance-Framework.md) *(the model + the folder map)*
- **The standing rules** — the register in [`Policies/`](../Policies/) (`POL-0001`…`POL-0016`)
- **Every decision** — [`ADR-Index`](../Decisions/ADR-Index.md)
- **The registers** — [`Policies/README`](../Policies/README.md) (16 POLs) · [`Standards/README`](../Standards/README.md) (12 STDs) · the pre-reconciliation trail [`Legacy-ADR-Index`](../Decisions/Legacy-ADR-Index.md)
- **The reconciliation in progress** — [`Governance-Reconciliation-Triage`](./Governance-Reconciliation-Triage.md)
- **The audit rule** — [`POL-0001` Audit](../Policies/POL-0001-Atlas-Audit-Policy.md)
- ⚙️ **Change the governance itself** — [`Atlas-Workflow` §5 governance change workflow](./Atlas-Workflow.md#5-governance-change-workflow) *(freeze → fold → backfill → regenerate → currency checklist)*

<details>
<summary>📚 <b>The full register — every policy, standard, and governance doc</b></summary>

**Policies (`POL-xxxx`) — the standing rules:** [POL-0001 Audit](../Policies/POL-0001-Atlas-Audit-Policy.md) · [POL-0002 Secrets](../Policies/POL-0002-Secrets-and-Credentials.md) · [POL-0003 Change Control](../Policies/POL-0003-Change-Control.md) · [POL-0004 Source of Truth](../Policies/POL-0004-Source-of-Truth.md) · [POL-0005 Backup & Recovery](../Policies/POL-0005-Backup-and-Recovery.md) · [POL-0006 Evidence & Verification](../Policies/POL-0006-Evidence-and-Verification.md) · [POL-0007 Hardening](../Policies/POL-0007-Hardening-Baseline.md) · [POL-0008 Naming & Addressing](../Policies/POL-0008-Naming-and-Addressing.md) · [POL-0009 Incident Response](../Policies/POL-0009-Incident-Response.md) · [POL-0010 Acceptable Use](../Policies/POL-0010-Acceptable-Use.md) · [POL-0011 Data Governance & Privacy](../Policies/POL-0011-Data-Governance-Classification-Privacy.md) · [POL-0012 Risk Management](../Policies/POL-0012-Risk-Management.md) · [POL-0013 Business Continuity](../Policies/POL-0013-Business-Continuity.md) · [POL-0014 Documentation](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) · [POL-0015 Engineering & Build](../Policies/POL-0015-Engineering-and-Build-Discipline.md) · [POL-0016 Realism & Learning](../Policies/POL-0016-Realism-and-Learning.md)

**Standards (`STD-xxxx`) — the *how* under a policy ([register](../Standards/README.md)):** [0001](../Standards/STD-0001-Password-and-Authentication.md) Password/Auth · [0002](../Standards/STD-0002-Access-Control.md) Access · [0003](../Standards/STD-0003-Physical-Security.md) Physical · [0004](../Standards/STD-0004-Encryption.md) Encryption · [0005](../Standards/STD-0005-Device-Documentation.md)–[0009](../Standards/STD-0009-Session-Planning-and-Handoff.md) documentation · [0010](../Standards/STD-0010-Incremental-Test-Gated-Build.md)–[0012](../Standards/STD-0012-Automation-and-IaC.md) build

**Governance docs:** [Framework](./Atlas-Governance-Framework.md) · [Workflow](./Atlas-Workflow.md) · [Change-Management](./Atlas-Change-Management-Process.md) · [Reconciliation triage](./Governance-Reconciliation-Triage.md)

**Templates:** [POL-Template](../Templates/POL-Template.md) · [ADR-Template](../Templates/ADR-Template.md) · [Change-Record](../Templates/Change-Record-Template.md) · [Build-Record](../Templates/Build-Record-Template.md)

</details>

---

## 10. Troubleshooting and the Academy

**Go here for:** the whole problem-solving library (every 🔧 above lives here).

- **Playbooks** (keyed by problem name) — [`Atlas-Academy/Playbooks/`](../../Atlas-Academy/Playbooks/README.md)
- **Command library — verify/inspect + troubleshoot commands, by platform:** [`Cisco-IOS`](../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [`RouterOS`](../../Atlas-Academy/Command-Library/RouterOS.md) · [`FortiOS`](../../Atlas-Academy/Command-Library/FortiOS.md) · [`Linux`](../../Atlas-Academy/Command-Library/Linux.md) · [`PowerShell-Tier0`](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) · [`Syslog-and-SNMP`](../../Atlas-Academy/Command-Library/Syslog-and-SNMP.md)
- **Per-device troubleshooting** — every device folder carries its own `Troubleshooting.md` (the device-specific issue log)
- **Concepts** (why it works) — [`Atlas-Academy/Concepts/`](../../Atlas-Academy/Concepts/)
- **How the Academy is built + navigated** — [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md)
- **The real-incident seam (frozen Lab-01)** — the device-verified records the playbooks are mined from: [`Labs/Lab-01-Mikrotik-Core/`](../../Labs/Lab-01-Mikrotik-Core/) · [`Operations/016-Network-Lessons-Learned`](../../Labs/Lab-01-Mikrotik-Core/Operations/016-Network-Lessons-Learned.md) · each device's `Troubleshooting.md` + `Build-Record.md` (SW01 · MKT01 · FGT01 · PI01 · PVE01). 🔒 Frozen (`ADR-0022`) — history; reconcile to the live design where they differ.

---

## 11. Automation and IaC

**Go here for:** scripts, infrastructure-as-code, and CI.

> 📖 **Full directory:** [Automation and IaC (Academy)](../../Atlas-Academy/Directory/Automation-and-IaC.md) — the two-homes model, the self-hosted git/CI capability, and the IaC discipline (idempotency · GitOps · policy-as-code), described — honestly marked mostly-designed.

- **The model** — [`ADR-0048` Automation & IaC](../Decisions/ADR-0048-Automation-and-IaC-Model.md) *(the per-device `Automation/` doc-type + the estate IaC capability)*
- **The self-hosted git/CI host** — [`CNT01-Container-Host/`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/) *(the #19 estate capability)*
- **Per-device automation** — each device's `Automation/` folder (scripts + how-tos)
- **The rule** — `POL-0015` Engineering & Build Discipline *(coming — folds `ADR-0041`/`0043`/`0048`)*
- 📚 **Academy (learn it)** — concept: [Ansible IaC Device Provisioning](../../Atlas-Academy/Concepts/Ansible-IaC-Device-Provisioning.md) · commands: [PowerShell-Tier0](../../Atlas-Academy/Command-Library/PowerShell-Tier0.md) · [Linux](../../Atlas-Academy/Command-Library/Linux.md)

---

## 12. Security program and compliance

**Go here for:** the security program beyond the devices — incident response, risk, privacy, awareness.

> 📖 **Full directory:** [Security Program and Compliance (Academy)](../../Atlas-Academy/Directory/Security-Program-and-Compliance.md) — the five program docs, the `305` scenario bar, the governing policies, and the Academy why-layer, described.

- **The program** ([`Security-Program/`](../Security-Program/)):
  - [`Atlas-Compliance-Program`](../Security-Program/Atlas-Compliance-Program.md) — the NIST CSF / CIS control mapping and how Atlas measures itself against it
  - [`Incident-Response-Playbook`](../Security-Program/Incident-Response-Playbook.md) — the step-by-step lifecycle for a suspected incident
  - [`Security-Awareness-Program`](../Security-Program/Security-Awareness-Program.md) — the human-layer posture (training, phishing)
  - [`Third-Party-Risk-Management`](../Security-Program/Third-Party-Risk-Management.md) — vendor and supply-chain risk handling
- **The scenario's bar** — [`305-Atlas-Industrial-Security-Requirements`](../Company-Profile/305-Atlas-Industrial-Security-Requirements.md) — the OT/industrial security requirements Atlas is built to meet
- **The rules** — [`POL-0002` Secrets](../Policies/POL-0002-Secrets-and-Credentials.md) · [`POL-0009` Incident Response](../Policies/POL-0009-Incident-Response.md) · [`POL-0011` Data Governance & Privacy](../Policies/POL-0011-Data-Governance-Classification-Privacy.md) · [`POL-0012` Risk Management](../Policies/POL-0012-Risk-Management.md)
- 📚 **Academy (learn it)** — concepts: [Risk as a Living Register](../../Atlas-Academy/Concepts/Risk-as-a-Living-Register.md) *(accepted-risk-needs-a-trigger)* · [Secrets & Credential Custody](../../Atlas-Academy/Concepts/Secrets-and-Credential-Custody.md) · [Identity-Aware vs Zone Firewall Policy](../../Atlas-Academy/Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md) · cert map: [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) · [Concepts index](../../Atlas-Academy/Concepts/)

<details>
<summary>🔧 <b>When it happens</b></summary>

- **A secret got committed to git** → [Respond-to-a-Committed-Secret](../../Atlas-Academy/Playbooks/Respond-to-a-Committed-Secret.md)
- **A key or credential leaked** → [Rotate-a-Leaked-Key](../../Atlas-Academy/Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md)

</details>

<details>
<summary>📚 <b>Go deeper — the security decisions</b></summary>

- **Segmentation & enforcement** → [ADR-0023](../Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) — the east-west firewall topology · [ADR-0038](../Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md) — inline IPS · [ADR-0047](../Decisions/ADR-0047-FGT01-FortiGuard-UTM.md) — perimeter UTM · [ADR-0050](../Decisions/ADR-0050-FGT01-TLS-Deep-Inspection-Scope-and-ICA01-Inspection-CA.md) — TLS deep-inspection scope
- **Identity & trust** → [ADR-0021](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) — tiered identity (Tier-0 protection) · [ADR-0009](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) — the IR + destroy-step lesson
- **Ownership** → [ADR-0018](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) — silos (Security owns audit)
- **Learn it (Academy)** → [Concepts](../../Atlas-Academy/Concepts/) — the "why it works" security modules · [Playbooks index](../../Atlas-Academy/Playbooks/README.md) · the **Security+ Domain-5** cert map
- **Device-level security** → see [§1 Security and perimeter](#1-security-and-perimeter) for the firewall / IPS / hardening pages

</details>

---

## Related

[`Atlas-Governance-Framework`](./Atlas-Governance-Framework.md) (§6 findability — this page is that router) · [`POL-0004`](../Policies/POL-0004-Source-of-Truth.md) (the rule that governs this page) · the repo [`INDEX.md`](../../INDEX.md) (full folder map) · `AI-Context/` (the machine-first counterpart).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-03. First cut — the quick-reference router: 10 numbered situation sections, each with authoritative docs + inline 🔧 troubleshooting (playbooks) + 📋 templates. Built from the live device roster (24) + Playbooks (21). Marks the Network/Server SoT registers as coming. |
| 0.2 | 2026-08-03. Added the ⚡ Fast-path table (the ~13 most common needs → one destination). |
| 0.3 | 2026-08-03. +§11 Automation & IaC · +§12 Security program & compliance · the frozen **Lab-01** real-incident seam · **per-platform command libraries + per-device `Troubleshooting.md`** under each domain (Cisco/RouterOS/FortiOS/Linux/PowerShell/Syslog) · **tied in `Atlas-Workflow`** (pairing callout + §7/§8/§9 deep-links into its sections). |
| 0.5 | 2026-08-03. Surfaced a visible **📚 Academy (learn it)** pointer line in every domain section (§1–§8, §11–§12) — the relevant Concepts, per-platform Command-Library pages, and cert map, at section level instead of only inside the go-deeper drawers (matches how §3/§4 lead with their Academy directory). |
| 0.4 | 2026-08-03. Rolled out the **two-drawer pattern** (collapsible 🔧 troubleshooting-by-symptom + 📚 go-deeper: runbooks · Academy · one build-record example · related decisions) across §1–§4, §6, §9, §12; enriched §12 with descriptive lines + the security-decision links (incl. the east-west firewall ADR); introduced the **per-domain deep-page** model — §4 links its full Academy directory [`Directory/Servers-and-Compute`](../../Atlas-Academy/Directory/Servers-and-Compute.md). |
| 0.6 | 2026-08-03. §1 Security & perimeter now leads with its **📖 Full directory** callout → the new [`Directory/Security-and-Perimeter`](../../Atlas-Academy/Directory/Security-and-Perimeter.md) Academy page (matching §3/§4). First of the four remaining per-domain twins from the `Session-29` brief. |
| 0.7 | 2026-08-03. §2 Identity & access now leads with its **📖 Full directory** callout → the new [`Directory/Identity-and-Access`](../../Atlas-Academy/Directory/Identity-and-Access.md) Academy page. Second of the four `Session-29` twins (Security ✅ · Identity ✅). |
| 0.8 | 2026-08-03. §5 Backup, recovery & continuity now leads with its **📖 Full directory** callout → the new [`Directory/Backup-Recovery-and-Continuity`](../../Atlas-Academy/Directory/Backup-Recovery-and-Continuity.md) Academy page. Third of the four `Session-29` twins. |
| 0.9 | 2026-08-03. §6 Monitoring & logging now leads with its **📖 Full directory** callout → the new [`Directory/Monitoring-and-Logging`](../../Atlas-Academy/Directory/Monitoring-and-Logging.md) Academy page. **Completes the four `Session-29` per-domain twins** (§1 §2 §5 §6 + the pre-existing §3 §4 — every twinned section now leads with its callout). |
| 0.10 | 2026-08-04. Wired the three new policy why-layer Concepts into the router: §5 now points at the new **A-Backup-Is-Not-a-Backup** concept (the restore-testing why-layer, replacing the A-Completed-Command stopgap); §12 adds **Risk as a Living Register** + **Secrets & Credential Custody**. |
| 0.11 | 2026-08-04. **Completed the per-domain Academy Directory twins** — §9 Governance & Decisions, §11 Automation & IaC, §12 Security-Program & Compliance each now lead with a 📖 Full-directory callout to their new Academy twin (joining §1–§6). Every substantive router section now has its exhaustive twin. |
