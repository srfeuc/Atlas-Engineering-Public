# CM-0035 — Disable Unused `bridgeLocal` Ports (`ether5`–`ether13`) and Relabel the Bridge Comment

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | ✅ **Closed — implemented and verified 2026-07-15** |
| Risk | **Low** — no cabling on these ports; `ether4` remains the live recovery port. |
| Affected systems | MKT01 (`ether5`–`ether13`, `bridgeLocal` interface comment) |
| Date raised / executed | 2026-07-15 |
| Evidence Status | **`Verified`** — `/interface print` read back on the live device, before and after |

## Reason

Two things surfaced during the 2026-07-15 MKT01 reconciliation:

**1. `ether5`–`ether13` were enabled — contradicting an ADR that claimed they were already disabled.**

`ADR-0014` (Option C, Accepted 2026-07-14) states *"`ether4` is the sole enabled recovery port, `ether5`–`ether13` disabled,"* and records it as **"Executed by `CM-0018`."** The live device disagreed:

```text
/interface print   (2026-07-15, before)
 3   S ether4 ...        <- no X: enabled
 4   S ether5 ...        <- no X: ENABLED
 ...
12   S ether13 ...       <- no X: ENABLED
```

**All nine were enabled.** This is another closeout that claimed a device state the device did not hold — the same Rank-6 pattern the audit documents. `bridgeLocal` is the recovery network and is deliberately kept, but only `ether4` needs to be live; the other nine were idle, purposeless, and enabled — the `010` Unused Interface Policy applies exactly as it did to `ether2` (`CM-0015`).

**2. The `bridgeLocal` interface still carried the misleading `;;; Legacy flat management bridge` comment.**

`CM-0016` corrected the *IP-address* comment on `10.0.0.1/24` but not the *bridge-interface* comment — so the exact "Legacy" label `CM-0016` existed to eliminate survived on a parallel object (R2: the correction reached one object and missed the one beside it).

## Implementation

```routeros
/interface disable ether5,ether6,ether7,ether8,ether9,ether10,ether11,ether12,ether13
/interface set bridgeLocal comment="ADMIN RECOVERY NETWORK (bridgeLocal) - DO NOT REMOVE. MAC-WinBox recovery via ether4 only. ADR-0013/0014/0016, CM-0016."
```

`ether4` is intentionally **not** disabled — it is the sole live recovery port.

## Validation — read back from the device, 2026-07-15

```text
/interface print
Flags: X - DISABLED; R - RUNNING; S - SLAVE
 3   S ether4        <- no X: still enabled (recovery port)
 4 X S ether5
 5 X S ether6
 ...
12 X S ether13
14  R  bridgeLocal   ;;; ADMIN RECOVERY NETWORK (bridgeLocal) - DO NOT REMOVE. MAC-WinBox recovery via ether4 only. ...
```

**`ether5`–`ether13` carry `X`. `ether4` does not. `ether1`/`ether3` untouched. The bridge comment no longer says "Legacy."**

## Rollback

```routeros
/interface enable ether5,ether6,ether7,ether8,ether9,ether10,ether11,ether12,ether13
```

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| `026-MKT01-Build-Guide.md` | ✅ **Updated** | The unused-interface step now disables `ether5`–`ether13` (keeping `ether4`), and the `bridgeLocal` build comment is the corrected recovery-network text. A rebuild reproduces the hardened state. |
| `022-MKT01-Build-Record.md` | ✅ **Updated** | Records `ether5`–`ether13` disabled and the corrected bridge comment. |
| `048-Teardown-and-Rebuild-Runbook.md` | 🟡 **Note** | The recovery port is **`ether4` only** — a cable in `ether5`–`ether13` is now dead. Runbook already directs `ether4`; no change required, flagged for awareness. |
| `ADR-0014` | 🟡 **Superseded on timing** | Its claim that `CM-0018` executed the `ether5`–`ether13` disable was false; the disable actually happened here, 2026-07-15. The *decision* stands; the *execution date* is corrected by this record. |

## Closeout

- [x] `ether5`–`ether13` disabled — **`X` flags read back**
- [x] `ether4` confirmed still enabled (recovery port intact)
- [x] `bridgeLocal` comment corrected — **read back, no longer "Legacy"**
- [x] `026` updated — disable step + corrected comment
- [x] `022` updated — port and comment state recorded
- [x] Change Management index updated (`CM-0035` listed)
- [x] **Closed 2026-07-15**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised and closed 2026-07-15 during the MKT01 device-reconciliation pass. Found `ether5`–`ether13` enabled (contradicting `ADR-0014`'s "disabled, executed by CM-0018" claim) and the `bridgeLocal` interface still commented "Legacy." Disabled the nine ports (kept `ether4`), relabelled the bridge comment, and read both back off the device. |
