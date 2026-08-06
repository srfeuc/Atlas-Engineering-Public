---
Title: CCNA Ch22 — Cisco Software-Defined Access (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the SDA chapter (objectives 6.2/6.3). Objective → Atlas artifact + build targets. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch22 (Vol 2) — Cisco Software-Defined Access

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **6.2** (traditional vs controller-based) + **6.3** (SDN architecture — overlay/underlay/fabric, control/data plane, N/S-bound APIs). Reverse-indexes into [`§6.2`](../../../Command-Library/Cisco-IOS.md#62--traditional-vs-controller-based-networking) / [`§6.3`](../../../Command-Library/Cisco-IOS.md#63--controller-based-software-defined-architecture-overlay-underlay-fabric).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap.

## On this page
1. [SDN / SDA](#1--sdn--sda)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — SDN / SDA

🔴 **Concept-only in Atlas** — the estate is traditional CLI (no controller). Study contrast only.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **Traditional vs controller-based** networking | [Cisco-IOS §6.2](../../../Command-Library/Cisco-IOS.md#62--traditional-vs-controller-based-networking) | Atlas = traditional CLI (the contrast) | 📘 |
| 1.2 | **Control vs data plane; overlay/underlay/fabric** | [Cisco-IOS §6.3](../../../Command-Library/Cisco-IOS.md#63--controller-based-software-defined-architecture-overlay-underlay-fabric) | — | 📘 |
| 1.3 | **Northbound vs southbound APIs** | [Cisco-IOS §6.3](../../../Command-Library/Cisco-IOS.md#63--controller-based-software-defined-architecture-overlay-underlay-fabric) | (NetBox northbound = the closest analogue) | 📘 |

---

## 2 — Gaps this page surfaces

- 📘 **No controller in Atlas** — SDA/DNA Center is study-only (a simulator/reading topic). The estate's *own* automation path (Oxidized→NetBox→Ansible, `ADR-0048`) is the traditional-side contrast — see [`Ch24`](Ch24-Understanding-Ansible-and-Terraform.md).
- 📋 **No SDN Concept page.**

## Related
- 🔧 Commands: [`§6.2`](../../../Command-Library/Cisco-IOS.md#62--traditional-vs-controller-based-networking) · [`§6.3`](../../../Command-Library/Cisco-IOS.md#63--controller-based-software-defined-architecture-overlay-underlay-fabric) *(mutual links)*.
- **Automation set:** [`Ch23 — REST & JSON`](Ch23-Understanding-REST-and-JSON.md) · [`Ch24 — Ansible & Terraform`](Ch24-Understanding-Ansible-and-Terraform.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 6.2 / 6.3.
- 📄 **Atlas contrast:** the traditional-CLI estate; NetBox (a northbound API analogue) via `ADR-0048`.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the SDA chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for SDA (6.2/6.3): 📘 concept-only (Atlas is traditional CLI); the Oxidized→NetBox→Ansible path is the real-side contrast. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
