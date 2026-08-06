# CM-0034 — Disable the Default `admin` User on MKT01

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | ✅ **Closed — implemented and verified 2026-07-15** |
| Risk | **Low** — `SethAdmin` (RADIUS-backed, full group) is the working admin and logged in the same day; the default account is a reduction in attack surface, not a functional change. |
| Affected systems | MKT01 (`/user`) |
| Date raised / executed | 2026-07-15 |
| Evidence Status | **`Verified`** — `/user print` read back on the live device, before and after |

## Reason

`/user print` on MKT01 (2026-07-15) showed the RouterOS default account `admin` **still enabled**, alongside the real operator account `SethAdmin`:

```text
0   admin      full   2026-07-12 21:45:05  none
1   SethAdmin  full   2026-07-15 12:41:22  none
```

A well-known default username left enabled on the core router is a standing hardening gap. No Atlas document recorded a decision either way — the account simply persisted from the factory image. `SethAdmin` is a full-group account, RADIUS-integrated, and demonstrably in use (it logged in the same day), so nothing depends on `admin`.

## Implementation

```routeros
/user disable admin
```

Not `remove`. Disabling is reversible and keeps the account's audit history; removing the last-resort default account is a heavier step reserved for a deliberate decision.

## Validation — read back from the device, 2026-07-15

```text
/user print
Flags: X - DISABLED
0 X admin      full   2026-07-12 21:45:05  none
1   SethAdmin  full   2026-07-15 12:41:22  none
```

**`admin` now carries `X`. `SethAdmin` is unchanged and remains the sole enabled login.**

> 🔴 **`SethAdmin` is now the only enabled account on MKT01.** Its password must be in Vaultwarden and recoverable — if it is lost, recovery is MAC-WinBox into `ether4` (`CM-0018`) and, failing that, a factory reset (MKT01 has no serial console, `ADR-0016`).

## Rollback

```routeros
/user enable admin
```

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| `026-MKT01-Build-Guide.md` | ✅ **Updated** | Harden step now disables the default `admin` account as part of the build, so a rebuild does not come back with it enabled. |
| `022-MKT01-Build-Record.md` | ✅ **Updated** | Records the local user state: `admin` disabled, `SethAdmin` the sole enabled account. |

## Closeout

- [x] `admin` disabled on the device — **`X` flag read back**
- [x] `SethAdmin` confirmed still enabled and recently logged in
- [x] `026` updated — disable step added to the build
- [x] `022` updated — user state recorded
- [x] Change Management index updated (`CM-0034` listed)
- [x] **Closed 2026-07-15**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised and closed 2026-07-15 during the MKT01 device-reconciliation pass. Default `admin` account found enabled; disabled and read back (`X`). `SethAdmin` is now the sole enabled login. |
