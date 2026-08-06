---
Title: Atlas CCNP Enterprise Lab Map — ENCOR 350-401 + ENARSI 300-410 (checkable study plan)
Path: Atlas-Academy/Certification
Status: 🟢 LIVING — the CCNP study plan (extends the CCNP section of `Atlas-Certification-Lab-Map.md`). Objective rows are **checkable** ([ ] → [x]) as each is proven on a device or a CML topology (`POL-0001`). Realizes the roadmap's advanced-scenarios layer.
Version: 1.0
Date: 2026-07-29
Scope: Global
---

# Atlas CCNP Enterprise Lab Map — ENCOR + ENARSI

<!-- provenance -->
> **What this is.** The CCNP counterpart to the CCNA map: every **ENCOR 350-401** + **ENARSI 300-410** exam objective mapped to the Atlas lab that teaches it, with a **checkbox to tick when you've proven it.** Written under Charter Rule 16 — it gives you the lab, the objective, and the verification; **you** type the config. Objectives transcribed from Cisco's official exam topics (ENCOR v1.2 · ENARSI 300-410) — **validate against the live blueprint before you sit** (Sources).

## 0. The CCNP reality — CML is the engine, physical is the integration

CCNP is **multi-router, multi-protocol** (EIGRP/OSPF/BGP redistribution, DMVPN, MPLS, FHRP at scale). Atlas has exactly **one** real Cisco IOS router (the **1941**) and **one** Catalyst switch (**SW01**) — not enough topology for most CCNP objectives on their own. Per the CCNA map's §4 finding, the answer is **not** more physical boxes (watts/heat/noise) — it's **Cisco Modeling Labs (CML) on PVE01**: real IOS/IOS-XE/NX-OS nodes, arbitrary topologies, zero added watts. **Use physical gear (1941 + SW01 + FGT01/MKT01) for real integrated/messy labs; use CML for topology depth + exam-CLI reps.**

**Prereqs (from the CCNA map):** the **1941 online** (free — do this first), **CML** stood up on PVE01 (CML-Free 5-node to start; CML-Personal 20-node when topologies grow), and a genuine **FTDI console cable**.

**Status key:** 🟢 **do now** (Atlas physical gear exists) · 🟡 **needs the 1941 online / a 2nd Cisco node** · 🧪 **CML** (virtual Cisco topology on PVE01) · ⚪ **theory / read-only** (no controller/appliance — SD-WAN, Catalyst Center, TrustSec).

## 1. ENCOR 350-401 → Atlas lab

### 1.0 Architecture (15%)
- [ ] **Enterprise design** (2-tier · 3-tier · fabric · cloud) — diagram Atlas as collapsed-core, contrast with 3-tier/fabric 🟢 + ⚪
- [ ] **High availability / FHRP** (redundancy · HSRP · VRRP · GLBP) — **VRRP on MKT01 now** 🟢 · HSRP on the 1941 (+ SVIs) 🟡 · multi-router FHRP + GLBP in CML 🧪
- [ ] **SD-WAN + SD-Access** (control/data plane, fabric roles) — ⚪ read-only (no controller)
- [ ] **QoS** (classification · marking · policing/shaping · queuing) — 1941 IOS QoS proven with **iperf3-generated congestion** 🟡 · concept 🟢
- [ ] **Wireless (ENCOR depth)** (AP modes · roaming · RF) — FortiAP (Fortinet mgmt) 🟢 · Cisco WLC/CAPWAP specifics ⚪ (CML/Packet Tracer)

### 2.0 Virtualization (10%)
- [ ] **Device virtualization** (hypervisor type 1/2 · VMs · containers) — PVE01 (type-1) + a container 🟢
- [ ] **Data-path virtualization** (VRF · GRE/IPsec tunneling) — VRF-lite + GRE on the 1941 🟡 · CML 🧪
- [ ] **Network virtualization** (LISP · VXLAN) — ⚪ concept / CML fabric lab 🧪

### 3.0 Infrastructure (30% — biggest)
- [ ] **L2 — trunking + EtherChannel** (802.1Q · LACP/PAgP) — SW01 trunk 🟢 · EtherChannel needs a 2nd switch + 2 links (**SG300**) 🟡
- [ ] **L2 — STP** (RSTP · MST · root · PortFast/BPDU/root guard) — SW01 RSTP root 🟢 · MST + real root election with a 2nd switch 🟡 / CML 🧪
- [ ] **L3 — EIGRP** (adjacency · metrics · summarization · load-balancing) — CML (needs 2+ IOS routers) 🧪
- [ ] **L3 — OSPF** (multi-area · neighbors · network types · summarization) — **OSPF FGT01↔MKT01 now** 🟢 · IOS multi-area on 1941 + CML 🧪
- [ ] **L3 — BGP** (eBGP · path selection · neighbors) — single-peer concept on FGT/MKT 🟢 · multi-AS in CML 🧪
- [ ] **IP Services** (NTP · NAT/PAT · HSRP/VRRP · multicast: PIM/IGMP) — NTP/NAT on 1941 🟡 · multicast in CML 🧪

### 4.0 Network Assurance (10%)
- [ ] **Diagnostics** (debug + conditional debug · ping/traceroute · SNMP · syslog) — every Atlas device → MON01 🟢
- [ ] **Flow + capture** (NetFlow · SPAN/RSPAN/ERSPAN) — SW01 SPAN (`Gi1/0/5`) 🟢 · NetFlow → MON01 🟢/🟡
- [ ] **IP SLA** (probes · tracking) — 1941 IP SLA + FHRP tracking 🟡 · CML 🧪
- [ ] **Catalyst Center (DNA)** — ⚪ read-only (no appliance)
- [ ] **NETCONF / RESTCONF** — IOS-XE in CML 🧪 · NetBox / FortiOS REST API as the analog 🟢

### 5.0 Security (20%)
- [ ] **Device access control** (AAA · TACACS+ / RADIUS / local) — **NPS RADIUS + 802.1X on SW01** 🟢 · TACACS+ concept 🟡
- [ ] **Infrastructure security** (ACLs · CoPP · port-security · DHCP snooping · DAI) — SW01 snooping/DAI ✅, add **port-security** 🟢 · IOS ACLs + CoPP on the 1941 🟡
- [ ] **Security design** (threat defense · NGFW · REST API security · TrustSec) — FGT01 NGFW 🟢 · TrustSec ⚪
- [ ] **Wireless security** (WPA2/3 · 802.1X-Enterprise) — FortiAP against RADIUS 🟢

### 6.0 Automation & AI (15%)
- [ ] **Python / JSON / YANG** fundamentals — parse a NetBox / FortiOS API response 🟢
- [ ] **Cisco APIs + REST responses** — IOS-XE RESTCONF in CML 🧪 · NetBox API 🟢
- [ ] **EEM applets** — on the 1941 / CML 🧪
- [ ] **Orchestration** (Ansible/Puppet/Chef/Terraform compare) — **Ansible rendering configs from NetBox** (Atlas's stated IaC path) 🟢

## 2. ENARSI 300-410 → Atlas lab

> ENARSI is **troubleshooting-heavy** — and Atlas is *ideal* for it because it already generates real faults (the `/8`-vs-`/24` outage, the unsynced clock, the unbound cert). Turn every incident into an ENARSI repro.

### 1.0 Layer 3 Technologies (35% — biggest)
- [ ] **EIGRP troubleshoot** (all address families · summarization · load-balancing · stubs) — CML 🧪
- [ ] **OSPF troubleshoot** (v2/v3 · areas · LSA types · network types · summarization) — OSPF FGT↔MKT 🟢 · 1941 + CML 🧪
- [ ] **BGP troubleshoot** (eBGP/iBGP · path attributes · address families) — CML 🧪
- [ ] **Redistribution + route control** (administrative distance · route maps · prefix lists · tagging/filtering) — multi-protocol redistribution in CML 🧪
- [ ] **Policy-based routing + VRF-lite** — 1941 🟡 / CML 🧪

### 2.0 VPN Technologies (20%)
- [ ] **MPLS operations** (LSR · LDP · label switching · LSP · L3VPN concept) — ⚪ concept / CML 🧪
- [ ] **DMVPN single-hub** (GRE/mGRE · NHRP · IPsec · dynamic neighbors · spoke-to-spoke) — CML (multi-router) 🧪
- [ ] **IPsec + GRE tunnels** — 1941 GRE+IPsec to FGT/MKT 🟡 · **FGT01 IPsec S2S** ✅ 🟢

### 3.0 Infrastructure Security (20%)
- [ ] **IOS AAA** (TACACS+ / RADIUS / local database) — NPS RADIUS 🟢 · TACACS+ concept 🟡
- [ ] **Router security** (ACLs · uRPF · CoPP) — 1941 🟡
- [ ] **IPv6 first-hop security** (RA guard · DHCPv6 guard · ND inspection) — needs **IPv6 on one VLAN** (register H1) 🟡 / CML 🧪
- [ ] **Control-plane policing (CoPP)** — 1941 / CML 🧪

### 4.0 Infrastructure Services (25%)
- [ ] **Device management** (SSH · console · file transfer) — Atlas ✅ 🟢
- [ ] **SNMP (v2c→v3) + logging/syslog** — rotate the live `homelab` community, then SNMPv3 → MON01 🟢
- [ ] **DHCP** (server · relay `ip helper-address` · snooping) — IOS DHCP + relay on the 1941 🟡 · SW01 snooping ✅ 🟢
- [ ] **IP SLA + object tracking** — 1941 🟡
- [ ] **NetFlow / Flexible NetFlow** — SW01/1941 → MON01 🟢/🟡
- [ ] **Catalyst Center Assurance (DNA)** — ⚪ read-only

## 3. Start now (CCNP-level reps before CML/1941)
1. **OSPF between FGT01 and MKT01** (also a CCNA start-now) — extend it: multiple areas / summarization / network-type changes.
2. **VRRP on MKT01** — the FHRP concept before HSRP on the 1941.
3. **SPAN + NetFlow to MON01** — Network Assurance reps on real traffic.
4. **Ansible-from-NetBox** — the Automation domain, and Atlas's stated IaC path (shared with CCNA domain 6).
5. **Turn a real fault into an ENARSI repro** — document symptom → diagnostic path → fix.

## 4. What needs CML vs physical (honest split)
- **CML (🧪):** EIGRP, BGP multi-AS, OSPF multi-area at scale, redistribution, DMVPN, MPLS, LISP/VXLAN, multicast, RESTCONF/EEM on IOS-XE — anything needing **3+ router nodes**.
- **Physical (🟢/🟡):** the 1941 (OSPF/NAT/ACL/QoS/CoPP/IP-SLA/DHCP IOS CLI), SW01 (STP/trunk/SPAN/port-security/802.1X), FGT01 (NGFW/IPsec), MKT01 (VRRP/OSPF concept), FortiAP (wireless), PVE01 (virtualization + the CML host).
- **Read-only (⚪):** SD-WAN, SD-Access, Catalyst Center, TrustSec, cloud fabric — no controller in the lab.

## Related
- `Atlas-Certification-Lab-Map.md` (CCNA — the prerequisite; §5 CCNP path) · `AZ-800-801-Windows-Server-Hybrid-Lab-Map.md` · `Atlas-FortiGate-FCP-Lab-Map.md` · `00-Atlas-Foundation/Roadmap/Atlas-Roadmap-Advanced-Scenarios.md` (the architect's CCNP vision this realizes) · `Atlas-Firewall-Architecture.md` (E-W segmentation) · `ADR-0018` (silos, Rule 16) · `ADR-0044` (enterprise model, certs anchor).
- **Sources (validate against current):** ENCOR 350-401 exam topics — https://learningnetwork.cisco.com/s/encor-exam-topics · ENARSI 300-410 exam topics — https://learningnetwork.cisco.com/s/enarsi-exam-topics

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-29 | Created — the CCNP counterpart to the CCNA lab map. ENCOR 350-401 (6 domains, incl. the v1.2 *Automation **and AI*** rename) + ENARSI 300-410 (4 domains) objectives → Atlas lab + status + a **[ ] checkbox**. Status key 🟢/🟡/🧪(CML)/⚪; the "CML is the engine, physical is the integration" reality; a start-now list; and the honest CML-vs-physical split. Extends the CCNP section of `Atlas-Certification-Lab-Map` + `Atlas-Roadmap-Advanced-Scenarios`. |
