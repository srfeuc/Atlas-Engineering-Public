---
Title: SIEM01 — Considerations (decided design + open risks)
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh
Status: 🟠 LIVING — the decided design + the risks the SIEM carries. Not built.
Version: 0.1
Date: 2026-07-30
---

# SIEM01 — Considerations (decided design + open risks)

> The "what could bite us" list for the host SIEM — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`). Facts linked to owners (`POL-0008`).

## Decided (operator 2026-07-30)
- ✅ **Dedicated host** — Wazuh runs on its **own host**, not co-located on MON01 (the long-open Wave-B flag, now closed): the OpenSearch indexer is RAM-heavy + this is the 🔴 Security pane, so keep it off the 🟡 Services availability box (MON01). Clean detection/SIEM separation.
- 📋 **VLAN + physical host + indexer sizing → the #20 pass.** Proposed **VLAN 40 (Monitoring)**, `10.40.0.x` — consistent with the Detect plane. Final VLAN (40 vs 20) + host + RAM/storage sized in #20.

## Standing risks (design)
- 🔴 **Indexer RAM/storage (OpenSearch is heavy).** Undersized → the SIEM falls over under log volume. Size conservatively in #20 (vendor minimums); retention/storage planned before agent rollout.
- 🔴 **Agent rollout is the real work.** The value is agents on hosts (FIM/SCA/vuln), not the server itself. Needs a rollout path — **GPO** (Windows) / config-mgmt (Linux) — starting **Tier-0 + servers**; agent keys are secrets (→ Vaultwarden, `POL-0002`).
- 🟡 **Division of labor (context, `ADR-0035`).** SIEM01 = **host detection + correlation**; it **consumes** MON01's Suricata/rsyslog — it does **not** replace the network IDS (Suricata on MON01) or MON01's availability/metrics. Keep the planes distinct (K8 is the correlation seam).
- 🟡 **Active response can cause outages.** Wazuh can auto-respond (block an IP, kill a process) — scope it carefully; an over-eager response is its own incident. Start alert-only, add response deliberately.

## Open decisions (note when reached)
- **Final VLAN (40 vs 20) + host + sizing** → #20.
- **SCAP / OpenSCAP** scope (Backlog #18) — when compliance scanning feeds Wazuh.
- **Active-response scope** — which responses are safe to automate.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Build-Guide.md` · `../MON01-Monitoring/` · `ADR-0035` · `../../Operations/Validation-and-Adversarial-Testing.md` · `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md` (#18 SCAP).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — recorded the **dedicated-host** decision (2026-07-30; the Wave-B flag closed) + VLAN/host/indexer sizing → #20; the risks (indexer RAM/storage; the agent-rollout-is-the-work reality + agent-key secrets; the MON01 division of labor; active-response caution) + open items (final VLAN/sizing #20; SCAP #18; active-response scope). |
