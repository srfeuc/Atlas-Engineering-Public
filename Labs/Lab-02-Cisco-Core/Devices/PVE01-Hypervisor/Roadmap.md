---
Title: PVE01 — Roadmap (host build path + hosted VMs)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor
Status: 🟢 LIVING — the host build path for the R410 hypervisor. Core (platform + network) is ✅ device-verified; deep state lives in the Virtualization Build-Records (POL-0001/POL-0008).
Version: 0.1
Date: 2026-07-30
---

# PVE01 — Roadmap (host build path + hosted VMs)

> **How to read this.** Each row is a **host build stage** on the R410 hypervisor (the hypervisor variant of the build path — bridge/storage/auth/backups, not services). Checkbox = status, evidenced by the read-backs in `../../Virtualization/Build-Records/PVE01-Diagnostics.md` (`POL-0001`). **Needs** = healthy-first; **Unblocks** = what proceeds. The **VMs** this host runs are on the always-on/spin-up split of `ADR-0036` v1.2 — their build paths live in each VM's own `Devices/` folder.

## The host build path (in order)

### Phase 1 — Hardware + BIOS prep (R410) — ✅ mostly (07-11/07-16)
- [x] ✅ **VT-x / KVM enabled** — was BIOS-disabled (dead CMOS traced), re-enabled 2026-07-11; `kvm_intel`+`kvm` loaded. *Evidence:* `PVE01-Diagnostics` §1. *Cert:* virtualization fundamentals.
- [x] ✅ **RAM 64 GB** — upgraded 2026-07-11 (4×16 GB); **62 GiB usable**; 🔴 **DIMM slot B1 faulty** → RAM relocated to B3 (check Dell triple-channel population). *Evidence:* `217-Verified-Facts` live-session addendum.
- [ ] 🔴 **CMOS/RTC battery** — physically dead (`CM-0012`, `ADR-0017` defer): RTC resets `2026`→`2018` across a power cycle; BIOS re-enable holds only on **continuous power/UPS**. NTP holds the OS clock while running (`ADR-0020`). *Physical replacement outstanding.*

### Phase 2 — Proxmox install + post-install — ✅ (07-16)
- [x] ✅ **Proxmox VE 8.4.19** (Debian 12, kernel 6.8.12-32-pve); **standalone, not domain-joined** (`pve01.lab`). *Cert:* Linux/infra. *Note:* no-subscription repo patch is reverted by `apt upgrade` — re-apply after updates.
- [x] ✅ **16 logical CPUs** (2×4×2) — NOT the `egrep '(vmx|svm)'`=32 double-count on kernel 6.8. *Evidence:* `217-Verified-Facts`.

### Phase 3 — Host networking — ✅ device-verified (07-24)
- [x] ✅ **`vmbr0` VLAN-aware + tagged mgmt** — bare `vmbr0` (no L3), `bridge-vids 10–90,999`; host mgmt on **tagged `vmbr0.10` = `10.10.0.10/27`**, gw `10.10.0.1`; native VLAN → **999**. `eno1`→SW01 `Gi1/0/4` 1 Gbps; `eno2` down. 🔴 **Authoritative home:** `../../Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`) — not restated here. *Unblocks:* VM VLAN placement. *Cert:* CCNA (802.1Q/trunking) applied to the hypervisor.

### Phase 4 — Storage — ✅ present (07-16); Build-Record added #21
- [x] ✅ **`local` (~94 GB dir) + `local-lvm` (~793 GB LVM-thin)** active. *Evidence:* `pvesm status` (`PVE01-Diagnostics` §1). *Record:* `../../Virtualization/Build-Records/PVE01-Storage.md` (new, #21). *Open:* a dedicated backup datastore lives on **BKP01/EQR6**, not here.

### Phase 5 — Authentication — ✅/🟡; Build-Record added #21
- [x] ✅ **Named admin `seth-admin@pve`** (Administrator at `/`, propagate) + **`root@pam`** (recovery only). *Record:* `../../Virtualization/Build-Records/PVE01-Authentication.md` (new, #21). *Open:* ACL least-privilege review 🟡; root login policy.

### Phase 6 — VM backups (PBS) — 📋 not built
- [ ] 📋 **Register PVE01 as a PBS backup source** on **BKP01** (datastore on the EQR6 8 TB) + schedule jobs + the mandatory off-site copy (`ADR-0009`). 🔴 **"No backups of any VM, ever"** is the standing deviation; a backup isn't real until a restore succeeds (`ADR-0011`/`POL-0005`). *Needs:* BKP01 built. *Unblocks:* the `221` migration (restore = the Game Day).

### Phase 7 — iDRAC hardening — 🔴 open gap
- [ ] 🔴 **Change iDRAC factory-default credentials** (real gap) + document the **shared-LOM** caveat (`CM-0011`): iDRAC rides `eno1`/`Gi1/0/4`, **not** out-of-band — dies when SW01 is wiped; the physical console is the real bootstrap. The R410 has an unused dedicated iDRAC port (future OOB option).

### Phase 8 — Spin-up-tier role + migration — 📋
- [ ] 📋 **Re-tier to spin-up heavy host** (`ADR-0036` v1.2): migrate the always-on tier (DC01/ICA01/NPS01/SRV01/Vaultwarden/FS01) **off** to PVE02/EQR6 via the **`221` runbook**; keep DC02 cold-standby + MON01 heavy + NETBOX01 + WSUS01/SQL01/KALI01 + the cluster node here. *Companion:* `../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`.

### Future / gated
- [ ] 📋 **Automation (Terraform/Ansible)** — `Automation/` slice (`ADR-0048`); the `221` migration is the IaC exercise. *Cert:* IaC / ENAUTO-adjacent.
- [ ] 📋 **Failover-cluster node + S2D** — the `ADR-0046` on-demand HA lab (power both hosts up; 1 GbE/S2D caveat). *Gated stub.*

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | SW01 (`Gi1/0/4`) | 802.1Q trunk, native 999, VLANs 10–90,999 |
| ⬆ Depends on | MKT01 (`10.10.0.1`) | VLAN-10 mgmt gateway |
| ⬆ Depends on | NTP source · BKP01/PBS | time (`ADR-0020`) · VM backups (Phase 6) |
| ⬇ Serves | DC02 · MON01 heavy · NETBOX01 · WSUS01 · SQL01 · KALI01 · cluster node | the VMs it hosts (spin-up tier, `ADR-0036` v1.2) |
| ⬇ Serves (transient) | DC01 + templates | currently resident → DC01 moves to EQR6 (`221`) |

## Certification alignment (learning lens)
| PVE01 stage | Exercises | Cert / skill |
|---|---|---|
| Proxmox install / VT-x / KVM | Type-1 hypervisor, hardware virtualization | Virtualization fundamentals (AZ-801 Hyper-V concepts transfer) |
| `vmbr0` VLAN-aware bridge + tagged mgmt | 802.1Q trunking on a host | CCNA (VLANs/trunks) applied to compute |
| `local` / `local-lvm` (LVM-thin) | storage pools, thin provisioning | Linux storage / infra |
| named-admin + ACLs | least-privilege administration | Security+ (least privilege) |
| PBS backup + restore Game Day | backup/restore, DR | AZ-801 (backup/DR concepts) · `POL-0005` |
| failover cluster + S2D (future) | clustering / software-defined storage | AZ-801 (failover clustering/S2D) |

## Related
- Authoritative networking: `../../Virtualization/Build-Records/PVE01-Networking.md`. As-built: `Build-Record.md` (+ the Virtualization records it points to). Verify: `Diagnostics.md`. Open risks: `Considerations.md`. The how: `Build-Guide.md`.
- Owners: `../../Service-Server-Build-Plan.md` (placement/sizing) · `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../../Architecture/Cabling-and-Port-Map.md` · `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — the host build path for the R410 hypervisor (hypervisor variant): Phase 1 hardware/BIOS (VT-x ✅, 64 GB ✅, CMOS 🔴 `CM-0012`), Phase 2 Proxmox 8.4.19 ✅, Phase 3 networking ✅ device-verified (points to `PVE01-Networking`, `ADR-0034`), Phase 4 storage ✅ (new Build-Record), Phase 5 auth ✅/🟡 (new Build-Record), Phase 6 PBS backups 📋, Phase 7 iDRAC hardening 🔴, Phase 8 spin-up re-tier + `221` migration 📋, future automation + failover-cluster gated. Status mirrors the Virtualization Build-Records (`POL-0001`/`POL-0008`). |
