---
Title: FGT01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟡 Seeded (ADR-0032). FGT01 = perimeter firewall (FortiGate-60E, FortiOS 7.4.5). Pass-1 core done 07-21. Read back with `get`, not `show` (MC-0001).
Version: 0.1
Date: 2026-07-28
---

# FGT01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **FGT01** — Role: north-south perimeter firewall (NAT, egress, inbound-deny). `wan1` → home router; `internal` → 1941 transit `10.255.255.0/30` (FGT01 `.1`). Break-glass mgmt `192.168.1.99`.

> **What this is (`ADR-0032`):** quick "is FGT01 built/connected right?" checks. Break-fix → `Troubleshooting.md`; how to *read* the logs/flows → `Logging-and-Flow-Tracing-Field-Guide.md`; deep set → **Atlas Academy**. 🔴 **Read state back with `get`, not `show`** — `set admin-server-cert` once silently didn't take (`MC-0001`). **Markers:** ✅ · 🟡 · ⏳ · 📋.

## 1. Installation / role verification
| Check | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| Firmware / in-support | `get system status` | FortiOS 7.4.5; in support | 🟡 | Build-Checklist |
| Named admin + trusthost | `get system admin` | named admin, `trusthost` scoped; default `admin`→`fortigateadmin` break-glass | ✅ core (07-21) | `ADR-0028` |
| No mgmt on WAN | `get system interface wan1` | `allowaccess ping` only (no https/ssh) | ✅ (CIS 1.3) | CIS |
| Strong crypto | `get system global \| grep strong-crypto` | `strong-crypto enable` | 🟡 | Build-Checklist §4 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Interfaces / IPs | `get system interface physical` | `internal` = `10.255.255.1/30`; `wan1` DHCP | 🟡 | `IP-Addressing-Plan-VLSM` |
| Time synced | `get system ntp` / `diagnose sys ntp status` | synced to `ADR-0020` source | 🟡 | `ADR-0020` |

## 3. Service-up checks
| Service | Command | Expected | Verified? |
|---|---|---|---|
| Egress policy + NAT | `get firewall policy` | egress policy present, `nat enable` | ✅ (07-21) |
| Traffic logging on | `get log setting` | `logtraffic all` | ✅ (07-21) |
| Private-data encryption | `get system global \| grep private-data` | enabled (32-hex key recorded offline) | 🟡 |

## 4. Inter-device link checks (reciprocal)
| Link | From FGT01 | From the OTHER device | Expected | Verified? |
|---|---|---|---|---|
| ↔ 1941 transit /30 | `execute ping 10.255.255.2` | `ping 10.255.255.1` on 1941 | reachable both ways | ✅ (07-21) |
| → internet (egress) | `execute ping 1.1.1.1` | — | replies (NAT works) | ✅ (07-21) |
| → DC LDAPS (admin auth) | `diagnose test authserver ldap <srv> <user> <pw>` | (DC) LDAPS bind | auth succeeds (Guide-2b) | 📋 gated on DC cert |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| DNS resolves | `execute ping fortiguard.com` (or `diagnose test application dnsproxy 6`) | resolves | 🟡 |

## 6. IP / connectivity entry points
| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| Interface/link | `get system interface physical` | link up, speed | 🟡 |
| Routing table | `get router info routing-table all` | default via wan1; interior `10.0.0.0/8` → 1941 | 🟡 |
| Live sessions | `diagnose sys session list` | a generated flow appears, ages out | 🟡 |
| Break-glass reachable | reach `192.168.1.99` / console | mgmt survives after local-in policy | 🟡 |

## 7. Logging & event sources
| Source | How to view | Look for | Verified? |
|---|---|---|---|
| Local logs | GUI Log&Report / `execute log filter` | policy hits, denies, admin activity | ✅ used (07-21) |
| Flow trace | `diagnose debug flow` (see the **Logging & Flow-Tracing Field Guide**) | per-packet policy decision | 🟡 |
| Ships to MON01? | `get log syslogd setting` | syslog to MON01 (Phase 6) | 📋 |

## If you built or changed FGT01 solo (ADR-0032)
Paste `get`-based read-backs (status/admin/policy/routing) → flip 🟡→✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync.

## Related
- `Troubleshooting.md` · `Logging-and-Flow-Tracing-Field-Guide.md` · `Build-Checklist.md` · `Build-Guide-Index.md` · `CIS-Hardening-FGT01.md` · `Build-Guide-2b-AD-LDAPS-Admin.md` (`ADR-0028`) · **Atlas Academy**.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Seeded (`ADR-0032`). ✅ marks the Pass-1 core facts (07-21: egress+NAT, traffic logging, 1941 transit ping, internet egress; named admin/trusthost, no-WAN-mgmt). LDAPS admin-auth link marked 📋 (gated on the DC cert, `ADR-0028`/Guide-2b). `get`-not-`show` rule + the Logging field-guide cross-link included. |
