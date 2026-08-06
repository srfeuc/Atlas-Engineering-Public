# MON01 — Roles (per-service build units)

> MON01 is a **multi-service host**, so each service is its own build unit (`ADR-0037` `Roles/` pattern — like SRV01). The **host** folder owns everything true of the box (OS, VLAN-40 identity, CIS hardening, the one-way firewall, split placement); each **role** folder owns everything true of that one service (packages, config, its own acceptance read-backs). A fact lives in exactly one place (`POL-0008`).

| Role | What it owns | Split placement | Build phase |
|---|---|---|---|
| `rsyslog/` | estate log collection + retention | light receiver on EQR6 · bulk archive on R410 | Roadmap Phase 2 |
| `LibreNMS/` | SNMPv3 polling + LLDP topology (`10.40.0.20`) | R410 (heavy) | Roadmap Phase 2 |
| `NetFlow/` | flow collection (nfdump/ntopng) → Phase-7 matrix | R410 (heavy) | Roadmap Phase 2 |
| `Suricata-IDS/` | network IDS on the `SW01 Gi1/0/5` SPAN | R410 (heavy) | Roadmap Phase 3 |
| `Grafana-UptimeKuma/` | dashboards (`10.40.0.30`) + up/down | Grafana on R410 · Uptime-Kuma on EQR6 (always-on) | Roadmap Phase 4 |

Each role folder holds a `Build-Checklist.md` now; `Build-Guide.md` + `Diagnostics` are added as the role is built (checklist-first lifecycle). The host spine that sequences these is `../Build-Guide/MON01-Build-Guide.md`.
