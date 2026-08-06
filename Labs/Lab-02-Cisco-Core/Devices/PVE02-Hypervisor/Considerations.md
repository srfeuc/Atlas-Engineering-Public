---
Title: PVE02 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor
Status: 🟠 LIVING — open risks/decisions on the EQR6 hypervisor (target-state). Facts linked to owners (POL-0008). Nothing device-verified — PVE02 not stood up (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# PVE02 — Considerations (open risks & decisions)

> The "what could bite us" list for the EQR6 hypervisor — separate from the procedure (`../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`) and the (future) read-backs. 🔴 **PVE02 is not built** — everything here is a design/plan risk (`POL-0001`). Facts linked to owners (`POL-0008`).

## Decided (this host — `ADR-0049` ask-at-planning; owner decisions carried from #20)
- **Tier = always-on critical** (`ADR-0036` v1.2, operator 2026-07-29). Quiet, low-power, WoL → the 24/7 host for identity/PKI/secrets/backup + bulk storage. The R410 is the mostly-off spin-up tier.
- **Standalone — no Proxmox cluster** (`ADR-0046`). A 2-node cluster needs a QDevice and would sit degraded with the R410 mostly off. VMs move by PBS backup-restore or `qm remote-migrate`.
- **Networking mirrors PVE01 exactly** (`ADR-0034`) — tagged `vmbr0.10`, native 999, `bridge-vids 10–90,999`. The switch-side trunk is owned by the SW01 page-set (add PVE02's port there).
- **Mgmt address `10.10.0.11/27` VLAN 10** (📋 proposed, IP plan owns) — deconflicted in the #20 VLAN-10 static map (`.1` MKT01 · `.2` SW01 · `.5` WAC · `.6` Pi01 · `.7` PFSENSE01 · `.8` PAW · `.10` PVE01 · `.11` PVE02).
- **DC01 moves here off the R410** (`ADR-0036` v1.2) — the always-on tier + a sane host clock (vs `CM-0012`) for the estate's time authority (`ADR-0020`).

## Open gates / prerequisites (🔴 — gate the build)
- 🔴 **64 GB RAM is a hard prerequisite** (`ADR-0036`). The EQR6 ships with **32 GB**; the always-on stack is ~44 GB (#20 budget) → it overruns 32 GB with no headroom. Install **2× 32 GB DDR5-4800 SODIMM (64 GB, EQR6 ceiling)** before it carries the tier. *Verdict:* 64 GB holds the full ~44 GB set (~20 GB headroom); swing candidates if squeezed = PAW01 then RDS01 to the R410.
- 🔴 **Single-8 TB SPOF + off-site copy is mandatory.** FS01 shares **and** the BKP01 datastore **and** Vaultwarden's store all land on **one external USB drive on one host**. If it dies you lose file shares, the backup datastore, *and* the vault's store at once. Mitigations: (1) 🔴 the **encrypted off-site copy** (`ADR-0009`/`ADR-0013`) is the real recovery guarantee — non-negotiable + must be **restore-tested** (the never-run Game Day, `POL-0005`); (2) strongly consider putting the **BKP01 datastore on a dedicated 2nd NVMe** (`ADR-0036` flags adding one) rather than sharing the 8 TB with FS01. *(Owner: `../../Service-Server-Build-Plan.md` single-8 TB note + `../BKP01-Backup/`.)*
- 🔴 **DC migration = USN-rollback trap** (`221` Phase 4). Clean-shutdown PBS backup only; **never restore an old DC snapshot** (PBS preserves the VM-GenerationID, which lets AD detect a legitimate restore). DC02 is the safety net during the window; pick one authority.

## Standing risks (design / hardware)
- 🔴 **No iDRAC / no out-of-band console** (unlike the R410). The console is **HDMI + keyboard at the unit**. **WoL + Auto-Power-On** give remote power-on + auto-recovery after an outage (a real bonus, partly offsetting PVE01's OOB gap), but there is **no remote console** — a failed boot needs physical access. No shared-LOM trap either (the R410's `CM-0011`), so it's a cleaner story, just not remote.
- 🟡 **Dual 1GbE only (no 2.5/10 GbE).** Fine for VM + mgmt traffic (dual NICs can split mgmt vs VM/storage). 🔴 **But S2D (`ADR-0046`) wants ≥10 GbE** — on 1 GbE, S2D teaches the mechanics but is slow. Options: USB-C → 2.5/5GbE adapter, the iSCSI-on-FS01 fallback, or accept slow-S2D as a documented lab limit.
- 🟡 **Confirm every spec on the live unit** (`POL-0001`) — CPU/NIC count/RAM/NVMe from the Amazon product sheet (`B0GYDH222T`) are the **plan**; read them back at install. The clean device-verified PVE02 Build-Guides/Records come from the fresh install.
- 🟡 **The whole estate's identity/PKI/secrets concentrate here** once the always-on tier lands — the off-site copy + DC02 cold-standby are the blast-radius mitigations; nothing always-on may depend on the mostly-off R410.

## Open decisions (need a call / detail when reached)
- **Dedicated 2nd NVMe for the BKP01 datastore** — buy + install a large 2nd M.2 (each slot → 4 TB) so backups don't share the 8 TB with FS01. Recommended before BKP01 holds real backups (`ADR-0036`).
- **NIC split** — whether to dedicate one 1GbE to mgmt and one to VM/storage, and whether to add the USB-C 2.5/5GbE adapter for the storage link (ties to the S2D decision).
- **CNT01 Linux git/CI slice always-on-vs-spin-up + Gitea-vs-GitLab** — owned by the still-owed **#19** estate-capability ADR, not decided here (budget check: even GitLab ~8 GB always-on keeps the EQR6 under 64 GB).

## Related
- `Roadmap.md` · `Build-Guide.md` (→ `221`) · `../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md` · `../../Virtualization/Build-Records/PVE01-Networking.md` (mirror) · `../../Service-Server-Build-Plan.md` (RAM budget + single-8 TB SPOF) · `00-Atlas-Foundation/Decisions/ADR-Index.md` (ADR-0036/0046/0009/0020).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — Decided (tier=always-on, standalone-no-cluster, networking-mirrors-PVE01, mgmt `.11`/VLAN 10, DC01-moves-here); open gates (🔴 64 GB prereq, 🔴 single-8 TB SPOF + mandatory off-site copy, 🔴 DC USN-rollback trap); standing risks (no-iDRAC/HDMI console + WoL offset, dual-1GbE/S2D, confirm-specs-on-unit, identity concentration); open decisions (dedicated 2nd NVMe, NIC split, CNT01 slice → #19). All target-state (`POL-0001`). Facts linked to owners (`POL-0008`). |
