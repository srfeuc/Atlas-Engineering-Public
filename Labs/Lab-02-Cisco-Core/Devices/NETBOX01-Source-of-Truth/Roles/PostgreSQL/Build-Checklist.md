---
Title: NETBOX01 · PostgreSQL — Build Checklist (NetBox database)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth/Roles/PostgreSQL
Status: 📋 Target design — the database tier for NetBox. You write the config; verify the DB accepts NetBox + is localhost-only (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 · PostgreSQL — Build Checklist

<!-- provenance -->
> **Role:** PostgreSQL 16 — the NetBox database. On the NETBOX01 host (Ubuntu 26.04). Docs: https://docs.netbox.dev/en/stable/installation/1-postgresql/.

## Gate
- [ ] 📋 Host up + hardened (Roadmap Stage 1); listens **localhost-only** (no VLAN-20 exposure — the DB is internal to the box).

## Build steps
- [ ] 📋 Install **PostgreSQL 16** (`postgresql`), confirm `systemctl status postgresql` active.
- [ ] 📋 Create the `netbox` **database** + **role** with a strong password (matches `configuration.py` — not committed to git).
- [ ] 📋 Grant the role ownership of the DB; confirm `listen_addresses` = localhost.
- [ ] 📋 Confirm the NetBox app can connect (deferred to the NetBox role's `migrate`).

## Acceptance (🎯)
- [ ] 📋 `sudo -u postgres psql -c '\l'` shows the `netbox` DB; NetBox migrations later apply cleanly against it (`../../Diagnostics.md` §3). ⬜ until read-back captured.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the per-service checklist for the PostgreSQL 16 database tier — install, `netbox` DB/role with a strong password, localhost-only, acceptance = DB present + migrations apply. All ⬜/📋. |
