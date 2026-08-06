---
Title: 1941 Build Guide (Core Router) — executable procedure
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: Build Guide — the how‑to. Validated on Packet Tracer; applied + device-verified on the physical 1941 (IOS 15.5(3)M4 universalk9). Read state back at each stage (POL-0001 R-A1). Companion: `Build-Checklist` (the design/why).
Version: 1.2
Date: 2026-07-20
---

# 1941 — Build Guide (Core Router)

## Provenance & scope

Built and debugged on **Packet Tracer** (first on a 2811 stand-in, then the 1941 model), reconciled against the `Build-Checklist`. This guide is the **corrected, real-hardware procedure** — apply it to the physical 1941. It covers **Master-Build-Order Phase 2 scope**: base + hardening + the two routed /30s + OSPF. Management services (NTP / SNMPv3 / syslog to MON01) are **deferred to Phase 4/6** — a stub section is at the end.

The `Build-Checklist` is the *why* (role, design rules, failure modes); this is the *how* (ordered commands + read-back). Where they ever disagree, the checklist's intent wins (Rule 13).

## What Packet Tracer got wrong that the real 1941 will get right

Apply on hardware, but expect these differences from the PT run:

- **The hardening lines PT rejected are valid on real 15.x** — `no ip http server`, `no ip http secure-server`, `no ip source-route` all work on the physical 1941; the PT image just lacked those features. They're **uncommented** below.
- **`crypto key generate rsa` really generates a key** (PT sometimes stubbed it). With `modulus 2048` given inline it won't prompt. SSH is not actually on until this runs.
- **OSPF interop with MKT01 (RouterOS) is real** — PT is forgiving; hardware is not. If the adjacency sticks, it's almost always **MTU** (stuck at EXSTART/EXCHANGE → `ip ospf mtu-ignore` on both /30 ends, or match MTU) or **network-type/DR** (stuck at INIT/2-WAY). See failure modes in the checklist.
- **Passwords:** the guide uses placeholders. Set strong, **different** values for `enable secret` and the admin user, and never commit the real secrets (public-release sanitization plan).
- **Interfaces:** the 1941 uses `GigabitEthernet0/0` and `0/1` (not the 2811's Fa). ISR G2 interfaces are admin-down by default → the `no shutdown` lines matter.

---

## Prereqs
- [ ] Console access to the 1941; `show version` — record the IOS train (for the right CIS benchmark).
- [ ] Confirm Gi0/0 and Gi0/1 usable.
- [ ] Cabling per `Cabling-and-Port-Map`: Gi0/1 → FGT01 /30, Gi0/0 → MKT01 /30.

## Stage 1 — Base + hardening

```
configure terminal
hostname 1941
no ip domain lookup
ip domain-name atlas.lab
crypto key generate rsa modulus 2048
ip ssh version 2
!
enable secret <ENABLE_SECRET>
username ciscoadmin privilege 15 secret <ADMIN_SECRET>
service password-encryption
service timestamps log datetime msec
login block-for 30 attempts 3 within 500
banner motd # Admin Access Only #
!
no cdp run
no service pad
no ip http server
no ip http secure-server
no ip source-route
```

**Verify before moving on:** `show ip ssh` → *SSH Enabled, version 2.0* (proves the key generated). `show run | include http|cdp|source-route` → the `no` forms present.

## Stage 1b — Console & VTY lines (this is what actually enables SSH login)

🔴 The key + `ip ssh version 2` in Stage 1 do **not** let anyone in on their own — the vty lines must be told to accept SSH and authenticate against the local user. Without this step SSH is configured but unusable.

```
ip ssh time-out 60
ip ssh authentication-retries 3
line con 0
 exec-timeout 5 0
 logging synchronous
line vty 0 4
 exec-timeout 2 0
 logging synchronous
 login local
 transport input ssh
line vty 5 15
 exec-timeout 2 0
 logging synchronous
 login local
 transport input ssh
```

**Verify:** `show ip ssh` → *SSH Enabled - version 2.0*, timeout 60, retries 3. `show run | section line vty` → `login local` + `transport input ssh` on both ranges. Then actually **SSH in as `ciscoadmin`** from a management host to prove it end-to-end.

## Stage 2 — Interfaces (two routed /30s + loopback, NO VLANs)

```
interface g0/1
 description ->FGT01 transit /30
 ip address 10.255.255.2 255.255.255.252
 no ip proxy-arp
 no shutdown
!
interface g0/0
 description ->MKT01 transit /30
 ip address 10.255.255.5 255.255.255.252
 no ip proxy-arp
 no shutdown
!
interface loopback 0
 ip address 10.255.0.1 255.255.255.255
```

**Verify:** `show ip interface brief` → Gi0/0 = 10.255.255.5, Gi0/1 = 10.255.255.2, Lo0 = 10.255.0.1, all **up/up** (the /30s go up once the MKT01/FGT01 ends are live). No subinterfaces.

## Stage 3 — Routing (OSPF + default)

```
router ospf 1
 router-id 10.255.0.1
 network 10.255.0.1 0.0.0.0 area 0      ! Loopback0
 network 10.255.255.4 0.0.0.3 area 0    ! Gi0/0 -> MKT01 (adjacency forms HERE)
 network 10.255.255.0 0.0.0.3 area 0    ! Gi0/1 -> FGT01 transit
 passive-interface GigabitEthernet0/1   ! FGT01 = static-default, not OSPF (drop if FGT01 runs OSPF)
 default-information originate
!
ip route 0.0.0.0 0.0.0.0 10.255.255.1
```

> ⚠️ **Only the two /30s + loopback go in OSPF.** Do **not** add `network` statements for the VLAN subnets (10.10–10.80) — `network` enables OSPF on a *matching interface*, it doesn't advertise a route, and the 1941 has no VLAN interface. The VLANs are **learned from MKT01**. (This is the exact mistake caught on the PT build.)

**Verify:** `show ip ospf neighbor` → MKT01 **FULL**. `show ip route ospf` → VLAN subnets via `10.255.255.6`. `show ip route static` → default via `10.255.255.1`. `show ip protocols` → OSPF on the two /30s only, Gi0/1 listed passive.

## Stage 4 — Save

```
end
write memory
```
Then export for the record (`Device-Backup-Runbook`).

---

## Consolidated paste-in (real 1941, Phase-2 scope)

🔴 **Do NOT paste this as one blob.** Run `configure terminal` … `crypto key generate rsa modulus 2048` **first and let it finish** (it emits `[OK]` and can eat the next line if the terminal races — the 07-20 device lesson), then paste the remainder. Everything after the key is paste-safe.

```
configure terminal
hostname 1941
no ip domain lookup
ip domain-name atlas.lab
crypto key generate rsa modulus 2048
!  ↑ let this complete before continuing
ip ssh version 2
ip ssh time-out 60
ip ssh authentication-retries 3
enable secret <ENABLE_SECRET>
username ciscoadmin privilege 15 secret <ADMIN_SECRET>
service password-encryption
service timestamps log datetime msec
login block-for 30 attempts 3 within 500
banner motd # Admin Access Only #
no cdp run
no service pad
no ip http server
no ip http secure-server
no ip source-route
interface g0/1
 description ->FGT01 transit /30
 ip address 10.255.255.2 255.255.255.252
 no ip proxy-arp
 no shutdown
interface g0/0
 description ->MKT01 transit /30
 ip address 10.255.255.5 255.255.255.252
 no ip proxy-arp
 no shutdown
interface loopback 0
 ip address 10.255.0.1 255.255.255.255
router ospf 1
 router-id 10.255.0.1
 network 10.255.0.1 0.0.0.0 area 0
 network 10.255.255.4 0.0.0.3 area 0
 network 10.255.255.0 0.0.0.3 area 0
 passive-interface GigabitEthernet0/1
 default-information originate
ip route 0.0.0.0 0.0.0.0 10.255.255.1
line con 0
 exec-timeout 5 0
 logging synchronous
line vty 0 4
 exec-timeout 2 0
 logging synchronous
 login local
 transport input ssh
line vty 5 15
 exec-timeout 2 0
 logging synchronous
 login local
 transport input ssh
end
write memory
```

## Full validation read-back (POL-0001 R-A1 — status, not config)
- [ ] `show ip ssh` — enabled, v2.
- [ ] `show ip interface brief` — both /30s + Lo0 up/up.
- [ ] `show ip ospf neighbor` — MKT01 **FULL**.
- [ ] `show ip route` — VLANs via `10.255.255.6`, default via `10.255.255.1`.
- [ ] `ping 10.255.255.1` and `10.255.255.6` — both live.
- [ ] SSH in as `ciscoadmin` from a management host (proves `login local` + the key).
- [ ] Internal host `traceroute` to internet → host → MKT01 → **1941** → FGT01 → out.

## Deferred — Stage 5 (Phase 4/6, when MON01 + NTP exist)
- [ ] NTP client → `ADR-0020` source (temp upstream now; DC PDC-emulator later).
- [ ] SNMPv3 → MON01 (no v2c `homelab` community).
- [ ] `logging host` (syslog) → MON01.
- [ ] NetFlow export → MON01 collector.

## Related
- `Build-Checklist` (design/why + failure modes) · `Cabling-and-Port-Map` · `IP-Addressing-Plan-VLSM` · `ADR-0023` (role: routes, no VLANs) · `ADR-0005` (FGT01 egress) · `ADR-0020` (clocks) · `Master-Build-Order` Phase 2.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First executable Build Guide for the physical 1941, distilled from the Packet Tracer build: staged base+hardening → interfaces → OSPF+default, each with read-back; the corrected OSPF (two /30s + loopback only, `passive-interface Gi0/1`, no VLAN network statements); consolidated paste-in with placeholder secrets; PT-vs-hardware differences (http/source-route valid on real 15.x, crypto key really generates, OSPF/RouterOS MTU/network-type interop); mgmt services deferred to Phase 4/6. |
| 1.1 | 2026-07-20. **Added Stage 1b — Console & VTY lines** (device walk-through gap Seth caught): the vty `login local` + `transport input ssh` (+ `ip ssh time-out`/`authentication-retries`, con/vty `exec-timeout`/`logging synchronous`) was only in the consolidated paste-in, not in the staged flow — so following the stages left SSH keyed-but-unusable. Now an explicit step with its own read-back + an end-to-end SSH login test. |
| 1.2 | 2026-07-21. **Reconciliation pass — internal consistency, no new/unverified config.** Consolidated paste-in brought in line with the staged flow: (1) added the missing `ip ssh time-out 60` + `ip ssh authentication-retries 3` (present in Stage 1b and the verify read-back, but dropped from the all-in-one block); (2) added a 🔴 caution to run `crypto key generate rsa` on its own and let it finish before pasting the rest — the 07-20 device lesson (its `[OK]` prompt can eat the following line). OSPF/interfaces/Stage 1b already reflected the verified 07-20 fixes — unchanged. |
