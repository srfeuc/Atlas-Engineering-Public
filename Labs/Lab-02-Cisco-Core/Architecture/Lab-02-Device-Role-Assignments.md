---
Title: Lab-02 Device Role Assignments
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Target Design — nothing here is built. Device config is the operator's to write (Charter Locked Rule 17).
Version: 1.2
---

# Lab-02 — Device Role Assignments

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Companion to `ADR-0023` (the topology decision), `Atlas-Service-Architecture.md` (the estate + the `ADR-0018` silo map in Part 2A), and `Atlas-Firewall-Architecture.md` (the east-west design bar).** This document answers one question: **after the re-architecture, what role is each device on, what may it do, what may it NOT do, and how do you prove it's doing its job.** It does not hand over config — per the Learning Rule, the design and the validation method are here; you write the device config.

## The topology this assumes (from `ADR-0023`, Option B)

```
Internet
  │
FGT01     ← perimeter / edge firewall — N-S, NAT, egress (role unchanged)
  │  routed transit link (e.g. /30)
1941      ← CORE ROUTER — routed backbone between edge and internal firewall
  │  routed transit link (e.g. /30)
MKT01     ← INTERNAL SEGMENTATION FIREWALL — L3 gateway for all internal VLANs,
  │        default-deny east-west, stateful, no east-west NAT, deny → MON01
  │  802.1Q trunk (all VLANs)
SW01      ← L2 access/distribution; DHCP snooping + DAI; SPAN (Gi1/0/5) → IDS
  ├── PVE01 (hypervisor, VLAN-aware trunk) ── the VM estate
  ├── Pi01 (DNS + NTP)      ── LabComputer (analyzer + IDS)
  └── VLANs: 10 Mgmt · 20 Servers (+ Tier-0 Identity) · 30 Web · 40 Mon ·
             50 Clients · 60 Deploy · 70 Test · 80 DMZ · 90 OT
```

> 🔴 **The one thing that is easy to get wrong:** MKT01 is *still the inter-VLAN gateway* — the 1941 did **not** take over inter-VLAN routing, it took over **core/edge (north-south) routing**. The re-role of MKT01 is that its default route now points at the 1941 and it now enforces a default-deny policy on the inter-VLAN traffic it was already carrying. That is the security win: **a MKT01 policy mistake can no longer take down core/edge routing**, because that lives on the 1941 + FGT01.

## The role list at a glance

| Device | Role | Layer | Silo (owner) | Key change from Lab-01 |
|---|---|---|---|---|
| **1941** | Core router (routed backbone, OSPF/static, default route to edge) | L3 core | 🔵 Network | **New box.** Takes north-south/core routing; inserted between MKT01 and FGT01 |
| **MKT01** | Internal east-west **segmentation firewall** + inter-VLAN gateway | L3 distribution + policy | 🔵 box / 🔴 **policy** | Default route → 1941 (was FGT01); gains default-deny east-west policy; loses RADIUS |
| **FGT01** | Perimeter / edge firewall (N-S, NAT, egress) | L3 edge | 🔵 box / 🔴 policy | Role unchanged; internal link now faces the 1941, not MKT01 |
| **SW01** | L2 access/distribution; DHCP snooping/DAI; SPAN→IDS | L2 access | 🔵 Network | Clock fixed; SPAN finally used; SNMP re-pointed at MON01 |
| **PVE01** | Hypervisor — hosts the entire service + Windows estate | Compute platform | 🟢 Systems | Idle → the busiest box; active (was frozen in Lab-01) |
| **Pi01** | DNS (Pi-hole forwarder) + NTP client-stratum | Service host | 🟡 Services | Reduced from 5 services to 2; crown jewels move off |
| **LabComputer** | Analyzer (Wireshark/iperf3) + Suricata IDS on the SPAN | Endpoint | 🟡 / 🔴 | The tap gets a listener |

**The VM estate on PVE01** (roles owned by Services/Security/Platform, hosted by 🟢 Systems) — full silo mapping is in `Atlas-Service-Architecture.md` Part 2A; summarised here:

| VM | Role | Silo (function owner) |
|---|---|---|
| **DC01 / DC02** | AD DS, AD-integrated DNS, **DHCP (on DC01 — `ADR-0030`; DC02 hot-standby later)**, PDC-emulator = NTP authority (`ADR-0020`) — **Tier 0** | 🔴 Security (identity) / 🟡 Services |
| **ICA01 / RCA01** | AD CS — enterprise issuing CA `ICA01` (`10.20.0.4`) + offline root `RCA01`; the estate's **only** PKI. OpenSSL retired, **CA01 not built** (`ADR-0031`) — **Tier 0** | 🔴 Security |
| **NETBOX01** | Source of truth (IPAM/DCIM) — everything renders from it | ⚪ Platform |
| **MON01** | LibreNMS, Grafana, NetFlow collector, rsyslog, Uptime Kuma | 🟡 Services |
| **SRV01** | nginx CRL host `pki.atlas.lab`, Oxidized, TFTP, SFTP, rsyslog relay — **no DHCP** (→ DC01, `ADR-0030`), **no FreeRADIUS** (retired, `ADR-0029`) | 🟡 Services |
| **Vaultwarden** | standalone (web console), AD CS cert; **CA01-VAULT01 joint host decommissioned** (`ADR-0031`) | 🔴 Security |
| **NPS01** | Windows NPS — network-device RADIUS for MKT01/SW01/1941 (`10.20.0.12`, `ADR-0029` v1.1) | 🔴 Security / 🟡 Services |
| **BKP01** | Proxmox Backup Server | 🟢 Systems / 🟡 Services |
| **FS01** | File services — SMB + **DFS/DFSR**, FSRM quotas (`Devices/FS01-File-Services/`) | 🟡 Services / 🔴 Security |
| **WSUS01** | Windows Update Services — patch rings by OU (`Devices/WSUS01-Patch-Management/`) | 🟡 Services / 🔴 Security |
| **SQL01** | SQL Server — app DBs, gMSA, TLS from ICA01 (`Devices/SQL01-Database/`) | 🟡 Services / ⚪ Platform |
| **RDS01** | Remote Desktop Services — session host/gateway, NPS01-backed (`Devices/RDS01-Remote-Desktop/`) | 🟡 Services / 🔴 Security |
| **SIEM01** | **Wazuh** host SIEM/XDR — complements MON01 Suricata (`Devices/SIEM01-Wazuh/`) | 🔴 Security |

> **Estate composition (Wave B, 2026-07-29).** The five rows above (FS01/WSUS01/SQL01/RDS01/SIEM01) are **operator-committed builds**; their per-host detail + status is the single source in **`Service-Server-Build-Plan.md`** (do not restate build steps here — this table owns *role + silo* only, `POL-0008`). **Deferred, in-estate:** **TrueNAS**. **PBS01 = BKP01** (same host, product name), not a separate role.

**Offline Root CA** — not a running device: air-gapped, LUKS-encrypted removable media, 🔴 Security. Signs the Intermediate and nothing else.

---

## Network devices — the detail (design · boundary · validate · fails)

### 1941 — Core Router  🔵 Network

- **Does:** routes the **north-south backbone** — one routed transit link to MKT01, one to FGT01; runs OSPF (or static) so MKT01's internal subnets are reachable toward the edge and the default route flows back; carries the default route toward FGT01. Optional transit ACLs. This is the IOS routing learning vehicle (adjacency, summarization, default-route origination).
- **Must NOT:** be the inter-VLAN gateway (that's MKT01) — it holds **no VLAN sub-interfaces** in this design; enforce east-west policy; do NAT.
- **Config surface (you write):** two routed interfaces (Gi0/0, Gi0/1) with /30 transit addressing; a routing protocol or static routes; default-route handling; optionally a transit ACL. `ip routing` on; no `switchport`/subinterface VLAN work.
- **Validate:** `show ip route` shows MKT01's internal subnets and a default toward FGT01; `show ip ospf neighbor` (or ping across each /30) proves both adjacencies; trace a path from an internal host to the internet and confirm it transits the 1941.
- 🔴 **Fails:** an **asymmetric or missing return route** — if the 1941 can reach a subnet but the return path differs, MKT01's stateful inspection breaks (Firewall-Arch §3.1). Keep paths symmetric. A missing default-route origination silently blackholes internet-bound traffic.

> **Honest note on CCNA scope:** because MKT01 owns the VLAN gateways, the classic *router-on-a-stick inter-VLAN* exercise does **not** live on the 1941 here — its lesson is routed-core/OSPF/transit. If you want router-on-a-stick as a standalone drill, do it as a throwaway lab; it is not the production path in Option B.

### MKT01 — Internal East-West Segmentation Firewall  🔵 box / 🔴 policy

- **Does:** the L3 **default gateway for every internal VLAN** (it keeps this from Lab-01); routes inter-VLAN **and** enforces a **default-deny, logged** policy between segments; default route points **up at the 1941**; ships deny logs to MON01.
- **Must NOT:** NAT east-west (real source IPs, or logs and policy are worthless — Firewall-Arch §3.3); carry RADIUS (moves to **NPS01** — `ADR-0029`); be the north-south core (that's the 1941); be touched policy-wise without a Change Record — **east-west policy is a Security-silo artefact** (`ADR-0018`).
- **Config surface (you write):** a VLAN interface + gateway IP per VLAN (incl. new **VLAN 90 OT**); the routed uplink /30 to the 1941; the default route to the 1941; the **allowed-flows matrix as firewall rules** — default-deny with explicit, named, per-service allows; deny-logging to MON01; the **Tier-0 Identity** and **OT** micro-zones as the tightest rule sets.
- **Validate (the half everyone skips):** `/ip firewall filter print stats` — count the rules, read each in English; **the reachability-matrix Game Day** — from a host in segment A, attempt each service in B; allowed flows succeed, everything else is *refused* and the deny is *logged with a correct timestamp*; confirm no NAT on inter-VLAN policies; watch the SPAN to see what's actually crossing.
- 🔴 **Fails:** "allow any-any to make bring-up work, never tighten" (the #1 real-world east-west failure); **rule ordering** (a broad allow above a specific deny silently wins — specific before general); **no tested console recovery** — a default-deny firewall that locks you out with no out-of-band path is a self-inflicted outage. Close the `ADR-0016` console gap (FTDI cable) **before** MKT01 is policy-critical.

### FGT01 — Perimeter / Edge Firewall  🔵 box / 🔴 policy

- **Does:** north-south enforcement — NAT/PAT to the home router, the single egress policy (`srcaddr all` per `ADR-0005`, deliberately broad until there's redundancy), inbound deny. Its internal transit link now faces the **1941**.
- **Must NOT:** have its egress narrowed until a redundant path exists to test it safely (`ADR-0005`); pretend to run UTM (unlicensed, stale signatures, none applied — `CM-0033`); lose its break-glass paths (console + `192.168.1.99`) in any hardening pass.
- **Config surface (you write):** re-point the internal interface/route at the 1941 transit /30; confirm the egress policy and NAT; keep `admin-server-cert` bound (verify with `get`, not `show` — MC-0001).
- **Validate:** `get firewall policy` (runtime, not `show`); `diagnose sys session list` shows live sessions; prove the recovery path (`192.168.1.99`/console) reachable *before* relying on policy; internet egress works from an internal host post-re-cable.
- 🔴 **Fails:** the confidence trap of an attached-but-stale UTM profile (Atlas attaches none, so nothing pretends — keep it that way or license + verify updates); a hardening change that severs management with no tested console.

### SW01 — L2 Access / Distribution Switch  🔵 Network

- **Does:** Layer-2 access and the all-VLAN 802.1Q trunk to MKT01; DHCP snooping + Dynamic ARP Inspection; port security; **SPAN on Gi1/0/5** mirroring the MKT01 trunk → the IDS; SNMP (v3) to MON01.
- **Must NOT:** route (it's L2 here); keep pointing SNMP at `10.40.0.52` (a host that does not exist — re-point at MON01); ship logs on an unsynced clock.
- **Config surface (you write):** trunk + access ports; DHCP snooping trust/limits and DAI (the `STATIC-HOSTS` ACL — ideally *generated from NetBox*, not hand-typed); SPAN session to the IDS host; SNMPv3; **fix the clock (`CM-0030`) first** so its logs correlate.
- **Validate:** `show vlan`, `show interfaces trunk`, `show ip dhcp snooping`, `show monitor session 1`; confirm the IDS actually receives mirrored traffic; confirm the clock reads synced *before* trusting timestamps.
- 🔴 **Fails:** DAI silently dropping a host missing from a hand-typed ACL (the Pi01 mystery that survived three handoffs — the NetBox fix makes the omission structurally impossible); a SPAN built and never plugged in (free east-west telemetry, unused — plug it in and prove it fires).

---

## Hosts and platform (briefer)

- **PVE01 — Hypervisor 🟢 Systems.** Hosts the whole estate. VLAN-aware bridge trunk to SW01; VMs land on their zone's VLAN (DCs → Tier-0 carve-out of 20; MON01 → 40; etc.). *Validate:* each VM's vNIC tag matches its zone; the host clock is synced. *Fails:* the VLAN-20 tagging issue from Book 2 — verify tags on the wire, not just in the config. Prerequisites: UPS (the dead CMOS battery loses RTC on power loss — `CM-0012`/`ADR-0017`) and the CR2032.
- **Pi01 — DNS + NTP 🟡 Services.** Pi-hole as the filtering *forwarder* (domain machines use AD DNS on the DCs; non-domain use Pi-hole — the `ADR-0003`/`ADR-0007` boundary); chrony as a lab stratum source under the `ADR-0020` hierarchy. Everything else (RADIUS, Vault, both CAs) leaves it. *Fails:* over-trust — the whole point of the reduction is that Pi01 stops being a single point of failure for the PKI.
- **LabComputer — Analyzer + IDS 🟡/🔴.** Wireshark on the SPAN, iperf3 for QoS congestion generation, Suricata/Zeek on the mirror. *Validate:* the IDS fires on a known-bad test — a sensor that never alerted is unproven.

## Dependencies & build order

Roles come online in the `Atlas-Service-Architecture.md` Part 8 phase order, not all at once: **NETBOX01 first** (source of truth) → SRV01/MON01 (services + visibility) → Pi01 reduced → **then the network re-role** (1941 core, MKT01 east-west) once there's monitoring to see the flows and a source of truth to generate ACLs from. The identity track (DC01/02, RCA01/ICA01) builds **in tandem** per the "one Lab-02, both tracks" decision. **Do not** make MKT01 policy-critical before: NetFlow/monitoring exists (to design the matrix from evidence), clocks are synced, and the console recovery path is tested.

## Change Log

| Version | Changes |
|---|---|
| 1.2 | 2026-07-29. **Wave-B estate decision.** VM-estate table: replaced the generic `FS01/WSUS01/WS01 (per VM Inventory)` row with the five **operator-committed** roles — **FS01, WSUS01, SQL01, RDS01, SIEM01 (Wazuh)** — each with silo + a pointer to its new `Devices/` stub. Added an estate-composition note (single source = `Service-Server-Build-Plan.md`; **TrueNAS** deferred; **PBS01 = BKP01**). Role/silo only here per `POL-0008`. |
| 1.1 | 2026-07-28. **Reconciled to ADR-0029 v1.1 / 0030 / 0031** (cascade from Master-Build-Order v1.6). VM-estate table: DHCP now on **DC01** (`ADR-0030`, DC02 hot-standby later); **CA01 row → ICA01/RCA01** (AD CS is the only PKI; OpenSSL retired, CA01 not built — `ADR-0031`); **SRV01** drops DHCP/FreeRADIUS (nginx-CRL/Oxidized/rsyslog only); **VAULT01 → Vaultwarden standalone** (web console, AD CS cert; CA01-VAULT01 host decommissioned); **added NPS01** (network-device RADIUS, `10.20.0.12`). MKT01 "RADIUS → SRV01/NPS" → **NPS01**; build-order "CA01" → RCA01/ICA01. |
| 1.0 | 2026-07-17. Initial device role assignments for the Lab-02 Option B topology (`ADR-0023`). Enumerates every device's role, silo owner, must/must-not boundaries, config surface, validation method, and failure modes. Records the key nuance that MKT01 retains inter-VLAN routing (the 1941 takes north-south/core), that RADIUS leaves MKT01 for SRV01/NPS, and that MKT01 policy-criticality is gated on monitoring + synced clocks + a tested console recovery path. |
