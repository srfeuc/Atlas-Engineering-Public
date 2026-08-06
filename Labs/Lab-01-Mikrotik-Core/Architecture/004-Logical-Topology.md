---
Title: Logical Topology
Path: Labs/Lab-01-Mikrotik-Core/Architecture
---

# Logical Topology

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Architecture

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence** — page: *Logical Topology*. |
| Version | 1.0 |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## Forwarding Model

```text
Endpoint -> SW01 -> MKT01 -> FGT01 -> Home/ISP Router -> Internet
```

- SW01 forwards frames within VLANs and transports tagged traffic.
- MKT01 owns all production VLAN gateways and inter-VLAN routing.
- FGT01 owns Internet policy, NAT, and the upstream default route.
- PVE01 uses one VLAN-aware bridge; host management is untagged/native VLAN 10 and guest traffic is tagged per VM.

## Routing Ownership

| Function | Owner |
|---|---|
| Internet default route | FGT01 |
| Internal default route | MKT01 via 172.16.0.1 |
| VLAN gateways | MKT01 |
| Inter-VLAN routing | MKT01 |
| Layer 2 forwarding | SW01 |
| Guest VLAN tagging | PVE01 vmbr0 |

## Security Boundaries

Internet, transit, management, server, web, monitoring, client, deployment, testing, and DMZ networks are treated as separate trust zones. VLAN 70 is designed for Internet-only testing and must not inherit general east-west access.
