# CM-0001 — Correct SW01 Gi1/0/1 Port Description

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

| Item | Value |
|---|---|
| Status | Closed |
| Risk | Low |
| Affected systems | SW01 |

## Purpose

Gi1/0/1 (trunk to MKT01) currently carries the description "Raspberry-Pi", left over from before the Raspberry Pi was moved to its own port. It should read "Trunk-to-MKT01" to match its actual role.

## Reason

Stale port description found during full SW01 validation, 2026-07-11. Gi1/0/7 now correctly carries the Raspberry-Pi description after the Pi was cabled there this session; Gi1/0/1 was never corrected.

## Prerequisites

None. Cosmetic label change, no traffic impact.

## Backup

`show running-config interface Gi1/0/1` — save output before change.

## Implementation

```text
configure terminal
interface Gi1/0/1
description Trunk-to-MKT01
exit
exit
write memory
```

## Validation

`show interfaces description` — confirm Gi1/0/1 reads "Trunk-to-MKT01".

## Rollback

```text
configure terminal
interface Gi1/0/1
description Raspberry-Pi
exit
exit
write memory
```

## Documentation updates

- [x] Build Record (023-SW01-Build-Record.md) — confirmed live: Gi1/0/1 shows `Trunk-to-MKT01`
- [ ] Build Guide, if target procedure changed — not applicable, target design already specified this description
- [ ] Revision History
- [ ] Confluence published and reviewed

## Closeout

- [x] Implemented
- [x] Validated
- [x] Documentation updated
- [x] Closed
