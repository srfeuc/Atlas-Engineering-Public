---
Title: SIEM01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh
Status: ⬜ NOT BUILT — the host SIEM does not exist yet. Records the not-built state + what will be verified. Records outrank guides (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# SIEM01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — ⬜ not built).** Right now the truth is: **it does not exist** (dedicated-host decided; VLAN/sizing → #20). Each row fills in at build (`POL-0008`). Markers: ✅ device-verified · 🟡 lab-unverified · ⬜ not built.

## SIEM01 — Wazuh host SIEM / XDR (dedicated host)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Host | **dedicated** (not on MON01) — physical host/sizing → #20 | ⬜ (decided) | operator 2026-07-30 |
| Addressing | 📋 VLAN 40 `10.40.0.x` (final → #20) | ⬜ | IP plan (`POL-0008`) |
| Wazuh stack | manager + indexer (OpenSearch) + dashboard | ⬜ | `Roadmap.md` |
| Agents | FIM/SCA/vuln on Tier-0 + servers | ⬜ | `Diagnostics.md` (to verify) |
| MON01 ingest | Suricata + rsyslog correlated (K8) | ⬜ | `../MON01-Monitoring/` |
| TLS | optional ICA01 cert (agent↔manager, dashboard) | ⬜ | `ADR-0027` |

> 🔴 **Nothing is built** — SIEM01 is committed + designed, awaiting the #20 host/sizing. At build, fill these from `Diagnostics.md` (`POL-0001`).

## Related
- `Diagnostics.md` · `Build-Guide.md` · `Build-Checklist.md` · `Roadmap.md` · `Considerations.md` · `../MON01-Monitoring/`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — records the **not-built** state (dedicated host decided; VLAN/sizing → #20) + the rows to verify at build (host, addressing, Wazuh stack, agents, MON01 ingest, TLS). All ⬜. |
