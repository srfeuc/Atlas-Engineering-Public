---
Title: PVE02 — Automation (Proxmox IaC — Terraform + Ansible)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor/Automation
Status: 📋 Designed stub (ADR-0048). Hypervisor variant = Terraform (Proxmox provider) + Ansible, NOT DSC. The 221 migration is the flagship IaC exercise. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# PVE02 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** PVE02's automation **slice** — how-tos + host-specific artifacts — authored **after** the manual build (automate what you have learned by hand). The **runnable shared code** (Terraform modules, shared Ansible roles, the self-hosted git/CI) is the **estate capability** owned centrally (`../../CNT01-Container-Host/` + `../../../Operations/Automation/`; Backlog #19 / Phase 10); this folder **links** to it. 🔴 **Hypervisor variant:** Terraform (Proxmox provider) + Ansible — **not** PowerShell DSC.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **Host provisioning** | **Terraform** (Proxmox provider) | Declare PVE02's VMs/clones from the golden templates → reproducible always-on stack | The first manual EQR6 stand-up (`221` Phase 1) |
| **Guest config** | **Ansible** (+ cloud-init) | Post-restore identity, packages, join, hardening on the migrated guests | The dependency-order reasoning + the DC USN-rollback method (learn it once) |
| **Host config as code** | **Ansible** (`community.general.proxmox*`) | `/etc/network/interfaces` render (mirror PVE01), storage/repo/no-sub, ACLs — idempotent host baseline | The manual Proxmox install |
| **Migration / bring-up** | **the `221` runbook** | The dependency-ordered PBS backup→restore move off the R410 — 🔴 **the estate's flagship IaC + first real Game-Day restore test** | The idempotency gate (a re-run must be a no-op) |

## How this fits the estate
- **The `221` migration is the flagship exercise** (operator ask — "act as if EQR6 is already here — plan the update / VM migration"): Terraform provisions, Ansible configures, **idempotency = the gate** (`ADR-0041`). Teaching companions: `Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (V1) + `Ansible-IaC-Device-Provisioning.md` (A1).
- **Phase alignment:** Build-Order **Phase 10** (`ADR-0048`) after the manual build is proven. **GitOps:** state + playbooks → the self-hosted git (**CNT01**, #19) → PR → apply.
- **Cert anchor:** IaC / Ansible (CCNP ENAUTO-adjacent) · AZ-801 (Hyper-V/clustering/backup concepts transfer).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) as the designed `Automation/` stub for PVE02 (`ADR-0048`, hypervisor variant) — Terraform host/VM provisioning, Ansible guest + host-as-code, and the `221` migration as the flagship IaC + Game-Day exercise; the "does NOT automate" learning boundary. Terraform/Ansible, not DSC. |
