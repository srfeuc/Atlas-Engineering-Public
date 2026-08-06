---
Title: FGT01 Verification Procedure
Path: Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall
---

# FGT01 Verification Procedure

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | 1.0 |
| Applies To | FGT01 (10.10.0.254, FortiGate-60E — perimeter firewall) |
| Evidence Status | **Verified** — live `get`/`diagnose` pass, FGT01, 2026-07-16 |
| Last Run | 2026-07-16 |

## Purpose

The **reconcile-to-live** procedure for FGT01: prove the running firewall matches `021` (Build Record) and `025` (Build Guide), 🟡 → 🟢. Run before a Game Day (`ADR-0011`), after any change, or when a doc is in doubt.

**Read-only checks only.** Risks and open items live in `059-FGT01-Considerations-and-Risks.md`.

## How to run

FGT01 is FortiOS, not Linux — there is no bash script. SSH in (`ssh admin@10.10.0.254`) or use the GUI **Dashboard → CLI Console**, and paste the block in `Tools/scripts/fgt01-recon` (also below). Everything is `get` / `diagnose` / `show` / `execute time` — **no config changes.**

> 🔴 **Use `get`, not `show`, for state.** `show` prints only non-default values — an unbound cert or a disabled interface "looks like nothing to see." `get` shows the running value. This is the MC‑0001 lesson (the silently-unbound `admin-server-cert`).
> 🔴 **No secrets.** Do not paste any line containing `ENC` or a password/key. None of the commands below require one.

## Verification battery

| # | Command | Expected (device-verified 2026-07-16) |
|---|---|---|
| 1 | `get system status` | FGT01, FortiOS **v7.4.5 build2702**, serial `FGT60ETK18099YR2`, NAT/root VDOM. 🔴 UTM DBs **stale**: Virus 2018-04-09, IPS/APP 2015-12-01 |
| 2 | `get system interface` | admin view: internal1 `172.16.0.1/29` up · internal2 `10.10.0.254/24` up · **internal3‑7 up** (recovery ports) · `internal` hard-switch **down**, holds `192.168.1.99` · **dmz up** `10.10.10.1/24` (factory relic) · wan2/modem/fortilink down · naf/l2t/ssl.root up (tunnels) · wan1 up (uplink) |
| 3 | `get system interface physical` | link state: only cabled ports (internal1/2, wan1) show up; internal3‑7/dmz show down = **no cable** (not disabled — compare with #2) |
| 4 | `show full-configuration system ntp` | `set server "pool.ntp.org"`, per-server `interface-select-method auto`; 🟡 global `set interface "fortilink"` (down, harmless leftover); `set server-mode enable` |
| 5 | `diagnose sys ntp status` / `execute time` | 🟢 **`synchronized: yes`**, `pool.ntp.org` stratum 2 — the clock works (corrects CM‑0033) |
| 6 | `get firewall address` | factory objects only — **no `Lab-Network`, no `Transit-Link`** (they do not exist; `ADR-0005`) |
| 7 | `show firewall policy 1` | policy `LAB-to-Internet`, internal1→wan1, `srcaddr all`, `dstaddr all`, `service ALL`, NAT enable, **no UTM** (`ADR-0005` deferred) |
| 8 | `get system global \| grep admin-server-cert` | `fortigate-bundle` (🟢 MC‑0001 holds) |
| 9 | `get system dns` | `protocol dot`, `globalsdns.fortinet.net`, servers 1.1.1.1/8.8.8.8; 🟡 validated against `Fortinet_Factory`, not the Lab CA |

## Interpreting results

- **Device wins** (Rule 13). A mismatch is a finding for `059`.
- **`get` vs `get ... physical`:** the first is admin state (enabled/disabled), the second is link state (cabled/not). A break-glass port reads admin-up + link-down when idle — that is correct, not a fault.
- **A config that looks broken is not a broken service.** CM‑0033 inferred FGT01's clock was dead from `get system ntp` and never ran `diagnose sys ntp status`. It syncs. Read the status, not just the config.

## Last-run record

| Date | Run by | Result | Output |
|---|---|---|---|
| 2026-07-16 | Seth | 🟢 Live state matches `021` on every point (interfaces, disabled set, `srcaddr all`, no custom objects, cert bound, DoT, **NTP synced**). Open items are design/holes, tracked in `059`. **CM‑0033's "clock broken" finding disproven.** | pasted CLI session |

## Related pages

- Build Record: `021` · Build Guide: `025`
- **Considerations & Risks: `059-FGT01-Considerations-and-Risks.md`**
- Troubleshooting: `037` · CIS: `047`
- Change records: `CM-0033` (Draft — NTP finding needs correcting), `CM-0032`, `CM-0004`, `MC-0001`, `ADR-0005`
- Battery: `Tools/scripts/fgt01-recon`
