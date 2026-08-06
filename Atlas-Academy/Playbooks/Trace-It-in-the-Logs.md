---
Title: Playbook — Trace It in the Logs (find & identify an event in centralized syslog)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, device-unverified — **📋 the read-backs land when MON01 is built (Phase 6)**. Grounded in **MON01** (the estate rsyslog sink) + the device senders (SW01/FGT01/MKT01/hosts). Command-first, searchable/ticket-ready per Backlog **#32**; the observability slice of Backlog **#34** (`ADR-0053` §5).
Version: 0.1
Date: 2026-08-01
---

# Playbook — Trace It in the Logs

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: log analysis / observability — an **action-layer** page. **Something happened — a drop, a reboot, a link flap, an auth failure, a config change — now find and identify it in the logs.** This is the *how do I find it, and how do I know I'm looking at the right event* procedure, across the estate's **centralized syslog on MON01** (and the device's own local log). *(The reflex that a log only counts if its clock is right is the [`../Concepts/A-Completed-Command-Is-Not-Evidence.md`](../Concepts/A-Completed-Command-Is-Not-Evidence.md) discipline applied to time.)*

**The one-line problem.** You know *what* happened and roughly *when* — you need the **log line that proves it**, on the **right device**, at the **right timestamp**, told apart from the surrounding noise.

> 📋 **Seeded (Backlog #34) — MON01 is not built yet (Phase 6).** The *method* below is complete and usable on any device's local log today; the **centralized** read-backs (per-host files on MON01, LibreNMS eventlog) land 🟡→✅ once the rsyslog collector + the senders are stood up (`POL-0001`).

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **the why → clocks-first**.
3. **① Pin it down** — what/where/when, and is the clock trustworthy.
4. **How to find & identify it — the method** (the core):
   - 4.1 Pick the right **source** (central MON01 vs the device's local log).
   - 4.2 **Narrow** by host → time window → severity/facility → search string.
   - 4.3 **Identify** the event — read severity, facility, the message pattern; separate signal from noise.
   - 4.4 **Correlate** across devices by timestamp (why clocks-first matters).
5. **Where each platform keeps its logs** (the sender side) · **If you can't find it**.
6. **Gap / what this closes** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type** (one per line)

- "*where do I see the logs for all the devices in one place?*" — the centralized-syslog question (step 4.1).
- "*I know it happened around 14:30 but I can't find the log line*" — the narrow-by-time step (step 4.2).
- 📋 (real read-back — pending MON01): `%LINK-3-UPDOWN: Interface GigabitEthernet1/0/4, changed state to down` (IOS link flap).
- 📋 `%SEC-6-IPACCESSLOGP` / a firewall deny line at the timestamp of the outage.
- "*the timestamps between two devices don't match*" — the clock-skew trap (step 4.4).

**Plain-language symptom phrases**

- "trace it in the logs" · "find the log for this event" · "which device logged this and when."
- "is there a log of that reboot / drop / login / change?"
- "how do I search all the syslog at once?"
- "the log is there but I can't tell if it's the right event."

**Aliases / also-known-as**

- centralized logging · log aggregation · rsyslog · syslog server · log correlation · severity/facility · `journalctl` · `show logging` · LibreNMS eventlog · grep the logs · SIEM pre-cursor.

**Keywords line**

`MON01` · rsyslog · `/var/log/remote/<host>` · `syslog/514` · `journalctl -u --since --until -p` · `show logging` · `/log print where` · `get log …` · severity 0–7 · facility · clocks-first `ADR-0020` · `#34`.

## Cert anchor

- **CCNA 4.0** (syslog — severities, `logging host`, timestamps) — primary.
- **CySA+** (centralized log analysis, correlation), **Linux+** (`journalctl`/rsyslog). *(Grounding index: `../Atlas-Certification-Lab-Map.md`.)*

## ① Pin it down (capture these first — they're the ticket)

- a. **What** happened (a drop / reboot / auth fail / link flap / config change) and its **expected log shape** (a link event? a `%SEC` deny? a `4625` logon?).
- b. **Where** — which device(s) would have logged it (the one that acted, and the collector MON01).
- c. **When** — the tightest time window you can (± a few minutes) — this is your strongest filter.
- d. 🔴 **Is the clock trustworthy?** — `timedatectl` / `show ntp status` on the source **and** MON01; a skewed clock means the event is filed under the *wrong* time (`ADR-0020`, `CM-0030`).
- e. **Is the source even shipping?** — if the device's per-host dir is absent on MON01, fix the sender first (§ senders / `../Command-Library/Syslog-and-SNMP.md`).

## How to find & identify it — the method

> The core of this page. Commands link down to `../Command-Library/Syslog-and-SNMP.md` (`POL-0008`).

**4.1 Pick the right source — central first, then the device.**

- a. **Centralized (MON01, once built):** every device ships to rsyslog; look under the per-host tree:
  - `ls /var/log/remote/` → the sending hosts · `less /var/log/remote/<host>/syslog`
  - or the **LibreNMS eventlog / syslog** UI (searchable by device + time).
  - Healthy: the host has a directory and recent lines. 📋 Broken: no dir → that device isn't shipping (sender fix).
- b. **The device's own local log (works today):** the source of truth if central is down or the device isn't shipping yet — see §5 per platform.

**4.2 Narrow — host → time window → severity/facility → string.** Filter, don't scroll.

- a. **Time window is your best filter** (Linux collector example):
  - `journalctl --since "14:25" --until "14:35"` (add `-u <unit>` for a service, `-p warning` for severity).
  - rsyslog files: `awk '$0 ~ "14:2[5-9]|14:3[0-5]"' /var/log/remote/<host>/syslog` — or `grep` the timestamp prefix.
- b. **Severity** (syslog 0–7: emerg…debug) — drop the noise: `-p err` (≤3) surfaces the real faults; `%…-3-…`/`%…-5-…` in IOS is the severity digit.
- c. **String** — the interface, IP, hostname, or error token: `grep -iE 'GigabitEthernet1/0/4|10\.10\.0\.5|DENY'`.

**4.3 Identify the event — is this the right line?**

- a. **Read the fields:** `<timestamp> <host> <facility>.<severity> <tag>: <message>`. Confirm the **host** is the one that acted and the **timestamp** is inside your window.
- b. **Recognize the pattern:** a link flap = a `%LINK-3-UPDOWN` **pair** (down then up); a deny = a firewall/`%SEC` line naming src/dst/port; a reboot = the boot banner + a gap in the stream; an auth fail = the platform's reject line.
- c. **Signal vs noise:** repeated identical lines = a flapping condition, not many events; a single line at the exact timestamp of the symptom is your candidate. Don't stop at the first match — check nothing *earlier* is the real cause.

**4.4 Correlate across devices — line the timelines up.**

- a. Pull the same window from each device involved (the client, the switch, the firewall) and order by timestamp — the **first** deviating line points at the origin.
- b. 🔴 This only works if the clocks agree — re-confirm Pin-it (d). Skew is the classic "the firewall logged the deny 3 minutes before the client even tried" false trail (`ADR-0020`).

## Where each platform keeps its logs (the sender side)

- **Cisco IOS** (SW01/1941): `show logging` (buffer + where it ships); severities are the digit in `%FAC-<sev>-MNEMONIC`.
- **RouterOS** (MKT01): `/log print where topics~"firewall"` (and `…~"system"`); actions in `/system logging`.
- **FortiOS** (FGT01): `execute log filter` + `execute log display`; `get log syslogd setting` for the ship-to.
- **Linux** (hosts/MON01): `journalctl` (see `Read-the-Logs-with-journalctl.md`); forwarded via `/etc/rsyslog.d/*.conf`.
- Turn-on + confirm-shipping detail: `../Command-Library/Syslog-and-SNMP.md` §Syslog-senders.

## If you can't find it

- Nothing on MON01 for that host → the device isn't shipping (sender off / ACL blocks `udp/514`) → fix at the sender, read the **local** log meanwhile.
- The line exists but the time is wrong → clock skew — the event is under a different minute; widen the window and check NTP (`Fix-the-SW01-Clock.md`).
- Right device, right time, no line → the event's severity is below the device's logging level (raise `logging trap`), or it logs to a facility you didn't search.
- Found many identical lines → a flap/loop, not N discrete events — treat the *first* and the *rate*, not the count.

## Gap / what this closes (`#34` · `#37`)

- **The gap:** until MON01 is built (Phase 6), there is **no central place to trace an event** — you must know which device to log into and read its local buffer, and cross-device correlation is manual and clock-fragile. MON01's rsyslog + LibreNMS eventlog closes it; **📋 designed-only until Phase 6** (`POL-0001`). Clocks-first (`ADR-0020`) is the hard prerequisite — this Playbook is unusable for correlation until NTP is trustworthy estate-wide. Track in `Devices/MON01-Monitoring/Roadmap.md` + the reconciliation map.

## Related

- **Command-Library (link down):** `../Command-Library/Syslog-and-SNMP.md` (collector + sender commands) · per-platform §Logging in `Cisco-IOS.md` / `RouterOS.md` / `FortiOS.md` / `Linux.md`.
- **Sibling playbooks:** `Read-the-Logs-with-journalctl.md` (the Linux-local companion) · `Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md` (the metrics twin) · `Trace-a-Blocked-Flow.md` (the deny you're often hunting) · `Fix-the-SW01-Clock.md` (make the timestamps trustworthy first).
- **Owner:** `Devices/MON01-Monitoring/` (`Roles/rsyslog`) · Backlog **#34** (observability) + **#27** (Services map — the syslog/514 flow) · `ADR-0032` (diagnostics architecture) · `ADR-0020` (clocks-first).
- Cert-aligned: **CCNA 4.0** (syslog) · **CySA+** (log analysis).

## Worked log

| Date | Who | Time | Event traced | Source (central/local) | Found it? | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-01 | **Seeded (Backlog #34 — syslog as a first-class troubleshooting tool).** The find-&-identify-an-event-in-the-logs method, command-first: pick the source (central MON01 vs local), narrow by host→time→severity→string, identify by reading the fields + recognizing the pattern, correlate across devices (clocks-first). Grounded in MON01 (rsyslog sink) + the per-platform senders. **Method authored now; centralized read-backs 📋 until MON01 Phase 6** (`POL-0001`). Command-first mold (`ADR-0053` §5); links down to the new `Command-Library/Syslog-and-SNMP.md`. Cert: CCNA 4.0 · CySA+. |
