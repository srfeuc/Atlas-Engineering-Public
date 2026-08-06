# ADR-0021 — Active Directory Becomes the Tiered Identity Backbone

| Item | Value |
|---|---|
| Status | **Proposed — 2026-07-16** (operator accepts by moving to `Accepted`) |
| Governing Policy | POL-0010 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-16 |
| Related | `ADR-0003` (AD CS vs Lab CA), `ADR-0004` (NPS vs FreeRADIUS), `ADR-0007` (`atlas.lab` domain suffix), `ADR-0020` (NTP time source — PDC emulator), `Atlas-Service-Architecture.md` Part 6, `Atlas-Next-Lab-Design-Brief.md` |
| Evidence Status | **`Verified`** for the current-state fact (a working AD exists, operator-confirmed); **`Target Design`** for the integrations (none built yet) |
| Supersedes | The *"`DC01-LAB` is a single-purpose throwaway, destroyed before Book 3"* stance in `Atlas-Service-Architecture.md` Part 6 |

> **This ADR exists because `Atlas-Service-Architecture.md` Part 6 was written assuming there was no Active Directory yet, so it scoped a domain controller to a throwaway RADIUS test to avoid scope creep. The operator now has a working AD and Windows Server experience. That changes the right answer — but only if the scope discipline Part 6 was protecting is preserved by design instead of by deferral.**

## Context

Identity is the one service everything else authenticates *to*: network-device admin (RADIUS), service logins (LDAP), name resolution (DNS), time (Kerberos requires it), certificates (PKI), and Windows configuration (GPO) all hang off it. `Atlas-Service-Architecture.md` Part 6 deferred it because standing up AD "to test RADIUS" is exactly how a homelab sprawls into an accidental, half-built Microsoft environment: one DC becomes DNS, then DHCP, then GPO, then a second DC, six months early.

**But the operator already has a working AD.** So the choice is no longer "defer AD to avoid sprawl" — it is "integrate the AD you have deliberately, or bolt identity on later as a migration." Retrofitting identity onto a running estate (re-pointing every device's auth, every service's login, the time hierarchy and the PKI) is strictly harder than building on it from the foundation.

## The design fact that decides this

**You cannot cleanly retrofit an identity provider.** Every downstream integration — RADIUS clients, LDAPS service binds, AD-integrated DNS, the Kerberos-enforced time hierarchy, AD CS — assumes the provider was there when the thing was built. Deferring AD means building all of that against *interim* identity (local users, FreeRADIUS, the OpenSSL CA) and then **migrating** it, which is the more expensive and more error-prone path. The only thing that makes "build it now" dangerous is **lack of scope** — and scope is a design decision you can write down.

## Decision

**Adopt the existing Active Directory as Atlas's identity backbone, from Phase 2 of the roadmap, under a mandatory tiered model.**

**In scope — AD provides:**

| Integration | Boundary |
|---|---|
| **NPS (RADIUS)** for SW01 / MKT01 / FGT01 admin auth | Domain-joinable identities via NPS; non-domain network devices keep FreeRADIUS — the coexistence `ADR-0004` already defines |
| **LDAPS** (never plain LDAP) for service auth — NetBox, Grafana, LibreNMS, Proxmox, Vaultwarden | Bind over TLS only; one identity across the service estate |
| **AD-integrated DNS**, coexisting with Pi-hole | Domain machines → AD DNS; non-domain → Pi-hole. The `ADR-0003`/`ADR-0007` domain-membership boundary |
| **PDC-emulator as the authoritative NTP source** | Exactly `ADR-0020`'s target — this is how the SW01 clock (`CM-0030`) gets a real internal authority |
| **GPO** for Windows CIS-benchmark hardening + WDS/PXE on VLAN 60 | Config-as-policy for the Windows estate only |
| **AD CS decision** | Resolve per `ADR-0003`: domain machines → AD CS, non-domain → the OpenSSL Lab CA |

**The mandatory guardrail — Microsoft's tiered admin model (this is what keeps it from sprawling and what makes it enterprise):**

- **Tier 0** = identity itself — Domain Controllers, AD CS, the tools that administer them. Highest trust. **DCs live in their own protected segment** (a dedicated identity VLAN, or a firewalled carve-out of VLAN 20), not the general server VLAN.
- **Tier 1** = servers/applications. **Tier 2** = user workstations.
- 🔴 **A credential from a higher tier never authenticates to a lower tier.** No Domain Admin logging into a workstation. This is the single most important operational discipline of the whole design.
- **Scope is fixed here, in writing:** AD serves the roles in the table above. Adding a role (a new forest, a trust, an Azure AD Connect, anything production-critical) is a **new Change Record or ADR**, not a drift.

## Alternatives Considered

**A — Keep AD scoped to a throwaway `DC01-LAB` (Part 6's stance).** Rejected. It made sense when no AD existed; it doesn't now. Deferring means building device auth, service auth, DNS, time and PKI against interim identity and then migrating — a bigger, riskier project than integrating deliberately. Retained only as the fallback if the operator wants a slower ramp.

**B — Promote AD as the backbone with no tiering.** Rejected. This is the sprawl Part 6 feared, plus the classic security failure (flat admin, Domain Admin everywhere). The tiered model is not optional overhead — it *is* the enterprise lesson and the thing that keeps scope bounded.

**C — Stay on FreeRADIUS + OpenSSL CA + local identity indefinitely.** Rejected as an end state (it caps the lab's growth and teaches the non-Microsoft path only), but it remains the correct *interim* for non-domain devices under `ADR-0004`/`ADR-0003` — this ADR is coexistence, not replacement.

## Consequences

- **Identity becomes Phase 2 of the roadmap** (`Atlas-Next-Lab-Design-Brief.md` §7), right after the source-of-truth foundation.
- **`ADR-0004`'s NPS/FreeRADIUS split becomes a real coexistence**, not a hypothetical bake-off — domain devices to NPS, non-domain to FreeRADIUS, on the same switch ports.
- **`ADR-0020` lands its target early** — the PDC emulator becomes the internal NTP authority, resolving `CM-0030` for SW01 with the AD you already have.
- **The service estate gains single sign-on** via LDAPS; `044`'s Vaultwarden convention narrows to break-glass/local accounts.
- **The "Microsoft lab" is no longer a separate deferred book** — it is the foundation, built tiered and correct, rather than bolted on later. Part 6's teardown-and-rebuild framing is retired.
- **New obligation:** AD is now production-critical, so it needs a **tested recovery path and backup** (DC restore is its own Game Day) before anything depends on it — the same "prove the recovery" bar as every other control.

## Review Trigger

- **Before a second DC is added** — redundancy is good, but it's the first step of sprawl; re-affirm scope.
- **When AD CS is stood up** — resolve `ADR-0003` at that point (AD CS for domain, Lab CA for non-domain).
- **If any non-test production system is joined** — confirm it's inside the tiered model, in a protected segment, with a recovery path.
- **Resolve alongside `ADR-0004`** — same domain-membership boundary; don't let them drift.

## Note

**The instinct Part 6 correctly feared was "one DC to test RADIUS" quietly becoming an unplanned Microsoft environment.** The fix is not to avoid AD — you have one — it is to **name its scope and its tiers on the record.** An identity backbone with written scope is architecture. An identity backbone that grew a role at a time is the sprawl. This ADR is the former; without it, you get the latter.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-16. Adopts the existing AD as the tiered identity backbone (NPS, LDAPS, AD DNS coexist, PDC-emulator NTP per `ADR-0020`, GPO, AD CS per `ADR-0003`), under Microsoft's Tier 0/1/2 model with DCs in a protected segment and a fixed written scope. Supersedes `Atlas-Service-Architecture.md` Part 6's throwaway-DC stance; extends `ADR-0004`'s coexistence. |
