# ADR-0048 — Automation & Infrastructure-as-Code Model (Per-Device `Automation/` Doc-Type + the Estate IaC Capability)

| Item | Value |
|---|---|
| Status | **Accepted in principle** (operator, 2026-07-29) — the *model* is decided; the tooling is **built phased + cert-matched**, not all at once. Nothing built. |
| Governing Policy | POL-0015 |
| Materialized as | [STD-0012 — Automation & IaC](../Standards/STD-0012-Automation-and-IaC.md) · this ADR is the adopting decision; the standing requirements now live in that standard (`ADR-0054` (B)→standard) |
| Scope | **Global** — an estate-wide documentation doc-type + build practice. |
| Date | 2026-07-29 |
| Supersedes | — Formalizes Improvement-Backlog **#7** (zero automation) + **#19** (DevOps / self-hosted git) into a model; **amends `ADR-0037`** (Documentation Standard — adds the `Automation/` doc-type); **expands `ADR-0043`** (the Build-Guide's Automation-onboarding *slot* now points at the doc-type). |
| Related | `ADR-0037` (Doc Standard — amended → v1.4) · `ADR-0043` (phased gated Build-Guides; the Automation-onboarding section) · `ADR-0044` (enterprise-first; certs anchor the skills) · `ADR-0041` (test-gated — idempotency is the automation gate) · `ADR-0032` (Oxidized = config-backup diagnostics) · **Charter Rule 16/17 (the Learning Rule)** · `Atlas-Improvement-Backlog` #7 + #19 · `Operations/Build-Order-and-Dependencies.md` **Phase 10 (Automation/IaC)** · `POL-0008` (one home per fact) · `POL-0001` (device is truth). |
| Evidence Status | **Decision / plan.** Nothing built; every automation artifact is 🟡 until it runs idempotently against a real device (`POL-0001`/`ADR-0041`). |

## Context

The operator wants **every device page-set to carry a page or two of automation scripts + how-tos** — infrastructure-as-code style: stand up an Azure environment from a file, build an entire device from a config file (bash / Ansible / Terraform), and not do everything by hand every time. Today the estate has **zero automation** (Backlog #7 — Ansible/Oxidized *designed*, not built), and a self-hosted Git + CI/CD DevOps capability is a *future* item (Backlog #19, sequenced at **Phase 10**).

What's missing is a **decided model**, so automation doesn't grow ad-hoc into the drift the estate keeps fighting. Four questions need answers before any device gets an automation page: **(a)** what gets automated vs hand-typed (the Learning-Rule tension — automation scripts *are* config, and Charter Rule 16/17 says the operator types learning-target config himself); **(b)** where the runnable code lives vs where the how-to lives (`POL-0008`); **(c)** which tools, and in what order; **(d)** how it appears as a repeatable per-device documentation element. The operator also asked, plainly, *"what are the main things people do with automation?"* — so the model **names the landscape** rather than assuming it.

## Decision

**Adopt a phased, cert-matched Automation / IaC model built on two distinct layers, reconciled with the Learning Rule.**

### 1. Two layers, two homes (`POL-0008`)
- **Per-device `Automation/` doc-type** — the device's automation **slice**: how-to pages + the device-specific scripts/playbooks + which estate modules it consumes. This is the "page or two per device" the operator asked for. **Amends the Documentation Standard (→ v1.4).**
- **Estate automation capability** — the shared runnable code + orchestration: a **self-hosted Git server** (Gitea/GitLab), a **CI runner**, shared **Ansible roles / Terraform modules / DSC configs**, and **Oxidized** config-backup. Owned centrally (`Operations/Automation/` + the self-hosted git repo — Backlog **#19**, **Phase 10**). The per-device `Automation/` **links** to it, never copies it.

### 2. Learning-Rule reconciliation (Charter 16/17) — the load-bearing rule
- **Plumbing & provisioning IS automated and lives in the repo:** golden images, cloud-init identity, service onboarding, config-backup (Oxidized), teardown/rebuild, and the IaC that stands up infrastructure. (Precedent already in-repo: the `Virtualization/Build-Guides/220` Ubuntu golden-image **companion `.sh`**.)
- **Learning-target config is hand-typed the *first* time** — that first pass is the skill the cert grades — **then optionally captured as automation once understood.** The principle: ***automate what you've already learned to do by hand.*** The device's `Automation/` page documents the automated form; the **Build-Guide still teaches the manual first pass** (GUI-primary, `POL`-house-rules).
- So an `Automation/` page never becomes a paste-the-answer shortcut around the learning; it's the "now do it repeatably" follow-on.

### 3. Full-stack, phased, cert-matched tooling (operator choice)
Adopt the **whole stack**, but introduce each tool **as the matching cert/phase lands** — not all at once (`ADR-0044` — certs anchor):

| Tool | What it does | Introduced with |
|---|---|---|
| **Oxidized** | Config backup → git; drift diff on change (GitOps, simplest form) | **First** — network devices; CCNA Dom-6 |
| **cloud-init + bash / PowerShell** | Provision a box from a file (identity, packages, services) | Already partly present (golden image); ongoing |
| **Ansible** | Idempotent config management over SSH/WinRM (Linux + Windows) | CCNP **ENAUTO** / general automation |
| **Terraform + Azure Bicep/ARM** | Declarative IaC — stand up / tear down an Azure env (+ Proxmox provider on-prem) | **AZ-104 / Phase H4** |
| **PowerShell DSC** | Windows desired-state (roles, GPO-as-code) | **AZ-800/801** |
| **Self-hosted Git (Gitea/GitLab) + CI runner** | GitOps: config → PR → test → deploy; the pipeline | **AZ-400** / Backlog #19 / **Phase 10** |

### 4. Per-device `Automation/` shape
A folder (like `Roles/`, `Changes/`): an index + how-to pages + the script/playbook files. Each artifact documents **purpose → what it automates → how to run → expected result → what it deliberately does *not* automate** (the hand-typed learning bits). It **cross-links** to (a) the Build-Guide's **Automation-onboarding** section (`ADR-0043` — the per-phase hook) and (b) the shared estate modules. Config commands feed the **Academy Command-Library** as always.

### 5. Enterprise-first, test-gated
Automation is scoped **as an enterprise runs it** (`ADR-0044`): GitOps for configs, idempotency, a **tested** teardown/rebuild (closes Backlog Tier-1 #3). Every automation artifact has a **positive + negative acceptance gate** (`ADR-0041`): it builds the intended thing **and** a re-run is idempotent (no drift, no double-apply) before it's ✅.

## Alternatives Considered
- **Just the Build-Guide's Automation-onboarding *section*, no dedicated doc-type.** Rejected — the operator wants "a page or two" per device; a single in-guide section can't hold multiple scripts + how-tos cleanly. The section stays as the *phase hook* and links to the new `Automation/` folder.
- **Central automation only, nothing per-device.** Rejected — loses the per-device learning slice + how-to the operator asked for. (The *runnable shared code* does stay central — that's the Decision-1 split.)
- **Adopt every tool at once.** Rejected — full-stack but **phased/cert-matched**; all-at-once buries the learning and front-loads tools before their cert.
- **Automate everything, including learning-target config.** Rejected — violates the Learning Rule; you'd skip the very skill the cert grades. Automate *after* the manual first pass.
- **Self-host git now vs GitHub + Actions.** Deferred to Backlog #19's own scoping — self-hosted (Gitea/GitLab) is the enterprise-real target (internal git ≠ public GitHub); GitHub Actions is the fallback CI. Not decided here.

## Consequences
- **Documentation Standard → v1.4** — new per-device **`Automation/`** doc-type added to the folder tree, the lifecycle table (authored *after* the manual build, as the repeatable form), and the elements list; the Build-Guide **Automation-onboarding** section now explicitly links to it. **Workflow → v1.4** (when/how the Automation pages are authored — after the first manual pass).
- **`ADR-Index` → v1.14** — new row (Global).
- **Backlog #7 + #19 annotated** — this ADR is the **model**; #7 (build the automation) and #19 (self-hosted git + CI) are the **execution owners**; **Phase 10** in `Build-Order-and-Dependencies` is where it sequences. A future `Devices/` folder for the git/CI host lands when #19 is scoped.
- **The device-replication wave inherits it** — every device page-set built from the DC template (MON01 → NPS01 → …) gets an `Automation/` **from the start**, so it's never retrofitted (operator: page-by-page, right the first time). Early devices may carry only the Oxidized config-backup hook until their later tools' certs land — a **gated stub** (`ADR-0043`), designed not empty.
- **WLC note (K6a):** the Standard already anticipates "a WLC from an autonomous AP" as an append-only phase — a controller/AP acquisition slots in as a new gated automation/build phase, not a rewrite.

## Review Trigger
- A tool proves low-value at the estate's scale → drop it (phased adoption makes this cheap).
- Self-hosting git proves too heavy → GitHub + Actions is the CI fallback (Backlog #19 decides).
- `Automation/` how-tos start duplicating the Command-Library or Build-Guide → tighten the ownership split (how-to + device script here; reusable commands in the Command-Library; the manual path in the Build-Guide).

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-29 | Created (operator ask: every device page-set should carry automation scripts + how-tos; IaC to stand up an Azure env or build a device from a config file). Adopts a **two-layer model** — a per-device **`Automation/` doc-type** (the slice + how-tos) + a **central estate capability** (self-hosted git/CI + shared Ansible/Terraform/DSC/Oxidized, Backlog #19 / Phase 10). Load-bearing **Learning-Rule reconciliation** (Charter 16/17): plumbing/provisioning automated + in-repo; learning-target config hand-typed first, then captured — *automate what you've learned to do by hand*. **Full-stack, phased, cert-matched** tooling (Oxidized → cloud-init/bash → Ansible → Terraform/Bicep → DSC → self-hosted git/CI), each anchored to its cert (`ADR-0044`). Test-gated on **idempotency** (`ADR-0041`). Amends `ADR-0037` (Standard → v1.4) + expands `ADR-0043`; formalizes Backlog #7/#19. |
