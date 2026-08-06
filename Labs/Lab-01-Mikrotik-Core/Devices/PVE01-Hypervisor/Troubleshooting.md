---
Title: PVE01 Troubleshooting Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor
---

# PVE01 Troubleshooting Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PVE01 - Role: Hypervisor

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | **1.1** |
| Applies To | PVE01 |
| Last Updated | 2026-07-14 |

## Purpose

Every entry below is a real incident encountered on PVE01, not a hypothetical. For initial build steps, see `Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/201-Dell-PowerEdge-R410-Preparation.md`.

## Before You Start

- [ ] Has the host lost power recently (outage, moved, PSU work)? If yes, jump straight to the CMOS Battery entry below — it explains three separate-looking symptoms with one cause.
- [ ] Is this a fresh symptom, or does it match something already known and accepted (e.g., the CMOS battery pattern)?
- [ ] Check `dmesg` before assuming anything — several of these incidents were only solvable because the actual kernel message named the real cause directly.

> 🔴 **`sudo` is not installed on PVE01.** Root-only login. Every command in this guide runs as root — **and every Proxmox guide that prefixes commands with `sudo` fails as written.** If you are copying a command from an external Proxmox tutorial, strip the `sudo` first. See `016-Network-Lessons-Learned.md`.

## Diagnostic Approach

```text
Hardware — BIOS state, CMOS battery, memory seating
OS/Boot — kernel messages, time sync
Network — bridge config, VLAN tagging
Storage — LVM/thin-pool health
```

---

## Incident: VMs Won't Start / VT-x Not Available

**Symptom:** VM creation or start fails, or `egrep -c '(vmx|svm)' /proc/cpuinfo` returns `0`.

**Root cause found:** BIOS-level Intel VT-x disabled — confirmed via `dmesg`, not assumed.

**Diagnostic steps:**
```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
lsmod | grep kvm
dmesg | grep -iE "kvm|vmx|svm|virtual"
```

Expected if healthy: `kvm`/`kvm_intel` loaded. 🔴 **On kernel 6.8 the `egrep -c '(vmx|svm)'` count is ~2× the CPU count (32 on this 16-CPU host)** — 6.8 adds a `vmx flags:` line per CPU — so read it only as *"> 0 = VT-x on"*, not a CPU count. For the actual count use `grep -c '^flags.*vmx' /proc/cpuinfo` (= 16).

What a failure looks like: count returns `0`, no kvm modules loaded, and — this is the line that actually explains it — `dmesg` shows:
```text
x86/cpu: VMX (outside TXT) disabled by BIOS
```

**This is not a one-off misconfiguration on this host — it's caused by the dead CMOS battery.** See that entry below; fixing VT-x alone without addressing the battery means it comes back after the next full power loss.

**Resolution:** Reboot → BIOS (F2) → Processor Settings → Virtualization Technology → Enabled. Save and reboot.

**Verify fix:**
```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
lsmod | grep kvm
```

---

## Incident: CMOS Battery Dead — Explains Three Symptoms at Once

**Symptom:** Any *combination* of: VT-x disabled unexpectedly, system clock wildly wrong (found reset to 2018), or a BIOS "invalid system configuration, please use Setup" message after any hardware change.

**Why this matters as one entry, not three:** these look unrelated the first time you see them. They aren't. A dead CR2032 CMOS battery resets BIOS settings to factory defaults and loses the real-time clock on every full power loss. If you're chasing one of these symptoms, check for the other two before treating them as separate problems.

**Diagnostic steps:**
```bash
date
timedatectl
hwclock --show
```
A `timedatectl` showing the RTC years in the past (this host: found at `2018-05-30`) while the OS clock is otherwise correct is the signature — the OS clock is being maintained by NTP after boot, the RTC itself is what's actually broken.

**Resolution (temporary, until physical replacement):**
```bash
chronyc tracking          # confirm Leap status: Normal and a real synced source
hwclock --systohc         # write the correct time to the RTC
```
This does **not** fix the underlying problem — the RTC will drift back to a stale date on the next full power loss. The only real fix is physically replacing the CR2032 battery.

> 🔴 **Update 2026-07-16:** a new CR2032 was installed and the durability test **still failed** — the RTC keeps resetting `2026`→`2018` across a power cycle (twice, including after reseating the holder clip; a written `hwclock --systohc` value does not survive). So on *this* board a battery swap did **not** resolve it. The open question is a weak/poorly-seated cell vs. a failed RTC circuit on the board (bare + seated voltage check pending). Tracked in `CM-0012` — **don't assume the swap fixed it; prove it with a boot RTC of `2026`.**

**Practical mitigation until replaced:** keep the host on continuous power (a UPS is the practical answer) — the battery is only a backup for full power loss, not normal operation. As long as the host never fully loses power, these symptoms mostly don't resurface.

**Common misconception, worth stating directly:** a CR2032 is a completely standard, cheap, widely available battery (same as most motherboards, key fobs, calculators) — it is not a hard-to-source part.

---

## Incident: DIMM Won't Seat / Memory Training Hang ("Configuring Memory" then blank screen)

**Symptom:** POST hangs at "Configuring Memory" with a blank screen after a RAM change; a specific DIMM slot's retention clips won't close.

**Root cause found on this host:** slot B1's socket was physically faulty — confirmed by moving the same DIMM to B3, where it seated and worked correctly.

**Diagnostic steps:**
1. Power off and fully unplug (hold power button ~5 sec after unplugging to drain residual charge).
2. Pull every DIMM, inspect the suspect slot for bent pins or debris.
3. Reseat: open both retention clips fully, align the notch, press evenly on both ends simultaneously.
4. If clips still won't close after correct technique, isolate: boot with only that DIMM in a known-good slot, then test the suspect slot alone with a known-good DIMM.

**Resolution:** Relocate the DIMM to a working slot. Check population order against the platform's documented supported configuration afterward — moving a DIMM to a different slot can silently drop triple-channel interleaving down to independent-channel mode (same capacity, worse bandwidth, no error thrown).

**Verify fix:**
```bash
free -h
dmidecode -t memory | grep -E "Size|Locator|Speed|Rank"
```

---

## Incident: BIOS Says "Invalid System Configuration, Please Use Setup"

**Symptom:** Appears after any DIMM change, repeats every boot until acknowledged.

**Diagnostic steps:** Enter Setup (F2, not F1 — F1 just dismisses it without re-validating). Check System BIOS → Memory Settings for total capacity and Node Interleaving / Memory Operating Mode.

**Resolution:** Save and Exit (F10) even without changing anything — this forces the BIOS to re-baseline its config against the current physical layout, which usually clears the message. If it repeats after a clean save, that indicates a genuine population-order mismatch, not a stale warning — see the DIMM entry above.

---

## Incident: Proxmox Host Can't Reach Its Intended VLAN (VLAN 20 Attempt)

**Symptom:** Host management interface configured for a target VLAN, but the host can't reach its gateway or be reached.

**Root cause found:** A tagging mismatch, not a broken link — `vmbr0` had the management IP placed directly on the bridge (untagged), while the switch port was configured as a trunk expecting that VLAN tagged, with native/PVID pointed at an unused VLAN. Two individually valid configurations that disagreed about who owned the 802.1Q tag.

**Diagnostic steps:**
```bash
ip a                                  # confirm which interface actually holds the IP
cat /etc/network/interfaces           # confirm bridge-vlan-aware and whether a vmbr0.X subinterface exists
```
On the switch side: confirm the port's native VLAN and tagged/untagged VLAN list match what the host is actually sending.

**Resolution applied (now the permanent design):** Host management stays untagged on `vmbr0`, landing on VLAN 10 via the switch's native VLAN — the host itself never needs to understand 802.1Q tagging for its own traffic. Individual VMs get tagged per-NIC in their own hardware settings instead.

**Lesson for any future VLAN placement decision on this host:** if a VM lands on a VLAN with DHCP and gets no address, don't assume the network path is broken before checking whether a DHCP scope actually exists on that VLAN yet — a missing DHCP server produces the same symptom as a real tagging fault.

---

## Quick Reference — Common Commands

| Task | Command |
|---|---|
| Check VT-x/virtualization support | `egrep -c '(vmx\|svm)' /proc/cpuinfo` |
| Check kernel virtualization messages | `dmesg \| grep -iE "kvm\|vmx\|svm\|virtual"` |
| Check RTC vs. system clock | `timedatectl` |
| Force NTP time correction | `chronyc tracking` then `hwclock --systohc` |
| Check memory layout | `dmidecode -t memory \| grep -E "Size\|Locator\|Speed\|Rank"` |
| Check bridge/VLAN config | `ip a` and `cat /etc/network/interfaces` |

## Escalation

1. Capture `dmesg`, `timedatectl`, and `dmidecode -t memory` output before further changes.
2. Check `Labs/Lab-02-Cisco-Core/Virtualization/Build-Records/215-PVE01-Current-State.md` against live state.
3. If hardware-related and the CMOS battery hasn't been physically replaced yet, treat any new hardware-adjacent symptom as possibly the same root cause until ruled out.

## Related Pages

- `Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/201-Dell-PowerEdge-R410-Preparation.md`
- `Labs/Lab-02-Cisco-Core/Virtualization/Build-Records/215-PVE01-Current-State.md`
- `Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/204-Proxmox-Networking.md`

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Created 2026-07-13 from real incidents: VT-x disabled by BIOS, the CMOS battery explaining three symptoms at once, the faulty B1 DIMM socket, the BIOS config warning, and the VLAN tagging mismatch. |
| **1.1** | **2026-07-14.** Added the 🔴 **`sudo` is not installed** warning — root-only login on this host, and every external Proxmox tutorial assumes otherwise. Published to Confluence (*PVE01 Troubleshooting Guide*); it was the only device troubleshooting guide with no Confluence home. |
| **1.2** | 🟢 **2026-07-16 — reconciled against the live `060` run.** Corrected the VT-x check: `egrep -c '(vmx|svm)'` returns **32** on kernel 6.8 (a `vmx flags:` line per CPU), not the "16" this guide expected — use `grep -c '^flags.*vmx'` / `kvm_intel`. Added the note that a battery **replacement did not fix** the CMOS/RTC durability failure (`CM-0012`). |
