---
Title: Servers and Compute — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §4. Every host, every doc, described.
Version: 0.1
Date: 2026-08-03
---

# Servers and Compute — Full Directory

> **The deep version of [Source-of-Truth §4](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#4-servers-and-compute).** The router gives you the one-glance answer; this page is the *encyclopedia* — every server and hypervisor in the estate, what it does, and every doc that governs or describes it. Keep the router in a tab for speed; come here when you want the whole picture.
>
> Each host folder carries the standard page-set (`ADR-0037`): **README** (front door + Services map) · **Build-Guide** (target) · **Build-Record** (verified reality) · **Diagnostics / Troubleshooting** · **Considerations** · **Changes/** · **Automation/**.

## On this page

1. [Hypervisors](#1-hypervisors)
2. [Windows servers](#2-windows-servers)
3. [Linux servers](#3-linux-servers)
4. [PKI hosts](#4-pki-hosts)
5. [Placement, sizing and topology](#5-placement-sizing-and-topology)
6. [The decisions (ADRs)](#6-the-decisions-adrs)
7. [Templates and how-tos](#7-templates-and-how-tos)
8. [Troubleshooting and the Academy](#8-troubleshooting-and-the-academy)

---

## 1. Hypervisors

| Host | Role | Docs |
|---|---|---|
| [`PVE01-Hypervisor`](../../Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor/) | The R410 Proxmox host — heavier, spin-up tier; device-verified networking (`ADR-0034`) | README · Build-Records · Diagnostics · Considerations |
| [`PVE02-Hypervisor`](../../Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor/) | The Beelink EQR6 Proxmox host — low-power always-on critical tier | README · [commissioning checklist](../../Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor/) |

The Proxmox pack (build records + networking ownership) lives under [`Virtualization/`](../../Labs/Lab-02-Cisco-Core/) and is front-doored by the `Devices/PVE0x` folders.

## 2. Windows servers

| Host | Role |
|---|---|
| [`DC-Domain-Controllers`](../../Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/) | The AD DS domain controllers — the tiered-identity backbone (`ADR-0021`); DNS + DHCP (`ADR-0030`) |
| [`NPS01-Network-Policy-Server`](../../Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server/) | RADIUS / 802.1X network-device auth (`ADR-0029`) |
| [`FS01-File-Services`](../../Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services/) | File services (shares, DFS, quotas) |
| [`WSUS01-Patch-Management`](../../Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management/) | Windows update management |
| [`SQL01-Database`](../../Labs/Lab-02-Cisco-Core/Devices/SQL01-Database/) | SQL Server — hosts the `AtlasHR` pipeline source |
| [`RDS01-Remote-Desktop`](../../Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop/) | Remote Desktop Services |
| [`WAC01-Windows-Admin-Center`](../../Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center/) | Windows Admin Center gateway (a Tier-0 admin surface) |
| [`PAW01-Tier0-Admin`](../../Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/) | The Privileged Access Workstation — the strongest baseline (`ADR-0021`) |

📘 **Building or recording one?** → [How-To-Make-a-Windows-Build-Record](../How-To-Make-a-Windows-Build-Record.md) + the [Windows build-record template](../../00-Atlas-Foundation/Templates/Build-Record-Windows-Template.md).

## 3. Linux servers

| Host | Role |
|---|---|
| [`NETBOX01-Source-of-Truth`](../../Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth/) | NetBox (IPAM/DCIM) — the emerging data source of truth (`POL-0004`) |
| [`BKP01-Backup`](../../Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/) | Backup + Vaultwarden (secrets) — the 3-2-1 host (`POL-0005`) |
| [`SRV01-Network-Services`](../../Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services/) | Network services host |
| [`SIEM01-Wazuh`](../../Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh/) | Wazuh SIEM — security telemetry |
| [`MON01-Monitoring`](../../Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/) | Syslog / SNMP / LibreNMS observability sink |
| [`CNT01-Container-Host`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/) | Docker/Podman + the self-hosted git/CI (`ADR-0048`, #19) |
| [`Pi01-DNS-NTP`](../../Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP/) | Pi-hole DNS filtering (`ADR-0051`) + chrony NTP |
| [`KALI01`](../../Labs/Lab-02-Cisco-Core/Devices/KALI01/) | The offensive/testing box |

## 4. PKI hosts

| Host | Role |
|---|---|
| [`RCA01-ICA01-ADCS`](../../Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/) | The two-tier Microsoft PKI — offline Root (RCA01) → issuing sub-CA (ICA01) (`ADR-0027`, `ADR-0031`) |

## 5. Placement, sizing and topology

- [`Service-Server-Build-Plan`](../../Labs/Lab-02-Cisco-Core/Service-Server-Build-Plan.md) — the interim single source for host placement + VM sizing (#20)
- [`Master-Build-Order`](../../Labs/Lab-02-Cisco-Core/Architecture/Master-Build-Order.md) · `Operations/Build-Order-and-Dependencies` — the cross-device build sequence
- Addressing for every host → [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) → NetBox

## 6. The decisions (ADRs)

- [`ADR-0036`](../../00-Atlas-Foundation/Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md) — compute topology + VM placement (the 2-hypervisor tiering)
- [`ADR-0045`](../../00-Atlas-Foundation/Decisions/ADR-0045-AZ800-801-Compute-Additions-WAC-Container-RODC.md) — AZ-800/801 additions (WAC01, container host, RODC)
- [`ADR-0046`](../../00-Atlas-Foundation/Decisions/ADR-0046-Two-Node-Failover-Cluster-and-S2D.md) — two-node failover cluster + Storage Spaces Direct
- [`ADR-0034`](../../00-Atlas-Foundation/Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md) — PVE01 networking has one authoritative home
- [`ADR-0039`](../../00-Atlas-Foundation/Decisions/ADR-0039-Commit-Full-Hybrid-Enterprise-Scope.md) — commit to the full hybrid enterprise scope
- [`ADR-0042`](../../00-Atlas-Foundation/Decisions/ADR-0042-Client-Workstation-Fleet-and-Department-Resource-Access.md) — the client workstation fleet

## 7. Templates and how-tos

- 📋 [Windows build-record template](../../00-Atlas-Foundation/Templates/Build-Record-Windows-Template.md) + 📘 [How-To-Make-a-Windows-Build-Record](../How-To-Make-a-Windows-Build-Record.md)
- 📋 [Generic build-record template](../../00-Atlas-Foundation/Templates/Build-Record-Template.md) · [Build-Guide template](../../00-Atlas-Foundation/Templates/Build-Guide-Template.md)
- 📋 [New-Windows-Server-Commissioning-Checklist](../../00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx) — the golden run-sheet

## 8. Troubleshooting and the Academy

- 🔧 **Playbooks** — [Proxmox-Inspect-and-Troubleshoot](../Playbooks/Proxmox-Inspect-and-Troubleshoot.md) · [Recover-the-Lab-from-a-Bare-Metal-Teardown](../Playbooks/Recover-the-Lab-from-a-Bare-Metal-Teardown.md) · [Domain-Join-Fails](../Playbooks/Domain-Join-Fails.md) · [Read-the-Logs-with-journalctl](../Playbooks/Read-the-Logs-with-journalctl.md)
- 🖥️ **Command libraries** — [PowerShell-Tier0](../Command-Library/PowerShell-Tier0.md) (Windows) · [Linux](../Command-Library/Linux.md)
- 🎓 **Concepts + cert alignment** — [Concepts](../Concepts/) · the **AZ-800/801** hybrid-lab cert map
- 🔩 **Per-host** — each host's own `Diagnostics.md` / `Troubleshooting.md`

## Related

[Source-of-Truth router §4](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#4-servers-and-compute) (the quick view) · [`POL-0004`](../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) · [`POL-0015` Engineering & Build](../../00-Atlas-Foundation/Policies/POL-0015-Engineering-and-Build-Discipline.md) · [`Atlas-Workflow` §1 source priority](../../00-Atlas-Foundation/Governance/Atlas-Workflow.md#1-source-priority--read-this-first).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-03. First cut — the exhaustive twin of Source-of-Truth §4: every hypervisor, Windows server, Linux server, and PKI host with its role + page-set; placement/sizing; the compute ADRs; templates + how-tos; troubleshooting + Academy. The model for per-domain directory pages. |
