---
Title: PFSENSE01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS
Status: ⬜ NOT BUILT — the inline IPS does not exist yet (hardware pending, ADR-0038 v1.2). This records the not-built state + what will be verified. Records outrank guides (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# PFSENSE01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — ⬜ not built).** The "what is actually true right now" snapshot for the inline IPS. Right now the truth is: **it does not exist** (design decided, hardware pending). Each row fills in at build (`POL-0008`). Markers: ✅ device-verified · 🟡 lab-unverified · ⬜ not built.

## PFSENSE01 — pfSense + Suricata inline IPS (transparent bridge, `ADR-0038` v1.2)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Appliance | physical 2-NIC low-power box | ⬜ hardware to acquire | `ADR-0038` D2a |
| Data path | transparent bridge on FGT01↔1941 /30; **no data-plane IP, no OSPF** | ⬜ | `ADR-0038` |
| Mgmt IP | 📋 proposed VLAN 10 | ⬜ | IP plan (`POL-0008`) |
| Fail mode | fail-CLOSED + tested manual transit-bypass | ⬜ | `ADR-0038` v1.2 |
| Suricata | monitor-only → tuned → inline-drop per category | ⬜ | `Roadmap.md` |
| Alerts → MON01/Wazuh | syslog export | ⬜ | Section K K8 |

> 🔴 **Nothing is built** — this device is a decided design awaiting hardware. At build, fill these rows from the `Diagnostics.md` read-backs (`POL-0001`).

## Related
- `Diagnostics.md` · `Build-Guide.md` · `Build-Checklist.md` · `Roadmap.md` · `Considerations.md` · `ADR-0038` v1.2.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — records the **not-built** state (design decided per `ADR-0038` v1.2; hardware pending) + the rows to verify at build (appliance, transparent bridge, mgmt IP, fail-closed + bypass, Suricata, alerts). All ⬜. |
