---
Title: NETBOX01 · NetBox — Build Checklist (app + gunicorn + nginx HTTPS)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth/Roles/NetBox
Status: 📋 Target design — the NetBox application tier (v4.6.5 pinned). You write the config; NetBox is **generated-from, never hand-typed** (`POL-0004`). Verify the API answers + the empty-diff proof (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 · NetBox — Build Checklist

<!-- provenance -->
> **Role:** NetBox **v4.6.5** (pinned) + **gunicorn** (WSGI) + **nginx** HTTPS + rq workers — the IPAM/DCIM application and its API/render surface (`10.20.0.11`, VLAN 20). Docs: https://docs.netbox.dev/en/stable/installation/. The executable companion is `../../Build-Guide.md`.

## Gate
- [ ] 📋 PostgreSQL role green (`../PostgreSQL/`) + Redis role green (`../Redis/`); host firewall permits inbound **443** on VLAN 20, DB/Redis stay localhost-only.

## Build steps
- [ ] 📋 Create the venv; install **NetBox v4.6.5** (pinned — not "latest") + Python requirements.
- [ ] 📋 `configuration.py`: strong `SECRET_KEY`, `ALLOWED_HOSTS`, the Postgres + Redis (cache/queue) backends; **no default creds**.
- [ ] 📋 Run `migrate`; create the superuser; collect static; start `netbox` + `netbox-rq` (gunicorn under systemd).
- [ ] 📋 nginx reverse-proxy → gunicorn socket; HTTPS with a **self-signed cert day one** (🔴 replaced by an **ICA01** cert at Phase 8 — `../../Considerations.md`).
- [ ] 📋 **Load the truth** (Roadmap Stage 4) — IPAM/DCIM from `../../NetBox-Data-Load-Prep.md` (the IP plan + cabling); device-only fields via the SoT Evidence Run-Sheet.

## Acceptance (🎯)
- [ ] 📋 `curl -k https://localhost/` → 200; `/api/` answers JSON (`../../Diagnostics.md` §4).
- [ ] 🔴 📋 **Empty-diff proof** — a NetBox-*generated* SW01 `STATIC-HOSTS`/DAI ACL **diffs empty** against the live device (`../../Diagnostics.md` §5). *Until this passes, "source of truth" is aspirational* (`POL-0004`). ⬜ unproven.

## Deferred / gated
- [ ] 📋 **TLS cert from ICA01** (Phase 8) — swap the self-signed nginx cert.
- [ ] 📋 **LDAPS-to-AD auth** (later) — central login via DC01; local admin until then (not domain-joined day one).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the per-service checklist for the NetBox v4.6.5 app tier — venv/pinned install, `configuration.py` (SECRET_KEY/backends/no-default-creds), migrate/superuser/gunicorn+rq, nginx HTTPS (self-signed day one → ICA01 Phase 8), data load, and acceptance = API answers + the 🔴 **empty-diff proof**. Gated enhancements: ICA01 cert + LDAPS auth. All ⬜/📋. |
