---
Title: BKP01 / PBS — Build Checklist (backup target)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup/Roles/PBS
Status: 📋 Planned — 🔴 Phase 9, the top live risk. Host build = `../../Build-Checklist.md`; the how = `../../Build-Guide.md` Part 4.
Version: 0.1
Date: 2026-07-30
---

# BKP01 / PBS — the backup target ("PBS01 = BKP01")

> 🔴 **A backup isn't real until a restore succeeds (`POL-0005`/`ADR-0011`).** And a datastore alone is not backup — the **off-site copy is mandatory** (`ADR-0009`/`ADR-0013`).

## Deps
- [ ] Host (BKP01) built + hardened · the **8 TB external** attached (`ADR-0036` v1.2) · the **PVE hosts** reachable as clients · DC reachable for system-state.

## Steps (detail in `../../Build-Guide.md` Part 4)
- [ ] 📋 Install **Proxmox Backup Server**; create the **datastore on the 8 TB** (not PVE VM storage).
- [ ] 📋 Add clients + schedule jobs — **DC01/DC02 · NETBOX01 · ICA01 · Vaultwarden** first (system-state / **KDS root key** / SYSVOL), then VMs + golden templates + device configs.
- [ ] 📋 Enable **verify** jobs (re-read + integrity).
- [ ] 📋 **Prune / retention** per 3-2-1 (sizing → Backlog #20).
- [ ] 🔴 📋 **Off-site copy** — restic/borg → external/cloud, **encrypted, key offline** (`POL-0002`). → `../../../../Operations/Device-Backup-Runbook.md`.
- [ ] 🔴 📋 **Restore Game Day** — restore a VM to isolated VLAN 70; confirm it boots. **Never run in Atlas.**

## Accept (`POL-0001`)
- [ ] 📋 A backup job completes; the **verify job passes**; prune leaves the retention set.
- [ ] 🔴 📋 **A restore completes** — the VM comes up in Testing and functions.
- [ ] 🔴 📋 The **off-site copy exists** and its restore was tested (mount the repo, read a file back).

## Related
- `../../Build-Guide.md` Part 4 · `../../../../Operations/Device-Backup-Runbook.md` · `../../Considerations.md` (single-datastore + blast-radius risks).

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-07-30 | Created — PBS datastore on the 8 TB, backup jobs (reconciled to DC01/DC02 · NETBOX01 · ICA01 · Vaultwarden), verify, prune/retention, mandatory off-site, and 🔴 the never-run restore Game Day. |
