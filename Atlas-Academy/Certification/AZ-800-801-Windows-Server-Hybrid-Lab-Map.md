---
Title: AZ-800 / AZ-801 — Windows Server Hybrid → Atlas Cert-Lab-Map (checkable study plan)
Path: Atlas-Academy/Certification
Status: 🟢 LIVING — the cert→lab study plan for the Windows Server Hybrid Administrator pair (`ADR-0044`). Objective rows are **checkable** ([ ] → [x]) as each is proven on a device (`POL-0001`). **Target = AZ-800 + AZ-801** (operator, 2026-07-29); see the **AZ-802 transition** banner.
Version: 2.0
Date: 2026-07-29
Scope: Global
---

# AZ-800 / AZ-801 — Windows Server Hybrid → Atlas Cert-Lab-Map

<!-- provenance -->
> **Purpose (`ADR-0044`).** The real enterprise is the standard; certs **anchor** the skills. This is the **study plan** counterpart to `Atlas-Certification-Lab-Map.md` (CCNA/CCNP): every **AZ-800** + **AZ-801** exam objective mapped to the Atlas host/lab that teaches it, with a **checkbox to tick when you've proven it on a device.** Objective text is transcribed from Microsoft's official *Skills measured* (AZ-800 as of 2026-01-21; AZ-801 as of 2025-10-06) — **validate against the live study guide before you sit** (link in Sources).

> ⏳ **AZ-802 transition (verified 2026-07-29).** **AZ-800 and AZ-801 retire 2026-09-30.** They are replaced by a single **AZ-802 — Administering Windows Server** (beta July 2026, GA ~Aug 2026), which **consolidates both** into 7 skill groups over the *same* on-prem+hybrid content (expanded Arc/Update-Manager, OSConfig/Windows-LAPS/Entra-Password-Protection, SMB-over-QUIC; *reduced* legacy DR/migration). **We target AZ-800/801 while they're active — the skills below carry straight over to AZ-802, so the lab does not change (`ADR-0044`), only the exam label.** If you won't test before 2026-09-30, sit **AZ-802** instead and use this same map (the AZ-802 crosswalk note is in each section).

## 0. How to use + status key

Tick a box only when the objective is **proven on a device** (a command + its output, `POL-0001`) — same discipline as the reconciliation work. A config you didn't verify is a config you didn't learn.

**Status key:** 🟢 **do now** (the Atlas host/role exists or is in the near-term core build) · 🟡 **needs a dependency** (a not-yet-built Atlas host/phase) · 🆕 **new scope** (an AZ-driven machine — `ADR-0045`/`ADR-0046`) · 🔵 **Azure phase (H4)** (needs the cloud subscription; the hybrid half) · ⚪ **theory / read-only** (no hands-on in Atlas).

## 1. Estate at a glance (service map)

The reassuring headline: **most of AZ-800/801 is already the Atlas on-prem core.** Legend ✅ in scope · 🔶 extend a host · 🆕 gap (new machine).

| Exam half | Mostly covered by | The gaps (🆕) |
|---|---|---|
| **AZ-800 core** | DC01/DC02 (AD DS·GPO·DNS·DHCP) · FS01 (file/DFS/FSRM) · NPS01 · home-PC Hyper-V · SRV01 | **WAC01** · **container host** · **RODC+site** · S2D (needs the cluster) |
| **AZ-801 advanced** | DC hardening/LAPS/PSO/Protected-Users · MON01 · BKP01 (backup) · per-device Diagnostics | **2-node failover cluster + S2D** (biggest) · Hyper-V Replica · Storage Migration Service · JEA · most **hybrid** = Azure/H4 |

New machines are committed in **`ADR-0045`** (WAC01 · container host · RODC) + **`ADR-0046`** (failover cluster + S2D); host extensions (FS01 iSCSI/S2D/dedup · DNSSEC · DHCP-failover · JEA) are tracked in the register.

## 2. AZ-800 — Administering Windows Server Hybrid Core Infrastructure

> **AZ-802 crosswalk:** AZ-800 groups 1–5 map to AZ-802 groups *Deploy/manage AD DS · Manage instances/workloads in hybrid · Manage VMs · On-prem+hybrid networking · Storage & file services* (nearly 1:1).

### 2.1 Deploy and manage AD DS on-premises and in cloud (30–35%)

- [ ] **Deploy & manage AD DS domain controllers** (on-prem · in Azure · RODC · FSMO) — DC01/DC02 on-prem ✅ · **RODC 🆕 (`ADR-0045`)** · DC-in-Azure 🔵(H4) · FSMO on DC01 ✅
- [ ] **Configure multi-site/-domain/-forest** (forest+domain trusts · AD DS sites · replication) — MSP forest-trust (Tier-B) 🟡 · **AD sites + RODC 2nd site 🆕** · DC01↔DC02 replication ✅
- [ ] **Create & manage AD DS security principals** (users/groups · multi-domain/forest · service-account type · service accounts/gMSA · join to AD DS/Entra DS/Entra) — OU/GPO + AGDLP ✅ · **gMSA (Tier-A, register C2) 🟡**
- [ ] **Implement & manage hybrid identities** (Entra Connect Sync · Cloud Sync · Entra DS · Connect Health · staged rollout) — **Entra Connect PHS (H1, `ADR-0040`) 🔵**
- [ ] **Manage via domain GPO** (Group Policy · GP Preferences · GP in Entra DS) — DC GPO stack ✅

### 2.2 Manage Windows Servers & workloads in a hybrid environment (10–15%)

- [ ] **Configure remote management** (WAC on-prem+Azure · PS remoting incl. 2nd hop · **JEA** · SSH · RDP) — **WAC01 🆕 (`ADR-0045`)** · PS remoting/SSH/RDP ✅ · **JEA endpoints 🆕 (config, no VM)**
- [ ] **Manage via Azure services** (Arc Connected Machine agent · Machine Config · VM extensions on Arc · Azure Update Manager · Automation runbooks) — WSUS01 on-prem patch ✅ · **Azure Arc/Update Manager 🔵(H4)**

### 2.3 Manage virtual machines and containers (15–20%)

- [ ] **Manage Hyper-V & guest VMs** (enhanced session · nested virt · memory · checkpoints · VM HA · vhd · vSwitch · NIC teaming · DDA/GPU · shielded VMs) — **home-PC Hyper-V (`ADR-0036`) 🟡 (formalize as a lab)**
- [ ] **Create & manage containers** (Windows container host · WSL for Linux containers · images · container networking · AKS on Windows Server) — **container host: SRV01 (Linux/Docker) now / `CNT01` on-demand 🆕 (`ADR-0045`)**
- [ ] **Manage Windows Server VMs on Azure** (storage · scale sets · availability sets/zones · JIT + Bastion · VM networking) — 🔵(H4)

### 2.4 On-premises and hybrid networking infrastructure (15–20%)

- [ ] **Name resolution** (DNS+AD DS · zones/records · forwarding/conditional · Azure DNS integration · DNS policies · **DNSSEC**) — DC01 AD-DNS + Pi01 ✅ · **DNSSEC 🔶** · Azure DNS 🔵
- [ ] **IP addressing** (IPAM · DHCP server role · scopes · reservations · **DHCP HA**) — DC01 DHCP (`ADR-0030`) ✅ · **DHCP failover (register C1) 🔶** · MS IPAM 🔶 (NetBox is the SoT)
- [ ] **Network connectivity** (Remote Access role · Azure Network Adapter · NPS role · **WAP** · **S2S VPN** · Entra Private/App Proxy) — NPS01 ✅ · WAP (ADFS01+WAP01, Tier-B) 🟡 · **S2S VPN from FGT01 🔵(H4)**

### 2.5 Storage and file services (15–20%)

- [ ] **Azure Files** (shares · permissions · **File Sync** · monitor · DFS→File-Sync migrate) — 🔵(H4, FS01↔Azure)
- [ ] **Windows Server file shares** (share access · FSRM · BranchCache · DFS · **SMB over QUIC** · SMB options) — FS01 ✅
- [ ] **Windows Server storage** (disks/volumes · Storage Spaces · **Storage Replica** · **Data Dedup** · SMB Direct · Storage QoS · file systems · **iSCSI**) — FS01 ✅ · **S2D → the cluster (`ADR-0046`)** · iSCSI/dedup = extend FS01 🔶

## 3. AZ-801 — Configuring Windows Server Hybrid Advanced Services

> **AZ-802 crosswalk:** AZ-801's *Secure* + *Monitor/troubleshoot* groups survive nearly whole into AZ-802; **HA/DR/Migration are trimmed** in AZ-802 (still 100% in-scope for AZ-801 and still great enterprise labs).

### 3.1 Secure Windows Server on-premises & hybrid (25–30%)

- [ ] **Secure the OS** (Exploit Protection · WDAC · **Credential Guard** · SmartScreen · security GPOs · **OSConfig baseline** · **Windows LAPS**) — DC GPO/hardening stack ✅ (OSConfig 🔶)
- [ ] **Secure hybrid AD** (password policies · **Entra Password Protection** · **protected users** · **RODC account security** · harden DCs · **auth policy silos** · restrict DC access · AD delegation · **Defender for Identity** · disable NTLM) — tiered-admin + PSO + Protected Users ✅ · auth-policy-silos 🔶 · **RODC 🆕** · Defender-for-Identity 🔵
- [ ] **Remediate via Azure** (Sentinel ingestion · Defender for Cloud · Defender for Servers) — SIEM01/Wazuh (on-prem analog) 🔶 · **Sentinel/Defender 🔵(H4)**
- [ ] **Secure networking** (Defender Firewall · **domain isolation** · connection-security rules · Azure NSGs) — GPO firewall + IPsec isolation ✅ *(this is the `ADR-0042` HR→HR ✓ / HR→IT ✗ segmentation proof)* · NSGs 🔵
- [ ] **Secure storage** (BitLocker · Azure Disk Encryption · recover encrypted volumes · IaaS disk keys) — BitLocker on member servers 🟡 · Azure 🔵

### 3.2 Windows Server high availability (15–20%)

- [ ] **Implement a failover cluster** (on-prem/hybrid/cloud · workgroup cluster · **stretch + S2D** · cluster storage · quorum · Network ATC · Scale-Out File Server · **Azure witness** · floating IP) — **🆕 2-node cluster (`ADR-0046`)**
- [ ] **Manage failover clustering** (cluster-aware updating · recover/upgrade node · failover · updates · **manage via WAC**) — **🆕 (`ADR-0046` + WAC01)**
- [ ] **Implement Storage Spaces Direct** (upgrade node · S2D networking · configure S2D) — **🆕 (`ADR-0046`)**

### 3.3 Disaster recovery (10–15%)

- [ ] **Backup & recovery** (Azure Recovery Services Vault · Azure Backup Server · policies · VM backup/restore · instant recovery) — BKP01 on-prem ✅ · Azure Backup 🔵(H4)
- [ ] **DR via Azure Site Recovery** (network mapping · on-prem+Azure replication · recovery plans) — 🔵(H4)
- [ ] **Hyper-V replicas** (configure hosts · replica servers · VM replication · failover) — **🆕 needs a 2nd Hyper-V host** (home PC + one more)

### 3.4 Migrate servers & workloads (20–25%)

- [ ] **Migrate on-prem storage** (**Storage Migration Service** · cutover · to Azure VMs · to Azure file shares) — **🆕 SMS: migrate a legacy box → FS01**
- [ ] **Migrate via Azure Migrate** (appliance · VM/physical → Azure VMs) — 🔵(H4)
- [ ] **Migrate legacy Windows Server workloads** (IIS · Hyper-V hosts · **RDS** · DHCP · print · in-place upgrade) — 🟡 (a throwaway legacy box; RDS01 in scope)
- [ ] **Migrate IIS to Azure** (assess · Web Apps · containers) — 🔵
- [ ] **Migrate an AD forest to Server 2025** (forest restructure · ADMT objects/GPOs · new forest · functional levels) — 🟡 *(the MSP-sim forest is the sandbox)*

### 3.5 Monitor & troubleshoot (15–20%)

- [ ] **Monitor** (Performance Monitor · Data Collector Sets · **WAC alerts** · System Insights · event logs · Azure Monitor DCRs · VM Insights) — MON01 ✅ · **WAC01 🆕** · Azure Monitor 🔵
- [ ] **Troubleshoot Windows Server** (connectivity · name resolution · Windows Update · **Time Service** · deployment · boot · performance · disk encryption · storage) — per-device `Diagnostics.md` + `Troubleshooting.md` ✅
- [ ] **Troubleshoot Active Directory** (AD recycle bin · **DSRM restore** · SYSVOL · replication · hybrid auth/sync · on-prem AD) — DC `Diagnostics` ✅ · Entra Connect Health (H1) 🔵

## 4. Start now (what the estate already reps — before any new machine)

DC01 is built, so a surprising amount of AZ-800/801 is tickable today:

1. **AD DS DC + FSMO + GPO + AGDLP** (2.1, 2.5-security) — DC01/DC02 are live; re-derive FSMO placement, prove a GPO applies (`gpresult`), prove AGDLP (HR→HR ✓ / HR→IT ✗ once FS01 shares exist).
2. **AD-integrated DNS + DHCP** (2.4) — inspect zones/forwarders on DC01; stand up a scope; then **DNSSEC** on one zone and **DHCP failover** once DC02 is verified (register C1).
3. **DC hardening + LAPS + PSO + Protected Users** (3.1) — already device-verified 2026-07-22; this *is* AZ-801 domain 1. Add **auth policy silos** as the next rep.
4. **Monitoring baseline** (3.5) — MON01 + PerfMon/Data Collector Sets; the SW01-clock and cert incidents are real troubleshooting labs.
5. **Backup** (3.3) — stand up BKP01 and run a restore Game Day (register I2) — the top-risk close *and* an AZ-801 objective.

## 5. Gaps → new scope (surfaced by this sweep)

Committed in ADRs (2026-07-29): **WAC01** (Windows Admin Center gateway — `ADR-0045`) · **container host** (SRV01/`CNT01` — `ADR-0045`) · **RODC + 2nd site** (`ADR-0045`, confirms register C5) · **2-node failover cluster + S2D + witness** (`ADR-0046`, the biggest gap). Extensions (no new VM): FS01 iSCSI/S2D/dedup · DNSSEC · DHCP-failover · JEA. Everything genuinely **hybrid** (Arc · Azure VMs · Entra DS · Azure Files/Sync · Azure Backup/ASR · Azure Monitor · Sentinel · S2S VPN) lands in **Azure phase H4** — the DC guide's H1/H4 stubs already gate it.

## 6. Study method + honest gaps

- **Enterprise-first, cert-labelled** (`ADR-0044`): build the real thing (`301`/`305` justification), then tick the objective. Never build a feature *only* to tick a box.
- **The hybrid half needs Azure.** Roughly every 🔵 row is real only once the H4 subscription exists — until then it's read-only. Budget for a small Azure spend or use a free/credit tenant for the sync + Arc labs.
- **AZ-802 note:** if you slip past 2026-09-30, sit **AZ-802** — the on-prem groups are unchanged; you'd just deprioritise the AZ-801 DR/Migration depth (3.3/3.4) that AZ-802 trims.
- **Depth reference:** the retired **MCSA 70-740/741/742** books map ~1:1 onto the on-prem half (drop Nano Server + 2016-only bits).

## Related
- `Atlas-Certification-Lab-Map.md` (CCNA/CCNP — the sibling study plan) · `Atlas-CCNP-Lab-Map.md` · `Atlas-FortiGate-FCP-Lab-Map.md` · `00-Atlas-Foundation/Roadmap/Atlas-Cert-Objective-Gap-Analysis.md` (Windows identity Tier A/B/C) · `ADR-0044` · `ADR-0045` · `ADR-0046` · `ADR-0036` · `Labs/Lab-02-Cisco-Core/Operations/Build-Order-and-Dependencies.md` (Phase 11 hybrid).
- **Sources (validate against current):** AZ-800 study guide — https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-800 · AZ-801 study guide — https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-801 · AZ-802 (replacement, GA ~Aug 2026) — https://learn.microsoft.com/en-us/credentials/certifications/exams/az-802/

## Change Log
| Version | Date | Change |
|---|---|---|
| 2.0 | 2026-07-29 | **Reshaped into a checkable study plan** (matching `Atlas-Certification-Lab-Map`): every AZ-800 (5 groups) + AZ-801 (5 groups) objective transcribed from Microsoft's *Skills measured* → mapped to the Atlas host/lab + status + a **[ ] checkbox**. Added the status key, an estate-at-a-glance summary, a **start-now** list, and the **AZ-802 transition** banner (AZ-800/801 retire 2026-09-30 → AZ-802; target stays AZ-800/801 per operator; skills carry over). New-scope now cites `ADR-0045`/`ADR-0046`. |
| 1.0 | 2026-07-29 | Created (`ADR-0044`) — first-pass AZ-800 + AZ-801 skill-domain → Atlas service/VM map; flagged the gaps → new scope (WAC01, failover cluster + S2D, container host, RODC, Hyper-V Replica, Storage Migration, JEA, FS01 storage extensions, DNSSEC/DHCP-failover, Azure/H4). |
