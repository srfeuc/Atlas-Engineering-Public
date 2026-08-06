---
Title: PVE01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Records
Status: 🟡 Seeded (ADR-0032). PVE01 = Proxmox VE 8.4.19 hypervisor, mgmt tagged `vmbr0.10 = 10.10.0.10/27`. Networking device-verified 2026-07-24 → several ✅.
Version: 0.1
Date: 2026-07-28
---

# PVE01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **PVE01** (Dell R410, Proxmox VE 8.4.19). Mgmt **tagged VLAN 10** on `vmbr0.10 = 10.10.0.10/27`; uplink `eno1` → SW01 `Gi1/0/4` (trunk, native 999). Authoritative networking state: `PVE01-Networking.md` (`ADR-0034`).

> **What this is (`ADR-0032`):** quick "is PVE01 built/connected right?" checks. Deep state → `PVE01-Networking.md` (Build-Record); the frozen Lab-01 `Build-Record-Network` is the pre-07-24 snapshot. 🔴 **iDRAC is shared-LOM on `eno1` — NOT out-of-band; the physical console is the real bootstrap.** **Markers:** ✅ · 🟡 · ⏳ · 📋.

## 1. Installation / role verification
| Check | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| PVE version / node up | `pveversion` / `pvecm status` | 8.4.19; node healthy (single node) | 🟡 | `217-Verified-Facts` |
| Logical CPUs (not 32) | `grep -c '^flags.*vmx' /proc/cpuinfo` | **16** (NOT `egrep -c '(vmx\|svm)'`=32 on kernel 6.8) | ✅ (07-16) | Build-Record |
| VT-x / KVM active | `lsmod \| grep kvm` | `kvm_intel` + `kvm` loaded | ✅ (07-16) | — |
| Storage | `pvesm status` | `local` + `local-lvm` active (~793 GiB pool) | ✅ (07-16) | — |

## 2. Identity & addressing (the current tagged-VLAN design)
| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Mgmt IP on `vmbr0.10` | `ip -br address` | `vmbr0.10 = 10.10.0.10/27`; **bare `vmbr0` + `eno1` = no L3** | ✅ (07-24) | `PVE01-Networking` |
| Default route | `ip route` | default via `10.10.0.1` | ✅ (07-24) | — |
| Uplink trunks all VLANs | `bridge vlan show` | `eno1` tagged on 10,20,…,90,999 (not VLAN 1 only) | 🟡 | `204` §3 (`bridge-vids`) |
| Link speed | `ethtool eno1` | 1 Gbps full-duplex, link up | ✅ (07-24) | — |

## 3. Service-up checks
| Service | Command | Expected | Verified? |
|---|---|---|---|
| Web GUI / API | `systemctl status pveproxy pvedaemon` | active; GUI on `https://10.10.0.10:8006` | 🟡 |
| VMs present | `qm list` | DC01(101), build-archive(100), `TPL-WIN2025`(9000); `TPL-UBUNTU2604` template | 🟡 |
| Time (RTC caveat) | `timedatectl` / `chronyc sources` | synced; 🔴 RTC resets on power loss (`CM-0012`) — keep on UPS | 🟡 |

## 4. Inter-device link checks (reciprocal)
| Link | From PVE01 | From the OTHER device | Expected | Verified? |
|---|---|---|---|---|
| ↔ SW01 trunk (`Gi1/0/4`) | `bridge vlan show` | `show interfaces Gi1/0/4 switchport` on SW01 | trunk native 999, VLANs tagged both ends | 🟡 |
| ← gateway (MKT01) | `ping -c4 10.10.0.1` | ping `10.10.0.10` from a mgmt host | reachable | ✅ (07-24) |
| Tagged VM path | put a VM on VLAN 70 → generate cross-VLAN | MKT01 `/log` shows `EAST-WEST-DENIED` | tagged frame reaches the router | ✅ (07-24) |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| Resolver / internet | `ping -c4 1.1.1.1` ; `getent hosts <name>` | reachable | ✅ gw+internet (07-24) |

## 6. IP / connectivity entry points
| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| L2/VLAN membership | `bridge vlan show` | `eno1` tagged VLAN set (the #1 "VLANs configured but don't work" check) | 🟡 |
| L3 addr/route | `ip -br a` / `ip route` | mgmt on `vmbr0.10`, default via gw | ✅ (07-24) |
| iDRAC (shared-LOM caveat) | `https://10.10.0.100` | reachable **only while SW01+Gi1/0/4 up** — not a teardown path | 🟡 |

## 7. Logging & event sources
| Source | How to view | Look for | Verified? |
|---|---|---|---|
| System journal | `journalctl -xe` / `journalctl -u pve*` | service errors, network apply | 🟡 |
| Task log | GUI → node → Tasks | clone/backup/config task results | 🟡 |
| Ships to MON01? | (Phase 6) | rsyslog once MON01 exists | 📋 |

## If you built or changed PVE01 solo (ADR-0032)
Paste `ip -br a` / `bridge vlan show` / `pvesm status` read-backs → flip 🟡→✅; update `PVE01-Networking.md` (the SoT) and mirror into `SESSION-HANDOFF.md` → Solo-work sync.

## Related
- **`PVE01-Networking.md`** (authoritative networking state, `ADR-0034`) · `Virtualization/Build-Guides/204-Proxmox-Networking.md` (procedure) · frozen Lab-01 `PVE01-Hypervisor/Build-Record-Network.md` (pre-07-24 snapshot) · **Atlas Academy** `Concepts/` (VLAN/802.1Q, DAI N2) · `036-PVE01-Troubleshooting-Guide.md` (if present).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Seeded (`ADR-0032`) alongside the `PVE01-Networking` Build-Record. ✅ marks the 2026-07-24 device-verified networking (tagged `vmbr0.10 /27`, no-L3 `vmbr0`/`eno1`, default route, 1 Gbps, gw+internet, tagged-VM path) and the 07-16 platform facts (16 logical CPUs, KVM, storage); GUI/VM/`bridge vlan show`/iDRAC left 🟡. iDRAC shared-LOM + RTC/`CM-0012` caveats carried. |
