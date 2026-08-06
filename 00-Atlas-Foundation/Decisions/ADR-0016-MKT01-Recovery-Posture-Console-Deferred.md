# ADR-0016 — MKT01 Recovery Posture: Serial Console Deferred, MAC-WinBox Accepted With Known Limits

| Item | Value |
|---|---|
| Status | ✅ **Accepted — operator, 2026-07-14** |
| Governing Policy | POL-0009 |
| Scope | **Lab-01-Mikrotik-Core** |
| Date | 2026-07-14 |
| Related | `ADR-0014`, `CM-0017`, `CM-0018`, `003`, `026`, `048`, `016` |
| Evidence Status | **`Verified`** — every claim below was read off MKT01 or produced by a live test on 2026-07-14 |
| Effect | 🔴 **Explicitly defers the remainder of `CM-0018` and `CM-0017`, per the Charter's pack lifecycle: *"each item must be closed, or explicitly deferred by an accepted ADR."*** **This ADR is what allows Book 1 to freeze without anyone pretending.** |

> **This ADR exists so that a partially-implemented change can be closed honestly instead of being ticked shut.**
>
> **`016` lesson 2:** *`CM-0009` was marked `Closed — implemented and verified` with two of its own boxes unticked.* **A checklist nobody verifies reports success by default.** **This is the alternative: say what was done, say what was not, say why, and accept it as a decision.**

## What was actually done — verified on the device

| Change | State | Evidence |
|---|---|---|
| `RECOVERY` interface list, one member: `bridgeLocal` | ✅ **Done** | `/interface list member print where list=RECOVERY` |
| `mac-winbox allowed-interface-list` = `RECOVERY` | ✅ **Done** | `/tool mac-server mac-winbox print` |
| MAC-Telnet (`mac-server`) = `none` | ✅ **Unchanged — now a recorded decision, not a default** | `/tool mac-server print` |
| 🟢 **MAC-connect from `ether4` — TESTED AND CONNECTED** | ✅ **PASS** | Live WinBox session; `/system resource print` returned |

> 🟢 **MKT01 has a working break-glass recovery path for the first time in its existence.** Four documents claimed it had one. **It never did.** Now it does.

## What was NOT done — and is deferred by this ADR

| Deferred | Why |
|---|---|
| 🔴 **Serial console** (`CM-0017`, `017`) | **Operator has purchased three USB-serial adapters; none worked.** In a production environment this would be non-negotiable. **In this lab, the cost/benefit does not currently justify a fourth attempt.** |
| 🔴 **Discovery scoping** (`CM-0018` Step 4) | `discover-interface-list` remains **`static`**. **The disclosure leak is OPEN.** |
| 🔴 **Disabling `ether5`–`ether13`** (`CM-0018` Step 5) | **All ten `bridgeLocal` ports remain enabled.** |

## 🔴 The 15-second drop — accepted, with eyes open

**MAC-WinBox on `bridgeLocal` connects and then drops after roughly 15 seconds.** Reproduced with a minimal config (one list member), static addressing, a direct cable to `ether4`, and **read-only commands only** — so it is **the transport, not the configuration.**

**Investigated and ruled out:**

- **Not our scoping** — `RECOVERY` had exactly one member; the drop persisted.
- **Not DHCP/APIPA re-homing** — the workstation uses static addressing exclusively.
- **Not a self-inflicted session kill** — the *first* drop was: modifying the interface list that the live MAC session's transport was bound to. **The second test changed nothing and still dropped.**
- 🔴 **WinBox 3.x was NOT tried, and will not be.** MikroTik has removed the WinBox 3 downloads; sourcing an old binary from an unofficial mirror to debug a recovery path is a worse trade than the problem. **Operator's call, and it is correct.**

### Why this is accepted rather than solved

> **The acceptance criterion for a break-glass path is not *"can it hold a session for an hour."*** **It is: *"can I get in, set an IP address, and switch to a real session?"***
>
> **Three commands completed inside the 15-second window. `/ip address add ...` is one line. It clears the bar.**

**MAC-WinBox is a recovery transport, not a management session** — it is non-TCP, and MikroTik's own guidance positions it for initial configuration and recovery, not sustained administration. **Judged against that bar, it passes.**

🔴 **But it is a thin margin, and the record should say so:** *"it works, if you are quick and you know exactly what to type."* **That is not the same as a console, and this ADR does not pretend it is.**

## 🔴 MAC-Telnet — rejected, and the reasoning that nearly got it accepted was bad

**Considered as a more reliable transport, scoped identically. Rejected by the operator: no Telnet.**

**Correct call.** The argument for it was: *"the alternative is no path at all."* **That framing was false.** The alternative is **a serial console** — same physical scoping, no cleartext credentials on the wire, and **it survives a RouterOS that will not boot**, which MAC-WinBox does not.

> 🔴 **The lesson is about the argument, not the protocol.** *"There is no other option"* is the reasoning that justifies bad decisions. **There was another option. It was deferred, not absent** — and a deferred option is not the same as no option.

## 🔴 The security change this ADR is accepting — stated plainly

| | MAC-WinBox answers on |
|---|---|
| **Before 2026-07-14** | **Zero ports.** `mac-winbox = none`. |
| **Now** | **Ten ports** — `ether4`–`ether13`, all enabled, all on `bridgeLocal`. |

**In an unlocked-server-room threat model, this is a net increase in physical attack surface, and it must not be recorded as anything else.**

**Accepted because:**

1. **The security delta is small.** An intruder standing at the router tries all ten sockets and finds a live one in seconds. **Disabling nine ports defends against an *accidental* plug-in, not a deliberate one.** The reduction from ten doors to one is real but modest, and it was initially oversold in analysis.
2. 🔴 **The real control was always the password**, not the port count. MKT01 authenticates via FreeRADIUS (`/user aaa use-radius=yes`).
3. **The real control for an unlocked room is `switchport port-security` on SW01** — not port states on the router. **Deferred to Book 10** (`ADR-0015`). **That is where this threat actually gets addressed.**
4. **The recovery path is worth more than the nine ports.** MKT01 had **no way in** if its addressing broke. It now has one. **That trade is worth making.**

> **This is a decision, not an oversight. If it is ever revisited, revisit it as a decision.**

## 🔴 The discovery leak remains OPEN

`discover-interface-list = static`. **MKT01 advertises its identity, RouterOS version (`7.23.1`), board model (`RB1100AHx4 Dude Edition`) and uptime on every static interface — including every VLAN.** Confirmed visually: a WinBox Neighbors view from VLAN 10 shows all of it, plus `Board's Port: vlan10-mgmt`.

**A host on VLAN 20 (Servers) or VLAN 50 (Client) gets a free patch-level and CVE lookup — and no access, because MAC-WinBox does not answer there.**

> **Disclosure without capability.**

**This is a one-command fix with no lockout risk** — `/ip neighbor discovery-settings set discover-interface-list=RECOVERY`. **From `ether4` the router would still appear in Neighbors, so recovery is unaffected.** **The only cost is losing CDP/LLDP visibility to SW01 on the trunk, which is cosmetic today because no monitoring host exists.**

**Deferred, not rejected.** 🔴 **It should be the first thing Book 10 does.**

## Consequences

- **`CM-0017` and `CM-0018` can close** — implemented as far as decided; remainder deferred **by this ADR**, per the Charter.
- **`022`, `026`, `003`, `048` and `016` must be reconciled to the device** — done in the same batch as this ADR.
- 🔴 **`026` §12 must be REWRITTEN, not just annotated.** A router rebuilt from the current guide comes back with `mac-winbox=none` — **no recovery path at all** — which is the state this whole session existed to fix. **The guide must produce the router we just built.**
- **Book 10 inherits three items:** discovery scoping, SW01 `port-security`, and a serial console if the appetite returns.

## The pattern

> **A recovery path you have never exercised is a recovery path you do not have.**

**Four documents described MKT01's MAC-connect bootstrap. Not one person had ever tried it. It did not work.**

**We built it, tested it, found it marginal, and wrote down exactly how marginal.** 🔴 **That is worth more than the path itself** — because the next person will read *"connects, drops after ~15 seconds, type fast"* instead of *"the keystone of any recovery,"* **and they will plan accordingly.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-14. Defers the serial console (three adapters bought, three failed), the discovery scoping, and the `ether5`–`ether13` disable. Accepts MAC-WinBox on `bridgeLocal` with its verified 15-second drop. **Records the net increase in physical attack surface explicitly, and why it is accepted.** Unblocks the closure of `CM-0017` and `CM-0018` without ticking a single box that is not true. |
