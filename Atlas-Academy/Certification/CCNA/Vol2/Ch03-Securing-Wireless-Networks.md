---
Title: CCNA Ch3 — Securing Wireless Networks (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the wireless-security chapter (objective 5.9). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch3 (Vol 2) — Securing Wireless Networks

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and the build target where there's no home yet). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **5.9** (wireless security — WPA/WPA2/WPA3). Reverse-indexes into [`Cisco-IOS §5.9`](../../../Command-Library/Cisco-IOS.md#59--wireless-security-protocols-wpa-wpa2-wpa3).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** WLC/AP build target.

## On this page
1. [Wireless security](#1--wireless-security)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Wireless security

🔗 **Ties to identity:** WPA2/3-**Enterprise** = 802.1X back to **NPS01** (§5.8 AAA) — the one place wireless meets the estate's identity stack. The **FortiAP** can demonstrate WPA2-Enterprise today.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **Authentication** — open · PSK (personal) · 802.1X/EAP (enterprise) | [Cisco-IOS §5.9](../../../Command-Library/Cisco-IOS.md#59--wireless-security-protocols-wpa-wpa2-wpa3) | FortiAP → NPS01 (802.1X) | 🟡 (FortiAP) |
| 1.2 | **Privacy/integrity** — TKIP · CCMP · GCMP | [Cisco-IOS §5.9](../../../Command-Library/Cisco-IOS.md#59--wireless-security-protocols-wpa-wpa2-wpa3) | — | 📘 |
| 1.3 | **WPA / WPA2 / WPA3** generations | [Cisco-IOS §5.9](../../../Command-Library/Cisco-IOS.md#59--wireless-security-protocols-wpa-wpa2-wpa3) | FortiAP (concept) | 📘 |

> 🖥️ **Build target:** a Cisco WLC/AP (a cheap **Mobility-Express AP**, under $300) for the Cisco-specific WPA config; the **FortiAP** already demonstrates **WPA2-Enterprise against NPS01** — a strong do-now that also serves §5.8.

---

## 2 — Gaps this page surfaces

- 🖥️ **WPA2-Enterprise on the FortiAP → NPS01** is a **do-now** (ties wireless to the real RADIUS stack, §5.8) — flips 1.1 toward ✅.
- 📋 **No wireless-security Concept page** (the auth-vs-privacy split; PSK vs Enterprise).

## Related
- 🔧 Commands: [`Cisco-IOS §5.9`](../../../Command-Library/Cisco-IOS.md#59--wireless-security-protocols-wpa-wpa2-wpa3) *(mutual link)*.
- 🔗 Identity: [`Cisco-IOS §5.8 AAA`](../../../Command-Library/Cisco-IOS.md#58--aaa-authentication-authorization-accounting) (RADIUS→NPS01).
- **Wireless set:** [`Ch1`](Ch01-Fundamentals-of-Wireless-Networks.md) · [`Ch2`](Ch02-Analyzing-Cisco-Wireless-Architectures.md) · [`Ch4`](Ch04-Building-a-Wireless-LAN.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 5.9.
- 📄 **Atlas devices:** the owned **FortiAP** (WPA2-Enterprise → NPS01, do-now); a Cisco WLC/AP = the build target.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the securing-wireless chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for wireless security (5.9): the FortiAP can do **WPA2-Enterprise → NPS01** (a do-now tying wireless to §5.8); WPA3/CCMP/GCMP + Cisco config are 🖥️ build targets. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
