---
Title: SIEM01 — Diagnostics (verify battery)
Path: Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh
Status: 📋 Planned battery (ADR-0032) — the SIEM is not built. All checks 📋 until built. Links up to Academy Command-Library.
Version: 0.1
Date: 2026-07-30
---

# SIEM01 — Diagnostics: verify battery

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Quick "is the SIEM built + actually detecting?" checks (`ADR-0032`). Break-fix → `Troubleshooting.md`. 🔴 Evidence = an agent reporting + an alert firing, not the service being installed (`POL-0001`).

## 1. Stack health
| Check | What to look for | Verified? |
|---|---|---|
| Manager / indexer / dashboard up | services running; dashboard loads over TLS | 📋 |
| Indexer headroom | OpenSearch heap + disk within budget (not near full) | 📋 |

## 2. Agents + host detection
| Check | What to look for | Verified? |
|---|---|---|
| Agent reports | a test host's agent appears **active** in the dashboard | 📋 |
| FIM fires | a change to a monitored path raises an alert | 📋 |
| SCA/CIS score | an SCA scan returns a policy score | 📋 |

## 3. Ingest + correlation (K8)
| Check | What to look for | Verified? |
|---|---|---|
| Suricata ingest | a MON01 Suricata alert is **visible inside Wazuh** | 📋 |
| rsyslog ingest | device/host syslog lands + is parsed | 📋 |

## Related
- `Troubleshooting.md` · `Build-Guide.md` · `../MON01-Monitoring/` (the feed) · `../../Operations/Validation-and-Adversarial-Testing.md` · Academy `Atlas-Academy/Command-Library/`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the 📋 planned battery: stack health (manager/indexer/dashboard + indexer headroom), host detection (agent active · FIM fires · SCA score), and ingest/correlation (Suricata visible in Wazuh · rsyslog parsed, K8). All 📋 until built. |
