---
Title: Clone the Windows Server 2025 Template
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Clone the Windows Server 2025 Template

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified target state; DC01 VLAN placement flagged as unresolved — see below |
| Version | 1.1 |
| Applies To | PVE01 |

## Purpose

Create a new Windows Server VM from `TPL-WIN2025`.

## Prerequisites

- Template converted (`212-Convert-Golden-Image-to-Template.md`)

## Clone Type

**Full clone** — use for independent production or long-lived infrastructure VMs. Independent storage, source-template changes don't affect the clone, easier movement and recovery.

**Linked clone** — use only for short-lived labs when the storage and lifecycle implications are understood.

## Implementation

### 1. Clone (GUI)

1. Select `TPL-WIN2025` (VMID 9000).
2. Select **Clone**.
3. Enter: New VMID, Name, Target node `pve01`, Target storage `local-lvm`, Mode: Full Clone.
4. Start cloning.
5. Wait for completion.

### 2. Example — DC01

| Setting | Value |
|---|---|
| VMID | 101 |
| Name | `DC01` |
| Clone mode | Full |
| Bridge | `vmbr0` |
| VLAN | See note below — **currently untagged (VLAN 10), not VLAN 20** |
| Storage | `local-lvm` |

> **Open item, not yet resolved as of this document's last update:** the Atlas VLAN Standards target design places domain controllers on VLAN 20 (Servers). DC01's live configuration currently has **no VLAN tag set** on `net0`, which places it on VLAN 10 (Management) by default — the same VLAN as PVE01 itself, SW01, and FGT01/MKT01 management interfaces. This was reportedly because an earlier attempt at VLAN 20 "didn't work" — but the network path for VLAN 20 (SW01 trunk, MKT01 routed interface) has since been independently validated as functional, and the more likely original cause is that VLAN 20 has no DHCP service yet, which would make any DHCP-configured VM on that VLAN appear non-functional regardless of the network path. This should be retested with a static IP before treating VLAN 10 as the permanent design for DC01, the way it correctly is for the PVE01 host itself.

### 3. Customize Hardware Before First Boot

Review: CPU, memory, VLAN tag, start-at-boot, startup order, backup policy, disk size.

### 4. First Boot

Windows completes specialization and presents OOBE or initial configuration.

1. Set local Administrator password if prompted.
2. Set final computer name.
3. Reboot.
4. Configure the production VLAN and static IP.
5. Verify QEMU Guest Agent.
6. Install final updates.
7. Join the domain only after DNS is correct.

## Validation

```powershell
hostname
whoami
Get-ComputerInfo | Select-Object CsName,CsDomain
Get-NetIPConfiguration
```

```bash
qm config <NEW-VMID>
qm status <NEW-VMID>
qm agent <NEW-VMID> ping
```

- Clone boots
- Unique name
- Unique network identity
- Correct VLAN — **pending the VLAN 10 vs. 20 resolution above**
- QEMU Agent responds
- No template-specific temporary name or address remains

## Common Mistakes

- Assuming a clone's failure to get an IP on a new VLAN means the network path is broken — check for a missing DHCP scope first, especially on VLANs that don't have a DHCP server deployed yet.
- Forgetting to change the computer name before joining anything — every clone starts with the same specialized name pattern until renamed.

## Rollback

Delete the clone; the template itself is untouched by cloning operations, so re-cloning is always available as a clean restart.

## Completion Checklist

- [x] Clone boots with unique identity
- [x] QEMU Agent responds
- [ ] Correct VLAN — **open, see note above**
- [ ] Static IP tested on target VLAN before relying on it

## Next Guide

Deploy DC01 from the Template.
