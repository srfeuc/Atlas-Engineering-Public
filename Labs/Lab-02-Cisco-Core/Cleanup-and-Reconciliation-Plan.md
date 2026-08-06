---
Title: Lab-02 Cleanup & Reconciliation — Action Plan (WORKING)
Path: Labs/Lab-02-Cisco-Core
Status: 🟠 WORKING — sequenced plan from `Review-Flag-Register.md` v0.5. **Re-scoped 2026-07-27** after finding the pre-existing 2026-07-24 doc-conflict audits + `ADR-0029`: this plan owns the **new decisions (D1/D4/D7), the learnability layer, and device/ops reconciliation**; the 07-24 audits own the stale-doc conflicts (we execute their reconciliation order, we don't re-derive it). Flag-then-act: each step agreed → bot edits → you commit/verify.
Version: 0.2
Date: 2026-07-27
---

# Lab-02 — Cleanup & Reconciliation Action Plan (re-scoped)

> **What changed in v0.2:** we learned a prior session already banked the FreeRADIUS→NPS decision (`ADR-0029`, 2026-07-24, NPS *on the DC*) and already audited the stale-doc conflicts. So: **D2 is done**, **D7 becomes an amendment** (not a new ADR), only **D1 + D4 are fresh ADRs**, and Phase 2 **executes the 07-24 audits' reconciliation order** rather than re-listing it.

## Ground rules (unchanged)
Flag → agree → bot edits the living doc → **you** commit (PowerShell, not VS Code Source Control) → verify. Follow `Contributing-Adding-Docs` + `Atlas-Documentation-Style-and-Conventions` (frontmatter, provenance, Version + Change Log, `git mv`, global ADR/POL numbering). **POL-0008:** reduce where a fact lives. Owner: 🤖 doc work · 🧑 Seth (decision / device / git). **All work here is docs+planning only — no lab access needed.**

## Phase 0 — Decisions (settled)
- **D7 = dedicated Windows member server for NPS** → **amend `ADR-0029`** (its Decision/Consequences say "on the DC"). You already have spare updated Windows VMs, so the host is a *designate/start/join/role*, not a build-from-scratch. It also becomes the NPS **PEAP server-cert** consumer and the subject for the deferred member-server LAPS tests.
- **D1 = DHCP on DC01**, **D4 = retire OpenSSL Lab CA** — carried into Phase 1 ADRs.

## Phase 1 — Decision records 🤖 draft / 🧑 commit
(Next free ADR numbers after `ADR-0029` = 0030, 0031.)

| ADR | Action | Captures | Register |
|---|---|---|---|
| `ADR-0029` | **AMEND** | NPS host = member server (not DC); keep availability caveat + break-glass; PEAP cert now build-time | A2, A4 |
| **`ADR-0030`** — DHCP on DC01 | **NEW** (supersedes the Kea-on-SRV01 plan) | DnsUpdateProxy/Tier-0 trade-off; DC01/DC02 **failover**; relay→DC01. **Note it inverts the 07-24 "DHCP-on-a-DC is wrong" findings.** | A1 |
| **`ADR-0031`** — Retire OpenSSL Lab CA | **NEW** (reverses `ADR-0003`; `ADR-0027` asks for it) | reissue/reinstall cost for FGT/MKT/Pi-hole; non-domain devices trust AD CS; CA01 disposition; VAULT01 survives | A3 |
| ~~NPS ADR~~ | — | **Already `ADR-0029`.** | D2 ✅ |

## Phase 2 — Reconcile ripples 🤖 edit / 🧑 commit

**2a. Execute the 07-24 audits' reconciliation order (stale-doc conflicts).** They already enumerated + severity-ranked these; we just *do* them (each a tracked change, POL-0003). Their order: before-NetBox (SRV01/CA/DHCP role rows, MON01 addr) → build-blocking (OU names, FGT LDAPS, native-999) → PKI-narrative preamble → cleanups. **Two of our decisions modify their direction:** D1 flips the DHCP rows to **DC01** (not "fix toward Kea/SRV01"); D4 makes the PKI preamble "**AD CS only** (OpenSSL retired)" (not "AD CS + OpenSSL coexist"). *(Effort: M, spread across their list.)*

**2b. Device/Operations reconciliation (ours — the 07-24 audits didn't scope Devices).**
- **C1 backup paths (do EARLY, safety):** `Device-Backup-Runbook` §4 + Pi01 checklist drop `/etc/freeradius` + `/etc/ssl/lab-ca`. *(S)*
- **C2 SRV01:** drop Kea + FreeRADIUS (per ADR-0029 §Consequences + D1); settle Ubuntu-vs-Debian. *(M)*
- **C3 CA01-VAULT01:** split; strike CA01 OpenSSL (D4); Vaultwarden → AD CS cert. *(M)*
- **C4 CIS-Hardening 1941/SW01/MKT01:** Pass-2 wording → NPS-on-member-server; fix MKT01 "AD-LDAPS"; drop SW01 "Pi01=RADIUS". *(M)*
- **C5 FGT CIS/checklist:** route admin-auth to ADR-0028/Guide-2b; drop RADSEC; Index add Troubleshooting+Logging. *(S)*
- **C6/C7:** MKT01 firewall-doc overlap + version drift; Virtualization freeze blockers; Validation stub. *(defer / M)*
> ⚠️ Re-verify C2 (+ any delta-file item) against current text first — some changed on 07-24.

## Phase 3 — Learnability (parallel; ours) 🤖
- **3a. One front door + reading path + glossary (B1)** — de-stale root README + Blueprint; pick the single "start here"; add a repo glossary (ADR/POL/CM + AGDLP/PSO/DSRM/FSMO/native-999…). Consider codifying both in `Atlas-Documentation-Style-and-Conventions`. **Highest leverage.** *(M)*
- **3b. Tracker focus restructure + "where we are" single owner (B5).** *(M)*

## Phase 4 — Atlas Academy (D6, ours) 🤖
- **4a. Adopt** (status bump; pin "link into 303/304, don't duplicate"). *(B3)*
- **4b. Tier-model / AGDLP one-pager** — fixes the doc you couldn't follow; Tiered-Admin links to it. **Early — high personal value.** *(B2)*
- **4c. NPS / RADIUS-vs-LDAPS module** — your ask; pairs with the ADR-0029 amendment.
- **4d. Uncovered-concept explainers** (Windows: FSMO/DFSR/baselines/VBS/DSRM; Network: OSPF-originate/DAI/RouterOS). Preserve the B4 house style. *(ongoing)*

## Phase 5 — D5 migrate-and-test lab 🧑 exec / 🤖 write-ups
After ADR-0031. Reuse `CA-Migration-and-DR-Lab` + `CA-Migration-Handoff-Sanity-Check` + `CA-PKI-Recovery-Objectives-RPO-RTO` + the new `Device-Confirmation-Commands`. Add the FreeRADIUS→VM move + **one real device→RADIUS login** (F14) + capture the live `openssl.cnf` (F12; mind the `.bak`/SAN trap). Write up as the Academy AAA+PKI module.

## Quick-wins to start
1. **C1 backup paths** — safety, tiny, no dependency.
2. **ADR-0030 + 2a DHCP rows** — the DC01/Windows-Infra side already agrees; flip the Architecture Kea/SRV01 rows.
3. **4b tier-model one-pager** — no dependency; directly fixes your comprehension pain.

## Dependency cheat-sheet
| To do… | …first need |
|---|---|
| ADR-0029 amendment (D7) | done (decision made) |
| Phase 2a DHCP rows | ADR-0030 |
| Phase 2a PKI preamble + 2b C3 | ADR-0031 |
| Phase 5 D5 lab | ADR-0031 |
| Phase 3 (nav) + 4b (tier one-pager) | nothing |

## Change Log
| Ver | Date | Change |
|---|---|---|
| 0.2 | 2026-07-27 | **Re-scoped** after finding the 07-24 audits + ADR-0029. D2 done; D7 → amend 0029; D1→ADR-0030, D4→ADR-0031. Phase 2 now *executes* the 07-24 reconciliation order (with D1/D4 changing two directions) + owns device/ops (C1–C7). Learnability/Academy/D5 unchanged. |
| 0.1 | 2026-07-27 | Original 5-phase plan (pre-re-baseline). |
