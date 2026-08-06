---
Title: ADR Index — by Scope and Status
Path: 00-Atlas-Foundation/Decisions
Status: 🟢 LIVING index of all ADRs (ADR-0033). Add a row when you add an ADR.
Version: 1.30
---

# ADR Index — by Scope

> Every ADR (`ADR-0008`: global numbering) tagged with a **Scope** (`ADR-0033`): **Global** = estate-wide principle · **Lab-01** = Lab-01-Mikrotik-Core · **Lab-02** = Lab-02-Cisco-Core. "Global if the principle is estate-wide." Judgment calls open to re-tag: 0005, 0021, 0024.
>
> 🔒 **How an ADR read *before* the #39 reconciliation?** The pre-reconciliation set is frozen verbatim — see [`Legacy-ADR-Index`](./Legacy-ADR-Index.md) (`ADR-0012`).

## Global — estate-wide (process / governance / standards)

| ADR | Title | Status |
|---|---|---|
| ADR-0003 | AD CS vs. the Existing OpenSSL Lab CA: Coexist or Replace | Accepted |
| ADR-0004 | NPS vs. FreeRADIUS: Coexist, Split on Domain Membership | Accepted — 🔴 superseded in part by ADR-0029 (2026-07-24): th |
| ADR-0007 | Adopt `atlas.lab` as the Consistent Internal Domain Suffix | Proposed — captured mid-session, not yet scheduled |
| ADR-0008 | Foundation Holds Process Only; Technology Content Belongs to Its Book | ✅ Accepted — and EXECUTED. Both moves are complete: 303-Wind |
| ADR-0009 | Intermediate CA Not Treated as Compromised | Proposed |
| ADR-0010 | Atlas Repository Publication and Its Preconditions | Accepted |
| ADR-0011 | Game Days: Unannounced Failure Drills That Test the Documentation | Proposed — captured 2026-07-13, deliberately NOT scheduled |
| ADR-0012 | Unverified Published Content Is Quarantined, Not Deleted | Accepted |
| ADR-0015 | Atlas Pack Sequencing and Scope Expansion | Accepted |
| ADR-0018 | The Atlas Operating Model: Team Silos and Ownership Boundaries | ✅ Accepted — 2026-07-17 |
| ADR-0020 | Atlas Time Source: AD-Anchored, an External Bridge Until the Domain Exists | Accepted — 2026-07-16 |
| ADR-0024 | Atlas Industrial IT Headcount: Eight in the Scenario, One at the Keyboard | Proposed |
| ADR-0026 | Adopt the Atlas Governance Framework (Policies Above Decisions) | Proposed |
| ADR-0032 | Diagnostics & Verification Documentation Architecture | Accepted (operator, 2026-07-28). |
| ADR-0033 | ADRs Carry a Scope (Global/Lab-01/Lab-02) + a Scope Index | Accepted (operator, 2026-07-28). |
| ADR-0034 | PVE01 Networking Config Has One Authoritative Home (Virtualization Build-Record) | Accepted (operator, 2026-07-28). Resolves manifest Freeze #2. |
| ADR-0037 | Adopt the Atlas Documentation Standard (per-device & per-service doc architecture) | Accepted (operator, 2026-07-28); amended 2026-07-29 (v1.1) — +`Roadmap.md` +connections map; (v1.2) — +📸/cert/traffic-flow/validation elements + `Operations/` fact-ownership; (v1.4) — +per-device `Automation/` doc-type (`ADR-0048`); (v1.5) — +README **Connections diagram (Mermaid)** + canonical template; (v1.6) — connections-diagram **edges labelled with protocol/port** (`ADR-0049`); (v1.7) — **Services map** README element (operator). |
| ADR-0041 | Incremental, Test-Gated Implementation (one unit at a time; each gate passes before the next) | Accepted (operator, 2026-07-29). |
| ADR-0043 | Scalable, Phased, Dependency-Gated Build-Guides (+ estate build-order consolidation) | Accepted (operator, 2026-07-29). Automation-onboarding section expanded by ADR-0048 (links to the `Automation/` doc-type). |
| ADR-0044 | Built to the Real-World Enterprise Model; Certifications Anchor the Skills | Accepted (operator, 2026-07-29). |
| ADR-0048 | Automation & Infrastructure-as-Code Model (per-device `Automation/` doc-type + estate IaC capability) | Accepted in principle (operator, 2026-07-29). Amends ADR-0037 (Standard v1.4); phased/cert-matched; formalizes Backlog #7/#19. |
| ADR-0049 | Documentation-Session Planning & Handoff Protocol (ask-at-planning · Living-STATE handoff + read rule · edge-labelled diagrams) | Accepted (operator, 2026-07-30). Amends ADR-0037 (Standard v1.6: mermaid edge labels) + extends ADR-0032 (handoff = STATE + append log + read rule). |
| ADR-0052 | The AI-Context Folder (a Durable Onboarding Map for AI Sessions) | Accepted (operator, 2026-07-31). Extends ADR-0049 (durable layer above the per-session handoff); applies POL-0004/0008. |
| ADR-0053 | Atlas Academy Documentation & Navigation Standard (Playbooks · cert-grounded spine · 3-click rule · Playbook template) | Accepted (operator, 2026-07-31). Extends ADR-0032; complements ADR-0037. **Amended 2026-07-31 (§8):** the Playbooks ↔ commissioning-checklist two-way cross-link convention. **Amended 2026-07-31 (§5):** +"Symptoms & search terms" required Playbook element (verbatim errors · plain phrases · aliases · keywords) — the offline-briefcase findability standard, anchored to `#32`. **Amended 2026-07-31 (§5):** +"Gap / what this closes" *optional* element — the gap-analysis note (closed-by-design vs still-open; security-vuln angle), linking to the cross-lab reconciliation & gap map, `#37`. **Amended 2026-08-01 (§5):** +3 formalized elements — the "On this page" quick-nav index, per-step provenance links (each step → the `CM`/`MC` step that proved it), and the "Worked example → the CM/MC doc" section; canonical shape = the golden-template reference `Playbooks/Read-the-Cert-Not-the-Sign-Log.md` (`MC-0002`). **Amended 2026-08-01 (§5):** +command-first-&-point-to-the-fix (action-layer, not a design doc) + explain-the-mechanism-where-a-misconception-bites (plain-language why grounded in the standard, e.g. OpenSSL SAN/`copy_extensions`). |
| ADR-0054 | Governance Reconciliation: Promote Policy-/Standard-Shaped ADRs; ADRs Become Amendments; Backfill `Governing Policy` | Proposed (2026-07-31). Executes ADR-0026 §4/§5-step-4; proposes POL-0014/0015/0016. Working list: `Governance/Governance-Reconciliation-Triage.md`; execution = Backlog #32. |

## Lab-01-Mikrotik-Core (frozen)

| ADR | Title | Status |
|---|---|---|
| ADR-0001 | PVE01 Work Proceeded in Parallel with Network, Before Freeze | Accepted (retroactive) |
| ADR-0002 | SW01 Gi1/0/3 VLAN Assignment (Windows-Laptop) | Accepted |
| ADR-0005 | FGT01 Firewall Policy Scope: Keep Broad Pending Network Redundancy | Accepted |
| ADR-0006 | Foundation Enrichment Proceeded Before Network Freeze | Accepted (retroactive) |
| ADR-0013 | Retirement of `bridgeLocal`, the Admin Recovery Network | Proposed — gated, deliberately NOT scheduled |
| ADR-0014 | MKT01 Layer-2 Management Posture: MAC-WinBox, MAC-Telnet, Neighbor Discovery, and the Missing Console | ✅ ACCEPTED — operator, 2026-07-14. Option C: MAC-WinBox scop |
| ADR-0016 | MKT01 Recovery Posture: Serial Console Deferred, MAC-WinBox Accepted With Known Limits | ✅ Accepted — operator, 2026-07-14 |
| ADR-0017 | Defer `CM-0012` (PVE01 CMOS Battery) and Freeze Book 1 | ✅ Accepted — 2026-07-14 |
| ADR-0019 | The Book 1 Audit Mandate: Coverage, Not Threads | Accepted — 2026-07-14 |
| ADR-0022 | Freeze Book 1 at `a03458f`; Defer the Residual Device Punch-List | ✅ Accepted — 2026-07-16 |

## Lab-02-Cisco-Core (active)

| ADR | Title | Status |
|---|---|---|
| ADR-0021 | Active Directory Becomes the Tiered Identity Backbone | Proposed — 2026-07-16 (operator accepts by moving to Accepte |
| ADR-0023 | Lab-02 Core & Segmentation Topology: 1941 as Core Router, MKT01 as Internal East-West Firewall | Proposed |
| ADR-0025 | Lab-02 Holds the Network and Identity Tracks in Tandem (Reversing the Throwaway-DC Stance) | Proposed |
| ADR-0027 | AD CS Two-Tier PKI, Built the Microsoft-Recommended Way | Proposed — 2026-07-22 (operator accepts by moving to Accepte |
| ADR-0028 | FGT01 Admin Auth via Direct LDAPS | Proposed — 2026-07-22 (operator accepts by moving to Accepte |
| ADR-0029 | Drop FreeRADIUS: Network-Device Auth Consolidates on Windows NPS | Accepted — amended 2026-07-27 (D7): the NPS host is a dedica |
| ADR-0030 | DHCP Consolidates on DC01 (Not Kea on SRV01) | Accepted (operator, 2026-07-28). |
| ADR-0031 | Retire the OpenSSL Lab CA: One Unified PKI on AD CS | Accepted (operator, 2026-07-28). Reverses ADR-0003. |
| ADR-0035 | FGT01 Runs Without UTM (No FortiGuard Subscription) | 🔴 **Superseded / reversed by ADR-0047** (2026-07-29) — UTM now purchased. |
| ADR-0036 | Atlas Compute Topology: Second Proxmox Host + VM Placement | Accepted as target topology (operator, 2026-07-28). Closes register A3a. **v1.3 (2026-07-30, #20 sweep):** placement/sizing single source = `Service-Server-Build-Plan` (this ADR = the principle); `VM-and-Services-Inventory` RETIRED; both hypervisor hosts on VLAN 10 (PVE01 `.10` / PVE02 `.11`); reaffirmed principle 1 vs a DC02 drift (DC02 stays R410; ICA01/SRV01 → EQR6). |
| ADR-0038 | pfSense as a Transparent Inline IPS on the North-South Edge Transit | Accepted (operator, 2026-07-29). 🟡 Reshaped by ADR-0047 — kept as free/complementary IPS + comparison. **Build sub-decisions resolved 2026-07-30 (v1.2): physical 2-NIC appliance · fail-closed · monitor-first · Suricata.** |
| ADR-0039 | Commit the Estate to a Full Hybrid Enterprise (scope) | Accepted (operator, 2026-07-29). Phased build. |
| ADR-0040 | Entra Connect Uses Password Hash Sync (PHS) as Primary Hybrid Auth | Accepted (operator, 2026-07-29). |
| ADR-0042 | Client Workstation Fleet + Department Resource Access | Accepted (operator, 2026-07-29). Phased. |
| ADR-0045 | AZ-800/801-Driven Compute Additions: WAC01, a Container Host, and the RODC | Accepted (operator, 2026-07-29). Extends ADR-0036; confirms C5 RODC. **WAC01 VLAN → 10 + placement → PVE02/EQR6 per operator 2026-07-30** (review trigger; overrides the VLAN-20 / PVE01 defaults). **CNT01 folder created + scoped 2026-07-30:** platform = **hybrid** (Linux Docker/Podman primary + a Windows-container AZ slice); purpose = the **estate self-hosted git/CI** (Backlog #19 / the ADR-0048 estate-capability half); the **#19 estate-capability ADR** (self-host-vs-GitHub · GitOps model · runner placement) is still owed. 🔎 **This ADR should be fleshed out** (the container-host + RODC decisions written up). |
| ADR-0046 | Two-Node Failover Cluster + Storage Spaces Direct (HA workload/storage/witness) | Accepted in principle (operator, 2026-07-29). Build-gated on PVE02. |
| ADR-0047 | FGT01 Runs FortiGuard UTM (Reverses ADR-0035; Reshapes ADR-0038) | Accepted in principle (operator, 2026-07-29). Subscription being purchased; profiles applied + DB-verified at build. |
| ADR-0050 | FGT01 TLS/SSL Deep-Inspection Scope + ICA01 Inspection-CA Distribution (Section-K K1) | Accepted (operator, 2026-07-30). Selective deep-inspect where ICA01 trust is GPO-distributed (domain client/user + server VLANs); certificate-inspection elsewhere; explicit bypass for pinned apps + banking/health/privacy + non-domain devices; re-signing CA = ICA01 subordinate. Formalizes Section-K K1. |
| ADR-0051 | DNS-Filtering Ownership: Pi-hole Owns It, FortiGuard DNS-Filter Off (Section-K K2) | Accepted (operator, 2026-07-30). Pi-hole (Pi01) is the single DNS-filtering home; FortiGuard DNS-filter stays OFF (FGT UTM keeps web/AV/IPS/app-control per ADR-0047). **Refines** Section-K K2's earlier "both, layered" recommendation to single-owner. |

## Change Log
| Version | Changes |
|---|---|
| 1.28 | 2026-07-31. Annotated **ADR-0053** → **+§5 "Gap / what this closes" (optional)** — a gap-analysis element on a Playbook naming a structural gap the incident exposed (a design weakness the current lab closes, or one still open in the partial build; security-vulnerability angle where it applies), linking to the new cross-lab **`Atlas-Academy/Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md`** and the Review-Flag-Register / backlog. Gap analysis adopted as a key Atlas tool (Backlog **#37**). No new ADR. |
| 1.30 | 2026-08-01. Annotated **ADR-0053** → **+§5 two required elements** (from the operator's review of the golden template): **command-first & point-to-the-fix** (a Playbook is the action layer — foreground the exact `show`/`get`/`openssl` reads and link to the doc that owns the fix, don't re-derive it as a design doc) and **explain-the-mechanism where a misconception bites** (a plain-language "how it actually works and why the naive assumption fails" note grounded in the real standard/default — e.g. the OpenSSL SAN / `copy_extensions` mechanism). Both demonstrated by the golden-template reference `Playbooks/Read-the-Cert-Not-the-Sign-Log.md` v1.1. **Also refined the `#32` element:** verbatim error strings go **one per bullet** (don't `·`-join), each optionally tagged with its failure mode + resolving step — differentiates and narrows. No new ADR. |
| 1.29 | 2026-08-01. Annotated **ADR-0053** → **+§5 three formalized elements** (form operator-confirmed at `Session-26` planning, `ADR-0049`): the **On this page** quick-nav index; **per-step provenance** links (each diagnosis-path step points to the `CM-####`/`MC-####` step that proved it); the **Worked example → the CM/MC doc** section (walk the real incident, quote the frozen read-backs, link the authoritative record). Previously demonstrated but not formalized; now canonical, set by the **golden-template reference `Atlas-Academy/Playbooks/Read-the-Cert-Not-the-Sign-Log.md`** (built from the device-verified `MC-0002`). No new ADR. |
| 1.27 | 2026-07-31. Annotated **ADR-0053** → **+§5 "Symptoms & search terms"** — a required, rich, plain-spoken findability element on every Playbook (verbatim error strings · plain-language symptom phrases · aliases/also-known-as · a keywords line), so the offline briefcase surfaces the page when the operator searches *what he is seeing, in his own words*. Anchored to Backlog **#32** (searchable / ticket-ready / offline briefcase). From the **#36** Playbook-building slice (building the Lab-01 mining queue into very-descriptive, searchable, ticket-ready Playbooks). No new ADR. |
| 1.26 | 2026-07-31. Annotated **ADR-0053** → **+§8** (the Playbooks ↔ commissioning-checklist two-way cross-link convention: a checklist's Cover links *down* to Playbooks; a Playbook's `Related` links *back* to the checklist phase — "check the commissioning checklist for this item"; one home per fact, `POL-0008`). From the **#33** golden-checklist / **#31(b/c)** Playbooks slice — which also added the `Domain-Join-Fails` Playbook. No new ADR. |
| 1.25 | 2026-07-31. Added **ADR-0054** (Governance Reconciliation — promote policy-/standard-shaped ADRs, ADRs become amendments, backfill `Governing Policy`; proposes **POL-0014/0015/0016**; working list `Governance/Governance-Reconciliation-Triage.md`; execution = Backlog **#32**) to the Global section. |
| 1.24 | 2026-07-31. **Backfill** — added the **ADR-0053** (Atlas Academy Documentation & Navigation Standard) row to the Global section; the ADR file existed on disk but this index row had never landed (device-authoritative reconcile, Rule 13). |
| 1.23 | 2026-07-31. **Backfill** — added the **ADR-0052** (AI-Context Folder) row to the Global section; same reconcile as 1.24 (row had never landed). |
| 1.22 | 2026-07-30. Added **ADR-0050** (FGT01 TLS deep-inspection scope + ICA01 inspection-CA distribution — Section-K **K1**) + **ADR-0051** (DNS-filtering ownership: **Pi-hole owns it, FortiGuard DNS-filter OFF** — Section-K **K2**; **refines** the earlier "both, layered" recommendation to single-owner) to the Lab-02 section. Both formalize the owed Section-K cluster ADRs from the FGT01 #22 pass. Propagated to `Pre-Build-Decisions` §K1/§K2 (status ✅ + lands-in) + FGT01 Considerations. |
| 1.21 | 2026-07-30. **#20 sweep** — annotated **ADR-0036** with its **v1.3** reconciliation: `Service-Server-Build-Plan` named the placement + sizing single source (this ADR keeps the principle only); **`VM-and-Services-Inventory` RETIRED**; both hypervisor hosts on VLAN 10 (PVE01 `10.10.0.10` / PVE02 `10.10.0.11` 📋); principle 1 reaffirmed against a DC02 drift (DC02 stays PVE01/R410; ICA01 + SRV01 → PVE02/EQR6). No new ADR. |
| 1.20 | 2026-07-30. Annotated **ADR-0037** → Standard **v1.7**: the per-device **Services map** README element (Service · Purpose · Consumed-by+port · Depends-on · Status; operator ask). Debuted on KALI01/SIEM01; backfill into existing READMEs = a high-priority Backlog item. |
| 1.19 | 2026-07-30. Annotated **ADR-0038** — build sub-decisions **resolved** (operator; `ADR-0049` ask-at-planning): **physical 2-NIC appliance** (D2a) · **fail-closed** (+ manual transit-bypass break-glass + monitor-first + fail-open review-trigger fallback) · **monitor-only-first rollout** (`ADR-0041`) · **Suricata** engine. ADR → v1.2. Feeds `Devices/PFSENSE01-IPS/`. |
| 1.18 | 2026-07-30. Annotated **ADR-0045** — **CNT01 container-host folder created + scoped** (Batch B): platform **hybrid** (Linux Docker/Podman primary + a Windows-container AZ-800/801 slice); purpose = the **estate self-hosted git/CI** (Backlog #19 / the ADR-0048 estate-capability half); the **#19 estate-capability ADR** remains to be written; flagged that ADR-0045 itself should be fleshed out (operator). From the Batch-B replication pass. |
| 1.17 | 2026-07-30. Annotated **ADR-0045** — WAC01 **VLAN → 10 (management)** + placement **→ PVE02/EQR6 always-on** per operator 2026-07-30 (exercises the ADR's own VLAN review trigger; overrides its VLAN-20 / PVE01 defaults; WAC is a Tier-0 admin surface → the mgmt plane). WAC01 page-set done → **replication Batch A complete**. |
| 1.16 | 2026-07-30. Added **ADR-0049** (Documentation-Session Planning & Handoff Protocol — ask-at-planning norm · Living-STATE handoff + read rule + archiving · per-device narrowing · edge-labelled connection diagrams) to the Global section. Annotated **ADR-0037** (amended → Standard **v1.6**: mermaid edges labelled with protocol/port) + extends **ADR-0032** (handoff read-to-state contract). |
| 1.15 | 2026-07-30. Annotated **ADR-0037** → Standard **v1.5** (+ README **Connections diagram (Mermaid)** element + canonical template; Workflow v1.5). Backfilled into the 8 existing device READMEs. No new ADR. |
| 1.14 | 2026-07-29. Added **ADR-0048** (Automation & IaC model — per-device `Automation/` doc-type + the estate IaC capability; phased/cert-matched; Learning-Rule reconciliation) to the Global section. Annotated **ADR-0037** (amended → Standard v1.4: +`Automation/` doc-type) + **ADR-0043** (Automation-onboarding section expanded). Formalizes Improvement-Backlog #7 + #19. |
| 1.13 | 2026-07-29. Added **ADR-0047** (FGT01 runs FortiGuard UTM — **reverses ADR-0035**, **reshapes ADR-0038**) to the Lab-02 section. Annotated the **ADR-0035** row (superseded/reversed) + the **ADR-0038** row (reshaped — pfSense kept as free/complementary IPS + comparison). Unlocks the FortiGate FCP lab-map §3 (register G5). |
| 1.12 | 2026-07-29. Added **ADR-0045** (AZ-800/801 compute additions — WAC01 + container host + RODC; extends ADR-0036) + **ADR-0046** (2-node Failover Cluster + S2D; HA workload/storage/witness; build-gated on PVE02) to the Lab-02 section. Both from the AZ-800/801 sweep (`Atlas-Academy/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md`). |
| 1.11 | 2026-07-29. Added **ADR-0044** (Built to the real-world enterprise model; certifications anchor the skills; Scope **Global**) to the Global section. |
| 1.10 | 2026-07-29. Added **ADR-0043** (Scalable, Phased, Dependency-Gated Build-Guides + the estate build-order consolidation; Scope **Global**) to the Global section. Amends the `ADR-0037` Build-Guide doc-type (→ Standard v1.3, pending) and consolidates the Lab-02 order docs (register E2). |
| 1.9 | 2026-07-29. **ADR-0037 amended → v1.2** — four per-device analytical elements (📸 captures · `Roadmap` Certification alignment · staged Traffic-flow · Validation link) + `Operations/` added to the fact-ownership map. Row annotated; governing docs Standard/Workflow → v1.2. |
| 1.8 | 2026-07-29. Added **ADR-0042** (Client Workstation Fleet + Department Resource Access; Scope **Lab-02**) to the Lab-02 section — a lean client fleet (WS-HR01/WS-ENG01/LT-SALES01/WS-IT01) as the estate's test clients for GPO / AGDLP dept access / LAPS / segmentation / Intune. |
| 1.7 | 2026-07-29. Added **ADR-0041** (Incremental, Test-Gated Implementation; Scope **Global**) to the Global section — the estate build discipline (one unit at a time; per-unit positive+negative acceptance gate; ✅ only on a passing gate; adversarial gates → Validation matrix). |
| 1.6 | 2026-07-29. Added **ADR-0039** (commit to a full hybrid enterprise — scope) + **ADR-0040** (Entra Connect = PHS) to the Lab-02 section. Closes `Pre-Build-Decisions` F-series + F2. |
| 1.5 | 2026-07-29. Added **ADR-0038** (pfSense transparent inline IPS on the FGT01↔1941 N-S transit; Scope Lab-02) to the Lab-02 section — closes `Pre-Build-Decisions` D1/D2. |
| 1.4 | 2026-07-29. **ADR-0037 amended (v1.1)** — added the `Roadmap.md` doc-type + the connections-map requirement (from the DC exemplar; governing docs `Atlas-Documentation-Standard`/`-Workflow` → v1.1). Row annotated. |
| 1.3 | 2026-07-28. Added **ADR-0037** (Atlas Documentation Standard - per-device & per-service doc architecture; Scope Global) to the Global section. Bumped this index frontmatter Version 1.0->1.3 to match its own change log. |
| 1.2 | 2026-07-28. Added **ADR-0035** (FGT01 no-UTM) + **ADR-0036** (compute topology: 2nd Proxmox host + VM placement; closes A3a) to the Lab-02 section. |
| 1.1 | 2026-07-28. Added **ADR-0034** (PVE01-networking ownership → Virtualization Build-Record; Scope Global) to the Global section. |
| 1.0 | 2026-07-28. Created (`ADR-0033`). Indexes ADR-0001…0032 by Scope + status. |