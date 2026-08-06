---
Title: SW01 Build Record
Path: Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch
---

# SW01 Build Record

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — reconciled to live 2026-07-16 (`056`); D10 closed. Residual device-side items raised: SPAN source (`CM-0036`), SNMP location string (`CM-0037`) |
| Version | 2.1 |
| Applies To | Atlas 2.0 |
| Last Live Verification | 2026-07-12 |
| Last Reconciled | 2026-07-14 |

## Platform

| Item | Value |
|---|---|
| Hardware | Cisco WS-C2960X-48FPS-L |
| IOS | 15.2(2)E6 |
| Live hostname | **SW01** — device-verified 2026-07-16 (`show version`; `CM-0022`) |
| Target hostname | SW01 |
| Management IP | 10.10.0.2/24 (VLAN 10 SVI) |
| Default gateway | 10.10.0.1 |
| Domain | lab.local |
| Console | 9600 baud, 8N1, no flow control |
| SFP ports | Gi1/0/49-52 |

## VLAN Database

| VLAN | Name | Status |
|---|---|---|
| 10 | Management | Active |
| 20 | Servers | Active |
| 30 | Web | Active |
| 40 | Monitoring | Active |
| 50 | Client | Active |
| 60 | Deployment | Active |
| 70 | Testing | Active |
| 80 | DMZ | Active |
| 999 | Unused | Active |

## Port Assignments (verified)

| Port | Description | Mode | Native VLAN | Tagged VLANs | State |
|---|---|---|---|---|---|
| Gi1/0/1 | Trunk-to-MKT01 | Trunk | 999 | 10,20,30,40,50,60,70,80,999 | Connected |
| Gi1/0/2 | LabComputer | Access | 10 | — | Connected |
| Gi1/0/3 | Disabled - pending device assignment, see ADR-0002 | Access | 10 *(VLAN membership unchanged, port administratively down)* | — | Disabled |
| Gi1/0/4 | PVE01 | Trunk | 10 | 10,20,30,40,50,60,70,80,999 | Connected |
| Gi1/0/5 | SPAN-Monitor-Port | Monitor | — | — | Not connected |
| Gi1/0/6 | FortiGate-Management | Access | 10 | — | Connected |
| Gi1/0/7 | Raspberry-Pi | Access | 10 | — | Connected (added this session) |
| Gi1/0/8-48 | Unused | Access | 999 | — | Disabled |
| Gi1/0/49-52 | Unused-SFP | — | — | — | Disabled |

## Spanning Tree

| Item | Value |
|---|---|
| Mode | Rapid PVST+ |
| Priority | 4096 (root bridge for all VLANs) |
| Root status | This bridge is the root |

## Layer 2 Security

| Feature | Status | Scope | Trusted Ports |
|---|---|---|---|
| DHCP Snooping | Enabled | VLANs 10-80 | Gi1/0/1 |
| ARP Inspection | Enabled | VLANs 10-80 | Gi1/0/1 |
| Storm Control | Enabled | All active ports | — |
| Port Security | Enabled | **Gi1/0/2, 3, 4, 7** — device-verified 2026-07-16 (max 2 on 2/3/7, max 16 on 4, violation restrict). 🔴 **`Gi1/0/7` = Pi01 was omitted from this row** — the same port that CM-0022 / `016` lesson 6 are about | — |
| BPDU Guard | Enabled | All non-trunk ports | — |
| Root Guard | Enabled | Gi1/0/1 | — |

## STATIC-HOSTS ARP Access List (applied to VLAN 10)

| IP | MAC (IOS format) | Device |
|---|---|---|
| 10.10.0.5 | 0000.5e00.5300 | **Pi01** |
| 10.10.0.10 | 0000.5e00.5313 | PVE01 eno1 |
| 10.10.0.50 | 0000.5e00.5316 | Admin workstation |
| 10.10.0.100 | 0000.5e00.5314 | iDRAC-PVE01 (shared LOM, not a dedicated NIC — see CM-0012) |
| 10.10.0.254 | 0000.5e00.5315 | FGT01 internal2 |

> 🔴 **CORRECTED 2026-07-13 (evening). This table was missing Pi01, and that omission propagated a false "mystery" across three session handoffs.**
>
> The live ACL (`show arp access-list STATIC-HOSTS`) lists **five** hosts. This record listed four — **Pi01 (`10.10.0.5`) was absent.** Reading this incomplete record, three consecutive handoffs asserted *"Pi01 is not in STATIC-HOSTS, so by SW01's own design it should be unreachable — and it isn't, and nobody knows why."*
>
> **There was no mystery. Pi01 is in the ACL and always was.** `show ip arp inspection statistics vlan 10` confirms the mechanism: `ACL Permits: 2594`, `DHCP Permits: 0` — every VLAN 10 host is permitted by this static ACL, and Pi01 is on it.
>
> **The document was wrong; the device was right; nobody ran `show arp access-list` until now.** Charter Rule 13. This is the same failure the whole session has been finding, applied to a firewall control that was working correctly the entire time.
>
> **Note for a rebuild:** all five entries below are required. A rebuild that omits Pi01 — as this record did — would leave Pi01's ARP dropped once DHCP snooping has no binding for it, which is a real outage. The device is the source of truth for this table, not this page.

## SPAN

| Item | Value |
|---|---|
| Session 1 source | 🔴 **NOT configured on the live device** (2026-07-16). `023`/`027` intend `Gi1/0/1` both, but the running config has only the destination line — **the monitor port mirrors nothing.** Re-add the source or accept it idle: `CM-0036`. |
| Session 1 destination | Gi1/0/5 (present on the device) |

## Management Access

| Item | Value |
|---|---|
| Local user | cisco (privilege 15) |
| SSH | Port 22, requires legacy algorithm flags |
| VTY access-class | MGMT-ACCESS (permits 10.10.0.0/24, 10.0.0.0/24) |
| exec-timeout | 10 minutes |

SSH connection from Windows:
```text
ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa -oMACs=+hmac-sha1 cisco@10.10.0.2
```

## SNMP and NTP

| Item | Value |
|---|---|
| SNMP community | homelab (ro) |
| SNMP host | 10.40.0.52 |
| NTP server | `10.10.0.5` (Pi01, interim) — 🔴 **configured but never synced; `show ntp status` = stratum 16, `never updated`** (`CM-0030`; decision `ADR-0020`) |
| Timezone | CST -6, CDT recurring |

## Known Deviations

| Item | Target | Current | Action |
|---|---|---|---|
| ~~Hostname~~ | SW01 | ✅ **`SW01`** — device-verified 2026-07-16 (`show version`; `CM-0022`) | **Closed.** Renamed long ago; the deviation was stale (`027` had built the old name as the target). |
| NTP | Windows Server AD hierarchy (PDC emulator) | 🔴 `10.10.0.5` (Pi01) — **configured but never synced, stratum 16** | Decision recorded `ADR-0020`; interim fix + proof tracked in `CM-0030` |
| Gi1/0/4 link (PVE01) | Up, 1 Gbps | 🔴 **`down/down` on 2026-07-16** — PVE01 uplink not up (earlier confirmed 1 Gbps post-reboot; transient 100 Mbps before that) | Confirm PVE01 is powered/cabled; relevant to the PVE01 reconcile (`057` row 8, `024`) |
| Admin workstation MAC in STATIC-HOSTS | Permanent entry | 0000.5e00.5316 (current) | Update if workstation hardware changes |
| Gi1/0/1 port description | Trunk-to-MKT01 | ✅ **Trunk-to-MKT01** | ✅ **Closed — `CM-0001`.** Its closeout confirmed live: Gi1/0/1 shows `Trunk-to-MKT01`. The stale description was corrected on the device; this record was the last copy still showing the old label. ✅ **DEVICE CHECK D10 confirmed 2026-07-16** — live config shows `description Trunk-to-MKT01`. |
| Gi1/0/3 VLAN | 50 (Client) — per Source of Truth | Resolved — port disabled via CM-0003, see ADR-0002 | Closed. Neither VLAN was chosen; port administratively shut down since nothing was connected. Revisit when a real device is assigned. |

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Initial verified record; STATIC-HOSTS corrected to five hosts (Pi01 added). |
| 2.1 | 2026-07-14 reconciliation batch (051 Tier 3, B6). Gi1/0/1 port description corrected to `Trunk-to-MKT01` per `CM-0001` (confirmed live); deviation closed. **Not changed here (out of this batch's scope):** the live cleartext SNMP community `homelab` (Tier 2 — redact *after* rotation, `CM-0023` to raise); the NTP server pointing at a host that serves no NTP (`016` lesson 16 / `CM-0030`, D11); the SNMP trap host `10.40.0.52`; and the `lab.local` domain (a third domain name — operator decision). The `Live hostname CoreSwitch` field conflicts with `016`'s 2026-07-14 device pass (which reports the hostname as already `SW01`) — flagged for the operator, not edited. |
| 2.2 | 🟢 **2026-07-16 — SW01 reconcile-to-live (`056`/`057`) + CoreSwitch sweep.** `Live hostname` and the hostname deviation **closed** — device-verified `hostname SW01` (`show version`; `CM-0022`); this record held the last live copy still asserting the old name. NTP rows updated: the switch is pointed at Pi01 and **has never synced** (stratum 16, `CM-0030`), with the time-source decision now recorded in **`ADR-0020`** (AD PDC-emulator target; external-pool interim). **Not changed here (still gated):** the live cleartext SNMP community (redact *after* rotation, `CM-0023`); the trap host `10.40.0.52`; the SPAN session with a destination but no source (`057` row 3); and the live `Home-Lab-California` location string (`057` row 8). |
| 2.3 | 🟢 **2026-07-16 — full reconcile against the live `056` run.** Corrected three device mismatches this record still carried after the hostname/NTP pass: **port-security scope** now lists `Gi1/0/7` (Pi01), which was omitted — the same port CM-0022 / `016` lesson 6 warn about; the **SPAN** row now states the live device has **no source** (only the destination), so the monitor port mirrors nothing — raised as **`CM-0036`**; the **`Gi1/0/4`** row now reflects the link reading **down** on 2026-07-16, not a confirmed 1 Gbps. **DEVICE CHECK D10 closed** — `Gi1/0/1` shows `Trunk-to-MKT01` live. The still-live SNMP `location` string is raised as **`CM-0037`**. |
