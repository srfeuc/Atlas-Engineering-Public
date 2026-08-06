---
Title: PVE02 — Roadmap (host build path + hosted VMs)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor
Status: 📋 TARGET-STATE — the host build path for the EQR6. Nothing device-verified (PVE02 not stood up). Mirrors the 221 runbook phases (POL-0001). Version bumps as stages land.
Version: 0.1
Date: 2026-07-30
---

# PVE02 — Roadmap (host build path + hosted VMs)

> **How to read this.** Each row is a **gated host build stage** on the EQR6 (`ADR-0043` — a phase starts only when its gate is met). 🔴 **All 📋/⬜ — PVE02 is not built.** The executable steps live in the **`221` runbook**; this Roadmap is the sequence + the dependency graph. **Needs** = healthy-first; **Unblocks** = what proceeds. The **VMs** this host will run are the always-on tier of `ADR-0036` v1.2.

## The host build path (in order) — mirrors the `221` runbook

### Phase 0 — 🔴 GATE: prerequisites — 📋
- [ ] 🔴 **64 GB RAM installed** (2× 32 GB DDR5-4800) — the `ADR-0036` hard prerequisite; the ~44 GB always-on stack overruns the stock 32 GB. *Unblocks:* everything.
- [ ] 📋 **8 TB external attached + healthy** (FS01 shares + PBS datastore). Consider a **dedicated 2nd NVMe** for the BKP01 datastore (separates the backup failure domain from FS01 — `ADR-0036`).
- [ ] 📋 **EQR6 clock + chrony set to the `ADR-0020` source** before any DC boots (a wrong host clock just relocates `CM-0012`).
- [ ] 📋 **New SW01 trunk port** — native 999, allowed 10–90,999, **DAI-trusted** (mirror `Gi1/0/4`; owned by the SW01 page-set).
- [ ] 📋 **BKP01/PBS reachable** + a datastore to receive backups. 📋 **Mandatory off-site copy path exists** (`ADR-0009`) before retiring any R410 source. 📋 **DC02 available** as fallback authority during the DC cutover.

### Phase 1 — EQR6 host bring-up — 📋
- [ ] 📋 Install **Proxmox VE 8.x**; hostname `pve02` / `pve02.lab`; no-subscription repo + updates.
- [ ] 📋 Create named admin **`seth-admin@pve`** (scope root per `206`). Add `local`/`local-lvm` + the **8 TB** datastore. **Join nothing** — standalone (`ADR-0046`). *Cert:* virtualization/Linux fundamentals.

### Phase 2 — Network (mirror PVE01's authoritative design) — 📋
- [ ] 📋 `vmbr0` VLAN-aware, `bridge-vids 10–90,999`, no L3 on bare `vmbr0`; **tagged `vmbr0.10` = `10.10.0.11/27`** 📋 (IP plan owns), gw `10.10.0.1`. Mirrors `../../Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`) exactly. *Gate:* `ping 10.10.0.1` 0% loss; `bridge vlan show` lists all VM VLANs tagged on the uplink. *Cert:* CCNA 802.1Q applied to compute.

### Phase 3 — Backup vehicle = the restore Game Day — 📋
- [ ] 📋 Stand up/confirm **PBS on BKP01** (datastore on the 8 TB); register PVE01 (source) + PVE02 (destination). 🔴 The migration **is** the estate's first real restore test (`ADR-0011`/`POL-0005`). *Gate:* one non-DC VM (e.g. SRV01) restored onto PVE02 + booted clean **before** touching DC01.

### Phase 4 — Migrate the always-on tier in dependency order — 📋
- [ ] 📋 **DC01 → ICA01 → NPS01 → SRV01 → Vaultwarden → FS01.** 🔴 **DC caveat:** clean-shutdown PBS backup only; **never restore an old DC snapshot** (USN-rollback — PBS preserves the VM-GenerationID). Time-first on DC01 (`w32tm`), then `dcdiag`/`repadmin`. *Needs:* Phases 0–3 green + DC02 healthy.

### Phase 5 — Cutover & verification — 📋
- [ ] 📋 Every migrated service answers (run each device's `Diagnostics.md`); auth end-to-end (domain login · NPS/RADIUS · ICA01 cert). Flip the always-on tier **live on EQR6**; power the R410 down to spin-up duty. Confirm the **off-site copy** covers the new EQR6 workloads before retiring R410 copies.

### Future / gated
- [ ] 📋 **Automation (Terraform/Ansible)** — `Automation/` slice (`ADR-0048`); the `221` migration is the IaC exercise. *Cert:* IaC / ENAUTO-adjacent.
- [ ] 📋 **Failover-cluster node + S2D** with PVE01 — the `ADR-0046` on-demand HA lab (power both up; 🔴 **1 GbE-only** storage → USB-C 2.5/5GbE adapter, iSCSI-on-FS01 fallback, or accept slow-S2D). *Gated stub.*

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | SW01 (new trunk) | 802.1Q trunk, native 999, DAI-trusted, VLANs 10–90,999 |
| ⬆ Depends on | MKT01 (`10.10.0.1`) | VLAN-10 mgmt gateway |
| ⬆ Depends on | 8 TB external · off-site copy | FS01 + PBS datastore · mandatory backup independence (`ADR-0009`) |
| ⬇ Serves | DC01 · ICA01 · NPS01 · SRV01 · BKP01 · Vaultwarden · FS01 · MON01 probe · RDS01 · WAC01 · PAW01 · CNT01 slice | the always-on tier it hosts (~44 GB / 64 GB, `ADR-0036` v1.2) |

## Certification alignment (learning lens)
| PVE02 stage | Exercises | Cert / skill |
|---|---|---|
| Proxmox install / standalone host | Type-1 hypervisor stand-up | Virtualization fundamentals (AZ-801 concepts transfer) |
| `vmbr0` VLAN-aware bridge + tagged mgmt | 802.1Q trunking on a host | CCNA (VLANs/trunks) applied to compute |
| PBS backup → restore (the Game Day) | backup/restore, DR, USN-rollback avoidance | AZ-801 (backup/DR) · `POL-0005`/`ADR-0011` |
| dependency-ordered migration | service dependency mapping, cutover | systems engineering / change control |
| failover cluster + S2D (future) | clustering / software-defined storage | AZ-801 (failover clustering/S2D) |

## Related
- Procedure: `../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`. Networking model: `../../Virtualization/Build-Records/PVE01-Networking.md`. As-built (empty until built): `Build-Record.md`. Open risks: `Considerations.md`.
- Owners: `../../Service-Server-Build-Plan.md` (placement/sizing + 64 GB budget) · `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../SW01-Access-Switch/` (the switch-side trunk) · `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — the target-state host build path for the EQR6, mirroring the `221` runbook phases: Phase 0 prerequisites gate (🔴 64 GB, 8 TB, clock, SW01 trunk, PBS+off-site+DC02), Phase 1 install, Phase 2 network (mirrors `PVE01-Networking`), Phase 3 PBS restore = Game Day, Phase 4 dependency-order migration (DC USN-rollback method), Phase 5 cutover, future automation + failover-cluster. All 📋/⬜ (`POL-0001`). Cert-aligned. |
