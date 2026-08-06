---
Title: Atlas Foundation — Start Here (find what governs your situation)
Path: 00-Atlas-Foundation
Status: 🟢 Living — the Foundation front door, built around the situation/role findability model (#41). Pick your situation or role and land on the doc that governs it. Regenerate when the tree or the router changes.
Version: 2.0
Date: 2026-08-03
---

# Atlas Foundation — Start Here

> 🧭 **Pick your situation or your role below and go straight to the doc that owns the answer** — fast, self-service, no manager. This is the human front door to the Foundation (the cross-lab governance, standards, and decisions). The machine-first twin for AI sessions is `AI-Context/`; *where the build is right now* is the [Lab-02 handoff](../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md); the repo-wide front door is the root [`README.md`](../README.md); terms → [`GLOSSARY.md`](../GLOSSARY.md).

## Find what governs your situation

> If a pointer here disagrees with its target, **the target wins** — fix the pointer (`POL-0004`). This is a router, never a copy.

### By situation — "I'm about to…"

| Your situation | Go to |
|---|---|
| **Make a change to a live device** | `POL-0003` (Change Control) → raise a `CM-####` from `Templates/Change-Record-Template.md`; the process is `Governance/Atlas-Change-Management-Process.md` |
| **Confirm a change actually took** | Playbook `Atlas-Academy/Playbooks/Confirm-a-Config-Change-Actually-Took.md` (read the running value back, not the exit code — `POL-0001`) |
| **Find a secret committed to the repo** | Playbook `Atlas-Academy/Playbooks/Respond-to-a-Committed-Secret.md` → **rotate first** · `POL-0002` (Secrets) · `ADR-0010` (publication gate) |
| **Harden a device / new workstation** | the `CIS-Hardening-*` baselines (`Labs/Lab-02-Cisco-Core/Architecture/`) · `POL-0007` · Playbook `Enumerate-Every-Enabled-Interface-Before-Hardening.md` (don't shut the break-glass path) · Backlog **#40** |
| **Add or move a document** | `Documentation/Contributing-Adding-Docs.md` (where a doc goes) + the Documentation Standard / Style / Workflow (all under `Documentation/`) |
| **Know where the build is right now** | `Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md` (the living STATE — read it every session) |
| **Look up an IP / VLAN / gateway** | `Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md` (v4) · `IPv6-Addressing-Plan.md` (v6, dual-stack) |
| **Diagnose a blocked connection** | Playbook `Atlas-Academy/Playbooks/Trace-a-Blocked-Flow.md` + `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (the flows owner) |
| **Recover a locked-out device** | Playbook `Atlas-Academy/Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md` (+ the device's console-recovery doc) |
| **Back up / restore** | `POL-0005` (Backup & Recovery) · `ADR-0011` (Game-Day: a backup isn't proven until a restore is) · BKP01 |
| **Study for a certification** | `Atlas-Academy/Certification/` — cert tracks mapped onto real Atlas builds (CCNA/CCNP · AZ-800/801 · FortiGate FCP · Security+ D5 · Project+ · pre-teardown catalogue) |
| **Publish the repo / go public** | `ADR-0010` (publication preconditions) · `Public-Release/` (sanitization plan + manifest) · run gitleaks on full history first |
| **Make an architecture decision** | write an ADR (`Templates/ADR-Template.md`, `AI-Context/ADR-Navigation.md`); if it is a standing rule it may be a **Policy** — `Governance/Atlas-Governance-Framework.md` |
| **Onboard as an AI session** | `AI-Context/README.md` → `AI-Context/What-To-Check-First.md` → the handoff |

### By role — "I am a…"

| Role | Start here |
|---|---|
| **Network engineer** | the device folders (`Labs/Lab-02-Cisco-Core/Devices/<dev>/`) · the flows matrix · `Atlas-Academy/Command-Library/` (Cisco-IOS / RouterOS / FortiOS) · the Playbooks |
| **Windows / identity engineer** | `Labs/Lab-02-Cisco-Core/Windows-Infrastructure/` · the DC device folder · `ADR-0021` (tiered identity) · `Atlas-Academy/Command-Library/PowerShell-Tier0.md` |
| **Security / audit** | `POL-0001` (Audit) · `Security-Program/` · SIEM01 / MON01 device folders · `Governance/` |
| **Operator / lab admin (Tier 0)** | the handoff · PAW01 · Backlog **#40** (your own admin box is the highest-value target) · `ADR-0021` |
| **HR / standard user** | your role's resource access (`ADR-0042`) · the acceptable-use policy `POL-0010` |
| **IT staff** | the `G-IT-Staff` access model (`ADR-0042`) · the tiered-admin rules (`ADR-0021`) · the Change-Management process |
| **Studying for a cert** | `Atlas-Academy/Certification/` (the tracks) · `Atlas-Academy/Command-Library/` (the verify commands) |
| **Reviewer / recruiter** | `PORTFOLIO.md` (highlights, evidence-linked) · `INDEX.md` (the map) |
| **AI session** | `AI-Context/README.md` + the house rules |

*The AI-context waypoint into this router is `AI-Context/Situation-Router.md`. Add a row above whenever you find yourself answering "where's the doc for* this*?" — that question is the maintenance signal.*

## The Foundation map

| Folder | What's in it |
|---|---|
| `AI-Context/` | 🤖 the AI-session onboarding map — start-here, pointers, directory map, ADR-navigation, the situation-router waypoint, audit playbooks (`ADR-0052`). |
| [`Governance/`](Governance/) | the **[Charter](Governance/Atlas-Charter.md)** (the operating constitution) · the [Governance Framework](Governance/Atlas-Governance-Framework.md) (Policy › Standard › ADR) · the [Source-of-Truth router](Governance/Atlas-Source-of-Truth.md) · the Workflow · Change-Management. |
| [`Policies/`](Policies/) | `POL-####` — the standing rules (register: [`Policies/README.md`](Policies/README.md)). |
| [`Standards/`](Standards/) | `STD-####` — the concrete, testable standards a policy requires (register: [`Standards/README.md`](Standards/README.md)). |
| [`Decisions/`](Decisions/) | `ADR-####` — point-in-time decisions (live [`ADR-Index`](Decisions/ADR-Index.md) · frozen [`Legacy-ADR-Index`](Decisions/Legacy-ADR-Index.md)). |
| [`Documentation/`](Documentation/) | how docs are built & written — the per-device Standard, Style & Conventions, Workflow, and **Contributing** (where a doc goes). |
| [`Reference/`](Reference/) | foundation-level teaching references — the [firewall / segmentation architecture](Reference/Atlas-Firewall-Architecture.md). |
| `Public-Release/` | the public / portfolio release controls — the sanitization plan + manifest (`ADR-0010`). |
| [`Templates/`](Templates/) | the skeletons — POL / STD / ADR / Build-Guide / Build-Record / Change-Record / commissioning checklists. |
| [`Security-Program/`](Security-Program/) | compliance, incident response, security awareness, third-party risk. |
| [`Roadmap/`](Roadmap/) | the authoritative [phase list](Roadmap/Atlas-Roadmap.md) + advanced scenarios + next-lab brief + the [improvement backlog](Roadmap/Atlas-Improvement-Backlog.md). |
| [`Company-Profile/`](Company-Profile/) | the fictional scenario — Atlas Industrial (`301`) + its security requirements (`305`). |

## Elsewhere in the repo

- **[`../Labs/`](../Labs/)** — the labs: `Lab-01-Mikrotik-Core` (frozen) and `Lab-02-Cisco-Core` (active). Device docs, change records, operations runbooks.
- **[`../Atlas-Academy/`](../Atlas-Academy/)** — the "why it works" + learning layer: Concepts, the Command-Library, problem-keyed Playbooks, the per-domain Directory, and the **[Certification tracks](../Atlas-Academy/Certification/)**.
- **`../99-Archive/`** — retired material, kept and signposted (`99-Archive/README.md`). Never current guidance.
- **[`../README.md`](../README.md)** (repo front door) · **[`../GLOSSARY.md`](../GLOSSARY.md)** (terms) · **[`../INDEX.md`](../INDEX.md)** (the full repo map).

---
*Rebuilt around the situation/role findability model (#41, 2026-08-03) — superseded the flat doc-list index. Regenerate when the Foundation tree or the router changes.*
