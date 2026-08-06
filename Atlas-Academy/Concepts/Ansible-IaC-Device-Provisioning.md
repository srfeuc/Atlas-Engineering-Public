---
Title: Automation & IaC — provisioning a device from a config file (Ansible + Terraform; Proxmox + a Hyper-V variant)
Path: Atlas-Academy/Concepts
Status: 🟢 Academy concept/lab module (D6 / `ADR-0032` concept layer). Automation **A1** — the concrete "build a device from a config file" lab behind `ADR-0048`. 📋 The pipeline is **planned, not built** (`POL-0001`) — the estate git/CI capability (CNT01 / **#19**) doesn't exist yet.
Version: 1.0
Date: 2026-07-30
---

# Provisioning a device from a config file — an Ansible + IaC lab

<!-- provenance -->
> **Atlas Academy — Concepts.** A "why it works" module written as a **hands-on lab**. Every claim points at a **real Atlas artifact** (`Academy/README` design principle). The real example is `ADR-0048` (the estate's Automation & IaC model) + the **CNT01** container host (**Backlog #19** — the self-hosted git/CI + GitOps home). Per the operator (2026-07-30): "use Ansible to set up a device on another Proxmox or Hyper-V box." 📋 planned — nothing here is device-verified.

> **The gap this closes:** clicking through a hypervisor console builds *one* box you can't reproduce. **Infrastructure as code** makes the box a file in git — reviewable, repeatable, and self-documenting. This lab is the smallest end-to-end version of the `ADR-0048` vision: a VM and its role, stood up from a committed config with no console clicks.

## The Concept

**IaC = you declare the desired state of a machine in a file in git, a tool converges the machine to that state, and the git history becomes the record of what the machine is.** "Build a device from a config file" is the literal `ADR-0048` goal.

- **Two layers (`ADR-0048`).** Each device carries its own **`Automation/`** doc (its scripts + how-tos); the **estate capability** lives on **CNT01** (#19) — self-hosted **Gitea/GitLab + a CI runner + GitOps**.
- **Provision vs configure — two tools, one pipeline.** **Terraform** (the `proxmox` provider) or `qm`/cloud-init **creates** the VM; **Ansible** **configures** the role inside it. On Windows/Hyper-V the same split maps to **Hyper-V VM creation** + **DSC or Ansible-over-WinRM** for config — which is the **AZ-802** objective (Hyper-V, not Proxmox).
- **Idempotency is the acceptance gate (`ADR-0041`/`ADR-0048`).** Run the playbook twice; the second run must report **no changes**. That "empty diff on the second run" is the same load-bearing proof as NetBox's generate-don't-type render — if run #2 changes anything, it's a script, not IaC.
- **GitOps closes the loop.** Config lives in git → a pull request → the runner deploys. Drift (someone hand-edits a box) shows up because reality no longer matches the file.

## The Atlas Example (real artifacts) — the lab (📋 proposed)

- **Target:** stand up a **throwaway lab VM on PVE02/EQR6** (or a **Hyper-V** box) entirely from a committed config — zero console clicks — then tear it down and rebuild it identically.
- **Flow:** config in git (CNT01 / #19) → **CI runner** → **Terraform** `proxmox` provider creates the VM from a **cloud-init** template → **Ansible** playbook installs + configures the role (a Linux service, or a Windows feature via **WinRM/DSC**) → **idempotency check** (re-run = empty diff) → evidence lands in the device's **`Build-Record`**.
- **GitOps tie-in — already sketched for the network:** **Oxidized** backs up device configs → git → PR → deploy is the estate pattern; the **MKT01** flagship ("render the RouterOS east-west filter from the flows matrix — policy-as-code") and the **SW01** DAI-from-NetBox render are the same idea applied to network gear.
- **Hyper-V variant (why do it twice):** provision the same role on **Hyper-V** for **AZ-802** using `New-VM` + **DSC** (or Ansible/WinRM). Seeing one concept implemented on two hypervisors is the Academy "same concept two ways cements it" principle.
- **The boundary (`ADR-0048` Learning-Rule + the KALI01 rule):** **automate the box, never the attacks**, and **automate what you have already built by hand once** — IaC encodes understanding, it isn't a substitute for it.

## What Could Go Wrong (the real traps)

- **A non-idempotent playbook.** If run #2 makes changes, you wrote a script, not IaC — the empty-diff gate is what catches it.
- **Secrets in git.** Config-as-code must pull credentials from a vault (**Vaultwarden** / `ansible-vault`), never plaintext — `POL-0001`'s no-live-secrets rule applies to code as much as docs.
- **Over-scoped provider token.** The Terraform → Proxmox API token grants too much; scope it to the one node/pool it needs.
- **Drift.** A hand-edit on the box makes git a lie; GitOps + an Oxidized/`ansible --check` diff surfaces it instead of hiding it.
- **Windows prerequisites.** DSC-pull / WinRM needs the trust + an **ICA01** cert in place first — the Hyper-V variant depends on the PKI being up.

## How to Explain This in an Interview

*"I treat my infrastructure as code. The VM and its configuration live in a git repo; a CI runner uses Terraform to create the VM on Proxmox and Ansible to configure the role inside it, and the test that it's really IaC is idempotency — running it twice makes zero changes. I deliberately do it two ways, Proxmox for my always-on estate and Hyper-V with DSC for the AZ-802 objective, and the same GitOps pattern backs up my switch and router configs, so if someone hand-edits a device it shows up as drift against the committed file. The rule I hold to is that I automate things I've already built by hand — the code encodes understanding, it doesn't replace it."*

## Related

- `00-Atlas-Foundation/Decisions/ADR-0048` (Automation & IaC model — the two layers) · `ADR-0041` (test-gated / idempotency discipline).
- `Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/` (**#19** — the self-hosted git/CI + GitOps home) · every device's `Automation/` doc · `Devices/MKT01-East-West-Firewall/` (policy-as-code flagship) · `Devices/SW01-Access-Switch/` (DAI-from-NetBox render).
- `Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (the host these provision *onto*) · `Atlas-Academy/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md` (→ AZ-802 Hyper-V) · `Concepts/README.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Authored (operator ask — "use Ansible to set up a device on another Proxmox or Hyper-V box via automation / IaC; a good Academy lab"). Automation **A1**. Grounded in `ADR-0048` (per-device `Automation/` + the CNT01/#19 estate capability), the Terraform-provisions / Ansible-configures split, the **idempotency empty-diff gate** (`ADR-0041`), the existing GitOps sketch (Oxidized→git→PR; MKT01 policy-as-code; SW01 DAI-from-NetBox), and the Hyper-V/DSC AZ-802 variant. All steps 📋 proposed (`POL-0001`). |
