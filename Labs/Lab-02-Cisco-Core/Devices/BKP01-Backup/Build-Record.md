---
Title: BKP01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup
Status: 🟡 LIVING — verified as-built state. **Not executed** — the Build-Guide is authored; the VM/services are pending. Records outrank guides (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# BKP01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** "What is actually true now" for BKP01 (`POL-0001` evidence home). **Records outrank guides** — if a guide and this table disagree, this table wins. Markers: 🟡 operator-reported · ⬜ not built. *(No device-verified rows yet — nothing is confirmed on the box.)*

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Host (Linux appliance) + identity | pending | ⬜ | Build-Guide Part 1 |
| IP / VLAN | host `10.20.0.18` · Vaultwarden `10.20.0.13`, VLAN 20 gw `10.20.0.1` — 📋 proposed | ⬜ (target) | `../../Architecture/IP-Addressing-Plan-VLSM.md` |
| Placement | PVE02/EQR6 + 8 TB external (`ADR-0036` v1.2) | ⬜ (target) | Build-Guide Part 0 |
| Hardening (named admin · SSH keys · firewall) | pending | ⬜ | Part 3 |
| **PBS datastore** (on the 8 TB) | pending | ⬜ | `Roles/PBS/` |
| Backup jobs · verify · prune/retention | pending | ⬜ | `Roles/PBS/` |
| 🔴 Off-site copy (restic/borg, encrypted) | pending | ⬜ | `../../Operations/Device-Backup-Runbook.md` |
| 🔴 Restore Game Day (`ADR-0011`) | **never run** | ⬜ | `Roles/PBS/` |
| **Vaultwarden** + ICA01 TLS | pending | ⬜ | `Roles/Vaultwarden/` |
| `049` recovery-path gate | OPEN | ⬜ | `Considerations.md` |

> 🔴 **Nothing device-verified yet** — BKP01 is pre-build (Phase 9, the top live risk). The gating actions are the PBS datastore, the mandatory off-site copy, and 🔴 the restore Game Day that has never run. Rows flip only with a captured read-back (`POL-0001`).

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-07-30 | Created — BKP01 authored but not executed; host, PBS, off-site, restore Game Day, and Vaultwarden all ⬜ pending. |
