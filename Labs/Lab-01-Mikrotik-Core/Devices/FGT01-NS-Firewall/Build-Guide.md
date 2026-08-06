---
Title: FGT01 Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall
---

# FGT01 Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | 🔴 **`Target Design`** — **a Build Guide describes what SHOULD be. It is NEVER `Verified`.** *(This said `Verified` until 2026-07-14. `CM-0033`.)* |
| Evidence Source | Live FGT01 device pass, 2026-07-14 (`get`, not `show`) |
| Last Verified | 2026-07-14 |
| Version | **3.1** |
| Applies To | Atlas 2.0 |
| Hardware | FortiGate 60E (physical — not FortiGate-VM) |
| FortiOS | 7.4.5 build2702 |
| Last Reconciled | 2026-07-16 |

## Target

Deploy FGT01 as the Atlas perimeter firewall: WAN DHCP uplink, /29 transit to MKT01, dedicated management interface on VLAN 10, /8 return route, outbound NAT, restricted administration, DNS/NTP baseline.

FGT01 does not perform inter-VLAN routing. That belongs to MKT01.

## Before You Begin

| Item | Value |
|---|---|
| Hardware | FortiGate 60E physical |
| FortiOS | 7.4.5 build2702 |
| Serial | FGT60ETK18099YR2 |
| wan1 | DHCP from home router |
| internal1 | 172.16.0.1/29 — transit to MKT01 ether1 |
| internal2 | 10.10.0.254/24 — management, VLAN 10 |
| internal2 MAC | 00:00:5e:00:53:03 — required for SW01 STATIC-HOSTS |
| MKT01 transit IP | 172.16.0.2 |
| SW01 port for internal2 | Gi1/0/6, VLAN 10 access |
| Console | 9600 baud, 8N1, no flow control |

> **Interface names are hardware-specific.** Physical 60E uses wan1, internal1, internal2, etc. FortiGate-VM uses port1, port2. Do not mix these up.

## 1. Verify Firmware and VDOM Mode

```text
get system status
```

Confirm FortiOS 7.4.5 build2702, correct serial, NAT mode. Note the VDOM mode — factory units may be in multi-VDOM mode. If multi-VDOM is active, `set vdom "root"` is required in every interface block. Verify before writing any interface config.

## 2. Set Hostname and Timezone

```text
config system global
    set hostname "FGT01"
    set timezone "America/Chicago"
end
```

> **Do not use numeric timezone codes.** `set timezone 23` returns "entry not found in datasource" on 7.4.5. Use the full string name. Run `set timezone ?` to list valid options for your firmware.

## 3. Split Internal Ports from Hardware Switch

On a factory 60E, internal1 through internal7 are members of the `internal` hardware switch. Individual IP assignment fails with a parse error until they are removed. Remove dependent defaults first.

```text
config system dhcp server
    purge
end
```

```text
config firewall policy
    purge
end
```

```text
config system virtual-switch
    edit "internal"
        config port
            delete internal1
            delete internal2
        end
    next
end
```

Verify both show `set type physical` before continuing:

```text
show system interface | grep "edit\|type"
```

> `set internal-switch-mode interface` does not exist in FortiOS 7.4.5. Use `config system virtual-switch` as shown above.

## 4. Configure Interfaces

```text
config system interface
    edit "wan1"
        set vdom "root"
        set mode dhcp
        set alias "WAN-HOME-ROUTER"
        set allowaccess ping
        set role wan
    next
    edit "internal1"
        set vdom "root"
        set ip 172.16.0.1 255.255.255.248
        set alias "TRANSIT-TO-LAB"
        set allowaccess ping https ssh
        set role lan
    next
    edit "internal2"
        set vdom "root"
        set ip 10.10.0.254 255.255.255.0
        set alias "MANAGEMENT"
        set allowaccess ping https ssh
        set role lan
    next
end
```

> Do not add https or ssh to wan1 allowaccess.

## 5. Configure Return Route

The static route must cover `10.0.0.0/8`. A /24 route only covers the legacy flat network — all VLAN subnets lose their return path silently.

```text
config router static
    edit 1
        set dst 10.0.0.0 255.0.0.0
        set gateway 172.16.0.2
        set device "internal1"
    next
end
```

Verify:

```text
get router info routing-table all
```

Expected: default route via wan1, `10.0.0.0/8` via `172.16.0.2` on internal1, connected routes for both internal interfaces.

## 6. Address Objects — 🔴 **DO NOT CREATE THEM. `ADR-0005` DEFERRED THIS.**

> 🔴🔴 **THIS STEP BUILT `Lab-Network` AND `Transit-Link` UNTIL 2026-07-14. THEY DO NOT EXIST ON THE DEVICE.**
>
> **Device-verified, 2026-07-14:**
> ```
> FGT01 # get firewall address
> == [ all ] == [ dmz ] == [ internal ] == [ internal1 address ] == [ internal2 address ]
> == [ EMS_ALL_UNKNOWN_CLIENTS ] == [ FABRIC_DEVICE ] == [ SSLVPN_TUNNEL_ADDR1 ] ...
> ```
> 🔴 **Every object is a FortiOS factory default. `Lab-Network` and `Transit-Link` are NOT THERE.**
>
> 🔴 **`ADR-0005` DELIBERATELY DECIDED TO KEEP `srcaddr all` UNTIL THE NETWORK HAS REDUNDANCY.** *"Aggressively narrowing outbound access now raises real risk of breaking something quietly — NTP, DNS-over-TLS, package updates all depend on broad outbound reachability — without the redundancy in place to safely test and recover."*
>
> 🔴 **A REBUILD FROM THE OLD GUIDE SILENTLY EXECUTED A DEFERRED DECISION.** **And the `/24`-vs-`/8` scoping mistake — which caused a real, lab-wide internet outage during the original build — was waiting on the other side of it.**

**Build nothing here. Go to Step 7.**

## 7. Outbound Policy — **build what the device HAS**

```text
config firewall policy
    edit 1
        set name "LAB-to-Internet"
        set srcintf "internal1"
        set dstintf "wan1"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set nat enable
    next
end
```

**Verify — 🔴 `get`, NEVER `show`:**

```text
get firewall policy
get firewall address
```

> 🔴 **`srcaddr all` IS THE CURRENT, DELIBERATE STATE** (`ADR-0005`). **It is broad, and it is a recorded decision with a review trigger — not an oversight.**

### 🔴 The scoped design — the FUTURE target, NOT this build

**When the network gains real redundancy (a second WAN path, a redundant firewall), `ADR-0005`'s review trigger fires and this becomes the work:**

```text
Lab-Network    = 10.0.0.0/8          🔴 /8. NOT /24.
Transit-Link   = 172.16.0.0/29       Required, or MKT01's OWN traffic cannot egress.
```

🔴 **`Lab-Network` MUST be `/8`. A `/24` covers only the flat recovery network and SILENTLY excludes every VLAN from the outbound policy.** **That produced a real, lab-wide internet outage during the original build.**

**And a richer set existed once, and is worth recovering when the time comes** (`ADR-0005`): `LAN-DNS-to-Pihole`, `Mgmt-SSH-to-Pi`, `Mgmt-SSH-to-MikroTik`, `WiFi-to-WAN-Internet`, `Deny-All-Log`.

> 🔴 **DO NOT BUILD THIS DURING A REBUILD. IT IS A CHANGE RECORD, AND `ADR-0005` GATES IT.**

## 8. Restrict Administration

```text
config system admin
    edit admin
        set trusthost1 10.0.0.0 255.255.255.0
        set trusthost2 10.10.0.0 255.255.255.0
        set trusthost3 192.168.1.0 255.255.255.0
    next
end
```

> Keep console access available before applying trusted hosts. Console bypasses all network-based restrictions and is the recovery path if you get locked out.

## 9. Configure DNS — 🔴 **DNS-over-TLS. The old guide built PLAIN DNS.**

```text
config system dns
    set primary 1.1.1.1
    set secondary 8.8.8.8
    set protocol dot
    set server-hostname "globalsdns.fortinet.net"
end
```

**Verify:**
```text
get system dns
```
🔴 **EXPECT `protocol: dot`.** **Device-verified 2026-07-14.**

> 🔴 **The live device has used DNS-over-TLS since before this guide existed** (`021`). **The old guide built plain DNS — so a rebuild SILENTLY DOWNGRADED the resolver's privacy, with no error.**
>
> 🟡 **Note: DoT here validates against `Fortinet_Factory`, not the Lab CA.** Recorded so it is not a surprise.

## 9b. Configure NTP — 🟡 **The clock SYNCS; the config is untidy (corrected 2026-07-16).**

```text
config system ntp
    set type custom
    set ntpsync enable
    unset interface
    set server-mode disable
    config ntpserver
        edit 1
            set server "pool.ntp.org"
        next
    end
end
```

**🔴 PROVE IT. A config line is not a synced clock:**

```text
get system ntp
diagnose sys ntp status
execute time
```

> 🟢 **CORRECTION — device-verified 2026-07-16. THE CLOCK SYNCS.** `show full-configuration system ntp` shows `set server "pool.ntp.org"` (per-server `interface-select-method auto`); `diagnose sys ntp status` → `synchronized: yes`, `pool.ntp.org` stratum 2. The 2026-07-14 `get system ntp` snapshot below omitted the server line and *looked* broken, but the clock egresses via wan1 and works. Build the clean config above, then PROVE it. Snapshot kept for context:
>
> ```
> FGT01 # get system ntp
> ntpserver:
>     == [ 1 ]
>     id: 1                    <-- 🔴 NO SERVER ADDRESS AT ALL
> server-mode : enable         <-- 🔴 OFFERING TO SERVE TIME IT CANNOT GET
> interface   : "fortilink"    <-- 🔴 THIS INTERFACE IS status: down (CM-0004 disabled it)
> ```
>
> 🟡 **The global `set interface "fortilink"` is a stale binding** (fortilink is down) — `unset interface` to tidy it; the per-server `auto` already egresses via wan1. **The server IS set (`pool.ntp.org`)** — the `get` snapshot just did not print it.
>
> 🟡 **`CM-0030` is narrower than first thought: only SW01 is unsynchronised** (`stratum 16`, ref time 1899 — pointed at Pi01, which serves no NTP). FGT01, MKT01 and Pi01 all sync. There is still no dedicated NTP *server* others can point at.
>
> 🟡 **Of the CIS NTP ticks, only `045` (SW01) is genuinely false.** `047` (FGT01) is now correct — the clock syncs; `046` (Pi01) named the wrong daemon but sync works, and was corrected. **`016` lesson 4 still holds: a tick from a config line is not a test — PROVE it with `diagnose`.**

## 9c. 🔴 Disable the unused factory interfaces — `CM-0004`

> 🔴 **THIS STEP DID NOT EXIST UNTIL 2026-07-14.** **`CM-0004` disabled these on the device on 2026-07-12 — and it PREDATES Charter Rule 15, so it has NO Build Guide reconciliation row.** **A rebuild from the old guide brought all four straight back.**

```text
config system interface
    edit "internal"
        set status down
    next
    edit "wan2"
        set status down
    next
    edit "fortilink"
        set status down
    next
    edit "modem"
        set status down
    next
end
```

**🔴 VERIFY — and FortiOS `grep` is NOT Linux `grep`:**

```text
show full-configuration system interface | grep -f "set status down"
```

> 🔴 **`grep -f` prints the CONTAINING CONFIG BLOCK and marks the match. USE IT.**
>
> **Three commands were tried before one answered the question** (`CM-0004`):
> - `get system interface physical` — 🔴 **WRONG QUESTION.** Reports *link and IP* state, not *administrative* status. **A disabled interface and an interface with no address look IDENTICAL.**
> - `grep -A5` — 🔴 **TRUNCATES.** `set status` sits *below* `set distance` in the block.
> - `grep -E` — 🔴 **FortiOS grep has NO `-E`, and no alternation.**
>
> 🔴 **Each ran cleanly. Each printed plausible output. NONE answered the question.** **`016` lesson 1's twin: a command completing without an error, ON THE WRONG QUESTION, is not evidence either.**

**Why each one:**

| Interface | Why it must be down |
|---|---|
| **`internal`** | 🔴 The factory hard-switch group. **Holds `192.168.1.99` — the factory bootstrap address — and was found ENABLED and ADMIN-REACHABLE.** |
| **`wan2`** | Enabled, admin-reachable, undocumented. Nothing connected. |
| **`fortilink`** | FortiSwitch fabric management. **No FortiSwitch exists in this lab.** |
| 🔴 **`modem`** | 🔴 **Carries an ENCRYPTED PPPoE CREDENTIAL** (`set mode pppoe`, `set password ENC ...`). **It is in the running config, and therefore in EVERY config backup you take.** **It appeared in NO Atlas document until `CM-0004` found it.** |

### 🔴🔴 DO **NOT** DISABLE `internal3`–`internal7`. THEY ARE FGT01's ONLY RECOVERY PATH.

```
FGT01 # get system interface        (device-verified 2026-07-14)
== [ internal3 ]  status: up
== [ internal4 ]  status: up
== [ internal5 ]  status: up
== [ internal6 ]  status: up
== [ internal7 ]  status: up
```

> 🔴 **The `internal` GROUP is down. Its five MEMBER PORTS are UP — DELIBERATELY.**
>
> 🔴 **They carry `192.168.1.99/24`. That is FGT01's ONLY IP-based break-glass path** (`003`, `048` Phase 1): *"`https://192.168.1.99` on the `internal` hard-switch ports (internal3–7). Laptop static `192.168.1.10/24`."*
>
> 🔴 **`set trusthost3 192.168.1.0/24` in Step 8 EXISTS FOR EXACTLY THIS.** **The pieces were all there. Nothing joined them up.**
>
> 🔴 **A HARDENING PASS THAT SHUTS THESE PORTS DESTROYS FGT01's RECOVERY PATH.** **`010`'s Unused Interface Policy requires the reason to be WRITTEN DOWN — and it never was, in `021` or in this guide. That is why five live ports on the perimeter firewall went unassessed.** (`CM-0033`)

### 🟡 `dmz` — decide, then act

**Device: `dmz  mode: static  ip: 10.10.10.1/24  status: up`** — factory default, no purpose, in no policy.

🔴 **VLAN 80 IS the DMZ**, routed by MKT01 at `10.80.0.1`. **This interface is a factory relic with a confusable address.** **`010`'s policy says disable it.** *(Open decision — `CM-0033`.)*

## 10. Connect internal2 and Update SW01 DAI

Connect FGT01 internal2 to SW01 Gi1/0/6. Confirm the physical link is up, then get the live MAC:

```text
diagnose hardware deviceinfo nic internal2
```

The MAC is shown as `Current_HWaddr`. Convert to IOS dot format (e.g. `00:00:5e:00:53:03` → `0000.5e00.5315`) and add to SW01:

```text
configure terminal
arp access-list STATIC-HOSTS
 permit ip host 10.10.0.254 mac host 0000.5e00.5315
exit
exit
write memory
```

> `get system interface` does not show MAC addresses in FortiOS 7.4.5. Always use `diagnose hardware deviceinfo nic <interface>`. Do not reuse internal1's MAC — the two interfaces have different MAC addresses.

## 10b. 🔴 Install the Lab CA certificate — `MC-0001`

> 🔴 **THIS STEP DID NOT EXIST UNTIL 2026-07-14.** **`MC-0001` installed the certificate on 2026-07-13 and its Build Guide row was never written.** **A rebuild from the old guide left FGT01 on a FACTORY SELF-SIGNED certificate.**

**Follow `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` — Parts A, B.0 and B.**

**The four traps, all of which `MC-0001` hit:**

1. 🔴 **`System > Certificates` is HIDDEN BY DEFAULT.** `System > Feature Visibility` → enable **Certificates**. **It is a visibility toggle, NOT a licence.**
2. 🔴 **Import the BUNDLE (leaf + chain), not the bare leaf.** **A "CA Certificate" object changes what FortiGate TRUSTS, not what it PRESENTS.**
3. 🔴 **VERIFY THE BINDING:**
   ```text
   get system global | grep admin-server-cert
   ```
   🔴 **`get`, NOT `show`.** **`show` prints only non-default values — an unbound certificate looks like "nothing to see."** **`set admin-server-cert` RAN, RETURNED NO ERROR, AND NEVER TOOK EFFECT — the device served the factory certificate for hours.** **This is the ORIGIN of Charter Rule 13's corollary.**
   **Device-verified 2026-07-14: `admin-server-cert : fortigate-bundle`.** 🟢
4. 🔴 **Verify the CHAIN on the wire:**
   ```bash
   openssl s_client -connect 10.10.0.254:443 -showcerts </dev/null 2>/dev/null | grep -c "BEGIN CERTIFICATE"
   ```
   🔴 **MUST return `3`.** `1` = you installed the bare leaf.

## 10c. 🔴 UTM — say plainly that there is none

```text
diagnose autoupdate versions
```

**Device-verified 2026-07-14:**
```
Virus-DB:  1.00000 (2018-04-09)     🔴 8 years stale
IPS-DB:    6.00741 (2015-12-01)     🔴 11 years stale
APP-DB:    6.00741 (2015-12-01)     🔴 11 years stale
```

> 🟢 **NO UTM PROFILES ARE APPLIED TO POLICY 1. Nothing pretends to protect anything.** **That is the GOOD branch of Roadmap Critical Risk #2:** *"Either the UTM profiles aren't applied, or **they are applied and providing nothing while appearing to. The second is worse.**"*
>
> 🔴 **Do not attach UTM profiles to a policy on this device without a licence.** **An unlicensed profile with 11-year-old signatures provides nothing and invites you to believe you are covered.** **Licence it, or formally accept it out of scope with an ADR — `047`'s *"possibly not applied"* is not an answer.**

## 11. Save Configuration

```text
execute backup config flash
```

## Validation

> 🔴 **`get`, NOT `show`. EVERY TIME.**
>
> **`show` displays only NON-DEFAULT values. An unset or default value looks like *"nothing to see."*** 🔴 **EMPTY OUTPUT IS NOT PROOF.**
>
> 🔴 **The old Validation block used `show` throughout — while `016`, `037` and this guide's own Common Mistakes all say not to.** **`show system global | grep admin-server-cert` returned EMPTY while the device was serving the FACTORY certificate** (`MC-0001` step 18). **`get` found it in one command.**

```text
get system status
get system interface
get router info routing-table all
get firewall policy
get firewall address
get system global | grep admin-server-cert
get system dns
get system ntp
diagnose sys ntp status
diagnose autoupdate versions
show full-configuration system interface | grep -f "set status down"
execute ping 172.16.0.2
execute ping 1.1.1.1
```

Expected — **every line device-verified 2026-07-14:**

- `wan1` has a DHCP address · `internal1` = `172.16.0.1/29` · `internal2` = `10.10.0.254/24`
- Routing table shows `10.0.0.0/8` via `172.16.0.2` on `internal1`
- **Policy 1 `LAB-to-Internet`, `srcaddr all`, NAT enabled** — *deliberate, `ADR-0005`*
- 🔴 **`get firewall address` returns FACTORY OBJECTS ONLY.** **NO `Lab-Network`. NO `Transit-Link`.** *(If they exist, someone executed `ADR-0005`'s deferred decision.)*
- 🔴 **`admin-server-cert : fortigate-bundle`** — **NOT** `Fortinet_GUI_Server`
- 🔴 **`get system dns` → `protocol: dot`**
- 🔴 **`internal`, `wan2`, `fortilink`, `modem` — all `set status down`**
- 🔴 **`internal3`–`internal7` — `status: up`. DELIBERATE. The recovery path. DO NOT DISABLE.**
- 🟢 **`diagnose sys ntp status` shows a REAL sync** — device-verified 2026-07-16: `synchronized: yes`, `pool.ntp.org` stratum 2. *(Only SW01 is actually unsynchronised — `CM-0030`.)*
- `execute ping 172.16.0.2` and `execute ping 1.1.1.1` both succeed

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Hardware switch not split before interface config | `command parse error before 'ip'` | Run Step 3 before Step 4 || Return route missing or /24 only | Lab devices unreachable from FortiGate side | Add /8 static route via 172.16.0.2 || NAT disabled on outbound policy | Traffic leaves FortiGate but home router has no return path | Enable `set nat enable` |
| Wrong internal2 MAC in SW01 STATIC-HOSTS | internal2 unreachable despite correct config and cable | Get MAC via `diagnose hardware deviceinfo nic internal2` |
| Numeric timezone code | `entry not found in datasource` | Use `set timezone "America/Chicago"` |
| Trusted hosts applied before confirming console access | Locked out | Console always bypasses trusted hosts — use it to recover |
| 🔴 **Building `Lab-Network` / `Transit-Link`** | 🔴 **You just executed a decision `ADR-0005` DEFERRED — and the `/24`-vs-`/8` outage is waiting** | **Step 6. Build `srcaddr all`. The device has no custom address objects.** |
| 🔴 **Leaving the four factory interfaces enabled** | 🔴 **`internal` comes back at `192.168.1.99`, ADMIN-REACHABLE. `modem` returns with its encrypted PPPoE credential.** | **Step 9c. `CM-0004` predates Rule 15 and never reached this guide.** |
| 🔴🔴 **Disabling `internal3`–`internal7`** | 🔴🔴 **YOU JUST DESTROYED FGT01's ONLY IP-BASED RECOVERY PATH.** | **Step 9c. They are up DELIBERATELY. `003`, `048`, and `trusthost3` all depend on them.** |
| 🔴 **`grep -E` or `grep -A5` on FortiOS** | 🔴 **Clean output. Wrong answer.** FortiOS grep has **no `-E`**; `-A5` truncates below `set distance`. | **`grep -f "set status down"` — it prints the containing block.** |
| 🔴 **`get system interface physical` to check if an interface is disabled** | 🔴 **WRONG QUESTION.** It reports *link* state. **A disabled interface and an interface with no address look IDENTICAL.** | **`show full-configuration ... \| grep -f "set status down"`** |
| 🔴 **`show` instead of `get`** | 🔴 **Empty output. It looks like "nothing to see."** **The device served the factory certificate for hours behind this.** | **`get`. Always.** |
| 🔴 **Installing the bare leaf certificate** | 🔴 **`ERR_CERT_AUTHORITY_INVALID` with a perfectly valid certificate.** | **Step 10b / `035` B.0. `s_client \| grep -c` must return `3`.** |
| 🔴 **Trusting `set admin-server-cert` because it returned no error** | 🔴 **The device serves the FACTORY certificate. Nothing warns you.** | **`get system global \| grep admin-server-cert`. This is Charter Rule 13's corollary.** |
| 🔴 **Attaching UTM profiles without a licence** | 🔴 **Signatures are 8–11 years old. It provides NOTHING and invites you to believe you are covered.** | **Step 10c. Licence it, or accept it out of scope with an ADR.** |
| 🔴 **Building plain DNS** | 🔴 **Silently downgrades the resolver's privacy. No error.** | **Step 9. `set protocol dot`.** |

## Rollback

Restore the pre-change configuration from console. Confirm management access, routes, and policy. Run the Network Validation Guide.

## Completion Checklist

- [ ] Firmware and VDOM mode verified
- [ ] Hostname FGT01, timezone America/Chicago
- [ ] internal1 and internal2 removed from hardware switch
- [ ] wan1 DHCP, no management access
- [ ] internal1 172.16.0.1/29, alias TRANSIT-TO-LAB
- [ ] internal2 10.10.0.254/24, alias MANAGEMENT
- [ ] Static route 10.0.0.0/8 via 172.16.0.2 confirmed in routing table
- [ ] **No custom address objects** — `srcaddr all` per `ADR-0005` (do NOT build `Lab-Network`/`Transit-Link`)
- [ ] Factory interfaces `internal`/`wan2`/`fortilink`/`modem` disabled — `internal3-7` left UP (recovery path)
- [ ] Lab CA certificate bound — `get system global | grep admin-server-cert` = `fortigate-bundle`, chain count 3
- [ ] DNS `protocol dot`; NTP proven synced with `diagnose sys ntp status`
- [ ] LAB-to-Internet policy with NAT enabled
- [ ] Trusted hosts configured
- [ ] DNS and NTP configured
- [ ] internal2 cabled to SW01 Gi1/0/6
- [ ] internal2 MAC in SW01 STATIC-HOSTS
- [ ] Configuration backed up to flash
- [ ] All validation pings succeed
- [ ] Build Record updated

---

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Verified build guide. |
| **3.0** | 🔴 **2026-07-14 — `CM-0033`. REBUILT AGAINST THE DEVICE (`get`, not `show`).** <br><br>🔴 **Evidence Status corrected from `Verified` to `Target Design`. A Build Guide describes what SHOULD be. It is NEVER `Verified`.** <br><br>🔴 **Step 6 built `Lab-Network` and `Transit-Link`. `get firewall address` proves they DO NOT EXIST — every object on the device is a FortiOS factory default.** **`021`'s "Address Objects" and "Firewall Policies (verified)" tables were copied from THIS GUIDE, not read from the device** — the exact inversion `Atlas-Workflow` v2.0 exists to prevent. 🔴 **And a rebuild SILENTLY EXECUTED the decision `ADR-0005` deliberately deferred, with the `/24`-vs-`/8` outage waiting on the other side.** **Step 7 now builds `srcaddr all` — what the device has. The scoped design is preserved as a gated FUTURE target.** <br><br>🔴 **NEW Step 9c — DISABLE THE FOUR FACTORY INTERFACES.** **`CM-0004` did this on the device on 2026-07-12 and PREDATES Charter Rule 15 — it has no Build Guide row, so a rebuild brought `internal` back at `192.168.1.99` ADMIN-REACHABLE, plus `wan2`, `fortilink`, and `modem` WITH ITS ENCRYPTED PPPoE CREDENTIAL.** Includes the FortiOS-`grep` trap: **no `-E`, `-A5` truncates, `get system interface physical` answers the WRONG QUESTION. Use `grep -f`.** <br><br>🔴🔴 **AND THE COUNTERPART: DO NOT DISABLE `internal3`–`internal7`.** **They are UP, deliberately — they carry `192.168.1.99`, FGT01's ONLY IP-based break-glass path (`003`, `048`), and `trusthost3 192.168.1.0/24` in Step 8 exists for exactly that.** **The reason was written in the runbook and NEVER in the Build Record or this guide — which is why five live ports on the perimeter firewall went unassessed.** <br><br>🔴 **NEW Step 10b — INSTALL THE LAB CA CERTIFICATE.** `MC-0001` installed it on 2026-07-13 and its Build Guide row was never written. **A rebuild left FGT01 on a factory self-signed certificate.** Includes all four `MC-0001` traps — Feature Visibility, leaf-vs-bundle, **the silently unbound `admin-server-cert`** (verify with **`get`**, never `show`), and the chain count of **3**. <br><br>🔴 **Step 9 now builds DNS-over-TLS.** The old guide built plain DNS — **a rebuild silently DOWNGRADED the resolver's privacy.** <br><br>🔴 **NEW Step 9b — NTP.** **Device: an EMPTY server entry bound to `fortilink`, which is DOWN.** `unset interface`, `server-mode disable`, **and PROVE it with `diagnose sys ntp status`.** **`CM-0030` is lab-wide: SW01 is `stratum 16, never updated`; there is NO NTP server anywhere in Atlas; three CIS checklists tick it falsely.** <br><br>🔴 **NEW Step 10c — UTM.** Signature databases are **8–11 years stale**. **No profiles are applied — the GOOD branch of Roadmap Critical Risk #2. Say it plainly, and do not attach an unlicensed profile that provides nothing while appearing to.** <br><br>🔴 **Validation rewritten to `get`.** The old block used `show` throughout — **while `016`, `037` and this guide's own Common Mistakes all say not to.** |
| **3.1** | 🟡 **2026-07-16 — device reconciliation (`058`).** **Step 9b corrected: the clock is NOT broken.** A fresh read (`show full-configuration system ntp` → `set server "pool.ntp.org"`; `diagnose sys ntp status` → `synchronized: yes`, stratum 2) disproves v3.0's "no working clock." The NTP server placeholder is now `pool.ntp.org`; the remaining work is *cleanup* (`unset` the stale `fortilink` binding), not a broken-clock fix. `CM-0030` narrowed to **SW01 only**; the "three false NTP ticks" corrected (only `045` is false). **Two R1 leftovers removed:** the Completion Checklist and Common Mistakes still told you to build `Lab-Network`/`Transit-Link` — which Step 6 forbids and `ADR-0005` defers. Checklist gains the missing cert / interface-disable / DoT / NTP-proof items. |
