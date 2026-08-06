---
Title: Enterprise Design Goals
Path: Labs/Lab-01-Mikrotik-Core/Architecture
---

# Enterprise Design Goals

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Architecture

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence 2026-07-13** — page: *Enterprise Design Goals*. Reconciled against live devices before publication. |
| Version | 1.0 |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## Purpose

Define the stable engineering goals used to evaluate network changes.

## Goals

- **Separation of responsibility:** perimeter security, routing, switching, and virtualization remain distinct.
- **Predictable segmentation:** every VLAN has a documented purpose, subnet, gateway, and security posture.
- **Recoverability:** backups, console access, fallback management, rollback steps, and validation are available before change.
- **Microsoft-aligned services:** Windows Server becomes authoritative for AD-integrated DNS, DHCP, time hierarchy, and PKI.
- **Operational clarity:** an engineer can rebuild, validate, and troubleshoot the environment from Atlas.
- **Controlled change:** Build Guides define target state; Change Records move live systems toward that state; Build Records are updated afterward.
- **No undocumented production changes:** Atlas is updated as part of implementation.

## Success Criteria

The design succeeds when an engineer can rebuild the production network from factory defaults, validate every traffic path, recover from a failed change, and identify temporary deviations without relying on chat history or memory.
