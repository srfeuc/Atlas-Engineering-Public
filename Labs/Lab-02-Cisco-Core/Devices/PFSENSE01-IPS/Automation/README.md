---
Title: PFSENSE01 — Automation (config-backup + rules-as-code)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS/Automation
Status: 📋 Designed stub (ADR-0048). Security variant = config-backup + Suricata-rules-as-code, NOT DSC. Authored after the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# PFSENSE01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** PFSENSE01's automation **slice** — how-tos + device-specific artifacts — authored **after** the manual build (automate what you have learned by hand). The **runnable shared code** (the self-hosted git/CI, shared rule sets) is the **estate capability** owned centrally (`../../CNT01-Container-Host/` + `../../../Operations/Automation/`; Backlog #19 / Phase 10); this folder **links** to it. 🔴 **Security variant:** config-backup + Suricata-rules-as-code — **not** PowerShell DSC.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **Config backup** | pfSense config XML → git (scheduled export) | Version the pfSense/bridge config on change → git; drift as a diff | The manual bridge/fail-closed build (the skill — `Build-Guide.md`) |
| **Suricata rules-as-code** | git-tracked rule sets + a deploy hook (shared with MON01) | Version + deploy the Suricata rule set / suppressions; one rule source across PFSENSE01 + MON01 | Writing/tuning the rules + choosing inline-vs-monitor categories (the Security+/CySA+ skill) |
| **Read-only verify** | script/playbook | Batch the `Diagnostics` battery (bridge/OSPF-unchanged, Suricata mode, alert reachability) | Interpreting the alerts + the tuning judgement |

## How this fits the estate
- **Phase alignment:** config-backup + rules-in-git from Phase 5/10; the inline-blocking enable stays the **manual, monitored, per-category** exercise (never automated past the tuning — `ADR-0041`, doubly so under fail-closed).
- **GitOps:** config + rules → the self-hosted git (**CNT01**, Backlog #19) → review/PR → deploy; shares the Suricata rule source with MON01.
- **Cert anchor:** config-backup + rules-as-code (Security+/CySA+ · CCNP-adjacent automation).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created as the designed `Automation/` stub for PFSENSE01 (`ADR-0048`, security variant) — pfSense config-backup to git + Suricata-rules-as-code (shared with MON01) + a read-only verify; the "does NOT automate" boundary (the manual bridge/fail-closed build + the rule tuning + the per-category inline enable stay hand-learned). Config-backup + rules-as-code, not DSC. |
