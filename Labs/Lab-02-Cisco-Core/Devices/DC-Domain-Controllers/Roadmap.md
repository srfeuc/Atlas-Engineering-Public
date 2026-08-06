---
Title: DC01/DC02 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟢 LIVING roadmap — the per-role build path for the Tier-0 identity core + what each role depends on and unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`); this page is the map, the checklist is the line-item record.
Version: 1.2
Date: 2026-07-29
---

# DC01 / DC02 — Roadmap (build path + connections)

> **How to read this.** Each row is a **role or stage** on the identity core. The checkbox is its status — **dated** and evidence-backed (the record is `Build-Checklist.md`). **Needs** = what must be healthy first; **Unblocks** = what can proceed once it's done. This is the sequence *and* the dependency graph on one page.

## The build path (in order)

### DC01 — the forest
- [x] **2026-07-21 — Promote `atlas.lab`** (new forest/domain, `ADR-0007`). *Needs:* PVE01 + VLAN-20 reachability + a working clock. *Unblocks:* everything below. → `Build-Guide/DC01/DC01-Build-Guide.md`.
- [x] **2026-07-21 — KDS root key.** *Needs:* the domain. *Unblocks:* **gMSA** (SQL01 / service accounts) later.
- [x] **2026-07-21 — OU skeleton** (role-based; `Devices`/`Employees` rename). → `Build-Guide/DC01/OU-Design-and-Build.md`.
- [x] **2026-07-21 — AD-integrated DNS** (forwarder `1.1.1.1` interim). *Unblocks:* domain-join for every host; the Pi01 conditional-forward.
- [x] **2026-07-21 — PDCe time authority** → `time.nist.gov` (`ADR-0020`). *Unblocks:* Kerberos/replication health for all members.

### Policy baseline (before populating objects)
- [x] **2026-07-21 — GPO 7a:** MS Server 2025 baseline + Wave-A links (8 purpose-scoped GPOs). → `Build-Guide/DC01/GPO-Design-and-Build.md`.
- [x] **2026-07-22 — GPO 7b:** Finance/HR PSO (`PSO-FinanceHR`).
- [x] **2026-07-22 — GPO 7c:** Windows LAPS (+ DSRM-via-LAPS → `POL-0002` retired).
- [ ] ⬜ **GPO Wave B** (VBS / Credential Guard) — *gated on* a Proxmox `msinfo32` VBS check (the hypervisor must expose the CPU features). Academy concept **W4**.
- [ ] 🔴 ⬜ **GPO 7d — tier-deny logon rights** (five cross-tier denials). *Needs:* the tier groups (below). *Unblocks:* the flagship "Tier-2 can't touch Tier-0" proof.

### Identity population
- [x] **2026-07-22 — AGDLP tier groups** (`G-Tier0/1/2-Admins`, `G-IT-Staff`) — device-verified. → `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` Part 2.
- [x] **2026-07-22 — Tier accounts** — `t0-seth` / `t1-seth` / `seth` created; off the built-in Administrator; Protected Users — ✅ device-verified 07-22 (`Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` Part 3). *Unblocks:* 7d enforcement + the adversarial tests.
- [ ] 📋 **gMSA service accounts** (`svc-gmsa-*`). *Needs:* KDS (done). *Unblocks:* SQL01, service hosts.
- [ ] 📋 **Populate from AtlasHR (SQL→AD)** — the real name-mess pipeline (`301`).

### DHCP + the second DC
- [ ] ⬜ **DHCP on DC01** (`ADR-0030`) — scopes per `IP-Addressing-Plan-VLSM`; OT gets none. *Unblocks:* the client VLANs; DC01/DC02 failover later.
- [ ] 🟡 **DC02 replica** — operator-reported promoted 2026-07-28; **read-back pending** (`repadmin /replsummary` = 0 · `dcdiag` · `Get-ADDomainController DC02`). Flips to ✅ at the bench. → `Build-Guide/DC02/DC02-Build-Guide.md`.

### Certificate application (from ICA01)
- [ ] 📋 **DC LDAPS / Kerberos-Auth cert** — autoenrol the **Kerberos Authentication** template from ICA01 (GPO → Domain Controllers OU). *Needs:* AD CS ceremony complete + CRL published (SRV01) + revocation gate passed. *Unblocks:* **LDAPS 636** → FGT01 admin auth (`ADR-0028`), service-estate secure LDAP, later PKINIT/smart-card. → `Build-Guide/DC01/DC01-Build-Guide.md` Stage 9. *Cert:* AZ-801 · 70-742 Ch8.

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PVE01 → SW01 → MKT01 (gw `10.20.0.1`) | VLAN-20 reachability |
| ⬆ Depends on | External NTP (`time.nist.gov`) | PDCe upstream clock (`ADR-0020`) |
| ⬆ Depends on | ICA01 (AD CS) | LDAPS cert (auto-enroll) |
| ⬇ Serves | SRV01 · NPS01 · MON01 · FS01 · WSUS01 · SQL01 · RDS01 · PAW01 · ICA01 · DC02 | domain-join · DNS · GPO · time |
| ⬇ Serves | NPS01 (RADIUS) · FGT01 (LDAPS `ADR-0028`) · RDS01 (gateway) | authentication vs AD |
| ⬇ Serves | FS01 (AGDLP shares) · SQL01 (gMSA / Win-auth) | authorization / service identity |

## Certification alignment (learning lens)

> **Why this is here.** Atlas's goal is a realistic enterprise that also **ticks certification objectives** — so each role notes the exam objective it exercises. Estate-wide cert mapping lives in `Atlas-Academy/Atlas-Certification-Lab-Map.md` (CCNA/CCNP) + `00-Atlas-Foundation/Roadmap/Atlas-Cert-Objective-Gap-Analysis.md` (Windows identity); this table is the DC's slice.

| DC role / stage | Exercises (exam objective) | Cert |
|---|---|---|
| Promote forest · FSMO · AD-DNS | AD DS install, forest/domain, FSMO placement | AZ-802 · 70-742 Ch1/6 |
| PDCe = NTP authority | Time hierarchy, `w32time` | AZ-802 · CCNA IP-services |
| OU + AGDLP groups | OU design, group scoping (AGDLP) | 70-742 Ch2 |
| GPO baseline / PSO / LAPS | GPO precedence, PSO, LAPS, **GP depth (gap-analysis A3)** | 70-742 Ch4/5 · AZ-802 |
| KDS + gMSA | Managed service accounts, **Kerberos delegation (A1)** | 70-742 Ch3 · AZ-802 |
| Tier-0 · deny-logon · Protected Users | Tiered admin, privileged access | security fundamentals · SC-300-adjacent |
| DHCP on DC01 | DHCP scopes, failover, relay | AZ-802 · CCNA IP-services |
| DC02 replica · (future) 2nd site | Replication, sites, **RODC (B2)** | 70-742 Ch6/7 · AZ-802 |

## Future — hybrid & cloud (later phases)

> **Where the cloud/growth work lands.** These are **later phases** (after the on-prem core is solid); each becomes its own `Devices/`-style unit + `Roadmap.md` when built. They live here because they **extend the identity core** — this is "replicate the DC to the cloud + add Entra + Intune." Estate-level detail: `00-Atlas-Foundation/Roadmap/Atlas-Roadmap-Advanced-Scenarios.md` (the Azure phase).

- [ ] 📋 **Phase H1 — Hybrid identity (Entra Connect).** Sync `atlas.lab` → an **Entra ID tenant** with **Entra Connect** (the "DC replicated to the cloud"): **PHS** as the primary auth method (`ADR-0040` — cloud auth survives an on-prem outage; AD FS is built separately as a federation lab, *not* the sign-in path), **Entra hybrid join**, seamless SSO. *Needs:* DC healthy + external connectivity + a tenant. *Unblocks:* Intune, cloud auth, Conditional Access. *Certs:* **AZ-802** (hybrid) · **AZ-104** · **SC-300**.
- [ ] 📋 **Phase H2 — Cloud endpoint management (Intune).** Enroll **Entra-/hybrid-joined** devices in **Intune** (MDM/MAM); compliance + configuration profiles; **co-management** with GPO. *Needs:* H1. *Certs:* **MD-102** · **MS-102**.
- [ ] 📋 **Phase H3 — Messaging (Exchange).** Build an **Exchange Server** (on-prem, AD-integrated) and/or **Exchange Online hybrid**: mail flow, the AD schema extension, a cert from **ICA01**. *Needs:* DC/AD + DNS + PKI. *Certs:* **MS-102** (messaging/hybrid). *Own home:* a future `Devices/EXCH01-Exchange/`.
- [ ] 📋 **Phase H4 — Azure IaaS + site-to-site.** Extend to Azure resources + an **S2S VPN** from FGT01 (the CCNP / AZ-104 cloud-networking scenario). *Certs:* **AZ-104** · CCNP.

> All four are also tracked estate-wide; when built, each gets its own device folder + Roadmap and links back here. The DC's role throughout is **the on-prem anchor the cloud extends from.**

## Related
- Line-item status + evidence: `Build-Checklist.md`. Front door: `README.md`. Open risks: `Considerations.md`.
- Estate index (cross-device status): `../../Service-Server-Build-Plan.md`.
- Cert mapping: `Atlas-Academy/Atlas-Certification-Lab-Map.md` · `00-Atlas-Foundation/Roadmap/Atlas-Cert-Objective-Gap-Analysis.md` · future/cloud detail: `00-Atlas-Foundation/Roadmap/Atlas-Roadmap-Advanced-Scenarios.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.2 | 2026-07-29. **Trued up Phase H1 to `ADR-0040`** — the Entra Connect sign-in method is *decided* (**PHS**), no longer an open PHS/PTA/federation choice; AD FS noted as a separate federation lab. Audit consolidation. |
| 1.1 | 2026-07-29. Added the **Certification alignment** table (DC roles → exam objectives → CCNA/AZ-802/70-742/SC-300, linking the estate cert docs) and the **Future — hybrid & cloud** phases (**H1** Entra Connect / hybrid identity · **H2** Intune · **H3** Exchange · **H4** Azure IaaS + S2S), each with Needs/Unblocks + cert tags. Delivers the operator's 'extend the roadmap with cert paths + future state' ask on the exemplar. |
| 1.0 | 2026-07-29. Created — per-role build path + connections for the Tier-0 identity core (README = front-door). |
