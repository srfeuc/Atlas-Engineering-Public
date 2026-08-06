---
Title: MON01 · rsyslog — Build Checklist (log collector)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/Roles/rsyslog
Status: 📋 Target design. You write the config; verify logs actually arrive with correct timestamps (`POL-0001`).
Version: 0.1
Date: 2026-07-29
---

# MON01 · rsyslog — Build Checklist

<!-- provenance -->
> **Role:** the estate **log collector** — every device ships logs here. Light receiver runs always-on on the EQR6 probe; the bulk archive on the R410. 🔴 Depends on **clocks synced** (`ADR-0020`) — a log on a wrong clock is worthless.

## Gate
- [ ] 🔴 Clocks synced estate-wide.
- [ ] Host firewall permits inbound **514/udp+tcp**; **denies inbound sessions** from monitored hosts.

## Build steps
- [ ] Enable rsyslog remote reception (imudp/imtcp); template logs per-host (`/var/log/remote/<host>.log`).
- [ ] Set **retention** (logrotate) sized to disk.
- [ ] Point **every device's** syslog at MON01's VLAN-40 IP (network devices, firewalls, Linux/Windows).
- [ ] Settle the **SRV01-relay vs MON01-collector** split (`../../Considerations.md`) so a log has one home (`POL-0008`).

## Acceptance (🎯)
- [ ] Logs arriving from **every** device with **correct timestamps** (`../../Diagnostics.md` §3).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the per-service checklist for the rsyslog collector role (Roles/ pattern). |
