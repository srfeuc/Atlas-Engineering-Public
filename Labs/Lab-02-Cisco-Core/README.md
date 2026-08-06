# Lab-02 — Cisco-Core

| Item | Value |
|---|---|
| Era | Cisco **1941 as routed core** + **MKT01 re-roled to east-west firewall / inter-VLAN gateway** (`ADR-0023`) |
| Status | 🚧 **ACTIVE — in build, not frozen** |
| Governance | Inherits `00-Atlas-Foundation/` (shared with Lab-01) |
| Scope | Dual — the Cisco-core network re-architecture **and** the enterprise-services + identity/PKI buildout that runs on it |

> 🧭 **Start here:** the live state is in **[`SESSION-HANDOFF.md`](SESSION-HANDOFF.md)**; the build order is **[`Master-Build-Order.md`](Architecture/Master-Build-Order.md)** → the sequenced bench list is **[`Master-Implementation-Checklist.md`](Master-Implementation-Checklist.md)**. The repo front door is the root [`README.md`](../../README.md).

## What this lab is

Lab-02 is two things at once, by design:

1. **A network re-architecture (`ADR-0023`).** The Cisco **1941 becomes the routed core** — two routed `/30` transit links + a loopback, **OSPF** with MKT01, default toward FGT01, and **no VLANs** on it (it is *not* router-on-a-stick — every VLAN gateway lives on MKT01). **MKT01 moves from core router to the east-west segmentation firewall + inter-VLAN gateway.** Same physical devices as Lab-01, new roles.
2. **The enterprise services + identity/PKI platform** that rides on it — virtualization (Proxmox), the Windows/AD environment (AD DS, DNS, DHCP), **AD CS two-tier PKI**, **NPS/RADIUS**, monitoring, backup, and east-west segmentation. This is the compute-and-identity layer, which is why it lives here rather than as its own lab.

## Contents

| Path | What's in it |
|---|---|
| **`SESSION-HANDOFF.md`** | 🟢 the single "where we are" owner — read first. |
| **`Master-Implementation-Checklist.md`** | the decision-free, phase-by-phase bench checklist. |
| **`Service-Server-Build-Plan.md`** | the service tier (SRV01/NPS01/MON01/Pi01/BKP01/PAW01/Vaultwarden) per host. |
| **`Build-Progress-Tracker.md`** | the execution log (order, connectivity matrix, done log). |
| **`Architecture/`** | the design layer — `Master-Build-Order`, `IP-Addressing-Plan-VLSM`, `Cabling-and-Port-Map`, `Atlas-East-West-Allowed-Flows-Matrix`, `Atlas-Service-Architecture`, `Lab-02-Device-Role-Assignments`, and the `CIS-Hardening-*` baselines. |
| **`Devices/`** | per-device docs — Build-Guide / Build-Checklist / **`Diagnostics.md`** (show-verify) / `Troubleshooting.md` for DC01·DC02, RCA01·ICA01 (AD CS), NPS01, SRV01, NetBox, MON01, PAW01, BKP01, Pi01, MKT01, SW01, 1941, FGT01. |
| **`Operations/`** | `SoT-Evidence-Run-Sheet`, `Device-Backup-Runbook`, `Device-Confirmation-Commands`, `Device-Hardening-Standard`, the doc-conflict audits, `Validation-and-Adversarial-Testing`. |
| **`Virtualization/`** | the Proxmox host build + Windows/Ubuntu golden-image pipelines (docs 201–220) + Build-Records (incl. `PVE01-Networking` — the authoritative PVE01 net doc, `ADR-0034`). |
| **`Windows-Infrastructure/`** | the Windows environment roadmap, `303` design standards, `304` Microsoft architecture reference. |

The company scenario that defines *why* this lab exists — Atlas's identity and security requirements (**301 + 305**) — lives at `00-Atlas-Foundation/Company-Profile/` (it governs every lab).

## Note on PVE01

PVE01 appears in **both** labs: frozen in Lab-01 as the network hypervisor, and active here as the virtualization platform. Same box, different era. Its **authoritative networking** doc is `Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`); the frozen Lab-01 copies are historical pointers.
