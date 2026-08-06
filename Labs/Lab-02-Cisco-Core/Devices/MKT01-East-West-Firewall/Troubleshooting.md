---
Title: MKT01 Troubleshooting Guide
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
---

# MKT01 Troubleshooting Guide

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: MKT01 - Role: East-West Firewall + Inter-VLAN Gateway (MikroTik RB1100AHx4, RouterOS 7.23.1)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Living |
| Version | 1.1 |
| Applies To | MKT01 |
| Last Updated | 2026-07-28 |

## Purpose
Real incidents on MKT01 with root cause + verified fix. Build steps: `Build-Guide.md`. Cross-device timeline: `Build-Progress-Tracker.md`.

## Before You Start
- [ ] **Read `print detail` / `print stats`, not plain `print`** (`016`) — plain `print` hides `address=` and dynamic rows, faking state.
- [ ] **RouterOS auto-saves** — config survives a power cut. But if the box only has *transit* addressing, a reboot that drops MAC-WinBox strands you: **always keep a durable mgmt IP on a free port** (`ether2` = `192.168.88.1/24`).
- [ ] **`ether3` (the trunk) MUST be `hw=no`** — the RTL8367 switch chip's hardware offload eats VLAN traffic otherwise. This is a functional requirement; re-verify after any firmware update/restore.
- [ ] **WinBox terminal rejects `#` comments and `\` line-continuations** — paste clean one-liners.

## Diagnostic Approach
```text
Reachability to the box — MAC-WinBox (Neighbors) is the L2 fallback when IP mgmt is gone
Offload trap          — VLAN sub-interfaces show 0 RX while ether3 shows traffic? → hw=no
OSPF                  — adjacency Full? redistribute=connected on the instance?
Live state            — print detail / print stats, never plain print
```

---

## Incident: Locked out after a power cut / reboot
**Symptom:** after an unplanned reboot, no IP path to MKT01; the default `192.168.88.1` is gone.
**Root cause:** only the transit `/30` was addressed; the defconf mgmt IP was removed and nothing laptop-reachable remained. RouterOS *had* auto-saved — the config was intact, just unreachable.
**Resolution:** reconnect over L2 via **WinBox → Neighbors → (select by MAC)**, then add a durable mgmt IP on a free port:
```
/ip address add address=192.168.88.1/24 interface=ether2 comment=MGMT-fallback
```
**Verify fix:** laptop on `ether2` reaches `192.168.88.1`; keep it until the console cable or a VLAN-10 mgmt path exists.
**Lesson:** transit-only addressing + a reboot = lockout. Durable mgmt IP first, always.

---

## Incident: VLAN gateways configured but hosts get nothing (0 RX on the sub-interfaces)
**Symptom:** VLAN sub-interfaces exist and look correct, but no VLAN traffic passes; `ether3` shows traffic while the VLAN interfaces show 0 RX.
**Root cause:** **RTL8367 hardware offload** on `ether3` — with `hw=yes` the switch chip intercepts frames before RouterOS sees them. A config that looks right and silently does nothing.
**Resolution:** the trunk port must be `hw=no` on the bridge, using the **VLAN-sub-interface model on a plain `bridge-trunk`** (not a `vlan-filtering` bridge):
```
/interface bridge port set [find interface=ether3] hw=no ingress-filtering=no
```
**Verify fix:** `/interface bridge port print detail where interface=ether3` → `hw=no`; hosts on the VLANs reach their gateways.
**Lesson:** `hw=no` is a functional requirement on this chip — re-verify after every firmware update / backup restore.

---

## Incident: `passive=yes` on the OSPF interface-template errors
**Symptom:** adding an OSPF interface-template with `passive=yes` → error at "column 59".
**Root cause:** `passive` is **not** a valid interface-template property in RouterOS 7.23.1.
**Resolution:** keep OSPF on the transit only and advertise the VLANs via redistribution:
```
/routing ospf instance set [find name=ospf1] redistribute=connected
```
**Verify fix:** `/routing ospf neighbor print` → the 1941 as **Full**; the 1941's `show ip route ospf` shows MKT01's VLANs as **O E2**.

---

## Incident: `etherA` / `etherB` don't exist; bridge-VLAN commands error
**Symptom:** config referencing `etherA`/`etherB` or a bridge-VLAN table fails.
**Root cause:** placeholders + the wrong VLAN model for the RB1100AHx4. Real ports are `ether1`–`ether13`.
**Resolution:** `ether1` = routed `/30` uplink to the 1941; `ether3` = 802.1Q trunk to SW01 (on `bridge-trunk`, `hw=no`). VLAN sub-interfaces on `bridge-trunk`; **no** `vlan-filtering=yes`, no bridge-VLAN table.
**Verify fix:** `/interface vlan print` → nine VLANs on `bridge-trunk`, `R` (running).

---

## Incident: WinBox terminal rejects pasted config
**Symptom:** parse errors when pasting multi-line config with `#` comments or `\` continuations.
**Root cause:** the WinBox terminal doesn't accept `#` comments or `\` line-continuations.
**Resolution:** paste **clean one-liners** only; strip comments and continuations.

---

## Quick Reference — Common Commands
| Task | Command |
|---|---|
| Reconnect when IP mgmt is gone | WinBox → Neighbors → select by MAC |
| Confirm the offload trap is avoided | `/interface bridge port print detail where interface=ether3` → `hw=no` |
| Confirm OSPF adjacency | `/routing ospf neighbor print` → Full |
| Confirm routes/default | `/ip route print` (default via `10.255.255.5`) |
| See true service/address state | `/ip service print detail` (not plain `print`, `016`) |

## Escalation
1. If unreachable by IP, go straight to MAC-WinBox (Neighbors) — don't factory-reset first.
2. Check `Build-Guide.md` (v0.8) against live state with `print detail`.
3. Cross-reference the tracker's troubleshooting log + Lab-01 `MKT01-Core-Router` notes.

## Related Pages
- `Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/Build-Guide.md`
- `Labs/Lab-02-Cisco-Core/Build-Progress-Tracker.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Console-Recovery-Cable-and-Settings.md`
