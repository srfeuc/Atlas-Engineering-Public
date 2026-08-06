---
Title: PVE01 Network Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor
---

# PVE01 Network Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PVE01 - Role: Hypervisor

> 🔴 **NOT the authoritative owner (`ADR-0034`).** Live PVE01 networking is owned by `Labs/Lab-02-Cisco-Core/Virtualization/Build-Records/PVE01-Networking.md` (procedure: `…/Virtualization/Build-Guides/204-Proxmox-Networking.md`). **This frozen guide describes the pre-2026-07-24 design** (untagged native VLAN 10, `/24`) and is retained as a historical snapshot only — the current design is **tagged `vmbr0.10` `/27`, SW01 `Gi1/0/4` native 999**. Do not build from this page. *(Navigation banner only — no design change; `ADR-0034` bounded freeze-exception.)*

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | **2.1** |
| Applies To | Atlas 2.0 |
| Hardware | Dell PowerEdge R410 |
| Proxmox VE | 8.4.19 |
| Kernel | 6.8.12-32-pve |
| Last Reconciled | 2026-07 |

## Target

Configure PVE01 network so the hypervisor host is reachable on VLAN 10 (Management) at 10.10.0.10, and VM workloads can be placed on any production VLAN using per-VM VLAN tags on a single VLAN-aware bridge.

This guide covers network configuration only. Proxmox installation, storage, and VM lifecycle are covered in the Enterprise Virtualization pack.

## Before You Begin

| Item | Value |
|---|---|
| Hostname | pve01 |
| FQDN | pve01.lab |
| Management IP | 10.10.0.10/24 |
| Gateway | 10.10.0.1 (MKT01 vlan10-mgmt) |
| Primary NIC | eno1 — 00:00:5e:3f:f6:a2 |
| Secondary NIC | eno2 — 00:00:5e:3f:f6:a3 (unused) |
| 🔴 **iDRAC** | 00:00:5e:3f:f6:**a4** — **SHARED LOM. NOT a separate port.** Rides `eno1`'s cable on Gi1/0/4. |
| iDRAC IP | 10.10.0.100/24 |
| Switch port | SW01 Gi1/0/4 — trunk, native VLAN 10 |
| SW01 STATIC-HOSTS | **BOTH** `eno1` (`0000.5e00.5313`) **and iDRAC** (`0000.5e00.5314`) MACs required — they appear on the **same port** |
| GUI | https://10.10.0.10:8006 |
| SSH | ssh root@10.10.0.10 |

## Design

PVE01 host management uses a single VLAN-aware bridge (`vmbr0`) on `eno1`. The bridge has the management IP assigned directly — untagged. SW01 Gi1/0/4 has native VLAN 10, so untagged frames from PVE01 are classified into VLAN 10 automatically.

VM workloads are placed on other VLANs by setting a VLAN tag on the VM's virtual NIC in the Proxmox GUI. No additional host interfaces or sub-interfaces are needed. The same `vmbr0` carries tagged VM traffic to the switch, which forwards it to MKT01 for routing.

This is a standard enterprise hypervisor pattern: host management untagged on one VLAN, VM traffic tagged per-VM on the same physical uplink.

> **Why VLAN 10 and not VLAN 20 (Servers)?** The original design placed PVE01 on VLAN 20. During deployment, PVE01's `vmbr0` sends untagged frames — it does not tag its own traffic. With native VLAN 999 on Gi1/0/4, those untagged frames landed in the unused catch-all and PVE01 was unreachable. The resolution was to set native VLAN 10 on Gi1/0/4, which permanently places PVE01 host management on VLAN 10. VM workloads remain on their intended VLANs via tagged virtual NICs.

## 1. Verify Proxmox Version and VT-x

```bash
pveversion
egrep -c '(vmx|svm)' /proc/cpuinfo
```

`pveversion` must show 8.4.x. The second command must return a number greater than zero — this confirms hardware virtualization is active in the CPU. If it returns 0, VT-x is disabled in BIOS. Enable it before creating any VMs: reboot → F2 → Processor Settings → Virtualization Technology → Enabled.

> 🟡 **Note (kernel 6.8, device-verified 2026-07-16):** `egrep -c '(vmx|svm)'` returns **~2× the CPU count** (32 on this 16-CPU host) because 6.8 prints a second `vmx flags:` line per CPU. Read it only as *"> 0 = VT-x on"*, **never as a CPU count**. For the count use `grep -c '^flags.*vmx' /proc/cpuinfo` (= 16), or confirm `kvm_intel` is loaded (`lsmod | grep kvm`). Same fix applies to `ADR-0017`'s CMOS close-test and `024`.

## 2. Configure /etc/network/interfaces

Edit the network configuration file:

```bash
nano /etc/network/interfaces
```

The target configuration:

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

Apply without rebooting:

```bash
ifreload -a
```

Verify:

```bash
ip a show vmbr0
```

Expected: `inet 10.10.0.10/24 scope global vmbr0`, state UP.

> `bridge-vlan-aware yes` is required. Without it, per-VM VLAN tags set in the Proxmox GUI have no effect.

## 3. Verify Connectivity

```bash
ping -c 4 10.10.0.1
ping -c 4 1.1.1.1
```

Both must succeed before continuing. If the gateway ping fails, check SW01 Gi1/0/4 is up and configured with native VLAN 10. If internet fails, check MKT01 firewall rules allow vlan10-mgmt to ether1.

## 4. Update SW01 STATIC-HOSTS

PVE01 uses a static IP. SW01 ARP inspection blocks it until the MAC is in the access list. Confirm the MAC from PVE01:

```bash
ip a show eno1 | grep ether
```

Expected: `00:00:5e:3f:f6:a2`. Convert to IOS dot format and add on SW01 — **and add the iDRAC MAC too:**

```text
configure terminal
arp access-list STATIC-HOSTS
 permit ip host 10.10.0.10 mac host 0000.5e00.5313
 permit ip host 10.10.0.100 mac host 0000.5e00.5314
exit
exit
write memory
```

> 🔴 **The iDRAC MAC is on the SAME port.** It is a **shared LOM**, not a dedicated NIC. `DHCP Permits: 0` on SW01 — a host missing from this ACL is **silently dropped**, with no fallback.

If PVE01 was unreachable before this step, it should become reachable immediately after.

## 5. Configure /etc/hosts

```bash
nano /etc/hosts
```

Verify these entries are present:

```text
127.0.0.1 localhost.localdomain localhost
10.10.0.10 pve01.lab pve01
```

## 6. Configure Repository

The default Proxmox enterprise repository requires a subscription. Use the no-subscription repository:

```bash
cat /etc/apt/sources.list.d/pve-no-subscription.list
```

Expected: `deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription`

If missing or pointing at the enterprise repo:

```bash
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
```

Disable the enterprise repo if present:

```bash
cat /etc/apt/sources.list.d/pve-enterprise.list
```

Comment out or remove any `enterprise.proxmox.com` lines.

## 7. Apply Updates

```bash
apt update && apt full-upgrade -y
```

Reboot if a new kernel was installed:

```bash
reboot
```

After reboot, verify the management IP is still reachable and re-run:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

## 8. Apply No-Subscription GUI Patch

The no-subscription nag dialog can interfere with the GUI shell button. Apply the patch:

```bash
sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
systemctl restart pveproxy
```

Refresh the browser after `pveproxy` restarts.

> This patch is overwritten when the `proxmox-widget-toolkit` package updates. Re-apply after `apt upgrade` if the nag returns.

## How to Place a VM on a Specific VLAN

No host-level configuration changes are needed. In the Proxmox GUI:

1. Create or edit a VM
2. Go to **Hardware → Network Device**
3. Set **Bridge** to `vmbr0`
4. Set **VLAN Tag** to the target VLAN ID (e.g. 20 for Servers)
5. Start the VM

The tagged frame exits PVE01 on eno1, arrives at SW01 Gi1/0/4 tagged, and is forwarded to MKT01 where it is routed to the correct VLAN gateway. No changes to SW01 or MKT01 are needed for existing VLANs.

## Validation

```bash
pveversion
egrep -c '(vmx|svm)' /proc/cpuinfo
cat /etc/network/interfaces
ip a
ping -c 4 10.10.0.1
ping -c 4 1.1.1.1
pvesm status
```

Expected:

- Proxmox 8.4.x running
- VT-x active (count > 0)
- vmbr0 at 10.10.0.10/24, state UP, bridge-vlan-aware yes
- Gateway and internet reachable
- `local` and `local-lvm` storage both active

## Known Issues

| Issue | Status |
|---|---|
| GUI shell button fails — VNC connection to localhost:5900 refused | Open — SSH is the working substitute |
| Gi1/0/4 negotiated at 100Mbps in one session | Resolved after reboot — monitor if it recurs; try cable swap first |
| 🔴 **iDRAC is on the shared LOM — NOT out-of-band** | **Open** — it dies with SW01, which is step one of any teardown. The R410 has an **unused dedicated iDRAC port.** See `CM-0011`. |
| 🔴 iDRAC not onboarded | **Open** — password **changed at the console 2026-07-16** (no longer factory), but no Lab CA cert, no deliberate path, still shared LOM. Onboarding blocked on `CM-0012` → `050`. |
| 🔴 CMOS battery / RTC non-durable | **Open** — new CR2032 installed 2026-07-16, **durability re-test still fails** (RTC resets `2026`→`2018` across a power cycle). Battery-vs-board unresolved. `CM-0012`. Keep on UPS. |

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `bridge-vlan-aware yes` missing | Per-VM VLAN tags have no effect | Add to vmbr0 stanza in `/etc/network/interfaces`, then `ifreload -a` |
| PVE01 management on vmbr0.20 instead of vmbr0 | Unreachable — vmbr0 sends untagged frames | Remove sub-interface; management IP goes on vmbr0 directly |
| SW01 Gi1/0/4 native VLAN 999 | PVE01 unreachable — untagged frames land in catch-all | Set `switchport trunk native vlan 10` on Gi1/0/4 |
| PVE01 MAC not in SW01 STATIC-HOSTS | ARP inspection **silently drops** PVE01 | Add `0000.5e00.5313` **and** `0000.5e00.5314` (iDRAC — same port) |
| 🔴 **Planning a rebuild around iDRAC access** | **iDRAC is unreachable during a teardown** — it shares `eno1`'s NIC/cable/port and dies with SW01 | **Use a physical keyboard and monitor.** See `048-Teardown-and-Rebuild-Runbook.md`. |
| VT-x not enabled in BIOS | VMs fail to start: `KVM virtualization configured but not available` | Reboot → F2 → Processor Settings → Virtualization Technology → Enabled |
| Enterprise repo active without subscription | `apt update` fails with 401 Unauthorized | Switch to pve-no-subscription repo |

## Rollback

Network configuration is in `/etc/network/interfaces`. Restore a previous version with:

```bash
cp /etc/network/interfaces.bak /etc/network/interfaces
ifreload -a
```

If `ifreload` is unavailable or fails, reboot. The configuration in the file is applied at boot.

## Completion Checklist

- [ ] Proxmox 8.4.x verified
- [ ] VT-x active — `egrep -c '(vmx|svm)' /proc/cpuinfo` returns > 0
- [ ] vmbr0 configured: 10.10.0.10/24, bridge-vlan-aware yes, eno1 as bridge port
- [ ] Gateway ping succeeds (10.10.0.1)
- [ ] Internet ping succeeds (1.1.1.1)
- [ ] PVE01 MAC **and iDRAC MAC** both in SW01 STATIC-HOSTS
- [ ] /etc/hosts has pve01.lab entry
- [ ] No-subscription repository configured
- [ ] Updates applied
- [ ] No-subscription GUI patch applied
- [ ] GUI reachable at https://10.10.0.10:8006
- [ ] SSH reachable at root@10.10.0.10
- [ ] Storage: local and local-lvm both active
- [ ] Build Record updated

## 🔴 Correction — 2026-07-13

**This guide previously listed the iDRAC as a "separate physical port."** It is not. `003-Physical-Topology.md` v2.0 confirmed via `ipmitool lan print 1` that the R410's three MACs are **sequential** (`…a2`, `…a3`, `…a4`) — **one card, iDRAC in shared/LOM mode**, riding `eno1`'s cable on `Gi1/0/4`.

**A guide that says iDRAC is a separate port produces a rebuild where the iDRAC MAC is never added to `STATIC-HOSTS`** — because nobody thinks a "separate port" needs an entry on `Gi1/0/4`. **ARP inspection then silently drops it**, and the iDRAC appears simply broken.

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Verified build guide. |
| **2.1** | 🔴 **iDRAC corrected: shared LOM, not a separate port.** Step 4 now adds **both** MACs to `STATIC-HOSTS`. Added the teardown warning — iDRAC is not a bootstrap path. Added `CM-0011` (shared LOM + factory credentials) and `CM-0012` (dead CMOS battery) to Known Issues. |
| **2.2** | 🟢 **2026-07-16 — reconciled against the live `060` run.** Added the kernel-6.8 note to the VT-x check (`egrep -c '(vmx|svm)'` = 32 = 2× CPU count; use `grep -c '^flags.*vmx'` / `kvm_intel`). Updated Known Issues: iDRAC password changed at the console (onboarding still blocked → `050`); CMOS/RTC durability re-test still failing (`CM-0012`). Network config, IP, `bridge-vlan-aware`, and repo all still match live. |
