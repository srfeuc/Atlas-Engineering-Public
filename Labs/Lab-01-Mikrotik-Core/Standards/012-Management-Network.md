---
Title: Management Network
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# Management Network

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence 2026-07-13** — page: *Management Network*. Reconciled against live devices before publication. |
| Version | **2.0** |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## Standard

VLAN 10 (`10.10.0.0/24`) is the permanent management network. Administrative access should originate from approved systems and use HTTPS, SSH, WinRM, PowerShell Remoting, or RDP where justified.

## Core Addresses

| System | Address | Access | Notes |
|---|---|---|---|
| MKT01 gateway | `10.10.0.1` | WinBox, SSH **port 2222**, `www-ssl` 443 | All restricted to `10.0.0.0/24` + `10.10.0.0/24` |
| SW01 SVI | `10.10.0.2` | SSH | Hostname **`SW01`** — device-verified 2026-07-16 (`show version`, `CM-0022`); the earlier *"rename still open"* was stale, the switch was renamed long ago |
| 🔴 **Pi01** | **`10.10.0.5`** | **SSH port 2222, key-only** | 🔴 **Was MISSING from this table until 2026-07-13.** Holds the **Lab CA, Vaultwarden, Pi-hole and FreeRADIUS.** |
| PVE01 | `10.10.0.10` | `https://10.10.0.10:8006`, SSH 22 | Certificate warning expected (no-subscription patch) |
| Admin workstation | `10.10.0.50` | — | 🔴 **Also missing until 2026-07-13.** Must be in `STATIC-HOSTS`. |
| 🔴 **iDRAC-PVE01** | `10.10.0.100` | `https://10.10.0.100` | 🔴 **NOT out-of-band.** Shared LOM on `eno1`/`Gi1/0/4`. **Dies with SW01.** Factory credentials (`CM-0011`). |
| FGT01 `internal2` | `10.10.0.254` | `https://10.10.0.254` | Lab CA certificate installed (`MC-0001`) |

## Transitional Access

The legacy `10.0.0.0/24` network remains permitted on selected management services until migration is complete. Remove it only through Change Management after VLAN 10 access and recovery options are verified.

## 🔴 DAI Requirement — and the rule this page already had

**Static VLAN 10 systems require verified IP/MAC entries when Dynamic ARP Inspection is enforced. NEVER guess a MAC address.**

**SW01 has `DHCP Permits: 0`. There is no snooping fallback.** A host missing from `STATIC-HOSTS` is **dropped, full stop** — no error, no warning. **It simply appears broken.**

> 🔴 **This rule was correct, and it was broken anyway.**
>
> **Nobody guessed Pi01's MAC. It was simply never written down.** `006-Network-Source-of-Truth.md`'s `STATIC-HOSTS` table had **four entries** where **five are required** — and Pi01 was the missing one. Its MAC (`00:00:5e:00:53:05`) was sitting in the IP table on the same page, uncopied.
>
> **The same omission in `023-SW01-Build-Record.md` produced a false "Pi01 should be unreachable" mystery that survived three handoffs.**
>
> 🔴 **"Never guess" was not enough. The rule needed a second half: *and never omit.*** A guessed MAC fails loudly. **An omitted one fails silently — and looks like a broken device.**

**All five `STATIC-HOSTS` entries** (see `006-Network-Source-of-Truth.md`):
`10.10.0.5` Pi01 · `10.10.0.10` PVE01 · `10.10.0.50` workstation · `10.10.0.100` iDRAC (**same port as PVE01**) · `10.10.0.254` FGT01.
