---
Title: PVE02 (EQR6) Bring-Up and VM Migration off the R410 — Runbook
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
Status: 📋 TARGET-STATE runbook — the machine is planned, not built (`POL-0001`). Phased/gated (`ADR-0043`). Every step is ⬜ until executed + evidenced. Operator ask 2026-07-30 ("act as if EQR6 is already here — plan the update / VM migration").
Version: 0.1
Date: 2026-07-30
---

# PVE02 (EQR6) Bring-Up and VM Migration off the R410 — Runbook

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **PVE02** (Beelink **EQR6** mini-PC hypervisor, `ADR-0036` v1.1/v1.2). Role: **the low-power always-on critical-tier Proxmox host.** Companion "why" module: `Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (**V1**).

> 🔴 **Nothing here is device-verified.** PVE02 does not exist yet; this is the **plan**, written so a rebuild session can execute it top-to-bottom. Verify every value on the unit before trusting it (`POL-0001`). The `#21` sweep turns PVE01/PVE02 into full `Devices/` folders; this runbook is the migration procedure that sweep will reference.

> **Note on sources (carry-over).** The R410-era **`2xx` Virtualization Build-Guides predate Atlas conventions — some are pre-Atlas carry-over.** Treat them as *historical procedure*, not current truth. The authoritative current state is **`Build-Records/PVE01-Networking.md`** (`ADR-0034`) + the **SW01 device page-set** (which owns the switch-side trunk/DAI config). The **clean, device-verified PVE02 Build-Guides and Build-Records get written during the fresh install** (`#21` — "document everything"); this runbook is the **target-state plan** they will flesh out and supersede.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering (Virtualization book) |
| Status | 📋 **Target-state / planned.** Gated (`ADR-0043`); ⬜ until executed. |
| Version | 0.1 |
| Applies To | **PVE02** (EQR6) — the destination; **PVE01** (R410) — the source. |
| Governing | `ADR-0036` (compute topology / VM placement — the always-on/spin-up split), `ADR-0046` (standalone; cluster on-demand only), `ADR-0020` (authoritative time — why the DC leads), `ADR-0011`/`POL-0005` (a backup is not real until a restore succeeds), `ADR-0009`/`ADR-0013` (backup independence / off-site), `ADR-0034` (PVE networking SoT), `POL-0001` (evidence), `POL-0008` (one home). |

## Purpose

Stand up the second hypervisor (EQR6) and relocate the **always-on critical tier** off the aging R410 — with each workload's identity and state intact, in dependency order, using a backup-and-restore path that doubles as the estate's first real restore test. The move also **fixes a root cause**: the R410's CMOS/RTC durability failure (`CM-0012`) is a poor home for a Domain Controller, which is the estate's authoritative time source (`ADR-0020`).

**Target placement (`ADR-0036` v1.2):**

| Tier | Host | VMs |
|---|---|---|
| Always-on critical | **PVE02 / EQR6** | DC01 · ICA01 · NPS01 · SRV01 · Vaultwarden · FS01 · BKP01 |
| Mostly-off spin-up | **PVE01 / R410** | DC02 (cold-standby) · MON01 · NetBox · lab / cluster node |

## PVE02 target facts (📋 proposed — verify on the unit; `#20` owns sizing/addressing)

| Item | Planned value | Note |
|---|---|---|
| Hardware | Beelink **EQR6** mini-PC (`ADR-0036` v1.1) | Confirm CPU / NIC count on the unit; **64 GB RAM is the prerequisite** (`ADR-0036`). |
| Proxmox VE | Latest PVE 8.x | Match/lead PVE01's `8.4.19`. |
| Hostname / FQDN | `pve02` / `pve02.lab` | **Standalone, not domain-joined** — a hypervisor on the mgmt plane (`.lab`, like PVE01). |
| Management | **tagged `vmbr0.10`**, `10.10.0.11/27` 📋 | Mirror PVE01's tagged-VLAN-10 design; **IP is proposed — the IP plan owns it**, deconflict against WAC01 `.5` / PAW in `#20`. |
| Gateway | `10.10.0.1` | Management `/27` (`10.10.0.0/27`). |
| Bridge | `vmbr0`, VLAN-aware, `bridge-vids 10,20,30,40,50,60,70,80,90,999` | Identical model to PVE01 (`Build-Records/PVE01-Networking.md`). |
| Datastore | `local` / `local-lvm` + the **8 TB external** for **PBS + FS01** | `ADR-0036` v1.2 (8 TB → FS01 + BKP01). |
| Named admin | `seth-admin@pve` | Same non-root admin model as PVE01 (`206`). |
| Cluster | **None** (standalone) | `ADR-0046` — cluster is on-demand only (1 GbE / S2D caveat). |

---

## Phase 0 — 🔴 GATE: prerequisites before any VM moves

- [ ] EQR6 in hand with **64 GB RAM** installed (`ADR-0036` prerequisite).
- [ ] 8 TB external attached and healthy.
- [ ] EQR6 **BIOS clock + host chrony/NTP set to the `ADR-0020` source** *before* any DC boots — moving a DC onto a host with a wrong clock just relocates the `CM-0012` problem.
- [ ] SW01 has a **new trunk port for PVE02** — native **999**, allowed `10–90,999`, and **DAI-trusted** (mirror `Gi1/0/4`; see Phase 2). Coordinate with `SW01/Build-Guide.md`.
- [ ] **BKP01/PBS reachable** and a datastore exists to receive backups (Phase 3).
- [ ] A **mandatory encrypted off-site copy** path exists (`ADR-0009`/`ADR-0013`) — do not decommission the R410 copy of anything until the off-site copy is confirmed.
- [ ] **DC02 (cold-standby) is available** as the fallback domain authority during the DC cutover.

🔴 **Do not proceed past this gate until every box is checked.**

## Phase 1 — EQR6 host bring-up

1. ⬜ Install Proxmox VE (latest 8.x) on the EQR6; set hostname `pve02` / FQDN `pve02.lab`.
2. ⬜ Convert the enterprise repo to the **no-subscription** repo; `apt update && apt full-upgrade` (re-apply the no-sub widget patch after updates — same R410 deviation).
3. ⬜ Create the **named admin** `seth-admin@pve` (PVE realm), scope root per `206`; do not administer as root.
4. ⬜ Storage: keep `local` / `local-lvm`; add the **8 TB external** as a directory/ZFS datastore for **PBS** + the **FS01** data disk (`ADR-0036` v1.2).
5. ⬜ **Join nothing** — PVE02 stays standalone (`ADR-0046`). A cluster is only formed on-demand, and the 1 GbE / S2D caveat still applies.

🔴 **GATE (Phase 1):** `pveversion`, `pvesh get /nodes/pve02/status`, and the 8 TB datastore visible in `pvesm status`; named-admin login works; root is scoped. Record read-backs in a PVE02 Build-Record (`#21`).

## Phase 2 — Network (mirror the PVE01 authoritative design)

The single source for the PVE networking model is `Build-Records/PVE01-Networking.md` (`ADR-0034`). PVE02 copies it exactly — **tagged management, native 999**:

1. ⬜ `vmbr0` = VLAN-aware bridge on the EQR6 primary NIC; `bridge-vids 10,20,30,40,50,60,70,80,90,999`; **no L3 on bare `vmbr0`**.
2. ⬜ `vmbr0.10` = **tagged VLAN 10** host management, `10.10.0.11/27` 📋 (proposed — IP plan owns), gateway `10.10.0.1`.
3. ⬜ SW01: the PVE02 uplink is a **trunk, native VLAN 999** (carries nothing untagged), allowed `10–90,999`, and **DAI-trusted** (the VM VLANs land here tagged — same reason `Gi1/0/4` is DAI-trusted; an untrusted port drops the VMs' gateway ARP). 🔴 **The switch side is owned by the SW01 page-set** (`Devices/SW01-Access-Switch/Build-Guide.md` + `Considerations.md`) — add PVE02's port there, don't duplicate the config here.
4. ⬜ VM VLAN model: tag the vNIC (802.1Q) **and** ensure the VLAN is in `bridge-vids`, or the VLAN-aware bridge tags internally and drops at the uplink.

🔴 **GATE (Phase 2):** from the EQR6, `ping 10.10.0.1` 0% loss on `vmbr0.10`; `bridge vlan show` lists every VM VLAN (10–90,999) as tagged on the uplink; SW01 trunk shows native 999 + DAI-trusted. Only then place VMs.

## Phase 3 — Backup vehicle = the restore Game Day

The migration **is** the estate's first real restore test — "no backups of any VM, ever" is a standing R410 deviation, and `ADR-0011`/`POL-0005` say a backup isn't real until a restore succeeds.

1. ⬜ Stand up / confirm **PBS on BKP01** with a datastore on the 8 TB.
2. ⬜ Register PVE01 (source) and PVE02 (destination) with PBS.
3. ⬜ For each VM to move: take a **fresh PBS backup from PVE01**, then **restore it onto PVE02**. (No cluster → no live `qm migrate`; the offline `qm remote-migrate` is the alternative, but PBS backup→restore is preferred because it *also* proves the backup.)

🔴 **GATE (Phase 3):** at least one non-DC VM (e.g. SRV01) restored onto PVE02 and booted clean **before** touching DC01.

## Phase 4 — Migrate in dependency order

Order matters: an identity **consumer** brought up before the DC can't authenticate.

**DC01 → ICA01 → NPS01 → SRV01 → Vaultwarden → FS01.**

### DC01 (VMID 101) — the one that bites

1. ⬜ Confirm **DC02 is up and healthy** as the fallback authority (`repadmin /replsummary` clean before you start).
2. ⬜ **Shut DC01 down cleanly** (never migrate a running DC by snapshot/clone).
3. ⬜ 🔴 **Never restore an *old* snapshot of a DC** — that triggers **USN rollback** and quarantines the DC. Use the **clean-shutdown PBS backup**; PBS preserves the **VM-GenerationID**, which is what lets AD detect a legitimate restore vs a rollback.
4. ⬜ Restore DC01 onto PVE02; place its vNIC on the correct VLAN tag; boot.
5. ⬜ **Time first:** `w32tm /query /status` + `w32tm /resync` — confirm the PDC Emulator is authoritative and the EQR6 host clock is sane (the whole reason for the move).
6. ⬜ Verify: `dcdiag`, `repadmin /replsummary` (DC01 ↔ DC02 clean), SYSVOL/DFSR healthy, DNS answering.

### The rest

- ⬜ **ICA01** (needs DC/time + PKI intact), **NPS01** (RADIUS/PEAP — needs its ICA01 cert), **SRV01**, **Vaultwarden** (AD CS cert + DB), **FS01** (data disk on the 8 TB) — each: clean shutdown on R410 → PBS restore on EQR6 → vNIC VLAN tag → boot → service-up check.
- ⬜ **BKP01** itself: if it moves to EQR6, keep PBS reachable throughout (don't cut the vehicle you're standing on — stage it so a restore target always exists).

## Phase 5 — Cutover & verification

1. ⬜ Confirm every migrated service answers on its address; run each device's `Diagnostics.md` battery.
2. ⬜ Confirm auth end-to-end: a domain login, an NPS/RADIUS auth, an ICA01-issued cert check.
3. ⬜ Flip the **always-on tier live on EQR6**; power the **R410 down to spin-up duty** (DC02 cold-standby, MON01, NetBox, labs).
4. ⬜ Confirm the **off-site backup copy** covers the new EQR6 workloads before retiring any R410 copies.

## Rollback / break-glass

- The **R410 still holds the source VMs** until you deliberately retire them — rollback = boot the workload back on PVE01 (its VLAN tags are unchanged).
- **DC rollback caveat:** if DC01 booted on EQR6 and replicated, do **not** then boot the old R410 DC01 — that's the USN-rollback trap. Pick one authority; DC02 is the safety net during the window.

## Known deviations / open items

| Item | State | Ref |
|---|---|---|
| PVE02 management IP `10.10.0.11/27` | 📋 **proposed** — IP plan owns; deconflict vs WAC01 `.5` / PAW on VLAN 10 | `#20` |
| EQR6 sizing (RAM headroom for FS01 + Vaultwarden + the always-on set) | 📋 to size | `#20` |
| Single **8 TB SPOF** + PBS/vault co-location blast radius | 🔴 open — off-site copy mandatory | `ADR-0009`/`ADR-0013`, `#20` |
| EQR6 has **no iDRAC** (unlike the R410) | Console = HDMI/keyboard at the unit; no shared-LOM OOB trap, but no remote console either | — |
| PVE01/PVE02 as full `Devices/` folders + `Virtualization/` tidy | ✅ **DONE (`#21`, 2026-07-30)** — `../../Devices/PVE01-Hypervisor/` + `../../Devices/PVE02-Hypervisor/` created; this runbook is `PVE02-Hypervisor`'s home build procedure | `#21` |
| The `2xx` Virtualization guides are **R410-era carry-over** (some pre-Atlas) | Historical procedure; clean device-verified PVE02 set comes from the fresh install | `#21` |


## Related

- **Why-it-works companion:** `Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (**V1**) · IaC follow-on `Concepts/Ansible-IaC-Device-Provisioning.md` (**A1**).
- `Build-Records/PVE01-Networking.md` (the networking model PVE02 mirrors, `ADR-0034`) · `Build-Guides/204-Proxmox-Networking.md` (procedure) · `Build-Guides/214-Deploy-DC01-from-Template.md`.
- `00-Atlas-Foundation/Decisions/`: `ADR-0036` (topology) · `ADR-0046` (standalone/cluster) · `ADR-0020` (time) · `ADR-0011` (Game Day) · `ADR-0009`/`ADR-0013` (backup independence).
- **Device front-doors (`#21`):** `Labs/Lab-02-Cisco-Core/Devices/PVE02-Hypervisor/` (this runbook's home page) · `Devices/PVE01-Hypervisor/` (the source host).
- `Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/` (PBS) · `Devices/DC-Domain-Controllers/` · `Devices/SW01-Access-Switch/` (DAI-trusted trunk) · `Architecture/IP-Addressing-Plan-VLSM.md` (Management `/27`).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Authored (operator ask — the `#21` companion migration runbook; "act as if EQR6 is already here"). Phased/gated target-state procedure: Phase 0 prerequisites gate · Phase 1 EQR6 bring-up · Phase 2 network (mirrors `PVE01-Networking` — tagged `vmbr0.10`, native 999, DAI-trusted uplink) · Phase 3 PBS restore = Game Day · Phase 4 dependency-order migration with the DC USN-rollback / VM-GenerationID method · Phase 5 cutover · rollback/break-glass. All steps ⬜ (`POL-0001`); PVE02 mgmt IP 📋 proposed (`#20`). Grounded in `ADR-0036` v1.2 placement + `ADR-0020`/`ADR-0011`/`ADR-0046`. |
