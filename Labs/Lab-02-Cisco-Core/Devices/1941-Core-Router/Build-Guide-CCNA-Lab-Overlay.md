---
Title: 1941 Build Guide — CCNA Lab Overlay (Router-on-a-Stick + ACLs)
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: 🟡 LAB OVERLAY BUILD GUIDE (`ADR-0023` Option A — the sanctioned CCNA/IOS learning vehicle). **Temporary** overlay on the 1941, separate from the production `Build-Guide.md` (Option B, routes-only). You type the config (Charter Rule 17); read state back (`POL-0001` R-A1). Companion evidence: `Build-Record-CCNA-Lab-Overlay.md`.
Version: 0.1
Date: 2026-08-05
Scope: Lab-02
---

# 1941 — Build Guide: CCNA Lab Overlay (Router-on-a-Stick + ACLs)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE)** — Host: **1941** (ISR G2, IOS 15.5(3)M4) — a **temporary CCNA-lab overlay**: inter-VLAN routing (router-on-a-stick) + ACLs. CCNA objectives exercised: **2.1/2.2** trunking · **3.x** inter-VLAN routing · **5.6** ACLs.

> **What this is.** The **executable procedure of record** for the CCNA overlay — a full standalone build (base assumptions → subinterfaces → ACLs → validation → revert), in the estate Build-Guide shape. It is the **target/intent**; the read-back reality lands in [`Build-Record-CCNA-Lab-Overlay.md`](./Build-Record-CCNA-Lab-Overlay.md) (a Record outranks a Guide; the device outranks both — Charter Rule 13). The ⭐ Academy Playbook [`Set-Up-the-1941-for-the-CCNA-Lab`](../../../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) is the **teaching companion** (the why + the exercises); this guide and that Playbook carry the same config on purpose (operator decision, 2026-08-05) — **keep them in sync** if either changes.

## 🔴 Read first — this is a *temporary* overlay, not the production build

The 1941's **production** role is **routes-only, no VLANs** — MKT01 owns inter-VLAN routing + the east-west firewall ([`ADR-0023`](../../../../00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) **Option B**, the target in [`Build-Checklist.md`](./Build-Checklist.md) and the production [`Build-Guide.md`](./Build-Guide.md)). For the CCNA lab you temporarily run **Option A — router-on-a-stick on the 1941**, which `ADR-0023` **explicitly keeps** as "the CCNA/IOS learning vehicle." So this is **sanctioned, not a violation** of the no-VLANs rule — do **not** let a future session "fix" the subinterfaces back out (that intent is recorded on the [`Considerations`](./Considerations.md) CCNA-overlay note). When the lab is done, **[revert](#7-rollback--revert-to-production-option-b)** and hand inter-VLAN + policy back to MKT01.

> 🔴 **One `.1` gateway per VLAN at a time.** During the lab the **1941 holds each VLAN's `.1` gateway** — the same `.1` the [IP plan](../../Architecture/IP-Addressing-Plan-VLSM.md) assigns to MKT01 in production. Only one device can own `.1` at once. MKT01's inter-VLAN role isn't live yet, so there's no conflict today — but **never run both as `.1` simultaneously** (duplicate-gateway).

---

## 1. Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 Overlay guide — authored 2026-08-05; **not yet applied to hardware** (read-backs land in the Build-Record) |
| Version | 0.1 |
| Applies To | Atlas 2.0 · the physical 1941 (IOS 15.5(3)M4) |
| Role decision | [`ADR-0023`](../../../../00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) Option A (temporary) → Option B (production target) |
| Config authority | **Operator types it** (Charter Rule 17); evidence read back per `POL-0001` |

## 2. Purpose

Give the 1941 a **temporary inter-VLAN + ACL configuration** so the CCNA hands-on objectives (trunking, router-on-a-stick, standard & extended ACLs) can be practiced on **real IOS** against the real Atlas VLAN plan — then cleanly reverted to the production routes-only design.

## 3. Design Philosophy

- **Router-on-a-stick**: one trunk from SW01 carries every VLAN to the 1941; the router terminates each VLAN on a **subinterface** that holds that VLAN's `.1` gateway. One physical link, all VLANs — the CCNA inter-VLAN pattern.
- **Real values, never placeholders**: gateways and masks come from the [IP plan](../../Architecture/IP-Addressing-Plan-VLSM.md); the ACLs enforce real rows from the [east-west flows matrix](../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md).
- **Temporary + reversible**: every change here has a matching line in §7 Rollback. The overlay is run **during lab sessions**, not 24/7 (power/heat, and `Gi0/0` is borrowed from the MKT01 transit).

## 4. Prerequisites

- [ ] **Console** access to the 1941 (SSH may drop when you re-address `Gi0/0`).
- [ ] The 1941 base + hardening from the production [`Build-Guide.md`](./Build-Guide.md) Stage 1/1b is already applied (SSH, named admin, vty). This overlay only changes `Gi0/0` + adds ACLs.
- [ ] A **trunk from SW01** to the 1941's `Gi0/0` (see §5).
- [ ] The [IP plan](../../Architecture/IP-Addressing-Plan-VLSM.md) open — every gateway is `10.<vlan>.0.1`, mask per VLAN.

## 5. Required Information — VLAN → gateway (from the IP plan)

🔗 **Intent home:** [`IP-Addressing-Plan-VLSM`](../../Architecture/IP-Addressing-Plan-VLSM.md) (`POL-0008`). Restated here as the values to type.

| VLAN | Zone | Subnet | Mask (dotted) | 1941 subinterface gateway |
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

## 6. Implementation

> 🔴 **You type this on the 1941** (Charter Rule 17). Work stage by stage and **read each stage back before moving on** (`POL-0001`).

> 📸 **Screenshot discipline.** Capture a screen after **every `show`/verify and every major change**. The **`SS-##`** slots below are the capture points — paste each into [`Build-Record-CCNA-Lab-Overlay`](./Build-Record-CCNA-Lab-Overlay.md) §3 (they map 1:1). A change you didn't screenshot is a change you can't prove (`POL-0001`).

### Stage 1 — The trunk from SW01 (prerequisite)

Router-on-a-stick needs **one trunk** carrying all VLANs from the switch to the router.

- **Cable** the 1941 `Gi0/0` to a free SW01 port. *(In production `Gi0/0` is the MKT01 transit /30 — for the lab it becomes the SW01 trunk; this is why the overlay is lab-session-only.)*
- **On SW01**, make that port a trunk matching the estate:
  - `switchport trunk encapsulation dot1q`
  - `switchport mode trunk`
  - `switchport trunk native vlan 999`
  - `switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,999`

**✅ Verify:** `show interfaces trunk` on SW01 → the port is `trunking`, native `999`, allowed VLANs `10,20,30,40,50,60,70,80,90,999`.

> 📸 **SS-01** — `show interfaces trunk` (SW01).

### Stage 2 — Router-on-a-stick (subinterfaces + gateways)

The pattern is one subinterface per VLAN: `interface Gi0/0.<vlan>` → `encapsulation dot1q <vlan>` → `ip address <gateway> <mask>`. The native VLAN (999) carries no IP.

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
interface GigabitEthernet0/0.30
 description VLAN30 Web-App - gateway
 encapsulation dot1q 30
 ip address 10.30.0.1 255.255.255.240
!
interface GigabitEthernet0/0.40
 description VLAN40 Monitoring - gateway
 encapsulation dot1q 40
 ip address 10.40.0.1 255.255.255.240
!
interface GigabitEthernet0/0.50
 description VLAN50 Clients - gateway
 encapsulation dot1q 50
 ip address 10.50.0.1 255.255.255.128
!
interface GigabitEthernet0/0.60
 description VLAN60 Deployment - gateway
 encapsulation dot1q 60
 ip address 10.60.0.1 255.255.255.224
!
interface GigabitEthernet0/0.70
 description VLAN70 Testing - gateway
 encapsulation dot1q 70
 ip address 10.70.0.1 255.255.255.240
!
interface GigabitEthernet0/0.80
 description VLAN80 DMZ - gateway
 encapsulation dot1q 80
 ip address 10.80.0.1 255.255.255.240
!
interface GigabitEthernet0/0.90
 description VLAN90 OT - gateway
 encapsulation dot1q 90
 ip address 10.90.0.1 255.255.255.192
!
end
write memory
```

**✅ Verify (read the state back — `POL-0001`):**
- `show ip interface brief | include 0/0` → each `Gi0/0.<vlan>` shows its `.1`, `up/up`.
- `show ip route connected` → a directly-connected route per VLAN subnet (this **is** inter-VLAN routing — the router now holds every VLAN network).
- From a **VLAN 50** host: `ping 10.50.0.1` (its gateway), then `ping 10.20.0.1` (another VLAN's gateway) → both reply.
- **Inter-VLAN, before ACLs:** a VLAN 50 host pings a VLAN 20 host → **succeeds** (open — you restrict it next).

> 📸 **Capture (→ Build-Record §3):** **SS-02** `show ip interface brief | include 0/0` (subinterfaces up/up — the major change) · **SS-03** `show ip route connected` · **SS-04** the VLAN-50 → VLAN-20 pings (pre-ACL).

### Stage 3 — ACL exercise A (standard, numbered)

**Policy:** *Testing (VLAN 70) must not reach Servers (VLAN 20); everything else allowed.* Standard ACLs match **source only** → place it **outbound, near the destination**, on `Gi0/0.20`.

```
configure terminal
access-list 10 deny  10.70.0.0 0.0.0.15
access-list 10 permit any
!
interface GigabitEthernet0/0.20
 ip access-group 10 out
end
```

**✅ Verify (review → test → count):**
- `show access-lists 10` → `10 deny 10.70.0.0, wildcard 0.0.0.15` · `20 permit any`.
- Test matrix:
  - VLAN 70 host → a VLAN 20 server: **ping fails** (denied).
  - VLAN 50 host → a VLAN 20 server: **ping succeeds** (permitted).
  - VLAN 70 host → a VLAN 50 host: **ping succeeds** (only →20 is blocked).
- `show access-lists 10` again → **match counts climb** on the exercised line (proof it's filtering).

> 📸 **Capture (→ Build-Record §3):** **SS-05** `show access-lists 10` (before the test) · **SS-06** `show access-lists 10` (after — the match-count delta) · **SS-07** the deny/permit ping matrix.

### Stage 4 — ACL exercise B (extended, named)

**Policy** (matches [flows matrix](../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) #3 Clients→Servers): *Clients (VLAN 50) may reach Servers (VLAN 20) on **HTTPS 443 only**; deny other client→server traffic; everything else normal.* Extended ACLs match the 5-tuple → place **inbound, near the source**, on `Gi0/0.50`.

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

> 📸 **Capture (→ Build-Record §3):** **SS-08** `show access-lists CLIENTS-TO-SERVERS` (with match counts) · **SS-09** the 443-works / ping-fails test.

---

## Validation — full read-back (POL-0001 R-A1 — status, not config)

- [ ] `show interfaces trunk` (SW01) — the router port trunking, native 999, all VLANs allowed.
- [ ] `show ip interface brief | include 0/0` — every `Gi0/0.<vlan>` up/up with its `.1`.
- [ ] `show ip route connected` — a connected route per VLAN subnet.
- [ ] Inter-VLAN ping (VLAN 50 → VLAN 20 gateway, and host→host) before ACLs — succeeds.
- [ ] `show access-lists 10` — the standard ACL, with match counts after the test.
- [ ] `show access-lists CLIENTS-TO-SERVERS` — the extended ACL, with match counts.
- [ ] The two ACL test matrices behave as specified (deny/permit as designed).

## Common Mistakes

- 🔴 **Wildcard, not subnet mask, in an ACL.** `/28` → wildcard `0.0.0.15`; `/25` → `0.0.0.127`; `/26` → `0.0.0.63`. Typing a subnet mask is the classic slip.
- 🔴 **Forgetting the implicit `deny any`.** Every ACL ends with an invisible `deny any` — that's why standard ACL 10 needs `permit any`, or it would block *all* traffic to VLAN 20.
- 🔴 **`ping` proves ICMP, not the service** (the `015` trap). A failed ping to a 443-only host doesn't mean 443 is blocked — test the real protocol (browser / `telnet 10.20.0.x 443`).
- 🔴 **Standard ACL placed near the source.** Standard ACLs match source only → place them **outbound near the destination**, or you over-block.
- 🔴 **Duplicate gateway.** Never let the 1941 and MKT01 both own a `10.<vlan>.0.1` at once.
- 🔴 **Missing subinterface `no shutdown`.** The parent `Gi0/0` must be `no shutdown`; subinterfaces follow the parent — if the parent is down, every VLAN gateway is down.

## Lessons Learned from Actual Deployment

> 🟡 **Pending first run.** Capture the real gotchas here after applying on hardware (e.g. did SSH drop on the `Gi0/0` re-address? did the SW01 native-VLAN match? any dot1q/encapsulation surprises?). Mirror the confirmed read-backs into [`Build-Record-CCNA-Lab-Overlay.md`](./Build-Record-CCNA-Lab-Overlay.md). Do not invent output.

## 7. Rollback — revert to production (Option B)

When the CCNA lab is done, hand routing + policy back to MKT01 (`ADR-0023` Option B):

```
configure terminal
no interface GigabitEthernet0/0.10
no interface GigabitEthernet0/0.20
no interface GigabitEthernet0/0.30
no interface GigabitEthernet0/0.40
no interface GigabitEthernet0/0.50
no interface GigabitEthernet0/0.60
no interface GigabitEthernet0/0.70
no interface GigabitEthernet0/0.80
no interface GigabitEthernet0/0.90
no interface GigabitEthernet0/0.999
!
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

- Re-cable `Gi0/0` to MKT01; restore **OSPF + the default route** per the production [`Build-Guide.md`](./Build-Guide.md) Stage 3.
- The **VLAN `.1` gateways move to MKT01**; east-west policy is enforced there. Confirm the 1941 no longer owns any `10.<vlan>.0.1`.
- **✅ Revert verify:** `show ip ospf neighbor` → MKT01 **FULL** again; `show ip route` → VLANs learned via `10.255.255.6`; `show ip interface brief` → no `Gi0/0.<vlan>` subinterfaces remain.

> 📸 **Capture (→ Build-Record, revert session):** **SS-10** `show ip ospf neighbor` (MKT01 FULL) · **SS-11** `show ip route` (VLANs via `10.255.255.6`, no subinterfaces).

## 8. Completion Checklist

- [ ] Overlay applied; all Stage-2/3/4 read-backs captured into the Build-Record (🟡→✅).
- [ ] Both ACL test matrices pass.
- [ ] Considerations CCNA-overlay note current; this guide + the ⭐ Playbook in sync.
- [ ] **On lab teardown:** §7 revert applied and verified (1941 back to Option B; MKT01 owns the gateways).

## Next Guide

Production restore → the routes-only [`Build-Guide.md`](./Build-Guide.md) (Option B); east-west policy → MKT01 (the [east-west flows matrix](../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md)).

## Related

- Evidence: [`Build-Record-CCNA-Lab-Overlay.md`](./Build-Record-CCNA-Lab-Overlay.md) · teaching: ⭐ [`Set-Up-the-1941-for-the-CCNA-Lab`](../../../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md).
- Production: [`Build-Guide.md`](./Build-Guide.md) · [`Build-Checklist.md`](./Build-Checklist.md) · overlay note: [`Considerations.md`](./Considerations.md) · checks: [`Diagnostics.md`](./Diagnostics.md).
- Facts: [`IP-Addressing-Plan-VLSM`](../../Architecture/IP-Addressing-Plan-VLSM.md) · [`Lab-02-Per-Device-Config-Design-Checklists`](../../Architecture/Lab-02-Per-Device-Config-Design-Checklists.md) (its 1941 section → this Build-Guide's content) · [`Atlas-East-West-Allowed-Flows-Matrix`](../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) · [`Cabling-and-Port-Map`](../../Architecture/Cabling-and-Port-Map.md).
- Academy: [`Command-Library · Cisco-IOS`](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) (§Routing inter-VLAN · §Security ACLs — Domains 3/5) · [`Atlas-Certification-Lab-Map`](../../../../Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md) (2.1/2.2 · 3.x · 5.6).
- `ADR-0023` (the 1941 role) · [`Atlas-Workflow` §1 source priority](../../../../00-Atlas-Foundation/Governance/Atlas-Workflow.md).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-05 | Created (#44 arc). The 1941 CCNA-lab **overlay** Build-Guide — a full standalone executable procedure (trunk prereq → router-on-a-stick subinterfaces for all VLANs from the IP plan → standard & extended ACL exercises → validation → revert-to-Option-B), in the estate Build-Guide shape. Separate from the production `Build-Guide.md` (operator decision, 2026-08-05, reconciled in `Considerations` §Decided). Carries the same config as the ⭐ Playbook by design — kept in sync. Operator types the config (Charter 17); read-backs land in `Build-Record-CCNA-Lab-Overlay.md`. |
