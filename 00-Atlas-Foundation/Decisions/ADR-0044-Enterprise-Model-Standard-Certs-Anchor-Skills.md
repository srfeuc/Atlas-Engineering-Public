# ADR-0044 — Built to the Real-World Enterprise Model; Certifications Anchor the Skills

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29). Framing / priority decision — the lens every scope call is made through. |
| Governing Policy | POL-0016 |
| Rule promoted to | [POL-0016 — Realism & Learning](../Policies/POL-0016-Realism-and-Learning.md) · this ADR is the adopting decision; the standing rule now lives in that policy (`ADR-0054` (C)→policy) |
| Scope | **Global** — how services/roles are scoped and built across the estate. |
| Date | 2026-07-29 |
| Supersedes | — (sets the priority between two existing lenses) |
| Related | `ADR-0039` (hybrid scope) · `ADR-0042` (workstations) · `ADR-0043` (gated Build-Guides) · Documentation Standard v1.2 (the per-device **Certification-alignment** element) · `Company-Profile/301` + `305` (the enterprise scenario) · `Atlas-Academy/Atlas-Certification-Lab-Map.md` + `Roadmap/Atlas-Cert-Objective-Gap-Analysis.md`. |
| Evidence Status | **Decision** (operator, 2026-07-29). |

## Context

Two lenses shape what gets built: **(a) how a real enterprise actually runs** — identity lifecycle (joiner/mover/leaver), change control, least privilege, monitoring/alerting, backup/DR *tested*, SecOps, compliance (the `301`/`305` scenario) — and **(b) certification objectives** (the exam skills). They mostly overlap, but where they diverge the operator set the priority: *"I want to learn how things work in the real world; the cert path anchors the skills I need."*

## Decision

**The real-world enterprise operating model is the standard; certifications are the skill anchor — a checklist laid over the enterprise design, not the driver.**

1. **Enterprise-first build.** Each service/role is scoped and built **as a real enterprise would run it** (production patterns: HA where it matters, JML identity lifecycle, change control, monitoring/alerting, *tested* backup/DR, least privilege, documented runbooks), grounded in `301`/`305`.
2. **Certs anchor the skills.** Each device `Roadmap`'s Certification-alignment slice (Standard v1.2) maps the enterprise work to the exam objectives it exercises. Where an objective isn't naturally exercised by the enterprise build, it is a **deliberate learning add-on**, noted as such — never forced into the architecture.
3. **Cert scoping is fed by the exam blueprints.** The operator supplies exam-guide **TOC / chapter descriptions** (e.g., the **AZ-800 / AZ-801** Exam Refs — the Windows Server Hybrid pair; **AZ-802** replaces them 2026-09-30 with the same skills — see the cert-lab-map); each Skill maps to an Atlas service/role, and gaps become scoped lab work. Mapping owner: the estate device×cert matrix + `Atlas-Cert-Objective-Gap-Analysis` (Academy).
4. **No vague placeholders.** `ADR-0043` gated stubs are **designed** — a future phase is a real enterprise design + its dependencies, gated; only the literal portal/hardware clicks are deferred, never the decision. (Operator: "I hate placeholders; I never remember what needs to be hashed out.")

## Alternatives Considered

- **Cert-driven build** (architecture follows the exam blueprint). Rejected — produces a lab that passes exams but doesn't reflect how enterprises actually operate; the operator wants real-world fluency first.
- **Enterprise-only, ignore certs.** Rejected — the certs are the *anchor* that keeps skill coverage honest and gives the learning a spine.
- **Leave the priority unstated.** Rejected — the operator wants it fixed so scoping isn't re-litigated each time (and forgotten).

## Consequences

- Scoping leads with *"what would the enterprise do,"* then checks *"which cert objective does this anchor."*
- The Certification-alignment element gains a **real-world note** where the enterprise practice (not the exam) is the point.
- The **hybrid/cloud phases** (Entra / Intune / Exchange / Azure) are scoped from **AZ-800/801 · AZ-104 · MD-102 · MS-102 · Exchange** blueprints mapped onto enterprise services (EXCH01, Entra Connect, an Intune-managed fleet, Azure VNet/S2S/Backup).
- `301`/`305` stays the anchoring scenario; a new role is justified by the enterprise first, then labelled with the certs it serves.

## Change Log

| Version | Changes |
|---|---|
| 1.1 | 2026-07-29. **AZ-802 correction.** Verified 2026-07-29: **AZ-802 (Administering Windows Server)** replaces AZ-800/801 on **2026-09-30** (beta July 2026, GA ~Aug 2026), same on-prem+hybrid skills — the earlier "there is no AZ-802" is outdated. Cert scoping unchanged (skills anchor the lab); target stays AZ-800/801 per operator. |
| 1.0 | 2026-07-29. Accepted. Real-world enterprise operating model = the standard; certifications anchor the skills (a checklist over the enterprise design). Cert scoping fed by exam-guide TOCs mapped to Atlas services/roles; gated stubs are **designed**, not placeholders (`ADR-0043`). Corrects "AZ-802" → the **AZ-800 + AZ-801** Windows Server Hybrid pair. |
