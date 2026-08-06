---
Title: KALI01 — Considerations (the controlled-attack model + risks)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01
Status: 🟠 PROPOSED — the controlled-attack model + the risks a live attacker box carries. Nothing built.
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Considerations (controlled-attack model + risks)

> The "what could bite us" list for the attacker host — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`). Facts linked to owners (`POL-0008`).

## The controlled-attack model (the load-bearing design)
- 🔴 **Isolated by default (VLAN 70).** KALI01 has **no standing lab access** — VLAN 70 is internet-only (already enforced). This is deliberate: a free-roaming attacker box would undercut the segmentation it exists to test.
- 🔴 **Attack paths are opened per Game Day, then closed** (`ADR-0011`). To test a control, either **move KALI01 to the zone under test** (the `ADR-0042` movable-client pattern) or **open one specific path** for the Game Day, run the attack, confirm the deny (+ log), and **close it**. No path is left standing.
- 🔴 **Evidence = the attack's result, not the tool's presence** (`POL-0001`). "KALI01 has nmap" proves nothing; "KALI01 ran nmap at the Tier-0 zone and got no services + a logged deny" is the evidence.

## Standing risks
- 🔴 **A path left open = a standing threat.** The single biggest risk — an attack path opened for a Game Day and forgotten becomes real exposure. Close every path; verify VLAN-70 isolation is restored after each test (`Diagnostics.md`).
- 🔴 **Blast radius on the target.** A real exploit can damage the *test target* — **snapshot the target VM before a destructive Game Day**; never run destructive tests against a production-critical box without a revert plan (availability first).
- 🔴 **Scope / legality.** Only ever the **own lab** — the toolset is dangerous off-scope. Keep it on VLAN 70; no external targets.
- 🟡 **Tool / exploit-DB freshness.** Stale signatures/exploits give false confidence (a defence looks strong because the attack was outdated). Update before a Game Day; record versions with the evidence.
- 🟡 **Placement / IP proposed → #20 / IP plan.** VM on PVE01/R410, VLAN 70, `10.70.0.x` are 📋 proposed.

## Open decisions (note when reached)
- **Dedicated KALI01 vs the movable client** — whether KALI01 is a standing VLAN-70 VM, the `ADR-0042` movable client re-tasked, or both. Settle with the client-fleet build (Backlog #23).
- **OWASP / SCAP scope** (Backlog #17/#18) — when the web/app zone + compliance scanning come online.

## Related
- `../../Operations/Validation-and-Adversarial-Testing.md` (the matrix) · `ADR-0011` (Game Days) · `ADR-0041` (test-gated) · `ADR-0042` (VLAN-70 fleet) · `Roadmap.md` · `Build-Guide.md` · `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the controlled-attack model (isolated-by-default VLAN 70; paths opened per Game Day then closed; evidence = the attack's result) + the risks (a path left open = standing threat; blast radius → snapshot targets; scope/legality = own lab only; tool-DB freshness; placement/IP proposed → #20) + open decisions (dedicated-vs-movable-client; OWASP/SCAP scope). |
