---
Title: CCNA Ch21 — OSPF Network Types and Neighbors (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the OSPF network-types + neighbors chapter (objective 3.4). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch21 (Vol 1) — OSPF Network Types and Neighbors

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **3.4** (single-area OSPFv2 — *network types, DR/BDR, neighbor troubleshooting*). Reverse-indexes into [`Cisco-IOS §3.4`](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [Network types](#1--network-types)
2. [Neighbor requirements & troubleshooting](#2--neighbor-requirements--troubleshooting)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — Network types

Where Atlas runs it: the 1941↔MKT01 link is a **point-to-point `/30`** — no DR/BDR. A **broadcast** (multi-access) segment with a DR/BDR election needs 3+ routers — the forthcoming **Packet-Tracer twin** is the home for that.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Point-to-point** — no DR/BDR (a `/30` link) | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | the 1941↔MKT01 `/30` (`show ip ospf neighbor` → `FULL/ -`) | 📋 | — | ✅ |
| 1.2 | **Broadcast** — DR/BDR election (priority, highest wins; router-id ties) | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | — *(needs 3+ routers → Packet-Tracer twin)* | 📋 | 📋 *(a DR/BDR-election drill — Packet Tracer)* | 📘 |

---

## 2 — Neighbor requirements & troubleshooting

Where Atlas runs it: the 1941↔MKT01 adjacency is **Cisco↔RouterOS** — the estate's real interop lesson.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **What must match** to form an adjacency — area, hello/dead, subnet/mask, **MTU**, auth | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Considerations](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) (OSPF↔RouterOS interop) | 📋 | 📋 *(the adjacency-stuck drill)* | ✅ |
| 2.2 | **Troubleshoot a stuck adjacency** — EXSTART/EXCHANGE = MTU; INIT/2-WAY = network-type/DR | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Build-Checklist](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) (failure modes) | 📋 | 📋 *(the adjacency-stuck drill)* | ✅ |

> 🔴 **Atlas reality (2.2) — the real interop lesson:** the 1941↔MKT01 adjacency sticks at **EXSTART/EXCHANGE** on an **MTU mismatch** (`ip ospf mtu-ignore` both ends, or match MTU), and at **INIT/2-WAY** on a network-type/DR mismatch. Currently **FULL** (07-21).

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "the OSPF adjacency won't come up."** The device-verified 1941↔MKT01 (Cisco↔RouterOS) MTU/EXSTART case — a top **Playbook build target**. The operator can run it on the real hardware.
- 📋 / 🖥️ **DR/BDR election (1.2)** needs a **multi-access segment (3+ routers)** — no Atlas home on one `/30`. 🖥️ **The forthcoming Packet-Tracer twin is the planned source** for this election demo (and its own Playbook).
- 📋 **No OSPF Concept page** (shared with Ch19/Ch20).

## Related

- 🔧 Commands: [`Cisco-IOS §3.4`](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) *(mutual link)*.
- 📄 Device: [`1941 Considerations`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) (OSPF/RouterOS interop) · [`1941 Build-Checklist`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) · [`1941 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md).
- **Trio:** [`Ch19 — OSPF Concepts`](Ch19-Understanding-OSPF-Concepts.md) · [`Ch20 — Implementing OSPF`](Ch20-Implementing-OSPF.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 3.4 (network types, DR/BDR, neighbors).
- 📒 **Operator notes:** `OSPF Config.txt` (DR/BDR election, priority, network-type point-to-point, timers).
- 📄 **Atlas devices:** [`1941 Considerations`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) / [`Build-Checklist`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) (the real Cisco↔RouterOS MTU/EXSTART interop).
- 🖥️ **Forthcoming:** the Packet-Tracer twin (a broadcast segment for the DR/BDR election) — a planned source of info + Playbooks.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the OSPF-network-types/neighbors chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for OSPF network types + neighbors (3.4), grounded in the point-to-point 1941↔MKT01 `/30` (no DR/BDR) + the real Cisco↔RouterOS MTU/EXSTART interop. Flags the adjacency-stuck Playbook target + the DR/BDR-election gap (Packet-Tracer twin as the planned home). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
