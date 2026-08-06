---
Title: CCNA Ch10 — RSTP and EtherChannel Configuration (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the RSTP-config + EtherChannel chapter (objectives 2.5/2.4). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch10 (Vol 1) — RSTP and EtherChannel Configuration

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **2.5** (Rapid PVST+ config) + **2.4** (EtherChannel/LACP). Reverse-indexes into [`Cisco-IOS §2.5`](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) + [`§2.4`](../../../Command-Library/Cisco-IOS.md#24--configure-and-verify-etherchannel-lacp).

**Legend:** **✅** device-real · **🟡** partial / do-now lab · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [Rapid PVST+ configuration](#1--rapid-pvst-configuration)
2. [EtherChannel (LACP)](#2--etherchannel-lacp)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — Rapid PVST+ configuration

Where Atlas runs it: **SW01** runs `spanning-tree mode rapid-pvst` as the root.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | Set the **mode + root** (`rapid-pvst`, priority) | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 | 📋 | 📋 *(root-election drill — 2nd switch)* | 🟡 |
| 1.2 | Read it back — `show spanning-tree` (roles/states) | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) | 📋 | — | 🟡 |

---

## 2 — EtherChannel (LACP)

🔴 **Build gap — Atlas has no bundle today.** EtherChannel needs a second switch + two links (the owned **SG300** could host it, but runs Small-Business OS, not exam-accurate IOS). A planned lab-expansion buy / Packet-Tracer twin closes it.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | Bundle links with **LACP** (`channel-group N mode active`) | [Cisco-IOS §2.4](../../../Command-Library/Cisco-IOS.md#24--configure-and-verify-etherchannel-lacp) | — | 📋 | 📋 *(mode-mismatch drill — 2nd switch)* | 📘 |
| 2.2 | Verify — `show etherchannel summary`, `show lacp neighbor` | [Cisco-IOS §2.4](../../../Command-Library/Cisco-IOS.md#24--configure-and-verify-etherchannel-lacp) | — | 📋 | — | 📘 |

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "EtherChannel won't bundle."** The classic mode-mismatch (`active`↔`passive` OK, `passive`↔`passive` never forms; member speed/VLAN mismatch). **Build target** once a second switch (or Packet-Tracer twin) exists.
- 📋 **Playbook needed — the STP root election** (shared with Ch9) — a real election + break needs a second switch.
- 📘 **EtherChannel is entirely a build gap** until the second switch lands — flip 2.x to ✅ then.

## Related

- 🔧 Commands: [`Cisco-IOS §2.5`](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) · [`§2.4`](../../../Command-Library/Cisco-IOS.md#24--configure-and-verify-etherchannel-lacp) *(mutual links)*.
- 📄 Device: [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md).
- **Sibling:** [`Ch9 — STP Concepts`](Ch09-Spanning-Tree-Protocol-Concepts.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 2.4 / 2.5.
- 📒 **Operator notes:** `STP.txt` · `Etherchannel.txt` (modes, load-balance, LACP hot-standby).
- 📄 **Atlas devices:** [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) (rapid-pvst root).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the RSTP/EtherChannel-configuration chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for RSTP config (2.5, SW01 real) + EtherChannel (2.4, 📘 build gap — no bundle; needs a 2nd switch/SG300). Flags EtherChannel-won't-bundle + root-election Playbook targets. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
