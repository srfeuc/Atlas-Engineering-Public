---
Title: MON01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass — automate what you've learned by hand (Learning Rule, Charter 16/17). 🟡 until each artifact runs idempotently on the device.
Version: 0.1
Date: 2026-07-29
---

# MON01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** This folder holds MON01's automation **slice** — how-tos + device-specific scripts/playbooks — authored **after** the manual first pass, never as a shortcut past the learning. The **runnable shared code** (roles, modules, the CI/git host) is the **estate capability** owned centrally (`Operations/Automation/` + the self-hosted git repo — Backlog #7/#19, Phase 10); this folder **links** to it. 🟡 until an artifact runs **idempotently** (`ADR-0041`).

## Planned automation (designed, phased — `ADR-0048` tooling ladder)

| Task | Tool | What it automates | What it does NOT automate (hand-learned first) |
|---|---|---|---|
| **Stack deploy** | Ansible | Install/configure LibreNMS, NetFlow, Suricata, Grafana, Uptime-Kuma on a fresh Debian; idempotent re-run | The *first* manual install of each — you learn each service by hand once (Roadmap Phases 2–4) |
| **SNMP/syslog enablement** | Ansible (network + Linux) | Turn on SNMPv3 + syslog export on every device, pointed at MON01; fix the SW01 `10.40.0.52` mistarget fleet-wide | The per-platform config the CCNA/CCNP objectives grade (do one device by hand first) |
| **Dashboards-as-code** | Grafana provisioning (JSON/YAML) | Version the Grafana dashboards + data sources in git so they rebuild identically | Designing what a good dashboard shows (the analysis skill) |
| **Sensor config in git** | Oxidized/git (via SRV01) | Back up Suricata rules + collector configs to git; drift diff on change | Writing/tuning the Suricata rule set (Security+/CySA+ skill) |

## How this fits the estate
- **Phase alignment:** these land at Roadmap **Phase 5** (Automation onboarding), after the manual stack is proven. Estate sequencing: Build-Order **Phase 10** (`ADR-0048`).
- **GitOps:** configs → the self-hosted git (Backlog #19) → review/PR → deploy; the CI runner lints + tests.
- **Cert anchor:** Ansible (CCNP ENAUTO), dashboards/CI (AZ-400-adjacent), SNMP/syslog automation (CCNA Dom-6).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the designed `Automation/` stub for MON01 (`ADR-0048`) — the planned Ansible stack-deploy, fleet SNMP/syslog enablement (incl. the SW01 mistarget fix), dashboards-as-code, and sensor-config-in-git, each with its "does NOT automate" learning boundary. Filled with real scripts + how-tos after the manual build (Roadmap Phase 5). |
