---
Title: Command Library — FortiOS (FGT01)
Path: Atlas-Academy/Command-Library
Status: 🟢 LIVING (ADR-0032). Verify commands for FGT01 (FortiGate-60E, FortiOS 7.4.5) — north-south perimeter firewall. Grouped by service; healthy-vs-broken.
Version: 1.0
Date: 2026-07-28
---

# Command Library — FortiOS (FGT01)

<!-- provenance -->
> **Atlas Academy — Command Library.** How to verify **FGT01** — the perimeter firewall (NAT, egress, inbound-deny; `wan1`→home router, `internal`→1941 transit `10.255.255.1/30`; break-glass `192.168.1.99`). Quick ref: `FGT01-Perimeter-Firewall/Diagnostics.md`; reading logs/flows: `.../Logging-and-Flow-Tracing-Field-Guide.md`.

> 🔴 **Read-back rule (`MC-0001`):** use **`get`, not `show`** — `show` prints intent (and omits defaults); `get` prints the effective running value. `set admin-server-cert` once ran clean and silently didn't take — caught only with `get`. Read the truth with `get` / `diagnose` / `execute`.

## §System — status / health
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Firmware / support | `get system status` | FortiOS 7.4.5; in support; correct hostname | EOS build; wrong version-gated feature assumed | Build-Checklist |
| Resource | `get system performance status` | CPU/mem/session count nominal | conserve mode, session exhaustion | — |
| Global hardening | `get system global \| grep -iE "strong-crypto\|cli-audit\|private-data"` | `strong-crypto enable`, `cli-audit-log enable` | disabled | Build-Checklist §4/§5 |

## §Admin — access + AD-LDAPS auth (`ADR-0028`)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Admin accounts + trusthost | `get system admin` | named admins; `trusthost` scoped; `fortigateadmin` local break-glass | open trusthost; only default `admin` | `ADR-0028` |
| No mgmt on WAN | `get system interface wan1` | `allowaccess: ping` only | https/ssh on WAN | CIS 1.3 |
| LDAPS server reachable | `diagnose test authserver ldap <srv> <user> <pw>` | authenticated; group returned | bind fail / cert-untrusted | Guide-2b (gated on DC cert) |
| LDAP config | `get user ldap` | least-priv `svc-fgt-ldap` bind, LDAPS 636 | Domain-Admin bind / 389 cleartext | `ADR-0028` |

> FGT01 uses **LDAPS**, not RADIUS/RADSEC (network-device RADIUS is on NPS01, `ADR-0029`).

## §Time — NTP (`ADR-0020`)
| Purpose | Command | Healthy | Broken looks like |
|---|---|---|---|
| NTP config/sync | `get system ntp` ; `diagnose sys ntp status` | synced to the `ADR-0020` source | unsynced (log timestamps useless) |

## §Interfaces / routing
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Interfaces + IP/link | `get system interface physical` | `internal 10.255.255.1/30` up; `wan1` DHCP up | link down; wrong IP | IP plan |
| Routing table | `get router info routing-table all` | default via wan1; interior `10.0.0.0/8` → 1941 `10.255.255.2` | no default / no interior return | `ADR-0023` |
| ARP | `get system arp` | 1941 transit peer present | missing next-hop | — |

## §Policy / NAT / sessions
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Firewall policy | `get firewall policy` | egress policy present, `nat enable`, `logtraffic all` | no NAT; logging off; interior default-allow | `ADR-0005` (egress broad, deferred) |
| Policy lookup | `diagnose firewall iprope lookup …` | the expected policy id matches a flow | matches a wrong/implicit rule | — |
| Live sessions | `diagnose sys session list` | a generated flow appears, ages out | flow absent (dropped upstream) | — |
| 🔬 Flow trace | `diagnose debug flow …` (see the Field Guide) | per-packet: policy id, action=accept, NAT | `action=deny`/no-match | Logging Field Guide |

## §Certificates (AD CS relying party)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| CA trust store | `get vpn certificate ca` | **Atlas Root CA** + ICA01 imported | absent (LDAPS/relying-cert fails) | `ADR-0031` Part 3B |
| Local/device certs | `get vpn certificate local` | ICA01-issued device cert bound | self-signed / OpenSSL leftover | `ADR-0031` |

## §Connectivity — L1→up
| Layer | Command | Tells you |
|---|---|---|
| L1 | `get system interface physical` | link/speed |
| L3 | `get router info routing-table all` ; `execute ping <gw>` | route + gateway |
| Path | `execute ping <dst>` ; `execute traceroute <dst>` ; `execute ping-options source <if>` | reach + source-scoped |
| Service open | `diagnose sys session list` after generating a flow | the TCP flow established (not just ICMP) |
| Break-glass | reach `192.168.1.99` / console | mgmt survives the local-in policy |

## §Logging
| Purpose | Command | Healthy | Broken looks like |
|---|---|---|---|
| Local logs | `execute log filter …` → `execute log display` | policy hits + **denies**, admin activity | logging off / denies not logged |
| Syslog to MON01 (Phase 6) | `get log syslogd setting` | server = MON01, synced clock | disabled (📋) |

## Related
- `FGT01-Perimeter-Firewall/Diagnostics.md` · `Logging-and-Flow-Tracing-Field-Guide.md` · `Build-Checklist.md` · `Build-Guide-2b-AD-LDAPS-Admin.md` (`ADR-0028`) · `CIS-Hardening-FGT01.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Created (`ADR-0032`). FortiOS verify commands by service — system/health, admin + AD-LDAPS auth (`ADR-0028`), NTP, interfaces/routing, policy/NAT/sessions + flow trace, AD CS relying certs (`ADR-0031`), connectivity, logging — with healthy-vs-broken and the `get`-not-`show` rule. |
