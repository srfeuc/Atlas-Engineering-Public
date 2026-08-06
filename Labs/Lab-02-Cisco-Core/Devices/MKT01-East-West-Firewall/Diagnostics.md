---
Title: MKT01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
Status: 🟡 Seeded (ADR-0032). MKT01 = east-west firewall + inter-VLAN gateway (RouterOS 7.23.1, RB1100AHx4). Pass-1 device-verified 07-22 → several ✅; the rest 🟡.
Version: 0.1
Date: 2026-07-28
---

# MKT01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **MKT01** — Role: East-West Firewall + inter-VLAN gateway (VLAN gateways `10.<vlan>.0.1`, loopback `10.255.0.2`, transit `10.255.255.6`).

> **What this is (`ADR-0032`):** quick "is MKT01 built/connected right?" checks. Break-fix → `Troubleshooting.md`; deep set → **Atlas Academy**. 🔴 **Read state back with `print detail`/`print stats`, never plain `print`** (`016` — a dynamic row was misread once). **Markers:** ✅ · 🟡 · ⏳ · 📋 (`POL-0001`).

## 1. Installation / role verification
| Check | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| RouterOS version | `/system resource print` | 7.23.1, RB1100AHx4 | ✅ (07-22) | — |
| Only ssh+winbox exposed | `/ip service print detail` | ssh,winbox enabled + scoped; telnet/ftp/www/www-ssl/api/api-ssl/reverse-proxy **disabled** | ✅ (07-22) | `CIS-Hardening-MKT01` §1 |
| Named admin, `admin` off | `/user print detail` | `mikrotikadmin` (full); `admin` disabled | ✅ (07-22) | CIS §1 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Addresses (gw per VLAN) | `/ip address print` | 9 VLAN gateways `10.<vlan>.0.1`, uplink `10.255.255.6`, loopback `10.255.0.2` | 🟡 | `IP-Addressing-Plan-VLSM` |
| VLAN sub-interfaces | `/interface vlan print` | 9 VLANs on `bridge-trunk`, `R` (running) | 🟡 | Build-Guide |
| Trunk offload OFF | `/interface bridge port print detail where interface=ether3` | `hw=no` (RTL8367 offload trap) | 🟡 | `Troubleshooting` |
| Time synced | `/system ntp client print` / `/system clock print` | `synchronized`, source DC01 `10.20.0.2`, correct date | ✅ (07-22) | `ADR-0020` |

## 3. Service-up checks
| Service | Command | Expected | Verified? |
|---|---|---|---|
| OSPF adjacency | `/routing ospf neighbor print` | 1941 = **Full** | ✅ (07-21) |
| Default route | `/ip route print` | default via `10.255.255.5` (1941) | ✅ |
| SNMP off (until MON01) | `/snmp print` | `enabled: no` | ✅ (07-22) |

## 4. Inter-device link checks (reciprocal)
| Link | From MKT01 | From the OTHER device | Expected | Verified? |
|---|---|---|---|---|
| ↔ 1941 (OSPF/transit) | `/routing ospf neighbor print` | `show ip ospf neighbor` on 1941 | Full both ways; MKT01 VLANs as `O E2` on 1941 | ✅ |
| ↔ DC01 (NTP/DNS) | `/ping 10.20.0.2 count=4` | ping MKT01 gw from DC01 | reachable both ways | 🟡 |
| → NPS01 RADIUS 1812/1813 | (after AAA) `/radius print` + test login | `show` NPS event on NPS01 | auth accepted (flow #14) | 📋 gated on NPS01 |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| Resolver reachable | `/ping 10.20.0.2 count=2` | replies | 🟡 |

## 6. IP / connectivity entry points
| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| L2/VLAN member set | `/interface bridge vlan print` (or `bridge vlan`) | eno-side VLAN membership | 🟡 |
| L3 route/gw | `/ip route print where dst-address=0.0.0.0/0` | default present via 1941 | ✅ |
| E-W policy hit | `/ip firewall filter print stats` | counters climb on the expected rule; deny logs (`EAST-WEST-DENIED`) | 🟡 |

## 7. Logging & event sources
| Source | How to view | Look for | Verified? |
|---|---|---|---|
| Local log | `/log print where topics~"firewall"` | `EAST-WEST-DENIED` / `INPUT-DENIED` entries, correct timestamp | 🟡 |
| Ships to MON01? | (Phase 6) | rsyslog to MON01 once built | 📋 |

## If you built or changed MKT01 solo (ADR-0032)
Paste `print detail`/`print stats` read-backs (services/addresses/OSPF/NTP) → flip 🟡→✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync.

## Related
- `Troubleshooting.md` (MKT01) · `Build-Guide.md` (v0.8) · `CIS-Hardening-MKT01.md` · **Atlas Academy** `Concepts/` (OSPF learn-vs-originate N1, RouterOS-v7 N3) · `Atlas-East-West-Allowed-Flows-Matrix.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Seeded (`ADR-0032`). ✅ marks the Pass-1 device-verified facts (07-22: services scoped, named admin, NTP; 07-21: OSPF Full/default route); addressing, VLAN/offload, E-W policy counters, and the NPS01 RADIUS flow (#14) left 🟡/📋. `print detail`-not-`print` rule flagged. |
