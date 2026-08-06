---
Title: Group Policy (GPO) — Mental Model, Design & Build (atlas.lab) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 LIVING (v0.8). 🔴 Entry **GATE** header added (`ADR-0043`). **GUI-primary (GPMC) + PowerShell.** The "learn GPOs properly" page + the Stage 7 build. **Done & device-verified:** 7a baseline + Wave-A links (07-21) · 7b Finance/HR PSO (07-21) · 7c LAPS schema+GPO (07-22, member test deferred) · **7c-DSRM DSRM-password-via-LAPS (07-22, fully verified — `POL-0002` retired)**. **Remaining:** Wave B (VBS/CG — Proxmox check) · **7d tier-deny logon GPOs — now UNBLOCKED** (references `G-Tier0/1/2-Admins`, built in Stage 8 · `Tiered-Admin-and-Groups-Build.md`) · a **Validation/adversarial-test pass** (Seth). `DC01-Build-Guide.md` Stage 7 points here; `303` Part 6 is the design rationale.
Version: 0.8
Date: 2026-07-22
---

# Group Policy — Mental Model, Design & Build

> **Why this page exists:** GPOs are the part of AD that bites people in the real world, almost always because the *processing/precedence model* isn't solid. Part 1 fixes the model; Part 2 is the Microsoft-accurate Stage 7 build. Read Part 1 first — it's the thing that makes the rest obvious.

> 🔴 **GATE (when this runs)** — DC01 **Stage 7**: OUs exist (Stage 6 ✅). **7d tier-deny** additionally needs the **Stage-8 tier groups** (`Tiered-Admin-and-Groups-Build.md`); GPO **Wave-B** is gated on the Proxmox VBS check.

## 🔎 Confidence & sourcing (honest)
- **Part 1 (the model)** and the **PSO**, **LAPS**, and **deny-logon** mechanics are grounded in Microsoft Learn (sources at the bottom) and are core, stable behavior — high confidence.
- **Security Compliance Toolkit / baselines** = a **Microsoft download** (link below); I can't fetch the binary, so grab it and I'll help you import it.
- **The exact tier-deny GPO/group *wiring*** (which group is denied on which OU) is what the **AD Tier Model repo** automates; I give you Microsoft's documented *technique* + the tier logic. Verify the exact matrix against the repo or build it incrementally and test with `gpresult`. If a page won't load for me, I'll give you the link to paste back.

---

# Part 1 — The mental model (read this first)

## 1. GPO vs GPO *link* (the #1 confusion)
- A **GPO** is a container of settings. It does nothing until it's **linked**.
- A **link** attaches a GPO to a **Site**, **Domain**, or **OU**. The *same* GPO can be linked in several places.
- So "delete the link" ≠ "delete the GPO." Disabling a link stops it applying there; the GPO still exists.

## 2. Two halves: Computer vs User
- **Computer Configuration** applies to the **computer**, at **boot** + periodic refresh. Scoped by where the **computer object** lives.
- **User Configuration** applies to the **user**, at **logon** + refresh. Scoped by where the **user object** lives.
- A GPO can carry both halves; only the relevant half applies to a given object. (This is why a GPO linked to a *computer* OU with only User settings does nothing — unless loopback, §5.)

## 3. Precedence — **LSDOU**, closest wins
GPOs apply in this order; **later overrides earlier**, so the **last applied wins**:
1. **L**ocal policy (on the box)
2. **S**ite
3. **D**omain
4. **O**U — parent OU → child OU, **deepest/closest to the object last** ⇒ **the OU nearest the object wins.**

Within a **single** container with multiple linked GPOs, **link order** decides: **lowest link-order number = highest precedence** (processed last). GPMC's "Group Policy Inheritance" tab shows the resultant order for any OU — use it.

## 4. The two overrides that break "closest wins"
- **Enforced** (on a *link*): that GPO's settings **win over everything below it** and **cannot be blocked**. Use sparingly (e.g., a security setting Legal/Security must guarantee).
- **Block Inheritance** (on an *OU*): stops **inherited** GPOs from above — **except Enforced ones**, which still punch through.
- Conflicts resolve by: **Enforced > Block Inheritance > normal closest-wins**.

## 5. 🔴 Loopback processing (the classic real-world trap)
Normally User settings come from the **user's** OU. **Loopback** makes User settings come from the **computer's** OU instead — for shared/kiosk/RDS/server scenarios where the *machine* should dictate the user experience regardless of who logs on.
- Setting: `Computer Config ▸ Policies ▸ Admin Templates ▸ System ▸ Group Policy ▸ Configure user Group Policy loopback processing mode`.
- **Merge** = user's-OU settings **then** computer's-OU settings (computer wins conflicts). **Replace** = computer's-OU user settings **only**.
- If "a user's GPO isn't applying on a server/kiosk," loopback is the first suspect.

## 6. Scoping *within* a link — 3 filters
An OU link says "these objects **could** get it." Three filters narrow *which*:
- **Security Filtering** (the common one): the GPO applies only to the users/computers/**groups** listed. Default = **Authenticated Users** (which includes computers). To scope to a group, add the group and remove Authenticated Users — **🔴 but** since a 2020 security update the object must still have **Read** to fetch the GPO, so on the **Delegation** tab add `Authenticated Users` (or `Domain Computers`) back with **Read** (not Apply). Missing this = "GPO mysteriously doesn't apply."
- **WMI Filtering:** apply only if a WMI query is true (e.g. `OS is a server`, `free disk > X`). Powerful but evaluated every refresh — don't overuse (perf).
- **Item-level targeting** (Group Policy **Preferences** only): per-item conditions (OU, group, IP range…). More flexible than WMI for Preferences.

## 7. How to SEE what actually applied (the debugging skill you were missing)
- **`gpresult /h report.html`** on the target → the **Resultant Set of Policy**: which GPOs won, which were denied and *why* (filtered out, empty, access-denied). This is the single most useful GPO troubleshooting command.
- **`rsop.msc`** — GUI RSoP. **`gpresult /r`** — quick text summary.
- **`gpupdate /force`** — reapply now (don't wait for the ~90-min refresh). Some settings (folder redirection, software install) need **logoff/reboot**.
- GPMC **Group Policy Modeling** — "what *would* apply" for a hypothetical user+computer+OU, before you deploy.

## 8. Design rules that prevent the pain
- **Many small, purpose-named GPOs** (`Baseline-Server-Security`, `LAPS`, `Tier0-Deny-Logon`) — **never** one giant "Default Domain Policy does everything." Default Domain Policy = *only* domain password/lockout + Kerberos; Default DC Policy = *only* DC-specific rights. Leave those two mostly alone.
- **Link high, filter tight** — link a GPO once at the right OU; scope with security groups rather than sprawling links.
- **Name so the log reads itself** — the `gpresult` report is only readable if GPOs are named for their job.
- **Test with `gpresult` / Modeling before trusting it.**

---

# Part 2 — Stage 7 build (Microsoft-accurate)
Order matters — do all of this **before** creating users/computers, so nothing is ever unmanaged.

## 7a. Microsoft Security Baseline (Server 2025 v2602) — IMPORTED ✅ (device-verified 2026-07-21)
The Security Compliance Toolkit ships each baseline as **GPO backups** (`GPOs\` = GUID folders + `manifest.xml`), plus `Scripts\` (the bulk importer), `GP Reports\` (HTML), `Documentation\`, `Templates\`.
🔗 **SCT 1.0:** https://www.microsoft.com/en-us/download/details.aspx?id=55319 → the *Windows Server 2025 Security Baseline* zip. **PolicyAnalyzer** is a *separate* `PolicyAnalyzer.zip` inside the toolkit — an optional diff/review tool, **not** required to import. Skippable.

### The import that actually worked (bulk, via the shipped script)
🔴 **Gotcha (device-learned):** `Baseline-ADImport.ps1` must be **executed as a file from its own `Scripts\` folder** — do **not** paste its lines at the prompt. Run interactively, `$MyInvocation.MyCommand.Path` is empty → `[IO.Path]::GetDirectoryName("")` throws *"The path is not of a legal form"* so `$gpoDir` never gets set, and the script's relative paths (`.\Tools\MapGuidsToGpoNames.ps1`, `..\GPOs`) resolve against your CWD (was `C:\WINDOWS\system32`) → helper not found → `$GpoMap` stays `$null` → the `Import-GPO` loop dies with *"Cannot index into a null array."* Nothing wrong with the baseline or AD — just execute the `.ps1`.

Working invocation (this is what produced the GPOs below):
```powershell
cd "C:\Users\Administrator.DC01\Downloads\Windows Server 2025 Security Baseline - 2602\Windows Server 2025 Security Baseline - 2602\Scripts"
Get-ChildItem -Recurse | Unblock-File                    # clear MOTW / "downloaded from internet" block
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\Baseline-ADImport.ps1                                   # imports every baseline GPO into AD, UNLINKED
```

The shipped `Baseline-ADImport.ps1` (recorded from the run; confirm the pristine copy with `Get-Content .\Baseline-ADImport.ps1`):
```powershell
$GpoMap = .\Tools\MapGuidsToGpoNames.ps1 ..\GPOs
Write-Host "Importing the following GPOs:" -ForegroundColor Cyan
Write-Host
$GpoMap.Keys | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
Write-Host
Write-Host
$rootDir   = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
$parentDir = [System.IO.Path]::GetDirectoryName($rootDir)
$gpoDir    = [System.IO.Path]::Combine($parentDir, "GPOs")
$GpoMap.Keys | ForEach-Object {
    $key  = $_
    $guid = $GpoMap[$key]
    Write-Host ($guid + ": " + $key) -ForegroundColor Cyan
    Import-GPO -BackupId $guid -Path $gpoDir -TargetName "$key" -CreateIfNeeded
}
```
It calls the helper `Scripts\Tools\MapGuidsToGpoNames.ps1` (reads `..\GPOs\manifest.xml`, returns a *name → backup-GUID* hashtable), then `Import-GPO -CreateIfNeeded` creates each GPO under its manifest name. GPOs are created **unlinked** — nothing applies until we link them (below). That's why the exact names weren't guessed: the script names them from Microsoft's manifest.

### Imported GPOs (confirmed via `Get-GPO -All`, 2026-07-21)
- MSFT Windows Server 2025 v2602 - Domain Security
- MSFT Windows Server 2025 v2602 - Domain Controller
- MSFT Windows Server 2025 v2602 - Domain Controller Virtualization Based Security
- MSFT Windows Server 2025 v2602 - Member Server
- MSFT Windows Server 2025 v2602 - Member Server Credential Guard
- MSFT Windows Server 2025 v2602 - Defender Antivirus
- MSFT Internet Explorer 11 - Computer
- MSFT Internet Explorer 11 - User
- *(built-ins, leave mostly alone: Default Domain Policy, Default Domain Controllers Policy)*

### 🔗 Link map (GPO → OU) — the authoritative wiring
| GPO | Link target (DN) | Why |
|---|---|---|
| …Domain Security | `DC=atlas,DC=lab` (root), **link order 1** above Default Domain Policy | Password / lockout / Kerberos are domain-wide — only honored from a root-linked GPO |
| …Domain Controller | `OU=Domain Controllers,DC=atlas,DC=lab` | DC hardening baseline (adds to, doesn't replace, Default DC Policy) |
| …Domain Controller Virtualization Based Security | `OU=Domain Controllers,DC=atlas,DC=lab` | DC VBS — ⚠ verify the VM exposes VBS first (Wave B) |
| …Member Server | `OU=Servers,OU=Devices,DC=atlas,DC=lab` | Member-server baseline; future servers inherit once moved out of `Staging` |
| …Member Server Credential Guard | `OU=Servers,OU=Devices,DC=atlas,DC=lab` | CG for member servers — ⚠ verify VBS/vTPM first (Wave B) |
| …Defender Antivirus | `OU=Devices,DC=atlas,DC=lab` **and** `OU=Domain Controllers,DC=atlas,DC=lab` | AV for all machines incl. DCs (`Devices` covers Servers + Workstations + `Staging` by inheritance) |
| MSFT Internet Explorer 11 - Computer | `OU=Devices,DC=atlas,DC=lab` *(optional / legacy — MSHTML & IE-mode hardening)* | Low priority; link if you want it |
| MSFT Internet Explorer 11 - User | `OU=Employees,DC=atlas,DC=lab` — **defer until users exist** | User-side; no user objects yet |

🔴 **Sequence it in two waves — don't link VBS/CG blind:**
- **Wave A (now):** Domain Security (root, order 1) · Domain Controller (DC OU) · Member Server (Servers) · Defender AV (Devices + DC OU) · IE11-Computer (Devices, optional). Then `gpupdate /force` on DC01, **reboot**, verify. Keep the **Proxmox console as break-glass** — these baselines enforce SMB/LDAP signing, NTLM restrictions, and stricter RDP/NLA; if RDP ever locks you out you still have console.
- **Wave B (after confirming VBS support):** DC VBS (DC OU) + Member Server Credential Guard (Servers). VBS/CG need the guest to expose virtualization extensions + Secure Boot (UEFI/OVMF) + vTPM — on PVE01 set CPU type `host`, boot UEFI, add a TPM. If unsupported the GPO is **benign but inert** (won't enable, won't break boot). Confirm with `msinfo32` → *Virtualization-based security = Running*.

### 7a-LINK — GUI walkthrough (GUI-primary; 📸 = screenshot point) with PowerShell alongside
Open **GPMC**: Server Manager ▸ **Tools ▸ Group Policy Management** (or `gpmc.msc`). Expand **Forest: atlas.lab ▸ Domains ▸ atlas.lab**. Set the PowerShell path vars once (used by every step below):
```powershell
Import-Module GroupPolicy
$root="DC=atlas,DC=lab"; $dc="OU=Domain Controllers,$root"; $dev="OU=Devices,$root"; $srv="OU=Servers,OU=Devices,$root"
```

**Step 0 — confirm the import.** Click **Group Policy Objects** in the tree. 📸 you should see the 8 `MSFT …` GPOs + the 2 built-ins — visual proof the import took.
```powershell
Get-GPO -All | Select DisplayName | Sort DisplayName
```

**The link gesture you'll repeat:** right-click the **target OU (or the domain node)** ▸ **Link an Existing GPO…** ▸ pick the GPO in the *Select GPO* box ▸ **OK**. Linking ≠ copying — the same GPO can be linked in several places. For every Wave-A link leave **Enforced** *off* and **Link Enabled** *on* (the defaults), and **don't touch Security Filtering** — default *Authenticated Users* is correct (these baselines should reach every computer in scope).

**① Domain Security → domain root, then force Link Order 1**
1. Right-click the **atlas.lab** *domain node* (not an OU) ▸ **Link an Existing GPO…** ▸ `MSFT Windows Server 2025 v2602 - Domain Security` ▸ OK.
2. Click the **atlas.lab** node ▸ right pane **Linked Group Policy Objects** tab.
3. Select *…Domain Security* ▸ click the **▲ up arrow** until **Link Order = 1** (top, above *Default Domain Policy*). 📸 the tab showing order 1.
   *Why:* password/lockout/Kerberos are domain-wide and closest-wins at the root — it must out-rank Default Domain Policy.
```powershell
New-GPLink -Name "MSFT Windows Server 2025 v2602 - Domain Security" -Target $root -LinkEnabled Yes
Set-GPLink -Name "MSFT Windows Server 2025 v2602 - Domain Security" -Target $root -Order 1
```

**② Domain Controller → Domain Controllers OU**
Right-click **Domain Controllers** ▸ Link an Existing GPO ▸ `…Domain Controller` ▸ OK. 📸 the OU with the new link.
```powershell
New-GPLink -Name "MSFT Windows Server 2025 v2602 - Domain Controller" -Target $dc -LinkEnabled Yes
```

**③ Member Server → Devices\Servers**
Expand **Devices**, right-click **Servers** ▸ Link an Existing GPO ▸ `…Member Server` ▸ OK. 📸
*(No servers live here yet — harmless; a server inherits it once you move it out of `Staging` into `Servers`.)*
```powershell
New-GPLink -Name "MSFT Windows Server 2025 v2602 - Member Server" -Target $srv -LinkEnabled Yes
```

**④ Defender Antivirus → Devices _and_ Domain Controllers** (same GPO, two links)
Right-click **Devices** ▸ Link an Existing GPO ▸ `…Defender Antivirus` ▸ OK. Then right-click **Domain Controllers** ▸ Link the *same* GPO again. 📸 both.
*(Devices covers Servers + Workstations + Staging by inheritance; the second link reaches the DCs, which sit outside Devices in the built-in OU.)*
```powershell
New-GPLink -Name "MSFT Windows Server 2025 v2602 - Defender Antivirus" -Target $dev -LinkEnabled Yes
New-GPLink -Name "MSFT Windows Server 2025 v2602 - Defender Antivirus" -Target $dc  -LinkEnabled Yes
```

**⑤ IE11 - Computer → Devices** *(optional / legacy)*
Right-click **Devices** ▸ Link an Existing GPO ▸ `MSFT Internet Explorer 11 - Computer` ▸ OK. Skip if you don't want the legacy MSHTML/IE-mode hardening. **Do not** link *IE11 - User* yet — no user objects exist.
```powershell
New-GPLink -Name "MSFT Internet Explorer 11 - Computer" -Target $dev -LinkEnabled Yes   # optional
```

**Step V — verify before trusting it** (📸 each)
1. Click **Domain Controllers** ▸ **Group Policy Inheritance** tab — the MSFT *Domain Controller* + *Defender* GPOs should sit **above** *Default Domain Controllers Policy*. 📸
2. Click the **atlas.lab** node ▸ **Group Policy Inheritance** — *Domain Security* at the top. 📸
3. On DC01: `gpupdate /force`, then **reboot** (keep the Proxmox console open as break-glass), then:
```powershell
gpresult /h C:\rsop-dc.html       # open it — the MSFT GPOs show as "Applied", nothing denied unexpectedly
Get-GPInheritance -Target $dc
Get-GPInheritance -Target $root
```

**Wave B — ONLY after the Proxmox VBS check** (`msinfo32` → *Virtualization-based security = Running*): same link gesture —
`…Domain Controller Virtualization Based Security` → **Domain Controllers**, and `…Member Server Credential Guard` → **Devices\Servers**. 📸 each.
```powershell
New-GPLink -Name "MSFT Windows Server 2025 v2602 - Domain Controller Virtualization Based Security" -Target $dc  -LinkEnabled Yes
New-GPLink -Name "MSFT Windows Server 2025 v2602 - Member Server Credential Guard"                  -Target $srv -LinkEnabled Yes
```

### Keep the vendor GPOs pristine
Don't edit the `MSFT …` GPOs in place. Put deviations (CIS overlay, deliberate lab exceptions like the looser `Workstations\Executive` baseline) in a **separate, higher-precedence** GPO so the source of every setting stays obvious and re-importing a newer baseline stays clean.

### Verify (7a)
```powershell
gpupdate /force                 # on DC01, then reboot
gpresult /h C:\rsop-dc.html
Get-GPInheritance -Target "OU=Domain Controllers,DC=atlas,DC=lab"
Get-GPInheritance -Target "DC=atlas,DC=lab"
```
- ✅ RSoP on DC01 shows Domain Controller + Domain Security + Defender AV winning; the Inheritance tab shows the MSFT GPOs above the two built-in defaults; DC still logs in, DNS + AD replication still healthy.
- ✅ **Wave A device-verified 2026-07-21.** After `gpupdate /force` + reboot, `gpresult /r` on DC01 lists Applied GPOs (Computer) in order: **Domain Controller → Defender Antivirus → Default Domain Controllers Policy → Domain Security → Default Domain Policy** — correct precedence, only the empty Local GPO "filtered", and the DC logs in fine (no lockout from the SMB/LDAP/NTLM/RDP tightening). Link readouts confirmed via `Get-GPInheritance` on the domain root, `Domain Controllers`, `Devices`, and `Devices\Servers`. **Wave B (DC VBS + Member Server Credential Guard) still pending the Proxmox `msinfo32` VBS check.**

## 7b. Fine-grained password policy (PSO) for Finance/HR — ADAC ✅ (device-verified 2026-07-21)
**What a PSO is:** a **Password Settings Object** (`msDS-PasswordSettings`) — one instance of a *fine-grained password policy*. The domain-wide policy (from the baseline **Domain Security** GPO at the root) applies to everyone; a PSO **overrides it for a group** (🔴 a group, **never** an OU). Precedence (a number) breaks ties when a user is in two PSOs — **lower number wins**.

### Step 0 — measure the domain default first (so "stricter" is provable)
```powershell
Get-ADDefaultDomainPasswordPolicy | Select ComplexityEnabled, MinPasswordLength, PasswordHistoryCount, MaxPasswordAge, LockoutThreshold
```
🔎 **On atlas.lab (07-21):** Complexity **On**, MinLength **14**, History **24**, MaxAge **42 days**, Lockout **3**. The baseline already set an aggressive default — so a "stricter" PSO must beat *these*, not stock Windows values. 🔴 **Gotcha:** a PSO with MaxAge 365 + Lockout 5 is stricter on *length* (15>14) but **looser** on rotation and lockout than this domain. Choose intentionally:
- **Tightest-group stance:** min 15, lockout ≤3, max age ≤42.
- **Modern-NIST stance (what we chose):** min 15, a long (365-day) max age — lean on length + lockout over forced rotation — but lockout **3** so Finance/HR is never the *weakest* group on lockout. *(If you go modern here, the domain's 42-day age is the old-school outlier — revisit later for consistency.)*

### Step A — the target group (apply a PSO to a group, not an OU)
**GUI (ADUC):** `atlas.lab ▸ Groups ▸ Security-Roles` ▸ right-click ▸ **New ▸ Group** ▸ `G-FinanceHR-Users`, scope **Global**, type **Security**. 📸
```powershell
New-ADGroup -Name "G-FinanceHR-Users" -GroupScope Global -GroupCategory Security `
  -Path "OU=Security-Roles,OU=Groups,DC=atlas,DC=lab" `
  -Description "Members get the stricter Finance/HR fine-grained password policy (PSO-FinanceHR)"
```
Empty for now — Finance/HR users get added here in Stage 8.

### Step B — create + apply the PSO
**GUI (ADAC — primary):**
1. Server Manager ▸ **Tools ▸ Active Directory Administrative Center** (or `dsac.exe`).
2. Left nav ▸ **Tree view** ▸ **atlas (local) ▸ System ▸ Password Settings Container**. 📸
3. **Tasks ▸ New ▸ Password Settings**. 📸
4. Fill: **Name** `PSO-FinanceHR` · **Precedence** `10` · ✅ min length `15` · ✅ complexity · history `24` · ✅ min age `1` · ✅ max age `365` · ✅ lockout: attempts `3`, reset after `30` min, locked `30` min · *reversible encryption* **off** · *protect from accidental deletion* **on**. 📸
5. **Directly Applies To ▸ Add… ▸ `G-FinanceHR-Users`** ▸ Check Names ▸ OK. 📸
6. **OK**.

**PowerShell (alongside):**
```powershell
New-ADFineGrainedPasswordPolicy -Name "PSO-FinanceHR" -Precedence 10 `
  -ComplexityEnabled $true -MinPasswordLength 15 -PasswordHistoryCount 24 `
  -MinPasswordAge 1.00:00:00 -MaxPasswordAge 365.00:00:00 `
  -LockoutThreshold 3 -LockoutDuration 00:30:00 -LockoutObservationWindow 00:30:00 `
  -ReversibleEncryptionEnabled $false
Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-FinanceHR" -Subjects "G-FinanceHR-Users"
```

### Verify
```powershell
Get-ADFineGrainedPasswordPolicy -Identity "PSO-FinanceHR" | Select Name,Precedence,MinPasswordLength,MaxPasswordAge,LockoutThreshold,AppliesTo
# once a Finance/HR user exists AND is in the group:
Get-ADUserResultantPasswordPolicy -Identity <user>    # → PSO-FinanceHR
```
- ✅ **Device-verified 07-21:** PSO exists — Precedence 10, MinLength 15, MaxAge 365, `AppliesTo` = `CN=G-FinanceHR-Users,OU=Security-Roles,OU=Groups,DC=atlas,DC=lab`. (Set LockoutThreshold **3** per the stricter-than-domain decision — confirm via the verify command.) Resultant-policy proof (`Get-ADUserResultantPasswordPolicy`) deferred to Stage 8 — no users yet.

### 🔎 Who runs this — admin account vs service account (design note, raised 07-21)
All GPO/PSO/DC work is currently done as the **built-in Administrator** — normal *bootstrap*, but not the end state. Two different identities, don't conflate them:
- **Human admin work (GPO/PSO/DC)** → a **tiered admin account** (`t0-seth`), created in **Stage 8**; built-in Administrator then becomes break-glass. Optional refinement: delegate GPO rights to a Tier-0 group (or the built-in `Group Policy Creator Owners`) instead of using full Domain Admin.
- **Service accounts (gMSA)** → non-interactive, **per-service** (NetBox, monitoring, backups), created as each service lands. A human editing GPOs does **not** use one.
Standard: Microsoft **AD tier model** + **Enterprise Access Model** (sources in `OU-Design-and-Build.md`).

## 7c. Windows LAPS ✅ (schema + self-perm + GPO device-verified 2026-07-22; member live-test deferred)
**What LAPS is:** Local Administrator Password Solution. Every Windows machine has a built-in **local Administrator**; imaging tends to give them all the *same* password → compromise one, pass-the-hash to all. LAPS makes each machine set a **unique, random** local-admin password, **auto-rotate** it, and store it **encrypted in AD** (the `msLAPS-*` attributes). Admins retrieve a machine's *current* password on demand; read is delegated (Tier-1 reads, Tier-2 doesn't). **Windows LAPS** is built into Server 2025 (no MSI). Manages member local admins here — and optionally the **DSRM** account on DCs (§7c-DSRM).

### Step 1 — extend the schema (one-time, forest-wide, PowerShell-only)
```powershell
Update-LapsADSchema        # adds msLAPS-* attributes; confirm Y / A (Yes-to-All)
```
Additive & safe; needs Schema Admin (built-in Administrator qualifies in a fresh forest). ✅ done 07-22 (Password, PasswordExpirationTime, Encrypted*, DSRM, version attributes).

### Step 2 — let machines write their own password (self-permission, scoped to Devices)
```powershell
Set-LapsADComputerSelfPermission -Identity "OU=Devices,DC=atlas,DC=lab"
```
Scoped to **Devices** (members) — **not** the DC OU (a promoted DC has no local admin to manage; DSRM is §7c-DSRM). ✅ done 07-22.

### Step 3 — the LAPS GPO (GUI-primary)
1. GPMC ▸ **Group Policy Objects ▸ New** ▸ `LAPS` ▸ **Edit**.
2. **Computer Config ▸ Policies ▸ Admin Templates ▸ System ▸ LAPS**.
3. **Configure password backup directory** = **Active Directory**.
4. **Password Settings** = length 20, all complexity sets, age 30 days.
5. Link `LAPS` to **OU=Devices**. *(Optional: GPO Status ▸ "User configuration settings disabled" — LAPS is computer-only, like the MSFT GPOs.)*
```powershell
New-GPO -Name "LAPS" | New-GPLink -Target "OU=Devices,DC=atlas,DC=lab" -LinkEnabled Yes
```
✅ Created + linked to **Devices** (Link Order 3) 07-22.

### Verify
```powershell
Get-Command -Module LAPS | Select Name
Get-LapsADPassword -Identity <server> -AsPlainText   # returns a password once a member joins Devices
```
- ✅ Schema / self-perm / GPO **device-verified**; module cmdlets present.
- ⏭ **Member live-password test deferred** — no member machine joined yet (same posture as the Member Server baseline).
- ⏭ **Tiered-read test (Stage 8):** `Set-LapsADReadPasswordPermission` to grant a **Tier-1** group read on `OU=Servers`; then prove a **Tier-2/helpdesk** account **cannot** read it — the checklist's flagship LAPS test.

## 7c-DSRM. LAPS-managed DSRM password on the DCs ✅ (fully device-verified 2026-07-22)
**DSRM = Directory Services Restore Mode** — a DC's recovery boot mode with its own local Administrator account, password set at promotion (the `POL-0002` "record it offline" item). Easy to lose exactly when a crisis needs it. LAPS can **manage + auto-rotate the DSRM password** and escrow it encrypted in AD — retrieve the current one with `Get-LapsADPassword` when needed. **This supersedes the manual `POL-0002` DSRM-record step.**

### Prereq — self-permission on the Domain Controllers OU
```powershell
Set-LapsADComputerSelfPermission -Identity "OU=Domain Controllers,DC=atlas,DC=lab"
```

### GPO — `LAPS-DC-DSRM` (a SEPARATE GPO from the member LAPS one)
1. New GPO `LAPS-DC-DSRM` ▸ Edit ▸ **Computer Config ▸ … ▸ System ▸ LAPS**.
2. **Configure password backup directory** = **Active Directory**.
3. 🔴 **Enable password backup for DSRM accounts** = **Enabled** (the DSRM-specific toggle — the whole point).
4. **Password Settings** = length 20, complexity, age 30.
5. Link to **OU=Domain Controllers**.
```powershell
New-GPO -Name "LAPS-DC-DSRM" | New-GPLink -Target "OU=Domain Controllers,DC=atlas,DC=lab" -LinkEnabled Yes
```

### Apply + verify (fully testable today — the DC is live)
```powershell
gpupdate /force
Invoke-LapsPolicyProcessing
Get-LapsADPassword -Identity DC01 -AsPlainText
```
- ✅ **Device-verified 07-22:** returns `Account = Administrator`, a rotated password, `Source = EncryptedDSRMPassword`, `DecryptionStatus = Success`, `AuthorizedDecryptor = ATLAS\Domain Admins`, 30-day expiry. **(Password value deliberately NOT recorded here — retrieve on demand.)** `POL-0002` manual DSRM-record item **retired**.
- 🔴 **Prereq met:** DSRM backup requires password **encryption** (DFL 2016+ — atlas.lab is 2025 ✓), encrypted to Domain Admins by default; later point *authorized decryptors* at a Tier-0 group.
- 🔴 **Op hygiene:** any LAPS password you copy out is burned — **force a rotation**: `Set-LapsADPasswordExpirationTime -Identity <name>` then `Invoke-LapsPolicyProcessing`.

## 7d. 🔴 Tier-deny logon GPOs (what actually *enforces* the tier model)
The OUs you built mean nothing to security until these exist. The technique (Microsoft-documented, Appendix D) uses **Deny logon user rights** so a tier's credentials **cannot authenticate** to other-tier systems.
- **The five logon rights** (all under `Computer Config ▸ Policies ▸ Windows Settings ▸ Security Settings ▸ Local Policies ▸ User Rights Assignment`):
  `Deny log on locally` · `Deny log on through Remote Desktop Services` · `Deny log on as a batch job` · `Deny log on as a service` · `Deny access to this computer from the network`.
- **The tier logic** (put the *other* tiers' admin groups into the Deny rights on each tier's computers). 🔗 **The groups these reference are built in Stage 8** — `G-Tier0-Admins` / `G-Tier1-Admins` / `G-Tier2-Admins` (see `Tiered-Admin-and-Groups-Build.md` §2a). Use those exact names:
  - GPO `Deny-Tier0-on-Lower` → linked to `Devices\Servers` + `Devices\Workstations`: deny **`G-Tier0-Admins`** those logon rights (a DC/PKI credential can't be harvested off a workstation).
  - GPO `Deny-Tier1-on-Tier0+2` → linked to the DC OU (via the **Default Domain Controllers** policy or a policy on that OU) + `Workstations`: deny **`G-Tier1-Admins`**.
  - GPO `Deny-Tier2-on-Tier0+1` → linked to `Servers` + the DC OU: deny **`G-Tier2-Admins`**.
- 🔴🔴 **Never link a deny-all-logon GPO at the domain level** — it can make even the built-in Administrator unusable, including in disaster recovery. Keep a tested **break-glass** account/path out of the deny scope, and **test with `gpresult` + a real logon attempt** on each tier before trusting it.
- 🔎 **What I'm giving vs. what to verify:** the *rights* and *technique* are Microsoft-exact; the precise **group-to-OU deny matrix** is what the tier-model repo scripts. Build it incrementally, test each with `gpresult`, or clone the repo to compare the exact GPOs.

## Verify (the whole stage)
- [ ] `Get-GPO -All | Select DisplayName` — small, purpose-named GPOs (no mega-GPO).
- [ ] `gpresult /h C:\rsop.html` on a server + a workstation — the right baseline/LAPS/tier GPOs win; nothing unexpected denied.
- [ ] `Get-ADUserResultantPasswordPolicy` for a Finance user → the PSO.
- [ ] 🔴 **Flagship test:** log a **Tier-2** account onto a **Tier-0** system → **denied** (capture it). Pair with the network-denial once segmentation (Phase 7) is live.

## Gotchas (the ones that cost real hours)
- **Security Filtering without Read** (post-2020) → GPO silently doesn't apply. Re-add Authenticated Users/Domain Computers with **Read** on Delegation.
- **Editing a baseline in place vs re-importing** — keep the vendor baseline GPO pristine; put your deviations in a *separate* overlay GPO so upgrades are clean.
- **Loopback left on / wrong mode** → user settings behave "weirdly" on servers/RDS.
- **Deny rights too broad / at domain root** → lockout. Scope by OU + group, keep break-glass out, test.
- **Trusting `show`/config instead of `gpresult`** → always read the *resultant* set, not the GPO's intended settings.

## Sources
**Microsoft Learn**
- Security Compliance Toolkit guide: https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/security-compliance-toolkit-10
- Security baselines guide: https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines
- Fine-grained password policies (ADAC): https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/adac/fine-grained-password-policies
- Deny logon user rights (Appendix D — technique): https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-d--securing-built-in-administrator-accounts-in-active-directory
- Windows LAPS (AD): https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory
- AD DS Tier Model: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/tier-model

**Downloads / repos**
- Security Compliance Toolkit 1.0 (download): https://www.microsoft.com/en-us/download/details.aspx?id=55319
- Microsoft Security Baselines blog: https://techcommunity.microsoft.com/t5/microsoft-security-baselines/bg-p/Microsoft-Security-Baselines
- AD Tier Model repo (exact tier GPOs/delegation): https://github.com/microsoft/ActiveDirectoryTierModel

**Local:** `303-Windows-Design-Standards.md` Part 6 (GPO baseline), `OU-Design-and-Build.md`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.7 | 2026-07-22 | **§7d made concrete + unblocked.** Stage 8 built the groups 7d denies, so replaced the abstract "Tier 0/1/2 admin group" placeholders with the exact names `G-Tier0-Admins` / `G-Tier1-Admins` / `G-Tier2-Admins` and pointed at `Tiered-Admin-and-Groups-Build.md` §2a. Status line updated (7d now unblocked). No 7d GPOs built yet — next session. |
| 0.1 | 2026-07-21 | Created — Part 1 GPO mental model (GPO-vs-link, computer/user, LSDOU precedence, Enforced/Block, loopback, security/WMI filtering + the post-2020 Read gotcha, `gpresult`/RSoP, design rules); Part 2 Stage-7 build (SCT baseline import via GPMC, Finance/HR PSO via ADAC + PowerShell, Windows LAPS, tier-deny logon GPOs with the five rights + tier logic + the never-at-domain-root warning). Honest confidence/sourcing notes; SCT download link; tier-deny wiring flagged for repo verification. |
| 0.2 | 2026-07-21 | **7a done — baseline imported & device-verified.** Rewrote 7a around the *actual* bulk import (`Baseline-ADImport.ps1` run from its `Scripts\` folder) incl. the recorded script + the "don't run its guts interactively" gotcha (empty `$MyInvocation.MyCommand.Path` → illegal-path throw; CWD-relative helper → null `$GpoMap`). Recorded the 8 imported GPO names (Server 2025 **v2602**) confirmed via `Get-GPO -All`. Added the authoritative **GPO→OU link map** (Domain Security→root order 1; DC + DC-VBS→Domain Controllers; Member Server + CredGuard→Devices\Servers; Defender AV→Devices+DC OU; IE11 Computer→Devices, User→Employees deferred), two-wave sequencing (VBS/CG held for a Proxmox VBS check), GUI+PowerShell (`New-GPLink`/`Set-GPLink`) steps, break-glass note, and 7a verify block. |
| 0.3 | 2026-07-21 | Added **§7a-LINK — GUI walkthrough** (GUI-primary, screenshot-marked with 📸 at each capture point) with the PowerShell equivalent inline at every step: open GPMC, Step 0 import proof, the reusable link gesture (Enforced off / Link Enabled on / leave Security Filtering default), steps ①–⑤ (Domain Security→root + set Link Order 1; Domain Controller; Member Server; Defender AV ×2; IE11-Computer), Step V verification (Inheritance tabs + `gpresult`/`Get-GPInheritance` + reboot with Proxmox console break-glass), and the Wave-B links gated on the `msinfo32` VBS check. Replaced the terse GUI paragraph. |
| 0.4 | 2026-07-21 | **Wave A applied & device-verified.** Recorded the `gpresult /r` proof on DC01 (Applied order: Domain Controller → Defender AV → Default DC Policy → Domain Security → Default Domain Policy; no lockout post-reboot). Noted the one build correction caught live: the Domain Controller baseline had been linked at the **domain root** by mistake → removed the root link (link ≠ GPO) and re-linked to the **Domain Controllers** OU at Link Order 1. Reaffirmed the rule: **only Domain Security is root-linked; every other baseline is per-OU.** Wave B still gated on the Proxmox VBS check. |
| 0.6 | 2026-07-22 | **7c + 7c-DSRM done.** §7c rewritten as a walkthrough (what-LAPS-is; schema `Update-LapsADSchema`, self-perm on Devices, `LAPS` GPO→Devices — all device-verified; member live-password + tiered-read tests deferred to Stage 8). Added **§7c-DSRM**: DSRM explainer + `LAPS-DC-DSRM` GPO (self-perm on the DC OU, "Enable password backup for DSRM accounts", link to Domain Controllers) — **fully device-verified** (`Get-LapsADPassword DC01` → `EncryptedDSRMPassword`, DecryptionStatus Success, Domain Admins decryptor, 30-day expiry; password value redacted). **`POL-0002` manual DSRM-record retired.** Op-hygiene note: rotate any copied LAPS password. Also set PSO lockout 3 (was 5). Logged Seth's ask for a later **Validation/adversarial-test (pen-test) pass**. |
| 0.5 | 2026-07-21 | **7b done — Finance/HR PSO built & device-verified.** Rewrote §7b as a GUI-primary (ADAC) + PowerShell walkthrough with 📸 marks: the "PSO = Password Settings Object, applies to a **group** not an OU" definition; **Step 0 measure the live domain default** (`Get-ADDefaultDomainPasswordPolicy` → min14/hist24/**42-day**/lockout**3**) with the honest "365+lockout5 is *looser* than the domain on two axes" gotcha and the tightest-group-vs-modern-NIST decision; `G-FinanceHR-Users` group build; `PSO-FinanceHR` (prec 10, min 15, 365-day, lockout **3**, applies-to the group); verify + device-verified readout. Added the **admin-account-vs-service-account** design note (bootstrap as built-in Administrator → tiered `t0-seth` in Stage 8; gMSA = per-service; GPO editing is an admin, not a service account). |
