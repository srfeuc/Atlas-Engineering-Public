---
Title: Lab-02 — Service-Server Build Plan
Path: Labs/Lab-02-Cisco-Core
Status: 🟢 Planning — the service tier, per host, ready to build. Sequenced against Master-Build-Order v1.6; placement per ADR-0036. Verify each with the SoT Evidence Run-Sheet + the per-device Diagnostics.md.
Version: 1.9
Date: 2026-07-30
---

# Lab-02 — Service-Server Build Plan

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build).** The estate's **service tier** turned into an actionable per-host plan — OS, address, physical host (`ADR-0036`), the services it runs, its dependencies, the build outline, and the acceptance read-back. Companion to `Master-Implementation-Checklist.md` (the sequence) and the per-device `Diagnostics.md` (verify).

> **Marker convention (`ADR-0032`):** ✅ device-verified · 🟡 operator-reported / lab-unverified · ⏳ in build · 📋 planned. Nothing ✅ without a read-back (`POL-0001`).

## Rule — this is the single source (Lab-01 `006-Network-Source-of-Truth` pattern)

> **This plan is the authoritative reference for the estate's _hosts, roles, physical-host placement, VM sizing, and build status_.** Update it **first** when any of those change; the other planning docs — `Master-Build-Order`, `Master-Implementation-Checklist`, `Build-Progress-Tracker` — **summarize and link here, they do not duplicate these tables** (register `E1`; `POL-0008`, reduce where a fact lives). **Addressing is the one carve-out:** its single source is `Architecture/IP-Addressing-Plan-VLSM.md` → **NetBox** once loaded — the IPs here are _proposed pointers_, not authoritative.
>
> 🔑 **Placement + sizing authority (settled in the #20 sweep, operator 2026-07-30).** This plan's **Physical host** column and the **EQR6 RAM budget** below are the estate's **interim single source for _which physical host each VM runs on and how big it is_**, until **NetBox** renders it (Phase 4). **`ADR-0036` states the placement _principle_** (tier-by-uptime, blast-radius) **and the initial split; this table is where the per-VM decision is recorded and kept current** — when the two disagree, the disagreement is a drift to reconcile *to `ADR-0036`'s principle*, not a second opinion. **`00-Atlas-Foundation/VM-and-Services-Inventory.md` is RETIRED** (PVE01-only, generic names) — it is *not* a placement or sizing source; do not reconcile to it.

## Estate at a glance (placement per `ADR-0036`)

> 🖥️ **Hypervisor host page-sets (`#21`, 2026-07-30):** **`Devices/PVE01-Hypervisor/`** (Dell R410 — spin-up heavy tier) · **`Devices/PVE02-Hypervisor/`** (Beelink EQR6 — always-on critical tier). The **Physical host** column below points at these two; each host folder's Services map lists the VMs it runs and links **back here** — this plan stays the placement/sizing authority (`POL-0008`).

| Host | OS | Addr / VLAN | Physical host | Services | Status |
|---|---|---|---|---|---|
| **DC01** | Win Svr 2025 | `10.20.0.2` / 20 T0 | **PVE02/EQR6** (`ADR-0036` v1.2; off the R410 — no `CM-0012` CMOS risk, operator 2026-07-30) | AD DS, AD-DNS, **DHCP** (`ADR-0030`), PDCe/NTP authority | ✅ promoted (host move pending) |
| **DC02** | Win Svr 2025 | `10.20.0.3` / 20 T0 | **PVE01/R410** (spin-up **cold-standby** — DCs on *different physical hosts*, `ADR-0036` v1.2 principle 1; #20-reconciled 2026-07-30) | replica DC/GC/DNS; DHCP failover later | 🟡 read-back pending |
| **ICA01** | Win Svr 2025 | `10.20.0.4` / 20 T0 | **PVE02/EQR6** (always-on Tier-0 CA — off the R410 with DC01, `ADR-0036` v1.2; #20-reconciled 2026-07-30) | AD CS enterprise issuing CA (+ **OCSP + KRA**, Tier-A) | ⏳ CA install next |
| **RCA01** | Win Svr (GUI) | offline | host-agnostic (off) | AD CS offline root | ⏳ ceremony gates PKI |
| **SRV01** | **Ubuntu 26.04** | `10.20.0.10` / 20 | **PVE02/EQR6** (always-on — the CRL/AIA endpoint `pki.atlas.lab` must stay reachable for revocation, `ADR-0036` v1.2; #20-reconciled 2026-07-30) | nginx CRL/AIA (`pki.atlas.lab`), Oxidized, TFTP/SFTP, rsyslog relay | 📋 guide authored |
| **NETBOX01** | **Ubuntu 26.04** | `10.20.0.11` / 20 | PVE01 | NetBox IPAM/DCIM — the source of truth | 🟡 net up; service unbuilt · **page-set ✅** (Standard v1.6, `Roles/`) |
| **NPS01** | Win Svr 2025 | `10.20.0.12` / 20 | **PVE02/EQR6** (always-on) | Windows NPS (RADIUS) for MKT01/SW01/1941 | 📋 not built · **page-set ✅** (Standard v1.4) |
| **BKP01** | Proxmox Backup Server | `10.20.0.18` / 20 *(proposed)* | **PVE02/EQR6** (8 TB datastore) | PBS backups + **Vaultwarden** (`ADR-0031`/A3a) | 📋 not built · **page-set ✅** (Standard v1.6, `Roles/`) |
| **Vaultwarden** | on BKP01 | `10.20.0.13` (web) | **PVE02** (via BKP01) | secrets vault; AD CS cert; `ADR-0009` custody | 📋 relocation · **page-set ✅** (via BKP01 `Roles/Vaultwarden/`) |
| **MON01** | Debian | VLAN 40 (LibreNMS `.20`, Grafana `.30`) | **split** (EQR6 probe + R410 heavy, `ADR-0036` v1.2) | rsyslog, SNMPv3/LibreNMS, NetFlow, **Suricata IDS** (the SPAN tap), Grafana, Uptime-Kuma | 📋 not built · **page-set ✅** (Standard v1.4) |
| **Pi01** | RPi OS | VLAN 10 `10.10.0.6/27` *(proposed)* | Raspberry Pi (physical) | Pi-hole DNS + chrony NTP **only** | 📋 rebuild · **page-set ✅** (Standard v1.6, flat) |
| **PAW01** | Win 11 | **`10.10.0.8` / 10 (mgmt)** | **PVE02/EQR6** (🟡 RAM-swing) | Tier-0 admin workstation (RSAT) + the Win11 golden image | 📋 not built · **page-set ✅** (Standard v1.4) · **VLAN 10 #20-decided** (off the T0 carve; admin path from mgmt only, flows #23) |
| **FS01** | Win Svr 2025 | `10.20.0.14` / 20 *(proposed)* | **PVE02/EQR6** (data on the 8 TB) | SMB shares, **DFS/DFSR**, FSRM quotas, VSS | 📋 not built · **page-set ✅** (Standard v1.4) |
| **WSUS01** | Win Svr 2025 | `10.20.0.15` / 20 *(proposed)* | **PVE01/R410** (spin-up) | Windows Update Services (patch rings, target groups) | 📋 not built · **page-set ✅** (Standard v1.4) |
| **SQL01** | Win Svr 2025 + SQL | `10.20.0.16` / 20 *(proposed)* | **PVE01/R410** (spin-up; AG replica) | SQL Server — app DBs, **gMSA**, TLS from ICA01 | 📋 not built · **page-set ✅** (Standard v1.4) |
| **RDS01** | Win Svr 2025 | `10.20.0.17` / 20 *(proposed)* | **PVE02/EQR6** (always-on) | RD Session Host/Gateway — **NPS01** CAP/RAP, ICA01 TLS | 📋 not built · **page-set ✅** (Standard v1.5) |
| **WAC01** | Win Svr 2025 | `10.10.0.5` / **10 (mgmt)** *(proposed)* | **PVE02/EQR6** (always-on) | Windows Admin Center gateway — Tier-0 mgmt surface (PAW-only, ICA01 TLS); Azure Arc on-ramp (`ADR-0045`) | 📋 not built · **page-set ✅** (Standard v1.6) |
| **SIEM01** | Ubuntu/Debian | **`10.40.0.11` / 40** *(proposed)* | **dedicated host** (**16 GB** indexer; spin-up tier w/ MON01 heavy) | **Wazuh** host SIEM/XDR (FIM/SCA/vuln; ingests MON01 Suricata+rsyslog, K8) | 📋 not built · **page-set ✅** (v1.7; **VLAN 40 + `.11` + 16 GB #20-decided**) |
| **CNT01** | Hybrid (Linux Docker/Podman + Win-container slice) | `10.20.0.19` / 20 *(proposed)* | **PVE02/EQR6** (Linux git/CI) + PVE01/R410 (Win slice) | Container host — **estate self-hosted git/CI** (Gitea/GitLab + runner; GitOps; Backlog #19; `ADR-0045`/`ADR-0048`) | 📋 not built · **page-set ✅** (gated stub, Standard v1.6) |
| **PFSENSE01** | pfSense + Suricata | mgmt `10.10.0.x` / 10 *(proposed)* | **physical 2-NIC appliance** (`ADR-0038` D2a) | inline IPS — transparent bridge on the FGT01↔1941 transit (fail-closed · monitor-first) | 📋 not built · **page-set ✅** (gated stub, v1.7) |
| **KALI01** | Kali Linux | `10.70.0.5` / 70 *(proposed)* | PVE01/R410 (spin-up) | offensive / validation host — drives the adversarial-testing matrix (VLAN-70 isolated) | 📋 not built · **page-set ✅** (Standard v1.7) |

> 🔴 **OS drift to fix while building:** SRV01 & NETBOX01 build-**guides** say **Ubuntu 26.04**; their **checklists** still say Debian — the guides win, fix the checklists. MON01 stays Debian. The generic `VM-and-Services-Inventory` names (CA01/FS01/WS01) are **retired in favour of NetBox** — don't reconcile to them. **Wave-B update (2026-07-29):** that caution was about the *old generic inventory doc* — **FS01, WSUS01, SQL01, RDS01, and SIEM01 (Wazuh) are now explicitly committed roles** (placement in the table above; stub homes under `Devices/`). NetBox stays the SoT for addressing; the generic inventory doc stays retired.

## EQR6 (PVE02) always-on RAM budget — the #20 sizing pass

`ADR-0036` v1.2 made **64 GB a hard prerequisite** and sized the *core* always-on stack at ~28–30 GB. Since then the index put **RDS01, WAC01, and PAW01** on the always-on tier too, so the budget is re-run here (this table is the sizing owner, `POL-0008`). Figures are planning estimates (right-size at build, `POL-0001`); Vaultwarden rides BKP01 (its RAM is inside BKP01's line).

| Always-on VM (EQR6) | Planned RAM | Note |
|---|---:|---|
| Proxmox host overhead | ~4 GB | reserve before allocating |
| DC01 | 6 GB | right-size to 4 once promoted |
| ICA01 (issuing CA) | 4 GB | #20-reconciled to EQR6 |
| NPS01 (RADIUS) | 3 GB | light |
| SRV01 (nginx CRL/Oxidized/rsyslog) | 2 GB | #20-reconciled to EQR6 |
| BKP01 (PBS, incl. Vaultwarden) | 5 GB | 4 PBS + ~1 Vaultwarden |
| FS01 (SMB/DFS) | 4 GB | data on the 8 TB |
| MON01 **light probe** (Uptime-Kuma + minimal syslog) | 2 GB | heavy stack is on the R410 |
| **Core always-on subtotal** | **~30 GB** | matches the `ADR-0036` estimate |
| RDS01 (RD Session Host/Gateway) | 6 GB | 🔎 the flagged one — grows under real session load |
| WAC01 (Admin Center gateway) | 4 GB | |
| PAW01 (Tier-0 workstation) | 4 GB | 🟡 RAM-swing |
| **Full always-on subtotal** | **~44 GB** | |

**Verdict:** **64 GB comfortably holds the full always-on set (~44 GB), leaving ~20 GB headroom** — so RDS01 + WAC01 + PAW01 *can* stay always-on on the EQR6 as the index has them; the `ADR-0036` 64 GB prerequisite stands and covers the expanded list. **The swing candidates** (move to the R410 spin-up tier only if a heavy always-on session squeezes RAM) are, in order: **PAW01** (can spin up with the R410 when doing Tier-0 work), then **RDS01** (heaviest, but user-facing availability argues for keeping it up). This resolves the open "RDS01 RAM on the always-on EQR6" question: **it fits.**

> 🔴 **Single-8 TB SPOF (blast radius → carry into Phase 9 build):** FS01 shares **and** the BKP01 datastore **and** Vaultwarden's backing store all live on **one external USB drive on one host (EQR6)**. If that drive dies you lose file shares, the backup datastore, *and* the vault's store at once. Two mitigations: (1) the **mandatory encrypted off-site copy** (`ADR-0009`) is the real recovery guarantee and is **non-negotiable + must be restore-tested** (the never-run Game Day, `POL-0005`); (2) strongly consider putting the **BKP01 datastore on a dedicated 2nd NVMe** (`ADR-0036` already flags adding one) rather than sharing the 8 TB with FS01 — separates the backup failure domain from the file-share one. Recorded for the BKP01/Phase-9 build.

## CNT01 sizing (provisional — platform choice is the #19 ADR's to make)

The hybrid container host splits across both hypervisors: a **Linux git/CI slice on the EQR6** (Gitea + a CI runner ≈ **4 GB / 2 vCPU**; GitLab would be ≈ 8 GB) and a **Windows-container slice on the R410 spin-up tier** (≈ **6 GB / 2 vCPU**). Whether the Linux git/CI slice runs **always-on** (to accept pushes / run GitOps pipelines) or **spin-up**, and **Gitea-vs-GitLab**, is owned by the **still-owed #19 estate-capability ADR** (self-host-vs-GitHub · GitOps model · runner placement) — not pre-empted here. **Budget check:** if the Linux slice runs always-on at ~4 GB (Gitea), the EQR6 always-on total rises ~44 → **~48 GB**, still comfortably within the 64 GB prerequisite; GitLab (~8 GB always-on) reaches ~52 GB — also fine. Either way **64 GB holds it.** KALI01 (spin-up, R410) is unaffected. This closes the #20 sizing residual; the platform/always-on call rides with #19.

## Build order & dependency chain

The critical path today is **PKI**, then the source of truth, then the rest:

```
RCA01 ceremony → ICA01 CA → SRV01 (CRL host) → DC LDAPS cert → revocation gate (Part 4)
                                                      ↓
   NetBox (SoT) → NPS01 (needs ICA01 cert for PEAP) → MON01 (visibility) → Pi01 (DNS/NTP)
                                                      ↓
        BKP01+Vaultwarden (before CA-passphrase handling) → PAW01 → segmentation (Phase 7)
```

## Per-host build outline (what to actually do)

### SRV01 — Ubuntu services box (the CRL host is on the PKI critical path)
- [ ] Clone `TPL-UBUNTU2604` → cloud-init identity `10.20.0.10` (static, VLAN 20).
- [ ] **nginx** serving `http://pki.atlas.lab/pki/` (root+issuing `.crt`/`.crl`) — AD-CS **Part 2.7** depends on this; add the `pki.atlas.lab` DNS A record on DC01.
- [ ] **Oxidized** (network-device config backup: MKT01/SW01/1941/FGT01) + **rsyslog** relay (→ MON01 when up) + **TFTP/SFTP**.
- [ ] Fix the **checklist OS** (Debian→Ubuntu). 🎯 Accept: `curl -I http://pki.atlas.lab/pki/` = 200; Oxidized pulls a device config.

### NETBOX01 — the source of truth (build early, Phase 4)
- [ ] Service install on the reachable VM (`10.20.0.11`): NetBox v4.6.5 + Postgres 16 + Redis 7 (guide authored).
- [ ] **Load the SoT data** from `NetBox-Data-Load-Prep.md` (devices, interfaces, IPs, prefixes, VLANs, cables — sourced from `IP-Addressing-Plan-VLSM` + `Cabling-and-Port-Map`).
- [ ] Wire the outputs: **SW01 `STATIC-HOSTS`/DAI ACL rendered *from* NetBox** (`POL-0004`); `006`-style tables become exports. 🎯 Accept: NetBox renders the IP register; a device/interface/cable round-trips.

### NPS01 — RADIUS (expand the stub → full guide + checklist)
- [ ] Reuse a spare Win VM → rename `NPS01` → domain-join → `OU=Servers,OU=Devices` (`10.20.0.12`).
- [ ] `Install-WindowsFeature NPAS` → **register in AD** (RAS-and-IAS-Servers group).
- [ ] RADIUS **clients** = MKT01/SW01/1941 (shared secrets → Vaultwarden, `POL-0002`); **network policies** map AD group → device privilege, deny-by-default.
- [ ] **Server cert** from ICA01 (RAS-and-IAS-Server template — AD-CS §3.5) for PEAP/EAP-TLS; PAP works without it.
- [ ] LAPS on NPS01 (the deferred **member-server LAPS test**). 🎯 Accept: one real **device→NPS login** end-to-end (closes RADIUS-never-device-tested).

### BKP01 + Vaultwarden — recovery-critical (→ PVE02)
- [ ] Stand up **Proxmox Backup Server**; add PVE01 as a backup source; schedule jobs; **off-site copy** (`Device-Backup-Runbook`).
- [ ] **Vaultwarden** standalone (web console), TLS cert from **ICA01**, DB restore. 🔴 Stand it up **before** any CA-passphrase handling (`ADR-0009`).
- [ ] 🔴 **Resolve the master-password recovery path** (open `049` ADR question) before trusting it as the vault.
- [ ] 🎯 Accept: a **test VM restore** from PBS succeeds (the never-run "restore Game Day"); Vaultwarden reachable, cert trusted.

### MON01 — visibility (Phase 6; also the IDS now that FGT has no UTM)
- [ ] Debian VM on VLAN 40; **LibreNMS** (`.20`) SNMPv3 polling all devices; **Grafana** (`.30`); **rsyslog** collector; **NetFlow** (fills the allowed-flows-matrix evidence); **Suricata** on the **SW01 `Gi1/0/5` SPAN** — the estate IDS (`ADR-0035`: FGT has no UTM); Uptime-Kuma.
- [ ] Turn on SNMPv3 + syslog **on every device** (the deferred "Phase 6" items across the CIS docs). 🎯 Accept: a device appears in LibreNMS; a deny shows in Grafana with a correct timestamp.

### Pi01 — DNS + NTP only (rebuild reduced)
- [ ] Rebuild the Pi as **Pi-hole DNS + chrony NTP only** (the other 3 services removed per its checklist); VLAN 10. 🎯 Accept: resolves + serves time; nothing else listening.

### PAW01 — Tier-0 workstation (→ PVE02)
- [ ] Finish the Win11 golden image → sysprep `/generalize /oobe /shutdown` → template → clone/join/harden → RSAT. **Tagged VLAN**, not native. 🎯 Accept: `t0-seth` administers DC01/ICA01 *only* from here.

## Wave-B committed roles (2026-07-29) — file · patch · SQL · RDS · SIEM

Five roles were **committed to build** (operator decision 2026-07-29); each has a **stub home** under `Devices/` (move-alongside-devices, register `E1`). The full build outline + acceptance live in each stub — **not restated here** (`POL-0008`); this is the sequence + the one dependency that gates each.

- **FS01 — File Services** (`Devices/FS01-File-Services/`). SMB + **DFS/DFSR** + FSRM + VSS. *Gate:* DCs up (AGDLP groups) + **BKP01** (never run a file server without a restore-tested backup). *Slots:* after the DC/member baseline.
- **WSUS01 — Patch management** (`Devices/WSUS01-Patch-Management/`). Update rings + target groups by OU. *Gate:* DC01 + a WSUS **GPO** + FGT egress to Microsoft. *Slots:* once members exist to patch.
- **SQL01 — SQL Server** (`Devices/SQL01-Database/`). App DBs, Windows-auth, **gMSA** service account (**Tier-A A1**), TLS from ICA01. *Gate:* DC + ICA01 cert; **A1 gMSA** is the tie-in. *Slots:* with/after the DC + AD CS.
- **RDS01 — Remote Desktop** (`Devices/RDS01-Remote-Desktop/`). Session host/gateway; **RD Gateway CAP/RAP on NPS01**; TLS from ICA01; **not** the Tier-0 path. *Gate:* **NPS01 + ICA01** both built. *Slots:* after NPS01.
- **SIEM01 — Wazuh** (`Devices/SIEM01-Wazuh/`). Host SIEM/XDR (FIM/SCA/vuln); **complements** MON01's network Suricata (`ADR-0035`) and ingests it. *Gate:* MON01 + agent rollout; **co-locate-vs-dedicated is an open flag**. *Slots:* after MON01.

> 📋 **Deferred (in the estate, no commitment this cycle — operator decision 2026-07-29):** **TrueNAS** (dedicated NAS/storage appliance — revisit only if PVE/BKP01 storage proves insufficient). **PBS01** is **not** a separate host: it is the product name for **BKP01** (Proxmox Backup Server), already in the estate above — no second entity to build. **pfSense IDS/IPS** *(future — operator raised 2026-07-29)*: a security appliance to add **at some point** to close the estate's **prevention gap**. Today's IDS is **Suricata on the SW01 SPAN** (MON01, `ADR-0035`) — **passive: it detects, it cannot drop.** pfSense running Suricata/Snort **inline** adds the *prevent* half (true **IPS**). 'Inline' is now **decided** (`ADR-0038`): a **transparent inline IPS on the FGT01↔1941 north-south transit** — it fills the FGT-no-UTM prevention gap and stays coherent with MON01-Suricata + SIEM01-Wazuh (detection) and MKT01 (E-W policy). Future build; own host **PFSENSE01**.

## Tier-A learning extensions folded in (gap analysis, committed)
- **A1 gMSA + Kerberos delegation** — after DC/members exist (KDS root key already present): run one service under a **gMSA**; demo constrained vs **RBCD** delegation. Precursor to AD FS.
- **A2 OCSP Online Responder + KRA** — extends **ICA01**: add an OCSP responder (role service) + a Key Recovery Agent template. Lands as a new **Part** in the AD-CS guide; continues the `ADR-0009` revocation theme.
- **A3 GPO depth** — loopback processing, WMI filtering, the **ADMX central store**, GPO backup/restore, RSoP/modeling — exercised on the DCs + a member/client.

## Related
- `Master-Implementation-Checklist.md` (the sequence) · `SoT-Evidence-Run-Sheet.md` (prove current state) · `Devices/NETBOX01-Source-of-Truth/NetBox-Data-Load-Prep.md`.
- `ADR-0036` (host placement) · `ADR-0030` (DHCP→DC01) · `ADR-0029` (NPS01) · `ADR-0031`/A3a (Vaultwarden) · `ADR-0035` (FGT no-UTM) · `Master-Build-Order.md` (phases).

## Change Log
| Version | Changes |
|---|---|
| 1.9 | 2026-07-30 (`#21`). **PVE01/PVE02 as `Devices/` — added the hypervisor front-door pointer** above the estate table: `Devices/PVE01-Hypervisor/` (R410 spin-up) + `Devices/PVE02-Hypervisor/` (EQR6 always-on) now carry the host page-sets, and their Services maps link back to this plan as the placement/sizing authority (`POL-0008`). No placement/sizing values changed (this stays the #20 authority). |
| 1.8 | 2026-07-30. **#20 close-out (CNT01 sizing + last address).** Added the **CNT01 sizing** section (Linux git/CI slice ~4 GB/2 vCPU on the EQR6 [Gitea; GitLab ~8 GB] + Windows-container slice ~6 GB/2 vCPU on the R410; always-on-vs-spin-up + Gitea-vs-GitLab deferred to the #19 ADR) with the budget check (64 GB still holds the always-on set even with the Linux slice always-on). Firmed **KALI01 -> `10.70.0.5`** (VLAN 70). **#20 is now fully closed** bar the #19-owned platform detail; next is #21 (PVE01/PVE02 as `Devices/`), its own session. |
| 1.7 | 2026-07-30. **#20 address-deconflict decisions (operator).** **PAW01 → VLAN 10 `10.10.0.8`** (off the VLAN-20 Tier-0 carve — admin surface on the mgmt plane with WAC01; Tier-0 admin path is MGMT→IDENTITY only, flows-matrix #23). **SIEM01 → `10.40.0.11` / VLAN 40, dedicated host, 16 GB** OpenSearch indexer. (Also firmed in the IP plan v1.10: SW01 mgmt `.2`, PFSENSE01 `.7`, the full VLAN-10 static map; Pi01 DNS/NTP MGMT-ingress resolved as a scoped exception, flows #19.) Host placement unchanged by this pass. |
| 1.6 | 2026-07-30. **#20 compute-placement + sizing reconciliation (operator).** Declared this plan the **interim single source for physical-host placement _and_ VM sizing** (until NetBox); `ADR-0036` states the principle, this table records the per-VM decision; **`VM-and-Services-Inventory` marked RETIRED** (not a placement/sizing source). **Reconciled 3 host cells to `ADR-0036` v1.2:** **DC02 → PVE01/R410** (cold-standby — DCs on different physical hosts, principle 1; the index had it on PVE02, co-locating both DCs), **ICA01 → PVE02/EQR6** (was PVE01), **SRV01 → PVE02/EQR6** (was PVE01 — CRL/AIA must stay reachable). Added the **EQR6 always-on RAM budget** (verdict: 64 GB holds the full ~44 GB always-on set incl. RDS01/WAC01/PAW01, ~20 GB headroom — resolves the RDS01-RAM question) + the **single-8 TB SPOF** blast-radius note (off-site copy mandatory + restore-test; consider a dedicated 2nd NVMe for the BKP01 datastore). |
| 1.5 | 2026-07-30. **DC01 → PVE02/EQR6** (operator — off the R410, no `CM-0012` CMOS risk; aligns `ADR-0036` v1.2). **Batch C+D security devices:** added **PFSENSE01** (inline IPS; mgmt VLAN 10 proposed) + **KALI01** (offensive/validation; VLAN 70 proposed) rows; **SIEM01** → dedicated-host DECIDED + page-set ✅ (v1.7), VLAN/sizing → #20. (Networking devices 1941/SW01/MKT01/FGT01 tracked in the IP plan/cabling + their folders; page-sets ✅.) |
| 1.4 | 2026-07-30. **Batch B (Linux service VMs) — page-sets ✅ + CNT01 row.** Flipped **NETBOX01** (page-set + `Roles/`), **BKP01** + **Vaultwarden** (page-set + `Roles/`; BKP01 addr `10.20.0.18` proposed), **Pi01** (page-set, flat; addr `10.10.0.6` proposed) to page-set ✅; added a **CNT01** row (container host — estate self-hosted git/CI #19; hybrid; `ADR-0045`; gated-stub page-set ✅; `10.20.0.19` proposed). Addresses proposed — authoritative in the IP plan (`POL-0008`). Batch B folders complete. |
| 1.3 | 2026-07-30. **WAC01 added + page-set ✅** (replication Batch A, from `ADR-0045`). New estate row — Windows Admin Center gateway, **PVE02/EQR6 always-on**, **VLAN 10 (mgmt)** `10.10.0.5` *(proposed)*, Tier-0 mgmt surface (PAW-only, ICA01 TLS), Arc on-ramp. Full page-set under `Devices/WAC01-Windows-Admin-Center/`. **Batch A COMPLETE** (RDS01 + WAC01 done). |
| 1.2 | 2026-07-30. **RDS01 page-set ✅** (replication Batch A). Status flipped *committed — stub → not built · page-set ✅ (Standard v1.5)*; full page-set authored under `Devices/RDS01-Remote-Desktop/` (README+Mermaid · Roadmap · Considerations · Build-Checklist · Build-Guide · Build-Record · Diagnostics · Troubleshooting · Changes/ · Automation/). Address still **proposed** (`POL-0008`; now in the IP-plan register). **Placement decided → PVE02/EQR6 always-on** (operator 2026-07-30; RAM sizing → #20); **RD Gateway/Web included**; VLAN **20** confirmed (client-reached service workload). |
| 1.1 | 2026-07-29. **Wave-B estate decision folded in (register `E1`).** Added the five **operator-committed roles** — **FS01** (file/DFS), **WSUS01** (patch), **SQL01** (SQL Server), **RDS01** (Remote Desktop), **SIEM01/Wazuh** (host SIEM) — to the estate table + a new *Wave-B committed roles* section, each pointing to a new **stub home** under `Devices/` (move-alongside-devices). Recorded **deferred** items (**TrueNAS**; **PBS01 = BKP01**, not a separate host). Amended the retired-names caution: those roles are now explicitly committed. Addresses proposed only — authoritative in the IP plan / NetBox (`POL-0008`). |
| 1.0 | 2026-07-28. Created. The service tier as a per-host build plan (SRV01, NETBOX01, NPS01, BKP01+Vaultwarden, MON01, Pi01, PAW01) with OS/addr/**physical-host placement (`ADR-0036`)**/services/deps/build-outline/acceptance; the PKI→SoT→services dependency chain; the OS drift (Debian→Ubuntu) + retire-VM-inventory notes; and the Tier-A gap-analysis extensions (gMSA/delegation, OCSP+KRA, GPO depth) folded in at their phase points. |
