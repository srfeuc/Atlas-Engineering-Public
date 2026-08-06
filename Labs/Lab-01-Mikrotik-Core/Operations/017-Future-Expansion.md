---
Title: Future Expansion
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Future Expansion

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | **Draft for Confluence Review** |
| Version | **2.0** |
| Applies To | Atlas |
| Last Reconciled | 2026-07-14 |

> **This is Book 1's deferred-work document.** Items live here so they survive the session that thought of them. **A deferred item is not a work order** — several below are gated, and the gate is stated with the item, not somewhere else.

## 🔴 Correction — v1.0 proposed retiring the recovery network

**v1.0 listed:** *"Retirement of the legacy `10.0.0.0/24` network."*

🔴 **`10.0.0.0/24` is `bridgeLocal` — the admin recovery network. There is no separate "legacy flat network" to retire. They are the same object.**

Read off MKT01, 2026-07-14:

```text
 1     ;;; Legacy flat management
       address=10.0.0.1/24 network=10.0.0.0 interface=bridgeLocal
```

```text
/interface bridge port print where bridge=bridgeLocal
Flags: I - INACTIVE; H - HW-OFFLOAD
0 IH ether4   bridgeLocal ...
...
9 IH ether13  bridgeLocal ...
```

**All ten ports (`ether4`–`ether13`) are members, hardware-offloaded, and NOT disabled** — there is no `X` in the flag legend. **`I` (INACTIVE) means no cable is currently plugged in.** That is the correct resting state for an unused fallback, **not evidence that it is dead.**

> 🔴 **A hasty read of `INACTIVE` says "retire it." That read is wrong, and it would remove the one management path that survives a VLAN failure.**

**`003-Physical-Topology.md` and `016-Network-Lessons-Learned.md` both already say, in writing: *do not remove `bridgeLocal`; do not retire it early.*** v1.0 of this page contradicted both. **The contradiction is resolved in favour of the device and the two documents that read it.**

**Retiring `bridgeLocal` is now tracked as `ADR-0013` — Proposed, gated, deliberately not scheduled.** It is not a Change Record, because **reversing a written decision is a decision.**

## 🔴 The device comment is part of the defect

MKT01 labels the recovery network **`;;; Legacy flat management`**. **Calling your recovery path "Legacy" on the device itself is an invitation to delete it** — and it is very likely why v1.0 of this page proposed exactly that.

**Tracked as `CM-0016`** — re-comment the address on MKT01 so the device says what it is.

## Deferred Enhancements

**Ungated — do when convenient:**

- Windows AD-integrated DNS and DHCP.
- Active Directory time hierarchy.
- AD CS and certificate-based management. *(Coexistence with the Lab CA, per `ADR-0003` — not a replacement.)*
- Monitoring and centralized logging. *(VLAN 40 is live and routed; **no monitoring host exists.** SW01 currently points SNMP at `10.40.0.52`, which does not exist.)*
- Proxmox Backup Server and shared storage.
- Additional switches or hypervisors.
- More-specific FortiGate routes if operationally justified. *(Deliberately deferred per `ADR-0005` — revisit once network redundancy exists.)*
- IPv6, VPN, wireless, voice, and WAN labs.

**🔴 Gated — do NOT start until the gate is met:**

| Item | Gate | Tracked as |
|---|---|---|
| 🔴 **Retire `bridgeLocal` (`10.0.0.0/24`)** | **Book 1 frozen**, iDRAC genuinely out-of-band on the dedicated NIC (`050`), **and a restore-tested backup for SW01 and MKT01.** None of the three is true today. | **`ADR-0013`** — Proposed |
| **Move iDRAC to the dedicated NIC** | `CM-0012` — CMOS battery replaced and the board proven to hold config across a full power loss. | `050` |
| **Game Day failure drills** | Book 1 frozen **and** `CM-0014` closed. | `ADR-0011` — Proposed |

## 🔴 Pi-hole is not "optional filtering" — corrected 2026-07-14

**v1.0 listed:** *"Optional Pi-hole filtering after Windows DNS is established."*

**Pi-hole on Pi01 (`10.10.0.5`) is the lab's authoritative resolver today.** It holds the local records for `vault.lab`, the MikroTik, and the CA hosts. **It is not optional and it is not a filter bolted onto something else.**

**Windows DNS, when it arrives, is a *coexistence* — split on domain membership**, exactly as `ADR-0003` splits the CA and `ADR-0004` splits RADIUS. **Non-domain devices stay on Pi-hole.** See `013-Internet-Access-Design.md` v2.0.

## The rule for everything on this page

**Every expansion requires capacity planning, a Change Record, validation, Build Record updates, and Source of Truth updates.**

> 🔴 **And a gated item requires its gate to be checked before it is started — not after.** `CM-0011` was executed as a to-do list without reading the record next to it that said `Blocks:`. **It degraded a BMC.** This page is where that mistake would be repeated at the network layer.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial deferred-enhancement list. |
| **2.0** | 🔴 **2026-07-14 — two corrections, one of them dangerous.** (1) v1.0 proposed *"retirement of the legacy `10.0.0.0/24` network."* **That network is `bridgeLocal`, the admin recovery path** — confirmed on MKT01: all ten ports (`ether4`–`ether13`) are bridge members, hardware-offloaded, and not disabled. **`003` and `016` both explicitly forbid removing it.** Moved to `ADR-0013`, gated. (2) v1.0 called Pi-hole *"optional filtering"* — **it is the authoritative resolver.** Added the gated/ungated split, and `CM-0016` for the misleading `;;; Legacy flat management` comment on the device. |
