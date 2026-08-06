---
Title: CCNA Ch20 — Implementing OSPF (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the OSPF-config chapter (objective 3.4). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch20 (Vol 1) — Implementing OSPF

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **3.4** (single-area OSPFv2 — the *configuration* half). Reverse-indexes into [`Cisco-IOS §3.4`](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [Single-area configuration](#1--single-area-configuration)
2. [Tuning & the default route](#2--tuning--the-default-route)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — Single-area configuration

Where Atlas runs it: **1941** — `router ospf 1`, `router-id 10.255.0.1`, only the two transit `/30`s + loopback in area 0 (device-verified 07-21).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Start the process + router-id** (`router ospf 1`, `router-id`) | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 | 📋 | — | ✅ |
| 1.2 | **`network … area 0` with wildcard** — enable OSPF on the right interfaces | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 (the two /30s + loopback) | 📋 | — | ✅ |
| 1.3 | **Verify** — `show ip ospf neighbor` (FULL), `show ip protocols` | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) §3/§4 | 📋 | — | ✅ |

> 🔴 **The classic mistake (device-verified lesson):** `network` enables OSPF on a *matching interface* — it does **not** advertise a route. Putting VLAN-subnet `network` statements on the 1941 (which owns no VLAN interface) does nothing; the VLANs are **learned from MKT01**. Only the two transit `/30`s + loopback belong here.

---

## 2 — Tuning & the default route

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **`passive-interface`** — silence OSPF on a non-neighbor link | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 (`passive-interface Gi0/1` → FGT01) | 📋 | — | ✅ |
| 2.2 | **`default-information originate`** — push the static default into OSPF | [Cisco-IOS §3.4](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 | 📋 | 📋 *(a "no default-information originate → internal blackhole" drill)* | ✅ |

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "internal traffic blackholes toward the internet."** Missing `default-information originate` → MKT01 never learns the default → internal hosts can't egress, with no obvious error. A clean 1941 drill. **Build target.**
- 📋 **No OSPF Concept page** (shared with Ch19/Ch21) — the learn-vs-originate (`O E2`) idea especially.

## Related

- 🔧 Commands: [`Cisco-IOS §3.4`](../../../Command-Library/Cisco-IOS.md#34--configure-and-verify-single-area-ospfv2) *(mutual link)*.
- 📄 Device: [`1941 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 · [`1941 Build-Checklist`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) (failure modes) · [`1941 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md).
- **Trio:** [`Ch19 — OSPF Concepts`](Ch19-Understanding-OSPF-Concepts.md) · [`Ch21 — OSPF Network Types & Neighbors`](Ch21-OSPF-Network-Types-and-Neighbors.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 3.4 (OSPF config).
- 📒 **Operator notes:** `OSPF Config.txt` (process/router-id/network-wildcard/passive-interface/default-information-originate + worked single-area example).
- 📄 **Atlas devices:** [`1941 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 / [`Build-Checklist`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) (the real config + the network-statement failure mode).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the implementing-OSPF chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for OSPF config (3.4), grounded in the real 1941 Stage-3 config (process 1, loopback router-id, the two /30s + loopback only, `passive-interface Gi0/1`, `default-information originate`) + the network-statement lesson. Flags the blackhole Playbook target. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
