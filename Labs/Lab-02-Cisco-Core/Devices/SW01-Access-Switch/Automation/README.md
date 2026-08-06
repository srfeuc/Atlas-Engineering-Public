---
Title: SW01 — Automation (config-backup + network automation)
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Automation
Status: 📋 Designed stub (ADR-0048). Networking variant = config-versioning + Ansible, NOT DSC. Authored after the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# SW01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** SW01's automation **slice** — how-tos + device-specific artifacts — authored **after** the manual CLI build (automate what you have learned by hand). The **runnable shared code** (Oxidized, Ansible network roles, the self-hosted git/CI) is the **estate capability** owned centrally (`../../CNT01-Container-Host/` + `../../../Operations/Automation/`; Backlog #19 / Phase 10); this folder **links** to it. 🔴 **Networking variant:** config-versioning + Ansible — **not** PowerShell DSC.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **Config backup** | **Oxidized** (on SRV01 → git) | Pull the running-config on change → git; drift shows as a diff | The CLI build itself (the CCNA skill — `Build-Guide.md`) |
| **DAI `STATIC-HOSTS` render** | **Ansible ← NetBox** | Generate the DHCP-snooping/DAI binding list **from NetBox** (the structural fix for the hand-typed "Pi01 mystery", `POL-0004`) | Designing the L2-security model (the skill) |
| **VLAN / port config render** | **Ansible** (`ios_*`) | Render VLAN + access/trunk port config from NetBox; read-only `show` verify playbook first | Designing the VLAN/trunk/STP topology (the CCNA/CCNP skill) |

## How this fits the estate
- **Phase alignment:** Oxidized config-versioning from Phase 5; the NetBox-driven DAI/VLAN render lands at Phase 4 (source of truth) → Phase 10 (Automation/IaC, `ADR-0048`).
- **GitOps:** Oxidized → the self-hosted git (**CNT01**, Backlog #19) → review/PR → deploy.
- **Cert anchor:** Oxidized/SNMP/syslog (CCNA Dom-6) · Ansible network automation + NetBox-driven config (**CCNP ENAUTO**).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created as the designed `Automation/` stub for SW01 (`ADR-0048`, networking variant) — Oxidized config-backup, the flagship **DAI `STATIC-HOSTS` render from NetBox** (fixes the Pi01-drop defect structurally), and Ansible VLAN/port config render + read-only verify; the "does NOT automate" learning boundary (the CLI build + L2 design stay hand-learned first). Config-versioning + Ansible, not DSC. |
