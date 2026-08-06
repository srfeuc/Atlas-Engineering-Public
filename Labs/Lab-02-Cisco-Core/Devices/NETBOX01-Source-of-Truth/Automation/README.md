---
Title: NETBOX01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth/Automation
Status: 📋 Designed stub (`ADR-0048`). Authored *after* the manual first pass — automate what you've learned by hand. 🟡 until each artifact runs idempotently on the device.
Version: 0.1
Date: 2026-07-30
---

# NETBOX01 — Automation (`ADR-0048`)

> **The double role.** NETBOX01 is unusual: it is both a host that *gets* automated **and** the thing the rest of the estate's automation **reads**. The source of truth *is what* Oxidized/Ansible pull from to render every downstream config (`POL-0004`). This folder is NETBOX01's automation **slice** — how-tos + device-specific playbooks — authored **after** the manual first pass, never as a shortcut past the learning. The **runnable shared code** (roles, modules, the CI/git host) is the **estate capability** owned centrally (`../../Operations/Automation/` + the self-hosted git repo — Backlog #19, Phase 10); this folder **links** to it. 🟡 until an artifact runs **idempotently**.

## Planned automation (designed, phased — `ADR-0048` tooling ladder)

| Task | Tool | What it automates | What it does NOT automate (hand-learned first) |
|---|---|---|---|
| **Stack deploy** | Ansible | Install/configure PostgreSQL 16 + Redis 7 + NetBox v4.6.5 + gunicorn + nginx on a fresh Ubuntu clone; idempotent re-run | The *first* manual install — you learn Postgres/Redis/NetBox/gunicorn/nginx by hand once (Roadmap Stages 1–3) |
| **Data seeding** | pynetbox / NetBox API | Bulk-load IPAM/DCIM from the IP plan + cabling (VLANs, prefixes, addresses, devices, interfaces, cables) | Deciding the data model + capturing device-only truth (serials/MACs/ports) — the SoT Evidence Run-Sheet |
| **Render-from-NetBox** | Ansible + Jinja (ENAUTO) | Generate device configs **from** the NetBox API — the SW01 `STATIC-HOSTS`/DAI ACL, the `006` table, the IP register as exports | Writing/understanding the target config the first time (the CCNA/CCNP objective) |
| **Config-in-git / drift** | Oxidized + git (via the git host) | Back up rendered configs + diff drift; surface a non-empty diff as a defect | Judging whether a diff is intended — the reconcile discipline (`POL-0004`) |

## The learning boundary (`ADR-0048`)
- **Automate what you've already done by hand.** No playbook lands before the manual build of that stage is proven (`Roadmap.md`). The "does NOT automate" column above is the line — the exam objectives are exercised by hand first.
- 🔴 **The empty-diff is the acceptance test for render-from-NetBox.** A generated SW01 ACL that diffs empty against the live device is *the* proof that automation reads a trustworthy source of truth. Until it passes, render-from-NetBox is unproven.

## How this fits the estate
- **Phase alignment:** these land at Roadmap **Stage 7** (Automation onboarding), after the manual stack is proven. Estate sequencing: Build-Order **Phase 10** (`ADR-0048`).
- **GitOps:** configs → the self-hosted git (Backlog #19) → review/PR → deploy; the CI runner lints + tests.
- **Cert anchor:** Ansible render-from-NetBox (**CCNP ENAUTO**), API/data-model automation (**CCNA Dom-6**).

## Related
- Estate capability: `../../Operations/Automation/` (shared roles/modules — Backlog #19) · `ADR-0048` in `00-Atlas-Foundation/Decisions/ADR-Index.md`. Build path: `../Roadmap.md` Stage 7. Data seed: `../NetBox-Data-Load-Prep.md`. The proof: `../Diagnostics.md` §5.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the designed `Automation/` stub for NETBOX01 (`ADR-0048`) — the planned Ansible stack-deploy, API data-seeding, **render-from-NetBox** config generation, and Oxidized config-in-git/drift, each with its "does NOT automate" learning boundary; foregrounds NETBOX01's double role (automated host **and** the source automation reads) and the empty-diff acceptance test. Links to the estate capability (`Operations/Automation/` + self-hosted git, Backlog #19). Filled with real artifacts after the manual build (Roadmap Stage 7). |
