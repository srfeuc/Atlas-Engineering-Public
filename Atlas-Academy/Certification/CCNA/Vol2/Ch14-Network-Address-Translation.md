---
Title: CCNA Ch14 — Network Address Translation (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the NAT chapter (objective 4.1). Objective → Atlas artifact + build targets (📋/🖥️). On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch14 (Vol 2) — Network Address Translation

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it* (and where there's no home yet, the build target). Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **4.1** (inside source NAT — static & pools). Reverse-indexes into [`Cisco-IOS §4.1`](../../../Command-Library/Cisco-IOS.md#41--configure-and-verify-inside-source-nat-static-and-pools).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** Packet-Tracer/lab build target.

## On this page
1. [NAT / PAT](#1--nat--pat)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — NAT / PAT

Where Atlas runs it: **PAT to the internet is FGT01's job** (FortiOS, real). On IOS this is a **study/lab** — a static NAT or PAT on the 1941.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🔧 Playbook | Status |
|---|---|---|---|---|---|
| 1.1 | **Static NAT** (1:1) | [Cisco-IOS §4.1](../../../Command-Library/Cisco-IOS.md#41--configure-and-verify-inside-source-nat-static-and-pools) | — (FGT01 does prod NAT) | 📋 | 🖥️ lab on the 1941 |
| 1.2 | **Dynamic pool + PAT/overload** (many→one) | [Cisco-IOS §4.1](../../../Command-Library/Cisco-IOS.md#41--configure-and-verify-inside-source-nat-static-and-pools) | FGT01 PAT (FortiOS) | 📋 | 🟡 real on FGT01; 📘 on IOS |
| 1.3 | **Verify** — `show ip nat translations` / `statistics` | [Cisco-IOS §4.1](../../../Command-Library/Cisco-IOS.md#41--configure-and-verify-inside-source-nat-static-and-pools) | — | 📋 | 🖥️ with the lab |

---

## 2 — Gaps this page surfaces

- 🖥️ **Build target — a NAT lab on the 1941** (or the Packet-Tracer twin): a static NAT + a PAT overload, verified with `show ip nat translations`. Flips 1.x to ✅. **The 1941 must not NAT in production** (FGT01 owns the edge) — this is a lab overlay.
- 📋 **Playbook needed — "NAT isn't translating."** The classic miss: interfaces not marked `ip nat inside`/`outside`. A clean lab drill.

## Related

- 🔧 Commands: [`Cisco-IOS §4.1`](../../../Command-Library/Cisco-IOS.md#41--configure-and-verify-inside-source-nat-static-and-pools) *(mutual link)*.
- 📄 Perimeter NAT: FGT01 (FortiOS) — the real PAT to the internet.
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objective 4.1.
- 📒 **Operator notes:** `NAT Notes.txt` · `NAT Setup.docx` (static/dynamic/PAT, inside/outside, verify).
- 📄 **Atlas devices:** FGT01 (the real perimeter PAT); the 1941 (the IOS NAT lab target).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the NAT chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for NAT (4.1): FGT01 owns prod PAT; IOS NAT is a 🖥️ lab target on the 1941. Flags the NAT lab + the inside/outside Playbook. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
