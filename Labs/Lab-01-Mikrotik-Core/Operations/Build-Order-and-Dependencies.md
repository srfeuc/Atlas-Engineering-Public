---
Title: Build Order and Dependencies
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Build Order and Dependencies

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | **Target Design** — a planned build sequence, not verified current state (Charter Rule 14). Phase 1 is built; Phases 2–6 are future. |
| Status | Draft for Confluence Review |
| Version | 1.1 |
| Last Reconciled | 2026-07-14 (051 / J5) |

> 🔴 **Open reconciliation notes (flagged 2026-07-14 — each needs a device read or a design decision, so it is surfaced rather than guessed):**
> - **Domain name is unsettled.** This page uses `lab.local`; `ADR-0007` adopted `atlas.lab` (unimplemented); the live devices are `<device>.lab` (`029`). `ADR-0012` quarantined a page for using `atlas.local`. Pick one AD domain name before Phase 2.
> - **Phase 2.3 validation `nslookup pve01.lab`** — the current Pi-hole record is `proxmox.lab`, not `pve01.lab` (`032`, `CM-0008`), so the check as written would fail. Confirm the intended DNS name on the device first (a wrong expected result is worse than none — `016` lesson 20).
> - **Phase 2.7 TrueNAS** is listed as a required step, but `VM-and-Services-Inventory.md` marks it *"Explicitly Deferred, Not Sized Yet."*

## Purpose

This page documents the correct build sequence for the Atlas environment and explains why the order matters. Every step has dependencies on what came before it. Building out of order does not always fail immediately — it often produces subtle, hard-to-diagnose problems hours or days later.

Use this page at the start of every new phase to understand what must be true before you begin.

---

## The Core Principle

**Infrastructure has a dependency graph, not a checklist.**

A checklist implies items are independent and can be done in any order. Infrastructure dependencies are hard — if DNS is not working, domain join fails. If domain join fails, Group Policy never applies. If Group Policy never applies, security baselines are not enforced. The failure three steps later looks like a security problem when it is actually a DNS problem.

Always validate each layer before building on top of it.

---

## Phase 1 — Enterprise Network (Current)

### Dependency Chain

```text
1. Physical layer
   Cables connected, link lights on, correct ports
   Validation: show interfaces status on SW01
        ↓
2. Layer 2 — VLANs and trunks
   SW01 VLAN database, trunk to MKT01, trunk to PVE01
   Validation: show vlan brief, show interfaces trunk
        ↓
3. Layer 3 — VLAN gateways
   MKT01 VLAN interfaces, gateway IPs, bridge-trunk hw=no
   Validation: /ip address print, ping each gateway from bridgeLocal
        ↓
4. Perimeter — internet access
   FGT01 transit, return route, LAB-to-Internet policy with NAT
   Validation: ping 1.1.1.1 from MKT01, then from a VLAN device
        ↓
5. Management plane
   All infrastructure devices reachable by IP from management VLAN
   FGT01: 10.10.0.254, MKT01: 10.10.0.1, SW01: 10.10.0.2, PVE01: 10.10.0.10
   Validation: ping all four from admin workstation
        ↓
6. Interim DNS
   Pi-hole reachable at 10.10.0.5, resolving queries
   Validation: nslookup google.com 10.10.0.5
        ↓
7. Hypervisor baseline
   PVE01 reachable, VT-x confirmed, storage healthy
   Validation: https://10.10.0.10:8006, egrep -c vmx /proc/cpuinfo
```

### What Breaks if You Skip a Step

| Skipped Step | What Fails Later |
|---|---|
| SW01 VLANs/trunks | MKT01 VLAN gateways unreachable — looks like a routing problem |
| MKT01 bridge-trunk hw=no | VLAN interfaces receive zero traffic — looks like a firewall problem |
| FGT01 return route as /8 | VLANs have no internet — only flat network works — intermittent and confusing |
| Pi-hole DNS | Domain join fails, Windows Update fails, certificate enrollment fails |
| PVE01 VT-x enabled | VMs fail to start — error appears only after hours of VM configuration |

---

## Phase 2 — Enterprise Virtualization

### Prerequisites (all of Phase 1 validated)

```text
1. Windows Server ISO uploaded to PVE01
   Validation: ISO visible in local storage ISO Images
        ↓
2. dc01 — Primary Domain Controller
   VM on VLAN 20, 10.20.0.10
   Roles: AD DS, DNS (AD-integrated), time source
   Validation: dcdiag /test:all passes, DNS resolves lab.local records
        ↓
3. DNS cutover
   MKT01 DNS → 10.20.0.10 (dc01)
   Client DNS → 10.20.0.10 (dc01) primary, 10.20.0.11 (dc02) secondary
   Pi-hole re-scoped (NOT removed) - stays a load-bearing resolver; role change via a Change Record (013 v2.0 / 017 v2.0)
   Validation: nslookup pve01.lab returns 10.10.0.10
        ↓
4. dc02 — Secondary Domain Controller
   VM on VLAN 20, 10.20.0.11
   Roles: AD DS replica, DNS replica
   Validation: AD replication healthy, dcdiag passes on both DCs
        ↓
5. DHCP on Windows Server
   Scopes for VLAN 50 (Client) and VLAN 60 (Deployment)
   MKT01 DHCP relay configured for each VLAN
   Validation: Client device gets address from correct scope
        ↓
6. NTP hierarchy from AD
   dc01 syncs to pool.ntp.org (PDC emulator)
   All domain members sync to dc01/dc02
   Update FGT01, MKT01, SW01 NTP to point at dc01
   Validation: w32tm /query /status on all Windows members
        ↓
7. TrueNAS — Network Storage
   VM on VLAN 20, 10.20.0.20
   SMB shares for file storage
   NFS/iSCSI for Proxmox Backup Server
   Validation: SMB share accessible from VLAN 50 client
        ↓
8. Proxmox Backup Server
   VM on VLAN 20, 10.20.0.30
   Backup jobs for all VMs
   Validation: Backup job completes, restore test passes
```

### What Breaks if You Skip a Step

| Skipped Step | What Fails Later |
|---|---|
| dc01 DNS before domain join | Every domain join fails — DNS error, not AD error |
| DNS cutover before dc02 | Single point of failure — dc01 outage breaks all DNS |
| DHCP relay on MKT01 | VLAN 50 clients get no address — they can see the gateway but get no DHCP offer |
| NTP from AD | Kerberos authentication fails with clock skew errors (>5 minutes difference) |
| TrueNAS before PBS | Proxmox Backup Server has nowhere to store backups |

---

## Phase 3 — Windows Infrastructure

### Prerequisites (Phase 2 complete, both DCs healthy)

```text
1. Organizational Unit structure
   Design OU tree before creating users or applying GPO
   Validation: OU structure matches Atlas design document
        ↓
2. User and group accounts
   Atlas employee simulation (~100-150 accounts)
   Security groups for role-based access
   Validation: Test user can log in from VLAN 50 workstation
        ↓
3. Group Policy baseline
   Security baselines (CIS or Microsoft Security Baseline)
   Password policy, account lockout, audit policy
   Software restriction or AppLocker
   Validation: gpresult /r on test workstation shows correct GPOs applied
        ↓
4. File Services
   DFS namespace on TrueNAS SMB shares
   Home folders, department shares
   Validation: UNC path accessible, permissions enforced
        ↓
5. Windows Admin Center
   Deployed on dedicated management VM or dc01
   Validation: WAC reachable, can manage all Windows servers
```

---

## Phase 4 — Identity and PKI

### Prerequisites (Phase 3 complete, AD healthy)

```text
1. Active Directory Certificate Services (ADCS)
   Two-tier PKI: offline root CA + online issuing CA
   Validation: Root CA cert published to AD, issuing CA online
        ↓
2. Certificate templates
   Computer authentication, user authentication, web server
   Auto-enrollment configured via GPO
   Validation: Domain computers auto-enroll, cert visible in certmgr
        ↓
3. NPS (Network Policy Server)
   RADIUS for 802.1X or VPN authentication
   Validation: Test authentication request succeeds
        ↓
4. 802.1X port authentication (advanced)
   SW01 configured for MAB and EAP on access ports
   NPS as RADIUS server
   Validation: Workstation authenticates via certificate before VLAN assignment
```

### Why PKI Comes After AD

ADCS integrates deeply with AD. Certificate templates use AD security groups. Auto-enrollment uses Group Policy. The CA publishes its certificate to AD. None of this works without a healthy, stable AD environment first. Building PKI on a new or unstable AD creates problems that are very difficult to unwind.

> 🔴 **AD CS does NOT replace the OpenSSL Lab CA.** Per `ADR-0003`, AD CS is scoped to domain-joined Windows resources only; the Pi01 OpenSSL Lab CA stays in service for the non-domain network devices (FGT01, MKT01, SW01, Pi01) and is not deprecated. Phase 4 stands up a second, coexisting PKI — not a migration.

---

## Phase 5 — Monitoring and Logging

### Prerequisites (Phase 3 complete, all production VMs running)

```text
1. Wazuh SIEM — 10.40.0.10
   Deploy manager first, then agents on all other VMs
   Validation: All agents reporting, no critical alerts on healthy systems
        ↓
2. LibreNMS — 10.40.0.20
   SNMP polling: SW01, MKT01, FGT01, PVE01
   Validation: All devices visible, interface graphs populating
        ↓
3. Grafana — 10.40.0.30
   Dashboards for Wazuh and LibreNMS data
   Validation: Key dashboards visible and accurate
        ↓
4. Syslog centralization
   FGT01, MKT01, SW01 sending syslog to Wazuh
   Validation: Firewall deny events visible in Wazuh
```

### Why Monitoring Comes Last in Each Phase

You cannot meaningfully monitor a system that is still being built — alerts will be noisy and misleading. Deploy monitoring after each phase is stable so you have a clean baseline. The first useful thing monitoring does is tell you when the baseline changes.

---

## Phase 6 — MSP Simulation (Advanced)

See the Atlas Roadmap — Advanced Scenarios page for full detail. High-level dependency chain:

```text
1. Multi-VDOM on FGT01 (or FortiGate-VM for second tenant)
        ↓
2. VLAN expansion for tenant networks
        ↓
3. Separate AD forest per tenant (or resource forest model)
        ↓
4. Inter-tenant routing policy (strict isolation)
        ↓
5. Shared services (DNS, monitoring) with tenant separation
        ↓
6. Tenant onboarding/offboarding documented procedure
```

---

## Universal Validation Rule

Before moving from any phase to the next, run the Network Validation Guide and confirm:

- All infrastructure devices reachable by management IP
- Internet access works from at least one VLAN
- DNS resolves both internal and external names
- No unexpected entries in firewall drop logs

If any of these fail, do not start the next phase. Fix the current layer first.
