---
Title: IP Addressing Strategy
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# IP Addressing Strategy

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence** — page: *IP Address Plan*. |
| Version | 1.0 |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## Standard

Atlas uses `10.<VLAN>.0.0/24` for production VLANs. Gateway `.1` belongs to MKT01. Infrastructure uses documented static addresses; clients will use Windows DHCP when deployed.

## Allocation Guidance

| Range | Intended Use |
|---|---|
| .1-.9 | Gateways and core network infrastructure |
| .10-.49 | Hypervisors and servers |
| .50-.99 | Managed infrastructure and administrative systems |
| .100-.199 | Reserved static or DHCP reservations |
| .200-.254 | DHCP clients where appropriate |

This is guidance, not a substitute for the Source of Truth.

## Reserved Networks

- `172.16.0.0/29`: FGT01-MKT01 transit only.
- `10.0.0.0/24`: transitional recovery network.
- VLAN 999: no routed subnet.

## Rules

- No duplicate IP objects on a RouterOS VLAN interface.
- Static devices protected by DAI require verified MAC/IP entries.
- Record address changes before or as part of Change Management.
