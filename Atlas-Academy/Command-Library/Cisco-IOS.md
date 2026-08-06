---
Title: Command Library — Cisco IOS (CCNA 200-301 v1.1 · SW01, 1941)
Path: Atlas-Academy/Command-Library
Status: 🟢 LIVING (`ADR-0032`). **v3 rebuild COMPLETE (#44)** — the whole-blueprint expansion reference for the Cisco IOS estate (SW01 · 1941), organised by the six CCNA 200-301 v1.1 domains. **All six CCNA 200-301 v1.1 domains built to v3.** The v1.0 service tables have been fully migrated into the domains; Appendix A is now a pointer map (`ADR-0012`/`POL-0008`).
Version: 3.5
Date: 2026-08-05
---

# Command Library — Cisco IOS (SW01 · 1941)

<!-- provenance -->
> **Atlas Academy — Command Library (the expansion layer).** The Academy feeds on the device docs and **expands what they summarise**: the terse `Diagnostics.md` quick-refs link *up* here; this page holds the full per-objective detail. Cisco IOS estate: **SW01** (Catalyst 2960X, pure L2, mgmt SVI `Vlan10 10.10.0.2`) and **1941** (ISR G2 core router, IOS 15.5(3)M4; no SVI — reached via loopback `10.255.0.1` / transit /30s). This v3 rebuild reorganises the library to cover the **entire CCNA 200-301 v1.1 blueprint**, numbered like the exam, so it doubles as a study spine and the reverse-index target for the `Certification/CCNA/` sub-pages.

> 🔴 **Read-back rule (`POL-0001` R-A1):** evidence is the runtime **`show … status`**, not `show run`. `show run` shows *intent*; it hid a dynamic state once. Where a runtime read exists, use it. 🔴 **1941 legacy SSH:** a modern OpenSSH client must offer legacy algorithms (`KexAlgorithms +diffie-hellman-group14-sha1`, `HostKeyAlgorithms +ssh-rsa`, `MACs +hmac-sha1` in `~/.ssh/config`) — the ISR image can't speak modern SSH ([`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md)).

> 📒 **Sourcing (`#44`, in priority):** the operator's Cisco notes (real commands + worked examples) → the device [Build-Guides](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md)/Records (real Atlas values + the real gotchas → the *Breaks-when* line) → the blueprint (structure). Course material (Flackbox / the operator's notes) is a commands-and-context reference to **fill gaps, not a template** — Atlas lifts the factual command + the `show`-output pattern, then writes the entry in its own voice; **paraphrase only, never reproduce course prose** (Charter Rule 16 / copyright).

---

## On this page

Jump to any objective. Grounding: **✅** device-verified · **🟡** partial · **📘** build gap · **📋** pending.

**Domain 1 — Network Fundamentals (20%)** — built to v3

[1.1 Network components](#11--explain-the-role-and-function-of-network-components) 📘 · [1.2 Topology architectures](#12--describe-characteristics-of-network-topology-architectures) 📘 · [1.3 Interfaces & cabling](#13--compare-physical-interface-and-cabling-types) 🟡 · [1.4 Interface & cable issues](#14--identify-interface-and-cable-issues-collisions-errors-duplexspeed) ✅ · [1.5 TCP vs UDP](#15--compare-tcp-to-udp) 📘 · [1.6 IPv4 addressing & subnetting](#16--configure-and-verify-ipv4-addressing-and-subnetting) ✅ · [1.7 Private IPv4](#17--describe-private-ipv4-addressing) ✅ · [1.8 IPv6 addressing](#18--configure-and-verify-ipv6-addressing-and-prefix) 📘 · [1.9 IPv6 address types](#19--describe-ipv6-address-types) 📘 · [1.10 Client-OS IP params](#110--verify-ip-parameters-for-client-os-windows-macos-linux) 🟡 · [1.11 Wireless principles](#111--describe-wireless-principles) 📘 · [1.12 Virtualization](#112--explain-virtualization-fundamentals-vms-containers-vrfs) 🟡 · [1.13 Switching concepts](#113--describe-switching-concepts-mac-learningaging-frame-switching-flooding-mac-table) ✅

**Domain 2 — Network Access (20%)** — built to v3

[2.1 VLANs](#21--configure-and-verify-vlans-normal-range-spanning-switches) ✅ · [2.2 Trunking / 802.1Q](#22--configure-and-verify-interswitch-connectivity-trunks-8021q-native-vlan) ✅ · [2.3 CDP & LLDP](#23--configure-and-verify-cdp-and-lldp) 🟡 · [2.4 EtherChannel](#24--configure-and-verify-etherchannel-lacp) 📘 · [2.5 RPVST+ STP](#25--interpret-rapid-pvst-spanning-tree-protocol) 🟡 · [2.6 Wireless architectures](#26--describe-cisco-wireless-architectures-and-ap-modes) 📘 · [2.7 WLAN infrastructure](#27--describe-physical-infrastructure-connections-of-wlan-components) 📘 · [2.8 Device management access](#28--describe-network-device-management-access) ✅ · [2.9 WLAN GUI config](#29--interpret-the-wireless-lan-gui-configuration) 📘

**Domain 3 — IP Connectivity (25%)** — built to v3

[3.1 Routing-table components](#31--interpret-the-components-of-the-routing-table) ✅ · [3.2 Forwarding decision](#32--how-a-router-makes-a-forwarding-decision-longest-match-ad-metric) ✅ · [3.3 Static & floating routes](#33--configure-and-verify-ipv4-and-ipv6-static-routing) 🟡 · [3.4 Single-area OSPFv2](#34--configure-and-verify-single-area-ospfv2) ✅ · [3.5 FHRP](#35--first-hop-redundancy-protocols-fhrp) 📘

**Domain 4 — IP Services (10%)** — built to v3

[4.1 NAT (static/pool/PAT)](#41--configure-and-verify-inside-source-nat-static-and-pools) 🟡 · [4.2 NTP](#42--configure-and-verify-ntp-client-and-server) ✅ · [4.3 DHCP & DNS role](#43--explain-the-role-of-dhcp-and-dns) ✅ · [4.4 SNMP](#44--explain-the-function-of-snmp) 🟡 · [4.5 Syslog](#45--syslog-features-facilities-and-severity-levels) 🟡 · [4.6 DHCP client & relay](#46--configure-and-verify-dhcp-client-and-relay) 🟡 · [4.7 QoS PHB](#47--forwarding-per-hop-behavior-phb-for-qos) 📘 · [4.8 SSH remote access](#48--configure-remote-access-using-ssh) ✅ · [4.9 TFTP/FTP](#49--tftpftp-capabilities) 🟡

**Domain 5 — Security Fundamentals (15%)** — built to v3

[5.1 Security concepts](#51--key-security-concepts-threats-vulnerabilities-exploits-mitigation) 📘 · [5.2 Program elements](#52--security-program-elements-awareness-training-physical-access) 📘 · [5.3 Local password control](#53--device-access-control-using-local-passwords) ✅ · [5.4 Password policy](#54--password-policy-elements-complexity-mfa-certificates-biometrics) 📘 · [5.5 IPsec VPNs](#55--ipsec-remote-access-and-site-to-site-vpns) 📘 · [5.6 ACLs](#56--configure-and-verify-access-control-lists-acls) ✅ · [5.7 Layer 2 security](#57--layer-2-security-dhcp-snooping-dynamic-arp-inspection-port-security) ✅ · [5.8 AAA](#58--aaa-authentication-authorization-accounting) 🟡 · [5.9 Wireless security](#59--wireless-security-protocols-wpa-wpa2-wpa3) 📘 · [5.10 WLAN WPA2-PSK](#510--configure-a-wlan-with-wpa2-psk-gui) 📘

**Domain 6 — Automation & Programmability (10%)** — built to v3

[6.1 Automation impact](#61--how-automation-impacts-network-management) 🟡 · [6.2 Traditional vs controller](#62--traditional-vs-controller-based-networking) 📘 · [6.3 SDN architecture](#63--controller-based-software-defined-architecture-overlay-underlay-fabric) 📘 · [6.4 AI/ML in netops](#64--ai-and-machine-learning-in-network-operations) 📘 · [6.5 REST APIs](#65--characteristics-of-rest-based-apis) 🟡 · [6.6 Config-mgmt (Ansible)](#66--configuration-management-mechanisms-ansible-terraform) 🟡 · [6.7 JSON](#67--components-of-json-encoded-data) 🟡

> ✅ **All six domains built — the v3 rebuild is complete.**

> This **On-this-page** index is part of the locked v3 template — each domain build appends its objectives here.

---

## How this page is organised

Every objective is written to one **v3 shape**, numbered like the blueprint (`1.6`, `1.6.1`):

- **What** — one or two lines: what the objective is and why it matters in Atlas.
- **Config** — the commands, **one per bullet** (the operator types device config — Charter Rule 17).
- **Verify** — the runtime read-back, bulleted, **with a worked example** (command → healthy output).
- **🔴 Breaks when** — the real failure mode (sourced from the Build-Guide gotchas + the incident record).
- **🔗 Depends on / Flow** — the service interdependencies (what this leans on, what leans on it).
- **📄 Expands** — the device doc this entry deepens (the Academy is the expansion of the terse device page).
- **Grounding** — **✅ device-verified** (a real Atlas read-back exists) · **🟡 partial** (some of it verified / operator-reported) · **📘 study-reference** (a CCNA point Atlas doesn't run yet — a build gap, marked not hidden).

Heavy `━━━` dividers separate objectives. Domain banners use `═══`.

### Top index — the six CCNA 200-301 v1.1 domains

| # | Domain | Weight | Where it lives on IOS | Status |
|---|---|---|---|---|
| **1** | **Network Fundamentals** | 20% | components, cabling, IPv4/IPv6 addressing, switching concepts | ✅ **built to v3 (this section)** |
| 2 | Network Access | 20% | VLANs, trunking, CDP/LLDP, EtherChannel, STP, wireless | ✅ **built to v3** |
| 3 | IP Connectivity | 25% | routing table, static, OSPFv2, FHRP | ✅ **built to v3** |
| 4 | IP Services | 10% | NAT, NTP, DHCP, SNMP, syslog, QoS, TFTP | ✅ **built to v3** |
| 5 | Security Fundamentals | 15% | ACLs, port-security, DHCP-snooping, DAI, AAA | ✅ **built to v3** |
| 6 | Automation & Programmability | 10% | REST/JSON, config-mgmt, Ansible-from-NetBox | ✅ **built to v3** |

> Sibling platform pages (same v3 rebuild to follow): [`RouterOS.md`](./RouterOS.md) (MKT01) · [`FortiOS.md`](./FortiOS.md) (FGT01) · [`PowerShell-Tier0.md`](./PowerShell-Tier0.md) · [`Linux.md`](./Linux.md). Master index: [`README.md`](./README.md). Study map: [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md).

<br>

═══════════════════════════════════════════════════════════════════════════════
## ═══ DOMAIN 1 — NETWORK FUNDAMENTALS (20%)
═══════════════════════════════════════════════════════════════════════════════

> Grounded in the real Cisco boxes: **1941** (ISR G2 router) and **SW01** (2960X L2 switch). Objectives 1.1–1.13. IPv6 (1.8/1.9) and wireless (1.11) are **build gaps** — marked 📘, not skipped.

### 1.1 — Explain the role and function of network components

**What.** Name each component class and the real Atlas box that plays it: **router** = 1941 (ISR G2) / MKT01 (RouterOS); **L2/L3 switch** = SW01 (2960X, L2); **next-gen firewall / IPS** = FGT01 (FortiGate 60E) + PFSENSE01 (Suricata IPS); **access point** = FortiAP (owned, not yet in lab); **controller** = none (FortiAP is Fortinet-managed, no Cisco WLC); **endpoints** = the VLAN-50 clients / Pi01; **servers** = DC01/DC02, NPS01, the member fleet; **PoE** = the 2960X's PoE ports.

**Config.** — (identification objective; no IOS config.)

**Verify.**
- `show version` on the 1941 → the platform + IOS train that fixes its role.
  - Worked read-back: `Cisco IOS Software, C1900 … Version 15.5(3)M4 … cisco CISCO1941/K9`.
- `show version` on SW01 → `WS-C2960X-…`, confirming an L2 switch, not a router.

**🔴 Breaks when.** You treat the **SG300** (Small Business OS) or **MKT01** (RouterOS) as IOS — same concepts, different CLI; the exam grades **Cisco IOS**. The 1941 is the only real IOS *router* in the estate.

**🔗 Depends on / Flow.** The estate role-split: endpoint → SW01 (access/L2) → 1941 (route/L3) → FGT01 (perimeter) → internet.

**📄 Expands.** [`Lab-02-Device-Role-Assignments`](../../Labs/Lab-02-Cisco-Core/Architecture/Lab-02-Device-Role-Assignments.md) · [`Atlas-Service-Architecture`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-Service-Architecture.md).

**Grounding.** 📘 study-reference (the `show version` identification is ✅ device-verified 07-22).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.2 — Describe characteristics of network topology architectures

**🏅 Cert.** [`CCNA Ch18 (Vol 2) — LAN Architecture`](../Certification/CCNA/Vol2/Ch18-LAN-Architecture.md).

**What.** Atlas is a **collapsed-core / SOHO**: no distinct distribution tier — SW01 (access) hands straight to the 1941/MKT01 core. Contrast the exam's other shapes: two-tier (collapsed core + access), three-tier (access/distribution/core), spine-leaf (data-centre), WAN, and **on-prem + cloud** (Atlas is hybrid — on-prem AD synced to Entra, [`ADR-0040`](../../00-Atlas-Foundation/Decisions/ADR-0040-Entra-Connect-Password-Hash-Sync.md)).

**Config.** — (architecture objective; no IOS config.)

**Verify.**
- `show cdp neighbors` reads the physical topology — **but CDP is disabled on the 1941** (`no cdp run`, a hardening choice), so use LLDP or the cabling map there.
  - Worked read-back (SW01): `Device ID  Local Intrfce  …  Platform  Port ID` listing MKT01 / 1941 / PVE01.
- `show ip route` on the 1941 → the point-to-point core: two transit `/30`s, no distribution layer.

**🔴 Breaks when.** You call Atlas "three-tier" — it has **no distribution layer**; it is collapsed-core/SOHO. Misreading the tier count is a classic exam trap.

**🔗 Depends on / Flow.** The hybrid edge: on-prem AD ⇄ Entra ID via Entra Connect (the "on-prem + cloud" objective, live in the estate).

**📄 Expands.** [`Atlas-Service-Architecture`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-Service-Architecture.md) · [`Cabling-and-Port-Map`](../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md).

**Grounding.** 📘 study-reference.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.3 — Compare physical interface and cabling types

**What.** Copper (Cat-x, shared-media historically, now point-to-point switched), single-mode / multimode fibre, and the connection models (shared vs point-to-point). Atlas is **all copper gigabit** today — fibre is study-only here.

**Config.**
- `interface GigabitEthernet0/0` — enter interface config
- `description ->MKT01 transit /30` — locally-significant label

**Verify.**
- `show interfaces GigabitEthernet0/0` → media, duplex, speed, error counters.
  - Worked read-back: `GigabitEthernet0/0 is up, line protocol is up … Full-duplex, 1000Mb/s, media type is RJ45`.
- `show interfaces status` on SW01 → the `Type` column per port (e.g. `10/100/1000BaseTX`).

**🔴 Breaks when.** ISR G2 interfaces are **admin-down by default** — forget `no shutdown` and the port is `administratively down` (the 1941 Build-Guide Stage 2 gotcha). A copper run in the wrong port shows `notconnect`.

**🔗 Depends on / Flow.** L1 underpins everything above — always test link/speed/duplex first (the L1→up discipline).

**📄 Expands.** [`Cabling-and-Port-Map`](../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md) · [`1941 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 2.

**Grounding.** 🟡 partial (copper 1G ✅ verified; fibre types 📘 not present in the estate).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.4 — Identify interface and cable issues (collisions, errors, duplex/speed)

**What.** Read the counters that reveal a physical fault: CRC/runts (bad cable/duplex), collisions (half-duplex), late collisions (**the duplex-mismatch signature**), input errors.

**Config.**
- `duplex auto` / `speed auto` — the safe default; a *forced* setting on one end only is how you create a mismatch to observe

**Verify.**
- `show interfaces GigabitEthernet0/0` → the counter block.
  - Worked read-back (healthy): `0 runts, 0 giants, 0 CRC … 0 collisions, 0 late collision`.
  - Worked read-back (duplex mismatch): rising `CRC`, `runts`, and **`late collision`** on the full-duplex side while the link still reads `up/up`.
- `show interfaces status` → `err-disabled` / `notconnect` flags.

**🔴 Breaks when.** One end auto-negotiates and the other is **hard-set** → duplex mismatch: link "up," throughput collapses, late collisions climb. It reads as an application problem but it's L1.

**🔗 Depends on / Flow.** A cabling/duplex fault masquerades as an upper-layer outage — this is why the [`Trace-a-Blocked-Flow`](../Playbooks/Trace-a-Blocked-Flow.md) discipline starts at L1.

**📄 Expands.** [`SW01 Diagnostics`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) §6 · Playbook [`Test-a-Connection`](../Playbooks/Test-a-Connection.md).

**Grounding.** ✅ device-verified (the `show` commands); the mismatch scenario 🟡 (reproduce-on-demand).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.5 — Compare TCP to UDP

**🏅 Cert.** [`CCNA Ch5 (Vol 2) — TCP/IP Transport & Applications`](../Certification/CCNA/Vol2/Ch05-Introduction-to-TCP-IP-Transport-and-Applications.md).

**What.** TCP = connection-oriented, ordered, acknowledged (443/636/22); UDP = connectionless, best-effort (53/123/161). It matters for **how you verify a service**.

**Config.** — (protocol concept; no IOS config.)

**Verify.**
- On IOS, `telnet <dst> <port>` is a crude **TCP-open** test — a SYN/ACK proves the port is listening.
  - Worked example: `telnet 10.20.0.2 443` → `Open` = the TCP service answered; `Connection refused`/timeout = it did not.
- `ping <dst>` tests **ICMP only** — a different thing entirely.

**🔴 Breaks when.** The **`015` trap**: a successful `ping` proves the host answers ICMP — **not** that a TCP service (443/636) is open. Always prove the *real* protocol.

**🔗 Depends on / Flow.** Underlies every connectivity test in the estate: ICMP ≠ TCP ≠ UDP.

**📄 Expands.** Playbook [`Test-a-Connection`](../Playbooks/Test-a-Connection.md) (the `015` ICMP-vs-service trap).

**Grounding.** 📘 study-reference (the `telnet`-port TCP test is ✅ used in the estate).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.6 — Configure and verify IPv4 addressing and subnetting

**What.** Assign an IPv4 address + mask to an interface, and read it back. Atlas is a **real VLSM exercise**: each VLAN is sized to need (`10.<vlan>.0.0` — VLAN 10 `/27`, VLAN 20 `/26`, VLAN 50 `/25`, …); the router-to-router transits are `/30`s; the 1941 loopback is a `/32`.

**Config.** *(real 1941 transit values — [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md))*
- `interface GigabitEthernet0/0` — the MKT01 transit
- `description ->MKT01 transit /30`
- `ip address 10.255.255.5 255.255.255.252` — a `/30`: two usable hosts (`.5`/`.6`)
- `no ip proxy-arp` — a transit doesn't proxy
- `no shutdown`
- `interface loopback 0` → `ip address 10.255.0.1 255.255.255.255` — the router-id / stable address (`/32`)

**Verify.**
- `show ip interface brief` → address + status per interface.
  - Worked read-back: `GigabitEthernet0/0  10.255.255.5  YES manual up  up` · `Loopback0  10.255.0.1  YES manual up  up`.
- `show ip route connected` → the `/30` as a directly-connected route (this is what routing is built on).

**🔴 Breaks when.** The mask is wrong — a `/30` typed as `/24`, or a `/8` where a `/24` was meant: the **FGT01 `/8`-vs-`/24` outage** was exactly this (longest-match sends traffic the wrong way). Also normal-but-alarming: a transit `/30` shows **`down/down` until the far end is live** — not a fault, just an unlit link.

**🔗 Depends on / Flow.** Addressing underpins routing (Domain 3) and DHCP scopes (Domain 4); the transit `/30`s are where the OSPF adjacency forms.

**📄 Expands.** [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) · [`1941 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 2.

**🏅 Cert.** [`CCNA Ch16 (Vol 1) — IPv4 Addressing & Static Routes`](../Certification/CCNA/Vol1/Ch16-IPv4-Addressing-and-Static-Routes.md) (addressing).

**Grounding.** ✅ device-verified (07-22: the two transit `/30`s + loopback, up/up).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.7 — Describe private IPv4 addressing

**What.** The RFC 1918 ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`). **The entire Atlas estate is `10.0.0.0/8`**; it reaches the internet only by NAT/PAT at FGT01.

**Config.** — (addressing-policy objective; the addresses themselves are set in 1.6.)

**Verify.**
- `show ip route` → every internal prefix is `10.x` (no public space inside).
- `show ip interface brief` → no internal interface carries a public address.

**🔴 Breaks when.** You assume "private = unreachable from outside" — it's the **NAT at FGT01** that bridges private↔public (Domain 4). Confusing the ranges (thinking `172.32.x` is private — it isn't; the block is `172.16–172.31`) is the common exam slip.

**🔗 Depends on / Flow.** Private inside → PAT at FGT01 → internet (ties to Domain 4 NAT).

**📄 Expands.** [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md).

**Grounding.** ✅ device-verified (the whole plan is `10/8`).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.8 — Configure and verify IPv6 addressing and prefix

**What.** Dual-stack IPv6 addressing (global/ULA + link-local), `/64` prefixes, EUI-64, SLAAC/DHCPv6. 🔴 **Build gap — no Atlas device runs IPv6 yet** (the operator's top study concern). A **proposed** dual-stack plan exists ([`IPv6-Addressing-Plan`](../../Labs/Lab-02-Cisco-Core/Architecture/IPv6-Addressing-Plan.md), ULA `fd42:a1b2:c3d4::/48`); building it on the 1941/SW01 closes 1.8–1.9 (and 3.3).

**Config.** *(from the proposed plan — not yet applied to hardware)*
- `ipv6 unicast-routing` — enable v6 forwarding globally (**without this the router only has link-local**)
- `interface GigabitEthernet0/0`
- `ipv6 address fd42:a1b2:c3d4:ff02::1/127` — the proposed 1941↔MKT01 transit (`/127`, the v6 analogue of a `/30`)
- `ipv6 address autoconfig` — SLAAC form (self-assign from an RA)
- `ipv6 address 2001:db8:0:1::/64 eui-64` — the EUI-64 form (interface-ID from the MAC)

**Verify.** *(once built)*
- `show ipv6 interface brief` → the auto link-local (`FE80::…`) + the configured global.
- `show ipv6 route` → the connected `/127` and `/64`s.

**🔴 Breaks when.** You omit `ipv6 unicast-routing` (interfaces come up link-local only, no forwarding). A prefix that isn't `/64` breaks SLAAC/EUI-64. **The hex trap:** `::11` is `0x11` = **17 decimal**, not 11 — Atlas keeps the *written* form matching the v4 host number for readability, but the value is hex.

**🔗 Depends on / Flow.** Dual-stack changes **addressing, not topology** — the v6 gateways still live on MKT01, mirroring the v4 plan 1:1.

**📄 Expands.** [`IPv6-Addressing-Plan`](../../Labs/Lab-02-Cisco-Core/Architecture/IPv6-Addressing-Plan.md) (📋 proposed).

**Grounding.** 📘 study-reference / **build gap** — planned, not device-verified.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.9 — Describe IPv6 address types

**What.** Unicast (**global** `2000::/3`, **unique-local** `fd00::/8`, **link-local** `fe80::/10`), **anycast**, **multicast** (`ff00::/8`, incl. solicited-node), and **modified EUI-64**. The proposed estate plan uses a **ULA** (`fd42:a1b2:c3d4::/48`) — the honest choice for a lab with no ISP v6 allocation.

**Config.** — (address-type objective; addresses are configured in 1.8.)

**Verify.** *(once built)*
- `show ipv6 interface GigabitEthernet0/0` → the `FE80::` link-local **and** the solicited-node multicast group the interface auto-joins.

**🔴 Breaks when.** You confuse **ULA** (`fd00::/8`, private) with **global** (`2000::/3`, internet-routable); or forget that **EUI-64** flips the 7th bit of the MAC and inserts `FFFE` in the middle. The doc prefix `2001:db8::/32` is *examples-only — never configured for real* (itself a CCNA point).

**🔗 Depends on / Flow.** Address type drives host method: static (infra/servers/OT), SLAAC (clients), DHCPv6 (deployment/testing) — see the plan's per-VLAN method table.

**📄 Expands.** [`IPv6-Addressing-Plan`](../../Labs/Lab-02-Cisco-Core/Architecture/IPv6-Addressing-Plan.md) §types.

**Grounding.** 📘 study-reference / build gap.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.10 — Verify IP parameters for Client OS (Windows, macOS, Linux)

**What.** Read a client's IPv4/mask/gateway/DNS from the host side, then confirm it from the Cisco side. The estate's clients live in **VLAN 50** (`10.50.0.0/25`, gateway `10.50.0.1`).

**Config.** — (client-side verification; no IOS config.)

**Verify.**
- Windows: `ipconfig /all` → address, mask, default gateway, DNS. Linux: `ip -br addr` + `ip route`. macOS: `ifconfig` / `networksetup -getinfo`.
  - Worked read-back (a VLAN-50 client): `IPv4 Address … 10.50.0.37` · `Default Gateway … 10.50.0.1`.
- Cisco side: `show ip arp` on SW01 → the client's MAC/IP is learned on its access port (proves L2/L3 presence).

**🔴 Breaks when.** An **APIPA** `169.254.x.x` address = DHCP failed (no scope/relay). A wrong/blank default gateway = on-subnet works, off-subnet doesn't — the "internet is down but I can print" symptom.

**🔗 Depends on / Flow.** Cross-platform — the client detail lives in [`PowerShell-Tier0`](./PowerShell-Tier0.md) (Windows) and [`Linux`](./Linux.md); the validation fleet is the VLAN-50 test stations (#23).

**📄 Expands.** [`PowerShell-Tier0`](./PowerShell-Tier0.md) · [`Linux`](./Linux.md).

**Grounding.** 🟡 partial (the VLAN-50 client fleet is #23, forthcoming; `show ip arp` on SW01 is ✅).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.11 — Describe wireless principles

**What.** SSID, RF, the **non-overlapping 2.4 GHz channels (1/6/11)**, and WPA2/WPA3 encryption. Atlas owns a **FortiAP** — but it's Fortinet-managed, **not a Cisco WLC**, and it isn't in the lab yet.

**Config.** — (no Cisco IOS command; the AP is FortiOS-managed.)

**Verify.** — (no IOS read-back; observed on the FortiGate/FortiAP side.)

**🔴 Breaks when.** Overlapping channels (e.g. 1 and 3) interfere. For the exam, **Cisco WLC / CAPWAP GUI specifics are simulator-only** here — the FortiAP teaches the RF/SSID/encryption *principles*, not Cisco-WLC mechanics.

**🔗 Depends on / Flow.** WPA2-**Enterprise** = 802.1X against **NPS01** — this objective ties into Domain 5 (AAA) once the AP is stood up.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §wireless (the FortiAP / `$500` plan).

**🏅 Cert.** [`CCNA Ch1 (Vol 2) — Wireless Fundamentals`](../Certification/CCNA/Vol2/Ch01-Fundamentals-of-Wireless-Networks.md).

**Grounding.** 📘 study-reference / build gap (FortiAP owned, not yet in lab).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.12 — Explain virtualization fundamentals (VMs, containers, VRFs)

**What.** Server virtualization (VMs), containers, and **VRFs** (L3 routing-table separation on one router). Atlas runs **VMs** on PVE01/PVE02 and **containers** on CNT01; it does **not** run VRFs (single global table).

**Config.** — (hypervisor/host-side for VMs/containers; VRF would be `ip vrf <name>` + `ip vrf forwarding` on an interface — **not used in Atlas**.)

**Verify.**
- `show vrf` on IOS → lists configured VRFs.
  - Worked read-back (Atlas today): empty — the 1941 uses the single global routing table.

**🔴 Breaks when.** You conflate a **VLAN** with a **VRF**: a VLAN is an L2 broadcast segment; a VRF is L3 routing-table isolation. Atlas separates with **VLANs + firewall policy**, not VRFs.

**🔗 Depends on / Flow.** PVE01/PVE02 host the VMs (incl. the Cisco boxes' virtual peers via CML); CNT01 the containers. VRF = 📘 not deployed.

**📄 Expands.** [`PVE01-Hypervisor`](../../Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor/README.md) · Concept [`Proxmox-VM-Migration-and-Host-Bring-Up`](../Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md).

**Grounding.** 🟡 partial (VMs/containers real; VRF 📘 not run).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1.13 — Describe switching concepts (MAC learning/aging, frame switching, flooding, MAC table)

**What.** How SW01 (2960X) forwards: it **learns** a source MAC → port on each frame, **ages** it out after silence (default 300 s), **switches** known-unicast to the one port, and **floods** unknown-unicast/broadcast/multicast to every port in the VLAN.

**Config.** — (default L2 behaviour; `mac address-table aging-time <sec>` is the only tunable, rarely changed.)

**Verify.**
- `show mac address-table` on SW01 → dynamic entries by VLAN/port.
  - Worked read-back: `10   0000.5e00.5301   DYNAMIC   Gi1/0/7` (Pi01 learned on its access port).
- `show mac address-table aging-time` → `300` (default). Watch an entry appear on the first frame and disappear after the aging window of silence.

**🔴 Breaks when.** A MAC **flapping** between two ports = a **loop** (STP's job — Domain 2); a table full of one MAC on every port = a **CAM-overflow / MAC-flood attack** (port-security's job — Domain 5). Unknown-unicast flooding to all ports is normal *until* the destination replies and is learned.

**🔗 Depends on / Flow.** The MAC table (L2) feeds ARP (L3): the switch floods the unknown, learns from the reply. Loops here are contained by STP; abuse here is contained by port-security.

**📄 Expands.** [`SW01 Diagnostics`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md) §6 · Domain 2 §Interfaces (forthcoming, this page).

**Grounding.** ✅ device-verified (the `show mac address-table` reads); the flap/flood scenarios 🟡.

<br>

═══════════════════════════════════════════════════════════════════════════════
## ═══ DOMAIN 2 — NETWORK ACCESS (20%)
═══════════════════════════════════════════════════════════════════════════════

> Grounded in **SW01** (2960X, the estate's access switch) — real VLANs 10–90 + 999, the MKT01 trunk (native 999), RSTP root, root-guard/portfast/bpduguard. Objectives 2.1–2.9. EtherChannel (2.4) and all wireless (2.6/2.7/2.9) are **build gaps** — marked 📘.

### 2.1 — Configure and verify VLANs (normal range) spanning switches

**What.** Define the normal-range VLANs and drop access ports into them. Atlas runs **nine zone VLANs 10–90 + 999** on SW01 (`10=Mgmt … 90=OT`, `999=NATIVE-PARK`); access ports carry one VLAN each. Voice VLANs and inter-VLAN routing are separate (routing lives on MKT01 / the 1941 overlay).

**Config.** *(real SW01 values — [`SW01 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Steps 2/4)*
- `vlan 10` → `name Mgmt`  *(repeat 20 Servers … 90 OT, 999 NATIVE-PARK)*
- `interface GigabitEthernet1/0/7` — the Pi01 access port
- `switchport mode access`
- `switchport access vlan 10`
- unused ports: `switchport access vlan 999` + `shutdown` (park them)

**Verify.**
- `show vlan brief` → the nine zone VLANs + 999, with their member ports.
  - Worked read-back: `10   Mgmt   active   Gi1/0/7` · `999  NATIVE-PARK  active  Gi1/0/3, …`.
- `show interfaces status` → each host in the right VLAN; unused = `disabled`.

**🔴 Breaks when.** A VM's VLAN is missing from the database → its port goes dark. **Don't reverse the Lab-01 port lessons:** `Gi1/0/3` stays `shutdown` (`ADR-0002`/`CM-0003`); **`Gi1/0/7` = Pi01 — never shut it.** VLAN 1 (default) is deliberately unused; parking is 999. **Voice VLAN** = 📘 (no IP phones in Atlas).

**🔗 Depends on / Flow.** VLANs are L2 segments; reaching *between* them is routing — MKT01 in production, the 1941 router-on-a-stick in the CCNA overlay (Domain 3 / the ⭐ Playbook).

**📄 Expands.** [`SW01 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) · [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md).

**🏅 Cert.** [`CCNA Ch8 (Vol 1) — Ethernet VLANs`](../Certification/CCNA/Vol1/Ch08-Implementing-Ethernet-VLANs.md) · [`Ch17 — IP Routing in the LAN`](../Certification/CCNA/Vol1/Ch17-IP-Routing-in-the-LAN.md).

**Grounding.** ✅ device-verified (VLANs 10–90+999 on SW01); voice 📘.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.2 — Configure and verify interswitch connectivity (trunks, 802.1Q, native VLAN)

**What.** A trunk carries many VLANs on one link (802.1Q tags each frame; the native VLAN rides untagged). Atlas: **`Gi1/0/1` → MKT01 (`ether3`)** and **`Gi1/0/4` → PVE01**, both **native 999**, allowed `10–90,999`, DTP off.

**Config.** *(real SW01 trunk — Build-Guide Step 3)*
- `interface GigabitEthernet1/0/1` → `description ->MKT01 trunk`
- `switchport mode trunk`
- `switchport trunk native vlan 999`
- `switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,999`
- `switchport nonegotiate` — kill DTP (don't let the port negotiate a trunk)

**Verify.**
- `show interfaces trunk` → the port `trunking`, **native 999**, allowed `10-90,999`.
  - Worked read-back: `Gi1/0/1  on  802.1q  trunking  999` then the allowed/active/forwarding VLAN lists.
- `show interfaces Gi1/0/1 switchport` → admin trunk, negotiation off.

**🔴 Breaks when.** 🔴 **The 2960X is 802.1Q-only — do NOT type `switchport trunk encapsulation dot1q`** (it errors `% Invalid input`; encapsulation is dot1q by default — device-verified 07-20). **Native-VLAN mismatch** between ends → VLAN hopping / the native-10 asymmetry that black-holed a tagged-VLAN-10 VM (fixed by native 999 both ends). **DTP left on** (dynamic) → a rogue switch can negotiate a trunk and reach every VLAN.

**🔗 Depends on / Flow.** The trunk to MKT01 is the estate's L2 spine — every VLAN reaches its gateway across it; DAI/snooping trust rides these trunk ports (Domain 5).

**📄 Expands.** [`SW01 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 3 · [`Cabling-and-Port-Map`](../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md).

**🏅 Cert.** [`CCNA Ch8 (Vol 1) — Ethernet VLANs`](../Certification/CCNA/Vol1/Ch08-Implementing-Ethernet-VLANs.md) (trunking).

**Grounding.** ✅ device-verified (native 999 both trunks, 07-24).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.3 — Configure and verify CDP and LLDP

**What.** Layer-2 neighbor discovery: **CDP** (Cisco, on by default) and **LLDP** (802.1AB, vendor-neutral, off by default). Atlas uses discovery on SW01; LibreNMS will draw the topology from LLDP.

**Config.**
- CDP: `cdp run` (global, default on) · `cdp enable` / `no cdp enable` (per interface)
- LLDP: `lldp run` (global — off by default) · per-interface `lldp transmit` / `lldp receive`

**Verify.**
- `show cdp neighbors detail` → neighbor device-id, platform, local/remote port, mgmt IP.
- `show lldp neighbors` → the vendor-neutral equivalent (needed for the non-Cisco MKT01/FGT01).

**🔴 Breaks when.** 🔴 **CDP is deliberately OFF on the 1941** (`no cdp run`) — its neighbors (MKT01/FGT01) aren't Cisco, so CDP only *leaks* device/version info to an untrusted link. LLDP is **off by default** — a blank `show lldp neighbors` usually means you never ran `lldp run`, not that the neighbor is absent.

**🔗 Depends on / Flow.** Discovery feeds the topology map (LibreNMS/MON01) and confirms the cabling map; on hardened transit links it's disabled on purpose (security > convenience).

**📄 Expands.** [`Cabling-and-Port-Map`](../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md) · [`SW01 Diagnostics`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md).

**🏅 Cert.** [`CCNA Ch13 (Vol 2) — Device Management Protocols`](../Certification/CCNA/Vol2/Ch13-Device-Management-Protocols.md) (CDP/LLDP).

**Grounding.** 🟡 partial (1941 `no cdp run` verified; SW01 CDP/LLDP reads 🟡).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.4 — Configure and verify EtherChannel (LACP)

**What.** Bundle 2–8 physical links into one logical `Port-channel` for bandwidth + redundancy. **LACP** (802.3ad, `active`/`passive`) is the standard; PAgP (`desirable`/`auto`) is Cisco; `on` is static (no negotiation). 🔴 **Build gap — Atlas has no bundle today** (needs a second switch + two links; the owned **SG300** could host it, but runs Small-Business OS, not exam-accurate IOS).

**Config.** *(the LACP pattern, for when a second switch lands)*
- `interface range GigabitEthernet1/0/1 - 2`
- `channel-group 1 mode active` — LACP, actively negotiating (creates `Port-channel1`)
- `interface Port-channel 1` → set trunk/VLAN params **on the port-channel**, not the members

**Verify.**
- `show etherchannel summary` → the bundle + member ports; flags `P` = bundled in port-channel.
- `show lacp neighbor` → the partner's LACP state.

**🔴 Breaks when.** **Mode mismatch** — `active`↔`passive` bundles, but `passive`↔`passive` never forms (neither initiates), and `on` must be `on`↔`on` (no negotiation). Mismatched speed/duplex/VLAN/allowed-list across members → the port won't join the bundle.

**🔗 Depends on / Flow.** An EtherChannel is a single STP link (Domain 2.5) — bundling removes the redundant-link-blocked-by-STP problem.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) (the second-switch / SG300 note).

**🏅 Cert.** [`CCNA Ch10 (Vol 1) — RSTP & EtherChannel`](../Certification/CCNA/Vol1/Ch10-RSTP-and-EtherChannel-Configuration.md).

**Grounding.** 📘 study-reference / build gap.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.5 — Interpret Rapid PVST+ Spanning Tree Protocol

**What.** STP prevents L2 loops by electing a **root bridge** and blocking redundant paths; **Rapid PVST+** is the fast per-VLAN default. SW01 runs `rapid-pvst` and is the intended **root**, with **root guard** on the MKT01 trunk so MKT01 can't take the root role.

**Config.** *(from the STP notes + SW01 Build-Guide)*
- `spanning-tree mode rapid-pvst`
- `spanning-tree vlan 10 root primary` — lower this bridge's priority so it wins the root election
- access ports: `spanning-tree portfast` + `spanning-tree bpduguard enable`
- the MKT01 trunk (`Gi1/0/1`): `spanning-tree guard root`

**Verify.**
- `show spanning-tree` → root bridge, this bridge's priority, and each port's **role** (root/designated/alternate) + **state** (forwarding/blocking).
  - Worked read-back: `This bridge is the root` on SW01's VLANs; the MKT01 trunk = designated/forwarding.
- `show spanning-tree summary` → mode `rapid-pvst`, PortFast/BPDU-guard status.

**🔴 Breaks when.** **PortFast on a switch-to-switch link** → a transient loop (only ever on single-host access ports). **BPDU guard err-disables** a portfast port the instant it receives a BPDU (a switch plugged into an access port) — recover with `errdisable recovery cause bpduguard`. **Root guard** puts a port in `root-inconsistent` if a superior BPDU arrives (MKT01 trying to become root). 🔴 With **only one switch today**, root election isn't really exercised — a second switch makes it real (🟡).

**🔗 Depends on / Flow.** STP protects the trunk topology (2.2); EtherChannel (2.4) collapses redundant links so STP doesn't block them.

**📄 Expands.** [`SW01 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 4 · [`SW01 Diagnostics`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md).

**🏅 Cert.** [`CCNA Ch9 (Vol 1) — STP Concepts`](../Certification/CCNA/Vol1/Ch09-Spanning-Tree-Protocol-Concepts.md) · [`Ch10 — RSTP & EtherChannel`](../Certification/CCNA/Vol1/Ch10-RSTP-and-EtherChannel-Configuration.md).

**Grounding.** 🟡 partial (root/portfast/bpduguard/root-guard configured; real election needs a 2nd switch).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.6 — Describe Cisco wireless architectures and AP modes

**🏅 Cert.** [`CCNA Ch2 (Vol 2) — Analyzing Cisco Wireless Architectures`](../Certification/CCNA/Vol2/Ch02-Analyzing-Cisco-Wireless-Architectures.md).

**What.** Autonomous vs lightweight (WLC-managed, CAPWAP) vs cloud-managed (Meraki) vs embedded-WLC; AP modes (local, FlexConnect, monitor, sniffer, bridge). 🔴 **Build gap — Atlas owns a FortiAP** (Fortinet-managed), **not a Cisco WLC**; Cisco-WLC architecture is simulator/study-only here.

**Config.** — (no Cisco IOS command; WLC/AP-managed.)

**Verify.** — (observed on the FortiGate/FortiAP side, not IOS.)

**🔴 Breaks when.** Treating the FortiAP as a Cisco WLC — the RF/SSID/mode *concepts* transfer, the CAPWAP/WLC mechanics don't.

**🔗 Depends on / Flow.** WPA2-Enterprise ties wireless to AAA (NPS01, Domain 5).

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §wireless.

**Grounding.** 📘 study-reference / build gap.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.7 — Describe physical infrastructure connections of WLAN components

**🏅 Cert.** [`CCNA Ch4 (Vol 2) — Building a Wireless LAN`](../Certification/CCNA/Vol2/Ch04-Building-a-Wireless-LAN.md).

**What.** How the pieces cable up: an AP on a switch **access port** (or a trunk when it carries multiple SSID→VLAN mappings), the **WLC** uplink as a **LAG** (EtherChannel), and the AP↔WLC CAPWAP relationship. 🔴 **Build gap** (no Cisco WLC in Atlas).

**Config.** — (design/cabling objective; no IOS command specific to Atlas today.)

**Verify.** — (n/a until a WLC exists.)

**🔴 Breaks when.** Putting a lightweight AP on the wrong port type — a single-SSID AP is an access port; a multi-VLAN AP/WLC uplink needs a trunk or LAG.

**🔗 Depends on / Flow.** Reuses trunking (2.2) + EtherChannel/LAG (2.4).

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §wireless.

**Grounding.** 📘 study-reference / build gap.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.8 — Describe network device management access

**What.** How you reach a device to manage it: **console** (out-of-band), **SSH** (encrypted, the only remote method Atlas allows), **Telnet/HTTP** (cleartext — disabled), **HTTPS**, **TACACS+/RADIUS** (centralized auth), and cloud-managed. Atlas: **SSH-only**, local named-admin now → **RADIUS via NPS01** later (`ADR-0029`).

**Config.** *(real SW01/1941 hardening)*
- `line vty 0 15` → `transport input ssh` + `login local`
- `no ip http server` · `no ip http secure-server` · (no telnet)
- `line con 0` → `exec-timeout 5 0` + `logging synchronous`

**Verify.**
- `show ip ssh` → `SSH Enabled - version 2.0`.
- `show run | include transport|http` → `transport input ssh`, no `ip http server`.

**🔴 Breaks when.** Telnet/HTTP left on = cleartext management (CIS fail). 🔴 **The 2960X/1941 speak only legacy SSH KEX** — a modern OpenSSH client refuses them: connect with `-o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa` (it's an algorithm mismatch, **not** a key-size problem). Cloud-managed (Meraki) = not an Atlas model.

**🔗 Depends on / Flow.** RADIUS admin-auth ⇐ NPS01 ⇐ AD CS (server cert) ⇐ DC (`ADR-0029`); until that stack exists, local break-glass is the only path — never PKI-ify it.

**📄 Expands.** [`CIS-Hardening-SW01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) · [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md).

**Grounding.** ✅ device-verified (SSH-only, no cleartext — 07-22).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.9 — Interpret the wireless LAN GUI configuration

**What.** Reading a WLC/AP GUI to stand up client connectivity: WLAN/SSID creation, security (WPA2/WPA3, PSK vs 802.1X/Enterprise), QoS profiles, and advanced settings. 🔴 **Build gap** — Atlas's wireless GUI is **FortiAP/FortiGate**, not Cisco WLC; the mapping (SSID → VLAN → security) transfers, the Cisco screens don't.

**Config.** — (GUI objective; no IOS CLI.)

**Verify.** — (validated in the FortiGate wireless GUI, not IOS.)

**🔴 Breaks when.** Picking PSK where the design wants **Enterprise** (802.1X) — Enterprise is what ties the WLAN back to NPS01/RADIUS.

**🔗 Depends on / Flow.** WPA2-Enterprise ⇒ 802.1X ⇒ NPS01 (Domain 5 AAA) — the one place wireless meets the estate's identity stack.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §wireless / §5 AAA.

**Grounding.** 📘 study-reference / build gap.


═══════════════════════════════════════════════════════════════════════════════
## ═══ DOMAIN 3 — IP CONNECTIVITY (25%)
═══════════════════════════════════════════════════════════════════════════════

> The biggest domain — grounded in the **1941's real OSPF**: process 1, router-id from the loopback `10.255.0.1`, adjacency **FULL with MKT01** over the `/30`, MKT01's VLANs learned as `O E2`, a static default out to FGT01. Objectives 3.1–3.5. FHRP (3.5) is a **build gap** (single gateway today) — marked 📘.

### 3.1 — Interpret the components of the routing table

**What.** Read `show ip route`: the **code** (`C` connected · `S` static · `S*` candidate default · `O` OSPF · `O E2` external), the **prefix/mask**, the **next-hop**, the `[AD/metric]`, and the **gateway of last resort**. The 1941's table = connected `/30`s + the loopback + MKT01's VLANs as `O E2` + a `S*` default.

**Config.** — (interpretation objective.)

**Verify.**
- `show ip route` → the full table.
  - Worked read-back: `C   10.255.255.4/30 is directly connected, GigabitEthernet0/0` · `O E2 10.50.0.0/25 [110/20] via 10.255.255.6` · `S*  0.0.0.0/0 [1/0] via 10.255.255.1` · header `Gateway of last resort is 10.255.255.1 to network 0.0.0.0`.
- `[110/20]` reads as **[AD/metric]** — `110` = OSPF's AD, `20` = the OSPF cost.

**🔴 Breaks when.** `Gateway of last resort is not set` = **no default** → internet-bound traffic blackholes. Misreading `O E2` (external, cost doesn't accrue per-hop) as a normal `O` route. A VLAN missing from the table = the MKT01 adjacency or redistribution is down (3.4).

**🔗 Depends on / Flow.** The table is the *output* of the forwarding logic (3.2); the `O E2` rows come from MKT01 redistributing its VLAN SVIs — the 1941 **learns**, it doesn't originate them (`ADR-0023`).

**📄 Expands.** [`1941 Diagnostics`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) §3 · [`1941 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3.

**Grounding.** ✅ device-verified (OSPF FULL + `O E2` VLANs, 07-21); the full table read 🟡.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3.2 — How a router makes a forwarding decision (longest match, AD, metric)

**What.** A router picks a route by, in order: **longest-prefix match** (most-specific mask wins), then lowest **administrative distance** (between *sources* — connected 0, static 1, OSPF 110), then lowest **metric** (between routes from the *same* protocol).

**Config.** — (forwarding-logic objective.)

**Verify.**
- `show ip route 10.50.0.37` → the *single* route the router would use for that destination (longest match).
- `show ip route 0.0.0.0` → the default, used only when nothing more specific matches.

**🔴 Breaks when.** 🔴 **The FGT01 `/8`-vs-`/24` outage** was exactly this — a too-broad prefix won longest-match and pulled traffic the wrong way. **AD confusion:** a static route (AD 1) beats OSPF (AD 110) for the same prefix — the basis of the floating-static trick (3.3), and a foot-gun if unintended.

**🔗 Depends on / Flow.** Longest-match → AD → metric is the fixed order; it's why a `/32` host route always wins over a `/24`, and a static always wins over OSPF unless you raise its AD.

**📄 Expands.** [`1941 Build-Checklist`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) (failure modes).

**Grounding.** ✅ device-verified via a real incident (the `/8`-vs-`/24` longest-match lesson).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3.3 — Configure and verify IPv4 and IPv6 static routing

**What.** Static routes: **network** (`ip route <net> <mask> <next-hop>`), **default** (`0.0.0.0 0.0.0.0`), **host** (`/32`), and **floating** (a higher AD so it's a dormant backup). The 1941's real default points at FGT01.

**Config.** *(real 1941 values)*
- `ip route 0.0.0.0 0.0.0.0 10.255.255.1` — the default → FGT01 (the `S*` in the table)
- `ip route 10.0.0.0 255.0.0.0 10.255.255.6 250` — a **floating** static (AD 250) backup to OSPF on the MKT01 leg
- host: `ip route 10.20.0.2 255.255.255.255 10.255.255.6`
- IPv6 (proposed plan): `ipv6 route ::/0 fd42:a1b2:c3d4:ff01::` — 📘 not yet on hardware

**Verify.**
- `show ip route static` → `S* 0.0.0.0/0 [1/0] via 10.255.255.1`; the floating route is **absent** while OSPF is up (AD 250 loses to 110) and only appears if the adjacency drops.

**🔴 Breaks when.** 🔴 **Single-homed egress:** a floating static for the *default* buys nothing — there's no second path to fail to. It only helps as the **AD-250 OSPF backup on the MKT01 leg**, and it rides the same cable, so it guards an OSPF-*process* failure, **not** a link failure — be honest (`POL-0013`). `%Inconsistent address and mask` = you put a host address where the **network** address goes (a `/26` wants `.128`, not the interface IP). IPv6 static = 📘 (no device runs v6).

**🔗 Depends on / Flow.** Static AD 1 < OSPF 110, so a static wins unless you raise its AD (that's what makes a floating static *floating*); the default here is what OSPF re-advertises to MKT01 via `default-information originate` (3.4).

**📄 Expands.** [`1941 Build-Checklist`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md) §3 · [`Considerations`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) (single-homed egress).

**🏅 Cert.** [`CCNA Ch16 (Vol 1) — IPv4 Addressing & Static Routes`](../Certification/CCNA/Vol1/Ch16-IPv4-Addressing-and-Static-Routes.md).

**Grounding.** ✅ device-verified (the default route); floating 🟡 (documented, honest caveat); IPv6 📘.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3.4 — Configure and verify single-area OSPFv2

**What.** One area (area 0): form an **adjacency**, set a stable **router-id**, and know the **network types** — a `/30` point-to-point (no DR/BDR) vs a broadcast/Ethernet segment (DR/BDR election). The 1941 runs OSPF `1`, router-id from the loopback, with **only** the two transit `/30`s + loopback in area 0.

**Config.** *(the real 1941 OSPF — [`Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3)*
- `router ospf 1`
- `router-id 10.255.0.1` — the loopback (always up/up → a stable ID)
- `network 10.255.255.4 0.0.0.3 area 0` — Gi0/0 → MKT01 (**the adjacency forms here**)
- `network 10.255.255.0 0.0.0.3 area 0` — Gi0/1 → FGT01 transit
- `network 10.255.0.1 0.0.0.0 area 0` — Loopback0
- `passive-interface GigabitEthernet0/1` — FGT01 takes a static default, not OSPF
- `default-information originate` — push the default to MKT01 over OSPF

**Verify.**
- `show ip ospf neighbor` → MKT01 **FULL**.
  - Worked read-back: `Neighbor ID  Pri  State     Dead Time  Address       Interface` → `10.255.0.2  0  FULL/  -  00:00:38  10.255.255.6  GigabitEthernet0/0` — the `/  -` means **no DR/BDR** (a point-to-point link doesn't elect one).
- `show ip protocols` → OSPF with the transit networks only (no user VLANs).

**🔴 Breaks when.** 🔴 **MTU mismatch with RouterOS (MKT01)** → the adjacency sticks at **EXSTART/EXCHANGE** (`ip ospf mtu-ignore` on both `/30` ends, or match MTU); a **network-type/DR mismatch** → stuck at **INIT/2-WAY**. 🔴 **The classic mistake:** adding `network` statements for the VLAN subnets (`10.10–10.90`) — `network` enables OSPF on a *matching interface*, it does **not** advertise a route, and the 1941 owns no VLAN interface, so those lines match nothing. The VLANs are **learned from MKT01**, never originated here.

**🔗 Depends on / Flow.** MKT01 originates the VLANs (they arrive as `O E2`, 3.1); the 1941 passes the default down via `default-information originate`. 🔴 Keep paths **symmetric** — request and reply both transit the 1941, or MKT01's stateful firewall drops half the flow.

**📄 Expands.** [`1941 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3 · [`Considerations`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) (OSPF↔RouterOS interop).

**🏅 Cert.** [`CCNA Ch19 (Vol 1) — OSPF Concepts`](../Certification/CCNA/Vol1/Ch19-Understanding-OSPF-Concepts.md) · [`Ch20 — Implementing OSPF`](../Certification/CCNA/Vol1/Ch20-Implementing-OSPF.md) · [`Ch21 — Network Types & Neighbors`](../Certification/CCNA/Vol1/Ch21-OSPF-Network-Types-and-Neighbors.md).

**Grounding.** ✅ device-verified (adjacency FULL with MKT01, 07-21).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3.5 — First hop redundancy protocols (FHRP)

**What.** FHRP (**HSRP** Cisco · **VRRP** standard · **GLBP** Cisco) lets two routers share one **virtual gateway IP + MAC** in active/standby, so hosts keep a single default gateway even if a router dies. 🔴 **Build gap — Atlas has one gateway** (MKT01 in production; the 1941 in the CCNA overlay); no FHRP runs today. HSRP needs a second router (or SVIs on a pair); VRRP could run on MKT01 as the concept.

**Config.** — (📘; the HSRP shape, for a future pair: `standby 1 ip <virtual-ip>` · `standby 1 priority 110` · `standby 1 preempt` on the gateway interface.)

**Verify.** *(when built)* `show standby brief` → the group, the virtual IP, and which router is **Active** vs **Standby**.

**🔴 Breaks when.** No FHRP → a gateway failure is an outage for that subnet (Atlas accepts this today). Misconfigured **priority/preempt** → both routers Active (duplicate gateway) or no fail-back after recovery.

**🔗 Depends on / Flow.** FHRP sits under inter-VLAN routing — it's the redundancy layer for the default gateway the hosts point at (3.4).

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) (FHRP needs a second router — VRRP-on-MKT01 as the concept).

**🏅 Cert.** [`CCNA Ch16 (Vol 2) — FHRP`](../Certification/CCNA/Vol2/Ch16-First-Hop-Redundancy-Protocols.md).

**Grounding.** 📘 study-reference / build gap.


═══════════════════════════════════════════════════════════════════════════════
## ═══ DOMAIN 4 — IP SERVICES (10%)
═══════════════════════════════════════════════════════════════════════════════

> Grounded in the estate's real services: **NTP from DC01 `10.20.0.2`** (`ADR-0020`, the `CM-0030` stuck-clock lab), **DHCP on DC01** (`ADR-0029`/`ADR-0030`), the removed v2c SNMP community (`CM-0023`), SSH-only management. Objectives 4.1–4.9. NAT/QoS/SNMPv3/syslog land when their owner (FGT01 / MON01) is built — marked 🟡/📘.

### 4.1 — Configure and verify inside source NAT (static and pools)

**What.** Translate inside private addresses to a public one: **static** (1:1), **dynamic pool** (many:pool), **PAT/overload** (many:1 by port). 🔴 In Atlas, **PAT to the internet is FGT01's job**, not the 1941 — IOS NAT here is a **lab/study** exercise (e.g. a static NAT on the 1941).

**Config.** *(the IOS pattern, from the operator's NAT notes)*
- `ip nat inside source static 10.20.0.5 <public>` — a static 1:1 map, **or**
- `ip nat inside source list 1 interface GigabitEthernet0/1 overload` — PAT out the edge interface
- `interface GigabitEthernet0/0` → `ip nat inside` · `interface GigabitEthernet0/1` → `ip nat outside`

**Verify.**
- `show ip nat translations` → the active translation table (inside-local ↔ inside-global).
- `show ip nat statistics` → hit counts + which interfaces are inside/outside.

**🔴 Breaks when.** Forgetting to mark the interfaces `ip nat inside`/`outside` → nothing translates (the most common NAT miss). In production the 1941 must **not** NAT internet traffic — that's FGT01 (double-NAT breaks return traffic).

**🔗 Depends on / Flow.** NAT sits at the private↔public boundary (Domain 1.7); Atlas's real boundary is FGT01 (FortiOS), so IOS NAT is study-only here.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) (NAT on FGT01 vs the 1941).

**🏅 Cert.** [`CCNA Ch14 (Vol 2) — NAT`](../Certification/CCNA/Vol2/Ch14-Network-Address-Translation.md).

**Grounding.** 🟡 partial (FGT01 PAT is real but FortiOS; IOS NAT = a lab, 📘).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.2 — Configure and verify NTP (client and server)

**What.** Sync the clock — everything (logs, Kerberos, certs) depends on it. The estate's source is **DC01 `10.20.0.2`** (the PDC-emulator hierarchy, `ADR-0020`); SW01's never-synced clock (`CM-0030`) is a real troubleshooting lab.

**Config.**
- `ntp server 10.20.0.2` — point the client at DC01
- *(optional)* `ntp source Loopback0` — a stable source address (the loopback never goes down)

**Verify.**
- `show ntp status` → the sync claim.
  - Worked read-back: `Clock is synchronized, stratum 3, reference is 10.20.0.2`.
- `show ntp associations` → `*~10.20.0.2` (the `*` = the selected sys.peer).

**🔴 Breaks when.** 🔴 **Ticking sync from `show run`** — the `045`/`CM-0030` false-tick: `show run` shows the *config*, only `show ntp status` proves **synchronized**. `unsynchronized` / `stratum 16` / a `1993` date = no sync (the SW01 scar).

**🔗 Depends on / Flow.** Time underpins auth + logging — a wrong clock silently breaks Kerberos (skew) and makes log correlation worthless.

**📄 Expands.** [`ADR-0020`](../../00-Atlas-Foundation/Decisions/ADR-0020-NTP-Time-Source-Architecture.md) · the ⭐ Playbook [`Fix-the-SW01-Clock`](../Playbooks/Fix-the-SW01-Clock.md).

**🏅 Cert.** [`CCNA Ch13 (Vol 2) — Device Management Protocols`](../Certification/CCNA/Vol2/Ch13-Device-Management-Protocols.md).

**Grounding.** ✅ device-verified (SW01/1941 sync to DC01, stratum 3).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.3 — Explain the role of DHCP and DNS

**What.** **DHCP** hands out address/mask/gateway/DNS; **DNS** resolves names. Atlas: **DHCP on DC01** (`ADR-0030`), **DNS = AD-DNS** internally + **Pi-hole** for filtering (`ADR-0051`). A router crossing a broadcast domain must **relay** DHCP (4.6).

**Config.** — (role objective; the IOS piece is the relay in 4.6.)

**Verify.**
- From a client: `ipconfig /all` / `ip -br addr` shows the DC01-assigned lease + DNS.
- On IOS: `show ip interface <if>` lists the `Helper address` if the router relays.

**🔴 Breaks when.** DHCP and DNS live on **different owners** — a DHCP outage stops new leases; a DNS outage breaks name resolution even with a valid lease (two different failure modes, don't conflate).

**🔗 Depends on / Flow.** DHCP hands clients the **Pi-hole/AD-DNS** resolver; the router relays the DHCP broadcast to **DC01** (4.6).

**📄 Expands.** [`ADR-0030`](../../00-Atlas-Foundation/Decisions/ADR-0030-DHCP-on-DC01.md) · Playbook [`Recover-from-a-DNS-Outage`](../Playbooks/Recover-from-a-DNS-Outage.md).

**Grounding.** ✅ device-verified (DHCP-on-DC01 + Pi-hole/AD-DNS decided & built).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.4 — Explain the function of SNMP

**What.** SNMP polls/pushes device state to an NMS. Atlas ships telemetry to **MON01/LibreNMS** — **SNMPv3 (auth+priv) only**; the old v2c `homelab` community was **removed** (`CM-0023`, a real cleartext-community scar).

**Config.** *(v3, when MON01 exists)*
- `snmp-server group ATLAS v3 priv` · `snmp-server user … ATLAS v3 auth sha … priv aes 128 …`
- 🔴 **never** re-add `snmp-server community homelab RO`

**Verify.**
- `show snmp community` → **no `homelab`** (proves the v2c removal).
- `show snmp` → v3 users/engine once MON01 polls.

**🔴 Breaks when.** A carried-over **v2c community** = a cleartext string that reads the whole device (the `CM-0023` scar); it was live in the SW01 config until removed. Never re-introduce it.

**🔗 Depends on / Flow.** SNMPv3 ⇒ MON01/LibreNMS (Phase 6); pairs with syslog (4.5) as the observability path.

**📄 Expands.** [`Syslog-and-SNMP`](./Syslog-and-SNMP.md) (the observability tool-domain page).

**🏅 Cert.** [`CCNA Ch17 (Vol 2) — SNMP`](../Certification/CCNA/Vol2/Ch17-SNMP.md).

**Grounding.** 🟡 partial (v2c removal ✅ verified; SNMPv3 📋 pending MON01).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.5 — Syslog features (facilities and severity levels)

**What.** Syslog messages carry a **facility** + a **severity 0–7** (0 emergency … 7 debug — *"Every Awesome Cisco Engineer Will Need Ice-cream Daily"*). Atlas ships logs to **MON01** (Phase 6); until then, the local buffer.

**Config.**
- `service timestamps log datetime msec` — usable timestamps (correlation needs a synced clock, 4.2)
- `logging host 10.40.0.x` · `logging trap informational` — ship level ≤ 6 to MON01

**Verify.**
- `show logging` → the buffer + the configured host/level.

**🔴 Breaks when.** A wrong **severity** floods (debug) or starves (emergencies-only) the collector; **no timestamps / a wrong clock** makes correlation useless (ties to 4.2).

**🔗 Depends on / Flow.** Syslog + SNMP → MON01 (Phase 6); timestamps depend on NTP (4.2).

**📄 Expands.** [`Syslog-and-SNMP`](./Syslog-and-SNMP.md) · Playbook [`Trace-It-in-the-Logs`](../Playbooks/Trace-It-in-the-Logs.md).

**🏅 Cert.** [`CCNA Ch13 (Vol 2) — Device Management Protocols`](../Certification/CCNA/Vol2/Ch13-Device-Management-Protocols.md) (syslog).

**Grounding.** 🟡 partial (method authored; read-backs land when MON01 is built — 📋).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.6 — Configure and verify DHCP client and relay

**What.** A router interface can be a **DHCP client** (`ip address dhcp`) or a **relay** (`ip helper-address`) — forwarding a client's broadcast DISCOVER as a unicast to the DHCP server (DC01) across a routed boundary.

**Config.**
- relay: `interface <VLAN-svi>` → `ip helper-address 10.20.0.2` (→ DC01)
- client (edge/test): `interface <if>` → `ip address dhcp`

**Verify.**
- `show ip interface <if>` → `Helper address is 10.20.0.2`.
- `show ip dhcp binding` (on the server side / an IOS DHCP pool) → the lease.

**🔴 Breaks when.** No `ip helper-address` on a routed segment → DHCP broadcasts die at the router and clients get **no lease** (APIPA 169.254.x). `ip helper-address` also forwards 7 other UDP services by default (TFTP/DNS/etc.) — scope it if that's unwanted.

**🔗 Depends on / Flow.** The relay points at **DC01** (the estate DHCP server, `ADR-0030`); in the CCNA overlay the 1941's subinterfaces would relay per VLAN.

**📄 Expands.** [`ADR-0030`](../../00-Atlas-Foundation/Decisions/ADR-0030-DHCP-on-DC01.md) · [`Build-Guide-CCNA-Lab-Overlay`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md).

**Grounding.** 🟡 partial (helper pattern; DC01 is the server, VLAN relay lands with the overlay).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.7 — Forwarding per-hop behavior (PHB) for QoS

**What.** How a device treats a packet at each hop: **classification** + **marking** (DSCP/CoS), **queuing**, **congestion** management, **policing** (drop over-rate) vs **shaping** (buffer over-rate). 🔴 **You only *see* QoS under congestion** — Atlas needs generated load (`iperf3`) to make a policy's effect visible.

**Config.** — (📘 conceptual; the IOS shape is `class-map` → `policy-map` → `service-policy` on an interface.)

**Verify.** *(when a policy + load exist)* `show policy-map interface <if>` → per-class match/drop counters.

**🔴 Breaks when.** No congestion → QoS does **nothing visible** (the policy is correct but idle); you must generate load (`iperf3`) to prove it changed the outcome.

**🔗 Depends on / Flow.** Marking at the edge → queuing/policing in the core; meaningless without a congestion source.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) (QoS needs `iperf3`).

**🏅 Cert.** [`CCNA Ch15 (Vol 2) — Quality of Service`](../Certification/CCNA/Vol2/Ch15-Quality-of-Service.md).

**Grounding.** 📘 study-reference (needs an `iperf3` congestion lab).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.8 — Configure remote access using SSH

**What.** The only remote-management method Atlas allows. Generate a key, force v2, and point the vty lines at SSH + local auth. Real on the 1941 and SW01 (`ciscoadmin` priv 15).

**Config.** *(real 1941 — [`Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 1/1b)*
- `hostname 1941` · `ip domain-name atlas.lab`
- `crypto key generate rsa modulus 2048` — **SSH is not on until this runs**
- `ip ssh version 2`
- `line vty 0 15` → `transport input ssh` + `login local`

**Verify.**
- `show ip ssh` → `SSH Enabled - version 2.0`, plus the timeout/retries.
  - Then actually **SSH in** as `ciscoadmin` end-to-end (config ≠ working login).

**🔴 Breaks when.** The **key isn't generated** → SSH is configured but dead. 🔴 On the ISR/2960X, `crypto key generate rsa` can **eat the next pasted line** (run it alone, let `[OK]` return — the 07-20 lesson). Modern OpenSSH refuses the legacy **KEX** → `-o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa`.

**🔗 Depends on / Flow.** SSH is the transport; who you authenticate *as* is 5.3 (local) → 5.8 (RADIUS/NPS).

**📄 Expands.** [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) · [`1941 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 1b.

**Grounding.** ✅ device-verified (SSHv2 end-to-end, 07-22).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4.9 — TFTP/FTP capabilities

**What.** Move IOS images / configs off-box — `copy running-config tftp`, `copy tftp: flash:` — to a file server (Atlas: **SRV01**, forthcoming). Backups + upgrades ride these.

**Config.** — (operational commands, not a persistent config.)

**Verify.**
- `copy running-config tftp` → prompts for the server + filename; `show flash` / `dir` → confirms the image/file landed.

**🔴 Breaks when.** No route/ACL to the TFTP server (or the server not running) → the copy hangs/fails; a bad image in flash → a boot-loop (verify the MD5 before reloading).

**🔗 Depends on / Flow.** Config export feeds the backup runbook + (future) Oxidized (Domain 6); TFTP is one of the services `ip helper-address` forwards (4.6).

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) · the device backup runbook.

**Grounding.** 🟡 partial (SRV01 file services forthcoming).


═══════════════════════════════════════════════════════════════════════════════
## ═══ DOMAIN 5 — SECURITY FUNDAMENTALS (15%)
═══════════════════════════════════════════════════════════════════════════════

> Atlas is a real security estate — this domain is where the Command-Library meets the CIS baselines and the SW01 L2-security build. Objectives 5.1–5.10. Concept/program items (5.1/5.2/5.4/5.5) point at the estate's Policies/Standards; ACLs (5.6) + L2 security (5.7) are device-real; wireless (5.9/5.10) is 📘.

### 5.1 — Key security concepts (threats, vulnerabilities, exploits, mitigation)

**🏅 Cert.** [`CCNA Ch9 (Vol 2) — Security Architectures`](../Certification/CCNA/Vol2/Ch09-Security-Architectures.md).

**What.** Threat (the actor/event) · vulnerability (the weakness) · exploit (the method) · mitigation (the control). Atlas's whole design *is* mitigation — segmentation, least-privilege, hardening, evidence.

**Config.** — (concept objective.)

**Verify.** — (assessed against the estate's controls, not a `show` command.)

**🔴 Breaks when.** Treating a vulnerability as a threat (a weakness isn't an attacker) — the distinction drives whether you patch, segment, or monitor.

**🔗 Depends on / Flow.** Maps onto the estate's layered controls (perimeter FGT01 → east-west MKT01 → host CIS → identity tiers).

**📄 Expands.** [`Atlas-Service-Architecture`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-Service-Architecture.md) · the estate Policies (`POL-*`).

**Grounding.** 📘 study-reference (grounded in the estate's security program).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.2 — Security program elements (awareness, training, physical access)

**What.** The human + physical layer: user awareness, training, and physical access control. Atlas documents these as a real program (awareness, physical security standard).

**Config.** — (program objective.)

**Verify.** — (audited against the program docs.)

**🔴 Breaks when.** Assuming technical controls cover a phished credential or an unlocked rack — the program layer is what catches those.

**🔗 Depends on / Flow.** Underpins every technical control (a shared password defeats AAA).

**📄 Expands.** the estate Security-Program + physical-security standard (`STD-0003`).

**Grounding.** 📘 study-reference (grounded in the estate's program docs).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.3 — Device access control using local passwords

**🏅 Cert.** [`CCNA Ch10 (Vol 2) — Securing Network Devices`](../Certification/CCNA/Vol2/Ch10-Securing-Network-Devices.md).

**What.** The local line of defence every device keeps: a named admin with an encrypted secret, an `enable secret`, no generic accounts, and the break-glass account you never centralize. Real: `ciscoadmin` priv 15, `secret 9` on the 1941/SW01.

**Config.**
- `enable secret <strong>` — Type-9/8 (scrypt/PBKDF2), never Type-7
- `username ciscoadmin privilege 15 secret <strong>`
- `service password-encryption` — hide the remaining cleartext (weak, but no plaintext at rest)
- `login block-for 30 attempts 3 within 500` — brute-force throttle

**Verify.**
- `show run | include username|enable secret` → `secret 9`, no `cisco`/`admin` generic, no Type-5/7.
- `show run | include login block` → the throttle present.

**🔴 Breaks when.** A generic account or a Type-7 secret (trivially reversible). 🔴 **Never PKI-ify / centralize the one local break-glass account** — the box must stay reachable if AD/RADIUS is down.

**🔗 Depends on / Flow.** Local auth is the fallback under **AAA/RADIUS** (5.8) — keep exactly one local break-glass.

**📄 Expands.** [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) · [`CIS-Hardening-SW01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md).

**Grounding.** ✅ device-verified (named admin, Type-9, throttle — 07-22).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.4 — Password policy elements (complexity, MFA, certificates, biometrics)

**What.** Management, complexity, and alternatives/step-ups: MFA, certificates, biometrics. Atlas: password/auth standard (`STD-0001`) + AD **PSOs**, **MFA via Entra**, **certs via AD CS**.

**Config.** — (policy objective; enforced in AD/Entra, not IOS.)

**Verify.** — (AD `Get-ADUserResultantPasswordPolicy`, not IOS.)

**🔴 Breaks when.** Complexity without a length floor, or MFA that excludes the highest-value (Tier-0) accounts.

**🔗 Depends on / Flow.** Device local passwords (5.3) sit under this policy; RADIUS/NPS (5.8) enforces the AD identity.

**📄 Expands.** the estate `STD-0001` (password & authentication).

**Grounding.** 📘 study-reference (grounded in `STD-0001` / AD PSOs).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.5 — IPsec remote-access and site-to-site VPNs

**🏅 Cert.** [`CCNA Ch19 (Vol 2) — WAN Architecture`](../Certification/CCNA/Vol2/Ch19-WAN-Architecture.md).

**What.** Site-to-site (gateway↔gateway tunnel) vs remote-access (client↔gateway). Atlas: **FGT01 IPsec** (FortiOS); an Azure S2S scenario is roadmap. Not an IOS build here.

**Config.** — (📘; FortiOS/edge, not the 1941.)

**Verify.** — (on FGT01, not IOS.)

**🔴 Breaks when.** Mismatched phase-1/phase-2 parameters (encryption/DH/PFS) between peers — the classic tunnel-won't-come-up.

**🔗 Depends on / Flow.** VPN terminates at the perimeter (FGT01), not the core router.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) (VPN on FGT01 / Azure S2S).

**Grounding.** 📘 study-reference (FGT01 IPsec, FortiOS).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.6 — Configure and verify access control lists (ACLs)

**What.** Standard (source only), extended (5-tuple), named. Real: the **1941 CCNA overlay** runs a standard ACL (deny VLAN 70→20) and an extended named ACL (VLAN 50→20 on 443 only) — grounded in the east-west flows matrix.

**Config.** *(real overlay values)*
- standard: `access-list 10 deny 10.70.0.0 0.0.0.15` → `permit any`; apply **outbound near the destination** (`ip access-group 10 out` on `Gi0/0.20`)
- extended named: `ip access-list extended CLIENTS-TO-SERVERS` → `permit tcp 10.50.0.0 0.0.0.127 10.20.0.0 0.0.0.63 eq 443` → `deny ip …` → `permit ip any any`; apply **inbound near the source**

**Verify.**
- `show access-lists` → the ordered lines; run traffic, then re-check — the **match counts climb** on the exercised line (that delta is the proof).

**🔴 Breaks when.** 🔴 **Wildcard, not subnet mask** (`/28`→`0.0.0.15`). The invisible **implicit `deny any`** at the end (why standard ACL 10 needs `permit any`). Standard ACL placed near the *source* over-blocks. And the **`015` ping trap** — a failed ping to a 443-only host doesn't mean 443 is blocked.

**🔗 Depends on / Flow.** ACLs enforce the flows matrix on the 1941 (lab) / the firewall on MKT01 (prod); vty ACLs scope management (2.8).

**📄 Expands.** the ⭐ [`Set-Up-the-1941-for-the-CCNA-Lab`](../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) + [`Build-Guide-CCNA-Lab-Overlay`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide-CCNA-Lab-Overlay.md) · [`Atlas-East-West-Allowed-Flows-Matrix`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md).

**🏅 Cert.** [`CCNA Ch6 (Vol 2) — Basic IPv4 ACLs`](../Certification/CCNA/Vol2/Ch06-Basic-IPv4-Access-Control-Lists.md) · [`Ch7 — Named & Extended`](../Certification/CCNA/Vol2/Ch07-Named-and-Extended-IP-ACLs.md) · [`Ch8 — Applied`](../Certification/CCNA/Vol2/Ch08-Applied-IP-ACLs.md).

**Grounding.** ✅ pattern authored to real Atlas VLANs/flows; 🟡 until the operator runs the overlay on hardware.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.7 — Layer 2 security (DHCP snooping, dynamic ARP inspection, port security)

**What.** Protect the access layer: **DHCP snooping** (trust only real DHCP uplinks + build a binding table), **DAI** (validate ARP against those bindings), **port-security** (limit MACs per port). Real on **SW01**: snooping on VLANs 10–90, **DAI on 20–90**, trust on the MKT01 (`Gi1/0/1`) + PVE01 (`Gi1/0/4`) trunks.

**Config.** *(real SW01 — Build-Guide Step 6 + the port-security notes)*
- `ip dhcp snooping` · `ip dhcp snooping vlan 10,20,…,90`
- `ip arp inspection vlan 20-90`
- the trunks: `ip dhcp snooping trust` + `ip arp inspection trust`
- access port: `switchport port-security` · `…maximum 2` · `…mac-address sticky` · `…violation shutdown`

**Verify.**
- `show ip dhcp snooping` → enabled, uplinks trusted, access untrusted.
- `show ip arp inspection statistics vlan 20` → a climbing **Dropped** counter = a legit host being blocked.
- `show port-security` → per-port max/violation/sticky state.

**🔴 Breaks when.** 🔴 **DAI drops a static VM's ARP on an *untrusted* trunk** — a statically-addressed VM (e.g. **DC01 on VLAN 20**) has no snooping binding, so its ARP is dropped and it can't reach its gateway *at all* until the hypervisor uplink (`Gi1/0/4`) is `ip arp inspection trust` (this cut DC01 off entirely — device-verified 07-21). Port-security `violation shutdown` → an err-disabled port (recover with `errdisable recovery cause psecure-violation`).

**🔗 Depends on / Flow.** DAI ⇐ the DHCP-snooping binding table (no snooping → no bindings → DAI drops everything untrusted); trust rides the trunk ports (2.2).

**📄 Expands.** [`SW01 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) Step 6 · Playbook [`Diagnose-a-Host-Silently-Dropped-by-DAI`](../Playbooks/Diagnose-a-Host-Silently-Dropped-by-DAI.md).

**🏅 Cert.** [`CCNA Ch11 — Switch Port Security`](../Certification/CCNA/Vol2/Ch11-Switch-Port-Security.md) · [`Ch12 — DHCP Snooping & DAI`](../Certification/CCNA/Vol2/Ch12-DHCP-Snooping-and-DAI.md) — the reverse index (objective → artifact).

**Grounding.** ✅ device-verified (snooping + DAI trust on SW01, 07-21).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.8 — AAA (authentication, authorization, accounting)

**What.** Centralize *who can log in* (authentication), *what they can do* (authorization), *what they did* (accounting). Atlas: **RADIUS → NPS01** (`ADR-0029` — Windows NPS, **not** FreeRADIUS); local named-admin today, NPS when the DC + AD CS + NPS01 exist.

**Config.** *(when NPS01 exists)*
- `aaa new-model` · `radius server NPS01` → `address ipv4 10.20.0.x` · `key <shared>`
- `aaa authentication login default group radius local` — RADIUS, **fall back to local**

**Verify.**
- `show run | include aaa|radius` → the model + server; test a RADIUS login **and** the local fallback.

**🔴 Breaks when.** 🔴 **No `local` fallback** (or a PKI-ed break-glass) → if NPS/AD is down, you're locked out. Reconcile the stale study note: Atlas moved **FreeRADIUS → NPS** (`ADR-0029`) — the cert map §5 still says FreeRADIUS.

**🔗 Depends on / Flow.** RADIUS ⇐ NPS ⇐ AD CS (NPS server cert) ⇐ DC — the whole stack must exist first; until then, 5.3 local auth holds.

**📄 Expands.** [`ADR-0029`](../../00-Atlas-Foundation/Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md) · [`1941 Considerations`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md) (Pass-2 RADIUS gate).

**Grounding.** 🟡 partial (decided `ADR-0029`; local now, NPS 📋 pending).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.9 — Wireless security protocols (WPA, WPA2, WPA3)

**🏅 Cert.** [`CCNA Ch3 (Vol 2) — Securing Wireless Networks`](../Certification/CCNA/Vol2/Ch03-Securing-Wireless-Networks.md).

**What.** WPA2 (AES-CCMP) vs WPA3 (SAE); PSK (personal) vs 802.1X/Enterprise. Atlas: **FortiAP**; WPA2-Enterprise = 802.1X back to **NPS01**. 📘 build gap (no Cisco WLC; AP not yet in lab).

**Config.** — (FortiAP GUI, not IOS.)

**Verify.** — (on the FortiGate wireless side.)

**🔴 Breaks when.** PSK where the design wants **Enterprise** — only 802.1X ties the WLAN to per-user identity (NPS/RADIUS).

**🔗 Depends on / Flow.** WPA2-Enterprise ⇒ 802.1X ⇒ NPS01 (5.8).

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §wireless.

**Grounding.** 📘 study-reference / build gap.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5.10 — Configure a WLAN with WPA2 PSK (GUI)

**What.** Stand up a basic SSID with WPA2-PSK in the wireless GUI. 📘 build gap — Atlas's GUI is **FortiAP/FortiGate**, not Cisco WLC; the SSID→VLAN→security mapping transfers, the screens don't.

**Config.** — (GUI objective; no IOS CLI.)

**Verify.** — (client associates + gets a VLAN-scoped lease, checked in the FortiGate GUI.)

**🔴 Breaks when.** SSID mapped to the wrong VLAN, or PSK where Enterprise was intended (5.9).

**🔗 Depends on / Flow.** WLAN → VLAN (trunk to the AP, 2.2) → DHCP (4.3/4.6).

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §wireless.

**Grounding.** 📘 study-reference / build gap.


═══════════════════════════════════════════════════════════════════════════════
## ═══ DOMAIN 6 — AUTOMATION & PROGRAMMABILITY (10%)
═══════════════════════════════════════════════════════════════════════════════

> Grounded in the estate's IaC path — **Oxidized → NetBox → Ansible** (`ADR-0048`): the whole reason this audit exists (docs drifting from devices) is what automation fixes. Objectives 6.1–6.7. Mostly 🟡 (planned) / 📘 (concept) until NetBox/CNT01 are built.

### 6.1 — How automation impacts network management

**What.** Automation replaces manual, per-box CLI with programmatic, **consistent, versioned, auditable** change — fewer human errors, faster rollout. Atlas's first step is **Oxidized**: it pulls each device's running config on a schedule and commits it to git, so it *tells you the moment a device stops matching its doc*.

**Config.** — (approach objective.)

**Verify.** — (an Oxidized git diff / a clean idempotent re-run, once built.)

**🔴 Breaks when.** Automating a **bad process** just makes mistakes faster; with **no source of truth** there's nothing authoritative to render from (garbage-in).

**🔗 Depends on / Flow.** **Oxidized → NetBox → Ansible** (`ADR-0048`) — backup/diff first, then source-of-truth, then rendering.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §6 (Oxidized→NetBox→Ansible).

**Grounding.** 🟡 partial (the IaC path is the estate's stated plan, not yet built).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 6.2 — Traditional vs controller-based networking

**🏅 Cert.** [`CCNA Ch22 (Vol 2) — Cisco SD-Access`](../Certification/CCNA/Vol2/Ch22-Cisco-Software-Defined-Access.md).

**What.** Traditional = each device has its own **control plane** (decides locally, configured box-by-box). Controller-based = a central controller programs the fabric through APIs. Atlas is **traditional CLI** today.

**Config.** — (comparison objective.)

**Verify.** — (n/a; conceptual.)

**🔴 Breaks when.** Expecting SDN benefits (central policy, one-touch change) from a hand-configured CLI estate — they don't come for free.

**🔗 Depends on / Flow.** Sets up the SDN architecture in 6.3.

**📄 Expands.** [`Atlas-Roadmap-Advanced-Scenarios`](../Certification/Atlas-Certification-Lab-Map.md) (SDN as a concept).

**Grounding.** 📘 study-reference.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 6.3 — Controller-based, software-defined architecture (overlay, underlay, fabric)

**What.** SDN separates the **control plane** (the controller) from the **data plane** (the switches); **northbound** APIs face apps, **southbound** APIs face devices; the **underlay** (physical) carries the **overlay** (virtual fabric). Concept-only in Atlas (no controller).

**Config.** — (architecture objective.)

**Verify.** — (n/a.)

**🔴 Breaks when.** Swapping northbound/southbound — northbound is to the *applications/operator*, southbound is to the *network devices*.

**🔗 Depends on / Flow.** The APIs here are REST (6.5); the data they carry is JSON (6.7).

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §6.

**Grounding.** 📘 study-reference (no controller in Atlas).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 6.4 — AI and machine learning in network operations

**What.** (New in v1.1.) **Predictive** ML (anomaly detection, capacity forecasting) and **generative** AI (config assistants, summarization) applied to network ops. Atlas uses AI assistance for the docs/build; no AIOps platform in the estate.

**Config.** — (concept objective.)

**Verify.** — (n/a.)

**🔴 Breaks when.** Trusting a model's output without a read-back — the estate's `POL-0001` evidence rule applies to AI output too (verify, don't assume).

**🔗 Depends on / Flow.** Consumes the telemetry from SNMP/syslog (4.4/4.5) once MON01 collects it.

**📄 Expands.** [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md) §6.

**Grounding.** 📘 study-reference.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 6.5 — Characteristics of REST-based APIs

**🏅 Cert.** [`CCNA Ch23 (Vol 2) — REST & JSON`](../Certification/CCNA/Vol2/Ch23-Understanding-REST-and-JSON.md).

**What.** REST = stateless HTTP: **verbs** map to **CRUD** (GET=read · POST=create · PUT/PATCH=update · DELETE=delete), **auth** (token/key/basic), **encoding** (usually JSON). Atlas has **two real REST endpoints**: the **NetBox** API and the **FortiOS** API.

**Config.** — (client-side; e.g. `curl -H "Authorization: Token <t>" https://netbox.atlas.lab/api/dcim/devices/`.)

**Verify.**
- a `200 OK` + a JSON body = the call worked; a `401/403` = an auth problem (missing/wrong token).

**🔴 Breaks when.** Missing/expired **token** → `401/403`; the wrong **verb** (a `GET` where a `POST` was needed) → nothing changes or a `405`.

**🔗 Depends on / Flow.** REST is how Ansible (6.6) reads/writes NetBox; the payloads are JSON (6.7).

**📄 Expands.** the NetBox / FortiOS API docs (real endpoints, once NetBox is built).

**Grounding.** 🟡 partial (real curl-able APIs — after NetBox/CNT01).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 6.6 — Configuration-management mechanisms (Ansible, Terraform)

**🏅 Cert.** [`CCNA Ch24 (Vol 2) — Ansible & Terraform`](../Certification/CCNA/Vol2/Ch24-Understanding-Ansible-and-Terraform.md).

**What.** Declarative, **idempotent** config management: **Ansible** (agentless, push, YAML playbooks) for device config; **Terraform** (state-driven provisioning) for infrastructure. Atlas's plan: **Ansible renders device configs from NetBox** (`ADR-0048`, Book 6).

**Config.** — (a playbook/inventory, not device CLI.)

**Verify.**
- an **idempotent** run: apply once → changes; run again → **no changes** (that "0 changed" is the proof the state matches intent).

**🔴 Breaks when.** Non-idempotent tasks (they "change" every run); **drift** when NetBox (the source of truth) and the device diverge — Oxidized (6.1) is what catches that.

**🔗 Depends on / Flow.** Ansible ⇐ **NetBox** (source of truth) → renders → pushes to devices; closes the Oxidized→NetBox→Ansible loop.

**📄 Expands.** [`ADR-0048`](../../00-Atlas-Foundation/Decisions/ADR-0048-Automation-and-IaC-Model.md) (the IaC model).

**Grounding.** 🟡 partial (Atlas's stated Book-6 path; not yet built).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 6.7 — Components of JSON-encoded data

**What.** JSON = **objects** `{ "key": value }`, **arrays** `[ … ]`, and scalars (string/number/boolean/null). It's the shape a NetBox/FortiOS API response comes back in.

**Config.** — (data-format objective.)

**Verify.**
- parse a real API response with `jq` (or Python) → confirm it's an object vs an array, and pull a key.

**🔴 Breaks when.** Invalid JSON — a **trailing comma**, unquoted keys, or single quotes; confusing an **object** (unordered key/value) with an **array** (ordered list) when indexing.

**🔗 Depends on / Flow.** JSON is what REST (6.5) returns and Ansible (6.6) consumes — the data layer under the whole automation stack.

**📄 Expands.** a NetBox/FortiOS API response (once built).

**Grounding.** 🟡 partial (real API payloads — after NetBox).

<br>

---

## Appendix A — v1.0 service-grouped reference ✅ fully migrated

> 🗄️ **Migration complete (`ADR-0012` / `POL-0008`).** The original v1.0 service tables were rewritten into the six v3 domains — one home per fact. Where each went: **§Mgmt / SSH → 2.8 · 4.8** · **§Time / NTP → 4.2** · **§Interfaces / VLAN / trunk → 2.1 · 2.2 · 2.3 · 1.13** · **§Routing / OSPF → 3.1 · 3.4** · **§Security / hardening → 5.3 · 5.7** · **§Logging → 4.5** · **§Connectivity (work L1→up) → 1.4 · 1.5 + the Playbooks [`Trace-a-Blocked-Flow`](../Playbooks/Trace-a-Blocked-Flow.md) · [`Test-a-Connection`](../Playbooks/Test-a-Connection.md)**. The domains above are the home.

---

## Related
- Device quick-refs (link *up* here): [`1941 Diagnostics`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Diagnostics.md) · [`SW01 Diagnostics`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Diagnostics.md).
- Hardening: [`CIS-Hardening-SW01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) · [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md).
- Academy: [`Concepts/README`](../Concepts/README.md) (the "why") · [`Atlas-Teaching-Patterns-and-House-Style`](../Atlas-Teaching-Patterns-and-House-Style.md) · the ⭐ [`Set-Up-the-1941-for-the-CCNA-Lab`](../Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) Playbook · [`Atlas-Certification-Lab-Map`](../Certification/Atlas-Certification-Lab-Map.md).
- Architecture: [`Lab-02-Per-Device-Config-Design-Checklists`](../../Labs/Lab-02-Cisco-Core/Architecture/Lab-02-Per-Device-Config-Design-Checklists.md) · [`Cabling-and-Port-Map`](../../Labs/Lab-02-Cisco-Core/Architecture/Cabling-and-Port-Map.md) · [`Atlas-East-West-Allowed-Flows-Matrix`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) · [`IP-Addressing-Plan-VLSM`](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) · [`IPv6-Addressing-Plan`](../../Labs/Lab-02-Cisco-Core/Architecture/IPv6-Addressing-Plan.md).
- `00-Atlas-Foundation/Decisions/ADR-0032` (this library's mandate) · `ADR-0023` (1941 role) · `ADR-0020` (NTP) · `ADR-0029` (NPS not FreeRADIUS).

## Change Log
| Version | Changes |
|---|---|
| 3.5 | 2026-08-05. **Domain 6 (Automation & Programmability, 6.1–6.7) built to v3 — the whole-blueprint v3 rebuild is COMPLETE.** Automation impact (Oxidized→NetBox→Ansible, `ADR-0048`) · traditional vs controller-based · SDN architecture (control/data plane, N/S-bound APIs) · AI/ML in netops (new v1.1) · REST APIs (real NetBox/FortiOS endpoints) · config-mgmt (Ansible-from-NetBox, idempotence) · JSON. **Finalized:** frontmatter marked complete; top-index all ✅; **Appendix A fully retired to a pointer map** (all v1.0 tables now homed in Domains 1–6, `POL-0008`). All On-this-page anchors resolve; 0 broken file links. |
| 3.4 | 2026-08-05. **Domain 5 (Security Fundamentals, 5.1–5.10) built to v3** — security concepts/program (→ estate POL/STD) · local password control (real `ciscoadmin` Type-9 + break-glass rule) · password policy (`STD-0001`) · IPsec VPN (FGT01, 📘) · ACLs (the real 1941-overlay standard+extended, wildcard/implicit-deny/`015` traps) · L2 security (SW01 snooping/DAI/port-security — the DC01-dropped-by-DAI lesson) · AAA (RADIUS→NPS `ADR-0029`, the local-fallback rule; reconciles the stale FreeRADIUS note) · wireless (📘). From the ACL/Port-Security notes + SW01 Build-Guide + the overlay; index + top-index updated. 0 broken links. |
| 3.3 | 2026-08-05. **Domain 4 (IP Services, 4.1–4.9) built to v3** — NAT · NTP (DC01 `10.20.0.2`, the `show ntp status` not `show run` rule, `CM-0030`) · DHCP+DNS role (DC01/Pi-hole) · SNMP (the removed v2c `homelab`, `CM-0023`) · syslog facilities/severity · DHCP client/relay (`ip helper-address`→DC01) · QoS PHB (📘 needs `iperf3`) · SSH (real 1941 key/vty + the legacy-KEX gotcha) · TFTP/FTP. From the operator's NAT/NTP/DHCP notes + the device reality; index + top-index updated. 0 broken links. |
| 3.2 | 2026-08-05. **Domain 3 (IP Connectivity, 3.1–3.5) built to v3** — routing-table components · forwarding decision (longest-match/AD/metric, the `/8`-vs-`/24` incident) · IPv4/IPv6 static + floating (the honest single-homed-egress caveat) · single-area OSPFv2 (the real 1941 adjacency with MKT01 — router-id/loopback, the two /30s, `default-information originate`, the MTU/EXSTART interop + the network-statement mistake) · FHRP (📘 single gateway today). Sourced from the [`1941 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md)/Checklist/Considerations + the operator's `OSPF Config`/`Static Routes` notes. Retired the Appendix-A §Routing subsection into Domain 3 (`POL-0008`); index + top-index updated. 0 broken links. |
| 3.1 | 2026-08-05. **Domain 2 (Network Access, 2.1–2.9) built to v3** — VLANs · trunking/802.1Q/native · CDP & LLDP · EtherChannel · Rapid-PVST+ · wireless arch/AP-modes · device-mgmt access · WLAN GUI; sourced from the operator's `Trunking`/`STP`/`Etherchannel`/`CDP & LLDP` notes + the [`SW01 Build-Guide`](../../Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch/Build-Guide.md) (real trunk native-999, the 2960X 802.1Q-only trap, root-guard/portfast/bpduguard, the legacy-SSH-KEX gotcha). EtherChannel + wireless marked 📘 build gaps. Added an **On-this-page** index (operator ask), retired the Appendix-A §Interfaces subsection into Domain 2 + 1.13 (`POL-0008`), and updated the top-index + change log. 0 broken links. |
| 3.0 | 2026-08-05. **v3 rebuild started (`#44`) — reorganised to the CCNA 200-301 v1.1 blueprint** (six domains + top index) in the locked v3 per-objective shape (What · Config · Verify+worked read-back · 🔴 Breaks-when · 🔗 Depends-on/Flow · 📄 Expands · ✅/🟡/📘 grounding · `━━━` dividers). **Domain 1 (Fundamentals, 1.1–1.13) fully built** from the operator's `Basic Configuring Router Commands` / `VLAN Troubleshooting` notes + the 1941/SW01 Build-Guides + Diagnostics (real Atlas values, gotchas → the Breaks-when line); IPv6 (1.8/1.9) + wireless (1.11) marked 📘 build gaps. **Domains 2–6 seeded as 📋 scope stubs** (objective list + sources per domain). The v1.0 service-grouped tables preserved in **Appendix A** (transitional, `ADR-0012`) — they migrate into Domains 2–6 as those are built. No device links broken (device `Diagnostics.md` up-links target the file, not fragments). |
| 1.1 | 2026-08-01. **Seeded the observability tool-domain page `Syslog-and-SNMP.md`** (Backlog **#34**) — rsyslog + LibreNMS collector on MON01 + the per-platform senders/agents; added the by-service row. 📋 method authored; read-backs land when MON01 (Phase 6) is built. |
| 1.0 | 2026-07-28. Created (`ADR-0032`). Cisco IOS verify commands by service — mgmt/SSH, NTP, interfaces/VLAN/trunk, OSPF routing, security/hardening, connectivity (L1→up), logging — each with healthy-vs-broken. Carries the `show`-status-not-`show run` rule and the 1941 legacy-SSH client-config note. *(Preserved in Appendix A, migrating into the v3 domains.)* |
