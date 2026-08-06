---
Title: CCNA Ch19 — WAN Architecture (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the WAN-architecture chapter (objectives 1.2/5.5). Objective → Atlas artifact + gaps. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch19 (Vol 2) — WAN Architecture

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **1.2** (WAN topology) + **5.5** (IPsec VPNs — S2S / remote-access). Reverse-indexes into [`§1.2`](../../../Command-Library/Cisco-IOS.md#12--describe-characteristics-of-network-topology-architectures) / [`§5.5`](../../../Command-Library/Cisco-IOS.md#55--ipsec-remote-access-and-site-to-site-vpns).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap.

## On this page
1. [WAN & VPN](#1--wan--vpn)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — WAN & VPN

🔴 **Mostly study-only** — Atlas's WAN edge is the home internet uplink at FGT01; VPN = FGT01 IPsec (FortiOS). MPLS/Metro-E/leased-line are reading topics.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **WAN options** — internet, MPLS, leased line, broadband | [Cisco-IOS §1.2](../../../Command-Library/Cisco-IOS.md#12--describe-characteristics-of-network-topology-architectures) | the FGT01 internet edge (the one real WAN link) | 📘 |
| 1.2 | **IPsec VPN** — site-to-site vs remote-access | [Cisco-IOS §5.5](../../../Command-Library/Cisco-IOS.md#55--ipsec-remote-access-and-site-to-site-vpns) | FGT01 IPsec (FortiOS); Azure S2S (roadmap) | 📘 |

---

## 2 — Gaps this page surfaces

- 📘 **WAN technologies (MPLS/leased-line/PPPoE)** are study/simulator topics — the operator's WAN lesson PDFs cover the *why*. An **Azure site-to-site VPN** (roadmap) is the real S2S build target.
- 📋 **No WAN/VPN Concept page.**

## Related
- 🔧 Commands: [`§1.2`](../../../Command-Library/Cisco-IOS.md#12--describe-characteristics-of-network-topology-architectures) · [`§5.5`](../../../Command-Library/Cisco-IOS.md#55--ipsec-remote-access-and-site-to-site-vpns) *(mutual links)*.
- 📄 Edge: FGT01 (the internet WAN link + IPsec).
- **Sibling:** [`Ch18 — LAN Architecture`](Ch18-LAN-Architecture.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 1.2 / 5.5.
- 📒 **Operator notes:** the WAN lesson PDFs (VPN / Leased-Lines / MPLS / PPPoE / WAN-Topology — operator-side, for the *why*).
- 📄 **Atlas devices:** FGT01 (the internet WAN link + IPsec); Azure S2S (roadmap).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the WAN-architecture chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for WAN architecture (1.2/5.5): FGT01 internet edge + IPsec; MPLS/leased-line study-only; Azure S2S as the roadmap build. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
