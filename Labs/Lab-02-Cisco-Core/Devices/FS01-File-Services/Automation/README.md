---
Title: FS01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# FS01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** This folder holds FS01's automation **slice** — how-tos + device-specific scripts — authored **after** the manual first pass (build the shares/DFS/FSRM by hand once to learn AZ-800 file services; *then* make it repeatable). Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #7/#19). 🟡 until idempotent (`ADR-0041`).

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | What it does NOT automate (hand-learned first) |
|---|---|---|---|
| **File-server role install** | PowerShell **DSC** | `Install-WindowsFeature` FS/FSRM/DFS; base config | The first manual role build (the AZ-800 skill) |
| **Shares + ACL-as-code** | PowerShell (`New-SmbShare` + `Set-Acl`) in git | Recreate the shares + their **AGDLP group** ACLs identically on rebuild | The **AGDLP design** (which group gets which share — the authorization logic, `ADR-0021`) |
| **FSRM templates-as-code** | PowerShell (`New-FsrmQuota`/`-FileScreen`) | Version + apply quota/screen templates | The policy (how big / what's screened) |
| **DFS namespace/targets** | PowerShell (`New-DfsnRoot`/`-DfsnFolderTarget`) | Recreate the namespace + targets | The namespace design |
| **Drive maps** | GPO (declarative) — the `BATlogin` module | Push mapped drives to the client fleet | — |

> 🔴 **Never automate the *data* or its permissions blindly** — ACL-as-code recreates the *group* ACLs (auditable), but the AGDLP group *design* and the data itself stay under human control. And the shares live on the 8 TB external (`Considerations.md`) — automation must mount-by-serial, not assume a drive letter.

## How this fits the estate
- **Phase alignment:** Roadmap **Phase 6**, after the manual build. Estate sequencing: Build-Order **Phase 10** (`ADR-0048`).
- **Cert anchor:** DSC + storage-as-code (AZ-800/801), GPO drive maps (AZ-800).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created as the `Automation/` slice for FS01 (`ADR-0048`) — planned DSC role install, shares/ACL-as-code (groups only), FSRM + DFS as-code, and GPO drive maps, each with its learning boundary. Foregrounds "automate the group ACLs, never the AGDLP design or the data," and the mount-by-serial rule for the 8 TB. |
