---
Title: MON01 — Build Guide (phased, gated executable spine)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/Build-Guide
Status: 📋 Spine — the phased, gated executable path (`ADR-0043`); phases mirror `Roadmap.md` 1:1. Per-service *how* lives in `Roles/`. Click-by-click steps are authored **at the bench, in real time** (`ADR-0037` workflow); future phases are **designed gated stubs**, not empty.
Version: 0.1
Date: 2026-07-29
---

# MON01 — Build Guide (spine)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** The rebuild contract for MON01. Work it **phase by phase, each behind its 🔴 GATE** — do not start a phase until its gate passes. Capture live values + 📸 + gotchas as you go (`ADR-0037`). The per-service detail is in `Roles/<service>/`; this spine is the order + the gates.

## Phase 0 — Gates 🔴
**GATE — do not start until:** estate **clocks synced** (`ADR-0020`, `CM-0030`) · the **SPAN is cabled** (`SW01 Gi1/0/5` → sensor). *These are not steps; they are preconditions.*

## Phase 1 — Host stand-up (split, `ADR-0036` v1.2) 🔴
**GATE:** PVE02/EQR6 stood up (64 GB) for the always-on probe · PVE01/R410 powered on for the heavy stack.
- **Always-on probe (EQR6):** clone the Debian template → identity on VLAN 40 → CIS baseline → Uptime-Kuma + a light syslog receiver.
- **Heavy stack (R410):** Debian on VLAN 40 → CIS hardening → the **one-way host firewall** (permit inbound syslog/SNMP-trap/NetFlow; deny inbound sessions from monitored hosts).
- 📸 the firewall ruleset + a refused inbound-SSH from a monitored host.
- **Certificate-application:** *(none required initially — MON01 is a collector. If Grafana/LibreNMS are published over TLS, request a server cert from ICA01; document here when that phase lands.)*

## Phase 2 — Logs & metrics 🔴
**GATE:** Phase 1 ✅ · clocks confirmed on the collectors.
- **Service-setup** → per `Roles/rsyslog/`, `Roles/LibreNMS/`, `Roles/NetFlow/`.
- 🔴 In the LibreNMS step, **re-point SW01 SNMP off the ghost `10.40.0.52`** onto MON01 and move it to **SNMPv3** (`CM-0023`).
- 📸 the LLDP topology map; a NetFlow capture of real flows.

## Phase 3 — Detection (Suricata) 🔴
**GATE:** SPAN cabled (Phase 0) · sensor host up.
- **Service-setup** → per `Roles/Suricata-IDS/`.
- 🔴 **Prove it fires** — generate an EICAR-style / known-bad pattern from LabComputer and confirm the alert. 📸 the alert.

## Phase 4 — Visualization 🔴
**GATE:** data sources (Phases 2–3) producing.
- **Service-setup** → per `Roles/Grafana-UptimeKuma/`. 📸 a dashboard rendering a live deny with a correct timestamp.

## Phase 5 — Automation-onboarding (`ADR-0048`) 🔴
**GATE:** the manual stack proven (Phases 1–4 ✅).
- Capture the repeatable form in `../Automation/`: Ansible stack-deploy, fleet SNMP/syslog enablement, dashboards-as-code, sensor-config-in-git. 🎯 idempotent re-run.

## Future / later (designed gated stubs)
- **Feed SIEM01/Wazuh** 🔴 GATE: SIEM01 built → ship Suricata + syslog into Wazuh (`ADR-0032`, register D3).
- **SCAP/OpenSCAP** compliance scans → the SIEM (Backlog #18).

## Related
- `../Roadmap.md` (the phases this mirrors) · `../Build-Checklist.md` (line-item + gates) · `../Diagnostics.md` (verify) · `Roles/` (per-service *how*) · `Atlas-Academy/Command-Library/Linux.md` (commands).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created — the phased, gated spine (`ADR-0043`) mirroring `Roadmap.md`: Phase 0 gates (clocks/SPAN), Phase 1 split host stand-up + the one-way firewall, Phases 2–4 pointing into `Roles/`, Phase 5 automation-onboarding (`ADR-0048`), and designed future stubs (SIEM feed, SCAP). Click-by-click filled at the bench. |
