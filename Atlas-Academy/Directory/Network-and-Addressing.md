---
Title: Network and Addressing — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §3. Real, device-verified examples from frozen Lab-01.
Version: 0.1
Date: 2026-08-03
---

# Network and Addressing — Full Directory

> **The deep version of [Source-of-Truth §3](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#3-network-and-addressing).** The router gives the one-glance answer; this page carries the whole picture **and the real examples** — the frozen Lab-01 build records, build guides, and change records were made *at the machine*, so they show exactly how a switch, router, or firewall was actually built, broke, and got fixed.
>
> 🔒 **Lab-01 is frozen (`ADR-0022`) — history, not current guidance.** Where a Lab-01 doc disagrees with the live Lab-02 design, the live design wins (`POL-0001`). Read these for *how it really went*; reconcile to the current build.

## On this page

1. [The network devices](#1-the-network-devices)
2. [Addressing and topology](#2-addressing-and-topology)
3. [Real change-management examples (Lab-01)](#3-real-change-management-examples-lab-01) — the goldmine
4. [Build records and guides (real examples)](#4-build-records-and-guides-real-examples)
5. [Commands — Cisco, MikroTik, Linux](#5-commands--cisco-mikrotik-linux)
6. [Playbooks and decisions](#6-playbooks-and-decisions)

---

## 1. The network devices

| Device | Role | Live (Lab-02) | Real example (frozen Lab-01) |
|---|---|---|---|
| Access switch | VLANs, trunking, L2 security | [`SW01-Access-Switch`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/) | [Lab-01 SW01](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/) — device-verified |
| Core router | inter-VLAN routing, core | [`1941-Core-Router`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/) | — |
| East-west firewall | intra-LAN segmentation | [`MKT01-East-West-Firewall`](../../Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/) | [Lab-01 MKT01](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/) — the richest firewall seam |
| Perimeter firewall | edge, UTM | [`FGT01-Perimeter-Firewall`](../../Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/) | [Lab-01 FGT01](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/) |

## 2. Addressing and topology

- [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) — the one authoritative plan (→ NetBox); [`IPv6-Addressing-Plan`](../../Labs/Lab-02-Cisco-Core/Architecture/IPv6-Addressing-Plan.md)
- [`Cabling-and-Port-Map`](../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md) · [`Atlas-East-West-Allowed-Flows-Matrix`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md)
- The rules: [`POL-0008` Naming & Addressing](../../00-Atlas-Foundation/Policies/POL-0008-Naming-and-Addressing.md) · [`POL-0004` Source of Truth](../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md)

## 3. Real change-management examples (Lab-01)

**The goldmine.** Every one below is a real, dated change on a real device, with the read-back that proved it. This is what a good `CM`/`MC` record looks like — and each teaches a trap.

**VLANs, ports & interfaces**
- [`CM-0003` — Disable SW01 Gi1/0/3](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0003-Disable-SW01-Gi1-0-3.md) — shut an unused access port (`ADR-0002`)
- [`CM-0001` — SW01 Gi1/0/1 description fix](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0001-SW01-Gi1-0-1-Description-Fix.md) — the doc held the last stale label; the device was already right (Rule 13)
- [`CM-0015` — Disable MKT01 ether2](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0015-Disable-MKT01-ether2.md) · [`CM-0035` — Disable MKT01 unused bridgeLocal ports](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0035-Disable-MKT01-Unused-bridgeLocal-Ports.md)

**Layer-2 security — the "silently dropped host" saga**
- [`CM-0022` — SW01 build guide rebuilds a switch that drops Pi01](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0022-SW01-Build-Guide-Rebuilds-a-Switch-That-Drops-Pi01.md) — the DAI / `STATIC-HOSTS` omission that produced a "mystery" surviving three handoffs. The single best source-of-truth lesson in the estate.

**Firewall rules**
- [`CM-0009` — Remove obsolete MKT01 RADIUS rules](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0009-Remove-Obsolete-MKT01-RADIUS-Rules.md) — prove-a-rule-is-dead before removing it
- [`CM-0006` — Disable MikroTik reverse proxy](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0006-Disable-MikroTik-Reverse-Proxy.md)
- [`CM-0033` — FGT01 five live undocumented ports](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/CM-0033-FGT01-Five-Live-Undocumented-Ports.md) · [`CM-0004` — Disable unused FGT01 interfaces](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/CM-0004-Disable-Unused-FGT01-Interfaces.md) — enumerate live before you harden

**Time & SNMP (the "configured ≠ working" traps)**
- [`CM-0030` — SW01 clock has never synchronised](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0030-SW01-Clock-Has-Never-Synchronised.md) — pointed at an NTP source, stratum 16, never synced (`ADR-0020`)
- [`CM-0023` — Remove carried-over SW01 v2c SNMP community](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0023-Remove-Carried-Over-SW01-v2c-SNMP-Community.md) · [`CM-0037` — Remove live SNMP location string](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0037-Remove-Live-SNMP-Location-String-from-SW01.md)

**Recovery / out-of-band**
- [`CM-0017` — MKT01 MAC-server state investigation](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0017-MKT01-MAC-Server-State-Investigation.md) · [`CM-0018` — Establish MKT01 MAC-WinBox recovery path](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0018-Establish-MKT01-MAC-WinBox-Recovery-Path.md)
- [`CM-0021` — MKT01 Build-Guide recovery-path regression](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0021-MKT01-Build-Guide-Recovery-Path-Regression.md) — hardening deleted the recovery path

> The estate-wide lesson these share (from [`016-Network-Lessons-Learned`](../../Labs/Lab-01-Mikrotik-Core/Operations/016-Network-Lessons-Learned.md), 62 KB): *a command that returns no error is not a confirmed change — read the state back.*

## 4. Build records and guides (real examples)

The device-verified pattern the [Build-Record template](../../00-Atlas-Foundation/Templates/Build-Record-Template.md) is cut from:

- **SW01 (Cisco IOS)** — [Build-Record](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Record.md) · [Build-Guide](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Guide.md) · [Verification](../../Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Verification.md)
- **MKT01 (RouterOS)** — [Build-Record](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Record.md) · [Build-Guide](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Guide.md) · the [Firewall per-rule tests](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Firewall-Per-Rule-Verification-Tests.md)
- **FGT01 (FortiOS)** — [Build-Record](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Build-Record.md) · [Build-Guide](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Build-Guide.md)

## 5. Commands — Cisco, MikroTik, Linux

Verify/inspect + troubleshoot commands **for this lab and its target state** — grounded in the real devices:

- 🖥️ [Cisco-IOS](../Command-Library/Cisco-IOS.md) — `show vlan`, `show interfaces status`, `show ip arp inspection`, `show spanning-tree`
- 🖥️ [RouterOS](../Command-Library/RouterOS.md) — `/interface print`, `/ip firewall filter print stats`, `/ip address print`
- 🖥️ [Linux](../Command-Library/Linux.md) — `ip -br a`, `ip r`, `ss -tulpn`, `ping`/`traceroute`, `resolvectl`
- 🖥️ [Syslog-and-SNMP](../Command-Library/Syslog-and-SNMP.md) — reading centralized logs + SNMP polling health

> 🔧 **Growing this:** more real `show`/read commands and PowerShell (`Get-NetIPConfiguration`, `Test-NetConnection`, `Get-NetAdapter`) get captured **at the machine** as Lab-02 is built (backlog #36 harvest). For now these are the Lab-01-proven set + the target-state additions.

## 6. Playbooks and decisions

- 🔧 **Playbooks** — [Trace-a-Blocked-Flow](../Playbooks/Trace-a-Blocked-Flow.md) · [MikroTik-EastWest-Inspect](../Playbooks/MikroTik-EastWest-Inspect-and-Troubleshoot.md) · [Prove-Exactly-Which-MikroTik-Rule-Acted](../Playbooks/Prove-Exactly-Which-MikroTik-Rule-Acted.md) · [Diagnose-a-Host-Silently-Dropped-by-DAI](../Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md) · [Fix-the-SW01-Clock](../Playbooks/Fix-the-SW01-Clock.md) · [Test-a-Connection](../Playbooks/Test-a-Connection.md)
- 🏛️ **Decisions** — [ADR-0023](../../00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) (topology) · [ADR-0002](../../00-Atlas-Foundation/Decisions/ADR-0002-SW01-Gi1-0-3-VLAN-Assignment.md) (VLAN assignment) · [ADR-0030](../../00-Atlas-Foundation/Decisions/ADR-0030-DHCP-on-DC01.md) (DHCP) · [ADR-0020](../../00-Atlas-Foundation/Decisions/ADR-0020-NTP-Time-Source-Architecture.md) (time)

## Related

[Source-of-Truth router §3](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#3-network-and-addressing) (the quick view) · [Servers and Compute directory](./Servers-and-Compute.md) · [`016-Network-Lessons-Learned`](../../Labs/Lab-01-Mikrotik-Core/Operations/016-Network-Lessons-Learned.md) · [`POL-0004`](../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) · [`POL-0008`](../../00-Atlas-Foundation/Policies/POL-0008-Naming-and-Addressing.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-03. First cut — network directory anchored in **real frozen-Lab-01 examples**: the device roster (live + Lab-01), the change-management goldmine (VLANs/ports · L2-security "dropped Pi01" · firewall rules · time/SNMP · recovery), the build records/guides the template is cut from, the Cisco/MikroTik/Linux command sets for this lab + target state, and the playbooks/decisions. |
