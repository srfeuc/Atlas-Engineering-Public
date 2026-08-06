---
Title: MKT01 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-02-Cisco-Core/Architecture
---

# MKT01 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: MKT01 - Role: **East-West Firewall** (`ADR-0023`; was Core Router in the frozen Lab-01)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 **Pass-1 device-verified 2026-07-22** (mgmt-plane items done; execution evidence in `MKT01/Build-Guide.md` §1 v0.7). Curated priority checklist, not exhaustive. Follows `Operations/Device-Hardening-Standard.md`. Logging→MON01 + SNMPv3 remain (Phase 6); Pass-2 **RADIUS admin auth → NPS on `NPS01`** remains (Phase-3-dependent). |
| Version | 1.2 |
| Applies To | MKT01 (MikroTik RB1100AHx4 Dude Ed., RouterOS 7.x) |
| Reference | No official CIS RouterOS benchmark exists; this is CIS-Controls-v8-informed + MikroTik hardening guidance, structured like `../FGT01-NS-Firewall/CIS-Hardening.md` |
| Governing Policy | `POL-0007` (Hardening Baseline); evidence per `POL-0001` R-A1 |

> 🔴 **Evidence rule (`POL-0001` R-A1):** a `[x]` requires a command **and its output**, not a config line — on RouterOS use `/…print stats`/`print detail`, not just `print` (plain `print` hid a dynamic WinBox row that was misread as an open service — `016`/Charter Rule 13 corollary). Items I cannot confirm from prior sessions are marked **Unverified** — a legitimate state to record, not hide.

> **Role note:** MKT01 is frozen as Lab-01's core router; in Lab-02 it becomes the **east-west segmentation firewall** (`ADR-0023`). Items tagged **[L2]** matter specifically for that re-role. The segmentation *policy* itself lives in the East-West Allowed-Flows Matrix, not here — this doc is device hardening.

---

## 1. Services & Management Plane

- [x] ✅ **Disable unused IP services** — 07-22: `telnet,ftp,www,www-ssl,api,api-ssl,reverse-proxy` disabled (🔎 **`reverse-proxy` on 443** was enabled+open and easy to miss — caught via `print detail`). Only `ssh`+`winbox` enabled. Verified with `/ip service print detail`.
- [x] ✅ **Scope management to source addresses** — 07-22: `ssh`+`winbox` `address=10.10.0.0/27,192.168.88.0/24` (mgmt VLAN + ether2 recovery net; tighten to `/27`-only once VLAN-10 mgmt is the norm).
- [x] ✅ **Strong admin auth, no default user** — 07-22: named `mikrotikadmin` (group full), **`admin` disabled**; password in Vaultwarden (`POL-0002`); `strong-crypto=yes`.
- [x] ✅ **MAC-server / MAC-Winbox / MAC-Telnet** — 07-22: set to **`none`** (fully off; `mac-ping` off too) — the serial console is the break-glass, so no L2 mgmt vector kept. *(Alternative if an L2 fallback is wanted: scope `mac-winbox` to ether2 only — set once, `026` last-write-wins.)*
- [x] ✅ **Neighbor discovery limited** — 07-22: `discover-interface-list=none`. *(Side effect: MKT01 no longer shows in WinBox Neighbors — connect by IP; expected, not a fault.)*

## 2. SNMP

- [x] ✅ 🔎 **POL-0001 correction (07-22):** `/snmp community print detail` showed **only the default `public`** — **no `homelab`** on MKT01. `CM-0023`'s "homelab live on MKT01" was a **stale carryover** (that v2c was SW01's, already removed). **SNMP now disabled** (`/snmp set enabled=no`) until **SNMPv3 (auth+priv) → MON01** in Phase 6. Never re-add a v2c community.

## 3. Unused Interfaces (`POL-0007`)

- [x] ✅ **Every port accounted for** — 07-22 (`/interface print`): **`ether4`–`ether13` disabled** (retired `bridgeLocal`); enabled/kept = **`ether1`** (uplink to 1941), **`ether3`** (trunk to SW01), **`ether2`** (mgmt-fallback `192.168.88.1`, documented recovery net).
- [x] ✅ **Exceptions recorded** — the three kept-up ports each have a documented role (above); `ether2` is no longer "undocumented" (`CM-0015` closed).

## 4. Firewall / Filter

- [ ] **Count the live rules and read each in English** — `/ip firewall filter print stats`. 🔴 The device had **22** rules where a doc claimed 24/23 (`CM-0009`/`POL-0001`) — count, don't carry forward.
- [ ] **Input chain default-deny to the router itself** — management-plane protection: only management-zone sources reach the router's own services.
- [ ] **[L2]** In Lab-02 the *forward*-chain east-west policy becomes default-deny per segment — but that is the **East-West Allowed-Flows Matrix**'s job, gated by the console recovery path below. Don't build it here; reference it.

## 5. Users, Logging & Time

- [ ] **RADIUS for admin auth** — migrating to **NPS on `NPS01`** (`ADR-0029`; FreeRADIUS on Pi01 retired — MKT01 is a RADIUS *client*, not an LDAPS admin box). Until then, ensure the RADIUS client secret is vaulted and not in git (`POL-0002`).
- [ ] **Logging off-box to MON01** — a router that logs only to itself loses its evidence when compromised.
- [x] ✅ **NTP client synced** — 07-22: was **stuck (`Jun/03`, NTP off)** — enabled `/system ntp client` → **DC01 `10.20.0.2`** (authoritative PDCe, `ADR-0020`), tz `America/Chicago`. `/system ntp client print` → **`status: synchronized`**, stratum 2, ~2 ms offset; `/system clock print` → correct `2026-07-22` (`CM-0030` clock finally working). Verified by runtime status, not config (`045`).
- [ ] **Logging off-box to MON01** — deferred to Phase 6 (MON01 not built).

## 6. Recovery / Management Plane (🔴 gates the Lab-02 re-role)

- [x] ✅ 🔴 **Serial console recovery path TESTED** — 07-22: FTDI cable connected (115200 8N1), **console login proven** (`[admin@MKT01] >`); it was also the safety net when a mid-hardening WinBox lockout happened (recovered by connecting by IP). **This gate is now met** — MKT01 has tested OOB recovery before it carries Lab-02 east-west policy.
- [x] ✅ **A known-good config export exists** — 07-22: `/export` + `/system backup save` pre- and post-hardening (`mkt01-preharden`, `mkt01-postharden-pass1`). *(→ Oxidized/git once SRV01 exists, Phase 5.)*

## Real Priorities, Ranked — ✅ **all five done 2026-07-22 (Pass 1)**

1. ✅ ~~Rotate the `homelab` SNMP community~~ → **stale finding** (only `public` on MKT01); SNMP disabled until SNMPv3→MON01 (Phase 6).
2. ✅ **Serial console recovery path tested** (`ADR-0016`) — the gate is met.
3. ✅ **Every interface accounted for** (`ether4`–`13` down; `ether1/2/3` documented; `CM-0015` closed).
4. ✅ **Management services verified with `print detail`** and scoped to the mgmt subnet(s).
5. ✅ **`mac-winbox` value confirmed live** = `none` (set once; `026` trap avoided).

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/CIS-Hardening.md` (the template)
- `00-Atlas-Foundation/Decisions/ADR-0016-MKT01-Recovery-Posture-Console-Deferred.md` · `ADR-0023` (Lab-02 role) · `ADR-0029` (RADIUS→NPS on `NPS01`)
- `Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (the Lab-02 policy, not device hardening)

## Change Log

| Version | Changes |
|---|---|
| 1.2 | 2026-07-28. **C4 auth reconciliation.** Pass-2 wording corrected from the stale **"AD-LDAPS admin"** to **RADIUS admin auth → NPS on `NPS01`** (`ADR-0029`; MKT01 is a RADIUS *client*, LDAPS is FGT01's path per `ADR-0028`), and `ADR-0004`/SRV01-NPS references updated to `ADR-0029`/`NPS01` in §5, Status, and Related. No device changes. |
| 1.1 | 2026-07-22. **Pass-1 device-verified** — checked off §1 (services/scope/named-admin/mac/discovery), §2 SNMP (POL-0001: `homelab` was stale for MKT01 → only `public`, SNMP disabled), §3 interfaces (`ether4–13` down, `ether1/2/3` documented — `CM-0015` closed), §5 NTP (was stuck Jun/03 → synced to DC01, `CM-0030` closed), §6 recovery (console tested — the Lab-02 gate is met; pre/post backups). Real Priorities all done. Evidence in `MKT01/Build-Guide.md` §1 v0.7; follows `Operations/Device-Hardening-Standard.md`. Remaining: logging/SNMPv3→MON01 (Phase 6), Pass-2 AD-LDAPS admin (Phase-3-dependent). |
| 1.0 | 2026-07-17. Created to fill backlog #12 (MKT01 had no CIS-Hardening doc), modelled on the strengthened FGT01 baseline. CIS-Controls-informed (no official RouterOS benchmark). Captures the known live findings — `homelab` SNMP (`CM-0023`), `ether2` undocumented (`CM-0015`), the 22-vs-24 rule count, the `mac-winbox` recovery trap — under the `POL-0001` R-A1 evidence rule, and gates the Lab-02 east-west role on the `ADR-0016` console recovery path. |
