---
Title: PVE02 — Build Record (as-built — not yet built)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor
Status: ⬜ NOT BUILT — PVE02 (EQR6) is acquired but not stood up. No verified state exists (POL-0001). Populated during the fresh install (#21 / the 221 runbook).
Version: 0.1
Date: 2026-07-30
---

# PVE02 — Build Record (as-built)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The "what is actually true right now" snapshot for the EQR6 hypervisor. 🔴 **Nothing is device-verified — PVE02 is acquired but NOT stood up.** Every row is ⬜ until the fresh install reads it back (`POL-0001`). Target values are the **plan** (`ADR-0036` v1.1/v1.2 + the `221` runbook); the product sheet is not evidence. Records outrank guides once real.

## PVE02 — Beelink EQR6 · Proxmox VE 8.x (always-on critical tier, `ADR-0036` v1.2)

| Attribute | Target (📋 plan — confirm on the unit) | Status | Will be recorded in |
|---|---|---|---|
| Platform | Beelink EQR6 · Ryzen 9 6900HX (8C/16T, Zen3+, Radeon 680M) | ⬜ | this record (at build) |
| RAM | 32 GB shipped → 🔴 **64 GB (2× 32 GB DDR5-4800)** prerequisite | ⬜ | this record |
| Storage | 500 GB NVMe (2× M.2 to 4 TB) + **8 TB external** (PBS + FS01); optional dedicated 2nd NVMe | ⬜ | a PVE02-Storage record (at build) |
| Proxmox VE | latest 8.x; `pve02` / `pve02.lab` (standalone) | ⬜ | this record |
| Networking | tagged `vmbr0.10 = 10.10.0.11/27` 📋, bare `vmbr0` (no L3), `bridge-vids 10–90,999`, native 999; new DAI-trusted SW01 trunk | ⬜ | a PVE02-Networking record (mirror PVE01, `ADR-0034`) |
| Authentication | `root@pam` (recovery) + `seth-admin@pve` (named admin) | ⬜ | a PVE02-Authentication record |
| Console / OOB | **no iDRAC** — HDMI+keyboard; **WoL + Auto-Power-On** (remote power, no remote console) | ⬜ | `Considerations.md` |
| Cluster | none (standalone, `ADR-0046`) | ⬜ | — |
| Hosted VMs | the always-on tier (DC01·ICA01·NPS01·SRV01·BKP01·Vaultwarden·FS01·MON01 probe·RDS01·WAC01·PAW01·CNT01 slice) | ⬜ | README Services map + `../../Service-Server-Build-Plan.md` |

> 🔴 **To make this record real:** execute the `221` runbook; at each Phase-N gate paste the read-backs (`pveversion`, `ip -br a`, `bridge vlan show`, `pvesm status`, `pveum user list`) into the clean device-verified PVE02 Build-Records the fresh install creates, then summarize here. Until then this page is a placeholder that says, honestly, "not built."

## Related
- Procedure: `../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`. Networking model: `../../Virtualization/Build-Records/PVE01-Networking.md`. Placement/sizing: `../../Service-Server-Build-Plan.md`. Open risks: `Considerations.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — the ⬜ not-built as-built record for the EQR6, listing the target attributes (64 GB prereq, 8 TB storage, mirror-PVE01 networking, no-iDRAC/WoL, standalone) as the plan and stating honestly that no state is device-verified (`POL-0001`); populated during the fresh install via the `221` runbook. |
