---
Title: Proxmox Post-Installation Configuration
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Proxmox Post-Installation Configuration

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified target state |
| Version | 1.0 |
| Applies To | PVE01 |

## Purpose

Bring a new Proxmox installation to the Atlas operational baseline.

## Prerequisites

- Proxmox VE installed (`202-Install-Proxmox-VE.md`)

## Implementation

### 1. Record the Baseline

```bash
hostname
hostname -f
pveversion -v
uname -a
ip -br address
ip route
lsblk
pvesm status
```

Save the output in the PVE01 Build-Records — `../Build-Records/215-PVE01-Current-State.md` for the snapshot, and the topic records `PVE01-Networking` / `PVE01-Storage` / `PVE01-Authentication` for the authoritative per-area state (`POL-0008`).

### 2. Repository Configuration

The verified environment uses the no-subscription repository appropriate to Proxmox VE 8 / Debian 12.

```bash
grep -R --line-number --no-messages . \
  /etc/apt/sources.list \
  /etc/apt/sources.list.d/
```

Disable an enterprise repository only when there is no active subscription. For Proxmox VE 8 / Debian 12, the repository is expected to reference:

```text
download.proxmox.com/debian/pve
bookworm
pve-no-subscription
```

Do not blindly copy repository lines from a different Proxmox or Debian release.

### 3. Update the Host

```bash
apt update
apt full-upgrade
```

Review removals before approving them. Reboot when the kernel or critical platform components are updated:

```bash
reboot
```

After reboot:

```bash
pveversion -v
uname -r
systemctl --failed
```

### 4. Time Configuration

```bash
timedatectl
timedatectl set-timezone America/Chicago
timedatectl status
```

The long-term target is the enterprise time hierarchy after Active Directory is operational.

### 5. DNS Configuration

```bash
cat /etc/resolv.conf
```

During initial build, use a working resolver. After Windows DNS exists, update PVE01 to the approved internal resolvers through the Proxmox UI or host configuration. Do not make the hypervisor dependent on a DNS service that has not yet been built.

### 6. Service Validation

```bash
systemctl status pveproxy
systemctl status pvedaemon
systemctl status pvestatd
systemctl status pve-cluster
```

### 7. SSH Validation

```bash
ss -lntp | grep ':22'
```

Test from an approved management workstation. Root SSH policy should be reviewed during hardening. A named Proxmox administrative account does not automatically become a Linux shell account.

### 8. Subscription Message

The no-subscription warning in the GUI is informational. Do not modify product JavaScript or package files merely to hide the message unless Atlas formally adopts and tests that customization.

### 9. Configuration Backup

```bash
tar -czf /root/pve01-config-baseline.tar.gz \
  /etc/network/interfaces \
  /etc/hosts \
  /etc/apt/sources.list \
  /etc/apt/sources.list.d \
  /etc/pve
```

Because `/etc/pve` is a live cluster filesystem, this archive is a supplemental configuration capture, not a substitute for VM backups or a documented restore procedure.

## Validation

- Package metadata updates without repository errors
- Host fully patched
- Correct kernel active
- No failed Proxmox services (`systemctl --failed` empty)
- Time correct
- DNS resolution works
- Baseline configuration archive created

## Common Mistakes

- Copying repository configuration lines from a different Proxmox/Debian release without checking the codename match.
- Hiding the subscription nag through unofficial patches instead of leaving it as an informational message.

## Rollback

Restore from the configuration baseline archive (`pve01-config-baseline.tar.gz`) for the files it covers. A full host reinstall is the fallback for anything the archive doesn't cover, since Proxmox has no built-in "undo update" mechanism.

## Completion Checklist

- [x] Baseline recorded
- [x] `pve-no-subscription` repo confirmed, no enterprise repo errors
- [ ] Host fully patched — re-check `apt list --upgradable` periodically, not a one-time task
- [x] No failed services
- [x] Configuration baseline archived

## Next Guide

Proxmox Networking.
