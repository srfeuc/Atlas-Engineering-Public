---
Title: Command Library — RouterOS (MKT01)
Path: Atlas-Academy/Command-Library
Status: 🟢 LIVING (ADR-0032). Verify commands for MKT01 (MikroTik RB1100AHx4, RouterOS 7.23.1) — east-west firewall + inter-VLAN gateway. Grouped by service; healthy-vs-broken.
Version: 1.0
Date: 2026-07-28
---

# Command Library — RouterOS (MKT01)

<!-- provenance -->
> **Atlas Academy — Command Library.** How to verify **MKT01** — the east-west segmentation firewall + inter-VLAN gateway (VLAN gateways `10.<vlan>.0.1`, loopback `10.255.0.2`, transit `10.255.255.6`). Quick ref: `MKT01-East-West-Firewall/Diagnostics.md`.

> 🔴 **Read-back rule (`016`):** use **`print detail`** / **`print stats`**, never plain `print` — plain `print` hid a dynamic WinBox service row that was misread as an open service. 🔴 **v7 ≠ v6:** OSPF and bridge syntax changed; MKT01 uses the **VLAN-sub-interface model on a plain `bridge-trunk` (`hw=no`)**, not a `vlan-filtering` bridge (Concept N3, RouterOS-v7). 🔴 **WinBox terminal** rejects `#` comments and `\` continuations — paste clean one-liners.

## §Mgmt — services / users
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Exposed services | `/ip service print detail` | only `ssh`,`winbox` enabled + `address=` scoped to mgmt | `telnet/ftp/www/www-ssl/api/api-ssl/reverse-proxy` up | `CIS-Hardening-MKT01` §1 |
| Named admin, `admin` off | `/user print detail` | `mikrotikadmin` (full); `admin` **disabled** | default `admin` active | `CIS` §1 |
| Live sessions | `/user active print` | expected admin from mgmt subnet | unknown source | — |
| L2 mgmt vectors off | `/tool mac-server print` ; `/ip neighbor discovery-settings print` | mac-server/mac-winbox = none; discovery = none | MAC-WinBox open (console is the break-glass) | `CIS` §1 |

## §Time — NTP (`ADR-0020`)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| NTP client | `/system ntp client print` | `status: synchronized`, server DC01 `10.20.0.2`, stratum 2 | `status: ...using...`/stuck | `ADR-0020` (`CM-0030`) |
| Clock | `/system clock print` | correct date, tz `America/Chicago` | `Jun/03`/wrong | `CM-0030` |

## §VLAN / L2 — bridge, trunk, VLANs
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| VLAN sub-interfaces | `/interface vlan print` | 9 VLANs on `bridge-trunk`, `R` (running) | missing/`X` | Build-Guide |
| 🔴 Trunk offload OFF | `/interface bridge port print detail where interface=ether3` | **`hw=no`** ingress-filtering=no | `hw=yes` → VLAN sub-ifaces show **0 RX** (RTL8367 trap) | `Troubleshooting` |
| Ports accounted for | `/interface print` | `ether1` uplink, `ether3` trunk, `ether2` mgmt-fallback; `ether4–13` disabled | stray enabled port | `CIS` §3 |
| Addresses / gateways | `/ip address print` | 9 VLAN gws `10.<vlan>.0.1`, uplink `.6`, loopback `10.255.0.2` | two IPs on one VLAN (ECMP flaps) | IP plan |

## §Routing — OSPF (`ADR-0023`)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| OSPF neighbor | `/routing ospf neighbor print` | 1941 = **Full** | `2-Way`/absent | — |
| Default route | `/ip route print where dst-address=0.0.0.0/0` | default via `10.255.255.5` (1941) | absent | — |
| VLANs advertised | (on 1941) `show ip route ospf` | MKT01 VLANs as `O E2` | none → `redistribute=connected` missing | Concept N1 |

## §Firewall — east-west policy (Phase 7)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Rule counters | `/ip firewall filter print stats` | expected permit counters climb; the two catch-all drops last | zero-counter permit (dead rule); permit above a drop (shadow) | `Firewall-Rebuild-…-Plan` |
| Live connections | `/ip firewall connection print where dst-address~"<dst>"` | the tracked flow present | none (never matched) | — |
| No east-west NAT | `/ip firewall nat print` | empty for inter-VLAN | masquerade between VLANs (kills source identity) | E-W matrix |
| Deny logging | `/log print where topics~"firewall"` | `EAST-WEST-DENIED`/`INPUT-DENIED` with correct timestamp | denies silent / bad timestamp | Gate #2 (clocks) |

## §Admin-auth — RADIUS client (`ADR-0029`, forthcoming)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| RADIUS client → NPS01 | `/radius print` ; `/radius monitor 0` | points at NPS01 `10.20.0.12`, 1812/1813; a test login accepted | timeouts / reject | flow #14, `ADR-0029` |

> MKT01 is a RADIUS **client** of NPS01 — it does **not** run RADIUS and does **not** do LDAPS (that's FGT01, `ADR-0028`). Keep the local break-glass admin.

## §Connectivity — L1→up
| Layer | Command | Tells you |
|---|---|---|
| L1/L2 | `/interface print stats` ; `/interface monitor-traffic <if>` | link, RX/TX, errors |
| VLAN member set | `/interface bridge vlan print` | which VLANs egress the uplink tagged |
| L3 | `/ip route print` ; `/ping <gw>` | route + gateway reply |
| Path | `/ping <dst>` ; `/tool traceroute <dst>` | reach + where it stops |

## §Logging / backup
| Purpose | Command | Healthy | Broken looks like |
|---|---|---|---|
| Log | `/log print where topics~"..."` | expected events, correct time | drops missing / bad time |
| Backup | `/export file=...` ; `/system backup save name=...` | binary + readable export saved | none (→ Oxidized once SRV01 up) |

## Related
- `MKT01-East-West-Firewall/Diagnostics.md` · `.../Build-Guide.md` · `CIS-Hardening-MKT01.md` · `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` · `../Concepts/README.md` (N1 OSPF, N3 RouterOS-v7).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Created (`ADR-0032`). RouterOS verify commands by service — mgmt/services, NTP, VLAN/L2 (incl. the `hw=no` offload trap), OSPF, east-west firewall (counters/connections/NAT/deny-logs), RADIUS-client (`ADR-0029`), connectivity, logging/backup — with healthy-vs-broken and the `print detail`-not-`print` rule. |
