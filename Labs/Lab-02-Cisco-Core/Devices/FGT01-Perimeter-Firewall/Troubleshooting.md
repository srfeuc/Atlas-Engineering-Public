---
Title: FGT01 Troubleshooting Guide
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
---

# FGT01 Troubleshooting Guide

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: FGT01 - Role: Perimeter (North-South) Firewall (FortiGate-60E, FortiOS 7.4.5)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Living |
| Version | 1.0 |
| Applies To | FGT01 |
| Last Updated | 2026-07-21 |

## Purpose
Real incidents on the Lab-02 FGT01 with root cause + verified fix. Build steps: `Build-Guide-1-Networking.md` + the `Build-Guide-Index`. Log/flow tracing: `Logging-and-Flow-Tracing-Field-Guide.md`. Cross-device timeline: `Build-Progress-Tracker.md`. *(See also the Lab-01 FGT01 Troubleshooting page for the certificate/VDOM history.)*

## Before You Start
- [ ] **Read with `get`, not `show`** (`MC-0001`) — `show` only prints non-default values and can make a wrong setting look empty.
- [ ] **`get system interface <name>` errors on 7.4.5** — use `show system interface <name>` for one interface, or `get system interface` for the full dump.
- [ ] **This 60E has no `port2`** — the interior ports are the `internal` hardware switch (`internal1`–`internal7`); it's **single-VDOM**.
- [ ] 🔴 **`internal3`–`internal7` = break-glass** (`192.168.1.99/24`, `CM-0033`) — never disable them.
- [ ] **The 60E has no disk** — logs to memory only (durable logging = syslog → MON01, Phase 6).

## Diagnostic Approach
```text
Interface     — no port2; split internal1 off the hardware switch before addressing
Reachability  — the box can ping out but a host can't? → the forward egress POLICY, not routing
Mgmt access   — transit is ping-only; GUI is on 192.168.1.99 (break-glass) or via enabled https on internal1
Flow "why"    — diagnose debug flow (see the Logging & Flow-Tracing Field Guide)
Live state    — get, not show
```

---

## Incident: `edit "port2"` fails — "Attribute 'vdom' MUST be set"
**Symptom:** creating/addressing `port2` errors with `Attribute 'vdom' MUST be set`.
**Root cause:** the 60E has **no `port2`** — that name only exists on the FortiGate-VM. Creating it makes a bogus logical interface (which is why FortiOS then demands a VDOM).
**Resolution:** use `internal1`; free it from the hardware switch first, then address it. No `set vdom` line (this unit is single-VDOM):
```
config system virtual-switch
 edit "internal"
  config port
   delete internal1
  end
 next
end
config system interface
 edit internal1
  set ip 10.255.255.1 255.255.255.252
  set allowaccess ping
 next
end
```
**Verify fix:** `show system interface internal1` → the `/30`, `allowaccess: ping`, `status: up`.

---

## Incident: A host can't reach the internet, but the FortiGate itself can
**Symptom:** `execute ping 1.1.1.1` from FGT01 succeeds; an interior host reaches the 1941 but times out to `1.1.1.1`.
**Root cause:** **no egress firewall policy.** The host's forwarded traffic hits the implicit deny; the FortiGate's *own* (self-originated) traffic isn't subject to the forward policy, which is why the box can ping out while the host can't.
**Resolution:** add the interior→wan1 egress policy with NAT:
```
config firewall policy
 edit 0
  set name "egress-interior-to-wan"
  set srcintf "internal1"
  set dstintf "wan1"
  set srcaddr "all"
  set dstaddr "all"
  set action accept
  set schedule "always"
  set service "ALL"
  set nat enable
  set logtraffic all
 next
end
```
**Verify fix:** the host reaches `1.1.1.1`; `get firewall policy` shows the policy with `nat: enable`. *(device-verified 2026-07-21 — this was the sole blocker to internet.)*
**Lesson:** routing decides *where*; the policy decides *whether*. "Box can ping out, host can't" almost always = missing/blocking forward policy.

---

## Incident: Can't reach the GUI over the network
**Symptom:** `https://10.255.255.1` (the transit IP) doesn't load; `https://192.168.1.99` isn't reachable from an interior host either.
**Root cause:** the transit (`internal1`) is **`allowaccess ping` only** — no HTTPS by design. And `192.168.1.99` lives on the isolated `internal` switch (ports internal2–7), a different segment your VLAN-10 host can't route to.
**Resolution:**
- **Break-glass GUI:** plug a laptop into internal3–7, set a `192.168.1.x` address, browse `https://192.168.1.99`.
- **Interior GUI (bring-up convenience):** enable HTTPS on the transit and browse `https://10.255.255.1`:
  ```
  config system interface
   edit internal1
    set allowaccess ping https
   next
  end
  ```
  🔴 This puts mgmt on the routed link — scope it (trusthost) or revert to ping-only in the Guide 2 hardening pass.
**Verify fix:** the GUI loads; `show system interface internal` → break-glass `allowaccess` includes `https ssh`.

---

## Incident: `get system interface internal1` errors on 7.4.5
**Symptom:** `get system interface internal1` returns an error.
**Root cause:** per-interface `get` doesn't work on 7.4.5.
**Resolution:** use `show system interface internal1` for one interface, or `get system interface` for the full dump. *(Read-back only — no config change.)*

---

## Quick Reference — Common Commands
| Task | Command |
|---|---|
| Confirm true interface state | `show system interface <name>` (per-interface `get` errors on 7.4.5) |
| Confirm the egress policy + NAT | `get firewall policy` |
| Confirm routing | `get router info routing-table all` |
| Trace WHY a packet is allowed/dropped | `diagnose debug flow ...` (see the Logging & Flow-Tracing Field Guide) |
| Confirm VDOM mode | `get system status` → "Virtual domain configuration" |
| Reach the GUI when the network path is down | laptop on internal3–7, `https://192.168.1.99` |

## Escalation
1. Prove the break-glass (`192.168.1.99` on internal3–7) is reachable before any mgmt-affecting change.
2. Use `diagnose debug flow` (Logging & Flow-Tracing Field Guide) to see the actual per-packet decision.
3. Cross-reference the tracker log + `Build-Guide-1-Networking.md` (v0.5).

## Related Pages
- `Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/Build-Guide-Index.md`
- `Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/Build-Guide-1-Networking.md`
- `Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/Logging-and-Flow-Tracing-Field-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Troubleshooting.md` (certificate/VDOM history)
