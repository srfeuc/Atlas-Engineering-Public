---
Title: FGT01 Build Guide 1 — Networking (Perimeter) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟢 LIVING (v0.5). GUI-primary + CLI. FortiOS 7.4.5 on a physical **FortiGate-60E**. Read back with `get`, not `show` (`MC-0001`). No FortiGuard needed for this pass. **Steps 1–4 all device-verified 2026-07-21 — an interior host reaches the internet end to end.**
Version: 0.5
Date: 2026-07-20
---

# FGT01 — Build Guide 1: Networking

Executes `Build-Checklist.md` §1–2 (topology, egress, NAT) + §7 (traffic logging). GUI path + CLI each step; `get` read-back; 📷 capture placeholder (drop screenshots in `captures/`).

## 🔴 This box is a physical FortiGate-60E — read this first (per Lab-01 `FGT01-NS-Firewall/Build-Guide.md`)
- **Real interfaces are `wan1`, `wan2`, `dmz`, and `internal` (a 7-port hardware switch: `internal1`–`internal7`).** There is **no `port2`** — that name is only on the FortiGate-VM. Creating one makes a new *logical* interface, which is why FortiOS demanded `vdom`.
- **You can't put an IP on a switch member** until you split it off the `internal` hardware switch (`config system virtual-switch`). The transit to the 1941 uses **`internal1`** (the port that was the MKT01 transit in Lab-01) — cable the 1941 into physical `internal1`.
- 🔴 **`internal3`–`internal7` are the break-glass** (`192.168.1.99/24`, `CM-0033`) — **leave them UP, never disable them.**
- **Check admin status with `show full-configuration system interface | grep -f "set status down"`, NOT `get system interface physical`** (physical shows link/IP; a disabled port and an unaddressed one look identical).
- **This unit (SN FGT60ETK18099YR2) is single-VDOM** (`get system status` → "Virtual domain configuration: disable"), so **no `set vdom` line is needed**. *(A multi-VDOM unit would require `set vdom "root"` in every interface block.)*
- **Per-interface read-back:** `get system interface <name>` errors on 7.4.5 — use `show system interface <name>`, or `get system interface` for the full dump.

## Scope now
`wan1` egress (existing) · the **internal link re-pointed to the 1941** (`10.255.255.1/30`) · routing (default → wan1, static → interior via the 1941) · the **egress policy + NAT** (broad, `ADR-0005`) · log every flow. **No inbound-allow. No UTM here** (that's Guide 3, needs FortiGuard).

## 🔴 Before you touch it
- Break-glass proven (console + `192.168.1.99` on `internal3`–`internal7`, `CM-0033`). Confirm recovery exists first.
- `get system status` — firmware level **and** VDOM mode recorded ("Virtual domain configuration"). If multi-VDOM, `set vdom "root"` in every interface block is mandatory.
- The 1941 transit uses **`internal1`** — cable the 1941 into physical `internal1`.

## Step 1 — The 1941-facing interface (`internal1`, the Lab-02 change)
The old FGT01↔MKT01 link becomes FGT01↔**1941** on `internal1`. Free it from the hardware switch, then set the transit /30 — a **pure routed transit**, `allowaccess ping` only (no https/ssh on the transit).
- CLI:
```
# 1a — free internal1 from the hardware switch (can't IP a switch member)
config system virtual-switch
 edit "internal"
  config port
   delete internal1
  end
 next
end
# 1b — configure internal1 as the 1941 transit
config system interface
 edit internal1
  set alias transit-1941
  set mode static
  set ip 10.255.255.1 255.255.255.252
  set allowaccess ping
  set role lan
 next
end
```
- GUI: (after the switch split) Network ▸ Interfaces ▸ edit `internal1` ▸ Addressing = Manual, `10.255.255.1/255.255.255.252` ▸ Administrative Access = **PING only** ▸ Role = LAN
- ✅ `show system interface internal1` → ip `10.255.255.1 255.255.255.252`, `allowaccess: ping`, `status: up` *(device-verified 2026-07-20)*
- ⚠️ `set internal-switch-mode interface` does **not** exist in 7.4.5 — split via `config system virtual-switch` as above (Lab-01 lesson).
- 📷 captures/fgt01-int-transit.png

## Step 2 — Routing (interior return via the 1941; default out wan1)
🔴 **The interior return route is the one line that turns "spine up" into "internet works."** Without it FGT01 has no path back to the VLANs, so every reply blackholes here — that's exactly why `10.255.255.1` times out from an interior host today. Add it **first**; the default route is usually already present.

**2a — Interior return route (the must-have): `internal1` → the 1941**
- GUI: Network ▸ Static Routes ▸ **+** → Destination `10.0.0.0/255.0.0.0` · Gateway `10.255.255.2` (the 1941) · Interface **`internal1`** (alias `transit-1941`).
- CLI:
```
config router static
 edit 0
  set dst 10.0.0.0 255.0.0.0
  set gateway 10.255.255.2
  set device "internal1"
 next
end
```
*(`edit 0` appends with the next free sequence number, so it can't clobber an existing route.)*
- ℹ️ **Why `/8`, not `/24`?** It's a **summary route.** The whole interior lives inside `10.0.0.0/8` by design (VLANs = `10.<vlan>.0.0`, transits/loopbacks in `10.255.x`), so one line sends *all* interior return traffic to the 1941 — which knows each specific VLAN via OSPF. A narrower route like `10.10.0.0/27` would cover only VLAN 10 and blackhole the rest (you'd need 9+ routes). Longest-prefix match still protects the connected transit and lets the wan1 default handle everything *outside* 10/8; the `/8` only pulls interior-bound replies away from the default. *(Edge case: if wan1 ever gets a `10.x` address, its connected route is more specific and still wins — no conflict.)*

**2b — Default route → wan1 (verify BEFORE adding — it usually already exists)**
- 🔴 wan1 faces the home router and is almost certainly **DHCP**, so FortiOS has already installed a default route ("Retrieve default gateway from server" is on by default). **Check first:** `get router info routing-table all` — if you see `S* 0.0.0.0/0 [...] via <gw>, wan1`, you are done; **do not add a duplicate.**
- Only if no default exists:
  - **DHCP wan1** — `config router static / edit 0 / set dst 0.0.0.0 0.0.0.0 / set device "wan1" / set dynamic-gateway enable / next / end` (no fixed gateway; it follows the DHCP-learned one).
  - **Static wan1** — same, but `set gateway <wan1-gateway>` instead of `dynamic-gateway`. Find the gateway from the home router's LAN IP or from `get router info routing-table all`.
- ✅ `get router info routing-table all` → default via wan1 **and** `S 10.0.0.0/8 [.../..] via 10.255.255.2, internal1`. `execute ping 10.255.255.2` (the 1941) already succeeds — the FGT01↔1941 /30 is up (1941 side is **`Gi0/1`**, not Gi0/0; Gi0/0 faces MKT01).
- 📷 captures/fgt01-routes.png
- ℹ️ Static (not OSPF) matches the 1941 side, where `Gi0/1` is **passive**. If you later run OSPF between FGT01 and the 1941, un-passive `Gi0/1` on the 1941 and replace this static.

## Step 3 — Egress policy + NAT (broad, `ADR-0005`)
One policy: interior → wan1, NAT on, log all. **Egress stays `srcaddr all`** deliberately (deferred by `ADR-0005` — no redundant path to safely test a tighter policy yet). Record it as *deferred with trigger = redundancy*, not an open finding.
- GUI: Policy & Objects ▸ Firewall Policy ▸ **+**
  - Name `egress-interior-to-wan` · Incoming **`internal1`** (transit-1941) · Outgoing `wan1` · Source `all` · Dest `all` · Service `ALL` · Schedule `always` · Action `ACCEPT` · **NAT = ON** (Use Outgoing Interface Address) · **Log Allowed Traffic = All Sessions**
- CLI:
```
config firewall policy
 edit 0
  set name "egress-interior-to-wan"
  set srcintf "internal1"
  set dstintf "wan1"
  set srcaddr "all"
  set dstaddr "all"
  set action accept
  set schedule "always"
  set service "ALL"
  set nat enable
  set logtraffic all
 next
end
```
- ✅ `get firewall policy` → the egress policy present, `nat: enable`, `logtraffic: all`; **no interior-facing default-allow beyond this**. `diagnose sys session list` shows a flow when a host browses out, ages when it stops.
- 📷 captures/fgt01-egress-policy.png

## Step 4 — Traffic logging on (denies especially)
Allowed-flow logging is **already on** from Step 3 (`set logtraffic all` on the egress policy). This step adds **implicit-deny logging** (so you can see what's dropped) and a **local log store**.
- 🔴 The **60E has no internal disk** — it logs to **memory** (`config log disk setting` does not apply on this model). Local retention is small; durable retention comes from forwarding to MON01/syslog in **Guide 2** once MON01 exists.
- CLI:
```
config log memory setting
 set status enable
end
config log setting
 set fwpolicy-implicit-log enable
end
```
- GUI: Log & Report ▸ Log Settings ▸ enable **Local Traffic Log** (memory) and **Log Denied/implicit-deny Traffic**. *(FortiAnalyzer/syslog forward to MON01 = Guide 2.)*
- ✅ `get log setting` → `fwpolicy-implicit-log: enable`; `get log memory setting` → `status: enable`. Browse out from a host, then Log & Report ▸ Forward Traffic shows the allow; blocked traffic shows against the implicit deny.
- ℹ️ **What `fwpolicy-implicit-log` does & how to use it:** every forwarded packet is matched against your firewall policies top-down; anything that matches **no** policy falls through to the built-in **implicit deny (policy ID 0)** and is dropped — silently, by default. This setting makes the box write a traffic log for each of those drops. On a north-south perimeter firewall that log is your record of **blocked inbound attempts** — internet-side scans/probes hitting `wan1` with nothing to permit them — plus any interior host trying a path you never allowed. **To read it:** Log & Report ▸ Forward Traffic, filter **Action = Deny** (implicit-deny rows show policy ID 0); or from the CLI `execute log filter category traffic` then `execute log display`. A quiet deny log is healthy; a sudden burst from one source is worth investigating. Only turn it back off if memory-log volume becomes a problem — and by then you'd be forwarding to syslog/MON01 (Guide 2) anyway. *(Device-applied 2026-07-21.)*
- ⚠️ **Corrected in v0.4:** `config log setting` has **no `logtraffic` field** — per-flow allow logging lives on the *policy* (Step 3), not here. The old `set logtraffic all` under `config log setting` would error.
- 📷 captures/fgt01-log-setting.png

## Validation (read back with `get`)
- [ ] `show system interface internal1` — transit /30, ping-only, up. ✅ device-verified 2026-07-20. 📷
- [x] `get router info routing-table all` — default via wan1 (`172.31.4.1`, DHCP), `10.0.0.0/8` via the 1941. ✅ 2026-07-21. 📷
- [x] `get firewall policy` — egress with NAT + log; no other interior default-allow. ✅ 2026-07-21. 📷
- [ ] `diagnose sys session list` — a browse-out flow appears/ages. 📷
- [x] End-to-end: an interior host (`10.10.0.20`, VLAN 10) reaches the internet; FGT01 also pings out and reaches every interior subnet. ✅ 2026-07-21.

## Failure modes
- 🔴 **`edit "port2"` on a 60E** — creates a bogus logical interface and errors `Attribute 'vdom' MUST be set`. No `port2` on hardware; use `internal1`, split from the switch. *(This unit is **single-VDOM** — no `set vdom` line; only a multi-VDOM box would need `set vdom "root"` in each block.)*
- 🔴 **IP on a switch member without splitting** — `command parse error before 'ip'`. Split `internal1` off the `internal` hardware switch first (`config system virtual-switch`).
- 🔴🔴 **Disabling `internal3`–`internal7`** — destroys the `192.168.1.99` break-glass (`CM-0033`). They stay UP.
- 🔴 **`get system interface physical` to check disabled** — wrong question (shows link/IP). Use `show full-configuration system interface | grep -f "set status down"`.
- 🔴 **`allowaccess https/ssh` on the transit** — exposes mgmt on the routed link. Ping-only.
- 🔴 **Narrowing egress with no redundancy** — locks the lab out with no failover (`ADR-0005`). Don't, until a second path exists.
- 🔴 **Ticking from `show`/`config`, not `get`** — `MC-0001` (admin-server-cert silently unbound for hours).
- **Forgetting the interior static** → return traffic to the VLANs blackholes at FGT01.

## Related
`Build-Guide-Index` · `Build-Checklist` §1–2/§7 · `Cabling-and-Port-Map` (link #2/#3) · `IP-Addressing-Plan-VLSM` (`10.255.255.0/30`) · the 1941 `Build-Guide` (the other end of the /30).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-20 | Networking draft — transit /30 to the 1941 (ping-only), default→wan1 + static `10.0.0.0/8`→1941, broad egress+NAT (`ADR-0005`), traffic logging. GUI + CLI; `get` read-backs; capture placeholders. Validate on device. |
| 0.2 | 2026-07-20 | Reconciled to the physical **FortiGate-60E** during the device walk-through (per Lab-01 `FGT01-NS-Firewall/Build-Guide`): replaced the `port2` VM placeholder with **`internal1`** + the `config system virtual-switch` split step; added the 60E interface note, the `internal3–7` break-glass warning, and the `get ... physical`-is-wrong status-check correction. Added the matching failure modes. |
| 0.3 | 2026-07-20 | **Step 1 device-verified** on SN FGT60ETK18099YR2. Box confirmed **single-VDOM** → removed the `set vdom "root"` line. Fixed per-interface read-back: `get system interface <name>` errors on 7.4.5 → use `show system interface <name>`. internal1 = 10.255.255.1/30 up, break-glass (192.168.1.99 hard-switch) intact. |
| 0.5 | 2026-07-21 | **Steps 2–4 device-verified — internet is live end to end** (interior host `10.10.0.20` → MKT01 → 1941 → FGT01 → out). On the box: wan1 came up on **DHCP with its default route already installed** (`172.31.4.1`), so Step 2b added nothing; the interior return route `10.0.0.0/8 → 10.255.255.2` and the egress policy + NAT were applied (the missing egress policy was the sole reason the host couldn't reach the internet while the FortiGate itself could); memory logging + `fwpolicy-implicit-log` enabled. Added a "what it does / how to use it" note to the Step 4 implicit-deny log, and the "why /8 (summary route)" note under Step 2a. Break-glass confirmed intact (`internal` = `192.168.1.99`, `allowaccess ping https ssh fabric`). 🔴 **Interim:** HTTPS enabled on `internal1` (the transit) for interior GUI access — **revisit in Guide 2** (scope to a trusthost, or return `internal1` to ping-only and manage via the `192.168.1.99` break-glass). |
| 0.4 | 2026-07-21 | **Steps 2–4 prep pass — paste-ready, not yet device-verified.** (1) Killed the two `port2` GUI leftovers in Steps 2 & 3 → `internal1` (matches the CLI + the 60E reality). (2) Reordered Step 2 to lead with the interior return route (the must-have), switched hardcoded `edit 1/2` → `edit 0` (no clobber), and added the wan1-DHCP caveat: check for an existing default before adding one; use `set dynamic-gateway enable` on a DHCP wan1. (3) Fixed the Step 2 read-back — the 1941's FGT-facing port is **Gi0/1**, not Gi0/0. (4) Rewrote Step 4: removed the invalid `config log setting → set logtraffic all` (that field is per-policy, already set in Step 3); use `fwpolicy-implicit-log` for deny logging + memory logging (60E has no disk). (5) Dropped the stray `set vdom "root"` from failure-mode #1 (single-VDOM, per 0.3). Header → v0.4. |
