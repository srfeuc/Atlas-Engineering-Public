---
Title: NETBOX01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: ⬜ SERVICE NOT BUILT — net bring-up 🟡 reported reachable; the NetBox service is planned (Phase 4). This page is the `POL-0001` evidence home; a row is ⬜/🟡 until a real read-back is captured. Records outrank guides.
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 service not built).** The single "what is actually true right now" snapshot for the source of truth — the `POL-0001` evidence home. It **outranks the Build-Guide** (guide = target state; this = reality). Each row cites *where the evidence lives* rather than re-pasting it (`POL-0008`). Markers: ✅ device-verified · 🟡 operator-reported, read-back pending · ⬜ not built. **Nothing here is ✅ yet.**

> 🔴 **Records outrank guides (`POL-0001`).** If a guide and this record disagree, the record is right. Never flip a row to ✅ without a captured command + output.

## Host — NETBOX01 (Ubuntu 26.04 · VLAN 20 · PVE01/R410)

| Attribute | As-built target | Status | Evidence (when built) |
|---|---|---|---|
| OS / clone | Ubuntu Server 26.04 LTS, clone of `TPL-UBUNTU2604` | ⬜ | `cat /etc/os-release` → `Diagnostics.md` §1 |
| **Net up · service unbuilt** | VLAN 20, `10.20.0.11/26`, gw `10.20.0.1`, SSH reachable | 🟡 | `Networking-Build-Guide.md` (reported reachable 2026-07-24); read-back pending |
| Addressing | `10.20.0.11` · VLAN 20 · DNS `10.20.0.2` | 🟡 | owner: `../../Architecture/IP-Addressing-Plan-VLSM.md` |
| CIS-Ubuntu hardening | named admin, SSH keys, host firewall, `unattended-upgrades` | ⬜ | `Roles/NetBox/` host section |
| Domain join | **not** domain-joined day one (local auth) | ⬜ | n/a until LDAPS enhancement |
| Placement | PVE01/R410 (spin-up) per `ADR-0036` v1.2 | 🟡 | `ADR-0036` (owner) |

## Services / roles

| Role | As-built target | Status | Evidence |
|---|---|---|---|
| PostgreSQL 16 | DB + role, localhost-only | ⬜ | `Roles/PostgreSQL/` |
| Redis 7 | cache + queue backends, localhost-only | ⬜ | `Roles/Redis/` |
| NetBox v4.6.5 + gunicorn | pinned app behind gunicorn; migrations applied; rq workers up | ⬜ | `Roles/NetBox/` · `Build-Guide.md` |
| nginx HTTPS | reverse proxy; **self-signed cert day one** | ⬜ | `Diagnostics.md` §4 |
| Data load (IPAM/DCIM) | VLANs/prefixes/addresses + devices/interfaces/cables loaded | ⬜ | `NetBox-Data-Load-Prep.md` |
| **Empty-diff proof** | NetBox-generated SW01 `STATIC-HOSTS`/DAI ACL **diffs empty** vs live | ⬜ | 🔴 the source-of-truth gate — unproven |
| TLS cert from ICA01 | ICA01-issued cert replaces self-signed (Phase 8) | ⬜ | ICA01 build |
| LDAPS-to-AD auth | central login via DC01 (later) | ⬜ | DC01 LDAPS |

> 🔴 **The service is not built.** When a role is stood up, capture the read-back in `Diagnostics.md`, flip its row here, and tick the `Build-Checklist.md` acceptance gate (`POL-0001`). "Source of truth" is not real until the **empty-diff** row is proven.

## Related
- `Build-Checklist.md` (action list + evidence) · `Diagnostics.md` (verify commands) · `Roadmap.md` (build path) · `Considerations.md` (open gates/risks) · `Changes/` (post-build change ledger).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the (near-empty) as-built record for NETBOX01 — a **net-up · service-unbuilt** row (🟡, per `Networking-Build-Guide.md`); every service row ⬜, including the 🔴 empty-diff proof gate. Structured to the host + three roles (PostgreSQL/Redis/NetBox) + the cert/auth enhancements; fills in as each is device-verified. |
