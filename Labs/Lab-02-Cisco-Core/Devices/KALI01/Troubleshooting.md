---
Title: KALI01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01
Status: 🟢 LIVING — symptom→cause→fix for the offensive host. Seeded from the attacker-host traps; real incidents append.
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → likely cause → fix for the attacker/validation host. Verify commands in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## KALI01 can reach the lab when it shouldn't
- **Symptom:** KALI01 pings/scans a lab VLAN outside a Game Day.
  - **Cause:** 🔴 a **path left open** after a previous test (the biggest attacker-host risk).
  - **Fix:** close the MKT01/FGT rule (or move KALI01 back to VLAN 70); re-verify isolation (`Diagnostics.md` §1). Make "close the path" the last step of every Game Day.

## An attack "succeeds" — did the control fail, or is the test wrong?
- **Symptom:** the attack works; a control looks broken.
  - **Cause:** either a real gap, **or** the test used a path that shouldn't exist / a stale tool giving a false result.
  - **Fix:** confirm the path was the *intended* scoped one; update tools; re-run. A real success = evidence of a gap (fix the control); a test artifact = fix the test.

## A Game Day broke the target
- **Symptom:** a destructive test damaged the test VM.
  - **Cause:** 🔴 no snapshot before a destructive attack.
  - **Fix:** revert the target snapshot; snapshot **before** every destructive Game Day (availability first).

## Stale exploit/rule DB gives false confidence
- **Symptom:** a defence looks strong; the attack was outdated.
  - **Cause:** stale Metasploit/nuclei/Suricata-equivalent DBs.
  - **Fix:** update before the Game Day; record tool versions with the evidence.

## Related
- `Diagnostics.md` · `Considerations.md` · `../../Operations/Validation-and-Adversarial-Testing.md` · `ADR-0011`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Seeded from the attacker-host traps — the path-left-open isolation breach; attack-succeeds (real gap vs test artifact); a destructive Game Day with no target snapshot; stale-DB false confidence. Real incidents append. |
