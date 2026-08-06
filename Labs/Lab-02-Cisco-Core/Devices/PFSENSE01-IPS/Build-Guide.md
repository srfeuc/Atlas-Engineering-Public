---
Title: PFSENSE01 — Build Guide (inline IPS, designed gated stub)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS
Status: 📋 PROPOSED / gated — a designed stub (ADR-0043). NOT executed. The design is decided (ADR-0038 v1.2); click-steps when the hardware lands. Mirrors Roadmap.
Version: 0.1
Date: 2026-07-30
---

# PFSENSE01 — Build Guide (inline IPS)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 proposed, ⬜ not built).** A **designed gated stub** (`ADR-0043`): the **gate**, the **phase outline**, and the load-bearing specifics (transparent bridge · fail-closed · monitor-first · Suricata) — decided in `ADR-0038` v1.2. The click-by-click steps are authored **when the hardware is acquired**. Work phase by phase, each behind its 🔴 gate.

## 🔴 GATE-0 — hardware + transit
**GATE — do not start until:** the **physical 2-NIC low-power appliance** exists (`ADR-0038` D2a) **and** the **FGT01↔1941 transit** is up (Phase 2).

## Phase 7a — Transparent bridge (outline)
- Install pfSense; bridge the two NICs across the FGT01↔1941 /30; **assign no IP to the bridge, run no OSPF**; set a **mgmt IP** (📋 VLAN 10). Verify traffic passes + the 1941↔FGT OSPF adjacency is unchanged.
- *Detail authored at build (the exact NIC/bridge config + the MTU check on the transit).*

## Phase 7b — Fail-closed + break-glass (outline)
- Confirm the bridge **fails closed** on a pfSense fault. **Document + test the manual transit-bypass** (direct FGT01↔1941 re-cable) and its restore time.
- *Detail authored at build.*

## Phase 7c — Suricata: monitor → tune → block (outline)
- Suricata **monitor-only** first (reuse MON01 rules) → baseline → tune false positives → **enable inline blocking per category** (`ADR-0041`) → ship alerts to MON01/Wazuh.
- *Detail authored at build (the category-by-category enable order + the tuning notes).*

## Automation-onboarding (hook)
- Config-backup + Suricata-rules-as-code → `../Automation/` (after the manual build). See `Automation/README.md`.

## Related
- `00-Atlas-Foundation/Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md` (v1.2) · `Roadmap.md` · `Build-Checklist.md` · `Considerations.md` · `ADR-0043` (gated-stub discipline) · `00-Atlas-Foundation/Atlas-Firewall-Architecture.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — designed gated stub (`ADR-0043`): 🔴 GATE-0 (hardware + transit) → transparent bridge → fail-closed + break-glass → Suricata monitor→tune→block → automation hook, with the load-bearing specifics from `ADR-0038` v1.2; no invented click-steps (hardware pending). |
