---
Title: CCNA Ch23 — Understanding REST and JSON (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the REST/JSON chapter (objectives 6.5/6.7). Objective → Atlas artifact + build targets. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch23 (Vol 2) — Understanding REST and JSON

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **6.5** (REST APIs) + **6.7** (JSON). Reverse-indexes into [`§6.5`](../../../Command-Library/Cisco-IOS.md#65--characteristics-of-rest-based-apis) / [`§6.7`](../../../Command-Library/Cisco-IOS.md#67--components-of-json-encoded-data).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** build target.

## On this page
1. [REST & JSON](#1--rest--json)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — REST & JSON

Where Atlas will run it: the **NetBox** and **FortiOS** REST APIs are real, `curl`-able endpoints (once NetBox/CNT01 are built).

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **REST characteristics** — HTTP verbs = CRUD, auth, stateless | [Cisco-IOS §6.5](../../../Command-Library/Cisco-IOS.md#65--characteristics-of-rest-based-apis) | NetBox / FortiOS API | 🟡 → 🖥️ |
| 1.2 | **Data encoding** — JSON (objects/arrays/scalars) | [Cisco-IOS §6.7](../../../Command-Library/Cisco-IOS.md#67--components-of-json-encoded-data) | a NetBox/FortiOS API response | 🟡 → 🖥️ |

---

## 2 — Gaps this page surfaces

- 🖥️ **Build target — `curl` the NetBox / FortiOS API** (after NetBox/CNT01): a `GET` with a token → a JSON body → parse with `jq`. Flips 1.x to ✅.
- 📋 **No REST/JSON Concept page.**

## Related
- 🔧 Commands: [`§6.5`](../../../Command-Library/Cisco-IOS.md#65--characteristics-of-rest-based-apis) · [`§6.7`](../../../Command-Library/Cisco-IOS.md#67--components-of-json-encoded-data) *(mutual links)*.
- **Automation set:** [`Ch22 — SDA`](Ch22-Cisco-Software-Defined-Access.md) · [`Ch24 — Ansible & Terraform`](Ch24-Understanding-Ansible-and-Terraform.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 6.5 / 6.7.
- 📄 **Atlas target:** the NetBox + FortiOS REST APIs (`ADR-0048`).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the REST/JSON chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for REST/JSON (6.5/6.7): 🖥️ build target = curling the real NetBox/FortiOS APIs (after NetBox). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
