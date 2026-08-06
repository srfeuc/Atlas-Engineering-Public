---
Title: BKP01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-30
---

# BKP01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** This folder holds BKP01's automation **slice** — how-tos + device-specific scripts — authored **after** the manual first pass (stand PBS + the off-site copy + Vaultwarden up by hand once; *then* make it repeatable). Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, **Backlog #19**). 🟡 until idempotent.

## Planned automation (designed, phased)

| Task | Tool | What it automates | What it does NOT automate |
|---|---|---|---|
| **PBS install + datastore** | Ansible | package install, datastore-on-the-8TB, base config | the sizing/retention decision (Backlog #20) |
| **Backup jobs as code** | Ansible / PBS API | job definitions (clients, schedule, verify, prune) in git | *which* systems are irreplaceable (the human call) |
| **Off-site sync** | cron + restic/borg | scheduled encrypted push to the off-site target | 🔴 **key custody** — the key stays offline (`POL-0002`), never in the repo |
| **Vaultwarden deploy** | Ansible / container | install + ICA01 TLS binding + admin-token wiring | the `049` recovery-path decision; the master secret |

> 🔴 **The automation boundary.** Backup/off-site is **plumbing → automate it**. But the **restore Game Day judgment stays MANUAL** (`ADR-0011`/`POL-0005`) — a human confirms a restored VM actually boots and works; a green cron log is not a restore. And **no key or secret** is ever committed (`POL-0002`).

## How this fits the estate
- **Phase alignment:** Roadmap Phase 10 · Build-Order Phase 10 (`ADR-0048`). Shared capability: **Backlog #19**.
- **Cert anchor:** IaC + backup-as-code (AZ-800/801); secret handling (Security+).

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the `Automation/` slice for BKP01 (`ADR-0048`) — planned Ansible PBS install, backup-job-as-code, off-site sync cron, Vaultwarden deploy; boundary = automate the plumbing, keep the restore judgment + key custody manual. |
