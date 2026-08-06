---
Title: NETBOX01 — Considerations (open gates, risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: 🟠 LIVING — the open gates, standing risks, and not-yet-settled decisions on the IPAM/DCIM source of truth. Closed items move to the Build-Record / Change Log.
Version: 0.2
Date: 2026-07-30
---

# NETBOX01 — Considerations (open gates, risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled" list for the source of truth — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`). Each item states the risk and its current disposition. Facts/decisions are **linked to their owners** (`POL-0008`).

## Open gates (must pass — block "done")
- 🔴 **The empty-diff proof.** "Source of truth" is **aspirational until proven**: a NetBox-*generated* SW01 `STATIC-HOSTS`/DAI ACL must **diff empty** against the live device. Until that clean diff exists, NetBox is *documentation*, not a source of truth — and the `006`/Pi01-dropped defect class is not actually fixed. This is the load-bearing acceptance gate for the whole host. → `Roadmap.md` Stage 4.
- 🔴 **Self-signed → ICA01 cert (Phase 8).** NetBox ships behind nginx with a **self-signed cert day one**. It must be replaced with an **ICA01-issued cert** once the intermediate CA is stood up (Phase 8). Until then, browser/API TLS trust is manual. → `Roadmap.md` Stage 5.

## Standing risks (design)
- 🔴 **Generate-don't-type or it goes stale (`POL-0004`).** NetBox only *is* the source of truth if downstream configs are **generated from it**, not typed alongside it. Editing a device directly and not updating NetBox reproduces the `006` failure (hand-typed, wrong; Pi01 silently dropped). The discipline — every change flows *through* NetBox, and Oxidized/Ansible render *from* it — is the mitigation; the empty-diff is the backstop that proves it.
- 🟡 **Not user-facing / R410 spin-up tier.** NETBOX01 lives on **PVE01/R410 (spin-up)** per `ADR-0036` v1.2 — **kept there this pass** (operator 2026-07-30) because it isn't user-facing and nothing *running* breaks if it's down; only **automation/rendering pauses**. Risk: if the R410 is off, no fresh renders. Accepted for now.
- 🟡 **Local auth day one.** NETBOX01 is **not domain-joined day one** — logins are local until LDAPS-to-AD lands. Keep the admin account strong and few; treat central RBAC as a later enhancement, not a control you have now.

## Open decisions (need a call / note when reached)
- ✅ **OS-drift Debian → Ubuntu — RECONCILED (#22 audit, 2026-07-30).** The `Build-Checklist.md` body already read **Ubuntu Server 26.04** (v1.1); the `Build-Guide.md`'s stale "checklist still says Debian" note was updated to reflect that the reconcile is done. Only the **historical changelog rows** still mention Debian (left as history). Ubuntu is authoritative; confirm the clone is Ubuntu **at build** (`POL-0001`).
- ✅ **Phase 3 vs Phase 4 — RECONCILED (#22 audit, 2026-07-30).** The device's `Build-Guide.md` + `Build-Checklist.md` live **"Phase 3 — first"** assertions were updated to **Phase 4 (Source of truth)** to match the build-order owner (`../../Operations/Build-Order-and-Dependencies.md`); the stale `Master-Build-Order.md Phase 3` citation was repointed to the owner (Master-Build-Order is **superseded**). The "built before the automation that renders from it (Phase 10)" intent is preserved. Historical changelog rows keep their original wording.
- 🟡 **LDAPS-to-AD auth — later.** Central auth via DC01 LDAPS is a planned enhancement (`Roadmap.md` Stage 6), gated on DC01 LDAPS + a bind account. Not day one; revisit after the manual build is proven.
- 🟡 **Residual VM sizing → Backlog #20.** Baseline is ~2 vCPU / 4 GB (per the VM Inventory). NetBox + PostgreSQL + Redis + gunicorn workers can outgrow that as the model + rq workload grow. Sizing is deferred to **Backlog #20**.

## Decided (audit #22, 2026-07-30)
- **Services map added to `README.md`** (Standard v1.7 / Backlog #27) — NetBox · PostgreSQL · Redis · REST API · rendered exports (one row per `Roles/` service + the API/exports), all ⬜ (not built, `POL-0001`). Edges already labelled (v1.6) — Services-map-only.
- **Both stale-guide reconciles CLOSED** (see Open decisions above): the **Debian→Ubuntu** note and the **Phase-3→4** phase citations are now consistent with the owners.
- **Networking-Build-Guide: already present** — NETBOX01 **already carries `Networking-Build-Guide.md`** (the cloud-init VLAN-20 `10.20.0.11` bring-up, reported reachable 2026-07-24). It is the **exemplar** the #22 "hosts with fiddly bring-up get one" policy points at; no new doc — it exists.

## Related
- `Roadmap.md` (where these sit in the build path) · `Build-Checklist.md` (line-item status) · `Troubleshooting.md` (incidents) · `Build-Record.md` (as-built) · `ADR-0036` (placement owner) · `POL-0004`/`POL-0008`/`POL-0001` in `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.2 | 2026-07-30 | **#22 audit:** Services map backfilled into `README.md` (Standard v1.7 / Backlog #27, all ⬜). **Both stale-guide reconciles CLOSED** — Debian→Ubuntu (Build-Guide note updated; body was already Ubuntu) + Phase-3→4 (Build-Guide/Build-Checklist live assertions repointed to the owner's Phase 4; superseded Master-Build-Order citation fixed). Recorded that `Networking-Build-Guide.md` already exists (the exemplar). |
| 0.1 | 2026-07-30 | Created — open gates (the 🔴 empty-diff proof; self-signed→ICA01 cert Phase 8), standing design risks (generate-don't-type or it goes stale; R410 spin-up tier; local auth day one), and open decisions (the Debian→Ubuntu OS-drift reconcile — Ubuntu wins; the Phase-3-vs-4 doc discrepancy → #22; LDAPS-to-AD later; sizing → #20). |
