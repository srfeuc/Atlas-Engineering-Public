# Atlas Proxmox and Windows Server Documentation v0.1

> 🚪 **Front doors (`#21`, 2026-07-30).** The hypervisors now have device page-sets: **`../../Devices/PVE01-Hypervisor/`** (built; the R410 spin-up tier) and **`../../Devices/PVE02-Hypervisor/`** (target-state; the EQR6 always-on tier). **Those `Devices/` folders are the front door**; this Virtualization pack stays the **deep build-record/procedure home** they link into (`POL-0008`, `ADR-0034`). Placement/sizing owner: `../../Service-Server-Build-Plan.md` (`ADR-0036`).

This package contains both:

1. **Build Guides** — target-state, start-to-finish procedures.
2. **Build Records** — the verified state of the environment as currently known.

## Important status

The Proxmox host, networking, storage, authentication, VM inventory, and template 9000 configuration are grounded in live command output collected in July 2026.

Some historical Windows installation actions were not preserved as exact command transcripts. Those procedures are written as detailed target-state guides and are marked for verification during the next rebuild or template refresh.

## Verified facts used throughout

| Item | Verified value |
|---|---|
| Host | `pve01` |
| FQDN | `pve01.lab` |
| Proxmox VE | `8.4.19` |
| Base OS | Debian 12 |
| Hardware | Dell PowerEdge R410 |
| CPU | 2 × Intel Xeon E5620 |
| Logical CPUs | 16 |
| RAM | 62 GiB usable (64 GB physical, upgraded 2026-07-11 — see Reference/Verified Facts live-session addendum) |
| Management IP | `10.10.0.10/24` |
| Gateway | `10.10.0.1` |
| Bridge | `vmbr0`, VLAN-aware |
| Primary NIC | `eno1` |
| Storage | `local`, `local-lvm` |
| Named administrator | `seth-admin@pve` |
| Windows template | VMID `9000`, `TPL-WIN2025` |
| Domain controller VM | VMID `101`, `DC01` |

## Suggested reading order

1. `Build Guides/00 - Guide Index.md`
2. Dell R410 preparation
3. Proxmox installation
4. Post-install configuration
5. Proxmox networking and storage
6. Proxmox authentication
7. Windows Server 2025 VM build
8. Windows base configuration
9. Golden-image preparation
10. Template conversion
11. Clone and DC01 deployment
12. Build Records for the verified current state
