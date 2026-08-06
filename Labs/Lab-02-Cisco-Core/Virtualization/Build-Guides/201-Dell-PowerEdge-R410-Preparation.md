---
Title: Dell PowerEdge R410 Preparation
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Dell PowerEdge R410 Preparation

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 Verified — live hardware facts confirmed 2026-07-11. **#22 audit (2026-07-30): the network-cabling note reconciled to the current tagged design (native 999 / tagged VLAN 10) + iDRAC shared-LOM correction — see Change Log.** |
| Version | 1.1 |
| Applies To | PVE01 |

## Purpose

Prepare the Dell PowerEdge R410 for a reliable Proxmox VE installation.

## Known Hardware

| Component | Verified value |
|---|---|
| Server | Dell PowerEdge R410 |
| CPU | 2 × Intel Xeon E5620 at 2.40 GHz |
| Cores | 4 per socket |
| Threads | 2 per core |
| Logical CPUs | 16 total |
| Memory | 62 GiB usable (64 GB physical) — upgraded 2026-07-11, see Known Issue below |
| Management | iDRAC at `10.10.0.100` |
| Production NIC | `eno1` after Linux installation |
| Secondary NIC | `eno2`, currently unused |

## Prerequisites

- Reliable power — ideally a UPS, see Known Issue below for why this matters more than usual on this host.
- iDRAC connected to the management network.
- Production NIC connected to SW01 Gi1/0/4.
- Local console or iDRAC virtual console access.
- Service tag, firmware versions, disk inventory, and RAID controller model recorded before starting.
- Existing data backed up before any RAID change.

## Implementation

### 1. Firmware and Hardware Inventory

Record:

```text
BIOS version:
iDRAC version:
Lifecycle Controller version:
RAID controller:
Physical disks:
NIC firmware:
Power-supply state:
Fan and temperature state:
```

Use iDRAC and the Lifecycle Controller where available.

### 2. BIOS Settings

Enter System Setup during POST and verify:

- Intel Virtualization Technology: **Enabled**
- VT-d / I/O virtualization: **Enabled**, when available
- Hyper-Threading: **Enabled**
- Execute Disable: **Enabled**
- Logical Processor: **Enabled**
- Boot mode: use the mode supported by the selected Proxmox installation; keep it consistent
- System profile: Performance or Performance-per-Watt, based on heat and power goals
- Integrated NICs: Enabled
- Correct date and time

### 3. Storage Preparation

1. Open the RAID controller utility.
2. Confirm every physical disk is healthy.
3. Create the intended virtual disk.
4. Record RAID level, stripe size, cache policy, and usable capacity.
5. Wait for initialization if required.
6. Confirm the virtual disk appears as one installation target.

The currently verified Proxmox layout provides approximately:

- 94 GB for the root filesystem and `local`
- 793 GB for `local-lvm`

Do not destroy or recreate the production array without a tested backup and a separate change record.

### 4. Network Cabling

| Connection | Destination |
|---|---|
| Production NIC | SW01 Gi1/0/4 (trunk) |
| iDRAC | 🔴 **shared-LOM — rides `eno1`'s cable on `Gi1/0/4`, not a separate out-of-band port** (`CM-0011`) |
| Console | Local or iDRAC virtual console |

**SW01 `Gi1/0/4` is a trunk with native VLAN 999 (parking, carries nothing untagged); host management is TAGGED VLAN 10 on the `vmbr0.10` sub-interface, and VM VLANs are tagged.** *(This supersedes the earlier untagged-native-10 design — see `../Build-Records/PVE01-Networking.md` (authoritative, `ADR-0034`) + `204-Proxmox-Networking.md`.)*

## Validation

```bash
lscpu | grep -i virtualization
grep -c vmx /proc/cpuinfo
ethtool eno1
```

Expected:

```text
Virtualization: VT-x
```

The VMX count should correspond to the number of logical processors. Expected link state:

```text
Speed: 1000Mb/s
Duplex: Full
Link detected: yes
```

## Common Mistakes

- Assuming VT-x is enabled because it was enabled last time — see Known Issue below; it does not reliably stay enabled on this specific host.
- Relying on the link speed shown once and not re-checking — this host was observed at 100 Mbps during earlier troubleshooting; always confirm 1000Mb/s before treating it as production-ready.

## Lessons Learned from Actual Deployment — CMOS Battery, VT-x, and DIMM Slot B1 (2026-07-11)

This server's CMOS battery is confirmed dead. This is not hypothetical — it happened on this exact host, and produced three symptoms that looked unrelated at first but traced back to the same root cause:

1. **VT-x was found disabled in BIOS** (`dmesg` reported `x86/cpu: VMX (outside TXT) disabled by BIOS`), despite this exact checklist calling for it Enabled. A dead CMOS battery resets BIOS settings to factory defaults on any full power loss — that's the actual mechanism, not a one-off misconfiguration.
2. **DIMM slot B1 was found physically faulty** during a RAM upgrade — the retention clip would not latch. RAM relocated to slot B3 works correctly and has since remained stable through the BIOS/CMOS fix. Check population order against Dell's documented supported configuration for this platform to confirm triple-channel interleaving is still achieved.
3. **The system clock (RTC) was found reset to 2018.** `chronyd` corrects this automatically once the OS is up and has network access, but the RTC itself reverts on every full power cycle until the battery is physically replaced.

**Practical implication:** as long as this host stays on continuous power, these symptoms mostly don't resurface. Any full power loss — outage, moved hardware, PSU swap — will likely reproduce all three symptoms again until the CR2032 battery is physically replaced (still outstanding). Re-check VT-x specifically after any such event, before assuming the host is ready for VM workloads:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
lsmod | grep kvm
```

## Rollback

Not applicable — this is a preparation guide, not a reversible change.

## Completion Checklist

- [x] No hardware alerts
- [x] RAID virtual disk healthy
- [x] VT-x enabled — confirmed after BIOS/CMOS remediation
- [x] Memory detected — 64 GB physical, 62 GiB usable
- [x] Production NIC links at 1 Gbps full duplex
- [ ] iDRAC reachable — not re-verified this session
- [ ] CMOS battery physically replaced — still outstanding
- [x] Proxmox installer can see the target disk and NIC

## Change Log

| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit — networking-cabling reconcile.** Corrected the §4 note from "native VLAN 10 for untagged host management" to the current device-verified design (SW01 `Gi1/0/4` trunk **native 999**; host mgmt **tagged VLAN 10** on `vmbr0.10`), and fixed the iDRAC line to reflect it is **shared-LOM** on `eno1`/`Gi1/0/4` (not a separate OOB port, `CM-0011`). Pointed to `PVE01-Networking.md` (authoritative). Hardware facts (RAM 62 GiB/64 GB, 16 logical CPUs, CMOS/VT-x/DIMM-B1 lessons) were already correct and unchanged. |
| 1.0 | Initial R410 preparation guide (device-verified hardware facts 2026-07-11). |

## Next Guide

Install Proxmox VE on PVE01.
