---
Title: CCNA Ch13 — Device Management Protocols (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the device-management-protocols chapter (NTP 4.2 · syslog 4.5 · CDP/LLDP 2.3). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch13 (Vol 2) — Device Management Protocols

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **4.2** (NTP) + **4.5** (syslog) + **2.3** (CDP/LLDP). Reverse-indexes into [`Cisco-IOS §4.2`](../../../Command-Library/Cisco-IOS.md#42--configure-and-verify-ntp-client-and-server) / [`§4.5`](../../../Command-Library/Cisco-IOS.md#45--syslog-features-facilities-and-severity-levels) / [`§2.3`](../../../Command-Library/Cisco-IOS.md#23--configure-and-verify-cdp-and-lldp).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [NTP](#1--ntp)
2. [Syslog](#2--syslog)
3. [CDP & LLDP](#3--cdp--lldp)
4. [Gaps this page surfaces](#4--gaps-this-page-surfaces)

---

## 1 — NTP

Where Atlas runs it: source = **DC01 `10.20.0.2`** (`ADR-0020`). SW01's never-synced clock (`CM-0030`) is a real troubleshooting lab with its own ⭐ Playbook.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **NTP client/server** (`ntp server 10.20.0.2`) | [Cisco-IOS §4.2](../../../Command-Library/Cisco-IOS.md#42--configure-and-verify-ntp-client-and-server) | [1941 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) §2 | 📋 | ⭐ [Fix-the-SW01-Clock](../../../Playbooks/Fix-the-SW01-Clock.md) | ✅ |
| 1.2 | **Verify — `show ntp status` (not `show run`)** | [Cisco-IOS §4.2](../../../Command-Library/Cisco-IOS.md#42--configure-and-verify-ntp-client-and-server) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) (`CM-0030`) | 📋 | ⭐ [Fix-the-SW01-Clock](../../../Playbooks/Fix-the-SW01-Clock.md) | ✅ |

---

## 2 — Syslog

Where Atlas runs it: local buffer today; ships to **MON01** when Phase 6 exists.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **Facilities + severity 0–7** | [Cisco-IOS §4.5](../../../Command-Library/Cisco-IOS.md#45--syslog-features-facilities-and-severity-levels) | [Syslog-and-SNMP](../../../Command-Library/Syslog-and-SNMP.md) | 📋 | [Trace-It-in-the-Logs](../../../Playbooks/Trace-It-in-the-Logs.md) | 🟡 |
| 2.2 | **Ship to a collector** (`logging host`, `logging trap`) | [Cisco-IOS §4.5](../../../Command-Library/Cisco-IOS.md#45--syslog-features-facilities-and-severity-levels) | — *(MON01 Phase 6)* | 📋 | [Trace-It-in-the-Logs](../../../Playbooks/Trace-It-in-the-Logs.md) | 📋 |

---

## 3 — CDP & LLDP

Where Atlas runs it: **CDP disabled on the 1941** (`no cdp run`, hardening); SW01 carries discovery.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 3.1 | **CDP / LLDP** — neighbor discovery (`show cdp/lldp neighbors`) | [Cisco-IOS §2.3](../../../Command-Library/Cisco-IOS.md#23--configure-and-verify-cdp-and-lldp) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) · [Cabling-and-Port-Map](../../../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md) | 📋 | — | 🟡 |

---

## 4 — Gaps this page surfaces

- 📋 **Syslog to MON01 (2.2)** is a build gap until Phase 6 (MON01/LibreNMS) exists — flips to ✅ then. [`Trace-It-in-the-Logs`](../../../Playbooks/Trace-It-in-the-Logs.md) is the drill.
- 📋 **No time/NTP Concept page** (the "why": stratum, the sync-vs-config distinction that the `CM-0030`/`045` false-tick teaches).

## Related

- 🔧 Commands: [`§4.2`](../../../Command-Library/Cisco-IOS.md#42--configure-and-verify-ntp-client-and-server) · [`§4.5`](../../../Command-Library/Cisco-IOS.md#45--syslog-features-facilities-and-severity-levels) · [`§2.3`](../../../Command-Library/Cisco-IOS.md#23--configure-and-verify-cdp-and-lldp) · [`Syslog-and-SNMP`](../../../Command-Library/Syslog-and-SNMP.md) *(mutual links)*.
- 📄 Device: [`1941 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) · [`SW01 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) · [`ADR-0020`](../../../../00-Atlas-Foundation/Decisions/ADR-0020-NTP-Time-Source-Architecture.md).
- 🔧 Playbook: ⭐ [Fix-the-SW01-Clock](../../../Playbooks/Fix-the-SW01-Clock.md) · [Trace-It-in-the-Logs](../../../Playbooks/Trace-It-in-the-Logs.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 4.2 / 4.5 / 2.3.
- 📒 **Operator notes:** `NTP Notes.txt` (client/server/peer, authentication, access-groups) · `CDP & LLDP.txt`.
- 📄 **Atlas devices:** the real NTP source **DC01 `10.20.0.2`** (`ADR-0020`, the `CM-0030` stuck-clock lab) · the 1941 `no cdp run` hardening · [`Syslog-and-SNMP`](../../../Command-Library/Syslog-and-SNMP.md) (MON01 collector).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the device-management-protocols chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for device-management protocols: NTP (4.2, real DC01 source + the ⭐ Fix-the-SW01-Clock Playbook), syslog (4.5, 🟡 until MON01), CDP/LLDP (2.3, 1941 `no cdp run`). Flags the syslog-to-MON01 gap + a time/NTP Concept. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
