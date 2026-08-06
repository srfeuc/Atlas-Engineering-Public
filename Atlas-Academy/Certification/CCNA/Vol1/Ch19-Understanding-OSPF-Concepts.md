---
Title: CCNA Ch19 — Understanding OSPF Concepts (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the OSPF-concepts chapter (objective 3.4). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch19 (Vol 1) — Understanding OSPF Concepts

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **3.4** (single-area OSPFv2 — the *concepts* half). Reverse-indexes into [`Cisco-IOS §3.4`](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [How OSPF works](#1--how-ospf-works)
2. [Neighbors & adjacency](#2--neighbors--adjacency)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — How OSPF works

Where Atlas runs it: **1941** — OSPF process 1, area 0, adjacency **FULL with MKT01**, MKT01's VLANs learned as `O E2`.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Link-state operation** — LSAs, the topology DB, SPF/Dijkstra | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) §3 | 📋 | — | 🟡 |
| 1.2 | **Areas** (single-area 0) + the **cost** metric | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 | 📋 | — | ✅ |
| 1.3 | **Router-ID** (from a loopback — always up) | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 (`router-id 10.255.0.1`) | 📋 | — | ✅ |

---

## 2 — Neighbors & adjacency

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **Neighbor states** (Down→Init→2-Way→ExStart→Exchange→Full) | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) §4 (`show ip ospf neighbor` FULL) | 📋 | 📋 *(an "adjacency stuck at EXSTART/INIT" drill)* | ✅ |
| 2.2 | **DR/BDR** — elected on broadcast segments, **none** on a point-to-point `/30` | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | the 1941↔MKT01 `/30` (`FULL/ -` = no DR/BDR) | 📋 | — | ✅ |

> 🔴 **Atlas reality:** the 1941↔MKT01 link is point-to-point, so `show ip ospf neighbor` shows `FULL/ -` — the `-` means no DR/BDR was elected (correct on a `/30`).

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "the OSPF adjacency is stuck."** The real 1941↔MKT01 (Cisco↔RouterOS) case: stuck **EXSTART/EXCHANGE** = MTU mismatch (`ip ospf mtu-ignore` or match MTU); stuck **INIT/2-WAY** = network-type/DR mismatch. A prime **Playbook build target** (device-verified interop lesson) — see [Ch21](Ch21-OSPF-Network-Types-and-Neighbors.md).
- 📋 **No OSPF Concept page** (the "why": LSAs vs distance-vector, learn-vs-originate `O E2`, the loopback router-id).

## Related

- 🔧 Commands: [`Cisco-IOS §3.4`](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) *(mutual link)*.
- 📄 Device: [`1941 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 · [`1941 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md).
- **Trio:** [`Ch20 — Implementing OSPF`](Ch20-Implementing-OSPF.md) · [`Ch21 — OSPF Network Types & Neighbors`](Ch21-OSPF-Network-Types-and-Neighbors.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 3.4 (OSPF concepts).
- 📒 **Operator notes:** `OSPF Config.txt` (router-id, network/wildcards, DR/BDR priority, timers, passive-interface).
- 📄 **Atlas devices:** [`1941 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) / [`Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) (the real FULL adjacency with MKT01; `O E2` VLANs).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the OSPF-concepts chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for OSPF concepts (3.4), grounded in the 1941's real area-0 adjacency with MKT01 (loopback router-id, `O E2` VLANs, `FULL/ -` point-to-point). Flags the adjacency-stuck Playbook target. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
