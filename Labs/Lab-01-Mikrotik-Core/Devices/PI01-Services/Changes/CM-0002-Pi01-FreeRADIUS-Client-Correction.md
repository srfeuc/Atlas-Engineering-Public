# CM-0002 — Correct Pi01 FreeRADIUS Client Addressing and Rotate Secrets

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

| Item | Value |
|---|---|
| Status | Closed |
| Risk | Medium — RADIUS auth outage for FGT01/MikroTik if misconfigured during change |
| Affected systems | Pi01 (FreeRADIUS), FGT01, MKT01 |

## Purpose

Two FreeRADIUS clients are configured with stale flat-network addresses instead of current VLAN 10 addresses. The `localhost` client also uses the FreeRADIUS default shared secret. All shared secrets in this file were additionally exposed in plaintext during this session's chat log and should be treated as compromised regardless of the addressing fix.

## Reason

Found during live Pi01 verification, 2026-07-11.

| Client | Configured | Should be |
|---|---|---|
| laptop | 10.0.0.50 | 10.10.0.50 |
| mikrotik | 10.0.0.1 | 10.10.0.1 |
| localhost | secret = `testing123` | new non-default secret |

## Prerequisites

- Confirm current RADIUS shared secrets configured on FGT01 and MKT01 match what will be set on Pi01 after rotation — this change requires updating the secret on all three systems together, not just Pi01, or RADIUS auth will break.
- Have console/local access to FGT01 and MKT01 available in case RADIUS auth is unavailable mid-change.

## Backup

`sudo cp /etc/freeradius/3.0/clients.conf /etc/freeradius/3.0/clients.conf.bak-20260711`

## Implementation

1. Generate new random secrets for `fortigate`, `mikrotik`, and `localhost` clients.
2. `sudo nano /etc/freeradius/3.0/clients.conf`
   - `laptop`: change `ipaddr` to `10.10.0.50`
   - `mikrotik`: change `ipaddr` to `10.10.0.1`, set new secret
   - `fortigate`: set new secret (rotating since exposed, even though IP is correct)
   - `localhost`: replace `testing123` with new secret
3. `sudo systemctl restart freeradius`
4. Update the matching RADIUS client secret on FGT01 and MKT01 to the new values.

## Validation

- `sudo systemctl status freeradius` — confirm running
- Test auth from FGT01 and MKT01 against Pi01 RADIUS after the secret update on all three systems
- `radtest` from Pi01 if available, to confirm local config is valid before touching FGT01/MKT01

## Rollback

Restore from backup: `sudo cp /etc/freeradius/3.0/clients.conf.bak-20260711 /etc/freeradius/3.0/clients.conf && sudo systemctl restart freeradius`. Revert FGT01/MKT01 secrets to prior values if already changed.

## Documentation updates

- [x] Build Record (029-Pi01-Build-Record.md) — Known Deviations already reflects the pre-fix state; update to Verified once closed
- [x] Build Guide — not applicable, no target procedure changed
- [ ] Revision History
- [ ] Confluence published and reviewed

## Closeout

- [x] Implemented — all four secrets rotated (`fortigate`, `mikrotik`, `localhost`, `localhost_ipv6`), `require_message_authenticator` enabled on `localhost`
- [x] Validated — FortiGate tested with real credentials via `Test Connectivity` and confirmed via the actual RADIUS reply payload; MikroTik's RADIUS integration was found to have never actually been completed (`use-radius` was `no`, no client entry existed) — built from scratch and confirmed working with real credentials
- [x] Documentation updated
- [x] Closed

**See `043-PKI-and-Credential-Security-Overhaul-Session-Summary.md` for the full diagnostic narrative**, including the MikroTik-side investigation (duplicate RADIUS entries, `use-radius` not persisting on first attempt, an unrelated stale local account password found along the way).
