---
Title: NETBOX01 · Redis — Build Checklist (cache + task queue)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth/Roles/Redis
Status: 📋 Target design — the cache + task-queue tier for NetBox. You write the config; verify Redis responds + backs the rq workers (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 · Redis — Build Checklist

<!-- provenance -->
> **Role:** Redis 7 — NetBox's **cache** + **task-queue** backends. On the NETBOX01 host (Ubuntu 26.04). Docs: https://docs.netbox.dev/en/stable/installation/2-redis/.

## Gate
- [ ] 📋 Host up + hardened (Roadmap Stage 1); binds **localhost-only** (internal to the box).

## Build steps
- [ ] 📋 Install **Redis 7** (`redis-server`), confirm `systemctl status redis-server` active.
- [ ] 📋 Set `bind 127.0.0.1` (localhost-only); set a `requirepass` if the estate baseline calls for it.
- [ ] 📋 Point NetBox's `configuration.py` at the correct Redis DB indexes — **separate** cache vs task-queue backends.
- [ ] 📋 Confirm the `netbox-rq` workers will attach (deferred to the NetBox role).

## Acceptance (🎯)
- [ ] 📋 `redis-cli ping` → `PONG`; NetBox background jobs (rq) run once the app is up (`../../Diagnostics.md` §3). ⬜ until read-back captured.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the per-service checklist for the Redis 7 cache + task-queue tier — install, localhost-only bind, separate cache/queue DB indexes, acceptance = `PONG` + rq jobs run. All ⬜/📋. |
