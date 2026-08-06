---
Title: Command Library — Linux (PVE01; Pi01 / SRV01 / NetBox / MON01 forthcoming)
Path: Atlas-Academy/Command-Library
Status: 🟡 LIVING — EXPANDING (ADR-0032). PVE01 (Proxmox/Debian) is built and grounded; the Debian/Ubuntu service hosts (Pi01, SRV01, NetBox, MON01) fill in as they're built.
Version: 0.1
Date: 2026-07-28
---

# Command Library — Linux

<!-- provenance -->
> **Atlas Academy — Command Library.** How to verify the Linux estate. **Built today:** **PVE01** (Proxmox VE 8.4.19 / Debian 12) — fully grounded (`Virtualization/Build-Records/PVE01-Diagnostics.md`). **Forthcoming:** **Pi01** (Pi-hole DNS + chrony NTP), **SRV01** (nginx CRL host + Oxidized + rsyslog, Ubuntu), **NetBox**, **MON01** — their service sections are seeded and expand as each is built.

> 🔴 **Read-back rule:** the runtime view — `systemctl is-active`, `ip -br`, `ss -tlnp`, `journalctl` — not the unit/config file. A file says intent; `systemctl`/`ss` say reality.

## §Networking (all Linux hosts)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Addresses (brief) | `ip -br address` | the host's IP on the right iface/mask | wrong mask; IP on the wrong iface | IP plan |
| Routes | `ip route` | default via the VLAN gateway | no default / wrong gw | — |
| Listening sockets | `ss -tlnp` | only expected services listening | an unexpected open port | hardening |
| Link | `ethtool <if>` | 1 Gbps full-duplex, link up | 100 Mbps / down | — |
| Reachability | `ping -c4 <gw>` ; `mtr <dst>` ; `nc -vz <dst> <port>` | gw replies; TCP port open | timeout; ICMP-only (prove the real port) | — |

### PVE01 bridge / VLAN (Proxmox-specific)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Mgmt on tagged VLAN | `ip -br address` | `vmbr0.10 = 10.10.0.10/27`; bare `vmbr0`/`eno1` no L3 | IP on bare `vmbr0`/`eno1` (native-999 breaks it) | `PVE01-Networking` |
| 🔴 Uplink trunks VLANs | `bridge vlan show` | `eno1` **tagged** on 10–90,999 | `eno1` VLAN 1 only → tagged VM frames dropped (missing `bridge-vids`) | `204` §3 (Concept N2/N3) |

## §Services (systemd)
| Purpose | Command | Healthy | Broken looks like |
|---|---|---|---|
| Is it running | `systemctl is-active <svc>` ; `systemctl status <svc>` | `active (running)`, no recent restarts | `failed`/`inactive`; flapping |
| Enabled at boot | `systemctl is-enabled <svc>` | `enabled` | `disabled` (won't survive reboot) |
| Why it failed | `journalctl -u <svc> -e --no-pager` | clean start logs | the error + exit code |
| What a unit listens on | `ss -tlnp \| grep <port>` | the service bound to the expected port | not listening (crashed/misconfigured) |

## §Proxmox (PVE01)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Version / node | `pveversion` ; `pvecm status` | 8.4.19; node healthy | version drift | `217-Verified-Facts` |
| Storage | `pvesm status` | `local` + `local-lvm` active (~793 GiB) | a store `inactive` | — |
| VMs | `qm list` | DC01(101), build(100), `TPL-WIN2025`(9000), `TPL-UBUNTU2604` | a VM missing/locked | — |
| Web/API | `systemctl status pveproxy pvedaemon` | active; GUI `https://10.10.0.10:8006` | down (SSH is the substitute) | — |
| CPU truth | `grep -c '^flags.*vmx' /proc/cpuinfo` | **16** (not `egrep -c '(vmx\|svm)'`=32) | misread as 32 | Build-Record |

## §DNS — resolver + Pi-hole (Pi01, forthcoming)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Resolve (host) | `getent hosts <name>` ; `resolvectl query <name>` | resolves via the configured resolver | SERVFAIL/NXDOMAIN | — |
| Dig a record | `dig @<resolver> <name>` | `ANSWER` present | `status: SERVFAIL` | — |
| Pi-hole up (Pi01) 📋 | `pihole status` ; `systemctl status pihole-FTL` | blocking active; FTL running | FTL down (no DNS) | Pi01 build (forthcoming) |
| DoH/DNSSEC chain (Pi01) 📋 | `systemctl status dnscrypt-proxy-doh` | active (the custom unit) | socket-activation fallback failed | Concept (DNS chain) |

## §Time — chrony (Pi01/SRV01/NTP clients)
| Purpose | Command | Healthy | Broken looks like | Grounds |
|---|---|---|---|---|
| Sync state | `timedatectl` | `System clock synchronized: yes`, NTP active | not synchronized | `ADR-0020` |
| Sources | `chronyc sources -v` ; `chronyc tracking` | `^* ` on DC01 `10.20.0.2` | no selected source / large offset | `ADR-0020` |
| 🔴 PVE01 RTC caveat | `hwclock` after a power cycle | (still resets `2026`→`2018`, `CM-0012`) — keep on UPS; NTP holds it while up | — | `CM-0012` |

## §Web / CRL host (SRV01, forthcoming) 📋
| Purpose | Command | Healthy | Grounds |
|---|---|---|---|
| nginx serving `/pki/` | `curl -I http://pki.atlas.lab/pki/` | `200`; root `.crt`/`.crl` fetchable | AD-CS CDP (`ADR-0031`) |
| Cert trust (non-domain) | `openssl verify -CAfile <root>.crt <cert>` | `OK`, chains to Atlas Root CA | AD-CS Part 3B |

## §Logging / package integrity
| Purpose | Command | Healthy | Broken looks like |
|---|---|---|---|
| System journal | `journalctl -xe --no-pager` ; `journalctl -p err -b` | no repeating errors | service crashes, OOM, auth failures |
| Auth log | `journalctl -u ssh` ; `/var/log/auth.log` | expected logins | brute-force / unknown source |
| Updates applied | `apt list --upgradable` ; `dpkg -l <pkg>` | patched; expected versions | pending security updates |

## Related
- `Virtualization/Build-Records/PVE01-Diagnostics.md` + `PVE01-Networking.md` (the built Linux host) · `../Concepts/README.md` (N2 DAI, N3 RouterOS-v7/VLAN, DNS chain) · Pi01/SRV01 build docs (as they land).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-28. Created (`ADR-0032`) as the **expanding** Linux page. Fully grounded for **PVE01** (networking incl. the `bridge vlan show`/`bridge-vids` trap, systemd, Proxmox, chrony, the RTC/`CM-0012` caveat); **Pi01/SRV01/NetBox/MON01** service sections seeded 📋 to fill in as each host is built. |
