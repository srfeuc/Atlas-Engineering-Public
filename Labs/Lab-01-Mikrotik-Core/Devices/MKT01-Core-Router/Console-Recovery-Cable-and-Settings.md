---
Title: MKT01 Console Recovery — Cable & Terminal Settings
Path: Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router
Status: Reference — closes the ADR-0016 out-of-band console gap. Port gender VERIFIED FEMALE 2026-07-20; cable spec updated to a male end. Facts from MikroTik official docs.
Version: 1.1
Date: 2026-07-20
---

# MKT01 Console Recovery — Cable & Settings

> **Why this exists.** `ADR-0016` deferred MKT01's out-of-band console; the Build-Record records **no serial console** and MAC-WinBox that **drops after ~15s** — the only Atlas device with no path that survives a RouterOS that won't boot. `ADR-0023` makes this a **hard prerequisite** before MKT01 becomes the policy-critical east-west firewall (a default-deny box with no console is one bad rule from total lockout). Three previously-purchased adapters failed — **counterfeit Prolific PL2303 chips** (`Atlas-Certification-Lab-Map` §4b). This note is the known-good spec.

## The port (verified — MikroTik official + physical check)

- MKT01 = **RB1100AHx4**, which has a **DB9 RS232C asynchronous serial port**.
- RouterBOARD console settings: **115200 baud, 8 data bits, no parity, 1 stop bit**. The RB1100 runs reliably at **115200** (unlike the RB1200, which needs 9600).
- It is a **DTE** port → connecting to a PC (also DTE) requires a **null-modem (crossover)** cable. A straight-through serial cable will not work.
- **Flow control: NONE.** RouterBOARDs do not implement hardware flow control; leaving RTS/CTS on in the terminal is the classic "connected but blank screen" cause.

## ✅ Gender — RESOLVED (2026-07-20)

Physical check on this unit: the DB9 console port is **female (holes)**. (This is the non-standard case — the DTE default is male; this specific RB1100AHx4 is female.) **Therefore the cable's router-facing end must be DB9 male.** This closes the last open verify on `ADR-0016` (audit item #6).

## The cable — genuine FTDI, null-modem, MALE router end

Because the port is **female** and null-modem-wired FTDI adapters are almost all **female-ended**, the reliable build is two pieces:

**Recommended (Option 1):**
1. **StarTech ICUSB232FTN** — USB → **genuine FTDI** chip → wired as a **null modem** → DB9 **female** (DCE). Genuine FTDI is the fix for the counterfeit-Prolific failures.
2. **+ a DB9 male-to-male, straight-through gender changer** (a plain coupler) to present a **male** end that mates the router's female port.

> ⚠️ The gender changer MUST be **straight-through (pin-to-pin)**, **NOT** a "null-modem gender changer." A crossover coupler stacked on the already-crossover ICUSB232FTN cancels the null-modem and you get a dead session.

**Alternative (Option 2, single-vendor):** a genuine-FTDI USB-to-DB9-**male** straight adapter (FTDI **UC232R-10**) **+ a DB9 null-modem adapter with a male router end** (M/F null-modem: its female mates the UC232R, its male mates the router). Straight adapter + null-modem adapter = one crossover overall, ending male.

Buy through a reputable channel (StarTech / CDW / RS / FTDI direct) — budget "FTDI"/serial marketplace listings are sometimes counterfeit too.

## 🔴 Do NOT use the on-hand cables

The two **CableCreation USB-to-RS232, PL2303 chipset, DB9 female** adapters already in the lab are **not suitable for MKT01**, for two reasons:
1. **PL2303 is the exact chipset family that failed three times here** (counterfeit-detection + Prolific's modern-Windows driver "Code 10" issues). Buying past that failure mode is the whole point of this spec — don't reintroduce it.
2. **Wrong physical fit anyway:** they are DB9 **female** (won't mate the female router port without a coupler) and **straight-through DTE** (no null-modem crossover). Making them work would mean stacking a null-modem adapter *and* a gender coupler onto the risky chip — more parts, same failure mode.

Keep them for a genuine straight-through DCE use; for MKT01 recovery, use the genuine-FTDI build above.

## Terminal settings

```
Speed (baud): 115200
Data bits:    8
Parity:       None
Stop bits:    1
Flow control: None        <-- not Hardware; this is the usual "no output" cause
```

## Pre-flight (so it works first try)

- [ ] **Open the terminal session BEFORE powering/rebooting** the router, so you catch the RouterBOOT output.
- [ ] Confirm **`serial0` isn't reassigned** — `/port print`. On the RB1100AH it has been found bound to `remote-access` instead of console; free it for the console.
- [ ] Gender confirmed **female → male cable end** (done 2026-07-20); straight-through coupler in hand (not null-modem).
- [ ] Test the full path **now, while the box is healthy** — a recovery cable proven only during an outage is a hope, not a control (`ADR-0011`). Log in over console, run one command, confirm output.

## Closes / relates

- **`ADR-0016`** (MKT01 console recovery deferred) — gender check now resolved (female); execution + a live test is the remaining Change Record.
- **`ADR-0023`** — gates MKT01's default-deny east-west policy on this recovery path existing and tested.
- `Atlas-Certification-Lab-Map` §4b (the FTDI/counterfeit-Prolific finding) · `048` Teardown (bootstrap access) · Build-Record §Layer-2 Management State (the 15-second MAC-WinBox limit).

## Sources (official)

- MikroTik Serial Console (RouterOS docs) — settings, null-modem requirement.
- MikroTik RB1100-series user manual — DB9 RS232C, 115200 8N1.
- MikroTik community: RB1100AH console (flow control none; serial0/remote-access reassignment).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First spec — closes ADR-0016 out-of-band gap; genuine-FTDI null-modem cable, 115200 8N1 flow-none. Gender left as the one open physical check. |
| 1.1 | 2026-07-20. Gender verified **female** on the physical unit → cable end must be **male**. Recommendation updated to ICUSB232FTN + straight-through M/M gender changer (Option 1), with UC232R + M/F null-modem as the single-vendor alternative. Added the crossover-cancellation warning. Recorded that the on-hand CableCreation PL2303 female adapters are unsuitable (chipset failure mode + wrong gender/wiring). Closes audit item #6. |
