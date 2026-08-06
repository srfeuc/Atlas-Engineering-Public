---
Title: Install Proxmox VE on PVE01
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Install Proxmox VE on PVE01

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 Procedure (target-state). **Networking reconciled to the authoritative `PVE01-Networking.md` (`ADR-0034`) in the #22 audit, 2026-07-30** — the stale `/24`-untagged-native-10 values were corrected to the current tagged `vmbr0.10` `/27` (native 999) design. See Change Log. |
| Version | 1.1 |
| Applies To | PVE01, Proxmox VE 8.4.19 (Debian 12) |

## Purpose

Install Proxmox VE on the prepared Dell PowerEdge R410 and establish first administrative access.

## Target Identity and Addressing

> 🔴 **Authoritative networking = `../Build-Records/PVE01-Networking.md` (`ADR-0034`, `POL-0008`); the full procedure is `204-Proxmox-Networking.md`.** The installer sets a simple initial address on the bare `vmbr0`; the **current device-verified design (2026-07-24)** is host management on a **tagged `vmbr0.10` sub-interface, `10.10.0.10/27`**, with **SW01 `Gi1/0/4` trunk native VLAN 999** (bare `vmbr0` holds no L3). The earlier untagged-native-10 `/24` design was **superseded on 2026-07-24** (it broke a VLAN-10-tagged VM's return path). Enter the installer values below, then reconcile to the tagged design in `204`.

| Setting | Value |
|---|---|
| Hostname | `pve01` |
| FQDN | `pve01.lab` |
| Management IP | `10.10.0.10/27` *(mask corrected from the old `/24`; matches the Management `/27` in `IP-Addressing-Plan-VLSM`)* |
| Gateway | `10.10.0.1` |
| Management bridge | `vmbr0` (installer default) → **migrated to a tagged `vmbr0.10` sub-interface in `204`** |
| Management VLAN | **VLAN 10, tagged** on `vmbr0.10` (final design). *The installer's initial config is untagged on `vmbr0`; `204` moves it to tagged `vmbr0.10` and sets SW01 `Gi1/0/4` native → 999.* |
| DNS during build | A reachable resolver; migrate to Windows DNS after deployment |
| Time zone | America/Chicago |

## Prerequisites

- Dell R410 preparation complete (`201-Dell-PowerEdge-R410-Preparation.md`)
- Proxmox ISO downloaded from the official project
- Bootable USB or iDRAC virtual media prepared
- SW01 Gi1/0/4 configured as a **trunk (native VLAN 999)** carrying tagged VLAN 10 for host mgmt + the VM VLANs (see `204-Proxmox-Networking.md` / `PVE01-Networking.md`)
- `10.10.0.10` confirmed unused
- Console access available

## Implementation

### 1. Install

1. Boot the server from the Proxmox installation media.
2. Select **Install Proxmox VE**.
3. Accept the license.
4. Select the RAID virtual disk.
5. Review storage options before accepting defaults.
6. Set Country: United States, Time zone: America/Chicago, Keyboard: appropriate local layout.
7. Set a strong temporary root password.
8. Enter an administrative email address.
9. Select the NIC that will become `eno1`.
10. Configure Hostname `pve01.lab`, IP `10.10.0.10/27`, Gateway `10.10.0.1`, DNS: reachable resolver. *(The installer puts this on the bare `vmbr0`; `204` migrates management to the tagged `vmbr0.10` sub-interface.)*
11. Review the summary.
12. Install.
13. Remove installation media.
14. Reboot.

### 2. First Login

```text
https://10.10.0.10:8006
Realm: Linux PAM
User: root
```

A browser certificate warning is expected until certificates are replaced or trusted.

### 3. First-Shell Verification

```bash
hostname
hostname -f
pveversion -v
cat /etc/os-release
ip -br address
ip route
```

Expected identity: `pve01` / `pve01.lab`. Expected routing at install time (bare `vmbr0`, before the `204` migration): `default via 10.10.0.1 dev vmbr0`, `10.10.0.0/27 dev vmbr0`. *(After `204`, management L3 is on `vmbr0.10` and bare `vmbr0` holds no L3 — see `PVE01-Networking.md`.)*

### 4. Verify `/etc/hosts`

Target:

```text
127.0.0.1 localhost.localdomain localhost
10.10.0.10 pve01.lab pve01
```

```bash
cat /etc/hosts
getent hosts pve01
getent hosts pve01.lab
```

## Validation

- Web interface reachable
- SSH or local shell reachable
- Hostname and FQDN correct
- Management IP and gateway correct
- Proxmox services active
- No storage or hardware errors

## Common Mistakes

- Skipping the RAID virtual disk review and accepting installer defaults blind — confirm the target disk matches the array actually built in the prep guide.

## Rollback

For a failed new installation:

1. Preserve installation logs or screenshots.
2. Verify BIOS, RAID, media, and network settings.
3. Reinstall cleanly rather than layering unverified fixes on a partial installation.

## Completion Checklist

- [x] Web interface reachable at `https://10.10.0.10:8006`
- [x] Hostname/FQDN correct
- [x] Management IP and gateway correct
- [x] No storage or hardware errors

## Change Log

| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit — networking reconcile (`ADR-0034`/`POL-0008`).** Corrected the stale pre-07-24 networking to the current device-verified design: management IP `/24`→**`/27`**, "VLAN 10 untagged on the host"→**tagged `vmbr0.10`**, "SW01 `Gi1/0/4` native VLAN 10"→**trunk native 999**; added the authoritative-networking pointer to `PVE01-Networking.md` + `204`, and clarified that the installer sets an initial address on bare `vmbr0` which `204` migrates to the tagged sub-interface. Version pin → PVE 8.4.19 / Debian 12. No procedure steps otherwise changed. |
| 1.0 | Initial install guide (R410 → Proxmox VE 8.x), carried the pre-07-24 `/24`-untagged-native-10 networking. |

## Next Guide

Proxmox Post-Installation Configuration.
