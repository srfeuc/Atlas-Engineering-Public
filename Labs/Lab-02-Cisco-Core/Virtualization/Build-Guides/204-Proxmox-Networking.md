---
Title: Proxmox Networking
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Proxmox Networking

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> 🔴 **Verified-state SoT = `Build-Records/PVE01-Networking.md` (`ADR-0034`, `POL-0008`).** This page is the **build *procedure*** — how to apply the design, the recovery-first order, and the lessons. The authoritative *verified state* for PVE01 networking lives in that Build-Record; keep this guide's steps current and read state back there.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | v1.2 — 🔴 **design change: host management moves from untagged (native VLAN 10) to TAGGED VLAN 10 on `vmbr0.10`**, so SW01 `Gi1/0/4` native VLAN becomes **999** (no more native==mgmt coupling). ✅ **Device-verified 2026-07-24** (`vmbr0.10` = `10.10.0.10/27`, `vmbr0` no L3, gateway ping 0% loss from the R410 console; SW01 both trunks native 999, saved). Coordinated with `SW01/Build-Guide.md` v0.7; see `Architecture/SW01-PVE01-Native-VLAN-Options.md` for both patterns. |
| Version | 1.2 |
| Applies To | PVE01 |

## Purpose

Configure PVE01 with **tagged** management traffic on VLAN 10 (a `vmbr0.10` subinterface) and tagged VM traffic on the same VLAN-aware bridge — and trunk the VM VLANs out the physical uplink so tagged frames actually leave the host. The physical uplink carries **no untagged VLAN**; SW01 `Gi1/0/4` native VLAN is the unused parking VLAN **999**.

## Design Philosophy

> 🔴 **Changed 2026-07-23 (v1.2).** Host management was previously *untagged*, relying on SW01 `Gi1/0/4`'s native VLAN 10 to classify it. That coupled the native VLAN to the management VLAN — a security-hygiene oversight — and it caused a real asymmetry bug: a VM whose vNIC was tagged VLAN 10 lost its return traffic, because the switch egressed VLAN 10 **untagged** on the native and the VLAN-aware bridge won't deliver an untagged frame to a tagged vNIC (see Lessons Learned — *Native VLAN 10 doubled as management*). The fix: management becomes a **tagged** VLAN like every other, on `vmbr0.10`; native 999 (parking) carries nothing.

Host management traffic is tagged VLAN 10 on `vmbr0.10`; the host owns the 802.1Q tag for its own management, exactly as each VM owns its tag. `bridge-vlan-aware=yes` on `vmbr0` enables per-VM tagging; a `vmbr0.10` subinterface gives the host itself a tagged presence on VLAN 10. Nothing rides the wire untagged, so the switch's native VLAN can be the unused **999** — no VLAN carries traffic as "native," which is the desired posture.

One addition is essential, and easy to miss: a VLAN-aware bridge only trunks the VLANs listed in `bridge-vids` out of its physical uplink. Without that line, `eno1` is a member of VLAN 1 only, and every tagged frame (VM *and* the host's own `vmbr0.10`) is silently dropped at the bridge before it reaches the switch. `bridge-vlan-aware yes` *enables* tagging; `bridge-vids` is what actually carries the tags to the wire. See Lessons Learned — *Tagged VM traffic never left the host*.

This design supersedes both (a) the original attempt to place the host directly on VLAN 20 (Servers), which failed on a tagging mismatch, and (b) the untagged-native-10 design that replaced it; see Lessons Learned. Management-on-VLAN-10 is unchanged — only *how the tag is carried* changed (now tagged, not native).

## Prerequisites

- Proxmox Post-Installation Configuration complete
- 🔴 **Out-of-band recovery proven first** — an actual login on PVE01's **iDRAC/BMC console** (`Device-Hardening-Standard` Part A). Applying this over the network will drop the session mid-change.
- SW01 `Gi1/0/4` set to trunk, **native VLAN 999**, VLANs 10,20,30,40,50,60,70,80,90,999 allowed (`SW01/Build-Guide.md` v0.7 — coordinate the two ends; see its Step-3 callout).

## Target Configuration

```text
auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet manual
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 10,20,30,40,50,60,70,80,90,999

# Host management — TAGGED VLAN 10 (was untagged-on-vmbr0 relying on native 10)
auto vmbr0.10
iface vmbr0.10 inet static
        address 10.10.0.10/27
        gateway 10.10.0.1

iface eno2 inet manual

source /etc/network/interfaces.d/*
```

Management is now **tagged** VLAN 10 on `vmbr0.10`; `vmbr0` itself holds no L3 address. `bridge-vids` makes `eno1` a tagged member of every VLAN — the VM VLANs **and** VLAN 10 (which now carries the host's own tagged management). The VLAN set matches the SW01 `Gi1/0/4` trunk (10–90,999). `bridge-vids 2-4094` is the allow-all alternative, but the scoped list matches the switch and keeps undefined VLANs off the wire.
- 🔴 **Mask fixed to `/27`** (was `/24`): VLAN 10 = `10.10.0.0/27` per `IP-Addressing-Plan-VLSM` (gateway `10.10.0.1/27`). `10.10.0.10` is unchanged and still valid in the /27 (.1–.30).
- 🔴 **VLAN 90 added to `bridge-vids`** to match the switch trunk's allowed list (10–90,999); harmless if no PVE01 VM uses OT.

## Implementation

### 1. Before Changing Networking

1. 🔴 **Prove the iDRAC/BMC console with a real login** — this change drops PVE01's network management for the window between the switch flip and the `vmbr0.10` apply. Do the whole thing from iDRAC, not over the network (`Device-Hardening-Standard` Part A).
2. Back up:
   ```bash
   cp /etc/network/interfaces /root/interfaces.before-$(date +%F-%H%M%S)
   ```
3. Confirm the SW01 side is ready to flip `Gi1/0/4` to **native 999** in the same window (`SW01/Build-Guide.md` v0.7 Step 3). SW01's own management is not at risk (it rides `Gi1/0/1`→MKT01), so drive the switch from a separate session and PVE01 from iDRAC.
4. Confirm `10.10.0.10/27` is still the intended host address (unchanged; mask corrected to /27).
5. Never apply this over the network — the out-of-band iDRAC path is mandatory here, not optional.

### 2. Apply Configuration

```bash
nano /etc/network/interfaces
```

Use the target configuration above. **Coordinated order (from iDRAC):** (1) flip SW01 `Gi1/0/4` to native 999; (2) edit `/etc/network/interfaces` to the target (bare `vmbr0` + tagged `vmbr0.10`); (3) apply. With `ifupdown2` a reload usually suffices — `ifreload -a` — but because this changes the management path, **a host reboot is the safest apply** and leaves no half-applied state. After it comes back, `ping 10.10.0.1` and confirm the web UI answers on `10.10.0.10`.

```bash
nano /etc/network/interfaces
ifreload -a          # or: reboot  (safest for a management-path change)
ip -br address       # vmbr0.10 = 10.10.0.10/27; vmbr0 and eno1 = no L3 address
bridge vlan show     # eno1 tagged on 10,20,…,90,999
ping -c4 10.10.0.1
```

### 3. Trunk the VM VLANs on the Uplink (`bridge-vids`)

A VLAN-aware bridge does **not** automatically carry VM VLANs out the physical port — each VLAN must be declared with `bridge-vids`, or the bridge tags the frame internally and then drops it on egress because the uplink is not a member of that VLAN. Add the VLANs in use to the `vmbr0` stanza (already shown in the Target Configuration):

```text
        bridge-vids 10,20,30,40,50,60,70,80,999
```

Apply and verify — with `ifupdown2` no reboot is needed:

```bash
cp /etc/network/interfaces /root/interfaces.before-vids-$(date +%F-%H%M%S)
# add the bridge-vids line to the vmbr0 stanza, then:
ifreload -a
bridge vlan show
```

In `bridge vlan show`, `eno1` must now list every VM VLAN (10, 20, … , 999) as a **tagged** member, alongside `1 PVID Egress Untagged` for management. If `eno1` shows only VLAN 1, the VLANs are not trunked and tagged VM traffic will die at the uplink.

To test a single VLAN before editing the file, add it at runtime (non-persistent — lost on reboot):

```bash
bridge vlan add dev eno1 vid 70
```

### 4. Assign a VM to a VLAN

In the VM hardware settings:

1. Select **Network Device**.
2. Bridge: `vmbr0`.
3. VLAN Tag: required VLAN ID — **must also be present in `bridge-vids` (§3)**, or the frame is dropped at the uplink.
4. Firewall: enable according to policy.
5. Confirm NIC model and guest driver support.

| Workload | VLAN tag |
|---|---:|
| Domain controller | 20 (target design — see Lessons Learned and Build Guide 014 for current live status) |
| Web server | 30 |
| Monitoring server | 40 |
| Client | 50 |
| Deployment server | 60 |
| Testing workload | 70 |
| DMZ server | 80 |

## Validation

```bash
ip -br address
ip route
bridge vlan show            # eno1 must list all VM VLANs (10-80,999) tagged, not just VLAN 1
ethtool eno1
ping -c 4 10.10.0.1
ping -c 4 1.1.1.1
```

Expected: `eno1` and bare `vmbr0` UP with **no L3 address**; **`vmbr0.10` UP at `10.10.0.10/27`**; default route through `10.10.0.1`; 1 Gbps full-duplex link; gateway and Internet reachable; and `eno1` carrying every VLAN (10–90,999) tagged in `bridge vlan show` (VLAN 10 is now tagged too, since the host's own management rides `vmbr0.10`).

**Tagged-VM check.** Place a VM on a non-management VLAN and confirm reachability appropriate to that VLAN's policy. For an isolated VLAN (e.g. 70), the correct proof is a *denial*: generate a cross-VLAN flow from the VM and confirm MKT01 logs `EAST-WEST-DENIED: forward: in:vlan70-testing out:vlan10-mgmt` — that entry proves the tagged frame reached the router. (Note: on an isolated VLAN with no DHCP, the switch's Dynamic ARP Inspection will drop the VM's gateway ARP unless a static binding exists — `ip source binding <mac> vlan 70 <ip> interface Gi1/0/4` on SW01, or a static ARP neighbour on the VM. This is expected Layer-2 behaviour, not a bridge fault.)

## Common Mistakes

- **Proxmox address conflicts with FortiGate.** FGT01's management interface uses `10.10.0.254`. PVE01 must use `10.10.0.10`.
- **`bridge-vlan-aware yes` without `bridge-vids`.** The uplink then carries only VLAN 1, so every tagged VM frame is silently dropped at `eno1` before it reaches the switch. `bridge vlan show` reveals it: the VM's tap has the correct PVID, but `eno1` lists VLAN 1 only. This is the single most common reason VLANs are "configured but don't work."
- 🔴 **Flipping only one end.** The switch native VLAN (999) and the PVE01 tagged-`vmbr0.10` change must happen **together**, from the iDRAC console. Switch-only → PVE01's still-untagged management lands in the parking VLAN and the web UI dies; PVE-only → the switch still egresses VLAN 10 untagged on native 10 and the tagged `vmbr0.10` never hears the return (the old asymmetry). Apply both in one out-of-band window.
- 🔴 **Management IP left on `vmbr0` (untagged) after native→999.** With native 999 the host's untagged frames go to the parking VLAN. The management IP must sit on the **tagged `vmbr0.10`**, not on `vmbr0` or `eno1`.
- **IP assigned to `eno1` or bare `vmbr0`.** The management IP belongs on the tagged `vmbr0.10` subinterface — not the physical member, not the bare bridge.
- **100 Mbps link.** Check cable, autonegotiation, switch port, NIC, and errors before changing bridge configuration — this was observed transiently on this host; confirmed stable at 1 Gbps as of the most recent check.

## Lessons Learned from Actual Deployment

### Host management on the wrong VLAN (native-VLAN tagging mismatch)

Proxmox's host management was originally planned for VLAN 20 (Servers). The actual attempt failed with a tagging mismatch: `vmbr0` had the management IP placed directly on the bridge (untagged), while the switch port was configured as a trunk expecting the target VLAN tagged, with native/PVID set to the unused VLAN 999 — so untagged frames from Proxmox were silently classified into VLAN 999 and never reached VLAN 20. Neither side was technically broken; they disagreed about who was responsible for the 802.1Q tag. The resolution at the time — untagged host management on VLAN 10 (via the switch's native VLAN), VMs tagged individually — was a legitimate, common enterprise pattern: VLAN isolation depends on which VLAN a device can reach, not on whether that one wire happens to carry a tag. 🔴 **Superseded 2026-07-23 (v1.2) — see the next lesson.** It was correct but coupled the *native* VLAN to the *management* VLAN, which is the oversight v1.2 removes.

### Native VLAN 10 doubled as management — moved to tagged (2026-07-23, v1.2)

The untagged-management design above made VLAN 10 the **native** VLAN on `Gi1/0/4`. Two problems followed. First, security hygiene: the native (untagged) VLAN should be an unused parking VLAN, never the management VLAN — coupling them means any device that falls back to untagged lands straight in management. Second, a concrete bug (`SW01/Build-Guide.md` v0.6): a VM whose vNIC was tagged **VLAN 10** lost its return traffic, because the switch egressed VLAN 10 **untagged** on the native and a VLAN-aware bridge will not deliver an untagged frame to a tagged vNIC — so VLAN 10 was effectively unusable for VM workloads.

The fix decouples them: SW01 `Gi1/0/4` native → **999** (parking, carries nothing), and PVE01's host management moves onto a **tagged `vmbr0.10`**. Now *nothing* rides the wire untagged, VLAN 10 behaves like every other tagged VLAN (VM workloads on VLAN 10 work), and native-VLAN hygiene is uniform across every trunk. Management is still on VLAN 10 — only the tag delivery changed (tagged, not native). 🔴 **Two-ended, recovery-first:** apply both ends from the iDRAC console in one window (Implementation §1–2); switch-only or PVE-only leaves management unreachable.

### Tagged VM traffic never left the host (missing `bridge-vids`)

For a long time, per-VM VLANs simply did not work: a VM tagged into VLAN 70 could reach nothing, and none of its traffic ever appeared at the core router. Every layer looked correct — the VM's IP, route, and NIC VLAN tag were right; the switch trunk allowed the VLAN; the Proxmox NIC firewall was ruled out. `bridge vlan show` finally exposed it: the VM's tap port carried the correct `70 PVID`, but the physical uplink `eno1` was a member of **VLAN 1 only**. A VLAN-aware Linux bridge will not trunk a VLAN out a port unless that VLAN is in the port's member set, and Proxmox populates the uplink's member set from the bridge's `bridge-vids` — which had never been set. So the bridge tagged each frame VLAN 70 internally, then dropped it on egress because `eno1` was not in VLAN 70.

Adding `bridge-vids 10,20,30,40,50,60,70,80,999` and reloading made `eno1` a tagged member of every VM VLAN. Confirmed working by tagging a VM into VLAN 70 and generating a cross-VLAN flow: MKT01 logged `EAST-WEST-DENIED: forward: in:vlan70-testing out:vlan10-mgmt … 10.70.0.50 -> 10.10.0.5`, proving the tagged frame reached the router and hit the east-west drop rule. The lesson mirrors the native-VLAN one above: nothing was "broken," and the config *looked* complete — `bridge-vlan-aware yes` was present — but the path was never proven end to end, and the one line that actually trunks VM VLANs to the wire was missing.

## Rollback

From console or iDRAC:

```bash
cp /root/interfaces.before-<timestamp> /etc/network/interfaces
reboot
```

## Completion Checklist

- [x] `eno1` UP, no L3 address
- [x] `vmbr0.10` UP at `10.10.0.10/27` (host mgmt tagged); bare `vmbr0` + `eno1` no L3 — ✅ device-verified 2026-07-24 (R410 console: `ip -br a` + `ping 10.10.0.1` 0% loss)
- [x] Default route via `10.10.0.1`
- [x] 1 Gbps full-duplex confirmed
- [x] Gateway and Internet reachable
- [x] Tagged VM VLAN connectivity proven (VLAN 70 VM → `EAST-WEST-DENIED` at MKT01)
- [ ] `bridge-vids 10,20,30,40,50,60,70,80,999` set permanently in `/etc/network/interfaces` and reconciled to live (`bridge vlan show` shows `eno1` trunking all VM VLANs after `ifreload -a`)

## Next Guide

Proxmox Storage.
