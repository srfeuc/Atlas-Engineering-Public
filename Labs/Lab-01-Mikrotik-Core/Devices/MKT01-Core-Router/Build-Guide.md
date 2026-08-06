---
Title: MKT01 Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router
---

# MKT01 Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Target Design |
| Evidence Source | Live validation 2026-07; RouterOS export |
| Last Verified | 2026-07-15 |
| Version | 2.4 |
| Hardware | MikroTik RouterBOARD RB1100AHx4 Dude Edition |
| RouterOS | 7.23.1 (stable) |

> ### This guide was incomplete for a from-factory rebuild until 2026-07-13
>
> Three things live MKT01 has were missing from this guide entirely:
>
> 1. **RADIUS.** Not present at all. MKT01's RADIUS integration was built from scratch on 2026-07-13 — it had *never actually existed*, despite Pi01 carrying a correctly-addressed `mikrotik` client block the whole time. Rebuilding from the old guide produced a router with no AAA. See **Step 14**.
> 2. **The Lab CA certificate on `www-ssl`.** Installed via `CM-0007`/`MC-0002`. Not present. Rebuilding put you back on a self-signed certificate. See **Step 15**.
> 3. **A placeholder password** in Step 1 — the same landmine that caused a real lockout on SW01.
>
> Also corrected: DNS pointed at public resolvers only, bypassing Pi-hole entirely.

## Target

Deploy MKT01 as the Atlas core router: /29 transit to FGT01, software-path VLAN trunk on `ether3`, eight routed production VLANs, VLAN 999 catch-all, `bridgeLocal` recovery network, stateful east-west firewall, hardened management services, no NAT.

MKT01 does not perform NAT, DHCP, or DNS. Those belong to FGT01 (NAT), Windows Server (DHCP/DNS), and Pi-hole (filtering).

## 🟢 Reconciliation status (2026-07-15) — and what it does and does not prove

**This guide was reconciled line-against-device on 2026-07-15** across the full config surface: identity, interfaces, addresses, routes, all 22 firewall rules, every service, `mac-server`/`mac-winbox`, discovery, the certificate **and its SAN**, DNS, NTP, RADIUS, AAA, users, and disk. Everything below matches the live MKT01 as of that date. This is the most device-grounded guide in the pack.

> 🔴 **Accuracy is not followability.** Reconciling against the *finished* device proves this guide describes the right end-state. It does **not** prove the build *sequence* survives on a bare, from-factory router — only an `ADR-0011` Game Day (a real rebuild from this guide alone) can prove that, and none has been done. Treat this as a trustworthy baseline, not a certified runbook.

### 🔴 Known gaps / not-yet-done (flagged, not silently missing)

- **SNMP** is a *live exposure*, not a missing feature: community `homelab`, v2c cleartext (`023`/`027`) — rotate to v3 or disable (`CM-0023`, unraised) before adding any monitoring.
- **Remote syslog:** none configured — but there is no collector yet (Monitoring pack, vlan40). Add when the collector exists.
- **NTP server:** MKT01 is a synced *client* only; the lab has no NTP server anywhere (`CM-0030`). Making MKT01 the interim source is a reasonable future change record.
- **Admin password rotation:** confirm `SethAdmin`'s password was rotated off any default and is in Vaultwarden (`044`/`CM-0028`).
- **Certificate step (§15)** depends on `035`, which has an open SAN-handling issue (`CM-0027`, Draft). The *current* MKT01 cert SAN is correct (`10.10.0.1`), but a reissue via `035` today may not be.
- **`vlan80-dmz`** has a gateway and route but **no forward firewall rule** — so all its traffic is denied by the east-west catch-all. That is the correct posture for an empty DMZ; explicit allow-rules get added (raising the rule count above 22) only when real DMZ hosts deploy.

## Before You Begin

| Item | Value |
|---|---|
| ether1 | 172.16.0.2/29 — transit to FGT01 internal1 |
| ether3 | `bridge-trunk` member, **`hw=no`** — trunk to SW01 Gi1/0/1 |
| ether4-13 | `bridgeLocal` 10.0.0.1/24 — recovery network |
| Default gateway | 172.16.0.1 (FGT01) |
| WinBox access | 10.0.0.1 (bridgeLocal) or 10.10.0.1 (vlan10-mgmt) |
| SSH | Port 2222, management subnets only |
| Switch chip | Realtek RTL8367 — **see Step 4** |

## 1. Verify RouterOS and Set the Password

```routeros
/system resource print
/system package print
```

Confirm RouterOS 7.23.1, RB1100AHx4 hardware. Factory default has **no password**. Set one immediately:

```routeros
/user set admin password="<REAL-VALUE-HERE>"
```

> 🔴 **Do not paste a placeholder string.** A literal placeholder is a real configured password from the moment it is set. This exact mistake caused a genuine lockout on SW01 during its original build — see `039-SW01-Troubleshooting-Guide.md`. Generate the real value, use it, store it in Vaultwarden under `MKT01 - Admin - admin`.

## 2. Set Identity

```routeros
/system identity set name=MKT01
```

Verify:

```routeros
/system identity print
# EXPECT: name: MKT01
```

> 🔴 **Corrected 2026-07-14 (`CM-0021`).** This step previously set `MikroTik` and told you *"a Change Record is required to rename the live device."*
>
> **The device has been `MKT01` since at least 2026-07-13** — confirmed live: `/system identity print` → `name: MKT01`, and the prompt reads `[SethAdmin@MKT01]`. **`022` records the rename deviation as CLOSED.**
>
> **A rebuild from the old guide named the router `MikroTik` again and re-opened a deviation that had already been closed.** **A Build Guide describes the TARGET state. The target is `MKT01`.**

## 3. Remove Factory Defaults

Stay connected via **MAC address** in WinBox's Neighbors tab. IP access will be interrupted.

> 🔴 **WARNING — added 2026-07-14 (`CM-0017`). THIS STEP AND §12 CONTRADICT EACH OTHER.**
>
> **This line depends on MAC-WinBox. §12 of this same guide DISABLES it** (`
# --- VERIFY. A command completing without an error is not a confirmed change. ---
/tool mac-server print                 # expect: none
/tool mac-server mac-winbox print      # expect: RECOVERY
/interface list member print where list=RECOVERY   # expect: exactly one member, bridgeLocal`).
>
> **During the build that ordering happens to work** — §12 runs last. 🔴 **But the router you are left with has NO MAC-connect, no serial console, and therefore no bootstrap path at all** — while `048-Teardown-and-Rebuild-Runbook.md` calls MAC-connect *"your single most important bootstrap tool."*
>
> 🔴 **A router built from this guide cannot be recovered by that runbook.** Confirmed by live test: `ERR: Could not connect, MacConnection syn timeout`.
>
> **`ADR-0014` decides the posture; `CM-0018` fixes it (MAC-WinBox scoped to `ether4`).** **Until `CM-0018` is executed and tested, do not rely on this line.**

```routeros
/ip dhcp-client remove [find]
/ip dhcp-server remove [find]
/ip dhcp-server network remove [find]
/ip pool remove [find]
/ip address remove [find]
/ip route remove [find]
/ip firewall filter remove [find]
/ip firewall nat remove [find]
```

## 4. Configure bridge-trunk for ether3

> 🔴 **This is the most critical step in the build.**
>
> The RB1100AHx4 uses Realtek RTL8367 switch chips. With hardware offload enabled on `ether3`, **the chip intercepts frames at the hardware level before RouterOS software ever sees them.** VLAN sub-interfaces receive zero traffic.
>
> The symptom is a correct-looking configuration that silently does nothing: `ether3` shows RX traffic while the VLAN sub-interfaces simultaneously show zero.
>
> **`hw=no` is not a performance tuning choice. It is a functional requirement on this hardware.**

```routeros
/interface bridge add name=bridge-trunk vlan-filtering=no protocol-mode=none comment="Trunk to SW01 - RTL8367 software path"
/interface bridge port add bridge=bridge-trunk interface=ether3 hw=no ingress-filtering=no
```

Verify before continuing — **both** settings must be present:

```routeros
/interface bridge port print detail where interface=ether3
```

If either is missing:

```routeros
/interface bridge port set [find interface=ether3] hw=no ingress-filtering=no
```

> **Re-verify `hw=no` after every firmware update and every backup restore.** It can come back.

## 5. Configure Transit

```routeros
/ip address add address=172.16.0.2/29 interface=ether1 comment="Transit to FGT01"
/ip route add gateway=172.16.0.1 comment="Default via FGT01"
```

Test immediately:

```routeros
/tool ping 172.16.0.1 count=5
```

**If this fails, stop and resolve before continuing.** Everything downstream depends on this path.

## 6. Configure bridgeLocal

```routeros
/ip address add address=10.0.0.1/24 interface=bridgeLocal comment="Recovery management network"
```

`bridgeLocal` groups ether4-ether13. **Keep it intact** — it is the recovery path when VLAN routing is unavailable.

## 7. Configure VLAN Sub-Interfaces

All nine on `bridge-trunk`. **VLAN IDs must exactly match SW01.**

```routeros
/interface vlan add name=vlan10-mgmt       vlan-id=10  interface=bridge-trunk comment="Management"
/interface vlan add name=vlan20-servers    vlan-id=20  interface=bridge-trunk comment="Servers"
/interface vlan add name=vlan30-web        vlan-id=30  interface=bridge-trunk comment="Web"
/interface vlan add name=vlan40-monitoring vlan-id=40  interface=bridge-trunk comment="Monitoring"
/interface vlan add name=vlan50-client     vlan-id=50  interface=bridge-trunk comment="Client"
/interface vlan add name=vlan60-deployment vlan-id=60  interface=bridge-trunk comment="Deployment"
/interface vlan add name=vlan70-testing    vlan-id=70  interface=bridge-trunk comment="Testing - isolated"
/interface vlan add name=vlan80-dmz        vlan-id=80  interface=bridge-trunk comment="DMZ"
/interface vlan add name=vlan999-unused    vlan-id=999 interface=bridge-trunk comment="Native VLAN catch-all"
```

Verify all nine show `R` (Running):

```routeros
/interface vlan print
```

## 8. Assign Gateway IPs

> 🟡 **Never create more than one IP address object per VLAN interface.** A duplicate creates two connected routes (ECMP). RouterOS alternates *randomly* between them, producing intermittent ARP failures and roughly 50% ping success — one of the hardest faults to diagnose, because it looks like a cabling or hardware problem.
>
> Verify with `/ip address print detail where network=10.X0.0.0` — exactly one result per VLAN.

```routeros
/ip address add address=10.10.0.1/24 interface=vlan10-mgmt comment="Management gateway"
/ip address add address=10.20.0.1/24 interface=vlan20-servers
/ip address add address=10.30.0.1/24 interface=vlan30-web
/ip address add address=10.40.0.1/24 interface=vlan40-monitoring
/ip address add address=10.50.0.1/24 interface=vlan50-client
/ip address add address=10.60.0.1/24 interface=vlan60-deployment
/ip address add address=10.70.0.1/24 interface=vlan70-testing
/ip address add address=10.80.0.1/24 interface=vlan80-dmz
```

`vlan999-unused` receives **no IP**. Verify the count:

```routeros
/ip address print
```

Expected: **10 entries** — ether1 (transit), bridgeLocal, and eight VLAN gateways. No duplicates.

## 9. Configure DNS and NTP

```routeros
/ip dns set servers=10.10.0.5,1.1.1.1,8.8.8.8 allow-remote-requests=no
/system ntp client set enabled=yes servers=pool.ntp.org
```

> 🟡 **Pi-hole (10.10.0.5) first.** The previous version of this guide listed only `1.1.1.1,8.8.8.8` — which meant MKT01 bypassed Pi-hole entirely. Corrected on the live device 2026-07-13.
>
> Confirm MKT01 is *actually* querying Pi-hole, not just falling through to public DNS:
>
> ```routeros
> :put [:resolve mikrotik.lab]
> ```
>
> A correct local answer proves the chain. This is the check that caught the original problem.

NTP is an interim value. Replace with the Windows Server AD time hierarchy after Book 3.

## 10. Create the VLANs Interface List

> **Create this list before writing any firewall rule that references it.** RouterOS validates interface-list references at rule creation time. A rule referencing a non-existent list fails immediately.

```routeros
/interface list add name=VLANs
/interface list member add list=VLANs interface=vlan10-mgmt
/interface list member add list=VLANs interface=vlan20-servers
/interface list member add list=VLANs interface=vlan30-web
/interface list member add list=VLANs interface=vlan40-monitoring
/interface list member add list=VLANs interface=vlan50-client
/interface list member add list=VLANs interface=vlan60-deployment
/interface list member add list=VLANs interface=vlan80-dmz
```

> `vlan70-testing` and `vlan999-unused` are **intentionally excluded.** vlan70 is isolated by design — internet access only, no lab VLAN access. vlan999 has no IP and carries no production traffic.

Verify exactly **seven** members:

```routeros
/interface list member print
```

## 11. Configure Firewall

**Target: 22 rules.** This set was derived by reading the live device (`/ip firewall filter print`, 2026-07-13) and removing two rules confirmed obsolete — see the notes below. **Order matters, and this order matches the device**, so a rebuild produces a comparable export. 🟢 **Re-verified against MKT01 2026-07-15:** the live `/ip firewall filter print` returns exactly these 22 rules in this order (indices 0–21) — no `10.0.0.5` fossils, both catch-all drops last in their chains, and none disabled/invalid.

> 🔴 **RouterOS defaults to ACCEPT for a chain with no matching rule.** Both catch-all drops below are therefore load-bearing. **The input-chain drop (the last rule) was missing from every previous version of this guide** — a rebuild from it produced a router with *no default deny on its input chain at all.*

Remove existing rules, then build from scratch:

```routeros
/ip firewall filter remove [find]

# --- INPUT chain: traffic TO the router itself ---
/ip firewall filter add chain=input   action=accept connection-state=established,related comment="Allow return traffic to router"
/ip firewall filter add chain=input   action=drop   connection-state=invalid log=yes log-prefix="DROPPED:" comment="Drop malformed packets input"
/ip firewall filter add chain=input   action=accept protocol=icmp limit=50,25:packet comment="Allow ping rate limited"
/ip firewall filter add chain=input   action=drop   protocol=icmp log=yes log-prefix="DROPPED:" comment="Drop excess ping"
/ip firewall filter add chain=input   action=accept in-interface=bridgeLocal comment="Allow LAN full access to router"
/ip firewall filter add chain=input   action=accept in-interface-list=VLANs comment="Allow VLAN devices to reach router"
/ip firewall filter add chain=input   action=drop   src-address=172.31.4.0/22 in-interface=ether1 log=yes log-prefix="DROPPED:" comment="Block home network from router"

# --- FORWARD chain: traffic THROUGH the router ---
/ip firewall filter add chain=forward action=accept connection-state=established,related comment="Allow return traffic through router"
/ip firewall filter add chain=forward action=drop   connection-state=invalid log=yes log-prefix="DROPPED:" comment="Drop malformed packets forward"
/ip firewall filter add chain=forward action=accept in-interface=vlan10-mgmt       out-interface-list=VLANs comment="Management full access to all VLANs"
/ip firewall filter add chain=forward action=accept in-interface=vlan40-monitoring out-interface-list=VLANs comment="Monitoring read access to all VLANs"
/ip firewall filter add chain=forward action=accept in-interface=vlan20-servers    out-interface=ether1 comment="Servers to internet"
/ip firewall filter add chain=forward action=accept in-interface=vlan50-client     out-interface=vlan20-servers comment="Clients to Servers"
/ip firewall filter add chain=forward action=accept in-interface=vlan50-client     out-interface=ether1 comment="Clients to internet"
/ip firewall filter add chain=forward action=accept in-interface=vlan60-deployment out-interface=vlan20-servers comment="Deployment to Servers"
/ip firewall filter add chain=forward action=accept in-interface=vlan30-web        out-interface=vlan20-servers comment="Web tier to Servers"
/ip firewall filter add chain=forward action=accept in-interface=vlan70-testing    out-interface=ether1 comment="Testing internet only - isolated from lab"
/ip firewall filter add chain=forward action=accept in-interface=bridgeLocal       out-interface-list=VLANs comment="Admin laptop bridgeLocal to VLANs"
/ip firewall filter add chain=forward action=accept in-interface=bridgeLocal       out-interface=ether1 comment="Flat network to internet"
/ip firewall filter add chain=forward action=accept in-interface=vlan10-mgmt       out-interface=ether1 comment="Management to internet"

# --- CATCH-ALL DROPS: both required. RouterOS defaults to ACCEPT without them. ---
/ip firewall filter add chain=forward action=drop log=yes log-prefix="EAST-WEST-DENIED:" comment="Drop everything else"
/ip firewall filter add chain=input   action=drop log=yes log-prefix="INPUT-DENIED:" comment="Drop all other traffic to router"
```

Verify:

```routeros
/ip firewall filter print count-only
```

Expected: **22**.

### Adding rules later

**Never insert by hard-coded rule number.** Anchor to the catch-all by comment:

```routeros
place-before=[find comment="Drop everything else"]     # for forward-chain rules
place-before=[find comment="Drop all other traffic to router"]   # for input-chain rules
```

### Note — no FortiGate→Pi01 RADIUS rules here, and why

Earlier versions of this guide, and the live device until `CM-0009`, carried two rules:

```text
;;; FortiGate ping to Pi-hole      dst-address=10.0.0.5  in=ether1 out=bridgeLocal
;;; FortiGate RADIUS to Pi-hole    dst-address=10.0.0.5  in=ether1 out=bridgeLocal dst-port=1812,1813
```

**Both were dead, for two independent reasons:**

1. **`10.0.0.5` is Pi01's pre-VLAN flat-network address.** Pi01 is at **10.10.0.5**. The rules matched nothing.
2. **Correcting the address would not have helped, because MKT01 is not in that path.** FGT01's `internal2` (`10.10.0.254/24`) and Pi01 (`10.10.0.5/24`) are on the **same subnet, same VLAN 10, Layer-2 adjacent via SW01**. FGT01→Pi01 RADIUS goes FGT01 → SW01 → Pi01. It never touches MKT01's forward chain.

This is why FGT01's RADIUS was confirmed working end-to-end while these rules pointed at a nonexistent host: *MKT01 was never involved.* Pi01's own UFW rule (`from 10.10.0.254`) confirms the same-subnet source.

They were fossils from the flat-network topology, surviving only because nothing depended on them. Removed via `CM-0009`, per the standard that a firewall rule must have a documented purpose.

> 🟡 **If VMs on VLANs 20–80 ever need Pi01 as a DNS or RADIUS target, that traffic *does* cross MKT01** and will need real forward rules. Add them then, against a real requirement — not preemptively.

## 12. Harden Management Services

> ✅ **REWRITTEN 2026-07-14 (`CM-0018` / `ADR-0014` / `ADR-0016`).**
>
> **The previous version of this section ended with three unexplained lines** — 🔴 **described here in prose, NOT as a code block, deliberately:**
>
> | It set | To |
> |---|---|
> | `/ip neighbor discovery-settings` → `discover-interface-list` | `static` *(the disclosure leak — still open, deferred by `ADR-0016`)* |
> | `/tool mac-server` → `allowed-interface-list` *(MAC-Telnet)* | `none` *(correct — keep)* |
> | 🔴 **`/tool mac-server mac-winbox` → `allowed-interface-list`** | 🔴 **`none` — THIS is the one that destroyed the recovery path** |
>
> 🔴 **These are NOT in a code fence, and that is on purpose.** **`CM-0017`'s root cause was this guide's §12 being quoted as illustrative text in a chat message — it contained live `set` commands, and it was pasted into the router.** *(It was harmless only by luck: the commands happened to be idempotent.)*
>
> > **Ground rule (`To-The-Next-Session` §7): any block of device commands, in any medium, will eventually be pasted into a device. Assume it will be.**
>
>
> 🔴 **`mac-winbox=none` DESTROYED the recovery path** that **step 3 of this very guide** tells you to rely on, and that `048-Teardown-and-Rebuild-Runbook.md` calls *"your single most important bootstrap tool."*
>
> 🔴 **A router built from the old guide had NO way in if its addressing broke** — MKT01 has **no serial console**. **Nobody found it because nobody has ever rebuilt** (`ADR-0011`).
>
> **They survived because they had no rationale attached. An unexplained hardening line is unreviewable — nobody can tell a good one from a catastrophic one.** **Every line below now says why.**
>
> 🔴 **AND: `/ip service set winbox address=...` does NOT restrict MAC-WinBox.** That address list governs **IP** WinBox on 8291. **MAC-WinBox is raw Ethernet — no IP, no port — and the input-chain default deny never evaluates it.** Every other management restriction on this router operates at Layer 3. **MAC-WinBox operates below all of them, and `allowed-interface-list` IS its entire access control.**

```routeros
/ip service set telnet  disabled=yes
/ip service set ftp     disabled=yes
/ip service set www     disabled=yes
/ip service set api     disabled=yes
/ip service set api-ssl disabled=yes

# 🔴 reverse-proxy. Found ENABLED on port 443 with address="" (NO source restriction)
#    and certificate=none, during the 2026-07-12 validation. Undocumented until then.
#    CM-0006 disabled it on the device — and never reached this guide (it predates
#    Charter Rule 15 and has no Build Guide row). A rebuild without this line brings
#    an unrestricted, uncertificated reverse proxy back on the core router. CM-0021.
/ip service set reverse-proxy disabled=yes

/ip service set ssh     port=2222 address=10.0.0.0/24,10.10.0.0/24
/ip service set winbox  address=10.0.0.0/24,10.10.0.0/24
/ip service set www-ssl disabled=no address=10.0.0.0/24,10.10.0.0/24
# --- Layer-2 management. Read the notes below BEFORE running these. ---

# MAC-Telnet: OFF. An unauthenticated-transport shell. Nothing in Atlas needs it.
/tool mac-server set allowed-interface-list=none

# Break-glass recovery scope. bridgeLocal ONLY - NOT bridge-trunk (which carries every VLAN).
/interface list add name=RECOVERY comment="MKT01 break-glass. MAC-WinBox scope. See ADR-0014."
/interface list member add list=RECOVERY interface=bridgeLocal

# MAC-WinBox: scoped to RECOVERY. This is MKT01's ONLY bootstrap path - it has no console.
# A VLAN-adjacent host has no L2 path to bridgeLocal and gets nothing.
/tool mac-server mac-winbox set allowed-interface-list=RECOVERY

# Neighbour discovery. NOTE: 'static' advertises identity/version/board/uptime on EVERY
# static interface, including every VLAN. This is a known open disclosure (ADR-0016),
# deferred to Book 10. The secure value is RECOVERY.
/ip neighbor discovery-settings set discover-interface-list=static
/tool bandwidth-server set enabled=no
```

## 🔴 VERIFY — and `/ip service print` CANNOT show you the important one

```routeros
/ip service print
```

**Expected:** `telnet`, `ftp`, `www`, `api`, `api-ssl`, **`reverse-proxy`** all show `X` (disabled). SSH on **2222**. `winbox` and `www-ssl` restricted to `10.0.0.0/24`, `10.10.0.0/24`.

> 🟡 **You will also see two `D` (dynamic) rows — `ntp` (123) and `discover` (5678).** They are **not** services you configured. `ntp` is the NTP *client*'s socket (`/system ntp server` is `enabled: no` — MKT01 serves no time). `discover` is **MNDP**, created by `/ip neighbor discovery-settings`. **Verified on the device 2026-07-14.**
>
> 🟡 **A `D c` `winbox` row with `remote=<your IP>` is YOUR OWN live session**, connection-tracked. **`/ip service print` hides `remote=`; only `print detail` shows it.** That is why this row sat "unexplained" in four documents. **Use `print detail`.**

### 🔴 MAC-WinBox is NOT an `/ip service`. It will not appear above. Check it separately.

```routeros
/tool mac-server mac-winbox print
# EXPECT: allowed-interface-list: RECOVERY      <-- NOT none.

/tool mac-server print
# EXPECT: allowed-interface-list: none          <-- MAC-Telnet stays off.

/interface list member print where list=RECOVERY
# EXPECT: exactly one member — bridgeLocal.
```

> 🔴 **If `mac-winbox` reads `none`, this router has NO WAY IN if its addressing breaks — and MKT01 has NO SERIAL CONSOLE.**
>
> 🔴 **A previous version of this guide set `RECOVERY` and then set `none` six lines later.** RouterOS `set` is **last-write-wins**, so the recovery path was silently destroyed by the very block written to build it. **`CM-0021`.**
>
> **That is why this check exists, and why it is not in the `/ip service` block above.**

> SSH is on port **2222**. Use `ssh -p 2222` when connecting directly. WinBox is unaffected.

## 13. Save Configuration

```routeros
/system backup save name=mkt01-baseline
/export hide-sensitive file=mkt01-baseline-export
```

Pull both files from WinBox Files to a safe location. The `.rsc` export is human-readable and supports selective restoration.

## 14. Configure RADIUS

> 🔴 **Missing from this guide entirely until 2026-07-13.**
>
> MKT01's RADIUS integration **never actually existed**, despite Pi01's `clients.conf` carrying a correctly-addressed `mikrotik` client block for a long time. **Only one side of the integration had ever been finished.** A rebuild from the old guide reproduced exactly that gap.

Retrieve the `mikrotik` client secret from Vaultwarden (`MKT01 - RADIUS - mikrotik client secret`).

```routeros
/radius add service=login address=10.10.0.5 secret=<mikrotik client secret> timeout=2s
/user aaa set use-radius=yes
/user aaa set accounting=yes
```

> 🔴 **Two traps, both hit for real:**
>
> **1. `/radius add` alone does nothing.** MikroTik has a *separate* `/user aaa` setting — `use-radius` — that must explicitly be `yes`. A perfectly configured RADIUS server entry is inert without it. **This was the actual root cause the whole time.**
>
> **2. `use-radius=yes` did not persist on the first attempt**, and returned no error. Always re-check immediately:
>
> ```routeros
> /user aaa print
> /radius print detail
> ```
>
> `/radius print detail` also catches **duplicate entries** — RouterOS does not warn about or merge them. A stale duplicate (commented `;;; PiHole`) was found holding an old compromised secret.

Local accounts remain functional. RADIUS is an *additional* auth path, not a replacement — MKT01 falls back to local accounts if Pi01 is unreachable. That is what makes the rollback safe.

## 15. Install the Lab CA Certificate on www-ssl

> 🔴 **Also missing from this guide entirely.** Installed via `CM-0007` and correctly reissued via `MC-0002`. A rebuild from the old guide left MKT01 serving a self-signed certificate.

1. Issue a certificate from the Lab CA with a **correct SAN** (`DNS:mikrotik.lab, IP:10.10.0.1`) — see `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`. **Verify the SAN on the file before proceeding** — the CA silently issued a SAN-less certificate once.

2. Drag the bundle and key into WinBox → **Files**. **Run WinBox as Administrator** or the upload fails on a permissions error.

3. `System > Certificates` → Import.

   > **RouterOS renames the object on import** (e.g. `mikrotik-bundle.crt_0`). It does **not** keep your filename. Note the new name.

4. **Remove any old certificate objects first.** Two objects invites binding to the wrong one later:

   ```routeros
   /certificate remove [find name~"<old-name>"]
   ```

5. `IP > Services` → `www-ssl` → set **Certificate** to the *new* object name.

Verify on the **live-served connection**, not the file:

```bash
openssl s_client -connect 10.10.0.1:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -text | grep -A1 "Subject Alternative Name"
```

## Validation

```routeros
/interface bridge port print detail where interface=ether3
/interface vlan print
/interface list member print
/ip address print
/ip route print
/ip firewall filter print count-only
/ip service print detail
/radius print detail
/user aaa print
/system identity print
/tool ping 172.16.0.1 count=5
/tool ping 1.1.1.1 count=5
:put [:resolve mikrotik.lab]

# 🔴 MAC-WinBox is NOT an /ip service. It appears in NONE of the above.
/tool mac-server mac-winbox print
/tool mac-server print
/interface list member print where list=RECOVERY
```

Expected:

- `/system identity print` → **`MKT01`**
- `ether3` bridge port shows **`hw=no`** and `ingress-filtering=no`
- Nine VLAN interfaces, all `R` (Running)
- VLANs list has exactly **seven** members
- Ten IP addresses — no duplicates
- Default route via `172.16.0.1`
- **Firewall: exactly `22` rules** — device-verified 2026-07-14
- Telnet, FTP, www, api, api-ssl **and `reverse-proxy`** disabled; SSH on 2222
- `use-radius: yes`; exactly one RADIUS entry
- `:resolve mikrotik.lab` returns the local answer — proving Pi-hole is actually queried
- Ping to `172.16.0.1` and `1.1.1.1` — 0% loss
- 🔴 **`mac-winbox allowed-interface-list: RECOVERY`** — **NOT `none`**
- 🔴 **`mac-server allowed-interface-list: none`** — MAC-Telnet stays off
- 🔴 **`RECOVERY` list has exactly one member: `bridgeLocal`**

> 🟡 **Two `D` (dynamic) rows are normal:** `ntp` (123) is the NTP *client*; `discover` (5678) is MNDP. **A `D c` `winbox` row with `remote=<your workstation IP>` is your own live session.** *(`print detail` shows `remote=`. Plain `print` does not — which is why this row was "unexplained" in four documents until 2026-07-14.)*

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `hw=yes` on ether3 bridge port | **VLAN interfaces show 0 RX while ether3 shows traffic** | Set `hw=no ingress-filtering=no` |
| Duplicate IP object on a VLAN | Intermittent ARP failures, ~50% ping success | Remove the stale entry |
| Interface list created after firewall rules | Rule creation fails outright | Create and populate `VLANs` first |
| vlan70-testing added to the VLANs list | Testing VLAN can reach lab VLANs | Remove it — isolation is the point |
| Catch-all drop not last | Legitimate traffic dropped | Use `place-before=[find comment="Drop everything else"]` |
| Missing Management-to-internet rule | VLAN 10 devices have no internet access | Add the forward rule |
| SSH attempted on port 22 | Connection timeout | Use port 2222 |
| **`/radius add` without `use-radius=yes`** | **RADIUS silently does nothing** | `/user aaa set use-radius=yes`, then **verify** |
| **Trusting a `set` that returned no error** | Change didn't persist | Re-print immediately, every time |
| **DNS set to public resolvers only** | MKT01 bypasses Pi-hole; local names don't resolve | Pi-hole first; confirm with `:resolve mikrotik.lab` |
| Placeholder password in Step 1 | Locked out with a "placeholder" that is a real password | Generate the real value before you type anything |

## Rollback

```routeros
/import file=mkt01-baseline-export.rsc
```

Or restore the binary backup: `/system backup load name=mkt01-baseline`

**After any restore, re-verify `hw=no` on ether3**, routes, management access, and internet reachability.

RADIUS rollback: `/user aaa set use-radius=no` reverts to local-account-only auth — safe at any time, since local accounts are never disabled by this build.

## Completion Checklist

- [ ] RouterOS 7.23.1 verified
- [ ] Password set to a **real generated value**, stored in Vaultwarden
- [ ] Identity set
- [ ] Factory defaults removed
- [ ] `bridge-trunk` created; **`hw=no` and `ingress-filtering=no` on ether3 — verified, not assumed**
- [ ] Transit 172.16.0.2/29 on ether1; ping to FGT01 succeeds
- [ ] `bridgeLocal` 10.0.0.1/24 intact
- [ ] Nine VLAN interfaces on bridge-trunk — all `R`
- [ ] Eight gateway IPs assigned — **no duplicates**
- [ ] DNS points at Pi-hole first; `:resolve mikrotik.lab` confirms it
- [ ] VLANs interface list — exactly seven members
- [ ] Firewall: **22 rules**, verified with `/ip firewall filter print count-only`
- [ ] **Both catch-all drops present** — forward *and* input. RouterOS defaults to ACCEPT without them.
- [ ] Services hardened — telnet/ftp/www/api/api-ssl **and `reverse-proxy`** disabled, SSH on 2222
- [ ] 🔴 **`mac-winbox allowed-interface-list` = `RECOVERY`** — read back with `/tool mac-server mac-winbox print`. **NOT `none`.** *(It is not an `/ip service`. It will not show up in `/ip service print`.)*
- [ ] 🔴 **`mac-server` (MAC-Telnet) = `none`** — read back, not assumed
- [ ] 🔴 **`RECOVERY` list has exactly one member: `bridgeLocal`**
- [ ] 🔴 **MAC-CONNECT TESTED FROM `ether4` — IT CONNECTED.** *(Reading the config string is **not** the test. See "Post-build: PROVE the recovery path" below — **do not skip it.**)*
- [ ] **RADIUS configured; `use-radius=yes` verified via `/user aaa print`**
- [ ] **Lab CA certificate bound to `www-ssl`, verified on the live connection**
- [ ] Configuration exported
- [ ] Build Record updated

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Troubleshooting.md`
- `Labs/Lab-01-Mikrotik-Core/Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/FreeRADIUS/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`


## 🔴 Disable unused interfaces — `ether2`

**`ether2` has no assigned purpose and nothing connected to it.** Per the **Unused Interface Policy** (`010-Security-Zones.md`), it must be **administratively disabled** — not left at factory default.

```text
/interface set [find name=ether2] disabled=yes comment="Unused - disabled per 010 Unused Interface Policy, CM-0015"
```

**Read it back. Do not trust the clean command:**

```text
/interface print
```

**Expected:** the flags legend includes **`X - DISABLED`**, and `ether2` carries an `X`.

> 🔴 **This step did not exist until 2026-07-13.** A router rebuilt from the previous version of this guide came back with **`ether2` enabled, idle, and undocumented** — exactly the state `CM-0015` was raised to fix. **The guide recreated the finding.**
>
> **Set the comment.** It makes the device self-documenting: the next person to run `/interface print` sees *why* the port is off and *which record to read*, without opening Atlas.

**Also disable the unused `bridgeLocal` ports `ether5`–`ether13`** — keep only `ether4` live (`CM-0035`, `ADR-0014`). `bridgeLocal` is the recovery network and stays, but only one port needs to be up:

```text
/interface disable ether5,ether6,ether7,ether8,ether9,ether10,ether11,ether12,ether13
/interface print
```

**Expected:** `ether5`–`ether13` carry `X`; **`ether4` does NOT** — it is the sole live recovery port.

> 🔴 **`ether4` only.** During recovery, a cable in `ether5`–`ether13` is dead. `ADR-0014`/`CM-0018` had recorded these nine as already disabled; the device showed them enabled until `CM-0035` actually disabled them on 2026-07-15.

## 🔴 Disable the default `admin` user

The factory image ships an enabled `admin` account. Disable it — `SethAdmin` (RADIUS-backed, full group) is the working login (`CM-0034`):

```text
/user disable admin
/user print
```

**Expected:** `admin` carries `X`; `SethAdmin` is enabled and is now the **only** enabled account.

> 🔴 **After this, `SethAdmin` is the sole enabled login.** Its password must live in Vaultwarden and be recoverable. If it is lost: MAC-WinBox into `ether4` (`CM-0018`), or a factory reset — MKT01 has **no serial console** (`ADR-0016`).

## Change Log — MOVED

> **The Change Log now sits at the FOOT of this document, below "Post-build: PROVE the recovery path."**
>
> 🔴 **It used to sit HERE — above three load-bearing sections, including the ONLY control that catches a broken recovery path.** A reader who scrolled to the Change Log had every reason to think the document had ended. **`CM-0021`.**

<!-- ARCHIVED CHANGE LOG ROWS - superseded by the Change Log at the foot of this file
| 2.0 | Reconciled 2026-07. |
| 2.1 | **Step 14 (RADIUS) and Step 15 (Lab CA certificate) added** — both exist on the live device and appeared nowhere in this guide, so a from-factory rebuild produced a router with no AAA and a self-signed certificate. **Placeholder password removed** from Step 1. **DNS corrected** to put Pi-hole first — the guide bypassed it entirely. **Step 11 firewall rebuilt from the live device** (`/ip firewall filter print`, 2026-07-13), resolving a count that three documents gave as 22, 23, and 24. Two findings: (a) the input-chain default deny was missing from every previous version of this guide; (b) two FortiGate→Pi-hole rules pointed at Pi01's pre-VLAN address `10.0.0.5`. Removed as fossils via `CM-0009`. Rule order now matches the device. Target: 22 rules. |
-->

## 🔴 The `bridgeLocal` address comment is part of the build

**When you create the recovery network's gateway address, comment it. This is not cosmetic.**

```routeros
/ip address set [find address="10.0.0.1/24"] comment="ADMIN RECOVERY NETWORK - DO NOT REMOVE. MAC-WinBox scope (RECOVERY list). Plug into ether4. See 003, 016, ADR-0013, ADR-0014, ADR-0016."
/ip address print detail where address="10.0.0.1/24"
```

**Why (`CM-0016`):** this address was previously commented **`;;; Legacy flat management`**. **That label is what caused `017-Future-Expansion.md` v1.0 to propose retiring the recovery network** — while `003` and `016` both said, in writing, *do not remove `bridgeLocal`*. **Three documents; the one that was wrong got its idea from the device itself.**

> 🔴 **Charter Rule 13 — the device beats the document — cuts both ways. When the device says something misleading, it does MORE damage than a misleading document, because everyone trusts it more.**

**A router rebuilt without this comment comes back with an unlabelled recovery network, and someone re-invents "legacy" for it. That is `CM-0015`'s lesson: a guide that does not mention a thing will recreate the thing.**

## 🔴 Post-build: PROVE the recovery path. Do not skip this.

**Reading `allowed-interface-list: RECOVERY` proves a string landed. It proves NOTHING about whether you can recover this router.**

1. **Cable the admin workstation directly into `ether4`.**
2. WinBox → **Neighbors** → **select ONE row** → click the **MAC address**, not the IP → **Connect.**
3. **It must connect.** If it returns `MacConnection syn timeout`, the scope is wrong — **stop and fix it before you walk away from this router.**

🔴 **KNOWN LIMIT — verified 2026-07-14:** **the session connects, then DROPS after roughly 15 seconds.** Minimal config, static addressing, direct cable, read-only commands — **it is the transport, not the configuration.**

> **MAC-WinBox is a break-glass transport, not a management session.** **The bar is: get in, set an IP, switch to a real session.** Three commands fit in the window. **Know exactly what you are going to type before you click Connect.**

🔴 **NEVER modify the interface list your current session's transport is bound to, while riding that transport.** Changing `RECOVERY` from a live MAC-WinBox session **kills the session instantly.** This is the network engineer's `rm -rf` on the directory you are standing in. **Make the change from a session that does not depend on the thing you are changing.**

## 🔴 What this guide still leaves open (`ADR-0016`)

- **All ten `bridgeLocal` ports (`ether4`–`ether13`) stay enabled.** A deliberate, recorded decision. **The real control for physical access is `port-security` on SW01** — Book 10.
- **Neighbour discovery remains `static`** — the version/board disclosure to every VLAN is **open**. One command (`discover-interface-list=RECOVERY`) closes it, with no lockout risk. **Book 10's first job.** *(Device-confirmed 2026-07-14: `discover-interface-list: static`, `protocol: cdp, lldp, mndp`.)*
- **No serial console.** Three USB-serial adapters bought; none worked. **In production this would be non-negotiable.**

---

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Reconciled 2026-07. |
| 2.1 | **Step 14 (RADIUS) and Step 15 (Lab CA certificate) added** — both exist on the live device and appeared nowhere in this guide, so a from-factory rebuild produced a router with no AAA and a self-signed certificate. **Placeholder password removed** from Step 1. **DNS corrected** to put Pi-hole first. **Step 11 firewall rebuilt from the live device**, resolving a count three documents gave as 22, 23 and 24. Two findings: the **input-chain default deny was missing from every previous version** (RouterOS defaults to ACCEPT), and two FortiGate→Pi-hole rules pointed at Pi01's **pre-VLAN address `10.0.0.5`** on a path MKT01 is not in — removed as fossils via `CM-0009`. Target: **22 rules**. |
| **2.2** | 🔴 **2026-07-14 — `CM-0021`. Every change below was made AFTER reading the live device, not from a document.** <br><br>🔴 **§12 SET `mac-winbox=RECOVERY` ON ONE LINE AND `none` SIX LINES LATER.** RouterOS `set` is **last-write-wins** — so the section rewritten on 2026-07-14 to *build* the recovery path **destroyed it**, and a router rebuilt from this guide came back with **no way in and no serial console.** The `RECOVERY` block had been *appended*; the old line was never *deleted*. **The stale line is gone.** <br><br>🔴 **§12 never disabled `reverse-proxy`** — found live on 443 with `address=""` and `certificate=none`. `CM-0006` disabled it on the device in 2026-07-12 and **never reached this guide** (it predates Charter Rule 15 and has no Build Guide row). **Added.** <br><br>🔴 **Nothing in this guide could have caught either.** §12's verify block was `/ip service print` — **and MAC-WinBox is not an `/ip service`, so it cannot appear there.** The Validation section had no `mac-server` command. **The Completion Checklist had no MAC-WinBox line at all.** **All three now check it, and the checklist demands a LIVE MAC-CONNECT, not a config read.** <br><br>🔴 **Step 2 built the wrong identity** (`MikroTik`), re-opening a deviation `022` records as closed. **Device: `name: MKT01`.** Corrected. <br><br>🔴 **The Change Log sat ABOVE three load-bearing sections**, including *"Post-build: PROVE the recovery path"* — **the only control that catches this class of defect.** **Moved to the foot.** <br><br>🟢 **Verified against MKT01, 2026-07-14 — no change needed:** firewall is **22 rules in exactly the order §11 builds them**; `ether3` is `hw=no ingress-filtering=no`; `ether2` is `X`; `RECOVERY` holds one member (`bridgeLocal`); `mac-server` is `none`; the `bridgeLocal` comment persisted; `use-radius: yes`; DNS is `10.10.0.5, 1.1.1.1, 8.8.8.8`. <br><br>🟢 **`/ip service print detail` SOLVED the dynamic WinBox row** — open in four documents as *"probably a session artefact, NOT VERIFIED."* It is `remote=10.10.0.50` — **the admin workstation's own live session.** Plain `print` hides `remote=`; only `print detail` shows it. **Verified and closed.** |
| **2.4** | 🟢 **2026-07-15 — full device reconciliation.** Verified line-against-device across the entire config surface (see the Reconciliation Status block at the top). Added two hardening steps proven on the device the same day: **disable `ether5`–`ether13`** keeping `ether4` as the sole recovery port (`CM-0035`), and **disable the default `admin` user** (`CM-0034`). Corrected the `bridgeLocal` interface comment off "Legacy." Added a **Known Gaps** block (SNMP v2c exposure, syslog, NTP server, password rotation, the `035`/SAN dependency) and documented `vlan80-dmz` isolation. Stated the honest limit: accurate to the device, not yet proven followable (no Game Day). |
