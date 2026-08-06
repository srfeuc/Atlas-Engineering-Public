---
Title: WSUS01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass. 🟡 until idempotent.
Version: 0.1
Date: 2026-07-30
---

# WSUS01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** WSUS01's automation **slice** — how-tos + scripts — authored **after** the manual first build. Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #7/#19). 🟡 until idempotent (`ADR-0041`).

## Planned automation (designed, phased)

| Task | Tool | What it automates | Does NOT automate (hand-learned first) |
|---|---|---|---|
| **WSUS role install + post-config** | PowerShell **DSC** / `Install-WindowsFeature` + `wsusutil` | Role, content dir, DB, products/classifications | The first manual sync + product selection (the AZ-800 skill) |
| **Approval-ring automation** | PowerShell (`Get/Approve-WsusUpdate`) | Auto-approve to **pilot**, hold for broad; scheduled | The **approval judgment** for broad (keep a human gate) |
| **Cleanup / decline-superseded** | scheduled PowerShell (`Invoke-WsusServerCleanup`) | Keep the content store bounded | — |
| **Client targeting GPO** | GPO (declarative) | WUServer + target-group by OU | The targeting design |

> 🔴 **Keep the broad-ring approval a human gate** — auto-approving everything defeats the ring model (`Considerations.md`). Automate *pilot* approval + cleanup, not the broad go/no-go.

## How this fits the estate
- Roadmap **Phase 5**, after the manual build. Estate: Build-Order **Phase 10** (`ADR-0048`). Cert anchor: DSC (AZ-800/801), scripted update lifecycle (AZ-800/801).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — `Automation/` slice for WSUS01 (`ADR-0048`): DSC role install, pilot-approval + cleanup automation, targeting GPO — with the "broad approval stays a human gate" boundary. |
