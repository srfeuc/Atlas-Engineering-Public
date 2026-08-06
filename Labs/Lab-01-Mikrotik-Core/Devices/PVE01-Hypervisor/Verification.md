---
Title: PVE01 Verification Procedure
Path: Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor
---

# PVE01 Verification Procedure

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PVE01 - Role: Hypervisor

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | 1.0 |
| Applies To | PVE01 (10.10.0.10 — Dell PowerEdge R410, Proxmox VE 8.4.19 host) |
| Evidence Status | **Verified** — full read-only battery run against the live host 2026-07-16 |
| Last Run | 2026-07-16 |

## Purpose

The **reconcile-to-live** procedure for PVE01: prove the running host matches `024` (Network Build Record) and `028` (Network Build Guide), 🟡 → 🟢. Run before a Game Day (`ADR-0011`), after any change, or when a doc is in doubt.

**Read-only checks only.** Risks and open items live in `061-PVE01-Considerations-and-Risks.md`.

## How to run

PVE01 is Proxmox (Debian). **Run as `root` — `sudo` is not installed on this host** (`036`), so no `sudo` in front. Get `Tools/scripts/pve01-recon.sh` onto the host and:

```bash
bash Tools/scripts/pve01-recon.sh 2>&1 | tee ~/pve01-recon-$(date +%F).txt
```

`tee` keeps a copy; the run ends with a `PVE01 RECON END` marker — if you don't see it, the paste is incomplete.

> 🔴 **Empty output is not a pass** (Rule 13; `016`). Re-run until you see real content.
> 🔴 **No secrets.** The iDRAC section is local KCS and prints names/privileges only — never a password. The changed BMC password is never echoed.
> 🔴 **CMOS durability is a two-part test, not a single read.** Section B reads current state; proving the board *holds* config needs a **full power-pull** between a written RTC and the next boot — see `CM-0012` Step 2 and `061` row 1.

## Verification battery

### Batch A — Platform + VT-x (`024`, `028`; DEVICE CHECK D12)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| Proxmox / kernel | `pveversion` | `pve-manager/8.4.19`, kernel `6.8.12-32-pve` |
| Hostname | `hostname -f` | `pve01.lab` |
| CPU count | `nproc` | **16** (2× Xeon E5620, 4c/8t each) |
| RAM | `free -h` | **62 Gi** total (64 GB physical / 62 GiB usable) |
| VT-x | `lsmod \| grep kvm` ; `grep -c '^flags.*vmx' /proc/cpuinfo` | `kvm_intel` + `kvm` loaded = VT-x **on**; `grep` = **16**. 🔴 **Do NOT use `egrep -c '(vmx\|svm)'`** — kernel 6.8 adds a `vmx flags:` line per CPU, so it returns **32** (2×16), not 16 (`024`) |
| CPU model | `lscpu \| grep -E 'Model name\|Socket\|Core\|Thread'` | E5620 @ 2.40GHz, 2 sockets, 4 cores/socket, 2 threads/core |
| Hosts file | `cat /etc/hosts` | `10.10.0.10 pve01.lab pve01` present |

### Batch B — CMOS / RTC durability (`CM-0012` Step 2 / `036`) — the experiment

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| OS clock | `date` ; `timedatectl` | current, `System clock synchronized: yes`, NTP active — *the OS clock is fine while powered* |
| **RTC at boot** | `dmesg \| grep -i 'RTC time'` | 🔴 **FAILING 2026-07-16: `date: 2018-05-30`** — the RTC resets on every power cycle even with the new battery (`CM-0012`). 🟢 only when this reads the current year |
| RTC now | `hwclock --show` | current *(because `hwclock --systohc` / NTP wrote it after boot — this does not prove durability)* |
| KVM modules | `lsmod \| grep kvm` | `kvm_intel`, `kvm` loaded |

> 🔴 **The durability verdict is not in this battery — it's in the power-pull.** Write the RTC (`hwclock --systohc`), **fully unplug**, boot, and read `dmesg` RTC. `2026` = holds; `2018` = does not (`CM-0012`, `061` row 1).

### Batch C — Network (`024`, `028`)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| Interfaces | `ip -br link` | `eno1` up `…a2`, `eno2` **down** `…a3`, `vmbr0` up `…a2` |
| Addressing | `ip -br -4 a` ; `ip a show vmbr0` | `vmbr0` `10.10.0.10/24` up |
| Config file | `cat /etc/network/interfaces` | matches `024`: `vmbr0` static, `bridge-ports eno1`, `bridge-vlan-aware yes`, `eno1`/`eno2` `manual` |
| Route | `ip route` | default via `10.10.0.1` on `vmbr0` |
| Bridge VLANs | `bridge vlan show` | vlan-filtering on; `eno1`/`vmbr0` carry **VLAN 1 PVID untagged** only (no tagged VMs running — see `061` row 9) |
| Link speed | `ethtool eno1 \| grep -E 'Speed\|Duplex\|Link'` | **1000 Mb/s, Full, Link detected: yes** (resolves the Gi1/0/4 link-speed deviation) |
| Reachability | `ping -c2 10.10.0.1` ; `ping -c2 1.1.1.1` | both succeed (gateway + internet via FGT01 NAT) |

### Batch D — Storage / repo / guests (`024`, `028`)

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| Storage | `pvesm status` | `local` (dir) active ~94 GB; `local-lvm` (lvmthin) active **831 GB = 793 GiB** (units — `024` flag closed) |
| Root FS | `df -h /` | `/dev/mapper/pve-root` 94 G, ~15% used |
| VMs | `qm list` | 🔴 **3 defined, all stopped:** `DC01` (101), `WIN2025-BUILD-ARCHIVE` (100), template `TPL-WIN2025` (9000). *("None deployed" in the old `024` was stale.)* |
| Containers | `pct list` | none |
| Repo | `cat …/pve-no-subscription.list` ; `ls …/sources.list.d/` | `pve bookworm pve-no-subscription`; enterprise repo `.bak` (disabled), `ceph.list.disabled` |

### Batch E — iDRAC / BMC (`CM-0012`, `050`) — local KCS, read-only, no secrets

| Check | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| BMC | `ipmitool mc info` | Dell, Firmware **1.70**, IPMI **2.0** |
| LAN | `ipmitool lan print 1` | IP `10.10.0.100`, MAC `…a4` (shared LOM), cipher **`XXXa`**, `802.1q VLAN: Disabled` (greyed — shared LOM), 🔴 SNMP community **`public`** (factory — disable per `050` §5) |
| Channel | `ipmitool channel info 1` | **`Access Mode: disabled`** — IPMI-over-LAN off |
| Users | `ipmitool user list 1` | `root` (ID 2) ADMINISTRATOR; password **changed at the console 2026-07-16** (not remote-verifiable — no path) |
| Power | `ipmitool chassis status` | `System Power: on`, `Main Power Fault: false` |

## Interpreting results

- **Device wins** (Rule 13). A mismatch is a finding for `061`.
- **A clean read is not durability.** The clock section is the trap: `timedatectl`/`hwclock` read correct *while powered* (NTP), but the RTC still fails across a power loss. Prove durability with the power-pull, not the live read (`CM-0012`).
- **iDRAC config ≠ CMOS durability.** The iDRAC holds its settings in its own NVRAM; it surviving a power cycle says nothing about the RTC/board either way.

## Last-run record

| Date | Run by | Result | Output |
|---|---|---|---|
| 2026-07-16 | Seth | 🟢 Platform / network / storage / repo all match `024`/`028` (with the corrections folded in: VMs present, VT-x count is 32 on 6.8, storage-units, link 1 Gbps). 🔴 **CMOS/RTC durability FAILED** (`CM-0012`); iDRAC held, password changed. | `~/pve01-recon-2026-07-16.txt` |

## Related pages

- Build Record: `024` · Build Guide: `028` (network; full R410/Proxmox build is Book 2)
- **Considerations & Risks: `061-PVE01-Considerations-and-Risks.md`**
- Troubleshooting: `036` · iDRAC onboarding: `050` (blocked on `CM-0012`)
- Change records / decisions: `CM-0012` (CMOS/RTC — Open), `ADR-0017` (defer/freeze), `ADR-0004` (`DC01`/RADIUS)
- Script: `Tools/scripts/pve01-recon.sh`
