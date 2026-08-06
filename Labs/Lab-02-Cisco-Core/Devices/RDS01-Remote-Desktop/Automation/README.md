---
Title: RDS01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass. 🟡 until idempotent.
Version: 0.1
Date: 2026-07-30
---

# RDS01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** RDS01's automation **slice** — how-tos + scripts — authored **after** the manual first build. Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #19). 🟡 until idempotent (`ADR-0041`).

## Planned automation (designed, phased)

| Task | Tool | What it automates | Does NOT automate (hand-learned first) |
|---|---|---|---|
| **RDS role install + deployment** | PowerShell **DSC** / `Install-WindowsFeature` + `New-RDSessionDeployment` | Roles, single-host deployment, collection scaffold | The first manual role deploy (the AZ-800 RDS skill) |
| **RemoteApp / collection publishing** | PowerShell (`New-RDRemoteApp`, `Set-RDSessionCollectionConfiguration`) | Publish apps + collection settings declaratively | The **choice of what to publish** + access-group design |
| **Certificate binding** | PowerShell (`Set-RDCertificate`) | Bind the ICA01 cert to Gateway/RDWeb/RDP | The manual enrol from ICA01 (the PKI skill) |
| **Session-lockdown GPO** | GPO (declarative) | Redirection/limits/hardening by OU | The lockdown design + the T0-exclusion decision |

> 🔴 **Keep CAP/RAP on NPS01, not scripted onto the host** — authorization is the estate policy home (`ADR-0029`, `Considerations.md`). Automate the RDS deployment + publishing, not a local authorization store.

## How this fits the estate
- Roadmap **Phase 7**, after the manual build. Estate: Build-Order **Phase 10** (`ADR-0048`). Cert anchor: DSC + RDS deployment (AZ-800/801 (→AZ-802 2026-09-30)), cert binding (AZ-800/801 (→AZ-802 2026-09-30) · Security+ PKI).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — `Automation/` slice for RDS01 (`ADR-0048`): DSC role/deployment, RemoteApp/collection publishing, ICA01 cert binding, session-lockdown GPO — with the "CAP/RAP stays on NPS, not scripted locally" boundary. |
