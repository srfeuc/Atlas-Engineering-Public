---
Title: CompTIA A+/Network+/Security+ — Pre-Teardown Exercise Catalogue
Path: Atlas-Academy/Certification
Path (suggested): 00-Atlas-Foundation/  — companion to Atlas-Certification-Lab-Map.md (which covers CCNA; this covers the CompTIA trifecta)
Status: Draft — gap analysis + do-before-teardown priority list. You run the labs (Charter Rule 16/17).
Author: drafted with Claude (Cowork), reconciled against the cert map, advanced-scenarios roadmap, 048 teardown runbook, and the Lab-02 pre-teardown checklist
Date: 2026-07-20
Exam versions (confirmed current, 2026): A+ 220-1201 / 220-1202 (V15) · Network+ N10-009 (V9) · Security+ SY0-701 (V7)
---

# CompTIA A+/Network+/Security+ — Pre-Teardown Exercise Catalogue

## Why this doc exists

`Atlas-Certification-Lab-Map.md` maps the lab to **CCNA 200-301** in detail, and `Atlas-Roadmap-Advanced-Scenarios.md` covers the CCNP/NSE/AZ/DR vision. Neither maps the **CompTIA A+ / Network+ / Security+** trifecta you asked about — that layer is missing. This fills it, and it's deliberately biased toward **one question:** *what can you only do while Lab-01 is standing, that a clean rebuild erases forever?*

The short version: **you have already exercised ~70-80% of Network+ and a large slice of Security+ just by building and reconciling Atlas** — much of the CCNA map's Network Access / IP Connectivity / Security Fundamentals rows *are* Network+ and Security+ objectives in different words. The value left on the table is not "learn new topics." It's **capture the evidence and run the fault-and-recovery labs before the live state is gone.**

---

## The teardown erases three things you can't rebuild

1. **The real faults.** SW01's clock that never synced (`CM-0030`), the FGT01 `/8`-vs-`/24` route lesson, the two `index.txt` orphans (`CM-0032`), the silently-unbound cert, the MKT01 mac-winbox recovery quirk. A clean rebuild is *clean* — these authentic, integrated faults vanish, and **Network+ domain 5.0 (Troubleshooting) is 24% of that exam** — the single biggest domain. You will not manufacture faults this real again.
2. **The live integrated state.** The actual MAC table, ARP cache, live inter-VLAN traffic on the SPAN port, the running configs as they truly are (not as documented). Evidence you can capture *once*, now.
3. **The "restore *this* system" drills.** DR is only real if you restore the actual CA / config / identity that exists today. After the wipe there's a *new* CA and *new* configs — you'd be testing recovery of something that was never in production.

So the ranking below is by **teardown-urgency**, not by exam weight.

---

## TIER 1 — Do before the first wipe (destroyed by teardown)

These need Lab-01's current live state. Most are low-effort and double as the `048` / Lab-02 pre-teardown checklist you're doing anyway — the trick is to **run them as graded exercises and keep the evidence**, not just tick a box.

| # | Exercise | Maps to | Why it's teardown-urgent |
|---|---|---|---|
| 1 | **Work every live fault as a documented troubleshooting lab** — SW01 clock (`CM-0030`), FGT01 `/8` route, `CM-0032` orphans, unbound cert. For each: symptom → hypotheses → `show`/diagnostic path → root cause → fix → verify. | **Net+ 5.0** (troubleshooting methodology, the whole domain) · **A+ 220-1201 5.0** & **220-1202 3.0** (troubleshooting steps) · **Sec+ 4.0** (`CM-0032` is an incident) | The faults exist **now**. A rebuild removes them. This is the highest-value pre-teardown work you can do. |
| 2 | **Packet-capture the live trust boundary.** LabComputer on the SW01 SPAN port (`Gi1/0/5`, already mirroring the MKT01 trunk). Capture: a TCP 3-way handshake, a DNS/UDP query to Pi-hole, ARP, an 802.1Q-tagged frame, an east-west DENY hitting the MKT01 drop rule. Save the `.pcap`s. | **Net+ 1.0** (ports/protocols, encapsulation) · **Net+ 5.0** (capture tools) · **Sec+ 4.0** (packet analysis) · **A+ 220-1201 2.0** (protocols) | Live multi-VLAN traffic on real gear disappears at teardown; a rebuilt lab's captures aren't the same evidence. |
| 3 | **Archive the running state of every device as evidence** — `show run`, `show vlan brief`, `show mac address-table`, `show interfaces status/trunk`, `show spanning-tree`, `show arp access-list`, ARP/route tables, FGT policy, MKT `/export`. (This overlaps the pre-teardown checklist — do it *as* the Net+ "documentation" objective.) | **Net+ 3.0** (documentation, baselines, SoT) · **A+ 220-1202 4.0** (documentation) · **Sec+ 4.0** | `048` says SW01/FGT01 have **no backup**; capture is one-shot. Also the seed for NetBox in Lab-02. |
| 4 | **Run the teardown itself as the "full-rebuild DR Game Day"** (`ADR-0011`) — time it, keep the "every time I left the docs" log (`048` Phase 4), capture the RTO. | **Sec+ 4.0 & 5.0** (BCP/DR, RTO/RPO, IR) · **Net+ 3.0** (DR concepts, backup/restore) · **A+ 220-1202 4.0** | The teardown happens once. Instrument it or lose the single best BCP/DR artifact you'll ever get. |
| 5 | **Prove the 3-2-1 backup + restore-verify** (close `049` Phase 5 off-site; decrypt-test the Pi01 archive per the pre-teardown checklist). | **Sec+ 4.0** (backup strategies, restore testing) · **Net+ 3.0** · **A+ 220-1202 4.0** | The pre-teardown checklist *requires* this before wiping; it's also a graded Security+ objective. Do it while the source exists. |
| 6 | **CA DR drill (already in flight)** + the `CM-0032` detection-control reconciliation as an incident write-up ("my only compromise-detection control was 40% blind"). | **Sec+ 4.0** (IR, PKI ops) · **Net+ 4.0** · **A+ 220-1202 2.0** (certs) | Restores *this* CA; the `CM-0032` story only exists on the current `index.txt`. |
| 7 | *(Optional, higher effort)* **Stand up the idle FortiAP against the current FreeRADIUS** — WPA2-Enterprise / 802.1X wireless. | **Net+ 2.0** (wireless) · **Sec+ 3.0** (wireless security, 802.1X) · **A+ 220-1201 2.0** (wireless) | Wireless is a trifecta gap the lab currently doesn't cover; doing it against the *existing* RADIUS ties AAA+wireless before that RADIUS is rebuilt. Skip if time is short — redoable in Lab-02. |

---

## TIER 2 — Redoable after teardown (nice-to-have now, not urgent)

Available on the current lab but reproducible (often better) in Lab-02 or on demand — don't let these block the wipe.

- **802.1X on an SW01 access port** against FreeRADIUS — Net+ 4.0 / Sec+ 3.0 (AAA). Rebuilt in Lab-02 with NPS too.
- **Port security** (sticky MAC, violation) — Net+ 4.0 / Sec+ 3.0 L2 mitigations. (DHCP snooping + DAI already live — capture them in Tier-1 #3.)
- **Subnet the whole lab by hand** — Net+ 1.0 / A+ 220-1201 2.0. Pure repetition; no gear needed, no teardown pressure.
- **Oxidized → git config backup** (Net+ 3.0 config mgmt, Sec+ 4.0) — the cert map already sequences Oxidized → NetBox → Ansible; standing up Oxidized *before* teardown gives you an automated "before" snapshot (nudges this toward Tier 1 if easy).
- **QoS with iperf3-generated congestion**, **NAT/PAT inspection on FGT01**, **SSH/SNMPv3/syslog** — all IP-services objectives, redoable.

---

## TIER 3 — Genuine trifecta gaps this lab can't (yet) give you

Mostly **A+ Core 1/2 endpoint-side** material — Atlas is infrastructure, not a helpdesk bench:

- **A+ 220-1201 1.0 Mobile Devices** (laptop/phone/tablet hardware, displays, ports) — not in the lab. Book/sim study.
- **A+ 220-1201 3.0 Hardware** — partially: you *did* hit real hardware (the PVE01 **CMOS-battery** replacement, `CM-0012`, is textbook A+ hardware troubleshooting; cabling; the FTDI console cable). But printers, RAM/PSU/motherboard swaps, laptop internals — bench/sim.
- **A+ 220-1202 1.0 Operating Systems** — Windows install/config, command-line, macOS/Linux client admin. Partially covered (Debian services, Windows workstation) but not the OS-install/config breadth. The Lab-02 Windows track (DC/GPO/WSUS) will close much of this.
- **A+ 220-1201 4.0 Virtualization & Cloud** — ✅ largely covered by PVE01; the Azure roadmap phase adds cloud.
- **Security+ 1.0/5.0 governance/program** — ✅ you're *already living this*: your CM records, ADRs, POLs, change-management gate, and risk-acceptance docs (`ADR-0009`) are exactly **Sec+ 5.0 (Program Management & Oversight)** and **A+ 220-1202 4.0 (Operational Procedures)** done to a professional standard. Capture that you've done it; you don't need to build anything.

**Takeaway on A+:** Network+ and Security+ are ~80% and ~60% lab-satisfiable respectively *right now*; A+ is the odd one out — its hardware/mobile/OS-install core lives outside an infrastructure lab, so treat A+ as mostly book/sim with the lab supplying virtualization, documentation/operational-procedures, and security.

---

## Per-exam one-line coverage summary

| Exam | Current lab coverage | The pre-teardown move |
|---|---|---|
| **Network+ N10-009** | High (~80%). Concepts, VLANs/trunking, routing, services, L2 security, ops — all built. | **Domain 5.0 Troubleshooting (24%)** via the live faults + captures. Biggest domain, most perishable evidence. |
| **Security+ SY0-701** | Medium-high. Architecture/segmentation, AAA, PKI, hardening (CIS), and governance already exercised. | **Domain 4.0 Security Operations (28%)** via the DR drills, packet/log analysis, and the `CM-0032` incident — all tied to the current live state. |
| **A+ 220-1201/1202** | Low-medium. Virtualization, documentation/operational-procedures, security, some real hardware. | Capture the **hardware fault (CMOS)**, **troubleshooting methodology**, and **operational-procedures** evidence; book/sim the mobile/printer/OS-install core. |

---

## Recommended pre-teardown sequence (fold into the existing checklist)

1. **Capture first** (Tier-1 #2, #3): SPAN `.pcap`s + full `show`/config archive of every device. One-shot evidence.
2. **Work the faults** (Tier-1 #1) while they're live; write each up as a troubleshooting record.
3. **Verify backups** (Tier-1 #5) — this is the `048`/pre-teardown gate anyway; run it as the Sec+ backup/restore objective.
4. **CA DR drill + `CM-0032` write-up** (Tier-1 #6) — the exercise you're already on.
5. *(Optional)* **FortiAP 802.1X** (Tier-1 #7) if time allows.
6. **Teardown = the DR Game Day** (Tier-1 #4): instrument it, log every doc gap, capture the RTO. The rebuild is Lab-02.

Everything in Tier 2/3 can wait for Lab-02 or book/sim — none of it should delay the wipe.

---

## Reconciliation notes

- This doc is the **CompTIA companion** to `Atlas-Certification-Lab-Map.md`; it doesn't duplicate the CCNA mapping, it sits beside it. Consider linking them.
- It leans on plans already in the repo: the DR Game-Day catalogue (`Atlas-Roadmap-Advanced-Scenarios.md`), the `048` teardown runbook, the Lab-02 pre-teardown checklist, and the Oxidized→NetBox→Ansible sequence. Nothing here is net-new architecture — it's a **certification lens** on work you're already doing.
- Exam weights cited are from the current objectives (A+ V15, N10-009, SY0-701). If you tell me which exam you're sitting first and your teardown date, I'll turn the relevant tier into a dated, checkbox study plan.
