---
Title: PVE01 Storage — Build Record
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Records
Status: 🟢 Verified reality (partial) — the authoritative home for PVE01's storage layout (POL-0008). local/local-lvm device-verified 2026-07-16; RAID/virtual-disk detail 🟡 still to read back. Verify on the device before trusting a doc (POL-0001).
Version: 1.0
Date: 2026-07-30
---

# PVE01 Storage — Build Record

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build)** — Host: **PVE01** (Dell R410 hypervisor). Role: **Proxmox VE storage layout.** Created in the `#21` sweep to close `VIRTUALIZATION-PACK-MANIFEST` **Freeze #3** (the missing Storage Build-Record).

> 🔴 **One authoritative home for PVE01's storage (`POL-0008`).** The build **procedure** lives in `Build-Guides/205-Proxmox-Storage.md` (target-state); this is the **verified state**. Records outrank guides (`POL-0001`).

## Document Control
| Item | Value |
|---|---|
| Owner | Atlas Engineering (Virtualization book) |
| Status | 🟢 **Verified** — `local` / `local-lvm` from live `pvesm status` (2026-07-16). 🟡 **Open:** RAID controller + virtual-disk detail, and current free-space %, still to read back. |
| Version | 1.0 |
| Applies To | **PVE01** — Proxmox VE 8.4.19 (Debian 12) |
| Authoritative for | PVE01 host storage: datastores, sizes, thin-pool, swap (`POL-0008`). Procedure: `Build-Guides/205-Proxmox-Storage.md`. |
| Governing | `POL-0001` (evidence), `POL-0008` (one home), `POL-0005` (backup/recovery — the datastore for backups lives on BKP01, not here). |

## Datastores (device-verified 2026-07-16)

| Name | Type | Approx. total | Usage at verification | Purpose | Status |
|---|---|---:|---:|---|---|
| `local` | Directory | ~94 GB | ~15% (07-16) | ISOs, templates, snippets, backups-dir (host OS volume) | ✅ active (`pvesm status`) |
| `local-lvm` | LVM-thin | ~793 GB | ~9.5% (07-16) | VM disk images (thin-provisioned) | ✅ active (`pvesm status`) |
| swap | swap | 8 GiB | — | host swap | ✅ (07-16, `215-Current-State`) |

> 🔴 **Thin-provisioning caveat.** `local-lvm` is **LVM-thin** — the sum of VM virtual-disk sizes can exceed the pool; watch actual allocation (`lvs`, data% on the thin pool). An over-committed thin pool that fills stops all VMs on it.

## Not on this host (`ADR-0036` v1.2 — placement)
- **The backup datastore is NOT on PVE01.** PBS's datastore lives on the **8 TB external attached to PVE02/EQR6** (`ADR-0036` v1.2) — PVE01 is a **backup source**, not the store. "No backups of any VM, ever" is the standing deviation until BKP01/PBS is built (`POL-0005`).
- **FS01 file shares** are on the EQR6 8 TB, not PVE01.

## Evidence needed (🟡 — read back to complete this record, `POL-0001`)
- **Dell PERC RAID controller model + virtual-disk layout** (RAID level, disk count/size backing `local`/`local-lvm`) — listed "still needed" in `217-Verified-Facts`; read back with `pvesm status -content`, `lvs`, `vgs`, `pvs`, and the Dell controller (`omreport`/`storcli` if available, or iDRAC).
- **Current free-space %** on both datastores (the 07-16 figures are a point-in-time snapshot).
- **Thin-pool data%/metadata%** (`lvs -a`) — the over-commit watch.

## Verify (paste read-backs → flip 🟡→✅)
```bash
pvesm status
pvesm status -content images,rootdir
lvs -a ; vgs ; pvs
df -h /var/lib/vz
cat /proc/swaps
```

## Related
- `Build-Guides/205-Proxmox-Storage.md` (procedure) · `215-PVE01-Current-State.md` (the 07-16 snapshot) · `Reference/217-Verified-Facts-and-Reconciliation-Notes.md` (evidence-needed list) · `PVE01-Diagnostics.md` §1 (storage check) · `../../Devices/PVE01-Hypervisor/` (device front-door) · `../../Devices/BKP01-Backup/` (the backup datastore's real home).

## Change Log
| Version | Changes |
| 1.0 | 2026-07-30 (#21). Created as the authoritative PVE01 storage Build-Record, closing manifest Freeze #3. Records the device-verified `local` (~94 GB dir) + `local-lvm` (~793 GB LVM-thin) + 8 GiB swap from live `pvesm status` (07-16, `215-Current-State`); the thin-provisioning over-commit caveat; the placement fact that the backup datastore lives on BKP01/EQR6 (`ADR-0036` v1.2), not here; and the still-open RAID/virtual-disk + free-space read-backs (🟡, `217-Verified-Facts`). |
