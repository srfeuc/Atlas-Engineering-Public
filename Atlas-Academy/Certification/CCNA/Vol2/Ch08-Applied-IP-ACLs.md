---
Title: CCNA Ch8 — Applied IP ACLs (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the applied/troubleshooting-ACL chapter (objective 5.6). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch8 (Vol 2) — Applied IP ACLs

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **5.6** (ACLs — *placement, common applications, troubleshooting*). Reverse-indexes into [`Cisco-IOS §5.6`](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [Applying & protecting](#1--applying--protecting)
2. [Troubleshooting an ACL](#2--troubleshooting-an-acl)
3. [Gaps this page surfaces](#3--gaps-this-page-surfaces)

---

## 1 — Applying & protecting

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Direction & location** — in/out; standard near dest, extended near source | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) §6 | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |
| 1.2 | **Protect the management plane** — a `vty` `access-class` ACL | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | [CIS-Hardening-1941](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) (vty `MGMT-SSH` on 0-4 & 5-15) | 📋 | — | ✅ |

---

## 2 — Troubleshooting an ACL

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 2.1 | **Order matters + the implicit `deny any`** | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (Common Mistakes) | 📋 | 📋 *(an "ACL blocks legit traffic / wrong order" drill)* | 🟡 |
| 2.2 | **Read the match counts** — `show access-lists` before/after | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md) (SS-05..09) | 📋 | 📋 *(same drill)* | ✅ |

> 🔴 **The test matrix in the overlay Playbook is 90% of this drill already** — it exercises deny/permit and reads the match-count delta. A dedicated *"a legit flow is being dropped — which ACL line?"* Playbook is the natural build target.

---

## 3 — Gaps this page surfaces

- 📋 **Playbook needed — "an ACL is blocking legitimate traffic."** Diagnose by reading `show access-lists` match counts + the line order (the implicit deny). The overlay test matrix is the seed. **Build target** when the operator runs the lab.
- 📋 **No ACL Concept page** (shared with Ch6/Ch7).

## Related

- 🔧 Commands: [`Cisco-IOS §5.6`](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) *(mutual link)*.
- 📄 Device: the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) / [Build-Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md) · [CIS-Hardening-1941](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) (vty ACL).
- 🔧 Playbook: ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) · [Trace-a-Blocked-Flow](../../../Playbooks/Trace-a-Blocked-Flow.md).
- **Sibling:** [`Ch6 — Basic IPv4 ACLs`](Ch06-Basic-IPv4-Access-Control-Lists.md) · [`Ch7 — Named & Extended IP ACLs`](Ch07-Named-and-Extended-IP-ACLs.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 5.6 (applying/troubleshooting ACLs).
- 📒 **Operator notes:** `ACL Access control list.txt` (placement, verify-then-test-then-count method).
- 📄 **Atlas devices:** the 1941 [overlay Build-Guide/Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (placement + match-count method) · [CIS-Hardening-1941](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) (the real vty `MGMT-SSH` access-class).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the applied-IP-ACLs chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for applied/troubleshooting ACLs (5.6): placement, the real vty `MGMT-SSH` access-class, order/implicit-deny, the match-count read-back. Flags the "ACL blocks legit traffic" Playbook target (overlay test matrix is the seed). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
