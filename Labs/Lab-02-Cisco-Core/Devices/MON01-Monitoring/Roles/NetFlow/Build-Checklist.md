---
Title: MON01 · NetFlow — Build Checklist (flow collector)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/Roles/NetFlow
Status: 📋 Target design. You write the config; verify real flows are collected (`POL-0001`). This is the Phase-7 matrix input.
Version: 0.1
Date: 2026-07-29
---

# MON01 · NetFlow — Build Checklist

<!-- provenance -->
> **Role:** the flow collector (nfdump default; ntopng if the visual view earns its weight — `../../Considerations.md`). On the R410 heavy-stack VM. 🔴 **This is the evidence the Phase-7 east-west allowed-flows matrix is built from** — let it watch ~a week.

## Gate
- [ ] Host up (Phase 1); host firewall permits inbound **2055/udp** (or the chosen NetFlow port).

## Build steps
- [ ] Install the collector (nfdump/nfcapd or ntopng); set the listen port + rotation.
- [ ] Configure **flow export** on the devices (the 1941 / MKT01 / relevant L3) → MON01.
- [ ] Let it run and accumulate → feed the Phase-7 matrix.

## Acceptance (🎯)
- [ ] `nfdump -R ... -c 20` (or the ntopng UI) shows **real src/dst/port flows** (`../../Diagnostics.md` §3).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the per-service checklist for the NetFlow collector role — flagged as the Phase-7 segmentation-matrix input. |
