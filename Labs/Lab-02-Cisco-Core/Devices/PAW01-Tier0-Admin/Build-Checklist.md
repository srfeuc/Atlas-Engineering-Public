---
Title: PAW01 — Build Checklist (Win11 golden image + Tier-0 PAW)
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin
Status: 📋 Target design — the line-item, dated, evidence-backed action list (`POL-0001`). Mirrors `Roadmap.md` / `Build-Guide.md`. Nothing ticked until a read-back is captured in `Diagnostics.md`.
Version: 1.0
Date: 2026-07-29
---

# PAW01 — Build Checklist (golden image + Tier-0 PAW)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Role: the Win11 **golden image** (sysprep → Proxmox template) + the **Tier-0 Privileged Access Workstation** you RDP into for RSAT. Placement PVE02/EQR6 (🟡 RAM swing — may spin up on R410); VLAN 20 **tagged**, `10.20.0.10–.55`. Detail: `Build-Guide.md`.

## Phase 1 — Win11 golden image
- [ ] Create the Win11 VM: **q35 / OVMF UEFI / EFI disk / TPM 2.0 / Secure Boot** (= Credential Guard/VBS prereqs); VirtIO SCSI + NIC; mount Win11 ISO + virtio-win ISO.
- [ ] Install Win11 (Enterprise preferred); enter **Audit Mode** (`Ctrl+Shift+F3`).
- [ ] Bake generic: VirtIO guest tools + QEMU agent; **fully patch**; machine-level settings (time zone, high-perf power, `powercfg /h off`). 🔴 don't touch Store apps.
- [ ] Finalize: `Scripts/Prep-GoldenImage.ps1` → `Test-SysprepReadiness.ps1` (**want GO**) → `Invoke-SysprepGeneralize.ps1 -Execute -ModeVM`.
- [ ] Convert the powered-off VM to a **Proxmox template** (`tmpl-win11-<date>`); record it.
- **🎯 Gate:** a test full-clone boots to **OOBE** (generalize worked); delete the test clone.

## Phase 2 — PAW01
- [ ] Full-clone **PAW01** (2 vCPU, 8 GB).
- [ ] 🔑 **Pre-stage** the `PAW01` computer object in `Admin\Tier 0\PAW` *before* joining.
- [ ] Network: VLAN 20 **tagged** (🔴 not native 10), static `10.20.0.10–.55`, gw `.1`, DNS `.2`.
- [ ] **Domain-join** `atlas.lab` as `t0-seth`; confirm PAW01 lands in `Admin\Tier 0\PAW`.
- [ ] Apply the **Win11 SCT baseline** GPO(s) → link to the PAW OU → `gpupdate` → `gpresult /h` confirms.
- [ ] Build + link **`PAW-Tier0-Hardening`** GPO: Credential Guard (VBS) · standard-user (no local admin) · **AppLocker allow-list** · no browser/mail · ASR · firewall deny-by-default · rely on **7d** deny-cross-tier.
- [ ] Install **RSAT** (AD DS · GPMC · DNS + AD PowerShell).
- **🎯 Gate:** RDP in as `t0-seth` (Kerberos + clipboard work); ADUC runs against the DC; a **Tier-1/Tier-2 logon is denied** here (7d); AppLocker blocks a non-allow-listed binary.

## Phase 3 — Cloud-managed delta (deferred — designed stub, Phase H2 / MD-102)
- [ ] 📋 Intune enrolment · Autopilot · Conditional Access · Defender for Endpoint — when H1/H2 exist. (`Build-Guide.md` Part 3.)

## Phase 4 — Automation onboarding (`ADR-0048`)
- [ ] ✅ golden-image finalize already scripted (`Scripts/`). 📋 add DSC/baseline-as-code + RSAT-install automation; Intune config later. → `Automation/`.

## Failure modes
- 🔴 **Store app / BitLocker breaks `sysprep /generalize`** — `Test-SysprepReadiness.ps1` first.
- 🔴 **PAW on native VLAN 10** — return traffic lost; use VLAN 20 tagged.
- 🔴 **Credential Guard not running** — the Proxmox VBS check wasn't met; verify `msinfo32`.
- 🔴 **7d not applied** — the "Tier-0 only" property isn't enforced; a lower-tier account could log on.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created (DC-template replication, Batch A) — phased to mirror `Roadmap.md`/`Build-Guide.md` with a 🎯 acceptance per phase (golden image → PAW clone/join/baseline/hardening/RSAT → cloud delta → automation), the native-VLAN-10 + sysprep + Credential-Guard + 7d failure modes. Complements the detailed v0.6 `Build-Guide.md`. |
