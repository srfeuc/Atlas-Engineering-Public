---
Title: Atlas Company Profile
Path: 00-Atlas-Foundation/Company-Profile
---

# Atlas — Company Profile

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Target Design |
| Evidence Source | Fictional. This is the scenario the environment is built to serve. |
| Version | 1.2 |
| Applies To | Book 3 (Windows Infrastructure), Book 4 (Identity and PKI), Book 8 (Labs) |
| Bound To | `305-Atlas-Industrial-Security-Requirements.md` — the segmentation & defence half (read as a pair) |

## Why This Document Exists First

You cannot design an OU tree, a group strategy, or a GPO baseline for a company that doesn't exist. Every design decision downstream — *why role-based OUs and not departmental ones, why Finance needs a PSO, why the shop floor breaks your naming convention* — only has a right answer once there is a company with real shape.

**This company is deliberately messy.** A clean org chart teaches nothing. Every awkward thing below is there because it forces a real design decision that a tidy fiction would let you skip.

> ## ⛓ This document is bound to `305-Atlas-Industrial-Security-Requirements.md`
>
> **Neither document is complete without the other. Read them as one.**
>
> This document is the **identity half**: who Atlas is, and how the 156 people, the acquisition, the ghosts, and the SQL→AD pipeline are provisioned. It deliberately stops at the network's edge — it justifies *the OU tree and the PSO*, not *the firewall and the OT boundary*.
>
> `305` is the **segmentation-and-defence half**: once these identities and this data exist, how are they classified, zoned, isolated, and proven contained? It supplies the OT zone this document's VLAN table is missing, the data classification that writes the East-West Allowed-Flows Matrix, the compliance obligations (PCI-DSS, PII, cyber-insurance → CIS v8 IG1) that make segmentation mandatory, and it re-reads the audit findings below (the Reeves Domain Admins, the ghosts, the shared kiosk logins, the scanner) as blast-radius problems.
>
> **The pairing:** add a department here and it needs a zone there; add a zone there and it needs a data owner here. The two are versioned as a pair — change one and you almost certainly touch the other.

---

## The Company

**Atlas Industrial** — a regional manufacturer and distributor of industrial components.

| Item | Value |
|---|---|
| Headcount | 156 |
| Sites | HQ (corporate + engineering), Plant (production + warehouse) — same campus, one network |
| Core business system | **AtlasERP** — line-of-business app on SQL Server. Orders, inventory, production scheduling. The company stops if it stops. |
| IT team | 8 people, in-house, no MSP |
| Age | 40 years old. Which is why everything is the way it is. |

Atlas makes physical things. That matters more than it sounds — it means a large chunk of the workforce **does not sit at a desk, does not have email, and shares a login with four other people.** Every "just create a user account" assumption breaks on the shop floor, and that is the point.

---

## Headcount by Department

| Department | Heads | The thing it teaches you |
|---|---|---|
| **Executive** | 5 | The exception problem. Someone will demand a carve-out from the password policy. |
| **Finance & Accounting** | 10 | Needs a stricter password policy than the domain default. So does HR. **Two departments, one requirement.** |
| **Human Resources** | 5 | Same PSO as Finance. Owns the HR database that AD is provisioned from. |
| **Sales** | 22 | **Split personality:** 12 field reps (laptops, VPN, BitLocker, roaming) + 10 inside sales (desktops, on-site). **Same department. Completely different machine policy.** |
| **Marketing** | 6 | Needs internet access no one else does. Adobe licensing. |
| **Customer Service** | 12 | Desk-bound, high turnover, shift work. Frequent onboard/offboard — your SOP gets tested here. |
| **Engineering (product design)** | 18 | CAD workstations. Expensive, licensed, non-standard hardware. A GPO that suits Finance will wreck these. |
| **IT** | 8 | Tier 0 / 1 / 2 lives here. See below. |
| **Production (shop floor)** | 45 | **The big one.** Mostly shared kiosk accounts. No email. No individual login for most. |
| **Warehouse & Logistics** | 15 | Handheld scanners. Ruggedized devices. A service account nobody remembers creating. |
| **Quality Assurance** | 6 | Needs read access to production *and* engineering data. Cross-departmental by nature. |
| **Facilities** | 4 | Badge system, HVAC controls. Owns a Windows box in a cupboard nobody has patched since 2019. |
| **Total** | **156** | |

---

## The Six Deliberate Problems

Each of these exists to force a design decision. **None of them are optional flavour.**

### 1. Sales proves departmental OUs are wrong

Sales is one department containing **two entirely different machine profiles.** Field reps need BitLocker, VPN, offline files, aggressive screen-lock. Inside sales need none of that and will hate all of it.

Meanwhile **Finance and HR — two separate departments — need the identical stricter password policy.**

Build a departmental OU tree and you will find yourself linking one GPO to two OUs and splitting one OU across two GPOs. **You cannot fix it by moving OUs around. The model is wrong.** Role-based OUs (`Workstations` / `Laptops` / `Kiosks`, and `Users` / `Privileged` / `Service`) make both problems disappear.

**You will only feel this if the data is real.** Three test users won't do it. 156 will.

### 2. The shop floor breaks "one user, one account"

45 production staff. **8 shared kiosk logins** (`PROD-LINE1` … `PROD-LINE8`). No email. No individual identity.

This is a real thing real manufacturers really do, and it teaches more than any lab exercise:

- Kiosk GPO lockdown — no control panel, no USB, auto-logon, forced reboot at shift end
- **You cannot audit "who did it."** Eight people share `PROD-LINE3`. When something goes wrong, the log says `PROD-LINE3`. That is a *security finding*, and writing it up is the lesson.
- The pressure to fix it (badge-based logon, individual accounts) versus the reality (the line stops if login takes 40 seconds)

### 3. IT is where Tier 0 actually gets tested

Eight people. Each needs **more than one account**:

| Role | Heads | Accounts |
|---|---|---|
| IT Manager | 1 | Standard user + Tier 1 |
| Sysadmin | 2 | Standard user + **Tier 0** (Domain Admin) |
| Helpdesk | 3 | Standard user + **Tier 2** (reset passwords, unlock — *scoped to one OU only*) |
| Application/DB | 2 | Standard user + Tier 1 + SQL admin |

**Twenty-plus accounts for eight humans.** That's what AGDLP and tiering are actually for, and it's invisible until you build it.

The lab that matters: **prove a Helpdesk Tier 2 account cannot touch a Tier 0 object.** Not assert it. Prove it, with the failure message as evidence.

### 4. The acquisition (this is the best one)

**Eighteen months ago, Atlas bought Reeves Fastening — 12 people.**

Their accounts were created in a hurry, by someone who has since left:

- They live in the default `CN=Users` container, not in any OU
- Their naming convention is `firstinitial-lastname` (`jsmith`), not Atlas's `first.last`
- Three have `Domain Admins` membership "temporarily," granted during the migration
- Their `Description` fields say things like `TEMP - fix later`
- One is a shared account, `reeves-office`, that four people still use

**Every MSP inherits exactly this, on day one, from every client.** This is the highest-value thing in the entire scenario:

- You cannot bulk-move them without breaking something
- You must decide: rename to the Atlas convention (breaking their profiles) or grandfather them (breaking your convention)
- **You must find the three Domain Admins nobody remembers granting.** That's a genuinely good PowerShell exercise and a genuinely good interview story.

### 5. The ghosts

**Five accounts belong to people who left.** Still enabled. Still in groups. One still has a mailbox. One is a manager whose account is used by their replacement *because nobody wanted to re-do the permissions.*

Teaches: stale-account auditing (`LastLogonTimestamp`), why offboarding needs to be a documented SOP and not a favour, and why "just use their account" is how breaches happen.

### 6. The names that break your script

Seed these deliberately. **They will break a naive provisioning script, and that is the point:**

| Problem | Example | What breaks |
|---|---|---|
| Collision | Two people named John Smith | `first.last` isn't unique |
| Apostrophe | Siobhan O'Brien | Naive T-SQL and PowerShell string handling |
| Hyphen | Marie-Claire Dubois-Fontaine | Length + character handling |
| **Too long** | Konstantinos Papadopoulos-Georgiou | **`sAMAccountName` is capped at 20 characters.** This one bites everyone, once. |
| Diacritics | José Ramírez | UPN vs sAMAccountName encoding |
| Single name | A contractor with one legal name | Your schema assumed two |

### 7. Contractors

**Six contractors.** Two engineering, two IT (a SQL consultant and a network contractor), two temp Customer Service for the busy season.

Every one needs an **account expiration date**. Every one will be forgotten if you don't build the expiry in at creation. That's `AccountExpirationDate`, a `Contractors` OU, and a scheduled report.

---

## Service Accounts

The ones a real company has, and the ones a real audit finds:

| Account | Runs | The lesson |
|---|---|---|
| `svc-atlaserp` | AtlasERP app pool → SQL | **gMSA candidate.** Should be. Probably isn't yet. |
| `svc-sqlengine` | SQL Server service | gMSA. Requires KDS root key + a real propagation delay. |
| `svc-backup` | Backup agent | Needs high privilege. Classic Tier 0 leak. |
| `svc-monitoring` | LibreNMS / Wazuh agents | Read-only. Prove it. |
| `svc-scanner` | **The multifunction printer's scan-to-folder account** | Password set in 2018. Written on a sticky note by the printer. It has more file-share access than the CFO. **Every company has this account.** |

---

## The SQL Layer — Reinforcing What You Asked For

**Don't provision AD from a CSV. Provision it from the HR database.** That's what actually happens, and it's a far better artifact.

### `SQL01` → database `AtlasHR`

```sql
CREATE TABLE Employees (
    EmployeeID      INT IDENTITY PRIMARY KEY,
    FirstName       NVARCHAR(50)  NOT NULL,
    LastName        NVARCHAR(50)  NOT NULL,
    PreferredName   NVARCHAR(50)  NULL,
    Department      NVARCHAR(50)  NOT NULL,
    JobTitle        NVARCHAR(100) NOT NULL,
    ManagerID       INT NULL REFERENCES Employees(EmployeeID),
    EmployeeType    NVARCHAR(20)  NOT NULL,   -- Employee | Contractor | Shared | Service
    WorkLocation    NVARCHAR(50)  NOT NULL,   -- HQ | Plant | Field | Remote
    HireDate        DATE NOT NULL,
    TerminationDate DATE NULL,
    IsActive        BIT NOT NULL DEFAULT 1,
    SourceSystem    NVARCHAR(30)  NOT NULL DEFAULT 'AtlasHR'  -- or 'ReevesLegacy'
);
```

That `ManagerID` self-reference gives you a real org hierarchy — which means **recursive CTEs**, which is exactly the SQL you should be able to write and most people can't.

### The pipeline

```
AtlasHR (SQL)  ->  Get-AtlasNewHires.ps1  ->  New-ADUser  ->  Set-ADUser -Manager
                        |
                        +-> writes back the resulting sAMAccountName to SQL
```

**Write-back matters.** Now SQL knows the AD account name, so the *next* run can detect changes and terminations rather than blindly recreating everyone. That single design decision is the difference between a script and a **sync**.

### SQL exercises that fall straight out of this

1. **Recursive CTE** — full reporting chain for any employee, up to the CEO.
2. **The offboarding query** — everyone with `TerminationDate` in the past and `IsActive = 1`. That's your five ghosts. Reconcile against AD.
3. **The collision query** — find every duplicate `first.last`. Write the tiebreak rule.
4. **The 20-char problem** — find every name whose generated `sAMAccountName` would exceed the limit, *before* you try to create it.
5. **Source-system audit** — everyone where `SourceSystem = 'ReevesLegacy'`. That's your acquisition cleanup list.
6. **The gap report** — accounts in AD with no matching row in SQL. **These are the ones nobody can explain.** Orphaned accounts are how attackers stay resident.

That last query is a genuinely good interview answer: *"I built a reconciliation between the HR system of record and Active Directory, and reported on anything that existed in one but not the other."*

---

## How This Maps to the Existing Lab

| Atlas VLAN | Who lives there | Now justified by |
|---|---|---|
| 10 Management | Infrastructure | IT (8) |
| 20 Servers | DC01/02, SQL01, FS01, WS01 | AtlasERP, AtlasHR |
| 30 Web | AtlasERP web front end | Sales + Customer Service use it |
| 40 Monitoring | Wazuh, LibreNMS, Grafana | `svc-monitoring` |
| 50 Clients | Desks | ~95 corporate users |
| 60 Deployment | WDS/MDT | **Imaging the CAD workstations and the kiosks** |
| 70 Testing | Isolated | Test the ERP upgrade before it kills the company |
| 80 DMZ | Customer order portal | External-facing |

**The VLANs were designed before the company existed. They now all have a reason to exist.** That closes a real gap — right now VLAN 60 and 70 are empty because nothing needed them.

---

## Build Order

1. **Company profile** — this document. Do not skip to the fun part.
2. **`SQL01` + `AtlasHR`** — populate 156 employees, *including* the mess above.
3. **OU design** — role-based. Justify it against the Sales split and the Finance/HR PSO overlap.
4. **The provisioning script** — SQL → AD. It *will* break on O'Brien and Papadopoulos-Georgiou. Fix it. That's the exercise.
5. **The Reeves cleanup** — a real migration project, with a change record.
6. **Groups (AGDLP), then GPOs, then LAPS.**
7. **Onboard and offboard one person, end to end** — as an SOP a colleague could follow.

---

## Related Pages

- **`00-Atlas-Foundation/Company-Profile/305-Atlas-Industrial-Security-Requirements.md` — the security & segmentation half. This document is bound to it; read them as a pair.**
- `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/README.md` — Book 3's target reader test
- `00-Atlas-Foundation/Roadmap/Atlas-Roadmap.md`
- `08-Labs/README.md` — Sections 1 and 2 all assume this company exists *(🔴 #22 audit 2026-07-30: this link target does not exist — no `08-Labs/` dir; needs repointing to the current labs index → Backlog #29)*

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial company profile. Every awkward element (the acquisition, the shop floor, the ghosts, the name collisions) is deliberate — a tidy org chart teaches nothing, and the design decisions in Book 3 only have right answers once the mess is real. |
| 1.1 | 2026-07-16. Bound this document to its new security & segmentation companion, `305-Atlas-Industrial-Security-Requirements.md`. Added the reciprocal "bound together" callout after the intro and the cross-reference in Related Pages. `301` remains the identity half; `305` is the segmentation-and-defence half; the two are versioned and read as a pair. |
| 1.2 | 2026-07-30. **#22-audit currency fix (nav only — content unchanged).** Corrected the stale frontmatter `Path` (`Windows Infrastructure` → `00-Atlas-Foundation/Company-Profile`) and repointed the broken `Windows-Environment-Roadmap.md` link to its successor `Roadmap/Atlas-Roadmap.md`. Flagged the remaining broken `08-Labs/README.md` link inline (no successor found → Backlog #29). The VLAN tables, the "Book N" scheme, and all narrative were left untouched (a fuller Foundation-doc currency audit is Backlog #29). |
