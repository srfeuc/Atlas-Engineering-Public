---
Title: PFSENSE01 — Considerations (decided design + open risks)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS
Status: 🟠 PROPOSED — the decided design (ADR-0038 v1.2) + the risks it carries. Nothing built.
Version: 0.2
Date: 2026-07-30
---

# PFSENSE01 — Considerations (decided design + open risks)

> The "what could bite us" list for the inline IPS — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`). Facts linked to owners (`POL-0008`).

## Decided (`ADR-0038` v1.2, operator 2026-07-30)
- ✅ **Physical low-power 2-NIC appliance** (D2a) — keeps PVE01 off the internet path. (VM-on-PVE01 rejected.) Hardware 📋 to acquire.
- ✅ **Transparent bridge on the FGT01↔1941 transit** — bump-in-the-wire; **no data-plane IP, no OSPF**; only a mgmt IP (📋 VLAN 10).
- ✅ **Fail-CLOSED** — the enterprise-strict posture; see the tradeoff + break-glass below.
- ✅ **Monitor-only (IDS) first → enable blocking per category after tuning** (`ADR-0041`).
- ✅ **Suricata engine** — consistency with MON01's Suricata (reuse rules/tuning); alerts → MON01/Wazuh.

## Decided (audit #22, 2026-07-30)
- **No separate `Networking-Build-Guide.md` for PFSENSE01** *(operator policy, #22 planning — appliances point, hosts get new)*. Even though its bring-up is genuinely fiddly (transparent bridge · fail-closed · mgmt-IP-only · tested manual bypass), that path is **already** the subject of the existing gated-stub **`Build-Guide.md`** (`ADR-0043`); a second doc would duplicate it (`POL-0008`). The click-steps land in that guide when the hardware arrives.
- **Services map added to `README.md`** (Standard v1.7 backfill, Backlog #27) — inline-IPS / alert-export / mgmt-plane rows, all honest ⬜/📋 (decided-but-not-built, `POL-0001`).

## Standing risks (design)
- 🔴 **Fail-closed = a new single point of failure on the internet path (accepted tradeoff).** If PFSENSE01 dies, egress stops until recovery. **Required mitigations:** (1) the documented + **tested manual transit-bypass break-glass** (re-cable FGT01↔1941 direct); (2) the monitor-first rollout; (3) the `ADR-0038` Review-Trigger fallback to **fail-open / monitor-only** if fail-closed causes real outages; (4) keep the box **simple + config-backed-up** so it fails rarely and recovers fast.
- 🔴 **Untuned inline drops cut legitimate traffic.** Under fail-closed this is doubly costly — monitor-only until tuned, then per-category (never all-at-once).
- 🔴 **Transparent-bridge discipline.** No IP in the routed path, no OSPF — the moment it routes, it changes topology + competes with the 1941 (`ADR-0023`). **MTU/bridge quirks on the transit can drop the 1941↔FGT OSPF adjacency** — watch it after insertion.
- 🟡 **Defence-in-depth, not the sole dropper.** FGT01 UTM is the licensed N-S edge (`ADR-0047`); PFSENSE01 is the free/complementary IPS behind it + the free-vs-licensed comparison. Tune it for what a free Suricata IPS *adds*, don't relitigate FGT's job.

## Open decisions (need a call / note when reached)
- **Section K K7 — IPS tuning depth** — which rule categories run inline vs monitor-only; its own ADR/worksheet when tuned.
- **Section K K8 — Suricata↔Wazuh correlation** — how PFSENSE01 + MON01 SPAN-Suricata + Wazuh host events correlate into one pane.
- **Hardware pick** — the specific 2-NIC low-power box (📋 to acquire).

## Related
- `00-Atlas-Foundation/Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md` (v1.2) · `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` · `ADR-0047` · `Roadmap.md` · `Build-Guide.md` · `../MON01-Monitoring/` + `../SIEM01-Wazuh/` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Date | Change |
| 0.2 | 2026-07-30 | **#22 audit:** added a **Decided** section — no separate `Networking-Build-Guide.md` (the existing gated-stub `Build-Guide.md` is PFSENSE01's networking build guide, `POL-0008`); Services map backfilled into `README.md` (Standard v1.7 / Backlog #27), all rows honest ⬜/📋. |
| 0.1 | 2026-07-30 | Created — recorded the `ADR-0038` v1.2 decided design (physical 2-NIC appliance · transparent bridge · fail-closed · monitor-first · Suricata) + the risks it carries (fail-closed SPOF + the required tested break-glass; untuned-drop; transparent-bridge/OSPF-MTU discipline; defence-in-depth-not-sole-dropper) + open items (K7 tuning · K8 correlation · the hardware pick). |
