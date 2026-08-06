---
Title: DC02 Build Guide (Replica Domain Controller — Tier 0, atlas.lab) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 LIVING (v0.2). 🔴 Per-stage **GATE** headers added (`ADR-0043`). **GUI-primary + PowerShell.** Windows Server 2025 VM on PVE01, VLAN 20 (`10.20.0.3/26`, gw `10.20.0.1`). The **second** DC — a *replica* added to the existing `atlas.lab` domain (NOT a new forest). 📋 **Authored 2026-07-22 — NOT yet device-executed (POL-0001).** Companion to `../DC01/DC01-Build-Guide.md`; this is the single source for DC02 (the Stage-8 doc's Part 4 points here).
Version: 0.2
Date: 2026-07-22
---

# DC02 — Build Guide (Replica Domain Controller, Tier 0)

## How to read this guide
Executable, **living**, same shape as `../DC01/DC01-Build-Guide.md`: each step gives the **GUI path** first (Server Manager / the AD consoles) then the **PowerShell** equivalent, then a **read-back** that proves it. 📸 = screenshot point (muscle-memory + evidence). 🔴 = the traps that cause rebuilds. **Nothing here is ✅ yet** — every read-back is `[ ]` until Seth runs it on the device and reports back.

## Why a second DC (and what it does *not* buy you)
A 156-person company on one DC is not a credible design (`301`) — one reboot, patch, or disk fault and **nobody can authenticate**. DC02 gives you redundancy for logon/Kerberos, a second **Global Catalog**, and a second AD-DNS server. 🔴 **What it is NOT: a backup.** Replication faithfully copies *deletions* too — fat-finger a delete and it's gone on both within minutes. AD Recycle Bin, DSRM, and system-state backup are still your recovery story; DC02 is *availability*, not *recoverability*.

## 🔴 The five traps specific to a replica DC (read first)
1. **It's a *replica*, not a forest.** Use **"Add a domain controller to an existing domain"** / `Install-ADDSDomainController` — **never** `Install-ADDSForest`. Promoting a second forest by mistake gives you two islands that never talk.
2. **DNS chicken-and-egg.** During promotion DC02's NIC DNS must point at **DC01 (`10.20.0.2`)**, or it can't find the domain to join. *After* replication is healthy, flip to **itself primary, DC01 secondary** (steady-state). Leaving it pointed only at itself creates a **DNS island**.
3. **Time comes from the domain, not the wire.** DC02 is **not** the PDC-emulator — it must sync **`DOMHIER`** (the domain hierarchy → the PDCe/DC01), **never** an external NTP source and **never** the hypervisor/CMOS. This is the *inverse* of DC01's config. Disable the Proxmox/QEMU guest time-sync here too.
4. **FSMO stays put (know where it lives).** A new replica holds **no** FSMO roles — all five remain on DC01. That's fine. 🔴 Don't *seize* roles (`seize` is for a dead DC only); if you ever want to *move* one, **transfer** it gracefully. Document that all 5 FSMO live on DC01.
5. **DC02 inherits Tier-0 policy the instant it lands in `Domain Controllers`.** It's auto-placed in the built-in `Domain Controllers` OU → it immediately gets the **MSFT DC baseline**, **Defender AV**, and **`LAPS-DC-DSRM`** GPOs. That's desired — but it means the same **Wave-B VBS** caveat applies (the DC-VBS GPO is still gated on the Proxmox `msinfo32` check). **Never move DC02 out of `Domain Controllers`.**

---

## Gate / pre-flight
- [ ] 🔴 **DC01 is healthy first.** Don't add a replica to a sick domain. On DC01: `dcdiag /v` clean, `Get-ADDomain` = `atlas.lab`, DNS answering. Fix anything red before starting.
- [ ] **Promotion credential = a Domain Admin.** Recommended: **`t0-seth`** (Stage 8 Part 3) once it exists — this is real Tier-0 work. If DC02 is built *before* the tiered accounts, the built-in Administrator is the bootstrap; either way it must be a Domain Admin.
- [ ] **VM exists on PVE01** — Windows Server 2025 from the golden template (`../../../../Virtualization/` guides 213 Clone → 214 Deploy). Same build discipline as DC01.
- [ ] 🔴 **Patch fully** before promotion (a Tier-0 DC must be current — the golden image was under-patched; that bit us on DC01).
- [ ] ⏸ NetBox gate is **soft** — assign the static IP by hand from `IP-Addressing-Plan-VLSM`.
- [ ] 💡 **Snapshot** `clean-base-<date>` before promoting, `dc02-atlaslab-<date>` after it verifies (VM Snapshot & Naming Convention standard).

## Stage 1 — Pre-promotion base (workgroup box)

> 🔴 **GATE** — DC01 healthy (`atlas.lab` promoted) · a patched WORKGROUP Win-Svr-2025 box on VLAN 20 (`10.20.0.3`).
- **GUI:** NIC (Control Panel ▸ Network ▸ adapter): static **`10.20.0.3 / 255.255.255.192`**, gw **`10.20.0.1`**, **DNS = `10.20.0.2` (DC01)** — 🔴 *not* itself, *not* `1.1.1.1`. vNIC tagged **VLAN 20**. Time zone Central. **Windows Update** → install all, reboot, repeat until clean. Rename the computer to **`DC02`** and reboot **before** promotion. 📸 the NIC + the rename.
- **PowerShell:**
  ```powershell
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.20.0.2   # DC01 first
  Set-TimeZone -Id "Central Standard Time"
  Rename-Computer -NewName "DC02" -Restart
  # after reboot, confirm fully patched:
  Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10
  ```
- [ ] Read-back: workgroup box named `DC02`, IP `10.20.0.3`, **DNS points at DC01**, CST, fully patched, reaches DC01 (`Test-NetConnection 10.20.0.2 -Port 389`).

## Stage 2 — Promote DC02 as a replica of `atlas.lab`

> 🔴 **GATE** — DC01 reachable + AD-DNS answering · this box's NIC DNS → **DC01** during promotion · 🔴 **replica** (`Install-ADDSDomainController`, never `Install-ADDSForest`).
- **GUI (primary):**
  1. Server Manager ▸ **Manage ▸ Add Roles and Features** ▸ Role-based ▸ **Active Directory Domain Services** ▸ Add Features ▸ Install (no reboot needed yet). 📸
  2. Click the notification **⚑** ▸ **Promote this server to a domain controller**. 📸
  3. **Deployment Configuration:** 🔴 **Add a domain controller to an existing domain** ▸ Domain = **`atlas.lab`** ▸ **Change…** ▸ supply **`ATLAS\t0-seth`** (or the built-in Administrator during bootstrap). 📸
  4. **Domain Controller Options:** ✅ **DNS server**, ✅ **Global Catalog**, Site = **`Default-First-Site-Name`**. Set a strong **DSRM password** — 🔴 it'll be **LAPS-managed** the moment DC02 lands in the `Domain Controllers` OU (the `LAPS-DC-DSRM` GPO already targets it), so set a good one now and let LAPS take over; retrieve later with `Get-LapsADPassword -Identity DC02`. 📸
  5. **Additional Options:** **Replicate from** = `DC01.atlas.lab` (or "Any domain controller"). Paths default. 📸
  6. **Review** ▸ **Prerequisites Check** ▸ **Install**. Auto-reboots. 📸
- **PowerShell (alongside — run on DC02):**
  ```powershell
  Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
  Import-Module ADDSDeployment
  Install-ADDSDomainController `
    -DomainName "atlas.lab" `
    -Credential (Get-Credential "ATLAS\t0-seth") `
    -InstallDns `
    -SiteName "Default-First-Site-Name" `
    -ReplicationSourceDC "DC01.atlas.lab" `
    -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM pw for DC02") `
    -NoGlobalCatalog:$false -Force
  # auto-reboots
  ```
- [ ] Read-back after reboot: `Get-ADDomainController -Identity DC02 | Select Name,Domain,IsGlobalCatalog,Site` → `DC02` / `atlas.lab` / GC True. 🔴 `Get-ADForest | Select Domains` still shows a **single** domain (you did NOT create a second forest).

## Stage 3 — 🔴 Time: DC02 syncs from the domain hierarchy (NOT external)

> 🔴 **GATE** — Stage 2 ✅ (promoted). DC02 takes time from the **domain hierarchy**, not an external source.
DC01 (the PDCe) is authoritative; DC02 must take time from it, not from `time.nist.gov` and not from CMOS.
```powershell
w32tm /config /syncfromflags:DOMHIER /update
Restart-Service w32time
w32tm /resync /rediscover
```
- [ ] Read-back: `w32tm /query /source` → **DC01** (a domain peer), *not* `time.nist.gov`, *not* `Local CMOS Clock`.
- 🔴 If it drifts to a VM/local provider, **disable the Proxmox/QEMU guest-agent time sync** on this VM (same trap as DC01, opposite target).

## Stage 4 — DNS steady-state (only AFTER replication is confirmed in Stage 5)

> 🔴 **GATE** — Stage 5 replication confirmed **first** (this stage is intentionally after Stage 5).
Once Stage 5 shows healthy replication, flip DC02's resolver to the standard replica pattern and add the forwarder DC01 uses.
- **GUI:** NIC ▸ DNS ▸ **Preferred = `127.0.0.1`**, **Alternate = `10.20.0.2` (DC01)**. DNS Manager ▸ Forwarders ▸ add `1.1.1.1` (Pi-hole later, same as DC01).
- **PowerShell:**
  ```powershell
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1,10.20.0.2
  Add-DnsServerForwarder -IPAddress 1.1.1.1
  ```
- [ ] Read-back: `Resolve-DnsName atlas.lab` answers locally from DC02; external names resolve via the forwarder. 🔴 Don't do this before Stage 5 — a replica pointed only at itself before it has replicated the zone is the classic **DNS island**.

## Stage 5 — 🔴 Verify replication (the entire point of DC02 — `repadmin` is finally meaningful)

> 🔴 **GATE** — Stage 2 ✅. Acceptance gate for DC02: `repadmin /replsummary` = 0 failures + `dcdiag`.
```powershell
# health of both DCs:
dcdiag /v
# replication summary — both DCs, 0 failures, small deltas:
repadmin /replsummary
repadmin /showrepl                       # per-partition, both directions
# force a sync and confirm objects flow both ways:
repadmin /syncall /AdeP
# GC + DNS + SYSVOL/DFSR:
Get-ADDomainController -Filter * | Select Name, IPv4Address, Site, IsGlobalCatalog
dcdiag /test:DNS /s:DC02
dcdiag /test:SysVolCheck /test:Advertising /s:DC02
```
- [ ] `repadmin /replsummary` → DC01 ↔ DC02, **0 failures**, largest delta minutes not hours.
- [ ] `dcdiag /v` clean on **both** (a couple of benign warnings on a brand-new DC are OK — read them, don't ignore them).
- [ ] `Get-ADDomainController -Filter *` lists **both** DCs, both **GC**, both in `Default-First-Site-Name`.
- [ ] **SYSVOL replicating** (DFSR): `\\atlas.lab\SYSVOL` resolves and both DCs advertise. `dcdiag /test:SysVolCheck` passes.
- [ ] **Object-flow proof:** create a throwaway OU on DC01, confirm it appears on DC02 within a refresh (then delete it) — the tangible "replication works" demo. 📸

## Stage 6 — Post-promotion housekeeping

> 🔴 **GATE** — Stage 5 ✅ (replication healthy).
- [ ] **FSMO map recorded** — confirm all five stayed on DC01 (this is fine for a two-DC single-site): `netdom query fsmo`. 🔴 Leave them on DC01 for now; if you later *practice* a transfer (a good AZ-802 exercise), use **Move-ADDirectoryServerOperationMasterRole** (graceful transfer), never a seize unless DC01 is dead.
- [ ] **Baselines/LAPS auto-applied** (DC02 is in `Domain Controllers`): `gpresult /r` on DC02 shows the MSFT **Domain Controller** baseline + **Defender AV** + **`LAPS-DC-DSRM`** winning. Then `Get-LapsADPassword -Identity DC02 -AsPlainText` returns a DSRM password (Source `EncryptedDSRMPassword`) — LAPS took it over. 🔴 The **Wave-B DC-VBS** GPO is still gated on the Proxmox `msinfo32` VBS check (same as DC01) — inert-but-benign until then.
- [ ] **Point clients/DHCP at both DCs** eventually — resilience only helps if resolvers list DC01 *and* DC02. (Fold into the DHCP scope when it's built.)
- [ ] 💡 **Snapshot `dc02-atlaslab-<date>`** now that it verifies.
- [ ] **NetBox** — add DC02 (`10.20.0.3`) as an object when NetBox lands.

---

## Validation — read the state back
- [ ] `Get-ADDomainController -Identity DC02` → GC, `atlas.lab`, `Default-First-Site-Name`.
- [ ] `Get-ADForest | Select Domains` → **one** domain (no accidental second forest).
- [ ] `repadmin /replsummary` → **0 failures**, both directions.
- [ ] `w32tm /query /source` on DC02 → **DC01** (DOMHIER), not external/CMOS.
- [ ] `netdom query fsmo` → all 5 on DC01 (documented).
- [ ] `gpresult /r` on DC02 → DC baseline + Defender + `LAPS-DC-DSRM` applied; `Get-LapsADPassword -Identity DC02` returns.
- [ ] DC02's NIC DNS = itself + DC01 (steady-state), set only after Stage 5.

## Failure modes
- 🔴 **`Install-ADDSForest` instead of `Install-ADDSDomainController`** — creates a second, isolated forest. Use the *replica* path; verify `Get-ADForest` shows one domain.
- 🔴 **NIC DNS pointed at itself during promotion** — can't locate the domain to join. Point at DC01 first; flip to steady-state after replication.
- 🔴 **DNS island** — a replica pointed only at itself before it has the zone. Set steady-state (Stage 4) *after* Stage 5.
- 🔴 **DC02 time from external/CMOS** — a non-PDCe DC must use `DOMHIER`. External source or hypervisor sync fights the domain and breaks Kerberos/replication.
- 🔴 **Seizing FSMO** — seizing is for a *dead* DC and can corrupt the domain if the old holder returns. Transfer gracefully; DC01 is alive.
- 🔴 **Moving DC02 out of `Domain Controllers`** — the default DC GPO + the MSFT baseline + LAPS-DC-DSRM stop applying.
- 🔴 **Promoted under-patched** — patch first (a Tier-0 DC must be current).
- 🔴 **Adding a replica to an unhealthy DC01** — replicate the problem. `dcdiag` DC01 clean first.
- **Treating DC02 as backup** — it isn't; replication copies deletions. Keep AD Recycle Bin + system-state backup.

## Related
- `DC01-Build-Guide.md` (the forest root — this mirrors its structure) · `Tiered-Admin-and-Groups-Build.md` (Stage 8 — Part 4 points here; provides `t0-seth`, the promotion credential) · `../../Build-Checklist.md` §8 · `GPO-Design-and-Build.md` (the DC baseline + `LAPS-DC-DSRM` DC02 inherits) · `OU-Design-and-Build.md` (DCs stay in `Domain Controllers`) · `../../Troubleshooting.md` (this device) · `IP-Addressing-Plan-VLSM` (`10.20.0.3`) · `Virtualization/` 213–214 (clone/deploy the VM) · `Master-Build-Order` Phase 3 · `301`/`303` · `ADR-0007/0020/0021/0024/0025` · VM Snapshot & Naming Convention.

## Sources
**Official Microsoft Learn**
- Install a replica DC (existing domain): https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-a-replica-windows-server-2012-domain-controller-in-an-existing-domain--level-200-
- Install-ADDSDomainController: https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsdomaincontroller
- Configure a time source for the forest (DOMHIER for non-PDCe DCs): https://learn.microsoft.com/en-us/services-hub/unified/health/remediation-steps-ad/configure-the-root-pdc-with-an-authoritative-time-source-and-avoid-widespread-time-skew
- Monitor/verify AD replication (repadmin): https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/troubleshoot-ad-replication-problems
- FSMO transfer vs seize: https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/transfer-or-seize-fsmo-roles-in-ad-ds
- Global Catalog: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/planning-global-catalog-server-placement
- Windows LAPS (AD) / DSRM: https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory
- AD DS Tier Model: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/tier-model

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-22 | Created — dedicated DC02 replica-DC build guide, mirroring `DC01-Build-Guide.md` (GUI-primary + PowerShell, 📸, 🔴 traps, read-backs). Covers the five replica-specific traps (replica-not-forest, DNS chicken-and-egg + island, DOMHIER time, FSMO stays/transfer-not-seize, auto-inherited DC-OU policy), plus VM prep, promotion (`Install-ADDSDomainController`), DOMHIER time, DNS steady-state, the full replication-verify pass (`repadmin`/`dcdiag`/DFSR/object-flow), and post-promotion housekeeping (FSMO map, LAPS/baseline inheritance, snapshots). Absorbs the Stage-8 doc's Part 4 as the single source (POL-0008). 📋 Authored — not device-executed (POL-0001). |
