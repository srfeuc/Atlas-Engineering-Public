---
Title: MON01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring
Status: ⬜ NOT BUILT — MON01 is planned (Phase 6). This page is the `POL-0001` evidence home; every row is ⬜ until a real read-back is captured. Records outrank guides.
Version: 0.1
Date: 2026-07-29
---

# MON01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** The single "what is actually true right now" snapshot for the visibility/detection stack — the `POL-0001` evidence home. It **outranks the Build-Guide** (guide = target state; this = reality). Each row cites *where the evidence lives* rather than re-pasting it (`POL-0008`). Markers: ✅ device-verified · 🟡 operator-reported, read-back pending · ⬜ not built.

## Host — MON01 (Debian · VLAN 40 · split: EQR6 probe + R410 heavy)

| Attribute | As-built target | Status | Evidence (when built) |
|---|---|---|---|
| Always-on probe VM (EQR6) | Uptime-Kuma + minimal syslog/health | ⬜ | `Diagnostics.md` §probe |
| Heavy-stack VM (R410) | Debian, VLAN 40, CIS-hardened, one-way host firewall | ⬜ | `Diagnostics.md` §host |
| Addressing | LibreNMS `10.40.0.20` · Grafana `10.40.0.30` · gw `10.40.0.1` | ⬜ | `IP-Addressing-Plan-VLSM` |
| Clocks synced (gate) | estate time healthy (`ADR-0020`) | ⬜ | `w32tm`/`chronyc` read-back |
| SPAN cabled (gate) | `SW01 Gi1/0/5` → sensor | ⬜ | SW01 config + sensor sees frames |

## Roles

| Role | As-built target | Status | Evidence |
|---|---|---|---|
| rsyslog collector | every device shipping; retention set | ⬜ | `Roles/rsyslog/` |
| SNMPv3 → LibreNMS | auth+priv polling; LLDP topology renders; **SW01 re-pointed off `10.40.0.52`** | ⬜ | `Roles/LibreNMS/` |
| NetFlow collector | devices exporting; real flows seen (Phase-7 input) | ⬜ | `Roles/NetFlow/` |
| Suricata IDS (SPAN) | sensor up; **fires on a test** (EICAR/known-bad) | ⬜ | `Roles/Suricata-IDS/` |
| Grafana + Uptime-Kuma | dashboards render; a deny shown with correct timestamp | ⬜ | `Roles/Grafana-UptimeKuma/` |
| One-directional rule | session *into* MON01 from a monitored host = refused | ⬜ | `../../Operations/Validation-and-Adversarial-Testing.md` |

> 🔴 **Nothing here is built yet.** When a role is stood up, capture the read-back in `Diagnostics.md`, flip its row here ✅, and tick the `Build-Checklist.md` acceptance gate (`POL-0001`).

## Related
- `Build-Checklist.md` (the action list + evidence) · `Diagnostics.md` (verify commands) · `Roadmap.md` (build path) · `Considerations.md` (open risks).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the (empty) as-built record for MON01 — all rows ⬜ (not built). Structured to the split deployment (EQR6 probe + R410 heavy stack) and the five roles; fills in as each is device-verified. |
