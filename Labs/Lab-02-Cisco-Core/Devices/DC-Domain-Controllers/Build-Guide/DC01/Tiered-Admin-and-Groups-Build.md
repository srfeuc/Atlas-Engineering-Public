---
Title: Tiered Admin, AGDLP Groups & DC02 — Design & Build (atlas.lab) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 LIVING (v0.7). 🔴 Entry **GATE** header added (`ADR-0043`). **GUI-FIRST (ADUC/ADAC) — every step is a full click-path; PowerShell is optional and clearly labeled.** Stage 8 — the AGDLP groups (incl. the Tier 0/1/2 admin groups that GPO **7d** denies cross-tier), the tiered admin accounts (`t0-seth`/`t1-seth`/`seth`), and getting Tier-0 work **off the built-in Administrator**. **DC02 has its own `../DC02/DC02-Build-Guide.md`** (Part 4 here is a pointer, POL-0008). **Progress: ✅ Part 2 (groups) + ✅ Part 3 (tiered accounts · off-built-in-Administrator · Protected Users) FULLY device-verified 2026-07-22. Remaining: tiered LAPS read test (§3g — needs a member server); DC02 promotion (`../DC02/DC02-Build-Guide.md`).** `../../Build-Checklist.md` §7–8 and `GPO-Design-and-Build.md` §7d point here; `303` Parts 4–5 are the design rationale.
Version: 0.7
Date: 2026-07-22
---

# Stage 8 — Tiered Admin, AGDLP Groups & DC02

> **Why this page exists:** Stage 7 built the *policy* (baselines, PSO, LAPS). Stage 8 builds the *identities that policy protects* — the groups and the tiered admin accounts — and adds the second DC so a 156-person company isn't running on one. This is also the page that finally gets us **off the built-in Administrator** and creates the exact groups the **7d tier-deny GPOs** will reference. Do §1–§2 (model + groups) before §3 (accounts), because every account gets dropped into the right group *at creation*, never retrofitted (`303` Part 7 order: groups → users).

> 🖱 **GUI-first, on purpose.** Every build step below is a **complete ADUC/ADAC click-path** — that's how this gets done in a real shop, and it's how you build the muscle memory. The wizards also guardrail you (valid scopes, name checks) in a way raw PowerShell doesn't. **PowerShell is included only as an optional "same thing, one line" block you can skip.** 📸 = screenshot point.

> 🔴 **GATE (when this runs)** — DC01 **Stage 8**: OUs exist (Stage 6 ✅). Order: groups (Part 2) → accounts (Part 3); enables GPO **7d**. DC02 promotion → `../DC02/DC02-Build-Guide.md`.

## 🔎 Confidence & sourcing (honest)
- **AGDLP** and the **tier-model three commandments** are core, stable Microsoft guidance (`303` Parts 4–5; Microsoft Learn links at the bottom) — high confidence.
- **The exact group *names*** (`G-Tier0-Admins`, …) are **my convention**, consistent with the repo's existing `G-*`/`DL-*` names and with what 7d needs. Microsoft's AD Tier Model repo uses its own names — if you later run that repo's deployment, reconcile the names (POL-0008). What matters is that **whatever 7d denies is exactly what §2 creates**.
- **Protected Users** behavior (Kerberos-only, no NTLM/RC4/DES, no unconstrained delegation) is Microsoft-documented; the *lockout risk* callout is the real-world caution.
- 🔴 **Nothing here is device-verified yet.** Treat this whole page as "authored, awaiting execution." Run it, then we mark state.

---

# Part 1 — The mental model (read first)

## 1.1 AGDLP — the group rule that never changes
**A**ccounts → **G**lobal groups → **D**omain **L**ocal groups → **P**ermissions. Read it as a pipeline:

- **Accounts** go into **Global groups**. Global = **"who someone is"** — a *role* or *department*. `G-Finance`, `G-Sales`, `G-Tier0-Admins`.
- **Global groups** nest into **Domain Local groups**. Domain Local = **"what a resource grants"** — access to one thing. `DL-FileShare-Finance-RW`, `DL-Printer-3rdFloor`.
- **Permissions** (an ACL on a folder/printer/share) are assigned to the **Domain Local group** — **never to a user, never to a global group directly.**

Why bother, especially solo? Because it makes access **auditable and durable**: "who can write to the Finance share?" is answered by looking at *one* DL group's members, and a new Finance hire gets access by joining *one* global group (`G-Finance`), not by touching any ACL. The indirection is the whole point.

> **The one-line test:** if you're about to put a *user* on an ACL, or grant a *global* group NTFS rights directly, stop — you skipped the DL layer.

**Naming convention for atlas.lab (this is the standard — use it everywhere):**

| Prefix | Scope | Means | Examples |
|---|---|---|---|
| `G-` | Global, Security | Role / department (who you are) | `G-Finance`, `G-Sales`, `G-IT-Staff`, `G-Tier0-Admins` |
| `DL-` | Domain Local, Security | Resource access (what you can touch) | `DL-FileShare-Finance-RW`, `DL-FileShare-Finance-RO` |
| `PSO-`… on a `G-` | — | Fine-grained password policy applies to a **global** group | `PSO-FinanceHR` → `G-FinanceHR-Users` (already built, §7b) |

*(`G-FinanceHR-Users` already exists from the 7b PSO work — it's the first real global group in the domain. A fine template for the rest.)*

## 1.2 Where the tier admin groups fit AGDLP
The **tier admin groups** (`G-Tier0-Admins` etc.) are **global role groups** — "who is a Tier-0 admin." They're used two ways:

1. **As the deny-logon subject (7d).** The five *Deny log on* user rights are a **User Rights Assignment** — a *permission on the computer*. Microsoft's tier-deny technique puts the **global** tier-admin group directly into those deny rights on the *other* tiers' machines. So the URA references `G-Tier0-Admins` **directly**, not via a DL group — the one place a global group lands on a "resource" without a DL wrapper, because the assignment is per-computer-set via the GPO's OU link, not a shared ACL.
2. **As a delegation subject (later).** When we delegate ("Tier-1 admins manage `Devices\Servers`"), *that* follows full AGDLP — the global tier group nests into a DL group that holds the delegated rights. Built when member servers exist.

So: **create the tier groups as global now** (§2); 7d consumes them directly; DL wrappers come with resources.

## 1.3 The tier model — the three commandments (`303` Part 5)
1. A **higher-tier credential must never be exposed to a lower-tier system.** (Don't log `t0-seth` onto a workstation.)
2. **Lower tiers consume higher-tier *services* (GPO, DNS), never the reverse.**
3. **Anything that can administer a tier *is* that tier** — a backup agent running as SYSTEM on a DC is Tier 0, whether you meant it or not.

Scaled to Atlas (solo operator playing all three silos, `ADR-0024`):

| Tier | Systems | Admin identity | Daily use of that identity |
|---|---|---|---|
| **Tier 0** | DCs, AD CS (later) | `t0-seth` | **DC/PKI admin only.** No browsing, no email, never logs onto a workstation/server. |
| **Tier 1** | Member servers (file, app, NetBox, monitoring) | `t1-seth` | Server admin only. Not a Domain Admin. |
| **Tier 2** | Workstations, end users | standard `seth` | Daily driver — email, browsing, docs. No local admin. |

You holding all three named accounts instead of three people holding one each **is** least-privilege for a solo admin — not a compromise (`303` Part 5).

---

# Part 2 — Build the AGDLP groups (GUI-first)

## 2.0 Open your console (do this once)
1. On **DC01**: **Server Manager ▸ Tools ▸ Active Directory Users and Computers** (or Start ▸ type `dsa.msc`). 📸
2. In ADUC, turn on **View ▸ Advanced Features** — reveals the Attribute Editor + all containers (you'll want it in §3e). Leave it on.
3. Expand **`atlas.lab`** in the left tree. You'll see `Admin`, `Devices`, `Employees`, `Groups`, `Disabled Objects` (the OU skeleton from Stage 6).

> 🖱 **Two beginner facts the wizards don't tell you:**
> - The **New Group** and **New User** wizards have **no Description box**. You set the description *afterward*: right-click the object ▸ **Properties ▸ General ▸ Description**. Descriptions are optional but recommended (they show in any list/audit) — do them once the object exists.
> - **"Check Names"** (in any Add… dialog) resolves what you typed against AD. If it underlines/resolves, you typed a real object; if it errors, you have a typo. Always click it before OK.

## 2a. The tier admin groups — the 7d prerequisite (do this first) — ✅ device-verified 2026-07-22
These three global groups are the **entire reason** 7d is gated on Stage 8. Each goes in its own tier's `Groups` OU.

**GUI — `G-Tier0-Admins`:**
1. In the tree, expand **`atlas.lab ▸ Admin ▸ Tier 0`** and click the **`Groups`** OU. 📸
2. Right-click **`Groups`** ▸ **New ▸ Group**. 📸
3. **Group name:** `G-Tier0-Admins`. (The *pre-Windows 2000* box auto-fills — leave it.)
4. **Group scope: Global.** **Group type: Security.** ▸ **OK**. 📸
5. Right-click the new **`G-Tier0-Admins`** ▸ **Properties ▸ General**, set **Description** = `Tier 0 administrators (DCs/PKI). Denied logon on Tier 1 + Tier 2 by GPO 7d.` ▸ **OK**.

**GUI — repeat for the other two** (identical steps, different OU + name + description):
- **`G-Tier1-Admins`** in **`Admin ▸ Tier 1 ▸ Groups`** — scope **Global**, type **Security**. Description: `Tier 1 administrators (member servers). Denied logon on Tier 0 (DCs) + Tier 2 by GPO 7d.` 📸
- **`G-Tier2-Admins`** in **`Admin ▸ Tier 2 ▸ Groups`** — scope **Global**, type **Security**. Description: `Tier 2 / helpdesk-delegated admins. Denied logon on Tier 0 + Tier 1 by GPO 7d.` 📸

<details><summary>PowerShell equivalent (optional — skip if you're GUI-only)</summary>

```powershell
Import-Module ActiveDirectory
$root="DC=atlas,DC=lab"
New-ADGroup -Name "G-Tier0-Admins" -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=Tier 0,OU=Admin,$root" -Description "Tier 0 administrators (DCs/PKI). Denied logon on Tier 1 + Tier 2 by GPO 7d."
New-ADGroup -Name "G-Tier1-Admins" -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=Tier 1,OU=Admin,$root" -Description "Tier 1 administrators (member servers). Denied logon on Tier 0 (DCs) + Tier 2 by GPO 7d."
New-ADGroup -Name "G-Tier2-Admins" -GroupScope Global -GroupCategory Security -Path "OU=Groups,OU=Tier 2,OU=Admin,$root" -Description "Tier 2 / helpdesk-delegated admins. Denied logon on Tier 0 + Tier 1 by GPO 7d."
```
</details>

> 🔎 **`G-Tier2-Admins` vs standard users:** most Tier-2 identities are *plain users* with no local admin (the highest-value, most-skipped control — `303` Part 5). `G-Tier2-Admins` is for the *delegated helpdesk role* — it exists now so 7d can deny it upward, even though we won't populate it until there's a helpdesk to model. Standard `seth` (§3) does **not** go in it.

**7d wiring these enable (next session — don't build here):** `Deny-Tier0-on-Lower` denies `G-Tier0-Admins` on `Devices\Servers` + `Devices\Workstations`; `Deny-Tier1-on-Tier0+2` denies `G-Tier1-Admins` on the DC OU + `Workstations`; `Deny-Tier2-on-Tier0+1` denies `G-Tier2-Admins` on `Servers` + the DC OU. (Detail in `GPO-Design-and-Build.md` §7d.)

## 2b. A role global for IT staff (home for the daily account) — ✅ device-verified 2026-07-22 (see placement nit in Verify)
Daily `seth` is a standard user, but an IT-staff role global is useful for future GPO filtering / app targeting.

**GUI:**
1. Expand **`atlas.lab ▸ Groups`** and click the **`Security-Roles`** OU.
2. Right-click **`Security-Roles`** ▸ **New ▸ Group** ▸ name `G-IT-Staff`, scope **Global**, type **Security** ▸ **OK**. 📸
3. Properties ▸ Description = `IT department staff (role/dept global, AGDLP). Non-privileged.`

<details><summary>PowerShell equivalent (optional)</summary>

```powershell
New-ADGroup -Name "G-IT-Staff" -GroupScope Global -GroupCategory Security -Path "OU=Security-Roles,OU=Groups,$root" -Description "IT department staff (role/dept global, AGDLP). Non-privileged."
```
</details>

## 2c. AGDLP demonstrated end-to-end (reference — build with file services, not now)
On record for when the file server lands (`303` Part 7 step 8). Example: a Finance read/write share.

**GUI (the pattern — do it later):**
1. `G-Finance` (Global) already exists from the user population.
2. In **`Groups ▸ Security-Roles`** ▸ **New ▸ Group** ▸ `DL-FileShare-Finance-RW`, scope **Domain local**, type **Security**.
3. Open **`DL-FileShare-Finance-RW` ▸ Properties ▸ Members ▸ Add…** ▸ type `G-Finance` ▸ **Check Names** ▸ OK. *(Global nests into Domain Local.)*
4. **On the file server:** the folder's **Security** tab ▸ **Edit ▸ Add** ▸ `DL-FileShare-Finance-RW` ▸ grant **Modify**. Never the user, never `G-Finance`.

The whole model: **user ∈ G-Finance ∈ DL-FileShare-Finance-RW → NTFS Modify.** Change access by group membership; never touch the ACL again.

### Verify (Part 2) — GUI — ✅ device-verified 2026-07-22
- In the ADUC tree, confirm `G-Tier0-Admins`, `G-Tier1-Admins`, `G-Tier2-Admins` each sit under their tier's `Groups` OU, and `G-IT-Staff` under `Groups\Security-Roles`. 📸
- Double-click each ▸ the **General** tab shows **Group scope = Global**, **Group type = Security**.

- ✅ **Verified 07-22** — `Get-ADGroup -Filter 'Name -like "G-*"'` returned all four **Global / Security** in the right OUs: `G-Tier0-Admins`→`OU=Groups,OU=Tier 0,OU=Admin`, `G-Tier1-Admins`→`Tier 1`, `G-Tier2-Admins`→`Tier 2` (+ the pre-existing `G-FinanceHR-Users` in `Security-Roles`).
- 🔎 **Placement nit caught on verify:** `G-IT-Staff` was created at `CN=G-IT-Staff,OU=Groups` (the `Groups` root) instead of the intended `OU=Groups,OU=Security-Roles` (where `G-FinanceHR-Users` correctly lives). Non-blocking; **recommended fix** = ADUC ▸ right-click `G-IT-Staff` ▸ **Move…** ▸ `Groups\Security-Roles`. *(Once moved, its DN matches this doc's §2b as authored.)*

<details><summary>PowerShell verify (optional)</summary>

```powershell
Get-ADGroup -Filter 'Name -like "G-*"' | Select Name, GroupScope, GroupCategory, DistinguishedName
```
</details>

---

# Part 3 — Tiered admin accounts + getting off the built-in Administrator (GUI-first)

Order matters: **create the accounts → put them in the right groups → *test logon* → only then rely on them and set the built-in Administrator aside.** Skipping the logon test before you stop using Administrator is how you lock yourself out of your own domain.

## 3a. Create the `IT` OU (decided: `OU=IT,OU=Employees`)
Daily `seth` is a standard Tier-2 user → it lives in the **Employees** tree. There's no `IT` OU there yet (`301`/`303` set IT = 8), so create it first.

**GUI:**
1. Expand **`atlas.lab`** ▸ right-click the **`Employees`** OU ▸ **New ▸ Organizational Unit**. 📸
2. **Name:** `IT`. Leave **"Protect container from accidental deletion" ✅ checked** ▸ **OK**.

🔴 This is a tree change — once it exists, tell the bot and it updates `OU-Design-and-Build.md` (POL-0008). Don't double-create if it's already there (check the tree first).

<details><summary>PowerShell equivalent (optional)</summary>

```powershell
New-ADOrganizationalUnit -Name "IT" -Path "OU=Employees,DC=atlas,DC=lab"   # protect-from-deletion ON by default
```
</details>

## 3b. Create the three accounts
🔴 **Set a strong unique password per account** (≥15 chars for the domain baseline) **at the console — never paste passwords into chat** (the DSRM exposure is the cautionary tale).

**GUI — `t0-seth` (the New User wizard):**
1. Expand **`atlas.lab ▸ Admin ▸ Tier 0`** ▸ click the **`Accounts`** OU ▸ right-click ▸ **New ▸ User**. 📸
2. **Full name:** `t0-seth`. **User logon name:** `t0-seth` (`@atlas.lab`). The pre-Windows-2000 (`sAMAccountName`) auto-fills to `t0-seth`. ▸ **Next**. 📸
3. **Password / Confirm:** type your chosen password. Checkboxes:
   - **Uncheck** "User must change password at next logon" (you're setting your own admin password).
   - Leave "User cannot change password" and "Password never expires" **unchecked** (let it follow policy).
   - Leave "Account is disabled" **unchecked**.
   ▸ **Next ▸ Finish**. 📸
4. Right-click `t0-seth` ▸ **Properties ▸ General ▸ Description** = `TIER 0 admin (DC/PKI only). Never log onto Tier 1/2 systems.` ▸ OK.

**GUI — repeat for the other two:**
- **`t1-seth`** in **`Admin ▸ Tier 1 ▸ Accounts`** — same wizard. Description: `TIER 1 admin (member servers only). Not a Domain Admin.` 📸
- **`seth`** (Full name `Seth (daily)`, logon name `seth`) in **`Employees ▸ IT`** — same wizard. Description: `Standard daily-driver account (Tier 2). No admin rights.` 📸

<details><summary>PowerShell equivalent (optional — you'll be prompted for each password)</summary>

```powershell
$root="DC=atlas,DC=lab"
New-ADUser -Name "t0-seth" -SamAccountName "t0-seth" -UserPrincipalName "t0-seth@atlas.lab" -Path "OU=Accounts,OU=Tier 0,OU=Admin,$root" -Enabled $true -AccountPassword (Read-Host -AsSecureString "t0-seth pw") -Description "TIER 0 admin (DC/PKI only). Never log onto Tier 1/2 systems."
New-ADUser -Name "t1-seth" -SamAccountName "t1-seth" -UserPrincipalName "t1-seth@atlas.lab" -Path "OU=Accounts,OU=Tier 1,OU=Admin,$root" -Enabled $true -AccountPassword (Read-Host -AsSecureString "t1-seth pw") -Description "TIER 1 admin (member servers only). Not a Domain Admin."
New-ADUser -Name "Seth (daily)" -SamAccountName "seth" -UserPrincipalName "seth@atlas.lab" -Path "OU=IT,OU=Employees,$root" -Enabled $true -AccountPassword (Read-Host -AsSecureString "seth pw") -Description "Standard daily-driver account (Tier 2). No admin rights."
```
</details>

## 3c. Group membership — the privilege wiring (the important part)
🔴 **The key distinction:** `G-Tier0-Admins` is the **identity marker** (what 7d denies on lower tiers). **Domain Admins** is the **actual privilege** that lets you administer DCs. `t0-seth` needs **both**. Do **not** nest `G-Tier0-Admins` *into* Domain Admins — keep Domain Admins membership explicit and near-empty (the Reeves lesson).

**GUI — the one gesture, done from each user's `Member Of` tab:**

*`t0-seth`* (needs Domain Admins **and** G-Tier0-Admins):
1. Double-click **`t0-seth`** ▸ **Member Of** tab ▸ **Add…**. 📸
2. Type `Domain Admins` ▸ **Check Names** ▸ **OK**.
3. **Add…** again ▸ type `G-Tier0-Admins` ▸ **Check Names** ▸ **OK** ▸ **Apply**. 📸 (Member Of now lists Domain Admins + G-Tier0-Admins + the default Domain Users.)

*`t1-seth`* (identity marker only — **not** a Domain Admin):
1. Double-click **`t1-seth`** ▸ **Member Of ▸ Add…** ▸ `G-Tier1-Admins` ▸ Check Names ▸ OK ▸ Apply. 📸

*`seth`* (role group only — stays a plain user):
1. Double-click **`seth`** ▸ **Member Of ▸ Add…** ▸ `G-IT-Staff` ▸ Check Names ▸ OK ▸ Apply.

> 🖱 Same result the other way: open the **group** ▸ **Members ▸ Add**. The `Member Of` path is easier here because you touch each user once and add all its groups.

<details><summary>PowerShell equivalent (optional)</summary>

```powershell
Add-ADGroupMember -Identity "Domain Admins"  -Members "t0-seth"    # actual Tier-0 privilege
Add-ADGroupMember -Identity "G-Tier0-Admins" -Members "t0-seth"    # tier identity marker (7d)
Add-ADGroupMember -Identity "G-Tier1-Admins" -Members "t1-seth"    # marker only — NOT a DA
Add-ADGroupMember -Identity "G-IT-Staff"     -Members "seth"
```
</details>

> **Why t1-seth isn't a Domain Admin:** Tier 1 admins get power from *delegated rights on `Devices\Servers`* (scoped), not domain-wide admin. No member servers exist yet, so t1-seth is intentionally low-privilege today — it becomes useful when servers land and we delegate to `G-Tier1-Admins`.
> **Enterprise/Schema Admins:** leave empty for daily work. If you need a schema change later, add `t0-seth` *for the task* and remove it after.

## 3d. 🔒 Test logon BEFORE trusting the switch (do not skip)
1. **Sign out**, then sign back into **DC01** (console or RDP) as **`ATLAS\t0-seth`** with the password you set. 📸
2. Open **Server Manager ▸ Tools ▸ Active Directory Users and Computers**. Prove you can edit: right-click any OU ▸ **New ▸ Organizational Unit** ▸ name it `zz-test`, then right-click `zz-test` ▸ **Delete**. If both worked, `t0-seth` has real admin. 📸
3. **Confirm its group membership (GUI):** in ADUC find `t0-seth` ▸ **Properties ▸ Member Of** — you should see **Domain Admins** and **G-Tier0-Admins**.
4. *(Optional certainty — one built-in command, not a script):* open **Command Prompt** and run `whoami /groups` — look for `Domain Admins` and `G-Tier0-Admins` in the token. This reads the *actual logged-on token*, which is the real proof (the Member Of tab shows assignment; the token shows what's active this session).

Only once `t0-seth` demonstrably administers the DC do you move to 3e.

## 3e. Get **off** the built-in Administrator (secure it as break-glass)
The built-in Administrator (RID 500) becomes **emergency-only** — not deleted, not daily. Keep it as tested break-glass, secured, unused.

**GUI:**
1. In ADUC (Advanced Features on, from §2.0), click the **`Users`** container under `atlas.lab`. Find the built-in Administrator.
   - 🔎 **Identifying it for sure:** the MSFT baseline *may have renamed* it, so don't trust the name alone. The built-in one is the account in **`CN=Users`** whose **Description** reads *"Built-in account for administering the computer/domain"*, and which has **no Delete option** (it's protected). To be 100% sure: right-click ▸ **Properties ▸ Attribute Editor** ▸ scroll to **`objectSid`** — the real one ends in **`-500`**. 📸
2. **Reset its password to something long (25+ chars):** right-click the account ▸ **Reset Password…** ▸ type a long random value ▸ OK. 🔴 Store it **offline / in your break-glass record only** — not in the repo, not in chat.
3. **Stop using it interactively.** From now on: `t0-seth` for Tier-0, `t1-seth` for Tier-1, `seth` for daily.
4. 🔴 **Do NOT disable it.** Right-click ▸ the account must stay **enabled** (no "Disable Account"). RID-500 is exempt from lockout and is your ultimate recovery path if the tier accounts break — leave it **enabled but idle**. (LAPS does **not** manage this — it's a *domain* account; the 7c LAPS/DSRM work covered *local*/DSRM admins, a different thing.)
5. 🔴 **Keep it OUT of Protected Users** (§3f) — never subject your break-glass account to Kerberos-only constraints during a disaster.

<details><summary>PowerShell equivalent — just the "which account is RID-500" lookup (optional)</summary>

```powershell
Get-ADUser -Filter * -Properties SID | Where-Object { $_.SID -like "*-500" } | Select Name, SamAccountName, Enabled
```
</details>

## 3f. (Recommended, with a caveat) Add the admin accounts to Protected Users
**Protected Users** is a built-in group that hard-blocks the credential-theft techniques tier-0 accounts are targeted by: **no NTLM, no RC4/DES, no unconstrained delegation, no long-lived TGTs, no cached logon.** For a fresh 2025-forest doing interactive DC admin, this is exactly right.

**GUI:**
1. In **`CN=Users`**, double-click **`Protected Users`** ▸ **Members ▸ Add…**. 📸
2. Type `t0-seth` ▸ Check Names ▸ then `; t1-seth` ▸ Check Names ▸ **OK ▸ Apply**. (Add **both** admin accounts; **not** the RID-500 account, **not** — for now — daily `seth`.)

🔴 **Caveat / sequencing:** Protected Users **removes NTLM fallback** — if anything these accounts touch relies on NTLM, logon fails with confusing errors. So **add them only after §3d proved Kerberos logon works**, keep the built-in Administrator (NTLM-capable, outside the group) as the escape hatch, and **if `t0-seth` logon breaks afterward**, remove it again: from a break-glass session, `Protected Users ▸ Members ▸ select t0-seth ▸ Remove`. Leave daily `seth` out for now.

<details><summary>PowerShell equivalent (optional)</summary>

```powershell
Add-ADGroupMember -Identity "Protected Users" -Members "t0-seth","t1-seth"   # NOT the RID-500 acct
# rollback if logon breaks:  Remove-ADGroupMember -Identity "Protected Users" -Members "t0-seth"
```
</details>

## 3g. Tiered LAPS read grant — now unblocked (closes a 7c deferral) — *later, needs a member server*
7c deferred "prove Tier-1 reads a machine's LAPS password and Tier-2 can't" because the tier groups didn't exist. They do now. This grants `G-Tier1-Admins` permission to read LAPS passwords on the `Servers` OU.

**GUI (Delegation of Control Wizard):**
1. In ADUC, expand **`Devices`** ▸ right-click the **`Servers`** OU ▸ **Delegate Control…** ▸ **Next**.
2. **Add…** ▸ `G-Tier1-Admins` ▸ Check Names ▸ OK ▸ **Next**.
3. **Create a custom task to delegate** ▸ Next ▸ **Only the following objects in the folder: ✅ Computer objects** ▸ Next.
4. Permissions: **✅ Property-specific** ▸ scroll and tick **Read msLAPS-Password** (and **Read msLAPS-EncryptedPassword** if present) ▸ **Next ▸ Finish**. 📸

> 🖱 **Honesty:** this one wizard is fiddly (a long attribute list), and it's the single step where the cmdlet below is genuinely cleaner and less error-prone. Either works; if the wizard's attribute list is overwhelming, use the one-liner.

<details><summary>PowerShell equivalent (optional — cleaner for this one)</summary>

```powershell
Set-LapsADReadPasswordPermission -Identity "OU=Servers,OU=Devices,DC=atlas,DC=lab" -AllowedPrincipals "G-Tier1-Admins"
```
</details>

Then (once a member server has joined and has a LAPS password) the flagship check: signed in as `t1-seth`, retrieve it and confirm a Tier-2/helpdesk account **cannot**. (LAPS retrieval context in `GPO-Design-and-Build.md` §7c.)

### Verify (Part 3) — GUI — 🔄 mostly device-verified 2026-07-22
> ✅ **Verified 07-22:** accounts created + enabled in their OUs; membership exactly right (`t0-seth`=Domain Admins+`G-Tier0-Admins`, `t1-seth`=`G-Tier1-Admins` only, `seth`=`G-IT-Staff`); Protected Users = t0+t1 (not RID-500); Enterprise/Schema Admins clean (only built-in Administrator); **logon test as `t0-seth` passed** (done *before* adding Protected Users — correct order). 🔎 **Protected-Users lesson:** `t0-seth` then couldn't RDP a DC **by IP** ("account restriction") — Protected Users blocks NTLM, and IP-based RDP forces NTLM. Administer via the **PAW** (Kerberos, by name) or console; don't remove from Protected Users. (This is why `PAW01-Tier0-Admin/Build-Guide.md` exists.)
> ✅ **Closed out 2026-07-22:** (1) `seth` **moved to `Employees\IT`** (out of the Admin tree — standard users belong in Employees); (2) **§3e** — built-in Administrator **rotated** (`PasswordLastSet` 07-22 14:40, still **Enabled**, `PasswordNeverExpires` set, password in **Vaultwarden** break-glass — not the repo/chat); (3) `G-IT-Staff` **moved to `Groups\Security-Roles`** (matches `G-FinanceHR-Users`). `Move-ADObject` used for the two moves — note the interactive `if/else`-on-separate-lines paste trap (run the move directly, or keep `if…else` on one line).

- **`t0-seth` ▸ Member Of** → Domain Admins + G-Tier0-Admins (+ Domain Users). 📸
- **`t1-seth` ▸ Member Of** → G-Tier1-Admins (+ Domain Users), **no** Domain Admins.
- **`seth` ▸ Member Of** → G-IT-Staff (+ Domain Users).
- **`Protected Users` ▸ Members** → t0-seth, t1-seth (**not** the RID-500 account).
- **Domain Admins ▸ Members** → t0-seth + the built-in Administrator only — keep it TIGHT.
- The built-in Administrator (`CN=Users`, RID-500) is **enabled**, password reset, unused.
- [ ] `t0-seth` administers DC01 (proved in §3d).
- [ ] 🔴 The **cross-tier deny** isn't real until **7d** — an account being "Tier 1" only *means* something once the deny-logon GPOs exist. Stage 8 makes the accounts and groups; **7d makes the boundary enforceable**; the flagship "Tier-2 can't touch Tier-0" proof lives in `Operations/Validation-and-Adversarial-Testing.md`.

<details><summary>PowerShell verify (optional)</summary>

```powershell
Get-ADGroupMember "Domain Admins"
Get-ADUser t0-seth -Properties MemberOf | Select -Expand MemberOf
Get-ADUser t1-seth -Properties MemberOf | Select -Expand MemberOf
Get-ADUser seth    -Properties MemberOf | Select -Expand MemberOf
Get-ADGroupMember "Protected Users"
```
</details>

---

# Part 4 — DC02 (second domain controller) → see `DC02-Build-Guide.md`

A 156-person company on a single DC is not a credible design (`301`) — one reboot or disk fault and the whole company can't authenticate. DC02 (`10.20.0.3`, VLAN 20, gw `10.20.0.1`) is part of Stage 8, but it's a substantial replica-DC build with its own traps (replica-not-forest, DNS island, `DOMHIER` time, FSMO, auto-inherited DC-OU policy), so it lives in its **own dedicated living guide** — the single source (POL-0008):

> 📄 **`DC02-Build-Guide.md`** (this folder) — VM prep → promote as a *replica* (Server Manager wizard, **not** a new forest) → `DOMHIER` time → DNS steady-state → the full `repadmin`/`dcdiag`/DFSR replication-verify pass → FSMO map + LAPS/baseline inheritance. Also GUI-first.

**The one Stage-8 dependency to note here:** run DC02's promotion as **`t0-seth`** (§3) — it's Tier-0 work and needs a Domain Admin credential. If you build DC02 before the tiered accounts exist, the built-in Administrator is the bootstrap. Everything else is in the DC02 guide.

## Failure modes (Stage 8 — accounts & groups)
- 🔴 **Nesting a custom group into Domain Admins** — makes privilege implicit and un-auditable. Keep Domain Admins membership explicit + near-empty.
- 🔴 **Stopping use of the built-in Administrator before testing `t0-seth`** — a password typo or missing Domain Admin membership locks you out. Test first (§3d).
- 🔴 **Disabling the built-in Administrator** — you lose your break-glass. Secure it, don't disable it.
- 🔴 **Protected Users before confirming Kerberos** — NTLM removal causes opaque logon failures. Add after §3d; keep break-glass out of the group.
- 🔴 **Creating a group with the wrong scope** — the New Group wizard defaults to **Global**; that's right for `G-*` but if you ever build a `DL-*` you must switch it to **Domain local**. Scope can be changed later in Properties, but get it right at creation.
- 🔴 **Treating "Tier 1/2" as enforced after Stage 8** — the *labels* exist now, the *boundary* doesn't until 7d.
- 🔴 *(DC02-specific failure modes live in `DC02-Build-Guide.md`.)*

## What Stage 8 unblocks (for the next session)
- **7d tier-deny logon GPOs** — now have real groups (`G-Tier0/1/2-Admins`) to reference. The flagship enforcement.
- **Hardening Pass 2** — AD/LDAPS-backed admin auth on FGT01 + network devices can now use real tiered accounts.
- **User population** (`301` SQL→AD) — the role globals (`G-Finance`, `G-Sales`, …) and the `Employees\IT` OU pattern established here are the template.
- **Tiered LAPS read proof** — §3g grant is in place; finish it when a member server exists.

## Sources
**Microsoft Learn**
- AGDLP / group scopes: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups
- Create a new group (ADUC): https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups
- AD DS Tier Model: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/tier-model
- Enterprise Access Model: https://learn.microsoft.com/en-us/security/privileged-access/privileged-access-access-model
- Protected Users security group: https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/protected-users-security-group
- Securing built-in Administrator (Appendix D — the deny-logon technique 7d uses): https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-d--securing-built-in-administrator-accounts-in-active-directory
- Delegating admin (Delegation of Control Wizard): https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/delegating-administration-of-account-ous-and-resource-ous
- Windows LAPS (read permission): https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory

**Repos**
- Microsoft AD Tier Model (reconcile exact group names if you run its deployment): https://github.com/microsoft/ActiveDirectoryTierModel

**Local:** `303-Windows-Design-Standards.md` Parts 4–5; `OU-Design-and-Build.md` (the OU tree these land in); `GPO-Design-and-Build.md` §7c (LAPS) + §7d (tier-deny, the consumer of these groups); `Operations/Validation-and-Adversarial-Testing.md` (the flagship cross-tier proof).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.6 | 2026-07-22 | **Part 3 fully closed out (device-verified).** `seth` moved to `Employees\IT`; `G-IT-Staff` moved to `Security-Roles`; built-in Administrator rotated + parked (Enabled, PasswordNeverExpires, password in Vaultwarden). Part 3 is done — remaining Stage-8 = tiered LAPS read test (needs a member server) + DC02 promotion. |
| 0.5 | 2026-07-22 | **Part 3 accounts device-verified (mostly).** `t0/t1-seth`+`seth` created, membership + Protected Users + logon-test confirmed; EA/SA clean. Recorded the **Protected-Users-vs-RDP-by-IP** lesson (→ use the PAW/Kerberos) in the Part-3 verify. Flagged the 3 open items: move `seth`→`Employees\IT` (was mis-placed in `Tier 2\Admin`), §3e rotate/park the built-in Administrator, move `G-IT-Staff`→`Security-Roles`. |
| 0.4 | 2026-07-22 | **Part 2 (groups) device-verified.** `G-Tier0/1/2-Admins` + `G-IT-Staff` created, all Global/Security, tier groups in the right tier `Groups` OUs (`Get-ADGroup` readout captured in Verify). 🔎 Caught a placement nit: `G-IT-Staff` landed in `OU=Groups` root instead of `OU=Groups\Security-Roles` — recommended a GUI **Move** to align with `G-FinanceHR-Users`. §2a/§2b marked ✅; status → Part 2 done / Part 3 pending. |
| 0.3 | 2026-07-22 | **Reworked GUI-FIRST per Seth's request** — every build step is now a complete ADUC/ADAC click-path (open-console + Advanced Features preamble; the "wizards have no Description box / use Check Names" beginner facts; per-group and per-account wizard walkthroughs; membership via each user's **Member Of** tab; the RID-500 identification via Description/no-Delete/`objectSid`-ends-500 and **Reset Password**; Protected Users via the **Members** tab with a GUI rollback; the LAPS read grant via the **Delegation of Control Wizard**, with an honest "the cmdlet is cleaner here" note; GUI verify read-backs). PowerShell demoted into optional collapsible "equivalent" blocks. `IT` OU decision resolved to `OU=IT,OU=Employees` (§3a is now a build step, not a decision). Added a wrong-group-scope failure mode. |
| 0.2 | 2026-07-22 | **DC02 split out to its own `DC02-Build-Guide.md`** (POL-0008 single source) — Part 4 here is now a concise pointer keeping only the Stage-8 dependency (promote as `t0-seth`). Trimmed the DC02-specific failure modes. Header/status updated. |
| 0.1 | 2026-07-22 | Created — Stage 8, authored (not yet device-executed, POL-0001). Part 1 AGDLP + tier-model model; Part 2 build of `G-Tier0/1/2-Admins` + `G-IT-Staff` + AGDLP DL example; Part 3 tiered accounts, the Domain-Admins-vs-tier-group distinction, logon-test-before-switch, off-the-built-in-Administrator, Protected Users, the tiered LAPS read grant; Part 4 DC02 (since split out). |
