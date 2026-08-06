# ADR-0013 — Retirement of `bridgeLocal`, the Admin Recovery Network

| Item | Value |
|---|---|
| Status | **Proposed — gated, deliberately NOT scheduled** |
| Governing Policy | POL-0007 |
| Scope | **Lab-01-Mikrotik-Core** |
| Date | 2026-07-14 |
| Related | `003-Physical-Topology.md`, `016-Network-Lessons-Learned.md`, `017-Future-Expansion.md`, `050-PVE01-iDRAC-Onboarding-Runbook.md`, `CM-0012`, `CM-0016`, `ADR-0011` |
| Evidence Status | **`Verified`** — MKT01 live output, 2026-07-14 |
| Supersedes | The line in `017-Future-Expansion.md` v1.0 proposing *"retirement of the legacy `10.0.0.0/24` network"* |

> **This ADR exists because `017` v1.0 proposed retiring the recovery network as a routine enhancement, and two other documents forbid it. A Change Record cannot resolve that. Reversing a written decision is a decision.**

## Context — what `bridgeLocal` actually is

**`bridgeLocal` is MKT01's admin recovery network.** `ether4`–`ether13`, gateway `10.0.0.1/24`. Plug the admin workstation into any of those ports, set a static `10.0.0.20/24`, and you have management access **independently of the VLAN infrastructure** — which, during a rebuild or a routing failure, does not exist.

### 🔴 There is only ONE `10.0.0.0/24`

`017` v1.0 said *"retire the legacy `10.0.0.0/24` network."* It was assumed this meant a dead pre-VLAN flat network, separate from `bridgeLocal`. **It does not. They are the same object.** Read off MKT01, 2026-07-14:

```text
/ip address print detail

 1     ;;; Legacy flat management
       address=10.0.0.1/24 network=10.0.0.0 interface=bridgeLocal
       actual-interface=bridgeLocal vrf=main
```

**One address. One interface. The device's own comment calls it *"Legacy flat management."***

### 🔴 And it is fully wired — INACTIVE is not DEAD

```text
/interface bridge port print where bridge=bridgeLocal
Flags: I - INACTIVE; H - HW-OFFLOAD
0 IH ether4   bridgeLocal  yes ...
...
9 IH ether13  bridgeLocal  yes ...
```

**All ten ports are members, hardware-offloaded, and NOT disabled** — **there is no `X` in the flag legend**, and per `016` (MikroTik): *RouterOS prints only the flags in use; no `X` means nothing on the device is disabled.*

**`I` (INACTIVE) means no cable is currently plugged in.** That is **the correct resting state for an unused fallback**, not evidence that it is dead.

> 🔴 **A hasty read of `INACTIVE` concludes "it's not doing anything, retire it."** That read is wrong. **A fallback is inactive right up until the moment it is the only thing that works.**

## The documents already decided this

| Document | Says |
|---|---|
| `003-Physical-Topology.md` | *"This exists precisely for rebuilds and lockouts… **Do not repurpose these ports. Do not remove `bridgeLocal`.**"* |
| `016-Network-Lessons-Learned.md` | *"`bridgeLocal` preserved access during routing failures. **It is the recovery path. Do not retire it early.**"* |
| `017-Future-Expansion.md` **v1.0** | 🔴 *"Retirement of the legacy `10.0.0.0/24` network."* |

**Two documents forbid it. One proposed it as routine housekeeping. Nothing reconciled them.**

## 🔴 Why retiring it TODAY would be reckless

**The recovery path is currently doing more work than it appears to, because the other independent paths are not there.**

| Path that should exist | Actual state |
|---|---|
| **iDRAC — out-of-band management** | 🔴 **It is not out-of-band.** Shared LOM on `eno1`/`Gi1/0/4`. **It dies with SW01 — step one of any teardown.** Fixed by `050`, which is **blocked on `CM-0012`** (dead CMOS battery). |
| **Restore-tested device backups** | 🔴 **None exist.** Not for SW01, FGT01, MKT01, or PVE01. `049` proved the **CA archive** restores. **No device configuration has ever been restored, on any device, ever.** |
| **Rebuild-from-documentation proven** | 🔴 **Never tested.** That is the entire premise of `ADR-0011`, which is itself Proposed and gated. |

**So today, if the VLAN infrastructure breaks, the management paths are: MikroTik WinBox MAC-connect, three serial consoles, and `bridgeLocal`.**

> 🔴 **Removing a fallback from a system that has never demonstrated it can recover without one is not simplification. It is a bet.**

## Decision

**Retirement is the intended end state. It is explicitly gated.**

### Preconditions — ALL must be true

| # | Precondition | Verify by |
|---|---|---|
| 1 | **Book 1 is frozen.** | `NETWORK-PACK-MANIFEST.md`. Three records open today: `CM-0010`, `CM-0012`, `CM-0014`. |
| 2 | 🔴 **The iDRAC is genuinely out-of-band** — moved to the R410's dedicated port, on its own cable and switch port, surviving an SW01 wipe. | `050`, which is blocked on `CM-0012`. **Not the shared LOM.** |
| 3 | 🔴 **A restore-tested backup exists for SW01 *and* MKT01.** | Not "a backup exists." **Restored, on the device, and proven.** A backup you have not restored is a hope (`016`). |
| 4 | **A rebuild has been performed from documentation alone**, at least once. | `ADR-0011` Move 3. |

**Any one failing means retirement is deferred. There is no "retire it and see."**

### Execution, once Accepted

A Change Record (`CM-XXXX`), **not** this ADR:

1. Remove `10.0.0.1/24` from `bridgeLocal`.
2. Decide `ether4`–`ether13`: **disabled**, or **enabled with a documented reason** — *"Available" is not a state* (`016` lesson 9).
3. **Reconcile the guides — Charter Rule 15.** `026-MKT01-Build-Guide.md`, `022-MKT01-Build-Record.md`, `003-Physical-Topology.md`, `016`, `048-Teardown-and-Rebuild-Runbook.md` — **every one of which currently instructs a reader to use `bridgeLocal` for recovery.** A rebuild from an unreconciled `026` recreates it.
4. **Read the state back off the device.**

## Consequences

**Accepted:**
- The lab keeps one management path that does not depend on VLANs, DAI, or SW01, until three real ones exist to replace it.
- **`017`'s dangerous line is neutralised** — the item now lives somewhere with its gate attached.

**Rejected — "retire it now, it's inactive":**

🔴 **`INACTIVE` means no cable is plugged in.** It is the correct state for a fallback. **This is the same error class as `CM-0012`'s cipher-0 "proof": reading an expected quiet result as evidence of something it does not evidence.**

**Rejected — "handle it with a Change Record":**

**A Change Record applies a decision safely. It does not make one.** `003` and `016` decided to keep `bridgeLocal`. **Reversing that is an ADR** — otherwise the reversal happens in a document nobody reading `003` would ever open. **`ADR-0008`: content in the wrong place gets acted on by someone who never knew there was a condition.**

## The pattern

> **A control that has never been needed looks identical to a control that is not needed.**

`bridgeLocal` has been quiet for months. **So has every safety net in this lab, right up to the moment it wasn't** — and `016` lesson 12 records that *every safety net that worked was one that failed loudly.* This one has not had to yet.

**And the device is carrying the invitation to delete it:** MKT01 comments the address `;;; Legacy flat management`. **Calling your recovery path "Legacy" on the device is how it gets deleted by someone acting in good faith.** Corrected by `CM-0016`.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-14. Raised after `017` v1.0 was found to propose retiring `10.0.0.0/24` — which the device confirmed **is** `bridgeLocal`, the admin recovery network that `003` and `016` both explicitly forbid removing. All ten member ports confirmed present, hardware-offloaded and not disabled. Gated on: Book 1 frozen, iDRAC genuinely out-of-band, restore-tested SW01/MKT01 backups, and one documentation-only rebuild. **Deliberately not scheduled.** |
