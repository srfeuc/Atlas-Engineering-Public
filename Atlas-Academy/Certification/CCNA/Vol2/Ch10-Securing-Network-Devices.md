---
Title: CCNA Ch10 — Securing Network Devices (reverse index)
Path: Atlas-Academy/Certification/CCNA/Vol2
Status: 🟢 CERT SUB-PAGE (`ADR-0053` §5) — reverse index for the device-hardening chapter (objectives 5.3/5.4). Objective → Atlas artifact + gaps. On the locked template (#44).
Version: 0.1
Date: 2026-08-05
---

# CCNA Ch10 (Vol 2) — Securing Network Devices

> 🎓 **What this is.** A **reverse index**: *objective → the real Atlas thing that proves it.* Objectives **paraphrased from the public CCNA 200-301 v1.1 blueprint** — never copied from any book (Charter Rule 16).

> **Chapter → blueprint → library.** = **5.3** (device access control — local passwords) + **5.4** (password policy — complexity, MFA, certs). Reverse-indexes into [`§5.3`](../../../Command-Library/Cisco-IOS.md#53--device-access-control-using-local-passwords) / [`§5.4`](../../../Command-Library/Cisco-IOS.md#54--password-policy-elements-complexity-mfa-certificates-biometrics).

**Legend:** **✅** device-real · **🟡** partial · **📘** study-reference · **📋** gap.

## On this page
1. [Local device access control](#1--local-device-access-control)
2. [Gaps this page surfaces](#2--gaps-this-page-surfaces)

---

## 1 — Local device access control

Where Atlas runs it: **1941 / SW01** — `ciscoadmin` priv 15 (`secret 9`), `enable secret`, `service password-encryption`, login throttling, SSH-only — with the one local break-glass never centralized.

| # | Objective (paraphrased) | 🔧 Command-Library | 📄 Device artifact | 🔧 Playbook | Status |
|---|---|---|---|---|---|
| 1.1 | **Enable secret + named local user** (Type-9, no generic) | [Cisco-IOS §5.3](../../../Command-Library/Cisco-IOS.md#53--device-access-control-using-local-passwords) | [CIS-Hardening-1941](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) · [CIS-Hardening-SW01](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) | [Recover-a-Locked-Out-Router-Out-of-Band](../../../Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md) | ✅ |
| 1.2 | **Login throttling** (`login block-for …`) | [Cisco-IOS §5.3](../../../Command-Library/Cisco-IOS.md#53--device-access-control-using-local-passwords) | [CIS-Hardening-1941](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) §2 | — | ✅ |
| 1.3 | **Password-policy elements** — complexity, MFA, certs (AD-side) | [Cisco-IOS §5.4](../../../Command-Library/Cisco-IOS.md#54--password-policy-elements-complexity-mfa-certificates-biometrics) | `STD-0001` + AD PSOs / Entra MFA / AD CS | 📘 |

> 🔴 **Never PKI-ify / centralize the one local break-glass account** — the box must stay reachable if AD/RADIUS is down.

---

## 2 — Gaps this page surfaces

- 📋 **Playbook exists** — [Recover-a-Locked-Out-Router-Out-of-Band](../../../Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md) is the break-glass drill for this objective (✅).
- 📋 **No credential-policy Concept** on the IOS side (the AD-side `STD-0001`/PSO layer is the home).

## Related
- 🔧 Commands: [`§5.3`](../../../Command-Library/Cisco-IOS.md#53--device-access-control-using-local-passwords) · [`§5.4`](../../../Command-Library/Cisco-IOS.md#54--password-policy-elements-complexity-mfa-certificates-biometrics) *(mutual links)*.
- 📄 Device: [`CIS-Hardening-1941`](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) · [`CIS-Hardening-SW01`](../../../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md).
- 🔧 Playbook: [Recover-a-Locked-Out-Router-Out-of-Band](../../../Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md).
- **Sibling:** [`Ch9 — Security Architectures`](Ch09-Security-Architectures.md).
- 🧭 [`Atlas-Certification-Lab-Map`](../../Atlas-Certification-Lab-Map.md) · the [Certification index](../../README.md). Governed by [`ADR-0053`](../../../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md).

## Sources
- 📘 **Public blueprint:** CCNA 200-301 v1.1 — objectives 5.3 / 5.4.
- 📒 **Operator notes:** `Security script.txt` · `Basic Configuring Router Commands.txt` (enable/secret/line config).
- 📄 **Atlas devices:** the real `ciscoadmin` Type-9 + login throttle on the 1941/SW01 (`CIS-Hardening-*`); `STD-0001` + AD PSOs/Entra MFA/AD CS.
- 🗂️ **Chapter structure only** (paraphrased, never reproduced — Charter Rule 16): the CCNA Official Cert Guide, Vol 2, the securing-network-devices chapter.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44) — Vol-2 reverse index for device hardening (5.3/5.4), grounded in the real `ciscoadmin` Type-9 + login-throttle on the 1941/SW01 + the break-glass rule (Playbook exists). Paraphrased from the public blueprint — no book text (Charter Rule 16). |
