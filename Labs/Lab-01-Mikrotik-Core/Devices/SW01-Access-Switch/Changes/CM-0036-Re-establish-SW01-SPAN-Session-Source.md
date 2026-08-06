# CM-0036 — Re-establish SW01 SPAN Session 1 Source (or Accept It Idle)

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

| Item | Value |
|---|---|
| Status | **Open — raised 2026-07-16** |
| Risk | Low — SPAN is passive; a source only mirrors traffic to `Gi1/0/5`, no forwarding impact |
| Affected systems | SW01 |
| Date raised | 2026-07-16 |
| Evidence Status | **`Verified`** — live `show run`, SW01, 2026-07-16 |
| Related | `023`, `027` §14, `057` row 3, `056` |
| Found by | The SW01 reconcile-to-live pass (`056`) |

## Purpose

SW01's SPAN session has a **destination but no source**, so the monitor port mirrors nothing. Restore the intended source (`Gi1/0/1` both directions) — or, if no capture host is attached yet, formally accept the session as idle and stop the docs claiming a source exists.

## Reason

The reconcile pass found the live running config contains **only**:

```
monitor session 1 destination interface Gi1/0/5
```

`023` (SPAN table) and `027` §14 both record **source `Gi1/0/1` both**. Rule 13 — the device wins, and the source line is genuinely absent (either never applied or later removed). `Gi1/0/5` is described `SPAN-Monitor-Port` and is cabled for a monitoring tool, so an idle session is most likely unintended.

## Decision needed (operator — Rule 16)

- **A — Re-add the source** (`Gi1/0/1` both). Restores the intended visibility of the MKT01 uplink to whatever is on `Gi1/0/5`. Choose this if a capture host / IDS is (or will be) attached.
- **B — Accept idle.** If nothing is attached to `Gi1/0/5` yet, record the session as deliberately idle and change `023`/`027` to say the source is intentionally absent — don't leave them asserting a source that isn't there.

## Prerequisites

Confirm whether a capture host / IDS is connected to `Gi1/0/5`.

## Backup

```text
show monitor session 1
show run | include monitor
```

Save output before the change.

## Implementation (Option A — per `027` §14)

```text
configure terminal
monitor session 1 source interface GigabitEthernet1/0/1 both
end
write memory
```

## Validation

```text
show monitor session 1
```

Expect: **Source Ports — Both: `Gi1/0/1`**; **Destination Ports: `Gi1/0/5`**. **Read the state back** — a command that returned no error is not a confirmed change.

## Rollback

```text
configure terminal
no monitor session 1 source interface GigabitEthernet1/0/1 both
end
write memory
```

## Documentation updates

- [ ] `023-SW01-Build-Record.md` — SPAN source row flips from "not configured" to confirmed present (or "accepted idle")
- [ ] `027-SW01-Build-Guide.md` §14 — live-state note flips to "source present, device-verified" (or records the idle decision)
- [ ] `057-SW01-Considerations-and-Risks.md` row 3 — closed
- [ ] Revision History

## Guide Reconciliation — required, not conditional

| Guide | Outcome | Detail |
|---|---|---|
| `027-SW01-Build-Guide.md` | To update on close | §14 already builds the source; add the confirmed-live note once re-added, or record the accept-idle decision. |
| `023-SW01-Build-Record.md` | To update on close | SPAN source row flips from "not configured" to confirmed, or to "accepted idle". |

## Closeout

- [ ] Decision made (A or B)
- [ ] Implemented (if A)
- [ ] Validated — `show monitor session 1` read back, not inferred from exit code
- [ ] `023` / `027` / `057` reconciled
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.**
