---
Title: Atlas Roadmap — Advanced Scenarios
Path: 00-Atlas-Foundation/Roadmap
---

# Atlas Roadmap — Advanced Scenarios

## Purpose

This page documents the long-term evolution of Atlas beyond the core infrastructure build. These scenarios add enterprise complexity, support certification lab work, and simulate the kind of environment an MSP or mid-size enterprise would actually operate.

None of this should be started until the current phase is frozen and validated. Complexity added to an unstable foundation is harder to debug than complexity added to a stable one.

---

## Current State Summary

| Phase | Description | Status |
|---|---|---|
| 1 | Enterprise Network | In Progress |
| 2 | Enterprise Virtualization | Pending |
| 3 | Windows Infrastructure | Pending |
| 4 | Identity and PKI | Pending |
| 5 | Monitoring and Logging | Pending |
| 6 | Security Hardening | Pending |
| 7 | Backup and Recovery | Pending |

---

## Phase 1.5 — Cisco 1941 Routing Replacement

> 🔴 **Superseded by `ADR-0023` (Option B).** This section describes the *rejected* approach — 1941 doing router-on-a-stick inter-VLAN with IOS ACLs and MKT01 decommissioned. The accepted design keeps **MKT01 as the internal east-west segmentation firewall + inter-VLAN gateway** and makes the **1941 the routed core (no VLANs)**. See `Labs/Lab-02-Cisco-Core/Architecture/` (topology, roles, build order). The router-on-a-stick idea survives only as a throwaway *learning drill*, not the production path. Retained here as history.

**Goal:** Replace MKT01 with the Cisco 1941 as the inter-VLAN router. Adds real IOS routing to the production environment and directly supports CCNP ENCOR study.

**What changes:**
- Cisco 1941 takes over router-on-a-stick inter-VLAN routing (subinterfaces on a trunk to SW01)
- OSPF replaces static routing between the 1941 and FGT01
- Extended named ACLs replace MikroTik east-west firewall rules
- MKT01 is decommissioned or repurposed as a lab device

**Skills developed:**
- IOS subinterface configuration (router-on-a-stick)
- OSPF single-area configuration and verification
- Extended named ACLs — the IOS equivalent of what MikroTik firewall rules do
- Route redistribution if needed between OSPF and connected routes on FGT01

**Certification relevance:** CCNA (routing, ACLs), CCNP ENCOR (OSPF, advanced routing)

**Prerequisites:** Phase 1 frozen, MKT01 config fully documented, Change Record written before cutover

---

## Advanced Phase — CCNP Lab Scenarios

Once the Cisco 1941 is in production, the following scenarios can be run without disrupting Atlas:

### OSPF Expansion
Add OSPF area 0 between FGT01 and the 1941. Redistribute connected routes. Verify route propagation. Add a second area if a second router is available.

**What you learn:** OSPF neighbor relationships, LSA types, area design, route summarization, redistribution

### HSRP / Gateway Redundancy
If a second router is added, run HSRP between two routers for each VLAN gateway. Clients use a virtual IP. Failover is transparent.

**What you learn:** First hop redundancy protocols, preemption, tracking, failover behavior

### IP SLA and Tracking
Configure IP SLA probes on the 1941 to monitor FGT01 reachability. Use object tracking to adjust routing if the probe fails.

**What you learn:** IP SLA, track objects, conditional routing

### QoS Baseline
Apply a basic QoS policy on the 1941: classify traffic by DSCP, queue management traffic above bulk data.

**What you learn:** MQC (Modular QoS CLI), DSCP marking, queuing

### Zone-Based Firewall
Replace ACLs on the 1941 with IOS zone-based firewall policy. Define zones per VLAN, write policy maps.

**What you learn:** ZBF architecture, class maps, policy maps, zone pairs — directly tested on CCNP Security

---

## Advanced Phase — PKI Migration & Disaster Recovery

**Goal:** treat recovery as a first‑class, *tested* skill — not a checkbox. `POL-0005` and `ADR-0011` say it plainly: **a backup you have never restored is a hope, not a backup.** No device backup in Atlas has ever been restored; these scenarios fix that, and each one is a strong portfolio write‑up (RTO/RPO, a tested restore).

### CA migration & disaster recovery — `Labs/Lab-02-Cisco-Core/Architecture/CA-Migration-and-DR-Lab.md`
Migrate the **retired Pi01 OpenSSL CA** to a proper host as a documented lab, then restore it from backup as a DR drill. A real CA with real key material and nothing to lose — the ideal practice subject. Teaches: a CA is just files (key, cert, `index.txt`/`serial`, config); secure key handling (`ADR-0009`); RTO/RPO; and the passphrase‑survival test (was your key's passphrase in the vault you also lost?).

**What you learn:** PKI internals, secure key transfer, `index.txt`/serial preservation, CRL after restore, RTO/RPO measurement.

### The wider DR Game‑Day catalogue (`ADR-0011`)
Run each as an unannounced‑ish drill, restore to an **isolated VLAN (70 Testing)**, and record the RTO:

| Drill | Restore | Proves |
|---|---|---|
| **CA restore** | the OpenSSL/AD CS CA from backup | it issues/revokes; chain still validates |
| **AD restore** | a DC via DSRM / the AD Recycle Bin; SYSVOL/system state | identity survives a DC loss (AZ‑801 exam skill) |
| **Device config restore** | a switch/router/firewall from Oxidized→git or the config backup | the config‑as‑record actually rebuilds the device |
| **Full teardown / rebuild** | the whole lab from the build guides + backups | the docs are *sufficient to rebuild without chat history* (the Charter's mission, tested) |

**Certification relevance:** AZ‑801 (AD backup/DSRM), Security+/CySA+ (BCP/DR, RTO/RPO), CCNP (config recovery). The full‑rebuild drill is the ultimate test of whether Atlas met its own Charter mission.

---

## Advanced Phase — MSP Simulation

**Goal:** Simulate Atlas as a managed service provider running infrastructure for multiple customers. Adds multi-tenancy, service isolation, shared services, and operational process complexity.

This is a significant undertaking — treat it as a dedicated project phase, not something to layer onto existing infrastructure mid-build.

### Architecture Overview

```text
Atlas MSP Core (shared infrastructure)
├── FGT01 — multi-VDOM or second FortiGate-VM
│   ├── Root VDOM — MSP management and shared services
│   ├── Customer-A VDOM — isolated tenant environment
│   └── Customer-B VDOM — isolated tenant environment
│
├── SW01 — additional VLANs per tenant
│   ├── VLAN 100-199 — Customer A
│   └── VLAN 200-299 — Customer B
│
├── PVE01 — tenant VMs in separate resource pools
│   ├── Customer A VMs — VLAN 100-199
│   └── Customer B VMs — VLAN 200-299
│
└── Shared Services (MSP-managed)
    ├── Wazuh — multi-tenant SIEM
    ├── LibreNMS — shared monitoring
    └── Backup infrastructure
```

### Customer Simulation

**Customer A — Small professional services firm (~25 users)**
- Single AD domain: customera.local
- File shares, basic GPO
- Workstations on VLAN 100
- Servers on VLAN 110
- Internet through FGT01 Customer-A VDOM with separate policy

**Customer B — Small healthcare-adjacent org (~30 users)**
- Single AD domain: customerb.local
- Stricter security baseline (simulate HIPAA-adjacent controls)
- Workstations on VLAN 200
- Servers on VLAN 210
- Internet through FGT01 Customer-B VDOM with stricter policy

### MSP Operational Scenarios

These are the scenarios that make the MSP simulation valuable as a portfolio piece:

**Tenant onboarding procedure**
Document the exact steps to provision a new customer: VDOM creation, VLAN assignment, AD forest, DNS delegation, monitoring enrollment, backup policy. This is the kind of runbook an MSP actually uses.

**Tenant isolation verification**
Prove that Customer A cannot reach Customer B. Run packet captures. Attempt cross-tenant access and verify it is blocked. Document the test and the result.

**Shared service delivery**
Deliver monitoring and backup to both tenants from shared infrastructure without exposing tenant A data to tenant B. This is an architecture problem, not just a configuration problem.

**Incident response simulation**
Simulate a compromised workstation on Customer A VLAN. Contain it (port disable on SW01, VLAN isolation), investigate via Wazuh, remediate, document. Write a post-incident report.

**Tenant offboarding**
Document how to cleanly remove a customer: disable VMs, revoke certificates, remove VLANs, remove VDOM, archive data. This is often worse than onboarding in practice.

### Certification Relevance

| Scenario | Certification |
|---|---|
| Multi-VDOM FortiGate | NSE 4, NSE 7 |
| Multi-tenant AD | AZ-800, AZ-801 |
| Tenant isolation and firewall policy | NSE 4, CCNP Security |
| SIEM multi-tenancy | SC-200 (Microsoft Security Operations) |
| PKI across tenants | AZ-801, SC-300 |
| Incident response | SC-200, CySA+ |

---

## Advanced Phase — Azure Integration

Once Windows infrastructure is stable, extend Atlas into Azure. This directly supports AZ-800/801 and AZ-500.

### Hybrid Identity
- Azure AD Connect syncing Atlas AD (lab.local) to Azure AD tenant
- Hybrid joined devices
- Conditional Access policies

### Azure Network Extension
- Site-to-site VPN from FGT01 to Azure Virtual Network Gateway
- Extend VLAN 20 (Servers) subnet into Azure via VPN
- Azure VMs joining on-premises domain

### Azure Arc
- Register PVE01 Linux host with Azure Arc
- Register Windows VMs with Azure Arc
- Apply Azure Policy to Arc-enabled resources

**Certification relevance:** AZ-800, AZ-801, AZ-500, SC-300

---

## Complexity Progression Summary

```text
Phase 1    Basic segmented network — operational
Phase 1.5  Cisco 1941 replaces MikroTik — IOS routing in production
Phase 2    Virtualization — VMs running
Phase 3    Windows AD — identity, DNS, DHCP, GPO
Phase 4    PKI — certificates, 802.1X, NPS
Phase 5    Monitoring — Wazuh, LibreNMS, Grafana
Phase 6    Security hardening — baselines, vulnerability management
Phase 7    Backup and DR — tested recovery procedures
           ↓
Advanced   CCNP routing scenarios — OSPF, HSRP, IP SLA, ZBF
Advanced   PKI migration & DR — CA migrate/restore, AD/DSRM, full-rebuild Game Day
Advanced   MSP simulation — multi-tenant, shared services, runbooks
Advanced   Azure integration — hybrid identity, VPN, Arc
```

Each step builds on a validated foundation. The MSP simulation and Azure integration are only meaningful if the core infrastructure is solid — otherwise you are debugging infrastructure problems while trying to learn multi-tenancy.

---

## Keeping Atlas Realistic

The goal is to simulate what a 100-150 person organization would actually run — not to add complexity for its own sake. Before adding any advanced scenario, ask:

- Does this reflect something a real organization or MSP would do?
- Does it teach a skill that maps to a certification or a job responsibility?
- Is the current phase stable enough to build on?

If the answer to any of these is no, finish what is already in progress first.

## Change Log

| Version | Changes |
|---|---|
| — | Original advanced-scenarios roadmap (CCNP labs, MSP simulation, Azure integration). |
| 2026-07-17 | Added the **PKI Migration & Disaster Recovery** advanced phase (the CA migrate/restore lab + the DR Game-Day catalogue: CA/AD/config/full-rebuild restores, `ADR-0011`/`POL-0005`). Flagged **Phase 1.5 as superseded by `ADR-0023`** (Option B keeps MKT01 as the east-west firewall; the 1941 is the routed core, not a router-on-a-stick replacement). Normalized line endings to LF per `.gitattributes`. |
