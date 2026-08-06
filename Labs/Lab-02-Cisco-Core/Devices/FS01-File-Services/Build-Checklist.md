---
Title: FS01 — Build Checklist (File Services)
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services
Status: 📋 Target design — the line-item, dated, evidence-backed action list (`POL-0001`). Mirrors `Roadmap.md`. Nothing ticked until a read-back is captured in `Diagnostics.md`.
Version: 1.0
Date: 2026-07-30
---

# FS01 — Build Checklist (File Services)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Role: Windows file server — SMB (AGDLP) · DFS + DFSR · FSRM · VSS. Placement **PVE02/EQR6**, **shares on the 8 TB external**, VLAN 20 `10.20.0.14` *(proposed)*. Sizing 🟡 2 vCPU / 4 GB / data-on-8TB (→ Backlog #20). Detail: `Build-Guide.md`. Supersedes the v0.1 stub.

## Phase 0 — Gates
- [ ] 🔴 DC healthy (AD + DNS) + **AGDLP groups exist**.
- [ ] 🔴 **8 TB external attached to the EQR6** + a data volume provisioned (mount-by-serial).

## Phase 1 — Host stand-up
- [ ] Clone Win Server 2025 → **FS01** (from the PAW01 golden image); domain-join → `OU=Servers,OU=Devices` → `gpupdate`.
- **🎯 Gate:** domain-joined, correct OU, server baseline applied.

## Phase 2 — File-server roles
- [ ] Add roles: **File Server · FSRM · DFS Namespaces + Replication**.
- [ ] Data volume on the 8 TB; **SMB shares with AGDLP ACLs** (🔴 groups only, no direct-user ACLs).
- [ ] **DFS namespace** + targets; **VSS** (Previous Versions) on the data volume; **FSRM** quotas + file-screens.
- [ ] **GPO drive maps** → the DFS path (the `BATlogin` module).
- **🎯 Gate:** a domain user gets a GPO-mapped drive + reads/writes an AGDLP share; DFS resolves; a VSS previous-version restores.

## Phase 3 — Protect it (`POL-0005`, not optional)
- [ ] 🔴 **BKP01 backs up the data volume + a restore is tested.**
- **🎯 Gate:** a test file is restored from BKP01 (not just VSS).

## Phase 4 — Certificate (light)
- [ ] TLS cert from ICA01 **only if** a web/mgmt or SMB-over-QUIC endpoint is published; else n/a.

## Phase 5 — Cluster fallback (`ADR-0046`, on-demand)
- [ ] iSCSI target (S2D fallback) · file-share witness (🟡 independence caveat, `Considerations.md`).

## Phase 6 — Automation onboarding (`ADR-0048`)
- [ ] DSC file-server role + **shares/ACL-as-code** + FSRM-as-code → `Automation/` (idempotent).

## Validation (the proofs)
- [ ] GPO-mapped drive reads/writes an AGDLP share.
- [ ] 🔴 **HR→HR ✓ / HR→IT ✗** (the `ADR-0042` department-access proof).
- [ ] DFS namespace resolves + fails over between targets.
- [ ] A VSS previous-version restores; a BKP01 restore succeeds (Phase 3).

## Failure modes
- 🔴 **VSS mistaken for backup** — it isn't (`POL-0005`); BKP01 + a tested restore is the safety net.
- 🔴 **8 TB USB disconnect** → shares offline; mount-by-serial, stable power, monitor.
- 🔴 **Direct-user ACL** → breaks AGDLP + the HR/IT proof; groups only.
- 🟡 **FSRM quota too tight / VSS storage full** → write failures / no previous-versions; size the shadow storage.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Rebuilt to the Documentation-Standard shape (DC-template replication, Batch A) — phased to mirror `Roadmap.md` with 🎯 acceptance per phase, the **EQR6 + 8 TB** placement (`ADR-0036` v1.2), the AGDLP HR→HR/HR→IT proof (`ADR-0042`), the VSS≠backup gate (`POL-0005`), and the cluster-fallback + automation phases. Supersedes the v0.1 stub. |
