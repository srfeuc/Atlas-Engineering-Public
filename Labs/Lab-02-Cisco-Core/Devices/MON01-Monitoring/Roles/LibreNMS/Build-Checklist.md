---
Title: MON01 · LibreNMS — Build Checklist (SNMPv3 metrics + topology)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/Roles/LibreNMS
Status: 📋 Target design. You write the config; verify devices poll + the topology renders (`POL-0001`).
Version: 0.1
Date: 2026-07-29
---

# MON01 · LibreNMS — Build Checklist

<!-- provenance -->
> **Role:** SNMPv3 polling + auto-drawn **LLDP topology** (`10.40.0.20`). On the R410 heavy-stack VM. Docs: https://docs.librenms.org/.

## Gate
- [ ] Host up (Phase 1); host firewall permits SNMP-trap **162** inbound; MON01 initiates polls **out** to 161.

## Build steps
- [ ] Install LibreNMS (per official docs) + dependencies.
- [ ] Configure **SNMPv3** (auth+priv) credentials; 🔴 **no v2c `homelab` community** (cleartext, in git — `CM-0023`).
- [ ] Add each device; enable **LLDP** on the network devices so the map draws.
- [ ] 🔴 **Re-point SW01's SNMP off the ghost `10.40.0.52`** onto MON01 (`CM-0023`).

## Acceptance (🎯)
- [ ] A device appears in LibreNMS; the **LLDP topology map renders** and matches the docs (`../../Diagnostics.md` §3).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the per-service checklist for the LibreNMS/SNMPv3 role — foregrounds SNMPv3-not-v2c and the SW01 mistarget fix (`CM-0023`). |
