# Atlas Windows Environment Roadmap

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Purpose

This is the plan for building out Atlas's Windows/Identity environment (Roadmap Phases 3 and 4) as a realistic simulation of a ~100-150 person company, informed by how real companies that size actually run IT — not just "what AD features exist." The goal, per your framing: build the environment first, then use Atlas itself as the base to simulate operating as an MSP.

Everything in here is a plan to work from, not something already built. Nothing gets implemented until we validate it against the live environment, same as every other pack.

---

## Part 1 — Defining Atlas as a Company (so the AD design has something real to model)

> 🔴 **Superseded by `301-Atlas-Company-Profile.md` (`ADR-0008`).** `301` is the authoritative company definition (Atlas Industrial, 156 people, the department table with real headcounts). The proposed table below is retained only as the *origin* of that decision — do not treat its numbers as current. The one genuine conflict it raised — IT headcount — is now settled by **`ADR-0024`** (see the IT row).

You can't design OUs, groups, or delegation sensibly without deciding who works at Atlas. Real 100-150 person companies at this size typically run a flat-ish functional structure — a handful of departments, not deep hierarchy. Proposed department breakdown for Atlas (adjust however you like, this is a starting point):

| Department | Approx. Headcount | Notes |
|---|---|---|
| Executive | 3-5 | CEO, COO, CFO, maybe VP Eng |
| IT | **8** (see `ADR-0024`) | 🔴 **Corrected.** `301` sets **IT: 8** — required to teach Tier 0/1/2, AGDLP, and delegated administration, none of which are teachable with one admin. The earlier "1" is retired as the *scenario* headcount by `ADR-0024`. Its two truths are preserved there: the **lab is operated by one person playing all silos** (`ADR-0018`), and the **MSP premise** (a 150-person shop with thin IT is exactly who hires an MSP) is kept as scenario framing. |
| Sales | 20-25 | Often the largest single department at this size |
| Marketing | 8-12 | |
| Engineering/Product | 25-35 | If Atlas is a tech company; adjust per whatever Atlas "does" |
| Customer Support | 15-20 | |
| Finance/Accounting | 6-10 | Higher compliance/access-control needs — relevant later for delegation design |
| HR | 4-6 | Same — sensitive data owner |
| Operations/Facilities | 5-8 | |

**Decide what Atlas actually does** as a company (SaaS product, consulting, manufacturing, whatever) — it changes what "Engineering" means and what line-of-business apps show up later. Not required to start the AD design, but worth pinning down before Phase 8 labs need it.

---

## Part 2 — Forest and Domain Design

**Recommendation: single forest, single domain.** Real-world guidance (including Microsoft's own) is explicit that multi-domain forests only make sense past tens of thousands of users or dozens of physical sites needing independent replication boundaries — neither applies to a 150-person single-site (or lightly multi-site) company. A second domain here would be complexity for its own sake, not realism.

| Decision | Value |
|---|---|
| Forest/domain name | 🔴 **`atlas.lab`** — decided by `ADR-0007` (committed) and now the live AD forest root (✅ DC01 promoted `atlas.lab`, device-verified 2026-07-21; resolves via AD DNS). Never use a name that resolves publicly; `.lab` satisfies it. ⚠️ **Naming nuance:** the AD domain is `atlas.lab`, but the **legacy OpenSSL device certs are still branded `<device>.lab`** (renaming to `<device>.atlas.lab` is deferred to the next cert renewal — `ADR-0007`), so match what's on the wire per device when you build. |
| Number of domains | 1 |
| DC count (target state) | 2 minimum, for redundancy — DC01 promoted (device-verified 2026-07-21); **DC02 promoted replica — operator-reported 2026-07-28, `repadmin`/`dcdiag` read-back pending** |
| Site design | Single AD Site initially. If Atlas later gets a "branch office" for lab purposes (e.g., simulating a second location on a different VLAN or over the eventual Azure VPN), that's when Sites and Services and a second subnet-mapped site become relevant — not before. |

---

## Part 3 — OU Structure

Real-world guidance strongly favors **role-based OU design over department-based**, because Group Policy is what actually needs to target OUs cleanly, and GPO targeting cares about *what a computer/user needs applied to it*, not what department they're in. Department is usually handled by **group membership**, not OU placement. This is a common mistake — building an OU tree that mirrors the org chart looks intuitive but makes GPO management worse, not better.

Proposed top-level structure:

```
atlas.lab
├── _Admin                    (Tier 0/1 — see Part 5)
│   ├── Tier0-Accounts
│   ├── Tier0-Groups
│   ├── Tier1-Accounts
│   └── Tier1-Groups
├── Service Accounts
│   ├── gMSA
│   └── Legacy (documented exceptions only — see Part 4)
├── Computers
│   ├── Servers
│   │   ├── Domain Controllers   (built-in OU, don't move DCs out of Domain Controllers OU — breaks default DC GPO application)
│   │   ├── File-Print
│   │   ├── App-Servers
│   │   └── Infra                (monitoring, RADIUS/NPS if it moves here later, etc.)
│   └── Workstations
│       ├── Standard
│       ├── Executive             (different GPO baseline — less restrictive for exec laptops is a real, common exception, document it as a deliberate decision, not a hole)
│       └── Kiosk-Shared          (if relevant — shared front-desk machines etc.)
├── Users
│   ├── Sales
│   ├── Marketing
│   ├── Engineering
│   ├── Support
│   ├── Finance
│   ├── HR
│   ├── Operations
│   └── Executive
├── Groups
│   ├── Security-Roles           (AGDLP resource-access groups — see Part 4)
│   └── Distribution              (email distribution lists, not security)
└── Disabled Objects              (staging for offboarded users/computers before deletion — never delete immediately)
```

Notes on this structure:
- **`_Admin` sorts first alphabetically** — deliberate, so it's always at the top of any AD tool's tree view. Small thing, real practice.
- **Department OUs under Users exist for delegation and organization, not primarily for GPO targeting** — most GPOs will target higher up (domain root, or the Computers/Users split) or via **group-based filtering (Group Policy Security Filtering)**, which is more flexible than OU-based targeting alone.
- **Disabled Objects OU** — standard practice: disable, move here, wait a retention period (30-90 days is typical), then delete. Never delete an offboarded account same-day; this is both a security control (revoke access immediately) and an operational safety net (undo an accidental termination).

---

## Part 4 — Groups and Service Accounts

### Group strategy: AGDLP (or AGUDLP with universal groups, irrelevant at single-domain scale)

**A**ccounts → **G**lobal groups → **D**omain **L**ocal groups → **P**ermissions. In practice at this scale:
- **Global groups** = role/department membership (`G-Sales`, `G-Finance`, `G-Engineering`)
- **Domain Local groups** = resource access (`DL-FileShare-Finance-RW`, `DL-Printer-3rdFloor`)
- Global groups get nested into Domain Local groups; permissions get assigned to Domain Local groups, never directly to users. This is the actual, durable best practice — not just an exam answer.

### Service accounts

This is the part you specifically flagged wanting to understand. Real guidance is clear and current:

- **Default to gMSA (group Managed Service Account)** for any service that supports it — automatic 240-byte random password, rotated every 30 days by Windows itself, no human ever knows or manages the password. This should be the default choice, not the exception.
- **Use sMSA only** for a single-server service that doesn't support gMSA but does support standalone managed accounts.
- **Fall back to a traditional user-account-as-service-account only when neither is supported** — and if you land here, that's a flag to document *why*, since it's the exception, not the norm, in a modern build.
- **Failover clustering does not support gMSA** — relevant later if Atlas ever builds a clustered file server or SQL AG for the lab.
- Prerequisite before any gMSA work: a **KDS root key** must exist in the domain (one-time setup, `Add-KdsRootKey`) — do this early, it has a propagation delay (10 hours by default) that trips people up if left until the moment a gMSA is actually needed.

**Naming convention recommendation:** prefix service accounts clearly, e.g. `svc-gmsa-<purpose>` — makes them instantly recognizable in any list, audit log, or GPO security filter, separate from human accounts.

---

## Part 5 — Tiered Administration (scaled down, not skipped)

> 🎓 **Concept companion (Academy):** for the plain-language "why three tiers / why a Tier-2 login on a DC is the whole ballgame," see `Atlas-Academy/Concepts/Tiered-Admin-Model.md` — the tier model taught through Atlas's own `t0/t1/t2-seth` accounts, Protected Users, the PAW, and the 7d deny-logon GPOs.

Microsoft's current model here is the **Enterprise Access Model (EAM)**, which replaced the older ESAE "Red Forest" approach a few years back. Full EAM is built for large, complex hybrid estates — genuinely overkill to build byte-for-byte at 150 people. But the **underlying three commandments still apply at any size**, and are worth building into Atlas deliberately rather than skipping because "we're small":

1. Credentials from a higher tier must never be exposed to a lower-tier system.
2. Lower-tier systems can consume higher-tier services (e.g., everything still gets Group Policy from Tier 0), never the reverse.
3. Anything that can manage a higher tier *is* that tier, whether you meant it to be or not (this is the one people miss — e.g., a backup agent running as SYSTEM on a domain controller is a Tier 0 system, full stop, even if nobody thought of it that way).

**Practical scoped-down version for Atlas:**

| Tier | What's in it | Practical control at this scale |
|---|---|---|
| Tier 0 | Domain Controllers, AD CS (if built), the accounts that administer them | Separate admin accounts (`t0-yourname`), never used for anything but DC/PKI admin. No browsing, no email, no daily-driver use on these credentials. |
| Tier 1 | Member servers — file server, future app servers, PVE01-equivalent if it were Windows | Separate admin accounts (`t1-yourname`), scoped via delegation, not Domain Admin membership. |
| Tier 2 | Workstations, end users | Standard user accounts, no local admin by default (this alone is one of the highest-value, most commonly-skipped controls in small-company IT) |

You being the sole engineer doesn't remove the value of this — it just means *you* hold three different named accounts (`t0-seth`, `t1-seth`, standard `seth`) instead of three different people holding one tier each. That's a realistic and common small-company pattern, not a compromise — it's exactly what "least privilege even when you're the only admin" looks like in practice.

---

## Part 6 — Group Policy Baseline

Recommended starting GPO set (build these as separate, purpose-scoped GPOs — never one giant "Default Domain Policy does everything" GPO):

| GPO | Scope | Contents |
|---|---|---|
| Domain Password & Lockout Policy | Domain root | Only place fine-grained password policy can't easily go per-OU without Password Settings Objects (PSOs) — worth learning PSOs specifically if Finance/HR need a stricter policy than Sales |
| Baseline Workstation Security | Computers\Workstations | Windows Defender baseline, firewall profile, BitLocker enforcement, disable legacy protocols (SMBv1, LLMNR) |
| Baseline Server Security | Computers\Servers | Tighter than workstation baseline — RDP restrictions, audit policy, service hardening |
| Certificate Autoenrollment | Domain root or Computers | Once AD CS exists — ties to the Microsoft Architecture Reference doc already written |
| Software/Printer Deployment | Per-department OU or via groups | Department-specific app deployment |
| Executive Exception Policy | Computers\Workstations\Executive | Document *why* it's different, don't just quietly loosen it |

**Local Administrator Password Solution (Windows LAPS)** is worth deploying early — it's explicitly on the AZ-801/AZ-802 security skill list, it's a real, current best practice (randomized, AD-stored, rotated local admin passwords per machine), and it directly prevents the classic "one local admin password shared across every workstation" failure mode.

---

## Part 7 — Core Services Build Order (maps onto existing Roadmap Phases 3-4)

> ⚠️ **`302-Windows-Environment-Build-Roadmap.md` is the authoritative build *schedule*** (capacity, licence clocks, cost — `ADR-0008`). This list is the *design-side* order and is consistent with it; when they differ on timing, `302` wins. Also: **AZ-801 references below/here should read AZ-802** — AZ-801 retires 2026-09-30, consolidated into AZ-802 (`ADR-0008`).

This refines the "Recommended Build Order" from the Microsoft Architecture Reference doc with the org design above folded in:

1. **AD DS forest/domain** on DC01 — ✅ promoted (device-verified 2026-07-21); DC02 replica promoted (🟡 operator-reported 2026-07-28, `repadmin`/`dcdiag` read-back pending)
2. **KDS root key** — do this immediately after, before you need it
3. **OU structure** from Part 3 — build the skeleton before creating a single user
4. **DNS + DHCP** — DHCP scope needs to exist before any client (including a re-tested VLAN 20 DC01) can rely on it
5. **Base GPOs** from Part 6 — before real user/computer objects populate the OUs, so nothing is ever unmanaged even briefly
6. **Groups** (Part 4) — before users, so every user gets placed into correct groups at creation, not retrofitted
7. **Bulk-create realistic user population** (see Part 8) matching the department table in Part 1
8. **File services / DFS** — first real "why does AD matter" payoff (department shares, permissions via Domain Local groups)
9. **AD CS two-tier PKI** — per the earlier Microsoft Architecture Reference doc, resolve the coexist-vs-replace ADR first
10. **Certificate autoenrollment + LAPS**
11. **NPS** — resolve the FreeRADIUS coexist-vs-replace question from the same doc

---

## Part 8 — Labs and Scenarios

You asked for labs that simulate the realistic operation of a company this size, not just "install AD DS." Grouped by what they actually exercise:

### Foundational build labs
- Promote DC01, add DC02, verify replication (`repadmin /replsummary`)
- Build the OU tree from Part 3 via PowerShell script (not GUI-clicked) — realistic, since real environments provision this way, and it doubles as reusable Atlas documentation
- Create the Part 1 department population via a CSV-driven bulk user import script — assign to correct OUs and groups at creation

### Day-2 operations labs (the actual bulk of a real sysadmin's week)
- **New hire onboarding**: create user, assign department groups, provision a mailbox-equivalent/shared resource, apply correct GPOs, generate a temp password with forced change at first logon
- **Termination/offboarding**: disable account, remove from all groups except a documented audit group, move to Disabled Objects OU, revoke any issued certificates, document the process as an SOP (this maps directly to the "MSP transition" idea — a documented, repeatable offboarding runbook is exactly MSP-grade work)
- **Password policy exception**: build a PSO for Finance/HR with stricter requirements than the domain default
- **Delegated help desk role**: create a Tier-2-scoped group with delegated rights to reset passwords and unlock accounts *only* for a specific OU (e.g., Support can't touch Finance) — this is the single most common real-world AD delegation task and a good exam-relevant and realistic lab in one

### Failure/incident-simulation labs
- Intentionally break replication between DC01/DC02, diagnose and fix it (`dcdiag`, `repadmin`) — AZ-801/AZ-802 troubleshooting domain, directly
- Simulate a locked-out/compromised service account, walk through detection and gMSA migration as the remediation
- SYSVOL/AD restore from backup — this is explicitly an exam skill (recover from AD recycle bin, DSRM) and a real "if this breaks, the whole company stops" scenario worth having actually done once, not just read about

### Security-hardening labs (ties to your AZ-801/802 background)
- Deploy Windows LAPS, verify rotation, verify a helpdesk-tier account *cannot* retrieve the password (only Tier 1)
- Audit and disable NTLM where possible — currently an explicit AZ-801/AZ-802 skill
- Build the Tier 0/1/2 separation from Part 5 for real, including testing that a Tier 2 credential genuinely cannot touch a Tier 0 system

### MSP-simulation labs (the "after that is done" phase)
Once Atlas's own environment is a believable, populated, running 150-person company, the natural next step is treating Atlas *itself* as your first "client" and building the MSP layer around it:
- Stand up a lightweight RMM/PSA-equivalent — open-source or free-tier options exist (e.g., a self-hosted RMM agent monitoring Atlas's own DCs/servers) so this doesn't require ongoing SaaS spend just for lab purposes
- Build a documentation system for "client" (Atlas) credentials, SOPs, and network diagrams — this is literally what Atlas itself already is, so the lab is really "imagine handing this repo to a new hire and see if they could actually run Atlas from it alone," which is a good practical test of whether the documentation is actually complete
- Simulate a second small "client" environment (could be a scaled-down second domain/forest, or even just a second OU tree treated as a separate tenant) to practice the actual context-switching and access-boundary discipline MSPs live by
- Ticketing/SLA simulation — even a simple spreadsheet-tracked "ticket queue" for your own future lab work, timed, gets at the actual operational skill (not just the technical one) that "functioning as an MSP" requires

---

## What This Roadmap Deliberately Doesn't Cover Yet

Multi-forest trusts, cross-forest migration, Entra ID hybrid sync, and Azure-hosted DC — all real AZ-802 material, all things a 150-person single-site company usually doesn't need on day one. These are natural **Phase 8 "Advanced Scenarios"** material (same pattern as the existing Cisco 1941 routing replacement idea) rather than core build — flag for later, don't build now.

## Related Atlas Pages

- Atlas Roadmap (`00-Atlas-Foundation/Roadmap/Atlas-Roadmap.md`) — Phase 3/4 this document expands
- Microsoft Architecture Reference — the AD CS/NPS coexist-vs-replace questions raised there apply directly to Parts 7 and 8 here
