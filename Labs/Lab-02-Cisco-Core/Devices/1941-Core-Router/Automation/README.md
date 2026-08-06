---
Title: 1941 — Automation (config-backup + network automation)
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Automation
Status: 📋 Designed stub (ADR-0048). Networking variant = config-versioning + Ansible, NOT DSC. Authored after the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# 1941 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** The 1941's automation **slice** — how-tos + device-specific artifacts — authored **after** the manual CLI build (automate what you have learned by hand). The **runnable shared code** (Oxidized, the Ansible network roles, the self-hosted git/CI) is the **estate capability** owned centrally (`../../CNT01-Container-Host/` + `../../../Operations/Automation/`; Backlog #19 / Phase 10); this folder **links** to it. 🔴 **Networking variant:** config-versioning + Ansible network automation — **not** PowerShell DSC.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **Config backup** | **Oxidized** (on SRV01 → git) | Pull the running-config on change → git; drift shows as a diff | The CLI build itself (the CCNA skill — `Build-Guide.md`) |
| **Config render from source of truth** | **Ansible** (`ios_*` / netmiko) | Render interface/OSPF/hardening config **from NetBox** (read-only `show` playbook first) | Designing the routing/segmentation (the CCNP skill) |
| **Read-only verify** | Ansible playbook | Batch the `Diagnostics` `show`-battery fleet-wide (OSPF/routes/SSH) | Interpreting the output |

## How this fits the estate
- **Phase alignment:** lands at Build-Order **Phase 10** (Automation/IaC, `ADR-0048`) after the manual build is proven; Oxidized can start at Phase 5 (config-versioning on SRV01).
- **GitOps:** Oxidized → the self-hosted git (**CNT01**, Backlog #19) → review/PR → deploy.
- **Cert anchor:** Oxidized / SNMP / syslog (CCNA Dom-6) · Ansible network automation (**CCNP ENAUTO**).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created as the designed `Automation/` stub for the 1941 (`ADR-0048`, networking variant) — Oxidized config-backup, Ansible config-render-from-NetBox + a read-only `show` verify playbook; the "does NOT automate" learning boundary (the CLI build + routing design stay hand-learned first). Config-versioning + Ansible, not DSC. |
