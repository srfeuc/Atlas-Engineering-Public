---
Title: BKP01 Build Checklist (Backup / Recovery)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup
Status: Target Design — build checklist. A backup isn't real until a restore succeeds (POL-0005/ADR-0011).
Version: 1.1
---

# BKP01 — Build Checklist (Proxmox Backup Server + Off-site)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`Atlas-Service-Architecture` 5.3, `POL-0005`, CSF: Recover):** VM backup (dedup, incremental, **verify jobs**) + an **off‑site** copy + the **restore Game Day** that has never been run. VLAN 20 (or Management). Sources: [Proxmox Backup Server docs](https://pbs.proxmox.com/docs/), [restic](https://restic.readthedocs.io/) / [borg](https://borgbackup.readthedocs.io/).

## 🔴 The rule
> **Backing up to the same physical host you're protecting is not backup.** BKP01's datastore must be on **separate media**, and a backup is not real **until a restore succeeds** (`ADR-0011`).

## Gate
- [ ] **Separate storage** for the datastore (a dedicated disk / external target), not PVE01's own VM storage.

## Build steps
### 1. Proxmox Backup Server
- [ ] Install PBS (VM now; bare‑metal on separate hardware is better later). Create a **datastore on the separate media**.
- [ ] Add the **PVE hosts** as clients; schedule backups of the VMs — **DC01/DC02 · NETBOX01 · ICA01 · Vaultwarden** first (the irreplaceable ones). 🟡 *Reconciled from the retired **CA01 / VAULT01** (`ADR-0031`).*
- [ ] 🟡 **Placement:** the PBS datastore lives on **PVE02/EQR6 + the 8 TB external** (`ADR-0036` v1.2) — not PVE01's VM storage.
- [ ] Enable **verify jobs** (PBS re‑reads backups and checks integrity) and prune/retention.

### 2. Off‑site (3‑2‑1, `POL-0005`)
- [ ] **restic/borg** → an external drive (rotate to `E:\` / off‑site) **and/or** an encrypted cloud target (Backblaze B2, rsync.net). **Encrypted**; the key recorded **offline** (`POL-0002`).
- [ ] Cover what PBS doesn't: the **device configs** (Oxidized→git already does this continuously) and the **offline CA media** (its own off‑site copy).

### 3. 🔴 The restore Game Day
- [ ] **Restore something on purpose** (`ADR-0011`) — a VM to an isolated VLAN (70 Testing), confirm it boots and works. **This has never been done in Atlas.** It is the single most important step here.

## Validation
- [ ] A backup job completes; the **verify job passes**.
- [ ] 🔴 **A restore completes** — the VM comes up in Testing and functions.
- [ ] The **off‑site copy exists** and its restore was also tested (mount the LUKS/repo, read a file back).

## Failure modes
- 🔴 **Datastore on the same physical host** — not backup; one failure loses both.
- 🔴 **Never restore‑tested** — Tier‑1 risk #1; a backup you haven't restored is a hope.
- 🔴 **All copies in one room** — a single event (fire/theft) is total loss.
- 🔴 **Lost encryption key** — the off‑site copy becomes unrecoverable.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Build checklist for BKP01 (Proxmox Backup Server + restic/borg off-site) per `POL-0005`. Datastore on separate media, PBS backups of the irreplaceable VMs with verify jobs, encrypted off-site 3-2-1, and 🔴 the restore Game Day (`ADR-0011`) that has never been run — the load-bearing step. |
| 1.1 | 2026-07-30. Reconciled the stale backup-target line (retired **CA01/VAULT01**, `ADR-0031`) → **DC01/DC02 · NETBOX01 · ICA01 · Vaultwarden**, and noted placement = **PVE02/EQR6 + the 8 TB external** (`ADR-0036` v1.2). No other change; the fuller build path now lives in `Roadmap.md` / `Build-Guide.md` / `Roles/`. |
