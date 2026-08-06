---
Title: PFSENSE01 — Diagnostics (verify battery)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS
Status: 📋 Planned battery (ADR-0032) — the inline IPS is not built. All checks 📋 until the hardware lands; flip 📋→✅ from read-backs. Links up to Academy Command-Library.
Version: 0.1
Date: 2026-07-30
---

# PFSENSE01 — Diagnostics: verify battery

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Quick "is the inline IPS built + inspecting right?" checks (`ADR-0032`). Break-fix → `Troubleshooting.md`. 🔴 Evidence = runtime status, not config (`POL-0001`). All 📋 until the appliance exists.

## 1. Bridge / data path (transparent)
| Check | What to look for | Verified? |
|---|---|---|
| Bridge is transparent | the bridge has **no data-plane IP**; both member NICs up; traffic passes | 📋 |
| No routing/OSPF on the bridge | pfSense runs no OSPF; the **1941↔FGT OSPF adjacency stays FULL** after insertion | 📋 |
| Mgmt reachable | mgmt IP (VLAN 10) reachable; data path unaffected by mgmt | 📋 |

## 2. Fail-closed + break-glass
| Check | What to look for | Verified? |
|---|---|---|
| Fail-closed behaviour | on a simulated pfSense fault, the bridge **blocks** (no uninspected pass) | 📋 |
| Manual transit-bypass | the direct FGT01↔1941 re-cable **restores internet** within the documented time | 📋 |

## 3. Suricata (monitor → block)
| Check | What to look for | Verified? |
|---|---|---|
| Suricata mode | monitor-only first; then inline-drop **only** on tuned categories | 📋 |
| Known-bad dropped | a test signature hit is **dropped inline**; a legitimate flow is **not** | 📋 |
| Alerts → MON01/Wazuh | the alert appears in MON01/SIEM01-Wazuh (syslog) | 📋 |

## 4. Correlation
| Check | What to look for | Verified? |
|---|---|---|
| One detection pane | PFSENSE01 inline alerts + MON01 SPAN-Suricata + Wazuh host events correlate (Section K K8) | 📋 |

## Related
- `Troubleshooting.md` · `Build-Guide.md` · `Build-Checklist.md` · `ADR-0038` v1.2 · Academy `Atlas-Academy/Command-Library/` (Linux/Suricata) · `../MON01-Monitoring/` + `../SIEM01-Wazuh/`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the 📋 planned verify battery for the inline IPS (`ADR-0032`): transparent-bridge (no IP, OSPF-unchanged), fail-closed + tested bypass, Suricata monitor→drop (known-bad dropped / legit not), alerts→MON01/Wazuh, and the K8 correlation check. All 📋 until built. |
