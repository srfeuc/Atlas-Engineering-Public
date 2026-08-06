---
Title: Atlas — Cert-Objective Gap Analysis (70-741 / 70-742 vs the lab)
Path: 00-Atlas-Foundation/Roadmap
Status: 🟢 Reference / roadmap input — captured 2026-07-28. A menu of net-new learning topics, not a build order. Deduped against `Atlas-Next-Lab-Design-Brief`, `Atlas-Roadmap-Advanced-Scenarios`, and `Atlas-Improvement-Backlog` as of this date.
Version: 1.0
Date: 2026-07-28
---

# Atlas — Cert-Objective Gap Analysis

## Purpose / how to use this

Seth reviewed the tables of contents of two Microsoft cert study books —
**Exam 70-741 (Networking with Windows Server 2016)** and **Exam 70-742 (Identity with Windows Server 2016)** —
and asked: *"the lab's goal is to learn — is there anything in here worth adding?"*

This doc is the answer, captured so the reasoning lives in the repo. It is a **menu of learning topics that are genuinely absent** from both the current lab and the existing roadmap, **ranked by learning-value ÷ effort × fit**. It is **not** a build order and does **not** supersede the phase plan in `Atlas-Next-Lab-Design-Brief`. Each item notes its exam mapping, rough effort, prerequisites, and where it plugs into work already in the repo.

**Headline finding:** the 70-742 (Identity) book is essentially Atlas's own blueprint — most of it is built or already sequenced — so the value is in a handful of *depth* topics. The 70-741 Ch9 material is mostly Hyper-V / datacenter-fabric and is a **poor fit** for a Proxmox lab (see Tier C).

> **⚠️ Dedup caveat:** this was deduped against the roadmap on 2026-07-28. Before actioning, re-check those three docs — if the roadmap moved, some items may have been picked up.

## Baseline — what the lab already has or has sequenced (do not re-derive)

Built or in-flight: AD DS (DC01/DC02), OUs (Devices/Employees), users/groups, **PSO + account policies**, **tiered admin (PAW, Tier 0/1/2, LAPS, DSRM)**, GPO (baseline/PSO/LAPS), **two-tier AD CS** (RCA01 offline root + ICA01 issuing — being built per `ADR-0027`), **NPS/RADIUS** (`ADR-0029`; host = `NPS01` member server per D7), **FGT01 LDAPS** (`ADR-0028`), NetBox, SRV01, MON01, Pi01, Proxmox, east-west segmentation (MKT01 + allowed-flows matrix), native VLAN 999.

Already on the roadmap (so **not** re-listed as gaps below):
- **AD backup / DSRM / AD Recycle Bin / authoritative restore** → the DR Game-Day catalogue in `Atlas-Roadmap-Advanced-Scenarios`.
- **Azure hybrid identity (Azure AD Connect, Conditional Access)** → the Azure Integration advanced phase.
- **Multidomain / multiple domains** → the MSP simulation (customera.local / customerb.local). *(Enrichment idea: the MSP sim keeps those domains isolated — adding a **forest trust** between them would cover the 70-742 Ch7 trust objectives it currently skips.)*
- **CCNP routing (OSPF/HSRP/IP SLA/ZBF/QoS)** → the CCNP advanced-scenarios.

---

## Tier A — high value, low cost, extends work already in flight

### A1. Kerberos delegation (constrained + resource-based) & gMSA
- **What:** group Managed Service Accounts (password-less, auto-rotating service identities) and Kerberos delegation — unconstrained vs **constrained** vs **resource-based constrained delegation (RBCD)**.
- **Why it fits:** delegation abuse (unconstrained, RBCD) is one of the top real-world AD attack paths — configuring it *and seeing why the insecure form is dangerous* is dead-on-theme with the tiering/PAW security focus. gMSA fits the `POL-0002` "no stored secrets" discipline. **The KDS root key already exists** (created during DC01 promotion), so gMSA is immediately doable.
- **Exam:** 70-742 Ch3 (Managing Service Accounts; Kerberos Delegation).
- **Effort:** Low. Existing DCs + one Windows service to run under the gMSA.
- **Plugs into:** service-account hygiene generally; **AD FS (A/B below) runs under a gMSA by default**, so this is a natural precursor.

### A2. AD CS — Online Responder (OCSP) + Key Recovery Agent (key archival/recovery)
- **What:** stand up an **OCSP Online Responder** alongside the existing CRL/CDP; configure a **Key Recovery Agent** to escrow and recover private keys.
- **Why it fits:** the two-tier CA is being built now and `ADR-0009` is essentially a monument to getting revocation right. OCSP is the modern revocation-check path that complements the CRL. KRA teaches key escrow/recovery (distinct from, but related to, the `ADR-0009` key/passphrase-separation discipline).
- **Exam:** 70-742 Ch8 ("Configuring the Online Responder"; "Key and Certificate Archival and Recovery").
- **Effort:** Low–Med. Extends the CA already in build; OCSP is a role service on a member server (or ICA01-adjacent), KRA is a template + CA config.
- **Plugs into:** `RCA01-ICA01-ADCS/AD-CS-Two-Tier-Build-Guide.md` (add Part for OCSP + KRA); `Part 4` revocation gate.

### A3. Group Policy depth
- **What:** loopback processing, WMI filtering, security/item-level targeting, the **ADMX central store**, GPO backup/restore/migration, RSoP / Group Policy Modeling.
- **Why it fits:** GPOs already exist; these are the techniques that turn "I made a GPO" into "I can target, filter, and troubleshoot GPOs." Group Policy is 25–30% of the 70-742 exam.
- **Exam:** 70-742 Ch4/5.
- **Effort:** Low. All exercisable on the existing DCs + a member server / client.
- **Plugs into:** `DC-Domain-Controllers/GPO-Design-and-Build.md`.

---

## Tier B — high value, bigger build, deserves its own pack

### B1. AD FS + Web Application Proxy (WAP)
- **What:** federation and SSO — claims, SAML/OAuth/OIDC, relying-party trusts, MFA hooks — with **WAP** as the DMZ reverse proxy that publishes AD FS.
- **Why it fits / why it's not a dup:** this is the one entire identity domain the lab doesn't touch. It is **not** the Azure AD Connect already queued in the Azure phase — directory **sync ≠ federation/SSO**; they are different capabilities. AD FS runs under a **gMSA (A1)** and needs a cert from **the AD CS (A2)**, so it slots in cleanly once the CA is live.
- **Exam:** 70-742 Ch9 (Implementing Identity Solutions).
- **Effort:** Med–High. Needs an AD FS VM + WAP in the DMZ (VLAN 80) + a sample relying-party app.
- **Prereq:** two-tier AD CS live; gMSA (A1) recommended first.

### B2. RODC + a second AD site
- **What:** a **Read-Only Domain Controller** (branch-office pattern) with a password replication policy and filtered attribute set, placed in its **own AD site/subnet** with a site link.
- **Why it fits:** teaches replication internals (intersite vs intrasite, KCC/ISTG) and a real security pattern — a DC in a location you can't physically trust. Complements the single-site design in place today.
- **Exam:** 70-742 Ch6/7 (RODC; Sites; Replication).
- **Effort:** Med. One extra VM + a second subnet/site definition.

---

## Tier C — skip or defer (recorded so a future session doesn't re-suggest)

- **70-741 Ch9 datacenter networking** — NIC Teaming/SET, VMQ, RSS, SR-IOV, SMB Direct/Multichannel, DCB. These are **Hyper-V host + RDMA-NIC** features; they can't be meaningfully exercised on an R410 running **Proxmox**. Networking learning is better served by the CCNP routing track already on the roadmap. **Skip.**
- **Microsoft SDN** (Network Controller, HNV, Software Load Balancing, Windows Server Gateways, distributed firewall policies, **Network Security Groups**) — heavy, Hyper-V / Azure-Stack-oriented. The actual lesson (per-flow east-west segmentation) is **already implemented** via MKT01 + the allowed-flows matrix — an NSG rule *is* one of the named allows. **Skip.**
- **AD RMS** (70-742 Ch9) — information rights management; genuinely sunsetting (Azure Information Protection / Purview is the modern path). Conceptually interesting but heavy and dated. **Defer / low.**

---

## Recommended next two moves (learning-per-effort)

1. **A1 — Kerberos delegation + gMSA.** Cheap, KDS root key already present, high security-learning payoff, and it unblocks AD FS.
2. **A2 — OCSP + KRA on the CA.** Extends the two-tier PKI already in build; natural continuation of the `ADR-0009` revocation theme.

Then, once the two-tier CA is live: **B1 — AD FS + WAP** as the identity capstone.

## Source material

| Book / exam | Scope | Verdict for Atlas |
|---|---|---|
| **70-742 — Identity with Windows Server 2016** | AD DS, GPO, AD CS, AD FS, AD RMS, WAP | **Strong fit** — it *is* the lab's blueprint; value is in the depth topics above (A1–A3, B1, B2). |
| **70-741 — Networking with Windows Server 2016**, Ch9 (Advanced Network Solutions) | NIC teaming/SET, DCB, QoS, RSS, VMQ, SR-IOV, SMB Direct/Multichannel, SDN, SLB, gateways, distributed firewall, NSGs | **Poor fit** — Hyper-V/datacenter-fabric; the transferable lesson (segmentation) is already covered. See Tier C. |

## Related docs

- `00-Atlas-Foundation/Roadmap/Atlas-Next-Lab-Design-Brief.md` (the authoritative phase plan this sits on top of)
- `00-Atlas-Foundation/Roadmap/Atlas-Roadmap-Advanced-Scenarios.md` (CCNP / PKI-DR / MSP / Azure phases — where AD backup-DR and multidomain already live)
- `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md` (Tier 1–3 gaps)
- `00-Atlas-Foundation/Decisions/ADR-0027` (AD CS — extend for A2), `ADR-0029` (NPS/`NPS01`), `ADR-0021` (tiered identity — the frame for A1)
- `Labs/Lab-02-Cisco-Core/Devices/RCA01-ICA01-ADCS/AD-CS-Two-Tier-Build-Guide.md` (A2 lands here) · `Devices/NPS01-Network-Policy-Server/Build-Guide.md`

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-28 | Created from Seth's review of the 70-741 + 70-742 study-book TOCs vs the current lab + roadmap. Ranked net-new learning topics: Tier A (Kerberos delegation + gMSA; OCSP + KRA; GP depth), Tier B (AD FS + WAP; RODC + second site), Tier C skip/defer (70-741 Ch9 datacenter net; MS SDN; AD RMS). Noted already-on-roadmap items (AD backup-DR, Azure hybrid, multidomain) and a forest-trust enrichment for the MSP sim. Deduped against the three Roadmap docs as of this date. |
