---
Title: MON01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring
Status: 🟠 LIVING — the open risks, gates, and not-yet-settled decisions on the visibility/detection stack. Closed items move to the Build-Record / Change Log.
Version: 1.1
Date: 2026-07-29
---

# MON01 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled yet" list for the Detect layer — separate from the steps (`Build-Guide/`) and the health checks (`Diagnostics.md`). Each item states the risk and its current disposition.

## Open gates
- 🔴 **Clocks-first (`ADR-0020`, `CM-0030`).** Logs/flows on a wrong clock can't be correlated. No collector is trustworthy until estate time is synced. Hard gate.
- 🔴 **SPAN never plugged in / IDS never tested.** The `SW01 Gi1/0/5` SPAN is built but has historically been unplugged — telemetry you own and don't use. Suricata is unproven until it **fires on a test** (`016` lesson 4).
- 🔴 **SW01 SNMP mis-targets a ghost.** SW01 currently points SNMP at `10.40.0.52`, a host that doesn't exist (`CM-0023`/`023`). Re-point it at MON01 during the LibreNMS build; drop the v2c `homelab` community (cleartext, in git) for **SNMPv3** auth+priv.

## Standing risks (design)
- 🔴 **The one-directional rule must be enforced, not assumed.** MON01 polls out; nothing sessions back in (matrix flow #2). If the MKT01 Phase-7 policy doesn't enforce it, a compromised host can pivot into the telemetry. Prove it with the reachability test (`Diagnostics.md` §the-one-way-rule).
- 🟡 **Detection ≠ prevention.** MON01's Suricata sees a *mirror* and only *alerts* — it cannot drop. Prevention is FGT01 UTM (`ADR-0047`) + pfSense IPS (`ADR-0038`) N-S and MKT01 E-W. Don't mistake a green Suricata for a blocked attack.
- 🟡 **Resource weight on a split box.** The heavy stack (LibreNMS + NetFlow + Suricata + Grafana) is non-trivial RAM/CPU; it lives on the R410 for that reason. Keep the always-on EQR6 probe genuinely *light* (Uptime-Kuma + a minimal syslog receiver) so it doesn't compete with the critical tier for the EQR6's 64 GB.

## Open decisions (need a call / ADR when reached)
- 🟡 **Split placement — refines `ADR-0036` (operator, 2026-07-29).** MON01 is split: **light always-on probe on PVE02/EQR6** (watches the always-on tier continuously) + **heavy stack on PVE01/R410** (spun up during active sessions + for the Phase-7 matrix build). *Rationale:* the R410 is mostly-off, so a monolithic MON01 there would leave the always-on core unmonitored. *Open sub-decision:* exactly how much runs always-on (Uptime-Kuma only, or also a always-on Suricata sensor on the EQR6 for the critical VLANs) — decide when the EQR6 RAM headroom is known post-64 GB. **This split should be reflected in `ADR-0036`'s placement table (POL-0008 owner).**
- 🟡 **rsyslog ownership vs SRV01.** SRV01 also carries an `rsyslog` role (relay). Settle the split: **SRV01 = the network-device rsyslog *relay*** (near the CRL/services box); **MON01 = the estate syslog *collector/archive* + correlation**. Confirm so a log has one home (`POL-0008`).
- 🟡 **NetFlow tool** — nfdump vs ntopng (richer UI, heavier). Default nfdump for the matrix evidence; ntopng if the visual flow view earns its weight.
- 🟡 **Suricata vs Zeek** for the SPAN. Suricata (signatures + the operator's log-reading focus) is the default; Zeek (protocol metadata) is a later complement, not a replacement.

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27) — one row per `Roles/` service (rsyslog · LibreNMS · NetFlow · Suricata · Grafana/Uptime-Kuma · SIEM feed) + protocol/port on every diagram edge (`SNMPv3/161 · syslog/514`, `SPAN mirror · one-way`, …). All rows honest ⬜ (not built, `POL-0001`).
- **No separate `Networking-Build-Guide.md` for MON01** *(operator policy — appliances point, hosts get new)*. Split VLAN-40 VM (EQR6 probe + R410 heavy); network reach owned by the hypervisor/switch pages + the SPAN is owned by the SW01 page (`POL-0008`).

## Related
- `Roadmap.md` (where these sit in the build path) · `Build-Checklist.md` (line-item status) · `Troubleshooting.md` (incidents) · `../../Operations/Validation-and-Adversarial-Testing.md` (the one-way-rule + IDS-fires proofs) · `ADR-0036` (placement owner) · `ADR-0032` (monitoring architecture).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** added a **Decided** section — Services map (one row per `Roles/` service) + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27, all ⬜); no separate `Networking-Build-Guide.md` (split VLAN-40 VM). |
| 1.0 | 2026-07-29. Created — open gates (clocks-first, SPAN/IDS-untested, SW01-SNMP-mistarget `CM-0023`), standing design risks (enforce the one-way rule; detection≠prevention; keep the always-on probe light), and open decisions (the split placement refining `ADR-0036`; rsyslog-vs-SRV01 ownership; NetFlow tool; Suricata-vs-Zeek). |
