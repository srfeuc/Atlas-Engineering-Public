---
Title: Packet Flow
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# Packet Flow

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence 2026-07-13** — page: *Packet Flow*. Reconciled against live devices before publication. |
| Version | **2.0** |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## Client to Internet

```text
Client -> SW01 -> MKT01 VLAN gateway -> MKT01 ether1 -> FGT01 internal1 -> NAT on wan1 -> Internet
```

## Inter-VLAN

```text
Source VLAN -> SW01 -> MKT01 source VLAN interface -> MKT01 firewall -> destination VLAN interface -> SW01 -> endpoint
```

## Proxmox Host Management

```text
PVE01 untagged vmbr0 traffic -> SW01 Gi1/0/4 native VLAN 10 -> MKT01 vlan10-mgmt
```

## Proxmox Guest Traffic

```text
VM tagged NIC -> vmbr0 -> eno1 -> SW01 Gi1/0/4 tagged VLAN -> MKT01 gateway
```

## 🔴 FGT01 to Pi01 — the flow that MKT01 is NOT in

```text
FGT01 internal2 (10.10.0.254/24)  ->  SW01 Gi1/0/6  ->  SW01 Gi1/0/7  ->  Pi01 (10.10.0.5/24)
```

**Same subnet. Same VLAN 10. Layer-2 adjacent via SW01. MKT01 is never involved.**

This is how FGT01 reaches **Pi01's FreeRADIUS** for admin authentication, and **Pi-hole** for DNS. It is a **switched** path, not a routed one — no gateway, no forward chain, no router.

> 🔴 **This flow was never documented, and its absence cost real time.**
>
> MKT01 carried **two firewall rules** permitting FGT01→Pi01 RADIUS (`CM-0009`). Both were dead **twice over** — they pointed at `10.0.0.5`, Pi01's *pre-VLAN* address, **and** they were on a device that is not on the path. **They had never done anything at all.**
>
> **And the anomaly this created went unquestioned for months:** FGT01's RADIUS was confirmed working end-to-end *while those rules pointed at a nonexistent host.* **It worked *because* MKT01 was not involved.** Nobody asked why, because no document said where the traffic actually went.
>
> **A flow you have not drawn is a flow you will write firewall rules for on the wrong device.**

## iDRAC — rides PVE01's cable

```text
iDRAC (10.10.0.100)  ->  SHARED LOM on eno1  ->  SW01 Gi1/0/4  ->  MKT01 vlan10-mgmt
```

🔴 **The iDRAC has no independent path.** Same NIC, same cable, same switch port as `eno1`. **It dies with SW01** — which is step one of any teardown. **It is not out-of-band management.** See `CM-0011`.

## Return-Path Rule

Every allowed outbound path must have a valid return route and matching stateful policy. **A FortiGate that can reach the Internet does not prove downstream VLANs have return routing or policy coverage.**

## The rule this page exists to enforce

> **Before you write a firewall rule, name the devices the packet actually traverses.**
>
> Not the devices you assume are involved. **The ones on the wire.** If FGT01→Pi01 had been drawn once, two dead rules would never have been written, and the pre-VLAN address they carried would have been caught the day the VLANs were built.
