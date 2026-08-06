---
Title: CCNA Ch16 — IPv4 Addressing and Static Routes (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the router IPv4-addressing + static-routing chapter (objectives 1.6/3.3). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch16 (Vol 1) — IPv4 Addressing and Static Routes

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **1.6** (IPv4 addressing on interfaces) + **3.3** (static / default / floating routes). Reverse-indexes into [`Cisco-IOS §1.6`](../../../Command-Library/Cisco-IOS.md#16--configure-and-verify-ipv4-addressing-and-subnetting) + [`§3.3`](../../../Command-Library/Cisco-IOS.md#33--configure-and-verify-ipv4-and-ipv6-static-routing).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [IPv4 addressing on a router](#1--ipv4-addressing-on-a-router)
2. [Static routing](#2--static-routing)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — IPv4 addressing on a router

Where Atlas runs it: **1941** — two transit `/30`s (`10.255.255.2` / `.5`) + a loopback `/32` (`10.255.0.1`).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Assign an IPv4 address + mask** to an interface (`ip address`, `no shutdown`) | [Cisco-IOS §1.6](../../../Command-Library/Cisco-IOS.md#16--configure-and-verify-ipv4-addressing-and-subnetting) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 2 | 📋 | — | ✅ |
| 1.2 | **Verify** — `show ip interface brief` (up/up + address) | [Cisco-IOS §1.6](../../../Command-Library/Cisco-IOS.md#16--configure-and-verify-ipv4-addressing-and-subnetting) | [1941 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) §2 | 📋 | — | ✅ |
| 1.3 | **A loopback** as a stable address (router-id) | [Cisco-IOS §1.6](../../../Command-Library/Cisco-IOS.md#16--configure-and-verify-ipv4-addressing-and-subnetting) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 2 | 📋 | — | ✅ |

---

## 2 — Static routing

Where Atlas runs it: **1941** — the real default `ip route 0.0.0.0 0.0.0.0 10.255.255.1` (→ FGT01), plus a floating AD-250 backup on the MKT01 leg.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **Network / default / host route** (`ip route …`) | [Cisco-IOS §3.3](../../../Command-Library/Cisco-IOS.md#33--configure-and-verify-ipv4-and-ipv6-static-routing) | [1941 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 | 📋 | 📋 *(a "traffic blackholes — missing default / wrong static" drill)* | ✅ |
| 2.2 | **Floating static** (higher AD as a dormant backup) | [Cisco-IOS §3.3](../../../Command-Library/Cisco-IOS.md#33--configure-and-verify-ipv4-and-ipv6-static-routing) | [1941 Considerations](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) (single-homed caveat) | 📋 | — | 🟡 |
| 2.3 | **Verify** — `show ip route [static]` (`S*` default, AD/metric) | [Cisco-IOS §3.3](../../../Command-Library/Cisco-IOS.md#33--configure-and-verify-ipv4-and-ipv6-static-routing) | [1941 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) §3 | 📋 | — | ✅ |

> 🔴 **Atlas reality (2.2):** egress is **single-homed** to FGT01 — a floating static for the *default* buys nothing; it only helps as the AD-250 OSPF backup on the MKT01 leg, and rides the same cable (guards an OSPF-process failure, not a link failure — be honest, `POL-0013`).

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "traffic to the internet blackholes."** Missing `default-information originate` / a wrong static / no gateway-of-last-resort → `show ip route` has no `S*`. A natural drill on the 1941. **Build target.**
- 📋 **No static-routing/AD Concept page** (the "why": longest-match → AD → metric; why a floating static floats).

## Related

- 🔧 Commands: [`Cisco-IOS §1.6`](../../../Command-Library/Cisco-IOS.md#16--configure-and-verify-ipv4-addressing-and-subnetting) · [`§3.3`](../../../Command-Library/Cisco-IOS.md#33--configure-and-verify-ipv4-and-ipv6-static-routing) *(mutual links)*.
- 📄 Device: [`1941 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) · [`1941 Build-Checklist`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) · [`1941 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md).
- **Sibling:** [`Ch17 — IP Routing in the LAN`](Ch17-IP-Routing-in-the-LAN.md) (inter-VLAN routing).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 1.6 / 3.3.
- 📒 **Operator notes:** `Static Routes.txt` (network/default/host/floating, AD, permanent, recursive-lookup) · `Basic Configuring Router Commands.txt`.
- 📄 **Atlas devices:** [`1941 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) / [`Build-Checklist`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) / [`Considerations`](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) (real transit /30s, loopback, default + floating-static caveat).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the IPv4-addressing/static-routes chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for router IPv4 addressing (1.6) + static routing (3.3), grounded in the real 1941 transit /30s, loopback, default route, and the honest single-homed floating-static caveat. Flags a blackhole Playbook target. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
