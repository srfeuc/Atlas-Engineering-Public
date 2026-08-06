---
Title: 1941 Build Checklist (Core Router)
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: Target Design — build checklist. You write the config; read state back (POL-0001 R-A1).
Version: 1.1
---

# 1941 — Build Checklist (Core Router)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`ADR-0023`):** the routed north‑south backbone between MKT01 and FGT01. Routes; **holds no VLANs**; does not filter east‑west. New Cisco 1941 (renewed), IOS 15.x. Companion: `Cabling-and-Port-Map`, `IP-Addressing-Plan-VLSM`, `Build-Guide` (the executable how‑to). Hardening source: CIS Cisco IOS Benchmark matched to your IOS train.
>
> 🔴 **You know Cisco best — so this is the one to trust your own read‑back over my syntax.** Ticks need the *status* output, not the config line (`POL-0001` R‑A1).

## Gate
- [ ] Console access; `show version` (record IOS train for the right CIS benchmark).
- [ ] Confirm 2 usable GigE ports (Gi0/0, Gi0/1). If you need more later, an EHWIC.

## Build steps

### 1. Base + hardening (CIS Cisco IOS)
- [ ] Hostname `1941`, `ip domain-name atlas.lab`, `crypto key generate rsa` (≥2048), **SSH v2 only**, `transport input ssh` on vty. (`no ip domain lookup` too — stops the DNS‑lookup hang on a mistyped command.)
- [ ] **No `ip http server` / `ip http secure-server`; no telnet.** `service password-encryption`, `enable secret`, named local admin (RADIUS later, `ADR-0004`). Give `enable secret` and the admin user **different** secrets.
- [ ] `login block-for … attempts …` (brute‑force), exec‑timeout on lines, `logging synchronous`, banner.
- [ ] Kill legacy attack surface: `no ip source-route`, `no ip proxy-arp` on the transit interfaces, `no service pad`, and **CDP off the transit links** (neither neighbor is Cisco — nothing to gain, info to leak).

### 2. Interfaces — two routed /30s, NO VLANs
- [ ] **Gi0/1 → FGT01**: `ip address 10.255.255.2 255.255.255.252` (`IP-Addressing-Plan-VLSM`; FGT01 = `.1`), `no shutdown`.
- [ ] **Gi0/0 → MKT01**: `ip address 10.255.255.5 255.255.255.252` (MKT01 = `.6`), `no shutdown`.
- [ ] **Loopback0**: `10.255.0.1/32` (OSPF router‑id).
- [ ] 🔴 **No subinterfaces, no `encapsulation dot1q`, no `switchport`** — the 1941 does not carry VLANs (`ADR-0023`). Inter‑VLAN routing lives on MKT01.

### 3. Routing (OSPF primary; static is the simpler fallback)
- [ ] **OSPF area 0**, `router-id 10.255.0.1`. Put the **two transit /30s and the loopback** into OSPF — **nothing else**:
```
router ospf 1
 router-id 10.255.0.1
 network 10.255.0.1 0.0.0.0 area 0      ! Loopback0
 network 10.255.255.4 0.0.0.3 area 0    ! Gi0/0 -> MKT01 (adjacency forms HERE)
 network 10.255.255.0 0.0.0.3 area 0    ! Gi0/1 -> FGT01 transit
 passive-interface GigabitEthernet0/1   ! FGT01 = static-default, not OSPF (drop this if FGT01 runs OSPF)
 default-information originate
```
- [ ] ⚠️ **Do NOT add `network` statements for the VLAN subnets (10.10–10.80).** A `network` statement *enables OSPF on an interface whose IP matches the range* — it does **not** advertise a route. The 1941 owns no VLAN interface, so those lines match nothing and do nothing. **MKT01 owns the VLAN SVIs, runs OSPF, and advertises them; the 1941 LEARNS them** over the adjacency and passes them toward FGT01.
- [ ] **Default route:** static default toward FGT01 (`ip route 0.0.0.0 0.0.0.0 10.255.255.1`) + `default-information originate` so MKT01 learns the default via OSPF.
- [ ] *(Fallback if you skip OSPF: static route for the internal supernet → MKT01 `10.255.255.6`, static default → FGT01 `10.255.255.1`; matching statics on FGT01/MKT01.)*
- [ ] *(Optional resilience — **floating static**: egress is single‑homed to FGT01, so **not** for the default route — there's no second path to fail to. The only place it helps is as a backup to OSPF on the MKT01 leg: `ip route 10.0.0.0 255.0.0.0 10.255.255.6 250` (AD 250, dormant behind OSPF). It rides the same cable, so it guards an OSPF‑process failure, **not** a link failure — be honest about that, `POL-0013`.)*
- [ ] **Keep paths symmetric** — request and reply both transit the 1941, or MKT01's stateful firewall breaks (Firewall‑Arch §3.1).

### 4. Management services
- [ ] **NTP** client to the `ADR-0020` source; **SNMPv3** → MON01; **syslog** → MON01. (No v2c `homelab` community.) *(Build when MON01/the NTP source exist — Phase 4/6.)*
- [ ] `copy running-config startup-config` + export (`Device-Backup-Runbook`).

## Validation — read the state back
- [ ] `show ip ospf neighbor` — adjacency with MKT01 **FULL**. *(If it's stuck: MTU mismatch, area, or network‑type — the usual OSPF‑to‑a‑non‑Cisco gotchas.)*
- [ ] `show ip route` — the VLAN subnets present **via MKT01** (`10.255.255.6`), a **default via FGT01** (`10.255.255.1`).
- [ ] `show ip interface brief` — both `/30`s + Loopback0 up/up, no subinterfaces.
- [ ] `ping 10.255.255.1` (FGT01) and `10.255.255.6` (MKT01) — both /30s live.
- [ ] From an internal host: `traceroute` to the internet shows host → MKT01 → 1941 → FGT01 → out.
- [ ] `show ntp status` — synchronized (not `show run`).

## Failure modes
- 🔴 **OSPF `network` statements list the transit /30s, not the VLANs** — VLANs are *learned* from MKT01, not originated here. Symptom of getting it backwards: `show ip ospf neighbor` is empty (Gi0/0 never entered OSPF) and no VLAN routes appear. `network` enables OSPF on matching interfaces; it does not advertise subnets.
- 🔴 **Asymmetric / missing return route** — MKT01's stateful inspection silently drops half‑seen flows. Keep it symmetric.
- 🔴 **No `default-information originate`** — internal traffic blackholes toward the internet with no obvious error.
- 🔴 **Adding a VLAN subinterface "to help"** — steals the inter‑VLAN gateway role from MKT01 and breaks Option B.
- 🔴 **OSPF adjacency stuck** — MTU / area / network‑type mismatch with the MKT01 side.
- **Telnet/HTTP or CDP left on the transit** — CIS fails and needless leakage.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Build checklist for the new Cisco 1941 as the Lab-02 core router (`ADR-0023`): SSH-only base + CIS IOS hardening, the two routed /30s to FGT01 and MKT01 (no VLANs/subinterfaces), OSPF area 0 with `default-information originate` (static fallback documented), loopback router-id, NTP/SNMPv3/syslog to MON01, with read-back validation and the asymmetric-route / missing-default / stray-subinterface failure modes. Hardening source: CIS Cisco IOS Benchmark (match the train). |
| 1.1 | 2026-07-20. Step 3 hardened after a PT build surfaced the trap: replaced "include both /30s and the loopback" with the **literal `network` lines** (two /30s + loopback) + `passive-interface Gi0/1`; added an explicit ⚠️ not to add VLAN-subnet `network` statements (the classic "network advertises a route" misconception — it enables OSPF on a *matching interface*), plus the matching failure mode. Noted the floating-static decision (single-homed → not for the default; optional AD-250 backup on the MKT01 leg). Added `no ip domain lookup` and "different enable/admin secrets" to Step 1; marked mgmt services as Phase 4/6. Companion `Build-Guide` added. |
