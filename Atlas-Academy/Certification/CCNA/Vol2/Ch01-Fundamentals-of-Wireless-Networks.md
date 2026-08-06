---
Title: CCNA Ch1 — Fundamentals of Wireless Networks (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the wireless-fundamentals chapter (objective 1.11). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch1 (Vol 2) — Fundamentals of Wireless Networks

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and the build target where there's no home yet). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **1.11** (wireless principles — SSID, RF, non-overlapping channels, encryption). Reverse-indexes into [`Cisco-IOS §1.11`](../../../Command-Library/Cisco-IOS.md#111--describe-wireless-principles).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** WLC/AP build target.

## On this page
1. [RF & wireless principles](#1--rf--wireless-principles)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — RF & wireless principles

🔴 **Build gap — no Cisco wireless in Atlas today.** The owned **FortiAP** teaches the RF/SSID *principles*; the Cisco specifics need a WLC/AP (see the build target).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **RF basics** — 2.4/5 GHz bands, **non-overlapping channels (1/6/11)** | [Cisco-IOS §1.11](../../../Command-Library/Cisco-IOS.md#111--describe-wireless-principles) | FortiAP (concept) | 📘 |
| 1.2 | **SSID + encryption** overview | [Cisco-IOS §1.11](../../../Command-Library/Cisco-IOS.md#111--describe-wireless-principles) | FortiAP (concept) | 📘 |
| 1.3 | **WLAN topologies** — BSS · ESS · IBSS · repeater/bridge/mesh | [Cisco-IOS §1.11](../../../Command-Library/Cisco-IOS.md#111--describe-wireless-principles) | — | 📘 |

> 🖥️ **Build target — a cheap Cisco WLC (under $300).** The best value is a used **Aironet 1815i or 1832i running Mobility Express** — an AP with an *embedded* WLC (“WLC awareness”), typically ~$50–120 used, giving the real Cisco WLC GUI + WLAN config in one box. Alternatives: the **Catalyst 9800-CL virtual WLC** (free, runs in a VM / EVE-NG); or an **autonomous IOS AP** (cheapest, standalone, no controller — teaches the autonomous model). The owned **FortiAP** covers RF/SSID/WPA *concepts* + WPA2-Enterprise against NPS01, but not the Cisco WLC GUI.

---

## 2 — Gaps this page surfaces

- 🖥️ **Get a cheap WLC/AP** (above) to move wireless from 📘 to hands-on. The FortiAP is the concept stand-in until then.
- 📋 **No wireless Concept page** (RF, channels, the BSS/ESS model).

## Related
- 🔧 Commands: [`Cisco-IOS §1.11`](../../../Command-Library/Cisco-IOS.md#111--describe-wireless-principles) *(mutual link)*.
- **Wireless set:** [`Ch2 — Cisco Wireless Architectures`](Ch02-Analyzing-Cisco-Wireless-Architectures.md) · [`Ch3 — Securing Wireless`](Ch03-Securing-Wireless-Networks.md) · [`Ch4 — Building a Wireless LAN`](Ch04-Building-a-Wireless-LAN.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 1.11.
- 📄 **Atlas devices:** the owned **FortiAP** (RF/SSID concepts); a **Cisco WLC/AP** = the build target.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the wireless-fundamentals chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for wireless fundamentals (1.11): 📘 today (FortiAP concept), 🖥️ build target = a cheap Mobility-Express AP / 9800-CL. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
