---
Title: NPS01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass — automate what you've learned by hand (Learning Rule, Charter 16/17). 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-29
---

# NPS01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** This folder holds NPS01's automation **slice** — how-tos + device-specific scripts — authored **after** the manual first pass, never as a shortcut past the learning (you build NPS by hand once so you learn RADIUS/NPS; *then* you make it repeatable). Runnable shared code (roles/modules, CI/git) = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #7/#19). 🟡 until idempotent (`ADR-0041`).

## Planned automation (designed, phased — `ADR-0048` tooling ladder)

| Task | Tool | What it automates | What it does NOT automate (hand-learned first) |
|---|---|---|---|
| **NPS install + config** | PowerShell **DSC** (Windows tier) | `Install-WindowsFeature NPAS`, AD registration, RADIUS clients, network policies | The *first* manual NPS build (Roadmap Phases 1–3) — the 70-741/CCNA RADIUS skill |
| **Policy-as-code** | PowerShell / `netsh nps export` in git | Version the network policies + RADIUS clients so they rebuild identically; drift diff | Designing the AD-group→privilege policy (the authorization logic) |
| **RADIUS-client rollout** | Ansible (network side) | Point MKT01/SW01/1941 at NPS with their secrets (from a vault, not git) | The per-platform AAA config the CCNA objective grades (do one by hand first) |
| **Cert enrolment** | autoenroll GPO / PowerShell | Renew/enrol the RAS-and-IAS-Server cert from ICA01 | The AD CS ceremony + template design (PKI skill) |

## How this fits the estate
- **Phase alignment:** Roadmap **Phase 6**, after the manual RADIUS build is proven. Estate sequencing: Build-Order **Phase 10** (`ADR-0048`).
- **Secrets:** RADIUS shared secrets + any bind creds come from the vault at run time — **never committed** (`POL-0002`).
- **Cert anchor:** DSC (AZ-800/801), Ansible (CCNP ENAUTO), policy-as-code/CI (AZ-400-adjacent).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the designed `Automation/` stub for NPS01 (`ADR-0048`) — planned DSC NPS-install, policy-as-code, Ansible RADIUS-client rollout, and cert autoenrol, each with its "does NOT automate" learning boundary. Filled after the manual build (Roadmap Phase 6). |
