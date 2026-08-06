---
Title: Tier B + Tier C — Planning-Session Brief (AD FS+WAP · RODC+site · exam-topic skip/defer)
Path: 00-Atlas-Foundation/Roadmap
Status: 🟢 Handoff/brief — read this to run a docs-only PLANNING pass on the cert-gap-analysis Tier B and Tier C items. Not a build; produces designs + ADRs, like the 2026-07-28 planning session did for the main roadmap.
Version: 1.0
Date: 2026-07-28
---

# Tier B + Tier C — Planning-Session Brief

<!-- provenance -->
> **Purpose.** A fresh session uses this to **plan** the gap-analysis **Tier B** (AD FS + WAP; RODC + second site) and to **finalize the Tier C** skip/defer decisions — a docs-only pass that produces designs, ADRs, and build-guide outlines. It does **not** build anything. Tier A (gMSA/Kerberos delegation, OCSP+KRA, GPO depth) is already committed into the roadmap and is the prerequisite chain for Tier B.

> **Context to load first (everything the pass needs):**
> - `Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md` (v13) — where the estate is.
> - `00-Atlas-Foundation/Roadmap/Atlas-Cert-Objective-Gap-Analysis.md` — the source ranking (Tier A/B/C).
> - `ADR-0036` (compute topology) — **the home-PC Hyper-V is the intended home for the AD FS lab**; PVE02 for redundancy.
> - `Labs/Lab-02-Cisco-Core/Master-Implementation-Checklist.md` — where these phases slot in (Phase 11 / advanced).
> - `ADR-0027` (AD CS — the cert source), `ADR-0021` (tiered identity), `ADR-0025` (Lab-02 holds both tracks).

## How to run the pass (mirror the 2026-07-28 method)
1. **Confirm prerequisites are real** (don't plan on sand): two-tier AD CS live (for certs), gMSA available (Tier-A A1), and a decision on where each new VM lands (`ADR-0036`).
2. **Surface + close the open decisions** (listed per item below) with `AskUserQuestion` before authoring.
3. **Produce, per adopted item:** an **ADR** (the decision + rationale + scope), a **build-guide outline** (steps + prereqs + acceptance read-backs), and the **placement** on the compute topology. Add each to `ADR-Index.md`, the roadmap, and the Master-Implementation-Checklist (advanced phases).
4. **Mark everything 🟡/📋** — these are designs, not built (`POL-0001`).

---

## Tier B1 — AD FS + Web Application Proxy (WAP)

**What:** federation / SSO — claims, SAML / OAuth2 / OIDC, relying-party trusts, MFA hooks — with **WAP** as the DMZ reverse proxy that publishes AD FS to the outside.

**Why it's not a duplicate (state this up front in the ADR):** this is **federation**, *not* the **Azure AD / Entra Connect *sync*** already queued in the Azure phase. Directory sync ≠ SSO/federation — different capabilities. AD FS is the one identity domain the lab doesn't yet touch.

**Dependencies (the reason it's Tier B, after Tier A):**
- **Two-tier AD CS live** — AD FS needs a service-communication cert + token-signing certs from ICA01.
- **gMSA (Tier-A A1)** — AD FS runs under a group Managed Service Account by default (ties to the `POL-0002` no-stored-secrets discipline).
- A **sample relying-party application** to prove SSO against (operator picks — see open decisions).

**Placement (`ADR-0036`):** an **AD FS VM** (member server) + a **WAP VM in the DMZ (VLAN 80)**. The **home-PC Hyper-V** is the intended home — non-critical, experiment-friendly, and it doubles as AZ-802 Hyper-V practice. Keep AD FS itself Tier-1-ish (it's identity-adjacent — decide its tier explicitly).

**Exam:** 70-742 Ch9 (Implementing Identity Solutions). **Effort:** Med–High.

**Open decisions for the pass:**
- Which **relying-party app** to publish (a simple internal web app? a SAML test SP? Grafana/NetBox OIDC?).
- **Protocol focus** — SAML vs OIDC/OAuth first (or both).
- **WAP in VLAN 80 (DMZ)** — confirm the east-west flow (DMZ→AD FS:443) and that it doesn't breach the DMZ-must-not-reach-interior rule beyond the one published endpoint.
- AD FS **tier** placement (Tier 0 vs Tier 1) — it issues tokens, so treat carefully.

**Deliverables:** an ADR (adopt AD FS+WAP as the identity capstone), a build-guide outline (AD FS farm → cert/gMSA prereqs → relying-party trust → WAP publish → MFA hook → SSO acceptance test), and the DMZ flow addition to the allowed-flows matrix.

## Tier B2 — RODC + a second AD site

**What:** a **Read-Only Domain Controller** (branch-office pattern) with a **Password Replication Policy** and a **filtered attribute set**, placed in its **own AD site/subnet** with a **site link**.

**Why it fits:** teaches replication internals (**intersite vs intrasite, KCC/ISTG**, site links, cost) and a real security pattern — a DC in a location you can't physically trust. Complements the current single-site design.

**Placement:** one extra VM (**home-PC Hyper-V** or **PVE02**) + a **second subnet/site** definition. The "branch" can be a distinct VLAN or the Hyper-V host's network.

**Exam:** 70-742 Ch6/7 (RODC; Sites; Replication). **Effort:** Med.

**Open decisions for the pass:**
- Where the **"branch" subnet/site** lives (a new VLAN? the Hyper-V host network?).
- **PRP scope** — which accounts' passwords the RODC may cache (and which are explicitly denied — Tier-0 accounts must be denied).
- Whether to pair it with the **forest-trust enrichment** for the MSP sim (gap-analysis note: adding a forest trust between customera/customerb.local covers the 70-742 Ch7 trust objectives) — decide if that rides here or stays in the MSP phase.

**Deliverables:** an ADR/design doc (RODC + site topology + PRP), the site-link/subnet design, and the acceptance tests (RODC holds no writable copy; denied accounts don't cache; replication is inbound-only).

---

## Tier C — finalize the skip/defer (record decisions so they don't get re-suggested)

The pass should **record these as decisions** (one small ADR — e.g. "Tier-C exam topics: skipped/deferred with rationale" — is enough), so a future session doesn't re-propose them:

| Topic (exam) | Decision | Rationale |
|---|---|---|
| **70-741 Ch9 datacenter networking** — NIC Teaming/SET, VMQ, RSS, SR-IOV, SMB Direct/Multichannel, DCB | **Skip** | Hyper-V-host + RDMA-NIC features; can't be exercised on an R410 running Proxmox. Networking learning is served by the CCNP track. |
| **Microsoft SDN** — Network Controller, HNV, SLB, gateways, distributed firewall, **NSGs** | **Skip** | Hyper-V/Azure-Stack-oriented; the real lesson (per-flow east-west segmentation) is **already built** via MKT01 + the allowed-flows matrix — an NSG rule *is* one of the named allows. |
| **AD RMS** (70-742 Ch9) — information rights management | **Defer / low** | Genuinely sunsetting; Azure Information Protection / Purview is the modern path. Conceptually interesting, heavy, dated. |

**Note:** AZ-802 (not AZ-800/801) is the current cert target and it **does** test Hyper-V — so the home-PC Hyper-V VMs (AD FS lab, RODC, test clients) double as AZ-802 practice. That's the intended way the Hyper-V objectives get covered, rather than the Ch9 datacenter-fabric features above.

## What this pass should output (checklist)
- [ ] AD FS + WAP — ADR + build-guide outline + DMZ flow + open decisions closed.
- [ ] RODC + second site — ADR/design + site/PRP design + open decisions closed.
- [ ] Tier-C — one ADR recording skip/defer with rationale (+ the AZ-802/Hyper-V note).
- [ ] Roadmap + `Master-Implementation-Checklist` (Phase 11 / advanced) + `ADR-Index` updated.
- [ ] `SESSION-HANDOFF` bumped.

## Related
- `Atlas-Cert-Objective-Gap-Analysis.md` (the source) · `ADR-0036` (compute placement) · `ADR-0027` (AD CS) · `Atlas-Roadmap-Advanced-Scenarios.md` (MSP/Azure phases these interact with) · `Master-Implementation-Checklist.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Created — the planning brief for Tier B (AD FS+WAP; RODC+second site) and Tier C (finalize skip/defer). Captures scope, the Tier-A/AD-CS/gMSA dependency chain, compute placement (home-PC Hyper-V per `ADR-0036`), the open decisions each item needs, the Tier-C skip/defer rationale table (+ the AZ-802 Hyper-V note), and the deliverables the pass should output. |
