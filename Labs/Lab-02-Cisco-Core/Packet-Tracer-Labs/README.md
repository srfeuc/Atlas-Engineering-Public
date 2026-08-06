---
Title: Packet-Tracer Labs
Path: Labs/Lab-02-Cisco-Core/Packet-Tracer-Labs
Status: 📋 SCAFFOLD — index for the Packet-Tracer lab docs
Version: 0.1
Date: 2026-08-05
---

# Packet-Tracer Labs

> **What this is.** The Packet-Tracer labs, documented in the **standard Atlas device page-set** — a deliberate exercise to test the documentation habit and the layout on real (simulated) builds. 🖥️ **sim-verified** (`ADR-0022`): a ✅ here is distinct from a hardware ✅; the real estate always wins over the sim.

> The **designs** live as specs under [`../Operations/`](../Operations/); these folders are where the **actual builds get documented + evidenced**.

## Labs

| Lab | What it is | Design spec |
|---|---|---|
| [`CCNA-Twin/`](CCNA-Twin/README.md) | the full dual-stacked CCNA-breadth twin | [`Packet-Tracer-Twin-Build-Spec`](../Operations/Packet-Tracer-Twin-Build-Spec.md) |
| [`STP-EtherChannel-Sandbox/`](STP-EtherChannel-Sandbox/README.md) | the Layer-2-only STP + EtherChannel drill | [`Packet-Tracer-STP-EtherChannel-Sandbox-Spec`](../Operations/Packet-Tracer-STP-EtherChannel-Sandbox-Spec.md) |

## The page-set (each lab)

`README` · `Build-Guide` · `Build-Checklist` · `Build-Record` · `Diagnostics` · `Troubleshooting` · `Considerations` · `Roadmap` · `Changes/` — the same set a real device carries, so documenting a PT lab feels identical to documenting hardware.

## Related

- Governance: `ADR-0022` (simulator precedence) · `ADR-0053` (Academy/Playbook standard) · the device-page-set standard in [`Documentation`](../../../00-Atlas-Foundation/Documentation/).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Scaffold created — per-lab subfolders (CCNA-Twin · STP-EtherChannel-Sandbox), full blank page-set each, for the operator to fill. |
