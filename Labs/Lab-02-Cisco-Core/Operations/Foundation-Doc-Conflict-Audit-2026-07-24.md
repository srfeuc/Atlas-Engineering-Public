---
Title: Atlas Foundation Documentation Conflict Audit — 2026-07-24
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 Audit record (flag-only). **No source docs were changed.** HIGH/MED findings re-verified directly 2026-07-24 (see the Verification status block). Each fix is a separate tracked change (`POL-0003`). Per `POL-0001`. Companion to `Doc-Conflict-Audit-2026-07-24.md` (Lab-02 Architecture + Windows docs; this one covers `00-Atlas-Foundation`).
Version: 1.2
Date: 2026-07-24
---

# Atlas Foundation — Documentation Conflict Audit (2026-07-24)

<!-- provenance -->
> **Cross-lab** — a documentation-consistency audit of `00-Atlas-Foundation` against the current, device-verified design (2026-07-24), run alongside the Lab-02 audit before NetBox becomes the source of truth (`POL-0004`). Per `ADR-0008` the Foundation is meant to hold **process only**, so this pass also flags lab-specific technical detail that has leaked in and gone stale, and ADRs that a later decision has overtaken.

## Method
Three independent read-only passes: (1) the design-bearing Foundation docs (`VM-and-Services-Inventory`, `Atlas-Firewall-Architecture`, Charter, Company-Profile, Roadmap set); (2) all 28 ADRs (for supersession + internal staleness); (3) the process/governance/policy/standards/templates corpus. Real text quoted; flag-only.

## The current design (the yardstick)
`atlas.lab`; DC01 `10.20.0.2` promoted, DC02 `10.20.0.3` replica; tier model, OUs Devices/Employees. Addressing `10.<vlan>.0.0/<mask>`, gateways on MKT01; ICA01 `.20.0.4`, SRV01 `.20.0.10`, NetBox `.20.0.11`, MON01 `10.40.0.10`. Topology (ADR-0023): FGT01→1941(routed core)→MKT01(east-west FW + all VLAN gateways)→SW01(L2). Trunks native **999** + management **tagged VLAN 10** (2026-07-24). PKI (ADR-0027): two-tier AD CS (RCA01+ICA01) for domain, OpenSSL (Pi01→CA01) for non-domain (ADR-0003); CRL/AIA on SRV01. Auth: FGT01 direct LDAPS (ADR-0028); network devices NPS-on-DC + FreeRADIUS-**on-SRV01** (ADR-0004). NetBox = source of truth. SRV01 = **Ubuntu**. Lab-01-Mikrotik-Core = **frozen** (MKT01 was core+gateway, no 1941); Lab-02 = active.

## 🔎 Verification status (2026-07-24)
All HIGH/MED findings were **re-verified directly against the source files** (after the M5 error). **Confirmed (quote-checked):** H1, H2, M1, M3, M4, M7, M8, M9. **Corrected:** M5 (v1.1 — see it). **Tempered on re-read:** M2 (the doc explicitly labels the old topology "Today (Book 1)" vs "Book 11 target — ADR-0023"; it does *not* present Lab-01 as unqualified-current) and M6 (ADR-0007's actual decision — renaming device certs — is legitimately still open; only its "does not resolve" note is overtaken). The LOW items and the Lab-02 audit were not re-verified in this pass.

## Severity legend
- **🔴 HIGH** — would drive a wrong build or feed wrong data into NetBox.
- **🟠 MED** — stale/misleading; a decision or fact that has since changed.
- **🟡 LOW** — cosmetic / fossil-in-example / valid-as-frozen-history.

## 🧭 Structural finding (root cause of several below)
The ADR set uses a **forward `Supersedes` header consistently, but no ADR carries a backward "Superseded/amended by" note.** So a factual premise inside an older ADR that a later one has overtaken is invisible to a reader who opens the older ADR. The two that mislead when read alone are **ADR-0007** ("atlas.lab does not resolve") and **ADR-0020** ("DC never promoted"). (ADR-0004 is *not* in this bucket — it's still the accepted base decision; it needs only a small "FGT01 exception → ADR-0028" pointer. See the corrected M5.)

---

## 🔴 HIGH

| # | File | Where | Conflict |
|---|---|---|---|
| H1 | `VM-and-Services-Inventory.md` | Windows Server Roles — "DHCP \| DC01 or DC02" | DHCP shown as a **DC role**; current design = **Kea on SRV01** (VLAN20 `.10`). Wrong-build + wrong NetBox data. |
| H2 | `VM-and-Services-Inventory.md` | VM Roster + Roles tables | **NetBox and SRV01 are absent entirely** — the two most load-bearing hosts (source of truth + services). A "VM & Services Inventory" missing both will misfeed NetBox population. |

## 🟠 MED

| # | File | Where | Conflict |
|---|---|---|---|
| M1 | `VM-and-Services-Inventory.md` | "CA01 \| AD CS — Issuing CA"; PKI "open coexist-vs-replace decision" | Single **CA01** issuing CA + PKI framed as **open**. Current: **ICA01 `10.20.0.4` + offline root RCA01** (two-tier AD CS), decision **settled** (ADR-0027); no RCA01 entry. |
| M2 → **LOW (tempered on re-read)** | `Atlas-Firewall-Architecture.md` | §2 "Today (Book 1)" vs "Book 11 target — settled by `ADR-0023`" | **The 1.0 draft overstated this.** The doc explicitly labels the flat/MKT01-core topology **"Today (Book 1)"** and the 1941-core **"Book 11 target — settled by ADR-0023 (Option B),"** and cites ADR-0023 correctly (incl. the Option-A→B correction). So it does **not** present Lab-01 as unqualified-current. Real (smaller) issue: it **sequences the active Lab-02 1941 topology as a future "Book 11 (the next lab)"** rather than the current build; plus lab device detail in Foundation (`ADR-0008`). Framing/sequencing, not a wrong-current-fact. |
| M3 | `Roadmap/Atlas-Roadmap.md` | Phases — AD CS at **Phase 4**; NetBox unmentioned | Old book sequencing. Current (Next-Lab Design Brief) pulls **NetBox to Phase 1**, Identity/AD to Phase 2, **AD CS forward**. Stale authoritative build order. |
| M4 | `Roadmap/Atlas-Roadmap-Advanced-Scenarios.md` | Azure Hybrid Identity — "Atlas AD (`lab.local`)" | Domain named **`lab.local`** → it's **`atlas.lab`** (ADR-0007). |
| M5 | `Decisions/ADR-0004-NPS-vs-FreeRADIUS.md` + `Architecture/Master-Build-Order.md` | ADR-0004 decision table; Master §Pass-2 vs §Phase-5 | 🔧 **Corrected 2026-07-24 — an earlier subagent-sourced draft of this row overstated it (verified since against the files).** ADR-0004 is **Accepted and still the base decision** (RADIUS split on domain membership: FreeRADIUS on **Pi01** for non-domain devices + NPS for domain) — it is **not** "reversed." **ADR-0028** carved out **only FGT01** to LDAPS and documents that deviation on its own page (ADR-0004 needs at most a one-line "FGT01 exception → ADR-0028" pointer — LOW). The claim "FreeRADIUS moved Pi01→SRV01 (ADR-0023)" was wrong: ADR-0023 only says *MKT01's* RADIUS function leaves it "to SRV01/NPS per Atlas-Service-Architecture.md" (the stale doc). 🔴 **The real finding: the FreeRADIUS host is unreconciled** — ADR-0004 + Master-Build-Order §Pass-2 say **Pi01**; Master §Phase-5 reduces Pi01 to **DNS+NTP only**; the SRV01 Build-Checklist lists FreeRADIUS on **SRV01**; the Build-Progress-Tracker's SRV01 line omits it. No decision record moves it. (The new `SRV01/Build-Guide.md` inherited the SRV01 assumption.) Needs an explicit decision. |
| M6 → **LOW (tempered on re-read)** | `Decisions/ADR-0007-Adopt-atlas-lab-Domain-Suffix.md` | Banner — "NOT IMPLEMENTED … `atlas.lab` … does not resolve" | ADR-0007's **actual decision** is renaming the OpenSSL device certs `<device>.lab` → `<device>.atlas.lab` — and that **is legitimately still unimplemented** (certs valid into 2027; deferred to next renewal). So the *decision* stands and isn't stale. Only the incidental line **"atlas.lab does not resolve"** is overtaken — the **AD domain** `atlas.lab` now resolves via DC01 (ADR-0027/0028). Fix = a one-line "the AD domain now resolves; device-cert renaming still pending" note, not a rework. |
| M7 | `Decisions/ADR-0020-NTP-…md` (+ ADR-0004) | Evidence — "DC01 is a stopped VM, never promoted" | Overtaken (AD live; ADR-0021/0025/0027). Also a **same-day (2026-07-16) contradiction** with ADR-0021 ("a working AD exists"). |
| M8 | `Security-Program/Incident-Response-Playbook.md` | Phase 4 Containment — "pull the **bridgeLocal**/mgmt path" | `bridgeLocal` recovery net was **retired** (ADR-0013); offered as a live containment step, blended among current options. |
| M9 | `Policies/POL-0013-Business-Continuity.md` | Identity continuity — "MKT01 falls back to local when **RADIUS/Pi01** is down" | ✅ verified (line 43). RADIUS located on **Pi01** — stale. Per the **2026-07-24 decision to drop FreeRADIUS entirely** (network-device auth → Windows **NPS** + AD CS), this is doubly wrong: the correct fallback is "when **NPS/the DC** is unreachable," and Pi01 is DNS/NTP only. |

## 🟡 LOW

| # | File | Where | Note |
|---|---|---|---|
| L1 | `VM-and-Services-Inventory.md` | MON01 "matches old MikroTik VLAN comments"; DNS "replaces interim 1.1.1.1/8.8.8.8" | Lab-01 provenance for VLAN40; AD DNS **coexists** with Pi-hole (Pi01), not "replaces." |
| L2 | `Atlas-Firewall-Architecture.md` | whole doc in Foundation | Candidate to **move to Lab-02** per ADR-0008 (companion already moved); the "today" technical content is the stale part. |
| L3 | `Decisions/ADR-0003-AD-CS-vs-OpenSSL-Lab-CA.md` | Context — "AD CS … Book 4 … OpenSSL two-tier on Pi01" | **Not superseded** — ADR-0027 *refines* it (coexist decision still current). Lacks a forward pointer to 0027/0025; OpenSSL intermediate is now **CA01**, not "on Pi01." |
| L4 | `Decisions/ADR-0014-…` + `ADR-0016-…` | MKT01 L2 mgmt / console-deferred | Valid as **frozen Lab-01** history, but Lab-02 re-roles MKT01 (ADR-0023) and **reverses the console deferral** (FTDI cable) — no relationship note. |
| L5 | `Decisions/ADR-0012-…md` | incidental examples — "`Gi1/0/4` native VLAN 10 deliberate"; "atlas.lab … unimplemented" | Now stale (native 999 + atlas.lab live); the ADR's actual decision (quarantine-not-delete) is unaffected. |
| L6 | ADR status hygiene | 0021/0023/0025/0027/0028 headed **"Proposed"** | These are treated as the in-force design and built upon; the `Status` lines read as not-yet-accepted. Lifecycle hygiene. |
| L7 | `Governance/Atlas-Change-Management-Process.md` | "Pi01 hosts … CA" worked example; "Initial Required Changes" Lab-01 punch list "*Still open*" | Fossils stated present-tense in a process doc (CA no longer on Pi01; Lab-01 frozen per ADR-0022). |
| L8 | `Templates/Change-Record-Template.md` | example "`033-Pi01-FreeRADIUS-Build-Guide.md`" | Seeds two Lab-01 fossils (flat `NNN-` numbering + FreeRADIUS-on-Pi01) into every new record. Illustrative only. |

## ✅ Clean / current
`Atlas-Charter.md`; `Company-Profile/301` + `305`; **`Roadmap/Atlas-Next-Lab-Design-Brief.md`** (the current authoritative narrative — NetBox-first, tiered AD, AD CS pulled forward); `Roadmap/Atlas-Improvement-Backlog.md`; `Governance/Atlas-Governance-Framework.md` + `Atlas-Workflow.md`; **`Policies/POL-0001`–`POL-0012`** (esp. **POL-0004** = NetBox as sole SoT ✓, **POL-0008** addressing ✓); `Standards/STD-0001`–`0004`; `Security-Program/` (Compliance, Awareness, Third-Party); `Atlas-Documentation-Standards.md`, `Contributing-Adding-Docs.md`, `README.md`, `Atlas-Public-Release-Sanitization-Plan.md`; most Templates. Most ADRs are valid point-in-time records.

## Recommended reconciliation order (each a separate tracked change)
1. **Before NetBox population:** `VM-and-Services-Inventory.md` (H1/H2/M1) — it's the Foundation's own inventory that NetBox supersedes; get it right or retire it in favor of NetBox.
2. **Highest leverage / lowest effort:** backward pointers on **ADR-0007** and **ADR-0020** (stale factual premises), a one-line FGT-exception pointer on **ADR-0004**, and — the substantive one — **an explicit decision on the FreeRADIUS host** (Pi01 vs SRV01, M5). Status → Accepted on the in-force ADRs (L6).
3. **Topology/order:** update or relocate `Atlas-Firewall-Architecture.md` (M2/L2); re-sequence `Atlas-Roadmap.md` (M3); fix `lab.local`→`atlas.lab` (M4).
4. **Process-doc fossils:** IR playbook bridgeLocal (M8), POL-0013 RADIUS/Pi01 (M9), CM-process Pi01-CA + punch list (L7), template (L8).

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.2 | 2026-07-24 | **Direct re-verification pass** (no subagents) after the M5 error. Quote-confirmed H1, H2, M1, M3, M4, M7, M8, M9 against the files. **Tempered M2** (the doc labels the old topology "Today (Book 1)" vs "Book 11 target — ADR-0023" — a deliberate teaching contrast, not "Lab-01 as current" → LOW) and **M6** (ADR-0007's device-cert-renaming decision is legitimately still open; only its "does not resolve" note is overtaken → LOW). Added the verification-status block. Folded in the **2026-07-24 decision to drop FreeRADIUS** (→ Windows NPS/PKI): resolves M5's open question and makes M9 doubly-stale. LOW items + the Lab-02 audit not yet re-verified. |
| 1.1 | 2026-07-24 | **Corrected M5 (ADR-0004)** after operator flagged it. The 1.0 row (subagent-sourced, unverified) wrongly called ADR-0004 "reversed / priority" and asserted "FreeRADIUS moved Pi01→SRV01 (ADR-0023)." Re-verified directly against ADR-0004 (Accepted base decision), ADR-0028 (FGT01-only carve-out), ADR-0023 (only MKT01's RADIUS→SRV01/NPS, citing the stale service-arch), Master-Build-Order, and the Build-Progress-Tracker. Real finding: the **FreeRADIUS host is unreconciled** (Pi01 vs reduced-Pi01 vs SRV01). Softened the structural finding + reconciliation order to match. |
| 1.0 | 2026-07-24 | Created — `00-Atlas-Foundation` documentation-consistency audit (three read-only passes: design-bearing docs, 28 ADRs, process corpus) vs the 2026-07-24 authoritative design. 2 HIGH, 9 MED, 8 LOW + the ADR backward-supersession structural finding. Governance/policy spine found current (POL-0004/0008 correct); staleness concentrated in `VM-and-Services-Inventory`, `Atlas-Firewall-Architecture`, the Roadmap, and a handful of Pi01/bridgeLocal fossils. Flag-only — no source docs changed. |
