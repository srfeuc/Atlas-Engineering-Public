---
Title: CCNA Ch9 — Security Architectures (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the security-architectures chapter (objectives 5.1/5.2). Objective → Atlas artifact + gaps. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch9 (Vol 2) — Security Architectures

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **5.1** (threats/vulnerabilities/exploits/mitigation) + **5.2** (security program — awareness/training/physical). Reverse-indexes into [`§5.1`](../../../Command-Library/Cisco-IOS.md#51--key-security-concepts-threats-vulnerabilities-exploits-mitigation) / [`§5.2`](../../../Command-Library/Cisco-IOS.md#52--security-program-elements-awareness-training-physical-access).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap.

## On this page
1. [Security concepts & program](#1--security-concepts--program)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Security concepts & program

Atlas is a real security estate — the *whole design* is mitigation (perimeter FGT01 → east-west MKT01 → host CIS → identity tiers), backed by a real policy/standard set.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **Threat vs vulnerability vs exploit vs mitigation** | [Cisco-IOS §5.1](../../../Command-Library/Cisco-IOS.md#51--key-security-concepts-threats-vulnerabilities-exploits-mitigation) | the estate Policies (`POL-*`) + [Firewall-Architecture](../../../../00-Atlas-Foundation/Reference/Atlas-Firewall-Architecture.md) | 📘 |
| 1.2 | **NGFW / IPS** in the architecture | [Cisco-IOS §5.1](../../../Command-Library/Cisco-IOS.md#51--key-security-concepts-threats-vulnerabilities-exploits-mitigation) | FGT01 (NGFW) + PFSENSE01 (Suricata IPS) | 🟡 |
| 1.3 | **Program elements** — awareness, training, physical | [Cisco-IOS §5.2](../../../Command-Library/Cisco-IOS.md#52--security-program-elements-awareness-training-physical-access) | the Security-Program docs + `STD-0003` | 📘 |

---

## 2 — Gaps this page surfaces

- 📋 **No security-concepts Concept page** (though the estate's POL/STD set is the grounding).

## Related
- 🔧 Commands: [`§5.1`](../../../Command-Library/Cisco-IOS.md#51--key-security-concepts-threats-vulnerabilities-exploits-mitigation) · [`§5.2`](../../../Command-Library/Cisco-IOS.md#52--security-program-elements-awareness-training-physical-access) *(mutual links)*.
- 📄 Reference: [`Atlas-Firewall-Architecture`](../../../../00-Atlas-Foundation/Reference/Atlas-Firewall-Architecture.md) (the segmentation pattern).
- **Sibling:** [`Ch10 — Securing Network Devices`](Ch10-Securing-Network-Devices.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 5.1 / 5.2.
- 📄 **Atlas devices/docs:** FGT01/PFSENSE01 (NGFW/IPS); the estate Policies + Security-Program + `STD-0003`.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the security-architectures chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for security architectures (5.1/5.2), grounded in the estate's real mitigation layers (FGT01/PFSENSE01 + POL/STD). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
