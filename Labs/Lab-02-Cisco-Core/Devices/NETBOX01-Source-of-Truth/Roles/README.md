# NETBOX01 — Roles (per-service build units)

> NETBOX01 is a **multi-service host**, so each service is its own build unit (`ADR-0037` `Roles/` pattern — like SRV01/MON01). The **host** folder owns everything true of the box (OS = Ubuntu 26.04 clone of `TPL-UBUNTU2604`, VLAN-20 identity `10.20.0.11`, CIS-Ubuntu hardening, the host firewall, placement on PVE01/R410); each **role** folder owns everything true of that one service (packages, config, its own acceptance read-backs). A fact lives in exactly one place (`POL-0008`).

| Role | What it owns | Build phase (Roadmap) |
|---|---|---|
| `PostgreSQL/` | the NetBox database — Postgres 16 server, `netbox` role + DB, localhost-only | Stage 2 (data tier) |
| `Redis/` | the cache + task-queue backends — Redis 7, localhost-only | Stage 2 (data tier) |
| `NetBox/` | the application — NetBox v4.6.5 (pinned) + gunicorn (WSGI) + nginx HTTPS + rq workers; the render/API surface | Stage 3 (application) |

Notes:
- **Data load** (IPAM/DCIM from the IP plan + cabling) is a *cross-role* step owned by `../NetBox-Data-Load-Prep.md`, run after the NetBox role is up (Roadmap Stage 4). The 🔴 **empty-diff proof** is its acceptance gate.
- **TLS cert from ICA01** (Phase 8) and **LDAPS-to-AD auth** (later) are enhancements on the NetBox role, gated — see `../Roadmap.md` Stages 5–6.

Each role folder holds a `Build-Checklist.md` now; `Build-Guide` + `Diagnostics` are added as the role is built (checklist-first lifecycle). The host-level executable spine is `../Build-Guide.md`; network bring-up is `../Networking-Build-Guide.md`.
