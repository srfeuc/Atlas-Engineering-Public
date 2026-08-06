---
Title: NETBOX01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: 🟢 LIVING roadmap — the per-service build path for the IPAM/DCIM source of truth + what each stage needs and unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`); this page is the map, the checklist is the line-item record.
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 — Roadmap (build path + connections)

> **How to read this.** Each row is a **stage** on the source-of-truth build. The checkbox is its status — **dated** and evidence-backed (the record is `Build-Checklist.md`). **Needs** = what must be healthy first; **Unblocks** = what proceeds once it's done. Enterprise-first; each stage names the cert objective it exercises (`ADR-0044`). Gated/future stages are **designed stubs** (`ADR-0043`), not empty placeholders.

## The build path (in order — Phase 4, Source of truth)

### Stage 0 — Gates
- [ ] 🔴 **Net bring-up done** — VLAN 20, `10.20.0.11`, reachable/SSH (see `Networking-Build-Guide.md`, reported 2026-07-24). *Needs:* PVE01/R410 → SW01 → MKT01 gw. *Unblocks:* the service install. *Cert:* CCNA Dom-1/4.
- [ ] 🔴 **DC01 DNS + time healthy** — name resolution (`atlas.lab`) + a synced clock. *Unblocks:* TLS, later LDAPS. *Cert:* CCNA Dom-4.

### Stage 1 — Host stand-up
- [ ] 📋 **Clone / identity / harden** — Ubuntu 26.04 clone of `TPL-UBUNTU2604`; hostname NETBOX01; CIS-Ubuntu hardening (named admin, SSH keys, host firewall, `unattended-upgrades`). *Needs:* Stage 0. *Unblocks:* PostgreSQL. → `Roles/` (host owns OS/IP/hardening). *Cert:* Linux+/LPIC-adjacent.

### Stage 2 — Data tier
- [ ] 📋 **PostgreSQL 16** — DB + role + strong password; localhost-only. *Needs:* host up. *Unblocks:* NetBox migrations. → `Roles/PostgreSQL/`. *Cert:* DCIM/data practice.
- [ ] 📋 **Redis 7** — cache + task queue backends; localhost-only. *Needs:* host up. *Unblocks:* NetBox + rq workers. → `Roles/Redis/`. *Cert:* automation infra.

### Stage 3 — Application
- [ ] 📋 **NetBox v4.6.5 + gunicorn + nginx HTTPS** — pinned NetBox behind gunicorn (WSGI) behind nginx; strong `SECRET_KEY`; **self-signed cert day one**. *Needs:* PostgreSQL + Redis. *Unblocks:* data load + the API. → `Roles/NetBox/` + `Build-Guide.md`. *Cert:* CCNA Dom-6 (automation infra).

### Stage 4 — Load the truth
- [ ] 📋 **Data load from the IP plan + cabling** — import VLANs/prefixes/addresses (IPAM) + devices/interfaces/cables (DCIM) per `NetBox-Data-Load-Prep.md`; device-only fields (serials/MACs/ports) via the SoT Evidence Run-Sheet. *Needs:* app up. *Unblocks:* generated exports + the empty-diff proof. *Cert:* DCIM/documentation practice.
- [ ] 🔴 **Empty-diff proof** — a NetBox-*generated* SW01 `STATIC-HOSTS`/DAI ACL that **diffs empty** against the live device. *Why:* until it passes, "source of truth" is aspirational (it's just documentation). *Unblocks:* trusting NetBox as the render source; fixes the Pi01-dropped defect. *Cert:* CCNP ENAUTO.

### Stage 5 — TLS from ICA01 (Phase 8, gated)
- [ ] 📋 **Replace the self-signed nginx cert with an ICA01-issued cert.** *Gate:* ICA01 (the intermediate CA) stood up at Phase 8. *Needs:* ICA01 issuing. *Unblocks:* trusted HTTPS for browsers + API clients. *Cert:* Security+ (PKI).

### Stage 6 — LDAPS-to-AD auth (later, gated)
- [ ] 📋 **LDAPS auth to DC01 (`atlas.lab`).** *Gate:* an enhancement — **not domain-joined day one**; local admin until then. *Needs:* DC01 LDAPS + a bind account. *Unblocks:* central identity/RBAC for NetBox logins. *Cert:* Security+ / AZ-800-adjacent.

### Stage 7 — Automation onboarding (Phase 10, gated — `ADR-0048`)
- [ ] 📋 **Oxidized/Ansible render configs FROM the NetBox API**, authored *after* the manual first pass. *Gate:* the empty-diff proof passed + the estate IaC capability exists. *Needs:* Stage 4 proven. *Unblocks:* generate-don't-type at fleet scale; the `006` table + IP register as rendered exports. → `Automation/`. *Cert:* CCNP ENAUTO · CCNA Dom-6.

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PVE01/R410 → SW01 → MKT01 (gw `10.20.0.1`) | VLAN-20 reachability |
| ⬆ Depends on | `TPL-UBUNTU2604` golden image | the clone source |
| ⬆ Depends on | DC01 | DNS (`atlas.lab`) + time · later LDAPS |
| ⬆ Depends on | ICA01 (Phase 8) | TLS cert (replaces self-signed) |
| ⬇ Serves | automation (Oxidized/Ansible, Phase 10) | REST API — render configs FROM NetBox |
| ⬇ Serves | SW01 | generated `STATIC-HOSTS`/DAI ACL (empty-diff proof) |
| ⬇ Serves | the IP register + `006` table | rendered exports (`POL-0004`) |

## Certification alignment (learning lens)

> The estate cert mapping lives in `Atlas-Academy/`; this is NETBOX01's slice (`ADR-0044`).

| NETBOX01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| IPAM/DCIM as source of truth | Documentation practice, address management | DCIM/documentation · CCNA Dom-6 |
| API + render-from-NetBox | Automation, REST/JSON, data-model-driven config | CCNA Dom-6 (automation) |
| Ansible renders from NetBox (empty-diff) | Infrastructure-as-code, idempotency, config templating | CCNP **ENAUTO** |
| TLS cert from ICA01 | PKI, certificate lifecycle | Security+ |
| LDAPS-to-AD auth | Directory auth, LDAPS | Security+ · AZ-800-adjacent |

## Future / enhancements (gated)

- [ ] 📋 **TLS cert from ICA01** (Stage 5, Phase 8) — gate: ICA01 up.
- [ ] 📋 **LDAPS-to-AD auth** (Stage 6) — gate: an enhancement, not day one.
- [ ] 📋 **Automation onboarding** (Stage 7, Phase 10) — gate: empty-diff proof + estate IaC capability.
- [ ] 📋 **Residual VM sizing** → **Backlog #20** (2 vCPU / 4 GB baseline; revisit as the model grows).

## Related
- Line-item status: `Build-Checklist.md`. Front door: `README.md`. Open risks: `Considerations.md`. Verify: `Diagnostics.md`.
- Estate index: `../../Service-Server-Build-Plan.md` (NETBOX01 = **Phase 4**, per `../../Operations/Build-Order-and-Dependencies.md`). Addressing: `../../Architecture/IP-Addressing-Plan-VLSM.md`. Flows: `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`. Decisions: `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created — per-stage build path (host → PostgreSQL → Redis → NetBox/gunicorn/nginx → data load + the 🔴 empty-diff proof → ICA01 TLS (Phase 8, gated) → LDAPS auth (later, gated) → automation onboarding (Phase 10, gated)), the connections-at-a-glance + cert-alignment tables, and the gated futures (sizing → #20). Aligned to the build-order owner's **Phase 4**. |
