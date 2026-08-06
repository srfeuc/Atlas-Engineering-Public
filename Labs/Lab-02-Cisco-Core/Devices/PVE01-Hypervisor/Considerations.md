---
Title: PVE01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor
Status: 🟠 LIVING — open risks/decisions on the R410 hypervisor. Closed items → the Virtualization Build-Records / Change Log. Facts linked to owners (POL-0008).
Version: 0.1
Date: 2026-07-30
---

# PVE01 — Considerations (open risks & decisions)

> The "what could bite us" list for the R410 hypervisor — separate from the procedure (`../../Virtualization/Build-Guides/`) and the read-backs (`../../Virtualization/Build-Records/PVE01-Diagnostics.md`). Facts linked to owners (`POL-0008`).

## Decided (this host — `ADR-0049` ask-at-planning)
- **Tier = spin-up heavy, mostly-off** (`ADR-0036` v1.2, operator 2026-07-29). The R410 is loud/power-hungry → it runs the heavy/on-demand tier; the quiet EQR6 is always-on. 🔴 **Consequence:** nothing always-on may **depend** on a VM hosted here — DC02 is cold-standby, the failover cluster is on-demand.
- **Standalone — no Proxmox cluster** (`ADR-0036`). Two standalone hosts; a 2-node cluster needs a QDevice for quorum and would sit degraded with the R410 mostly off. VMs move by **backup-restore or `qm remote-migrate`**.
- **Networking has one authoritative home** (`ADR-0034`, `POL-0008`) — the Virtualization Build-Record, **not** this folder. This device folder is the front door; it never restates the bridge/VLAN config.
- **DC01 moves off the R410 to the EQR6** (`ADR-0036` v1.2) — the R410's dead CMOS (`CM-0012`) is a poor home for the estate's authoritative time source (`ADR-0020`); the `221` runbook executes the move.

## Open gates / live gaps (`POL-0001` — device is truth)
- 🔴 **`CM-0011` — iDRAC on shared LOM + factory-default credentials.** iDRAC (`10.10.0.100/24`) **rides `eno1`'s cable on `Gi1/0/4`** — NOT a separate port, NOT out-of-band; it dies when SW01 is wiped (step 1 of any teardown). **The physical console is the real bootstrap.** Factory-default iDRAC creds were **never changed** (a real security gap). The R410 has an **unused dedicated iDRAC port** (future OOB option). Owner: `Changes/` (`CM-0011`).
- 🔴 **`CM-0012` — CMOS/RTC battery physically dead** (`ADR-0017` defer). New CR2032 (2026-07-16) but durability RE-TEST FAILED — RTC resets `2026`→`2018` across a genuine power loss. **Keep on continuous power/UPS;** NTP holds the OS clock while running (`ADR-0020`). Physical replacement still outstanding. This is *why DC01 leaves the R410.*
- 🔴 **No backups of any VM, ever.** PBS on BKP01 is planned + unbuilt; a backup isn't real until a restore succeeds (`ADR-0011`/`POL-0005`). The `221` migration's PBS restore is the estate's **first real restore test** (the Game Day). Until then, PVE01's VMs are unprotected.
- 🟡 **GUI shell / noVNC broken** — VNC to `localhost:5900` refused in earlier records; **SSH is a full substitute** (diagnostic commands recorded). Re-verify before carrying forward.
- 🟡 **`bridge-vids` permanence** — ensure `bridge-vids 10–90,999` is persisted in `/etc/network/interfaces` and reconciled to live (`bridge vlan show`) after `ifreload -a` (`204` §3). An unpersisted set silently drops VM VLANs at the uplink.
- 🟡 **Proxmox global firewall `disabled/running`** — the per-VM `firewall=1` flags (9000/100/101) are **inert** as a result. Correct anywhere the pack describes the firewall as simply "Enabled" (`217-Verified-Facts`).

## Standing risks (design)
- 🔴 **DIMM population** — RAM relocated off faulty slot B1 to B3; verify against Dell's supported population for full triple-channel interleaving (a mis-populated set runs but slower).
- 🔴 **Single-host blast radius (historical)** — every estate VM once ran here; `ADR-0036` (the second host) exists to end that. Until PVE02 is stood up + the always-on tier migrated, a PVE01 loss is still estate-wide for anything not yet moved.
- 🟡 **No-subscription patch reverts** — `proxmox-widget-toolkit` updates overwrite the no-sub patch; re-apply after `apt upgrade` (needs a post-update hook).

## Open decisions (need a call / ADR when reached)
- **Dedicated OOB via the unused iDRAC port** — cable + configure the R410's real iDRAC NIC for out-of-band, closing the shared-LOM trap. Its own change when done.
- **Failover-cluster/S2D storage link** (`ADR-0046`) — 1 GbE-only limits S2D; USB-C 2.5/5GbE adapter vs iSCSI-on-FS01 vs accept slow-S2D — decided at the on-demand cluster build.

## Related
- `Roadmap.md` · `Build-Record.md` · `Build-Guide.md` (pointer) · `../../Virtualization/Build-Records/PVE01-Networking.md` (SoT) · `../../Virtualization/Build-Records/PVE01-Diagnostics.md` · `00-Atlas-Foundation/Decisions/ADR-Index.md` (ADR-0034/0036/0017/0046).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — Decided (tier=spin-up, standalone-no-cluster, networking-one-home `ADR-0034`, DC01-moves-off); open gates (`CM-0011` iDRAC shared-LOM + factory creds, `CM-0012` CMOS/RTC dead, no-VM-backups, GUI-shell broken, `bridge-vids` permanence, inert global firewall); standing risks (DIMM population, single-host blast radius, no-sub patch reverts); open decisions (dedicated OOB iDRAC port, S2D storage link). Facts linked to owners (`POL-0008`). |
