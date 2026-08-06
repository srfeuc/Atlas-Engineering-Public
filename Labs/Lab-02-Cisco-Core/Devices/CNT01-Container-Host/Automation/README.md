---
Title: CNT01 — Automation (the estate automation-capability home)
Path: Labs/Lab-02-Cisco-Core/Devices/CNT01-Container-Host/Automation
Status: 📋 PROPOSED / designed stub (`ADR-0048`). CNT01 IS the estate automation-capability home (Backlog #19); does NOT automate yet — built after the manual first pass. Still ⬜.
Version: 0.2
Date: 2026-07-30
---

# CNT01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** CNT01 **IS the estate's automation-capability home** (**Backlog #19**): the **CI runner**, the **shared Ansible/Terraform**, and the **self-hosted git** (Gitea/GitLab) all live here. **Every other device's `Automation/` folder links UP to this one** — this is the estate source-of-truth + CI/CD host, not a per-device slice. It **does NOT automate yet:** it is 🔴 gated on the **Backlog #19 estate-capability ADR** (self-host-vs-GitHub · the GitOps model · where the CI runner lives) + placement (#20), and built **after the manual first pass**. 📋 until GATE-0 clears, then hand-built before it is captured as idempotent IaC (`ADR-0041`). Still ⬜.

## Planned automation (designed, phased — after GATE-0 + the manual first pass)

| Task | Tool | What it would automate | Does NOT automate (hand-learned first) |
|---|---|---|---|
| **Docker/Podman install/config** | Ansible | Install + configure the Linux container runtime | The first manual runtime stand-up |
| **Gitea/GitLab + ICA01 cert enrol/bind** | Ansible / compose | Stand up self-hosted git + enrol/bind the published-service TLS cert idempotently | The manual git stand-up + enrol from ICA01 (the PKI skill) |
| **GitOps device-config pipeline** | CI runner + Ansible | Oxidized → git → review/PR → deploy, referencing NetBox as source-of-truth | The first manual pipeline wiring (the automation skill) |
| **Ansible/Terraform pipelines** | the estate CI capability | Run estate-wide IaC pipelines (Phase 10) | The pipeline design itself (per the #19 ADR) |
| **CI runner onboarding** | the estate CI capability | Register CNT01 as the estate runner host | The runner-placement decision (`ADR-0048` / #19) |
| **Windows-container slice** | DSC / Ansible | Stand up the AZ-800/801 Windows-container slice (R410) | The Windows-slice scope/placement (#20) |

> 🔴 **Nothing is automated until the #19 ADR is written** — the estate-capability shape (self-host posture, GitOps model, runner placement) drives the tooling. Automate the *plumbing* after the manual pass, never the *scope* decisions (`Considerations.md`).

## How this fits the estate
- Roadmap **Phase 5/7**, after the manual build. Estate: Build-Order **Phase 10** (`ADR-0048`) → `../../../Operations/Build-Order-and-Dependencies.md`. CNT01 IS the estate automation-capability home: **Backlog #19** (self-hosted git + CI). Cert anchor: **AZ-400 + CCNA Dom-6** (DevOps / automation) primary, **AZ-800/801** for the Windows slice (→AZ-802 2026-09-30).

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-30. Decisions baked in (operator 2026-07-30): platform=hybrid; purpose=estate git/CI (#19). Reframed: CNT01 IS the estate automation-capability home — the CI runner + shared Ansible/Terraform + self-hosted git live here, and every other device's `Automation/` links up to it. Planned tasks retargeted to the Linux git/CI stack + GitOps + the Windows slice. Kept a designed stub, still ⬜ (built after the manual first pass). Cert anchor → AZ-400 + CCNA Dom-6 (+ AZ-800/801 for the Win slice). |
| 0.1 | 2026-07-30. Created — `Automation/` slice for CNT01 (`ADR-0048`): the container host as the natural IaC/CI home, explicitly "does NOT automate yet — gated on the platform decision (`ADR-0045`)"; planned tasks branch on Win-vs-Linux; links the estate capability (Backlog #19). |
