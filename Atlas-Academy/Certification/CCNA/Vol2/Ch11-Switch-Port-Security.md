---
Title: CCNA Ch11 — Switch Port Security (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — the **reverse index** for the CCNA port-security chapter. Maps each objective → the Atlas artifact that demonstrates it, and marks the gaps (📋). Sibling of `Ch12` (together = objective 5.7). Built on the locked `Ch12` template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch11 — Switch Port Security

> 🎓 **What this is.** A **reverse index** for one exam chapter: *objective → the real Atlas thing that proves it.* It doesn't teach the topic (that's the Concept) or list the commands (that's the Command-Library) — it's the **map**. Objectives are **paraphrased from the public CCNA 200-301 v1.1 blueprint** and Atlas's own build — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** This chapter = exam objective **5.7** (*Configure and verify Layer 2 security features*), the **port-security** half. It reverse-indexes into [`Command-Library · Cisco-IOS` §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security). *(DHCP snooping + DAI are the sibling — [`Ch12`](Ch12-DHCP-Snooping-and-DAI.md).)*

**Legend:** **✅** demonstrated on a real Atlas device · **🟡** partial / a do-now lab · **📘** study-reference · **📋** gap — no Atlas home yet.

## On this page
1. [Port Security](#1--port-security)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Port Security

Where Atlas runs it: **SW01** (2960X) — unused ports are parked in VLAN 999 and shut; `Gi1/0/3` stays shut (`ADR-0002`), `Gi1/0/7` = Pi01 is never shut. Sticky-MAC + violation modes on the *active* access ports are a sanctioned **do-now lab** (the operator's `Switch Port Security` notes).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **What it does** — bind an access port to a limited set of MACs (stop a rogue device / a CAM-table flood) | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 (unused ports parked/shut) | 📋 *(no Concept)* | — | ✅ |
| 1.2 | **MAC learning** — static vs dynamic vs **sticky** | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [CIS-Hardening-SW01](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) §5 | 📋 | — | 🟡 |
| 1.3 | **Violation modes** — shutdown (err-disable) / restrict / protect | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [CIS-Hardening-SW01](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) §5 | 📋 | — | 🟡 |
| 1.4 | **Configure & verify** — `switchport port-security …`, read `show port-security` | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) §6 | 📋 | — | 🟡 |
| 1.5 | **Recover an err-disabled port** — `errdisable recovery cause psecure-violation` | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | — | 📋 | — | 📘 |

> 🔴 **Atlas reality (1.1):** the estate's live port-security posture is **park-and-shut the unused ports** (VLAN 999 + `shutdown`) plus the two never-touch rules (`Gi1/0/3` shut; `Gi1/0/7` = Pi01 never shut). Adding **sticky-MAC + `violation shutdown`** on the active access ports is the sanctioned do-now lab — flip 1.2–1.4 to ✅ once read back with `show port-security`.

---

## 2 — Gaps this page surfaces

- 📋 **No Layer-2-security Concept page** (shared with [`Ch12`](Ch12-DHCP-Snooping-and-DAI.md)). Port-security's *why* (MAC-flood / rogue-device mitigation, the sticky-MAC trade-off, the violation-mode choice) has no [`Concepts/`](../../../Concepts/README.md) home. **Build target:** the same `Concepts/DHCP-Snooping-and-DAI.md` could broaden to *L2 access-security*, or a dedicated port-security Concept.
- 📋 **No port-security Playbook.** A *"port is err-disabled after a port-security violation"* drill (recover with `errdisable recovery`) is a natural [`Playbooks/`](../../../Playbooks/README.md) build target — the port-security analogue of the DAI Playbook.
- 🟡 **Sticky-MAC + violation modes** are a do-now lab, not yet device-verified — the ✅ flips when read back.

> When these close, the 📋/🟡 above flip — the page *is* the checklist.

## Related

- 🔧 Commands: [`Command-Library · Cisco-IOS` §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) *(the mutual link — commit together, `#44`)*.
- 📄 Device: [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) · [`SW01 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) · [`CIS-Hardening-SW01`](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md).
- **Sibling chapter:** [`Ch12 — DHCP Snooping & DAI`](Ch12-DHCP-Snooping-and-DAI.md) (the other half of objective 5.7).
- 🧭 Overview: [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md).
- Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 5.7 (port security).
- 📒 **Operator notes:** `Switch Port Security.txt` (static/sticky MAC, violation modes, errdisable recovery).
- 📄 **Atlas devices:** [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 · [`CIS-Hardening-SW01`](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) §5 · [`SW01 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) §6.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the port-security chapter.


## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — the **second CCNA cert sub-page**, on the locked `Ch12` template: the reverse index for switch port-security (objective 5.7, port-security half), each paraphrased objective → Command-Library §5.7 + the SW01 posture (parked/shut unused ports; `CIS-Hardening-SW01` §5) + `show port-security`. Marks the sticky-MAC/violation config as a 🟡 do-now lab, and surfaces the 📋 gaps (the shared L2-security Concept + a port-security Playbook). Objectives paraphrased from the public blueprint — no book text (Charter Rule 16). |
