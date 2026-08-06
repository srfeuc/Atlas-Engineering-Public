---
Title: KALI01 — Diagnostics (verify battery)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01
Status: 📋 Planned battery (ADR-0032) — the offensive host is not built. All checks 📋 until built. Links up to Academy Command-Library.
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Diagnostics: verify battery

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Quick "is KALI01 built + safely isolated?" checks (`ADR-0032`). Break-fix → `Troubleshooting.md`. 🔴 The most important check is **isolation** — that the attacker box can't reach the lab except on a granted path (`POL-0001`).

## 1. Isolation (the safety check — run before + after every Game Day)
| Check | What to look for | Verified? |
|---|---|---|
| Internet-only | KALI01 reaches the internet | 📋 |
| No standing lab access | KALI01 **cannot** reach any lab VLAN by default (ping/scan refused) | 📋 |
| Path closed after test | after a Game Day, isolation is **restored** (the opened path is gone) | 📋 |

## 2. Host / toolset
| Check | What to look for | Verified? |
|---|---|---|
| VM up · VLAN 70 | `10.70.0.x`, VLAN 70; clean snapshot exists | 📋 |
| Tools updated | exploit/rule DBs current (record versions with evidence) | 📋 |

## 3. Validation wiring (per Game Day — evidence lives in the matrix)
| Control | The proof | Verified? |
|---|---|---|
| Tier-deny | Tier-2 cred refused at a Tier-0 object | 📋 |
| L2/switch | ARP-spoof dropped by DAI/port-security | 📋 |
| E-W + IPS | denied flow refused+logged; exploit dropped (FGT/PFSENSE01) | 📋 |
| PKI/ESC | AD CS abuse fails | 📋 |

## Related
- `Troubleshooting.md` · `Build-Guide.md` · `../../Operations/Validation-and-Adversarial-Testing.md` (the evidence home) · `ADR-0011`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the 📋 planned battery: **isolation** (internet-only, no standing lab access, path-closed-after-test) as the primary safety check + host/toolset + the per-control validation wiring. All 📋 until built. |
