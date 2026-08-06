---
Title: WSUS01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management
Status: 🟢 LIVING roadmap — the build path for the WSUS host + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`).
Version: 1.0
Date: 2026-07-30
---

# WSUS01 — Roadmap (build path + connections)

> **How to read this.** Each row is a stage. **Needs** = healthy-first; **Unblocks** = what proceeds. Detail: `Build-Guide.md`.

## The build path (in order)

### Phase 0 — Gate
- [ ] 🔴 **DC healthy** (AD + DNS) + **FGT01 egress** to the Microsoft Update endpoints. *Why:* domain-join + the first sync need both.

### Phase 1 — Host stand-up
- [ ] 📋 Clone Win Server 2025 → **WSUS01** (from the PAW01 golden image); domain-join → `OU=Servers,OU=Devices` → `gpupdate`. Placement PVE01/R410.
- [ ] 📋 Add a **content-store vdisk** (updates are large; keep off the OS disk).

### Phase 2 — WSUS role + first sync
- [ ] 📋 Install the **WSUS** role (**WID** default DB; point at **SQL01** only if scale warrants). Content store → the vdisk.
- [ ] 📋 Choose **products + classifications**; run the first **sync** (large — mind the egress + the future FGT-UTM inspection cost). *Unblocks:* approvals.

### Phase 3 — Targeting + approval rings
- [ ] 📋 **GPO client-side targeting** (WUServer + target group) → **target groups** by OU: Servers · Clients · Tier-0. *Needs:* the OU design.
- [ ] 📋 **Approval rings**: **pilot → broad**; schedule cleanup + decline-superseded. *Unblocks:* controlled patch rollout.

### Phase 4 — Acceptance
- [ ] 🎯 A client **checks in** + lands in the correct target group; a **test approval installs** on a pilot host; the **compliance report** shows patch state across groups.

### Phase 5 — Automation onboarding (`ADR-0048`)
- [ ] 📋 DSC WSUS role + scripted approval rings / cleanup jobs → `Automation/` (idempotent).

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | DC01 (join + WSUS-targeting GPO) | AD OU → target groups |
| ⬆ Depends on | FGT01 egress → Microsoft Update | update sync (N-S) |
| ⬆ Depends on | content-store vdisk · (opt) SQL01 DB | update storage / DB backend |
| ⬇ Serves | every domain computer | approved updates + compliance |
| ⬇ Serves | CIS baselines / SCAP (#18) | patch delivery + measurement |

## Certification alignment (learning lens)
| WSUS01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| WSUS role + sync | update services install/config | AZ-800/801 (→AZ-802 2026-09-30) · 70-741 |
| Target groups via GPO | client targeting, GPO | AZ-800/801 · 70-741 |
| Approval rings + reporting | update lifecycle, compliance | AZ-800/801 · Security+ (patch mgmt) |
| (later) Intune co-management | cloud update rings | MD-102 · MS-102 |

## Staged traffic-flow
> Visualizes the flows matrix (owner): clients → WSUS01 **8530/8531** (E-W, intra-estate); WSUS01 → Microsoft Update (**N-S egress**, crosses FGT — UTM-inspected once `ADR-0047` is live); everything else to WSUS01 denied + logged.

## Validation
- Prove-it: `../../Operations/Validation-and-Adversarial-Testing.md` + `Diagnostics.md`. Key proofs: a pilot host **checks in** to the right group; a **test patch installs**; the **compliance report** renders.

## Future / later phases
- [ ] 📋 **Intune co-management** (Phase H2) — cloud update rings alongside WSUS (MD-102). [ ] 📋 **SQL01 backend** if WID hits scale. [ ] 📋 **SCAP** compliance cross-check (#18).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `README.md` · `Considerations.md`. Estate index: `../../Service-Server-Build-Plan.md`. Hardening: `../../Operations/Device-Hardening-Standard.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Created — build path + connections for the WSUS host (DC-template replication, Batch A). Phased (host+content-vdisk → role+sync → GPO targeting/approval rings → acceptance → automation), placement PVE01/R410 (spin-up, storage-heavy, non-uptime-critical), cert alignment, the N-S first-sync/FGT-UTM note, and future Intune co-management. |
