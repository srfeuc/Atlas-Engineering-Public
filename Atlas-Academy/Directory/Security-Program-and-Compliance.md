---
Title: Security Program and Compliance — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §12. The security program beyond the devices — compliance, incident response, risk, privacy, awareness, third-party.
---

# Security Program and Compliance — Full Directory

> **The deep version of [Source-of-Truth §12](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#12-security-program-and-compliance).** The router points you at the program docs; this page is the *encyclopedia* — the whole security program that sits *above* the individual devices: how Atlas measures itself against a framework, responds to an incident, manages risk and privacy, trains the human layer, and handles vendor risk. Keep the router in a tab; come here for the whole picture.
>
> Device-level security (the firewall, IPS, hardening, PKI) lives in [Security & Perimeter](./Security-and-Perimeter.md) and [Identity & Access](./Identity-and-Access.md); this page is the *program* layer that governs all of it.

## On this page

1. [The program](#1-the-program) — the five program docs
2. [The scenario bar](#2-the-scenario-bar) — what Atlas is built to meet
3. [The standing rules](#3-the-standing-rules) — the governing policies
4. [Device-level security](#4-device-level-security) — where enforcement lives
5. [When it happens](#5-when-it-happens) — the incident playbooks
6. [The Academy why-layer](#6-the-academy-why-layer)
7. [The decisions (ADRs)](#7-the-decisions-adrs)

---

## 1. The program

The [`Security-Program/`](../../00-Atlas-Foundation/Security-Program/) folder is the estate's security program beyond the devices:

| Doc | What it owns |
|---|---|
| [`Atlas-Compliance-Program`](../../00-Atlas-Foundation/Security-Program/Atlas-Compliance-Program.md) | The **NIST CSF / CIS control mapping** and how Atlas measures itself against it — the framework the standards and policies satisfy |
| [`Incident-Response-Playbook`](../../00-Atlas-Foundation/Security-Program/Incident-Response-Playbook.md) | The step-by-step **IR lifecycle** for a suspected incident (the process behind [`POL-0009`](../../00-Atlas-Foundation/Policies/POL-0009-Incident-Response.md)) |
| [`Security-Awareness-Program`](../../00-Atlas-Foundation/Security-Program/Security-Awareness-Program.md) | The **human-layer** posture — training, phishing, passphrase hygiene |
| [`Third-Party-Risk-Management`](../../00-Atlas-Foundation/Security-Program/Third-Party-Risk-Management.md) | **Vendor and supply-chain** risk — and the cyber-insurance **transfer** that `POL-0012` leans on |

> **The honest thread (`POL-0006`):** the program is authored and the control mapping is designed, but the estate is candid that its biggest program-level gap is *observability* — *"no evidence of compromise"* today means *"we cannot see," not "we looked"* (the meta-risk R-11 in [`POL-0012`](../../00-Atlas-Foundation/Policies/POL-0012-Risk-Management.md); the [Risk as a Living Register](../Concepts/Risk-as-a-Living-Register.md) why-layer). Monitoring (MON01/SIEM01) is the build that turns inference into observation — see [Monitoring and Logging](./Monitoring-and-Logging.md).

## 2. The scenario bar

Atlas is built to meet a concrete fictional bar: [`305-Atlas-Industrial-Security-Requirements`](../../00-Atlas-Foundation/Company-Profile/305-Atlas-Industrial-Security-Requirements.md) — the OT/industrial security requirements of the `301` company, where **availability outranks confidentiality** on the production line (a control that risks stopping the line is itself a risk). That bar is what the segmentation, the tiering, and the risk appetite all answer to.

## 3. The standing rules

The program's governing policies (the [Governance directory](./Governance-and-Decisions.md) holds the full register):

- [`POL-0002` Secrets & Credentials](../../00-Atlas-Foundation/Policies/POL-0002-Secrets-and-Credentials.md) · [`POL-0009` Incident Response](../../00-Atlas-Foundation/Policies/POL-0009-Incident-Response.md) · [`POL-0011` Data Governance & Privacy](../../00-Atlas-Foundation/Policies/POL-0011-Data-Governance-Classification-Privacy.md) · [`POL-0012` Risk Management](../../00-Atlas-Foundation/Policies/POL-0012-Risk-Management.md).
- Ownership: the **Security silo** ([`ADR-0018`](../../00-Atlas-Foundation/Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)) owns audit, IR, and risk sign-off.

## 4. Device-level security

The program sets the bar; enforcement lives on the devices — see the [Security & Perimeter directory](./Security-and-Perimeter.md) for the full picture:

- **Segmentation & enforcement** — [`ADR-0023`](../../00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) (east-west topology) · [`ADR-0038`](../../00-Atlas-Foundation/Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md) (inline IPS) · [`ADR-0047`](../../00-Atlas-Foundation/Decisions/ADR-0047-FGT01-FortiGuard-UTM.md) (perimeter UTM) · [`ADR-0050`](../../00-Atlas-Foundation/Decisions/ADR-0050-FGT01-TLS-Deep-Inspection-Scope-and-ICA01-Inspection-CA.md) (TLS deep-inspection scope).
- **Identity & trust** — [`ADR-0021`](../../00-Atlas-Foundation/Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md) (tiered identity — Tier-0 protection) · [`ADR-0009`](../../00-Atlas-Foundation/Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) (the IR + destroy-step lesson).

## 5. When it happens

- **A secret got committed to git** → [Respond-to-a-Committed-Secret](../Playbooks/Respond-to-a-Committed-Secret.md) (the [Secrets & Credential Custody](../Concepts/Secrets-and-Credential-Custody.md) why-layer).
- **A key or credential leaked** → [Rotate-a-Leaked-Key-Before-You-Back-It-Up](../Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md).
- The full IR lifecycle is the [`Incident-Response-Playbook`](../../00-Atlas-Foundation/Security-Program/Incident-Response-Playbook.md).

## 6. The Academy why-layer

- 🎓 **Concepts** — [Risk as a Living Register](../Concepts/Risk-as-a-Living-Register.md) (accepted-risk-needs-a-trigger; "we cannot see" is the top risk) · [Secrets & Credential Custody](../Concepts/Secrets-and-Credential-Custody.md) · [Encryption & PKI in Atlas](../Concepts/Encryption-and-PKI-in-Atlas.md) (data protection) · [Identity-Aware vs Zone Firewall Policy](../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md) · the [Concepts index](../Concepts/).
- 🏅 **Cert alignment** — [Security+ Domain-5](../Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (governance, risk, compliance, IR) · governance is cert-adjacent to CompTIA Project+ / ITIL.

## 7. The decisions (ADRs)

- [`ADR-0018`](../../00-Atlas-Foundation/Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) — the operating-model silos (Security owns audit/IR/risk)
- [`ADR-0009`](../../00-Atlas-Foundation/Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) — the incident-response + accept-with-triggers exemplar
- the segmentation/enforcement decisions in [§4](#4-device-level-security) above

## Related

[Source-of-Truth router §12](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#12-security-program-and-compliance) (the quick view) · [`Security-Program/`](../../00-Atlas-Foundation/Security-Program/) · [Security & Perimeter directory](./Security-and-Perimeter.md) · [Identity & Access directory](./Identity-and-Access.md) · [Monitoring and Logging directory](./Monitoring-and-Logging.md) · [Governance and Decisions directory](./Governance-and-Decisions.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-04. First cut — the exhaustive twin of Source-of-Truth §12: the five-doc security program (compliance mapping · IR playbook · awareness · third-party risk), the `305` scenario bar (OT availability), the governing policies (`POL-0002`/`0009`/`0011`/`0012`), the device-level enforcement pointers (segmentation + identity ADRs), the incident playbooks, and the Academy why-layer (Risk / Secrets / Encryption concepts) — with the honest "we cannot see" observability gap named. Built to complete the Academy Directory. |
