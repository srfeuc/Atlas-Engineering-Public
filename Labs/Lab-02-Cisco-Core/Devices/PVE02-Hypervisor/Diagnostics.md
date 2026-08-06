---
Title: PVE02 — Diagnostics (planned battery — mirrors PVE01)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor
Status: 📋 Planned — the show/verify battery for PVE02, mirroring PVE01's. Nothing verified (PVE02 not built, POL-0001). Populated at the fresh install.
Version: 0.1
Date: 2026-07-30
---

# PVE02 — Diagnostics (planned)

> **The battery mirrors PVE01's** (`../../Virtualization/Build-Records/PVE01-Diagnostics.md`, `ADR-0032`) — same checks, EQR6 values. 🔴 **All 📋 — PVE02 is not built;** these are the read-backs to run at the fresh-install gates (`221`), each flipping ⬜→✅ as it passes.

## Battery (run at build — `221` gates)
| Check | Command | Expected (target) | Status |
|---|---|---|---|
| PVE version / node | `pveversion` / `pvesh get /nodes/pve02/status` | 8.x; node healthy (single node) | 📋 |
| RAM (64 GB prereq) | `free -h` | ~62–63 GiB usable (64 GB installed) — 🔴 fail the gate if 32 GB | 📋 |
| VT-x / KVM | `lsmod \| grep kvm` | `kvm_amd` + `kvm` loaded (AMD Ryzen) | 📋 |
| Storage | `pvesm status` | `local` + `local-lvm` + the 8 TB datastore active | 📋 |
| Mgmt IP | `ip -br address` | `vmbr0.10 = 10.10.0.11/27`; bare `vmbr0`/uplink no L3 | 📋 |
| Default route | `ip route` | default via `10.10.0.1` | 📋 |
| Uplink VLAN membership | `bridge vlan show` | uplink tagged on 10–90,999 (the #1 "VLANs don't work" check) | 📋 |
| Gateway reach | `ping -c4 10.10.0.1` | 0% loss | 📋 |
| Named admin | `pveum user list` | `seth-admin@pve` present; root scoped | 📋 |

> 🔴 **AMD note:** the EQR6 is Ryzen → the KVM module is `kvm_amd` (PVE01/Xeon uses `kvm_intel`); the VT-x check differs accordingly. 🔴 **No iDRAC** — a failed boot needs the HDMI console (WoL only powers it on).

## When PVE02 is built (`ADR-0032`)
Run the battery at each `221` gate; paste read-backs into the clean device-verified PVE02 Build-Records the fresh install creates (the SoT), then mirror the summary into `Build-Record.md` here + `SESSION-HANDOFF.md`.

## Related
- Model: `../../Virtualization/Build-Records/PVE01-Diagnostics.md`. Procedure/gates: `../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`. Networking target: `../../Virtualization/Build-Records/PVE01-Networking.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — the planned show/verify battery for the EQR6, mirroring PVE01's (`ADR-0032`) with EQR6-specific values (64 GB RAM gate, `kvm_amd`, `10.10.0.11/27`, no-iDRAC console). All 📋 until the fresh install (`POL-0001`). |
