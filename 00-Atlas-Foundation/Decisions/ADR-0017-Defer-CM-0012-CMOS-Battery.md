# ADR-0017 — Defer `CM-0012` (PVE01 CMOS Battery) and Freeze Book 1

| Item | Value |
|---|---|
| Status | ✅ **Accepted — 2026-07-14** |
| Governing Policy | POL-0012 |
| Scope | **Lab-01-Mikrotik-Core** |
| Related | `CM-0012`, `050-PVE01-iDRAC-Onboarding-Runbook.md`, `036`, `ADR-0011`, `ADR-0015` |
| Effect | 🔴 **This is the last blocker. With it deferred, BOOK 1 FREEZES.** |

## Context

**`CM-0012` is hardware-blocked.** PVE01's CR2032 is dead: BIOS settings (including VT-x) and BMC configuration survive **only on continuous power.** Every other Book 1 blocker is now closed:

| | |
|---|---|
| `CM-0010` | ✅ Closed — CA rotation, exposed key copies destroyed, guides reconciled |
| `CM-0014` | ✅ Closed — **rotation proven, history purged and verified from a fresh clone of GitHub, scanner proven against the real incident** |
| `CM-0016` | ✅ Closed — the `;;; Legacy flat management` label that nearly got the recovery network deleted |
| `CM-0017` / `CM-0018` | ✅ Closed — MKT01 has a working break-glass path **for the first time in its existence** |
| 🔴 **`CM-0012`** | **Hardware. Cannot be closed by any amount of documentation.** |

## Decision

**`CM-0012` is deferred, not closed.** Per the Charter's pack lifecycle — *"each item must be closed, **or explicitly deferred by an accepted ADR**"* — **Book 1 freezes.**

**Nothing is ticked that is not true.** The battery is still dead. **This ADR says so, on the record, with a name and a date on it.**

> **A deferral you wrote down is engineering. A tick you did not earn is a lie.**

## What remains true while deferred

- 🔴 **PVE01 loses its BIOS settings and RTC on every full power loss.** VT-x reverts. The clock resets (found at **2018**). **`036` documents all three symptoms as one root cause.**
- 🔴 **`050` (iDRAC Onboarding) stays BLOCKED.** *"Configuring a BMC that cannot hold its settings is documenting a lie."*
- 🔴 **The iDRAC remains on the shared LOM** — **it dies with SW01, which is step one of any teardown.** It is **not** out-of-band. `048` says so.
- **Mitigation:** keep PVE01 on **continuous power**. A UPS is the practical answer.

## Conditions to close

1. Replace the CR2032.
2. **Full power-pull** (unplug, hold power ~5s to drain).
3. **Prove the board holds config:** `egrep -c '(vmx|svm)' /proc/cpuinfo` returns the CPU count, and `timedatectl` shows a sane RTC.
4. **Then** `050` unblocks — and its Step 1 moves the iDRAC to the dedicated NIC. 🔴 **Same chassis visit. And the iDRAC's MAC changes — SW01's `STATIC-HOSTS` must be updated in the same session, or DAI drops it silently** (`DHCP Permits: 0`, no fallback).

> **Three things in one chassis visit, and the third one is not in the chassis.**

## Consequences

- ✅ **Book 1 FREEZES.** The first pack in Atlas to reach `Frozen`.
- **Book 10 (Network Services) can begin** — `ADR-0015`.
- **A frozen pack with a deferred hardware item is honest.** A frozen pack with a ticked box that nobody earned is the defect this entire project exists to prevent.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-14. Defers `CM-0012` pending a CR2032. **Book 1 freezes with every other blocker genuinely closed and verified.** |
