---
Title: CCNA Ch24 — Understanding Ansible and Terraform (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — gap-marked reverse index for the config-management chapter (objectives 6.1/6.6). Objective → Atlas artifact + build targets. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch24 (Vol 2) — Understanding Ansible and Terraform

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **6.1** (automation impact) + **6.6** (config-management — Ansible/Terraform). Reverse-indexes into [`§6.1`](../../../Command-Library/Cisco-IOS.md#61--how-automation-impacts-network-management) / [`§6.6`](../../../Command-Library/Cisco-IOS.md#66--configuration-management-mechanisms-ansible-terraform).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap · **🖥️** build target.

## On this page
1. [Automation & config-management](#1--automation--config-management)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Automation & config-management

Atlas's stated path: **Oxidized → NetBox → Ansible** (`ADR-0048`) — the exact drift problem this whole audit exists to fix.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | Status |
|---|---|---|---|---|
| 1.1 | **Automation impact** — consistent, versioned, auditable change | [Cisco-IOS §6.1](../../../Command-Library/Cisco-IOS.md#61--how-automation-impacts-network-management) | Oxidized (config backup/diff) | 🟡 → 🖥️ |
| 1.2 | **Ansible** (agentless, push, idempotent) vs **Terraform** (state) | [Cisco-IOS §6.6](../../../Command-Library/Cisco-IOS.md#66--configuration-management-mechanisms-ansible-terraform) | Ansible-from-NetBox (`ADR-0048`, Book 6) | 🟡 → 🖥️ |

---

## 2 — Gaps this page surfaces

- 🖥️ **Build target — stand up Oxidized → NetBox → Ansible** (the operator's stated build; also mentioned trying **Terraform**). An idempotent Ansible run (0-changed on re-run) is the proof. Flips 1.x to ✅.
- 📋 **No IaC Concept page** (idempotence, source-of-truth-driven rendering, drift).

## Related
- 🔧 Commands: [`§6.1`](../../../Command-Library/Cisco-IOS.md#61--how-automation-impacts-network-management) · [`§6.6`](../../../Command-Library/Cisco-IOS.md#66--configuration-management-mechanisms-ansible-terraform) *(mutual links)*.
- **Automation set:** [`Ch22 — SDA`](Ch22-Cisco-Software-Defined-Access.md) · [`Ch23 — REST & JSON`](Ch23-Understanding-REST-and-JSON.md).
- 📋 Decision: [`ADR-0048`](../../../../00-Atlas-Foundation/Decisions/ADR-0048-Automation-and-IaC-Model.md) (the IaC model).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 6.1 / 6.6.
- 📄 **Atlas target:** Oxidized→NetBox→Ansible (`ADR-0048`, Book 6); Terraform (operator wants to try it).
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the Ansible/Terraform chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — gap-marked Vol-2 reverse index for Ansible/Terraform (6.1/6.6): 🖥️ build target = the Oxidized→NetBox→Ansible path (`ADR-0048`) + Terraform. Paraphrased from the public blueprint — no book text (Charter Rule 16). |
