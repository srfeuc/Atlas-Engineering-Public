---
Title: Network Source of Truth
Path: Labs/Lab-01-Mikrotik-Core/Architecture
---

# Network Source of Truth

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Architecture

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | **2.3** |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07-16 |

## Rule

This page is the authoritative reference for all network addresses, MACs, VLANs, and port assignments. Update this page first when any authoritative value changes. Other pages summarize and link here — they do not duplicate these tables.

---

## Device Inventory

| Hostname | Platform | Role | Management IP | Access |
|---|---|---|---|---|
| FGT01 | FortiGate 60E | Perimeter firewall, NAT | 10.10.0.254 (internal2) | https://10.10.0.254 or ssh admin@10.10.0.254 |
| MKT01 | MikroTik RB1100AHx4 Dude Edition, 64 GB SATA SSD | Core router, inter-VLAN routing | 10.10.0.1 (vlan10-mgmt) or 10.0.0.1 (bridgeLocal) | WinBox to 10.0.0.1 or 10.10.0.1 |
| SW01 | Cisco WS-C2960X-48FPS-L | Layer 2 switching | 10.10.0.2 (VLAN 10 SVI) | ssh sw01 (see SSH config) |
| PVE01 | Dell PowerEdge R410 / Proxmox VE 8.4 | Hypervisor | 10.10.0.10 (vmbr0) | https://10.10.0.10:8006 or ssh root@10.10.0.10 |
| iDRAC-PVE01 | Dell iDRAC | 🔴 **NOT out-of-band — shared LOM on `eno1`/`Gi1/0/4`.** Dies with SW01. | 10.10.0.100 | https://10.10.0.100 |
| **Pi01** | Raspberry Pi | 🔴 **Four roles: Lab CA (Root + Intermediate keys), Vaultwarden (every credential), Pi-hole DNS, FreeRADIUS (device AAA).** The lab's single largest point of failure. | 10.10.0.5 | ssh -p 2222 dnsadmin@10.10.0.5 |

---

## MAC Address Reference

| Device | Interface | MAC | Notes |
|---|---|---|---|
| PVE01 | eno1 (primary NIC) | 00:00:5e:3f:f6:a2 | In SW01 STATIC-HOSTS as 0000.5e00.5313 |
| PVE01 | eno2 (secondary NIC) | 00:00:5e:3f:f6:a3 | Unused — DOWN |
| iDRAC-PVE01 | iDRAC NIC | 00:00:5e:3f:f6:a4 | Sequential MAC after eno2. In SW01 STATIC-HOSTS as 0000.5e00.5314 |
| FGT01 | internal2 | 00:00:5e:00:53:03 | Confirmed via `diagnose hardware deviceinfo nic internal2`. In SW01 STATIC-HOSTS as 0000.5e00.5315 |
| Admin workstation | Ethernet 2 | 00:00:5e:00:53:04 | In SW01 STATIC-HOSTS as 0000.5e00.5316 — update if workstation changes |

> Dell PowerEdge R410 assigns sequential MACs: eno1 (f6:a2), eno2 (f6:a3), iDRAC (f6:a4). Do not reuse an adjacent interface MAC when adding STATIC-HOSTS entries.

---

## IP Address Assignments — VLAN 10 (Management)

| Device | IP | MAC | DHCP or Static | SW01 Port |
|---|---|---|---|---|
| MKT01 vlan10-mgmt gateway | 10.10.0.1 | N/A | Static | N/A — MikroTik |
| SW01 VLAN 10 SVI | 10.10.0.2 | N/A | Static | N/A — switch itself |
| Pi-hole | 10.10.0.5 | 00:00:5e:00:53:05 | Static | Gi1/0/7 |
| PVE01 eno1 | 10.10.0.10 | 00:00:5e:3f:f6:a2 | Static | Gi1/0/4 |
| iDRAC-PVE01 | 10.10.0.100 | 00:00:5e:3f:f6:a4 | Static | Gi1/0/4 (shared port) |
| Admin workstation | 10.10.0.50 | 00:00:5e:00:53:04 | Static (set manually) | Gi1/0/2 |
| FGT01 internal2 | 10.10.0.254 | 00:00:5e:00:53:03 | Static | Gi1/0/6 |

---

## Transit Network

| Network | Device A | IP | Device B | IP |
|---|---|---|---|---|
| 172.16.0.0/29 | FGT01 internal1 | 172.16.0.1 | MKT01 ether1 | 172.16.0.2 |

---

## VLAN Reference

| VLAN | Name | Subnet | MKT01 Gateway | Trust | Notes |
|---:|---|---|---|---|---|
| 10 | Management | 10.10.0.0/24 | 10.10.0.1 | Highest | Infrastructure administration — Pi-hole, PVE01, SW01, FGT01 mgmt |
| 20 | Servers | 10.20.0.0/24 | 10.20.0.1 | High | Windows Server AD (planned), TrueNAS, PBS — VM workloads via PVE01 |
| 30 | Web | 10.30.0.0/24 | 10.30.0.1 | Controlled | Web/application tier |
| 40 | Monitoring | 10.40.0.0/24 | 10.40.0.1 | High visibility | Wazuh (10.40.0.10 planned), LibreNMS (10.40.0.20), Grafana (10.40.0.30) |
| 50 | Client | 10.50.0.0/24 | 10.50.0.1 | Medium | Workstations — DHCP from Windows Server when deployed |
| 60 | Deployment | 10.60.0.0/24 | 10.60.0.1 | Controlled | WDS, PXE boot, OS deployment |
| 70 | Testing | 10.70.0.0/24 | 10.70.0.1 | Low | Internet-only isolation — excluded from MKT01 VLANs interface list |
| 80 | DMZ | 10.80.0.0/24 | 10.80.0.1 | Low | Future public-facing services |
| 999 | Unused | None | None | None | Native VLAN on trunks — no IP, no hosts, no routing |

---

## SW01 Port Assignments

| Port | Description | Mode | Native VLAN | Tagged VLANs | Security |
|---|---|---|---|---|---|
| Gi1/0/1 | Trunk-to-MKT01 | Trunk | 999 | 10,20,30,40,50,60,70,80,999 | Root Guard, DHCP Snooping Trust, ARP Inspection Trust |
| Gi1/0/2 | LabComputer | Access | 10 | — | PortFast, BPDU Guard, Port Security max 2 |
| Gi1/0/3 | Disabled - pending device assignment, see ADR-0002 | Access | 10 *(VLAN membership unchanged, port administratively down)* | — | Shutdown |
| Gi1/0/4 | PVE01 | Trunk | 10 | 10,20,30,40,50,60,70,80,999 | PortFast trunk, BPDU Guard, Port Security max 16 |
| Gi1/0/5 | SPAN-Monitor-Port | Monitor | — | — | SPAN **destination** present; 🔴 **source NOT configured on the live device** (2026-07-16) — mirrors nothing (`CM-0036`) |
| Gi1/0/6 | FortiGate-Management | Access | 10 | — | PortFast, BPDU Guard |
| Gi1/0/7 | Raspberry-Pi | Access | 10 | — | PortFast, BPDU Guard, Port Security max 2 |
| Gi1/0/8-48 | Unused | Access | 999 | — | Shutdown, BPDU Guard |
| Gi1/0/49-52 | Unused-SFP | — | — | — | Shutdown |

---

## SW01 STATIC-HOSTS ARP Access List

Required for all static-IP devices on VLAN 10. ARP inspection drops packets from devices without a DHCP snooping binding entry.

| IP | MAC (IOS format) | Device |
|---|---|---|
| **10.10.0.5** | **0000.5e00.5300** | 🔴 **Pi01 — was MISSING from this table until 2026-07-13. See below.** |
| 10.10.0.10 | 0000.5e00.5313 | PVE01 eno1 |
| 10.10.0.100 | 0000.5e00.5314 | iDRAC-PVE01 |
| 10.10.0.254 | 0000.5e00.5315 | FGT01 internal2 |
| 10.10.0.50 | 0000.5e00.5316 | Admin workstation |

🔴 **All five are required.** `DHCP Permits: 0` on SW01 — **there is no snooping fallback.** A host missing from this ACL is **dropped, full stop**, with no error and no warning. It simply appears broken.

> ### 🔴 This table was missing Pi01, and that is not a small thing
>
> **Until 2026-07-13 this table had four entries.** `048-Teardown-and-Rebuild-Runbook.md` states that **five are required**, and that the same omission in `023-SW01-Build-Record.md` **created a false "Pi01 should be unreachable" mystery that survived three handoffs.**
>
> `048` says: *"Build the ACL from this list, not from a stale record."* **This page was the stale record** — and it is the page that declares itself authoritative for exactly these values.
>
> **It even had Pi01's MAC.** `00:00:5e:00:53:05` appears in the *IP Address Assignments* table on this very page. It was simply never carried across into the ARP ACL.
>
> **A rebuild from the four-entry table produces a switch that silently drops Pi01** — the CA, the vault, DNS, and RADIUS — and the operator spends three sessions hunting a ghost.

Update this table and the switch when any static-IP device on VLAN 10 is added, replaced, or changes MAC address.

---

## Recovery / Transitional Network

| Network | Gateway | Interface | Purpose |
|---|---|---|---|
| 10.0.0.0/24 | 10.0.0.1 | MKT01 bridgeLocal (ether4-13) | Fallback management when VLAN routing is unavailable. Retained until formally retired through Change Management. |

---

## Known Deviations from Target Design

| Item | Target | Current Reality | Resolution |
|---|---|---|---|
| ~~MKT01 hostname~~ | MKT01 | ✅ **CLOSED 2026-07-13** — device confirms `MKT01` live (`[SethAdmin@MKT01]`). This deviation was stale. | — |
| ~~SW01 hostname~~ | SW01 | ✅ **CLOSED 2026-07-16** — device-verified `hostname SW01` (`show version`, `CM-0022`); the switch was renamed long ago, this deviation was stale | — |
| DNS | Windows Server AD DNS → Pi-hole → 1.1.1.1 | **Partially transitioned, 2026-07-13.** Admin workstation manually configured to use Pi-hole (`10.10.0.5`) as primary DNS, `1.1.1.1` as secondary fallback — confirmed working (`nslookup` shows `Server: pi.hole` actually answering). This is deliberately scoped to the one workstation, not a network-wide cutover — Pi01 had a hard-hang incident requiring a physical power cycle earlier the same session, making it a real, known single point of failure risk to depend on for the whole network's DNS before Windows Server AD DNS exists to share that load. Every other device on the network still resolves via `1.1.1.1`/`8.8.8.8` direct. | Deploy Windows Server AD; expand Pi-hole DNS to more devices only with the same fallback-scoped caution |
| DHCP | Windows Server | Not deployed | Deploy Windows Server AD |
| NTP | Windows Server AD NTP hierarchy (PDC emulator) | pool.ntp.org (interim) — 🔴 **SW01 excepted: points at Pi01 (a non-server), stratum 16, never synced** | Decision recorded **`ADR-0020`** (AD-anchored, external-pool bridge); SW01 fix `CM-0030` |
| 🔴 **iDRAC is not out-of-band** | Dedicated iDRAC port | **Shared LOM** — same NIC, cable and switch port as `eno1`. **Dies with SW01**, which is step one of any teardown. | `050` §1 — the R410 has an **unused dedicated iDRAC port**; move it during the same chassis visit |
| 🔴 iDRAC credentials | Hardened, vaulted, named | **Admin password changed at the console 2026-07-16** (no longer factory); not remote-verifiable (IPMI-over-LAN off). Store as `PVE01 - iDRAC - BMC Admin`. | Full onboarding (cert, path) **blocked on `CM-0012`** → `050`. `CM-0011` closed-as-false |
| 🔴 PVE01 CMOS / RTC | Holds config across power loss | **New CR2032 installed 2026-07-16 — durability re-test FAILED** (RTC resets `2026`→`2018` across a power cycle; battery-vs-board unresolved) | `CM-0012` (**Open**); keep on continuous power / UPS (`ADR-0017`) |
| PVE01 GUI shell | Functional | VNC connection refused (SSH works) | Under investigation |
| ~~PVE01 link speed~~ | 1 Gbps | ✅ **Re-confirmed 1 Gbps / full duplex 2026-07-16** (`ethtool eno1`) | Closed |
| Pi-hole role | DNS filtering forwarder (not authoritative) | Deployed and running at 10.10.0.5 | Remains until Windows AD DNS deployed |

## 🔴 MKT01 — Interface MAC Table (added 2026-07-14)

**This document declares itself authoritative for every MAC in the lab. Until 2026-07-14 it contained ZERO MAC addresses for MKT01 — the core router, which owns every VLAN gateway.**

**Read from the device, `/interface ethernet print`, 2026-07-14:**

| Interface | MAC | Switch chip | State | Use |
|---|---|---|---|---|
| `ether1` | `00:00:5e:00:53:06` | `switch1` | **R** (running) | Transit to FGT01 — `172.16.0.2/29` |
| `ether2` | `00:00:5e:00:53:07` | `switch1` | 🔴 **X** (disabled) | `CM-0015` — unused, disabled per `010` |
| `ether3` | `00:00:5e:00:53:08` | `switch1` | **RS** (running, slave) | **Trunk to SW01 `Gi1/0/1`** — `bridge-trunk`, `hw=no` |
| `ether4` | `00:00:5e:00:53:09` | `switch1` | **S** (slave) | 🟢 **`bridgeLocal` — THE recovery port. MAC-WinBox answers here** (`CM-0018`) |
| `ether5` | `00:00:5e:00:53:0a` | `switch1` | **S** | `bridgeLocal` |
| `ether6` | `00:00:5e:00:53:0b` | `switch2` | **S** | `bridgeLocal` |
| `ether7` | `00:00:5e:00:53:0c` | `switch2` | **S** | `bridgeLocal` |
| `ether8` | `00:00:5e:00:53:0d` | `switch2` | **S** | `bridgeLocal` |
| `ether9` | `00:00:5e:00:53:0e` | `switch2` | **S** | `bridgeLocal` |
| `ether10` | `00:00:5e:00:53:0f` | `switch2` | **S** | `bridgeLocal` |
| `ether11` | `00:00:5e:00:53:10` | `switch3` | **S** | `bridgeLocal` |
| `ether12` | `00:00:5e:00:53:11` | `switch3` | **S** | `bridgeLocal` |
| `ether13` | `00:00:5e:00:53:12` | `switch3` | **S** | `bridgeLocal` |

**The MACs are sequential** — `…:6F` through `…:7B`. **One NIC block.**

### 🔴 The switch-chip groupings were recorded NOWHERE before today

**`switch1` = `ether1`–`ether5`. `switch2` = `ether6`–`ether10`. `switch3` = `ether11`–`ether13`.**

**This matters.** `016` (MikroTik) records that **`hw=no` on `ether3` is a functional requirement, not a tuning choice** — the switch chip intercepts frames **in hardware**, before RouterOS's VLAN sub-interfaces ever see them. **The chip groupings are the map of which ports share that hardware path.** They belong in the source of truth, and they were not in any document in the repository.

### 🔴 The recovery path is `ether4` — and it is the ONLY one

**MAC-WinBox answers on the `RECOVERY` interface list (`bridgeLocal`) — `CM-0018`, `ADR-0014`, `ADR-0016`.** All ten `bridgeLocal` ports remain **enabled** (a deliberate, recorded decision — `ADR-0016`).

🔴 **KNOWN LIMIT: the MAC session connects, then DROPS after ~15 seconds.** It is a break-glass transport, not a management session. **Get in, set an IP, switch to a real session. MKT01 has no serial console.**

## Change Log — 2026-07-14

| Change | Source |
|---|---|
| **Added MKT01's complete interface MAC table (13 entries).** 🔴 **This document — the authoritative source for MACs — had NONE of them.** | `/interface ethernet print` |
| **Added the `switch1`/`switch2`/`switch3` hardware groupings.** Recorded in no document before today. | same |
| Recorded `ether4` as the sole MAC-WinBox recovery port | `CM-0018` |
| MKT01 platform recorded as `RB1100AHx4 Dude Edition` (device `board-name`) + 64 GB SATA SSD — device-confirmed 2026-07-15 | `/system resource` / `/disk print` |
| **2026-07-16 device reconcile (v2.3).** SW01 hostname deviation **CLOSED** (`SW01`, `CM-0022`); NTP decision recorded (**`ADR-0020`**, SW01 clock broken per `CM-0030`); iDRAC password changed at the console + onboarding blocked on `CM-0012`→`050`; **CMOS/RTC durability re-test FAILED** (`CM-0012`); PVE01 link re-confirmed 1 Gbps; SPAN source gap noted on `Gi1/0/5` (`CM-0036`). | This session's SW01 + PVE01 device recons |
