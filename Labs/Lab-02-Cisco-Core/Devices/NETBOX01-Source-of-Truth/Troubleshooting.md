---
Title: NETBOX01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: 🟢 LIVING — symptom→cause→fix for the IPAM/DCIM source of truth. Seeded from the known failure modes of a NetBox + PostgreSQL + Redis + gunicorn + nginx stack; real incidents append as they occur. Verify commands live in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 service not built).** Symptom → likely cause → fix, for the source of truth. Seeds from the stack's known traps; the health checks that confirm a fix are in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## Service won't start
- **Symptom:** `systemctl status netbox` shows failed / gunicorn won't come up.
  - **Cause:** bad `configuration.py` (SECRET_KEY missing, wrong `ALLOWED_HOSTS`, DB/Redis creds), or the venv/Python doesn't match the pinned NetBox v4.6.5.
  - **Fix:** `journalctl -u netbox -e`; validate `configuration.py`; confirm the venv Python + `pip` requirements match v4.6.5; restart `netbox netbox-rq`. Confirm with `Diagnostics.md` §2.

## Database / migrations
- **Symptom:** NetBox errors on start / `showmigrations` shows unapplied `[ ]`.
  - **Cause:** migrations not run after an upgrade, or PostgreSQL unreachable / wrong role/DB.
  - **Fix:** confirm Postgres up (`Diagnostics.md` §3) and the `netbox` DB/role exist; run the NetBox `migrate`; re-check `showmigrations`. Never hand-edit tables.

## Redis / task queue
- **Symptom:** background jobs (rq) stuck; webhooks/reports don't run; UI warns the queue is down.
  - **Cause:** `redis-server` down, wrong Redis DB index for cache vs queue, or `netbox-rq` workers not running.
  - **Fix:** `redis-cli ping` → `PONG`; confirm cache vs task-queue backends point at the right Redis DBs; `systemctl status netbox-rq`; restart the workers.

## nginx / TLS
- **Symptom:** browser can't reach NetBox / cert warning / 502 Bad Gateway.
  - **Cause:** 502 = gunicorn socket down or misnamed; cert warning = the **self-signed day-one cert** (expected until ICA01, Phase 8); or `server_name`/`ALLOWED_HOSTS` mismatch.
  - **Fix:** for 502, confirm gunicorn/NetBox unit up + the proxy_pass socket path; for TLS, this is expected until the **ICA01-issued cert** replaces self-signed (`Considerations.md`); verify `curl -k https://localhost/` returns 200.

## API / auth
- **Symptom:** `/api/` returns 401/403; automation can't read NetBox.
  - **Cause:** missing/expired API token, or (later) LDAPS bind failing.
  - **Fix:** issue/rotate an API token with the right permissions; test `curl -k -H "Authorization: Token <t>" https://localhost/api/dcim/devices/`. **LDAPS is a later enhancement** — until then auth is local; don't chase an AD bind that isn't configured yet (`Considerations.md`).

## Source-of-truth drift (the defect class this host exists to kill)
- **Symptom:** a rendered config doesn't match the live device / the empty-diff isn't empty.
  - **Cause:** someone edited the device directly without updating NetBox (the `006` failure; Pi01 dropped from a hand-typed ACL).
  - **Fix:** treat NetBox as authoritative — reconcile the model, re-render, and re-run the **empty-diff** (`Diagnostics.md` §5). The fix is discipline: every change flows *through* the source of truth (`POL-0004`).

## Related
- `Diagnostics.md` (the checks that confirm the fix) · `Considerations.md` (why these traps exist) · Academy `Atlas-Academy/Command-Library/Linux.md` · `Roles/` (per-service specifics).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Seeded from the NetBox-stack failure modes: service-won't-start (config/venv), DB/migrations, Redis/rq queue, nginx/TLS (incl. the expected self-signed-until-ICA01 warning + 502), API/auth (tokens; LDAPS-is-later), and source-of-truth drift (the `006`/Pi01 defect the empty-diff kills). Real incidents append as they occur. |
