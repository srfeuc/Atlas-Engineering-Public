---
Title: MON01 — Build Checklist (Monitoring / Visibility)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring
Status: 📋 Target design — the line-item, dated, evidence-backed action list (`POL-0001`: you write the config; verify data actually arrives). Mirrors `Roadmap.md`. Nothing ticked until a read-back is captured in `Diagnostics.md`.
Version: 2.0
Date: 2026-07-29
---

# MON01 — Build Checklist (Monitoring / Visibility)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Role (`Atlas-Service-Architecture` 5.2 · CSF: **Detect**): the visibility + network-detection stack — rsyslog · SNMPv3→LibreNMS · NetFlow · **Suricata IDS** (SPAN) · Grafana · Uptime-Kuma. **Split deployment** (`ADR-0036` v1.2): light always-on probe on **PVE02/EQR6**; heavy stack on **PVE01/R410**. VLAN 40 (`10.40.0.x`, gw `10.40.0.1`). Sources: [CIS Debian](https://www.cisecurity.org/benchmark/debian_linux) · [LibreNMS](https://docs.librenms.org/) · [Suricata](https://docs.suricata.io/).

> 🔴 **Design rule — monitoring is one-directional.** MON01 **polls out**; **nothing sessions back in** (matrix flow #2). A compromised server must not pivot into the telemetry. Enforce in the MKT01 Phase-7 policy.

## Phase 0 — Gates (blocking)
- [ ] 🔴 **Clocks synced** estate-wide (`ADR-0020`, `CM-0030`) — logs on a wrong clock are worthless.
- [ ] 🔴 **SPAN cabled** — `SW01 Gi1/0/5` → the Suricata sensor.
- **🎯 Gate:** both true before any collector is trusted.

## Phase 1 — Host stand-up (split)
- [ ] **Always-on probe (EQR6):** minimal Debian VM — named admin, SSH keys, host firewall; install **Uptime-Kuma** + a **light syslog receiver**.
- [ ] **Heavy stack (R410):** Debian VM, VLAN 40 — CIS hardening (named admin, SSH keys, `unattended-upgrades`), **host firewall = permit inbound syslog/SNMP-trap/NetFlow; deny inbound sessions from monitored hosts.**
- **🎯 Gate:** both VMs reachable on VLAN 40; the R410 host firewall refuses an inbound SSH from a monitored host.

## Phase 2 — Logs & metrics
- [ ] **rsyslog collector** — every device ships logs here; retention set (light receiver always-on on EQR6; bulk archive on R410). Settle the SRV01-relay-vs-MON01-collector split (`Considerations.md`).
- [ ] **SNMPv3 → LibreNMS** (`10.40.0.20`) — auth+priv polling; LLDP topology renders. 🔴 **Re-point SW01 SNMP off `10.40.0.52`** onto MON01 (`CM-0023`); **no v2c `homelab` community.**
- [ ] **NetFlow collector** (nfdump/ntopng) — devices export; collect ~a week → the Phase-7 matrix input.
- **🎯 Gate:** a device appears in LibreNMS with the LLDP map; NetFlow shows real flows; logs arrive with **correct timestamps**.

## Phase 3 — Detection
- [ ] **Suricata** on the SPAN feed. 🔴 **Prove it fires** on a test (EICAR-style / known-bad) — a sensor that never alerted is unproven (`016` lesson 4).
- **🎯 Gate:** Suricata **alerts on the test**, and the alert is visible in Grafana/SIEM with a correct timestamp.
- *(Wazuh/Security Onion are heavier — SIEM01's own host per A2; MON01 feeds it.)*

## Phase 4 — Visualization
- [ ] **Grafana** dashboards (`10.40.0.30`) + **Uptime-Kuma** up/down.
- **🎯 Gate:** dashboards render from live data; a **deny** is visible with a correct timestamp.

## Phase 5 — Automation onboarding (`ADR-0048`)
- [ ] After the manual build is proven, capture the repeatable form in `Automation/` (Ansible stack-deploy, fleet SNMP/syslog enablement, dashboards-as-code). 🎯 idempotent re-run = no drift.

## Validation (the proofs)
- [ ] Logs arriving from **every** device, **correct timestamps**.
- [ ] LibreNMS polling all devices; LLDP topology map renders.
- [ ] NetFlow showing real flows (the segmentation input).
- [ ] Suricata **alerts on a test**.
- [ ] 🔴 **The one-way rule holds** — from a monitored host, a session *into* MON01 is **refused** (matrix flow #2).

## Failure modes
- 🔴 **Unsynced clocks** — logs uncorrelatable; fix `CM-0030` first.
- 🔴 **SPAN built, IDS never plugged in / never tested** — telemetry you own and don't use.
- 🔴 **Monitoring reachable *back* into** — breaks the one-directional design; a foothold pivots into telemetry.
- 🔴 **SW01 SNMP at `10.40.0.52`** (a ghost) / **v2c `homelab`** (cleartext, in git — `CM-0023`) — re-point + go v3.

## Change Log
| Version | Changes |
|---|---|
| 2.0 | 2026-07-29. Rebuilt to the Documentation-Standard shape (`ADR-0037`) as part of the DC-template replication: phased to mirror `Roadmap.md` with a 🔴 GATE + 🎯 acceptance per phase, the **split deployment** (`ADR-0036` v1.2), the one-directional rule, the SW01-SNMP-mistarget fix (`CM-0023`), and a Phase-5 `Automation/` onboarding step (`ADR-0048`). Supersedes v1.0 (2026-07-17). |
| 1.0 | 2026-07-17. Original build checklist (rsyslog, SNMPv3/LibreNMS, NetFlow, Grafana, Uptime-Kuma, Suricata) on CIS-Debian — the Phase-6 visibility stack gating Phase-7 segmentation. |
