---
Title: WAC01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass. 🟡 until idempotent.
Version: 0.1
Date: 2026-07-30
---

# WAC01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** WAC01's automation **slice** — how-tos + scripts — authored **after** the manual first build. Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #19). 🟡 until idempotent (`ADR-0041`).

## Planned automation (designed, phased)

| Task | Tool | What it automates | Does NOT automate (hand-learned first) |
|---|---|---|---|
| **WAC gateway install + config** | PowerShell **DSC** / `msiexec` + `Set-WACGateway` | Install (gateway mode, 443), extension set, service config | The first manual install + cert bind (the AZ-800 skill) |
| **ICA01 cert bind** | PowerShell (cert request + `netsh http`/WAC cert API) | Enrol + bind the gateway cert idempotently | The manual enrol from ICA01 (the PKI skill) |
| **Node onboarding** | PowerShell (WAC connections import) | Add the estate's managed nodes in bulk | The **Tier-0 delegation model** decision (Kerberos vs CredSSP scoping) |
| **Access lockdown** | GPO + firewall/ACL (declarative) | PAW-only 443 rule + Tier-0 role mapping | The **access-policy decision** (who is Tier-0) |

> 🔴 **The Tier-0 boundary stays a human decision** — automate the *plumbing* (install, cert, node import), not the *who-can-reach-Tier-0* policy (`Considerations.md`, `ADR-0021`). Never script an unconstrained-CredSSP delegation.

## How this fits the estate
- Roadmap **Phase 6**, after the manual build. Estate: Build-Order **Phase 10** (`ADR-0048`). Cert anchor: DSC + WAC deployment (AZ-800/801 (→AZ-802 2026-09-30)); Arc onboarding automation lands with Phase 11.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — `Automation/` slice for WAC01 (`ADR-0048`): DSC gateway install, ICA01 cert bind, node onboarding, access-lockdown GPO/ACL — with the "Tier-0 access policy + delegation stays a human decision" boundary. |
