---
Title: Verified Facts and Reconciliation Notes
Document Type: Reference
Status: Active
Version: 0.1
---

# Verified Facts and Reconciliation Notes

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Corrections applied

### Proxmox address

Correct:

```text
10.10.0.10/24
```

Incorrect older record:

```text
10.10.0.254/24
```

`10.10.0.254` belongs to FGT01 internal2.

### Logical CPU count

Correct topology:

```text
2 sockets × 4 cores × 2 threads = 16 logical CPUs
```

Older material incorrectly stated 32.

### Proxmox version

Live output reported:

```text
Proxmox VE 8.4.19
Debian 12
```

Older planned pages mentioning Proxmox 9 are target drafts, not the current record.

### Named account

Correct Proxmox account:

```text
seth-admin@pve
```

Do not replace it with `sethadmin` or assume it is a Linux user.

## Evidence still needed

- Windows edition and build for VM 100/101 — **RESOLVED**: Windows Server 2025 Standard, Evaluation license, build 26100 (see Golden Image Historical Record)
- QEMU Guest Agent state inside Windows — **RESOLVED**: confirmed Running during the build
- Dell RAID controller and virtual-disk details
- current BIOS/iDRAC firmware
- `qm config 100` — **RESOLVED**, collected during live session (2026-07-11)
- `qm config 101` — **RESOLVED**, collected during live session (2026-07-11)
- current `qm list` — **RESOLVED**, collected during live session (2026-07-11)
- DC01 IP, VLAN, role state, domain, and DNS — still open; DC01 is currently stopped and has not been promoted to a domain controller

## Live-session addendum (2026-07-11)

Additional facts confirmed via direct SSH session on PVE01, independent of this package and the recovered chat transcript:

- **RAM**: physical memory upgraded to 64 GB (4× 16GB, slots A1/A2/B1/B2). `free -h` shows 62 GiB usable. The `31 GiB usable` figure elsewhere in this package (README, `01 - PVE01 Current State.md`) is stale and predates this upgrade.
- **VT-x**: was found BIOS-disabled (`dmesg`: `x86/cpu: VMX (outside TXT) disabled by BIOS`), traced to a dead CMOS battery, and fixed via BIOS re-enable. Confirmed working post-fix: `egrep -c '(vmx|svm)' /proc/cpuinfo` = 32 (thread count × property, not vCPU count — logical CPU count is still 16), `kvm`/`kvm_intel` modules loaded.
- **CMOS battery**: confirmed dead — RTC was found reset to 2018, chrony re-syncs correctly on boot but this will not survive a genuine full power loss. Physical battery replacement still outstanding.
- **DIMM slot B1**: found physically faulty (socket won't latch). RAM relocated to B3 and works; population order should be checked against Dell's supported configuration for full triple-channel interleaving.
- **Golden image lineage (100 → 9000 → 101)**: definitively confirmed via the actual `qmclone` task log bodies (not just task labels, which are misleadingly named after the source VM) — resolves the "cloned or created" hedge in the Golden Image Historical Record.
- **Proxmox global firewall**: `pve-firewall status` returns `disabled/running`. The per-VM `firewall=1` flag present in VM configs (9000, 100, 101) is currently inert as a result — worth correcting anywhere this package describes the firewall as simply "Enabled."
- **CPU count**: 16 logical CPUs independently re-confirmed via `nproc`, `lscpu | grep '^CPU(s):'`, and `grep -c ^processor /proc/cpuinfo` — matches this package's own correction, no further action needed.
