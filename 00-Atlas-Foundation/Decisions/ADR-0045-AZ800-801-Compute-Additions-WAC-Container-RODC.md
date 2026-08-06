# ADR-0045 — AZ-800/801-Driven Compute Additions: WAC01 (Windows Admin Center), a Container Host, and the RODC

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29) — scoped additions; execution **staged** (placement build-gated on PVE02 where noted). |
| Governing Policy | POL-0008 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-29 |
| Supersedes | — **Extends `ADR-0036`** (compute topology / placement) with three cert-driven hosts. **Confirms** the RODC already committed in `Pre-Build-Decisions` **C5** / `ADR-0039` (Tier-B). |
| Related | `ADR-0036` (host placement / blast-radius), `ADR-0039` (full-hybrid scope — RODC + 2nd site), `ADR-0044` (enterprise model; certs anchor the skills), `ADR-0021` (tiered identity — why an RODC is branch-appropriate), `Atlas-Academy/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md` (the sweep this closes), `ADR-0046` (the failover cluster — split out). |
| Evidence Status | **Decision / plan.** None built. PVE02 not yet acquired (`ADR-0036` build gate for placement). |

## Context

The **AZ-800/801 sweep** (`Atlas-Academy/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md`) mapped both exams onto the estate and found that **most of the on-prem core is already in scope** — but it surfaced a handful of genuine gaps that are also *real enterprise infrastructure* (per `ADR-0044`: enterprise-first, certifications anchor the skills). Three of them are discrete compute additions small enough to decide together; the larger gap — Failover Clustering / Storage Spaces Direct — is a bigger commitment and gets its own **`ADR-0046`**.

## Decision

Add three items to the estate definition:

### 1. WAC01 — Windows Admin Center gateway
A **dedicated management host** (Windows Server, **gateway-mode** WAC — not a desktop install) that centralizes hybrid administration of the Windows estate (DCs, member servers, the cluster, Hyper-V) and is the on-ramp to **Azure Arc / hybrid management**. Central to **AZ-800** (hybrid management) and **AZ-801** (monitoring).
- **Placement:** PVE01 core-services tier, **VLAN 20** (Tier-0-adjacent management); revisit VLAN 10 (mgmt) if its Roadmap shows it must reach clients/DMZ.
- **Tier note:** WAC manages **Tier-0** (the DCs), so it is itself a **Tier-0 management surface** — administered **only from PAW01**, hardened, HTTPS with a cert from **ICA01**, never broadly exposed.

### 2. A container host — Windows containers / Docker
Rather than a new box by default, **ride SRV01** (already Ubuntu/Docker-capable) for **Linux/Docker** now, and add a **Windows-container** capability on a Windows member server (or a small **`CNT01`**) *on demand* when the AZ-800 "Windows containers" objective is worked. Keeps the estate lean (`ADR-0044` — enterprise-justified first); `CNT01` only earns a standing host if a persistent Windows-container workload appears.

### 3. RODC (+ 2nd AD site / subnet)
A **read-only DC in its own AD site** — the branch-office pattern. **Already committed** (`Pre-Build-Decisions` C5; `ADR-0039` Tier-B); this ADR **confirms it as a concrete VM + site/subnet** and ties it to **AZ-800** (AD DS sites/replication) + the branch objectives.
- **Placement:** a "branch" host — **home-PC Hyper-V or PVE02** — to make the site boundary real (not co-located with the writable DCs).
- **Security:** scoped **Password Replication Policy** (only branch users' secrets cached), **filtered attribute set**. An RODC is deliberately **lower-trust** — it belongs at the branch.

## Alternatives Considered
- **Fold WAC onto an existing server** (install on SRV01/MON01). Rejected — WAC-gateway is its own management plane touching Tier-0; co-locating muddies the tier boundary and blast radius. A small dedicated host is the enterprise norm.
- **A dedicated container host from day one.** Deferred — SRV01 already does Docker; a separate `CNT01` only earns its place with a standing Windows-container workload.
- **Skip the RODC** (writable DC everywhere). Rejected — the RODC + 2nd site is the exact AD DS sites/replication + branch-security skill AZ-800 (and 70-742) grade, and it is already committed scope.

## Consequences
- **`Pre-Build-Decisions` machines-in-scope** gains **WAC01** + the container-host note; the **RODC** row is confirmed (was C5). Each new host gets a `Devices/` folder + `Roadmap` in the definition pass (DC template).
- **`IP-Addressing-Plan-VLSM`** owes addresses: **WAC01** (VLAN 20/mgmt), `CNT01` if built, and the **RODC** an address in its **2nd-site subnet** (a new subnet the plan must allocate).
- **Placement rides `ADR-0036`:** WAC01 on PVE01; RODC targeted at a branch host (home-PC Hyper-V or PVE02) to make the site real; container capability on SRV01.
- **Build-order** (`Operations/Build-Order-and-Dependencies`): WAC01 **after** the first member servers exist (something to manage); RODC **after** DC01/DC02 + AD CS (needs a writable DC + certs); container host whenever SRV01 is up.
- **Cert linkage** recorded in the AZ-800/801 lab-map (WAC / containers / RODC rows move toward planned).

## Review Trigger
- If WAC's Roadmap shows it must manage clients/DMZ too → revisit its VLAN (10 vs 20).
- If a standing Windows-container workload appears → promote `CNT01` from on-demand to a committed host.
- If PVE02 / home-PC Hyper-V never lands → the RODC's "2nd site" is **logical-only** (same host, different AD site) — acceptable for the objective, but note it is **not** true physical branch redundancy.

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-29 | Created from the AZ-800/801 sweep. Adds **WAC01** (Windows Admin Center gateway; PVE01/VLAN 20; Tier-0 management surface, PAW-only, ICA01 cert), a **container capability** (SRV01 for Linux/Docker now; `CNT01` only on demand for Windows containers), and **confirms the RODC + 2nd site** (C5 / `ADR-0039`) as a concrete VM. Extends `ADR-0036` placement; failover clustering split to `ADR-0046`. |
