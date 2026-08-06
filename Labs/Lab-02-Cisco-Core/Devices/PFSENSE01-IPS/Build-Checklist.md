---
Title: PFSENSE01 — Build Checklist (inline IPS)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS
Status: 📋 PROPOSED / gated — line-item, all ⬜. Design decided (ADR-0038 v1.2); build gated on hardware. Mirrors Roadmap (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# PFSENSE01 — Build Checklist (inline IPS)

<!-- provenance -->
> 🔴 **NOT STARTED — gated on hardware** (the physical 2-NIC appliance, `ADR-0038` D2a). The **design is fully decided** (`ADR-0038` v1.2: transparent bridge · physical 2-NIC · fail-closed · monitor-first · Suricata) — only the build waits on the box. Every `[ ]` → `[x]` only with a read-back once built (`POL-0001`). Detail: `Build-Guide.md`.

## 🔴 GATE-0 — hardware + transit
- [ ] ⬜ **Physical 2-NIC low-power appliance acquired** (`ADR-0038` D2a).
- [ ] ⬜ **FGT01↔1941 transit confirmed up** (Phase 2) — the cable this bridges.

## Phase 7 — Transparent bridge
- [ ] ⬜ Install pfSense; create a **transparent (filtering) bridge** across the 2 NICs on the FGT01↔1941 /30. **No data-plane IP; no OSPF.**
- [ ] ⬜ Assign a **mgmt IP** (📋 proposed VLAN 10); scope mgmt access (SSH/GUI) to the mgmt plane.
- **🎯 Gate:** traffic passes the bridge transparently; the 1941↔FGT OSPF adjacency + routing are unchanged.

## Phase 7 — Fail-closed + break-glass
- [ ] ⬜ Confirm **fail-CLOSED**: on a pfSense fault the bridge blocks (no uninspected pass-through).
- [ ] ⬜ Document + **test the manual transit-bypass break-glass**: a direct FGT01↔1941 re-cable restores internet.
- **🎯 Gate:** the bypass restores egress within a known, documented time.

## Phase 7 — Suricata: monitor → tune → block
- [ ] ⬜ Suricata **monitor-only (IDS)**; reuse MON01's rule sets; baseline.
- [ ] ⬜ Tune false positives; **enable inline blocking per category** (one at a time, `ADR-0041`).
- [ ] ⬜ Ship **alerts → MON01/Wazuh** (syslog).
- **🎯 Gate:** a known-bad test is dropped inline; a legitimate flow is not; the alert appears in MON01/Wazuh.

## Phase 10 — Automation
- [ ] ⬜ Config-backup + Suricata-rules-as-code → `Automation/` (idempotent).

## Failure modes (pre-empt)
- 🔴 **Enabling inline-drop before tuning** under fail-closed → an untuned rule cuts the internet. Monitor-only first, always.
- 🔴 **A pfSense fault with no tested bypass** → prolonged internet outage. The manual transit-bypass must be documented + tested first.
- 🔴 **Giving the bridge a data-plane IP / running OSPF** → it stops being a transparent bump-in-the-wire and changes topology (`ADR-0038`).
- 🔴 **Inventing a mgmt IP** → drift from the IP plan (`POL-0008`); it is 📋 proposed VLAN 10 until the IP plan assigns it.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created to the standard — all ⬜, opening on the hardware gate; phased (GATE-0 → transparent bridge → fail-closed+break-glass → Suricata monitor→tune→block → alerts → automation) with 🎯 gates + the pre-empt failure modes, per `ADR-0038` v1.2. |
