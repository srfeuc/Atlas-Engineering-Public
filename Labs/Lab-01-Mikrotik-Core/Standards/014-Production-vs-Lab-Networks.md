---
Title: Production vs Lab Networks
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# Production vs Lab Networks

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence 2026-07-13** — page: *Production vs Lab Networks*. Reconciled against live devices before publication. |
| Version | **2.0** |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## Production Foundation

**Built and live — treat as stable infrastructure:**

| System | Role |
|---|---|
| **FGT01** | Perimeter firewall, NAT |
| **MKT01** | Core router, inter-VLAN routing, east-west firewall |
| **SW01** | Layer 2 switching, ARP inspection, port security |
| **PVE01** | Hypervisor host management |
| 🔴 **Pi01** | **Lab CA (Root + Intermediate keys), Vaultwarden, Pi-hole DNS, FreeRADIUS.** 🔴 **Was MISSING from this list until 2026-07-13** — the most production-critical device in the lab was absent from its own Production Foundation. |

**Planned, NOT built — do not treat as foundation:**

| System | Status |
|---|---|
| Windows identity / DNS / DHCP / AD CS | 🔴 **Not deployed.** DC01 exists as a **stopped VM, never promoted.** |
| Monitoring (Wazuh, LibreNMS, Grafana) | 🔴 **Not deployed.** VLAN 40 is live; nothing is on it. |
| Backup | 🟡 **Partial.** `049` proved the **CA backup** restores. **No device backup has ever been restored.** |
| Cisco 1941 | 🔴 **Not deployed.** Phase 1.5. |

> 🔴 **The previous version of this page listed Windows identity, monitoring and backup as "stable infrastructure" — none of which exist — while omitting Pi01, which holds the CA, the vault, DNS and device AAA.**
>
> **A Production Foundation that names what is planned and omits what is running is not a foundation. It is a wish.**

## Laboratory Scope

VLAN 70 and the Cisco 1941 support isolated testing, routing protocols, and risky workloads. Laboratory activity must not require changes to the stable production forwarding path unless an approved change specifically calls for it.

## Rule

Testing convenience never overrides production segmentation, recoverability, or management access.
