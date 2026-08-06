---
Title: SIEM01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh
Status: 🟢 LIVING — symptom→cause→fix for the Wazuh host SIEM. Seeded from the known Wazuh traps; real incidents append.
Version: 0.1
Date: 2026-07-30
---

# SIEM01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → likely cause → fix for the host SIEM. Verify commands in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## An agent isn't reporting
- **Symptom:** a host's Wazuh agent shows disconnected / never-connected.
  - **Cause:** connectivity to the manager (**1514/1515**) blocked, a bad/duplicate enrollment key, or a clock skew.
  - **Fix:** confirm the path to SIEM01 (VLAN/firewall); re-enroll the agent (fresh key → Vaultwarden, `POL-0002`); check time sync; restart the agent.

## The indexer is struggling / dashboard slow or down
- **Symptom:** the dashboard is slow/unavailable; searches time out.
  - **Cause:** 🔴 **OpenSearch indexer under-resourced** (heap/disk) — the RAM-heavy component.
  - **Fix:** raise the heap / add disk / tighten retention; this is the #20 sizing decision made real — size conservatively, don't run it starved.

## Suricata alerts aren't showing in Wazuh
- **Symptom:** MON01 has Suricata alerts but they don't appear in the SIEM (K8 broken).
  - **Cause:** the syslog/ingest from MON01 is unset/misdirected, or the decoder isn't parsing them.
  - **Fix:** confirm MON01 ships to SIEM01 (syslog 514); confirm the Wazuh decoder/ruleset parses Suricata; generate a test alert and confirm it lands.

## An active response caused an outage
- **Symptom:** a host/IP got blocked by Wazuh and a legitimate service broke.
  - **Cause:** 🔴 an over-eager **active-response** rule.
  - **Fix:** disable/scope that response; start **alert-only** and add automated responses deliberately, one tested rule at a time (`ADR-0041`).

## Related
- `Diagnostics.md` · `Considerations.md` · `../MON01-Monitoring/` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Seeded from the known Wazuh traps — agent-not-reporting (1514/key/clock); indexer under-resourced (heap/disk → #20 sizing); Suricata ingest broken (syslog/decoder, K8); an active-response outage (scope it / alert-only first). Real incidents append. |
