---
Title: Device Responsibilities
Path: Labs/Lab-01-Mikrotik-Core/Architecture
---

# Device Responsibilities

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Architecture

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | **2.1** |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## Responsibilities

| Platform | Primary Responsibilities | Explicit Exclusions |
|---|---|---|
| FGT01 | WAN uplink, perimeter firewall, NAT, return route (10.0.0.0/8 via MKT01), management interface on VLAN 10 | Inter-VLAN routing, DHCP, enterprise DNS |
| MKT01 | VLAN interfaces and gateways, inter-VLAN routing, east-west stateful firewall, transit route to FGT01, bridgeLocal recovery network | NAT, authoritative DNS, production DHCP |
| SW01 | Layer 2 switching, VLAN database, trunk ports, access ports, spanning tree root, DHCP snooping, ARP inspection, port security, storm control, SPAN | Layer 3 routing of any kind |
| PVE01 | Hypervisor host management on VLAN 10, VLAN-aware bridge (vmbr0), per-VM VLAN assignment via virtual NIC tags | Physical routing, perimeter security, DHCP, DNS |
| 🔴 **Pi01** | **FOUR roles on one Raspberry Pi:** (1) **Lab CA** — Root + Intermediate private keys; (2) **Vaultwarden** — every credential in the lab; (3) **Pi-hole** — DNS filtering forwarder; (4) **FreeRADIUS** — device AAA for FGT01 and MKT01 | Authoritative enterprise DNS (Windows Server AD DNS takes this role when deployed). **Must NOT be domain-joined** — see `ADR-0004`. |
| Windows Server | AD DS, authoritative DNS, DHCP, AD-integrated NTP hierarchy, PKI via ADCS (planned Phase 3) | Perimeter NAT |
| Cisco 1941 | Planned replacement for MKT01 — inter-VLAN routing via router-on-a-stick, OSPF toward FGT01, east-west ACLs, CCNA/CCNP routing lab | Production forwarding until Change Record executed |

## Planned Evolution — Cisco 1941

The Cisco 1941 is the planned successor to MKT01 in the inter-VLAN routing role. When deployed it will:

- Replace MKT01's router-on-a-stick function using IOS subinterfaces
- Run OSPF toward FGT01 over the transit link (replacing static routing)
- Implement east-west access control via IOS extended named ACLs (replacing MikroTik firewall rules)
- Enable CCNA/CCNP lab scenarios: HSRP, IP SLA, zone-based firewall, routing protocol redistribution

This change requires a Phase 1.5 Change Record. MKT01 remains in production until the cutover is validated.

## Troubleshooting Ownership

Work from the lowest layer upward. Do not assume a higher-layer problem until the lower layer is confirmed healthy.

| Layer | Owner | First Command |
|---|---|---|
| Physical link | SW01 | `show interfaces status` |
| VLAN and trunk | SW01 | `show vlan brief` / `show interfaces trunk` |
| Layer 2 security | SW01 | `show ip arp inspection` / `show ip dhcp snooping` |
| VLAN gateway and routing | MKT01 | `/ip address print` / `/ip route print` |
| East-west firewall | MKT01 | `/ip firewall filter print stats` |
| Perimeter and NAT | FGT01 | `get router info routing-table all` / `show firewall policy` |
| DNS | Pi-hole → Windows Server (future) | `nslookup <name> 10.10.0.5` |
| VM networking | PVE01 | `ip a` on VM / check VLAN tag in Proxmox GUI |

## Single Responsibility Rule

Each platform has one primary role. If a proposed change asks a device to take on a responsibility listed in another device's Explicit Exclusions column, stop and question the design before implementing. Examples of violations to avoid:

- Enabling NAT on MKT01 (FGT01's responsibility)
- Configuring routing on SW01 (MKT01's responsibility)
- Using PVE01 vmbr0 as a router between VLANs (MKT01's responsibility)
- Running authoritative DNS on Pi-hole permanently (Windows Server's planned responsibility)

## 🔴 The rule above is already broken — by Pi01

**"Each platform has one primary role."** Pi01 has **four**: the Lab CA, Vaultwarden, Pi-hole, and FreeRADIUS.

| What Pi01 holds | If Pi01 dies |
|---|---|
| **Root + Intermediate CA private keys** | No certificate can be issued or reissued |
| **Vaultwarden** | Every credential in the lab is inaccessible |
| **Pi-hole** | All local DNS resolution stops |
| **FreeRADIUS** | FGT01 and MKT01 admin logins fall back to local accounts |

🔴 **And it has failed once already** — an unexplained hard hang requiring a physical power cycle. **Root cause never found.**

**This is not an oversight to fix by moving services around today.** It is a recorded, accepted concentration of risk, and it is *why* `ADR-0004` refuses to domain-join Pi01: adding a Samba/winbind stack and a Kerberos dependency would make the lab's single point of failure also depend on a domain controller — a VM, on PVE01, whose **CMOS battery is dead** (`CM-0012`).

> **A Single Responsibility Rule that does not name its biggest violator is not a rule. It is a preference.** The violation is stated here so a future engineer meets it deliberately rather than discovering it during an outage.
