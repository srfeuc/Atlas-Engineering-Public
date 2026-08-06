---
Title: Playbook — Recover a Locked-Out Router Out-of-Band (MAC-WinBox / console before factory reset)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on MKT01. Grounded in the real frozen **Lab-01** MKT01 recovery build (`CM-0017`/`CM-0018` + the console-recovery spec), current-design-reconciled (`ADR-0022`/`ADR-0023`). Searchable/ticket-ready per Backlog **#32**.
Version: 1.0
Date: 2026-07-31
---

# Playbook — Recover a Locked-Out Router Out-of-Band

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: recovery / break-glass. **You can't reach the core router over its normal IP management path — a bad rule, a disabled port, a lost address, or a config that won't boot — and you need to get back in without a factory reset.** This page walks the out-of-band ladder: IP management → **MAC-WinBox (Layer-2, on the one recovery port)** → **serial console** → factory reset as the last resort.

**Why this is a first-tier playbook (Backlog `#32`).** MKT01 owns every VLAN gateway; a lockout is an estate-wide outage. In frozen Lab-01 the router had **no console** for most of its life, and **MAC-WinBox on `ether4` was the only way back** — a path that had to be *built and proven with a live MAC-connect before it was ever needed* (`CM-0018`). `ADR-0023` now makes a tested console a **hard prerequisite** before MKT01 becomes the default-deny east-west firewall: *a default-deny box with no console is one bad rule from total lockout.* Build and test the recovery path on a healthy device — a cable proven only during an outage is a hope, not a control (`ADR-0011`).

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- "*ERR: Could not connect, MacConnection syn timeout*" (a MAC-WinBox attempt failing).
- WinBox by IP just times out / "*could not connect to 10.10.0.1*".
- serial console shows a **blank screen** / garbage (wrong baud or flow control).
- "*connected but blank*" over console (RTS/CTS flow control left on).

**Plain-language symptom phrases**

- "I'm locked out of the router / MikroTik and there's no console."
- "I pushed a bad firewall rule and now I can't reach anything."
- "I disabled the wrong port and cut off my own management path."
- "how do I get into the router without a factory reset?"
- "WinBox won't connect by IP anymore."
- "the router won't boot its config / I need break-glass access."
- "MAC connect drops after a few seconds."

**Aliases / also-known-as**

- out-of-band recovery · break-glass access · MAC-WinBox / MAC-Telnet · Layer-2 management · console recovery · serial console · null-modem cable · ROMMON (Cisco equivalent) · factory reset last resort.
- locked out of MikroTik · RouterOS lockout · lost management access · recovery path · `ether4`-only.

**Keywords line**

`MAC-WinBox` · `mac-server` · `RECOVERY` interface list · `ether4` · `CM-0017` · `CM-0018` · RB1100AHx4 · 115200 8N1 · null-modem · FTDI · `/port print` · `serial0` · syn timeout · `ADR-0016` · `ADR-0023` · WinBox Neighbors · factory reset · break-glass.

## Cert anchor

- **MTCNA** (RouterOS management, MAC-WinBox, recovery) — the primary anchor.
- **CCNA** (out-of-band console, password recovery / ROMMON — the Cisco equivalent).
- CompTIA **Security+ / Server+** (recovery, break-glass, physical access).
- *(Grounding index: `../Atlas-Certification-Lab-Map.md` §4 (MTCNA recovery) + the MKT01 console-recovery spec; `../Concepts/README.md` — recovery paths are load-bearing and invisible.)*

## Grounded in — MKT01's recovery model (know it *before* you're locked out)

The recovery ladder, in order (`POL-0008` — the device pages own these facts; this page links):

- **Normal path:** IP WinBox / SSH to MKT01's mgmt address (`10.10.0.1` in Lab-01; today's plan address). Unaffected by MAC-server changes — it's your working rollback session.
- **Break-glass path (Layer-2):** **MAC-WinBox** answers on the **`RECOVERY`** interface list = **`bridgeLocal` via `ether4` only** (`CM-0018`). MAC-WinBox speaks **Ethernet, not IP** — the IP firewall never evaluates it, so it works even when routing/addressing is broken. In Lab-01 the session **dropped after ~15 s** (a recorded limitation, `ADR-0016`). MAC-**Telnet** (`mac-server`) is deliberately **`none`** (unauthenticated shell — nothing needs it).
- **Serial console:** MKT01 = **RB1100AHx4**, **DB9 RS232**, **115200 8N1, flow control NONE**, **null-modem (crossover)** cable, genuine **FTDI** chip, router port is **female → cable end male** (the console-recovery spec). Historically deferred (`ADR-0016`); `ADR-0023` makes it a hard prereq for the E-W firewall role.
- **Factory reset:** the last resort — it wipes the box that owns every VLAN gateway; you then rebuild from the teardown runbook (`Recover-the-Lab-from-a-Bare-Metal-Teardown.md`).

> 🔴 **Physical-threat note (why only `ether4`):** every enabled `bridgeLocal` port answers MAC-WinBox — so ten enabled ports = ten login prompts in an unlocked room. Scoping to `ether4` reduces ten doors to one. A source-MAC allow-list was **rejected** — MACs are spoofable in one command, so it's a speed bump that looks like a lock. The real control for the room is **SW01 `port-security`** (deferred to Book 10). You cannot disable *all* ports — you can't log in to re-enable one — so `ether4` is the irreducible price of having a recovery path.

Command detail (link down — `POL-0008`): `../Command-Library/RouterOS.md` §Mgmt (`/tool mac-server`, `/interface list`, `/port print`). Why-it-works: `../Concepts/README.md` (MAC-WinBox bypasses every IP control; discovery ≠ access).

## ① Pin it down (capture these first — they're the ticket)

- a. **What broke your access** — a bad firewall rule? a disabled port? a lost/changed mgmt IP? a config that won't boot? (Determines which rung you need.)
- b. **Do you still have *any* working session?** — an open WinBox/SSH tab is your rollback; **do not close it.** If you're mid-change, you may be able to undo before fully locking out.
- c. **Which recovery paths exist & are proven** on this device — MAC-WinBox on `ether4` (tested?), a working serial console (cable in hand, tested?), or neither.
- d. **Physical access** — can you reach the device to plug into `ether4` or the console port? (Break-glass is inherently on-site.)
- e. **Is a reboot safe?** — a config that won't boot vs a bad-but-running config change the order (don't reboot away a running rollback).

## The diagnosis / recovery path — least-destructive rung first

**1. Try the normal IP path (and keep any working session open).**

- a. WinBox/SSH to the mgmt IP.
  - Reference: `../Command-Library/RouterOS.md` §Mgmt.
  - Works → you're in; go undo the change (below). Keep the session; it's your rollback.
  - Broken: `could not connect` / timeout → drop to rung 2.
- b. If you have *another* still-open session, use it to read `/ip firewall filter print` / `/interface ethernet print` and undo the offending line — the cheapest recovery of all.

**2. MAC-WinBox on `ether4` (Layer-2 break-glass).**

- a. Plug the admin workstation **directly into `ether4`** (the only port that answers).
- b. WinBox → **Neighbors** → select **exactly one row** (not two — multiple selections cause a malformed request that looks like a lockout) → click the **MAC address** → **Connect**.
  - Healthy: a session opens — you're in over Layer 2, no IP needed. Work fast (the Lab-01 path dropped after ~15 s — get the one command in).
  - 🔴 Broken: `MacConnection syn timeout` → either you're not on `ether4`, the `RECOVERY` list is wrong (MAC server may need the physical port added), or `mac-winbox` is `none`. 📸 the successful MAC-connect (the proof the path works).
- c. In the MAC session, undo the lockout cause (re-enable the port / fix the rule / restore the mgmt address), then confirm IP WinBox works again.

**3. Serial console (when MAC-WinBox can't help — e.g. the box won't boot its config).**

- a. Use the known-good cable: genuine **FTDI**, **null-modem**, DB9 **male** end (router port is female). Do **not** stack a null-modem coupler on an already-crossover cable (cancels the crossover → dead session).
- b. Terminal: **115200, 8 data, No parity, 1 stop, Flow control NONE** (RTS/CTS on = the classic "connected but blank").
- c. **Open the terminal BEFORE powering/rebooting** so you catch RouterBOOT output.
- d. If blank: confirm `serial0` isn't reassigned — `/port print` (it has been found bound to `remote-access` instead of console; free it).
- e. Log in, fix the config, save.

**4. Factory reset — last resort only.**

- a. Only if rungs 1–3 are exhausted. This wipes the router that owns every VLAN gateway.
- b. Then rebuild from the teardown/rebuild runbook (`Recover-the-Lab-from-a-Bare-Metal-Teardown.md`) using the source-of-truth config, not memory.

## Fix / prove the recovery path exists BEFORE you need it (the real deliverable)

The best time to run this playbook is on a **healthy** device (`ADR-0011` — a path proven only in an outage is a hope):

- a. Confirm the `RECOVERY` interface list = `bridgeLocal`, `mac-winbox = RECOVERY`, `mac-server` (MAC-Telnet) still `none` — read each back (`print detail`, not assumed).
- b. **Test A — the path works:** MAC-connect from `ether4` succeeds (📸 it).
- c. **Test B — the exposure is closed:** from a VLAN host, a MAC-connect is **refused** (no L2 path from the VLANs to `bridgeLocal`).
- d. Prove the serial console end-to-end: log in over console, run one command, confirm output — with the cable/settings above.
- e. Keep both config files off the device (a backup on the box you might lock yourself out of is not a backup).

## Prove it's recovered

- a. IP WinBox/SSH to the mgmt address works again; the offending change is undone/corrected (read it back — `Confirm-a-Config-Change-Actually-Took.md`).
- b. The gateways are up estate-wide (inter-VLAN routing restored).
- c. The recovery path itself still works (re-test MAC-connect from `ether4` after any port changes).
- d. 📸 the restored IP session + the working MAC-connect. Mark ✅ only with the pasted read-backs (`POL-0001`).

## If still broken

- MAC-connect times out on `ether4` → add `ether4` to `RECOVERY` directly and re-test; confirm you're physically on `ether4`, and select one Neighbors row only.
- Console is blank → wrong flow control (set NONE), wrong baud (115200), a straight-through (non-null-modem) cable, a counterfeit PL2303 chip (use genuine FTDI), or `serial0` reassigned (`/port print`).
- Nothing works and it's a bad config that boots → you still have Layer-2; if it *won't* boot → console; if console is unavailable → factory reset + rebuild.
- The mgmt IP is simply wrong/lost → MAC-WinBox doesn't need IP; get in over Layer 2 and reset the address.

## Related

- **Command-Library:** `../Command-Library/RouterOS.md` (§Mgmt — `/tool mac-server`, `/interface list`, `/port print`).
- **Concepts:** `../Concepts/README.md` (MAC-WinBox bypasses every IP control; discovery ≠ access; recovery paths are load-bearing).
- **Decisions / owners:** `Devices/MKT01-East-West-Firewall/` (+ the console-recovery cable spec) · `ADR-0016` (console deferred → the spec) · `ADR-0023` (console is a hard prereq for the E-W role) · `ADR-0014` (Layer-2 management posture).
- **Sibling playbooks:** `Enumerate-Every-Enabled-Interface-Before-Hardening.md` (don't shut the recovery port in the first place) · `Recover-the-Lab-from-a-Bare-Metal-Teardown.md` (the full rebuild if you must reset) · `Confirm-a-Config-Change-Actually-Took.md` (read the fix back) · `Disable-the-Default-admin-Without-Locking-Yourself-Out.md` (the credential twin).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).
- **Real lineage:** frozen Lab-01 `Devices/MKT01-Core-Router/Changes/CM-0017` (MAC-server was always `none`) + `CM-0018` (built + proved the `ether4` recovery path by live MAC-connect) + `Console-Recovery-Cable-and-Settings.md` (the serial spec) — `ADR-0022`-reconciled.

## Worked log

| Date | Who | Time (RTO if a drill) | Path used | Cause of lockout | Outcome |
|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the new **Symptoms & search terms** element `#32`). The core router's break-glass ladder: IP WinBox/SSH → MAC-WinBox on `ether4` (Layer-2, bypasses the IP firewall) → serial console (RB1100AHx4, 115200 8N1, null-modem, genuine FTDI, female→male) → factory reset last. Emphasises building + testing the path on a healthy device (Test A works / Test B closed) per `ADR-0011`, and why only `ether4` stays open (spoofable MACs; `port-security` is the real room control). Grounded in the frozen Lab-01 `CM-0017`/`CM-0018` MAC-WinBox build + the console-recovery spec (`ADR-0016`/`ADR-0023`). 🟡 until worked on MKT01. |
