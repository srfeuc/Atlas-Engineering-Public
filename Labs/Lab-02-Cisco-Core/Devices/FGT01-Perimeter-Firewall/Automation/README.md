---
Title: FGT01 — Automation (config-backup + policy-as-code)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/Automation
Status: 📋 Designed stub (ADR-0048). Networking variant = config-versioning + Ansible fortios_*, NOT DSC. Authored after the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# FGT01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** FGT01's automation **slice** — how-tos + device-specific artifacts — authored **after** the manual FortiOS build (automate what you have learned by hand). The **runnable shared code** (Oxidized, Ansible network roles, the self-hosted git/CI) is the **estate capability** owned centrally (`../../CNT01-Container-Host/` + `../../../Operations/Automation/`; Backlog #19 / Phase 10); this folder **links** to it. 🔴 **Networking variant:** config-versioning + Ansible `fortios_*` — **not** PowerShell DSC.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **Config backup** | **Oxidized / scheduled `execute backup`** → git | Version the FortiOS config on change → git; drift as a diff | The FortiOS build itself (the FCP skill — `Build-Guide-*`) |
| **Policy + UTM profile as-code** | **Ansible `fortios_*`** | Render firewall policies + UTM profiles from a defined source; idempotent re-apply | Designing the policy + choosing UTM/TLS-inspection scope (the FCP + K1 decision) |
| **Read-only verify** | Ansible playbook | Batch the `Diagnostics` `get`-battery (status/policy/routing) + the `get system status` subscription/DB check | Interpreting the flow trace + the confidence-trap judgement (`ADR-0047`) |

## How this fits the estate
- **Phase alignment:** Oxidized/backup from Phase 5; policy/UTM as-code **after** the manual UTM build is proven (never a shortcut past the confidence-trap check) → Phase 10 (`ADR-0048`).
- **GitOps:** config → the self-hosted git (**CNT01**, Backlog #19) → review/PR → deploy — a firewall/UTM change is a reviewed PR.
- **Cert anchor:** Oxidized/backup + `fortios_*` automation (FCP automation · CCNP ENAUTO-adjacent).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created as the designed `Automation/` stub for FGT01 (`ADR-0048`, networking variant) — FortiOS config-backup (Oxidized / `execute backup`), Ansible `fortios_*` policy + UTM-profile as-code, and a read-only `get`-battery + `get system status` verify; the "does NOT automate" boundary (the policy design + the UTM/TLS-inspection scope + the confidence-trap judgement stay hand-learned). Config-versioning + Ansible, not DSC. |
