# Atlas Repository — Master Index

A guided map of the whole repository: every top-level folder, what's inside it, and where to start. If you're looking for something specific, this page tells you which folder it lives in — and the "kinds of folders" legend explains the repeating pattern so any folder you open reads the same way.

> 📂 **New to browsing a repository like this?** Everything here opens right in your web browser — just **click any folder or file name to read it.** You don't need to download anything or install any tools. Folder and file names are the links; click one to go in, and use your browser's **Back** button to come back out. Nothing here is hidden behind code you have to run.

> **Two ways in:** 👔 *Recruiter / reviewer?* Start at **[`PORTFOLIO.md`](PORTFOLIO.md)** — the highlights, each linked to its proof.  🧭 *Engineer?* Start at **[`README.md`](README.md)** — the front door with a "start here by what you need" table. This INDEX is the full directory both of them point back to.

## The four areas at a glance

| Area | What's in it | Best entry |
|---|---|---|
| **[`00-Atlas-Foundation/`](00-Atlas-Foundation/)** | The engineering *process* that spans every lab: charter, policies, standards, decisions, roadmap, security program, templates | [`00-Atlas-Foundation/README.md`](00-Atlas-Foundation/README.md) |
| **[`Labs/Lab-01-Mikrotik-Core/`](Labs/Lab-01-Mikrotik-Core/)** | 🔒 The frozen first lab — a complete five-device network, end to end | [`Lab-01 README`](Labs/Lab-01-Mikrotik-Core/README.md) |
| **[`Labs/Lab-02-Cisco-Core/`](Labs/Lab-02-Cisco-Core/)** | 🟢 The active build — Cisco core + the enterprise services / identity / PKI platform, across 25 devices | [`Lab-02 handoff`](Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) |
| **[`Atlas-Academy/`](Atlas-Academy/)** | The learning layer — *why* it works, *how* to verify, *what to do* when it breaks, and cert maps | [`Academy README`](Atlas-Academy/README.md) |

---

## How this repository is organized — the kinds of folders

Atlas uses the **same folder pattern everywhere**, so once you know these types, any folder you open is predictable. Every folder has a `README.md` that is its "front door" — open that first.

**Top-level areas**

- **`00-Atlas-Foundation/`** — the estate-wide *process and governance*: the rules, decisions, and templates that apply to every lab. Nothing device-specific lives here.
- **`Labs/Lab-XX-.../`** — a **lab** is one complete IT environment. Lab-01 is frozen (a finished record); Lab-02 is the active build.
- **`Atlas-Academy/`** — the *learning* layer: the "why," the "how to verify," and the "what to do when it breaks."
- **`99-Archive/`** — retired material, kept for history. **Never** current guidance.
- **`tools/`** — helper scripts for git and publishing.

**Inside a lab, these folder types repeat**

- **`Devices/<DEVICE>/`** — one physical device or host (e.g. `SW01-Access-Switch/`). Its `README.md` is the device front-door: what it is, what it connects to, and which doc answers which question. Inside each device folder you'll find the same document types (below), plus:
  - **`Changes/`** — that device's **change ledger** (`CM-####` records — every change, with risk, backup, rollback, and validation).
  - **`Automation/`** — the Infrastructure-as-Code / automation slice for that device (`ADR-0048`).
  - **`Roles/`** — on a host that runs several services, the per-service build units.
- **`Architecture/`** — the **design layer**: topology, IP addressing, cabling/port maps, allowed-flow matrices, device-role assignments, and the `CIS-Hardening-*` security baselines.
- **`Operations/`** — the **working docs**: evidence run-sheets, backup/verification runbooks, session plans, and audits.
- **`Change-Management/`** (lab level) — the master `CM/MC` ledger index + cross-device change records.

**The document types you'll see in a device folder**

| File | Answers |
|---|---|
| `README.md` | *What is this device, what does it touch, and which doc do I want?* (the front door) |
| `Build-Guide.md` | *How do I build it?* — the step-by-step CLI/GUI procedure |
| `Build-Checklist.md` / `Build-Record.md` | *What's the design, and what's actually running now?* (records outrank guides — `POL-0001`) |
| `Diagnostics.md` | *How do I verify it's healthy?* — the `show`/command battery, with healthy-vs-broken output |
| `Troubleshooting.md` | *It's misbehaving — what are the symptoms and fixes?* |
| `Roadmap.md` / `Considerations.md` | *What's the build path, and what's still open/risky?* |

> **A convention that pays off everywhere:** a checkbox is only ✅ when the **command and its real output** are pasted in (`POL-0001`). Anything operator-reported-but-unverified is 🟡; planned is 📋. So the status markers mean something.

---

## `00-Atlas-Foundation/` — the process & governance

*From its README: everything that spans labs — the charter, the governance and security programs, the policy/standard/decision hierarchy, the roadmap, and the templates.*

| Folder | What you'll find |
|---|---|
| [`Decisions/`](00-Atlas-Foundation/Decisions/) | Every **Architecture Decision Record** (`ADR-0001`…`ADR-0054`) — the point-in-time choices, with rationale, alternatives, and consequences. Start at [`ADR-Index.md`](00-Atlas-Foundation/Decisions/ADR-Index.md). |
| [`Policies/`](00-Atlas-Foundation/Policies/) | `POL-####` — the standing rules (audit, secrets, change control, source-of-truth, backup, naming/addressing, incident response, risk, business continuity, and more). |
| [`Standards/`](00-Atlas-Foundation/Standards/) | `STD-####` — the concrete standards the policies require: password/auth, access control, physical, encryption. |
| [`Governance/`](00-Atlas-Foundation/Governance/) | The **Charter** (operating constitution), the Policy → Standard → ADR hierarchy, the Source-of-Truth router, the workflow, and how `CM/MC` change records are raised and reviewed. |
| [`Documentation/`](00-Atlas-Foundation/Documentation/) | How docs are built & written — the per-device Standard, Style & Conventions, Workflow, and **Contributing** (where a doc goes). |
| [`Reference/`](00-Atlas-Foundation/Reference/) | Foundation-level teaching references — the firewall / segmentation architecture. |
| `Public-Release/` | The public / portfolio release controls — the sanitization plan + manifest (`ADR-0010`). |
| [`Roadmap/`](00-Atlas-Foundation/Roadmap/) | The authoritative phase list, the improvement backlog, advanced-scenario backlog, and cert-objective gap analysis. |
| [`Security-Program/`](00-Atlas-Foundation/Security-Program/) | The compliance program, incident-response playbook, security-awareness program, and third-party risk management. |
| [`Company-Profile/`](00-Atlas-Foundation/Company-Profile/) | The fictional scenario Atlas is built for — Atlas Industrial (`301`) and its security requirements (`305`). It governs *why* every lab is shaped as it is. |
| [`Templates/`](00-Atlas-Foundation/Templates/) | The blank skeletons every doc is built from (ADR, build guide/record, change record, diagnostics, troubleshooting, manifests). |
| `AI-Context/` | The durable onboarding *map* for an AI or new contributor (`ADR-0052`) — pointers and navigation, never copies. Start here if you're picking the repo up cold. |

## `Labs/Lab-01-Mikrotik-Core/` — 🔒 the frozen first lab

*From its README: the first Atlas build — a five-device enterprise network with **MKT01 (MikroTik) as the core router**, **FGT01 (FortiGate)** at the perimeter, **SW01 (Cisco 2960X)** as the L2 access switch, **PI01 (Raspberry Pi)** running four shared services, and **PVE01 (Proxmox/Dell R410)** as the hypervisor.* **Frozen** (`ADR-0022`) and reconciled to live state on every device — the portfolio artefact for that era; not current guidance where it disagrees with an active doc.

| Folder | What you'll find |
|---|---|
| [`Architecture/`](Labs/Lab-01-Mikrotik-Core/Architecture/) | Physical & logical topology, device responsibilities, network source of truth (docs 001–006). |
| [`Standards/`](Labs/Lab-01-Mikrotik-Core/Standards/) | Lab-specific IP, VLAN, routing, security-zone, and management-network standards (007–014). |
| [`Operations/`](Labs/Lab-01-Mikrotik-Core/Operations/) | Cross-device runbooks — CA issuance/renewal, teardown, backup, validation, and the Book-1 audit report. |
| [`Change-Management/`](Labs/Lab-01-Mikrotik-Core/Change-Management/) | The `CM/MC` ledger index + cross-device change records (device-specific ones live under each device's `Changes/`). |
| [`Devices/`](Labs/Lab-01-Mikrotik-Core/Devices/) | The five devices (`MKT01`, `SW01`, `FGT01`, `PI01`, `PVE01`), each with its Build-Guide, Build-Record, Troubleshooting, hardening, and Changes. |

## `Labs/Lab-02-Cisco-Core/` — 🟢 the active build

*From its README: Lab-02 is two things at once by design —* **(1)** a network re-architecture (`ADR-0023`): the Cisco **1941 becomes the routed core** running OSPF, and **MKT01 re-roles to the east-west segmentation firewall / inter-VLAN gateway**; **(2)** the **enterprise services + identity/PKI platform** that rides on it — Proxmox virtualization, Windows/AD (AD DS, DNS, DHCP), a two-tier **AD CS PKI**, **NPS/RADIUS**, monitoring, backup, and east-west segmentation. **The live "where we are" is always [`SESSION-HANDOFF.md`](Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md).**

The plan, three levels: [`Atlas-Roadmap`](00-Atlas-Foundation/Roadmap/Atlas-Roadmap.md) (phases) → [`Architecture/Master-Build-Order.md`](Labs/Lab-02-Cisco-Core/Architecture/Master-Build-Order.md) (the active order) → [`Master-Implementation-Checklist.md`](Labs/Lab-02-Cisco-Core/Master-Implementation-Checklist.md) (the decision-free bench list). Service tier per host: [`Service-Server-Build-Plan.md`](Labs/Lab-02-Cisco-Core/Service-Server-Build-Plan.md).

| Folder | What you'll find |
|---|---|
| [`Devices/`](Labs/Lab-02-Cisco-Core/Devices/) | **25 devices**, each its own front-door folder with Build-Guide, `Diagnostics.md`, `Troubleshooting.md`, `Changes/`, and `Automation/` (grouped by role below). |
| [`Architecture/`](Labs/Lab-02-Cisco-Core/Architecture/) | The design layer — `Master-Build-Order`, `IP-Addressing-Plan-VLSM`, `Cabling-and-Port-Map`, the east-west allowed-flows matrix, device-role assignments, and the `CIS-Hardening-*` baselines. |
| [`Windows-Infrastructure/`](Labs/Lab-02-Cisco-Core/Windows-Infrastructure/) | The Windows environment plan — forest/domain design, role-based OU structure, AGDLP groups + gMSA service accounts, the GPO baseline (incl. LAPS), and the core-services build order. |
| [`Virtualization/`](Labs/Lab-02-Cisco-Core/Virtualization/) | The deep Proxmox build home — host bring-up, Windows/Ubuntu golden-image pipelines, and Build-Records (the authoritative `PVE01-Networking`, `ADR-0034`). The `PVE01`/`PVE02` device folders are the front doors into it. |
| [`Operations/`](Labs/Lab-02-Cisco-Core/Operations/) | Working docs — the evidence run-sheet, device-backup runbook, hardening standard, doc-conflict audits, and validation/adversarial-testing. |

**The 25 devices, by role** (each folder is a front door — Build-Guide, `Diagnostics.md`, `Troubleshooting.md`, `Changes/`, `Automation/`):

- **Network:** `1941-Core-Router` (routed core, OSPF) · `SW01-Access-Switch` (L2) · `MKT01-East-West-Firewall` (inter-VLAN gateway + E-W firewall) · `FGT01-Perimeter-Firewall` (FortiGate, N-S) · `PFSENSE01-IPS` (inline IPS)
- **Identity & PKI:** `DC-Domain-Controllers` (DC01/DC02, Tier 0) · `RCA01-ICA01-ADCS` (two-tier AD CS) · `CA01-VAULT01-PKI` · `NPS01-Network-Policy-Server` (RADIUS) · `PAW01-Tier0-Admin` (privileged access workstation)
- **Virtualization & compute:** `PVE01-Hypervisor` (Dell R410) · `PVE02-Hypervisor` (Beelink EQR6, always-on tier) · `CNT01-Container-Host`
- **Core services:** `Pi01-DNS-NTP` (Pi-hole + chrony) · `SRV01-Network-Services` · `FS01-File-Services` (SMB/DFS/FSRM) · `SQL01-Database` · `RDS01-Remote-Desktop` · `WAC01-Windows-Admin-Center` · `WSUS01-Patch-Management` · `NETBOX01-Source-of-Truth` (IPAM/DCIM)
- **Security & monitoring:** `SIEM01-Wazuh` (host SIEM/XDR) · `MON01-Monitoring` (the Detect layer) · `KALI01` (offensive/validation host)
- **Backup:** `BKP01-Backup` (PBS + Vaultwarden)

## `Atlas-Academy/` — the learning layer

*From its README: the estate's "why it works and how it fits together" layer (adopted, `ADR-0053`). Build Guides answer "how do I build this"; Academy answers "why does this work, how do I verify it, and what do I do when it breaks."* Start at [`Academy-Vision-and-Scope.md`](Atlas-Academy/Academy-Vision-and-Scope.md).

| Folder / doc | What you'll find |
|---|---|
| [`Concepts/`](Atlas-Academy/Concepts/) | Short modules explaining *why* something works, each taught through a **real Atlas device** as the worked example (tiered admin, VLAN tagging, identity-aware firewalling, and more) — never a generic tutorial. |
| [`Command-Library/`](Atlas-Academy/Command-Library/) | The master **verification-command reference** — *how to check* a device or service is healthy, platform-first (PowerShell/IOS/RouterOS/FortiOS/Linux), with healthy-vs-broken output. The per-device `Diagnostics.md` pages link up into it. |
| [`Playbooks/`](Atlas-Academy/Playbooks/) | Problem-named troubleshooting/operations playbooks — *what to do when it breaks* (the filename **is** the problem, so it's found by search and maps 1:1 to a ticket title). |
| Cert-map docs | How the estate maps to **CCNA, CCNP (ENCOR+ENARSI), AZ-800/801, FortiGate FCP, Security+, and Project+** — using real Atlas infrastructure as the exercises. |
| [`Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md`](Atlas-Academy/Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md) | What each machine was in frozen Lab-01, where its services moved to in Lab-02, what carried over, and the gaps the new design closes. |

## Supporting areas

| Path | What you'll find |
|---|---|
| `99-Archive/` | Retired material, preserved for history. **Never** current guidance. |
| [`tools/`](tools/) | Git and publishing helper scripts. |

## Root pages

| Page | For | What it is |
|---|---|---|
| [`README.md`](README.md) | Engineers | The front door + start-here table — the primary index. |
| [`PORTFOLIO.md`](PORTFOLIO.md) | Recruiters / reviewers | The highlights, each linked to its evidence. |
| [`INDEX.md`](INDEX.md) | Everyone | This page — the full folder-by-folder directory + the "kinds of folders" legend. |
| [`GLOSSARY.md`](GLOSSARY.md) | Everyone | Acronyms and Atlas-specific terms. |
| [`Atlas-Blueprint.md`](Atlas-Blueprint.md) | Context | A historical planning snapshot (~2026-07-13); kept for its reasoning, not the current plan. |
