---
Title: Atlas Certification Lab Map — CCNA now, CCNP next
Path: Atlas-Academy/Certification
Status: Draft — design proposal and study plan. Realizes the roadmap for certification.
Version: 1.1
---

# Atlas Certification Lab Map — CCNA now, CCNP next

> **What this is.** `Atlas-Roadmap-Advanced-Scenarios.md` describes the *architect's* long-term vision (CCNP scenarios, MSP, Azure). This document fills the gap under it: a concrete **CCNA 200‑301 blueprint → Atlas lab** mapping for the exam you're studying *now*, what you can do today, what the **$500** budget should buy, and what stays theory. It is written under Charter Rule 16 — it gives you the lab, the objective, and the verification; **you** type the config.

## 0. The three findings that shape everything below

1. 🔴 **You own a Cisco 1941 and it is not in the lab.** Getting it online (Roadmap "Phase 1.5") is **free** and is the single highest-value CCNA move you can make — it is the only real **Cisco IOS router** you have, and CCNA routing (OSPF, ACLs, NAT, static/floating routes) is graded on IOS CLI. MKT01 (RouterOS) and FGT01 (FortiOS) teach the *concepts* with different syntax; the exam wants Cisco. **Prioritize standing up the 1941 before spending a dollar.**
2. 🟢 **Atlas already covers ~80% of CCNA hands-on** with real, messy, integrated gear — which is *better* than a simulator for retention, because things break in ways Packet Tracer never shows you (the `/24`-vs-`/8` outage, the silently-unbound cert, the SW01 clock that never synced). Use Atlas for depth; use **Packet Tracer / Cisco CML / Boson NetSim** for exam-CLI *drilling* and the topics Atlas can't physically do.
3. 🟢 **You already own the fixes for those gaps — the real constraint is power, not money.** You have a **FortiAP** (wireless), an **SG300** (a second managed switch), the **1941** (Cisco IOS router), and you replaced PVE01's CMOS battery tonight (`CM-0012` closed). So "more Cisco topology" is not more physical boxes drawing watts — it's **Cisco Modeling Labs on PVE01** (§4), and the $500 goes to **storage/backup**, not networking (§4b).

---

## 1. Assessment of the three source docs

| Doc | Agree | Improve / gap |
|---|---|---|
| **`Atlas-Service-Architecture.md`** | 🟢 Strongly. Role split, NetBox as SoT, offline Root CA, "don't run services on the 1 GiB router" — all correct and all great learning. | Foreground **CCNA value** per host (it reads as an ops plan); add **wireless** to the estate (a CCNA domain it omits); note the 1941 is *owned and idle*. |
| **`Atlas-Roadmap-Advanced-Scenarios.md`** | 🟢 Good CCNP/advanced vision (OSPF, HSRP, IP SLA, ZBF, MSP, Azure). | 🔴 **Skips the CCNA-level lab plan** — this document is that missing layer. Also: you can run **OSPF and VRRP between FGT01↔MKT01 today**, before the 1941, to start routing labs now. |
| **`ADR-0018` (silos)** | 🟢 Intent is right — boundaries create the pauses that catch mistakes; Rule 16 is excellent. | For a lab of one, 5 silos risks ceremony. Suggest *enforcing* only the two that actually caught real incidents so far — **Platform↔Security** (the git-committed passphrase) and **Services↔Network** (RADIUS rule on the wrong device) — and letting the rest be advisory until they earn enforcement. |

---

## 2. CCNA 200‑301 blueprint → Atlas lab map

Status key: 🟢 **do it now** (gear exists) · 🟡 **needs the 1941 online** (owned, free) · 🔵 **needs a $500 purchase** · ⚪ **theory / simulator** (Packet Tracer, CML, Boson).

### 1.0 Network Fundamentals (20%)

| Exam topic | Atlas lab | Status |
|---|---|---|
| Roles: router/switch/firewall/AP/endpoint | Name each Atlas device's role; FGT01 firewall, SW01 switch, MKT01/1941 router, Pi01/PVE01 endpoints/host | 🟢 (AP → 🔵) |
| Topology architectures (2/3-tier, spine-leaf, SOHO) | Atlas is a **collapsed-core / SOHO**; diagram it, contrast with 3-tier | 🟢 + ⚪ |
| Interfaces & cabling; interface/cable issues (duplex/speed/errors) | `show interfaces` on SW01 — CRC/errors/duplex; force a duplex mismatch and watch it | 🟢 |
| TCP vs UDP | Wireshark on LabComputer — capture a real TCP handshake and a DNS/UDP query | 🟢 |
| IPv4 addressing & subnetting | Your VLAN plan **is** a subnetting exercise; re-derive every subnet by hand | 🟢 (drill separately) |
| **IPv6 addressing** | 🔴 **Atlas is v4-only.** Add IPv6 (SLAAC + static) to one VLAN on the 1941/FGT01 — a real lab | 🟡 |
| Wireless principles (SSID, RF, WPA) | — | 🔵 (AP) + ⚪ |
| Virtualization (VMs/containers) | PVE01 — you already run VMs; add a container | 🟢 |
| Switching concepts (MAC table, flooding, ARP) | `show mac address-table` on SW01; watch it learn/age | 🟢 |

### 2.0 Network Access (20%)

| Exam topic | Atlas lab | Status |
|---|---|---|
| VLANs (data/voice), access ports | SW01 VLAN 10–80 — already built; add/verify | 🟢 |
| Trunking (802.1Q, native VLAN) | The SW01↔MKT01 trunk — inspect, change native VLAN, observe | 🟢 |
| Inter-switch connectivity / DTP | 🔴 needs a **second Catalyst** — trunk negotiation between two switches | 🔵 |
| CDP / LLDP | Enable both on SW01/1941; LibreNMS draws the topology from LLDP | 🟢 |
| EtherChannel (LACP/PAgP) | 🔴 needs a **second switch + two links** — bundle them | 🔵 |
| STP (RSTP, root, PortFast, BPDU guard, port states) | SW01 is RSTP root; **with a 2nd switch, root election becomes real** and you can break it | 🟢→🔵 |
| Wireless architecture (WLC, AP modes) | — | 🔵 (AP w/ Mobility Express) |
| WLAN config (WPA2, GUI) | — | 🔵 |

### 3.0 IP Connectivity (25% — the biggest domain)

| Exam topic | Atlas lab | Status |
|---|---|---|
| Routing table / forwarding (longest match, AD, metric) | `show ip route`; the FGT01 **`/8`-vs-`/24` outage is a real longest-match lesson** | 🟡 (1941) / 🟢 (concept) |
| Static routing (default, network, host, floating) | 1941 default + floating static as backup to the FGT01 path | 🟡 |
| **OSPFv2 single-area** | 🔴 **Run OSPF between FGT01 and MKT01 TODAY** (both support it) — neighbors, router-id, DR/BDR, cost. Redo on the 1941 for exam CLI | 🟢 now / 🟡 IOS |
| FHRP / HSRP | HSRP is Cisco — needs the 1941 (+ SVIs on SW01, or a 2nd router). **VRRP on MKT01 now** as the concept | 🟡 / 🟢 (VRRP) |

### 4.0 IP Services (10%)

| Exam topic | Atlas lab | Status |
|---|---|---|
| NAT (static, PAT) | FGT01 does PAT to the internet; add a static NAT on the 1941 | 🟢 / 🟡 |
| NTP | Atlas NTP — **and SW01's broken clock (`CM-0030`) is a real troubleshooting lab** | 🟢 |
| DHCP (server, relay, snooping) | SW01 DHCP snooping already; add an IOS DHCP server + `ip helper-address` relay | 🟢 / 🟡 |
| DNS | Pi-hole — inspect, add records | 🟢 |
| SNMP (v2c→v3) | 🔴 rotate the live `homelab` community first, then SNMPv3 to LibreNMS | 🟢 (after MON01) |
| Syslog | Ship SW01/FGT01 logs to MON01 | 🔵/planned |
| QoS (classification, marking, queuing) | 🔴 **needs generated congestion — `iperf3`** on LabComputer + a VM, then prove the policy changed the outcome | 🟢 (with iperf3) |
| SSH | Already on every device | 🟢 |
| TFTP/FTP | IOS image/config transfer to SRV01 | 🟡/planned |

### 5.0 Security Fundamentals (15%)

| Exam topic | Atlas lab | Status |
|---|---|---|
| AAA (RADIUS/TACACS+) | FreeRADIUS → **802.1X on SW01 ports** is a superb lab; NPS later to compare | 🟢 |
| Device hardening / access control | Your CIS checklists (`045`–`047`) are this domain, applied | 🟢 |
| L2 security: port security, DHCP snooping, DAI | SW01 already runs snooping + DAI; **add port security** (sticky MAC, violation) | 🟢 |
| ACLs (standard/extended/named) | IOS ACLs on the 1941; VTY ACL on SW01 now; FGT01 policy = the firewall view | 🟡 / 🟢 |
| Wireless security (WPA2/3, PSK/Enterprise) | 🔴 **WPA2-Enterprise = 802.1X wireless against your RADIUS** — ties AAA + wireless + security | 🔵 (AP) |
| VPN concepts (S2S / remote-access) | FGT01 IPsec; the Azure S2S scenario later | 🟡 / ⚪ |

### 6.0 Automation & Programmability (10%)

| Exam topic | Atlas lab | Status |
|---|---|---|
| Automation impact; traditional vs controller-based / SDN | Contrast Atlas (CLI) with SDN concepts | ⚪ |
| REST APIs | **NetBox API** and the **FortiOS API** are real REST you can curl | 🟢 (after NetBox) |
| Config mgmt (Ansible/Puppet/Chef) | **Ansible rendering configs from NetBox** — Atlas's stated IaC path | 🟢 (Book 6) |
| JSON / data formats | Parse a NetBox / FortiOS API response | 🟢 |
| Cisco DNA Center | — | ⚪ |

**Coverage:** every domain has real Atlas labs; the only pure-theory items are SDN/DNA Center and some wireless RF theory. **That is an exceptional CCNA lab for a homelab.**

---

## 3. Start now — before buying anything, before the 1941

These need zero new hardware and start real CCNA reps this week:

1. **OSPF between FGT01 and MKT01.** Both do OSPFv2. Bring up a single area, watch the neighbor state machine, verify the route exchange. *(Objective: adjacency, router-id, cost. Verify: neighbor table + routes both sides.)*
2. **Port security on an SW01 access port.** Sticky MAC, violation mode; then plug in a different device and watch it shut. *(This is also how you'd catch a rogue device.)*
3. **The SW01 clock as a troubleshooting lab.** `CM-0030` — it's `stratum 16, never synced`. *Fix it* (point it at a real server, or at FGT01 which now has a valid stratum-2 clock). Proving it with `show ntp status` is the exact CCNA skill.
4. **Wireshark the trust boundary.** Plug LabComputer into the SW01 SPAN port (`Gi1/0/5`, already mirroring the MKT01 trunk) and *watch inter-VLAN traffic*. Free packet analysis on real traffic.
5. **Subnet the whole lab by hand**, then check yourself against `006`. Subnetting is 20% of the exam and pure repetition.
6. 🔴 **Stand up Oxidized (automation, moved up).** It pulls the running config off every device on a schedule and commits it to git — so it *tells you the moment a device stops matching its doc*, the exact pain this whole audit exists to fix. Lowest effort, highest payoff, and it's CCNA domain 6 (config management, git, diffs). Then **NetBox** (source of truth), then **Ansible** rendering configs from it. **Order: Oxidized → NetBox → Ansible.**

---

## 4. Cisco Modeling Labs — the power-free "Cisco way"

> 🔴 **You own the physical gaps' fixes (FortiAP, SG300, 1941). Your real constraint is power/heat/noise — not money.** The answer to "more Cisco topology" is not more boxes. It's **Cisco Modeling Labs (CML) on PVE01.**

CML runs virtual IOS / IOS-XE / NX-OS nodes on the 62 GiB hypervisor you already own — real Cisco images, real CLI, arbitrary topologies, **zero added watts.** It's Cisco's own product and how a great many people study now.

- **CML-Free** — 5 nodes, $0. Enough for point topologies (two routers + OSPF; a switch pair + STP).
- **CML-Personal** — ~$199/yr, 20 nodes. A full CCNA/CCNP topology.
- **Free alternatives:** **Packet Tracer** (official, exam-shaped, $0) for drilling; **containerlab / GNS3** ($0) for real images on Proxmox.

Use **physical gear for the messy integrated labs** (real cabling and convergence, the SPAN port, 802.1X against your actual RADIUS) and **CML for topology depth + exam-CLI reps.** Run the 1941 and switches only during lab sessions — not 24/7 — to hold down power and fan noise.

### 4a. The gear you already own (don't re-buy)

| You have | Use it for | Honest caveat |
|---|---|---|
| **FortiAP** | Real wireless: SSIDs, WPA2-Enterprise **against your RADIUS** (802.1X) | Fortinet's management, not Cisco WLC. Cisco-WLC/CAPWAP GUI specifics → Packet Tracer/CML. |
| **SG300** | A second managed L2/L3 switch: VLANs, trunking, STP topology | Runs Small Business OS, **not IOS** — IOS-*like*, not exam-accurate CLI. Real switch, different syntax. |
| **1941** | 🔴 Your only real Cisco **IOS router** — OSPF, ACLs, NAT, HSRP, static/floating | Stand it up (free). Power it during lab sessions. |
| **PVE01** | The CML / containerlab host + all service VMs | CMOS battery replaced 2026-07-16 — `CM-0012` closed, nested-virt unblocked. |

### 4b. The $500 — pointed at compute/storage, not networking

The network gaps are covered by gear you own + CML, so spend the budget where it helps and doesn't add watts:

| # | Buy | ~Cost | Why |
|---|---|---|---|
| 1 | **Low-power NAS (2-bay) + 2 drives** *(or storage into PVE01)* | ~$300 | 🔴 Fixes **Critical Risk #1** (both CA copies in one room) **and** stores the CML/VM labs. The "server you'd rather have." Pick a low idle-watt unit. |
| 2 | **Genuine FTDI (FT232R) USB-serial console cable** | ~$20 | The CCNA console tool; closes the MKT01 console gap (`ADR-0016`). Your past three were counterfeit Prolific. |
| 3 | **CML-Personal license** *(optional — start on CML-Free)* | ~$199 | 20-node Cisco topologies on PVE01. Skip if the free 5-node tier is enough for now. |
| 4 | **External USB drive** for off-site rotation | ~$55 | The "1" in 3-2-1. Rotate it out of the room. |

**Two ways to spend it, both under $500:**
- **Backup-first (recommended):** NAS + drives (~$300) + console cable (~$20) + off-site USB (~$55) ≈ **$375**, stay on CML-Free. Closes your single biggest risk and gives you lab storage.
- **Cisco-depth-first:** console cable (~$20) + CML-Personal (~$199) + storage into PVE01 (~$120) + off-site USB (~$55) ≈ **$394**, if unlimited Cisco topology matters more than a dedicated NAS right now.

> **Not on the list, on purpose:** another switch, router, or AP. You own enough physical network gear — more is watts and fan noise for diminishing return. The **free 1941 + CML** is your Cisco topology engine.

---

## 5. The CCNP path (extends the Advanced-Scenarios doc)

Once CCNA is done and the 1941 is in production, the roadmap's scenarios line up cleanly:
- **ENCOR:** multi-area OSPF (add a second area on the 1941/FGT), EIGRP if you add a router, route redistribution, first-hop redundancy at scale, the firewall doc's east-west segmentation.
- **ENARSI (troubleshooting):** Atlas is *ideal* — it already generates real faults (the exact class you've been reconciling).
- **CCNP Security / NSE:** the `Atlas-Firewall-Architecture.md` east-west build (MKT01 as E-W firewall, Book 11), IOS Zone-Based Firewall on the 1941, FortiGate multi-VDOM for the MSP simulation.
- **Automation:** Ansible-from-NetBox is both a CCNP DevNet-adjacent skill and Atlas's stated Book 6.

---

## 6. How to study *with* Atlas (the method)

- **Atlas for depth, simulator for breadth.** Do the integrated, break-it-for-real labs on Atlas; drill pure exam CLI and the physically-impossible topics (big topologies, WAN) in **Packet Tracer / CML / Boson NetSim**.
- **Rule 16 applies to you, not just the AI.** For each lab, *you* write the config. Use the assistant (and this repo) for the design, the verification method, and the failure modes — then type it yourself. That's the whole point of the lab.
- **Every lab ends with a verification and a one-line record.** Same discipline as the reconciliation work: a config you didn't verify is a config you didn't learn.
- **Turn faults into labs.** The SW01 clock, the FGT01 `/8` route, the unbound cert — real incidents are the best troubleshooting practice you'll get. Don't just fix them; write down the diagnostic path.

## 7. Honest gaps (what Atlas still can't give you)

- **WAN technologies** (MPLS, PPP, broadband beyond your home uplink) — theory + simulator.
- **SDN / DNA Center / SD-Access** — concept only; no controller.
- **Large topologies** (many-router OSPF, spanning many areas) — CML/Packet Tracer.
- **Some IPv6 depth** — deployable in Atlas but you have to choose to build it (recommended: one dual-stack VLAN).

## Related pages

- **Sibling study plans:** `Atlas-CCNP-Lab-Map.md` (ENCOR+ENARSI) · `AZ-800-801-Windows-Server-Hybrid-Lab-Map.md` (Windows Server Hybrid) · `Atlas-FortiGate-FCP-Lab-Map.md` (FortiGate FCP).
- `Atlas-Roadmap-Advanced-Scenarios.md` (this realizes its missing CCNA layer) · `Atlas-Service-Architecture.md` (device roles / hardware) · `Atlas-Firewall-Architecture.md` (N‑S/E‑W) · `ADR-0018` (silos, Rule 16)

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-16. Realizes the roadmap for certification: a full CCNA 200‑301 blueprint → Atlas lab map, the "start now" list, a CCNA-prioritized $500 hardware plan (with the free 1941 move first), the CCNP path, a study method under Rule 16, and honest gaps. Includes an assessment of the three source docs. |
| 1.1 | 2026-07-16. Updated for owned gear (FortiAP, SG300, 1941) and the power constraint: §4 rewritten around **Cisco Modeling Labs on PVE01** (power-free Cisco topology) with the gear-you-own table and honest caveats (FortiAP≠Cisco WLC; SG300≠IOS); §4b repoints the $500 at **NAS/storage/backup + CML**, not more networking; automation (Oxidized→NetBox→Ansible) moved up into the "start now" list; `CM-0012` closed (CMOS replaced). |
