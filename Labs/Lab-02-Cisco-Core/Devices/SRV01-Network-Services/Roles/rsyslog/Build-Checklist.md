---
Title: SRV01 / rsyslog — Build Checklist (log relay → MON01)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services/Roles/rsyslog
Status: 📋 Planned — log relay. Host build = `../../Build-Checklist.md`.
Version: 1.0
Date: 2026-07-29
---

# SRV01 / rsyslog — log relay → MON01

> Relays device + SRV01's own logs to **MON01** (the collector). CCNA (syslog) · SecOps logging.

## Deps
- [ ] Host built · **MON01** up + listening (the collector target).

## Steps
- [ ] Configure `rsyslog` to forward to MON01; forward SRV01's own logs too.
- [ ] Confirm transport (TCP/TLS preferred over UDP for anything sensitive).

## Accept (`POL-0001`)
- [ ] A log line from SRV01 (and a relayed device line) **appears on MON01** with a correct timestamp.

## Related
- `../../Build-Checklist.md` §6 · `../../../MON01-Monitoring/` (the collector).
