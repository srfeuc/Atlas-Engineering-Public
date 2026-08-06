# CM-0018 — Build MKT01's Recovery Path on `ether4`, Scope Discovery, and Close the Nine Open Doors

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | ✅ **Closed 2026-07-14 — implemented as decided.** `RECOVERY` list + `mac-winbox` scoping **done and TESTED** (MAC-connect from `ether4` connected). **Discovery scoping and the `ether5`–`ether13` disable were NOT done and are explicitly deferred by `ADR-0016`.** |
| Risk | **Medium.** Touches the management-access path of a router **with no console.** |
| Affected systems | MKT01 — `/interface list`, `/interface ethernet`, `/tool mac-server mac-winbox`, `/ip neighbor discovery-settings` |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — every completed step was read back off the device, and the recovery path was proven by a live MAC-connect, not by reading a setting |
| Blocked by | 🔴 **`ADR-0014`** |
| Related | `CM-0017`, `CM-0015`, `ADR-0013`, `026` §12, `048`, `003` |

> 🔴 **A `Draft` record is a hypothesis, not a work order.** `CM-0011` was executed as a to-do list and degraded a BMC. **Read the device first.**

## Purpose

**This is a BUILD, not a fix. Nothing is broken — the recovery path four documents describe has simply never existed.**

`CM-0017` proved `mac-winbox` has always been `none`: on the live device, in the `2026-07-13` export, and in a live WinBox test returning **`ERR: Could not connect, MacConnection syn timeout`**.

| # | Change | Why |
|---|---|---|
| 1 | `RECOVERY` interface list → `bridgeLocal` | The scope container |
| 2 | `mac-winbox allowed-interface-list` → `RECOVERY` | **Builds a recovery path for the first time** |
| 3 | `mac-server` (MAC-Telnet) → **stays `none`** | Unauthenticated-transport shell. Nothing needs it. |
| 4 | `discover-interface-list` → `RECOVERY` | **Closes the disclosure leak** |
| 5 | 🔴 **Disable `ether5`–`ether13`. Keep `ether4`.** | **Ten live sockets on the core router become one** |

## Why `ether4` only — the physical threat model

**The operator's scenario: the server room is not locked. Anyone can walk in, plug into a port, and try.**

**After step 2, every enabled `bridgeLocal` port answers MAC-WinBox.** With `ether4`–`ether13` all up, that is **ten empty RJ45 sockets on the core router, each one a WinBox login prompt.**

> **Reducing ten doors to one does not lock the room. It removes nine free shots.** An intruder who plugs into `ether5`–`ether13` now gets **nothing at all** — no login prompt, no banner, no link.

### 🔴 Why NOT bind MAC-WinBox to a source MAC address

**Considered and rejected.** RouterOS has no per-source-MAC control for `mac-server` — the control is **per-interface**. And more importantly:

> 🔴 **An attacker standing at the router can set their NIC's MAC to anything. MAC addresses are spoofable in one command.**
>
> **A MAC allow-list here would be a speed bump that looks like a lock — and that is worse than an obvious gap, because you would stop watching the door.** (`016` lesson 4, in a different hat.)

### 🔴 Why at least ONE port must stay enabled

**You cannot disable them all.** If you are locked out, you cannot log in to re-enable one. **`ether4` is the irreducible price of having a recovery path at all.**

**Revisit once MKT01 has a working serial console** (`017`) — at that point even `ether4` could arguably close.

### 🔴 The real control for an unlocked room is on SW01, not here

**`switchport port-security` with `violation shutdown` on SW01's access ports and the `Gi1/0/1` trunk** is the actual answer to *"someone unplugs a device and plugs in their own."*

**You already run a partial version:** SW01's `DHCP Permits: 0` + Dynamic ARP Inspection + the `STATIC-HOSTS` ARP ACL means an unknown MAC on a VLAN 10 access port is **already dropped**.

> **Deferred to the Network Services pack (Book 10) — it is a CCNA topic, it belongs on the switch, and it is not this change.** **Named here so it does not evaporate.**

## There are no unused ports to disable

**Confirmed from `mkt01-pre-CM-0009.rsc`. All thirteen are accounted for:**

| Port | Use |
|---|---|
| `ether1` | Transit to FGT01 (`172.16.0.2/29`) |
| `ether2` | ✅ **Already disabled — `CM-0015`.** *That was the unused port.* |
| `ether3` | Trunk to SW01 (`bridge-trunk`, `hw=no`) |
| `ether4` | 🟢 **Recovery — the only enabled `bridgeLocal` port after this change** |
| `ether5`–`ether13` | 🔴 **To be disabled by this record** |

## 🔴 Before you touch anything

**MKT01 has no console. If you lock yourself out, the recovery is a factory reset of the device that owns every VLAN gateway.**

- [ ] **Keep your current WinBox/SSH session open throughout. It is your rollback.**
- [ ] **Open a second session before starting.**
- [ ] **Back up and export, and pull BOTH files off the router.** A backup on the device you may lock yourself out of is not a backup.
- [ ] **Read and record the current state first** (`/tool mac-server mac-winbox print`, `/ip neighbor discovery-settings print`, `/interface ethernet print`).

## Implementation

**One step at a time. Read back after each. Do not paste the block.**

**Step 1 — Create the `RECOVERY` interface list** containing **`bridgeLocal`** as its only member. Comment it: `MKT01 break-glass. MAC-WinBox + discovery scope. ether4 only. See ADR-0014.` **Read back — expect exactly one member.**

> 🔴 **`bridgeLocal`, not the physical ports.** They are **bridge slaves**; the MAC server binds to the **bridge interface**. **`bridge-trunk` (`ether3`, every VLAN) is a separate bridge and is deliberately excluded. That separation IS the control.** **Step 3 proves which is true — I am not certain, and neither should you be.**

**Step 2 — Set `mac-winbox allowed-interface-list` to `RECOVERY`.** Read it back. **Confirm `/tool mac-server` (MAC-Telnet) is still `none`** — print it, do not assume it.

**Step 3 — 🔴 PROVE IT. This step IS the record.**

**Test A — the path works.** Plug the admin workstation into **`ether4`**. WinBox → Neighbors → **select ONE row** → click the **MAC address** → Connect.

> 🔴 **Select one row, not two.** The failed test on 2026-07-14 had *"2 devices selected"* — both rows were the same router (same MAC; one IPv4, one IPv6 link-local). **A timeout from a malformed multi-target request is not the same evidence as a refusal.**

| Result | Meaning |
|---|---|
| ✅ **Connects** | 🟢 **MKT01 has a working recovery path for the first time in its life.** |
| 🔴 **`MacConnection syn timeout`** | The list is wrong — the MAC server likely needs the **physical port**. Add `ether4` to `RECOVERY` directly and re-test. **Do not proceed until a MAC-connect SUCCEEDS.** |

**Test B — the exposure is closed.** From a **VLAN** host: WinBox → Neighbors → attempt MAC connect.

| Result | Meaning |
|---|---|
| ✅ **Refused** | Correct. No L2 path from the VLANs to `bridgeLocal`. |
| 🔴 **Connects** | 🔴 **STOP.** Set `mac-winbox` to `none` and re-open `ADR-0014`. |

**Step 4 — Set `discover-interface-list` to `RECOVERY`.** Read it back.

**Then verify from a VLAN host:** WinBox → Neighbors. 🔴 **MKT01 must NO LONGER APPEAR** — no identity, no `7.23.1`, no `RB1100Dx4`, no uptime, no `vlan10-mgmt`.

> **Accepted cost:** CDP/LLDP visibility to SW01 on the trunk is lost. **Cosmetic today — no monitoring host exists.** 🔴 **Book 10 will need to revisit this** — CDP/LLDP are CCNA syllabus. `ADR-0014` records it.

**Step 5 — Disable `ether5`–`ether13`.** Comment each: `Disabled CM-0018 - bridgeLocal recovery is ether4 only`.

🔴 **`ether4` stays ENABLED. Do not disable it. It is the only way back in.**

**Read back:** `/interface ethernet print` — expect `X` on `ether2` (from `CM-0015`) and on `ether5`–`ether13`. **`ether1`, `ether3`, `ether4` enabled.**

> 🔴 **RouterOS prints only the flags in use.** Confirm the `X` legend is present and the count is right — **nine newly disabled, plus `ether2` = ten.**

**Step 6 — Re-run Test A on `ether4`** after the port changes. **Then** save and export, and pull both files off the device.

## Rollback

**Re-enable `ether5`–`ether13`, set `mac-winbox` to `none`, set discovery to `static`, remove the `RECOVERY` list.** Returns the device to its current state.

**IP WinBox on `10.10.0.1` is unaffected by every command in this record and remains your working path throughout.**

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| 🔴 **`026` §12** | **MUST REWRITE at closeout** | Replace `mac-winbox=none` and `discovery=static` with the `RECOVERY` list, **and state WHY.** **Keep `mac-server=none`.** Add the `ether5`–`ether13` disable. **An unexplained hardening line is how this survived.** ⚠️ **Warning block added 2026-07-14; the rewrite waits for the read-back, because a Build Guide must not describe a device that does not exist.** |
| ✅ **`048`** | **Updated 2026-07-14** | Bootstrap table now says **MKT01 has NO path**, with the `syn timeout` evidence. Will change to *"`ether4` only"* at closeout. |
| ✅ **`003`** | **Updated 2026-07-14** | Same. Plus: **MKT01 has no console.** |
| 🔴 **`016`** | **Must update at closeout** | New lesson: **MAC-WinBox bypasses every IP control on the router**, and **discovery ≠ access**. |
| 🔴 **`022`** | **Must update at closeout** | Record `mac-winbox: RECOVERY`, `mac-server: none`, `discovery: RECOVERY`, and **`ether5`–`ether13` disabled** as verified state. |
| `ADR-0013` | **Reinforced** | **`bridgeLocal` is now load-bearing twice** — the recovery network, **and** the only segment MAC-WinBox answers on. |
| 🔴 **Book 10 (new)** | **Deferred, named** | **SW01 `port-security` — the real answer to the unlocked-room threat.** |

## Closeout

- [ ] `ADR-0014` **Accepted**
- [x] Backup + export taken
- [x] ✅ Current state recorded **before** any change — the step `CM-0017` v1.0 skipped
- [x] ✅ `RECOVERY` list created — **read back: one member, `bridgeLocal`**
- [x] ✅ `mac-winbox = RECOVERY` — read back
- [x] ✅ MAC-Telnet confirmed still `none` — **read, not assumed**
- [x] 🟢 **Test A — MAC-connect from `ether4`: CONNECTED.** Three read-only commands returned over the MAC session. 🔴 **Dropped after ~15s. Accepted (`ADR-0016`).**
- [ ] 🔴 **Test B — NOT PERFORMED. Deferred (`ADR-0016`).** *`bridge-trunk` and `bridgeLocal` are separate bridges, so VLAN hosts should have no L2 path — **but that is reasoning, not a test, and this record will not claim otherwise.***
- [ ] 🔴 **NOT DONE — deferred (`ADR-0016`).** `discovery` remains `static`. **The version/board disclosure to every VLAN is OPEN.**
- [ ] 🔴 **NOT DONE — deferred (`ADR-0016`).**
- [ ] 🔴 **NOT DONE — deferred (`ADR-0016`).** **All ten `bridgeLocal` ports remain enabled — a deliberate, recorded decision.**
- [x] **N/A** — no port changes were made
- [x] Saved and exported
- [x] ✅ **Guide reconciliation complete** — `026` §12 **REWRITTEN with rationale**; `022` records the real state; `003`, `048`, `016` corrected.
- [x] ✅ `CM-0017` closed
- [x] ✅ SW01 `port-security` raised in Book 10 (`ADR-0015`, `ADR-0016`) — **the real control for the unlocked-room threat**
- [x] ✅ **Closed 2026-07-14**

> ✅ **Four boxes remain unticked, and this record is Closed anyway — because every one of them is explicitly deferred by an accepted ADR (`ADR-0016`), which is exactly what the Charter's pack lifecycle provides for.**
>
> 🔴 **Nothing was ticked that is not true. That is the difference between this record and `CM-0009`** — which was marked *"Closed — implemented and verified"* with two boxes silently unticked, and left a Build Record describing a firewall that no longer existed.
>
> **A deferral you wrote down is engineering. A tick you did not earn is a lie.**

## Note

> **Seeing a device in a discovery list is not access. Being able to click Connect is not access. Not being asked for a password is not access.**
>
> **Access is a session. Everything else is the door being visible.**

**WinBox never asked for a password because it never got far enough to ask.** The connection died at the MAC layer before authentication could exist. **That is the fourth time in this session a quiet, expected result was read as a meaningful one** — cipher 0 against a closed channel, `INACTIVE` on the `bridgeLocal` ports, a desktop search against the wrong folder, and now `syn timeout` read as a lockout.

**Every single time, the device was already telling the truth.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Drafted as remediation for an accidental disable. |
| 2.0 | Reframed as a **BUILD** — `CM-0017` proved nothing was ever broken. |
| **3.0** | 🔴 **2026-07-14.** Added **step 5: disable `ether5`–`ether13`, keep `ether4`** — ten live sockets on the core router in an unlocked room become one. Recorded **why source-MAC binding was rejected** (spoofable in one command; a speed bump that looks like a lock). Recorded **why one port must stay enabled** (you cannot re-enable a port you cannot log in to). **Confirmed there are no other unused ports — `CM-0015` already handled `ether2`.** Named **SW01 `port-security`** as the real control, deferred to Book 10. |
| **4.0** | ✅ **CLOSED 2026-07-14.** `RECOVERY` list + `mac-winbox` scoping implemented and **proven by a live MAC-connect from `ether4`** — MKT01 has a working break-glass path **for the first time in its existence**, with a verified ~15-second drop. **Discovery scoping, the `ether5`–`ether13` disable, and Test B were NOT done and are deferred by `ADR-0016`.** `026` §12 rewritten so a rebuilt router comes back with a recovery path instead of none. |
