# ADR-0036 — Atlas Compute Topology: A Second Proxmox Host + VM Placement Strategy

| Item | Value |
|---|---|
| Status | **Accepted as the target topology** (operator, 2026-07-28). ✅ **PVE02 ACQUIRED 2026-07-29** — Beelink **EQR6** (Ryzen 9 6900HX); closes decision **A4**. Execution now staged on *standing it up* (not acquiring). |
| Governing Policy | POL-0008 (+POL-0013) |
| Scope | **Lab-02-Cisco-Core** (the compute estate) |
| Date | 2026-07-28 (PVE02-acquired update 2026-07-29) |
| Supersedes | — Extends `ADR-0001` (PVE01) with a multi-host placement model. Closes register **A3a** (Vaultwarden host = BKP01) + **A4** (PVE02 acquired). **Lifts the PVE02 build-gate on `ADR-0046`** (the 2-node cluster now has its second physical host). |
| Related | `ADR-0021` (tiered identity — why DCs/CA blast radii are split), `ADR-0027` (CA off the DCs), `ADR-0031` (Vaultwarden survives standalone), `ADR-0009` (secrets custody / backup survivability), `ADR-0046` (2-node failover cluster — was gated on PVE02), `CM-0012` (PVE01 board fault — a live single-host risk). |
| Evidence Status | **Decision / plan.** PVE01 capacity is device-verified (62 GiB usable, ~793 GiB). **PVE02 = acquired hardware (EQR6), not yet stood up** — Proxmox install + VLAN join + migration are the open build steps. |

## Context

Today **every Atlas VM runs on PVE01** (Dell R410, 62 GiB usable) — a **single point of failure for the entire estate**, made sharper by `CM-0012` (the PVE01 board/CMOS fault, unresolved). If DC02 is co-located with DC01, a PVE01 failure takes down **both** domain controllers, the CA, DNS, DHCP, RADIUS, monitoring, and — if Vaultwarden lives there — the secrets vault and its DB. That is the opposite of the redundancy the tiered/replica design is *supposed* to buy: a second DC on the same host is not fault tolerance, it's two eggs in one basket.

The operator **has acquired a second Proxmox host (PVE02)** — a Beelink **EQR6** (2026-07-29, closes A4) — and can additionally run **Hyper-V VMs on a home PC**. This ADR sets *how to split the estate across them* so the hardware actually buys availability, and records Vaultwarden's placement (register **A3a**).

### PVE02 — the acquired hardware (2026-07-29)

**Beelink EQR6 — AMD Ryzen 9 6900HX** (8C/16T, Zen3+, up to 4.9 GHz, 16 MB L3; Radeon 680M 12-core iGPU), **32 GB DDR5-4800 dual-channel (2× SODIMM, expandable to 64 GB)**, **500 GB M.2 PCIe 4.0 ×4 NVMe (2× M.2 2280 slots, each expandable to 4 TB)**, **dual 1000 Mbps LAN (2× 1GbE)**, **1× USB-C 10 Gbps** + 3× USB3 10 Gbps, WiFi 6 / BT 5.2, 2× 4K@60 HDMI, **built-in PSU (no brick)**, **Wake-on-LAN + Auto-Power-On**. Purchased via Amazon (listing `B0GYDH222T`); specs from the operator-provided product sheet (2026-07-29) — confirm the live unit at Proxmox install (`POL-0001`).

Fit vs the estate need (honest):
- ✅ **Power / reliability / budget** — low idle, integrated PSU, well under the $500–700 target. **Wake-on-LAN + Auto-Power-On** are a real bonus: remote power-on and auto-recovery after an outage partly offset PVE01's out-of-band gap (`CM-0012`/`050`).
- ✅ **CPU** — 8C/16T is ample for PVE02's assigned load (DC02 + BKP01/Vaultwarden + PAW01 + a cluster node).
- ✅ **Two M.2 NVMe slots (to 4 TB each)** — lets **BKP01's datastore live on its own drive**: add a 2nd NVMe (a large one) rather than sharing the 500 GB boot drive. Do this before BKP01 holds real backups.
- 🔴 **RAM is the constraint (as flagged in the recommendation).** 32 GB is tight for PVE02's Windows-heavy load once the failover-cluster node lands. **Recommend upgrading to 64 GB (2× 32 GB DDR5-4800 SODIMM, ~$90)** — 64 GB is the EQR6's ceiling (below the MS-01's 96 GB, but enough for PVE02's role since PVE01/R410 carries the heavy tier).
- 🟡 **Networking is dual 1GbE, not 2.5/10 GbE.** Fine for VM + mgmt traffic, and dual NICs let you separate mgmt vs VM/storage. **But S2D (`ADR-0046`) really wants ≥10 GbE for storage replication** — on 1 GbE, S2D teaches the *mechanics* but is slow. Two mitigations: (a) the **USB-C 10 Gbps** port can host a **USB → 2.5GbE (or 5GbE) adapter** for a faster storage link, or (b) lean on the `ADR-0046` fallback (**iSCSI-on-FS01**), or (c) accept slow-S2D as a documented lab limitation. Recorded as an `ADR-0046` build-time note.

## Decision

**Atlas becomes a multi-host estate: PVE01 + PVE02 (Proxmox) + optional home-PC Hyper-V. VMs are placed by blast-radius and recovery independence, not convenience.**

> 🔄 **Placement model revised 2026-07-29 (operator) — tier by *uptime*, now that PVE02 (EQR6) is the low-power always-on box.** The original model made the **R410 (PVE01) the primary tier**; the operator has inverted that: the **EQR6 is quiet, low-power, Wake-on-LAN, and stays on 24/7 → it is the always-on critical tier**, and the **R410 is loud/power-hungry → it becomes the spin-up-when-needed heavy-compute tier** (mostly off). Two consequences the operator accepted: (1) **DC02 and the failover cluster (`ADR-0046`) are spin-up / on-demand, not continuous HA** — so nothing always-on may *depend* on them; (2) the EQR6's always-on stack must be **self-sufficient**, which makes the **64 GB RAM upgrade a prerequisite, not a nicety**.

### Placement principles (the "how to split it" rationale)
0. **Tier by uptime (2026-07-29).** The **always-on critical tier runs on the low-power EQR6 (PVE02)** and must be self-sufficient; the **spin-up heavy tier runs on the R410 (PVE01)**, powered on for heavy labs / the cluster exercise / DC02 replication windows. This *inverts* the original "R410 = primary" framing.
1. **Identity redundancy across *physical* hosts.** DC01 (always-on, EQR6) and DC02 (R410) sit on **different hosts**. With the R410 mostly off, **DC02 is a cold-standby replica** brought up for replication + the HA lab — a documented lab trade-off (a live EQR6 loss with the R410 off = no live DC until the R410 is powered on). Acceptable at lab scale; the off-site backup is the real recovery guarantee.
2. **Backup independence = the off-site copy (revised).** BKP01's datastore lives on the **8 TB external attached to the EQR6** (operator, 2026-07-29) — i.e. *on the same host it protects*, which strict independence forbids. The independence is therefore the **mandatory scheduled off-site copy** (`ADR-0009` — encrypted, rotated, with a destroy step): if the EQR6 dies, the off-site copy restores it. **The off-site copy is now a hard requirement, not optional.**
3. **Secrets survive a host loss.** Vaultwarden (CA passphrases, DSRM, break-glass per `ADR-0009`) runs on the always-on EQR6 (rides BKP01, A3a) and survives an EQR6 loss **via the off-site backup**. TLS cert from AD CS (ICA01), reached by web console (`ADR-0031`).
4. **Tier-0 stays on trusted infrastructure.** DCs, the CA, and **PAW01** run on the Proxmox hosts (Tier-0-clean), **never** the home PC. PAW01 → the always-on EQR6 so Tier-0 admin is reliably reachable. RCA01 (offline root) is powered off except for ceremonies — host-agnostic.
5. **The home PC is for non-critical / experimental / cert work only.** Lab clients, the **AD FS + WAP** build (Tier B, DMZ), later **MSP-sim tenant** DCs, **AZ-802 Hyper-V** exercises. Nothing Tier-0 or production-critical.
6. **Bulk storage on the 8 TB external (EQR6).** Spinning USB is right for **FS01 file shares** + the **BKP01 backup datastore** (high capacity, modest IOPS); it is **not** for VM boot disks or S2D (those stay on the internal NVMe). FS01 therefore moves to the EQR6 (revises decision **A1**, which had it on PVE01).

### Target placement (revised 2026-07-29)

| Host | Hardware | Runs | Why |
|---|---|---|---|
| **PVE02** ⭐ **always-on core** | ✅ **Beelink EQR6** — Ryzen 9 6900HX, **32→64 GB** (upgrade first), 500 GB NVMe (2× M.2) + **8 TB external** | **DC01** (DNS/DHCP), **ICA01** (issuing CA), **NPS01**, **SRV01**, **Vaultwarden**, **FS01** (shares on the 8 TB), **BKP01 datastore** (on the 8 TB), **MON01 probe** (Uptime-Kuma + light syslog — always-on watch of this tier) | Low-power, quiet, WoL, 24/7 → everything that must never be down + bulk storage. |
| **PVE01** — spin-up heavy tier | Dell R410 (62 GiB) — **mostly off**, powered on for heavy work | **DC02** (cold-standby replica), **MON01 heavy stack** (LibreNMS/NetFlow/Suricata/Grafana), **NETBOX01**, the **failover-cluster node + S2D** (`ADR-0046`), big-RAM lab VMs | Loud/power-hungry → run on demand: the HA-cluster exercise, the heavy monitoring/matrix work, big labs, DC02 replication windows. |
| **Home-PC Hyper-V** | personal workstation | Lab **clients/test VMs**, **AD FS + WAP** (Tier B), later **MSP-sim tenants**, **AZ-802 Hyper-V** labs | Non-critical, experiment-friendly, cert-relevant. |
| **Pi01** | Raspberry Pi (physical) | Pi-hole DNS + chrony NTP | Already physical; unchanged. |

> **RAM budget check (EQR6):** the always-on stack (DC01 · ICA01 · NPS01 · SRV01 · Vaultwarden · FS01 · BKP01 + Proxmox overhead) is ~28–30 GB — it **overruns 32 GB with no headroom**, so **64 GB is a prerequisite** before PVE02 carries this load. PAW01 can ride the EQR6 too within 64 GB, or spin up with the R410 if headroom is tight.

### Staged rollout (PVE02 acquired 2026-07-29 — now the *primary* build target)
- **First: prep the EQR6 hardware.** Add the **64 GB RAM kit** (prerequisite for the always-on stack) + a **2nd NVMe** if wanted, and **attach the 8 TB external** (FS01 + BKP01 datastore).
- **Stand up PVE02:** install Proxmox → join the mgmt VLAN (tagged VLAN 10) → **build the always-on core here** (DC01, ICA01, NPS01, SRV01, Vaultwarden, FS01, BKP01). If any of these were built on PVE01 first, **migrate them to the EQR6** (backup-restore or `qm remote-migrate`). Gets a `Devices/PVE02-Hypervisor/` (or Virtualization Build-Record) page-set + an `Automation/` folder (`ADR-0048`).
- **R410 spins up on demand:** for the failover-cluster/S2D exercise (`ADR-0046`), MON01/NetBox, big-RAM labs, and DC02 replication windows. Powered off otherwise (power/noise).
- **Off-site backup is a hard requirement** (principle 2): schedule the encrypted off-site copy of BKP01 + the CA/secrets archive (`ADR-0009`) — it is the real independence now that backups are local to the EQR6.
- **Cluster or not (Proxmox layer):** a 2-node Proxmox cluster needs a **third quorum vote** (QDevice). **Run the two hosts standalone** (no Proxmox cluster) at this scale — and note the R410 is mostly off anyway, so a Proxmox cluster would sit degraded. Manual migrate (backup/restore or `qm remote-migrate`) is fine. *(This is the **Proxmox** layer; the **Windows** failover cluster of `ADR-0046` is a separate, on-demand lab.)*

## Alternatives Considered
- **Stay single-host (PVE01 only).** Rejected — `CM-0012` makes it a live risk and a "second DC" on one host is theatre.
- **Two-node Proxmox cluster with HA.** Deferred — needs a QDevice for quorum; overkill for two hosts. Standalone + manual migrate is enough.
- **Put PAW01 / Tier-0 on the home PC.** Rejected — Tier-0 must stay on trusted, always-on infrastructure (principle 4).
- **Vaultwarden its own VM.** Considered (cleanest isolation) but operator chose **BKP01 co-location** — acceptable: both are recovery-critical and land on PVE02, satisfying principles 2 + 3.

## Consequences
- **`IP-Addressing-Plan-VLSM`:** assign **Vaultwarden/BKP01** an address (proposed **`10.20.0.13`** for Vaultwarden's web console; BKP01 host also VLAN 20) — authoritative value owed to the plan.
- **A new host doc** `Devices/PVE02-Hypervisor/` (or a Virtualization Build-Record) when PVE02 is acquired.
- **Placement + sizing authority (settled in the #20 sweep, 2026-07-30):** the **interim single source for _which physical host each VM runs on and how big it is_** is **`Labs/Lab-02-Cisco-Core/Service-Server-Build-Plan.md`** (its Physical-host column + the EQR6 RAM budget), until **NetBox** renders it. **This ADR states the _principle_** (tier-by-uptime + blast-radius) **and the initial split**; the per-VM decision is recorded and kept current in that plan. **`VM-and-Services-Inventory` is RETIRED** (PVE01-only, generic names, no host column) — it does **not** gain a host column; it is not a placement or sizing source.
- **Both hypervisor _hosts_ are managed on VLAN 10.** PVE01 `10.10.0.10` (`ADR-0034`) and **PVE02/EQR6 `10.10.0.11`** (📋 proposed) are hypervisor **management** interfaces on VLAN 10; the VMs they run are VLAN-20/40/etc. workloads (`IP-Addressing-Plan-VLSM` v1.9 registers both).
- **`Device-Backup-Runbook`:** the backup design is now **local datastore on the 8 TB (EQR6) + a mandatory off-site copy** (`ADR-0009`) — the off-site copy is the independence, since local backup co-locates with what it protects. Closes part of the "no backups anywhere / never restore-tested" risk *only once the off-site copy + a restore test exist* (Backlog Tier-1 #1).
- **Decision A1 revised:** **FS01 moves to PVE02** (on the 8 TB external), not PVE01 as A1 originally placed it. WSUS01/SQL01/RDS01's placement is revisited against the new uptime tiers (always-on vs spin-up) when each is scoped.
- **Register:** **A3a → CLOSED** (Vaultwarden = BKP01, on PVE02/EQR6); **A4 → CLOSED / ✅ ACQUIRED** (Beelink EQR6, 2026-07-29). `CM-0012` (PVE01 OOB gap) becomes **lower-priority** — the estate's *always-on* tier is now the EQR6 (which has WoL), and the R410 is intentionally mostly-off.
- **`ADR-0046` (2-node failover cluster) — build-gate LIFTED but re-scoped to on-demand:** PVE02 provides the 2nd physical host, but since the R410 is mostly off, the cluster is a **spin-up HA lab** (power both hosts up for the exercise), **not continuous HA** — nothing always-on may depend on it. Build-time notes: the EQR6's **1GbE-only storage network** (S2D wants ≥10 GbE → USB-C 2.5/5GbE adapter, the **iSCSI-on-FS01 fallback**, or accept slow-S2D for learning) + the RAM headroom on the EQR6 node.
- **Prerequisite hardware:** the **64 GB RAM kit** (2× 32 GB DDR5-4800) is now a **prerequisite** before PVE02 carries the always-on stack (not merely recommended); the **8 TB external** (owned) serves FS01 + BKP01; a larger 2nd NVMe is optional.
- **Roadmap:** milestone becomes "**prep + stand up PVE02 (EQR6) as the always-on core; R410 → spin-up tier**"; the AD FS+WAP (Tier B) and MSP-sim phases have a home (home-PC Hyper-V).

## Review Trigger
- If live-migration / automatic HA becomes a real requirement → revisit clustering (+ QDevice).
- If a **third** host or real storage (shared/NFS/Ceph) enters → revisit placement.

## Change Log
| Version | Changes |
|---|---|
| 1.3 | 2026-07-30. **#20 sweep — authority + drift reconciliation (no change to the placement _decision_).** Named **`Service-Server-Build-Plan.md` the interim single source for host placement + VM sizing** (this ADR keeps the principle + initial split); **`VM-and-Services-Inventory` RETIRED** (removed the stale "gains a host column" consequence). Recorded **both hypervisor hosts on VLAN 10** (PVE01 `10.10.0.10`, PVE02/EQR6 `10.10.0.11` 📋). **Reaffirmed principle 1 against an index drift:** the estate index had briefly placed **DC02 on PVE02** (co-locating both DCs) — corrected back to **PVE01/R410 cold-standby** (DCs on different physical hosts); **ICA01 + SRV01** reconciled onto the EQR6 always-on tier where this ADR already placed them. EQR6 RAM budget re-run in the index: 64 GB holds the full always-on set (incl. RDS01/WAC01/PAW01). |
| 1.2 | 2026-07-29. **Placement model inverted + storage/backup model (operator).** The low-power, always-on **EQR6 (PVE02) becomes the always-on critical tier** (DC01 · ICA01 · NPS01 · SRV01 · Vaultwarden · FS01 · BKP01); the loud **R410 (PVE01) becomes the mostly-off spin-up heavy tier** (DC02 cold-standby · MON01 · NetBox · the cluster node · big-RAM labs). Added principle 0 (tier by uptime) + principle 6 (bulk storage). An **8 TB external on the EQR6** serves **FS01 + BKP01 datastore** → **backup independence is now the mandatory off-site copy** (`ADR-0009`), since backups co-locate. **FS01 moves to PVE02** (revises A1). **64 GB RAM = prerequisite** (always-on stack ~28–30 GB overruns 32 GB). **DC02 + the `ADR-0046` cluster are on-demand/spin-up, not continuous HA** — nothing always-on may depend on them. Rewrote the placement table, principles, staged rollout, and consequences. **MON01 is split** (operator, 2026-07-29, during the MON01 page-set build): the **light always-on probe** (Uptime-Kuma + minimal syslog) on the EQR6 watches the always-on tier, the **heavy stack** (LibreNMS/NetFlow/Suricata/Grafana) on the R410 spins up for active sessions + the Phase-7 matrix. |
| 1.1 | 2026-07-29. **PVE02 ACQUIRED — closes A4.** Recorded the hardware: **Beelink EQR6** (Ryzen 9 6900HX 8C/16T, 32 GB DDR5-4800 → 64 GB via 2× SODIMM, 500 GB NVMe with **2× M.2 slots to 4 TB each**, **dual 1GbE**, USB-C 10 Gbps, WiFi 6, built-in PSU, **Wake-on-LAN + Auto-Power-On**; Amazon `B0GYDH222T`). Added a fit assessment (✅ CPU/power/storage-slots; 🔴 upgrade RAM to 64 GB; 🟡 dual-1GbE limits S2D — USB-C 2.5/5GbE adapter or iSCSI-on-FS01 fallback). Updated Status/placement-table/staged-rollout to *stand-it-up* (not acquire); added PVE02 as the failover-cluster's 2nd physical host → **lifts the `ADR-0046` build-gate**. Recommended follow-on: 64 GB kit + a 2nd NVMe for BKP01. |
| 1.0 | 2026-07-28. Accepted as the target topology. Atlas goes multi-host: **PVE01** (core identity+services) + **PVE02** (to acquire — DC02, BKP01+Vaultwarden, PAW01, RCA01) + optional **home-PC Hyper-V** (non-critical/experimental/AZ-802/AD FS labs). Placement by blast-radius: DCs on different hosts, backup+secrets off the host they protect, Tier-0 off the home PC. Vaultwarden → BKP01 (closes register A3a). Staged: build on PVE01 now, migrate DC02/BKP01/Vaultwarden to PVE02 when it lands; **standalone hosts, no cluster** (avoids quorum fragility; manual migrate). |
