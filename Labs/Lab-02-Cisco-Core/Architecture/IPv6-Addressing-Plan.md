---
Title: Lab-02 IPv6 Addressing Plan (dual-stack, ULA)
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: 📋 PROPOSED — the dual-stack IPv6 plan (pairs with a proposed ADR "Adopt dual-stack IPv6"). Companion to `IP-Addressing-Plan-VLSM.md` (the IPv4 owner). Device-verified-first: each address is 🟡 until its `show ipv6` read-back is pasted (`POL-0001`).
Version: 0.1
Date: 2026-08-02
---

# Lab-02 — IPv6 Addressing Plan (dual-stack, ULA)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build).** The IPv6 half of the estate's addressing, run **dual-stack** alongside the IPv4 plan (`IP-Addressing-Plan-VLSM.md` stays authoritative for v4; this doc owns v6). Built as a **CCNA study rig** — it deliberately exercises the exam's IPv6 blueprint (address types, /64, EUI-64, SLAAC, DHCPv6, static routing, OSPFv3, verification). The IPv4 gateways live on MKT01 (`ADR-0023`); **the v6 gateways live on MKT01 too** — dual-stack changes addressing, not topology.

## The idea in one line

> **Mirror the IPv4 plan so every address maps 1:1.** IPv4 encodes the VLAN in the second octet (`10.<vlan>.0.0`); IPv6 encodes it in the **subnet field** of a single ULA /48, and the **host's v4 number becomes its v6 interface ID**. `10.20.0.2` ⇄ `fd42:a1b2:c3d4:20::2` — the same box, readable at a glance.

## 1. The estate prefix (ULA)

| Item | Value | Why |
|---|---|---|
| Estate prefix | **`fd42:a1b2:c3d4::/48`** | A **ULA** (`fd00::/8`) — the private-network v6 range. Internally routable, never internet-routed — the honest choice for a lab with no ISP v6 allocation. |
| Per-VLAN subnet | **`/64`** (always) | IPv6 subnets are `/64` — SLAAC/EUI-64 requires it. The IPv4 mask (`/25`, `/26`…) is irrelevant in v6; **every VLAN is a /64**, sized identically. |
| Subnet field | **= the VLAN number** | The 4th hextet is the VLAN, mirroring the v4 second octet (VLAN 20 → `…:20::/64`). |

> 🔴 **Real-world caveat (a CCNA point):** a ULA's 40-bit **Global ID** (the `42:a1b2:c3d4` part) must be **pseudo-randomly generated** per RFC 4193 — you don't get to pick a pretty one in production. This sample is kept semi-readable **on purpose for the lab**; regenerate a random /48 if this ever leaves the bench, and know the difference. *(Alternative for pure practice: the documentation prefix `2001:db8::/32` — but it's "examples only, never configure it for real," which is itself worth learning.)*

## 2. Per-VLAN /64 table (gateways on MKT01, `::1`)

| VLAN | Zone | IPv4 (for reference) | IPv6 /64 | Gateway (MKT01) | Host method |
|---|---|---|---|---|---|
| 10 | Management | `10.10.0.0/27` | `fd42:a1b2:c3d4:10::/64` | `…:10::1` | **static** (low IDs mirror v4) |
| 20 | Servers (T0/T1) | `10.20.0.0/26` | `fd42:a1b2:c3d4:20::/64` | `…:20::1` | **static** |
| 30 | Web / App | `10.30.0.0/28` | `fd42:a1b2:c3d4:30::/64` | `…:30::1` | **static** |
| 40 | Monitoring | `10.40.0.0/28` | `fd42:a1b2:c3d4:40::/64` | `…:40::1` | **static** |
| 50 | Clients (T2) | `10.50.0.0/25` | `fd42:a1b2:c3d4:50::/64` | `…:50::1` | **SLAAC** (RA from MKT01) |
| 60 | Deployment | `10.60.0.0/27` | `fd42:a1b2:c3d4:60::/64` | `…:60::1` | **DHCPv6 (stateful)** |
| 70 | Testing | `10.70.0.0/28` | `fd42:a1b2:c3d4:70::/64` | `…:70::1` | **DHCPv6 (stateless) + SLAAC** |
| 80 | DMZ | `10.80.0.0/28` | `fd42:a1b2:c3d4:80::/64` | `…:80::1` | **static** |
| 90 | OT isolation | `10.90.0.0/26` | `fd42:a1b2:c3d4:90::/64` | `…:90::1` | **static** (no autoconf — like v4) |

**The three host methods are deliberate — they cover the CCNA addressing objectives:**

- **Static** (infra/servers/OT) — the interface ID is the **v4 host number written the same way**: DC01 `10.20.0.2` → `…:20::2`; NetBox `10.20.0.11` → `…:20::11`. ⚠️ *Hex caveat (a real IPv6 lesson): hextets are hexadecimal, so `::11` is `0x11` = 17 decimal — we keep the **written** form matching v4 for readability, but `::10` ≠ decimal 10. Know it.*
- **SLAAC** (clients, VLAN 50) — MKT01 sends **Router Advertisements**; hosts self-assign from the /64 (EUI-64 or privacy addresses). This is the single most-tested v6 mechanism.
- **DHCPv6** (deployment/testing) — stateful (server hands out the full address) and stateless (SLAAC for the address + DHCPv6 for DNS/options). Run both to see the RA **M/O flags** in action.

## 3. Transit links & loopbacks (`…:ff00::/56` block, off the VLAN space)

| Purpose | IPv4 | IPv6 | Addresses |
|---|---|---|---|
| FGT01 ⇄ 1941 transit | `10.255.255.0/30` | **`/127`** `fd42:a1b2:c3d4:ff01::/127` | FGT01 `::`, 1941 `::1` |
| 1941 ⇄ MKT01 transit | `10.255.255.4/30` | **`/127`** `fd42:a1b2:c3d4:ff02::/127` | 1941 `::`, MKT01 `::1` |
| 1941 loopback | `10.255.0.1/32` | **`/128`** `fd42:a1b2:c3d4:ff00::1/128` | |
| MKT01 loopback | `10.255.0.2/32` | **`/128`** `fd42:a1b2:c3d4:ff00::2/128` | |

> **Why `/127` on point-to-point links** (RFC 6164): the v6 analogue of the v4 `/30` — two usable addresses, no waste, no NDP-exhaustion risk. *(Simpler lab alternative: a `/64` with `::1`/`::2`, or run OSPFv3 over link-local only and skip global transit addresses entirely — a good thing to try both ways.)*

## 4. Routing — add OSPFv3 (dual-stack)

- Enable **`ipv6 unicast-routing`** on the 1941 (IOS) — 🔴 **without it, nothing routes v6**, the #1 "why isn't this working" cause.
- Run **OSPFv3** between the 1941 and MKT01, alongside the existing OSPFv2 — same areas, same idea, separate process. Default route from FGT01 southbound.
- OSPFv3 **peers over link-local** (`fe80::`) and still needs an explicit **router-id** (a 32-bit dotted value — reuse the v4 loopback, e.g. `1.1.1.1`/`2.2.2.2`). Great teaching point: the neighbor's *next-hop* is a link-local address.

## 5. The enablers & gotchas (where IPv6 actually bites)

- 🔴 **Permit ICMPv6 on MKT01 and FGT01.** NDP (neighbor discovery = v6's ARP), RAs, and Path-MTU all ride ICMPv6 — filter it like v4 ICMP and **v6 breaks entirely**. This is a real east-west-firewall lesson.
- **RAs drive SLAAC.** MKT01 must *send* Router Advertisements on the client /64s (`ipv6 nd` settings; the **M** flag = use DHCPv6 for addresses, **O** flag = DHCPv6 for other options only).
- **NDP replaces ARP** — `show ipv6 neighbors` is your `show ip arp`.
- **DNS is dual-stack** — add **AAAA** records (Pi-hole + AD DNS serve them); clients then prefer v6 (Happy Eyeballs). No AAAA = you won't *see* v6 in use even when it works.
- **Link-local is automatic** — every interface gets an `fe80::` address the moment v6 is enabled, before you configure anything.

## 6. Verification — the read-back per platform (`POL-0001`)

| Platform | Devices | The reads |
|---|---|---|
| Cisco IOS | 1941, SW01 | `show ipv6 interface brief` · `show ipv6 route` · `show ipv6 ospf neighbor` · `show ipv6 neighbors` · `ping ipv6 <addr>` |
| RouterOS | MKT01 | `/ipv6 address print` · `/ipv6 route print` · `/ipv6 neighbor print` · `/ping <v6>` |
| FortiOS | FGT01 | `get system interface` · `diagnose ipv6 neighbor-cache list` · `execute ping6 <addr>` |
| Windows | DC01/02, servers | `Get-NetIPAddress -AddressFamily IPv6` · `Get-NetRoute -AddressFamily IPv6` · `ping -6 <addr>` · `Test-NetConnection <host>` |
| Linux | Pi01, PVE01/02, NetBox, SRV01, MON01 | `ip -6 addr` · `ip -6 route` · `ip -6 neighbor` · `ping6 <addr>` |

> ✅ only lands when the read-back is pasted (`POL-0001`). Add a Worked-log row per device as it's brought up.

## 7. Rollout — dual-stack, one device at a time (device-verified-first)

1. **Core first:** `ipv6 unicast-routing` on the 1941; v6 gateways (`::1`) on MKT01's VLAN interfaces; the two `/127` transit links. Prove with `ping ipv6` across each transit hop.
2. **OSPFv3** 1941 ⇄ MKT01; confirm `show ipv6 ospf neighbor` FULL and v6 routes learned.
3. **Static infra/servers** (VLANs 10/20/30/40/80/90): add the `::<v4host>` address per box; `ping ipv6` the gateway then across VLANs.
4. **SLAAC** on VLAN 50: turn on RAs at MKT01; confirm a client self-assigns (`ip -6 addr` / `Get-NetIPAddress`).
5. **DHCPv6** on VLANs 60/70: stateful then stateless; watch the M/O flags.
6. **Then the ACLs** (see the Academy lab below): once v6 is up, **IPv6 ACLs** (`ipv6 access-list` + `traffic-filter`) — no wildcard masks, prefix-length instead — enforce the same flows on both stacks.

## 8. CCNA coverage this rig exercises

Address **types** (GUA vs **ULA** vs link-local vs multicast) · the **/64** boundary · **interface IDs / EUI-64** · **SLAAC** · **stateless & stateful DHCPv6** (M/O flags) · **static IPv6 routing** · **OSPFv3** · **dual-stack** operation · **IPv6 ACLs** · and the full **`show ipv6 …` verification** family. That's essentially the whole CCNA IPv6 blueprint, on your own kit.

## Related

- `IP-Addressing-Plan-VLSM.md` (the IPv4 owner — this is its dual-stack sibling) · `Atlas-East-West-Allowed-Flows-Matrix.md` (the flows this filters, v4 and v6) · `ADR-0023` (1941 core / MKT01 gateways — unchanged by dual-stack).
- Academy: `../../../Atlas-Academy/Command-Library/Cisco-IOS.md` · `RouterOS.md` · `FortiOS.md` · `Linux.md` · `PowerShell-Tier0.md` (add the IPv6 verification sections) · `Atlas-Certification-Lab-Map.md` (CCNA — map the IPv6 objectives here).
- Pairs with a proposed **ADR "Adopt dual-stack IPv6 (ULA) across the estate"** (the decision + why ULA + why dual-stack) — to be written.

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-02 | Created (proposed). The dual-stack IPv6 plan mirroring the IPv4 VLSM scheme: a ULA /48, one /64 per VLAN (subnet field = VLAN), gateways on MKT01 (`::1`), static infra IDs = the v4 host number, SLAAC for clients, DHCPv6 for deployment/testing, `/127` transit + `/128` loopbacks, OSPFv3 alongside OSPFv2. Enablers/gotchas (ICMPv6, RAs, NDP, AAAA), per-platform verification reads, a device-verified-first rollout, and the CCNA blueprint mapping. 🟡 every address until its `show ipv6` read-back is pasted (`POL-0001`). |
