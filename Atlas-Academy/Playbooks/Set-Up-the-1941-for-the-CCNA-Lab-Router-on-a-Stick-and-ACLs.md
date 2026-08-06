---
Title: Set Up the 1941 for the CCNA Lab — Router-on-a-Stick + ACLs
Path: Atlas-Academy/Playbooks
Status: 🟡 LAB PLAYBOOK (`ADR-0053`) — a **temporary CCNA-lab overlay** on the 1941 (`ADR-0023` Option A, the sanctioned learning vehicle). You type the config (Charter Rule 17); this gives the design, the real addresses, and the validation. Sourced from the operator's Cisco notes (`Trunking DTP VTP`, `ACL …`) + the [IP plan](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md).
Version: 0.1
Date: 2026-08-04
Scope: Lab-02
---

# Set Up the 1941 for the CCNA Lab — Router-on-a-Stick + ACLs

> **Lab-02 · Cisco-Core (ACTIVE)** — Host: **1941** — CCNA lab overlay (inter-VLAN routing + ACLs). Objectives: **2.1/2.2** trunking · **3.x** inter-VLAN routing · **5.6** ACLs.

## 🔴 Read first — this is a *temporary* overlay
The 1941's **production** role is **routes-only, no VLANs** — MKT01 owns inter-VLAN routing + the east-west firewall ([`ADR-0023`](../../00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) Option B, the target in [`1941 Build-Checklist`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md)). For the CCNA lab you temporarily run **Option A — router-on-a-stick on the 1941** (ADR-0023 keeps the 1941 as "the CCNA/IOS learning vehicle," so this is sanctioned, not a violation). When the CCNA work is done, **[revert](#5-revert-to-production)** and hand inter-VLAN + policy back to MKT01. This is recorded as a CCNA-overlay note on the [1941 Considerations](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md).

> 🔴 **One gateway per VLAN at a time.** During the lab the **1941 holds each VLAN's `.1` gateway** — the same `.1` the [IP plan](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) assigns to MKT01 in production. Only one device can own `.1` at once. Since MKT01's inter-VLAN role isn't live yet, there's no conflict — but never run both as `.1` simultaneously (duplicate-gateway).

## On this page
1. [Prerequisites — the trunk to SW01](#1-prerequisites--the-trunk-to-sw01)
2. [Router-on-a-stick — subinterfaces + gateways](#2-router-on-a-stick--subinterfaces--gateways)
3. [ACL exercise A — standard (deny one VLAN to another)](#3-acl-exercise-a--standard-numbered)
4. [ACL exercise B — extended (clients → servers, one port)](#4-acl-exercise-b--extended-named)
5. [Revert to production](#5-revert-to-production)

---

## 1. Prerequisites — the trunk to SW01

Router-on-a-stick needs **one trunk** carrying all the VLANs from the switch to the router.

- **Cable** the 1941 `Gi0/0` to a free SW01 port. *(In production `Gi0/0` is the MKT01 transit /30 — for the lab it becomes the SW01 trunk; that's why this is lab-session-only, run the 1941 during labs, not 24/7.)*
- **On SW01**, make that port a trunk matching the estate: `switchport mode trunk` · `switchport trunk encapsulation dot1q` · `switchport trunk native vlan 999` · `switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,999`.
- Have the [IP plan](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) open — every gateway is `10.<vlan>.0.1`, mask per VLAN.
- Console access to the 1941 (SSH may drop when you re-address `Gi0/0`).

**VLAN → gateway (from the IP plan) — what you'll type:**

| VLAN | Zone | Subnet | Mask (dotted) | 1941 subint gateway |
|---|---|---|---|---|
| 999 | native (no hosts) | — | — | `Gi0/0.999` (native, no IP) |
| 10 | Management | `10.10.0.0/27` | `255.255.255.224` | `10.10.0.1` |
| 20 | Servers (+T0) | `10.20.0.0/26` | `255.255.255.192` | `10.20.0.1` |
| 30 | Web/App | `10.30.0.0/28` | `255.255.255.240` | `10.30.0.1` |
| 40 | Monitoring | `10.40.0.0/28` | `255.255.255.240` | `10.40.0.1` |
| 50 | Clients | `10.50.0.0/25` | `255.255.255.128` | `10.50.0.1` |
| 60 | Deployment | `10.60.0.0/27` | `255.255.255.224` | `10.60.0.1` |
| 70 | Testing | `10.70.0.0/28` | `255.255.255.240` | `10.70.0.1` |
| 80 | DMZ | `10.80.0.0/28` | `255.255.255.240` | `10.80.0.1` |
| 90 | OT | `10.90.0.0/26` | `255.255.255.192` | `10.90.0.1` |

---

## 2. Router-on-a-stick — subinterfaces + gateways

🔴 **You type this on the 1941** (Charter Rule 17). The pattern is one subinterface per VLAN: `interface Gi0/0.<vlan>` → `encapsulation dot1q <vlan>` → `ip address <gateway> <mask>`. Worked for 999/10/20/50/70 below — **repeat the pattern for 30/40/60/80/90** from the table.

```
configure terminal
interface GigabitEthernet0/0
 no ip address
 no shutdown
!
interface GigabitEthernet0/0.999
 description Native (no hosts)
 encapsulation dot1q 999 native
!
interface GigabitEthernet0/0.10
 description VLAN10 Management - gateway
 encapsulation dot1q 10
 ip address 10.10.0.1 255.255.255.224
!
interface GigabitEthernet0/0.20
 description VLAN20 Servers - gateway
 encapsulation dot1q 20
 ip address 10.20.0.1 255.255.255.192
!
interface GigabitEthernet0/0.50
 description VLAN50 Clients - gateway
 encapsulation dot1q 50
 ip address 10.50.0.1 255.255.255.128
!
interface GigabitEthernet0/0.70
 description VLAN70 Testing - gateway
 encapsulation dot1q 70
 ip address 10.70.0.1 255.255.255.240
!
end
write memory
```

**✅ Verify (read the state back — `POL-0001`):**
- `show ip interface brief | include 0/0` → each `Gi0/0.<vlan>` shows its `.1`, `up/up`.
- `show ip route connected` → a directly-connected route per VLAN subnet (this is inter-VLAN routing — the router now has all the VLAN networks).
- From a **VLAN 50** host: `ping 10.50.0.1` (its gateway), then `ping 10.20.0.1` (another VLAN's gateway) → both reply.
- **Inter-VLAN, before ACLs:** a VLAN 50 host pings a VLAN 20 host → **succeeds** (open — you'll restrict it next).
- 📸 capture: `show ip route connected` + the two pings.

---

## 3. ACL exercise A — standard numbered

**Policy (from your ACL notes pattern):** *Testing (VLAN 70) must not reach Servers (VLAN 20); everything else is allowed.* Standard ACLs match **source only**, so place it **outbound, near the destination** — on `Gi0/0.20`.

```
configure terminal
access-list 10 deny  10.70.0.0 0.0.0.15
access-list 10 permit any
!
interface GigabitEthernet0/0.20
 ip access-group 10 out
end
```

**✅ Verify (your notes' method — review, then test, then count):**
- `show access-lists 10` → `10 deny 10.70.0.0, wildcard 0.0.0.15` · `20 permit any`.
- Test matrix:
  - VLAN 70 host → a VLAN 20 server: **ping fails** (denied).
  - VLAN 50 host → a VLAN 20 server: **ping succeeds** (permitted).
  - VLAN 70 host → a VLAN 50 host: **ping succeeds** (only →20 is blocked).
- `show access-lists 10` again → the **match counts** climb on the line you exercised (proof it's actually filtering).
- 📸 capture: `show access-lists 10` before/after the pings.

> 🔴 **Wildcard, not mask.** `/28` → wildcard `0.0.0.15`. The classic mistake is a subnet mask here. And the implicit `deny any` at the end is why you need `permit any` — without it, ACL 10 would block *all* traffic to VLAN 20.

---

## 4. ACL exercise B — extended named

**Policy (aligns with the [flows matrix](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) #3 Clients→Servers):** *Clients (VLAN 50) may reach Servers (VLAN 20) on **HTTPS 443 only**; deny other client→server traffic; everything else normal.* Extended ACLs match the 5-tuple, so place it **inbound, near the source** — on `Gi0/0.50`.

```
configure terminal
ip access-list extended CLIENTS-TO-SERVERS
 permit tcp 10.50.0.0 0.0.0.127 10.20.0.0 0.0.0.63 eq 443
 deny   ip  10.50.0.0 0.0.0.127 10.20.0.0 0.0.0.63
 permit ip  any any
!
interface GigabitEthernet0/0.50
 ip access-group CLIENTS-TO-SERVERS in
end
```

**✅ Verify:**
- `show access-lists CLIENTS-TO-SERVERS` → three ordered lines with sequence numbers.
- Test:
  - VLAN 50 host → `https://10.20.0.x` (server on 443): **works**; the `permit tcp … eq 443` count climbs.
  - VLAN 50 host → `ping 10.20.0.x`: **fails** (ICMP is not 443 → hits the `deny ip`).
  - VLAN 50 host → a VLAN 70 host: **works** (`permit ip any any`).
- 📸 capture: `show access-lists CLIENTS-TO-SERVERS` with match counts.

> 🔴 **`ping` proves ICMP, not the service.** A failed ping to :443 doesn't mean 443 is blocked — test the *real* protocol (browser / `telnet 10.20.0.x 443`). This is the `015` trap.

---

## 5. Revert to production

When the CCNA lab is done, hand routing + policy back to MKT01 (`ADR-0023` Option B):

```
configure terminal
no interface GigabitEthernet0/0.10
no interface GigabitEthernet0/0.20
no interface GigabitEthernet0/0.50
no interface GigabitEthernet0/0.70
no interface GigabitEthernet0/0.999
!  (repeat for any other VLAN subinterfaces you added)
no access-list 10
no ip access-list extended CLIENTS-TO-SERVERS
!
interface GigabitEthernet0/0
 description ->MKT01 transit /30
 ip address 10.255.255.5 255.255.255.252
 no ip proxy-arp
 no shutdown
end
write memory
```

- Re-cable `Gi0/0` to MKT01; restore **OSPF + the default route** per the [1941 Build-Guide](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Guide.md) Stage 3.
- The **VLAN `.1` gateways move to MKT01**; east-west policy is enforced there. Confirm the 1941 no longer owns any `10.<vlan>.0.1`.
- ✅ `show ip ospf neighbor` → MKT01 FULL again; `show ip route` → VLANs learned via `10.255.255.6`.

---

## Learn it — the Academy (expands this)
- 🔧 **Commands:** [`Command-Library · Cisco-IOS`](../Command-Library/Cisco-IOS.md) — §Routing (inter-VLAN, static/OSPF) · §Security (ACLs).
- 🏅 **Cert objectives:** trunking 2.1/2.2 · inter-VLAN 3.x · ACLs 5.6 — [Atlas-Certification-Lab-Map](../Certification/Atlas-Certification-Lab-Map.md).
- 📄 **Sources:** operator's `Trunking DTP VTP.txt` (router-on-a-stick) + `ACL …` notes; the [IP plan](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md) (gateways); the [flows matrix](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) (what the ACLs enforce).
- 🎯 **Prove it with real clients:** the VLAN-50 test-station fleet (Backlog #23).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-04 | Created (#44 arc). The 1941 CCNA-lab overlay — router-on-a-stick (subinterface gateways from the IP plan) + a standard and an extended ACL exercise (from the operator's ACL notes, grounded in Atlas VLANs + the flows matrix), with a revert-to-production (Option B) section. Operator types the config (Charter Rule 17). |
