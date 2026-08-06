---
Title: CCNA Ch4 — Building a Wireless LAN (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the build-a-WLAN chapter (objectives 2.7/2.9/5.10). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch4 (Vol 2) — Building a Wireless LAN

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and the build target where there's no home yet). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **2.7** (WLAN physical infra) + **2.9** (WLAN GUI config) + **5.10** (WPA2-PSK WLAN). Reverse-indexes into [`Cisco-IOS §2.7`](../../../Command-Library/Cisco-IOS.md#27--describe-physical-infrastructure-connections-of-wlan-components).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** WLC/AP build target.

## On this page
1. [Connect & configure a WLAN](#1--connect--configure-a-wlan)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Connect & configure a WLAN

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **Physical infra** — AP on access/trunk port, WLC uplink as LAG | [Cisco-IOS §2.7](../../../Command-Library/Cisco-IOS.md#27--describe-physical-infrastructure-connections-of-wlan-components) | (reuses trunking §2.2 + EtherChannel §2.4) | 📘 → 🖥️ |
| 1.2 | **Configure a WLAN in the GUI** — SSID → VLAN, security, QoS profile | [Cisco-IOS §2.7](../../../Command-Library/Cisco-IOS.md#27--describe-physical-infrastructure-connections-of-wlan-components) | FortiAP GUI (analogue) | 📘 → 🖥️ |
| 1.3 | **WPA2-PSK WLAN** end-to-end | [Cisco-IOS §2.7](../../../Command-Library/Cisco-IOS.md#27--describe-physical-infrastructure-connections-of-wlan-components) | FortiAP (can do PSK today) | 🟡 (FortiAP) |

> 🖥️ **Build target — a cheap Cisco WLC (under $300).** A used **Aironet 1815i / 1832i running Mobility Express** — an AP with an *embedded* WLC (“WLC awareness”), ~$50–120 used — gives the real Cisco WLC GUI + WLAN config in one box. Alternatives: the free **Catalyst 9800-CL virtual WLC** (VM / EVE-NG); or an **autonomous IOS AP** (cheapest, standalone). The owned **FortiAP** covers the *concepts* + WPA2-Enterprise against NPS01, not the Cisco WLC GUI.

---

## 2 — Gaps this page surfaces

- 🖥️ **The full "create a WLAN in the WLC GUI" objective (2.9/5.10) needs the Cisco WLC** — a **Mobility-Express AP** (under $300) is the cheapest way to do it for real. The **FortiAP** can stand up a WPA2-PSK SSID→VLAN today (the mapping transfers; the Cisco screens don't).
- 📋 **Playbook needed — "a wireless client can't associate / gets no lease."** SSID→VLAN mapping / DHCP-per-WLAN / PSK-vs-Enterprise — a natural drill once the WLC/AP is up.

## Related
- 🔧 Commands: [`Cisco-IOS §2.7`](../../../Command-Library/Cisco-IOS.md#27--describe-physical-infrastructure-connections-of-wlan-components) *(mutual link)*.
- 🔗 Reuses: trunking [§2.2](../../../Command-Library/Cisco-IOS.md#22--configure-and-verify-interswitch-connectivity-trunks-8021q-native-vlan) · EtherChannel/LAG [§2.4](../../../Command-Library/Cisco-IOS.md#24--configure-and-verify-etherchannel-lacp) · DHCP [§4.3](../../../Command-Library/Cisco-IOS.md#43--explain-the-role-of-dhcp-and-dns).
- **Wireless set:** [`Ch1`](Ch01-Fundamentals-of-Wireless-Networks.md) · [`Ch2`](Ch02-Analyzing-Cisco-Wireless-Architectures.md) · [`Ch3`](Ch03-Securing-Wireless-Networks.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 2.7 / 2.9 / 5.10.
- 📄 **Atlas devices:** the owned **FortiAP** (WPA2-PSK SSID→VLAN today); a **Mobility-Express AP / 9800-CL** = the build target for the Cisco WLC GUI.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the building-a-wireless-LAN chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for building a WLAN (2.7/2.9/5.10): the FortiAP can do WPA2-PSK today; the Cisco WLC GUI is the 🖥️ build target (cheap Mobility-Express AP). Flags the client-can't-associate Playbook. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
