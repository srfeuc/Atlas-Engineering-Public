---
Title: CCNA Ch18 — LAN Architecture (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the LAN-architecture chapter (objectives 1.2/1.1). Objective → Atlas artifact + gaps. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch18 (Vol 2) — LAN Architecture

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **1.2** (topology architectures — 2/3-tier, spine-leaf, SOHO) + **1.1.h** (PoE). Reverse-indexes into [`§1.2`](../../../Command-Library/Cisco-IOS.md#12--describe-characteristics-of-network-topology-architectures) / [`§1.1`](../../../Command-Library/Cisco-IOS.md#11--explain-the-role-and-function-of-network-components).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap.

## On this page
1. [LAN topology architectures](#1--lan-topology-architectures)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — LAN topology architectures

Where Atlas runs it: a **collapsed-core / SOHO** — SW01 (access) → 1941/MKT01 (core), no distinct distribution tier.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **2-tier / 3-tier / spine-leaf / SOHO** | [Cisco-IOS §1.2](../../../Command-Library/Cisco-IOS.md#12--describe-characteristics-of-network-topology-architectures) | Atlas = collapsed-core/SOHO ([Cabling-and-Port-Map](../../../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md)) | ✅ (as the real example) |
| 1.2 | **PoE** (powering APs/phones) | [Cisco-IOS §1.1](../../../Command-Library/Cisco-IOS.md#11--explain-the-role-and-function-of-network-components) | the 2960X's PoE ports (SW01) | 🟡 |

> 🔴 **Atlas is not 3-tier** — it has no distribution layer; calling it three-tier is the classic misread.

---

## 2 — Gaps this page surfaces

- 📘 **Spine-leaf / 3-tier** are study-only (Atlas is collapsed-core) — a Packet-Tracer twin could diagram them.
- 📋 **No topology Concept page.**

## Related
- 🔧 Commands: [`§1.2`](../../../Command-Library/Cisco-IOS.md#12--describe-characteristics-of-network-topology-architectures) · [`§1.1`](../../../Command-Library/Cisco-IOS.md#11--explain-the-role-and-function-of-network-components) *(mutual links)*.
- 📄 Architecture: [`Cabling-and-Port-Map`](../../../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md) · [`Atlas-Service-Architecture`](../../../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-Service-Architecture.md).
- **Sibling:** [`Ch19 — WAN Architecture`](Ch19-WAN-Architecture.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 1.2 / 1.1.h.
- 📄 **Atlas devices:** the collapsed-core/SOHO topology (`Cabling-and-Port-Map`); the 2960X PoE ports.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the LAN-architecture chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for LAN architecture (1.2/1.1.h): Atlas as the real collapsed-core/SOHO example + the 2960X PoE. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
