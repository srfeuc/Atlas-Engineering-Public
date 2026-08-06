---
Title: SIEM01 — Build Guide (Wazuh host SIEM, designed gated stub)
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh
Status: 📋 PROPOSED / gated — a designed stub (ADR-0043). NOT executed. Dedicated-host decided; VLAN/sizing → #20. Click-steps at build. Mirrors Roadmap.
Version: 0.1
Date: 2026-07-30
---

# SIEM01 — Build Guide (Wazuh host SIEM / XDR)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 proposed, ⬜ not built).** A **designed gated stub** (`ADR-0043`): the gate + the phase outline; the click-by-click steps are authored at build. **Dedicated host is decided**; the VLAN + indexer sizing come from **#20**. Work phase by phase.

## 🔴 GATE-0 — host + sizing (#20)
**GATE — do not start until:** the dedicated host + VLAN (📋 VLAN 40) + indexer **RAM/storage** are sized (#20). The OpenSearch indexer is RAM-heavy — do not under-provision.

## Phase 6a — The Wazuh stack (outline)
- Deploy **Wazuh manager + indexer (OpenSearch) + dashboard** on the dedicated host; VLAN 40 (proposed); optional **ICA01** TLS for agent↔manager + the dashboard.
- *Detail at build (install method, indexer heap/storage, cert bind).*

## Phase 6b — Agents + detection content (outline)
- **Enroll agents (Tier-0 + servers first)** — GPO (Windows) / config-mgmt (Linux); enable **FIM**, **SCA/CIS** policies, **vuln** feeds. Agent keys → Vaultwarden (`POL-0002`).
- *Detail at build (the rollout path + the FIM/SCA policy set).*

## Phase 6c — Ingest + correlation (outline)
- **Ingest MON01's Suricata + rsyslog** (syslog) → correlate host + network in one pane (Section K **K8**). Build alerting; add **active response** deliberately (alert-only first).
- *Detail at build.*

## Automation-onboarding (hook)
- Agent rollout as code (GPO/Ansible) + rules/decoders-as-code → `../Automation/`.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Considerations.md` · `../MON01-Monitoring/` · `ADR-0035` · `ADR-0043` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — designed gated stub (`ADR-0043`): GATE-0 (dedicated host decided + VLAN/indexer sizing #20) → Wazuh stack (manager/indexer/dashboard + ICA01 TLS) → agents (FIM/SCA/vuln, Tier-0 first; keys→Vaultwarden) → MON01 Suricata/rsyslog ingest + correlation (K8) + alerting (alert-only first) → automation hook. Click-steps at build. |
