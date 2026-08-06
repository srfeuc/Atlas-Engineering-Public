---
Title: MKT01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
Status: 🟢 LIVING — the verified as-built state of the E-W firewall + inter-VLAN gateway. Pass-1 + gateway + OSPF device-verified (07-21/07-22); E-W policy still permissive. Records outrank guides (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# MKT01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The "what is actually true right now" snapshot for the E-W firewall / inter-VLAN gateway. It **outranks the Build-Guide** (guide = target; this = reality). Each row cites where the evidence lives (`POL-0008`). Markers: ✅ device-verified · 🟡 lab-unverified · ⬜ not built. 🔴 Read state back with `print detail`/`print stats`, never plain `print`.

## MKT01 — MikroTik RB1100AHx4 · RouterOS 7.23.1  (E-W firewall + inter-VLAN gateway, `ADR-0023`)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Platform / RouterOS | RB1100AHx4, RouterOS 7.23.1 | ✅ (07-22) | `Diagnostics.md` §1 |
| Mgmt services | only ssh + winbox exposed + scoped; telnet/ftp/www/api disabled | ✅ (07-22) | `Diagnostics.md` §1 · `CIS-Hardening-MKT01` |
| Named admin | `mikrotikadmin` (full); `admin` disabled | ✅ (07-22) | `Diagnostics.md` §1 |
| NTP | synchronized, source DC01 `10.20.0.2` | ✅ (07-22, `CM-0030`) | `Diagnostics.md` §2 |
| VLAN gateways / SVIs | 9 gateways `10.<vlan>.0.1` on `bridge-trunk`; transit `10.255.255.6`; loopback `10.255.0.2`; **offload off** | 🟡 read-back pending | `Diagnostics.md` §2/§6 |
| OSPF | area 0, **adjacency 1941 FULL**; VLANs advertised; default learned via `10.255.255.5` | ✅ (07-21) | `Diagnostics.md` §3/§4 |
| Default route | via 1941 `10.255.255.5` | ✅ | `Diagnostics.md` §3/§6 |
| SNMP | off (until MON01) | ✅ (07-22) | `Diagnostics.md` §3 |
| E-W policy | **permissive (temporary)** — default-deny is Phase 7, from evidence | 🟡 permissive | `Diagnostics.md` §6 · flows matrix |
| DHCP relay → DC01 | not built | 📋 | — (Phase 3h, `ADR-0030`) |
| Pass-2 RADIUS (NPS01) | not applied | ⬜ | — (gated, `ADR-0029`, flow #14) |
| rsyslog / NetFlow → MON01 | not built | 📋 | — (Phase 6; the Phase-7 evidence source) |

> 🔴 **Outstanding read-backs to flip 🟡→✅:** `/ip address print`, `/interface vlan print`, bridge-port `hw=no`, `/ip firewall filter print stats`. Paste into `Diagnostics.md` (`POL-0001`).

## Related
- `Diagnostics.md` (the verify commands + ✅ evidence) · `Build-Guide.md` (target) · `Build-Checklist.md` · `Roadmap.md` · `Considerations.md` · the two Phase-7 worksheets.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — consolidated MKT01's device-verified as-built state from the Build-Guide/Diagnostics (RouterOS 7.23.1, services scoped, named admin, NTP, **OSPF FULL with 1941**, default route, SNMP off — 07-21/07-22) into the single as-built snapshot; VLAN gateways/SVIs + offload + E-W policy counters 🟡 pending read-back; E-W policy **permissive** (default-deny is Phase 7); DHCP relay + RADIUS + MON01 telemetry 📋/⬜. Records outrank guides (`POL-0001`). |
