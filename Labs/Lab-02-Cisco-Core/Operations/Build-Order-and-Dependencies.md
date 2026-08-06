---
Title: Lab-02 — Build Order & Dependencies (the estate build sequence)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 LIVING — the single owner of the estate build order + cross-device dependencies (`ADR-0043`; register E2). **Supersedes `Architecture/Master-Build-Order.md` + `Master-Implementation-Checklist.md`.** The *how* lives in each device's gated Build-Guide (`ADR-0043`); live status → `Build-Progress-Tracker.md`; where-we-are → `SESSION-HANDOFF.md` (`POL-0008`).
Version: 1.5
Date: 2026-07-30
---

# Lab-02 — Build Order & Dependencies

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).**

> **Authority Rule (`POL-0008`).** This is the **one** owner of *what gets built, in what order, gated on what.* It replaced three overlapping docs (`Master-Build-Order` + `Master-Implementation-Checklist` + the tracker's commissioning order). **Update the order here first; everything else links, it does not restate.** Division of labor:
> - **This doc** = the cross-device sequence + the 🔴 GATES + the dependency map (the *plan* — changes rarely).
> - **Each device's `Build-Guide` / `Build-Guide/`** = the *how* for its phases (`ADR-0043`: phases mirror the device `Roadmap`; per-phase gate; the click-steps live there).
> - **`Build-Progress-Tracker.md`** = live status / execution log (what's done, what broke).
> - **`SESSION-HANDOFF.md`** = the where-we-are narrative.
> - **`Architecture/Atlas-Service-Architecture.md`** = the design (why each service exists / where it lands).

## How to build from this
Read top-down. A **🔴 GATE** blocks everything after it until its condition is met. For each phase: **confirm the gate → open the named device Build-Guide(s) → execute gate-by-gate** (`ADR-0041` — one tested unit at a time) → paste read-backs so 🟡→✅ (`POL-0001`). **Finish and verify a phase before the next** (Charter Rule 1/8).

## Decisions that shape the order — all CLOSED (don't re-decide at the bench)
| Area | Decision | ADR |
|---|---|---|
| Domain / time / identity | `atlas.lab`; PDCe external-time authority; AD is the tiered backbone | `ADR-0007` · `ADR-0020` · `ADR-0021` |
| Core topology | 1941 routed core; MKT01 the east-west firewall | `ADR-0023` |
| PKI | Two-tier AD CS (offline RCA01 + issuing ICA01); **AD CS is the only CA** (OpenSSL retired) | `ADR-0027` · `ADR-0031` |
| Device auth | Network devices → **NPS on NPS01**; FGT01 → **direct LDAPS** | `ADR-0029` · `ADR-0028` |
| DHCP | On **DC01** (not Kea/SRV01); MKT01 relay | `ADR-0030` |
| Perimeter IDS/IPS | FGT01 **no UTM** (Suricata SPAN = IDS); **pfSense inline IPS** on the N-S transit | `ADR-0035` · `ADR-0038` |
| Compute | Second host **PVE02** (build gate); blast-radius placement | `ADR-0036` |
| Cloud scope | Full hybrid enterprise (Entra Connect **PHS** → Intune → Exchange → Azure; AD FS/RODC/MSP Tier-B) | `ADR-0039` · `ADR-0040` |
| Build discipline | Incremental, **test-gated** (one unit, gate, then next) | `ADR-0041` |
| Endpoints | Lean **client workstation fleet** + AGDLP department access | `ADR-0042` |
| Doc/build model | **Phased, dependency-gated Build-Guides** mirroring the Roadmap | `ADR-0043` |

## Still-open (not blocking; propose-at-build)
🔴 Vaultwarden master-password recovery (`049`) · 🔴 PVE01 board `CM-0012` (replace vs UPS-forever) · 🟡 GPO Wave-B VBS/CredGuard (Proxmox `msinfo32` check) · pfSense physical-vs-VM + fail-open/closed (`ADR-0038` D2a/D2b) · SIEM01/Wazuh co-locate-vs-dedicated + placement VLAN.

## The five principles this order obeys
1. Source of truth is a **database (NetBox)**, not a document.
2. **Separate the planes** — routing / filtering / services / identity, each on the box built for it.
3. **Default-deny, log the deny, test the deny.**
4. **Synchronized clocks first** — logs, Kerberos, certs all die without them.
5. **Build the visibility stack before the security stack** — you can't segment flows you can't see.

> 🔴 **The sequencing trap this avoids:** you do **not** turn on default-deny east-west during bring-up. The network comes up **permissive** → you make the flows **visible** (Phase 6) → you write the deny policy **from evidence** (Phase 7). That dodges the #1 real-world failure: "allow any-any to make it work, never tighten."

## Execution reality (2026-07-29)
Networking foundation + internet are **live**; Hardening **Pass-1** is device-verified on all three network devices. **Identity (Phase 3) is running deep and early** (DC01 promoted + full GPO stack + tier groups). **AD CS is pulled forward** (`ADR-0027`) because the DC LDAPS cert gates the device-auth wave; **OpenSSL is retired** (`ADR-0031`). The **DC-early** re-sequence is permanent. Live per-step status is in `Build-Progress-Tracker.md`; this doc is the stable plan.

---

## The phases
> Each phase: **Goal · Stand up · 🔴 Gate · Drives (the device Build-Guides) · Verify.** Status is not kept here (POL-0008 → the tracker).

### Phase 0 — Before the first wipe · [safety]
- **Goal:** safety net + hardware in place.
- **Stand up:**
  - backups on `E:\` + off-site — with **text exports confirmed readable**
  - UPS + CR2032 on PVE01 (`CM-0012`)
  - FTDI / MikroTik console cable (✅ acquired)
- **🔴 Gate:** the first phase — nothing precedes it.
- **Drives:** `Operations/Device-Backup-Runbook.md`, `Architecture/Pre-Teardown-Backup-and-Verify-Checklist.md`.
- **Verify:** a text export opens and is readable (not just "the backup ran").

### Phase 1 — Wipe & cable (physical) · [topology]
- **Goal:** clean devices, correct topology.
- **Stand up:**
  - factory-reset MKT01 / SW01 / FGT01; fresh Pi01
  - rack the 1941
  - cable per `Cabling-and-Port-Map.md` (FGT01→1941→MKT01→SW01, PVE01 trunk, SPAN to the IDS host)
  - **prove console access to every device** (esp. MKT01 via FTDI) *before* relying on the network
- **🔴 Gate:** Phase 0 backups readable.
- **Drives:** `Architecture/Cabling-and-Port-Map.md` + each device's Build-Guide.
- **Verify:** console reachable on every box.

### Phase 2 — Network foundation (PERMISSIVE) · [connectivity]
- **Goal:** everything can talk and reach the internet. **Segmentation comes later.**
- **Stand up:**
  - **SW01** — VLANs 10–90, trunk, SPAN `Gi1/0/5`
  - **MKT01** — a VLAN gateway per subnet, `/30` uplink, default→1941 (**permissive filter, temporary**)
  - **1941** — two routed `/30`s, OSPF + loopback, default→FGT
  - **FGT01** — wan1, internal1, egress + NAT
  - **PVE01** — VLAN-aware bridge, native **999**, mgmt on `vmbr0.10`
  - temporary upstream NTP
- **🔴 Gate:** Phase 1 cabled + console proven.
- **Drives:** SW01 / MKT01 / 1941 / FGT01 Build-Guides + `Virtualization/Build-Records/PVE01-Networking.md`.
- **Verify:** host → internet; `traceroute` host→MKT01→1941→FGT01→out; routing correct; clocks synced (read *status*, `POL-0001`). *(✅ done — see tracker.)*

### Phase 2.5 — Box hardening (perimeter-first, two-pass) · [CSF: Protect]
- **Goal:** lock each box's management plane. **Box hardening ≠ east-west segmentation** (that's Phase 7, from evidence).
- **Stand up — Pass 1 (self-contained):**
  - named admin + disable the default admin
  - trusthost / mgmt-scope
  - MFA that needs no CA (FortiToken)
  - strong crypto/TLS; disable unused services
  - encrypted backup; DoS / local-in; admin + event logging
- **Stand up — Pass 2 (AD/PKI-backed):**
  - FGT01 → **direct LDAPS** (`ADR-0028`)
  - MKT01 / SW01 / 1941 → **RADIUS to NPS01** (`ADR-0029`)
  - keep one **local break-glass** per box — never PKI-ify it
- **🔴 Gate — Pass 2:** Phase 3 (DC) complete **+** the AD CS **DC LDAPS cert** (Phase 8/3b).
- **Drives:** `Architecture/CIS-Hardening-*.md`; `FGT01/Build-Guide-2b-AD-LDAPS-Admin.md`.
- **Verify:** every box reachable from the mgmt host **and** its break-glass path; named-admin login (local Pass-1, then AD Pass-2). *(Pass-1 network devices ✅; FGT Pass-1 core ✅; Pass-2 ⬜ gated.)*

### Phase 3 — Identity (DC track) + the Tier-0 admin plane · [CSF: Protect]
- **Goal:** AD as the tiered identity backbone **+** the hardened plane you administer it from. Built **early** — Pass-2 auth, PDCe time, and AD-DNS all depend on it.
- **Prereq:** Windows **golden images** — Server 2025 (guides 207–214) + Win11 (`PAW01` Part 1).
- **Stand up (sub-phases 3a–3h):**
  - **3a** — DC01 promote: `atlas.lab`, KDS root key, AD-DNS, PDCe external-time authority
  - **3b** — OU skeleton (role-based, tier-model-aligned)
  - **3c** — GPO stack: baseline / PSO / LAPS / tier-deny
  - **3d** — AGDLP tier groups (`G-Tier0/1/2-Admins`)
  - **3e** — tiered accounts + off the built-in Administrator + Protected Users
  - **3f** — DC02 replica
  - **3g** — **PAW01** (the Tier-0 admin workstation)
  - **3h** — **DHCP on DC01** (`ADR-0030`; MKT01 relay per served VLAN)
- **🔴 Gate:** Phase 2 connectivity + working clocks. *(7d tier-deny gated on the tier groups; GPO Wave-B on the VBS check.)*
- **Drives:** `Devices/DC-Domain-Controllers/Build-Guide/` (spine + `OU-` / `GPO-` / `Tiered-Admin-and-Groups-Build`), `Devices/PAW01-Tier0-Admin/Build-Guide.md`.
- **Verify:** `Get-ADDomain`=`atlas.lab`; `Get-KdsRootKey`; `w32tm /query /source` external (PDCe); `repadmin /replsummary` clean; `gpresult` baseline/LAPS/PSO; **flagship test** — a Tier-2 credential cannot touch a Tier-0 object (→ Validation matrix). *(DC01 core+GPO+groups ✅; tier accounts + DC02 read-back + PAW + DHCP ⬜/🟡 — tracker.)*

### Phase 4 — Source of truth (NetBox) · [CSF: Identify]
- **Goal:** one database every later step reads from.
- **Stand up:**
  - **NETBOX01** (Linux) on `10.20.0.11`
  - load from `IP-Addressing-Plan-VLSM` + `Cabling-and-Port-Map` (incl. the Windows hosts + tier/VLAN placement)
  - `006` becomes a **rendered export** of NetBox (`POL-0004`)
  - SW01 `STATIC-HOSTS` / DAI is now **generated**, not hand-typed
- **🔴 Gate:** nothing downstream (generated ACLs, automation) starts before this exists.
- **Drives:** `Devices/NETBOX01-Source-of-Truth/Build-Guide.md`, `NetBox-Data-Load-Prep.md`.
- **Verify:** NetBox renders the IP register; SW01 DAI list is generated, not hand-typed.

### Phase 5 — Core services (PVE01) · [CSF: Protect]
- **Goal:** the services the estate depends on, off the wrong boxes.
- **Stand up:**
  - **Pi01** — Pi-hole DNS + NTP **only**; conditional-forward `atlas.lab`→DCs
  - **SRV01** (Ubuntu) — **nginx CRL host `pki.atlas.lab` first** (the AD CS prerequisite), then Oxidized / rsyslog / TFTP-SFTP
  - **NPS01** (Windows member server) — RADIUS for the network devices; **server cert from ICA01**; hosts the member-server LAPS test
  - *(DHCP is on DC01 — Phase 3h, not here.)*
- **🔴 Gate:** Phase 3 (AD) + AD CS (for the NPS/SRV certs).
- **Drives:** `Devices/SRV01-Network-Services/` (+ `Roles/`), `Devices/NPS01-Network-Policy-Server/Build-Guide.md`, `Devices/Pi01-DNS-NTP/`.
- **Verify:** DNS resolves; Oxidized commits land in git; **NPS01 answers a real device→RADIUS login**.

### Phase 6 — Visibility (MON01) + IDS · [CSF: Detect]
- **Goal:** see everything before you secure it.
- **Stand up:**
  - **MON01** — rsyslog ← every device · **SNMPv3**→LibreNMS · **NetFlow** · Grafana · Uptime-Kuma · **Suricata on the SPAN**
  - turn on **SNMPv3 + syslog on every device** (the deferred CIS "Phase 6" items)
  - **SIEM01 / Wazuh** — ingest Suricata + rsyslog into one security pane
- **🔴 Gate:** Phase 5 (hosts + services to watch).
- **Drives:** `Devices/MON01-Monitoring/` (+ `Roles/`), `Devices/SIEM01-Wazuh/`.
- **Verify:** NetFlow watches real traffic ~a week — **that evidence is what the Phase-7 matrix is built from.**

### Phase 7 — East-west segmentation (MKT01) + inline IPS · [CSF: Protect]
- **Goal:** default-deny east-west, **from evidence**, tested.
- **Stand up:**
  - fill `Atlas-East-West-Allowed-Flows-Matrix` **from the NetFlow evidence** (incl. the PAW→Tier-0 admin flows)
  - flip MKT01 permissive → **default-deny + log** (Tier-0 `.2–.9` and OT VLAN 90 tightest)
  - add **PFSENSE01 inline IPS** on the FGT01↔1941 N-S transit (`ADR-0038`)
  - build the forward chain **incrementally** — one scoped rule, tested, then the next (`ADR-0041`)
- **🔴 Gate:** console break-glass proven (Phase 1) + clocks + **MON01/NetFlow evidence (Phase 6)** + the matrix filled.
- **Drives:** `Devices/MKT01-East-West-Firewall/Incremental-East-West-Firewall-Build-Worksheet.md` + `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md`; future `Devices/PFSENSE01-IPS/`.
- **Verify:** the **reachability-matrix Game Day** (`ADR-0011`) — every allowed flow passes, every denied flow is refused **and logged**.

### Phase 8 — PKI (AD CS) · [CSF: Protect]
- **Goal:** real PKI with **revocation from cert #1** (`ADR-0009`). One unified CA — AD CS — for domain **and** non-domain (`ADR-0031`). *(Mostly pulled forward to Phase 3b via `ADR-0027`.)*
- **Stand up:**
  - offline **RCA01** root → enterprise **ICA01** issuing CA
  - DC LDAPS / Kerberos certs + the **NPS01 server cert** + autoenrollment
  - working HTTP **CDP/AIA on SRV01**
  - fold non-domain (FGT / MKT / Pi-hole) onto AD CS + **migrate-and-test (D5)** → decommission the OpenSSL CA
  - **OCSP + KRA** (Tier-A A2)
- **🔴 Gate:** the **RCA01 offline-root ceremony gates everything**; the **revocation acceptance gate** (guide Part 4) is **mandatory** before PKI is "done."
- **Drives:** `Devices/RCA01-ICA01-ADCS/Build-Guide/` (`AD-CS-Two-Tier-Build-Guide` + Diagnostics-RCA01/ICA01).
- **Verify:** `pkiview.msc` all-OK **and** an observed revoke→reject.

### Phase 9 — Resilience (backup) · [CSF: Recover] · 🔴 top live risk
- **Goal:** backups that have **actually been restored.**
- **Stand up:**
  - **BKP01** (Proxmox Backup Server on PVE02) + off-site restic/borg
  - include **AD system-state** (KDS key, SYSVOL) + the golden templates
  - Vaultwarden co-locates on BKP01
- **🔴 Gate:** don't leave this late (it is the top live risk); needs **PVE02** acquired (`ADR-0036`).
- **Drives:** `Devices/BKP01-Backup/` (+ `Roles/`), `Operations/Device-Backup-Runbook.md`.
- **Verify:** 🔴 **Restore Game Day** (`ADR-0011`, `POL-0005`) — restore something on purpose. It has never been done.

### Phase 10 — Automation / IaC · [CSF: Protect + maturity] · model = `ADR-0048`
- **Goal:** changes flow through automation, from the source of truth.
- **Model (`ADR-0048`):** two layers — per-device **`Automation/`** doc-type (slice + how-tos) + the **estate capability** (self-hosted git/CI + shared Ansible/Terraform/DSC/Oxidized, this phase + Backlog #19). Learning-Rule reconciled (automate what you've learned by hand); phased, cert-matched.
- **Stand up (phased, cert-matched — `ADR-0048`):**
  - Oxidized config-versioning live (from Phase 5) — CCNA Dom-6
  - **Ansible** rendering device configs **from NetBox** (read-only `show` playbook first) — CCNP ENAUTO
  - Terraform + Bicep/ARM (Azure env; Proxmox provider on-prem) — AZ-104 / H4
  - PowerShell DSC (Windows desired-state) — AZ-800/801
  - self-hosted **git (Gitea/GitLab) + CI runner** (GitOps) — AZ-400 / Backlog #19
  - each device onboards via its Build-Guide **Automation-onboarding** section (`ADR-0043`) → links down to the device `Automation/` folder (`ADR-0048`)
- **🔴 Gate:** Phase 4 (NetBox as the source).
- **Drives:** the per-device `Automation/` folders + Build-Guide Automation-onboarding sections; the `Operations/Automation/` home + the self-hosted git host (Backlog #19).
- **Verify:** a NetBox-driven config render + a detected drift diff; every artifact **idempotent** (`ADR-0041`).

### Phase 11 — Hybrid Identity & Cloud (Azure / Entra) · [maturity] · *ADVANCED / EVENTUAL*
- **Goal:** extend the on-prem tier model into Microsoft cloud management — deliberately **after** the on-prem foundation is solid. 🔴 **Not a blocker for anything earlier.**
- **Stand up (phased):**
  - **H1** — Entra Connect (**PHS**, `ADR-0040`)
  - **H2** — Intune (co-management; enrol the workstation fleet)
  - **H3** — Exchange (on-prem → EXO hybrid; **EXCH01**)
  - **H4** — Azure IaaS + S2S VPN from FGT01
  - **Tier-B (parallel):** AD FS + WAP (federation lab, DMZ VLAN 80) · RODC + 2nd AD site · the MSP forest-trust sim
- **🔴 Gate:** on-prem foundation solid (Phase 3 + 8) **+** a tenant/subscription. Each capability is fenced as a **gated stub** in the relevant device Build-Guide (`ADR-0043`) until reached.
- **Drives:** the DC `Roadmap` H1–H4 + future `Devices/` folders (Entra Connect host, EXCH01, ADFS01+WAP01, RODC).
- **Certs:** AZ-802 · AZ-104 · MS-102 · MD-102 · SC-300.

---

## Cross-cutting track — Validation & pen-test (not a phase)
Each control is **proven as it is built** via `Operations/Validation-and-Adversarial-Testing.md` (control → attack → evidence): tier-deny (Phase 3), east-west/IPS (Phase 6–7), L2/switch (Phase 2/7), PKI/ESC (Phase 8). The offensive pass uses **KALI01** on VLAN 70 (`ADR-0042` neighbour; J-series). Runs alongside every phase, not after it (`ADR-0041`).

## Cross-device dependency map (the chicken-and-egg)

> **This map is filled in progressively — each device's replication/build pass adds its row** (operator, 2026-07-30). Some rows/phases predate the Wave-B roles + `ADR-0036` v1.2 placement and **may not be fully current**; treat a **missing** device as *not-yet-documented*, not *no dependency*. Deeper currency reconciliation is part of the #22 audit.
| You need… | …before | Handled in |
|---|---|---|
| Routing / connectivity | anything talks | Phase 2 |
| Synced clocks | logs, Kerberos, certs | temp NTP (Phase 2) → PDCe (Phase 3) |
| Windows golden templates | cloning DCs / PAW / clients | Virtualization prep (207–214; Win11 in 3g) |
| Identity (AD) | AD-backed hardening, AD-DNS, domain joins, the PAW | **Phase 3** |
| Tier groups (`G-Tier*-Admins`) | 7d tier-deny GPOs | Phase 3 (groups) |
| PAW (Tier-0 workstation) | operating Tier-0 safely | Phase 3g |
| Source of truth (NetBox) | generated ACLs, automation | **Phase 4** |
| DHCP on DC01 | painless client/clone addressing | Phase 3h (`ADR-0030`; infra stays static) |
| **AD CS** (DC LDAPS cert) | FGT Pass-2 / service-estate LDAPS / **NPS01 cert** | **pulled forward — `ADR-0027`** (Phase 3b/8) |
| NPS01 (device RADIUS) | Phase-2.5 Pass-2 network-device admin | Phase 5 (gated on AD + AD CS cert) |
| RDS01 (published desktops) | standard users' remote desktops/apps + RD Gateway | after **NPS01** (CAP/RAP) + **AD CS/ICA01** (TLS) + DC → **after Phase 8**; on **PVE02/EQR6** always-on (`ADR-0036`) |
| WAC01 (mgmt gateway) | central Windows-estate management + Arc on-ramp | after **≥1 member server** + **AD CS/ICA01** (TLS) + **PAW01** (`ADR-0045`); on **PVE02/EQR6** always-on, **VLAN 10** |
| SRV01 nginx-CRL | the PKI revocation endpoint (CDP/AIA) | Phase 5 (gates Phase 8 Part 4) |
| Visibility (NetFlow) | writing the deny policy | Phase 6 → Phase 7 |
| Console recovery | making MKT01 policy-critical | Phase 1 → gate for Phase 7 |
| FS01 department shares + AGDLP | the workstation-fleet access proofs | Phase 5 (FS01) → clients gated on it |
| Client workstation fleet | GPO / AGDLP / segmentation / Intune tests | after Phase 3 + FS01 (`ADR-0042`) |
| **PFSENSE01** (pfSense inline IPS) | N-S prevention **behind** FGT01 UTM (defence-in-depth) | **Phase 7** (`ADR-0038` v1.2): **physical 2-NIC transparent bridge** on the FGT01↔1941 transit · **fail-closed** (needs a manual transit-bypass break-glass) · **monitor-only-first** rollout (`ADR-0041`) · **Suricata**; mgmt IP 📋 VLAN 10 |
| **SIEM01/Wazuh** | one security pane (ingest MON01 Suricata + rsyslog, K8) | **Phase 6** — **dedicated host** (operator 2026-07-30); VLAN/sizing → #20 |
| **KALI01** (offensive/validation) | proving each control — the negative test | **cross-cutting** (`ADR-0041`/`ADR-0011`) — VLAN-70 isolated; attack paths opened **per Game Day**; drives `Operations/Validation-and-Adversarial-Testing.md` |
| PVE02 | DC02 / BKP01 / Vaultwarden / PAW redundancy | build gate (`ADR-0036`) — Phase 9 leans on it |
| Entra Connect + Intune + Exchange | cloud-managed estate | **Phase 11** (after 3 + 8) |
| **NETBOX01** (Linux) | generated device configs/ACLs + the rendered IP register (`POL-0004`); GitOps input | **Phase 4** — needs net bring-up + DC01 DNS/time; ICA01 TLS + LDAPS auth later; PVE01/R410 |
| **BKP01 + Vaultwarden** (Linux) | estate recoverability + secrets/CA-passphrase custody | **Phase 9** — needs PVE02 + the 8 TB; DC (system-state) + ICA01 (Vaultwarden TLS); Vaultwarden **before any CA-passphrase handling** (`ADR-0009`); off-site copy mandatory; PVE02/EQR6 |
| **Pi01** (physical Pi) | filtering DNS + NTP (non-domain/infra); `atlas.lab` conditional-forward | **Phase 5** — needs SW01 VLAN 10 + DC01 (forward target); **not** DHCP (→ DC01, `ADR-0030`); bare-metal, VLAN 10 |
| **CNT01** (container host) | the estate self-hosted git/CI + GitOps/CI pipelines | **Phase 10** — needs DC + ICA01; gated on the **#19** estate-capability ADR + placement (#20); hybrid (Linux git/CI on EQR6 + Win slice on R410) |

## Related
- **Per-device order + how:** each `Devices/<host>/Roadmap.md` (the map) + `Build-Guide` / `Build-Guide/` (the gated how, `ADR-0043`).
- **Status / log:** `Build-Progress-Tracker.md`. **Where we are:** `SESSION-HANDOFF.md`. **Design:** `Architecture/Atlas-Service-Architecture.md`.
- **Owners it links to (`POL-0008`):** `Architecture/IP-Addressing-Plan-VLSM.md` (addresses) · `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (flows) · `Decisions/ADR-Index.md` (decisions) · `Operations/Validation-and-Adversarial-Testing.md` (proofs).

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.5 | 2026-07-30 | **Batch C+D:** annotated the **SIEM01/Wazuh** dependency row (dedicated host, K8, → #20) + added a **KALI01** row (cross-cutting validation; VLAN-70 isolated; attack paths per Game Day). |
| 1.4 | 2026-07-30 | Annotated the **PFSENSE01 (pfSense inline IPS)** dependency-map row with the resolved `ADR-0038` v1.2 build sub-decisions — physical 2-NIC transparent bridge · fail-closed (+ manual transit-bypass break-glass) · monitor-only-first rollout · Suricata; mgmt IP 📋 VLAN 10. (Batch C+D — ahead of the PFSENSE01 folder.) |
| 1.3 | 2026-07-30 | **Batch B (Linux service VMs) dependency-map rows** — added **NETBOX01** (Phase 4), **BKP01+Vaultwarden** (Phase 9; Vaultwarden-before-CA-passphrase; off-site mandatory), **Pi01** (Phase 5; not DHCP), **CNT01** (Phase 10; the estate git/CI, gated on the #19 ADR). From the Batch-B replication pass. |
| 1.2 | 2026-07-30 | Added **WAC01** (mgmt gateway) to the dependency map — needs ≥1 member server + AD CS/ICA01 TLS + PAW01 (`ADR-0045`); on PVE02/EQR6, VLAN 10. From the WAC01 replication pass (**Batch A complete**). WSUS01/SQL01 still owe rows. |
| 1.1 | 2026-07-30 | Added **RDS01** to the cross-device dependency map (published desktops — needs **NPS01** CAP/RAP + **AD CS/ICA01** TLS + DC → sequences **after Phase 8**; on **PVE02/EQR6**, `ADR-0036`), from the RDS01 replication pass. 🔎 **Still owed here:** dependency-map rows for **WSUS01 / SQL01** (reconcile as each is next touched). No phase-bullet changes. Added a note that the dependency map is **filled progressively per device** and some content may not be current pending per-device reconciliation (#22). |
| 1.0 | 2026-07-29 | Created (`ADR-0043` / register E2) — **the single estate build-order owner**, consolidating `Master-Build-Order` (plan + gates + dependency cheat-sheet + the five principles) and `Master-Implementation-Checklist` (closed-decisions + decision-free bench phrasing) into one doc. Each phase reduced to **goal · stand-up · 🔴 gate · driving Build-Guides · verify**; the click-steps now live in the per-device gated Build-Guides. Dependency map extended with the machines added since (NPS01, SIEM01, the workstation fleet + FS01 shares, PFSENSE01, KALI01, PVE02, the hybrid hosts). Validation/pen-test recorded as a cross-cutting track. Each phase's **Stand up** laid out as bullets (one per device/action) for bench readability. Both source docs → superseded pointers; tracker → execution log; `Atlas-Service-Architecture` → design + scope banner. |
