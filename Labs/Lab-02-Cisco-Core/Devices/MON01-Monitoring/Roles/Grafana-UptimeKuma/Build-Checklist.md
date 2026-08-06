---
Title: MON01 · Grafana + Uptime-Kuma — Build Checklist (visualization + uptime)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/Roles/Grafana-UptimeKuma
Status: 📋 Target design. You write the config; verify dashboards render from live data (`POL-0001`).
Version: 0.1
Date: 2026-07-29
---

# MON01 · Grafana + Uptime-Kuma — Build Checklist

<!-- provenance -->
> **Role:** the single-pane view — **Grafana** dashboards (`10.40.0.30`, on the R410 heavy stack) over the metrics/logs/flows, and **Uptime-Kuma** up/down. 🔀 **Uptime-Kuma runs on the always-on EQR6 probe** (so the critical tier's up/down is watched even when the R410 is off); Grafana rides the R410 with its data sources.

## Gate
- [ ] Data sources producing (LibreNMS / NetFlow / rsyslog / Suricata — Roadmap Phases 2–3).

## Build steps
- [ ] Install Grafana; add data sources (LibreNMS/SQL, the flow + log stores, Suricata EVE).
- [ ] Build dashboards: device health, flows, a **security panel** (denies + Suricata alerts) with correct timestamps.
- [ ] Install **Uptime-Kuma** on the EQR6 probe; add always-on monitors for the critical tier (DC01, ICA01, NPS01, gateways).
- [ ] *(If published over TLS: request a server cert from ICA01 — note in the host Build-Guide.)*

## Acceptance (🎯)
- [ ] Dashboards render from **live** data; a **deny** is visible with a **correct timestamp**; Uptime-Kuma shows the critical tier up/down (`../../Diagnostics.md` §3).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the per-service checklist for the Grafana + Uptime-Kuma visualization role — reflects the split (Uptime-Kuma always-on on the EQR6; Grafana on the R410). |
