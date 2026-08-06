---
Title: Atlas Compliance Program (the wrapper around POL-0001 + the 305 CIS-IG1 anchor)
Path: 00-Atlas-Foundation/Security-Program
Status: Draft — a one-pager that turns the existing CIS-IG1 mapping into reporting + attestation + consequences. Covers Security+ 5.4.
Version: 1.0
---

# Atlas Compliance Program

## 🔴 Reconciliation up front (why this isn't duplicating POL-0001 or 305)

- `POL-0001` (Audit) = **how** compliance is *checked* (the reconcile-to-live mechanism, evidence rules). This doc does not restate it.
- `305` Part 3 = **the framework** Atlas anchors to (CIS Controls v8 IG1, PCI-DSS, PII, cyber-insurance) and the control→artifact table. This doc does not restate it.
- **What's missing, and all this adds:** the *program wrapper* around them — **reporting cadence, internal vs external, attestation/acknowledgement, and the consequences of non-compliance** (Security+ 5.4). It's the cover sheet, not new controls.

## The obligations (from `305`, not re-derived)

PCI-DSS (order portal), PII/financial (Finance/HR), and the **cyber-insurance attestation** — anchored to **CIS Controls v8 IG1**. The full control→artifact mapping lives in `305` Part 3; the honest, worked attestation lives in `Third-Party-Risk-Management` §4.

## Compliance reporting

| Type | To whom | Cadence | Vehicle |
|---|---|---|---|
| **Internal** | The operator / `301` Exec | Per reconcile pass + before a freeze | The `POL-0001` audit output + the Divergence Register |
| **External** | Cyber-insurer; a PCI acquirer; an auditor | On renewal / on request | The attestation (`Third-Party` §4); a PCI SAQ; the right-to-audit evidence |

## Compliance monitoring

- **Due diligence / due care** — the reconcile-to-live discipline *is* due care (you check, you don't assume).
- **Attestation & acknowledgement** — users acknowledge the AUP (`POL-0010`) at onboarding + annually; the operator attests the cyber-insurance questionnaire truthfully (an "⚠️" answer attested as "✅" is how a claim is denied).
- **Internal & external** — internal audit (`POL-0001`) + external assessment (insurer questionnaire, PCI).
- **Automation** — gitleaks CI today; Oxidized drift + Wazuh later (the continuous form of compliance monitoring).

## Consequences of non-compliance (name them, so the controls have teeth)

| Consequence | Where it bites Atlas (`301`/`305`) |
|---|---|
| **Fines / sanctions** | PCI penalties; privacy-law fines (CCPA/GDPR via the order portal) |
| **Reputational damage** | A breach of customer card/PII data at a 40-year-old regional manufacturer |
| **Loss of license / ability to process** | Losing the ability to take card payments (PCI) — the order portal's whole purpose |
| **Contractual impacts** | 🔴 **Cyber-insurance claim denied** for a false attestation (`305`'s named forcing function); MSP-customer SLA penalties |

## Verification

- [ ] The CIS-IG1 mapping (`305`) is current and each control traces to an artifact.
- [ ] The attestation (`Third-Party` §4) is reviewed each insurer renewal and its "⚠️/🔴" rows are on the risk register (`POL-0012`).
- [ ] AUP acknowledgements are recorded (`POL-0010`/`POL-0001`).
- [ ] Internal compliance reporting runs on the audit cadence.

## Related

`POL-0001` (the check) · `305` Part 3 (the framework) · `Third-Party-Risk-Management` §4 (the worked attestation) · `POL-0010` (AUP acknowledgement) · `POL-0011` (privacy/retention obligations) · `POL-0012` (the "⚠️" answers become risks).
