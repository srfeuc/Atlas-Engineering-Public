---
Title: Playbook — Fix the SW01 Clock (NTP unsynchronized, CM-0030)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — the documented fault is `CM-0030`; the fix + read-backs are 🟡 until run on SW01.
Version: 1.1
Date: 2026-07-31
---

# Playbook — Fix the SW01 Clock

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: problem. **SW01's clock is unsynchronized — `stratum 16`, never synced (`CM-0030`).** A wrong clock breaks log correlation, certificate validation, and Kerberos; NTP is a graded CCNA skill and this is a *real* Atlas fault, not a hypothetical.

## Symptoms / when you'd use this

- `show ntp status` says **`unsynchronized`** (or `%NTP is not enabled`).
- `show clock` is wrong, or shows `.STEP.`.
- Logs carry implausible timestamps.
- A device points at a **stale source** (`10.10.0.5`, a pre-VLAN address that no longer serves time).

## Cert anchor

CCNA 4.0 IP Services (NTP). *(Grounding index: `../Atlas-Certification-Lab-Map.md` §4 — "SW01's broken clock is a real troubleshooting lab.")*

## Grounded in

- **SW01** (Catalyst 2960X, mgmt SVI `Vlan10 10.10.0.2`).
- Time architecture: **`ADR-0020`** — Atlas time is **AD-anchored** (DC01 PDC-emulator `10.20.0.2` is the source), external bridge until the domain serves time.
- The fault + history: **`CM-0030`**.
- Command detail: `../Command-Library/Cisco-IOS.md` §Time (link down — read the runtime, not `show run`, `POL-0001`).

## ① Pin it down (capture these first — they're the ticket)

- a. **The symptom** — `show ntp status` = unsynchronized? `show clock` wrong?
- b. **The source it's trying** — from `show ntp associations` (a stale `10.10.0.5`?).
- c. **The intended source** — DC01 `10.20.0.2` (`ADR-0020`).
- d. **What depends on it** — logs, certificate validation, and Kerberos across the estate share this clock; a wrong clock breaks them silently.

## Diagnosis path

Each step links down to Cisco-IOS §Time; **never invent output** — paste the real read-back.

**1. Confirm it's actually unsynced.**

- Command: `show ntp status`.
- Healthy: `Clock is synchronized, stratum 3, reference 10.20.0.2`.
- Broken: `unsynchronized`, or `%NTP is not enabled`.
- 📸 the `show ntp status` line (before). *(Store in `images/`; no secrets — `POL-0002`/SS-001.)*

**2. See which source it's trying.**

- Command: `show ntp associations`.
- Healthy: `*~10.20.0.2` (the `*` = selected sys.peer, DC01).
- Broken: no `*`; `reach 0` (never heard back); or a **stale** `10.10.0.5`.

**3. Check the clock itself.**

- Command: `show clock`.
- Broken: wrong date / `.STEP.` — confirms it never converged.

**4. Is the *source* even valid?**

- NTP can't sync to a server that isn't serving good time.
- From SW01: `ping 10.20.0.2` — is the intended source reachable?
- On the source: confirm it's a healthy stratum (DC01 PDC-emulator up per `ADR-0020`, or the interim external/FGT01 bridge).
- If the source is down, **that's the real fix** — not SW01.

## The fix

Point SW01 at the correct, valid source and drop the stale one (record against `CM-0030`; configure per `ADR-0020`):

- a. Remove the stale association — `no ntp server 10.10.0.5`.
- b. Set the correct one — `ntp server 10.20.0.2` (add the external bridge only if the domain isn't serving time yet).
- c. Give NTP a source interface if the mgmt plane requires it — `ntp source Vlan10`.
- d. Confirm the mgmt path to the source is permitted (VTY/ACL, E-W matrix).
- Take it from `show ntp status`, not `show run` (`POL-0001`); the exact commands are SW01's to run + read back (🟡).

## Prove it's fixed

- a. Give it a minute to converge.
- b. `show ntp status` = **`Clock is synchronized, stratum 3, reference 10.20.0.2`**.
- c. `show ntp associations` shows `*~10.20.0.2` with a climbing `reach` (`377` = perfect).
- d. `show clock` correct (CST/CDT).
- e. Flip `CM-0030` → resolved, with the pasted evidence.
- f. 📸 the synchronized `show ntp status` (after). Mark ✅ only then.

## If still broken

- Syncs to nothing after the source is confirmed good → an ACL/E-W rule blocking **UDP/123** → `Trace-a-Blocked-Flow.md`; or NTP is administratively disabled.
- The 1941 and other devices share this source, so a source-side fault shows estate-wide (`ADR-0020`).

## Related

- `../Command-Library/Cisco-IOS.md` §Time (`show ntp status`/`associations`/`clock`) · `ADR-0020` (time architecture — the owner) · `CM-0030` (this fault's record) · `SW01-Access-Switch/Diagnostics.md`.
- Sibling: `Test-a-Connection.md` (prove the source is reachable).

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-31 | Reformatted to the `ADR-0053` §5 template — added **① Pin it down**, granular list steps (command / healthy / broken on their own lines), and 📸 capture markers. No method change. |
| 1.0 | 2026-07-31 | Created (`ADR-0053`). A concrete single-device break-fix for the real `CM-0030` SW01 NTP fault — diagnose (`show ntp status`/`associations`/`clock`), verify the *source* is valid (`ADR-0020`), fix (drop stale `10.10.0.5` → DC01 `10.20.0.2`), prove with the runtime read-back. 🟡 pending the on-device run. |
