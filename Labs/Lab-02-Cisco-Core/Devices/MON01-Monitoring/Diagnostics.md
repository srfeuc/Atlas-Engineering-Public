---
Title: MON01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring
Status: 📋 Seeded (`ADR-0032`). MON01 = the visibility/detection stack, VLAN 40 (LibreNMS `10.40.0.20`, Grafana `10.40.0.30`). Commands authored from docs; **📋 not built** — every row is 🟡 lab-unverified until a read-back is pasted. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-29
---

# MON01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **MON01** (Debian) — Role: rsyslog · SNMPv3/LibreNMS · NetFlow · Suricata IDS (SPAN) · Grafana · Uptime-Kuma. VLAN 40.

> **What this is (`ADR-0032`):** the quick "is MON01 built + is data actually arriving?" checks — the distinctive MON01 discipline is that *service-up is not enough; the data has to land*. Break-fix → `Troubleshooting.md`; the deep set → **Atlas Academy `Command-Library/Linux.md`**. Markers: ✅ device-verified · 🟡 lab-unverified · 📋 planned.

## 1. Host / role verification
| Check | When | Command | Expected (healthy) | Verified? |
|---|---|---|---|---|
| OS / version | after build | `cat /etc/os-release` | Debian (stable) | 📋 |
| Services up | anytime | `systemctl is-active rsyslog snmpd suricata grafana-server` | all `active` (per host in the split) | 📋 |
| NetFlow collector up | anytime | `systemctl is-active nfdump` (or `ntopng`) | `active` | 📋 |
| Uptime-Kuma (probe) | anytime | `systemctl is-active uptime-kuma` (EQR6 probe) | `active` | 📋 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Hostname | `hostnamectl` | MON01 (or MON01-probe on the EQR6) | 📋 |
| IP / VLAN 40 | `ip -br a` | `10.40.0.x/24` on VLAN 40 | 📋 |
| Gateway reachable | `ping -c2 10.40.0.1` | replies | 📋 |
| Clock synced (gate) | `chronyc tracking` (or `timedatectl`) | synced, low offset (`ADR-0020`) | 📋 |

## 3. Data-is-arriving checks (the point of MON01)
| Check | When | Command / where | Expected (healthy) | Verified? |
|---|---|---|---|---|
| Logs arriving | after Phase 2 | `tail -f /var/log/remote/<device>.log` (or the rsyslog target) | fresh lines from **every** device, **correct timestamps** | 📋 |
| SNMP poll works | per device | `snmpwalk -v3 -l authPriv -u <user> ... <device> sysDescr` | device responds; appears in LibreNMS | 📋 |
| LLDP topology | after LibreNMS | LibreNMS → Devices → Map | the map renders + matches the docs | 📋 |
| NetFlow flows | after Phase 2 | `nfdump -R /var/cache/nfdump -c 20` (or ntopng UI) | real src/dst/port flows | 📋 |
| Suricata fires | on a test | `tail -f /var/log/suricata/fast.log` while triggering EICAR/known-bad | an **alert** appears (🔴 unproven until it does) | 📋 |
| Grafana live | after Phase 4 | browse `https://10.40.0.30:3000` | dashboards render from live data | 📋 |

## 4. The one-directional rule (the security proof)
| Test | From | Command | Expected | Verified? |
|---|---|---|---|---|
| Poll-out allowed | MON01 | `snmpwalk ... <device>` · `ping <device>` | works (MON01 initiates) | 📋 |
| Ingest allowed | a device | send syslog/NetFlow to MON01 | arrives (inbound to MON01 only) | 📋 |
| 🔴 Session-back **refused** | a monitored host | `ssh mon01` / `curl http://10.40.0.x` | **refused/timeout** (matrix flow #2) | 📋 |

## 5. Inter-device link checks
| Link | From MON01 | Expected | Verified? |
|---|---|---|---|
| SPAN feed live | `tcpdump -i <span-if> -c 5` | sees mirrored MKT01-trunk frames | 📋 |
| SW01 SNMP re-pointed | LibreNMS shows SW01 polling | SW01 → MON01 (not the ghost `10.40.0.52`, `CM-0023`) | 📋 |
| → SIEM01 feed (later) | Suricata/syslog forwarded | Wazuh ingests (`ADR-0032`) | 📋 |

## If you built or changed MON01 solo (`ADR-0032`)
Paste the read-backs (services active, a log line with a correct timestamp, an SNMP walk, a NetFlow sample, the Suricata test alert, the refused session-back) so the next session flips 📋/🟡 → ✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync + `Operations/Device-Confirmation-Commands.md`.

## Related
- `Troubleshooting.md` (MON01) · **Atlas Academy** `Command-Library/Linux.md` · `Roadmap.md` (build path) · `../../Operations/Validation-and-Adversarial-Testing.md` (the one-way-rule + IDS-fires proofs).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded from the `Diagnostics-Show-Commands-Template` (`ADR-0032`) for the MON01 replication: host/service-up, addressing + clock gate, the distinctive **data-is-arriving** battery, the **one-directional-rule** security proof, and the SPAN/SW01-SNMP/SIEM links. All 📋 (not built); flips to ✅ on read-back (`POL-0001`). |
