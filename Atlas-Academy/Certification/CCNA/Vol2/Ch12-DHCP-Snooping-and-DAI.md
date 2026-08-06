---
Title: CCNA Ch12 — DHCP Snooping & Dynamic ARP Inspection (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — the **reverse index** for the CCNA L2-security chapter (DHCP snooping + DAI). Maps each objective → the Atlas artifact that demonstrates it, and marks the gaps (📋). **Golden-first sub-page (#44)** — the template for the rest of `Certification/CCNA/`.
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch12 — DHCP Snooping & Dynamic ARP Inspection

> 🎓 **What this is.** A **reverse index** for one exam chapter: *objective → the real Atlas thing that proves it.* It doesn't teach the topic (that's the Concept) or list the commands (that's the Command-Library) — it's the **map** that says "to see DHCP snooping done for real, go here; to verify it, go there; if there's no Atlas home yet, here's the 📋 gap." Objectives are **paraphrased from the public CCNA 200-301 v1.1 blueprint** and Atlas's own build — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** This chapter = exam objective **5.7** (*Configure and verify Layer 2 security features — DHCP snooping, dynamic ARP inspection, and port security*), the **DHCP-snooping + DAI** half. It reverse-indexes into [`Command-Library · Cisco-IOS` §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security). *(Port-security is the sibling chapter — see [Related](#related).)*

**Legend:** **✅** demonstrated on a real Atlas device · **🟡** partial / config present, read-back pending · **📘** study-reference (Atlas doesn't run it yet) · **📋** gap — no Atlas home yet (build target).

## On this page
1. [DHCP Snooping](#1--dhcp-snooping)
2. [Dynamic ARP Inspection (DAI)](#2--dynamic-arp-inspection-dai)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — DHCP Snooping

Where Atlas runs it: **SW01** (2960X) — snooping enabled on the user VLANs, the MKT01/PVE01 trunks trusted.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | The threat it stops — a **rogue/spurious DHCP server** handing out bad gateways/DNS | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | — | 📋 *(no Concept)* | — | 📘 |
| 1.2 | **Trusted vs untrusted** ports + the **snooping binding table** (the table DAI later reads) | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 6 (uplinks `ip dhcp snooping trust`) | 📋 | — | ✅ |
| 1.3 | **Rate-limiting** DHCP messages on untrusted ports | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 6 | 📋 | — | 🟡 |
| 1.4 | **Configure & verify** — `ip dhcp snooping` per VLAN, trust uplinks, read `show ip dhcp snooping` | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) §3 | 📋 | — | ✅ |

> 🔴 **Atlas reality (1.2):** snooping is on for VLANs 10–90; the **MKT01 (`Gi1/0/1`) and PVE01 (`Gi1/0/4`) trunks are `ip dhcp snooping trust`** — a VM that serves DHCP across a trunk needs its uplink trusted or its offers get dropped.

---

## 2 — Dynamic ARP Inspection (DAI)

Where Atlas runs it: **SW01** — DAI live on VLANs **20–90**, validating ARP against the snooping binding table; the inter-switch/hypervisor trunks are DAI-trusted. This is the estate's most-instructive L2 lesson (it once cut DC01 off entirely).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | The threat it stops — **ARP spoofing / gratuitous-ARP** cache poisoning (a man-in-the-middle) | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | — | 📋 *(no Concept)* | [Diagnose-a-Host-Silently-Dropped-by-DAI](../../../Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md) | 📘 |
| 2.2 | **Validating ARP against the snooping bindings** (why DAI ⇐ snooping) | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 6 | 📋 | [Diagnose-a-Host-Silently-Dropped-by-DAI](../../../Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md) | ✅ |
| 2.3 | **Trust on inter-switch / uplink ports** — why a static VM with no binding needs a trusted uplink | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 3 (`ip arp inspection trust` on `Gi1/0/4`) | 📋 | [Diagnose-a-Host-Silently-Dropped-by-DAI](../../../Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md) | ✅ |
| 2.4 | **Configure & verify** — `ip arp inspection vlan …`, read `show ip arp inspection statistics` | [Cisco-IOS §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) | [SW01 Diagnostics](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) §3 | 📋 | [Diagnose-a-Host-Silently-Dropped-by-DAI](../../../Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md) | ✅ |

> 🔴 **Atlas reality (2.3) — the teaching moment:** **DC01** (VLAN 20, static, no snooping binding) was **fully cut off** (couldn't reach its gateway in *or* out) until the PVE01 trunk (`Gi1/0/4`) got `ip arp inspection trust` (device-verified 07-21). You can't snoop VM DHCP across a trunk, so trust the hypervisor uplink. This is the flow DAI protects — see the [east-west flows matrix](../../../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md).

---

## 3 — Gaps this page surfaces

The reverse index doubles as a **gap-finder** — where an objective has no Atlas home yet, that's a build target:

- 📋 **No DHCP-snooping / DAI Concept page.** The Command-Library's §5.7 and this chapter both want a *"why it works"* Concept (the binding-table → DAI dependency; the spurious-server and ARP-spoofing attacks), but none exists under [`Concepts/`](../../../Concepts/README.md) yet (the old "N2" reference has no page). **Build target:** a `Concepts/DHCP-Snooping-and-DAI.md` grounded in the DC01-dropped-by-DAI incident. *(Recorded in Backlog #44.)*
- 🟡 **Rate-limiting (1.3)** is authored in the Build-Guide but not device-verified — flip to ✅ when read back.

> When these close, the 📋/🟡 above flip — the page *is* the checklist.

## Related

- 🔧 Commands: [`Command-Library · Cisco-IOS` §5.7](../../../Command-Library/Cisco-IOS.md#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) *(the mutual link — commit together, `#44`)*.
- 📄 Device: [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) · [`SW01 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md).
- 🔧 Playbook: [`Diagnose-a-Host-Silently-Dropped-by-DAI`](../../../Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md).
- 🧭 Overview / front-door: [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md).
- **Sibling chapter:** [`Ch11 — Switch Port Security`](Ch11-Switch-Port-Security.md) (the port-security half of objective 5.7).
- Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) (the Academy Documentation Standard).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 5.7 (DHCP snooping + DAI).
- 📒 **Operator notes:** `Switch Port Security.txt` (the DHCP-snooping + DAI config/verify sections).
- 📄 **Atlas devices:** [`SW01 Build-Guide`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Steps 3/6 · [`SW01 Diagnostics`](../../../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) §3.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the DHCP-snooping/ARP-inspection chapter.


## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — the **golden-first CCNA cert sub-page**: the reverse index for the DHCP-snooping + DAI chapter (objective 5.7), each paraphrased objective → Command-Library §5.7 + the SW01 Build-Guide/Diagnostics + the DAI Playbook, grounded in the real SW01 build (snooping VLANs 10–90, DAI 20–90, the DC01-dropped-by-DAI trust lesson). Surfaces the 📋 **no DHCP-snooping/DAI Concept** gap. Objectives paraphrased from the public blueprint — no book text (Charter Rule 16). Template for the rest of `Certification/CCNA/`. |
