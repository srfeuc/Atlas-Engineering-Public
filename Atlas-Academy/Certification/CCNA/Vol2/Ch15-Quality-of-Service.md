---
Title: CCNA Ch15 — Quality of Service (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the QoS chapter (objective 4.7). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch15 (Vol 2) — Quality of Service

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and the build target where there's no home yet). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **4.7** (per-hop behavior — classification, marking, queuing, congestion, policing, shaping). Reverse-indexes into [`Cisco-IOS §4.7`](../../../Command-Library/Cisco-IOS.md#47--forwarding-per-hop-behavior-phb-for-qos).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** lab/Packet-Tracer build target.

## On this page
1. [QoS per-hop behavior](#1--qos-per-hop-behavior)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — QoS per-hop behavior

🔴 **You only *see* QoS under congestion** — Atlas needs generated load (`iperf3`) to make a policy's effect visible. This is on the operator's build list.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🔧 Playbook | Status |
|---|---|---|---|---|---|
| 1.1 | **Classification + marking** (DSCP/CoS) | [Cisco-IOS §4.7](../../../Command-Library/Cisco-IOS.md#47--forwarding-per-hop-behavior-phb-for-qos) | — | 📋 | 📘 → 🖥️ |
| 1.2 | **Queuing / congestion management** | [Cisco-IOS §4.7](../../../Command-Library/Cisco-IOS.md#47--forwarding-per-hop-behavior-phb-for-qos) | — | 📋 | 📘 → 🖥️ |
| 1.3 | **Policing vs shaping** (drop vs buffer over-rate) | [Cisco-IOS §4.7](../../../Command-Library/Cisco-IOS.md#47--forwarding-per-hop-behavior-phb-for-qos) | — | 📋 | 📘 → 🖥️ |
| 1.4 | **Verify** — `show policy-map interface` under load | [Cisco-IOS §4.7](../../../Command-Library/Cisco-IOS.md#47--forwarding-per-hop-behavior-phb-for-qos) | — | 📋 | 🖥️ |

---

## 2 — Gaps this page surfaces

- 🖥️ **Build target — a QoS lab with generated congestion** (`iperf3` on a client + a VM, then prove the policy changed the outcome). This is the operator's stated build; it flips all of 1.x to ✅. Without load, a QoS policy is correct but idle.
- 📋 **Playbook needed — "the QoS policy isn't doing anything."** Almost always: no congestion to act on (generate load first).
- 📋 **No QoS Concept page.**

## Related

- 🔧 Commands: [`Cisco-IOS §4.7`](../../../Command-Library/Cisco-IOS.md#47--forwarding-per-hop-behavior-phb-for-qos) *(mutual link)*.
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) (QoS needs `iperf3`) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 4.7.
- 📒 **Operator notes:** the `QOS` note folder (operator-side — re-provide when building this).
- 📄 **Atlas target:** an `iperf3` congestion lab (a client + a VM) — the operator's stated build.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the QoS chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for QoS (4.7): 📘 today, 🖥️ build target = an `iperf3` congestion lab (operator's stated build). Flags the QoS lab + the no-congestion Playbook. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
