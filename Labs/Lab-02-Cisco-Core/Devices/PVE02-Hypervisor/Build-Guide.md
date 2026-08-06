---
Title: PVE02 — Build Guide (pointer to the 221 bring-up runbook)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor
Status: 🟢 Pointer — the executable bring-up + migration procedure is the 221 runbook (target-state, gated). Clean device-verified records come from the fresh install (#21).
Version: 0.1
Date: 2026-07-30
---

# PVE02 — Build Guide (pointer)

> **This is a front-door index, not a second procedure (`POL-0008`).** PVE02's bring-up + the migration of the always-on tier off the R410 is the **`221` runbook** — phased, gated, target-state. This page points to it (and to the networking model it mirrors) so a successor knows exactly where the executable steps are. 🔴 **Nothing is device-verified — PVE02 is not built.**

## The bring-up + migration procedure
- 🔴 **`../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`** — the home procedure: Phase 0 prerequisites gate (64 GB, 8 TB, clock, SW01 trunk, PBS+off-site+DC02) · Phase 1 EQR6 bring-up · Phase 2 network (mirror PVE01 — tagged `vmbr0.10`, native 999, DAI-trusted uplink) · Phase 3 PBS restore = the Game Day · Phase 4 dependency-order migration (DC01→ICA01→NPS01→SRV01→Vaultwarden→FS01, with the DC USN-rollback / VM-GenerationID method) · Phase 5 cutover · rollback/break-glass.
- **Teaching companion (the "why"):** `Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (V1). IaC follow-on: `Concepts/Ansible-IaC-Device-Provisioning.md` (A1).

## The networking model to mirror (`ADR-0034`)
- **`../../Virtualization/Build-Records/PVE01-Networking.md`** — PVE02 copies this exactly (tagged management on `vmbr0.10`, native 999, `bridge-vids 10–90,999`). Procedure reference: `../../Virtualization/Build-Guides/204-Proxmox-Networking.md`. The **switch-side** trunk is owned by `../SW01-Access-Switch/` — add PVE02's port there, don't duplicate.

## Verified state (from the fresh install — `POL-0001`)
- **`Build-Record.md`** — ⬜ empty until PVE02 is stood up. The clean, device-verified PVE02 Build-Guides + Build-Records get written **during the fresh install** (`#21` — "document everything"); they will flesh out and supersede the `221` target-state plan and the R410-era `2xx` carry-over.
- **`Diagnostics.md`** — 📋 the show/verify battery (mirrors `../../Virtualization/Build-Records/PVE01-Diagnostics.md`), populated at build.

## Target facts (📋 proposed — verify on the unit; #20 owns sizing/addressing)
| Item | Planned value | Note |
|---|---|---|
| Hardware | Beelink EQR6 (Ryzen 9 6900HX 8C/16T) | 🔴 **64 GB RAM prerequisite** before the always-on stack |
| Proxmox VE | Latest 8.x | match/lead PVE01's 8.4.19 |
| Hostname / FQDN | `pve02` / `pve02.lab` | standalone, not domain-joined |
| Management | tagged `vmbr0.10` = `10.10.0.11/27` 📋 | mirror PVE01; IP plan owns |
| Datastore | `local`/`local-lvm` + the 8 TB external (PBS + FS01) | consider a dedicated 2nd NVMe for PBS |
| Named admin | `seth-admin@pve` | same model as PVE01 (`206`) |
| Cluster | none (standalone) | `ADR-0046` — on-demand only |

## Related
- `Roadmap.md` (the gated stages) · `Considerations.md` (risks: 64 GB prereq, single-8 TB SPOF, no-iDRAC, USN-rollback) · `../../Virtualization/VIRTUALIZATION-PACK-MANIFEST.md` (pack index).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — front-door pointer to the `221` bring-up + migration runbook (the home procedure), the `PVE01-Networking` model PVE02 mirrors (`ADR-0034`), the V1/A1 teaching companions, and the target facts (64 GB prereq, `.11`/27 mgmt, standalone). Notes the clean device-verified records come from the fresh install (`POL-0001`). |
