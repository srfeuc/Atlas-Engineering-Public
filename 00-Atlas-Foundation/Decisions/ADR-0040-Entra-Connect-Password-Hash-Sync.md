# ADR-0040 — Entra Connect Uses Password Hash Sync (PHS) as the Primary Hybrid Auth

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29). Not built (Phase H1). |
| Governing Policy | POL-0010 |
| Scope | **Lab-02** (Cisco-Core) — hybrid identity. |
| Date | 2026-07-29 |
| Supersedes | — |
| Related | `ADR-0039` (hybrid-enterprise scope) · `ADR-0021` (tiered identity) · the DC Roadmap **Phase H1** · `Pre-Build-Decisions.md` F2 · the **AD FS** Tier-B item (federation — a *separate* exercise). |
| Governing docs | future `Devices/ENTRACONNECT01/` + the DC Roadmap H1. |
| Evidence Status | **Decision** (operator, 2026-07-29). |

## Context

Hybrid identity (Phase H1, `ADR-0039`) syncs `atlas.lab` → Entra ID via **Entra Connect**. Entra Connect offers three sign-in methods, and the choice shapes resilience, infrastructure, and the on-prem dependency:

- **Password Hash Sync (PHS)** — a hash of the password hash is synced to Entra; **authentication happens in the cloud**.
- **Pass-Through Authentication (PTA)** — auth is validated on-prem by lightweight agents at sign-in time.
- **Federation (AD FS)** — Entra redirects auth to an on-prem AD FS farm.

The gap-analysis explicitly warns that **directory sync ≠ federation** — they are different capabilities, and AD FS is already in-scope as its *own* learning target. This ADR picks the **primary** hybrid auth method.

## Decision

**Use Password Hash Sync (PHS) as the primary hybrid authentication method.** Rationale:

1. **Most resilient** — because authentication happens in Entra, cloud sign-in **survives an on-prem / DC / WAN outage**; PTA and federation both make every cloud login depend on on-prem being reachable.
2. **Simplest infrastructure** — no PTA agents to deploy/HA, no AD FS + WAP farm to stand up and keep highly available *just to log in*.
3. **Security features** — PHS enables Entra **leaked-credential detection** / Identity Protection, and supports **Seamless SSO** and Conditional Access.

**Deliberate nuance:** **AD FS + WAP stays in-scope** (`ADR-0039`, Tier-B) — but as a **separate federation learning exercise** (claims, SAML/OIDC, a relying-party app), **not** the primary hybrid sign-in path. The estate runs **PHS for production hybrid auth** and **builds AD FS in parallel to learn federation** — which also cleanly demonstrates *sync vs federation* side by side.

## Alternatives Considered

- **PTA as primary.** Rejected — agent infrastructure + an on-prem dependency for *every* cloud authentication; keep it as a possible later comparison lab.
- **Federation (AD FS) as primary.** Rejected as the auth path — most complex, needs an HA AD FS+WAP farm, and makes cloud login depend on on-prem uptime. Built **separately** for learning (Tier-B), not as the sign-in method.
- **Cloud-only accounts (no sync).** Rejected — defeats the hybrid-identity objective.

## Consequences

- A sync host — **Entra Connect** on a member server (or dedicated **ENTRACONNECT01**) — enters scope; own folder + Roadmap.
- **Password writeback** (for self-service password reset from cloud → on-prem) is an **optional follow-on decision** — flag when SSPR is built (needs Entra ID P1).
- **Seamless SSO + Conditional Access** build on PHS.
- The **AD FS lab** is explicitly a *federation learning artifact*, decoupled from the auth path — no HA burden on the sign-in critical path.

## Review Trigger

- If a scenario needs **real-time on-prem enforcement** at sign-in (e.g., immediate account-disable honored instantly), evaluate PTA.
- If a specific app requires **SAML/WS-Fed federation**, route it through the AD FS lab — not by changing the primary method.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Accepted. PHS chosen as the primary hybrid auth (resilience: cloud auth survives on-prem outage; no agent/AD FS HA burden; enables leaked-credential detection + Seamless SSO). AD FS + WAP stays in-scope as a *separate* federation learning exercise, not the sign-in path. Closes `Pre-Build-Decisions` F2. |
