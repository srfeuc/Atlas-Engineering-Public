---
Title: WSUS01 — Build Checklist (Patch Management)
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management
Status: 📋 Target design — line-item, dated, evidence-backed (`POL-0001`). Mirrors `Roadmap.md`. Supersedes the v0.1 stub.
Version: 1.0
Date: 2026-07-30
---

# WSUS01 — Build Checklist (Patch Management)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** WSUS for domain patch management. Placement **PVE01/R410** (spin-up), content store on its own vdisk, VLAN 20 `10.20.0.15` *(proposed)*. Detail: `Build-Guide.md`.

## Phase 0 — Gate
- [ ] 🔴 DC healthy (AD+DNS) · **FGT01 egress to Microsoft Update** confirmed.

## Phase 1 — Host stand-up
- [ ] Clone Win Server 2025 → **WSUS01**; domain-join → `OU=Servers,OU=Devices` → `gpupdate`.
- [ ] Add a **content-store vdisk** (100 GB+; off the OS disk).
- **🎯 Gate:** domain-joined, correct OU, content vdisk online.

## Phase 2 — WSUS role + first sync
- [ ] `Install-WindowsFeature UpdateServices -IncludeManagementTools`; post-install → content store = the vdisk; **WID** DB (or SQL01 if scale).
- [ ] Choose **products + classifications**; run the **first sync** (expect it to be slow — large + UTM-inspected once `ADR-0047`).
- **🎯 Gate:** sync completes; updates populate.

## Phase 3 — Targeting + approval rings
- [ ] **GPO**: WUServer → WSUS01, **client-side targeting** by OU → target groups (Servers · Clients · Tier-0).
- [ ] Approval rings: **pilot → broad** (a hold between); schedule cleanup + decline-superseded (after the first full sync).
- **🎯 Gate:** a pilot host checks in + lands in the right group.

## Phase 4 — Acceptance
- [ ] 🎯 A **test approval installs** on a pilot host; the **compliance report** shows patch state across groups.

## Phase 5 — Automation onboarding (`ADR-0048`)
- [ ] DSC WSUS role + scripted approval-ring/cleanup jobs → `Automation/`.

## Failure modes
- 🔴 **Content store on the OS disk** → fills the boot volume. Own vdisk, sized + cleaned.
- 🔴 **Auto-approve everything** → a bad patch hits all hosts at once; keep the ring hold.
- 🟡 **Forgotten patch cycles** (R410 mostly off) → drift; pair cycles with spin-ups + track compliance.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Rebuilt to the standard (DC-template replication, Batch A) — phased with 🎯 gates (host+content-vdisk → role+sync → GPO targeting/rings → acceptance → automation), the first-sync/egress + approval-discipline + storage failure modes. Supersedes the v0.1 stub. |
