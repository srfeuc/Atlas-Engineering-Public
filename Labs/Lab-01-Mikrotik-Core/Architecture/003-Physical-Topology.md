---
Title: Physical Topology
Path: Labs/Lab-01-Mikrotik-Core/Architecture
---

# Physical Topology

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Architecture

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | **Verified** — port assignments reconciled against `023-SW01-Build-Record.md` (live, 2026-07-12) |
| Evidence Source | SW01 live port table; `029-Pi01-Build-Record.md` |
| Last Verified | 2026-07-13 |
| Version | 2.0 |

> **Print this page.** During a rebuild you will have no network, no Confluence, and no ability to look anything up. This is the one page that must exist on paper.

## Production Connections

| Device A | Interface | Device B | Interface | VLAN / Mode | Purpose |
|---|---|---|---|---|---|
| Home / ISP Router | LAN | **FGT01** | `wan1` | DHCP | Internet handoff |
| **FGT01** | `internal1` | **MKT01** | `ether1` | Routed | Transit, `172.16.0.0/29` |
| **FGT01** | `internal2` | **SW01** | `Gi1/0/6` | Access, VLAN 10 | FortiGate management |
| **MKT01** | `ether3` | **SW01** | `Gi1/0/1` | **Trunk, native 999** | Tagged VLAN trunk |
| **MKT01** | `ether4`–`ether13` | Admin workstation | NIC | `bridgeLocal` `10.0.0.0/24` | **Recovery network** |
| **SW01** | `Gi1/0/2` | LabComputer | NIC | Access, VLAN 10 | |
| **SW01** | `Gi1/0/3` | *(nothing)* | — | **Disabled** | Pending device assignment — ADR-0002 / CM-0003 |
| **SW01** | `Gi1/0/4` | **PVE01** | `eno1` | **Trunk, native 10** | Hypervisor trunk |
| **SW01** | `Gi1/0/5` | Analyzer | NIC | SPAN destination | Mirrors Gi1/0/1. Usually unplugged. |
| **SW01** | `Gi1/0/7` | **Pi01** | NIC | Access, VLAN 10 | DNS, CA, RADIUS, Vaultwarden |
| **SW01** | `Gi1/0/8`–`48` | — | — | VLAN 999, shutdown | |
| **SW01** | `Gi1/0/49`–`52` | — | — | SFP, shutdown | |
| SW01 `Gi1/0/4` | PVE01 shared LOM | **iDRAC (PVE01)** | **Shared with `eno1`** | VLAN 10, `10.10.0.100/24` | ✅ **Resolved 2026-07-13 — shared LOM, no separate cable** |

### Corrections made 2026-07-13

The previous version of this table was **wrong on two rows and missing two more**:

| Was | Actually |
|---|---|
| `Gi1/0/2 → Raspberry Pi` | **`Gi1/0/7 → Pi01`.** The Pi was moved. `Gi1/0/2` is LabComputer. |
| `Gi1/0/3 → Admin workstation` | **`Gi1/0/3` is administratively disabled** (ADR-0002 / CM-0003). The workstation connects via `bridgeLocal`. |
| *(absent)* | `Gi1/0/7` did not appear at all |
| ~~*(absent)*~~ | **RESOLVED — iDRAC is on the shared LOM via `Gi1/0/4`, not a dedicated NIC. There is no separate cable.** |

> ✅ **RESOLVED 2026-07-13 — and the premise was wrong.** iDRAC does **not** have a dedicated NIC. `ipmitool lan print 1` reported MAC `00:00:5e:3f:f6:a4`, and `ip a` showed the R410's three NIC MACs are sequential — `eno1 …a2`, `eno2 …a3`, `iDRAC …a4` — one card, **iDRAC in shared/LOM mode.** It rides `eno1`'s cable on switch port `Gi1/0/4`. **There was no missing cable. The three-session hunt was for a port that does not exist.**
>
> 🔴 **Consequence — iDRAC is NOT out-of-band.** Sharing `eno1`'s NIC means it dies when `eno1`'s link fails, when `Gi1/0/4` is misconfigured, or when **SW01 is wiped — which is step one of any teardown.** Out-of-band management that depends on the in-band network is not out-of-band. The R410 has an unused dedicated iDRAC port on the back panel; **moving iDRAC to it is a real improvement — see `CM-0011` / the NIC-move ADR.** Until then, `048` must not present iDRAC as a reliable bootstrap path. See also `CM-0012` (the BMC's settings are non-durable while the CMOS battery is failing).

## The Two Native VLANs Are Different On Purpose

| Trunk | Native VLAN | Why |
|---|---|---|
| **Gi1/0/1** → MKT01 | **999** | The trunk carries **only tagged** traffic. Native 999 (unused) means any untagged frame lands in a black hole — which is what you want. |
| **Gi1/0/4** → PVE01 | **10** | PVE01's `vmbr0` sends its **management traffic untagged.** Native VLAN 10 classifies those frames into Management, where `10.10.0.10` lives. VM workloads use *tagged* virtual NICs and are unaffected. |

> **Making these consistent breaks PVE01.** With native 999 on Gi1/0/4, PVE01's untagged management frames land in the unused VLAN and the host becomes unreachable. **This already happened once.** It is documented in `036-PVE01-Troubleshooting-Guide.md` and `039-SW01-Troubleshooting-Guide.md` from both sides.

## Bootstrap Access — Reaching a Device With No Network

**Every entry below works with zero network configuration.** This table is why the page gets printed.

| Device | Method | Settings |
|---|---|---|
| **SW01** | Serial console | **9600 baud**, 8N1, no flow control. **Not 115200** — that gives garbage. |
| **MKT01** | 🟢 **WinBox → Neighbors → connect by MAC. Cable into any `bridgeLocal` port (`ether4`–`ether13`).** | ✅ **BUILT AND TESTED 2026-07-14 (`CM-0018`).** It had **never worked before** — `mac-winbox` was `none` since the build. Now scoped to the `RECOVERY` list (`bridgeLocal`). 🔴 **KNOWN LIMIT: the session CONNECTS, then DROPS after ~15 seconds.** It is a break-glass transport, not a management session. **Get in, set an IP, switch to a real session. Type fast and know what you are typing.** 🔴 **MKT01 has NO serial console** — three USB-serial adapters were bought and none worked; deferred by `ADR-0016`. **Run WinBox as Administrator** or file uploads fail. |
| **FGT01** | `https://192.168.1.99` | On the `internal` hard-switch ports (**internal3–7**). Laptop static `192.168.1.10/24`. Console fallback: 9600 8N1. |
| **PVE01** | **Physical console/keyboard first.** iDRAC (`https://10.10.0.100`) only if SW01 and `Gi1/0/4` are already up. | 🔴 **iDRAC is on the shared LOM — it dies with SW01. It is NOT independent out-of-band management.** Do not rely on it during a teardown. See `CM-0011`. |
| **Pi01** | Physical keyboard + HDMI | SSH is key-only on **port 2222**. It will not exist on a fresh build. |

> 🔴 **CORRECTED 2026-07-14.** This previously read: *"The MikroTik MAC-connect is the keystone of any recovery. Practise it before you need it."*
>
> **Nobody practised it. It did not work — `mac-winbox` was `none` from the day the router was built, and four documents said otherwise.**
>
> **`016` lesson 4: a test that cannot fail proves nothing. The corollary, earned here: a recovery path you have never exercised is a recovery path you do not have.**
>
> ✅ **It works now** (`CM-0018`) — **and it drops after ~15 seconds.** That is enough to set an IP and move to a real session, and **not** enough to administer anything. **Plan accordingly.**
>
> 🔴 **All ten `bridgeLocal` ports remain enabled — a deliberate, recorded decision (`ADR-0016`), not an oversight.** The real control for an unlocked room is **`port-security` on SW01**, deferred to Book 10.

## Recovery Network

`bridgeLocal` — MKT01 `ether4`–`ether13`, `10.0.0.1/24`.

**This exists precisely for rebuilds and lockouts.** Plug the admin workstation into any of those ports, set a static `10.0.0.20/24` with gateway `10.0.0.1`, and you have management access **independently of the VLAN infrastructure** — which, during a rebuild, does not exist yet.

**Do not repurpose these ports. Do not remove `bridgeLocal`.**

## Physical Notes

- Cisco console: **9600 baud**, 8N1, no flow control.
- SFP ports on the WS-C2960X-48FPS-L are **`Gi1/0/49`–`52`** — *not* `Gi1/1/1-4`.
- PVE01 must negotiate **1 Gbps full duplex**. It was found at 100 Mbps once; confirmed 1 Gbps after a reboot. **Re-check after any cable change.**
- **CMOS battery on PVE01 is dead.** BIOS settings (including VT-x) survive only while the host stays on continuous power. **Physical replacement outstanding.**

## Validation

```text
SW01:    show interfaces status
SW01:    show interfaces trunk
MKT01:   /interface bridge port print detail where interface=ether3   # hw=no
FGT01:   get system interface physical
PVE01:   ethtool eno1                                                  # 1000Mb/s, Full
```

## Related Pages

- `Operations/048-Teardown-and-Rebuild-Runbook.md` — **read before any teardown**
- `Operations/Build-Order-and-Dependencies.md`
- `Build-Records/023-SW01-Build-Record.md` — the authoritative port table

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial topology. |
| 2.0 | **Reconciled against SW01's live port table.** Two rows were wrong (Pi on `Gi1/0/2`, workstation on `Gi1/0/3`) and two connections were missing entirely (`Gi1/0/7`, and **iDRAC — which still has no recorded port**). Added the bootstrap access table, the recovery network, and an explanation of why the two trunk native VLANs deliberately differ. |
