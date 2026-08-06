---
Title: Pi01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP
Status: 📋 Seeded (`ADR-0032`). Pi01 = physical Pi, VLAN 10, `10.10.0.6` (📋 proposed). Commands authored from docs; **📋 not built** — every row 🟡/📋 until a read-back is pasted. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-30
---

# Pi01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 rebuild)** — Host: **Pi01** (Raspberry Pi OS Lite, bare-metal) — Role: Pi-hole filtering DNS + chrony NTP (`ADR-0003`/`ADR-0020`).

> **What this is (`ADR-0032`):** the quick "is Pi01 built + does it actually resolve and sync?" checks. The distinctive Pi01 discipline is proving **resolution and sync from the service's own status** — not a config line, not a file's contents (the `custom.list` trap), not `systemctl` presence (the timesyncd trap). Break-fix → `Troubleshooting.md`; the deep set → Academy `Atlas-Academy/Command-Library/Linux.md`.

## 1. Host / identity
| Check | Command | Expected (healthy) | Verified? |
|---|---|---|---|
| OS / form factor | `cat /etc/os-release` · `cat /proc/device-tree/model` | Raspberry Pi OS Lite 64-bit · physical Pi | 📋 |
| Hostname / IP / VLAN | `hostnamectl` · `ip a` | `pi01` · `10.10.0.6` /27 · gw `10.10.0.1` (proposed) | 📋 |
| Host firewall | `nft list ruleset` (or `ufw status`) | inbound **53/123/22 only** | 📋 |

## 2. NTP — chrony (NOT timesyncd)
| Check | Command | Expected | Verified? |
|---|---|---|---|
| 🔴 chrony is the daemon | `systemctl status chrony` + `systemctl is-active systemd-timesyncd` | chrony active; timesyncd **inactive/masked** | 📋 |
| Actually synchronized | `chronyc tracking` | Leap Normal; sane reference + offset (not "Not synchronised") | 📋 |
| Upstream sources | `chronyc sources` | reachable source(s) per the `ADR-0020` hierarchy | 📋 |

## 3. DNS — Pi-hole + conditional-forward
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Pi-hole up | `pihole status` | active; blocking enabled | 📋 |
| `atlas.lab` conditional-forward | `dig @10.10.0.6 <host>.atlas.lab` | resolves **via the DCs** (not NXDOMAIN) | 📋 |
| External name | `dig @10.10.0.6 example.com` | resolves; a known-ad domain is filtered | 📋 |
| 🔴 Local record resolves | `dig @10.10.0.6 <local-record>` | **resolves** — proves `dnsmasq.d` is live, not the inert `custom.list` | 📋 |

## 4. Migration-off confirmation (the reduction)
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| No RADIUS/Vault/CA here | `ss -tlnp` + grep old configs | none listening; nothing points at Pi01 for them (`ADR-0009`) | 📋 |
| No DHCP here | `ss -ulnp | grep :67` | nothing — DHCP is on DC01 (`ADR-0030`) | 📋 |

## 5. Inter-device link checks
| Link | From Pi01 | Expected | Verified? |
|---|---|---|---|
| → gateway | `ping 10.10.0.1` | MKT01 VLAN-10 gw reachable | 📋 |
| → DC (forward target) | `dig @<DC-IP> <host>.atlas.lab` | DC answers (the conditional-forward target works) | 📋 |
| → upstream time | `chronyc sources` | upstream reachable/selected | 📋 |

## If you built or changed Pi01 solo (`ADR-0032`)
Paste the read-backs (`chronyc tracking` synced, `systemctl status chrony`, `pihole status`, the `dig` for `atlas.lab` + external + a local record) so the next session can advance 📋/🟡 rows as read-backs land; mirror into `SESSION-HANDOFF.md` → Solo-work sync + `../../Operations/Device-Confirmation-Commands.md`.

## Related
- `Troubleshooting.md` (break-fix) · `Build-Checklist.md` (the scars) · Academy `Atlas-Academy/Command-Library/Linux.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md` · `ADR-0020`/`ADR-0003`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Seeded from the `Diagnostics-Show-Commands-Template` (`ADR-0032`) for Pi01: host/identity + firewall, the chrony-not-timesyncd + `chronyc tracking`/`sources` sync proof, the Pi-hole `atlas.lab` conditional-forward + external + **local-record-resolves** (anti-`custom.list`) checks, the migration-off/no-DHCP confirmation, and the gw/DC/upstream links. All 📋; flips on read-back (`POL-0001`). |
