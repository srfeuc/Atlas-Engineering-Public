---
Title: MON01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring
Status: 🟢 LIVING — symptom→cause→fix for the visibility/detection stack. Seeded from the known failure modes; real incidents append here as they occur. Verify commands live in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-29
---

# MON01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → likely cause → fix, for the Detect stack. Seeds from the design's known traps; the health checks that confirm a fix are in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## Logs / timestamps
- **Symptom:** logs are uncorrelatable / timestamps disagree across devices.
  - **Cause:** clocks not synced (`CM-0030`) — the estate time gate wasn't met.
  - **Fix:** fix time first (`ADR-0020` hierarchy — PDCe → devices); confirm `chronyc tracking` on MON01 and `w32tm /query /source` on Windows before trusting any log.
- **Symptom:** no logs from a device.
  - **Cause:** syslog not enabled on the source, or the R410 host firewall dropped it, or (split) the source is pointed at the wrong MON01 instance.
  - **Fix:** confirm the device's syslog target = MON01's VLAN-40 IP; confirm the host firewall permits inbound 514; check the receiver with `Diagnostics.md` §3.

## SNMP / LibreNMS
- **Symptom:** SW01 not in LibreNMS / polling fails.
  - **Cause:** SW01 SNMP still points at the ghost `10.40.0.52` (`CM-0023`), or still v2c `homelab`.
  - **Fix:** re-point SW01 SNMP at MON01; move to **SNMPv3** (auth+priv); re-add in LibreNMS. Verify with `snmpwalk -v3`.
- **Symptom:** LLDP topology map empty/partial.
  - **Cause:** LLDP not enabled on the devices, or SNMP creds wrong on some.
  - **Fix:** enable LLDP; confirm each device polls; the map is proof the docs match reality.

## NetFlow
- **Symptom:** no flows / matrix has no evidence.
  - **Cause:** devices not exporting, or exporting to the wrong collector IP/port, or the firewall drops 2055.
  - **Fix:** confirm the exporter config + destination; permit inbound NetFlow on the host firewall; `nfdump -R ... -c 20` should show flows.

## Suricata / IDS
- **Symptom:** Suricata running but never alerts.
  - **Cause:** SPAN not actually delivering frames (unplugged, wrong port), or rules disabled — **the classic "sensor never fired = unproven" trap** (`016` lesson 4).
  - **Fix:** `tcpdump` the SPAN interface to confirm mirrored frames arrive; enable/update rule set; trigger an EICAR/known-bad test and confirm `fast.log`.

## The one-directional rule
- **Symptom:** a monitored host can open a session *into* MON01 (SSH/web).
  - **Cause:** the MKT01 Phase-7 policy (or the host firewall) doesn't enforce poll-out-only (matrix flow #2).
  - **Fix:** deny inbound sessions from monitored VLANs to VLAN 40 at MKT01; keep only syslog/SNMP-trap/NetFlow inbound to MON01; re-run the reachability proof (`Diagnostics.md` §4).

## Related
- `Diagnostics.md` (the checks that confirm the fix) · `Considerations.md` (why these traps exist) · Academy `Command-Library/Linux.md` · `Roles/` (per-service specifics).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded from MON01's known failure modes (unsynced clocks, missing logs, SW01-SNMP-mistarget `CM-0023`, empty LLDP/NetFlow, Suricata-never-fires, the one-way-rule breach). Real incidents append as they occur. |
