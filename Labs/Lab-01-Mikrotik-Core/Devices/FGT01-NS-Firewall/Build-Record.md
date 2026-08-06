---
Title: FGT01 Build Record
Path: Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall
---

# FGT01 Build Record

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — reconciled to the live device 2026-07-16; **DEVICE CHECK D8/D9 resolved** (policy `srcaddr all` / no custom objects; `dmz` admin-up; UTM DBs stale; NTP synchronised) |
| Version | 2.1 |
| Applies To | Atlas 2.0 |
| Last Live Verification | 2026-07-16 |
| Last Reconciled | 2026-07-14 |

## Interfaces — Disabled

**Evidence Status: `Verified` — `show full-configuration system interface | grep -f "set status down"`, 2026-07-13.**

| Interface | Status | Recorded in |
|---|---|---|
| `wan2` | `set status down` | `CM-0004` |
| `internal` (factory hard-switch) | `set status down` — still holds `192.168.1.99`, the factory bootstrap address | `CM-0004` |
| `fortilink` | `set status down` | `CM-0004` |
| 🔴 **`modem`** | `set status down` | **NOTHING — found 2026-07-13** |

> 🔴 **`modem` appeared in no Atlas document at all.** Not in `CM-0004`, not in this Build Record, not in the Build Guide. **It is disabled — but nobody recorded that it should be**, so a rebuilt FGT01 would leave it at its factory default and nobody would notice.
>
> **It also carries a credential:**
>
> ```
> edit "modem"
>     set mode pppoe
>     set password ENC <redacted — encrypted PPPoE credential; do not reproduce in docs, per 018 secrets rule / CM-0014>
> ```
>
> An encrypted PPPoE credential on an undocumented interface. **Almost certainly factory noise — but it is a credential, it is in the running config, and it is in every config backup you take.** Recorded here so it stops being a surprise.

> **This Build Record was right and `CM-0004` was stale.** For a month, this page said *"unused interfaces — disabled"* while `CM-0004` said `Draft`. **The device settled it in favour of this page.** Charter Rule 13 — kind of evidence, not headcount.


## Platform

| Item | Value |
|---|---|
| Hardware | FortiGate 60E |
| Serial | FGT60ETK18099YR2 |
| FortiOS | v7.4.5 build2702 (GA.M) |
| Operation mode | NAT |
| VDOM mode | Multi-VDOM — root VDOM active |
| Hostname | FGT01 |
| Timezone | America/Chicago |

## Interfaces

| Interface | Alias | IP | Mode | allowaccess | Role |
|---|---|---|---|---|---|
| wan1 | WAN-HOME-ROUTER | DHCP (172.31.4.x) | DHCP | ping | wan |
| wan2 | — | DHCP, unused | DHCP | ping | wan |
| internal1 | TRANSIT-TO-LAB | 172.16.0.1/29 | Static | ping https ssh | lan |
| internal2 | MANAGEMENT | 10.10.0.254/24 | Static | ping https ssh | lan |
| internal3-7 | — | **up** (members of the `internal` hard-switch) | — | — | 🟢 **Break-glass recovery — do NOT disable** (`CM-0033`; device-verified up 2026-07-16) |
| internal | — | 192.168.1.99/24 (factory default) | Static | ping https ssh fabric | lan |
| fortilink | — | 10.255.1.1/24 (factory default) | Static | ping fabric | — |
| dmz | — | Factory default (10.10.10.1/24) | Static | ping https fabric | dmz |

> internal1 and internal2 were removed from the `internal` hardware switch during deployment using `config system virtual-switch`. Both show `type physical` in `show system interface`.
>
> 🟡 **FortiOS internal tunnel interfaces `naf.root`, `l2t.root`, `ssl.root` are `status: up` (`type tunnel`)** — device-verified 2026-07-16. Benign FortiOS internals, recorded here for completeness (`CM-0033`).

> 🔴 **Superseded 2026-07-14 (051 / B3).** An earlier version of this record described `internal`, `wan2` and `fortilink` as *left at factory defaults rather than disabled*. **The "Interfaces — Disabled" section above (`CM-0004`, device-verified) is authoritative: `wan2`, `internal`, `fortilink` and `modem` are all `set status down`.** `010` confirms the same. The contradictory prose was pre-`CM-0004` and is removed.
>
> 🔴 **Do not, however, disable the `internal` group's member ports `internal3`–`internal7`.** The live device reports them **UP**, and they are FGT01's only IP-based recovery path (`192.168.1.99`, per `003`/`048`). A disabled *group* is not a disabled *port* — see `016` lesson 15 and `CM-0033` (Draft). *(DEVICE CHECK D9 resolved 2026-07-16: `dmz` is admin-**up** at factory `10.10.10.1/24` — not disabled; still a factory relic to decide on (`CM-0033` F2). The 2015–2018 UTM databases are confirmed stale — Roadmap Critical Risk #2, no profiles applied. Both tracked in `059`.)*

## Routing Table (verified)

| Network | Via | Interface |
|---|---|---|
| 0.0.0.0/0 | Home router (wan1 gateway) | wan1 |
| 10.0.0.0/8 | 172.16.0.2 | internal1 |
| 172.16.0.0/29 | Connected | internal1 |
| 10.10.0.0/24 | Connected | internal2 |

## Address Objects

| Name | Subnet | Notes |
|---|---|---|
| Lab-Network | 10.0.0.0/8 | 🔴 **TARGET / does not currently exist on the device** (`ADR-0005`). If ever recreated: must be `/8` — a narrower scope silently breaks VLAN internet access (documented outage). |
| Transit-Link | 172.16.0.0/29 | 🔴 **TARGET / does not currently exist on the device** (`ADR-0005`). |

> These are the deferred scoped-policy objects, not current device state (D8).

## Firewall Policies (verified)

| ID | Name | Source Intf | Dest Intf | srcaddr | Action | NAT | Log |
|---|---|---|---|---|---|---|---|
| 1 | LAB-to-Internet | internal1 | wan1 | **all** | accept | enabled | all |

> 🔴 **`srcaddr` is `all` on the device — corrected 2026-07-14 (051 / B1).** This table previously showed the scoped design (`Lab-Network`, `Transit-Link`). **`ADR-0005` (live validation 2026-07-12, and an archived 2026-07-09 pull) confirms policy 1 uses `srcaddr all`, and the scoped address objects do not exist on the device.** Keeping `all` is a deliberate deferral per `ADR-0005`, not a gap. **Re-confirmed 2026-07-16 (`show firewall policy 1`, `get firewall address`): policy 1 is `srcaddr all` / `dstaddr all` / `service ALL` / no UTM, and no custom address objects exist. DEVICE CHECK D8 resolved.**

## Administration

| Item | Value |
|---|---|
| Admin account | admin |
| Trusted host 1 | 10.0.0.0/24 |
| Trusted host 2 | 10.10.0.0/24 |
| Trusted host 3 | 192.168.1.0/24 |
| Access profile | super_admin |

## DNS and NTP

| Item | Value |
|---|---|
| Primary DNS | 1.1.1.1 (interim) |
| Secondary DNS | 8.8.8.8 (interim) |
| Protocol | DNS-over-TLS (`set protocol dot`), server-hostname `globalsdns.fortinet.net` — confirmed 2026-07-12, more secure than plain DNS and previously undocumented |
| NTP | pool.ntp.org (interim) — 🟢 **synchronised, stratum 2, device-verified 2026-07-16** (`diagnose sys ntp status`; egress via wan1, not the down `fortilink`) |

## MAC Addresses

| Interface | MAC |
|---|---|
| internal1 | 00:00:5e:00:53:17 |
| internal2 | 00:00:5e:00:53:03 |

> internal2 MAC confirmed via `diagnose hardware deviceinfo nic internal2`. Required in SW01 STATIC-HOSTS as `0000.5e00.5315`.

## SW01 Connection

| SW01 Port | Mode | VLAN | Purpose |
|---|---|---|---|
| Gi1/0/6 | Access | 10 | FGT01 internal2 management |

## Known Deviations

| Item | Target | Current | Action |
|---|---|---|---|
| DNS | Windows Server AD DNS | 1.1.1.1/8.8.8.8 | Update after Windows Server deployed |
| NTP | Windows Server AD hierarchy | pool.ntp.org | Update after Windows Server deployed |
| DMZ interface | 10.80.0.x | Factory default 10.10.10.1/24 | Update when DMZ is built |
| Additional firewall policies | Full Atlas policy set | LAB-to-Internet only | Add via Change Records as services are deployed |
| Firewall policy scope | `srcaddr` = `Lab-Network`, `Transit-Link` (scoped address objects) | `srcaddr` = `all` | **Deliberately deferred — see ADR-0005.** Kept broad until network redundancy exists; not an unresolved gap, a conscious choice with a review trigger. |
| Lab CA certificate | Installed on FGT01 | ✅ **Installed** — `MC-0001` (Closed). SAN verified on the wire 2026-07-13 (`029`): `DNS:fortigate.lab, IP:10.10.0.254, IP:172.16.0.1`, `issuer=CN=Home Lab Intermediate CA`, valid to 2027-06-20. | ✅ **Closed** — `CM-0005` was Superseded by `MC-0001`. Uses the Pi01 OpenSSL Lab CA per `ADR-0003`. |

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Initial verified record. |
| 2.1 | 2026-07-14 reconciliation batch (051 Tier 3, B1–B4). Firewall policy 1 `srcaddr` corrected to the device value `all` (the scoped table was the deferred target per `ADR-0005`); `Lab-Network`/`Transit-Link` marked as non-existent target objects; removed the pre-`CM-0004` prose that contradicted the device-verified "Interfaces — Disabled" section; closed the Lab CA certificate deviation (installed via `MC-0001`, SAN verified). Device-gated omissions (`dmz` disabled state, UTM signature DBs, `internal3`–`internal7` recovery path) flagged for D8/D9 / `CM-0033`, not changed. |
| 2.2 | 2026-07-16 reconciliation to the live device (verification run, `058`). **DEVICE CHECK D8/D9 resolved:** policy 1 `srcaddr all`/`dstaddr all`/`service ALL`/no UTM re-confirmed; `dmz` recorded as admin-**up** (factory relic, not disabled); UTM DBs confirmed stale. `internal3‑7` row corrected from "Unassigned/Unused" to the device-verified break-glass recovery state. NTP recorded as **synchronised, stratum 2** (`diagnose sys ntp status`) — which **disproves `CM-0033`'s "clock broken" finding**; the tunnel interfaces added. Every table now matches the live device. |
