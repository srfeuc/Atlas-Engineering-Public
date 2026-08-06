---
Title: PVE01 — Build Record (as-built summary → the Virtualization records)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor
Status: 🟢 LIVING — the as-built summary for the R410 hypervisor. Deep records live in the Virtualization book (POL-0008); this summarizes + points. Core device-verified 07-16/07-24.
Version: 0.1
Date: 2026-07-30
---

# PVE01 — Build Record (as-built summary)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The "what is actually true right now" snapshot for the R410 hypervisor. 🔴 **The deep, authoritative records live in the Virtualization book** (`ADR-0034`, `POL-0008`) — this page is the **device-folder summary** that points to them, so a reader lands here and is routed to the one home per fact. Records outrank guides (`POL-0001`). Markers: ✅ device-verified · 🟡 lab-unverified · 📋 planned.

## PVE01 — Dell PowerEdge R410 · Proxmox VE 8.4.19 (spin-up heavy tier, `ADR-0036` v1.2)

| Attribute | As-built | Status | Authoritative record |
|---|---|---|---|
| Platform / PVE | Dell R410 · Proxmox VE 8.4.19 · Debian 12 · kernel 6.8.12-32-pve · `pve01.lab` (standalone) | ✅ (07-16) | `215-PVE01-Current-State.md` |
| CPU | 2× Xeon E5620 — **16 logical CPUs** (not 32) | ✅ (07-16) | `217-Verified-Facts.md` |
| RAM | 64 GB physical / **62 GiB usable**; DIMM B1 faulty → B3 | ✅ (07-16) | `217-Verified-Facts.md` |
| VT-x / KVM | enabled (re-enabled 07-11); `kvm_intel`+`kvm` loaded | ✅ (07-16) | `PVE01-Diagnostics.md` §1 |
| Networking | tagged `vmbr0.10 = 10.10.0.10/27`, bare `vmbr0` (no L3), `bridge-vids 10–90,999`, native 999; `eno1`→SW01 `Gi1/0/4` 1 Gbps | ✅ (07-24) | 🔴 **`PVE01-Networking.md`** (`ADR-0034`) |
| Storage | `local` ~94 GB (dir) + `local-lvm` ~793 GB (LVM-thin), active | ✅ (07-16) | `PVE01-Storage.md` (new #21) |
| Authentication | `root@pam` (recovery) + `seth-admin@pve` (Administrator at `/`, propagate) | ✅ / 🟡 ACL review | `PVE01-Authentication.md` (new #21) |
| iDRAC | shared-LOM `10.10.0.100/24` on `eno1` — **not OOB**; factory creds unchanged | 🔴 gap | `Considerations.md` (`CM-0011`) |
| CMOS/RTC | battery dead — resets `2026`→`2018` on power loss; keep on UPS | 🔴 open | `Considerations.md` (`CM-0012`) |
| VM backups | none — PBS on BKP01 planned/unbuilt | 📋 | `../BKP01-Backup/` |
| Hosted VMs | spin-up tier (DC02 · MON01 heavy · NETBOX01 · WSUS01 · SQL01 · KALI01 · cluster node) + resident DC01/templates | see README | `../../Service-Server-Build-Plan.md` |

> 🔴 **Outstanding read-backs (flip 🟡→✅ in the Virtualization records):** `bridge vlan show` (eno1 tagged on all VM VLANs) · `pveum acl list` (least-privilege review) · `pvesm status` re-confirm. Paste into the Virtualization Build-Records (the SoT), then mirror here.

## Related
- **Authoritative records (deep home):** `../../Virtualization/Build-Records/` — `PVE01-Networking` · `215-PVE01-Current-State` · `PVE01-Storage` (new) · `PVE01-Authentication` (new) · `PVE01-Diagnostics` · `216-Windows-Golden-Image-Historical-Record`; `../../Virtualization/Reference/217-Verified-Facts-and-Reconciliation-Notes.md`.
- `Roadmap.md` · `Considerations.md` · `Diagnostics.md` · `Build-Guide.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — the device-folder as-built **summary** consolidating the R410's verified state (platform/CPU/RAM/VT-x 07-16, networking 07-24) and routing every row to its authoritative Virtualization Build-Record (`ADR-0034`/`POL-0008`). iDRAC + CMOS gaps and the no-VM-backups deviation carried; outstanding read-backs flagged. |
