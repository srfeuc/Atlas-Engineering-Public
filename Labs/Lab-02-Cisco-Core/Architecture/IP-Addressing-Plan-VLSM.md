---
Title: Lab-02 IP Addressing Plan (VLSM)
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Target Design — the authoritative addressing plan. You assign and configure it (Charter Locked Rule 17).
Version: 1.11
---

# Lab-02 — IP Addressing Plan (VLSM)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **The single addressing plan for Lab-02** (`POL-0008` — one plan, no drift; this is what closed the `10.0.0.x`-vs-`10.10.0.x` defect). **VLSM, VLAN-encoded, sized to the 301 scenario.** Companion to `Cabling-and-Port-Map.md` (this doc is authoritative for addresses; the cabling doc's `e.g.` values defer to it) and the `Atlas-East-West-Allowed-Flows-Matrix.md` (zones). The gateways all live on MKT01 (`ADR-0023`).

## The scheme, in one line
> **`10.<vlan>.0.0 /<mask>`** — the second octet *is* the VLAN ID (readable), and the **mask varies by host count** (that's the VLSM). Each VLAN's gateway is `10.<vlan>.0.1` on MKT01. Everything sits in `10.0.0.0/8`; transit and loopbacks live in `10.255.x` so they never collide with a VLAN.

## VLAN subnets (sized to the 301 scenario)

| VLAN | Zone (trust) | Scenario hosts | Mask | Network | Usable | Broadcast | Gateway (MKT01) |
|---|---|---:|---|---|---|---|---|
| 10 | Management | ~20 | **/27** | `10.10.0.0/27` | .1–.30 | .31 | `10.10.0.1` |
| 20 | Servers (T1) **+ T0 carve** | ~25 | **/26** | `10.20.0.0/26` | .1–.62 | .63 | `10.20.0.1` |
| 30 | Web / App | ~8 | **/28** | `10.30.0.0/28` | .1–.14 | .15 | `10.30.0.1` |
| 40 | Monitoring | ~10 | **/28** | `10.40.0.0/28` | .1–.14 | .15 | `10.40.0.1` |
| 50 | Clients (T2) | ~95 | **/25** | `10.50.0.0/25` | .1–.126 | .127 | `10.50.0.1` |
| 60 | Deployment | ~25 | **/27** | `10.60.0.0/27` | .1–.30 | .31 | `10.60.0.1` |
| 70 | Testing | ~10 | **/28** | `10.70.0.0/28` | .1–.14 | .15 | `10.70.0.1` |
| 80 | DMZ | ~6 | **/28** | `10.80.0.0/28` | .1–.14 | .15 | `10.80.0.1` |
| 90 | OT Isolation | ~40 | **/26** | `10.90.0.0/26` | .1–.62 | .63 | `10.90.0.1` |

**Sizing logic (the VLSM part):** smallest mask that fits the scenario count with ~30% growth headroom. Clients (~95) is the driver → /25 (126). Servers and OT are the next tier → /26 (62). Web/Mon/Test/DMZ are small → /28 (14). Management/Deployment mid → /27 (30). **If a zone outgrows its mask, widen that one subnet — you don't touch the others** (the whole point of the VLAN-encoded scheme: each VLAN owns a full `10.<vlan>.0.0/16`, so there's always room to widen).

## 🔎 Management (VLAN 10) vs Servers (VLAN 20) — what lives where

A recurring question: why does a service like **NetBox** go on VLAN 20 and not VLAN 10? Because the two VLANs mean different things:

- **VLAN 10 (Management)** is the **device control plane** — the interfaces you *administer infrastructure on*: switch/router/firewall management, **both hypervisor hosts (PVE01 *and* PVE02/EQR6)**, Pi01, the PAW/admin. Keep it **small and admin-only**; it's the most security-sensitive network you have (reach it and you reach the management interface of every device). "Management VLAN" means *the network you manage devices on* — **not** *any app an admin happens to use*.
- **VLAN 20 (Servers)** is where **service workloads** live and are consumed: DC01/DC02 (Tier-0 carve), **NetBox** (`10.20.0.11`), SRV01, monitoring. NetBox is a web app + PostgreSQL + (later) LDAP auth, reached by browsers and by automation via its API — a "service reached by clients" pattern that belongs behind the east-west firewall in the Servers zone.

So **a service VM goes on 20, not 10 — even an infrastructure tool like NetBox** (it *documents* the infrastructure; it isn't a device's management interface). Putting a full web+DB stack on the management plane would enlarge the blast radius of your most sensitive VLAN for no benefit. Clean symmetry: **each hypervisor _host_ (PVE01 and PVE02/EQR6) is managed on VLAN 10**; the **VMs they run** are services on VLAN 20 — manage the platform on 10, run the workloads on 20. *(This rule predated the second host: `ADR-0036` added PVE02/EQR6 as the always-on hypervisor, so the estate now has **two** VLAN-10 hypervisor management interfaces, not one — reconciled in the #20 sweep, 2026-07-30.)*

## Transit links & loopbacks (infrastructure — `10.255.x`)

| Purpose | Mask | Network | Addresses |
|---|---|---|---|
| FGT01 ⇄ 1941 transit | **/30** | `10.255.255.0/30` | FGT01 `.1`, 1941 `.2` |
| 1941 ⇄ MKT01 transit | **/30** | `10.255.255.4/30` | 1941 `.5`, MKT01 `.6` |
| 1941 loopback (OSPF RID) | /32 | `10.255.0.1/32` | |
| MKT01 loopback (OSPF RID) | /32 | `10.255.0.2/32` | |

*(Point-to-point /30s carry no hosts and no VLANs — routed links only, per `ADR-0023`.)*

## Static vs DHCP convention (per subnet)

- **`.1` = gateway** (MKT01 VLAN interface), always.
- **Low range = static** (infrastructure, servers, printers, OT devices); **upper range = DHCP pool** where DHCP applies.
- Suggested split:

| Zone | Static range | DHCP pool | Notes |
|---|---|---|---|
| Management (/27) | .2–.20 | .21–.30 | mostly static (devices) |
| Servers (/26) | **.2–.9 = Tier-0 (DCs, CA)**, .10–.55 servers | .56–.62 (reserved) | see Tier-0 carve below |
| Web / Mon / DMZ (/28) | .2–.14 | — | static |
| Clients (/25) | .2–.20 | .21–.126 | mostly DHCP |
| Deployment (/27) | .2–.10 (WDS/PXE) | .11–.30 | imaging targets DHCP |
| Testing (/28) | .2–.6 | .7–.14 | mixed |
| OT (/26) | .2–.62 | — | 🔴 **no DHCP on OT** — PLCs/HMIs/SCADA are statically addressed |

> **DHCP server = DC01 (Windows DHCP), `ADR-0030` — not yet standing.** *(Reverses the earlier "Kea on SRV01" plan; `ADR-0030` consolidates DHCP on DC01 for the fewer-VMs driver, with DC02 as the later failover peer and a dedicated DDNS account **not** in `DnsUpdateProxy`.)* Until it is stood up, *everything* is hand-addressed static. 🔴 Because the gateways/SVIs are on **MKT01** and DC01 lives only in VLAN 20, DHCP for the other VLANs needs a **RouterOS DHCP relay on MKT01** → DC01 (`10.20.0.2`) per served VLAN. Infrastructure (Tier-0 `.2–.9`, servers `.10–.55`) stays **static regardless** — DHCP is for the client/deployment/testing population.

## 🔴 Tier-0 Identity carve-out (within VLAN 20)

DCs and the CA are **Tier 0** (`ADR-0021`, `305` Part 4) and must be the most isolated hosts. Rather than a separate VLAN, they get a **reserved low block in VLAN 20 — `10.20.0.2`–`10.20.0.9`** — and the MKT01 east-west policy treats that block as the **Identity micro-zone** (matrix flow #9: only LDAPS/Kerberos/DNS reach it; nothing initiates *out* of a user zone into it). *(If you'd rather hard-separate them, promote this block to its own VLAN — but the reserved-range + firewall micro-zone is enough at this scale.)*

## Worked examples (so the plan is unambiguous)
- **DC01** → `10.20.0.2` (Tier-0 block), gateway `10.20.0.1`, mask `/26`.
- **MON01** → `10.40.0.10`, gateway `10.40.0.1`, mask `/28`. *(This re-addresses the old planned `10.40.0.20/.30` — those were never deployed; `/28` is the right size for ~10 monitoring hosts.)*
- **A sales laptop** → DHCP from `10.50.0.21`–`10.50.0.126`, gateway `10.50.0.1`, mask `/25`.
- **A PLC** → static `10.90.0.x` (no DHCP), gateway `10.90.0.1`, mask `/26`.
- **SW01 management** → `10.10.0.x`, gateway `10.10.0.1`, mask `/27`.

## Current & reserved host assignments (live register — POL-0008)

The concrete assignments as of 2026-07-22 (this is the authoritative register until NetBox renders from it). ✅ = device-verified/set; 🟡 = operator-reported, device read-back pending; ⏳ = in build; 📋 = planned/proposed (operator confirms). All VLAN 20 = mask `/26`, gateway `10.20.0.1` (on MKT01), DNS `10.20.0.2`.

| Host | VLAN | Address | Status | Role |
|---|---|---|---|---|
| DC01 | 20 (Tier-0) | `10.20.0.2` | ✅ | PDCe, AD-DNS, forest root |
| DC02 | 20 (Tier-0) | `10.20.0.3` | 🟡 promoted — operator-reported 2026-07-28 (`repadmin`/`dcdiag` read-back pending) | replica DC / GC / DNS |
| **ICA01** | 20 (Tier-0) | `10.20.0.4` | ✅ set 2026-07-22 | AD CS enterprise issuing CA |
| RCA01 | — | *offline, no IP* | n/a | AD CS offline root (never networked; `.5` reserved on paper only) |
| SRV01 | 20 (server) | `10.20.0.10` | 📋 | Linux services: nginx CRL host `pki.atlas.lab`, Oxidized, syslog (**DHCP moved to DC01 `ADR-0030`; FreeRADIUS moved to NPS01 `ADR-0029`**) |
| NetBox | 20 (server) | `10.20.0.11` | 📋 | IPAM/DCIM (will render this register) |
| **NPS01** | 20 (server) | `10.20.0.12` | 📋 | Windows Network Policy Server (RADIUS) for network-device admin auth (`ADR-0029` D7). Member server, `OU=Servers,OU=Devices`; **not** in the `.2–.9` Tier-0 carve |
| **RDS01** | 20 (server) | `10.20.0.17` | 📋 proposed | RD Session Host + RD Gateway/Web (standard-user published desktops; CAP/RAP on **NPS01** `ADR-0029`, TLS from **ICA01** `ADR-0027`). **Always-on → PVE02/EQR6** (`ADR-0036` v1.2). Not in the `.2–.9` Tier-0 carve |
| **WAC01** | **10 (mgmt)** | `10.10.0.5` | 📋 proposed | Windows Admin Center gateway (Tier-0 mgmt surface, PAW-only; TLS from **ICA01**). **Always-on → PVE02/EQR6** (`ADR-0036` v1.2). **VLAN 10** per operator 2026-07-30 (exercises `ADR-0045`'s VLAN review trigger; a Tier-0 admin surface belongs on the mgmt plane). ✅ `.5` deconflicted in the #20 pass (VLAN-10 map below) |
| **PAW01** | **10 (mgmt)** | `10.10.0.8` | 📋 proposed | Tier-0 admin workstation (RSAT). **Moved to VLAN 10** in the #20 sweep (operator 2026-07-30) — an admin surface belongs on the mgmt plane, with WAC01; the admin path into Tier-0 exists **only** from Management (`ADR-0021`/`305` Part 4, flows-matrix #23). **No longer in the VLAN-20 `.2–.9` Tier-0 carve.** Always-on → PVE02/EQR6 (🟡 RAM-swing) |
| **BKP01** | 20 (server) | `10.20.0.18` | 📋 proposed | Proxmox Backup Server (PBS datastore on the 8 TB) + Vaultwarden host. **PVE02/EQR6 always-on** (`ADR-0036` v1.2). Not in the `.2–.9` Tier-0 carve |
| **Vaultwarden** | 20 (server) | `10.20.0.13` | 📋 proposed | Secrets vault (web console) co-located on **BKP01**; TLS from ICA01; `ADR-0009`/`ADR-0031` custody. (Was only in the estate index — now registered here, `POL-0008`.) |
| **CNT01** | 20 (server) | `10.20.0.19` | 📋 proposed | Container host — estate self-hosted git/CI (Backlog #19; hybrid Linux-primary + Windows slice; `ADR-0045`/`ADR-0048`). **Linux runtime → PVE02/EQR6**; Windows slice → PVE01/R410 (→ #20) |
| MON01 | 40 | `10.40.0.10` | 📋 | monitoring stack |
| Pi01 | 10 | `10.10.0.6` | 📋 proposed | Pi-hole DNS forwarder + chrony NTP (physical Pi, bare-metal). 🔎 **Deconflict `.6` vs WAC01 `.5`** + SW01/PVE01 mgmt on VLAN 10 |
| PFSENSE01 (mgmt) | 10 | `10.10.0.7` | 📋 proposed | inline-IPS **mgmt only** — the data path is a transparent bridge with **no data-plane IP** (`ADR-0038` v1.2). `.7` firmed in the #20 deconflict |
| SIEM01 | 40 | `10.40.0.11` | 📋 proposed | Wazuh host SIEM/XDR (**dedicated host**, **16 GB** OpenSearch indexer; VLAN **40** + `.11` DECIDED #20 2026-07-30) |
| KALI01 | 70 | `10.70.0.5` | 📋 proposed | offensive/validation host (VLAN 70 Testing — isolated by default; attack paths per Game Day) |
| **SW01** (mgmt) | **10 (mgmt)** | `10.10.0.2` | 🟡 operator-reported | Access-switch management SVI (`Vlan10`). `.2` firmed in the #20 deconflict (was `10.10.0.x` in the worked examples) |
| **PVE01** (hypervisor host) | **10 (mgmt)** | `10.10.0.10` | 🟡 operator-reported (Virtualization `PVE01-Networking`, `ADR-0034`) | R410 hypervisor **management interface** (`vmbr0.10`, native VLAN 10 on Gi1/0/4). The *host* is on VLAN 10; the *VMs* it runs are VLAN 20/40/etc. workloads. Spin-up heavy tier (`ADR-0036` v1.2) |
| **PVE02** (hypervisor host) | **10 (mgmt)** | `10.10.0.11` | 📋 proposed | **EQR6** hypervisor **management interface** (tagged `vmbr0.10`, mirrors PVE01). Always-on core tier (`ADR-0036` v1.2). New in the #20 sweep — the second hypervisor's VLAN-10 mgmt address, next to PVE01's `.10` |

> **VLAN-10 (`10.10.0.0/27`) static map (firmed in the #20 deconflict, 2026-07-30 — static `.2–.20`, DHCP `.21–.30`):** `.1` MKT01 vlan10 SVI (gateway) · `.2` SW01 mgmt · `.5` WAC01 · `.6` Pi01 · `.7` PFSENSE01 mgmt · `.8` PAW01 · `.10` PVE01 host · `.11` PVE02/EQR6 host. `.3–.4`, `.9`, `.12–.20` reserved. No collisions. *(1941/FGT01 are managed via their transit/loopback + trusthost paths, not a VLAN-10 SVI — not on this list.)*

> 🔎 **Host placement is *not* owned here.** Which **physical host** each VM runs on (PVE01 vs PVE02 vs home-PC) is owned by **`Labs/Lab-02-Cisco-Core/Service-Server-Build-Plan.md`** (the interim placement + sizing single source until NetBox; `ADR-0036` states the principle). This register owns **addresses**; a host mention in a Role cell above is a convenience pointer, not the authority.

🔴 **Tier-0 block `.2–.9` is CAs + DCs only** — general servers start at `.10`. (This corrects a transient mis-assignment of a build box to `.9` on 2026-07-22; build/template VMs use a temporary static in the server range, e.g. `.50+`, and are generalized to no-static.)

## Validation
- [ ] Every VLAN's gateway `.1` is configured on MKT01 and pings from a host in that VLAN.
- [ ] No subnet overlaps another (they can't — different second octet — but confirm the masks don't exceed the VLAN's block).
- [ ] The two transit /30s ping across; loopbacks reachable via OSPF.
- [ ] DHCP hands out only within the pool range; static devices sit below it.
- [ ] This plan is the **only** place addresses are defined — NetBox renders from it, `006`-style tables become exports of it (`POL-0004`).

## Failure modes
- 🔴 **A host addressed outside its mask** (e.g. a `.20` in a `/28` that stops at `.15`) — the classic VLSM mistake; check every static assignment against the mask.
- 🔴 **Overlapping static and DHCP ranges** → duplicate-address conflicts.
- **Treating `10.<vlan>.0.0/16` as usable** — only the masked portion is live; the rest is headroom, not addresses to hand out.
- **Re-drifting** — if any address ends up defined somewhere other than here (a guide, a device, a second table), that's the `POL-0008` defect returning. One plan.

## Change Log

| Version | Changes |
|---|---|
| 1.11 | 2026-07-30. **#20 close-out — last floating address firmed.** KALI01 register address `10.70.0.x` -> **`10.70.0.5`** (VLAN 70 Testing static range `.2-.6`). Closes the last open address in the #20 sweep; CNT01 `.19` / BKP01 `.18` / Vaultwarden `.13` remain 📋 proposed pending build. |
| 1.10 | 2026-07-30. **#20 address deconflict (operator decisions).** Firmed the **VLAN-10 static map** (`.1` MKT01 · `.2` SW01 mgmt · `.5` WAC01 · `.6` Pi01 · `.7` PFSENSE01 · `.8` PAW01 · `.10` PVE01 · `.11` PVE02) — no collisions. **Moved PAW01 → VLAN 10 `10.10.0.8`** (off the VLAN-20 `.2–.9` Tier-0 carve — admin surface on the mgmt plane, flows-matrix #23). **Firmed** PFSENSE01 mgmt → `10.10.0.7`, **SIEM01 → `10.40.0.11` VLAN 40** (dedicated host, 16 GB indexer), **SW01 mgmt → `10.10.0.2`**. Pi01 `.6` kept; its DNS/NTP MGMT-ingress resolved as a **scoped exception** (flows-matrix #19). |
| 1.9 | 2026-07-30. **#20 sweep — two-hypervisor reconciliation.** The **VLAN-10-vs-20 rationale predated the second host** — updated it to reference **both hypervisor hosts (PVE01 *and* PVE02/EQR6)** on VLAN 10, not just PVE01 (`ADR-0036` added the always-on EQR6). Added register rows for both hypervisor **management interfaces**: **PVE01** `10.10.0.10` (🟡, `ADR-0034`) and **PVE02/EQR6** `10.10.0.11` (📋 proposed — the new second host's mgmt address; deconflict vs WAC01 `.5`/Pi01 `.6`). Added the note that **VM→physical-host placement is owned by `Service-Server-Build-Plan.md`** (this register owns addresses only, `POL-0008`). No subnet/mask changes. |
| 1.8 | 2026-07-30. **Batch C+D security devices — register rows** (📋 proposed): **PFSENSE01** mgmt VLAN 10 (data path = transparent bridge, no data-plane IP, `ADR-0038` v1.2) · **SIEM01** VLAN 40 (dedicated; VLAN/sizing → #20) · **KALI01** VLAN 70 (isolated). Networking devices (1941/SW01/MKT01/FGT01) already carry their transit/loopback/SVI addresses above. |
| 1.7 | 2026-07-30. **Batch B (Linux service VMs) register rows.** Added **BKP01** `10.20.0.18` + **Vaultwarden** `10.20.0.13` (co-located; was only in the estate index → now registered here, `POL-0008`) + **CNT01** `10.20.0.19` (container host / estate git/CI, `ADR-0045`), all VLAN 20 📋 proposed; set **Pi01** `.x`→`10.10.0.6` (VLAN 10 📋 proposed) with a 🔎 deconflict note vs WAC01 `.5`. NETBOX01 `.11` unchanged. From the Batch-B replication pass. |
| 1.6 | 2026-07-30. **Added the WAC01 host row** — `10.10.0.5`, **VLAN 10 (Management)** (📋 proposed), per the WAC01 replication pass + operator's VLAN-10 call (WAC is a Tier-0 admin/management surface → the mgmt plane, like 'the PAW/admin'; exercises `ADR-0045`'s review trigger, overrides its VLAN-20 default). 🔎 Deconflict `.5` against the other VLAN-10 hosts (Pi01, SW01/PVE01 mgmt). 🔴 Related drift to reconcile: PAW01 is VLAN 10 in this plan's text but VLAN 20 in the estate index — settle both admin surfaces together (#20). |
| 1.5 | 2026-07-30. **Added the RDS01 host row** — `10.20.0.17`, VLAN 20 **server** range (📋 proposed; not in the `.2–.9` Tier-0 carve), per the RDS01 replication pass (`POL-0008`: this plan is RDS01's authoritative address home). RDS is a client-*reached* service workload → VLAN 20 (the NetBox rationale), reached via flows-matrix flow #3 + the new RD-Gateway flow #15. 🔎 **Still owed:** FS01/WSUS01/SQL01 register rows (proposed `.14/.15/.16`) — reconcile in the #20 pass. |
| 1.4 | 2026-07-28. **Phase-2 reconciliation (register A2a + the A1 DHCP-wording gap).** Added the **NPS01** host row — `10.20.0.12`, VLAN 20 **server** range (the Tier-0 `.2–.9` carve stays CAs+DCs only) — per `ADR-0029` D7 (`POL-0008`: the IP plan is NPS01's authoritative address home). **Flipped the DHCP wording from "Kea on SRV01" → "DC01 (Windows DHCP)" per `ADR-0030`** in both the static/DHCP convention note and the SRV01 register role (relay on MKT01 now targets DC01 `10.20.0.2`); SRV01's role line also drops FreeRADIUS (→ NPS01, `ADR-0029`). This closes the A1 doc-row flip that register v0.8 recorded as done but which was still un-applied here at HEAD. No subnet/mask changes. |
| 1.3 | 2026-07-28. **DC02 status reconciled (07-24 audit M10).** Host register: DC02 `10.20.0.3` **⏳ promoting → 🟡 promoted (operator-reported 2026-07-28; `repadmin`/`dcdiag` read-back pending)**; added the **🟡** legend key (operator-reported, device read-back pending) so it is not conflated with ✅ device-verified. No address change. *(DHCP host = SRV01(Kea)→DC01 per `ADR-0030` is a separate Phase-2a edit, not in this pass.)* |
| 1.2 | 2026-07-24. Added **"Management (VLAN 10) vs Servers (VLAN 20) — what lives where"** — the design rationale for why service VMs (NetBox `10.20.0.11`, the DCs, SRV01) sit on the Servers VLAN while VLAN 10 is reserved for the device/hypervisor management plane. Keeps the management VLAN lean (smallest blast radius) and clarifies that "Management VLAN" = the network you manage devices on, not any admin tool. No address changes. |
| 1.1 | 2026-07-22. Added the **Current & reserved host assignments** register (DC01 ✅ `.2`, DC02 ⏳ `.3`, **ICA01 ✅ `.4`**, RCA01 offline, SRV01 📋 `.10`, NetBox 📋 `.11`, MON01 `.40.0.10`, Pi01 VLAN 10) so the plan reflects real hosts, not just ranges. Recorded **DHCP = SRV01 (Kea), held for SRV01**, with the **MKT01 DHCP-relay** requirement and the "infra stays static regardless" clarification. Reaffirmed the Tier-0 `.2–.9` = CAs+DCs boundary (corrected a transient build-box mis-assignment to `.9`). |
| 1.0 | 2026-07-17. Authoritative Lab-02 addressing plan (`POL-0008`). VLSM, VLAN-encoded (`10.<vlan>.0.0/<mask>`), sized to the 301 scenario: Clients /25, Servers & OT /26, Management & Deployment /27, Web/Mon/Test/DMZ /28; transit /30s and loopbacks in `10.255.x`; gateways on MKT01 (`ADR-0023`); the Tier-0 Identity carve-out as a reserved block in VLAN 20; static/DHCP split per zone (OT static-only). Supersedes the old `10.40.0.20/.30` planned addresses. |
