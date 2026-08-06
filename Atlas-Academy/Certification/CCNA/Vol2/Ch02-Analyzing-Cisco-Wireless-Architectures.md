---
Title: CCNA Ch2 — Analyzing Cisco Wireless Architectures (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the wireless-architectures chapter (objective 2.6). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch2 (Vol 2) — Analyzing Cisco Wireless Architectures

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and the build target where there's no home yet). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **2.6** (Cisco wireless architectures + AP modes). Reverse-indexes into [`Cisco-IOS §2.6`](../../../Command-Library/Cisco-IOS.md#26--describe-cisco-wireless-architectures-and-ap-modes).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** WLC/AP build target.

## On this page
1. [AP architectures & WLC models](#1--ap-architectures--wlc-models)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — AP architectures & WLC models

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **AP architectures** — autonomous · cloud (Meraki) · split-MAC (lightweight + WLC) · **Mobility Express** | [Cisco-IOS §2.6](../../../Command-Library/Cisco-IOS.md#26--describe-cisco-wireless-architectures-and-ap-modes) | FortiAP (Fortinet split-MAC analogue) | 📘 |
| 1.2 | **WLC deployment models** — unified · cloud · embedded/ME | [Cisco-IOS §2.6](../../../Command-Library/Cisco-IOS.md#26--describe-cisco-wireless-architectures-and-ap-modes) | — | 📘 → 🖥️ |
| 1.3 | **AP modes** — local · FlexConnect · monitor · sniffer · bridge | [Cisco-IOS §2.6](../../../Command-Library/Cisco-IOS.md#26--describe-cisco-wireless-architectures-and-ap-modes) | — | 📘 → 🖥️ |

> 🖥️ **Build target — a cheap Cisco WLC (under $300).** A used **Aironet 1815i / 1832i running Mobility Express** — an AP with an *embedded* WLC (“WLC awareness”), ~$50–120 used — gives the real Cisco WLC GUI + WLAN config in one box. Alternatives: the free **Catalyst 9800-CL virtual WLC** (VM / EVE-NG); or an **autonomous IOS AP** (cheapest, standalone). The owned **FortiAP** covers the *concepts* + WPA2-Enterprise against NPS01, not the Cisco WLC GUI.

---

## 2 — Gaps this page surfaces

- 🖥️ **A Mobility-Express AP is the cheapest way to hold *both* the WLC and an AP** — it demonstrates the embedded-WLC model (1.2) + local AP mode (1.3) in one sub-00 box. Flips 1.x to ✅/🟡.
- 📋 **No wireless-architecture Concept page** (autonomous vs split-MAC vs cloud vs ME).

## Related
- 🔧 Commands: [`Cisco-IOS §2.6`](../../../Command-Library/Cisco-IOS.md#26--describe-cisco-wireless-architectures-and-ap-modes) *(mutual link)*.
- **Wireless set:** [`Ch1 — Wireless Fundamentals`](Ch01-Fundamentals-of-Wireless-Networks.md) · [`Ch3 — Securing Wireless`](Ch03-Securing-Wireless-Networks.md) · [`Ch4 — Building a Wireless LAN`](Ch04-Building-a-Wireless-LAN.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 2.6.
- 📄 **Atlas devices:** the owned **FortiAP** (a Fortinet split-MAC AP); a **Mobility-Express AP / 9800-CL** = the build target.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the wireless-architectures chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for wireless architectures (2.6): 📘 today, 🖥️ build target = a Mobility-Express AP (holds both WLC + AP under $300) / 9800-CL. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
