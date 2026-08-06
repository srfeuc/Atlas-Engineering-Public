---
Title: PVE01 Current State
Document Type: Build Record
Verification Status: Verified from live host output
Last Verified: July 2026
---

# PVE01 Current State

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Identity

| Item | Value |
|---|---|
| Hostname | `pve01` |
| FQDN | `pve01.lab` |
| Proxmox VE | 8.4.19 |
| Base OS | Debian GNU/Linux 12 |
| Kernel observed | 6.8.12-32-pve |
| Hardware | Dell PowerEdge R410 |

## Compute

| Item | Value |
|---|---|
| CPUs | 2 × Intel Xeon E5620 |
| Cores per socket | 4 |
| Threads per core | 2 |
| Logical CPUs | 16 |
| Virtualization | Intel VT-x — was found BIOS-disabled (dead CMOS battery); re-enabled 2026-07-11 |
| RAM | 62 GiB usable (64 GB physical, upgraded 2026-07-11; DIMM slot B1 found faulty, RAM relocated to B3) |
| Swap | 8 GiB |

## Networking

> 🔴 **This table is the 2026-07-11 snapshot and its networking is SUPERSEDED. Authoritative home = `PVE01-Networking.md` (`ADR-0034`, `POL-0008`).** The current device-verified design (2026-07-24) is host management on a **tagged `vmbr0.10` sub-interface, `10.10.0.10/27`**, with **SW01 `Gi1/0/4` trunk native VLAN 999** (bare `vmbr0` holds no L3). The `/24` + untagged-native-10 below is the old design (it broke a VLAN-10-tagged VM's return path — see `PVE01-Networking.md` History). Corrected values annotated inline.

| Item | Value |
|---|---|
| Production NIC | `eno1` |
| Secondary NIC | `eno2`, unused |
| Bridge | `vmbr0` (VLAN-aware; **no L3** in the current design — management moved to `vmbr0.10`) |
| Address | ~~`10.10.0.10/24`~~ → **`10.10.0.10/27` on `vmbr0.10`** (corrected 2026-07-24; `PVE01-Networking.md`) |
| Gateway | `10.10.0.1` |
| VLAN awareness | Enabled (`bridge-vids 10–90,999`) |
| Management VLAN | ~~VLAN 10, untagged~~ → **VLAN 10, TAGGED** (`vmbr0.10`); SW01 `Gi1/0/4` native = **999** |
| Switch port | SW01 Gi1/0/4 (trunk, native 999) |

## Storage

| Name | Type | Approximate total | Usage at verification |
|---|---|---:|---:|
| `local` | Directory | 94 GB | Approximately 15% |
| `local-lvm` | LVM-thin | 793 GB | Approximately 9.5% |

## Authentication

| Account | Realm | Role |
|---|---|---|
| `root@pam` | PAM | Host recovery and Linux administration |
| `seth-admin@pve` | PVE | Administrator at `/`, propagation enabled |

## Inventory

| VMID | Name | State/type |
|---:|---|---|
| 100 | `WIN2025-BUILD-ARCHIVE` | Archived build VM |
| 101 | `DC01` | Windows Server VM |
| 9000 | `TPL-WIN2025` | Template |

## Known issue

The Proxmox GUI shell/noVNC terminal had a connection-refused issue in earlier records. SSH remained functional. Re-verify before carrying the issue forward as current.

## Validation

```bash
hostname
hostname -f
pveversion -v
lscpu
free -h
ip -br address
ip route
pvesm status
qm list
pveum user list
pveum acl list
```
