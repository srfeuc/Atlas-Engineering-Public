---
Title: DC01 Build Guide (Domain Controller — Tier 0, atlas.lab) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 LIVING (v0.7). 🔴 Per-stage **GATE** headers added (`ADR-0043`). **Stage 9 (cert from ICA01) + H1–H4 hybrid/cloud phases added — 📋 gated stubs.** **GUI-primary + PowerShell.** Windows Server 2025 VM on PVE01, VLAN 20 (`10.20.0.2/26`, gw `10.20.0.1`). Executable companion to `../../Build-Checklist.md`. Every step follows **official Microsoft** procedure. Stages 0–6 **device-verified 2026-07-21** (OUs built). Detail lives in the split-out pages: **`OU-Design-and-Build.md`** (Stage 6), **`GPO-Design-and-Build.md`** (Stage 7), **`Tiered-Admin-and-Groups-Build.md`** + **`../DC02/DC02-Build-Guide.md`** (Stage 8).
Version: 0.9
Date: 2026-07-29
---

# DC01 — Build Guide (Domain Controller, Tier 0)

## How to read this guide
Executable, **living**. Each step gives the **GUI path** first (Server Manager / the AD consoles) and the **PowerShell** equivalent alongside, then a **✅ read-back** that proves it. 🔴 items are the traps that cause rebuilds. **📸 Capture** markers flag the screen or output to screenshot as **rebuild evidence** (`ADR-0037` v1.2, GUI-primary) — **never** capture a live secret (DSRM / LAPS / passwords, `POL-0002`).

## 🔴 The four traps (read first)
1. **Domain name = `atlas.lab`, NOT `atlas.local`/`.corp`.** This box was found promoted to `atlas.local` (wrong per `ADR-0007`; `.local` collides with mDNS). **A wrong domain name is a rebuild, not an edit** — hence Stage 0. ✅ Now on `atlas.lab`.
2. **KDS root key immediately** (Stage 3) — production key has a **~10-hour** propagation delay; forget it and gMSAs fail cryptically later. ✅ created (backdated) 2026-07-21.
3. **Tiered from day one** (Stages 6–8) — `t0-`/`t1-`/standard from the start; retrofitting never happens.
4. **VM time-sync fight** (Stage 5) — the PDC-emulator must take time from an external source, not the hypervisor/CMOS. ✅ set to `time.nist.gov` 2026-07-21.

---

## Gate / pre-flight (verified 2026-07-21)
- ✅ Network: `10.20.0.2/26`, gw `10.20.0.1`, reaches gateway + internet *(unblocked by trusting the PVE01 trunk for DAI on SW01)*. vNIC tagged VLAN 20.
- 🔴 **Patch fully** before/at promotion (a Tier-0 DC must be current — the golden image was under-patched).
- ⏸ NetBox gate is **soft** for promotion — assign the static IP by hand from `IP-Addressing-Plan-VLSM`; NetBox after (agreed DC-early divergence, Rule 13).
- 💡 **Snapshot** `clean-base-<date>` before promoting and `dc-atlaslab-<date>` after it verifies (see the VM Snapshot & Naming Convention standard).

## Stage 0 — 🔴 Demote the wrong forest (`atlas.local`) — ✅ done 2026-07-21

> 🔴 **GATE** — Phase 0 backups verified readable. *Only if this box is the mislabeled `atlas.local` DC* — a clean box skips to Stage 1.
- **GUI:** Server Manager ▸ **Manage ▸ Remove Roles and Features** ▸ your server ▸ uncheck **Active Directory Domain Services** ▸ it prompts to demote ▸ **Demote this domain controller** ▸ tick **Last domain controller in the domain** ▸ set a new local Administrator password ▸ **Demote**. Reboots to a standalone server.
- **PowerShell:**
  ```powershell
  Uninstall-ADDSDomainController -LastDomainControllerInDomain -RemoveApplicationPartitions -Force
  ```
- ✅ After reboot: `Get-ComputerInfo | Select CsName,CsDomain,CsDomainRole` → **WORKGROUP / StandaloneServer**.
- 📸 **Capture:** the demote-complete confirmation (or the `Get-ComputerInfo` output) showing **WORKGROUP / StandaloneServer** — proves the wrong forest (`atlas.local`) is fully gone before you re-promote.

## Stage 1 — Pre-promotion base

> 🔴 **GATE** — Stage 0 ✅ (box is WORKGROUP / StandaloneServer).
- **GUI:** confirm the NIC (Control Panel ▸ Network ▸ adapter): static `10.20.0.2 / 255.255.255.192`, gw `10.20.0.1`, DNS temp `1.1.1.1`. Time zone = Central (taskbar clock ▸ Date/time settings). **Windows Update** ▸ install everything, reboot, repeat until clean.
- **PowerShell:**
  ```powershell
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 1.1.1.1
  Set-TimeZone -Id "Central Standard Time"
  Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10   # confirm fully patched
  ```
- ✅ Workgroup box, correct IP/DNS, CST, **fully patched**.
- 📸 **Capture:** the NIC IPv4 properties (`10.20.0.2/26`, gw `10.20.0.1`) and `Get-HotFix` — proves the base is correctly addressed and fully patched **before** promotion (an under-patched Tier-0 DC is a rebuild risk).

## Stage 2 — Promote the new forest `atlas.lab` — ✅ done 2026-07-21

> 🔴 **GATE** — Stage 1 ✅ (fully patched · static `10.20.0.2/26` · temp DNS `1.1.1.1`) · PVE01 + VLAN-20 reachable.
- **GUI (primary):**
  1. Server Manager ▸ **Manage ▸ Add Roles and Features** ▸ Role-based ▸ select **Active Directory Domain Services** ▸ Add Features ▸ Install.
  2. Click the notification **⚑** ▸ **Promote this server to a domain controller**.
  3. **Deployment Configuration:** *Add a new forest* ▸ Root domain name = **`atlas.lab`**.
  4. **Domain Controller Options:** set Forest/Domain **functional level to the highest offered** (Windows Server 2025; fall back to 2016 if 2025 isn't listed) ▸ keep **DNS server** checked ▸ set a strong **DSRM password** (record offline, `POL-0002`).
  5. **Additional Options:** NetBIOS = **`ATLAS`**. Paths ▸ Review ▸ **Prerequisites Check** ▸ **Install**. Reboots.
- **PowerShell:**
  ```powershell
  Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
  Install-ADDSForest -DomainName "atlas.lab" -DomainNetbiosName "ATLAS" -ForestMode Win2025 -DomainMode Win2025 -InstallDns -Force
  ```
- ✅ `Get-ADDomain | Select DNSRoot,NetBIOSName,DomainMode` → **`atlas.lab` / ATLAS** *(verified 2026-07-21)*. `dcdiag /v` clean; NIC primary DNS auto-set to `127.0.0.1`.
- 📸 **Capture (decision):** the **Deployment Configuration** screen — *Add a new forest*, root domain **`atlas.lab`** — and the **Prerequisites Check = Passed** screen. These two prove the domain name (the #1 rebuild trap) before install. *(Do not capture the DSRM-password screen.)*
- 📸 **Capture (acceptance):** `Get-ADDomain | Select DNSRoot,NetBIOSName,DomainMode` = **`atlas.lab` / ATLAS** — the as-built proof.
- 🔴 Anything but `atlas.lab` → rebuild, not edit.

## Stage 3 — 🔴 KDS root key — ✅ done 2026-07-21 (PowerShell-only; no GUI)

> 🔴 **GATE** — Stage 2 ✅ (domain promoted). The backdate is valid **only** while this is the sole DC.
Single-DC lab → backdate so gMSAs work now instead of after the ~10-hour wait (**only valid with one DC**):
```powershell
Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))
```
- ✅ `Get-KdsRootKey` returns a key; a **4004** event is logged in the KDS event log. *(What it's for: the forest-wide seed every gMSA password derives from — it lives in AD and is backed up with AD system state; you never write it down.)*
- 📸 **Capture:** `Get-KdsRootKey` (a key is returned) + the KDS **4004** event — proves gMSAs will work now instead of after the ~10-hour wait.

## Stage 4 — DNS (AD-integrated) — ✅ done 2026-07-21

> 🔴 **GATE** — Stage 2 ✅ (AD-DNS installed with the role).
- **GUI:** **DNS Manager** (`dnsmgmt.msc`) ▸ right-click the server ▸ **Properties ▸ Forwarders ▸ Edit** ▸ add `1.1.1.1` (Pi-hole takes this over later).
- **PowerShell:** `Add-DnsServerForwarder -IPAddress 1.1.1.1`
- ✅ `Get-DnsClientServerAddress` → self (`127.0.0.1`); `Resolve-DnsName atlas.lab` answers from the DC; external names resolve via the forwarder.
- 📸 **Capture:** the DNS **Forwarders** tab (`1.1.1.1`) and `Resolve-DnsName atlas.lab` answering from the DC — proves AD-DNS resolves internally and forwards externally.

## Stage 5 — 🔴 Time: PDCe authority — ✅ done 2026-07-21 (w32tm; CLI-only, no GUI)

> 🔴 **GATE** — Stage 2 ✅. Do this before any member joins (Kerberos needs domain time).
```powershell
w32tm /config /manualpeerlist:"time.nist.gov,0x8 pool.ntp.org,0x8" /syncfromflags:manual /reliable:yes /update
Restart-Service w32time
w32tm /resync /rediscover
```
- ✅ `w32tm /query /source` → **`time.nist.gov`** (verified), not `Local CMOS Clock`.
- 📸 **Capture:** `w32tm /query /source` = **`time.nist.gov`** — proves the PDCe time trap (trap #4) is closed and the clock is not on CMOS/hypervisor.
- 🔴 If it reverts to a VM/local provider, disable the **Proxmox/QEMU guest-agent time sync** on this VM. Members/DC02 sync from the domain hierarchy, not their own external source.

---

> 🌐 **Domain-scope note.** Stages 6–8 (OU · GPO · tiered identity) are **domain-wide** AD objects **configured on DC01** and replicated to every DC (incl. DC02). They live under `Build-Guide/DC01/` because that is *where they were built* — **not** because they are DC01-local.

## Stage 6 — OU skeleton — ✅ built 2026-07-21 (authoritative page: `OU-Design-and-Build.md`)

> 🔴 **GATE** — Stage 2 ✅. Full detail: `OU-Design-and-Build.md`.
🔴 The full OU design + build — the Microsoft tier-model-aligned tree, the PowerShell script (omits `Marketing` for a GUI exercise), the `redircmp` staging step, and the special-treatment flags — lives in its own page: **`OU-Design-and-Build.md`** (this folder). Build from there; it's the single source, not duplicated here.
- **Load-bearing rules:** role-based, not departmental; **DCs stay in the built-in `Domain Controllers` OU**; 🔴 **root OUs can't be named `Computers`/`Users`** — they collide with the built-in containers (`8305`), so we use **`Devices`/`Employees`**.
- ✅ Skeleton built 07-21: `Admin\Tier 0/1/2` (+Accounts/Groups/Service Accounts/PAW), `Devices`, `Employees`, `Groups`, `Disabled Objects`; `Get-ADOrganizationalUnit -Filter *` matches; DCs still under `Domain Controllers`.

## Stage 7 — Baseline GPOs + PSO + LAPS + tier-deny — 🔄 next (authoritative page: `GPO-Design-and-Build.md`)

> 🔴 **GATE** — Stage 6 ✅ (OUs exist). **7d tier-deny** additionally needs the **Stage-8 tier groups**. Full detail: `GPO-Design-and-Build.md`.
🔴 GPOs get their own page — a full **GPO mental model** (LSDOU precedence, Enforced/Block, loopback, security filtering + the post-2020 Read gotcha, `gpresult`/RSoP) plus the Microsoft-accurate build (Security-Baseline import via GPMC, Finance/HR PSO via ADAC, Windows LAPS, and the **tier-deny logon GPOs** that actually *enforce* the tier OUs): **`GPO-Design-and-Build.md`** (this folder). Do this stage from there.
- **Order (before creating users/computers):** base GPOs → PSO → LAPS → tier-deny.
- 🔴🔴 Never link a **deny-all-logon** GPO at the domain root (can lock out even the built-in Administrator). Scope by OU + group; keep a break-glass out of scope; test each with `gpresult`.

## Stage 8 — Groups (AGDLP), tiered accounts, DC02 — 📋 authored (authoritative pages: `Tiered-Admin-and-Groups-Build.md` + `DC02-Build-Guide.md`)

> 🔴 **GATE** — Stage 6 ✅ (OUs). Order: groups (Part 2) → accounts (Part 3) → then 7d. Full detail: `Tiered-Admin-and-Groups-Build.md` + `DC02-Build-Guide.md`.
🔴 Stage 8 has its own pages now (single source, POL-0008) — build from them, not from this pointer:
- **`Tiered-Admin-and-Groups-Build.md`** — AGDLP model + the tier admin groups `G-Tier0/1/2-Admins` (the 7d prerequisite), the tiered accounts (`t0-seth`→`Admin\Tier 0\Accounts`; `t1-seth`→`Admin\Tier 1\Accounts`; standard `seth`, `ADR-0024`), **getting off the built-in Administrator**, and Protected Users.
- **`DC02-Build-Guide.md`** — the second DC as a *replica* (`10.20.0.3`): promote (Add a DC to an existing domain, **not** a new forest), `DOMHIER` time, DNS steady-state, and the `repadmin`/`dcdiag` replication verify.
- ✅ **Part 2 (groups) + Part 3 (accounts · off-built-in-Admin · Protected Users) device-verified 07-22** (`Tiered-Admin-and-Groups-Build.md`). Remaining: DC02 promotion (🟡 read-back pending) + the tiered-LAPS read test (needs a member server).

---

## Stage 9 — 🔐 Certificate application: LDAPS / Kerberos-Auth cert from ICA01 (autoenrollment) — 📋 gated on the PKI

> 🔴 **GATE** — do not start until the **AD CS ceremony is complete** (RCA01 root signed ICA01 · ICA01 issuing + `certsvc` started) · the **Kerberos Authentication** template is **published + hardened** on ICA01 with *Domain Controllers* granted **Enroll + Autoenroll** · **CRL/AIA reachable** at `http://pki.atlas.lab/pki/` (SRV01) · the **revocation acceptance gate passed** (`ADR-0009`) · DC promoted (Stage 2 ✅). *CA-side detail is owned by the AD-CS guide (`RCA01-ICA01-ADCS/AD-CS-Two-Tier-Build-Guide.md` Part 3) — verify it, don't rebuild it here.*

**Why (enterprise + cert lens).** The DC needs an enterprise cert so **LDAPS (636)** works — the prerequisite for FGT01 admin auth (`ADR-0028`), secure LDAP for the service estate (`ADR-0021`), and later Kerberos **PKINIT** / smart-card logon. The Microsoft-current template is **Kerberos Authentication** (supersedes *Domain Controller* / *Domain Controller Authentication*). Both DCs auto-enrol their **own** cert via one GPO on the Domain Controllers OU. *Cert-anchored:* **AZ-801** (AD CS / hybrid PKI) · 70-742 Ch8 · Security+ (PKI).

### Steps (DC-side; the CA-side template publish is owned by the AD-CS guide)
1. **Confirm the CA prerequisites** (verify — the AD-CS guide built them):
   - ICA01 issuing ✅; **Kerberos Authentication** template published, *Domain Controllers* = Enroll+Autoenroll.
   - **ICA01 in the NTAuth store:** `certutil -viewstore -enterprise NTAuth` shows *Atlas Issuing CA*.
   - **RCA01 root** in Trusted Root (domain-distributed via GPO); **CRL** reachable (`curl -I http://pki.atlas.lab/pki/...crl` = 200).
   - 📸 **Capture:** `certutil -viewstore -enterprise NTAuth` = ICA01 present — proves DCs trust CA-issued auth certs.
2. **Enable certificate autoenrollment (GPO).** GPMC → an autoenroll policy linked to the **Domain Controllers** OU → Computer Config ▸ Policies ▸ Windows Settings ▸ Security Settings ▸ **Public Key Policies** ▸ **Certificate Services Client – Auto-Enrollment** = **Enabled** + tick *Renew expired / update / remove revoked*.
   - 📸 **Capture:** the Auto-Enrollment policy = Enabled + the GPO linked to *Domain Controllers*.
3. **Force enrolment on the DC:** `gpupdate /force` → `certutil -pulse`.
4. 🎯 **Verify the cert issued (acceptance):** `Get-ChildItem Cert:\LocalMachine\My | ? {$_.EnhancedKeyUsageList -match 'Kerberos'}` → a cert with EKUs **KDC Authentication · Server Auth · Client Auth · Smart-Card Logon**, **Issuer = Atlas Issuing CA (ICA01)**.
   - 📸 **Capture:** the cert **Details** — EKU list + Issuer = ICA01 + a valid chain to RCA01.
5. 🎯 **Verify LDAPS actually works (the point):** `ldp.exe` ▸ Connect ▸ `dc01.atlas.lab` port **636**, **SSL** ✔ → bind succeeds; `Test-NetConnection dc01.atlas.lab -Port 636`.
   - 📸 **Capture:** `ldp.exe` bound on **636/SSL** — proves LDAPS is live (unblocks `ADR-0028`).
6. 🎯 **Verify chain + revocation:** `certutil -verify -urlfetch <thumbprint>` → chain DC → ICA01 → RCA01, **CRL check = OK** (the `ADR-0009` revocation gate).

### Unblocks
FGT01 admin **LDAPS** (`ADR-0028`) · secure LDAP for the service estate (NetBox/Grafana/Proxmox/Vaultwarden, `ADR-0021`) · the NPS01 PEAP server-cert path · later Kerberos **PKINIT** / smart-card logon.

> **DC02:** same GPO, its own cert — DC02 auto-enrols when it applies the Domain Controllers autoenroll policy; verify with steps 4–6 against `dc02.atlas.lab`.

## Hybrid & cloud phases (H1–H4) — 📋 gated stubs (designed now; full click-steps when the tenant/hardware exists)

> These extend the on-prem identity core into Microsoft cloud management (`ADR-0039` scope). Each is **fenced by a 🔴 GATE** and **owned by its own future device folder** — the DC's role throughout is the **on-prem anchor** the cloud extends from. Designed per `ADR-0044` (real enterprise pattern + cert anchor), **not** placeholders; the exact portal clicks are written when the phase is reached.

### H1 — Hybrid identity: Entra Connect (PHS)
> 🔴 **GATE** — on-prem core solid (DC healthy · LDAPS live, Stage 9) · an **Entra ID tenant** · external connectivity · a **sync host** (a domain-joined member server — *not* the DC; future `Devices/ENTRACONNECT01/`). Method = **PHS** (`ADR-0040`).
- **Design:** install **Entra Connect** on the member server → **Password Hash Sync** → **scope the sync** (Employees OUs only; **exclude Tier-0 admin + service accounts**) → **Seamless SSO** → verify (`Get-ADSyncScheduler` + Entra portal → Users). Cloud auth then **survives an on-prem outage** (`ADR-0040`).
- **DC's role:** the source directory; a least-priv sync account; DNS. **Unblocks:** H2, Conditional Access. **Certs:** AZ-800/801 · MS-102 · SC-300.

### H2 — Cloud endpoint management: Intune (co-management)
> 🔴 **GATE** — H1 done · Entra P1 / Intune licences · the **workstation fleet** exists (`ADR-0042`: WS-HR01 / WS-ENG01 / LT-SALES01 / WS-IT01).
- **Design:** **hybrid Entra join** the fleet (via Entra Connect device sync) → enrol in **Intune** → **co-management** (move workloads GPO→Intune deliberately) → **compliance policies** + **configuration profiles** + **Defender for Endpoint**; **Autopilot** for the LT-SALES01 laptop.
- **DC's role:** the hybrid-join anchor + the GPO half of co-management. **Owned by:** the workstation-fleet folder. **Certs:** MD-102 · MS-102 · AZ-801.

### H3 — Messaging: Exchange (on-prem → EXO hybrid)
> 🔴 **GATE** — DC/AD + DNS + **a cert from ICA01** (the Stage-9 pattern) · a host (**`Devices/EXCH01-Exchange/`**) · for hybrid: the tenant + EXO licences.
- **Design:** build **EXCH01** (AD schema extension · mailboxes · mail flow · connectors) → the **Hybrid Configuration Wizard** → **EXO hybrid** (shared namespace · mailbox moves). Proper SAN cert + autodiscover DNS.
- **DC's role:** AD schema + identity + DNS; the cert pattern from Stage 9. **Owned by:** EXCH01. **Certs:** MS-102.

### H4 — Azure IaaS + site-to-site
> 🔴 **GATE** — H1 (hybrid identity) · an **Azure subscription** · FGT01 (for the VPN).
- **Design:** Azure **VNet** + **S2S VPN from FGT01** (IPsec) → an Azure VM → **Azure Arc** onboarding the on-prem servers → **Azure Backup / Monitor**.
- **DC's role:** the on-prem anchor Azure extends from (hybrid identity · Arc). **Certs:** AZ-104 · AZ-801 · CCNP (cloud networking).

## Validation — read the state back

> 📸 Each read-back below is the DC's **acceptance evidence** — capture the command + output; the screenshots land in `../../Build-Record.md` / `../../Diagnostics-DC01.md`. Stage 6/7/8 captures live in their authoritative pages (`OU-`/`GPO-Design-and-Build.md`, `Tiered-Admin-and-Groups-Build.md`).
- [x] `Get-ADDomain | Select DNSRoot,NetBIOSName,DomainMode` → **`atlas.lab`** ✅ 2026-07-21.
- [x] `Get-KdsRootKey` → present (KDS 4004 event) ✅ 2026-07-21.
- [x] `w32tm /query /source` → external source (`time.nist.gov`) ✅ 2026-07-21.
- [ ] `Get-ADOrganizationalUnit -Filter *` matches the Stage-6 tree; DCs still under `Domain Controllers`.
- [ ] `dcdiag /v` clean; `repadmin /replsummary` (once DC02 exists).
- [ ] `gpresult /h` on a member → baseline + LAPS applied; `Test-ADServiceAccount <gmsa>` → True.
- [ ] 🔴 **Flagship test:** a Tier-2/helpdesk account **cannot** touch a Tier-0 object — capture the AD failure.

## Failure modes
- 🔴 **`atlas.local`/`.corp`/single-label** — wrong name = **rebuild**, not edit. `.local` collides with mDNS. Verify `Get-ADDomain` right after.
- 🔴 **KDS key forgotten / 10-hour delay ignored** — gMSAs fail later. Backdate only in a one-DC lab.
- 🔴 **Functional level left at the `Win2008R2` default** (PowerShell path) — set it explicitly.
- 🔴 **Built flat, "tier later"** — never happens. Tier from day one.
- 🔴 **PDCe time from hypervisor/CMOS** — Kerberos/replication break. External source; verify `w32tm /query /source`.
- 🔴 **DCs moved out of the `Domain Controllers` OU** — default DC GPO stops applying.
- 🔴 **New computers land in the default `Computers` container** (can't link a GPO there) — set `redircmp` to `Devices\Staging`.
- 🔴 **Root OU named `Computers`/`Users`** → `8305 "name already in use"` (collides with the built-in containers). Use `Devices`/`Employees` (or a top org OU).
- 🔴 **Promoted under-patched** — patch first.
- **Single DC** — build DC02.

## Related
- `../../Build-Checklist.md` · `../../Troubleshooting.md` (this device) · `IP-Addressing-Plan-VLSM` (`10.20.0.2`) · `Master-Build-Order` Phase 3 (+ Phase 2.5) · `303`/`301` · `ADR-0007/0020/0021/0025` · `VM Snapshot & Naming Convention`.

## Sources
**Official Microsoft Learn**
- Install AD DS / promote: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-
- Install-ADDSForest: https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest
- KDS root key: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-managed-service-accounts/group-managed-service-accounts/create-the-key-distribution-services-kds-root-key
- PDCe time / w32tm: https://learn.microsoft.com/en-us/services-hub/unified/health/remediation-steps-ad/configure-the-root-pdc-with-an-authoritative-time-source-and-avoid-widespread-time-skew
- Windows LAPS (AD): https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory
- AD DS Tier Model: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/tier-model
- Reviewing OU Design Concepts: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/reviewing-ou-design-concepts
- Creating an OU Design: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/creating-an-organizational-unit-design
- Enterprise Access Model: https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-access-model

**Microsoft AD Tier Model (the repo — authoritative OU/GPO/delegation structure)**
- GitHub repo: https://github.com/microsoft/ActiveDirectoryTierModel
- Deployment site: https://microsoft.github.io/ActiveDirectoryTierModel/
- Quick Deployment Guide: https://microsoft.github.io/ActiveDirectoryTierModel/quick-deployment-guide/
- Detailed Deployment Guide: https://microsoft.github.io/ActiveDirectoryTierModel/detailed-deployment-guide/

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.6 | 2026-07-29 | **Added 📸 Capture markers** (`ADR-0037` v1.2) at the name/confirmation/acceptance screens — demote (WORKGROUP), pre-promotion NIC+patch, the Deployment-Configuration `atlas.lab` + Prerequisites-Check screens, `Get-ADDomain`, KDS 4004, DNS forwarder + resolve, `w32tm` source — with an explicit *never capture a secret* rule (DSRM/LAPS). Validation note added. Header → v0.6. |
| 0.9 | 2026-07-29 | **H1–H4 hybrid/cloud phases added** as *designed* gated stubs (`ADR-0043`/`ADR-0044`) — Entra Connect (PHS) · Intune co-management · Exchange→EXO hybrid · Azure IaaS+S2S — each with its 🔴 GATE, enterprise design, owning future device folder, and cert anchor. Finishes the DC as the copy-me template. |
| 0.8 | 2026-07-29 | **Stage 9 — Certificate application (from ICA01)** added (the `ADR-0043` standard cert section): DC LDAPS/Kerberos-Auth cert via **autoenrollment**, gated on the AD CS ceremony + revocation gate; DC-side steps + 📸 + LDAPS(636) verify; CA-side linked to the AD-CS guide. Added a **domain-scope note** on Stages 6–8; Stage-8 accounts **reconciled ✅ 07-22**. |
| 0.7 | 2026-07-29 | **Per-stage 🔴 GATE headers** added to every stage (`ADR-0043`). |
| 0.1 | 2026-07-21 | Created — PowerShell-first, Microsoft-Learn-grounded (demote → promote atlas.lab → KDS → DNS → PDCe time; OU/GPO/LAPS/tiering/DC02 outlined). |
| 0.2 | 2026-07-21 | **Reworked GUI-primary + PowerShell** (per preference). Marked **Stages 0/2/3/5 device-verified** — demote, `atlas.lab` promoted, KDS key, PDCe time. Added GUI paths, pre-promotion patch reminder, snapshot checkpoints. |
| 0.3 | 2026-07-21 | Stage 4 marked done (forwarder). **OU skeleton built on the device** and split into its own authoritative page **`OU-Design-and-Build.md`** — Stage 6 here is now a pointer (single source, no drift). Microsoft tier-model-aligned; 🔴 reserved-name fix learned on the box: root OUs `Computers`/`Users` collide with the built-in containers (`8305`) → renamed to **`Devices`/`Employees`** (LAPS path + failure mode updated to match). Added the **Microsoft AD Tier Model repo** links to Sources. `Master-Build-Order` ref updated to Phase 3 (DC re-sequenced). |
| 0.5 | 2026-07-22 | **Stage 8 split into its own pages** — `Tiered-Admin-and-Groups-Build.md` (AGDLP tier groups + tiered accounts + off-built-in-Admin) and `DC02-Build-Guide.md` (replica DC). Stage 8 here is now a pointer (single source, POL-0008). 📋 both authored 07-22, not yet executed. Header → v0.5. |
| 0.4 | 2026-07-21 | **Stage 7 split into `GPO-Design-and-Build.md`** — a GPO *mental-model* page (LSDOU precedence, Enforced/Block, loopback, security filtering + post-2020 Read gotcha, `gpresult`/RSoP) + the Microsoft-accurate build (SCT baseline import via GPMC, Finance/HR PSO via ADAC, Windows LAPS, tier-deny logon GPOs). Stage 7 here is now a pointer. Header → v0.4 (Stages 0–6 device-verified). |
