---
Title: Atlas Roadmap
Path: 00-Atlas-Foundation/Roadmap
Location: 00 Atlas Foundation
Status: Active
Version: 2.0
---

# Atlas Roadmap

> 🔴 **This is the original book-based roadmap (v2.0 dashboard). The OPERATIVE plan is now `Labs/Lab-02-Cisco-Core/Master-Build-Order.md` v1.6 + `Labs/Lab-02-Cisco-Core/Master-Implementation-Checklist.md` (the sequenced, decision-free bench list). Several items below are superseded — see "2026-07-28 planning update" before the Change Log.**

## Project Dashboard

> **Corrected 2026-07-13.** The previous dashboard read *Foundation 10%, Network 90%, Virtualization 0%.* Foundation had 24 documents. Virtualization had 18 — and is arguably the best-written book in the repository. **The one page meant to show where things stand was the least accurate page in the repo.** Do not let that happen again: update this table from the repository, not from memory.

| Book | Status | Reality |
|---|---|---|
| **00 Atlas Foundation** | 🟢 **Baseline complete** | Charter (15 locked rules), Workflow, 7 ADRs, templates, evidence standard. **Refinement only — stop expanding it.** |
| **01 Enterprise Network** | 🟡 **Content complete** | 65 docs. All CM/MC records closed. Awaiting Confluence reconciliation + freeze. **Two open device checks** (see below). |
| **02 Enterprise Virtualization** | 🟡 **Draft assembled** | 18 docs, 14 Build Guides, 2 Build Records. **Guides are strong; records are thin.** ✅ `VIRTUALIZATION-PACK-MANIFEST.md` exists. ✅ **Numbering fixed 2026-07-13** — renumbered to `201`–`217`, resolving the collision with Book 1. **Build Records still need thickening before freeze.** |
| **03 Windows Infrastructure** | ⚪ Not started | Company Profile and 12-week build roadmap written. **DC01 exists as a stopped VM, never promoted.** |
| **04 Identity and PKI** | ⚪ Not started | AD CS. *A Lab CA already exists on Pi01 — this book is the AD CS counterpart, per ADR-0003.* |
| **05 Monitoring and Logging** | ⚪ Not started | **Highest-leverage unbuilt book.** Blocks nine open items across SW01, Pi01, and FGT01. |
| **06 Security** | ⚪ Not started | |
| **07 Backup and Recovery** | 🔴 **Not started — and this is a live risk** | **There are no backups of anything, anywhere.** See Critical Risks. |
| **08 Enterprise Labs** | ⚪ Not started | Catalogue written and unusually honest about hardware limits. |
| **09 Atlas Academy** | 🟢 **Adopted (D6, 2026-07-28)** | ✅ Adopted — `Concepts/` (the "why it works"), the `Command-Library/` (verify commands), and house-style are built. (The stale-guide risk is managed by writing modules against reconciled docs.) |

---

## Critical Risks

### 1. The Root CA has no off-device backup

**Pi01 holds the Root CA private key. Vaultwarden — which holds the passphrase protecting that key — runs on the same Raspberry Pi.**

That Pi had an **unexplained hard hang** requiring a physical power cycle. Root cause never identified. The only backup is a single `tar` taken to an external drive on 2026-07-12.

**If that SSD fails, the following are gone permanently:** the Root and Intermediate CAs, every certificate in the lab, the vault holding both passphrases, every RADIUS secret, Pi-hole, and all local DNS.

**Nothing else in this project is worth doing until this is fixed.** Offline media. Two copies. One off-site.

### 2. FGT01 UTM — ✅ RESOLVED (`ADR-0035`, 2026-07-28)

**Decided: FGT01 runs *without* UTM** (no FortiGuard licence; the stale 2015–2018 signatures are never attached). Detection moves to the **Suricata SPAN tap on MON01**. The dangerous middle ground (a green UTM column over dead signatures) is explicitly forbidden. Revisit only if a bundle is bought.

### 3. Two open device checks blocking the Book 1 freeze

- **Pi01 is not in SW01's `STATIC-HOSTS`**, has a static IP on VLAN 10, and by your own DAI design should be unreachable. It isn't. Nobody knows why.
- **FGT01 and Pi-hole certificate SANs** were never independently verified against the CA-wide `copy_extensions` defect.

---

## Mission

Atlas is the authoritative engineering repository for the enterprise lab.

The objective is documentation sufficient for an engineer to **completely rebuild the environment using Atlas alone**, with no chat history and no memory.

**Atlas is part of production.**

---

## Engineering Rules

- One pack at a time. One page at a time.
- One logical change per commit.
- **One authoritative home per fact.**
- Build Guides describe target state. **Build Records describe verified reality. Records outrank guides.**
- **Verify against live systems. "No error returned" is not evidence.**
- A change is not closed until the Guides it invalidates are reconciled.
- Do not redesign Atlas while a book is under construction. Record ideas; defer them.

> **The process is now more mature than the infrastructure.** Two of nine books exist. There are no backups and no monitoring. **The scaffolding is finished. Stop writing process and go build.**

---

## Phases

### Phase 1 — Enterprise Network — *content complete*

Remaining: resolve the two device checks, reconcile Confluence, **freeze.**

### Phase 2 — Enterprise Virtualization — *draft assembled*

Remaining: ~~PACK-MANIFEST~~ ✅, ~~resolve the `001`–`014` numbering collision with Book 1~~ ✅ **(done 2026-07-13 — Book 2 is now `201`–`217`)**, thicken the Build Records, **freeze.**

**Note:** PVE01's networking is currently documented in *three* places (`028` in Book 1, `004` in Book 2, and a Confluence page). **Decide ownership before freezing either book.**

### Phase 3 — Windows Infrastructure

12-week roadmap written. AD DS → HR-driven provisioning from SQL → client + GPO → services → tiering → nested Hyper-V → Azure/hybrid → DR.

### Phase 4 — Identity and PKI

AD CS, auto-enrolment, certificate templates, NPS. **Coexists with the OpenSSL Lab CA** per ADR-0003 — building both, and comparing them, is the point.

### Phase 5 — Monitoring and Logging

Wazuh, LibreNMS, Grafana, syslog.

> **Promote this.** Centralised logging is the single blocking item on **nine** open findings across three devices. It is worth more than its position suggests.

### Phase 6 — Security
### Phase 7 — Backup and Recovery

> **Should arguably be Phase 0.** See Critical Risks.

### Phase 8 — Enterprise Labs

Certification-quality labs on the completed environment.

**Certification target corrected 2026-07-13:**

| Was | Now |
|---|---|
| AZ-800 + AZ-801 | **AZ-802 — Administering Windows Server** |

Microsoft consolidated AZ-800 and AZ-801 into a single exam, **AZ-802**, and renamed the credential to *Windows Server Administrator Associate* (dropping "Hybrid"). **AZ-800 and AZ-801 retire 30 September 2026.**

**Consequence for `08-Labs`:** its Section 4 maps only to AZ-800's domains. AZ-802 also absorbs AZ-801 — **security hardening, high availability, disaster recovery, server migration, and monitoring are entirely missing from the current lab plan.** Hyper-V is on the exam and Atlas runs Proxmox; **run Hyper-V nested.**

### Phase 9 — Atlas Academy — ✅ *adopted (D6, 2026-07-28)*

Adopted as the estate's "why it works" + "how to verify" layer: `Atlas-Academy/Concepts/`, `Command-Library/`, and house-style are built. Modules are written against reconciled docs (the original stale-guide caution).

---

## Success Criteria

Atlas is complete when:

- Every infrastructure component is documented, with an evidence status.
- Every build can be reproduced from Atlas alone.
- Every production change is tracked, **and every guide it invalidated was reconciled.**
- Every Confluence page reflects the Git repository — **and exactly one page owns each fact.**
- **Atlas can be restored from backup.** *(Currently: it cannot.)*

## 2026-07-28 planning update (what's superseded + what's new)

The book model above is superseded by the **Master-Build-Order v1.6** (11-phase teardown-rebuild) + the **Master-Implementation-Checklist**. Key changes since v2.0:
- **Academy adopted** (D6) · **OpenSSL Lab CA retired → AD CS only** (`ADR-0031`, so Critical-Risk #1's "Root CA on the Pi / Vaultwarden on the same Pi" is being dismantled) · **PVE01-networking ownership resolved** (`ADR-0034`) · **FGT UTM decided = none** (`ADR-0035`).
- **Compute topology (`ADR-0036`):** acquire **PVE02**; split DC02/BKP01/Vaultwarden/PAW01 onto it; home-PC Hyper-V for non-critical/AZ-802/AD-FS. This directly attacks Critical-Risk #1 (no off-host backup) — **Backup (Phase 9) + a real restore Game Day are the top priority.**
- **Cert-gap-analysis Tier-A committed** (gMSA + Kerberos delegation, OCSP + KRA, GPO depth); Tier-B (AD FS+WAP, RODC+site) planned-later; Tier-C skipped. See `Atlas-Cert-Objective-Gap-Analysis.md`.
- The live sequence + per-host build lives in `Master-Implementation-Checklist.md` + `Service-Server-Build-Plan.md`; state is in `SESSION-HANDOFF.md`.

## Change Log

| Version | Changes |
|---|---|
| 2.1 | 2026-07-28. Marked superseded by Master-Build-Order/Implementation-Checklist (banner + planning-update section). **Academy → adopted** (D6); **FGT UTM Critical-Risk → resolved** (`ADR-0035`, no UTM). Recorded the compute-topology (`ADR-0036`) + gap-analysis Tier-A commitments. |
| 1.1 | Initial roadmap. |
| 2.0 | **Dashboard rebuilt from the repository** — the old one understated Foundation by ~90% and Virtualization by 100%. Book 09 added. **Critical Risks section added** — the Root CA has no off-device backup, and that outranks everything else in this document. **AZ-800/AZ-801 replaced with AZ-802** (they retire 2026-09-30). Evidence-precedence corrected to match the Charter. |
