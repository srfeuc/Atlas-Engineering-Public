---
Title: CCNA Ch16 — First Hop Redundancy Protocols (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the FHRP chapter (objective 3.5). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch16 (Vol 2) — First Hop Redundancy Protocols

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and the build target where there's no home yet). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **3.5** (FHRP — HSRP/VRRP/GLBP concepts). Reverse-indexes into [`Cisco-IOS §3.5`](../../../Command-Library/Cisco-IOS.md#35--first-hop-redundancy-protocols-fhrp).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** lab/Packet-Tracer build target (needs a second router).

## On this page
1. [FHRP](#1--fhrp)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — FHRP

🔴 **Atlas has one gateway today** (MKT01 in prod; the 1941 in the lab) — no FHRP runs. HSRP needs a second router; the **Packet-Tracer twin** is the natural home.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🔧 Playbook | Status |
|---|---|---|---|---|---|
| 1.1 | **Purpose** — a shared virtual gateway IP/MAC (active/standby) | [Cisco-IOS §3.5](../../../Command-Library/Cisco-IOS.md#35--first-hop-redundancy-protocols-fhrp) | — (single gateway) | 📋 | 📘 → 🖥️ |
| 1.2 | **HSRP** (Cisco) — priority, preempt, virtual IP | [Cisco-IOS §3.5](../../../Command-Library/Cisco-IOS.md#35--first-hop-redundancy-protocols-fhrp) | — | 📋 | 📘 → 🖥️ (2nd router) |
| 1.3 | **Verify** — `show standby brief` | [Cisco-IOS §3.5](../../../Command-Library/Cisco-IOS.md#35--first-hop-redundancy-protocols-fhrp) | — | 📋 | 🖥️ |

---

## 2 — Gaps this page surfaces

- 🖥️ **Build target — HSRP on a router pair** (a second router / the Packet-Tracer twin): virtual IP, priority + preempt, fail-over. Flips 1.x to ✅.
- 📋 **Playbook needed — "both routers Active / no fail-back."** The classic HSRP priority/preempt misconfig.
- 📘 **VRRP on MKT01** could demonstrate the *concept* today (a possible do-now).

## Related

- 🔧 Commands: [`Cisco-IOS §3.5`](../../../Command-Library/Cisco-IOS.md#35--first-hop-redundancy-protocols-fhrp) *(mutual link)*.
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) (FHRP needs a 2nd router) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 3.5.
- 📒 **Operator notes:** the FHRP / HSRP / HSRP-Advanced / Network-Redundancy lesson PDFs (operator-side — re-provide when building this).
- 📄 **Atlas target:** HSRP on a router pair (2nd router / Packet-Tracer twin); VRRP-on-MKT01 for the concept.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the FHRP chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for FHRP (3.5): 📘 today (single gateway), 🖥️ build target = HSRP on a router pair (2nd router / Packet-Tracer twin); VRRP-on-MKT01 as the concept. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
