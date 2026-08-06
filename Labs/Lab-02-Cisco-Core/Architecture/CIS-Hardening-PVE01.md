---
Title: PVE01 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-02-Cisco-Core/Architecture
---

# PVE01 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: PVE01 - Role: Hypervisor / virtualization platform (same box frozen in Lab-01; active here)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft — curated priority checklist, not exhaustive. Fills backlog #12 (PVE01 had no CIS doc). |
| Version | 1.0 |
| Applies To | PVE01 (Dell PowerEdge R410, Proxmox VE on Debian) |
| Reference | CIS Debian Linux Benchmark + Proxmox VE hardening guidance, structured like `../FGT01-NS-Firewall/CIS-Hardening.md` |
| Governing Policy | `POL-0007` (Hardening Baseline); evidence per `POL-0001` R-A1 |

> 🔴 **Evidence rule (`POL-0001` R-A1):** a `[x]` requires a command **and its output**. The `046` false-tick — *"chrony confirmed working"* when `chronyc: command not found` and the host actually runs `systemd-timesyncd` — happened on this class of box. Tick from `timedatectl`, not memory. **Unverified** is a legitimate recorded state.

---

## 1. Authentication & Named Administration

- [x] **Named admin account exists** — `seth-admin@pve` is in use (the least-privilege pattern the FGT01 doc wishes it had). *Evidence: documented in Book 2 auth build (`206`); confirm live with `pveum user list`.*
- [ ] **Root login restricted** — root@pam reserved for break-glass; day-to-day work via the named account; confirm PAM/SSH `PermitRootLogin` posture.
- [ ] **SSH hardening** — key-based auth preferred, password auth limited; management scoped to the Management zone (VLAN 10), not all VLANs.
- [ ] **2FA on the Proxmox web UI** — TOTP for admin accounts (Proxmox supports it natively).

## 2. iDRAC / BMC (🔴 real gap)

- [ ] 🔴 **Change iDRAC factory credentials** — the Virtualization pack manifest records **"iDRAC not hardened — factory default credentials never changed. Real gap."** A BMC on the network with factory creds is a full out-of-band takeover path. Change it, scope it to Management, and record it.
- [ ] **iDRAC on its dedicated NIC + Management VLAN** — ties to `050`; the MAC change on move must be reflected in the source of truth (`POL-0004`) or DAI drops it.

## 3. Updates & Repositories

- [ ] **No-subscription repo handled** — the manifest notes the no-subscription patch "will be reverted by `apt upgrade`"; needs a post-update hook or documented manual re-application so patching doesn't silently regress.
- [ ] **Patch cadence defined** — kernel/PVE updates on a schedule (WSUS is for Windows; this is the Debian side).

## 4. Time Synchronization

- [ ] 🔴 **Verify the actual time daemon and sync state** — `046` claimed chrony; the box runs `systemd-timesyncd`. Confirm with `timedatectl` (not `chronyc`), synced to the `ADR-0020` source. Every VM's clock, and thus every log and cert, depends on the host clock being right. **This is CIS 8.4 (Standardize Time Sync) — the prerequisite for all detective controls.**
- [ ] 🔴 **UPS + CR2032 installed** — the dead CMOS battery (`CM-0012`/`ADR-0017`) drops the RTC and BIOS settings on power loss; VT-x/nested-virt reverts too. Hardening is moot if the clock resets on every outage.

## 5. Virtualization / Network Segmentation

- [ ] **VLAN-aware bridge tags verified on the wire** — Book 2 had a VLAN-20 tagging failure; confirm each VM's vNIC lands in its intended zone by capture, not config (`POL-0004`/`POL-0006`).
- [ ] **Guest isolation** — VMs on their zone VLAN; no bridge shortcut around the MKT01 east-west firewall (would defeat `ADR-0023` segmentation).
- [ ] **Remove/disable unused host services** (`POL-0007`) — e.g. the broken noVNC/VNC on `localhost:5900` (manifest) if not used; SSH is the substitute.

## 6. Storage, Backup & Logging

- [ ] 🔴 **VM backups exist and are off-host** — the manifest states **"No backups of any VM, ever."** Proxmox Backup Server on `BKP01`, on **separate physical media** — backing up to the host it protects is not backup (`POL-0005`).
- [ ] **A restore has actually run** — a Game Day (`ADR-0011`/`POL-0005`): a backup you haven't restored is a hope.
- [ ] **Host logs shipped to MON01** — off-box, against the synced clock (§4).

## Real Priorities, Ranked

1. 🔴 **Change the iDRAC factory credentials** (out-of-band takeover path, factory creds today).
2. 🔴 **Real VM backups on separate media + one restore test** ("no backups, ever").
3. 🔴 **UPS + CR2032, then verify time sync with `timedatectl`** (clock is the base of all logging/PKI).
4. **Verify VLAN tags on the wire** (the Book 2 tagging failure; prevents segmentation bypass).
5. **Root/SSH hardening + 2FA** on top of the existing named admin.

## Related Pages

- `Labs/Lab-02-Cisco-Core/Virtualization/VIRTUALIZATION-PACK-MANIFEST.md` (the known-deviations source) · `Build-Records/215-PVE01-Current-State.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/CIS-Hardening.md` (the template)
- `00-Atlas-Foundation/Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md` · `ADR-0020` (NTP) · `ADR-0011` (Game Days)
- `00-Atlas-Foundation/Policies/` — `POL-0005` (Backup), `POL-0007` (Hardening)

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Created to fill backlog #12 (PVE01 had no CIS-Hardening doc), modelled on the strengthened FGT01 baseline. CIS Debian + Proxmox-informed. Captures the known real gaps — factory iDRAC creds, no VM backups ever, the `046` time-daemon false-tick, the dead CMOS battery — under the `POL-0001` R-A1 evidence rule, and cross-references `POL-0005`/`POL-0007`. |
