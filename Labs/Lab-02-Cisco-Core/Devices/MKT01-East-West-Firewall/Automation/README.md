---
Title: MKT01 — Automation (config-backup + policy-as-code)
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/Automation
Status: 📋 Designed stub (ADR-0048). Networking variant = config-versioning + Ansible/policy-render, NOT DSC. Authored after the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# MKT01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** MKT01's automation **slice** — how-tos + device-specific artifacts — authored **after** the manual RouterOS build (automate what you have learned by hand). The **runnable shared code** (Oxidized, Ansible network roles, the self-hosted git/CI) is the **estate capability** owned centrally (`../../CNT01-Container-Host/` + `../../../Operations/Automation/`; Backlog #19 / Phase 10); this folder **links** to it. 🔴 **Networking variant:** config-versioning + Ansible — **not** PowerShell DSC.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **Config backup** | **Oxidized** (on SRV01 → git) | Pull the RouterOS config on change → git; drift shows as a diff | The RouterOS build itself (the MTCNA/CCNA skill — `Build-Guide.md`) |
| **E-W policy render** | **Ansible ← the flows matrix / NetBox** | Render the RouterOS filter rules **from `Atlas-East-West-Allowed-Flows-Matrix`** (the policy owner) so the rules are the matrix, generated not hand-typed | Designing the segmentation + writing each *reason* (the whole Phase-7 learning exercise — `POL`: no reason, no rule) |
| **Read-only verify** | Ansible playbook | Batch the `Diagnostics` `print stats` battery (OSPF/addresses/rule-hits) | Interpreting the counters + the Game-Day judgement |

## How this fits the estate
- **Phase alignment:** Oxidized config-versioning from Phase 5; the flows-matrix→RouterOS policy render lands **after** the manual Phase-7 default-deny build is proven (never as a shortcut past the evidence step) → Phase 10 (`ADR-0048`).
- **GitOps:** Oxidized → the self-hosted git (**CNT01**, Backlog #19) → review/PR → deploy — a firewall change is a reviewed PR.
- **Cert anchor:** Oxidized/syslog (CCNA Dom-6) · Ansible network automation + policy-as-code (**CCNP ENAUTO**) · segmentation design (Security+).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created as the designed `Automation/` stub for MKT01 (`ADR-0048`, networking variant) — Oxidized config-backup, the flagship **E-W-policy render from the flows matrix / NetBox** (rules generated, not hand-typed — after the manual Phase-7 build is proven), and a read-only `print stats` verify playbook; the "does NOT automate" boundary (the segmentation design + writing each rule's *reason* stays the hand-learned Phase-7 exercise). Config-versioning + Ansible, not DSC. |
