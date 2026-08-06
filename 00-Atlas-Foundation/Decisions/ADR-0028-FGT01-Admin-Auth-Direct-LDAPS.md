---
Title: ADR-0028 — FGT01 Admin Auth via Direct LDAPS (deviation from the ADR-0004 RADIUS boundary)
Path: Atlas Foundation/Decisions
---

# ADR-0028 — FGT01 Admin Auth via Direct LDAPS

| Item | Value |
|---|---|
| Status | **Proposed — 2026-07-22** (operator accepts by moving to `Accepted`) |
| Governing Policy | POL-0010 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-22 |
| Related | `ADR-0004` (NPS vs FreeRADIUS — network-device auth = RADIUS), `ADR-0021` (LDAPS = the service estate), `ADR-0027` (AD CS — provides the DC LDAPS cert), `ADR-0003` (two-CA coexist) |
| Evidence Status | **`Target Design`** — nothing built; **gated on the DC LDAPS cert** (AD CS, `ADR-0027`). The AD-side prereqs can be built now. |

> **This ADR exists because the operator chose LDAPS for the FortiGate's AD-backed admin auth — "I've already done RADIUS before, let's do LDAPS." That is a deliberate deviation from `ADR-0004`, which routes network-device admin auth through RADIUS. Per Atlas discipline (decisions are ADRs, not silent changes), the deviation is recorded here.**

## Context

`ADR-0004` set one boundary — domain membership — and put **network-device admin auth on RADIUS** (non-domain devices → FreeRADIUS/Pi01; domain-joined → NPS), while `ADR-0021` reserved **LDAPS for the service estate** (NetBox, Grafana, Proxmox, Vaultwarden). The FGT01 Pass-2 goal ("the FortiGate needs an AD account to secure it") is to back FortiGate **admin login** with AD identities instead of a local-only account.

Two ways to do that: **(A)** RADIUS-backed (point FreeRADIUS at AD), which is `ADR-0004`-consistent, or **(B)** **direct FGT→LDAPS to the DC.** The operator picked **B**, for two reasons: (1) a **learning goal** — RADIUS/FreeRADIUS admin auth is already done (`033`), LDAPS is the skill to practice; and (2) FortiOS does **LDAPS admin auth natively and cleanly** per-device, with no FreeRADIUS reconfiguration.

## Decision

**FGT01 authenticates administrators via direct LDAPS (TCP 636) to the Domain Controllers**, with admin-profile assignment driven by membership of an AD group. Specifically:

- **LDAPS only — never plain LDAP/389.** The FGT binds over TLS to `dc01.atlas.lab` (+ DC02 as secondary), validating the DC's server cert against the **AD CS root** (`ADR-0027`) imported into the FGT's CA store.
- A least-privilege, read-only **LDAP bind/service account** (`svc-fgt-ldap`, in the Service Accounts OU, deny interactive logon) lets the FGT query the directory.
- An AD **network-admin group** (`G-Network-Admins`, global) is matched to a FortiGate admin profile (`super_admin`, or a scoped profile).
- 🔴 **`fortigateadmin` stays as the local break-glass admin — never removed, never PKI-ified** (`ADR-0004`/`ADR-0021` break-glass rule).

### Scope — this is FGT-specific, NOT a reversal of `ADR-0004`

- **Only FGT01** moves to direct LDAPS here. `ADR-0004`'s RADIUS boundary **still stands for the rest**: MKT01/SW01/1941 admin auth remains RADIUS-oriented (RouterOS and IOS do RADIUS/TACACS+ far more natively than LDAP), and the **FreeRADIUS-vs-NPS coexistence is untouched.**
- So the estate ends with a deliberate mix: **FGT01 → LDAPS**, **other network gear → RADIUS**, **service estate → LDAPS** (`ADR-0021`). That's acceptable — the point of `ADR-0004` was "one boundary, applied consistently"; this is a single, documented, per-platform exception, not drift back to ad-hoc.

## Consequences

- **Gated on AD CS (`ADR-0027`).** LDAPS needs the DC to present a server-auth cert; that cert comes from AD CS. So the FGT LDAPS config waits on the DC cert (AD CS guide Part 3.4). **The AD-side prereqs (`G-Network-Admins` + `svc-fgt-ldap`) can be built now.**
- **The bind account's credentials live on the FGT.** Keep it read-only and least-privilege — if the FGT is compromised, only a read-only directory bind leaks (it can enumerate group membership, which authenticated users can already do). Password in Vaultwarden (`POL-0002`).
- **Admin availability depends on the DC being reachable** (same tradeoff any AD-backed auth carries) — the local `fortigateadmin` break-glass is exactly why it's kept.
- **Tier placement (`ADR-0021`):** network-device admin ≈ **Tier 1**; map a Tier-1-class identity (e.g. `t1-seth`, or a dedicated net-admin account) into `G-Network-Admins`. Elevating perimeter firewalls to Tier 0 remains an optional, separate decision.
- **Drives** a new `Devices/FGT01-Perimeter-Firewall/Build-Guide-2b-AD-LDAPS-Admin.md` (the Pass-2 companion to Guide 2).

## Alternatives Considered

- **A — RADIUS-backed (FreeRADIUS→AD LDAP bind).** `ADR-0004`-consistent, scales to all network gear identically. **Not chosen** — the operator has already built RADIUS admin auth and wants the LDAPS skill; and for a single perimeter firewall, direct LDAPS is simpler than reworking FreeRADIUS's authorize path to return the Fortinet VSA.
- **C — Stay local-only (`fortigateadmin`).** Rejected as the end state — the Pass-2 goal is AD-backed named-admin auth; local stays only as break-glass.

## Review Trigger

- **If this pattern is extended to many devices**, reconsider centralizing on RADIUS/NPS (per-device LDAPS config doesn't centralize policy the way a RADIUS server does).
- **If FGT01 is ever exposed to an untrusted network**, re-evaluate the on-box bind-account exposure.
- **Resolve alongside `ADR-0004`** — if the RADIUS/NPS coexistence is ever revisited, fold this exception back in explicitly.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-22. FGT01 admin auth = **direct LDAPS (636)** to the DCs, group-mapped via `G-Network-Admins`, bound by a least-priv `svc-fgt-ldap`, validating the DC cert against the AD CS root (`ADR-0027`); `fortigateadmin` kept as local break-glass. A deliberate, **FGT-specific** deviation from `ADR-0004`'s RADIUS boundary (learning goal + FortiOS-native LDAPS) — does **not** reverse RADIUS for MKT01/SW01/1941 or the FreeRADIUS/NPS coexistence. Gated on the DC LDAPS cert; AD-side prereqs buildable now. |
