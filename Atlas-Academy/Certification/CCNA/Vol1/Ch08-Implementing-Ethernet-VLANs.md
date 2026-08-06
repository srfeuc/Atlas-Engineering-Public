---
Title: CCNA Ch8 — Implementing Ethernet VLANs (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — the **reverse index** for the VLANs + trunking chapter (objectives 2.1/2.2). Maps each objective → the Atlas artifact + marks gaps (📋). On the locked `Vol2/Ch12` template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch8 (Vol 1) — Implementing Ethernet VLANs

> 🎓 **What this is.** A **reverse index** for one exam chapter: *objective → the real Atlas thing that proves it.* Objectives are **paraphrased from the public CCNA 200-301 v1.1 blueprint** and Atlas's own build — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = exam objectives **2.1** (*VLANs — access ports, default VLAN, inter-VLAN connectivity*) + **2.2** (*interswitch connectivity — trunks, 802.1Q, native VLAN*). Reverse-indexes into [`Command-Library · Cisco-IOS` §2.1](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) / [§2.2](../../../Command-Library/Cisco-IOS.md#22--configure-and-verify-interswitch-connectivity-trunks-8021q-native-vlan).

**Legend:** **✅** demonstrated on a real Atlas device · **🟡** partial / a do-now lab · **📘** study-reference · **📋** gap — no Atlas home yet (a 📋 in the **Playbook** column = *a Playbook is needed to demonstrate this*).

## On this page
1. [VLANs](#1--vlans)
2. [Trunking](#2--trunking)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — VLANs

Where Atlas runs it: **SW01** — nine zone VLANs 10–90 + 999, access ports carrying one VLAN each.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Create VLANs + assign access ports** (data VLAN) | [Cisco-IOS §2.1](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Steps 2/4 | 📋 | 📋 *(needs a "port in the wrong VLAN" drill)* | ✅ |
| 1.2 | **Default VLAN / parking** — unused ports → VLAN 999 + shut | [Cisco-IOS §2.1](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 | 📋 | — | ✅ |
| 1.3 | **Voice VLAN** (data + voice on one access port) | [Cisco-IOS §2.1](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) | — | 📋 | 📋 | 📘 *(no IP phones in Atlas)* |
| 1.4 | **Inter-VLAN connectivity** — routing between VLANs | [Cisco-IOS §2.1](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (router-on-a-stick) | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |

---

## 2 — Trunking

Where Atlas runs it: **SW01** — `Gi1/0/1` → MKT01 and `Gi1/0/4` → PVE01, both 802.1Q, **native VLAN 999**, allowed 10–90,999.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **Configure a trunk** — `switchport mode trunk`, allowed-VLAN list | [Cisco-IOS §2.2](../../../Command-Library/Cisco-IOS.md#22--configure-and-verify-interswitch-connectivity-trunks-8021q-native-vlan) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 3 | 📋 | 📋 *(needs a "trunk didn't form / VLAN missing" drill)* | ✅ |
| 2.2 | **802.1Q tagging + native VLAN** (native 999, the 2960X is 802.1Q-only) | [Cisco-IOS §2.2](../../../Command-Library/Cisco-IOS.md#22--configure-and-verify-interswitch-connectivity-trunks-8021q-native-vlan) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 3 | 📋 | 📋 *(needs a "native-VLAN mismatch" drill)* | ✅ |

> 🔴 **Atlas reality:** the SW01↔PVE01 native-VLAN-10→999 change once black-holed a tagged-VLAN-10 VM until PVE01 tagged its own management — the estate's native-VLAN lesson (a strong **Playbook** candidate, see §3).

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "a VLAN/trunk isn't carrying traffic."** The operator's `VLAN Troubleshooting and Commands` notes + the real **native-VLAN-999 asymmetry** incident (a tagged-VLAN-10 VM losing return traffic) are a ready-made drill: `show vlan brief` / `show interfaces trunk` → native mismatch / missing allowed-VLAN / wrong access VLAN. **Build target** when the operator runs the lab.
- 📋 **No VLAN/trunking Concept page** (the "why": broadcast domains, tagging, native-VLAN security).
- 📘 **Voice VLAN (1.3)** — no IP phones in Atlas; simulator/study only.

## Related

- 🔧 Commands: [`Cisco-IOS §2.1`](../../../Command-Library/Cisco-IOS.md#21--configure-and-verify-vlans-normal-range-spanning-switches) · [`§2.2`](../../../Command-Library/Cisco-IOS.md#22--configure-and-verify-interswitch-connectivity-trunks-8021q-native-vlan) *(mutual links — commit together)*.
- 📄 Device: [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) · the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md).
- 🔧 Playbook: ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) (router-on-a-stick).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 2.1 / 2.2 (the authoritative objective text).
- 📒 **Operator notes:** `Trunking DTP VTP.txt` · `VLAN Troubleshooting and Commands.txt` (real commands + worked examples).
- 📄 **Atlas devices:** [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) (VLANs 10–90/999, native-999 trunks) · the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the Ethernet-VLANs chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for VLANs + trunking (2.1/2.2), grounded in SW01's real VLANs 10–90/999 + the native-999 trunks + the 1941 router-on-a-stick overlay. Flags a **Playbook build target** (VLAN/trunk-not-carrying, from the operator's notes + the native-VLAN incident). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
