---
Title: MKT01 Considerations and Risks
Path: Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router
---

# MKT01 Considerations and Risks

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Device-verified |
| Version | 1.0 |
| Applies To | MKT01 (10.10.0.1 — MikroTik RB1100AHx4 Dude Edition, core router; **east-west firewall in Book 11**) |
| Last Reviewed | 2026-07-16 — live device pass (`054`) |

## Purpose

What could bite you on MKT01 — design risks, weak spots, unverified assumptions — each with a way to check it. Read before you trust, rebuild, or harden this device. Complements `041` (Troubleshooting) and `022` (Build Record). MKT01 is today Atlas's **core router and de-facto east-west chokepoint**; in Book 11 it becomes the **dedicated east-west firewall** (`Atlas-Firewall-Architecture.md`).

## How to read this

- 🟩 **Recommendation** — best practice to adopt.
- 🟨 **Hole** — unverified assumption / weak spot; run the check to settle it.
- 🟥 **Device-gated** — confirmed issue needing a live device read/write.

**Verify, don't assume** — run the command; don't trust the status column (Rule 13).

## Considerations & Risks

| # | Consideration / Risk | Type | How to verify | Current status | Ref |
|---|---|---|---|---|---|
| 1 | 🔴 **No serial console.** Three USB-serial adapters failed; MAC-WinBox (drops after ~15s) is the **only** out-of-band path — and only if RouterOS boots. **The only Atlas device with no path that survives a router that won't boot.** | 🟥 Device-gated | `/tool mac-server mac-winbox print` (RECOVERY); physically, no console cable works | Open, deferred `ADR-0016`. **Fix: a genuine FTDI cable** (hardware list). | `ADR-0016`, `022`, `048` |
| 2 | **MAC-WinBox recovery** on `bridgeLocal` (RECOVERY list) — get in, set an IP, switch to a real session. | 🟩 Recommendation | `/interface list member print where list=RECOVERY` → `bridgeLocal` | 🟢 Built + tested (`CM-0018`). 🔴 **NEVER modify the RECOVERY list while riding a MAC-WinBox session** — it kills it instantly. Do not remove. | `CM-0018` |
| 3 | 🔴 **Neighbour-discovery = `static`** — MKT01 advertises identity, RouterOS version, board model, uptime and port **on every VLAN**. A VLAN-50 client can read the router's patch level for free. | 🟥 Device-gated | `/ip neighbor discovery-settings print` → `static` | **Open**, deferred `ADR-0016`. Disclosure without recovery benefit. Scope it to RECOVERY. | `022`, `ADR-0016` |
| 4 | 🔴 **`hw=no` on ether3 (bridge-trunk) is a FUNCTIONAL requirement, not tuning.** The RTL8367 chip intercepts frames before RouterOS VLAN sub-interfaces see them if `hw=yes` — VLANs break **silently**. | 🟨 Hole | `/interface bridge port print` → ether3 `hw=no` | 🟢 **Confirmed `hw=no` 2026-07-16.** Re-verify after every reboot and firmware update. | `022` |
| 5 | 🔴 **East-west is flat and router-based.** MKT01 routes *and* filters all inter-VLAN traffic; the catch-all drops (rules 20/21) are load-bearing because **RouterOS defaults to ACCEPT**. Control plane + policy plane in one 1 GiB box. | 🟥 Device-gated | `/ip firewall filter print` → rules 20 `EAST-WEST-DENIED:`, 21 `INPUT-DENIED:` present | Working today. **Book 11 splits it: 1941 routes, MKT01 = dedicated E-W firewall.** | `Atlas-Firewall-Architecture.md`, `022` |
| 6 | 🔴 **1 GiB RAM, gateway for all nine VLANs.** Do **not** run services on it — a leak or a container reboot takes out inter-VLAN routing for the whole lab. | 🟥 Device-gated | `/system resource print` → 1024 MiB | By design; `Atlas-Service-Architecture.md` argues services go on PVE01, not here. | `Atlas-Service-Architecture.md` Part 1 |
| 7 | ✅ **The dynamic WinBox row (`D c`) is a live-session artefact — RESOLVED.** On 2026-07-16 the row carried `remote=10.10.0.50` (the admin workstation's own session), not an unrestricted listener. | 🟩 Recommendation | `/ip service print detail` — the `D c` row shows the connecting client's IP | 🟢 **Closed 2026-07-16** — not an exposure. | `022` |
| 8 | ✅ **SNMP is DISABLED on MKT01** (`enabled: no`, device-verified 2026-07-16) — no live community, no exposure. *(Unlike SW01, which runs SNMP v2c.)* | 🟩 Recommendation | `/snmp print` → `enabled: no` | 🟢 **No action.** If a collector is ever added, enable **SNMPv3**, never v2c. | `Atlas-Service-Architecture` #4 |
| 9 | **Certificate `mikrotik-bundle.crt_0`, serial 1001**, SAN `IP:10.10.0.1` — correct (device-verified 2026-07-16). Subject carries **`L=Redding, S=California`** — a real-world location disclosure (same class as `029`). | 🟩 Recommendation | `/certificate print detail` ; on Pi01 `openssl ca -status 1001` (Valid) | 🟢 Chain correct. 🔴 Revocation is **decorative** CA-wide (no CDP); the `L=Redding` disclosure rides in the cert until reissue — scrub before publication (`ADR-0010`). | `MC-0002`, `CM-0032`, `ADR-0009`, `ADR-0010` |
| 12 | 🟨 **RouterBOOT firmware is behind RouterOS.** `current-firmware: 6.42.10` under RouterOS `7.23.1` (`upgrade-firmware: 7.23.1` available) — old bootloader firmware on a v7 OS, a latent boot/hardware-compat gap. | 🟨 Hole | `/system routerboard print` → compare `current-firmware` vs `upgrade-firmware` | **Found 2026-07-16.** Fix: `/system routerboard upgrade` then reboot (a device write — raise a short CM). Low urgency, but do it before a Game Day. | `022` |
| 10 | **NTP client-only** — syncs `pool.ntp.org` (stratum 1) but **serves no time.** | 🟨 Hole | `/system ntp client print` (synced); `/system ntp server print` (off) | 🟢 **Synced 2026-07-16** (stratum 1, offset ~-1.9 ms). Fine as a client. Atlas's time-source decision is `ADR-0020` (AD PDC target; external-pool bridge); MKT01 stays a client. | `CM-0030`, `ADR-0020` |
| 11 | **Hardened surface confirmed:** `admin` disabled (`CM-0034`), reverse-proxy disabled (`CM-0006`), `ether2` + `ether5-13` disabled (`CM-0015`/`CM-0035`). | 🟩 Recommendation | `/user print`, `/ip service print`, `/interface ethernet print` | 🟢 Done — keep verified after any rebuild. | `CM-0034`, `CM-0006`, `CM-0015`, `CM-0035` |

## Open holes — summary (most consequential first)

1. **No serial console (row 1)** — the recovery gap; a genuine FTDI cable closes it.
2. **Discovery disclosure = static (row 3)** — every VLAN reads the router's patch level; scope it.
3. **RouterBOOT firmware behind RouterOS (row 12)** — `6.42.10` under `7.23.1`; `/system routerboard upgrade` + reboot.

*(Resolved 2026-07-16: the dynamic-WinBox row — row 7, the operator's own session; and SNMP — row 8, disabled, no community.)*

## For the next build (Book 11 / Device Role Plan)

- **MKT01 becomes the dedicated east-west firewall** — separate routing (1941) from filtering (MKT01), write an **allowed-flows matrix** (segment × segment × service) before any rule, default-deny + log between segments, no NAT east-west. See `Atlas-Firewall-Architecture.md` §4.
- **Fix the out-of-band first** (FTDI console) before making MKT01 policy-critical — you can't safely iterate firewall policy on a box whose only recovery drops after 15 seconds.
- **Scope neighbour discovery** to RECOVERY; **SNMPv3**; keep services off the router.
- **Don't let routing and filtering share the 1 GiB box** — that single-failure-domain is the whole reason for the split.

## Revision history

| Version | Date | Change |
|---|---|---|
| 0.9 | 2026-07-16 | Scaffold built from `022` v2.8 (device-reconciled 2026-07-15) and the MKT01 change records. Pending a fresh device pass (`054`) to promote to 1.0. |
| 1.0 | 2026-07-16 | **Promoted to device-verified from the live `054` run.** Confirmed `hw=no`, firewall 22, hardened surface, cert, NTP synced (stratum 1). **Resolved:** dynamic-WinBox row (operator's own session, row 7) and SNMP (disabled — no community, row 8). **New:** RouterBOOT firmware `6.42.10` < RouterOS `7.23.1` (row 12); `L=Redding` cert disclosure noted (row 9). |

## Related pages

- **Verification Procedure: `054-MKT01-Verification-Procedure.md`**
- Build Record: `022` · Build Guide: `026` · Troubleshooting: `041`
- 🔵 **Firewall architecture (east-west): `00-Atlas-Foundation/Atlas-Firewall-Architecture.md`**
- Change records: `CM-0034`, `CM-0035`, `CM-0018`, `CM-0016`, `CM-0015`, `CM-0009`, `CM-0006`, `MC-0002`, `ADR-0016`
