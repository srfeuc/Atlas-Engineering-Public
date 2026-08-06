# ADR-0001 — PVE01 Work Proceeded in Parallel with Network, Before Freeze

| Item | Value |
|---|---|
| Status | Accepted (retroactive) |
| Governing Policy | POL-0003 |
| Scope | **Lab-01-Mikrotik-Core** |
| Date | 2026-07-11 |

## Context

The Atlas Charter's Rule 1 states: "One pack at a time. Finish, publish, review, reconcile, and freeze the active pack before beginning another." Book 2 (Enterprise Virtualization) is explicitly marked "Deferred. Do not begin until the preceding active pack is frozen" in the root README.

During the same working session, significant Book 2 work happened anyway: PVE01 hardware validation (RAM upgrade, CMOS battery diagnosis, VT-x recovery, DIMM fault), a full golden-image lineage investigation, and fourteen Build Guides — while Network (Book 1) remained open, with real unresolved items (the Gi1/0/3 VLAN question, two open Change Management records, FGT01 never validated).

## Alternatives Considered

1. **Stop all Book 2 work and finish Network first**, strictly per the Charter. Rejected in the moment because PVE01's hardware incidents (dead CMOS battery, faulty DIMM) were physically happening in real time during a live troubleshooting session — deferring documentation of a live incident wasn't practical.
2. **Silently continue and not acknowledge the rule was broken.** Rejected — this ADR exists specifically to avoid that.
3. **Retroactively document the exception and its scope**, then return to strict sequencing. Chosen.

## Decision

Accept that PVE01-specific hardware/OS work (Build Guides 001-014, the hardware incident history) proceeded in parallel with open Network work, on the grounds that PVE01 is a genuine boundary device — simultaneously Network's endpoint and Virtualization's foundation — and that live hardware incidents don't wait for a documentation freeze schedule.

This does not extend to non-PVE01 Book 2 work (e.g., Windows Server role deployment, AD DS promotion). That work should not begin until Network is actually frozen.

## Rationale

A rule that can never bend for a genuine physical-world event (hardware failing in real time) isn't a good rule to follow blindly. But an unbounded exception isn't a rule at all. Scoping the exception specifically to PVE01 hardware/OS content — and writing it down — preserves the intent of "don't diffuse effort across too many open fronts" while being honest about what actually happened.

## Consequences

- Network (Book 1) must be prioritized to actual freeze before further Book 2 content beyond what's already written.
- Future sessions should check this ADR before assuming parallel-book work is generally acceptable — it isn't; this was a scoped, justified exception, not a precedent for ignoring Rule 1 broadly.

## Review Trigger

Revisit if Network freeze is delayed materially (e.g., more than one additional working session) by continued Book 2 work.
