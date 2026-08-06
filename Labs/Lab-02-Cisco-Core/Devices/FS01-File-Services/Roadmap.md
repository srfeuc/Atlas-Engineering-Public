---
Title: FS01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services
Status: 🟢 LIVING roadmap — the build path for the file server + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`).
Version: 1.0
Date: 2026-07-30
---

# FS01 — Roadmap (build path + connections)

> **How to read this.** Each row is a stage. **Needs** = what must be healthy first; **Unblocks** = what proceeds once it's done. Detail: `Build-Guide.md`.

## The build path (in order)

### Phase 0 — Gates
- [ ] 🔴 **DC healthy** (AD + DNS) + the **AGDLP groups** exist (OU design). *Why:* shares are ACL'd by AD group.
- [ ] 🔴 **The 8 TB external attached to the EQR6** + a data volume provisioned (`ADR-0036` v1.2). *Why:* the shares live there, not the OS NVMe.

### Phase 1 — Host stand-up
- [ ] 📋 **Clone a Win Server 2025 VM → FS01** (from the PAW01 golden image), 2 vCPU / 4 GB (🟡 proposed). Placement PVE02/EQR6.
- [ ] 📋 **Domain-join** `atlas.lab` → `OU=Servers,OU=Devices` → `gpupdate` (server baseline). *Unblocks:* the roles.

### Phase 2 — File-server roles
- [ ] 📋 Add roles: **File Server**, **FSRM**, **DFS Namespaces + Replication**.
- [ ] 📋 Create the **data volume** on the 8 TB; **SMB shares with AGDLP ACLs** (no direct-user ACLs — groups only). *Unblocks:* the `ADR-0042` HR→HR ✓ / HR→IT ✗ proof.
- [ ] 📋 **DFS namespace** (`\\atlas.lab\...`) + targets; **VSS** (Previous Versions); **FSRM** quotas + file-screens.
- [ ] 📋 **GPO drive maps** point users at the DFS path (the `BATlogin` module). *Unblocks:* the client-fleet mapped drives.

### Phase 3 — Protect it (not optional, `POL-0005`)
- [ ] 🔴 **BKP01 backs up the data volume + a restore is tested.** *Why:* VSS is not a backup; unprotected data is a Tier-1 risk. *Needs:* BKP01 built.

### Phase 4 — Certificate application (light)
- [ ] 📋 SMB is Kerberos-secured already; **request a TLS cert from ICA01** only if SMB-over-QUIC or a web/management endpoint is published. Otherwise n/a.

### Phase 5 — Fallback roles for the cluster (`ADR-0046`, later/on-demand)
- [ ] 📋 **iSCSI target** on FS01 = the S2D **fallback** shared storage for the 2-node cluster. [ ] 📋 **File-share witness** host (🟡 see the independence caveat in `Considerations.md`). *Needs:* the cluster lab.

### Phase 6 — Automation onboarding (`ADR-0048`)
- [ ] 📋 After the manual build: DSC file-server role + **shares/ACL-as-code** + FSRM-as-code in `Automation/` (idempotent).

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | DC01 (join · AGDLP groups · DNS) | AD-group ACLs |
| ⬆ Depends on | PVE02/EQR6 + the 8 TB external | host + where shares live |
| ⬆ Depends on | BKP01 | data protection (`POL-0005`) |
| ⬇ Serves | the client fleet (`ADR-0042`) | dept shares + GPO drive maps |
| ⬇ Serves | the failover cluster (`ADR-0046`) | iSCSI target + witness (fallback) |

## Certification alignment (learning lens)
| FS01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| SMB shares + AGDLP ACLs | file/share permissions, AGDLP | AZ-800/801 (→AZ-802 2026-09-30) · 70-740/741 |
| DFS namespace + DFSR | DFS, replication | AZ-800/801 · 70-741 |
| FSRM quotas/screening + dedup | storage management, data dedup | AZ-800 · 70-740 |
| VSS previous-versions | Shadow Copies | AZ-800 · 70-740 |
| iSCSI target (cluster fallback) | block storage, iSCSI | AZ-800 (storage) |

## Staged traffic-flow (the AGDLP access proof)
> Visualizes `Architecture/Atlas-East-West-Allowed-Flows-Matrix` (owner): **Stage 0** baseline-deny to FS01. **Stage 1** clients → FS01 SMB/445 (E-W, intra-estate — *not* crossing FGT/pfSense, so no UTM/IPS penalty). **Stage 2 (the `ADR-0042` proof):** WS-HR01 (HR group) → the **HR share** = *allowed*; WS-HR01 → the **IT share** = **denied** by the AGDLP ACL. This is the flagship department-access cell.

## Validation
- Prove-it rows: `../../Operations/Validation-and-Adversarial-Testing.md` + `Diagnostics.md`. Key proofs: a GPO-mapped drive reads/writes an AGDLP share; **HR→HR ✓ / HR→IT ✗**; DFS resolves + fails over; a **VSS restore** of a prior version.

## Future / later phases
- [ ] 📋 **Data dedup** + **DFSR to a 2nd target** (when a 2nd file host / site exists). [ ] 📋 the cluster fallback roles (Phase 5). [ ] 📋 sizing finalized by the capacity pass (Backlog #20).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `README.md` · `Considerations.md`. Tier/AGDLP: `../DC-Domain-Controllers/Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md`. Client fleet: `ADR-0042`. Estate index: `../../Service-Server-Build-Plan.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Created — build path + connections for the file server (DC-template replication, Batch A). Phased (host → roles/shares/DFS/FSRM/VSS → BKP01-protect → cert → cluster-fallback → automation), reflects the **EQR6 + 8 TB** placement (`ADR-0036` v1.2), the AGDLP HR→HR/HR→IT proof (`ADR-0042`), proposed sizing (→ Backlog #20), and the cluster iSCSI/witness fallback (`ADR-0046`). |
