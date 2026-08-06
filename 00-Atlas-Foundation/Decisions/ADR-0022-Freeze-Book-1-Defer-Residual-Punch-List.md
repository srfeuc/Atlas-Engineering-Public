# ADR-0022 — Freeze Book 1 at `a03458f`; Defer the Residual Device Punch-List

| Item | Value |
|---|---|
| Status | ✅ **Accepted — 2026-07-16** |
| Governing Policy | POL-0003 |
| Scope | **Lab-01-Mikrotik-Core** |
| Related | `CM-0030`, `CM-0036`, `CM-0037`, `CM-0012`, `ADR-0017`, `ADR-0020`, `055-MKT01-Considerations-and-Risks.md`, `050-PVE01-iDRAC-Onboarding-Runbook.md`, `ADR-0019` |
| Freeze baseline | **`a03458f`** (`main`, `origin/main`) — *"Freeze handoff: Session-Handoff v8.0, place Design Brief, 305 + 301 v1.1 (bind pair)"* |
| Effect | 🔴 **Opens the restructure gate.** With these items deferred on the record, Restructure Gate 1 (*no open device-gated work*) is satisfied — **by deferral, not by unearned ticks.** |

## Context

Book 1 is reconciled to live across all five devices — Pi01 and FGT01 previously, SW01 / MKT01 / PVE01 this cycle. The operator is declaring the freeze **here, at `a03458f`**, so the flat → `governance/` + `labs/` + `devices/` restructure can run on a clean, tagged tree.

The restructure Execution Handoff's **Gate 1** forbids starting *"while device-gated work is open."* Six items remain open on the devices. None blocks a documentation freeze — each is non-blocking, hardware-bound, or waiting on infrastructure that does not yet exist (a monitoring host; Phase 2 AD). Per the Charter pack lifecycle — *"each item must be closed, **or explicitly deferred by an accepted ADR**"* — this ADR defers them, by name, each with the condition that closes it.

> **A deferral you wrote down is engineering. A tick you did not earn is a lie.** Nothing below is ticked. Every item is still open; this ADR says so, with a name and a date on it.

## The deferred items

| Item | Device | What is still true (NOT ticked) | Condition to close |
|---|---|---|---|
| **CM-0030** | SW01 | Clock reads **stratum 16 — never synchronised.** The NTP *config* points somewhere; the *clock* does not follow it. | Point SW01 at a real authority — the AD PDC-emulator once Phase 2, or the external pool as interim (target set by **ADR-0020**) — then **verify the clock READS synced**, not the config line. |
| **CM-0036** | SW01 | A SPAN session is built on **Gi1/0/5** and **nothing is plugged into it.** A tap nobody tapped is a control that was never tested. | Attach an analyzer (Suricata / Wireshark), confirm mirrored traffic arrives — **or formally retire the SPAN**, so a dangling config isn't mistaken for a live control. |
| **CM-0037** | SW01 | SNMP carries a **location string and points at a host that does not exist** (MON01 is not built). | Correct the string and repoint at MON01 **when it exists** — or remove SNMP until there is something to point it at. |
| **CM-0012** | PVE01 | RTC **will not hold time.** 🔴 **Re-tested this cycle with a NEW CR2032 — still failed.** The fault is the **board, not the cell.** Blocks `050` (iDRAC onboarding). | 🔴 **Supersedes ADR-0017 close-condition #1** ("replace the CR2032") — now known insufficient. Close requires a **board-level fix** (mainboard replacement) **or** a written acceptance that PVE01 lives on **continuous power (UPS)** permanently. Remains deferred under **ADR-0017**. |
| **MKT01 RouterBOOT firmware** | MKT01 | Firmware finding at **`055` row 12** is unresolved — neither upgraded nor formally accepted. | **Decide upgrade-or-accept and record it.** Default under this freeze: **accept the running firmware**, revisit at the next MKT01 maintenance window. (Operator: record the running version.) |
| **MKT01 discovery leak** | MKT01 | `discover-interface-list` may still **broadcast device identity** (open since v7.0 #7). | 🟢 **Recommended to CLOSE now, not defer** — one command, zero lockout risk. Restrict discovery to `none` (or the management interface only), then **read it back** to confirm. Deferred only if not closed at freeze. |

## Scope of this freeze

- The baseline is **`a03458f` exactly** — nothing planned, only what is committed.
- 🔴 **CIS benchmarking of MKT01 and PVE01 is NOT part of this freeze.** Only SW01 / Pi01 / FGT01 have CIS checklists (`045` / `046` / `047`); MKT01 and PVE01 do not. That work is contemplated but not done. It is **new device-gated work**: doing it *before* the restructure **re-opens this freeze**; doing it *after* lands it directly in each device's `cis-hardening.md` slot. This ADR freezes what exists, not what is planned.

## What this freeze does NOT resolve (still open — and worse than anything above)

Carried from the v8 handoff. These are not device-gated and are not fixed by freezing:

- 🔴 **No off-site copy of the backup media.** Both archive copies are in one room; a single fire takes the Root CA, the Intermediate CA, every RADIUS secret and the vault. (`049` Phase 5.)
- 🔴 **No device backup has ever been restore-tested.** Only the CA archive has. A backup you have not restored is a hope.

Freezing Book 1 does not make these true — it just stops adding to Book 1 while they remain open. The restructure is a **move, not a fix**, and does not touch them either.

## Decision

**Book 1 freezes at `a03458f`.** The six items above are deferred (CM-0012 remains deferred, its close-condition updated to board-level). Once this ADR is committed — and the operator optionally closes the MKT01 discovery leak — **Gate 1 is satisfied and the restructure may proceed:** tag `pre-restructure`, branch, migrate.

## Consequences

- ✅ **The restructure gate opens.** The move can begin on a clean, tagged tree.
- The deferred items **travel with their devices** — after the restructure each lives under `labs/lab-1-mikrotik-core/devices/<device>/changes/`, so none is lost in the move.
- **A frozen pack with named, dated deferrals is honest.** A frozen pack with an unearned tick is the defect this project exists to prevent.
- If a deferred item is later closed, Book 1 may briefly **unfreeze** to accept the change record — *"a freeze that cannot be revisited is a monument, not a baseline"* (`ADR-0019`).

## Review Trigger

- **Phase 2 (AD) stands up** → CM-0030 (point SW01 at the PDC-emulator) becomes closable.
- **MON01 / the monitoring host is built** → CM-0036 and CM-0037 become closable.
- **PVE01 mainboard replaced, or UPS-acceptance written** → CM-0012 / `050` unblock.
- **Next MKT01 maintenance window** → RouterBOOT upgrade-or-accept is finalised.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-16. Freezes Book 1 at `a03458f`; defers `CM-0030`, `CM-0036`, `CM-0037` and the MKT01 RouterBOOT finding; reaffirms the `CM-0012` deferral and **supersedes ADR-0017's CR2032 close-condition with a board-level finding** (new-battery re-test failed); recommends closing the MKT01 discovery leak at freeze. **Opens the restructure gate.** Records that CIS benchmarking and the two lab-wide risks (off-site backup, restore-test) are explicitly out of scope and remain open. |
