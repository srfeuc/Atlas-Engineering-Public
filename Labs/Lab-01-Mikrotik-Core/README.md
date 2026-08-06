# Lab-01 — Mikrotik-Core

| Item | Value |
|---|---|
| Era | MKT01 as core router (the founding Atlas lab) |
| Status | ✅ FROZEN 2026-07-16 · device-verified across all five devices |
| Freeze basis | `pre-restructure` tag · `00-Atlas-Foundation/Decisions/ADR-0022-…` |
| Governance | Inherits `00-Atlas-Foundation/` — Charter, Policies, ADRs, Templates |
| Devices | MKT01, SW01, FGT01, PI01, PVE01 |

## What this lab is

The first Atlas build: a five-device enterprise network with **MKT01 (MikroTik) as the core router** — inter-VLAN routing and the east-west firewall — **FGT01 (FortiGate)** at the perimeter (WAN / NAT), **SW01 (Cisco 2960X)** as the Layer-2 access switch, **PI01 (Raspberry Pi)** running the lab's four shared services, and **PVE01 (Proxmox / Dell R410)** as the hypervisor. It is frozen and reconciled to live state on every device — the portfolio artefact for this era.

> When Lab-02 re-roles these devices (Cisco 1941 becomes core; MKT01 becomes an east-west firewall), **this lab does not change.** Every page here carries a `Lab-01 · Host · Role` header so it is never confused with a later era.

## Devices — this era's roles

| Device | Role here | Folder |
|---|---|---|
| MKT01 | Core Router — VLAN gateways, inter-VLAN routing, east-west stateful firewall | `Devices/MKT01-Core-Router/` |
| FGT01 | Perimeter Firewall — WAN uplink, NAT, edge security | `Devices/FGT01-NS-Firewall/` |
| SW01 | Access Switch — L2 switching, VLANs, STP root, DHCP snooping, DAI, port security | `Devices/SW01-Access-Switch/` |
| PI01 | Shared Services — Lab CA, Vaultwarden, Pi-hole DNS, FreeRADIUS (four roles, one box) | `Devices/PI01-Services/` |
| PVE01 | Hypervisor — VLAN-aware bridge, per-VM VLAN tagging | `Devices/PVE01-Hypervisor/` |

## Map

- `Architecture/` — physical & logical topology, device responsibilities, network source of truth (001–006)
- `Standards/` — IP, VLAN, routing, security zones, packet flow, management network (007–014; lab-specific)
- `Operations/` — cross-device runbooks: CA issuance/renewal, teardown, backup, validation, and the Book-1 audit report
- `Change-Management/` — the CM/MC ledger index + cross-device change records (device-specific CMs live under each device's `Changes/`)
- `Devices/<device>/` — each device's Build-Guide, Build-Record, Troubleshooting, CIS-Hardening, Verification, Considerations, and Changes

## Open items — deferred, not closed (ADR-0022)

- **SW01:** CM-0030 (clock never synchronised), CM-0036 (SPAN built, never tapped), CM-0037 (SNMP points at a host that doesn't exist yet)
- **PVE01:** CM-0012 (RTC won't hold time — board fault; blocks `050` iDRAC onboarding)
- **MKT01:** RouterBOOT firmware finding; discovery-leak (recommended close)

Two lab-wide risks outrank the punch-list and remain open: **no off-site copy of the backup media**, and **no device backup has ever been restore-tested.**
