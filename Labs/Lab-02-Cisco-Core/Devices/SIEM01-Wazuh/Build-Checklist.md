---
Title: SIEM01 — Wazuh (host SIEM / XDR) — Build Checklist
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh
Status: 🟡 Target Design — committed, not built. Dedicated-host DECIDED (2026-07-30); VLAN/host sizing → #20. Runs per POL-0001 (verify on the device; evidence = command + output).
Version: 0.2
Date: 2026-07-30
---

# SIEM01 — Wazuh (host SIEM / XDR) — Build Checklist

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 committed, not built)** — Host: **SIEM01** — Role: **Wazuh manager/indexer/dashboard — host IDS, log analysis, FIM, SCA/CIS, vuln detection**. Companion: `README.md` (front-door + Services map) · `Roadmap.md` (build path) · `Build-Guide.md` (the how). Every `[ ]` → `[x]` only with a command + its output (`POL-0001`).

## Document Control
| Item | Value |
|---|---|
| Status | 🟡 **Target Design — committed, not built.** `ADR-0032` marker: 📋 planned. |
| Applies To | **SIEM01** — Ubuntu/Debian (Wazuh manager + indexer + dashboard) |
| Placement | 🔴 **Dedicated host — DECIDED (operator 2026-07-30)** (not co-located on MON01). VLAN + physical host + indexer sizing → **#20** (📋 proposed VLAN 40 `10.40.0.x`; authoritative in `../../Architecture/IP-Addressing-Plan-VLSM.md` / NetBox, `POL-0008`). |
| Silo | 🔴 Security |
| Governs / Related | `ADR-0035` (Suricata SPAN = network IDS; **Wazuh complements it host-side**) · `ADR-0032` · `ADR-0037` · Section K **K8** (Suricata↔Wazuh correlation) · Backlog **#18** (SCAP) |
| Governing Policy | `POL-0001` (evidence) · `POL-0002` (secrets/agent-keys → Vaultwarden) · `POL-0008` (addressing lives in the IP plan) |

## Part 0 — What this host does
**Wazuh** manager/indexer/dashboard with **agents** on Windows/Linux hosts: **FIM**, log collection, **SCA/CIS** config checks, vulnerability detection; **ingests MON01's Suricata + rsyslog** for one host+network security pane (K8).
- **In scope:** host-based security telemetry (FIM, log analysis, SCA, vuln) across Tier-0 + servers; Suricata/rsyslog ingest.
- **Out of scope:** **not** MON01 (availability/metrics); **not** the network IDS (Suricata on MON01, `ADR-0035`) — Wazuh *consumes* Suricata.

## Part 1 — Dependencies (build gates)
- [ ] 🔴 **Host + VLAN + indexer sizing (#20)** — dedicated host decided; the physical host / VLAN / RAM+storage are the #20 pass.
- [ ] **Agent rollout path** — GPO (Windows) / config-mgmt (Linux); start Tier-0 + servers.
- [ ] **MON01 up** (the Suricata/rsyslog feed) · optional **ICA01** cert for agent↔manager TLS.

## Part 2 — Build outline (expand at build; you write the config)
- [ ] Deploy Wazuh **manager + indexer + dashboard** on the **dedicated host** (VLAN 40 proposed).
- [ ] **Enroll agents** (Tier-0 first): **FIM** on key paths, **SCA/CIS** policies, vuln feeds; agent keys → Vaultwarden.
- [ ] Wire **Suricata + rsyslog** ingest from MON01 (K8); build alerting (**alert-only first**; add active response deliberately).

## Part 3 — Acceptance (`POL-0001` — command + output)
- [ ] An **agent on a test host reports** into the dashboard (active).
- [ ] A **FIM change fires** an alert; an **SCA/CIS scan** returns a score.
- [ ] A **Suricata alert is visible inside Wazuh** (ingest proven, K8).

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-30. **Dedicated-host flag RESOLVED (operator): dedicated host** (not co-located on MON01); VLAN + physical host + indexer sizing → **#20** (proposed VLAN 40). Aligned to the full page-set (README+Services map · Roadmap · Considerations · Build-Guide · Diagnostics · Troubleshooting · Automation/ · Changes/). Added the K8 correlation + `POL-0002` agent-key note + alert-only-first active response. |
| 0.1 | 2026-07-29. Stub created to give **SIEM01** a home under `Devices/` per the Wave-B estate decision (move-alongside-devices; register **E1**). Role, placement (proposed), dependencies, build outline, acceptance seeded from the estate roadmap. |
