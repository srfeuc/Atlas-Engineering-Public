# ADR-0014 — MKT01 Layer-2 Management Posture: MAC-WinBox, MAC-Telnet, Neighbor Discovery, and the Missing Console

| Item | Value |
|---|---|
| Status | ✅ **ACCEPTED — operator, 2026-07-14.** Option C: MAC-WinBox scoped to `bridgeLocal`; MAC-Telnet stays `none`; neighbour discovery scoped with it; **`ether4` is the sole enabled recovery port, `ether5`–`ether13` disabled.** Executed by `CM-0018`. |
| Governing Policy | POL-0007 (+POL-0009) |
| Scope | **Lab-01-Mikrotik-Core** |
| Date | 2026-07-14 |
| Related | `CM-0017`, `CM-0018`, `026-MKT01-Build-Guide.md`, `048-Teardown-and-Rebuild-Runbook.md`, `003-Physical-Topology.md`, `016`, `ADR-0011`, `ADR-0013` |
| Evidence Status | **`Verified`** — live device output, live MAC-connect test, and `mkt01-pre-CM-0009.rsc` (2026-07-13 16:06) |
| Supersedes | `026-MKT01-Build-Guide.md` §12 |

> **v1.0 of this ADR was built on a false premise** — that MAC-WinBox had been enabled and was accidentally turned off. **The export proves it was `none` all along.** The premise is corrected; **the decision it demands is unchanged, and more urgent than v1.0 realised.**

## The actual situation

**MKT01's documented recovery path does not exist and never has.**

`mac-winbox allowed-interface-list=none` — confirmed on the live device **and** in an export predating the investigation. **MAC-connect has been refused this entire time.**

Meanwhile, **four documents say otherwise:**

| Document | Claim |
|---|---|
| `003-Physical-Topology.md` | MKT01's **only** bootstrap method. *"The keystone of any recovery."* |
| `048-Teardown-and-Rebuild-Runbook.md` | *"Your **single most important bootstrap tool**."* |
| `026-MKT01-Build-Guide.md` line 73 | *"Stay connected via **MAC address**… IP access will be interrupted."* |
| `026-MKT01-Build-Guide.md` **§12** | 🔴 `mac-winbox allowed-interface-list=none` — **turns it off** |

> 🔴 **`026` builds a router that `048` cannot bootstrap, and `026` contradicts itself to do it.**
>
> **This has been true since both were written. It was never found because nobody has ever rebuilt** — the exact claim `ADR-0011` exists to test.

## 🔴 And MKT01 has no console

| Device | Out-of-band |
|---|---|
| SW01 | ✅ Serial, 9600 8N1 |
| FGT01 | ✅ Serial **+** `192.168.1.99` fallback |
| PVE01 | ✅ Physical console |
| 🔴 **MKT01** | 🔴 **None. Not documented anywhere.** |

**So today the core router of the lab — owner of every VLAN gateway — has exactly one management path: IP WinBox/SSH from VLAN 10 or `bridgeLocal`. If its addressing breaks, the recovery is a factory reset.**

## Why MAC-WinBox is a security question at all

**MAC-WinBox is Layer 2. It obeys none of this router's IP controls.**

**Not** `/ip service set winbox address=10.0.0.0/24,10.10.0.0/24`. **Not** the input-chain default deny. **It is not IP traffic, so the IP firewall never evaluates it.** Its only control is `/tool mac-server mac-winbox allowed-interface-list`.

> **Every management restriction on MKT01 operates at Layer 3. MAC-WinBox operates below all of them.** The hardening is real, careful, and simply **does not apply to this protocol.**
>
> **So the interface list is not a convenience setting. It IS the access control** — the entire one.

**This is why the answer cannot be "just turn it back on."**

## Options

### Option A — `allowed-interface-list=all`

| | |
|---|---|
| Recovery | ✅ From anywhere with L2 adjacency |
| Exposure | 🔴 **Any host on VLAN 20, 30, 50, 60, 80 reaches the WinBox login prompt.** IP restrictions bypassed entirely. |
| Verdict | 🔴 **Reject.** Trades a real, network-wide exposure for a convenience. **The only remaining control would be the password.** |

> **Note:** VLAN 70's isolation is an **IP-forwarding** control (exclusion from the `VLANs` list). **It would not stop MAC-WinBox.** The isolation people trust is not the isolation that would apply.

### Option B — `allowed-interface-list=none` (the current state)

| | |
|---|---|
| Exposure | ✅ Closed |
| Recovery | 🔴 **None. And there is no console.** |
| Verdict | 🔴 **Reject as it stands.** Defensible **only** once a tested serial console exists. **Security that removes your last recovery path is a bet that nothing will break.** |

### 🟢 Option C — scoped to `bridgeLocal` (RECOMMENDED)

**MAC-WinBox answers only on `bridgeLocal` — the recovery ports `ether4`–`ether13`.**

**`bridge-trunk` (`ether3`, all VLANs) and `bridgeLocal` are separate bridges.** The separation is clean, not partial.

| | |
|---|---|
| Recovery | ✅ **Works — with a physical cable in `ether4`–`ether13`** |
| Exposure | ✅ **A host on any VLAN has no L2 adjacency to `bridgeLocal`. It gets nothing.** |
| Cost | You must be at the router. |
| Verdict | 🟢 **Accept.** |

> **Requiring physical presence for break-glass is not a burden. It is the control.** A recovery scenario already has you standing at the device. **"Anyone on the network" becomes "anyone in the room."**

**MAC-Telnet (`/tool mac-server`) stays `none` under every option** — an unauthenticated-transport shell that nothing in Atlas needs.

## Decision

**Option C. ✅ ACCEPTED 2026-07-14.**

**Neighbor discovery is scoped in the same change** (operator direction, 2026-07-14): `discover-interface-list` moves from `static` — **every static interface, VLANs included** — to the same `RECOVERY` list.

**The router currently broadcasts its identity, RouterOS version, board model and uptime to VLAN 50 and VLAN 20, and then refuses the connection. We have the disclosure without the capability.**

**Accepted cost:** CDP/LLDP visibility to SW01 on the trunk is lost. **Cosmetic today — no monitoring host exists.** 🔴 **Revisit deliberately when the Network Services pack deploys CDP/LLDP and a collector** — this ADR will be the thing that has to change.

## 🔴 Independent requirement — MKT01 needs a console

**Whatever is decided above, wire and test the RB1100's physical console port, and add it to `003`'s bootstrap table.**

**MAC-WinBox is a Layer-2 path — it still requires RouterOS booted and its bridge functional.** A console does not. **MKT01 is the only Atlas device with no path that survives a broken RouterOS.** Raised in `017-Future-Expansion.md`.

## Consequences

- **`026` §12 is superseded** and must be rewritten **with a rationale.** An unexplained hardening line is how this survived: three commands, no reason, no validation, no acknowledgement that they contradict two other documents.
- **`048`, `003`, `016` become true again** — with the physical-port qualification stated.
- **`022` must record `mac-server` state** — and the **64 GB SSD**, which appears in no document in the repository.
- **This ADR must be revisited by the Network Services pack.** CDP/LLDP are on the CCNA syllabus and on the roadmap; **scoping discovery to `RECOVERY` today is correct and will need a deliberate reversal later.** Better a decision that gets revisited than a default nobody chose.

## The pattern

> **A control that bypasses your controls is not a gap in the policy. It is a second policy that nobody wrote down.**

**And a recovery path that four documents describe, which has never worked, is not a recovery path. It is a belief.**

> **`016` lesson 4: a test that cannot fail proves nothing.** **Corollary, established here: a recovery path you have never exercised is a recovery path you do not have.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-14 on the false premise that MAC-WinBox had been accidentally disabled. |
| **2.0** | 🔴 **Premise corrected.** `mkt01-pre-CM-0009.rsc` proves `mac-winbox=none` predates the investigation — **MAC-connect has never worked.** Option A therefore describes a state that never existed. **The decision is unchanged and more urgent:** four documents describe a recovery path that does not exist, `026` builds a router `048` cannot bootstrap, and **MKT01 has no console.** Added the requirement that the Network Services pack must revisit the discovery scoping. |
| **2.1** | ✅ **ACCEPTED 2026-07-14.** Option C adopted. **`ether4` designated the sole enabled `bridgeLocal` port** — ten live sockets on the core router in an unlocked room become one. `CM-0018` is released from Draft and is now a work order. |
