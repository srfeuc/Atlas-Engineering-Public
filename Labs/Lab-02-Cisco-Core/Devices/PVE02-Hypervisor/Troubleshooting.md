---
Title: PVE02 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor
Status: 🟠 Seeded (target-state) — anticipated EQR6/Proxmox + migration failure modes. Grows real as PVE02 is built. Verify commands → the planned Diagnostics battery.
Version: 0.1
Date: 2026-07-30
---

# PVE02 — Troubleshooting (symptom → cause → fix)

> Symptom-first fixes for the EQR6 hypervisor + the migration. 🔴 **Seeded from the plan** (`221` + the PVE01 experience) — grows real as PVE02 is stood up. Verify commands: `Diagnostics.md`; networking model: `../../Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`).

| Symptom | Likely cause | Fix |
|---|---|---|
| **Always-on stack won't all fit / host swapping** | Only **32 GB** installed — the ~44 GB always-on set overruns it | 🔴 Install the **64 GB** kit (`ADR-0036` prerequisite) before carrying the tier; or swing PAW01 then RDS01 to the R410 spin-up tier. |
| **A migrated VM has no network on its VLAN** | VLAN tagged on the vNIC but not in `bridge-vids`, or the SW01 trunk isn't DAI-trusted | `bridge vlan show` → confirm the uplink lists the VLAN; add to `bridge-vids 10–90,999`, `ifreload -a`. Confirm the SW01 port is native-999 + **DAI-trusted** (owned by the SW01 page-set). |
| **DC01 quarantined / replication broken after the move** | 🔴 Restored an **old snapshot** of the DC → **USN rollback** | Only ever restore the **clean-shutdown PBS backup** (PBS preserves the VM-GenerationID). If it happened: DC02 is the authority; do **not** boot the old R410 DC01. Follow the `221` DC caveat. |
| **DC time wrong after migration** | Host clock not set before the DC booted | Set the EQR6 chrony/BIOS clock to the `ADR-0020` source **before** DC01 boots; `w32tm /resync` on the PDCe. |
| **Can't reach the host to fix a failed boot** | 🔴 **No iDRAC** — WoL powers it on but there is **no remote console** | Physical HDMI+keyboard at the unit. (WoL/Auto-Power-On only power it on/recover after outage.) |
| **S2D replication painfully slow** | 🔴 **1 GbE-only** storage network (`ADR-0046`) | Add a USB-C → 2.5/5GbE adapter, use the iSCSI-on-FS01 fallback, or accept slow-S2D as a documented lab limit. |
| **Lost FS01 shares + backups + vault at once** | 🔴 Single-8 TB SPOF (all three share one drive) | This is why the **off-site copy is mandatory** (`ADR-0009`) + restore-tested; move the BKP01 datastore to a dedicated 2nd NVMe to split the failure domain. |
| **Specs don't match the plan** | Product-sheet values assumed, not read back | Confirm CPU/NIC/RAM/NVMe on the live unit at install (`POL-0001`); the device is the truth, the sheet is the plan. |

## Escalation
- Migration specifics (dependency order, DC USN-rollback method, rollback/break-glass) → `../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`.
- Networking → `../../Virtualization/Build-Records/PVE01-Networking.md` + `204-Proxmox-Networking.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — seeded symptom→cause→fix for the EQR6 + migration: RAM overrun (64 GB prereq), VM-VLAN drop (`bridge-vids`/DAI-trusted), DC USN-rollback, DC time, no-iDRAC console, 1 GbE/S2D, single-8 TB SPOF, spec-vs-plan. Grows real as PVE02 is built; links to the `221` runbook + `PVE01-Networking`. |
