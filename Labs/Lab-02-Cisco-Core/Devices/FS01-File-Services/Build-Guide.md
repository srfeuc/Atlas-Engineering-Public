---
Title: FS01 — File Services Build Guide (phased, gated)
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services
Status: 📋 Target design — the phased, gated rebuild contract (`ADR-0043`); phases mirror `Roadmap.md`. NOT executed. Author live values + 📸 + gotchas at the bench (`POL-0001`). You write the config (Charter Rule 17).
Version: 0.1
Date: 2026-07-30
---

# FS01 — File Services Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **FS01** — Windows file server (SMB/AGDLP · DFS/DFSR · FSRM · VSS). Placement **PVE02/EQR6**, shares on the **8 TB external**. Work **phase by phase, each behind its 🔴 GATE**.

## Phase 0 — Gates 🔴
**GATE — do not start until:** DC healthy (AD + DNS) + the **AGDLP groups** exist · the **8 TB is attached to the EQR6** with a data volume (mount-by-serial, not drive-letter roulette).

## Phase 1 — Host stand-up 🔴
**GATE:** Phase 0 ✅.
- **Service-setup:** clone Win Server 2025 (from the PAW01 golden image) → **FS01** → domain-join `atlas.lab` → `OU=Servers,OU=Devices` → `gpupdate /force`. 📸 domain + OU.

## Phase 2 — File-server roles 🔴
**GATE:** Phase 1 ✅.
- **Service-setup:** `Install-WindowsFeature FS-FileServer, FS-Resource-Manager, FS-DFS-Namespace, FS-DFS-Replication -IncludeManagementTools`.
- Create the data volume on the 8 TB; create **SMB shares**; set NTFS + share ACLs via **domain-local groups only** (AGDLP — `ADR-0021`). 🔴 never a direct-user ACL.
- **DFS namespace** `\\atlas.lab\<ns>` + folder targets; enable **VSS** (Shadow Copies) on the data volume; **FSRM** quotas + file-screen templates.
- **GPO drive maps** → the DFS path (the `BATlogin` module; Academy `Windows-Logon-Scripts-and-Drive-Mapping`). 📸 the share ACL (groups), the DFS namespace, a mapped drive.

## Phase 3 — Protect it (`POL-0005`) 🔴
**GATE:** BKP01 built.
- Register the data volume with **BKP01**; run a backup; 🔴 **test a restore** (VSS is not a backup). 📸 the restored test file.

## Phase 4 — Certificate application (from ICA01) 🔴
**GATE:** only if a TLS endpoint is published (web/mgmt or SMB-over-QUIC).
- **Certificate-application:** enrol a server cert from ICA01; else **n/a** (SMB is Kerberos-secured).

## Phase 5 — Cluster fallback roles (`ADR-0046`, on-demand) 🔴
**GATE:** the failover-cluster lab takes the S2D-fallback path.
- **iSCSI target** (shared storage for the 2 nodes) · **file-share witness** (🟡 mind the independence caveat — `Considerations.md`; prefer cloud witness/BKP01).

## Phase 6 — Automation-onboarding (`ADR-0048`) 🔴
**GATE:** the manual build proven.
- DSC file-server role + **shares/ACL-as-code** + FSRM templates-as-code → `Automation/` (idempotent). The AGDLP *design* stays a human decision.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Diagnostics.md` · `Build-Record.md` · `ADR-0021` (AGDLP) · `ADR-0036` (placement/8TB) · `ADR-0042` (client dept access) · `ADR-0046` (cluster fallback) · `Atlas-Academy/Command-Library/PowerShell-Tier0.md` · `Atlas-Academy/Concepts/Windows-Logon-Scripts-and-Drive-Mapping.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — the phased, gated Build-Guide (`ADR-0043`) mirroring `Roadmap.md`: gates (DC+AGDLP, 8 TB) → host → roles/shares/DFS/FSRM/VSS + GPO drive maps → BKP01-protect → cert (conditional) → cluster fallback → automation. Standard sections + 📸 points. Click-by-click filled at the bench. |
