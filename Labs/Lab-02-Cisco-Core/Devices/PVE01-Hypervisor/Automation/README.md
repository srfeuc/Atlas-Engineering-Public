---
Title: PVE01 — Automation (Proxmox IaC — Terraform + Ansible)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor/Automation
Status: 📋 Designed stub (ADR-0048). Hypervisor variant = Terraform (Proxmox provider) + Ansible, NOT DSC. Authored after the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# PVE01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** PVE01's automation **slice** — how-tos + host-specific artifacts — authored **after** the manual build (automate what you have learned by hand; Learning Rule Charter 16/17). The **runnable shared code** (the Terraform modules, shared Ansible roles, the self-hosted git/CI) is the **estate capability** owned centrally (`../../CNT01-Container-Host/` + `../../../Operations/Automation/`; Backlog #19 / Phase 10); this folder **links** to it. 🔴 **Hypervisor variant:** Terraform (Proxmox provider) + Ansible — **not** PowerShell DSC.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **VM provisioning** | **Terraform** (`telmate/proxmox` or `bpg/proxmox` provider) | Declare VMs/clones from the golden templates (`TPL-WIN2025`/`TPL-UBUNTU2604`) → reproducible on-demand spin-up | Building the golden images by hand (the OS/Sysprep skill — `211`/`220`) |
| **Guest config** | **Ansible** (+ cloud-init) | Post-clone identity, packages, join, hardening on the spin-up guests | Designing the role/segmentation (the systems-engineering skill) |
| **Host config as code** | **Ansible** (`community.general.proxmox*`) | `/etc/network/interfaces` render, storage/repo/no-sub-patch, ACLs — idempotent host baseline | The first manual Proxmox stand-up (`201`–`206`) |
| **Migration / bring-up** | **the `221` runbook** | The dependency-ordered PBS backup→restore move to PVE02 — **the estate's IaC + Game-Day exercise** | The USN-rollback / VM-GenerationID reasoning (learn it once) |

## How this fits the estate
- **Phase alignment:** lands at Build-Order **Phase 10** (Automation/IaC, `ADR-0048`) after the manual build is proven.
- **GitOps:** Terraform state + Ansible playbooks → the self-hosted git (**CNT01**, Backlog #19) → review/PR → apply.
- **The `221` migration is the flagship IaC exercise** for this host (Terraform provisions PVE02, Ansible configures, idempotency = the gate). Teaching companions: `Atlas-Academy/Concepts/Ansible-IaC-Device-Provisioning.md` (A1) + `Proxmox-VM-Migration-and-Host-Bring-Up.md` (V1).
- **Cert anchor:** IaC / Ansible (CCNP ENAUTO-adjacent) · AZ-801 (Hyper-V/clustering concepts transfer to the Proxmox layer).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) as the designed `Automation/` stub for PVE01 (`ADR-0048`, hypervisor variant) — Terraform VM provisioning from the golden templates, Ansible guest + host-as-code config, the `221` migration as the flagship IaC/Game-Day exercise; the "does NOT automate" learning boundary (golden-image build + manual stand-up stay hand-learned). Terraform/Ansible, not DSC. |
