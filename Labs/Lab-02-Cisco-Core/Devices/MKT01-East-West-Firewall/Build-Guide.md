---
Title: MKT01 Build Guide (East-West Firewall + Inter-VLAN Gateway) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
Status: 🟡 LIVING (v0.7) — networking device-verified; **Phase-2.5 Pass-1 hardening ✅ COMPLETE & device-verified (07-22)**. (v0.8: C4 auth wording reconciled to `ADR-0029`.) RouterOS **7.23.1** on the **RB1100AHx4**. Bridge/VLAN/uplink verified; OSPF via `redistribute=connected`. **Pass-1 done:** console break-glass proven · named admin `mikrotikadmin` + `admin` disabled · ssh/winbox scoped + strong-crypto · `reverse-proxy`/telnet/ftp/www/api off · mac-server off · unused ether disabled · SNMP off · **NTP synced to DC01, clock corrected**. Pass-2 (**RADIUS admin auth → NPS on `NPS01`**, `ADR-0029`) → Phase-3-dependent.
Version: 0.9
Date: 2026-07-22
---

# MKT01 — Build Guide (East-West Firewall + Inter-VLAN Gateway)

## How to read this guide (living doc)

This is the executable, **living** companion to `Build-Checklist.md` (the design/why). We build it, update it as things change, and drop **screen captures** in at each ✅ read-back during the device walk-through.

Every step shows **both**: the **CLI** command (source of truth, copy-pasteable) and the **WinBox** path (visual). Then a **✅ read-back** (`print detail` / `print stats`, never plain `print` — `016`) and a **📷 capture** placeholder.

```
Step — <intent>
  CLI:      /the/command …
  WinBox:   Menu ▸ Sub ▸ field = value
  ✅ verify: /read-back print detail   → what you expect to see
  📷 capture: captures/<name>.png       (drop the screenshot here during the walk-through)
```

> Put screenshots in a `captures/` subfolder next to this file and reference each one inline with a normal Markdown image link whose path points into that folder (`captures/your-screenshot.png`).

## Scope of THIS pass (networking) — and what's deferred

**In scope now** (Master-Build-Order **Phase 2**, PERMISSIVE): base + service hardening · the VLAN gateways + 802.1Q trunk to SW01 · the routed /30 uplink to the 1941 · OSPF peering with the 1941 · default route re-pointed to the 1941 · input-chain protection of the router itself.

**Deferred** (built later, not now):
- 🔴 **East-west forward policy** — stays **permissive** during bring-up. The default-deny is built **incrementally per zone** later via `Incremental-East-West-Firewall-Build-Worksheet.md` (Phase 7), gated on the console cable (`ADR-0016`). We do **not** write forward-chain deny rules in this pass.
- **NTP / SNMPv3 / syslog → MON01** — Phase 4/6, when MON01 exists (stub at the end).

## Pre-flight (at the start of the device walk-through)

- CLI: `/system resource print` → **record the RouterOS version** (this guide is v7; v6 syntax differs).
- CLI: `/export file=mkt01-ew-pre` and `/system backup save name=mkt01-ew-pre` → back up before any change.
- Console break-glass (FTDI, `ADR-0016`) reachable. *(Gates the Phase-7 deny, not this build — but have it before you're policy-critical.)* During the build, **MAC-WinBox** (default `allowed-interface-list=all` after a reset) is your safety net — leave `mac-server` alone until the very end.
- 🔴 **Give yourself a durable management IP on a free port BEFORE building the uplink** — the transit /30 and the tagged trunk are NOT laptop-reachable, and a reboot that drops MAC-WinBox will otherwise strand you (learned the hard way 2026-07-20). E.g. `/ip address add address=192.168.88.1/24 interface=ether2 comment=MGMT-fallback`, laptop on ether2. Keep it until the console cable or VLAN-10 mgmt path exists.
- 🔴 **Real RB1100AHx4 ports (per Lab-01 `MKT01-Core-Router/Build-Guide`):** **`ether1` = routed /30 uplink to the 1941** (link #3), **`ether3` = 802.1Q trunk to SW01** (link #4, on `bridge-trunk` with **`hw=no`**), **`ether2` = mgmt-fallback `192.168.88.1/24`** (the durable recovery net set up in pre-flight — 🔴 **do NOT disable it while it's your only laptop-reachable mgmt path**; disable it only once the console cable or a VLAN-10 mgmt path exists), `ether4`–`ether13` = the retired `bridgeLocal` (free — access ports or disabled). **No `etherA`/`etherB`** — those were placeholders. See the Stage 2 hardware note.

---

## Stage 1 — Base + service hardening

> 📋 **Follows `Operations/Device-Hardening-Standard.md`** (the shared recovery-first order + Pass-1 checklist every device executes) — this Stage is MKT01's device-specific instance of it.

> 🔴🔴 **Lockout order (device-run 2026-07-22):** the two steps that *remove your remote access* — **1.2 scope ssh/winbox** and **1.3 kill `mac-server`** — must come **after** you've proven a break-glass path (1.0), or you strand the box. Do **1.0 → 1.1 → 1.5 (SNMP) → 1.4 → 1.2 → 1.3** — with **1.3 dead last**. Steps 1.0/1.1/1.4/1.5 are lockout-safe; 1.2/1.3 are the sharp ones.

**1.0 — Back up + PROVE the console break-glass FIRST (the gate for everything sharp below)**
- CLI: `/export file=mkt01-preharden` then `/system backup save name=mkt01-preharden`
- 🔴 **Prove serial console recovery** (FTDI, `ADR-0016` — cable acquired 07-22): connect at **115200 8N1, no flow control**, log in → you should get `[admin@MKT01] >`. This is your break-glass and CIS priority #2 (it also gates the Phase-7 east-west deny). **Do not run 1.2/1.3 until this gives you a prompt.**
- ✅ **Device-verified 2026-07-22:** `/export` + `/system backup save` ran; **console login confirmed over serial** (`[admin@MKT01] >`).
- 📷 captures/mkt01-console.png

**1.1 — Named admin, disable `admin`**
- CLI: `/user add name=<you> group=full password=<12+ char>` then `/user disable admin`
- WinBox: System ▸ Users ▸ **+** (name, group=full, password) ▸ then select `admin` ▸ **Disable**
- ✅ `/user print` → your user `full`, `admin` `X` (disabled)
- 📷 captures/mkt01-users.png

**1.2 — Disable unused IP services; scope ssh/winbox to Management** *(🔴 lockout-sensitive — do after 1.0)*
- 🔴 **Scope to the subnet you'll actually manage from.** If you still reach MKT01 from the **ether2 laptop (`192.168.88.x`)**, scoping to `10.10.0.0/27` alone cuts your line — include both, then tighten later: `address=10.10.0.0/27,192.168.88.0/24`. If you manage from a **VLAN-10 host (`10.10.0.x`)**, `10.10.0.0/27` alone is right. Either way the **console (1.0) is your recovery** if the scope is wrong.
- 🔴 **Don't miss `reverse-proxy` (device-learned 07-22):** RouterOS 7.23.1 has a **`reverse-proxy` service on port 443** in addition to `www-ssl` — it was **enabled + open (`address=""`)** on the box and easy to overlook (disabling `www`/`www-ssl` doesn't touch it). Disable it explicitly. *(And row `D c winbox` in the print is your own live connection — the dynamic `D` row, not an open service; don't misread it, `016`.)*
- CLI:
```
/ip service disable telnet,ftp,www,www-ssl,api,api-ssl,reverse-proxy
/ip service set ssh address=10.10.0.0/27          # add ,192.168.88.0/24 if managing from ether2
/ip service set winbox address=10.10.0.0/27        # add ,192.168.88.0/24 if managing from ether2
/ip ssh set strong-crypto=yes
```
- WinBox: IP ▸ Services ▸ disable telnet/ftp/www/www-ssl/api/api-ssl/**reverse-proxy** ▸ open `ssh` and `winbox`, set **Available From** = your mgmt subnet(s)
- ✅ **Device-verified 07-22:** only `ssh` + `winbox` enabled, each `address=10.10.0.0/27,192.168.88.0/24`; `reverse-proxy` now `X`. *(plain `print` hides `address=` — use `print detail`, `016`)*
- 📷 captures/mkt01-ip-services.png

**1.3 — MAC access off the mgmt path** *(set the recovery value ONCE — `026` last-write-wins)*
- CLI:
```
/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=none
/tool mac-server ping set enabled=no
```
- WinBox: Tools ▸ Mac Server ▸ (MAC Telnet / MAC WinBox / MAC Ping) → interfaces = none
- ✅ `/tool mac-server print` + `mac-winbox print` → `none`
- 📷 captures/mkt01-mac-server.png

**1.4 — Neighbor discovery + turn off what you don't use**
- CLI:
```
/ip neighbor discovery-settings set discover-interface-list=none
/tool bandwidth-server set enabled=no
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set update-time=no
/ip dns set allow-remote-requests=no
```
- 🔎 **`/ip cloud` (device-learned 07-22):** in 7.23.1 `ddns-enabled` only accepts **`auto` / `yes`** (there is **no `no`** — `set ddns-enabled=no` errors). **`auto` is effectively off** (DDNS only activates if you configure cloud DDNS), so leave it at `auto`. What matters is **`update-time=no`** — stop pulling time from MikroTik cloud so the NTP client (1.6) is the single source. (`back-to-home-vpn` was already `revoked-and-disabled`.)
- WinBox: IP ▸ Neighbors ▸ Discovery Settings ▸ Interfaces = none · then the respective menus (IP ▸ Proxy/Socks/UPnP · IP ▸ Cloud ▸ **untick Update Time** · IP ▸ DNS · Tools ▸ BTest Server)
- ✅ **Device-verified 07-22:** discovery/btest/proxy/socks/upnp off; `/ip dns print` → `allow-remote-requests: no`; cloud `update-time=no`.
- 📷 captures/mkt01-service-hardening.png

**1.5 — SNMP: remove any v2c community + disable until MON01** *(secret hygiene — Pass 1)*
- 🔎 **POL-0001 correction (device 2026-07-22):** `/snmp community print detail` on MKT01 returned **only the default `public`** — **no `homelab`**. The `CIS-Hardening-MKT01.md` CM-0023 "homelab live on MKT01" was a **stale carryover** (the `homelab` v2c was SW01's, already removed). Don't chase a ghost — verify, then act on what's live.
- CLI:
```
/snmp community print detail                 # confirm what's actually there
/snmp community remove [find name=homelab]   # no-op here (absent) — safe to run
/snmp set enabled=no                          # SNMP off until SNMPv3 -> MON01 (Phase 6)
```
- WinBox: IP ▸ SNMP ▸ Communities (remove non-default v2c) ▸ SNMP ▸ **Enabled = off**
- ✅ **Device-verified 07-22:** only `public` (DEFAULT) present; **SNMP disabled**. *(SNMPv3 auth+priv → MON01 replaces this in Phase 6; never re-add a v2c community, `CM-0023`.)*
- 📷 captures/mkt01-snmp.png

**1.6 — Time: NTP client + timezone** *(done in Pass 1 — the clock was dead, `CM-0030`)*
- 🔎 **Why here, not deferred:** the box came up with a **stuck clock** (`date: 2026-06-03`, NTP `enabled: no / stopped`, tz `manual +00:00`) — every log/cert timestamp was wrong, and it made recent events (failed logins) look like June. NTP-synced is a Pass-1 checklist item, so fix it now that DC01 (the authoritative PDCe) exists.
- CLI:
```
/system ntp client set enabled=yes servers=10.20.0.2      # DC01 = authoritative PDCe (ADR-0020). External fallback: pool.ntp.org
/system clock set time-zone-name=America/Chicago           # Central + auto-DST (matches DC01); was manual +00:00
```
- WinBox: System ▸ NTP Client (Enabled, Servers = `10.20.0.2`) · System ▸ Clock (Time Zone Name = `America/Chicago`)
- ✅ **Device-verified 07-22:** `/system ntp client print` → **`status: synchronized`**, `synced-server 10.20.0.2`, stratum 2, offset ~2 ms; `/system clock print` → **`2026-07-22`**, `America/Chicago`, gmt-offset `-05:00`, dst-active yes. *(Read the runtime status, not the config — the `045` false-tick.)*
- 📷 captures/mkt01-ntp.png

---

## Stage 2 — VLAN gateways + trunk to SW01 (link #4)

> 🔴🔴 **Hardware truth (device-verified 2026-07-20, per Lab-01 `MKT01-Core-Router/Build-Guide` §4):** the RB1100AHx4 uses a **Realtek RTL8367** switch chip. Use the **VLAN-sub-interface model on a plain `bridge-trunk` (NOT a `vlan-filtering` bridge)**, and the trunk port **`ether3` MUST be `hw=no`** — with hardware offload on, the chip intercepts frames before RouterOS sees them and your VLAN sub-interfaces get **zero traffic** (a config that looks right and silently does nothing). `hw=no` is a **functional requirement**, not a tuning choice. **Re-verify it after every firmware update / backup restore.** Real ports are `ether1`–`ether13`: **`ether1` = uplink to the 1941**, **`ether3` = trunk to SW01**. There is no `etherA`/`etherB`.

**2.1 — `bridge-trunk` (software path) + the ether3 trunk member**
- CLI:
```
/interface bridge add name=bridge-trunk vlan-filtering=no protocol-mode=none comment="Trunk to SW01 - RTL8367 software path"
/interface bridge port add bridge=bridge-trunk interface=ether3 hw=no ingress-filtering=no
```
- WinBox: Bridge ▸ **+** (name `bridge-trunk`, Protocol Mode none, VLAN Filtering **off**) ▸ Ports ▸ **+** (interface `ether3`, **Hardware ✖ / hw=no**, Ingress Filtering off)
- ✅ `/interface bridge port print detail where interface=ether3` → 🔴 `hw=no`, `ingress-filtering=no`
- 📷 captures/mkt01-bridge-trunk.png

**2.2 — VLAN sub-interfaces on `bridge-trunk` + gateways** (from `IP-Addressing-Plan-VLSM`)
- CLI:
```
/interface vlan add name=vlan10-mgmt       vlan-id=10 interface=bridge-trunk
/interface vlan add name=vlan20-servers    vlan-id=20 interface=bridge-trunk
/interface vlan add name=vlan30-web        vlan-id=30 interface=bridge-trunk
/interface vlan add name=vlan40-monitoring vlan-id=40 interface=bridge-trunk
/interface vlan add name=vlan50-client     vlan-id=50 interface=bridge-trunk
/interface vlan add name=vlan60-deployment vlan-id=60 interface=bridge-trunk
/interface vlan add name=vlan70-testing    vlan-id=70 interface=bridge-trunk
/interface vlan add name=vlan80-dmz        vlan-id=80 interface=bridge-trunk
/interface vlan add name=vlan90-ot         vlan-id=90 interface=bridge-trunk
```
then, one address per VLAN (🔴 **never two** — a duplicate makes two connected routes / ECMP → random ~50% ping failures, Lab-01 §7):
```
/ip address add address=10.10.0.1/27 interface=vlan10-mgmt
/ip address add address=10.20.0.1/26 interface=vlan20-servers
/ip address add address=10.30.0.1/28 interface=vlan30-web
/ip address add address=10.40.0.1/28 interface=vlan40-monitoring
/ip address add address=10.50.0.1/25 interface=vlan50-client
/ip address add address=10.60.0.1/27 interface=vlan60-deployment
/ip address add address=10.70.0.1/28 interface=vlan70-testing
/ip address add address=10.80.0.1/28 interface=vlan80-dmz
/ip address add address=10.90.0.1/26 interface=vlan90-ot
```
- WinBox: Interfaces ▸ VLAN ▸ **+** (name, VLAN ID, Interface = `bridge-trunk`) ×9 · IP ▸ Addresses ▸ **+** ×9
- ✅ `/interface vlan print` → nine VLANs, all on `bridge-trunk`, `R` (running). `/ip address print` → nine gateways, **masks exactly per the VLSM plan** (/27,/26,/28,/28,/25,/27,/28,/28,/26).
- 📷 captures/mkt01-vlan-addresses.png
- ℹ️ **No bridge-VLAN table, no `vlan-filtering=yes`.** In the sub-interface model the VLAN interface does the tagging; the plain `bridge-trunk` (with `ether3 hw=no`) passes the tagged frames. This is the model Lab-01 proved on this chip. (SW01's trunk must carry the same VLAN IDs tagged.)

**2.3 — Disable unused ether/sfp** (`CM-0015` — disable ports that are genuinely unused + undocumented)
- 🔴 **Do NOT disable `ether2`** right now — it holds the `192.168.88.1/24` mgmt-fallback (pre-flight), your only laptop-reachable recovery path until the console cable / VLAN-10 mgmt exists. Disabling it here is how you re-create the power-cut lockout. Disable it later, deliberately, once another mgmt path is proven.
- CLI: `/interface ethernet disable ether4,ether5,ether6,ether7,ether8,ether9,ether10,ether11,ether12,ether13` (the retired `bridgeLocal` — omit any repurposed as access ports)
- WinBox: Interfaces ▸ select the genuinely-unused ports ▸ **Disable** *(leave `ether1` uplink, `ether3` trunk, and `ether2` mgmt-fallback enabled)*
- ✅ `/interface print` → `ether1` (uplink), `ether3` (trunk), `ether2` (mgmt-fallback) enabled; unused disabled
- 📷 captures/mkt01-interfaces.png

---

## Stage 3 — Routed /30 uplink to the 1941 + OSPF

**3.1 — Uplink /30 on `ether1` + loopback (OSPF router-id)**
- CLI:
```
/ip address add address=10.255.255.6/30 interface=ether1 comment="UPLINK-1941 (link#3)"
/interface bridge add name=loopback comment="OSPF RID"
/ip address add address=10.255.0.2/32 interface=loopback
```
- WinBox: IP ▸ Addresses ▸ **+** (10.255.255.6/30 on `ether1`) · Bridge ▸ **+** (name `loopback`, no ports) · IP ▸ Addresses ▸ **+** (10.255.0.2/32 on loopback)
- ✅ `/ip address print` → uplink + loopback present; `ping 10.255.255.5` (the 1941) once MKT01 `ether1` ↔ 1941 `Gi0/0` is cabled and up
- ⚠️ After a reset, `ether1` also carries the defconf `192.168.88.1/24` — a handy WinBox fallback during the build; remove it (`/ip address remove [find comment="defconf"]`) once another mgmt path exists, so the transit link isn't carrying a stray subnet.
- 📷 captures/mkt01-uplink.png

**3.2 — OSPF (v7): adjacency on the /30, redistribute the VLAN subnets** *(device-verified 2026-07-20)*
🔴 **`passive` is NOT a property of the OSPF interface-template in 7.23.1** (the working `ether1` template print has no `passive` field; `passive=yes` errors at "column 59"). And running OSPF on user VLANs is the wrong posture for a segmentation firewall anyway. So: **OSPF runs ONLY on the `ether1` transit; the VLAN subnets reach the 1941 via `redistribute=connected`** (advertised as OSPF external — no hellos leak onto user VLANs). Each command one line (WinBox rejects `\` / `#`).
- CLI:
```
/routing ospf instance add name=ospf1 version=2 router-id=10.255.0.2 redistribute=connected
/routing ospf area add name=backbone instance=ospf1 area-id=0.0.0.0
/routing ospf interface-template add area=backbone interfaces=ether1
```
*(instance already exists? just add redistribute: `/routing ospf instance set [find name=ospf1] redistribute=connected`)*
- WinBox: Routing ▸ OSPF ▸ Instances ▸ edit `ospf1` ▸ **Redistribute = connected** · Areas ▸ **+** (backbone, 0.0.0.0) · Interface Templates ▸ **+** (`ether1` only, area backbone)
- **Fallback** (if `redistribute` is rejected): add the VLANs as **non-passive** templates (they advertise; harmless hellos with nothing else speaking OSPF on the VLANs) — split to short lines:
  `/routing ospf interface-template add area=backbone interfaces=loopback,vlan10-mgmt,vlan20-servers,vlan30-web,vlan40-monitoring`
  `/routing ospf interface-template add area=backbone interfaces=vlan50-client,vlan60-deployment,vlan70-testing,vlan80-dmz,vlan90-ot`
- ✅ `/routing ospf neighbor print` → the 1941 as **Full**; on the 1941, `show ip route ospf` shows the VLAN subnets via 10.255.255.6
- 📷 captures/mkt01-ospf-neighbor.png
- ⚠️ If the adjacency sticks: **MTU mismatch** (RouterOS vs Cisco) or **network-type** — the OSPF-to-non-Cisco gotcha the 1941 checklist warns about. Match MTU or set both /30 ends to the same network type.

**3.3 — Default route → the 1941** *(the re-role: default now points at the 1941, not FGT01)*
- CLI: `/ip route add dst-address=0.0.0.0/0 gateway=10.255.255.5 comment="default -> 1941"`
- WinBox: IP ▸ Routes ▸ **+** (Dst 0.0.0.0/0, Gateway 10.255.255.5)
- ✅ `/ip route print` → default via 10.255.255.5; a host `traceroute` to internet = host → MKT01 → 1941 → FGT01 → out
- 📷 captures/mkt01-routes.png

---

## Stage 4 — Firewall: input protection now, forward PERMISSIVE (deferred)

**4.1 — Input chain (protect the router — safe to build now)**
- CLI:
```
/ip firewall filter add chain=input action=accept connection-state=established,related,untracked comment="in: est,rel,untracked"
/ip firewall filter add chain=input action=drop connection-state=invalid comment="in: drop invalid"
/ip firewall filter add chain=input action=accept protocol=icmp comment="in: icmp"
/ip firewall filter add chain=input action=accept src-address=10.10.0.0/27 comment="in: MGMT -> router"
/ip firewall filter add chain=input action=drop comment="in: default deny" log=yes log-prefix="INPUT-DENIED:"
```
- WinBox: IP ▸ Firewall ▸ Filter Rules ▸ **+** (one per line above)
- ✅ `/ip firewall filter print stats` → input drops non-mgmt; you still reach the box from 10.10.0.x
- 📷 captures/mkt01-input-chain.png

**4.2 — Forward chain: PERMISSIVE placeholder (do NOT build the deny yet)**
- CLI:
```
/ip firewall filter add chain=forward action=accept comment="TEMPORARY PERMISSIVE - Phase 2 bring-up; tighten in Phase 7 per Incremental worksheet"
```
- ✅ `/ip firewall filter print` → the temporary permit is present and **labelled**; forward is open so bring-up works
- 🔴 The default-deny east-west policy is built **later**, incrementally, per `Incremental-East-West-Firewall-Build-Worksheet.md`. Not here.

**4.3 — Confirm NO east-west NAT / no fasttrack on inspected flows**
- CLI: `/ip firewall nat print`  → **empty for inter-VLAN** (NAT stays at FGT01). No `fasttrack-connection` rule that would bypass the (future) east-west inspection.
- ✅ `/ip firewall nat print` empty east-west
- 📷 captures/mkt01-nat-empty.png

---

## Stage 5 — Save (services)

- CLI: `/export file=mkt01-ew-networking` + `/system backup save name=mkt01-ew-networking`
- ✅ **NTP client done in Pass 1** (§1.6 — the clock was dead) → synced to DC01 `10.20.0.2`.
- **Still deferred to Phase 6 (MON01 up):** SNMPv3 → MON01 (never the old v2c `homelab`, `CM-0023`) · syslog → MON01. RADIUS does **not** run *on* MKT01 — MKT01 is a RADIUS **client** of **NPS01** (`ADR-0029` → NPS on `NPS01`; FreeRADIUS retired).

---

## Validation — read the state back (per checklist; capture each)

- [ ] `/ip service print detail` — only ssh/winbox, scoped to 10.10.0.0/27. 📷
- [ ] `/ip address print` — nine VLAN gateways (masks exact) + uplink + loopback. 📷
- [ ] `/interface bridge print detail` — 🔴 `vlan-filtering: no` (sub-interface model on this chip); `/interface vlan print` — nine VLANs on `bridge-trunk`, `R` (running); `/interface bridge port print detail where interface=ether3` — `hw=no`. *(No bridge-VLAN table — that's the wrong model here.)* 📷
- [ ] `/routing ospf neighbor print` — 1941 **Full**; VLAN subnets learned on the 1941. 📷
- [ ] `/ip route print` — default via 10.255.255.5. 📷
- [ ] `/ip firewall filter print stats` — input default-deny; forward = one labelled permissive rule. 📷
- [ ] `/ip firewall nat print` — empty east-west. 📷
- [ ] From a host in each VLAN: gateway ping; internet reachable (permissive). 📷

## Failure modes (from the checklist)
- 🔴🔴 **RTL8367 hardware offload on `ether3`** — with `hw=yes`, VLAN sub-interfaces show **0 RX** while `ether3` shows traffic; a config that looks right and does nothing. `hw=no ingress-filtering=no` is a **functional requirement**; re-verify after every firmware update / restore (Lab-01 §4).
- 🔴 **`etherA`/`etherB` don't exist** — the RB1100AHx4 is `ether1`–`ether13`. `ether1` = uplink, `ether3` = trunk.
- 🔴 **VLANs on a `vlan-filtering` bridge instead of the sub-interface model** — the wrong model for this chip; use VLAN sub-interfaces on plain `bridge-trunk`.
- 🔴 **`passive=yes` on the OSPF interface-template** — not a valid property in 7.23.1 (errors at "column 59"). Use `redistribute=connected` on the instance instead (and keep OSPF off user VLANs).
- 🔴 **No laptop-reachable mgmt IP + a reboot** — the transit /30 and tagged trunk aren't reachable by a laptop; if MAC-WinBox drops you're stranded. Add a mgmt IP on a free port first (pre-flight).
- 🔴 **Two IP addresses on one VLAN** — ECMP / random ~50% ping failures (Lab-01 §7). One address per VLAN.
- 🔴 **WinBox terminal + `#` comments / `\` continuations** — it rejects both; paste clean one-liners.
- 🔴 **v6 vs v7 syntax** — confirm the version; these are v7 (OSPF especially changed).
- 🔴 **NAT east-west** — every internal host looks like MKT01; policy + logs useless. Keep NAT at FGT01.
- 🔴 **FastTrack on inspected flows** — inter-VLAN skips the firewall silently. Don't fasttrack east-west.
- 🔴 **Reading `print` not `print detail`** — the dynamic-row misread that faked an open service (`016`).
- 🔴 **`mac-winbox` last-write-wins** — set the recovery value once, verify live (`026`).
- 🔴 **"WinBox can't find MKT01, Neighbors list is empty" after hardening (device-learned 07-22)** — this is *expected*, not a fault: §1.4 disables neighbor discovery and §1.3 disables MAC-WinBox, so MKT01 no longer advertises itself and can't be reached by MAC. **Connect by IP** instead (WinBox "Connect To" = `10.10.0.1` from a VLAN-10 host, or `192.168.88.1` from ether2 — both in the ssh/winbox scope), and make sure your laptop has an IP in that subnet (MAC-WinBox didn't need one; IP WinBox does). The **serial console** is the ultimate recovery. *(Optional: keep a scoped `mac-winbox` on ether2 only if you want an L2 fallback — CIS-MKT01 §1.)*
- 🔴 **Default-deny east-west with no console** — deferred on purpose; permissive now, console-tested before Phase 7.
- 🔴 **Stuck clock / NTP off (`CM-0030`)** — MKT01 came up at `Jun/03` with NTP disabled; every timestamp was wrong and recent events looked old. Enable NTP → DC01 `10.20.0.2` + set the tz name (§1.6); verify by `/system clock print` + `ntp client print status`, not the config.

## Related
- `Operations/Device-Hardening-Standard.md` (the shared recovery-first + Pass-1 pattern this Stage 1 executes) · `Build-Checklist.md` (design/why) · `IP-Addressing-Plan-VLSM.md` (addresses) · `Cabling-and-Port-Map.md` (ports/links) · `Incremental-East-West-Firewall-Build-Worksheet.md` (the deferred Phase-7 firewall) · `Console-Recovery-Cable-and-Settings.md` (`ADR-0016`) · Lab-01 `MKT01-Core-Router/Build-Guide.md` (RouterOS specifics to reference) · `ADR-0023` (role) · `Master-Build-Order.md` Phase 2.

## Progress / Change Log
| Version | Date | Change |
|---|---|---|
| 0.9 | 2026-08-04 | **Doc hygiene (#43).** Removed a dead image-link example in "How to read this guide" — it pointed at a non-existent `captures/` screenshot and tripped the link-checker; reworded to describe the image-link convention in prose. No build/config change. |
| 0.8 | 2026-07-28 | **C4 auth reconciliation (docs-only).** Corrected the stale **"Pass-2 AD-LDAPS admin"** (status line) → **RADIUS admin auth → NPS on `NPS01`** (`ADR-0029`; MKT01 is a RADIUS *client*, LDAPS is FGT01's path per `ADR-0028`), and the Stage-5 note **`ADR-0004`→SRV01/NPS** → **`ADR-0029`→NPS on `NPS01`**. No config/device changes. |
| 0.1 | 2026-07-20 | First living draft — networking scope (hardening, VLAN gateways + trunk, /30 uplink, OSPF v7 to the 1941, default re-point, input-chain protection), firewall forward deferred to the incremental worksheet, services deferred to Phase 4/6. CLI + WinBox side by side; capture placeholders. |
| 0.2 | 2026-07-20 | 🔴 **Corrected on the device** (RB1100AHx4, RouterOS 7.23.1) against Lab-01 `MKT01-Core-Router/Build-Guide`. Replaced the wrong `vlan-filtering` bridge + `etherA`/`etherB` placeholders with the device-proven model: **VLAN sub-interfaces on a plain `bridge-trunk`**, trunk = **`ether3` with `hw=no`** (the RTL8367 offload trap — a functional requirement), uplink = **`ether1`**. Dropped the bridge-VLAN-table / `vlan-filtering=yes` steps. Added the RTL8367, no-etherA/B, one-IP-per-VLAN, and WinBox `#`/`\` failure modes. OSPF templates flattened to one-liners. |
| 0.3 | 2026-07-20 | Device-verified: bridge/VLAN/uplink/`ether3 hw=no`/`ether1` uplink all confirmed. OSPF fixed — **`passive` is not a valid interface-template property in 7.23.1**; switched to `redistribute=connected` on the instance (OSPF stays on the transit only, VLANs advertised as external — the right posture for a segmentation firewall), with a non-passive-template fallback. Added the **durable management-IP-first** step + failure mode after a power-outage lockout (RouterOS auto-saves; the transit/trunk aren't laptop-reachable; recovered via MAC-WinBox). |
| 0.7 | 2026-07-22 | **Phase-2.5 Pass-1 COMPLETE & device-verified.** All Stage-1 steps run on the box: named admin `mikrotikadmin` + `admin` disabled, ssh/winbox scoped to `10.10.0.0/27,192.168.88.0/24` + strong-crypto, mac-server off, unused ether disabled, SNMP off. **Two device-exposed gaps folded in:** (1) **`reverse-proxy` on 443** was enabled+open and missed by the original disable list → added to §1.2; (2) **`/ip cloud ddns-enabled` has no `no`** in 7.23.1 (`auto`=effective-off) → §1.4 now sets `update-time=no` instead. **New §1.6 NTP** (the clock was stuck at Jun/03, NTP off) → synced to DC01 `10.20.0.2`, tz `America/Chicago`, clock corrected. Added the **"empty Neighbors after hardening → connect by IP"** + **stuck-clock** failure modes. Stage 5 NTP no longer "deferred." |
| 0.6 | 2026-07-22 | Linked Stage 1 to the new **`Operations/Device-Hardening-Standard.md`** (the shared recovery-first + Pass-1 pattern all devices execute) — Stage 1 is now MKT01's device-specific instance of the standard. |
| 0.5 | 2026-07-22 | **Phase-2.5 Pass-1 hardening started.** Reworked Stage 1 into a **lockout-safe order** (new **1.0 = back up + PROVE the serial console break-glass first** — the gate for the sharp steps; explicit ordering note; 1.2 scope now warns to include your actual mgmt subnet; 1.3 mac-server flagged dead-last). Added **1.5 SNMP** (remove any v2c community + disable until MON01) with the **POL-0001 correction**: MKT01 had only the default `public`, **no `homelab`** (CM-0023 was SW01's, stale for MKT01). Device-verified 07-22: backup saved, **console login proven** over serial, SNMP disabled. |
| 0.4 | 2026-07-21 | **Internal-consistency reconciliation — no new/unverified config.** (1) 🔴 **Safety fix:** Stage 2.3 no longer disables `ether2` — it holds the live `192.168.88.1/24` mgmt-fallback (the recovery net; disabling it re-creates the power-cut lockout). Port map + 2.3 read-back updated to keep `ether2` enabled until console/VLAN-10 mgmt exists; the disable list is now the retired `ether4`–`ether13`. (2) Validation read-back corrected to the device-verified model — `vlan-filtering: no` + `/interface vlan print` (sub-interface model), **not** the stale `vlan-filtering: yes` / bridge-VLAN-table check left over from the pre-0.2 wrong model. Header → v0.4. |
