---
Title: Atlas Academy — Certification Tracks (index)
Path: Atlas-Academy/Certification
Status: 🟢 Living — the index for the estate's certification study plans. Each track maps a certification's objectives onto the real, already-built parts of Atlas that exercise them. Governed by the Academy Documentation Standard (`ADR-0053`).
Version: 1.0
Date: 2026-08-03
---

# Atlas Academy — Certification Tracks

> 🎓 **Each track maps a certification's objectives onto the real Atlas builds that prove them** — study by doing against the actual estate, not by re-hosting generic material (the Academy design principle). In the *checkable* plans, an objective row flips `[ ] → [x]` only once it is device-verified (`POL-0001`) — the same evidence bar as the rest of Atlas.

## The tracks

| Track | Target exam(s) | Status |
|---|---|---|
| [`Atlas-Certification-Lab-Map.md`](Atlas-Certification-Lab-Map.md) | **CCNA** now, **CCNP** next — the master study-plan / roadmap | Draft |
| [`Atlas-CCNP-Lab-Map.md`](Atlas-CCNP-Lab-Map.md) | **CCNP Enterprise** — ENCOR 350-401 + ENARSI 300-410 (checkable) | 🟢 Living |
| [`AZ-800-801-Windows-Server-Hybrid-Lab-Map.md`](AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) | **AZ-800 / AZ-801** — Windows Server Hybrid Administrator (checkable) | 🟢 Living |
| [`Atlas-FortiGate-FCP-Lab-Map.md`](Atlas-FortiGate-FCP-Lab-Map.md) | **FortiGate FCP** — FCP_FGT_AD-7.6 (checkable) | 🟢 Living |
| [`Atlas-Security-Plus-Domain5-Coverage-Map.md`](Atlas-Security-Plus-Domain5-Coverage-Map.md) | **Security+ SY0-701** — Domain 5 (Program Management & Oversight) coverage map | Draft |
| [`Atlas-CompTIA-Project-Plus-Lab-Map.md`](Atlas-CompTIA-Project-Plus-Lab-Map.md) | **CompTIA Project+ (PK0-005)** — objective spine + the Atlas artifacts per domain | 🟡 Seed |
| [`CompTIA-Pre-Teardown-Exercise-Catalogue.md`](CompTIA-Pre-Teardown-Exercise-Catalogue.md) | **A+ / Network+ / Security+** — pre-teardown exercise catalogue (do-before-teardown) | Draft |

*(A **CompTIA Linux+** track is planned — see [`../Academy-Vision-and-Scope.md`](../Academy-Vision-and-Scope.md).)*

### CCNA per-chapter reverse-index sub-pages (`CCNA/`) 🆕

The CCNA track is being deepened with **per-chapter reverse-index sub-pages** under [`CCNA/`](CCNA/) — each maps a chapter's paraphrased objectives to the exact Atlas artifact (**Command-Library §** · device doc · Concept · Playbook) and flags the gaps (📋). Objectives are paraphrased from the public blueprint, never copied from a book (Charter Rule 16). Built so far — **Vol 2:** [`Ch1 — Wireless Fundamentals`](CCNA/Vol2/Ch01-Fundamentals-of-Wireless-Networks.md) · [`Ch2 — Wireless Architectures`](CCNA/Vol2/Ch02-Analyzing-Cisco-Wireless-Architectures.md) · [`Ch3 — Securing Wireless`](CCNA/Vol2/Ch03-Securing-Wireless-Networks.md) · [`Ch4 — Building a WLAN`](CCNA/Vol2/Ch04-Building-a-Wireless-LAN.md) · [`Ch5 — TCP/IP Transport`](CCNA/Vol2/Ch05-Introduction-to-TCP-IP-Transport-and-Applications.md) · [`Ch6 — Basic IPv4 ACLs`](CCNA/Vol2/Ch06-Basic-IPv4-Access-Control-Lists.md) · [`Ch7 — Named & Extended ACLs`](CCNA/Vol2/Ch07-Named-and-Extended-IP-ACLs.md) · [`Ch8 — Applied IP ACLs`](CCNA/Vol2/Ch08-Applied-IP-ACLs.md) · [`Ch9 — Security Architectures`](CCNA/Vol2/Ch09-Security-Architectures.md) · [`Ch10 — Securing Network Devices`](CCNA/Vol2/Ch10-Securing-Network-Devices.md) · [`Ch11 — Switch Port Security`](CCNA/Vol2/Ch11-Switch-Port-Security.md) · [`Ch12 — DHCP Snooping & DAI`](CCNA/Vol2/Ch12-DHCP-Snooping-and-DAI.md) *(the golden template)* · [`Ch13 — Device Management Protocols`](CCNA/Vol2/Ch13-Device-Management-Protocols.md) · [`Ch14 — NAT`](CCNA/Vol2/Ch14-Network-Address-Translation.md) · [`Ch15 — QoS`](CCNA/Vol2/Ch15-Quality-of-Service.md) · [`Ch16 — FHRP`](CCNA/Vol2/Ch16-First-Hop-Redundancy-Protocols.md) · [`Ch17 — SNMP`](CCNA/Vol2/Ch17-SNMP.md) · [`Ch18 — LAN Architecture`](CCNA/Vol2/Ch18-LAN-Architecture.md) · [`Ch19 — WAN Architecture`](CCNA/Vol2/Ch19-WAN-Architecture.md) · [`Ch22 — SD-Access`](CCNA/Vol2/Ch22-Cisco-Software-Defined-Access.md) · [`Ch23 — REST & JSON`](CCNA/Vol2/Ch23-Understanding-REST-and-JSON.md) · [`Ch24 — Ansible & Terraform`](CCNA/Vol2/Ch24-Understanding-Ansible-and-Terraform.md); **Vol 1:** [`Ch8 — Ethernet VLANs`](CCNA/Vol1/Ch08-Implementing-Ethernet-VLANs.md) · [`Ch9 — STP Concepts`](CCNA/Vol1/Ch09-Spanning-Tree-Protocol-Concepts.md) · [`Ch10 — RSTP & EtherChannel`](CCNA/Vol1/Ch10-RSTP-and-EtherChannel-Configuration.md) · [`Ch16 — IPv4 Addressing & Static Routes`](CCNA/Vol1/Ch16-IPv4-Addressing-and-Static-Routes.md) · [`Ch17 — IP Routing in the LAN`](CCNA/Vol1/Ch17-IP-Routing-in-the-LAN.md) · [`Ch19 — OSPF Concepts`](CCNA/Vol1/Ch19-Understanding-OSPF-Concepts.md) · [`Ch20 — Implementing OSPF`](CCNA/Vol1/Ch20-Implementing-OSPF.md) · [`Ch21 — OSPF Network Types & Neighbors`](CCNA/Vol1/Ch21-OSPF-Network-Types-and-Neighbors.md).

## How a track works

Every track is **cert-grounded** (`ADR-0053`): it lists the exam objectives and, per objective, names the real Atlas device / build / change that proves it. Tracks link **down** into the [`../Command-Library/`](../Command-Library/) (the verification commands) and the [`../Playbooks/`](../Playbooks/) (the problem-keyed drills), and **out** to the device folders under `Labs/`. They are not generic study material — every row must earn its place by pointing at something Atlas actually built.

## Related

[`../README.md`](../README.md) (Academy index) · [`../Academy-Vision-and-Scope.md`](../Academy-Vision-and-Scope.md) (why the Academy exists + the cert tracks) · [`../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md`](../../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) (the Academy Documentation Standard).
