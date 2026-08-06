---
Title: KALI01 — Build Guide (offensive host, designed gated stub)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01
Status: 📋 PROPOSED / gated — a designed stub (ADR-0043). NOT executed. The per-attack detail is authored with each Game Day. Mirrors Roadmap.
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Build Guide (offensive / validation host)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 proposed, ⬜ not built).** A **designed gated stub** (`ADR-0043`): the gate, the VM stand-up outline, and the **controlled-attack model** — the *per-attack* click-steps are authored **with each Game Day** (`ADR-0011`) as the matching control is built, so the attack matches the real target. Work phase by phase.

## 🔴 GATE-0 — isolation + test model
**GATE — do not start until:** VLAN 70 isolation is confirmed (internet-only, no lab access) **and** the Game-Day path model is agreed (open one path → test → close; snapshot the target).

## Stand up (outline)
- Deploy a **Kali Linux VM** on PVE01/R410, VLAN 70, `10.70.0.x` (📋 proposed); clean snapshot; install + update the toolset (README Services map).
- *Detail at build (image, VLAN-70 NIC, snapshot policy).*

## The controlled-attack workflow (per Game Day, `ADR-0011`)
1. **Pick the control** to prove (from `../../Operations/Validation-and-Adversarial-Testing.md`).
2. **Snapshot the target**; **open the one path** needed (move KALI01 to the zone, or a scoped MKT01/FGT rule).
3. **Run the attack** (the tool from the Services map for that control).
4. **Confirm the deny** — the attack fails **and** the deny is logged (correct timestamp, synced clocks).
5. **Close the path**; **re-verify VLAN-70 isolation**; record the evidence + tool versions.

- *Per-attack detail (the exact commands per control) is authored alongside each control's build — never ahead of the target existing (`POL-0001`).*

## Automation-onboarding (hook)
- Box-as-code (rebuildable Kali + tool config) → `../Automation/`; the attacks stay hand-run (the learning).

## Related
- `../../Operations/Validation-and-Adversarial-Testing.md` · `ADR-0011` (Game Days) · `Roadmap.md` · `Build-Checklist.md` · `Considerations.md` · `ADR-0043`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — designed gated stub (`ADR-0043`): GATE-0 (isolation + test model) → Kali VM stand-up → the 5-step controlled-attack Game-Day workflow (pick control → snapshot + open path → attack → confirm deny+log → close + re-verify isolation) → automation hook. Per-attack detail authored with each Game Day; no invented steps ahead of the target. |
