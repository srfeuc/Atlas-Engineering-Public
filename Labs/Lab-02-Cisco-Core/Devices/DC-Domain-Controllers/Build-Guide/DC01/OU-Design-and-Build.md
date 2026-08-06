---
Title: OU Design & Build (atlas.lab) — Microsoft tier-model-aligned — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟡 LIVING (v0.4). 🔴 Entry **GATE** header added (`ADR-0043`). **GUI-primary + PowerShell.** The authoritative OU design + build for `atlas.lab`. `DC01-Build-Guide.md` Stage 6 points here; `303` Part 3 is the design rationale. Skeleton **built device-verified 2026-07-21**; **`Employees\IT` added 2026-07-22 (Stage 8)**.
Version: 0.4
Date: 2026-07-22
---

# OU Design & Build — atlas.lab

> 🔴 **GATE (when this runs)** — DC01 **Stage 6**: the domain `atlas.lab` is promoted (DC01 Stage 2 ✅). Build the OU tree **before** GPOs (Stage 7) or accounts (Stage 8).

## Purpose
One place for the Organizational Unit structure: **what** it is, **why** it's shaped this way (grounded in Microsoft's documented guidance), and **how** to build it (PowerShell for the bulk, GUI for one department as a learning exercise). Source of truth for the OU tree — the DC guide references it rather than duplicating it.

## 🔎 How we know this is "right" (provenance — read this)
There is **no single OU tree Microsoft mandates.** Two things are true and combine here:
1. **The Microsoft AD Tier Model** prescribes the *administrative-separation principles* — Tier 0/1/2, higher-tier credentials never exposed to lower tiers, DCs stay in the built-in `Domain Controllers` OU, a computer **staging** OU. It governs the **`Admin`** subtree.
2. **Microsoft's OU-design guidance** is explicit that the **functional layout is yours to design** for *delegation and GPO scoping* — **not the org chart**. That's the `Employees`/`Devices`/`Groups` portion (`303` Part 3).

So "the right way" = **follow the principles** (this tree does); the tier-model repo's exact tree is *one valid instantiation*.

🔴 **Honesty about sourcing:** aligned to Microsoft's **documented** model + the repo's **confirmed shape** (Tier 0/1/2 + per-tier PAWs; deploy order OUs → Groups → Users → Delegation → GPOs). **Not** byte-for-byte the repo's script output (its exact `../../plan.md`/JSON isn't on the public doc pages). **Verify against the primary sources below** — worth doing for ownership; for the strict output, clone the repo and run its deployment in a test forest.

## 🔴 Reserved-name rule (device-learned 2026-07-21)
**You cannot create a root OU named `Computers` or `Users`** — they collide with the built-in `CN=Computers` / `CN=Users` containers and fail with `8305 "name already in use"`. This tree therefore uses **`Devices`** (servers/workstations) and **`Employees`** (user departments). *(Alternative pattern: put everything under one top-level org OU, e.g. `OU=Atlas`, and then `Computers`/`Users` are legal as its children — but our `Admin`/`Groups`/`Disabled Objects` were already created at the root, so we keep a flat root and rename the two reserved ones.)*

## Design principles this obeys
- **Role/administration-based, not departmental** — OUs are for delegation + GPO targeting; *department = group membership*.
- **Tiered admin** — `Admin\Tier 0/1/2`; anything that can manage Tier 0 (incl. a DC-resident service account) *is* Tier 0.
- 🔴 **DCs stay in the built-in `Domain Controllers` OU** — moving them breaks default DC GPO.
- **New-computer quarantine** — `Devices\Staging` + `redircmp` so machines get a baseline GPO on join.
- **`Disabled Objects`** — offboarding staging before deletion.

## The target tree (as built)
```
atlas.lab
├── Admin                          🔺 (303 had "_Admin")
│   ├── Tier 0  → Accounts / Groups / Service Accounts / PAW
│   ├── Tier 1  → Accounts / Groups / Service Accounts / PAW
│   └── Tier 2  → Accounts / Groups / PAW
│        🔺 service accounts live IN their tier (was flat in 303); PAW OUs created even if real PAWs are deferred
├── Devices                        🔺 renamed from "Computers" (reserved at root)
│   ├── Staging                    🔺 new-computer quarantine (redircmp target)
│   ├── Servers → File-Print / App-Servers / Infra
│   └── Workstations → Standard / Executive / Kiosk-Shared
├── Employees                      🔺 renamed from "Users" (reserved at root)
│   └── Sales / Marketing / Engineering / Support / Finance / HR / Operations / Executive / IT   🔺 (IT added 2026-07-22, Stage 8 — home for daily `seth` + the 8-person IT dept per 301/303)
├── Groups → Security-Roles / Distribution
└── Disabled Objects
```
> 🔺 = stricter than / changed from `303` Part 3 as written (tiered service accounts, PAW OUs, `Staging`, and the `Devices`/`Employees` renames).

### Strictness decision (explicit choice)
- **Aligned (what we build):** full `Admin` tier structure incl. per-tier Service Accounts + **PAW OUs created** (real PAW *machines* deferred in a solo lab).
- **Strict repo version:** also auto-creates the tier **GPOs, delegation ACLs, Protected-Users** wiring — run the repo's deployment if you want that. `303` Part 5 deliberately scales this down for 150 people.

## Build — PowerShell (everything except `Marketing`)
`Marketing` is omitted so you build it by hand in the GUI (below).
```powershell
$base = "DC=atlas,DC=lab"
function NewOU($n,$p){ New-ADOrganizationalUnit -Name $n -Path $p }   # protect-from-deletion ON by default
# Admin (tier model)
NewOU "Admin" $base
"Tier 0","Tier 1","Tier 2" | % { NewOU $_ "OU=Admin,$base" }
foreach($t in "Tier 0","Tier 1"){ "Accounts","Groups","Service Accounts","PAW" | % { NewOU $_ "OU=$t,OU=Admin,$base" } }
"Accounts","Groups","PAW" | % { NewOU $_ "OU=Tier 2,OU=Admin,$base" }
# Devices  (NOT "Computers" — reserved at root)
NewOU "Devices" $base
"Staging","Servers","Workstations" | % { NewOU $_ "OU=Devices,$base" }
"File-Print","App-Servers","Infra" | % { NewOU $_ "OU=Servers,OU=Devices,$base" }
"Standard","Executive","Kiosk-Shared" | % { NewOU $_ "OU=Workstations,OU=Devices,$base" }
# Employees  (NOT "Users" — reserved at root) — Marketing omitted for the GUI
NewOU "Employees" $base
"Sales","Engineering","Support","Finance","HR","Operations","Executive" | % { NewOU $_ "OU=Employees,$base" }
NewOU "IT" "OU=Employees,$base"   # 🔺 added 2026-07-22 (Stage 8) — home for daily `seth` + the 8-person IT dept (301/303)
# Groups + Disabled Objects
NewOU "Groups" $base
"Security-Roles","Distribution" | % { NewOU $_ "OU=Groups,$base" }
NewOU "Disabled Objects" $base
# Redirect new domain-joined computers into Staging
redircmp "OU=Staging,OU=Devices,$base"
```

## Build — GUI (the `Marketing` OU: your screenshot walkthrough)
1. Server Manager ▸ **Tools ▸ Active Directory Users and Computers** (`dsa.msc`).
2. *(Optional)* **View ▸ Advanced Features** — reveals all containers + attribute/security tabs.
3. Expand `atlas.lab`, **right-click the `Employees` OU ▸ New ▸ Organizational Unit**.
4. Name `Marketing`; leave **"Protect container from accidental deletion"** ✅ checked ▸ **OK**.
5. Move a user in later: right-click the user ▸ **Move…** (or drag).

## 🔴 OUs / objects that need special treatment
- **Root name collision:** never name a root OU `Computers`/`Users` → use `Devices`/`Employees` (or a top org OU). *(The rule above.)*
- **Domain Controllers (built-in):** DCs *are* Tier 0 but **stay in `Domain Controllers`** — never move them.
- **Devices\Staging:** `redircmp "OU=Staging,OU=Devices,$base"` so new joins get a baseline GPO, not the un-linkable default `Computers` container.
- **Finance & HR:** stricter password policy via a **PSO** (fine-grained, on a group), not a per-OU GPO.
- **Workstations\Executive:** a deliberately *looser* GPO baseline — document *why*.
- **Sales:** field/inside split handled with **groups** (`G-Sales-Field`/`G-Sales-Inside`), not sub-OUs.
- **Service Accounts (per-tier):** a Tier 0 service account *is* Tier 0; gMSA default, `Legacy` = documented exceptions only.

## Verify
- [ ] `Get-ADOrganizationalUnit -Filter * | Select Name,DistinguishedName` matches the tree.
- [ ] DCs still under the built-in `Domain Controllers` OU.
- [ ] `Get-ADDomain | Select ComputersContainer` → `OU=Staging,OU=Devices,DC=atlas,DC=lab` (redircmp set).

## Sources
**Microsoft Learn**
- AD DS Tier Model: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/tier-model
- Reviewing OU Design Concepts: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/reviewing-ou-design-concepts
- Creating an OU Design: https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/creating-an-organizational-unit-design
- Enterprise Access Model: https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-access-model

**Microsoft AD Tier Model (the repo — authoritative, verify the exact tree here)**
- GitHub repo: https://github.com/microsoft/ActiveDirectoryTierModel
- Deployment site: https://microsoft.github.io/ActiveDirectoryTierModel/
- Quick Deployment Guide: https://microsoft.github.io/ActiveDirectoryTierModel/quick-deployment-guide/
- Detailed Deployment Guide: https://microsoft.github.io/ActiveDirectoryTierModel/detailed-deployment-guide/

**Local design rationale:** `303-Windows-Design-Standards.md` Part 3 (OUs), Part 5 (tiering).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-21 | Created — split out of the DC01 guide Stage 6. Microsoft tier-model-aligned tree + provenance/verify-it-yourself section + repo links. |
| 0.3 | 2026-07-22 | **Added `OU=IT,OU=Employees`** (Stage 8) — home for the daily `seth` account and the 8-person IT dept (`301`/`303`); the tree diagram + build script updated. 🔎 Reminder from execution: a *standard* daily account belongs in the **Employees** tree, not `Admin\Tier 2\Accounts` (the Admin tree is for privileged identities) — `seth` was initially mis-placed in `Tier 2\Admin` and is being moved here. |
| 0.2 | 2026-07-21 | **Built on the device** — corrected the `8305` reserved-name failure: root OUs `Computers`/`Users` collide with the built-in containers → renamed to **`Devices`**/**`Employees`** (documented the rule + the top-org-OU alternative). Fixed the script + `redircmp` path accordingly. `Admin`+tiers, `Groups`, `Disabled Objects` created first-try. |
