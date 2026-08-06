# ADR-0025 — Lab-02 Holds the Network and Identity Tracks in Tandem (Reversing the Throwaway-DC Stance)

| Item | Value |
|---|---|
| Status | **Proposed** |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-17 |
| Related | `Atlas-Service-Architecture.md` Part 6 (the stance this reverses), `Atlas-Next-Lab-Design-Brief.md` §2 (Path A), `301`/`305` (the bound scenario), `ADR-0004` (NPS/FreeRADIUS coexistence), `ADR-0021` (tiered identity), `ADR-0023` (the topology this shares a lab with) |
| Governing Policy | *(none yet — candidate once the Governance Framework is adopted)* |
| Evidence Status | **`Target Design`** |

> **Reverses an argued position, so it gets its own ADR rather than a silent edit.** `Atlas-Service-Architecture.md` Part 6 argued — well — that the Microsoft environment is a *separate, later* lab and that `DC01-LAB` is a throwaway to be destroyed before it. That argument was correct *when there was no real AD.* There is one now.

## Context

`Atlas-Service-Architecture.md` Part 6 ("The Domain Controller trap") built a deliberate firewall against scope creep: `DC01-LAB` may run AD DS **only** as an NPS prerequisite, may **not** become the lab's DNS/DHCP or hold GPOs, and **is destroyed when the Microsoft environment is built later, from Microsoft's reference architecture.** The reasoning was sound for its assumption: *you have no real AD yet.*

That assumption is now stale. `Atlas-Next-Lab-Design-Brief.md` §2 says so plainly: *"You have a working AD, so that framing is out of date — and that's good news,"* and offers **Path A — AD is the lab's identity provider, from now, deliberate and tiered.** The operator has chosen a single **Lab-02 holding both tracks — the Cisco-core/segmentation network re-architecture and the Windows/identity environment — built in tandem**, bound by the `301`/`305` scenario.

## Alternatives Considered

1. **Keep Part 6 as written** — Windows env is a separate, later lab; `DC01-LAB` a throwaway. Rejected: it defers the identity track that `305` needs to make segmentation meaningful, and it destroys a working AD only to rebuild it.
2. **Two separate labs built concurrently.** Rejected (considered and set aside by the operator): the tracks are two halves of one bound scenario, and splitting them into separate labs fights the `301`↔`305` binding rather than using it.
3. **One Lab-02 holding both tracks, in tandem — Path A.** Chosen.

## Decision

**Lab-02-Cisco-Core holds both tracks and they are built in tandem:**

- The **network/segmentation track** (`ADR-0023`: 1941 core, MKT01 east-west firewall, the OT boundary) and the **Windows/identity track** (AD DS, tiered per `ADR-0021`, OU/AGDLP/GPO, the SQL→AD pipeline) are **one lab**, developed concurrently.
- **`DC01`/`DC02` are real, permanent domain controllers** — not a throwaway. AD is the lab's identity provider from now (Design Brief Path A): NPS for device-admin AAA (`ADR-0004`), LDAPS for service auth, AD-integrated DNS (Pi-hole coexists as the filtering forwarder), the PDC-emulator as NTP authority (`ADR-0020`).
- **`Atlas-Service-Architecture.md` Part 6's "separate, later lab" and "destroy `DC01-LAB`" stance is reversed** and superseded by this ADR. The Service-Arch doc already carries a forward-reference note to that effect (added when it was seated into Lab-02).

## Rationale

**`305` is the hinge that makes tandem the correct structure, not a convenience.** The scenario binds identity to segmentation reciprocally: a department in `301` needs a zone in `305`; a zone needs a data owner and an OU. The flagship exercise both documents name — *prove a Helpdesk Tier-2 account cannot touch a Tier-0 object, with the AD failure message AND the firewall denial as paired evidence* — **cannot be built from either track alone.** Defence-in-depth is those two proofs stacked, and they live in different tracks. Deferring one track guts the other.

**The scope-creep risk Part 6 named is real and is not dismissed — it is managed differently.** Instead of deferral, it is held by building tiered from day one (`ADR-0021`), by keeping the identity estate sized to the `301` scenario (not sprawling), and by the allowed-flows matrix that forces every cross-track flow to be explicit. Eyes open, not deferred.

## Consequences

- **`Atlas-Service-Architecture.md` Part 6 is superseded** by this ADR (its seat-note already points here). The `DC01-LAB`-throwaway language is historical context, not current scope.
- **`ADR-0004` is extended, not contradicted:** NPS (domain) and FreeRADIUS (non-domain) coexist as designed — the difference is that the domain side is now permanent, not a test appliance.
- **The Windows/identity build (302/303/304) is in-scope for Lab-02 now**, in tandem with the network re-role — consistent with the Lab-02 README's "two things at once, by design."
- **The tiered design (`ADR-0021`) becomes a build-time requirement, not a later refinement** — Tier-0 DCs in their own protected segment from the start (the matrix's Identity zone / `ADR-0023`'s Tier-0 carve-out).
- **Sequencing still applies:** per the Design Brief phase plan, source-of-truth and visibility (NetBox, monitoring) precede the segmentation cutover; the identity track builds alongside, not ahead of, the foundation.

## Review Trigger

- If the identity estate begins to sprawl beyond the `301` scenario (extra domains, unplanned trusts), revisit — that is the Part 6 risk materialising, and the response is to re-scope, not to re-defer.
- If the two tracks prove genuinely un-buildable in tandem by one operator, revisit the concurrency (not the single-lab decision).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-17. Records the "one Lab-02, both tracks in tandem" decision (Design Brief Path A). Reverses `Atlas-Service-Architecture.md` Part 6's separate-later-lab / throwaway-`DC01-LAB` stance; makes `DC01`/`DC02` permanent and AD the lab's identity provider; keeps the scope-creep risk managed by tiering + scenario-sizing + the allowed-flows matrix rather than by deferral. |
