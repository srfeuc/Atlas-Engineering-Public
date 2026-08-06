---
Title: MON01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring
Status: 🟢 LIVING roadmap — the per-role build path for the visibility/detection stack + what each role needs and unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`); this page is the map, the checklist is the line-item record.
Version: 1.0
Date: 2026-07-29
---

# MON01 — Roadmap (build path + connections)

> **How to read this.** Each row is a **role or stage** on the visibility stack. The checkbox is its status — **dated** and evidence-backed (the record is `Build-Checklist.md`). **Needs** = what must be healthy first; **Unblocks** = what proceeds once it's done. This is the sequence *and* the dependency graph on one page.

## The build path (in order)

### Phase 0 — Gates (do not start until these pass)
- [ ] 🔴 **Clocks synced** across the estate (`ADR-0020`, `CM-0030`). *Why first:* logs/flows on a wrong clock are uncorrelatable — the whole stack is worthless without it. *Unblocks:* every collector below.
- [ ] 🔴 **SPAN cabled** — `SW01 Gi1/0/5` mirroring the MKT01 trunk into the Suricata sensor (`ADR-0023`). *Unblocks:* the IDS role.

### Phase 1 — Host stand-up (split deployment, `ADR-0036` v1.2)
- [ ] 📋 **Always-on probe VM on PVE02/EQR6** — minimal Debian: **Uptime-Kuma** + a **lightweight syslog receiver / health probe** for the always-on tier. *Needs:* PVE02 stood up (64 GB). *Unblocks:* continuous up/down of the critical tier even when the R410 is off.
- [ ] 📋 **Heavy-stack VM on PVE01/R410** — Debian, VLAN 40, CIS-hardened (named admin, SSH keys, host firewall = permit inbound syslog/SNMP-trap/NetFlow, **deny inbound sessions from monitored hosts**, `unattended-upgrades`). *Needs:* PVE01 powered on. *Unblocks:* the metrics/flow/IDS roles.

### Phase 2 — Logs & metrics
- [ ] 📋 **rsyslog collector** (`Roles/rsyslog/`) — every device ships logs here; set retention. *Needs:* clocks. *Unblocks:* correlation + the SIEM01 feed. → the light receiver runs always-on on the EQR6; the bulk archive on the R410.
- [ ] 📋 **SNMPv3 → LibreNMS** (`Roles/LibreNMS/`, `10.40.0.20`) — auth+priv polling; LibreNMS **auto-draws the LLDP topology** (instant proof the docs match reality). 🔴 **Re-point SW01's SNMP at MON01** — it currently targets the nonexistent `10.40.0.52` (`CM-0023`); never the v2c `homelab` community. *Unblocks:* device health dashboards.
- [ ] 📋 **NetFlow collector** (`Roles/NetFlow/`, nfdump/ntopng) — devices export, MON01 collects; let it watch ~a week. *Unblocks:* 🔴 **the Phase-7 east-west allowed-flows matrix** (this is the evidence it's built from).

### Phase 3 — Detection
- [ ] 📋 **Suricata IDS on the SPAN** (`Roles/Suricata-IDS/`) — east-west network detection from the tap. 🔴 **Prove it fires** on a test (EICAR-style / known-bad pattern) — a sensor that never alerted is unproven (`016` lesson 4). *Needs:* SPAN cabled. *Unblocks:* the SIEM01/Wazuh network feed + the "did we catch it?" validation answer.

### Phase 4 — Visualization
- [ ] 📋 **Grafana** (`Roles/Grafana-UptimeKuma/`, `10.40.0.30`) dashboards + **Uptime-Kuma** up/down. *Needs:* data sources above. *Unblocks:* the operator's single-pane view; a deny shown with a correct timestamp.

### Phase 5 — Automation onboarding (`ADR-0048`)
- [ ] 📋 **Ansible deploy of the stack + SNMP/syslog enablement + dashboards-as-code** — authored *after* the manual first pass (automate what you've learned). *Needs:* the manual build proven. → `Automation/`.

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PVE02 (probe) + PVE01 (heavy) → SW01 → MKT01 (gw `10.40.0.1`) | VLAN-40 reachability |
| ⬆ Depends on | Synced clocks (`ADR-0020`) · SPAN `SW01 Gi1/0/5` (`ADR-0023`) | correlation · IDS feed |
| ⬆ Depends on | SNMPv3 + syslog enabled on every device | the sources it collects |
| ⬇ Serves | SIEM01/Wazuh | Suricata alerts + syslog (host+network correlation) |
| ⬇ Serves | the Phase-7 east-west matrix | NetFlow evidence |
| ⬇ Serves | the operator + the Validation pass | Grafana/Uptime-Kuma + "did we catch it?" |

## Certification alignment (learning lens)

> Each role notes the exam objective it exercises; the estate cert mapping lives in `Atlas-Academy/` (this table is MON01's slice).

| MON01 role / stage | Exercises (exam objective) | Cert |
|---|---|---|
| SNMPv3 polling · syslog · NetFlow | Network monitoring, SNMP, syslog, NetFlow/telemetry | CCNA Dom-4 (IP services) · CCNP ENCOR |
| Suricata IDS on a SPAN | IDS/IPS concepts, signatures, blue-team fundamentals | Security+ · CySA+ |
| One-directional monitoring design | Segmentation of the management plane; least privilege | Security+ · CCNP Security |
| Reading logs / correlating a deny | Log analysis, telemetry correlation | CySA+ · the operator's "reading firewall logs" focus (FCP §6) |
| Grafana / dashboards-as-code | Observability, IaC (`ADR-0048`) | AZ-400-adjacent |

## Staged traffic-flow (the one-directional proof)

> A staged view (visualizes `Architecture/Atlas-East-West-Allowed-Flows-Matrix`, the fact owner — `ADR-0041` incremental discipline):
> **Stage 0 (baseline-deny):** nothing to/from VLAN 40. **Stage 1 (poll-out):** MON01 → devices SNMP/161, ICMP — *allowed*. **Stage 2 (ingest):** devices → MON01 syslog/514, NetFlow/2055, SNMP-traps/162 — *allowed inbound to MON01 only*. **Stage 3 (the proof):** a monitored host → MON01 on any *session* port (SSH/22, web) — 🔴 **refused** (matrix flow #2). Everything else denied + logged.

## Validation

- Prove-it rows live in `../../Operations/Validation-and-Adversarial-Testing.md` (control → attack → evidence) + this host's `Diagnostics.md`. Key MON01 proofs: **Suricata alerts on a test**; **the one-way rule holds** (a session *into* MON01 from a monitored host is refused); **logs arrive with correct timestamps**.

## Future / later phases

- [ ] 📋 **Feed SIEM01/Wazuh** — ship Suricata + syslog into Wazuh for one-pane host+network correlation (`ADR-0032`; register D3 = ingest). *Needs:* SIEM01 built. *(Co-locate-vs-dedicated for SIEM01 is a separate open flag — SIEM01 is its own host per A2.)*
- [ ] 📋 **SCAP / OpenSCAP compliance scans** feeding the SIEM (Backlog #18) — later foundation.
- [ ] 📋 **Wireless / extra telemetry** as the estate grows (FortiAP logs, etc.).

## Related
- Line-item status + evidence: `Build-Checklist.md`. Front door: `README.md`. Open risks: `Considerations.md`. Verify: `Diagnostics.md`.
- Estate index: `../../Service-Server-Build-Plan.md` (MON01 = Phase 6, the IDS). Detection division of labor: `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` · `ADR-0038` · `ADR-0047`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created — per-role build path + connections for the visibility/detection stack (README = front-door). Reflects the **split placement** (`ADR-0036` v1.2: light always-on probe on the EQR6 + heavy stack on the R410), the clocks-first + SPAN gates, the one-directional design + its staged proof, the cert-alignment slice, and the `ADR-0048` automation phase. |
