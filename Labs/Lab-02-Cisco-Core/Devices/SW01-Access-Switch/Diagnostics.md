---
Title: SW01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch
Status: 🟡 Seeded (ADR-0032). SW01 = L2 access/distribution switch (Catalyst 2960X, IOS 15.x), mgmt SVI `10.10.0.2`. Pass-1 device-verified 07-22 → several ✅.
Version: 0.1
Date: 2026-07-28
---

# SW01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **SW01** — Role: L2 access/distribution (carries all VLANs to MKT01, does not route). Mgmt SVI `Vlan10 = 10.10.0.2`.

> **What this is (`ADR-0032`):** quick "is SW01 built/connected right?" checks. Break-fix → `Troubleshooting.md`; deep set → **Atlas Academy**. 🔴 Evidence = runtime `show` **status**, not `show run` (`POL-0001` R-A1). **Markers:** ✅ · 🟡 · ⏳ · 📋.

## 1. Installation / role verification
| Check | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| Pure L2 (no routing) | `show ip route` (or `show run \| i ip routing`) | no `ip routing`; L2 only | ✅ (07-22) | `ADR-0023` |
| SSHv2 + strong crypto | `show ip ssh` | v2.0; CTR ciphers; DH 2048 | ✅ (07-22) | `CIS-Hardening-SW01` §1 |
| Named admin only | `show run \| i username` | `ciscoadmin` priv 15; no generic `cisco` | ✅ (07-22) | CIS §2 |

## 2. Identity & addressing
| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Mgmt SVI up | `show ip interface brief` | `Vlan10 10.10.0.2 up/up`; `Vlan1 admin down` | ✅ (07-22) | CIS §5 |
| VLANs present | `show vlan brief` | VLANs 10,20,…,90,999 defined | 🟡 | — |
| Time synced | `show ntp status` / `show ntp associations` | `synchronized, stratum 3`, `*~10.20.0.2` (DC01) | ✅ (07-22, `CM-0030`) | `ADR-0020` |

## 3. Service-up checks
| Service | Command | Expected | Verified? |
|---|---|---|---|
| No cleartext mgmt | `show run \| i http\|telnet` | no `ip http server`, no telnet | ✅ (07-22) |
| SNMP (until MON01) | `show snmp community` | no v2c community present | ✅ (07-22) |
| DHCP snooping | `show ip dhcp snooping` | enabled (DAI deferred to NetBox, Phase 4) | 🟡 |

## 4. Inter-device link checks (reciprocal)
| Link | From SW01 | From the OTHER device | Expected | Verified? |
|---|---|---|---|---|
| ↔ MKT01 trunk (`Gi1/0/1`) | `show interfaces trunk` | `/interface print` on MKT01 | trunk up, VLANs allowed both ends | 🟡 |
| ↔ PVE01 trunk (`Gi1/0/4`) | `show interfaces Gi1/0/4 switchport` | `bridge vlan show` on PVE01 | trunk, native 999, VLANs tagged; DAI-trusted | 🟡 |
| ← mgmt host (VLAN 10) | `show ip arp` | ping `10.10.0.2` from `10.10.0.20` | reachable | ✅ (07-22) |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| Resolver reachable (mgmt) | `ping 10.20.0.2` | replies | 🟡 |

## 6. IP / connectivity entry points
| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| L1/L2 port + VLAN | `show interfaces status` | link/speed/VLAN per port | 🟡 |
| Port security / unused | `show run interface Gi1/0/3` | `Gi1/0/3` shut; `Gi1/0/7` = Pi01 (never shut) | 🟡 |
| MAC table | `show mac address-table` | expected MACs per VLAN/port | 🟡 |

## 7. Logging & event sources
| Source | How to view | Look for | Verified? |
|---|---|---|---|
| Local buffer | `show logging` | link flaps, DAI/port-security drops | 🟡 |
| Ships to MON01? | (Phase 6) | syslog once MON01 exists | 📋 |

## If you built or changed SW01 solo (ADR-0032)
Paste the `show` status read-backs (SSH/NTP/SVI/trunks) → flip 🟡→✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync.

## Related
- `Troubleshooting.md` (if present) · `CIS-Hardening-SW01.md` · `SW01/Build-Guide.md` · **Atlas Academy** `Concepts/` (DAI trust N2) · `Atlas-East-West-Allowed-Flows-Matrix.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Seeded (`ADR-0032`). ✅ marks Pass-1 device-verified facts (07-22: SSH crypto, named admin, VLAN1-down/SVI, NTP stratum-3, no cleartext/SNMP); trunks, DHCP-snooping/DAI, port status left 🟡. `show`-status-not-`show run` rule flagged. |
