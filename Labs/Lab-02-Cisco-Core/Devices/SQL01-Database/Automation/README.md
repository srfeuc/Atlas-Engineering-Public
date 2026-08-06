---
Title: SQL01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass. 🟡 until idempotent.
Version: 0.1
Date: 2026-07-30
---

# SQL01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** SQL01's automation **slice** — how-tos + scripts — authored **after** the manual first build (build SQL by hand once to learn install/gMSA/TLS/backup; *then* make it repeatable). Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #7/#19). 🟡 until idempotent (`ADR-0041`). **Secrets/connection strings from the vault at run time — never in git** (`POL-0002`).

## Planned automation (designed, phased)

| Task | Tool | What it automates | Does NOT automate (hand-learned first) |
|---|---|---|---|
| **SQL install + config** | PowerShell **DSC** / **DBATools** (`dbatools`) | Unattended install, memory cap, TempDB, Windows-auth, gMSA service account, TLS bind | The first manual install (the AZ-800/DBA skill) |
| **Backup jobs** | DBATools / Agent job scripts in git | Native backups + copy-to-BKP01 + a scheduled **restore test** | The RPO/RTO decision (how often / retention) |
| **Login/role provisioning** | DBATools (`New-DbaLogin`/role scripts) | Recreate AD-group logins + least-priv roles idempotently | The access-model design (who gets what) |
| **Always On AG** | DBATools (`New-DbaAvailabilityGroup`) | Stand up / re-add the AG replica (Phase 7, `ADR-0046`) | The HA topology decision |

> 🔴 **Never automate credentials into git.** DBATools pulls the gMSA/connection context at run time; SQL logins (if any) come from the vault. And keep the **memory cap** in the config-as-code so a rebuild doesn't starve the host.

## How this fits the estate
- Roadmap **Phase 8**, after the manual build. Estate: Build-Order **Phase 10** (`ADR-0048`). Cert anchor: DSC/DBATools (AZ-800/801), backup automation (AZ-801/DBA).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — `Automation/` slice for SQL01 (`ADR-0048`): DSC/DBATools install+config, backup+restore-test jobs, login/role provisioning, and the Always On AG stand-up — with the "no creds in git" + "keep the memory cap in code" boundaries. |
