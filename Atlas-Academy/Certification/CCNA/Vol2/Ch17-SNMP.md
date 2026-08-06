---
Title: CCNA Ch17 — SNMP (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the SNMP chapter (objective 4.4). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch17 (Vol 2) — SNMP

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and the build target where there's no home yet). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **4.4** (the function of SNMP). Reverse-indexes into [`Cisco-IOS §4.4`](../../../Command-Library/Cisco-IOS.md#44--explain-the-function-of-snmp).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** lab build target.

## On this page
1. [SNMP](#1--snmp)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — SNMP

Where Atlas runs it: the old v2c `homelab` community was **removed** (`CM-0023`, a real cleartext scar); **SNMPv3** (auth+priv) → **MON01/LibreNMS** lands at Phase 6 (on the operator's build list).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🔧 Playbook | Status |
|---|---|---|---|---|---|
| 1.1 | **What SNMP does** — poll/trap device state to an NMS | [Cisco-IOS §4.4](../../../Command-Library/Cisco-IOS.md#44--explain-the-function-of-snmp) | [Syslog-and-SNMP](../../../Command-Library/Syslog-and-SNMP.md) | [Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device](../../../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md) | 🟡 |
| 1.2 | **v2c vs v3** (community string vs auth+priv) | [Cisco-IOS §4.4](../../../Command-Library/Cisco-IOS.md#44--explain-the-function-of-snmp) | `CM-0023` (v2c removed) | [Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device](../../../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md) | ✅ (removal) |
| 1.3 | **Verify** — `show snmp community` (no v2c) / `show snmp` | [Cisco-IOS §4.4](../../../Command-Library/Cisco-IOS.md#44--explain-the-function-of-snmp) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) | [Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device](../../../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md) | 🟡 |

---

## 2 — Gaps this page surfaces

- 🖥️ **Build target — SNMPv3 → MON01/LibreNMS** (Phase 6, on the operator's build list): auth+priv, a real poll. Flips 1.1/1.3 to ✅ — and the [Diagnose-SNMP-Polling](../../../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md) Playbook goes live.
- 🔴 **Never re-add the v2c `homelab` community** (`CM-0023`) — the cleartext scar this objective teaches.

## Related

- 🔧 Commands: [`Cisco-IOS §4.4`](../../../Command-Library/Cisco-IOS.md#44--explain-the-function-of-snmp) · [`Syslog-and-SNMP`](../../../Command-Library/Syslog-and-SNMP.md) *(mutual links)*.
- 🔧 Playbook: [Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device](../../../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md).
- **Sibling:** [`Ch13 — Device Management Protocols`](Ch13-Device-Management-Protocols.md) (NTP/syslog).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 4.4.
- 📄 **Atlas devices:** `CM-0023` (the v2c removal) · [`Syslog-and-SNMP`](../../../Command-Library/Syslog-and-SNMP.md) (rsyslog + LibreNMS collector on MON01) · the [Diagnose-SNMP-Polling](../../../Playbooks/Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device.md) Playbook.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the SNMP chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for SNMP (4.4): the v2c removal (`CM-0023`) is ✅; SNMPv3→MON01 is the 🖥️ build target (Phase 6) that lights up the Diagnose-SNMP-Polling Playbook. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
