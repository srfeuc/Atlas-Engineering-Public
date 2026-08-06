---
Title: PVE01 — Diagnostics (pointer to the Virtualization show-battery)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor
Status: 🟢 Pointer — the read-only health/verify battery for PVE01 lives in the Virtualization book (ADR-0032). This page routes to it.
Version: 0.1
Date: 2026-07-30
---

# PVE01 — Diagnostics (pointer)

> **The show/verify battery for PVE01 already exists** — `../../Virtualization/Build-Records/PVE01-Diagnostics.md` (`ADR-0032`), seeded alongside the authoritative networking record. This page is the device-folder front door to it (`POL-0008`); it does not restate the commands.

## Go here
- 🔴 **`../../Virtualization/Build-Records/PVE01-Diagnostics.md`** — the full battery: PVE version/node · 16 logical CPUs · VT-x/KVM · storage · mgmt IP on `vmbr0.10` · default route · `bridge vlan show` uplink membership · link speed · GUI/API · `qm list` · time (RTC caveat) · reciprocal SW01-trunk checks · iDRAC shared-LOM caveat · journal/task logs.

## Quick reference (the load-bearing checks — full command + expected in the battery)
| Check | Command | Expected | Verified |
|---|---|---|---|
| Logical CPUs (not 32) | `grep -c '^flags.*vmx' /proc/cpuinfo` | **16** | ✅ (07-16) |
| Mgmt IP | `ip -br address` | `vmbr0.10 = 10.10.0.10/27`; bare `vmbr0`/`eno1` no L3 | ✅ (07-24) |
| Uplink VLAN membership | `bridge vlan show` | `eno1` tagged on 10–90,999 (the #1 "VLANs don't work" check) | 🟡 |
| Storage | `pvesm status` | `local` + `local-lvm` active | ✅ (07-16) |
| Gateway | `ping -c4 10.10.0.1` | 0% loss | ✅ (07-24) |

> 🔴 **iDRAC is shared-LOM on `eno1` — NOT out-of-band; the physical console is the real bootstrap.** 🔴 **RTC resets on power loss (`CM-0012`) — keep on UPS.**

## If you built or changed PVE01 solo (`ADR-0032`)
Paste `ip -br a` / `bridge vlan show` / `pvesm status` / `pveum acl list` read-backs → flip 🟡→✅ in the **Virtualization Build-Records** (the SoT), then mirror the state summary into `Build-Record.md` here and `SESSION-HANDOFF.md`.

## Related
- `../../Virtualization/Build-Records/PVE01-Diagnostics.md` (the battery) · `../../Virtualization/Build-Records/PVE01-Networking.md` (SoT) · `Troubleshooting.md` · `Build-Record.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — front-door pointer to the existing `PVE01-Diagnostics` battery in the Virtualization book (`ADR-0032`/`POL-0008`), with a quick-reference of the load-bearing checks + the iDRAC/RTC caveats. |
