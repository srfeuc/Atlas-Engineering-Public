---
Title: Command Library — Syslog & SNMP (the observability tools: rsyslog · LibreNMS · snmp)
Path: Atlas-Academy/Command-Library
Status: 📋 SEEDED — EXPANDING (`ADR-0032`; Backlog **#34**). The verification set for the estate's **syslog + SNMP** telemetry, grounded in **MON01** (the syslog/SNMP/NetFlow/Suricata sink, **Phase 6 — 📋 not built**). The **method** below is authored now (tool-knowledge, hand-off-ready); the **read-backs land 🟡→✅ when MON01 + the senders are stood up** (`POL-0001`). A deliberate **tool-domain** page (not platform-first) because observability spans every device (sender) into one collector (MON01).
Version: 0.1
Date: 2026-08-01
---

# Command Library — Syslog & SNMP (observability)

<!-- provenance -->
> **Book 9 — Atlas Academy — Command Library (`ADR-0032`).** How to verify the estate's **detect layer**: is every device **shipping** logs/metrics, and is **MON01** collecting them? Two halves — the **collector** (MON01: `rsyslog` for logs, **LibreNMS** for SNMPv3 metrics + the auto-drawn LLDP map) and the **senders** (SW01 · FGT01 · MKT01 · the hosts). The Playbooks that *use* this link down here: `../Playbooks/Trace-It-in-the-Logs.md` · `../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md`.

> 🔴 **Clocks-first (`ADR-0020`, `CM-0030`).** Logs and metrics on a wrong clock are **worthless for correlation** — verify NTP sync on the sender *and* MON01 before trusting a timeline. 🔴 **One-directional (`ADR-0036`/matrix flow #2):** MON01 **polls out**; nothing sessions back in. 🔴 **Not built yet** — every read-back below is 📋 until MON01 Phase 6.

> **MON01 quick facts (grounding):** Debian · VLAN 40 (gw `10.40.0.1`) · **LibreNMS `10.40.0.20`** · Grafana `10.40.0.30` · **syslog `udp/514`** · **SNMPv3 `udp/161`** · NetFlow `2055`. Split placement (`ADR-0036` v1.2): light probe on PVE02/EQR6, heavy stack on PVE01/R410. Owner: `Devices/MON01-Monitoring/`.

## §Syslog — collector (MON01 · rsyslog) 📋
| Purpose | Command (on MON01) | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| rsyslog running + listening | `systemctl is-active rsyslog` ; `ss -ulnp \| grep :514` | `active`; bound `udp/514` (and `tcp/514` if used) | inactive; nothing on 514 → no device can ship | MON01 `Roles/rsyslog` |
| Logs actually arriving, per host | `ls -la /var/log/remote/` ; `tail -f /var/log/remote/<host>/syslog` | a directory **per sending device**, growing | host missing = that device isn't shipping (fix at the sender) | `#34` |
| The clock the logs are stamped with | `timedatectl` (on MON01 **and** the sender) | both `System clock synchronized: yes`, same source (DC01 `10.20.0.2`) | skew → timelines don't line up (`CM-0030`) | `ADR-0020` |

## §Syslog — senders (turn it on + confirm it's leaving the device) 📋
| Platform | Configure / confirm it's sending | Grounds |
|---|---|---|
| **Cisco IOS** (SW01/1941) | `show logging` (host = MON01, level); `logging host 10.40.0.20` + `logging trap informational` | IOS §Logging · CIS |
| **RouterOS** (MKT01) | `/system logging action print` (a `remote` action → MON01); `/log print` | RouterOS §Logging |
| **FortiOS** (FGT01) | `get log syslogd setting` (status enable, server `10.40.0.20`) | FortiOS §Logging |
| **Linux** (hosts) | `journalctl -u rsyslog`; the `*.* @10.40.0.20:514` forward rule in `/etc/rsyslog.d/` | Linux §Logging |

## §SNMP — poller (MON01 · LibreNMS) 📋
| Purpose | Command (on MON01/LibreNMS) | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| LibreNMS self-check | `cd /opt/librenms && ./validate.php` | all green | failed checks (poller not running, DB, perms) | MON01 `Roles/LibreNMS` |
| The poller is running + on time | `systemctl status librenms-scheduler` (or the cron); the device's **"last polled"** in the UI | polled within the interval (default 5 min) | "last polled" stale/red → poller stalled or device unreachable | `#34` |
| Debug-poll one device | `./poller.php -h <device> -d` | walks the OIDs, updates RRD, no timeouts | `Timeout`/`No response` (SNMP path), or auth error (v3 creds) | — |
| Is SNMP answering at all? | `snmpwalk -v3 -l authPriv -u <user> -a SHA -A '<auth>' -x AES -X '<priv>' <device> sysDescr.0` | the device's `sysDescr` string | timeout (161 blocked / agent off); `authorizationError` (v3 creds/context) | — |

## §SNMP — agents (turn it on + confirm the device answers) 📋
| Platform | Configure / confirm the agent | Grounds |
|---|---|---|
| **Cisco IOS** (SW01/1941) | `show snmp` ; `show snmp user` (v3); ACL permits MON01 `10.40.0.20` on `udp/161` | IOS §SNMP · CIS · 🔴 the **SW01 SNMP-mistarget** bug (re-point off `.52`) |
| **RouterOS** (MKT01) | `/snmp print` (enabled=yes); `/snmp community print` (v3 user, scoped to MON01) | RouterOS §SNMP |
| **FortiOS** (FGT01) | `get system snmp sysinfo` (status enable); `show system snmp user` (v3) | FortiOS §SNMP |
| **Linux** (hosts) | `systemctl is-active snmpd` ; `snmpwalk -v3 … localhost sysUpTime` from the host itself | Linux §SNMP |

## §Read-it — what LibreNMS/logs are telling you 📋
| Question | Where to look | Reads as |
|---|---|---|
| Is a device **up** vs **SNMP-down**? | LibreNMS device status + `ping` + `snmpwalk sysUpTime` | up+polled (green) · up-but-SNMP-down (device pings, snmp times out) · down (no ping) |
| A **link/port** event | LibreNMS port view + the syslog `%LINK-3-UPDOWN`/`%LINEPROTO` messages | flaps show as port state changes + repeated syslog lines at a timestamp |
| The **LLDP topology** | LibreNMS auto-map | a missing neighbour = SNMP/LLDP not enabled on one side |

## Related
- **Playbooks (the "how do I use this"):** `../Playbooks/Trace-It-in-the-Logs.md` · `../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md`.
- **Sender detail (per platform):** `Cisco-IOS.md` (§Logging/§SNMP) · `RouterOS.md` (§Logging) · `FortiOS.md` · `Linux.md` (rsyslog/snmpd — MON01 is Debian, so its host-level checks live there too).
- **Owner:** `Devices/MON01-Monitoring/` (`Roles/rsyslog` · `Roles/LibreNMS` · `Diagnostics.md`) · ties to **#27** (Services map — the "Consumed by · port" column names these flows) + **#34** (this observability slice).
- **Concept (why correlation needs synced clocks):** `../Concepts/A-Completed-Command-Is-Not-Evidence.md` (read the *arriving* data, not the assumption it's arriving) · `ADR-0020` (time).
- Cert-aligned: **CCNA 4.0** (syslog/SNMP) · **CySA+** (log analysis / centralized logging).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-08-01. **Seeded (Backlog #34)** — the syslog + SNMP observability command set, grounded in MON01 (Phase 6, 📋 not built). Collector (rsyslog + LibreNMS) + sender/agent (IOS/RouterOS/FortiOS/Linux) + a read-it section, with the clocks-first + one-directional rules. **Method authored (tool-knowledge); read-backs 🟡→✅ when MON01 + the senders are stood up.** Deliberately a tool-domain page (observability spans platforms). |
