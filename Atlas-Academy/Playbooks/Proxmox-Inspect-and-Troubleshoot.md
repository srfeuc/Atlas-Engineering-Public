---
Title: Playbook — Proxmox Inspect & Troubleshoot (PVE01 / PVE02)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — commands + the real incidents are grounded; per-run read-backs land in the Worked log. PVE01 built; PVE02 target-state.
Version: 1.0
Date: 2026-07-31
---

# Playbook — Proxmox Inspect & Troubleshoot

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: problem. **A Proxmox host is misbehaving — VM networking is dead, the host won't run VMs, storage is missing, a VM won't start, or the web UI is unreachable. Inspect the host and fix it.** Per-host troubleshooting for **PVE01** (R410) and **PVE02** (EQR6).

**Companion docs (link, don't duplicate — `POL-0008`).** Build/prep: `Virtualization/Build-Guides/201-Dell-PowerEdge-R410-Preparation.md` · install `202` · post-install `203`. Authoritative networking: `Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`) + `204-Proxmox-Networking.md`. Storage `205` · auth `206` · PVE02 bring-up `221`. Verify commands: `../Command-Library/Linux.md` §Proxmox / §Networking / §Time. Why-it-works: `../Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md`.

## Symptoms / when you'd use this

- A VM has no network, or only *some* VLANs work, though the host itself is reachable.
- The host won't start VMs (`KVM not available` / VT-x errors) — often **after a power loss**.
- The Proxmox web UI (`https://<host>:8006`) is down, or the host mgmt IP is gone.
- A datastore (`local` / `local-lvm`) is missing or `inactive`.
- A VM is `locked` or won't start.
- The clock is wrong (see the RTC note — real on PVE01).

## Cert anchor

CompTIA **Linux+** (virtualization, services, storage, networking) · AZ-800 (the Hyper-V analog for the exam) · CCNA 2.0 (VLAN/trunk — the VM-networking half). *(Grounding index: the cert maps; `../Academy-Vision-and-Scope.md`.)*

## Grounded in — the real PVE01 facts + the incidents that bite

- **PVE01** = Dell R410, 16 logical CPUs, 62 GiB, `local` ~94 GB + `local-lvm` ~793 GB; mgmt **`vmbr0.10` = `10.10.0.10/27`** (tagged VLAN 10), uplink `eno1` → SW01 `Gi1/0/4` (trunk, native 999). **PVE02** = EQR6 (target-state; `10.10.0.11`).
- 🔴 **The three that actually bite here** (all real): **`CM-0012`** — a dead CMOS battery resets BIOS on any full power loss → **VT-x disabled** + **RTC reset to 2018** (`201` Lessons Learned); **the `bridge-vids` trap** — if `eno1` isn't tagged for the VM VLANs, tagged VM frames are silently dropped (`204` / Concept N2/N3); **`CM-0011`** — iDRAC is shared-LOM on `eno1`, not a separate OOB port.
- 🔴 **PVE01 is root-only — `sudo` is not installed.** Every command here runs as **root**; any external Proxmox tutorial that prefixes `sudo` **fails as written** — strip it (Lab-01 `016` / PVE01 `Troubleshooting`).

## ① Pin it down (capture these first — they're the ticket)

- a. **Which host** — PVE01 or PVE02 — and can you reach it (SSH by **IP** / iDRAC console)?
- b. **What's failing** — VM networking / the host running VMs / the web UI / storage / one VM / the clock?
- c. **Scope** — one VM or all? one VLAN or all? one datastore?
- d. **Recent change** — 🔴 **any power loss / move / PSU swap?** (that's the `CM-0012` trigger). A config edit, a reboot, an upgrade?

## Diagnosis path — by symptom (jump to yours)

Each step links **down** to the Command-Library; **never invent output** (`POL-0001`).

**A. VM networking dead — some/all VLANs (the `bridge-vids` trap).**

- a. Host mgmt on the tagged sub-iface? `ip -br address` → `vmbr0.10 = 10.10.0.10/27`; bare `vmbr0`/`eno1` carry **no** L3.
  - Broken: an IP on bare `vmbr0`/`eno1` → native-999 breaks it. → `../Command-Library/Linux.md` §PVE01 bridge/VLAN.
- b. 🔴 Is the uplink tagged for the VM VLANs? `bridge vlan show`.
  - Healthy: `eno1` **tagged** on 10–90,999.
  - Broken: `eno1` **VLAN 1 only** → tagged VM frames dropped (missing `bridge-vids`). This is the classic Atlas trap. → `204` / Concept N2/N3.
- c. 📸 the `bridge vlan show` output (the VLAN list on `eno1`). *(images/; no secrets — `POL-0002`/SS-001.)*
- d. Still dead? Confirm the *switch* side (SW01 `Gi1/0/4` trunk allows the VLAN) → `Trace-a-Blocked-Flow.md` step 5 + `../Command-Library/Cisco-IOS.md` §Interfaces.

**B. Host won't run VMs (VT-x / KVM) — usually after a power loss (`CM-0012`).**

- a. `grep -c '^flags.*vmx' /proc/cpuinfo` → the real count (**16** on PVE01). 🔴 *Don't* use `egrep -c '(vmx|svm)'` as a count — on kernel 6.8 it returns **32** (a `vmx flags:` line per CPU); read that only as *">0 = VT-x on"* (Lab-01 `Troubleshooting` v1.2).
- b. `lsmod | grep kvm` → `kvm_intel` (or `kvm_amd` on EQR6) loaded.
- c. `dmesg | grep -iE 'kvm|vmx|svm'` → 🔴 `VMX (outside TXT) disabled by BIOS` = VT-x got reset (dead CMOS battery, `CM-0012`).
- Reference: `201` Lessons Learned + Lab-01 `PVE01-Hypervisor/Troubleshooting.md`. 📸 the `dmesg` VMX line if disabled.

**C. Web UI / host mgmt unreachable.**

- a. `systemctl status pveproxy pvedaemon` → both `active`; UI at `https://<host>:8006`.
- b. If services are up but unreachable → it's networking (symptom A) or the switch path; SSH by IP is the substitute console.
- c. Reference: `../Command-Library/Linux.md` §Proxmox.

**D. Storage missing / inactive.**

- a. `pvesm status` → `local` + `local-lvm` **active** (~94 GB / ~793 GB).
- b. Broken: a store `inactive` → check the underlying LVM/disk (`205`); thin-overcommit caveat noted there.
- c. 📸 the `pvesm status` table.

**E. A VM won't start / is locked.**

- a. `qm list` → the VM present, its status.
- b. `qm start <id>` → read the error; `qm unlock <id>` if it's stale-locked (a killed migration/backup).
- c. `qm config <id>` for its disk/net binding; `journalctl -u pve*` for why (→ `Read-the-Logs-with-journalctl.md`).

**F. Clock wrong (RTC reset — real on PVE01).**

- a. `timedatectl` → `System clock synchronized: yes`.
- b. `chronyc tracking` / `chronyc sources` → selected source DC01 `10.20.0.2` (`ADR-0020`).
- c. 🔴 `hwclock` after a power cycle still resets (`CM-0012`); `chronyd` re-corrects once the OS + network are up. Keep the host on UPS. → `../Command-Library/Linux.md` §Time.

## The fix

- **Networking (A):** re-add the VLANs to the uplink (`bridge-vids` on `eno1` / the `vmbr0` config per `204`/`PVE01-Networking`, the authoritative owner — don't hand-edit divergently, `POL-0004`); reload networking; re-test a VM on the affected VLAN.
- **VT-x (B):** re-enter BIOS, re-enable Intel VT + VT-d (`201` §2). 🔴 **The CMOS battery is the root cause — but a CR2032 swap was tried and did *not* resolve it** (the RTC still resets `2026`→`2018` across a power cycle; open: weak cell vs a failed RTC circuit — `CM-0012`). Practical mitigation = **keep the host on UPS** (the battery only matters on a full power loss). Re-check `grep -c '^flags.*vmx'` **before** trusting the host with VMs, and prove any battery fix with a **boot RTC of `2026`**.
- **Web/storage/VM (C/D/E):** restart the affected service / reactivate the store / `qm unlock` + start; record a `CM-####` if it's a config change.
- **Clock (F):** ensure the NTP source is reachable (`Fix-the-SW01-Clock.md` shares the `ADR-0020` source); the durable fix is the CMOS battery.

## Prove it's fixed

- a. Re-run the specific check that failed (e.g. `bridge vlan show` shows the VLANs; `egrep -c vmx` non-zero; `pvesm status` active; `qm list` running).
- b. For networking: a VM on the affected VLAN passes `Test-a-Connection.md` to its gateway + a peer.
- c. 📸 the recovered read-back.
- d. Mark ✅ only with the pasted output.

## If still broken

- VM networking fine on the host but blocked beyond it → not Proxmox; it's the switch/firewall path → `Trace-a-Blocked-Flow.md`.
- Host flapping VT-x/RTC every reboot → the CMOS battery isn't replaced (`CM-0012`); that's the root cause, not a config.
- iDRAC unreachable → remember it's **shared-LOM** on `eno1` (`CM-0011`) — if `eno1`/the switch port is down, iDRAC is too.

## Worked log

*Add a row each time this playbook is actually run — the outcome is the evidence (`POL-0001`). This tracks **uses**; the Change Log below tracks **edits**.*

| Date | Who | Time | Host · scenario · outcome (RTO if a drill) |
|---|---|---|---|
| | | | |

## Related

- Build/records: `Virtualization/Build-Guides/201`–`206`, `221` · `Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`) / `PVE01-Storage` / `PVE01-Authentication` / `PVE01-Diagnostics`.
- Command-Library: `../Command-Library/Linux.md` (§Proxmox/§Networking/§Time). Concepts: `../Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (N2/N3 VLAN, migration).
- Decisions/records: `ADR-0034` (networking ownership) · `ADR-0036` (placement) · `CM-0011` (iDRAC shared-LOM) · `CM-0012` (CMOS/VT-x/RTC) · `ADR-0020` (time).
- 🔒 **Lab-01 (frozen) real-incident history** (`ADR-0022` — historical; the current design wins where they differ): `Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor/Troubleshooting.md` (VT-x · CMOS-explains-three-symptoms · the faulty B1 DIMM · the "invalid system configuration" BIOS message · the VLAN-tagging mismatch — 🔴 **its "untagged vmbr0" resolution is superseded by the current tagged `vmbr0.10` design**) · `.../Devices/PVE01-Hypervisor/Changes/CM-0011`/`CM-0012` (the authoritative records) · `Operations/050-PVE01-iDRAC-Onboarding-Runbook.md` · `Operations/016-Network-Lessons-Learned.md`.
- Sibling playbooks: `Trace-a-Blocked-Flow.md` · `Test-a-Connection.md` · `Read-the-Logs-with-journalctl.md` · `Port-Already-In-Use.md` · `Domain-Join-Fails.md`.
- **Checklist (reciprocal, `ADR-0053` §8):** `00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx` — **Phase 1 "VM create & base OS"** (VirtIO + QEMU guest agent) + **Phase 3 "disable hypervisor guest time-sync"** hand off here for a VM that won't boot / has no NIC / has a bad clock on Proxmox.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created (`ADR-0053`) — the per-host Proxmox inspect-&-troubleshoot page (operator ask). Six symptom paths (VM networking / VT-x / web / storage / VM / clock) grounded in the real PVE01 facts + the `CM-0012`/`CM-0011`/`bridge-vids` incidents; links down to `201`–`206`/`PVE01-Networking`/Command-Library. Folded in the **frozen Lab-01 PVE01 Troubleshooting** history (operator) — the **root-only/no-`sudo`** warning, the corrected VT-x count (`grep -c '^flags.*vmx'`, not `egrep`=32 on kernel 6.8), and the honest `CM-0012` status (**battery swap did not fix the RTC** — UPS is the mitigation). Introduces the **Worked log** section (`ADR-0053` §5). 🟡 until run. |
