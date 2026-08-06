---
Title: CCNA Ch17 — IP Routing in the LAN (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the inter-VLAN-routing chapter (objective 2.1 inter-VLAN + L3 switching). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch17 (Vol 1) — IP Routing in the LAN

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **2.1** (inter-VLAN connectivity) + Layer-3 switching (SVIs / routed ports). Reverse-indexes into [`Cisco-IOS §2.1`](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) + [`§3.1`](../../../Command-Library/Cisco-IOS.md#31--interpret-the-components-of-the-routing-table).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [Router-on-a-stick](#1--router-on-a-stick)
2. [Layer-3 switching (SVIs / routed ports)](#2--layer-3-switching-svis--routed-ports)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — Router-on-a-stick

Where Atlas runs it: the **1941 CCNA overlay** — one trunk from SW01, a subinterface + `.1` gateway per VLAN (real IP-plan addresses). This is the estate's operator-adopted inter-VLAN lab.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Subinterfaces + `encapsulation dot1q`** — a gateway per VLAN on one trunk | [Cisco-IOS §2.1](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) §6 | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |
| 1.2 | **Verify inter-VLAN** — `show ip route connected`, ping across VLANs | [Cisco-IOS §3.1](../../../Command-Library/Cisco-IOS.md#31--interpret-the-components-of-the-routing-table) | the 1941 [overlay Build-Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md) | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |

---

## 2 — Layer-3 switching (SVIs / routed ports)

🔴 **Atlas split:** SW01 is **pure L2** (no `ip routing`, no routing SVI — `ADR-0023`); production inter-VLAN routing lives on **MKT01**. A multilayer-switch SVI/routed-port build is **study/📘** here (SW01 must not steal the gateway role).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **L3-switch SVI** inter-VLAN (`ip routing` + `interface vlan N`) | [Cisco-IOS §2.1](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) | — (SW01 stays L2) | 📋 | 📋 *(would need an L3-switch lab)* | 📘 |
| 2.2 | **Routed (no-switchport) interface** | [Cisco-IOS §3.1](../../../Command-Library/Cisco-IOS.md#31--interpret-the-components-of-the-routing-table) | the 1941's routed `/30`s (already routed ports) | 📋 | — | ✅ |

> 🔴 **One `.1` gateway per VLAN at a time** — the 1941 holds the VLAN gateways during the lab; MKT01 owns them in production. Never both at once (duplicate gateway).

---

## 3 — Gaps this page surfaces

- 📋 **L3-switch SVI routing (2.1)** has no Atlas home — SW01 is deliberately L2. A Packet-Tracer twin (a multilayer switch) is the cleanest way to exercise it. **Study/build target.**
- 📋 **No inter-VLAN-routing Concept page** (router-on-a-stick vs L3-switch vs routed port — the three ways, and why Atlas picks router-on-a-stick for the lab / MKT01 for prod).

## Related

- 🔧 Commands: [`Cisco-IOS §2.1`](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) · [`§3.1`](../../../Command-Library/Cisco-IOS.md#31--interpret-the-components-of-the-routing-table) *(mutual links)*.
- 📄 Device: the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) / [Build-Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md).
- 🔧 Playbook: ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md).
- **Sibling:** [`Ch8 — Ethernet VLANs`](Ch08-Implementing-Ethernet-VLANs.md) · [`Ch16 — Static Routes`](Ch16-IPv4-Addressing-and-Static-Routes.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 2.1 (inter-VLAN connectivity) + L3 switching.
- 📒 **Operator notes:** `Trunking DTP VTP.txt` (the router-on-a-stick subinterface template) + the [IP-Addressing-Plan-VLSM](../../../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) (gateways).
- 📄 **Atlas devices:** the 1941 [overlay Build-Guide/Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (real router-on-a-stick) · `ADR-0023` (the 1941/MKT01 inter-VLAN split).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the IP-routing-in-the-LAN chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for inter-VLAN routing, grounded in the real 1941 router-on-a-stick overlay (the ⭐ Playbook) + the Atlas L2/L3 split (SW01 pure-L2; MKT01 owns prod inter-VLAN). Flags the L3-switch-SVI study gap + an inter-VLAN-routing Concept. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
