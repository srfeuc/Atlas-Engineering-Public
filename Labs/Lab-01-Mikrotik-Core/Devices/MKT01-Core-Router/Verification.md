---
Title: MKT01 Verification Procedure
Path: Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router
---

# MKT01 Verification Procedure

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | 1.0 |
| Applies To | MKT01 (10.10.0.1 / bridgeLocal 10.0.0.1 — MikroTik RB1100AHx4 Dude Edition, core router) |
| Evidence Status | **Verified** — full read-only battery run against the live device 2026-07-16; every check matches `022` v2.8 |
| Last Run | 2026-07-16 |

## Purpose

The **reconcile-to-live** procedure for MKT01: prove the running router matches `022` (Build Record) and `026` (Build Guide), 🟡 → 🟢. Run before a Game Day (`ADR-0011`), after any change, or when a doc is in doubt.

**Read-only checks only.** Risks and open items live in `055-MKT01-Considerations-and-Risks.md`.

## How to run

MKT01 is RouterOS, not Linux/IOS. Connect via **SSH** (`ssh SethAdmin@10.10.0.1 -p 2222`) or **WinBox** (`:8291`), from VLAN 10 (`10.10.0.0/24`) or the bridgeLocal recovery net (`10.0.0.0/24`). Everything below is a `print` — **no `set`/`add`/`remove`, no config change.**

> 🔴 **No secrets.** Use `/radius print` (not `print detail` — the secret is write-only but don't risk it); for SNMP, confirm state but **do not paste the community string**. Nothing else here reveals a secret.
> 🔴 **Empty output is not a pass** (Rule 13). Re-run until you see real content.

## Verification battery

### A — Identity & platform (`022` Platform)

| Command | Expected |
|---|---|
| `/system identity print` | `MKT01` |
| `/system resource print` | RouterOS **7.23.1**, `board-name: RB1100AHx4 Dude Edition`, 1024 MiB RAM, ARM 4-core |
| `/system routerboard print` | serial `9BD90AB80B08`. 🔴 `current-firmware` **`6.42.10`** is behind RouterOS `7.23.1` — RouterBOOT upgrade pending (`055` row 12) |
| `/disk print` | 64 GB `FORESEE` SATA SSD, `sata1-part1`, **MOUNTED** |
| `/system ntp client print` | **synced**, `pool.ntp.org` — *client only, serves no time* |

### B — Interfaces, bridges, addressing (`022` Interfaces/Bridge/VLAN)

| Command | Expected |
|---|---|
| `/interface ethernet print` | `ether2` **disabled (X)** (`CM-0015`); **`ether5`–`ether13` disabled (X)** (`CM-0035`); `ether4` enabled (sole recovery port) |
| `/interface bridge print` | `bridgeLocal`, `bridge-trunk` |
| `/interface bridge port print` | 🔴 `ether3` on `bridge-trunk` with **`hw=no`** (RTL8367 requirement — verify after every reboot/firmware) |
| `/ip address print detail` | ether1 `172.16.0.2/29`; `bridgeLocal 10.0.0.1/24` with the **"ADMIN RECOVERY NETWORK — DO NOT REMOVE"** comment; VLAN gateways `10.{10..80}.0.1/24` |
| `/interface vlan print` | vlan10-mgmt … vlan80-dmz; `vlan70-testing` isolated (not in VLANs list); `vlan999-unused` no IP |

### C — Routing & firewall (`022` Routing/Firewall)

| Command | Expected |
|---|---|
| `/ip route print` | default `0.0.0.0/0` via `172.16.0.1` (ether1); connected routes for each VLAN + bridgeLocal |
| `/ip firewall filter print count-only` | **22** |
| `/ip firewall filter print` | 🔴 rule **20** forward catch-all **drop** `EAST-WEST-DENIED:`; rule **21** input catch-all **drop** `INPUT-DENIED:` — *load-bearing (RouterOS defaults ACCEPT)* |
| `/ip firewall nat print` | 🔴 **EMPTY — MKT01 does NO NAT** (device-verified 2026-07-16). FGT01 owns production NAT (`009`/`022`). *(The earlier scaffold's "masquerade out ether1" here was doc-derived and wrong.)* |

### D — Services, accounts, RADIUS, cert, DNS (`022` Management/RADIUS/DNS)

| Command | Expected |
|---|---|
| `/ip service print detail` | SSH `2222`, WinBox `8291`, www-ssl `443` — all restricted to `10.0.0.0/24` + `10.10.0.0/24`; telnet/ftp/www/api/api-ssl **disabled**. 🟢 The dynamic WinBox row (`D c`) is the operator's own live session (`remote=10.10.0.50`) — **artefact, not exposure** (resolved 2026-07-16) |
| `/user print` | `admin` **disabled (X)** (`CM-0034`); `SethAdmin` full |
| `/user aaa print` | `use-radius: yes`, `accounting: yes` |
| `/radius print` | single entry, `address=10.10.0.5`, `authentication-port=1812`, `require-message-auth` set *(secret not shown)* |
| `/certificate print detail` | `mikrotik-bundle.crt_0`, serial **1001**, SAN `DNS:mikrotik.lab, IP:10.10.0.1`; bound to `www-ssl` |
| `/ip dns print` | servers `10.10.0.5, 1.1.1.1, 8.8.8.8`; `allow-remote-requests: no` |

### E — Layer-2 management / recovery (`022` L2 Management State)

| Command | Expected |
|---|---|
| `/interface list member print where list=RECOVERY` | one member: **`bridgeLocal`** |
| `/tool mac-server mac-winbox print` | `allowed-interface-list: RECOVERY` |
| `/tool mac-server print` | `allowed-interface-list: none` (MAC-Telnet off — a recorded decision) |
| `/ip neighbor discovery-settings print` | 🔴 `discover-interface-list: static` — **the disclosure leak is OPEN** (`ADR-0016`) |
| `/snmp print` | 🟢 **`enabled: no`** — SNMP is OFF (device-verified 2026-07-16); no community exposure. **Do not run `/snmp community print`.** |

## Interpreting results

- **Device wins** (Rule 13). A mismatch is a finding for `055`.
- **MKT01's out-of-band is fragile** — no serial console; MAC-WinBox drops after ~15s (`055`). Do verification over SSH/WinBox on a stable session, and **never modify the `RECOVERY` interface list while riding a MAC-WinBox session.**

## Last-run record

| Date | Run by | Result | Output |
|---|---|---|---|
| 2026-07-16 | Seth | 🟢 **All A–E checks match `022` v2.8.** Firewall 22; `ether3` `hw=no`; `ether2`+`ether5-13` disabled; `use-radius: yes`; cert SAN `IP:10.10.0.1`; `admin` disabled; DNS `10.10.0.5/1.1.1.1/8.8.8.8`; NTP synced (stratum 1); **no NAT** (empty); SNMP off. One new finding: RouterBOOT firmware `6.42.10` < RouterOS `7.23.1` (`055` row 12). | pasted CLI session |

## Related pages

- Build Record: `022` · Build Guide: `026` · Troubleshooting: `041`
- **Considerations & Risks: `055-MKT01-Considerations-and-Risks.md`**
- 🔵 **Firewall architecture (MKT01 = east-west firewall in Book 11): `00-Atlas-Foundation/Atlas-Firewall-Architecture.md`**
- Change records: `CM-0034`, `CM-0035`, `CM-0009`, `CM-0015`–`CM-0018`, `MC-0002`, `ADR-0016`
