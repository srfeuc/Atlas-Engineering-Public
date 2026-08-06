---
Title: STP + EtherChannel Sandbox — Packet-Tracer Lab
Path: Labs/Lab-02-Cisco-Core/Packet-Tracer-Labs/STP-EtherChannel-Sandbox/README.md
Status: 📋 SCAFFOLD — front door + page-set index (fill the Learn-it links)
Version: 0.1
Date: 2026-08-05
---

<!-- provenance -->
> **Lab-02 · Cisco-Core · Packet-Tracer-Labs (🖥️ simulator, `ADR-0022`).** This documents the **STP + EtherChannel Sandbox** built in Packet Tracer. A ✅ here is **🖥️ sim-verified**, distinct from a hardware ✅. Design lives in the spec (linked below); this page-set is where the *actual build* is recorded.

> 📋 **SCAFFOLD — fill this in.** Section headers + prompts are pre-placed to match the Atlas device page-set; the content is intentionally blank so the operator documents the real build and tests the layout.

# STP + EtherChannel Sandbox

> **What this is (one line):** _the Layer-2-only STP + EtherChannel drill — a 3× 2960 triangle (Po1 LACP · Po2 PAgP · single trunk)._

**Design reference (the spec):** [`Packet-Tracer-STP-EtherChannel-Sandbox-Spec.md`](../../Operations/Packet-Tracer-STP-EtherChannel-Sandbox-Spec.md) — roster, link plan, objective coverage, and the topology diagram.

## On this page-set

| Doc | What it holds |
|---|---|
| [`Build-Guide`](Build-Guide.md) | how to build it in PT — the config to type, stage by stage (target state) |
| [`Build-Checklist`](Build-Checklist.md) | the sequenced bench checklist (tick as you go) |
| [`Build-Record`](Build-Record.md) | verified reality — the `show`/screenshot evidence, per objective |
| [`Diagnostics`](Diagnostics.md) | the show/verify commands + expected read-backs |
| [`Troubleshooting`](Troubleshooting.md) | symptoms → cause → fix |
| [`Considerations`](Considerations.md) | decisions + open risks/gotchas |
| [`Roadmap`](Roadmap.md) | what's next / not-yet-built |
| [`Changes/`](Changes/) | change records (CM-####) for this lab |

## 🎓 Learn it (link, don't restate)

- 🎓 Concept: _<!-- link the Concept that explains the why -->_
- 🔧 Command-Library: [`Cisco-IOS`](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md)
- 🏅 Cert objectives demonstrated: _<!-- link the Certification sub-pages this lab proves -->_
- 🔧 Playbooks seeded from this lab: _<!-- link -->_

## Related

- Spec: [`Packet-Tracer-STP-EtherChannel-Sandbox-Spec.md`](../../Operations/Packet-Tracer-STP-EtherChannel-Sandbox-Spec.md) · governance: `ADR-0022` (simulator precedence) · `ADR-0053` (Academy/Playbook standard).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Scaffold created (blank page-set for the operator to fill). |
