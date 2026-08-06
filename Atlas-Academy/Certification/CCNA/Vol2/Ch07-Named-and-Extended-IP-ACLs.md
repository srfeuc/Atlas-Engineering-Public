---
Title: CCNA Ch7 — Named and Extended IP ACLs (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the extended/named-ACL chapter (objective 5.6). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch7 (Vol 2) — Named and Extended IP ACLs

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **5.6** (ACLs — the *extended + named* half). Reverse-indexes into [`Cisco-IOS §5.6`](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [Extended & named ACLs](#1--extended--named-acls)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Extended & named ACLs

Where Atlas runs it: the **1941 CCNA overlay** — `ip access-list extended CLIENTS-TO-SERVERS` permits VLAN 50 → VLAN 20 on **443 only**, denies other client→server, applied **inbound on `Gi0/0.50`**.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Extended ACL — the 5-tuple** (protocol, src, dst, port) | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) §6 Stage 4 | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |
| 1.2 | **Named ACLs** + sequence numbers | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (`CLIENTS-TO-SERVERS`) | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |
| 1.3 | **Placement** — inbound, near the source | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) §6 Stage 4 | 📋 | — | ✅ |

> 🔴 **Atlas trap (`015`):** a failed **ping** to a 443-only host doesn't mean 443 is blocked — ICMP hits the `deny ip`, not the `permit tcp … eq 443`. Prove the *real* protocol.

---

## 2 — Gaps this page surfaces

- 📋 **No ACL Concept page** (shared with Ch6/Ch8) — extended-vs-standard, the 5-tuple, the `015` ping-vs-service trap.
- The demonstrating Playbook is **🟡 until the overlay runs on hardware** (pattern authored to real Atlas VLANs/flows).

## Related

- 🔧 Commands: [`Cisco-IOS §5.6`](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) *(mutual link)*.
- 📄 Device: the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) · the [flows matrix](../../../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) (what the extended ACL enforces).
- 🔧 Playbook: ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md).
- **Sibling:** [`Ch6 — Basic IPv4 ACLs`](Ch06-Basic-IPv4-Access-Control-Lists.md) · [`Ch8 — Applied IP ACLs`](Ch08-Applied-IP-ACLs.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 5.6 (extended/named ACLs).
- 📒 **Operator notes:** `ACL Access control list.txt`.
- 📄 **Atlas devices:** the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (the real extended named ACL `CLIENTS-TO-SERVERS`, 443-only, inbound-near-source) + the [flows matrix](../../../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the named/extended-ACLs chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for extended/named ACLs (5.6), grounded in the 1941-overlay `CLIENTS-TO-SERVERS` extended ACL (443-only, inbound-near-source) + the `015` ping-vs-service trap. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
