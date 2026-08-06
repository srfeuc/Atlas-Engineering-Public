---
Title: STD-0012 — Automation & IaC Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0015` via `ADR-0048` (Accepted in principle — the model is in force; the tooling builds phased). 
Version: 1.0
---

# STD-0012 — Automation & IaC

> **At a glance.** Automation has two homes — a per-device `Automation/` doc-type that links to the shared estate capability (self-hosted git/CI + shared modules); plumbing is automated and lives in the repo, but a learning-target is hand-typed first and captured only once understood; every automation artifact must be idempotent before it's ✅.

| Item | Value |
|---|---|
| Layer | **Standard** — the automation/IaC model + doc-type; binds every device `Automation/` + the estate capability |
| Governing policy | [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) — Engineering & Build Discipline |
| Requirement, in one line | Two homes (per-device `Automation/` ↔ shared capability) · automate-what-you've-learned · phased cert-matched ladder · idempotent-before-✅ |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0048`](../Decisions/ADR-0048-Automation-and-IaC-Model.md) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Detailed spec | the per-device shape [`CNT01/Automation/README`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/Automation/README.md) + [`Build-Order-and-Dependencies`](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md) Phase 10 |
| Applies to | every device `Automation/` folder + the estate git/CI capability ([`CNT01`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/), Backlog #19) |
| Feeds / fed by | **fed by** [`STD-0005`](./STD-0005-Device-Documentation.md) (`Automation/` is a page-set doc-type) + [`STD-0010`](./STD-0010-Incremental-Test-Gated-Build.md) (idempotency = the automation gate) · **feeds** [`STD-0011`](./STD-0011-Phased-Build-Guides.md) (the Automation-onboarding phase hook) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | IaC / GitOps · AZ-400 (DevOps) · the Learning Rule (Charter 16/17) |

---

## Scope & applicability

Binds the automation model: where automation lives (two homes), what gets automated vs hand-typed, the phased tool ladder, and the idempotency gate. **Status honesty (`POL-0006`):** the *model* is in force; **nothing automated is built yet** — this standard is the shape the capability builds into (Phase 10).

**Boundary with adjacent standards:** *the build-guide hook* is [`STD-0011`](./STD-0011-Phased-Build-Guides.md); *the idempotency gate* is [`STD-0010`](./STD-0010-Incremental-Test-Gated-Build.md); *the `Automation/` doc-type shape* is part of [`STD-0005`](./STD-0005-Device-Documentation.md); this standard owns the *model*.

## Why a standard, not left in a guide

Automation without a model becomes copy-pasted scripts and drift. Atlas's rule is enterprise-real: shared runnable code lives **once** (git/CI), a device only documents what it consumes, and — the load-bearing part — **you automate what you already learned to do by hand**, so the Build-Guide still teaches the manual first pass. A standard makes that split auditable.

---

## The requirements

Each is citable as `STD-0012 R#`.

### R1 — Two layers, two homes

A **per-device `Automation/` doc-type** (the device's how-to pages + device-specific scripts + which estate modules it consumes) **links to, never copies**, the **estate capability** — shared runnable code + orchestration (self-hosted Git + CI runner + shared Ansible roles / Terraform modules / DSC / Oxidized), owned centrally (`Operations/Automation/`, on [`CNT01`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/), Backlog #19) (`POL-0008`).

### R2 — Automate what you've learned by hand (the Learning Rule)

Plumbing/provisioning **is** automated and in the repo (golden images, cloud-init, config-backup, teardown/rebuild, IaC); a **learning-target config is hand-typed the first time**, then optionally captured as automation once understood (Charter 16/17). The Build-Guide still teaches the manual first pass.

### R3 — A phased, cert-matched tool ladder

Tools are introduced **as their cert lands** (`ADR-0044`): **Oxidized → cloud-init / bash+PowerShell → Ansible → Terraform+Bicep/ARM → PowerShell DSC → self-hosted Git (Gitea/GitLab) + CI.** Not all at once.

### R4 — The per-device `Automation/` shape

An `Automation/` folder (like `Roles/`/`Changes/`) — an index + how-to pages + script/playbook files; **each artifact documents** purpose → what it automates → how to run → expected result → **what it deliberately does *not* automate** (the hand-typed learning bits) — and cross-links the Build-Guide onboarding hook + the shared modules.

### R5 — Automation is test-gated and idempotent

Every automation artifact carries a `STD-0010` gate: it builds the intended thing **and a re-run is idempotent** (no drift, no double-apply) **before it's ✅**. GitOps for device configs (review/PR → deploy).

---

## Adopting & amending decisions

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0048`](../Decisions/ADR-0048-Automation-and-IaC-Model.md) | Accepted in principle | the two-home model, the Learning Rule, the phased ladder, the idempotency gate (amended the [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) doc-standard → v1.4: the `Automation/` doc-type) |

(Formalizes Backlog #7 (zero automation) + #19 (self-hosted git/CI). Originals in the legacy snapshot.)

## Verification (how conformance is proven)

- [ ] **R1/R4** — every built device page-set has an `Automation/` folder with a README index (early devices may hold only the Oxidized config-backup hook as a gated stub).
- [ ] **R1** — no per-device `Automation/` folder contains the *shared* runnable modules (those live once, centrally — the two-home split).
- [ ] **R5** — each automation artifact's acceptance gate asserts **idempotency on re-run**.
- [ ] **R2** — each artifact names **what it does *not* automate** (the learning bits).
- [ ] **Meta** — a new tool arrives as its cert lands, not ahead of it.

## Learn it — the source of truth for the *why* + the how

- 🎓 **Concept (why):** [`Ansible IaC Device Provisioning`](../../Atlas-Academy/Concepts/Ansible-IaC-Device-Provisioning.md)
- 🖥️ **Commands:** the [Command-Library](../../Atlas-Academy/Command-Library/) (per-platform automation reads)
- 🧩 **The shape, worked:** [`CNT01/Automation/README`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/Automation/README.md) · the [Build-Order Phase 10](../../Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md)
- 📋 **Program:** [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md)

## What a violation looks like

A shared Ansible role copied into a device's `Automation/` folder · an automation artifact that isn't idempotent on re-run · automating a learning-target before it's been done by hand · a tool introduced years ahead of its cert track · an `Automation/` artifact that doesn't say what it leaves manual.

## Related

[`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) (governing) · [`STD-0010`](./STD-0010-Incremental-Test-Gated-Build.md) · [`STD-0011`](./STD-0011-Phased-Build-Guides.md) · [`STD-0005`](./STD-0005-Device-Documentation.md) · [`ADR-0048`](../Decisions/ADR-0048-Automation-and-IaC-Model.md) · [`CNT01`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0048` into a testable standard** (#39 (B)→STD): the two-home model (per-device `Automation/` ↔ the shared capability), the Learning Rule, the phased cert-matched ladder, the `Automation/` doc-type shape, and idempotent-before-✅ — each with a structure/idempotency read-back; honest that nothing is built yet. Cut from `STD-Template`. |
