---
Title: Enterprise Network Overview
Path: Labs/Lab-01-Mikrotik-Core/Architecture
---

# Enterprise Network Overview

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Architecture

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — reconciled 2026-07-14 (051 Tier 3); DEVICE CHECK D2/D5 pending |
| Version | 2.3 |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07-16 |

## Purpose

Atlas provides a segmented enterprise-style network for infrastructure services, virtualization, Microsoft server workloads, monitoring, security testing, and certification labs. The design separates perimeter security, routing, switching, and virtualization so each platform has a single, clear responsibility.

## Current Architecture

```text
Internet
  |
Home/ISP Router (172.31.4.1)
  |
FGT01 — FortiGate 60E
  wan1: DHCP from home router
  internal1: 172.16.0.1/29 (transit)
  internal2: 10.10.0.254/24 (management, VLAN 10)
  |
Transit 172.16.0.0/29
  |
MKT01 — MikroTik RB1100AHx4 Dude Edition, 64 GB SATA SSD
  ether1: 172.16.0.2/29
  ether3: 802.1Q trunk to SW01
  bridgeLocal: 10.0.0.1/24 (recovery)
  vlan10-mgmt through vlan80-dmz: VLAN gateways
  |
SW01 — Cisco WS-C2960X-48FPS-L
  Gi1/0/1: trunk to MKT01 (native 999)
  Gi1/0/4: trunk to PVE01 (native 10)
  Gi1/0/6: access VLAN 10 to FGT01 internal2
  Gi1/0/7: access VLAN 10 to Pi01 (Root CA, Intermediate CA, Vaultwarden, FreeRADIUS, Pi-hole DNS)
  |
PVE01 — Dell PowerEdge R410 / Proxmox VE 8.4
  eno1 → vmbr0: 10.10.0.10/24 (VLAN 10, untagged)
  VM workloads: tagged virtual NICs per VLAN
```

## Primary Roles

| Device | Role | Does Not Provide |
|---|---|---|
| FGT01 | Internet edge, perimeter firewall, NAT, perimeter logging | Inter-VLAN routing, DHCP, DNS |
| MKT01 | VLAN gateways, inter-VLAN routing, east-west firewall | NAT, authoritative DNS, DHCP |
| SW01 | Layer 2 switching, trunks, access ports, STP, DHCP snooping, ARP inspection, SPAN | Layer 3 routing |
| PVE01 | Virtual workloads, VLAN-aware bridge, tagged VM networking | Routing, NAT, DHCP, DNS |
| Pi01 | Root CA + Intermediate CA, Vaultwarden, FreeRADIUS, and Pi-hole DNS — the lab's most load-bearing host | Authoritative enterprise DNS (that becomes Windows Server's role when deployed) |
| Windows Server | AD DS, authoritative DNS, DHCP, NTP hierarchy, PKI (planned) | Perimeter NAT |

## Operating Principles

- Build Guides describe the target state. Build Records describe verified reality.
- Production changes use a Change Record. Keep changes small, testable, and reversible.
- Confluence is the human-facing source of truth. Git is the version-controlled source.
- Common operational information is reachable within three clicks.
- Windows Server will become the authoritative enterprise DNS and DHCP platform when deployed. 🔴 **Pi-hole is currently a load-bearing resolver for the lab and must not be treated as disposable** (`013` v2.0 / `017` v2.0 were both rewritten to kill the "optional forwarder" wording — a reader who acted on it would have removed a live service). Any change to Pi-hole's role goes through a Change Record; its exact place in the resolver chain during the AD transition is pending device reconciliation (DEVICE CHECK D2).
- The Cisco 1941 is planned as the future replacement for MKT01 in the inter-VLAN routing role (OSPF, HSRP, IP SLA practice). 🔴 **This is not a near-term change record.** `ADR-0015` re-sequenced it as **Book 11** (after Book 10) and **gated** it: it requires restore-tested SW01/MKT01 backups **and** an ADR explicitly reversing Routing Standard `009`, which currently keeps the 1941 outside the production forwarding path. MKT01 remains in production.

## Current Known Deviations

| Item | Target | Current | Notes |
|---|---|---|---|
| ~~SW01 hostname~~ | SW01 | ✅ **CLOSED 2026-07-16** — device-verified `hostname SW01` (`CM-0022`); the deviation was stale | — |
| DNS | Windows Server AD → Pi-hole → 1.1.1.1 | 1.1.1.1/8.8.8.8 direct | Interim until Windows Server deployed |
| DHCP | Windows Server | Not deployed | Interim until Windows Server deployed |
| NTP | Windows Server AD hierarchy (PDC emulator) | pool.ntp.org — **SW01 excepted: never synced** | Decision `ADR-0020`; SW01 fix `CM-0030` |
| iDRAC credentials | Hardened, vaulted | Password changed at the console 2026-07-16 (no longer factory) | Onboarding blocked on `CM-0012` → `050` |
| PVE01 GUI shell | Functional | VNC connection refused | SSH is working substitute |
| Cisco 1941 | Future MKT01 replacement | Not yet deployed | Planned Phase 1.5 |

## Related Pages

Physical Topology · Logical Topology · Network Source of Truth · VLAN Standards · Device Responsibilities · Build Records · Build Guides · Network Validation Guide

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Verified overview. |
| 2.1 | 2026-07-14 reconciliation batch (051 Tier 3 / A1, A2, A5, A11). Removed the "Pi-hole is optional" wording (killed in `013`/`017`); added Pi01 and its load-bearing services to the topology and roles; corrected the 1941 framing to the gated Book 11 per `ADR-0015`; removed the closed MKT01-hostname deviation (`006` device-confirmed, `022`). **Left for the operator (not edited):** the DNS deviation row (three documents disagree — DEVICE CHECK D2 settles it); the iDRAC-credentials row (the admin password is genuinely still factory per `044`/Tier 2 — DEVICE CHECK D5); and the `SW01 hostname` deviation, which conflicts with `016`'s 2026-07-14 device pass (hostname reported already `SW01`) — flagged, pending the operator's ruling and `CM-0024`. |
| 2.2 | 2026-07-15 — MKT01 device-reconciliation. Recorded MKT01's full model as **`RB1100AHx4 Dude Edition`** (the device `board-name` from `/system resource`) and its **64 GB SATA SSD** (`/disk print`); the plain `RB1100AHx4` here was incomplete. Device-confirmed, not transcribed. |
| 2.3 | 2026-07-16 — SW01 hostname deviation **CLOSED** (device `SW01`, `CM-0022`); NTP row points to `ADR-0020` (SW01 clock broken, `CM-0030`); iDRAC password changed at the console (onboarding blocked on `CM-0012`→`050`). |
