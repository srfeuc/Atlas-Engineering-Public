---
Title: CCNA Ch9 — Spanning Tree Protocol Concepts (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol1
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — the **reverse index** for the STP chapter (objective 2.5). Maps each objective → the Atlas artifact + marks gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch9 (Vol 1) — Spanning Tree Protocol Concepts

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives are **paraphrased from the public CCNA 200-301 v1.1 blueprint** and Atlas's own build — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = exam objective **2.5** (*Interpret basic operations of Rapid PVST+ STP — root/port roles, port states, PortFast, root/loop/BPDU guard*). Reverse-indexes into [`Command-Library · Cisco-IOS` §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol).

**Legend:** **✅** device-real · **🟡** partial / a do-now lab · **📘** study-reference · **📋** gap (a 📋 in the **Playbook** column = *a Playbook is needed to demonstrate this*).

## On this page
1. [STP operation & roles](#1--stp-operation--roles)
2. [Protecting the edge](#2--protecting-the-edge)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — STP operation & roles

Where Atlas runs it: **SW01** runs **Rapid PVST+** and is the intended **root**, with **root guard** on the MKT01 trunk. 🔴 With one switch today a real root election isn't exercised — a second switch (a planned lab-expansion buy) makes it real.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Why STP** — prevent L2 loops / broadcast storms on redundant links | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | — | 📋 | 📋 *(needs a loop / broadcast-storm drill — 2nd switch)* | 📘 |
| 1.2 | **Root bridge / root port** (priority, primary/secondary) | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 (SW01 = root) | 📋 | 📋 *(needs a root-election drill — 2nd switch)* | 🟡 |
| 1.3 | **Port states & roles** (forwarding/blocking; root/designated/alternate) | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) | 📋 | — | 🟡 |

---

## 2 — Protecting the edge

Where Atlas runs it: **SW01** access ports carry **PortFast + BPDU guard**; the MKT01 trunk carries **root guard**.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **PortFast** on single-host access ports | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 | 📋 | — | ✅ |
| 2.2 | **BPDU guard** — err-disable a portfast port that receives a BPDU | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 | 📋 | 📋 *(needs a "switch plugged into an access port → err-disabled" drill)* | ✅ |
| 2.3 | **Root guard / loop guard / BPDU filter** | [Cisco-IOS §2.5](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 3 (`spanning-tree guard root` on `Gi1/0/1`) | 📋 | 📋 *(needs a "MKT01 tries to become root → root-inconsistent" drill)* | 🟡 |

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "a loop / a BPDU-guard err-disable."** Two natural drills: (a) plug a switch into a PortFast+BPDU-guard access port → the port err-disables → recover with `errdisable recovery cause bpduguard`; (b) with a **second switch**, force a root election and break it. Both are **build targets** once the operator adds a second switch (a planned lab-expansion buy).
- 📋 **No STP Concept page** (the "why": the election algorithm, port states, why PortFast+BPDU-guard belong together).
- 🟡 **Root election / port roles** are single-switch today — they flip to ✅ with a second switch (or a Packet-Tracer twin).

## Related

- 🔧 Commands: [`Cisco-IOS §2.5`](../../../Command-Library/Cisco-IOS.md#25--interpret-rapid-pvst-spanning-tree-protocol) *(mutual link — commit together)*.
- 📄 Device: [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) · [`SW01 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md).
- **Sibling chapter:** *RSTP & EtherChannel Configuration* (Ch10) — a forthcoming `Vol1/` sub-page.
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 2.5 (the authoritative objective text).
- 📒 **Operator notes:** `STP.txt` (real commands + the priority/portfast/bpduguard/root-guard examples).
- 📄 **Atlas devices:** [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) (rapid-pvst root, root guard, portfast/bpduguard) · [`SW01 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 1, the STP-concepts chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-1 reverse index for STP concepts (2.5), grounded in SW01's rapid-pvst root + root-guard/portfast/bpduguard. Flags **Playbook build targets** (loop/broadcast-storm + BPDU-guard err-disable + root-inconsistent drills — most need a 2nd switch, a lab-expansion buy). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
