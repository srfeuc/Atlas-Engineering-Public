---
Title: SIEM01 — Automation (agent rollout + rules-as-code)
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh/Automation
Status: 📋 Designed stub (ADR-0048). Security variant = agent rollout (GPO/Ansible) + rules-as-code, NOT DSC. Authored after the manual first pass.
Version: 0.1
Date: 2026-07-30
---

# SIEM01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** SIEM01's automation **slice** — authored **after** the manual build. The runnable shared code (git/CI) is the estate capability (`../../CNT01-Container-Host/`; Backlog #19); this folder **links** to it. 🔴 **Security variant:** agent rollout + rules-as-code — **not** PowerShell DSC. The **detection-content design** (which rules, which FIM paths, tuning) is the **hand-learned** skill, not automated away.

## Planned automation (designed, phased)

| Task | Tool | What it automates | Hand-learned first (NOT automated) |
|---|---|---|---|
| **Agent rollout** | **GPO** (Windows) / **Ansible** (Linux) | Deploy + enroll the Wazuh agent fleet-wide from one source | Choosing the FIM/SCA policy set (the CySA+ skill) |
| **Rules / decoders as code** | git-tracked rules + a deploy hook | Version + deploy custom rules/decoders (incl. the Suricata-ingest parsing) | Writing/tuning the detection rules + the correlation logic |
| **Read-only verify** | script | Batch the `Diagnostics` battery (agent-active, ingest-visible, indexer-headroom) | Interpreting the alerts + the active-response judgement |

## How this fits the estate
- **Phase alignment:** agent rollout via GPO/Ansible from Phase 6; rules-as-code → Phase 10 (`ADR-0048`); **active response stays deliberate** (alert-only first, add responses one tested rule at a time — `ADR-0041`).
- **GitOps:** rules/decoders → the self-hosted git (**CNT01**, Backlog #19) → review/PR → deploy.
- **Cert anchor:** agent automation + detection-as-code (CySA+ · Security+).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the `ADR-0048` stub for SIEM01 (security variant): agent rollout (GPO/Ansible) + rules/decoders-as-code + a read-only verify; the "does NOT automate" boundary (the detection-content design + tuning + the active-response judgement stay hand-learned). Not DSC. |
