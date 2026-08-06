# ADR-0002 — SW01 Gi1/0/3 VLAN Assignment (Windows-Laptop)

| Item | Value |
|---|---|
| Status | Accepted |
| Governing Policy | POL-0008 |
| Scope | **Lab-01-Mikrotik-Core** |
| Date | 2026-07-12 |

## Context

The Network Source of Truth and the pre-this-session SW01 Build Record both document Gi1/0/3 ("Windows-Laptop") as VLAN 50 (Client). A full live validation pass of SW01 this session found Gi1/0/3 actually configured for VLAN 10 (Management) instead. This is not a naming drift like the SW01/MKT01 hostname renames handled elsewhere — moving a client machine onto the management VLAN is a trust-zone change, not a cosmetic one.

## Alternatives Considered

1. **Update documentation to match live reality (VLAN 10).** Treats the live config as correct and the old docs as stale. Risk: if the VLAN 10 assignment was itself an unintentional misconfiguration or a temporary troubleshooting leftover, this makes a real security gap permanent by documenting it as intended.
2. **Revert the live port to VLAN 50 to match documentation.** Treats the original design as correct. Risk: if there was a real reason for the move (e.g., the workstation needed management-plane access for some legitimate purpose) this reverts a deliberate change without understanding why it was made.
3. **Leave both live config and documentation flagged as unreconciled until the engineer confirms which is intended.** Chosen for now, since neither alternative should be picked without knowing the actual intent.

## Decision

**Disable Gi1/0/3.** Neither VLAN 50 (documented) nor VLAN 10 (live) gets chosen. The port is currently unconnected — no device is relying on either assignment right now — so committing to one without knowing why the other was ever configured would be a guess dressed up as a decision. Shutting the port down removes the live trust-zone ambiguity entirely without pretending to know something that isn't known.

## Rationale

Per the Charter's Rule 8 ("Verify; do not guess"), and reinforced by the earlier finding in this session: an untagged VLAN 10 assignment on a client port is a real security-relevant fact, not a cosmetic one, and shouldn't be resolved by picking whichever value is more convenient. Since nothing is actually plugged in, the safe default is "off" until a real device and a real intended VLAN are both known. This also matches the network's existing default posture — unused ports elsewhere in the design (Gi1/0/8-48) are already `Shutdown, BPDU Guard`, so disabling an unconnected port is the norm here, not an exception.

## Consequences

- SW01 Build Record and the Network Source of Truth both update Gi1/0/3 to `Disabled` rather than resolving the VLAN 50-vs-10 conflict — this closes the ambiguity without erasing the history of how it was found.
- If a real device needs this port in the future, its VLAN gets assigned deliberately at that time, as a fresh decision informed by what the device actually is — not inherited from either stale value.
- The live change itself is tracked in CM-0003, since disabling a port is a real change to production, not just a documentation update.

## Review Trigger

Revisit if a device is ever connected to Gi1/0/3 — at that point this ADR is superseded by whatever VLAN decision fits that device, not reopened as the same question.
