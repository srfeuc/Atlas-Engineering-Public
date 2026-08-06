---
Title: WSUS01 — Patch Management Build Guide (phased, gated)
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management
Status: 📋 Target design — phased, gated rebuild contract (`ADR-0043`); mirrors `Roadmap.md`. NOT executed. Author live values + 📸 + gotchas at the bench (`POL-0001`). You write the config (Charter Rule 17).
Version: 0.1
Date: 2026-07-30
---

# WSUS01 — Patch Management Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — WSUS on Win Server 2025, PVE01/R410, content store on its own vdisk. Work **phase by phase, each behind its 🔴 GATE**.

## Phase 0 — Gate 🔴
**GATE — do not start until:** DC healthy (AD+DNS) · **FGT01 egress to Microsoft Update** confirmed (the sync needs it).

## Phase 1 — Host stand-up 🔴
**GATE:** Phase 0 ✅.
- **Service-setup:** clone Win Server 2025 → WSUS01 → domain-join → `OU=Servers,OU=Devices` → `gpupdate`. Add + online a **content-store vdisk**. 📸 domain/OU, the vdisk.

## Phase 2 — WSUS role + first sync 🔴
**GATE:** Phase 1 ✅.
- **Service-setup:** `Install-WindowsFeature UpdateServices -IncludeManagementTools`; run post-install config → content dir = the vdisk; DB = **WID** (or SQL01 at scale). Choose products/classifications; start the **first sync**. 📸 the sync status. *(Expect slow — large + UTM-inspected once `ADR-0047`.)*

## Phase 3 — Targeting + approval rings 🔴
**GATE:** Phase 2 ✅ (updates populated).
- **Service-setup:** GPO — WUServer → `http://wsus01.atlas.lab:8530`, **client-side targeting** → target groups by OU (Servers/Clients/Tier-0). Build **pilot → broad** approval rings; schedule cleanup + decline-superseded (after the first full sync). 📸 the target groups, an approval.

## Phase 4 — Certificate application (optional) 🔴
**GATE:** if serving WSUS over **HTTPS/8531** (recommended for client-server auth).
- **Certificate-application:** enrol a server cert from **ICA01**; bind 8531; update the GPO to the SSL URL. Else n/a (8530 HTTP intra-estate).

## Phase 5 — Acceptance + automation-onboarding (`ADR-0048`) 🔴
- 🎯 pilot host checks in → right group; a **test patch installs**; compliance report renders. 📸.
- Then capture DSC + approval automation in `../Automation/`.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Diagnostics.md` · `ADR-0047` (UTM inspects the sync) · `Atlas-Academy/Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — phased, gated Build-Guide (`ADR-0043`) mirroring `Roadmap.md`: gate (DC+egress) → host+content-vdisk → role+first-sync → GPO targeting/approval-rings → optional HTTPS cert → acceptance+automation. 📸 points; click-by-click at the bench. |
