---
Title: Atlas Industrial — Security & Segmentation Requirements
Path: 00-Atlas-Foundation/Company-Profile
---

# Atlas Industrial — Security & Segmentation Requirements

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Target Design |
| Evidence Source | Fictional. The security half of the scenario the environment is built to serve. |
| Version | 1.1 |
| Applies To | Book 3 (Windows Infrastructure), Book 4 (Identity and PKI), Book 5 (Security), Book 11 (Firewall / East-West), Book 8 (Labs) |

> ## ⛓ This document is bound to `301-Atlas-Company-Profile.md`
>
> **Neither document is complete without the other. Read them as one.**
>
> `301` defines **who Atlas is** and **how identity is provisioned** — the org chart, the 156 people, the acquisition, the ghosts, the SQL→AD pipeline. It is excellent at answering *"why is the OU tree shaped this way, why does Finance get a PSO, why does the shop floor break the naming convention."*
>
> `301` does **not** answer the next question: *once these identities and this data exist, how are they segmented, defended, and proven isolated?* Zones, firewall rules, OT isolation, data classification, and the compliance obligations that force them all need the **same real-company grounding** that `301` gives identity — and that grounding lives **here**.
>
> **The pairing:** `301` is *identity and provisioning*; `305` is *segmentation and defence*. `301` says "here is the company and its people." `305` says "here is what that company is legally, operationally, and physically obligated to protect, and how the network is divided to do it." Change one and you almost certainly have to change the other — a new department in `301` needs a zone here; a new zone here needs a data owner in `301`. They are versioned as a pair.

---

## Why This Document Exists

`301` proved a point that this document borrows wholesale: **you cannot design against a company that doesn't exist.** You cannot design an OU tree for an imaginary org, and you equally cannot design a **security-zone model, a firewall policy, or an OT boundary** for an imaginary one. Every segmentation decision downstream — *why the shop floor is its own zone and not just another VLAN, why the order portal cannot reach Finance, why the DCs live in a carve-out nobody else can initiate to* — only has a right answer once there is real data, a real legal obligation, and a real physical process behind it.

**This company is deliberately messy, and its security posture is deliberately messier.** A clean network with one flat trust zone teaches nothing. Every awkward thing below forces a real design decision that a tidy fiction would let you skip — and unlike the identity mess in `301`, most of these mistakes are the ones that end up in the incident report.

The four parts below are the four things `301` is silent on. Each one is a design requirement, not flavour, and each one feeds a specific downstream artifact: the **East-West Allowed-Flows Matrix**, the **Book 11 firewall rules**, and the **CIS/NIST control mapping**.

---

## Part 1 — Data Classification: the layer that writes the matrix

The `Atlas-East-West-Allowed-Flows-Matrix.md` has a column that is deliberately left blank: **`Reason`**. No reason, no rule. This part is where the reasons come from. **You cannot write "why is `Clients → Servers:443` allowed" until you have classified what lives on the server tier and who is entitled to reach it.**

### The classification Atlas actually needs

Four levels — more than that is theatre for a 156-person shop, fewer and you can't tell the order portal from the CAD vault.

| Level | What it is at Atlas | Where it lives | Who may reach it |
|---|---|---|---|
| **Restricted** | Cardholder data (order portal), payroll & PII (HR/Finance), domain secrets (`NTDS.dit`, CA keys) | DMZ app → tokenised; Finance/HR file shares; DCs (Tier 0) | Named roles only. **Everything else denied and logged.** |
| **Confidential** | AtlasERP business data, CAD/product designs, the `AtlasHR` database | VLAN 20 (Servers), VLAN 30 (Web/App) | The department that owns it + QA read-only + the app tier |
| **Internal** | General file shares, intranet, print | VLAN 20/50 | All corporate staff (Tier 2) |
| **Public / Untrusted** | The customer-facing order portal front end | VLAN 80 (DMZ) | The internet — and it **must not reach back inside** |

### Per-department access → this is the matrix `Reason` column

The point of `301`'s messy departments is that their **data-access requirements are not uniform**, and that non-uniformity is exactly what turns a whole-zone permit (🟡) into a scoped service rule. A worked handful:

| Department (from `301`) | Data it must reach | The flow it justifies | The flow it must **not** have |
|---|---|---|---|
| **Finance & HR** | Restricted PII/payroll; owns `AtlasHR` | `Clients → Servers:445/1433` to the Finance share + SQL | No path from the shop floor or DMZ, ever |
| **Engineering** | Confidential CAD vault | `Clients → Servers:{CAD app port}` | Cannot reach Finance's Restricted share |
| **Quality Assurance** | *Read* production **and** engineering data | Two **read-only** flows, cross-departmental | No write; no path to identity |
| **Sales / Customer Service** | AtlasERP web front end | `Clients → Web:443`; `Web → Servers:1433` (three-tier) | Clients never reach the DB directly |
| **Order portal (DMZ)** | One backend call, if any | 🔴 *one host, one port — or deleted* | The whole interior. This is the flow attackers want |
| **Production (shop floor)** | Its own line-of-business kiosk app only | Stays inside its own zone (Part 2) | The corporate LAN, the internet, identity |

> **The exercise:** take every 🟡 whole-zone permit in the allowed-flows matrix, find the department in `301` that needs it, name the data class and the port, and write the `Reason`. When you can't find a department that needs it, that's a rule to delete. **That is data classification doing real work, not a poster on a wall.**

---

## Part 2 — OT / Shop-Floor Segmentation: the zone `301` implies but never draws

`301` tells you 45 production staff share 8 kiosk logins and that Facilities "owns a Windows box in a cupboard nobody has patched since 2019." What `301` does **not** say — and what this document makes a hard requirement — is that **the shop floor is not just another user VLAN. It is Operational Technology, and it belongs behind an IT/OT boundary.**

### What actually lives on the plant side

| System | What it is | Why it can't be treated like a PC |
|---|---|---|
| **PLCs** (programmable logic controllers) | Run the production line | No patching window — a reboot stops the line. Legacy protocols, no auth |
| **HMIs** (human-machine interfaces) | The kiosk screens operators touch | The `PROD-LINE1…8` shared logins from `301` live here |
| **SCADA / line-control server** | Supervises and logs the process | Often Windows, often old, often un-patchable without vendor sign-off |
| **Facilities: HVAC + badge system** | Building controls (`301`, Facilities) | IP-connected, rarely inventoried, frequently the soft entry point |
| **The 2019 box** | The unpatched Windows machine in the cupboard | **This is the case study.** It cannot be patched *and* cannot be exposed. Segmentation is the only control left |

### Why this is a NIST 800-82 problem, not a VLAN problem

The instinct is "put the plant on VLAN 90 and move on." That is a VLAN, not a boundary. **OT segmentation follows the Purdue model** (levels 0–5, from physical process up to enterprise IT) and **NIST SP 800-82** (Guide to Operational Technology Security). The requirements that fall out:

- **A defined IT/OT boundary.** Corporate IT (Levels 4–5) and the plant (Levels 0–3) meet at **one controlled conduit**, not a flat switch. Nothing on the corporate LAN initiates into the OT zone except through a named, logged flow.
- **The unpatchable box is *why segmentation exists*.** You will never patch the 2019 machine or the PLCs on a normal cadence. NIST 800-82's answer is **compensating controls**: isolate it, allow only the exact flow its process needs, and monitor that flow. Segmentation is the patch you can't apply.
- **Availability outranks confidentiality here.** In IT, you patch and reboot. In OT, the line stopping *is* the incident. The `301` tension — "the line stops if login takes 40 seconds" — is the same tension that makes OT security its own discipline. You design around uptime, not against it.
- **The badge/HVAC systems are in scope.** They are the classic "we forgot Facilities was on the network" finding. They get a zone too.

> **The lab that matters:** prove that a host on the corporate Clients VLAN **cannot** open a session to the SCADA server or the 2019 box — refused and logged — while the one flow the line genuinely needs still passes. That is the IT/OT boundary, tested, not asserted. It is also a `NIST 800-82` talking point that puts you ahead of most people who list "network security" on a résumé.

---

## Part 3 — The Compliance Anchor: why any of this is mandatory

Left to preference, segmentation gets value-engineered away the first time it's inconvenient. **Compliance is what makes it non-negotiable** — and a manufacturer with a customer-facing order portal and a payroll system has real, nameable obligations. This part gives the design its *"because we have to,"* which is the strongest reason a rule can have.

| Obligation | Where it bites at Atlas | What it forces |
|---|---|---|
| **PCI-DSS** | The customer **order portal** takes card payments (VLAN 80 DMZ) | The cardholder-data environment must be **segmented** from everything else. This single requirement justifies the entire DMZ-cannot-reach-interior stance. Scope reduction (tokenise, don't store) is the real-world move |
| **PII / financial data** | Finance & HR hold payroll, SSNs, employee records (`301`) | Access control + audit logging on the Restricted share. Ties straight back to the Finance/HR PSO in `301` and the ghost-account offboarding problem |
| **Cyber-insurance attestation** | The renewal questionnaire every real company now signs | MFA, segmentation, logging, offboarding, backup/recovery — **you attest you have them, and a claim can be denied if you didn't.** This is the modern forcing function most homelabs miss |

### The anchor: CIS Controls v8, Implementation Group 1

Rather than boil the ocean, Atlas anchors to **CIS Controls v8 IG1** — the baseline set of safeguards defined for exactly a small-to-mid org with limited IT staff. It is the honest target for an 8-person team, and it maps cleanly onto everything `301` and this document already describe:

| CIS Control (v8, IG1) | Atlas artifact that satisfies it |
|---|---|
| 1 & 2 — Inventory of assets & software | The NetBox/DCIM source-of-truth work; the "gap report" query in `301` |
| 3 — Data protection | Part 1 above (classification) |
| 4 — Secure configuration | GPO CIS baselines (Book 3); device hardening (Books 1/11) |
| 5 & 6 — Account & access management | `301`'s AGDLP + the tiering in Part 4; the ghosts and Reeves cleanup |
| 8 — Audit log management | Syslog → SIEM (roadmap); the kiosk non-repudiation finding |
| 12 — Network infrastructure management | The allowed-flows matrix + Book 11 |
| 13 — Network monitoring & defence | Monitoring VLAN 40, the SPAN, NetFlow |

> **The point:** every control above is already something the lab builds. Anchoring to IG1 turns a pile of homelab exercises into **a defensible security programme with a name a real auditor recognises** — and gives each firewall rule and each GPO a citation, not just a preference.

---

## Part 4 — Tiering & the Audit Findings: identity mistakes are segmentation mistakes

`301` is honest about its identity mess — the Reeves Domain Admins, the ghosts, the shared kiosk accounts, the over-privileged scanner. This part makes the point `301` stops short of: **every one of those is also a segmentation and blast-radius finding**, and the fix is `ADR-0021`'s tiered model enforced *by the network*, not just by AD groups.

### Tiering is a network boundary, not only an AD construct

`ADR-0021` adopts Microsoft's **Tier 0 / 1 / 2** model. The half people forget: **tiering only works if the network enforces it too.**

- **Tier 0** = identity itself — Domain Controllers, AD CS. Per `ADR-0021` they live in **their own protected segment** (a dedicated identity VLAN or a firewalled carve-out of VLAN 20). The allowed-flows matrix's flow #9 — *auth-only, inbound to Identity* — is the network half of the tier boundary. **Nothing initiates *out* of a user zone into Tier 0 except LDAPS/Kerberos/DNS.**
- 🔴 **A higher-tier credential never authenticates to a lower tier.** No Domain Admin on a workstation. `301` states this; the network makes it *enforceable* by ensuring the admin path only exists from the Management zone.

### The `301` findings, re-read as blast radius

| Finding (from `301`) | Identity reading (`301`) | Segmentation / blast-radius reading (here) |
|---|---|---|
| **3 temp Reeves Domain Admins** | Over-privileged accounts to find and strip | 3 Tier-0 credentials with no segment discipline — a phish on any one owns the domain. **Find them (`ADR-0021` Review Trigger), then verify no path lets them log into Tier 2** |
| **5 ghost accounts** | Stale-account offboarding SOP | 5 live credentials with unknown reachability — the exact accounts attackers use to stay resident. Offboarding is a *containment* control, not hygiene |
| **8 shared kiosk logins** | Can't audit "who did it" | **Non-repudiation gap.** `PROD-LINE3` in a log names eight people. This is a CIS Control 8 (audit) and a Part 2 (OT) finding — the compensating control is segmentation + monitoring, since you can't fix the shared login without stopping the line |
| **`svc-scanner`** — "more file-share access than the CFO" | Over-privileged service account | Lateral-movement highway. Restricted-data access from an unattended, sticky-note-password box. Least-privilege here is a **data-classification** enforcement (Part 1) |

> **The flagship lab (`301` names it, this document scopes it):** *prove a Helpdesk Tier-2 account cannot touch a Tier-0 object* — with the AD failure message **and** the firewall/network denial as paired evidence. Identity says "the group membership doesn't allow it." Segmentation says "even if it did, there's no path." **Defence in depth is exactly those two proofs stacked.** That is the single highest-value thing in the whole scenario.

---

## How This Maps to the Zones (and back to `301`'s VLAN table)

`301` closes with a table showing every VLAN finally has a *reason to exist* now that the company is real. This document adds the **trust** dimension — a VLAN is plumbing; a **zone** is a trust boundary — and each row traces back to a `301` department and forward to an allowed-flows-matrix zone.

| `301` VLAN | Zone (trust) | Grounded by (`301`) | Governed by |
|---|---|---|---|
| 20 Servers | **SERVERS (T1)** + a carved **IDENTITY (T0)** | AtlasERP, `AtlasHR`, the DCs | Part 4 tiering; matrix flow #9 |
| 30 Web | **WEB/APP** | Order portal / ERP front end | Part 1 three-tier; Part 3 PCI |
| 50 Clients | **CLIENTS (T2)** | ~95 corporate users | Part 1 per-dept access |
| 80 DMZ | **DMZ** (must not reach interior) | The order portal | Part 3 PCI-DSS segmentation |
| *(new)* Plant / OT | **OT ISOLATION** | Shop floor, SCADA, the 2019 box, Facilities | Part 2 / NIST 800-82 |
| 40 Monitoring | **MONITORING** (poll-only) | `svc-monitoring` | Part 3 CIS 8 & 13 |
| 10 Management | **MANAGEMENT** | IT (8) | Part 4 tier boundary |

**The one addition `301`'s table is missing: the OT zone.** `301`'s VLAN map has no home for the plant floor as a *trust boundary* — it treats production as just more users. Part 2 is that missing zone. That gap is precisely why these two documents are bound together.

---

## Related Pages

- **`00-Atlas-Foundation/Company-Profile/301-Atlas-Company-Profile.md` — the identity half. This document is bound to it; read them as a pair.**
- `Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` — the artifact Part 1 fills; this document supplies its `Reason` column
- `00-Atlas-Foundation/Decisions/ADR-0021-AD-as-Tiered-Identity-Backbone.md` — the Tier 0/1/2 model Part 4 enforces at the network
- `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` — the method (§3.6 segmentation, §4 the Book 11 bar)
- `00-Atlas-Foundation/Roadmap/Atlas-Next-Lab-Design-Brief.md` — where the NIST/CIS and zones-vs-VLANs guidance is developed in full
- `08-Labs/README.md` — the segmentation and tier-boundary Game Days assume this document exists *(🔴 #22 audit 2026-07-30: this link target does not exist — no `08-Labs/` dir; needs repointing to the current labs index → Backlog #29)*

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial security & segmentation companion to `301`. Four parts: (1) data classification feeding the allowed-flows-matrix `Reason` column; (2) OT/shop-floor segmentation under the Purdue model and NIST 800-82, with the unpatchable 2019 box as the case study; (3) the compliance anchor — PCI-DSS for the order portal, PII/financial for Finance/HR, cyber-insurance → CIS Controls v8 IG1; (4) tiering (`ADR-0021`) and the `301` audit findings re-read as blast-radius/segmentation problems. Explicitly bound to `301` — the two are versioned and read as one. |
| 1.1 | 2026-07-30. **#22-audit currency fix (nav only — content unchanged).** Corrected the stale frontmatter `Path` (`Windows Infrastructure` → `00-Atlas-Foundation/Company-Profile`) and flagged the broken `08-Labs/README.md` link inline (no successor found → Backlog #29). All four parts, the zone/VLAN mapping, and the narrative were left untouched (the fuller Foundation-doc currency audit is Backlog #29). |
