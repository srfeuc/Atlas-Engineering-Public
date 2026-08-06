---
Title: Validation & Adversarial Testing (Lab-02 "pen-test" pass) — LIVING
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟡 LIVING (v0.2) — the place to *prove* each control works, not just that it was configured. Created 2026-07-22; **network / firewall / IPS-IDS / L2 rows added 2026-07-29** (operator's pen-test-the-network ask). Fill rows as controls become testable.
Version: 0.2
Date: 2026-07-29
---

# Validation & Adversarial Testing — Lab-02

> **Why this exists:** a control you haven't adversarially tested is a control you're *hoping* works. This is the counterpart to `POL-0001` ("verify by device status") taken one step further — for each security control we built, the **attack that should fail**, run it, and capture the evidence. Green here means *proven*, not *configured*.

## How to use this page
- One row per control. **Attack** = the thing that must be denied/blocked. **Expected** = the pass condition. **Evidence** = screenshot / command output / log ID. **Status:** ⬜ not yet · 🔄 partially · ✅ proven · ❌ failed (fix + note).
- Prefer capturing the **actual denial message / log entry**, not just "seemed blocked."
- Most identity rows **gate on Stage 8** (tiered accounts `t0/t1/t2-seth` + AGDLP groups) — you need a lower-tier identity to *be* the attacker. Network rows gate on segmentation + NetFlow (Phase 7).

## Control → attack → evidence matrix

### Identity / Active Directory
| # | Control (where) | Attack (must fail) | Expected | Evidence | Status |
|---|---|---|---|---|---|
| ID-1 | **Tier-deny logon GPOs** (7d) | Log a **Tier-2** account onto a **Tier-0** system (DC) — local **and** RDP | Logon denied by user-right (`Deny log on locally` / `…through RDS`) | screenshot of the denial + `gpresult` | ⬜ gated on 7d + Stage-8 groups |
| ID-2 | **Tier-deny (network)** (7d) | Tier-2 cred → "Access this computer from the network" against a DC | Denied | failed net-use / event log | ⬜ gated on 7d |
| ID-3 | **LAPS read boundary** (7c) | A **Tier-2 / helpdesk** account runs `Get-LapsADPassword` for a server a **Tier-1** account can read | Access denied for Tier-2; success for Tier-1 | both command outputs | ⬜ gated on `Set-LapsADReadPasswordPermission` + Stage-8 groups |
| ID-4 | **Finance/HR PSO** (7b) | Set a **14-char** password on a Finance/HR user (member of `G-FinanceHR-Users`) | Rejected (min 15); `Get-ADUserResultantPasswordPolicy` = `PSO-FinanceHR` | error + resultant-policy output | ⬜ needs a Finance/HR user (Stage 8) |
| ID-5 | **Baseline enforced** (7a) | Locally weaken a hardened setting on DC01 (e.g., re-enable a disabled proto), then `gpupdate` | GPO re-asserts the hardened value | before/after + `gpresult /h` | 🔄 baseline applied; do the tamper test |
| ID-6 | **DSRM-via-LAPS** (7c-DSRM) | (positive) retrieve + confirm rotation of the DSRM password | `Get-LapsADPassword` returns; value changes after `Set-LapsADPasswordExpirationTime` | ✅ verified 07-22 (value redacted) | ✅ |
| ID-7 | **Domain Admins hygiene** (`301`) | Audit `Domain Admins` / `Enterprise Admins` membership | Near-empty; only intended accounts | `Get-ADGroupMember` output | ⬜ |

### Network / Segmentation (gate: Phase 7 + MON01/NetFlow)
| # | Control | Attack (must fail) | Expected | Evidence | Status |
|---|---|---|---|---|---|
| NET-1 | **East-west default-deny** (MKT01, Phase 7) | Host in VLAN-X initiates to VLAN-Y outside allowed flows | Blocked | firewall log / failed connection | ⬜ gated on segmentation |
| NET-2 | **FGT01 egress policy** | Interior host → internet on a disallowed port/dest | Blocked + logged | FGT log entry | ⬜ |
| NET-3 | **DAI / STATIC-HOSTS** (SW01) | Unlisted host ARP on a DAI-protected VLAN | ARP dropped | `show ip arp inspection statistics` | 🔄 (VLAN 20 trust proven; test an unlisted host) |

### Perimeter / Admin access
| # | Control | Attack (must fail) | Expected | Evidence | Status |
|---|---|---|---|---|---|
| PER-1 | **FGT01 trusthost** | Admin login attempt from a non-trusted source IP | Rejected | FGT event log | ⬜ |
| PER-2 | **DC RDP = admins only** (baseline) | Non-admin domain user RDP to DC01 | Denied (right not held) | denial screenshot | ⬜ needs a std user (Stage 8) |

### Firewall & routing controls (gate: Phase 7 segmentation + the 1941 core)
| # | Control (where) | Attack (must fail) | Expected | Evidence | Status |
|---|---|---|---|---|---|
| FW-1 | **FGT01 egress policy** (N-S) | Interior host → internet on a disallowed port/dest | Blocked + logged | FGT policy log | ⬜ |
| FW-2 | **FGT01 inbound deny** | Unsolicited inbound WAN → interior host | Dropped (no session) | `diagnose sys session list`, FGT log | ⬜ |
| FW-3 | **MKT01 east-west per-rule** (default-deny) | For each *disallowed* pair in the flows matrix, initiate the service | Refused + deny **logged with correct timestamp** | MKT01 `/ip firewall filter print stats` + MON01 log | ⬜ gated on Phase 7 |
| FW-4 | **MKT01 no east-west NAT** | Confirm real source IPs cross segments (not NAT'd) | Real src IPs in logs/capture | packet capture / log | ⬜ |
| FW-5 | **1941 mgmt-plane / transit ACL** | From a user VLAN, reach the 1941 VTY / SNMP | Denied (VTY ACL) | `show access-lists`, failed SSH | ⬜ |
| FW-6 | 🔴 **Reachability-matrix Game Day** (the E-W capstone) | From segment A, sweep every service in segment B | Allowed succeed; **everything else refused + logged** | the full matrix run | ⬜ |

### IPS / IDS efficacy (does detection + prevention actually fire?)
| # | Control (where) | Attack | Expected | Evidence | Status |
|---|---|---|---|---|---|
| IDS-1 | **Suricata detection** (MON01 SPAN) | Trigger a known-bad signature — `curl testmynids.org/uid/index.html`, an EICAR fetch, or `tcpreplay` a malicious pcap | Suricata **alerts**; event in MON01/Grafana | alert + timestamp | ⬜ *"a sensor that never alerted is unproven"* |
| IPS-1 | **pfSense inline PREVENTION** (`ADR-0038`, N-S) | Same known-bad across the FGT01↔1941 transit | pfSense **drops** it (not just alerts) — transfer fails | drop log + failed transfer | ⬜ gated on the pfSense build |
| IDS-2 | **Evasion sanity** | Basic fragmentation / encoding of the test payload | Still detected — or the gap is noted + the rule tuned | before/after | ⬜ |
| IDS-3 | **Alert → SIEM pipeline** | Confirm Suricata + pfSense alerts reach **Wazuh / MON01** | Event visible in the SIEM pane | screenshot | ⬜ gated on SIEM01 |

### Layer-2 switch security (SW01)
| # | Control | Attack (must fail) | Expected | Evidence | Status |
|---|---|---|---|---|---|
| L2-1 | **Port security** (sticky MAC / violation) | Plug a different MAC into a secured access port | Port err-disables / restricts | `show port-security`, log | ⬜ |
| L2-2 | **DHCP snooping** | Rogue DHCP server on an untrusted port | Offers dropped on the untrusted port | `show ip dhcp snooping` | ⬜ |
| L2-3 | **DAI** (STATIC-HOSTS) | ARP-spoof / unlisted host on a DAI VLAN | ARP dropped | `show ip arp inspection statistics` | 🔄 (VLAN-20 trust proven; test a spoof) |
| L2-4 | **BPDU / root guard** | Inject BPDUs from an access port | Port err-disabled | `show spanning-tree`, log | ⬜ |
| L2-5 | **VLAN hopping / DTP** | Attempt DTP negotiation / double-tagging from an access port | No trunk formed; frames don't hop | `show interfaces switchport` | ⬜ |

## Tooling to add as this matures
Assessment tools that stress the AD build beyond spot-checks — **defensive/assessment kit**, run against your own lab:
- **PingCastle** — AD security score + risk report (fast, repeatable; good before/after each hardening pass).
- **Purple Knight** (Semperis) — AD/Entra security indicators of exposure/compromise.
- **BloodHound** (SharpHound collector) — attack-path graphing; the real test of whether the tier model actually holds.
- Manual: `gpresult /h`, event logs (4625 failed logon, 4768/4769 Kerberos), `net use`, RDP attempts.

**Network / offensive kit (on the attacker host — own-lab ROE, snapshot targets first):**
- **nmap** (host/port/service discovery — maps the segmentation + firewall reality), **hping3 / Scapy** (crafted packets, ACL/DoS tests), **yersinia / macof** (L2: DHCP starvation, STP, CDP, DTP), **testmynids.org / EICAR / tcpreplay** (IDS/IPS triggers), **arpspoof** (DAI test), **Metasploit** (exploit + verify — against your own lab only). Base the attacker on the **Testing VLAN (70)** with controlled per-test reach into the target segment; capture each **deny / alert / drop** as the evidence.

> Run PingCastle/Purple Knight **before** Stage-8 tiering and again **after** 7d + segmentation — the score delta is the evidence the tier model earned its keep.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.2 | 2026-07-29 | **Network pen-test rows added** (operator's ask: test the firewall, IPS/IDS, networking devices). New sections: **Firewall & routing** (FGT egress/inbound, MKT01 per-rule E-W + no-NAT, 1941 mgmt-plane, the reachability Game Day), **IPS/IDS efficacy** (Suricata alert · **pfSense inline drop** `ADR-0038` · evasion · SIEM pipeline), **L2 switch security** (port-security, DHCP-snooping, DAI, BPDU guard, VLAN hopping). Added the **network/offensive kit** (nmap/hping3/Scapy/yersinia/testmynids/Metasploit) + own-lab ROE. Attacker-host decision tracked in `Pre-Build-Decisions` J-series. |
| 0.1 | 2026-07-22 | Stub created (Seth's ask). Control→attack→evidence matrix seeded for Identity/Network/Perimeter with current gating (most rows wait on Stage-8 tier accounts/groups + Phase-7 segmentation); DSRM-via-LAPS row already ✅. Tooling backlog: PingCastle / Purple Knight / BloodHound + before/after scoring. |
