# CM-0012 — PVE01 CMOS Battery Failing: BMC Settings Non-Durable, Default Credentials Exposed

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PVE01 - Role: Hypervisor

| Item | Value |
|---|---|
| Status | **Open — battery replaced 2026-07-16, durability RE-TEST FAILED; battery-vs-board unresolved** |
| Risk | **Low → conditional.** 🔴 **Corrected 2026-07-13 (was High).** No remote BMC path exists today (IPMI-over-LAN disabled, web UI unreachable). The battery is the real issue: a power-loss reset could *create* an exposure that does not currently exist. |
| Affected systems | PVE01 (host hardware, iDRAC/BMC, BIOS) |
| Date raised | 2026-07-13 |
| Evidence Status | **`Verified`** — `ipmitool` output, `ip a`, and direct operator confirmation |
| Blocks | `CM-0011` (iDRAC hardening), the iDRAC dedicated-NIC move, and any BIOS-level change |

> 🔴 **Corrected 2026-07-13.** This record originally reframed `CM-0011`'s findings as "possibly wiped by the dead battery." **On the device, that guess was wrong in both directions:** `CM-0011`'s findings were not *wiped* hardening — they were **never-real findings** (cipher 0 was already `XXXa`; auth `NONE` was a capability-list misread; IPMI-over-LAN is disabled so nothing was ever reachable). **There was no hardening to wipe, because there was no exposure and no onboarding.**
>
> **The battery instinct — "fix the hardware before you trust any setting" — was still right.** It just got the right answer from the wrong evidence. That distinction is preserved below rather than silently corrected.

## Purpose

Record three linked facts about PVE01, establish their dependency order, and capture the **proven-good state of the cipher-0 fix before a power cycle** so the battery replacement can be tested as a real before/after rather than from memory.

## The three findings

### 🔴 1. The CMOS battery is failing

Operator-confirmed. On a Dell R410, a dead CMOS battery means **BIOS and iDRAC settings can reset to factory default on any full power loss.**

**This is a candidate root cause for multiple previously-unexplained items:**

| Symptom | How a dead CMOS battery explains it |
|---|---|
| iDRAC found at cipher 0 / auth NONE / SNMP `public` — all factory defaults | The hardening may have existed and been **wiped by a power event**, not never applied |
| Uncertainty whether iDRAC's IP `10.10.0.100` survives a reboot | With no battery, the static assignment may not persist |
| **Pi01's unexplained hard hang** (open across three handoffs) | Failing power/board hardware produces exactly this "no root cause found" class of instability. **Candidate, not conclusion** — Pi01 is a separate device; but worth noting the lab has one confirmed failing power component. |

### 🔴 2. iDRAC credential — status UNKNOWN and currently UNTESTABLE (corrected 2026-07-13)

**This section originally stated "no password was ever set — likely factory `root`/`calvin`, a larger exposure than cipher 0." The device contradicts both halves.**

`ipmitool user list 1` on PVE01:

```
ID  Name    Callin  Link Auth  IPMI Msg   Channel Priv Limit
2   root    true    true       true       ADMINISTRATOR
```

**User 2 (`root`) is an enabled ADMINISTRATOR with IPMI messaging configured.** But:

| Claim | Test | Result |
|---|---|---|
| "likely `root`/`calvin`" | `-C 3 -U root -P calvin` | ❌ **Rejected** |
| "no password ever set" | `-C 3 -U root -P ''` | ❌ **Rejected** |
| Any remote credential test | — | 🔴 **Meaningless** — IPMI-over-LAN is disabled, web UI unreachable |

> 🔴 **The credential is UNKNOWN, not "default," and it is currently UNTESTABLE** — there is no reachable path (IPMI-over-LAN off, web UI down) to authenticate against. `calvin` was never actually *rejected*; it was never *evaluated*, because the channel is closed.
>
> **"Operator-confirmed: no password was ever set" is an operator recollection that the device does not support** — `calvin` and blank both fail, which means *something* is set, or the account is unreachable, or both. **We do not know, and we cannot find out until the BMC has a working path.**
>
> **Net today:** an enabled ADMIN account with an unknown password on a controller with **no reachable remote path.** That is *unmanaged*, not *exposed*. It becomes exposed the moment a path is opened — which is exactly what a factory reset (dead battery) would do.

### 🔴 3. Cipher 0 — the "proof" here is VOID (corrected 2026-07-13)

**This section originally claimed cipher 0 was "proven closed by the exploit failing." That proof is invalid.**

The device's cipher string is `XXXaXXXXXXXXXXX` (suites 0/1/2 unused, only suite 3 at admin) — **and that is fine.** But the *proof* offered for it was the exploit failing:

```bash
ipmitool -I lanplus -H 10.10.0.100 -C 0 -U root -P "" chassis status
# -> Error: Unable to establish IPMI v2 / RMCP+ session
```

> 🔴 **`ipmitool channel info 1` shows `Access Mode : disabled` — IPMI-over-LAN is OFF, and off in Non-Volatile settings too. It was never enabled.**
>
> **So this exploit would have failed identically with cipher 0 wide open at ADMIN** — the RMCP+ session dies at a *disabled channel*, before any cipher is evaluated. **The test cannot distinguish "cipher 0 disabled" from "the port was never open." The control was never established.**
>
> **This is the same failure the entire pack catalogues:** an expected result (`Unable to establish session`) appeared, and it was read as proof of the change — when the change had nothing to do with it. A negative result from an unestablished control proves nothing.

**The correct statement:** the cipher string reads `XXXa` locally (device-confirmed over KCS), which is the hardened value. **But no remote exploit was ever possible to begin with**, so "proven by the exploit failing" is deleted. The `XXXa` value remains a useful **before/after control sample for the battery test** — that part stands.

## Network facts recorded (from `ip a`, 2026-07-13)

```
eno1   00:00:5e:3f:f6:a2   -> vmbr0, 10.10.0.10/24  (host data)
eno2   00:00:5e:3f:f6:a3   DOWN
iDRAC  00:00:5e:3f:f6:a4   (shared LOM, 10.10.0.100)
```

Three **sequential** MACs on one NIC card. iDRAC's `...a4` is its own address on the shared LOM — it rides `eno1`'s cable and switch port `Gi1/0/4`. **This confirms `003-Physical-Topology.md`'s "dedicated physical NIC" claim is wrong** and that there is no separate iDRAC cable in the current cabling. (The R410 *has* an unused dedicated iDRAC port; moving to it is the separate NIC-move change.)

## Remediation — in dependency order

**Do NOT reorder. Each step depends on the one before.**

### Step 1 — Replace the CMOS battery

- Part: **CR2032** 3V lithium coin cell (standard; any brand). Confirmed correct for the R410.
- On the R410 the cell can sit partly under a riser/shroud — allow a few minutes and a screwdriver, not thirty seconds.

> 🟡 **Done 2026-07-16 — but see Step 2: the swap did NOT fix it.** A new CR2032 was installed, and the holder clip was reseated after the first failure. The RTC still does not hold.

### Step 2 — Full power cycle, then re-test (THE experiment)

**Pull power completely — not a warm reboot.** A warm reboot does not exercise the thing a dead battery breaks.

```bash
# From Pi01, after the box is back up:
ipmitool -I lanplus -H 10.10.0.100 -C 0 -U root -P "" chassis status   # must still be REJECTED
ssh dnsadmin@10.10.0.5   # then, from PVE01 host:
ipmitool lan print 1 | grep -E "Cipher Suite Priv Max|IP Address|SNMP Community"
```

| Result | Verdict |
|---|---|
| Cipher string still `XXXa...`, IP still `10.10.0.100`, IPMI-over-LAN still **disabled** | ✅ **Board holds config across a full power loss.** Proceed to onboard the iDRAC (below). |
| Cipher string back to `aaaa...`, IPMI-over-LAN **enabled**, or IP changed | ❌ **The board does not hold config.** 🔴 **This is the real danger:** a reset re-enables IPMI-over-LAN and restores factory defaults — turning today's *unmanaged* BMC into an *exposed* one (cipher 0 at ADMIN, `root`/`calvin` live). **Do not build anything on this board until it holds.** |

> 🔴 **RESULT — 2026-07-16: the board does NOT hold the clock. The iDRAC DID hold. Two separate findings — don't conflate them.**
>
> - **RTC / CMOS: FAIL.** With the new CR2032 (and a reseated holder clip), the RTC resets `2026`→`2018-05-30` on every power cycle. `hwclock --systohc` writes `2026`, `hwclock --show` confirms it, then `dmesg` after the next boot reads `PM: RTC time: … date: 2018-05-30`. Tested twice. **A battery swap has not fixed it.**
> - **iDRAC / BMC: HELD.** Across the same cycles `ipmitool lan print 1` still shows cipher `XXXa`, IP `10.10.0.100`, IPMI-over-LAN `disabled`. The iDRAC stores config in its **own NVRAM, not the CMOS**, so this is *not* evidence about RTC durability either way. (The admin password was changed at the console 2026-07-16 and held.)
>
> 🔴 **So the exposure this record feared — a factory reset re-enabling IPMI-over-LAN — did NOT happen; the iDRAC held.** But the clock durability the onboarding depends on is **disproven for the battery alone.** **Next step: measure the cell** (bare ≥ 3.0 V; ~3 V seated, server unplugged) to split **weak/poorly-seated cell** (fixable) from a **failed RTC circuit on the board** (not fixable — the R410 is ~2010-era). If a known-good, well-seated cell still won't hold, the realistic paths are **UPS-and-accept** (NTP holds the OS clock while powered) or **retire the board**. Until a boot RTC reads `2026`, `050` stays blocked and this record stays **Open**.

### Step 3 — Onboard the iDRAC (only after the board is proven durable)

🔴 **The iDRAC was never onboarded** — it has an IP and nothing else: no Lab CA certificate, no named admin account, no Vaultwarden entry, no build-guide section, IPMI-over-LAN disabled, on the shared LOM rather than the dedicated port. **This is a build, not a fix**, and it is tracked as its own iDRAC onboarding build guide. In dependency order:

- **Move iDRAC to the dedicated NIC** (same chassis-open as the battery — do it in one visit). Makes it genuinely out-of-band instead of dying with SW01.
- **Set a password** — generate in Vaultwarden, **≤ 20 characters** (`ipmitool` rejected a >20-byte password this session — a real IPMI 2.0 client constraint). Store as `PVE01 - iDRAC - BMC Admin` per `044`.
- **Enable IPMI-over-LAN and/or the web UI deliberately**, with a Lab CA certificate — the iDRAC is the only management interface in Atlas outside the PKI.
- **Verify remotely** with an authenticated cipher-3 session returning `System Power: on`. 🔴 **This verification is impossible today** (no reachable path) — which is exactly why setting a password *before* onboarding would be writing a credential you cannot prove works.

### Step 4 — Confirm the onboarding held

After onboarding on a durable board, re-verify remotely: authenticated cipher-3 session works, Lab CA certificate serves on the web UI, credential is in Vaultwarden.

> 🔴 **`CM-0011` is CLOSED as substantially false** — its findings did not survive contact with the device (IPMI-over-LAN disabled; cipher 0 already `XXXa`; auth `NONE` a misread). **Do not treat it as the hardening to-do list.** The onboarding build above replaces it.

## Documentation updates

- [ ] `201-Dell-PowerEdge-R410-Preparation.md` — add: **CMOS battery health check**, **set an iDRAC password (≤20 chars)**, and **BMC hardening**. None are currently in the hardware-prep guide.
- [ ] `003-Physical-Topology.md` — correct the "dedicated NIC" claim; record iDRAC on shared LOM via `Gi1/0/4`.
- [ ] `024-PVE01-Network-Build-Record.md` — record iDRAC network + credential + battery state.
- [ ] Pi01 hard-hang open item — add "PVE01 CMOS battery failing" as a **candidate** cross-reference, not a conclusion.
- [ ] `sudo` is **not installed** on PVE01 (root-only login). Every Proxmox guide that prefixes commands with `sudo` will fail as written. Reconcile.

## Guide Reconciliation — required, not conditional

| Guide | Outcome | Detail |
|---|---|---|
| `201-Dell-PowerEdge-R410-Preparation.md` | 🔴 **Must update** | Prepares the R410 with **no CMOS check, no iDRAC password, no BMC hardening.** A rebuild from it produces this exact exposed, non-durable state. |
| `202-Install-Proxmox-VE.md` | 🔴 **Must update** | Written with `sudo` throughout; PVE01 has no `sudo`. Commands fail as written. |
| `048-Teardown-and-Rebuild-Runbook.md` | 🔴 **Must update** | Phase 1 lists iDRAC as PVE01's bootstrap path. **A BMC with default creds and volatile settings is not a reliable recovery path.** Overlaps `CM-0011`. |

## Note

**Cipher 0 was hardened tonight, and it is the right kind of proof — the exploit failing, from a second host.** But the CMOS finding turns that from a closed item into a *control sample.* 

**That is the correct outcome, not a setback.** The value of tonight's cipher-0 work is no longer "the BMC is hardened" — it is **"we now have a known-good, timestamped state to test the battery against."** Without it, the power-cycle experiment in Step 2 would have nothing to measure.

**The honest order is: fix the battery, prove it holds, set a password, then harden.** Anything else is writing settings onto a surface that erases them.

## Change Log

| Version | Changes |
|---|---|
| **3.0** | 🔴 **2026-07-16 — battery replaced, durability RE-TEST FAILED.** New CR2032 installed (holder clip reseated after the first failure); the RTC still resets `2026`→`2018` across a power cycle, tested twice. **The iDRAC held** (cipher `XXXa`, IP `.100`, IPMI disabled — its own NVRAM) and its **admin password was changed at the console** — so the feared IPMI-reset exposure did not occur, but the clock durability the onboarding depends on is disproven *for the battery alone.* Battery-vs-board split pending a voltage check. **`050` stays blocked; record stays Open.** Also reconciled into `024`/`028`/`036`/`060`/`061`. |
| **2.0** | 🔴 **Corrected 2026-07-13. Risk High -> Low/conditional.** Device testing voided this record's two headline claims: (1) the cipher-0 "proof" is invalid -- `Access Mode : disabled` means IPMI-over-LAN was never on, so the exploit failed at a closed channel, not a closed cipher; (2) the credential is UNKNOWN and untestable, not confirmed-default -- `root`/`calvin` and blank both rejected, but via a disabled channel, so nothing was actually evaluated. The BMC is **unmanaged, not exposed** today. The battery instinct was right for the wrong reasons and is preserved. Real work reframed as **iDRAC onboarding (a build, not a fix)**. `CM-0011` closed as substantially false. |
| 1.0 | Raised 2026-07-13. CMOS battery failing (operator-confirmed) → BMC/BIOS settings non-durable across power loss, a candidate root cause for the factory-default iDRAC state and possibly the Pi01 hang. iDRAC has **no password** (operator-confirmed) → likely default `root`/`calvin`, a high exposure. Cipher 0 disabled and **proven closed** this session, but flagged **provisional** pending the post-battery power-cycle test. Dependency order established: battery → power-cycle test → password → hardening. |
