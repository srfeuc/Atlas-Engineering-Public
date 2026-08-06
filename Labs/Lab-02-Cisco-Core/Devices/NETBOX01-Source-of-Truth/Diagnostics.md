---
Title: NETBOX01 Diagnostics — Read-Only Verification Battery
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: 📋 Seeded. NETBOX01 = the IPAM/DCIM source of truth, VLAN 20 (`10.20.0.11`). Commands authored from docs; **📋 service not built** — every row is 🟡 lab-unverified until a read-back is pasted. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 — Diagnostics: Read-Only Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 service not built)** — Host: **NETBOX01** (Ubuntu 26.04) — Role: IPAM/DCIM source of truth (NetBox v4.6.5 + PostgreSQL 16 + Redis 7 + gunicorn + nginx HTTPS). VLAN 20, `10.20.0.11`.

> **What this is.** The quick, **read-only** "is it built + does it actually serve the truth?" checks — the distinctive NETBOX01 discipline is that *service-up is not enough; the API has to answer and exports have to render*. Break-fix → `Troubleshooting.md`; the deep set → **Atlas Academy `Atlas-Academy/Command-Library/Linux.md`**. Markers: ✅ device-verified · 🟡 lab-unverified · 📋 planned. Run as an unprivileged user; nothing here changes state.

## 1. Host / identity
| Check | Command | Expected (healthy) | Verified? |
|---|---|---|---|
| OS / version | `cat /etc/os-release` | Ubuntu 26.04 LTS | 📋 |
| Hostname | `hostnamectl` | NETBOX01 | 📋 |
| IP / VLAN 20 | `ip -br a` | `10.20.0.11/26` | 📋 |
| Gateway reachable | `ping -c2 10.20.0.1` | replies | 📋 |
| DNS resolves | `resolvectl query netbox.atlas.lab` (DNS `10.20.0.2`) | resolves | 📋 |

## 2. Services up (systemd)
| Check | Command | Expected | Verified? |
|---|---|---|---|
| NetBox app + workers | `systemctl status netbox netbox-rq` | `active (running)` | 📋 |
| PostgreSQL 16 | `systemctl status postgresql` | `active (running)` | 📋 |
| Redis 7 | `systemctl status redis-server` | `active (running)` | 📋 |
| nginx | `systemctl status nginx` | `active (running)` | 📋 |
| gunicorn socket | `systemctl status netbox` (gunicorn under NetBox unit) | listening | 📋 |

## 3. Data-tier reachability
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Postgres accepts | `sudo -u postgres psql -c '\l'` \| grep netbox | the `netbox` DB present | 📋 |
| Redis responds | `redis-cli ping` | `PONG` | 📋 |
| Migrations applied | `nbshell`/`manage.py showmigrations` \| grep '\[ \]' | no unapplied migrations | 📋 |

## 4. Web / API / TLS (the point of NetBox)
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Local HTTPS health | `curl -k https://localhost/` | HTTP 200 / login page HTML | 📋 |
| API reachable | `curl -k https://localhost/api/` (or a token'd `/api/dcim/devices/`) | JSON API root / device list | 📋 |
| nbshell / ORM | `nbshell` → `Device.objects.count()` | a count matching the data load | 📋 |
| Cert identity | `openssl s_client -connect localhost:443 </dev/null 2>/dev/null \| openssl x509 -noout -issuer` | self-signed day one → **ICA01** after Phase 8 | 📋 |

## 5. Source-of-truth sanity (render / export)
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| Export renders | run the config/export template against NetBox data | a rendered artifact (no template errors) | 📋 |
| 🔴 Empty-diff proof | `diff <(netbox-generated SW01 STATIC-HOSTS/DAI ACL) <(live SW01 ACL)` | **empty** — the source-of-truth gate | 📋 |
| IPAM matches the plan | spot-check a prefix/address vs `../../Architecture/IP-Addressing-Plan-VLSM.md` | agrees (`POL-0008`) | 📋 |

## If you built or changed NETBOX01 solo
Paste the read-backs (services active, `curl -k https://localhost/` 200, an API/`nbshell` response, and above all the **empty-diff** result) so the next session flips 📋/🟡 → ✅; mirror into the estate handoff + `../../Operations/` confirmation docs (do **not** edit those owner docs' facts — append evidence only).

## Related
- `Troubleshooting.md` (symptom→fix) · **Atlas Academy** `Atlas-Academy/Command-Library/Linux.md` · `Roadmap.md` (build path) · `Build-Record.md` (as-built) · `../../Architecture/IP-Addressing-Plan-VLSM.md` (IPAM owner).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Seeded the read-only battery for NETBOX01: host/identity, systemd service-up (netbox/postgresql/redis/nginx/gunicorn), data-tier reachability (psql/`redis-cli ping`/migrations), web+API+TLS (`curl -k https://localhost/`, `/api/`, `nbshell`, cert issuer), and the source-of-truth render/**empty-diff** sanity checks. All 📋 (not built); flips to ✅ on read-back (`POL-0001`). |
