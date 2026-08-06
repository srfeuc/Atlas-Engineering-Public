---
Title: Automation and IaC — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §11. The automation model, the estate capability, and the IaC discipline — honestly marked mostly-designed.
---

# Automation and IaC — Full Directory

> **The deep version of [Source-of-Truth §11](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#11-automation-and-iac).** The router points you at the model; this page is the *encyclopedia* — where automation lives, the self-hosted capability that will run it, and what actually makes a build "infrastructure as code." Keep the router in a tab; come here for the whole picture.
>
> 🔴 **Honest status up front (`POL-0001`/`POL-0006`):** this domain is **mostly designed, barely built.** The IaC capability (CNT01 + self-hosted git/CI) is 📋 not built; the pipelines are authored. Nothing here is ✅ on intent — the concept pages are marked "the pipeline is planned," and so is this page.

## On this page

1. [The model](#1-the-model) — two homes for automation
2. [The estate capability](#2-the-estate-capability) — CNT01 + self-hosted git/CI
3. [Per-device automation](#3-per-device-automation)
4. [The IaC discipline](#4-the-iac-discipline) — idempotency · GitOps · policy-as-code
5. [Playbooks vs Runbooks](#5-playbooks-vs-runbooks)
6. [Commands, concepts and the Academy](#6-commands-concepts-and-the-academy)
7. [The decisions (ADRs)](#7-the-decisions-adrs)

---

## 1. The model

Automation has **two homes** ([`ADR-0048` Automation & IaC Model](../../00-Atlas-Foundation/Decisions/ADR-0048-Automation-and-IaC-Model.md), materialized as [`STD-0012`](../../00-Atlas-Foundation/Standards/STD-0012-Automation-and-IaC.md), under [`POL-0015`](../../00-Atlas-Foundation/Policies/POL-0015-Engineering-and-Build-Discipline.md)):

- **Per-device `Automation/`** — each device folder carries its own automation doc-type: the scripts and how-tos specific to that host.
- **The estate IaC capability** — shared, runnable automation code + CI, hosted on the self-hosted git/CI box (CNT01). This is where cross-device pipelines and the config-as-code renderers live.

The governing discipline: **automate what you've *learned*** (not what you're still figuring out), on a **phased, cert-matched ladder**, and **idempotent before it's ✅** — a script that isn't safe to run twice isn't done.

## 2. The estate capability

| Host | Role | Status |
|---|---|---|
| [`CNT01-Container-Host`](../../Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/) | The self-hosted **git + CI** capability — the home for shared automation code, pipelines, and GitOps (the [Backlog **#19**](../../00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md) estate capability) | 📋 Authored, not built |

Until CNT01 exists, automation is per-device scripts + the CI already running against the repo (`gitleaks` + link-check + LF in [`.github/workflows/atlas-checks.yml`](../../.github/workflows/atlas-checks.yml)). The self-hosted GitOps model (Oxidized → git → PR → deploy) lands with the host.

## 3. Per-device automation

Every device's standard page-set includes an `Automation/` folder ([`STD-0005` Device Documentation](../../00-Atlas-Foundation/Standards/STD-0005-Device-Documentation.md)); browse the roster under [`Devices/`](../../Labs/Lab-02-Cisco-Core/Devices/). Automation for a *specific* device's facts lives on that device (`POL-0008`); this Academy page and the [concepts](#6-commands-concepts-and-the-academy) explain the cross-device *patterns*.

## 4. The IaC discipline

What actually makes a build "infrastructure as code" rather than "a script" — taught in full by [Ansible IaC Device Provisioning](../Concepts/Ansible-IaC-Device-Provisioning.md):

- **Idempotency is the gate.** Terraform provisions a VM, Ansible configures the role, and **run #2 produces an empty diff.** A change that isn't safe to re-apply hasn't met the bar.
- **GitOps catches drift.** Oxidized backs up device configs → git → PR → deploy, so a hand-edit on a box **diffs against the committed file** and is caught (the seeded [GitOps & config drift](../Concepts/) concept).
- **Policy-as-code.** MKT01 renders its east-west filter from the [`Atlas-East-West-Allowed-Flows-Matrix`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md); SW01's DAI bindings render from NetBox — the config is *generated from the source of truth* (`POL-0004`), never hand-typed.

## 5. Playbooks vs Runbooks

A deliberate `ADR-0048` scope line: the Academy's **Playbooks** (*"it's broken / I need to operate it"*) exist **now**; **Runbooks** — the *"how do I automate this technique"* set (JSON/Python/PowerShell/IaC/Linux-CLI) — are the **deferred sibling that arrives with the automation work.** Don't file an automation how-to as a Playbook.

## 6. Commands, concepts and the Academy

- 🎓 **Concepts (why it works)** — [Ansible IaC Device Provisioning](../Concepts/Ansible-IaC-Device-Provisioning.md) (idempotency / the smallest end-to-end IaC) · the seeded **GitOps & config drift** target in the [Concepts index](../Concepts/).
- 🖥️ **Commands** — [PowerShell-Tier0](../Command-Library/PowerShell-Tier0.md) · [Linux](../Command-Library/Linux.md) (the runnable side deepens here as the capability is built).
- 🏅 **Cert alignment** — AZ-802 (Hyper-V for the exam vs Proxmox in the lab) · the automation ladder is cert-matched per `ADR-0048`.

## 7. The decisions (ADRs)

- [`ADR-0048`](../../00-Atlas-Foundation/Decisions/ADR-0048-Automation-and-IaC-Model.md) — the Automation & IaC model (two homes · automate-what-you've-learned · idempotent-before-✅) → materialized as [`STD-0012`](../../00-Atlas-Foundation/Standards/STD-0012-Automation-and-IaC.md).
- Estate capability (self-hosted git/CI, GitOps model, CI-runner placement) — [Backlog **#19**](../../00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md) (an ADR is owed; not yet written).

## Related

[Source-of-Truth router §11](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#11-automation-and-iac) (the quick view) · [`ADR-0048`](../../00-Atlas-Foundation/Decisions/ADR-0048-Automation-and-IaC-Model.md) · [`STD-0012`](../../00-Atlas-Foundation/Standards/STD-0012-Automation-and-IaC.md) · [`POL-0015`](../../00-Atlas-Foundation/Policies/POL-0015-Engineering-and-Build-Discipline.md) · [Servers and Compute directory](./Servers-and-Compute.md) · [Governance and Decisions directory](./Governance-and-Decisions.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-04. First cut — the exhaustive twin of Source-of-Truth §11: the two-homes automation model (`ADR-0048`→`STD-0012`), the self-hosted git/CI capability (CNT01, #19, 📋 not built), the per-device `Automation/` doc-type, the IaC discipline (idempotency · GitOps drift · policy-as-code from the SoT), and the Playbooks-vs-Runbooks scope line — honestly marked mostly-designed. Built to complete the Academy Directory. |
