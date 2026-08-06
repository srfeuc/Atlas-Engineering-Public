---
Title: Security+ SY0-701 Domain 5 (Program Management & Oversight) — Atlas Coverage Map
Path: Atlas-Academy/Certification
Path (suggested): 00-Atlas-Foundation/  — companion to Atlas-Certification-Lab-Map (CCNA) and the CompTIA Pre-Teardown Catalogue
Status: Draft — gap analysis of the repo against the pasted Domain-5 objectives.
Date: 2026-07-20
---

# Security+ Domain 5 — what Atlas has, and what it's missing

## The headline (read this first)

Domain 5 is the **one place the gaps are not about the lab**. Everything here is a **document artifact** — a policy, a plan, a register, a training deck — so **teardown timing is irrelevant**: you can write all of it before, during, or after the rebuild, on paper, at zero hardware cost.

And the split is lopsided:

- **You are unusually strong** on the *process/governance* spine — a genuine **Policy > Standard > ADR > Change hierarchy** (adopted by `ADR-0026`), a rigorous **change-management process**, a **formal audit process** (`POL-0001`), and a real **compliance anchor** (`305`: CIS Controls v8 IG1, PCI-DSS, NIST 800-82). Most homelabs have none of this; you have more than the exam expects.
- **You are almost empty** on the *human and external* half — **security awareness (5.6)** and **third-party/vendor risk (5.3)** are near-zero, and a handful of named artifacts (**incident-response plan, business-continuity, AUP**) are missing even though you *do* the underlying work.

The good news: your fictional company (`301-Atlas-Company-Profile` + `305-Industrial-Security`, plus the MSP scenario and `ADR-0024`'s eight-roles-one-operator) is the **ready-made grounding** for every missing artifact. It already references a cyber-insurance questionnaire, PCI scope, ghost-account offboarding, shared kiosks, and vendor sign-off — the exact hooks these docs need.

Legend: ✅ have · ⚠️ partial · ❌ missing.

---

## 5.1 — Security governance

| Element | State | Where it lives / what's missing |
|---|---|---|
| **Guidelines** | ⚠️ | Implicit in the Governance Framework + standards; no distinct "guidelines" (recommended-not-mandatory) layer. Minor. |
| Policy: Information security | ✅ | Governance Framework Policy Register: POL-0001..0008. Real policy layer. |
| Policy: **Acceptable Use (AUP)** | ❌ | No AUP. `301` has 156 users — the natural home for one. |
| Policy: **Business continuity** | ❌ | `POL-0005` covers backup/DR; **BCP (continuity of operations, BIA) is broader and absent.** |
| Policy: Disaster recovery | ✅ | `POL-0005` + the DR Game-Day catalogue + RPO/RTO objectives. |
| Policy: **Incident response** | ❌ | 🔴 You *do* IR rigorously (`ADR-0009`, every CM record), but there is **no IR policy/plan** with named phases. Biggest "substance exists, artifact doesn't" gap. |
| Policy: **SDLC** | ❌ | No software dev; the NetBox→Ansible IaC path is the closest analog. Low priority / arguably N/A. |
| Policy: Change management | ✅✅ | `Atlas-Change-Management-Process` + `POL-0003` + the CM record corpus + `ADR-0018` silo trigger. Stronger than the exam needs. |
| Standard: Password | ⚠️ | Passphrase rules in `049`/`POL-0002`, but no named **password standard**. |
| Standard: Access control | ⚠️ | `ADR-0021` tiering + RADIUS/802.1X, no single **access-control standard** doc. |
| Standard: Physical security | ❌ | None. (`305` names badge/HVAC for the fiction; no standard.) |
| Standard: Encryption | ⚠️ | PKI + LUKS + AES-256 archives in practice; no named **encryption standard**. |
| Procedure: Change management | ✅ | The 12-step workflow + guide-reconciliation. |
| Procedure: **Onboarding/offboarding** | ❌ | `301` has the *problem* (ghosts, Reeves cleanup) but **no onboarding/offboarding SOP**. |
| Procedure: Playbooks | ⚠️ | Runbooks exist; **no IR playbooks** specifically. |
| External: Regulatory / Legal | ⚠️ | `305`: PCI-DSS, cyber-insurance, PII. No explicit **legal** treatment; regulatory is design-anchor, not a register. |
| External: Industry | ✅ | NIST SP 800-82 (OT), Purdue model, CIS v8 IG1 — genuinely mapped. |
| External: Local / National / Global | ❌ | Not addressed. |
| Monitoring **and revision** | ⚠️ | **Revision** ✅✅ (change logs, revision history, audit cadence, reconcile-to-live). **Monitoring** ⚠️ — Book 5 (Wazuh/LibreNMS) planned, not built. |
| Governance **structures** | ⚠️ | `ADR-0018` (5 silos as roles) + `ADR-0024` (eight roles, one operator) = a centralized, role-based model. No board/committee (N/A solo, but a "Change Advisory" analog could be simulated). |

---

## 5.3 — Third-party / vendor risk  🔴 near-total gap

| Element | State | Hook that already exists in the repo |
|---|---|---|
| Vendor assessment (pentest, right-to-audit, internal-audit evidence, independent assessments, supply-chain) | ❌ | The **SPAN/Suricata IDS** and a pentest give you a "rules of engagement" + right-to-audit story; supply-chain = the counterfeit-Prolific cable finding is a real supply-chain lesson. |
| Vendor selection (due diligence, conflict of interest) | ❌ | The order-portal / CAD / SCADA vendors in `301`/`305`. |
| **Agreement types** (SLA, MOA, MOU, MSA, WO/SOW, NDA, BPA) | ❌ | The **MSP scenario** (customer A/B) is the natural place for SLAs/NDAs/MSAs; `305` mentions **vendor sign-off** for the un-patchable OT box. |
| Vendor monitoring / questionnaires | ❌ | 🔴 `305` already names a **cyber-insurance renewal questionnaire** — that *is* a third-party questionnaire/attestation you can write. |
| Rules of engagement | ❌ | Needed for the IDS/pentest work anyway. |

This is the domain with the least coverage. It's all writable against the fictional vendors/customers you already invented.

---

## 5.4 — Security compliance  ⚠️ good foundation, missing the formal wrapper

| Element | State | Notes |
|---|---|---|
| Compliance reporting — internal | ✅ | The audit process (`POL-0001`), Book-1 audit (`ADR-0019`), Divergence Register. |
| Compliance reporting — external | ❌ | No external reporting model. |
| Consequences of non-compliance (fines, sanctions, reputational, license, contractual) | ⚠️ | `305` names one real one — **cyber-insurance claim denial**; the rest unmodeled. |
| Compliance monitoring — due diligence/care | ✅ | The reconcile-to-live discipline is due care. |
| — attestation & acknowledgement | ⚠️ | "Operator-confirmed" notes are attestation-shaped; not formalized. |
| — internal / external | ⚠️ | Internal ✅; external ❌. |
| — automation | ✅ | gitleaks CI + (future) Oxidized drift detection. |

You have the **substance of a compliance program** (CIS IG1 anchor + audit + automation); what's missing is the **framing** — a short "compliance program" doc that turns the CIS-IG1 mapping into a reporting cadence, an attestation, and stated consequences.

---

## 5.6 — Security awareness  🔴 near-total gap

| Element | State | Perfect grounding already in `301` |
|---|---|---|
| Phishing (campaigns, recognizing, responding) | ❌ | 156 users; a phishing-campaign runbook + "how to report" is a clean artifact. |
| Anomalous behavior recognition (risky/unexpected/unintentional) | ❌ | Ties to Book 5 (Wazuh) once built; the program doc can precede the tooling. |
| User guidance & training (handbook, situational awareness, **insider threat**, password mgmt, **removable media & cables**, social engineering, opsec, hybrid/remote) | ❌ | `301`'s **shared kiosks**, **ghost accounts**, and **`svc-scanner` sticky-note password** are textbook training scenarios. `POL-0002` already touches **removable media/cables** (USB backups) — extend it. |
| Reporting & monitoring (initial, recurring) | ❌ | Define an initial + recurring cadence. |

Awareness is the human layer an infra lab never touches — but your fictional company is *built* for it.

---

## What to write (prioritized — all paper, all grounded in `301`/`305`)

1. **Incident Response plan + policy (`POL — Incident Response` + a playbook).** 🔴 Highest value: you already execute IR to a high standard (`ADR-0009`, every CM). Formalize the phases (prepare → detect → analyze → contain → eradicate → recover → lessons) and point them at real Atlas incidents as worked examples. Closes 5.1 (IR policy + playbook) and strengthens 4.x.
2. **Security Awareness program** — an **AUP** + a short training handbook + a **phishing-campaign runbook**, grounded in `301`'s users/kiosks/ghosts. Closes almost all of **5.6** and the AUP gap in 5.1, cheaply.
3. **Third-party / Vendor Risk pack** — a vendor-risk register + a one-page **agreement-types cheat sheet** (SLA/MOA/MOU/MSA/SOW/NDA/BPA) + the **cyber-insurance questionnaire** as a worked attestation, using the order-portal vendor and the MSP customers. Closes most of **5.3**.
4. **Business Continuity (`POL — Business Continuity` + a BIA)** — the sibling to `POL-0005` DR: what must stay up, MTD/RTO/RPO per service, continuity vs. recovery.
5. **A compliance-program one-pager** — turn `305`'s CIS-IG1/PCI mapping into a reporting cadence + attestation + stated consequences. Closes the 5.4 wrapper.
6. **Four thin named standards** — Password, Access Control, Physical Security, Encryption — mostly *referencing* what already exists (`POL-0002`, `ADR-0021`, CIS, the PKI) so each objective has a citable doc.

> None of this blocks or is blocked by the teardown. It's the cheapest, highest-density Security+ Domain-5 study you can do — and it slots straight into the governance framework you already run.

## Related

`Atlas-Governance-Framework` (the POL register these extend) · `Atlas-Change-Management-Process` · `POL-0001` (Audit) · `301`/`305` (the grounding) · `Atlas-Roadmap-Advanced-Scenarios` (MSP scenario = the vendor/tenant hooks) · the CompTIA Pre-Teardown Catalogue (this is the Domain-5 companion to it).
