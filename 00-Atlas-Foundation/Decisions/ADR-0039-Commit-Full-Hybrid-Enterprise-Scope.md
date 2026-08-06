# ADR-0039 — Commit the Estate to a Full Hybrid Enterprise (scope)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29). Scope commitment; phased build. |
| Governing Policy | POL-0016 |
| Scope | **Lab-02** (Cisco-Core) — estate scope / roadmap. |
| Date | 2026-07-29 |
| Supersedes | — (extends the phase plan) |
| Related | `ADR-0021` (tiered identity) · `ADR-0025` (Lab-02 holds both tracks) · `ADR-0036` (compute topology) · `Pre-Build-Decisions.md` F/C-series · `Atlas-Academy/Atlas-Certification-Lab-Map.md` · `00-Atlas-Foundation/Roadmap/Atlas-Cert-Objective-Gap-Analysis.md` + `Atlas-Roadmap-Advanced-Scenarios.md`. |
| Governing docs | `Service-Server-Build-Plan.md` (estate) · the per-device Roadmaps (future-phase sections). |
| Evidence Status | **Decision** (operator, 2026-07-29). Defines scope; builds are phased and future. |

## Context

The on-prem core (AD DS, two-tier PKI, NPS, east-west segmentation, the service estate) is being built. The operator's stated goal is a **realistic enterprise that also ticks certification objectives — learning is paramount.** The open question: how far does the estate go — on-prem only, or a full **hybrid/cloud + advanced on-prem** enterprise?

Resolved in the `Pre-Build-Decisions` batch-1 (2026-07-29): **all future areas are in-scope.** This ADR records that commitment so the reasoning and the resulting machine list live in the repo, and so the dependency map / build order can sequence them.

## Decision

**Commit the estate to a full hybrid enterprise, built in phases *after* the on-prem core is solid.** In scope:

- **Hybrid identity** — **Entra Connect** (sync `atlas.lab` → an Entra ID tenant; H1) then **Intune** (cloud endpoint management; H2). *(Sync method decided separately — `ADR-0040`: PHS.)*
- **Messaging** — **Exchange** on-prem first (learning) → **Exchange Online hybrid** (H3); host **EXCH01**.
- **Cloud infra** — **Azure IaaS** + a **site-to-site VPN** from FGT01 (H4).
- **Advanced on-prem identity** — **AD FS + WAP** (federation/SSO), an **RODC** in a second AD site, and the **MSP multi-domain sim** (`customera.local`/`customerb.local`) with a **forest trust** (Tier-B).

Each capability becomes **its own device folder + Roadmap** (per the Documentation Standard) and is **phased after the core** — the dependency map sequences them last. Cert alignment: AZ-802, AZ-104, MS-102, MD-102, SC-300, 70-742 depth, CCNP.

## Alternatives Considered

- **On-prem only.** Rejected — omits the entire hybrid/cloud skill set that modern enterprises *and* the target certs (AZ-802 hybrid, AZ-104, M365) require. The whole point is a realistic enterprise.
- **Cloud-first / cloud-only.** Rejected — the on-prem AD/PKI/network core is the anchor and the CCNA/AZ-802/70-742 learning base; hybrid *extends* it, it doesn't replace it.
- **Defer the decision.** Rejected — "define the whole lab before building" needs the ceiling set now so the dependency map and machine list are complete.

## Consequences

- **New machines/services enter the estate:** an **Entra ID tenant** + Entra Connect sync host, **Intune** (cloud service), **EXCH01**, **ADFS01 + WAP01** (DMZ, VLAN 80), an **RODC** (2nd site), the **MSP sim domains**, and **Azure** resources. Each gets its own folder + Roadmap in the definition pass.
- **External dependencies (cost/accounts):** an **Entra/M365 tenant** and an **Azure subscription** — use dev/test/trial tiers where possible; a phase blocked on cost is *deferred*, not dropped (review trigger).
- **Compute:** leans on **PVE02** (planned, not yet acquired — build gate, `ADR-0036`) + home-PC Hyper-V for AZ-802/AD FS labs.
- **Scope is deliberately large** — managed by **phasing** (on-prem core first, hybrid last) and the define-before-build discipline; the estate dependency map must place these at the end of the build order.

## Review Trigger

- If a tenant/subscription **cost** or hardware **capacity** blocks a phase, **defer that phase** (record the deferral) — the commitment stands.
- If the on-prem core slips, hybrid phases wait; they are explicitly downstream of a healthy DC/PKI/network core.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Accepted. Commits the estate to a full hybrid enterprise (Entra Connect + Intune · Exchange on-prem→EXO hybrid · Azure IaaS+S2S · AD FS/WAP + RODC/2nd-site + MSP forest-trust), phased after the on-prem core, each its own device folder + Roadmap. Records the new machines, the tenant/subscription dependencies, and the phasing discipline. Sync method split to `ADR-0040`. |
