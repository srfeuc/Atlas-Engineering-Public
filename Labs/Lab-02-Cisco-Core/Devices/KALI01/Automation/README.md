---
Title: KALI01 — Automation (box-as-code; attacks stay hand-run)
Path: Labs/Lab-02-Cisco-Core/Devices/KALI01/Automation
Status: 📋 Designed stub (ADR-0048). Security variant = rebuildable box + tool config; the ATTACKS stay hand-run. NOT DSC. Authored after the manual first pass.
Version: 0.1
Date: 2026-07-30
---

# KALI01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** KALI01's automation **slice** — authored **after** the manual first pass. 🔴 **The learning boundary is sharp here:** automate the **box** (rebuildable Kali + tool install/config, snapshot/revert), **never the attacks** — running the attack + reading the result by hand *is* the PenTest+/validation skill. The runnable shared code (git/CI) is the estate capability (`../../CNT01-Container-Host/`; Backlog #19). **Not** DSC.

## Planned automation (designed, phased)

| Task | Tool | What it automates | Hand-run first / always (NOT automated) |
|---|---|---|---|
| **Rebuild the box** | cloud-init / Ansible | A rebuildable Kali VM + the toolset install/config → same box every time | Choosing + learning the tools |
| **Snapshot/revert helper** | Proxmox API / script | Snapshot the target + KALI01 before a Game Day; revert after | Deciding what's destructive |
| **Evidence capture** | script | Collect the attack output + tool versions into the evidence record | 🔴 **The attacks themselves + reading the result** — always hand-run (the skill) |

## How this fits the estate
- **Phase alignment:** box-as-code at Phase 10; the **Game-Day attacks stay manual, per `ADR-0011`** (the whole point is to run + interpret them).
- **Cert anchor:** the automation (box rebuild) is minor; the value is the hand-run attacks (PenTest+/CySA+).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the `ADR-0048` stub for KALI01 with a sharp boundary: automate the **box** (rebuildable Kali + tool config + snapshot/revert + evidence capture), **never the attacks** (hand-run = the skill). Not DSC. |
