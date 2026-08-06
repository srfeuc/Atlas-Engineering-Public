---
Title: Virtualization — Bringing up PVE02 (EQR6) and migrating VMs off the R410 (Proxmox)
Path: Atlas-Academy/Concepts
Status: 🟢 Academy concept/lab module (D6 / `ADR-0032` concept layer). Virtualization **V1** — the "why + the runbook" for the `ADR-0036` v1.2 topology move. 📋 The migration itself is **planned, not executed** (`POL-0001`) — the operator's "act as if EQR6 is already here" lab. Nothing here is device-verified.
Version: 1.0
Date: 2026-07-30
---

# Bringing up PVE02 (EQR6) and migrating VMs off the R410 — a Proxmox migration lab

<!-- provenance -->
> **Atlas Academy — Concepts.** A "why it works" module written as a **hands-on lab runbook**. Every claim points at a **real Atlas artifact** (`Academy/README` design principle). The real example is the `ADR-0036` v1.2 compute-topology move + the **Beelink EQR6** the operator bought. Per the operator (2026-07-30) we **treat EQR6/PVE02 as already present** and write the plan; the migration is 📋 planned, so no step here is a device-verified fact.

> **The gap this closes:** in a homelab you "copy a VM" and forget it. In an estate you **plan a migration** — dependency order, backup-as-restore-test, and the fact that a **Domain Controller cannot be moved like a file server**. This module is that plan, with the reasoning attached.

## The Concept

**Host bring-up + VM migration = standing up a second independent hypervisor, then relocating live workloads with their identity and state intact — in an order dictated by dependencies, not convenience.**

- **Two standalone hosts, no cluster.** `ADR-0046` keeps PVE01/PVE02 **standalone** (cluster is on-demand only; the 1 GbE / S2D caveat). No cluster means **no live migration** (`qm migrate` needs a cluster). Migration is therefore **backup-and-restore** (Proxmox Backup Server / `vzdump`) or an **offline `qm remote-migrate`** — never a seamless hot move.
- **The always-on vs spin-up split (`ADR-0036` v1.2).** EQR6 = **low-power always-on critical tier** (DC01 · ICA01 · NPS01 · SRV01 · Vaultwarden · FS01 · BKP01). R410 = **mostly-off spin-up heavy tier** (DC02 cold-standby · MON01 · NetBox · lab nodes). Migration moves the always-on tier onto EQR6 first; placement is decided by **uptime need**, not by which host is bigger.
- **Why move DC01 at all — it's a correctness fix, not capacity.** The R410 has an unstable CMOS/clock (`CM-0012`). A DC is the estate's **authoritative time source** (the PDC Emulator, `ADR-0020`); if the host clock drifts, Kerberos' ±5-minute window is blown and **authentication fails estate-wide**. Moving DC01 to stable hardware removes the root cause — that's the whole reason it leads the migration.

## The Atlas Example (real artifacts) — the runbook, treating EQR6 as present

📋 **Proposed sequence** (each step becomes a gated Build-Record entry when actually run):

1. **Host bring-up.** Install Proxmox VE on EQR6; **64 GB RAM is the prerequisite** (`ADR-0036`). Attach the **8 TB external** as the PBS / FS01 datastore. Join **nothing** — standalone (`ADR-0046`).
2. **Network first, VMs second.** Build PVE02's trunk exactly like PVE01: **`vmbr0.10` tagged management, native VLAN 999** (the current device-verified design, `Build-Records/PVE01-Networking`). SW01 needs a **new DAI-trusted trunk port** for PVE02 that mirrors `Gi1/0/4` (native 999, VLANs tagged). Until that port is right, VLAN-10 management traffic silently won't pass — the same tagged/native trap seen in the PVE01 VLAN-20 attempt.
3. **Backup is the vehicle — and the migration IS the restore Game Day.** A backup isn't real until a restore succeeds (`ADR-0011` / `POL-0005`). Use **BKP01/PBS**: back up each VM on the R410 → restore onto EQR6. This finally exercises the restore path that has never been run.
4. **Migrate in dependency order:** **DC01 first** (time + identity root) → **ICA01** (needs the DC) → **NPS01** → **SRV01** → **Vaultwarden** → **FS01**. Bringing an identity *consumer* up before the DC means it can't authenticate.
5. **DC-specific method — the one that bites.** **Never snapshot-rollback or clone a live DC** (USN rollback → replication divergence, a quarantined DC). Shut DC01 down **cleanly**, restore the **same VM** (PBS preserves the **VM-GenerationID**), boot, and verify replication/SYSVOL. Keep **DC02 (cold-standby)** available as the fallback authority during the cutover.
6. **Cutover verify.** `w32tm /query /status` for time sanity on the new host; `dcdiag` + `repadmin /replsummary`; confirm NPS01 + ICA01 reachable; then flip the always-on tier on and power the R410 down to spin-up duty.

## What Could Go Wrong (the real traps)

- **You move the DC but not the reason.** If EQR6's own host clock/BIOS + chrony aren't set to the `ADR-0020` source **before** the DC boots, you've relocated the CMOS problem, not fixed it.
- **USN rollback.** Restoring an *old* DC snapshot after replication has advanced quarantines the DC. A clean-shutdown PBS restore with VM-GenerationID is safe; the "just roll back the snapshot" reflex is not.
- **Trunk/DAI.** VMs land but can't reach the management plane because PVE02's SW01 port isn't native-999 + DAI-trusted — the SW01 "Pi01 mystery" family of faults.
- **Single 8 TB SPOF + PBS/vault co-location blast radius** (→ **#20**). The **mandatory off-site copy** (`ADR-0009`/`ADR-0013`, key held offline) must exist before you trust the move.
- **Order inversion.** ICA01/NPS01 up before DC01 → nothing authenticates; the migration looks broken when it's just out of order.

## How to Explain This in an Interview

*"I moved my domain controller off failing hardware. Because it's a DC I couldn't just copy the VM — a DC restored from a stale snapshot triggers USN rollback and breaks AD replication. So I used a clean-shutdown backup-and-restore with the VM-GenerationID preserved, migrated in dependency order behind a cold-standby DC, and fixed the underlying reason for the move: the old host's clock was unstable, and since that DC is my authoritative time source, bad host time meant Kerberos failures across the whole estate. I also treated the migration as my first real restore test — a backup you've never restored isn't a backup."*

## Related

- `00-Atlas-Foundation/Decisions/ADR-0036` (compute topology / VM placement) · `ADR-0046` (cluster on-demand) · `ADR-0020` (authoritative time) · `ADR-0011` (Game Day) · `ADR-0009`/`ADR-0013` (backup independence / off-site).
- `Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/` (PBS restore) · `Devices/DC-Domain-Controllers/` · `Devices/SW01-Access-Switch/` (the DAI-trusted trunk) · `Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md` (the **operational runbook** this module is the "why" for) · `Virtualization/` (→ **#21** PVE01/PVE02-as-devices).
- `Atlas-Academy/Concepts/Ansible-IaC-Device-Provisioning.md` (the IaC companion — provisioning *onto* this host) · `Concepts/README.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Authored (operator ask — "act as if EQR6 is already here, plan the update/VM migration; a good Academy lab"). Virtualization **V1**. Runbook grounded in `ADR-0036` v1.2 (always-on/spin-up split), `ADR-0020` (why the DC leads — CMOS/`CM-0012` time fix), `ADR-0011`/`POL-0005` (migration = restore Game Day), the DC USN-rollback / VM-GenerationID trap, and the SW01 native-999 + DAI-trusted trunk requirement. All steps 📋 proposed (`POL-0001`). |
