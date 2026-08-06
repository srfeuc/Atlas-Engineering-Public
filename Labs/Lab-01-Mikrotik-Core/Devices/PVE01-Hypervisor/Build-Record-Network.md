---
Title: PVE01 Network Build Record
Path: Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor
---

# PVE01 Network Build Record

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PVE01 - Role: Hypervisor

> 🔴 **NOT the authoritative owner (`ADR-0034`).** Live PVE01 networking is owned by `Labs/Lab-02-Cisco-Core/Virtualization/Build-Records/PVE01-Networking.md`. **This frozen record describes the pre-2026-07-24 design** (`vmbr0` `10.10.0.10/24`, untagged native VLAN 10) and is retained as a historical snapshot only — the current device-verified design is **tagged `vmbr0.10` `/27`, native 999, `bridge-vids 10–90,999`**. Do not build from this page. *(Navigation banner only — no design/config change; `ADR-0034` bounded freeze-exception.)*

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — reconciled to live 2026-07-16 (`060`). D12 done (nproc 16, 62 GiB, VT-x active) with the VT-x-command caveat below. 🔴 **CMOS durability RE-TEST FAILED** — see Known Issues + `CM-0012` |
| Version | **2.2** |
| Applies To | Atlas 2.0 |
| Last Live Verification | 2026-07-09 |
| Last Reconciled | 2026-07-14 |

## Platform

| Item | Value |
|---|---|
| Hardware | Dell PowerEdge R410 |
| CPU | 2x Intel Xeon E5620 @ 2.40GHz — **16 logical CPUs** (4c/8t each) |
| RAM | **64 GB physical / 62 GiB usable** |
| Proxmox VE | 8.4.19 |
| Kernel | 6.8.12-32-pve |
| Hostname | pve01 |
| FQDN | pve01.lab |
| Repository | pve-no-subscription |

> 🔴 **Corrected 2026-07-14 (reconciliation batch, 051 Tier 3 / B9).** This record previously asserted **32 vCPUs / 32 GB RAM** under `Status: Verified`. That was false. The live host is **16 logical CPUs / 62 GiB usable / 64 GB physical**, per four device-read sources — `VM-and-Services-Inventory.md` (confirmed live 2026-07-11), `Atlas-Service-Architecture.md`, `036-PVE01-Troubleshooting-Guide.md` ("16 on this host"), and `ADR-0017`. `Atlas-Workflow.md` uses this record's old numbers as its worked example of a false `Verified`. **`ADR-0017`'s CMOS close-test — *`egrep -c` returns the CPU count* — must be checked against 16, not 32.** Operator: re-confirm on the device (DEVICE CHECK D12: `nproc` · `free -h` · `egrep -c '(vmx|svm)' /proc/cpuinfo`) to re-earn a same-day `Verified`.

## Network Interfaces

| Interface | MAC | State | Role |
|---|---|---|---|
| eno1 | 00:00:5e:3f:f6:a2 | UP — master of vmbr0 | Primary NIC, connected to SW01 Gi1/0/4 |
| eno2 | 00:00:5e:3f:f6:a3 | DOWN | Not configured — `iface eno2 inet manual`, no `auto` stanza, so it is not brought up at boot (`010` confirms it is not in `auto`). Deliberately unconfigured, not merely "available". |
| vmbr0 | 00:00:5e:3f:f6:a2 | UP | Management bridge |
| **iDRAC** | 00:00:5e:3f:f6:**a4** | UP | 🔴 **SHARED LOM — rides `eno1`'s cable on Gi1/0/4. NOT a separate port. NOT out-of-band.** |

## /etc/network/interfaces (verified)

```text
auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
        address 10.10.0.10/24
        gateway 10.10.0.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes

iface eno2 inet manual

source /etc/network/interfaces.d/*
```

## IP Addressing

| Interface | IP | VLAN | Method |
|---|---|---|---|
| vmbr0 | 10.10.0.10/24 | 10 (native on SW01 Gi1/0/4) | Static |
| iDRAC | 10.10.0.100/24 | 10 — **via the same Gi1/0/4, shared LOM** | Static |

## Virtualization

| Item | Value |
|---|---|
| VT-x status | **Enabled** — `kvm_intel` + `kvm` modules loaded (device-verified 2026-07-16). 🔴 **`egrep -c '(vmx|svm)' /proc/cpuinfo` is NOT a valid CPU/VT-x count on this kernel:** 6.8 prints a second `vmx flags:` line per CPU, so it returns **32** (2 × 16) — not 16, and not "32 CPUs". Use `grep -c '^flags.*vmx' /proc/cpuinfo` (= 16) or the loaded `kvm_intel` module as the real check. |
| KVM | Active — `kvm_intel` loaded |

## Storage

| Name | Type | Total | Used | Available |
|---|---|---|---|---|
| local | Directory | 94 GB | 14 GB | 76 GB |
| local-lvm | LVM Thin | 831 GB (**= 793 GiB**) | 79 GB | 753 GB |

> 🟢 **Storage "discrepancy" resolved 2026-07-16 (units, not a difference).** `pvesm status` reports `local-lvm` total `831840256` KiB = **793 GiB = 831.8 GB** — the same pool the Inventory recorded as "~793 GiB". GB vs GiB, not two different sizes. The 024 v2.2 flag is closed.

## SW01 Connection

| SW01 Port | Mode | Native VLAN | Purpose |
|---|---|---|---|
| Gi1/0/4 | Trunk | 10 | PVE01 eno1 — host management untagged, VM traffic tagged |

## /etc/hosts (verified)

```text
127.0.0.1 localhost.localdomain localhost
10.10.0.10 pve01.lab pve01
```

## VM VLAN Assignment

VMs are placed on VLANs by setting a VLAN tag on the virtual NIC in the Proxmox GUI. No host-level configuration changes are required for existing VLANs. The bridge (`vmbr0`) carries both untagged host management traffic and tagged VM traffic on the same physical uplink.

## Access Methods

| Method | Address | Notes |
|---|---|---|
| Web GUI | https://10.10.0.10:8006 | No-subscription patch applied — certificate warning expected |
| SSH | ssh root@10.10.0.10 | Port 22 |
| 🔴 **iDRAC** | https://10.10.0.100 | 🔴 **Only while SW01 and Gi1/0/4 are up. NOT a teardown bootstrap path.** |
| **Physical console** | Keyboard + monitor | ✅ **The actual bootstrap path.** |
| GUI Shell | Node → Shell | Currently broken — VNC connection to localhost:5900 refused |

## Known Issues and Deviations

| Item | Target | Current | Action |
|---|---|---|---|
| GUI shell | Functional | VNC connection refused (exit code 1) | SSH is working substitute — under investigation |
| 🔴 **iDRAC on shared LOM** | True out-of-band on the dedicated port | **Shares `eno1`'s NIC, cable and switch port** | **Open** — the R410 has an **unused dedicated iDRAC port.** See `CM-0011`. |
| 🔴 **iDRAC credentials** | Hardened, vaulted, named | **Admin password CHANGED at the console 2026-07-16** — no longer factory-default, but **not remote-verifiable** (IPMI-over-LAN off, web UI down). Store in Vaultwarden as `PVE01 - iDRAC - BMC Admin` (≤20 char) if not already. | Full onboarding (Lab CA cert, deliberate path, dedicated-NIC move) is **blocked on `CM-0012`** → `050`. 🔴 **Do not treat `CM-0011` as a work order** — closed as substantially false (`016` lesson 5). |
| 🔴 **CMOS battery / RTC** | Holds RTC + BIOS across power loss | 🔴 **New CR2032 installed 2026-07-16 — durability RE-TEST FAILED.** The RTC still resets `2026`→`2018-05-30` across a power cycle (twice, including after a holder-clip reseat); a written `hwclock --systohc` value does not survive. Battery-vs-board **unresolved** (bare/seated voltage check pending). | `CM-0012` (**Open**). Keep on continuous power / UPS (`ADR-0017`); NTP holds the OS clock while running |
| Link speed Gi1/0/4 | 1 Gbps | ✅ **Re-confirmed 1 Gbps / full duplex 2026-07-16** (`ethtool eno1`); link up, gateway + internet reachable. *(SW01 saw Gi1/0/4 "down" earlier only because PVE01 was powered off at the time.)* | Closed — monitor only if 100 Mbps recurs |
| No-subscription patch | Persistent | Overwritten by package updates | Re-apply after proxmox-widget-toolkit updates |
| VMs | All planned VMs running | 🔴 **3 defined, all stopped** (device-verified 2026-07-16, `qm list`): `DC01` (VMID 101), `WIN2025-BUILD-ARCHIVE` (100), template `TPL-WIN2025` (9000). *"None deployed" was stale.* `DC01` present-but-stopped matches `ADR-0004`. No containers (`pct list` empty). | Track VM inventory; `DC01` promotion is Book 3 |

## 🔴 Correction — 2026-07-13

**This record previously described the iDRAC as being on a "separate physical port," with the note *"works regardless of Proxmox OS state."* Both statements were false.**

`003-Physical-Topology.md` v2.0 established the truth on 2026-07-13, verified with `ipmitool lan print 1` and `ip a`:

> The R410's three NIC MACs are **sequential** — `eno1 …a2`, `eno2 …a3`, `iDRAC …a4`. **One card, iDRAC in shared/LOM mode.** It rides `eno1`'s cable on `Gi1/0/4`. **There was no missing cable.** A three-session hunt was searching for a port that does not exist.

**This page was never updated to match.** For a day, the Build Record — the document whose only job is to record verified reality — claimed PVE01 had independent out-of-band management that it does not have.

🔴 **The consequence is not cosmetic.** iDRAC dies when `eno1` fails, when `Gi1/0/4` is misconfigured, or when **SW01 is wiped — which is step one of any teardown.** A rebuilder trusting this page would plan a recovery around a management interface that is guaranteed to be down at the exact moment they need it.

**Out-of-band management that depends on the in-band network is not out-of-band.**

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Initial verified record, 2026-07-09. |
| **2.1** | 🔴 **iDRAC corrected: shared LOM, not a separate port; NOT out-of-band.** Reconciled against `003-Physical-Topology.md` v2.0, which had the verified facts a full day earlier. Added the CMOS battery (`CM-0012`) and the shared-LOM deviation (`CM-0011`) to Known Issues. Added the physical console as the real bootstrap path. |
| **2.2** | 2026-07-14 reconciliation batch (051 Tier 3, B9–B11). Corrected CPU/RAM/VT-x to the device-read 16 / 62 GiB / 16 (from five sources; the 32/32 figures were false). Removed the dangerous "`CM-0011` (Draft, not executed)" framing from the iDRAC row (`CM-0011` is Closed — substantially FALSE). Replaced eno2 "available" with its actual administrative state. Storage discrepancy (`local-lvm` 831 GB vs Inventory ~793 GB) flagged for device re-check, not changed. |
| **2.3** | 🟢 **2026-07-16 — full reconcile against the live `060` run.** Corrected: **VMs** ("None deployed" → 3 defined-but-stopped incl. `DC01`, matching `ADR-0004`); **VT-x check** (`egrep -c '(vmx|svm)'` returns **32** on kernel 6.8 due to the added `vmx flags:` line — not 16, not 32 CPUs; use `kvm_intel` loaded / `grep -c '^flags.*vmx'`); **storage flag closed** (831 GB = 793 GiB, units); **Gi1/0/4 re-confirmed 1 Gbps up**. Recorded the **iDRAC password change** (console, 2026-07-16). 🔴 **CMOS/RTC row updated to the failed durability re-test** — new CR2032 in, RTC still resets `2026`→`2018` across a power cycle; `CM-0012` stays Open and `050` stays blocked. |
