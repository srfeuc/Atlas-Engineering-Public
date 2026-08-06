---
Title: PAW01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin
Status: 🟢 LIVING roadmap — the build path for the Win11 golden image + the Tier-0 PAW + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`); this page is the map, the checklist is the line-item record.
Version: 1.0
Date: 2026-07-29
---

# PAW01 — Roadmap (build path + connections)

> **How to read this.** Each row is a **stage**. **Needs** = what must be healthy first; **Unblocks** = what proceeds once it's done. Detail: `Build-Guide.md`. PAW01 is the **Tier-0 admin surface** — most Tier-0 admin work flows through it once it exists.

## The build path (in order)

### Phase 1 — The Win11 golden image (reusable template)
- [ ] 📋 **Create the Win11 VM** (UEFI + Secure Boot + **TPM 2.0** = also the Credential Guard/VBS prereqs) → install → **Audit Mode** customize (VirtIO tools, fully patch, generic machine settings). *Unblocks:* the sysprep seal + every future clone. → Build-Guide Part 1a–1c.
- [ ] 📋 **Finalize + seal** — run `Scripts/Prep-GoldenImage.ps1` → `Test-SysprepReadiness.ps1` (want GO) → `Invoke-SysprepGeneralize.ps1 -Execute` (or the GUI). *Needs:* patched Audit-Mode image. → Part 1d–1e.
- [ ] 📋 **Convert to a Proxmox template** (`tmpl-win11-<date>`); a test full-clone boots to OOBE (proves generalize). *Unblocks:* PAW01 + the VLAN-50 client fleet (`ADR-0042`). → Part 1f.

### Phase 2 — PAW01 (the Tier-0 workstation)
- [ ] 📋 **Full-clone PAW01** from the template (2 vCPU, 8 GB). → Part 2a.
- [ ] 📋 **Pre-stage the computer object** in `Admin\Tier 0\PAW` *before* joining (so it lands in the Tier-0 subtree + inherits Tier-0 GPOs, not `Devices\Staging`). *Needs:* the tier OUs (DC build). → Part 2b.
- [ ] 📋 **Network** — VLAN 20 **tagged** (🔴 not native VLAN 10), static `10.20.0.10–.55`, gw `.1`, DNS `.2`. → Part 2c.
- [ ] 📋 **Domain-join** `atlas.lab` as `t0-seth`; confirm PAW01 in `Admin\Tier 0\PAW`. *Unblocks:* GPO application. → Part 2d.
- [ ] 📋 **Win11 security baseline** (SCT — same mechanism as the DC 7a) linked to the PAW OU. → Part 2e.
- [ ] 📋 **PAW-Tier0-Hardening GPO** — Credential Guard (VBS) · no local admin for the user · AppLocker allow-list · no browser/mail · ASR · firewall deny-by-default · **7d deny-cross-tier**. *Needs:* the baseline + (for Credential Guard) the Proxmox VBS check. → Part 2f.
- [ ] 📋 **Install RSAT** (ADUC/ADAC/GPMC/DNS + AD PowerShell) — *the point of the PAW*. *Unblocks:* administering DC/ICA01/NPS from here. → Part 2g.
- [ ] 🎯 **Acceptance:** RDP into PAW01 as `t0-seth` (Kerberos + clipboard work); run ADUC against the DC; a **Tier-1/Tier-2 account is denied logon** here (7d proof).

### Phase 3 — Cloud-managed delta (deferred, designed — Phase H2 / MD-102)
- [ ] 📋 **Intune / Autopilot / Conditional Access / Defender for Endpoint** — the modern (Entra-centric) PAW controls, layered on once hybrid identity (H1) + Intune (H2) exist. *Designed, not silently skipped* (`ADR-0043` gated stub). → Build-Guide Part 3.

### Phase 4 — Automation onboarding (`ADR-0048`)
- [ ] ✅ *(partial)* the golden-image finalize is **already scripted** (`Scripts/`). 📋 Add DSC/baseline-as-code + RSAT-install automation + the Intune config later. → `Automation/`.

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | DC01 (OU + GPO + join + Kerberos + 7d) | Tier-0 identity |
| ⬆ Depends on | the Win11 golden-image template · PVE02/EQR6 | clone source · host (UEFI/TPM/VBS) |
| ⬇ Serves | DC01/DC02 · ICA01 · NPS01 · all Tier-0 targets | the RSAT/RDP admin path |
| ⬇ Serves | the client fleet (`ADR-0042`) | reuses the golden image |

## Certification alignment (learning lens)

| PAW01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| Sysprep golden image → template | Image deployment, generalize/OOBE | AZ-800/801 (→AZ-802 2026-09-30) · MD-102 |
| PAW / Enterprise Access Model | Privileged access, tiering | Security+ · SC-300-adjacent |
| Win11 SCT baseline + hardening GPO | Security baselines, GPO, AppLocker, ASR | AZ-800/801 · Security+ |
| Credential Guard / VBS | Credential protection | AZ-800/801 · Security+ |
| RSAT-based Tier-0 admin | AD administration tooling | 70-742 · AZ-800/801 |
| Intune/Autopilot PAW (Phase 3) | Cloud endpoint mgmt, Conditional Access | **MD-102** · MS-102 |

## Staged traffic-flow (the Tier-0 admin path)

> Visualizes `Architecture/Atlas-East-West-Allowed-Flows-Matrix` (owner): **Stage 0** baseline-deny to/from VLAN 20 admin host. **Stage 1** PAW01 → Tier-0 block `10.20.0.2–.9` on RDP/Kerberos/LDAPS/DNS — *allowed*. **Stage 2** inbound RDP to PAW01 from the mgmt source only. **Stage 3 (7d proof):** a Tier-1/Tier-2 account attempting interactive logon to PAW01 — **denied**; `t0-seth` on a Tier-1/2 box — **denied**. Everything else denied + logged.

## Validation
- Prove-it rows: `../../Operations/Validation-and-Adversarial-Testing.md` + `Diagnostics.md`. Key proofs: RDP-as-`t0-seth` works (Kerberos+clipboard); **7d cross-tier deny holds** (the flagship "Tier-2 can't touch Tier-0"); AppLocker blocks a non-allow-listed binary.

## Future / later phases
- [ ] 📋 **Phase 3 cloud delta** (Intune/Autopilot/CA — Phase H2). [ ] 📋 **WDAC** (stronger than AppLocker). [ ] 📋 the **client fleet** golden-image reuse (`ADR-0042`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `README.md` · `Considerations.md` · `Scripts/` · `Automation/`. Tier model: `../DC-Domain-Controllers/Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md`. Estate index: `../../Service-Server-Build-Plan.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created — build path + connections for the Win11 golden image + the Tier-0 PAW (DC-template replication, Batch A). Phased (golden image → PAW clone/join/baseline/hardening/RSAT → cloud delta → automation), with the cert-alignment slice, the Tier-0-admin staged flow + the 7d proof, and the deferred cloud delta as a designed stub. Wraps the existing v0.6 `Build-Guide.md` + the `Scripts/` golden-image automation. |
