# CM-0003 — Disable SW01 Gi1/0/3 (Windows-Laptop, Unconnected)

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

| Item | Value |
|---|---|
| Status | Closed |
| Risk | Low — port is currently unconnected, no active traffic affected |
| Affected systems | SW01 |

## Purpose

Disable Gi1/0/3, resolving the VLAN 50-vs-10 conflict identified during live SW01 validation by removing the ambiguous assignment entirely rather than guessing which one was intended.

## Reason

See ADR-0002. Documentation said VLAN 50 (Client); live config showed VLAN 10 (Management) — a trust-zone discrepancy on a port with nothing actually connected to it. Decision: disable rather than pick one.

## Prerequisites

None. Port is confirmed not connected — no user or device impact.

## Backup

```text
show running-config interface Gi1/0/3
```

Save output before change.

## Implementation

```text
configure terminal
interface Gi1/0/3
shutdown
description Disabled - pending device assignment, see ADR-0002
exit
exit
write memory
```

## Validation

```text
show interfaces Gi1/0/3 status
show interfaces description
```

Confirm Gi1/0/3 shows `disabled` administrative state and the new description.

## Rollback

```text
configure terminal
interface Gi1/0/3
no shutdown
description Windows-Laptop
switchport access vlan 50
exit
exit
write memory
```

Note: rollback restores the port to its previously *documented* state (VLAN 50), not its previously *live* state (VLAN 10) — since VLAN 50 was the intended design per the Standards, not the unexplained live value.

## Documentation updates

- [x] SW01 Build Record (`023-SW01-Build-Record.md`) — Gi1/0/3 row updated to `Disabled`, Known Deviations entry resolved
- [x] Network Source of Truth (`006-Network-Source-of-Truth.md`) — Gi1/0/3 port table entry updated to `Disabled`, admin workstation port reference tightened to Gi1/0/2
- [ ] Revision History
- [ ] Confluence published and reviewed

## Closeout

- [x] Implemented
- [x] Validated
- [x] Documentation updated
- [x] Closed
