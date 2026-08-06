---
Title: Routing Standards
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# Routing Standards

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence** — page: *Routing*. |
| Version | **2.0** |
| Applies To | Atlas |
| Last Reconciled | 2026-07-14 |

## Production Routing

- MKT01 is the gateway for all internal production VLANs.
- MKT01 default route points to FGT01 at `172.16.0.1`.
- FGT01 has a return route to Atlas internal networks through `172.16.0.2`.
- FGT01 performs production NAT; MKT01 does not.
- SW01 remains Layer 2.
- Cisco 1941 routing labs remain outside the production forwarding path.

## Current FortiGate Summary Route

`10.0.0.0/8` via `172.16.0.2` covers the transitional network and all current VLANs. More-specific routes may replace it through a future reviewed change.

## 🔴 Routing is not the same as the packet path

**This section was added in v2.0 because its absence caused a real, months-long defect.**

MKT01 carried **two firewall rules** permitting FGT01 → Pi01 RADIUS. Both were dead **twice over**:

1. They pointed at `10.0.0.5` — Pi01's **pre-VLAN** address, which no longer exists.
2. **They sat on a device that is not on the path at all.**

FGT01 (`10.10.0.254/24`) and Pi01 (`10.10.0.5/24`) are **the same subnet, the same VLAN, Layer-2 adjacent via SW01.** That traffic **never enters MKT01's forward chain.**

**And the anomaly went unquestioned for months:** RADIUS was confirmed working end to end *while the rules pointed at a nonexistent host.* **It worked *because* MKT01 was not involved.** Nobody asked why — **because no document said where the traffic actually went.**

> 🔴 **A flow you have not drawn is a flow you will write firewall rules for on the wrong device.**
>
> **A routing table tells you where a packet goes when it must leave a subnet. It says nothing about the packets that never leave one.** Those are the ones you will mis-police.

**See `011-Packet-Flow.md`**, which now draws the flows, and `CM-0009`, which removed the dead rules.

## Validation

```text
FGT01: get router info routing-table all
MKT01: /ip route print detail
Windows: tracert 1.1.1.1
Linux: traceroute 1.1.1.1
```

## Related

- `011-Packet-Flow.md` — where traffic actually goes
- `013-Internet-Access-Design.md`
- `CM-0009` — the dead RADIUS rules this lesson came from

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial routing model. |
| **2.0** | **2026-07-14.** Added *"Routing is not the same as the packet path"* — the `CM-0009` finding. The guide previously described the routing model correctly and said **nothing** about Layer-2-adjacent traffic, which is precisely the class of flow that got firewall rules written on the wrong device. Published to Confluence (*Routing*), replacing a four-line stub that had no transit addressing, no NAT ownership and no validation commands. |
