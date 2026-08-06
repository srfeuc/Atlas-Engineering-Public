---
Title: POL-0010 — Acceptable Use Policy (AUP)
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force. Written for the 301 company (156 users); the operator is also bound in the lab.
Version: 2.0
---

# POL-0010 — Acceptable Use

> **At a glance.** Atlas systems, accounts, data, and network are for **authorized business use**; every user is accountable for activity under their credential, protects the data class they touch, and reports anything suspicious — and **no exception is granted informally**. This policy folds the AUP into citable requirements (`POL-0010 R1`…) and doubles as a directory of the decisions that govern access (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; what every user of Atlas systems must and must not do |
| Requirement, in one line | Authorized use only; accountable for your credential; least privilege + tiering; protect your data class; report; offboard; no informal exceptions. |
| Owner | 🔴 Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)); HR co-owns enforcement in the `301` org |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) — governs the tiered-identity model ([`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md)) applied to people |
| Applies to | **All users** — the 156 `301` employees, contractors, the shop floor (shared kiosks), and the operator in the lab |
| Builds on | [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) (no secrets in the clear) · [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md) (the data class) · [`POL-0009`](./POL-0009-Incident-Response.md) (report → respond) |
| Governs the standard | [`STD-0002` Access Control](../Standards/STD-0002-Access-Control.md) (the AGDLP/tiering enforcement) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 **GV** / **PR.AT** · CIS Controls v8 **14** (Security Awareness) · Security+ 5.1 |

---

## Scope & applicability

Governs how every human uses Atlas accounts, devices, network, and data — the 156 `301` employees, contractors, the shop floor, and the operator.

**Boundary with [`STD-0002`](../Standards/STD-0002-Access-Control.md):** POL-0010 is the *rule for people* (what a user may do, accountability, least privilege); STD-0002 is the *technical enforcement* (AGDLP, the tier-deny GPOs, the PAW). **Boundary with [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md):** POL-0011 defines the *data classes*; POL-0010 requires users to *protect the class they touch*.

## Why this is a policy, not a note

`301` is built to break *"just create a user account"*: 45 shop-floor staff share **8 kiosk logins**, Executives will **demand a carve-out from the password policy**, field reps roam with laptops, and `svc-scanner` has *more file-share access than the CFO* on a 2018 sticky-note password. An AUP is the standing rule that makes accountability, least privilege, and *"no informal exceptions"* enumerable — the thing the ghosts, the temp Domain Admins, and the shared kiosks each quietly violate.

---

## The standing requirements

Each is citable as `POL-0010 R#`.

### R1 — Authorized use, and you are accountable for your credential

Accounts/devices/network/data are for business purposes; incidental personal use must not interfere, consume undue resources, or break a rule below. You are **responsible for activity under your account** — don't share passwords. 🔴 The shared-kiosk reality (`PROD-LINE1..8`) is a **known, compensated exception** (a non-repudiation gap covered by segmentation + monitoring, `305`), not a licence to share credentials elsewhere.

### R2 — Least privilege and tiering

Use the lowest-privilege account for the task. 🔴 **A higher-tier credential never logs into a lower tier** ([`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md)/[`STD-0002`](../Standards/STD-0002-Access-Control.md)): no Domain Admin on a workstation, no Tier-0 account reading email. The three "temporary" Reeves Domain Admins are exactly what this forbids.

### R3 — Protect the data class you touch

Restricted (PII/payroll/cardholder/CA keys) and Confidential (ERP/CAD) data stay in their systems — not copied to a laptop, USB, personal cloud, or chat ([`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md)/`305`). No secrets in email/chat/tickets/docs/code ([`POL-0002`](./POL-0002-Secrets-and-Credentials.md); the `CM-0014` and `svc-scanner` failures).

### R4 — Devices, media, and email hygiene

Keep devices patched and encrypted (field-rep laptops require BitLocker); lock your screen; report lost/stolen devices. No unknown USB devices, no removable media for Restricted data without approval, no "found" hardware (the malicious-cable/USB-drop vector). Don't click unexpected attachments/links; report suspected phishing ([`POL-0009`](./POL-0009-Incident-Response.md) + the Awareness Program).

### R5 — No exceptions without a record; offboard on time

An exception (the Executive who wants out of the password PSO) is granted **only in writing, by the owner, with a compensating control** — never a verbal favour. Access ends when employment/contract ends; contractors carry an expiration date at creation (the five ghosts are what happens when this isn't enforced).

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0010 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0004 — NPS vs. FreeRADIUS: Coexist, Split on Domain Membership](../Decisions/ADR-0004-NPS-vs-FreeRADIUS.md) | Accepted — 🔴 superseded in part by ADR-0029 (2026-07-24):… | POL-0010 |
| [ADR-0010 — Atlas Repository Publication and Its Preconditions](../Decisions/ADR-0010-Atlas-Repository-Publication-Preconditions.md) | Accepted | POL-0011 (+POL-0010) |
| [ADR-0021 — Active Directory Becomes the Tiered Identity Backbone](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) | Proposed — 2026-07-16 (operator accepts by moving to Acce… | POL-0010 |
| [ADR-0028 — FGT01 Admin Auth via Direct LDAPS](../Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md) | Proposed — 2026-07-22 (operator accepts by moving to Acce… | POL-0010 |
| [ADR-0029 — Drop FreeRADIUS: Network-Device Auth Consolidates on Wind…](../Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md) | Accepted — amended 2026-07-27 (D7): the NPS host is a ded… | POL-0010 |
| [ADR-0040 — Entra Connect Uses Password Hash Sync (PHS) as the Primar…](../Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md) | Accepted (operator, 2026-07-29). Not built (Phase H1). | POL-0010 |
| [ADR-0042 — Client Workstation Fleet + Department Resource Access](../Decisions/ADR-0042-Client-Workstation-Fleet-and-Department-Resource-Access.md) | Accepted (operator, 2026-07-29). Scope addition; phased, … | POL-0007 (+POL-0010) |
<!-- END AUTOGEN:decisions POL-0010 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. To change a rule, an ADR carries `Governing Policy: POL-0010`, states *"amends `POL-0010` R#"*, and a Change Log row is added ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)); preserved, never deleted (legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — every user acknowledged the AUP at onboarding + annual refresh (attestation recorded, ties to [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md)); no shared credentials outside the sanctioned kiosk exception.
- [ ] **R2** — no higher-tier credential logs into a lower tier ([`STD-0002`](../Standards/STD-0002-Access-Control.md) enforcement).
- [ ] **R3** — Restricted/Confidential data stays in-system; no secret in email/chat/commit.
- [ ] **R4** — devices patched/encrypted; media rules enforced; phishing reported.
- [ ] **R5** — exceptions exist only in writing with an owner + compensating control; offboarding disables access on the termination date (the `301` HR-vs-AD gap report).
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

Shared credentials outside the sanctioned kiosk exception · a Domain Admin used on a workstation · Restricted data on a personal device/USB/cloud · a secret pasted into chat/ticket/commit · an "exception" no one wrote down · an account still enabled after the person left.

## Related

[`Security-Awareness-Program`](../Security-Program/Security-Awareness-Program.md) (how users are trained) · [`STD-0002` Access Control](../Standards/STD-0002-Access-Control.md) · [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) · [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md) · [`ADR-0021`](../Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) · `305`/`301` · the [Identity & Access directory](../../Atlas-Academy/Directory/Identity-and-Access.md).

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [Tiered-Admin Model](../../Atlas-Academy/Concepts/Tiered-Admin-Model.md) (why a higher-tier credential never touches a lower tier — blast radius) · [AGDLP — Granting Rights to Groups, Not People](../../Atlas-Academy/Concepts/AGDLP-Granting-Rights-to-Groups-Not-People.md) (least privilege, the model) · [Secrets & Credential Custody](../../Atlas-Academy/Concepts/Secrets-and-Credential-Custody.md) (no secrets in the clear).
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (5.1) · [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (identity governance).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First AUP — grounded in 301's shared kiosks, Reeves temp Domain Admins, ghosts, field-rep laptops, and svc-scanner; accountability · least privilege/tiering · data-class handling · media/cable · no-informal-exceptions · offboarding. |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the rules distilled into citable `R1–R5`; boundaries with `STD-0002`/`POL-0011`; the amendment model; per-`R#` Verification; a **Learn it (Academy)** section (Tiered-Admin / AGDLP / Secrets concepts); status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
