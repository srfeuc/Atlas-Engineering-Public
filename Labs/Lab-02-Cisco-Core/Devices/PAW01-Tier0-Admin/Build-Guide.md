---
Title: Windows 11 Golden Image + Tier-0 PAW (PAW01) — Build Guide (atlas.lab) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin
Status: 🟡 LIVING (v0.5). **GUI-FIRST + PowerShell alongside.** Microsoft-grounded (PAW / Enterprise Access Model + sysprep golden-image + Win11 security baseline via the SCT). Builds the reusable **Win11 golden image** (sysprep→Proxmox template) and the dedicated **Tier-0 PAW** you RDP into to run RSAT (solves the Protected-Users/Kerberos + copy-paste problem). 📋 **Authored 2026-07-22 — NOT device-executed (POL-0001).** Consumes the `Admin\Tier 0\PAW` OU + `t0-seth` from `Tiered-Admin-and-Groups-Build.md`.
Version: 0.6
Date: 2026-07-22
---

# Windows 11 Golden Image + Tier-0 PAW (PAW01)

> **Why this page exists:** `t0-seth` is in **Protected Users** (no NTLM), so you can't RDP to a DC by IP, and the Proxmox console has no copy/paste. The fix — and the *correct* Tier-0 pattern — is a dedicated **Privileged Access Workstation (PAW)**: a hardened, admin-only Windows 11 box, domain-joined, running **RSAT**, that you RDP into (Kerberos + clipboard both work) and administer the DCs *from*. You rarely RDP onto a DC again. This guide builds the reusable **golden image** first (so future clients clone from it too), then the PAW.

## 🔎 Confidence & sourcing (honest) — and the on-prem vs cloud reality
- **Sysprep golden-image**, **RSAT install**, and the **PAW/Enterprise Access Model** are Microsoft-documented (links at the bottom) — high confidence.
- 🔴 **Microsoft's *current* PAW deployment guidance is Intune / Entra ID / Autopilot-centric** (Conditional Access, Intune profiles, Defender for Endpoint, MFA, downloadable Intune-config scripts). **Atlas is on-prem AD with no Entra/Intune yet.** So this guide implements the **on-prem-achievable subset** — clean-source golden image, domain join into the Tier-0 PAW OU, the **Win11 security baseline via the Security Compliance Toolkit** (same mechanism as the Server baseline in 7a), a **PAW hardening GPO**, and our **tier model** (7d deny-cross-tier). The **cloud-managed pieces are listed as a deferred delta in Part 3** — not silently skipped.
- **Win11 security baseline exact version/GPO names:** grab the current baseline from the SCT and confirm the names *on import* (like we did for Server 2025 v2602) — don't trust a name I typed. As of this writing Microsoft has published the **Windows 11 v25H2** baseline.
- 🔴 **Nothing here is device-verified.** Authored plan; run it, then we mark state.

## Microsoft's PAW profiles (where we land)
Microsoft defines three: **Enterprise** (general admin), **Specialized** (sensitive roles), **Privileged** (Tier-0 — DCs, PKI, identity). A DC-admin box is the **Privileged** profile. We build to that intent with on-prem controls.

---

# Part 1 — The Windows 11 golden image (Proxmox template)

> Microsoft's documented image flow: **install → customize in *Audit Mode* → `sysprep /generalize /oobe /shutdown` → capture/template.** We do exactly that, then turn the shut-down VM into a Proxmox template.

## 1a. Create the VM on PVE01 (Win11 requirements = also what Credential Guard needs)
Win11 *requires* UEFI + Secure Boot + TPM 2.0 — and conveniently those are the same prerequisites as **Credential Guard/VBS** later, so building it right now pays off twice.

**Proxmox VM settings (GUI ▸ Create VM):**
- **System:** Machine **q35**, BIOS **OVMF (UEFI)**, add an **EFI Disk**, **✅ Add TPM (v2.0)**, **✅ Secure Boot** (Pre-Enrolled Keys). 📸
- **CPU:** type **host**, **2+ cores** (needed for VBS). **Memory:** **8 GB** (min 4). Enable **Balloon** off is fine.
- **Disk:** **64 GB**, bus **SCSI** on **VirtIO SCSI single** controller (VirtIO for speed — you'll load its driver during setup). Cache = default.
- **Network:** **VirtIO (paravirtualized)**, on the VLAN you'll build clients on (see note). 
- **CD/DVD:** mount the **Windows 11 ISO**; add a **second CD drive** with **`virtio-win-0.1.285.iso`** (for the storage/NIC drivers + guest agent).
- Name it something like `win11-gold` (this VM becomes the *template source* — you won't run it directly after sysprep).

> 🖱 **VLAN note:** the golden image is generic; VLAN matters for the *PAW clone* (Part 2c), not the template. Build the image on any lab-reachable VLAN with internet for updates.

## 1b. Install Windows 11
1. Boot the VM ▸ Windows Setup. When you reach **"Where do you want to install Windows?"** and see **no disk**, click **Load driver** ▸ browse the **virtio-win** CD ▸ `vioscsi\w11\amd64` ▸ install → the VirtIO disk appears. 📸
2. Edition: **Windows 11 Pro or Enterprise** (Enterprise is the better PAW OS — it's where Credential Guard/AppLocker are first-class; Pro works with caveats noted in Part 2). 
3. 🔎 **Skip the Microsoft-account/OOBE** for a clean local image: at the region screen you can press **Shift+F10** ▸ `OOBE\BYPASSNRO` (or `start ms-cxh:localonly` on newer builds) to allow a **local account** — but for a golden image the cleaner move is to jump straight to **Audit Mode** (next step), which logs in as the built-in Administrator and never creates a first user at all.

## 1c. 🔧 Customize in Audit Mode (Microsoft's recommended way)
At the **first OOBE screen** (region select), press **Ctrl+Shift+F3**. Windows reboots into **Audit Mode**, logged in as the built-in Administrator, with the Sysprep dialog open. This is where Microsoft says to do image customization — changes here bake into the image for every clone.

> 🖱 **Proxmox noVNC key-passthrough (device-learned 2026-07-22):** noVNC is finicky about which combos it forwards vs the browser eating them, and it varies. **In this build `Ctrl+Shift+F3` worked and `Shift+F10` was intercepted.** So: **try `Ctrl+Shift+F3` first**; if it's eaten, the alternative is `Shift+F10` → `%windir%\System32\Sysprep\sysprep.exe /audit /reboot` (lands in the *same* Audit Mode, no chord). If *neither* passes: click noVNC **Fullscreen** first (stops the browser grabbing F-keys), or switch the VM **Display → SPICE** + remote-viewer for full key passthrough (also gives copy/paste into the VM). (This is also the OOBE screen where the VirtIO NIC shows "No Internet" until guest tools are installed — expected.)

**Bake into the image NOW (every clone inherits it — PAW *and* future VLAN-50 clients, so keep it generic + minimal):**
1. **VirtIO guest tools + QEMU guest agent** from the virtio-win CD (`virtio-win-guest-tools.exe`) — drivers + agent (this also fixes the "No Internet"). 📸
2. **Windows Update** — fully patch (reboot as needed; you stay in Audit Mode across reboots).
3. **Machine-level settings** that suit every clone: time zone, a high-performance power plan, disable hibernation (`powercfg /h off`), and any runtimes *everything* needs (VC++ redists, .NET).
4. *(Optional, conservative)* strip consumer bloat you never want — keep it light, and 🔴 **never touch Microsoft Store apps**: a per-user Store app makes `sysprep /generalize` **fail** (*"...installed for a user, but not provisioned for all users"*).
5. *(Optional — Microsoft's way to propagate default-user UI tweaks)* an unattend with `CopyProfile=true` seeds your Explorer/desktop customizations into new profiles; otherwise do per-user UI via GPO.

**Do NOT bake in — per-clone or via GPO after domain join (keeps the image reusable + role-neutral):**
- Computer **name**, **domain join**, **static IP/VLAN** — per clone (sysprep clears the name anyway).
- **RSAT** — PAW-only (Part 2g); you don't want admin tools on general client clones.
- **Security baseline + PAW hardening + Credential Guard** — via **GPO** after the clone joins its OU (Part 2e/2f), not baked in.

Leave the Sysprep dialog open (or reopen `C:\Windows\System32\Sysprep\sysprep.exe`) for when you seal (Part 1e).

## 1d. Pre-sysprep hygiene (the gotchas that waste an afternoon)
- 🔴 **BitLocker OFF / suspended** before generalize — on **Win11 24H2+** `sysprep /generalize` has a known conflict with an encrypted volume. A fresh Audit-Mode image normally isn't encrypted; confirm with `manage-bde -status` and disable if it is.
- 🔴 **No pending Store app updates** (see 1c-4).
- Confirm you're not over the **1001-generalize limit** (irrelevant on a fresh image; matters only if you re-sysprep the same image many times).

## 1d▸ Scripted clean + seal (repo `Scripts/`) — recommended

Three PowerShell scripts make the finalize **repeatable and lean** (they also serve the future VLAN-50 clients, not just PAW01). Run them **in Audit Mode, elevated**. They live in `Devices/PAW01-Tier0-Admin/Scripts/`:

| Script | What it does | When |
|---|---|---|
| **`Prep-GoldenImage.ps1`** | Bakes generic machine settings (High-perf power, hibernation off, time zone) + removes build cruft: WinSxS `/StartComponentCleanup /ResetBase`, `SoftwareDistribution`, temp/Prefetch, **all event logs**, Delivery-Optimization cache, recycle bin, and a **TRIM** so Proxmox reclaims the space. Generic only — **no** name/IP/domain/RSAT/baseline. | After Windows Update, before sealing |
| **`Test-SysprepReadiness.ps1`** | Non-destructive **GO/NO-GO**: BitLocker decrypted, no pending reboot, built-in-Administrator/Audit-Mode heuristic, *installed-but-unprovisioned appx* advisory, free disk. Exit 0 = GO. | Right before sealing |
| **`Invoke-SysprepGeneralize.ps1`** | Guarded wrapper — runs the readiness check, **dry-runs by default**, and seals (`/generalize /oobe /shutdown [/mode:vm]`) only with `-Execute`. | To seal (or use the GUI, 1e) |

Typical run:
```powershell
# elevated PowerShell, in Audit Mode, from the Scripts folder:
Set-ExecutionPolicy -Scope Process Bypass -Force
.\Prep-GoldenImage.ps1 -DisableStoreAutoUpdate      # clean + finalize (generic)
.\Test-SysprepReadiness.ps1                          # want: RESULT: GO
.\Invoke-SysprepGeneralize.ps1 -Execute -ModeVM      # seal — or do it via the GUI (1e)
```

> 🔴 The scripts **check** the gotchas in 1d below, they don't hide them — read the `[FAIL]`/`[NOTE]` output. `Prep-GoldenImage.ps1` will **not** bulk-remove Store apps (that can itself break generalize); it only reports risky ones. To get the scripts onto the image: copy the `Scripts\` folder in (or `git`/USB/share), since the image isn't domain-joined yet.

## 1e. Sysprep — generalize and shut down
In the open Sysprep dialog (or CLI), Microsoft's recommended settings:
- **System Cleanup Action:** *Enter System Out-of-Box Experience (OOBE)*
- **✅ Generalize** (this strips the machine **SID**, device-specific config, and user-specific provisioned app data — the whole point)
- **Shutdown Options:** *Shutdown*
- **OK**. The VM generalizes and powers off. 📸

**CLI equivalent (identical effect):**
```cmd
C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown
```
*(Optional `/mode:vm` — skips re-detecting hardware on first boot; valid because the template and its clones live on the same PVE01 hypervisor. Safe to add for a Proxmox template.)*

## 1f. Convert to a Proxmox template
With the VM **powered off** (do not boot it again — booting a generalized image runs OOBE and consumes the image):
1. Proxmox ▸ right-click the `win11-gold` VM ▸ **Convert to template**. 📸
2. Record it in `Virtualization/Reference/218-VM-Snapshot-and-Naming-Convention` (name e.g. `tmpl-win11-<yyyymmdd>`).

### Verify (Part 1)
- [ ] The VM shows as a **template** in Proxmox (icon changes; can no longer start it directly).
- [ ] A test **full clone** boots to the **OOBE** "let's set up" screen (proves generalize worked). Delete the test clone.

---

# Part 2 — PAW01 (the Tier-0 admin workstation)

## 2a. Clone PAW01 from the template
Proxmox ▸ right-click the template ▸ **Clone** ▸ **Full Clone** (not linked — a PAW should be independent) ▸ name **`PAW01`** ▸ set resources (2 vCPU, 8 GB). 📸

## 2b. 🔑 Pre-stage the computer object in the PAW OU *before* joining
So PAW01 lands in `Admin\Tier 0\PAW` (and immediately gets the PAW GPOs) instead of `Devices\Staging` (where `redircmp` sends unstaged joins):
1. On the DC / your current admin session, **ADUC** ▸ expand **`Admin ▸ Tier 0 ▸ PAW`** ▸ right-click ▸ **New ▸ Computer** ▸ name **`PAW01`** ▸ OK. 📸
2. *(This is the tier model in action: the PAW **is** a Tier-0 device, so its object lives in the Tier-0 subtree and inherits Tier-0 policy.)*

## 2c. First boot, network, name
1. Boot **PAW01** ▸ complete OOBE ▸ create a **local** account for now (you'll use domain accounts after join).
2. **Network:** put the PAW on a **tagged VLAN** — **not the native VLAN 10.** 🔴 **Corrected 2026-07-22:** an earlier draft put the PAW on Mgmt VLAN 10, but VLAN 10 is the *native* (untagged) VLAN on the PVE01 trunk, and a VM tagged VLAN 10 loses return traffic (the switch egresses native VLAN 10 untagged; the VLAN-aware bridge won't deliver it to a tag-10 vNIC — see `SW01/Build-Guide` failure modes + `Master-Build-Order` Phase 2). **Use VLAN 20 or a dedicated admin VLAN** (tagged): e.g. a static in `10.20.0.10–.55` (server range, avoid the Tier-0 block `.2–.9`), gw `10.20.0.1`, DNS `10.20.0.2` (DC01). *(Alternative if you want VLAN 10 specifically: re-architect the PVE trunk to native-999 + tag PVE mgmt as 10 — bigger change, touches hypervisor mgmt.)*
   - 🔴 **East-west flow:** the MKT01 policy must let PAW01 reach the Tier-0 identity block (`10.20.0.2–.9`) over the admin protocols (RDP/Kerberos/LDAPS/DNS) — add/confirm this in `Atlas-East-West-Allowed-Flows-Matrix` when segmentation is enforced (Phase 7). Until deny is on, it's open.
3. Confirm the computer name is **`PAW01`** (matches the pre-staged object) ▸ reboot if you renamed.

## 2d. Domain join
**GUI:** Settings ▸ **System ▸ About ▸ Domain or workgroup ▸ Change** ▸ **Domain** = `atlas.lab` ▸ supply a join credential (**`t0-seth`**, or the built-in Administrator as bootstrap) ▸ reboot. 📸
- ✅ After reboot, in ADUC confirm **`PAW01` is in `Admin\Tier 0\PAW`** (because you pre-staged it). Sign in as **`ATLAS\t0-seth`**.

## 2e. Apply the Windows 11 security baseline (SCT — same mechanism as 7a)
1. Download the **Security Compliance Toolkit** (same site as the Server baseline) → the **Windows 11 (current, e.g. v25H2)** baseline zip. 🔗 https://www.microsoft.com/en-us/download/details.aspx?id=55319
2. Import its GPO backups into AD (run the shipped `Baseline-ADImport.ps1` **from its own `Scripts\` folder** — remember the 7a gotcha: never paste its guts interactively). `Get-GPO -All` to read the **real** GPO names it created.
3. In GPMC, **link the Win11 baseline GPO(s) to `Admin\Tier 0\PAW`** (and/or a broader `Devices\Workstations` OU when the client population exists). 📸
4. `gpupdate /force` on PAW01, reboot, `gpresult /h` to confirm it applied.

## 2f. The PAW hardening GPO (the on-prem "Privileged profile" subset)
Create a **separate** GPO — e.g. `PAW-Tier0-Hardening` — linked to `Admin\Tier 0\PAW`, layering the Microsoft Privileged-profile intent onto the baseline. Build these in the GPO (GUI paths in `GPO-Design-and-Build.md` Part 1 apply):

| Control (Microsoft Privileged profile) | On-prem GPO implementation |
|---|---|
| **Credential Guard** (VBS) | Computer ▸ Admin Templates ▸ System ▸ Device Guard ▸ *Turn On Virtualization Based Security* = Enabled, Credential Guard = *Enabled with UEFI lock*. 🔴 Gated on the **same Proxmox VBS check** as the DC Wave-B GPOs (`msinfo32` → VBS Running). Win11's Secure Boot + vTPM already satisfy the hardware side. |
| **No local admin for the user** | Computer ▸ Prefs ▸ Control Panel ▸ **Local Users and Groups** — set the local **Administrators** membership to only the intended Tier-0 admins; the interactive user is a standard user. |
| **App control (allow-list)** | **AppLocker** (Computer ▸ Windows Settings ▸ Security Settings ▸ Application Control Policies) — allow admin tooling (RSAT/MMC/PowerShell), deny everything else. *(WDAC is the stronger, more modern option if you want to go further.)* |
| **Block web browsing + email** | Don't install browsers/mail on the image; enforce with the AppLocker allow-list. (No Azure proxy on-prem — we simply don't provide the apps.) |
| **Attack Surface Reduction** | Defender ASR rules via Computer ▸ Admin Templates ▸ … ▸ Microsoft Defender ▸ Attack Surface Reduction (or the baseline may set these). |
| **Firewall deny-by-default** | Windows Defender Firewall (via GPO): inbound **block** (allow only RDP from your mgmt source), outbound restricted to DNS/DHCP/NTP/domain/updates. |
| **Deny cross-tier logon** | Already handled by **7d**: `G-Tier1-Admins`/`G-Tier2-Admins` are denied logon here (this is a Tier-0 box), and `G-Tier0-Admins` is denied on lower tiers. The PAW is *where `t0-seth` logs on*. |

## 2g. Install RSAT (the point of the PAW)
**GUI:** Settings ▸ **System ▸ Optional features ▸ Add a feature** ▸ search **RSAT** ▸ install:
- **RSAT: Active Directory Domain Services and Lightweight Directory Services Tools** (ADUC, ADAC, the AD PowerShell module)
- **RSAT: Group Policy Management Tools** (GPMC)
- **RSAT: DNS Server Tools**
📸

**PowerShell (alongside — discover the exact names first, don't trust mine):**
```powershell
Get-WindowsCapability -Online -Name "Rsat*" | Select Name, State
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
Add-WindowsCapability -Online -Name "Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0"
Add-WindowsCapability -Online -Name "Rsat.Dns.Tools~~~~0.0.1.0"
```

## 2h. Use it — this is what solves your copy/paste + Protected Users problem
- From your normal desktop, **RDP to `PAW01`** (by name/FQDN so it's Kerberos; clipboard/copy-paste works over RDP by default). Sign in as **`t0-seth`** — Protected Users is happy because it's Kerberos, not NTLM-by-IP.
- On PAW01, open **ADUC / ADAC / GPMC / DNS** and administer the **DCs remotely** — you don't RDP onto DC01/DC02 at all. `t0-seth` stays on the Tier-0 PAW, exactly where a Tier-0 credential belongs.

### Verify (Part 2)
- [ ] `PAW01` object is in `Admin\Tier 0\PAW`; `gpresult /h` shows the Win11 baseline + `PAW-Tier0-Hardening` applied.
- [ ] `msinfo32` → **Virtualization-based security: Running** and **Credential Guard: Running** (after the Proxmox VBS enablement).
- [ ] RSAT tools open; you can edit AD/GPO against the domain from PAW01.
- [ ] RDP to PAW01 as `t0-seth` works (Kerberos) and **clipboard works**.
- [ ] The interactive user is **not** a local admin.

---

# Part 3 — The cloud-managed delta (deferred — honest scope)
Microsoft's full Privileged-PAW is Intune/Entra-managed. Here's what we're **not** doing on-prem now, and why it's OK to defer in a lab (revisit if/when Atlas adds Entra/Intune):

| Microsoft cloud control | Status in Atlas | On-prem stand-in (if any) |
|---|---|---|
| **Windows Autopilot** self-deploying provisioning | ❌ deferred | Our sysprep **golden image** is the clean-source equivalent |
| **Intune device profiles / compliance** | ❌ deferred | **GPO** (baseline + PAW-hardening) |
| **Conditional Access** (block admin from non-PAW) | ❌ deferred | **7d deny-cross-tier logon** + network segmentation (Phase 7) |
| **Defender for Endpoint (EDR)** | ❌ deferred | Defender AV baseline + ASR via GPO; MON01 for visibility later |
| **MFA on admin sign-in** | ❌ deferred (no on-prem MFA infra) | Strong unique passwords + Protected Users + tiering; revisit with PKI smartcard/Windows Hello later |
| **Entra dynamic device groups / BitLocker escrow** | ❌ deferred | AD groups; BitLocker with AD-escrow is a later hardening item |

🔎 **The honest summary:** this PAW is a genuine, tier-model-correct, baseline-hardened Tier-0 admin workstation for an on-prem lab. It is **not** the full Intune-managed Privileged profile — that's a cloud workstream. Nothing here pretends otherwise.

## Part 3.1 — What the cloud-managed version costs (planning note, 2026 pricing)
Budget context (Seth: ≤ ~$20/mo for services until the lab matures; Azure "eventually"). 🔑 **The on-prem PAW above needs $0 of Azure — build it now.** When you later integrate Azure, the managed-PAW layer is cheap and **fits under $20/month for a single admin** — and it's **per-user SaaS licensing (predictable), not metered Azure consumption**, so there's no surprise-bill risk:

| Option | ~USD/user/mo | Gives you | Fit |
|---|---|---|---|
| **EMS E3** | **$12** | Intune P1 + Entra ID P1 (**Conditional Access**) | ✅ minimum for a cloud-managed PAW |
| **EMS E5** | **$18** | above + Entra ID P2 → **PIM** (just-in-time admin elevation) | ✅ best fit — PIM maps directly onto the tier model |
| À la carte | ~$14 | Entra ID P1 (~$6–7) + Intune P1 ($8) | ✅ |
| M365 Business Premium | ~$22 | Office + Defender for Business + Intune + Entra P1 | ⚠ just over budget; productivity-focused |
| **M365 Developer Program** | **$0** | renewable **E5 sandbox** (25 licenses; Entra + EMS) — a *separate* tenant to learn Entra/Intune/CA/PIM | ✅ free labbing (not tied to `atlas.lab`) |

**Sequencing (why later, not now):** an Intune / Conditional-Access-managed PAW needs the device in **Entra** (hybrid-Entra-join), which means standing up **Entra Connect Sync** to link `atlas.lab` → an Entra tenant. That hybrid-identity project is worth doing **after** the on-prem foundation (DCs, tiering, PKI) is solid — exactly the "integrate Azure eventually" / `303` **Phase-8 (Advanced: Entra hybrid)** slot. **Recommendation:** on-prem GPO PAW now ($0) → when ready, learn on the **free dev tenant**, then **EMS E5 ($18/mo, one user)** on a real tenant for **PIM + Conditional Access** on the actual PAW. (When you commit to this, it's worth an ADR for the hybrid-identity decision.)

## Failure modes
- 🔴 **Booting the generalized template** instead of cloning from it — consumes the image (runs OOBE). Convert to template and clone; never boot the source.
- 🔴 **Store app installed before sysprep** → generalize fails. Leave Store apps alone in Audit Mode.
- 🔴 **BitLocker on during generalize (24H2+)** → sysprep breaks. Confirm off first.
- 🔴 **Joining before pre-staging** → PAW lands in `Devices\Staging` (via redircmp), missing the Tier-0 PAW GPOs. Pre-stage the computer object in `Admin\Tier 0\PAW` first.
- 🔴 **Making the daily user a local admin on the PAW** — defeats the point. The interactive user is standard; admin tooling runs with the tiered admin creds.
- 🔴 **Treating the PAW as a general workstation** (browsing/email on it) — it's dedicated to admin. That's the whole model.
- 🔴 **Credential Guard linked before the Proxmox VBS check** — benign-but-inert if VBS isn't exposed; enable VBS on the VM (host CPU, UEFI/Secure Boot, vTPM) first, same gate as the DC Wave-B GPOs.

## Sources
**Microsoft Learn / Microsoft**
- Sysprep (Generalize) a Windows installation: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation
- Audit Mode overview: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/audit-mode-overview
- Sysprep command-line options: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep-command-line-options
- Privileged access: devices (why PAWs matter): https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-devices
- Deploying a privileged access solution (profiles + controls): https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-deployment
- Enterprise Access Model: https://learn.microsoft.com/en-us/security/privileged-access/privileged-access-access-model
- Install RSAT on Windows: https://learn.microsoft.com/en-us/windows-server/administration/install-remote-server-administration-tools
- Security Compliance Toolkit (download + guide): https://www.microsoft.com/en-us/download/details.aspx?id=55319 · https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/security-compliance-toolkit-10
- Windows 11 security baselines (blog index): https://techcommunity.microsoft.com/category/security-baselines
- Credential Guard: https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/

**Local:** `Tiered-Admin-and-Groups-Build.md` (the `Admin\Tier 0\PAW` OU + `t0-seth`), `GPO-Design-and-Build.md` (§7a baseline import mechanism + §7d deny-cross-tier + GPO GUI paths), `IP-Addressing-Plan-VLSM` (Management VLAN 10), `Virtualization/Build-Guides` 207–214 (the Server golden-image flow this parallels), `218-VM-Snapshot-and-Naming-Convention`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.6 | 2026-07-22 | Added **§1d▸ Scripted clean + seal** + a `Scripts/` folder: `Prep-GoldenImage.ps1` (machine settings + WinSxS/temp/event-log/DO-cache/TRIM cleanup, generic), `Test-SysprepReadiness.ps1` (GO/NO-GO: BitLocker/pending-reboot/audit-mode/appx/disk), `Invoke-SysprepGeneralize.ps1` (guarded, dry-run-by-default sysprep wrapper). Win11 golden image confirmed fully updated 07-22 → ready to seal. |
| 0.5 | 2026-07-22 | Part 2c — **corrected the PAW's VLAN**: not native VLAN 10 (VM-on-native-VLAN asymmetry breaks it, device-learned) → a **tagged** VLAN (20 / dedicated admin), avoiding the Tier-0 block. Cross-refs SW01 failure modes + Master-Build-Order Phase 2. |
| 0.4 | 2026-07-22 | Part 1c — **corrected the noVNC keystroke record** (Seth: `Ctrl+Shift+F3` worked, `Shift+F10` was intercepted — try Ctrl+Shift+F3 first, Shift+F10→`sysprep /audit /reboot` as fallback). Restructured the Audit-Mode step into an explicit **"bake in now vs per-clone/GPO"** list (keep the image generic for PAW + VLAN-50 clients; name/join/IP/RSAT/baseline/hardening are per-clone or GPO). |
| 0.3 | 2026-07-22 | Part 1c — added the noVNC Audit-Mode gotcha (superseded by v0.4's correction). |
| 0.2 | 2026-07-22 | Added **Part 3.1 — cloud-managed cost/sequencing** (2026 pricing, searched): on-prem PAW = $0; the Azure-managed layer fits ≤$20/mo for one admin (EMS E3 $12 = Intune+Entra P1/Conditional Access; **EMS E5 $18 = +PIM**; à la carte ~$14; Business Premium ~$22 over; **free M365 Developer E5 sandbox** for learning). Per-user SaaS (predictable, not metered). Recommendation: on-prem PAW now → Entra Connect hybrid + EMS E5 later (`303` Phase-8), worth an ADR when committed. |
| 0.1 | 2026-07-22 | Created — Microsoft-grounded, GUI-first. Part 1 Win11 golden image (Proxmox UEFI/SecureBoot/vTPM VM → VirtIO install → **Audit Mode** customize → `sysprep /generalize /oobe /shutdown` → Proxmox template), with the Store-app / BitLocker-24H2 / boot-the-template gotchas. Part 2 PAW01 (full clone → **pre-stage the computer object in `Admin\Tier 0\PAW`** → static on Mgmt VLAN 10 → domain join as `t0-seth` → **Win11 SCT baseline** like 7a → `PAW-Tier0-Hardening` GPO mapping the Microsoft Privileged-profile controls to on-prem GPO/AppLocker/Firewall/CredGuard → **RSAT** install → RDP-in usage that fixes the Protected-Users/Kerberos + copy-paste problem). Part 3 the honest **cloud-managed delta** (Autopilot/Intune/Conditional Access/Defender-for-Endpoint/MFA deferred, with on-prem stand-ins). 📋 Authored, not device-executed (POL-0001). |
