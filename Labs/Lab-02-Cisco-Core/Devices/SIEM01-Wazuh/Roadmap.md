---
Title: SIEM01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh
Status: 🟢 LIVING — the build path for the host SIEM/XDR. Dedicated-host decided; VLAN/host sizing → #20. Not built. Mirrors Build-Checklist (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# SIEM01 — Roadmap (build path + connections)

> **How to read this.** Each row is a build stage on the Wazuh host SIEM (the security variant — the stack + agents + ingest, not general services). Checkbox = status. **Needs** = healthy-first; **Unblocks** = what proceeds. Cert objective per stage (`ADR-0044`).

## The build path (in order)

### 🔴 GATE-0 — host + VLAN sizing (→ #20)
- [ ] 🔴 **Dedicated host + VLAN/sizing** — dedicated is **decided** (2026-07-30); the physical host + VLAN (📋 proposed VLAN 40, `10.40.0.x`) + indexer RAM/storage are sized in the **#20** compute/sizing pass. *Why:* the OpenSearch indexer is RAM-heavy — size before build. *Cert:* Security+ (architecture).

### Phase 6 — Stand up the Wazuh stack
- [ ] 📋 **Wazuh manager + indexer + dashboard** on the dedicated host. *Needs:* GATE-0. *Unblocks:* agents + ingest. *Cert:* Security+/CySA+ (SIEM).
- [ ] 📋 **TLS** — optional **ICA01** cert for agent↔manager + the dashboard. *Cert:* Security+ (PKI).

### Phase 6 — Agents + detection content
- [ ] 📋 **Enroll agents (Tier-0 + servers first)** via GPO (Windows) / config-mgmt (Linux); enable **FIM** on key paths, **SCA/CIS** policies, **vuln** feeds. *Needs:* the stack up + a rollout path. *Unblocks:* host detection. *Cert:* CySA+ (host detection).
- [ ] 📋 **Ingest MON01's Suricata + rsyslog** (syslog) — network detection into the same pane (Section K **K8**). *Needs:* MON01 up. *Unblocks:* one security pane. *Cert:* CySA+ (correlation).

### Phase 6/7 — Alerting + validation wiring
- [ ] 📋 **Alerting + active response**; wire into `../../Operations/Validation-and-Adversarial-Testing.md` (a KALI01 attack / FIM change / ESC attempt shows here). *Cert:* CySA+ · PenTest+ (from the defender side).

### Phase 10 — Automation onboarding (`ADR-0048`)
- [ ] 📋 **Agent rollout as code** (GPO/Ansible) + **rules/decoders-as-code**. → `Automation/`.

### Future (Backlog)
- [ ] 📋 **SCAP / OpenSCAP compliance scanning** feeding Wazuh (Backlog **#18**). *Cert:* CySA+.

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | dedicated host (→#20) → SW01 → MKT01 | VLAN 40 (proposed) reachability |
| ⬆ Depends on | MON01 · Wazuh agents · ICA01 | Suricata/rsyslog (514) · FIM/SCA/vuln (1514) · TLS |
| ⬇ Serves | the estate security pane | host + network detection, correlated (K8) |
| ⬇ Serves | the validation pass | a control's alert as evidence |

## Certification alignment (learning lens)
| SIEM01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| Wazuh manager/indexer/dashboard | SIEM deployment, log management | Security+ · CySA+ |
| Agents · FIM · SCA/CIS · vuln | host detection, integrity, config compliance | CySA+ |
| Suricata/rsyslog ingest + correlation | SIEM correlation, one pane | CySA+ |
| Alerting + active response | detection engineering, response | CySA+ |
| SCAP / OpenSCAP (future) | automated compliance scanning | CySA+ |

## Related
- The stack how: `Build-Guide.md`. Line-item: `Build-Checklist.md`. Open risks: `Considerations.md`. Verify: `Diagnostics.md`.
- Owners: `../MON01-Monitoring/` (the feed) · `ADR-0035` (division of labor) · `../../Operations/Validation-and-Adversarial-Testing.md` · `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../../Operations/Build-Order-and-Dependencies.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the build path for the Wazuh host SIEM/XDR: 🔴 GATE-0 (dedicated host **decided** + VLAN/indexer sizing → #20) → stack (manager/indexer/dashboard + ICA01 TLS) → agents (FIM/SCA/vuln, Tier-0 first) + MON01 Suricata/rsyslog ingest (K8) → alerting + validation wiring → automation (agent-rollout + rules-as-code) → SCAP (#18). Cert Security+/CySA+. Not built. |
