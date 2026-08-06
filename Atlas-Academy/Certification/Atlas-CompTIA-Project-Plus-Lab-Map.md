---
Title: Atlas CompTIA Project+ (PK0-005) Lab Map
Path: Atlas-Academy/Certification
Status: 🟡 SEED (v0.1, 2026-07-31) — the objective spine + the Atlas artifacts that exercise each domain. Deepen from the uploaded PK0-005 eBook (operator has it).
Version: 0.1
Date: 2026-07-31
---

# Atlas CompTIA Project+ (PK0-005) Lab Map

> How the **Atlas governance estate itself** teaches CompTIA **Project+ (PK0-005)**. Unlike the technical cert maps (CCNA/AZ-800/FCP), Project+ is exercised not by a device but by **how Atlas is run** — the Policy/Standard/ADR hierarchy, the change-control discipline, the roadmap and backlog, the risk register. The governance-reconciliation work (`ADR-0054`) is the live worked example: it *is* integrated change control.
>
> **Grounding rule (Academy house style):** every objective below points at a **real Atlas artifact** that demonstrates it. This is a seed — the four domains and weights are the current PK0-005 blueprint; the sub-objective detail is filled from the operator's PK0-005 eBook in a later pass.

## The exam at a glance (PK0-005)

| Domain | Weight | One-line |
|---|---|---|
| **1 — Project Management Concepts** | **33%** | methodology, change control, risk, quality, communication, teams |
| **2 — Project Life Cycle Phases** | **30%** | initiate → plan → execute/control → close; stakeholders, artifacts, lessons learned |
| **3 — Tools & Documentation** | **19%** | charts, logs, registers, dashboards, PM software |
| **4 — Basics of IT & Governance** | **18%** | IT infrastructure literacy, operational change control, CI/CD, compliance/privacy |

Up to 95 questions, 90 minutes, multiple-choice + performance-based.

## Domain 1 — Project Management Concepts (33%)

| Objective area | Atlas artifact that exercises it |
|---|---|
| **Change control / integrated change control** | **`ADR-0054` + the Governance Framework** — the baseline-and-amendment model (Policy = baseline; ADR = approved change request). The clearest single demonstration. |
| Risk management (identify/assess/treat/review) | `POL-0012` (Risk Management) + the Roadmap **Critical Risk** register + accepted-risk-with-trigger pattern (`ADR-0005`/`ADR-0009`). |
| Issue vs risk handling | the `Review-Flag-Register` (open flags) + device `Considerations` (typed holes). |
| Quality management / verification | `POL-0001` (Audit) + `POL-0006` (Evidence) — "a tick needs the command that proves it." |
| Communication & stakeholder management | `SESSION-HANDOFF` (living STATE) + the AI-Context folder (`ADR-0052`) — handoff *is* stakeholder communication across sessions. |
| Methodology (predictive vs agile) | the **incremental, test-gated** build model (`ADR-0041`) — iterative delivery with per-unit acceptance gates. |

## Domain 2 — Project Life Cycle Phases (30%)

| Objective area | Atlas artifact |
|---|---|
| Initiating (charter, stakeholders) | `Atlas-Charter.md` (the estate's charter) + `ADR-0018` (roles/silos). |
| Planning (scope, schedule, dependencies) | `Atlas-Roadmap.md` + `Operations/Build-Order-and-Dependencies.md` (dependency-ordered plan). |
| Executing / monitoring & controlling | `Build-Progress-Tracker` + the per-device Build-Records + the phased gates (`ADR-0043`). |
| Closing (lessons learned, sign-off) | `ADR-0012` (quarantine/preserve) + `POL-0001` audit sign-off + the CM-#### lesson trail. |
| Change during the life cycle | `POL-0003` (Change Control) — a cross-silo change raises a Change Record. |

## Domain 3 — Tools & Documentation (19%)

| Objective area | Atlas artifact |
|---|---|
| Registers & logs | the **ADR-Index**, the **Improvement Backlog**, the **Review-Flag-Register**, the risk register (`POL-0012`), Change Records (CM/MC). |
| Charts / diagrams | the Mermaid connection diagrams (Standard v1.6) + the staged traffic-flow views + the topology docs. |
| Dashboards / status | `SESSION-HANDOFF` living STATE + the xlsx commissioning checklists (COUNTIF progress). |
| Collaboration / PM software | git + the CI checks (`atlas-checks.yml`) as the estate's change pipeline; the self-hosted git/CI capability (`#19`). |

## Domain 4 — Basics of IT & Governance (18%)

> **This is where Atlas is strongest** — the whole estate is the IT-literacy sandbox this domain assumes.

| Objective area | Atlas artifact |
|---|---|
| IT infrastructure (multi-tier, networking, storage, virtualization) | the entire Lab-02 estate — VLANs/segmentation, Proxmox, S2D (`ADR-0046`), the storage pass (`#25`). |
| Cloud models (IaaS/PaaS/SaaS) | the hybrid model (`ADR-0039`/`ADR-0040` Entra) — on-prem + cloud identity. |
| Operational change control | `POL-0003` + the CM/MC records — the same integrated-change-control idea Domain 1 tests, applied to ops. |
| CI/CD | `atlas-checks.yml` (gitleaks + link + LF) + the automation/IaC model (`ADR-0048`) + the GitOps plan (`#19`). |
| Compliance & privacy | `POL-0011` (Data Governance/Privacy) + `POL-0007` (CIS hardening) + `POL-0010` (Acceptable Use). |

## Why this cert belongs in Atlas now

The governance-reconciliation question that produced `ADR-0054` — *"can we make ADRs into policies and have the ADRs be amendments? is that how project management works?"* — is a **Project+ Domain 1 question** almost verbatim. Atlas already runs the practices (baselines, change requests, risk registers, lessons learned); this cert map names them in PM vocabulary so the operator can (a) see the estate through the PMBOK/Project+ lens and (b) study for the exam using artifacts they already built.

## To deepen (next pass)

- Fold the **PK0-005 eBook** sub-objectives (operator has the PDF) into per-domain objective checklists.
- Add a **Project+ ↔ Atlas objective matrix** row-per-objective (like the other cert maps' coverage tables).
- Cross-link from `Atlas-Certification-Lab-Map.md` (the catalogue) once the matrix exists.

## Related

`Atlas-Governance-Framework.md` · `ADR-0054` · `Governance-Reconciliation-Triage.md` · `POL-0001`/`POL-0003`/`POL-0012` · `Atlas-Certification-Lab-Map.md` · `Atlas-Roadmap.md` · `Atlas-Improvement-Backlog` **#33**
