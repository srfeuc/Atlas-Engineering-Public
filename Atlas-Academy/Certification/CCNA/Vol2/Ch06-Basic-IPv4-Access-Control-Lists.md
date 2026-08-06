---
Title: CCNA Ch6 — Basic IPv4 Access Control Lists (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the standard-ACL chapter (objective 5.6). Objective → Atlas artifact + gaps (📋). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch6 (Vol 2) — Basic IPv4 Access Control Lists

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — **never** copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **5.6** (ACLs — the *standard numbered* half). Reverse-indexes into [`Cisco-IOS §5.6`](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap (📋 in **Playbook** col = *a Playbook is needed to demonstrate this*).

## On this page
1. [Standard numbered ACLs](#1--standard-numbered-acls)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Standard numbered ACLs

Where Atlas runs it: the **1941 CCNA overlay** — `access-list 10 deny 10.70.0.0 0.0.0.15` / `permit any`, applied **outbound on `Gi0/0.20`** (Testing→Servers denied).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🎓 Concept | 🔧 Playbook | Status |
|---|---|---|---|---|---|---|
| 1.1 | **Match source only** — a standard numbered ACL | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) §6 Stage 3 | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |
| 1.2 | **Wildcard masks** (`/28` → `0.0.0.15`) | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (Common Mistakes) | 📋 | — | ✅ |
| 1.3 | **Placement** — outbound, near the destination | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) §6 Stage 3 | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |
| 1.4 | **Verify** — `show access-lists` (order + match counts) | [Cisco-IOS §5.6](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) | the 1941 [overlay Build-Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md) (SS-05/06) | 📋 | ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) | ✅ |

> 🔴 **Atlas traps:** **wildcard, not subnet mask**; the invisible **implicit `deny any`** (why ACL 10 needs `permit any`); a standard ACL placed near the *source* over-blocks.

---

## 2 — Gaps this page surfaces

- 📋 **No ACL Concept page** (the "why": standard-vs-extended, wildcard bits, implicit deny, placement logic).
- The demonstrating Playbook (⭐ Set-Up-the-1941) is **🟡 until the operator runs the overlay on hardware** — the ✅ above are pattern-authored to real Atlas VLANs; they confirm on the read-back.

## Related

- 🔧 Commands: [`Cisco-IOS §5.6`](../../../Command-Library/Cisco-IOS.md#56--configure-and-verify-access-control-lists-acls) *(mutual link)*.
- 📄 Device: the 1941 [overlay Build-Guide](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) / [Build-Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Record-CCNA-Lab-Overlay.md).
- 🔧 Playbook: ⭐ [Set-Up-the-1941-for-the-CCNA-Lab](../../../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md).
- **Sibling:** [`Ch7 — Named & Extended IP ACLs`](Ch07-Named-and-Extended-IP-ACLs.md) · [`Ch8 — Applied IP ACLs`](Ch08-Applied-IP-ACLs.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 5.6 (standard ACLs).
- 📒 **Operator notes:** `ACL Access control list.txt` · `ACL Example Configure Numbered Standard IPv4 ACLs.txt`.
- 📄 **Atlas devices:** the 1941 [overlay Build-Guide/Record](../../../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) (the real standard ACL 10, wildcard, placement, match-count proof) + the [flows matrix](../../../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the basic-IPv4-ACLs chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for standard ACLs (5.6), grounded in the 1941-overlay standard ACL 10 (wildcard, placement outbound-near-destination, match-count verify) + the wildcard/implicit-deny traps. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
