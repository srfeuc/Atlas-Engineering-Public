---
Title: Lab-02 — Pre-Build Decisions Register (define-before-build)
Path: Labs/Lab-02-Cisco-Core
Status: 🟠 WORKING — the single list of decisions to make **before** the estate is built (operator: "the whole lab needs to be defined before we start building", 2026-07-29). Driven to zero, then it becomes historical (like `Cleanup-and-Reconciliation-Plan.md`). Each decided item lands in an **ADR** (load-bearing) or the **Review-Flag-Register** / **IP-Addressing-Plan** and is struck here.
Version: 0.9
Date: 2026-07-29
---

# Lab-02 — Pre-Build Decisions Register

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — defining).** Every open decision that shapes *what gets built*, gathered so we can resolve them in batches before construction. **How we use it:** pick a batch → decide (options + a recommendation are pre-filled) → record the decision (ADR if load-bearing, else register/IP-plan) → strike it here. Status: 🔵 open · ✅ decided · ⏸ deferred (with a trigger).

> **Coverage note (v0.1):** seeded from the register flags, the DC `Considerations`, the estate roadmap, the cert docs, and `ADR-0036`. **Still to sweep** for more decisions as we go: the per-device `Considerations` (only DC exists so far), `Atlas-Roadmap-Advanced-Scenarios`, `Atlas-Next-Lab-Design-Brief`, `Tier-B-C-Planning-Session-Brief`. This register is **living** — new decisions are added as each device is defined.

> ✅ **SCOPE LOCKED (operator, 2026-07-29):** the lab is a **full hybrid enterprise** — *all* future areas are in-scope (Hybrid identity: Entra Connect + Intune · Exchange · Azure IaaS + S2S · Advanced on-prem identity: AD FS/WAP + RODC/2nd-site + MSP multi-domain/forest-trust). See the decided F/C rows + **Machines now in scope** below.

## A — Compute & placement

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| A1 | Where do the 5 new committed roles run? (FS01, WSUS01, SQL01, RDS01) | PVE01 · PVE02 · home-PC Hyper-V | 🔄 **REVISED 2026-07-29 (`ADR-0036` v1.2):** **FS01 → PVE02/EQR6** (on the 8 TB external; always-on file/backup tier). WSUS01/SQL01/RDS01 placed by uptime tier when scoped (always-on EQR6 vs spin-up R410) | 🟡 partial | ADR-0036 / IP-plan |
| A2 | **SIEM01/Wazuh** host model | Dedicated VM · co-locate on MON01 | **Dedicated VM** (🔴 Security vs MON01 🟡 Services) | 🔵 | new ADR |
| A3 | SIEM01/Wazuh placement | PVE01 vs PVE02 · VLAN 40 vs 20 | **PVE01, VLAN 40** (with the monitoring segment) | 🔵 | ADR / IP-plan |
| A4 | **PVE02** acquisition status | acquired · planned-not-acquired · not planned | ✅ **ACQUIRED 2026-07-29 — Beelink EQR6** (Ryzen 9 6900HX, 32→64 GB, 500 GB NVMe + 2× M.2, **8 TB external**, dual 1GbE, WoL). Now the **always-on critical tier** (`ADR-0036` v1.2); R410 → spin-up. Prereq: 64 GB kit before loading. Lifts the `ADR-0046` cluster gate (on-demand). | ✅ | ADR-0036 v1.1/1.2 |
| A5 | Home-PC Hyper-V — what actually lands there? (ADR-0036: non-critical / AZ-802 / AD FS) | confirm list | AZ-802 Hyper-V labs + AD FS lab VM | 🔵 | ADR-0036 |

## B — Addressing (owner: `IP-Addressing-Plan-VLSM` → NetBox)

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| B1 | IP assignments for the 5 new roles | assign on VLAN 20/40 | FS01 `.14` · WSUS01 `.15` · SQL01 `.16` · RDS01 `.17` · SIEM01 `10.40.0.x` | 🔵 | IP-plan |
| B2 | Reserve addresses for future hosts (Exchange, Entra-Connect sync) | reserve now · later | reserve a block when F-scope is set | ⏸ | IP-plan |

## C — Identity / AD

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| C1 | DHCP failover topology (ADR-0030 put DHCP on DC01; failover "later") | split-scope · failover (hot-standby/load-share) | **failover, load-share** once DC02 verified | ⏸ (after DC02 read-back) | ADR-0030 note |
| C2 | gMSA rollout order (Tier-A A1) | which service first | **SQL01 first**, then service hosts | 🔵 | register / SQL01 Roadmap |
| C3 | Pi01 conditional-forward cutover timing | now · after DC02 | **after DC02 verified** | ⏸ | register |
| C4 | Forest trust for the MSP sim (70-742 Ch7) | in-scope · skip | ✅ **in-scope** (Tier-B; trust objectives) | ✅ | roadmap |
| C5 | RODC + 2nd AD site (Tier-B B2) | in-scope · defer · skip | ✅ **in-scope, later** (replication/site learning) | ✅ | roadmap |
| C6 | AD FS + WAP (Tier-B B1) | in-scope · defer · skip | ✅ **in-scope** (identity capstone, after AD CS live) | ✅ | roadmap |

## D — Security & monitoring

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| D1 | **pfSense IDS/IPS** model | inline · passive · skip | ✅ **INLINE (true IPS)** — adds the prevention the passive Suricata-SPAN can't (`ADR-0038`) | ✅ | `ADR-0038` |
| D2 | pfSense — where in the path? | edge · internal · per-segment | ✅ **Transparent inline bridge on the FGT01↔1941 N-S transit** (not routed, not E-W) | ✅ | `ADR-0038` |
| D2a | pfSense physical deployment | physical appliance · VM on PVE01 | **physical low-power appliance** (keeps PVE01 off the N-S path) — confirm at build | 🔵 | ADR-0038 / build |
| D2b | pfSense fail-open vs fail-closed | fail-open · fail-closed | **fail-open** (homelab; internet survives a pfSense fault) | 🔵 | POL/ADR |
| D3 | Wazuh ↔ MON01 relationship | ingest Suricata+rsyslog into Wazuh · keep panes separate | **ingest** (one security pane) | 🔵 | SIEM01 Roadmap |

## E — PKI

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| E1 | OCSP + KRA (Tier-A A2) placement | on ICA01 · on a member server | **role-service on/adjacent to ICA01** | 🔵 | AD-CS guide |
| E2 | 🔴 Vaultwarden master-password recovery path (open ADR `049`) | decide the custody/recovery model | operator input — **blocker before trusting the vault** | 🔵 | ADR-0009 / new ADR |

## F — Future / cloud scope (the big "what's in-scope before building")

> ✅ Scope commitment recorded in **`ADR-0039`** (full hybrid enterprise, phased); Entra Connect sync method in **`ADR-0040`** (PHS).

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| F1 | Hybrid identity — **Entra Connect** (DC→cloud) | in-scope · defer · skip | ✅ **in-scope** (Phase H1 — the "DC replicated to cloud") | ✅ | roadmap / ADR |
| F2 | Entra Connect sync method | PHS · PTA · federation | ✅ **PHS** (`ADR-0040`) — cloud auth survives on-prem outage; AD FS built separately as a *federation lab*, not the auth path | ✅ | `ADR-0040` |
| F3 | **Intune** (cloud endpoint mgmt) | in-scope · defer · skip | ✅ **in-scope** (Phase H2, after Entra Connect) | ✅ | roadmap |
| F4 | **Exchange** | on-prem · EXO hybrid · both · skip | ✅ **on-prem first** (learning) → **EXO hybrid** later; own host **EXCH01** | ✅ | roadmap / EXCH01 |
| F5 | Azure IaaS + S2S VPN from FGT01 | in-scope · defer | ✅ **in-scope, later** (AZ-104 / CCNP) | ✅ | roadmap |

## G — Certification scope & learning priorities

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| G1 | Active cert-path priority order | CCNA · CCNP · FortiGate (NSE/FCP) · AZ-800/801 · AZ-104 · MD-102/MS-102 · SC-300 | **CCNA now → AZ-800/801 → FortiGate → CCNP → Azure (AZ-104) → M365** | 🔵 | cert-lab-map |
| G2 | Stand up the **1941** (free, highest-value CCNA move) | now · later | **now** (before spending anything) | 🔵 | cert-lab-map |
| G3 | **CML** (Cisco Modeling Labs) tier | CML-Free (5-node) · CML-Personal (~$199) | **start CML-Free** | 🔵 | cert-lab-map |
| G4 | Wireless (FortiAP) into the estate for CCNA wireless | in-scope · skip | **in-scope** (WPA2-Enterprise vs RADIUS) | 🔵 | cert-lab-map |
| G5 | FortiGate certification — formal path? | FCP/NSE · concepts-only | ✅ **Formal FCP/NSE target** — map FGT01/MKT01 work to its objectives | ✅ | cert-lab-map |

## H — Networking

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| H1 | IPv6 dual-stack on one VLAN (CCNA gap) | in-scope · skip | **in-scope, one VLAN** | 🔵 | cert-lab-map |
| H2 | OSPF-now on FGT01↔MKT01 before the 1941 | do now · wait for 1941 | **do now** (free routing reps) | 🔵 | cert-lab-map |

## I — Backup / storage (🔴 top risk)

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| I1 | The **$500** spend | backup-first (NAS+drives+console+off-site) · Cisco-depth-first (CML-Personal) | **backup-first** (closes Critical-Risk #1) | 🔵 | cert-lab-map |
| I2 | **Restore Game Day** commitment (never run) | commit + schedule · defer | **commit** — it's the top-risk close | 🔵 | BKP01 |
| I3 | TrueNAS (deferred) revisit trigger | keep deferred | revisit only if PVE/BKP01 storage insufficient | ✅ deferred | estate |

## J — Security validation / penetration testing

> Operator ask (2026-07-29): **pen-test the firewall, IPS/IDS, and networking devices**. Extends `Operations/Validation-and-Adversarial-Testing.md` (control→attack→evidence) — identity rows exist; the network/firewall/IPS-IDS/L2 rows were added 2026-07-29. These decisions define the **attacker capability**.

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| J1 | Pen-test scope | control-validation only · full offensive · both | **both** — validate every control *and* run real offensive tooling (own-lab) | 🔵 | Validation doc |
| J2 | Attacker host | extend **LabComputer** · dedicated **Kali VM (KALI01)** | **dedicated KALI01** (clean, snapshottable kit); keep LabComputer as the analyzer | 🔵 | Devices/KALI01 |
| J3 | Attacker placement | Testing VLAN 70 (isolated) · movable per-test | **VLAN 70 base** + controlled per-test reach into the target segment | 🔵 | IP-plan |
| J4 | Tooling set | network (nmap/hping3/Scapy/yersinia) + IDS (testmynids/EICAR/tcpreplay) + AD (PingCastle/BloodHound) + Metasploit | **adopt the full kit**; own-lab ROE, snapshot-first | 🔵 | Validation doc |
| J5 | Cert alignment | Security+ · PenTest+ · CySA+ · CEH | ✅ **Security+ core + PenTest+** (follow PenTest+ as the pen-test track when needed; CySA+ optional) | ✅ | cert map |

## K — Security-inspection cluster (firewall / IPS / UTM / CCNP-security — decide together)

> **Why a cluster (operator, 2026-07-29):** these decisions *interlock* — a choice in one inspection layer changes another (e.g. where DNS filtering lives affects whether Pi-hole keeps that job; how deep TLS inspection goes affects which relying parties need the ICA01 cert; how granular the E-W matrix is affects what the IPS even sees). Deciding them in isolation is how the ADR set drifted into the `ADR-0035`↔`ADR-0047` contradiction. **Decide them as a batch; each still lands in its own ADR** (operator's call, 2026-07-29 — individual ADRs, not one consolidated one). This section is the batching/tracking layer; it does **not** duplicate rows owned elsewhere (`POL-0008`) — it links to them.

> **Settled anchors (the layered inspection model these decisions hang off):** N-S content inspection = **FGT01 FortiGuard UTM** (`ADR-0047`) · N-S free/complementary inline IPS + free-vs-licensed comparison = **pfSense** (`ADR-0038`) · E-W prevention = **MKT01 default-deny** (`ADR-0023`) · network detection = **Suricata-on-SPAN / MON01** (`ADR-0032`) · host detection/SIEM = **Wazuh / SIEM01** · FGT admin auth = **direct LDAPS** (`ADR-0028`) · network-device auth = **NPS01** (`ADR-0029`). The FortiGate cert view is `Atlas-Academy/Atlas-FortiGate-FCP-Lab-Map.md`; the CCNP view is `Atlas-CCNP-Lab-Map.md`; the design/teaching home is `00-Atlas-Foundation/Atlas-Firewall-Architecture.md`.

| ID | Decision | Options | Recommendation | Status | Lands in |
|---|---|---|---|---|---|
| K1 | **TLS/SSL deep-inspection scope + inspection-cert distribution** — how far FGT01 UTM decrypts, and where the ICA01 inspection CA cert is trusted | full deep-inspection everywhere · certificate-inspection (SNI/cert only) everywhere · **deep inside, cert-only outbound-to-unknown** · per-segment | **Deep inspection where the ICA01 trust is distributed (managed clients / server VLANs); certificate-inspection elsewhere; explicit bypass for pinned apps + non-domain devices** | ✅ | **`ADR-0050`** (formalized 2026-07-30; re-signing CA = ICA01 subordinate GPO-pushed to Trusted Root; scoped to FGT-60E) |
| K2 | **DNS-filtering ownership** — FortiGuard DNS filter (UTM) vs Pi-hole sinkholing vs both | FortiGuard DNS filter only · Pi-hole only · both, layered | **Pi-hole (Pi01) owns DNS filtering — single home; FortiGuard DNS-filter stays OFF** (FGT UTM keeps web/AV/IPS/app-control per `ADR-0047`). *Refined 2026-07-30 from the earlier "both, layered" rec — one DNS-control home avoids split-brain blocklists; see `ADR-0051`.* | ✅ | **`ADR-0051`** (refines this row's earlier "both, layered" recommendation to single-owner) |
| K3 | **FSSO (Fortinet SSO to AD)** — identity source for FGT identity-based policies | collector-agent (DC-event) · agentless polling · none (LDAP/RADIUS auth only) | **Collector-agent FSSO** (the FCP-graded pattern; transparent identity in policy) — after the DC + FGT LDAPS are live | 🔵 | new ADR (ties `ADR-0028`/`ADR-0029`, FCP §2) |
| K4 | **MKT01 east-west matrix depth** — how granular before build | VLAN-pair only · VLAN-pair + a few host micro-rules · full microsegmentation | **VLAN-pair default-deny first (the `ADR-0023` matrix), then targeted micro-rules for the crown-jewel segments (Tier-0/servers)** — microseg is a later capstone | 🔵 | new ADR / `Atlas-Firewall-Architecture` §4 |
| K5 | **1941 Zone-Based Firewall (ZBF)** — CCNP-security lab on the core router | in-scope · skip (MKT01 owns E-W) | **In-scope as a CCNP-security lab** (ZBF on the 1941 as a *teaching* control), kept distinct from MKT01's production E-W role so the two don't overlap in the path | 🔵 | cert-map (CCNP) / new ADR if it changes topology |
| K6 | **Wireless security** — WPA2/WPA3-Enterprise + 802.1X | WPA2-Enterprise via FortiAP→NPS01 · WPA3-Enterprise · PSK-only | **WPA2/WPA3-Enterprise via FortiAP → RADIUS(NPS01)** — CCNA/CCNP wireless + the 802.1X security story (**cross-ref G4**; don't duplicate) | 🔵 | cert-map (G4) / NPS01 Roadmap |
| K6a | **Wireless controller (WLC) hardware** — operator open to buying a WLC-aware AP/device | FortiGate-as-WLC managing FortiAP(s) (no new controller) · dedicated **Cisco 9800-CL virtual WLC** + a CAPWAP AP · physical Cisco WLC | **FortiGate-as-WLC + a FortiAP first** (reuses the edge, cheapest path, FCP-aligned); **add a Cisco 9800-CL virtual WLC** when the CCNA/CCNP *controller-based wireless* objectives need Cisco-flavored CAPWAP/WLC | 🔵 | cert-map / new ADR if hardware acquired |
| K7 | **IPS rule-set + tuning discipline** — pfSense Suricata categories + FGT IPS sensor scope | block-from-day-1 · **monitor-first → tune → block** (per `ADR-0041`) | **Monitor-first, then block** on both pfSense and FGT UTM IPS; pick rule categories per segment; a positive test (known-signature trigger) gates each 'on' | 🔵 | new ADR / Build-Guides (`ADR-0041` gated) |
| K8 | **Detection correlation / single pane** — Suricata + Wazuh + FGT/pfSense/MKT01 logs | separate panes · **ingest all into Wazuh (one pane)** · SIEM-forward to cloud later | **Ingest into Wazuh (SIEM01) as the security pane** (**cross-ref D3** — don't duplicate); NTP-synced timestamps first (`CM-0030` SW01 clock) | 🔵 | SIEM01 Roadmap (D3) |
| K9 | **pfSense deployment sub-decisions** — physical-vs-VM + fail-open/closed | see D2a / D2b | *(owned in Section D — **cross-ref D2a physical-appliance, D2b fail-open**; listed here only so the cluster is complete, `POL-0008`)* | 🔗 | `ADR-0038` / build (D2a/D2b) |
| K10 | **CCNP infrastructure-security topics** — control-plane + L2 hardening to lab | CoPP · Control-Plane Policing · infrastructure ACLs · DHCP snooping/DAI/port-security (some in CIS hardening) · MACsec | **Lab the L2 set (DHCP snooping/DAI/port-security) on SW01 + CoPP/iACLs on the 1941**; MACsec optional (hardware-dependent) | 🔵 | cert-map (CCNP ENARSI) / CIS-hardening docs |

## Machines now in scope (from the scope decisions, 2026-07-29)

These enter the estate definition and will each get a device folder + Roadmap during the definition pass:

- **Entra ID tenant + Entra Connect** — hybrid identity sync (cloud tenant + an on-prem sync role, likely a member server). *Phase H1.*
- **Intune** — cloud endpoint management (no on-prem VM; an Entra/MDM service). *Phase H2.*
- **EXCH01 — Exchange Server** (on-prem, AD-integrated) → later **Exchange Online hybrid**. *Phase H3.*
- **ADFS01 + WAP01** — AD FS (federation/SSO) + Web Application Proxy in the DMZ (VLAN 80). *Tier-B.*
- **RODC (2nd site)** — read-only DC in its own AD site/subnet. *Tier-B.* **(`ADR-0045` confirms it as a concrete VM + 2nd-site subnet; also C5.)**
- **MSP sim domains** — `customera.local` / `customerb.local` with a **forest trust**. *Tier-B / advanced-scenarios.*
- **Azure** — IaaS resources + an S2S VPN from FGT01 (cloud, not a local VM). *Phase H4.*
- **PFSENSE01 (inline IPS)** — transparent inline IPS on the FGT01↔1941 N-S transit (`ADR-0038`); physical-appliance-vs-VM (D2a) + fail-open/closed (D2b) pending.
- **KALI01 (attacker / validation host)** — Kali VM on the Testing VLAN (70) for the pen-test pass (J-series); own-lab ROE. Complements LabComputer (analyzer/IDS).
- **Client workstation fleet — WS-HR01 · WS-ENG01 · LT-SALES01 · WS-IT01** — the estate's **test clients** on VLAN 50 (one movable to VLAN 70) for GPO / AGDLP department access / LAPS / segmentation / Intune; role-based OUs + security-filtered GPOs; AGDLP to the FS01 department shares (**HR→HR ✓ / HR→IT ✗**). Modeled as a `Devices/Workstations/` fleet off a Win11 golden image (`ADR-0042`).

- **WAC01 — Windows Admin Center gateway** — dedicated gateway-mode management host for the Windows estate + Azure-Arc on-ramp; PVE01 / VLAN 20; **Tier-0 management surface** (PAW-only, ICA01 cert). *AZ-800/801 sweep · `ADR-0045`.*
- **Container host** — Windows containers / Docker; **ride SRV01** (Linux/Docker) now, add a Windows-container capability / `CNT01` **on demand**. *AZ-800 · `ADR-0045`.*
- **Failover-cluster node pair** (e.g. `SQLN1`/`SQLN2` for a SQL Always On AG, or `CLU01a`/`CLU01b` for a clustered file server) — 2 nodes on **different physical hosts** (PVE01 + PVE02) + **S2D** + a **file-share/cloud witness**. **Build-gated on PVE02.** *AZ-801 (biggest HA gap) · `ADR-0046`.*

> **AZ-800/801 sweep additions (2026-07-29):** the four above (WAC01 · container host · cluster pair · RODC-confirmed) come from `Atlas-Academy/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md`. Host **extensions** (no new VM) also logged there: FS01 iSCSI/S2D/dedup · DNSSEC · DHCP **failover** (C1) · JEA endpoints · the Azure/H4 enumeration.

## Related
- `Review-Flag-Register.md` (flags + settled decisions) · `Service-Server-Build-Plan.md` (estate single source) · `Architecture/IP-Addressing-Plan-VLSM.md` (addressing owner) · `00-Atlas-Foundation/Decisions/ADR-Index.md`.
- Cert scope: `Atlas-Academy/Atlas-Certification-Lab-Map.md` · `00-Atlas-Foundation/Roadmap/Atlas-Cert-Objective-Gap-Analysis.md` · `Atlas-Roadmap-Advanced-Scenarios.md`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.9 | 2026-07-29 | **PVE02 ACQUIRED (A4 ✅) + placement inverted + storage/backup model.** Operator bought a **Beelink EQR6** (Ryzen 9 6900HX, 32→64 GB, 500 GB NVMe + 2× M.2, dual 1GbE, WoL) and has an **8 TB external** for it. Recorded in **`ADR-0036` v1.1** (hardware) + **v1.2** (placement inversion: EQR6 = always-on critical tier · R410 = mostly-off spin-up heavy tier; 8 TB → FS01 + BKP01 datastore; backup independence = mandatory off-site copy; **64 GB = prerequisite**; DC02 + `ADR-0046` cluster = on-demand). **A1 revised** — FS01 moves to PVE02/EQR6. **`ADR-0046` v1.1** — cluster gate lifted but re-scoped on-demand + 1GbE-S2D caveat. |
| 0.8 | 2026-07-29 | **Added Section K — the security-inspection cluster** (operator ask: the firewall / IPS / UTM / CCNP-security decisions interlock and should be decided together with a single home). Batches 11 interlocking rows (K1 TLS deep-inspection scope + inspection-cert distribution · K2 DNS-filter ownership FortiGuard-vs-Pi-hole · K3 FSSO · K4 E-W matrix depth · K5 1941 ZBF · K6 wireless 802.1X + **K6a WLC hardware** (FortiGate-as-WLC vs Cisco 9800-CL — operator open to buying an AP/controller) · K7 IPS tuning discipline · K8 detection correlation · K9 pfSense D2a/D2b cross-ref · K10 CCNP infra-security) off a *settled-anchors* model (`ADR-0047` UTM · `ADR-0038` pfSense · `ADR-0023` E-W · `ADR-0032` detection · `ADR-0028`/`0029` auth). **Each row lands in its own ADR** (operator's call — individual, not one consolidated ADR). Cross-refs D2a/D2b/D3/G4 rather than duplicating (`POL-0008`). Follows `ADR-0047` (which closed the `ADR-0035`↔UTM contradiction this cluster exists to prevent recurring). |
| 0.7 | 2026-07-29 | **AZ-800/801 sweep → new-scope machines.** Added **WAC01** (Windows Admin Center gateway), a **container host** (SRV01 now / `CNT01` on demand), and a **2-node failover-cluster pair + S2D + witness** to machines-in-scope; **confirmed the RODC** (C5) as a concrete VM. Recorded in **`ADR-0045`** (WAC/container/RODC) + **`ADR-0046`** (cluster/S2D). Set G1's target label to **AZ-800/801** (the active pair); **AZ-802** replaces them 2026-09-30 with the same skills (tracked in the cert-lab-map). |
| 0.6 | 2026-07-29 | **Client workstation fleet + dept resource access → `ADR-0042`.** Lean set (WS-HR01/WS-ENG01/LT-SALES01/WS-IT01) on VLAN 50 (one movable to VLAN 70) as the test clients for GPO, AGDLP dept access (HR→HR ✓ / HR→IT ✗), LAPS, segmentation, Intune co-management; added to machines-in-scope. Also this session: **`ADR-0041`** (incremental, test-gated implementation — Global build discipline). |
| 0.5 | 2026-07-29 | **Cloud-scope + Entra-method ADRs written.** `ADR-0039` records the full-hybrid-enterprise commitment (F/C-series); `ADR-0040` sets Entra Connect = **PHS** (F2 ✅), with AD FS kept as a separate federation lab. |
| 0.4 | 2026-07-29 | **Added the J-series (security validation / pen-testing)** — operator's ask to pen-test the firewall/IPS-IDS/networking. J1 scope · J2 attacker host (**KALI01** Kali VM) · J3 placement (VLAN 70) · J4 tooling · J5 cert (PenTest+/CySA+). Added **KALI01** to machines-in-scope; extended `Validation-and-Adversarial-Testing.md` → v0.2 with the network/IPS-IDS/L2 rows. |
| 0.3 | 2026-07-29 | **D1/D2 closed → `ADR-0038`.** pfSense = **transparent inline IPS on the FGT01↔1941 north-south transit** (fills the FGT-no-UTM gap; complements MON01-Suricata + Wazuh; MKT01 keeps E-W). Surfaced two build-time subs: **D2a** physical-appliance-vs-VM (rec: physical), **D2b** fail-open-vs-closed (rec: fail-open). |
| 0.2 | 2026-07-29 | **Batch-1 decided (scope locked).** Full hybrid enterprise: F1 Entra Connect + F3 Intune + F4 Exchange + F5 Azure + C4/C5/C6 (MSP forest-trust / RODC+site / AD FS+WAP) all **in-scope**. A4 PVE02 = **planned, not acquired (build gate)**. G5 FortiGate = **formal FCP/NSE**. D1 pfSense = **inline IPS (needs ADR)**. Added the **Machines now in scope** section (Entra Connect, EXCH01, ADFS01+WAP01, RODC, MSP domains, Azure, pfSense). |
| 0.1 | 2026-07-29 | Created — the pre-build decisions register (operator: define the whole lab before building). Seeded ~30 open decisions across compute/placement, addressing, identity, security/monitoring, PKI, future-cloud scope, certification, networking, backup — each with options + a recommendation + where it lands. Living; to be enriched from the per-device `Considerations` + the Roadmap-folder docs as we sweep. |
