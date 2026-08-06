---
Title: Teardown and Rebuild Runbook
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Teardown and Rebuild Runbook

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Target Design |
| Evidence Source | Derived from the Build Guides, `003-Physical-Topology.md`, and `Build-Order-and-Dependencies.md` |
| Version | 1.0 |
| Applies To | A full teardown and rebuild of the physical network from Atlas documentation alone |

## Purpose

**This is the test.** The Charter's mission says Atlas must be *"sufficient for an engineer to rebuild, operate, troubleshoot, and recover the environment without relying on chat history or memory."*

Tearing the lab down and rebuilding it from the documentation is the only way to find out whether that is true. Everything else is an opinion.

**Expect to fail somewhere.** That is the point. Every gap you hit is a gap a new hire would have hit, and each one is a document that needs fixing.

---

## 🔴 STOP — Read This Before You Touch Anything

### Your credentials live on the machine you are about to wipe

**Vaultwarden runs on Pi01.** Every device password in this lab is stored in Vaultwarden.

**Wipe Pi01 and you have deleted your own credentials.** You will then be standing in front of a factory-reset FortiGate with no idea what the admin password was, and no way to look it up.

**The same host also holds:**
- The **Root CA** and **Intermediate CA** private keys — every certificate in the lab depends on them
- All four **FreeRADIUS shared secrets**
- **Pi-hole's** entire local DNS records
- The **`nginx`** config, the **UFW** ruleset

**One Raspberry Pi. All of it.**

### And a factory-reset device has no IP

You will have **no network**. Not "a degraded network" — **none**. No DHCP, no DNS, no management VLAN, and no way to reach anything by hostname.

Every step below assumes that.

---

## Phase 0 — Extraction (do this days before, not on the day)

### 0.1 — Get the credentials off Pi01

```bash
# Vaultwarden: use the web UI export, not a file copy.
# https://vault.lab:8443 -> Tools -> Export Vault -> .json
```

**Store on offline media. Two copies. One off-site.**

> **Also print the device admin passwords on paper.** You will be sitting at a serial console with no computer that can open a JSON file. This is not paranoia — it is the actual failure mode.

### 0.2 — Back up the Lab CA *as a directory*

```bash
sudo tar -czvf lab-ca-$(date +%F).tar.gz /etc/ssl/lab-ca
```

> **Decision point, and it matters:**
>
> **Restore the CA** → every existing device certificate stays valid, every workstation trust store stays valid. Fast.
>
> **Rebuild the CA** → a brand-new Root. **Every certificate must be reissued, and every workstation trust store must be re-imported.** Slow, painful, and *exactly* what you would do after a real compromise.
>
> **For a first rebuild: restore.** Prove the network works. **Rebuild the CA as a separate, later exercise** so you find out what that actually costs before you find out in an incident.

### 0.3 — Back up everything else on Pi01

```bash
sudo tar -czvf pi01-full-$(date +%F).tar.gz \
  /etc/ssl/lab-ca /etc/pihole /etc/freeradius /etc/nginx /etc/ufw \
  ~/vaultwarden/data /etc/systemd/system/dnscrypt-proxy-doh.service
```

### 0.4 — Export every device config

| Device | Command |
|---|---|
| **FGT01** | `execute backup config tftp FGT01-preteardown-YYYY-MM-DD.conf <ip>` — or GUI download |
| **MKT01** | `/export hide-sensitive file=mkt01-preteardown` **and** `/system backup save name=mkt01-preteardown` |
| **SW01** | `show running-config` → capture the terminal session. **There is no scp target when the network is gone.** |
| **PVE01** | `/etc/network/interfaces`, `qm config 100/101/9000`, `pvesm status` |

**Pull all of them onto the workstation, then onto offline media.**

### 0.5 — Print the port map on paper

`003-Physical-Topology.md`. **On paper.** You will be crawling behind a rack with no working network and no ability to open a Confluence page.

### 0.6 — Pre-teardown checklist

- [ ] Vaultwarden exported to offline media, **verified openable**
- [ ] Device admin passwords **written on paper**
- [ ] Lab CA directory backed up, **restore path decided (restore vs rebuild)**
- [ ] Pi01 full config backup taken
- [ ] All four device configs exported and pulled off-device
- [ ] **Port map printed**
- [ ] Console cable located and **tested** *(9600 8N1 — test it now, not at 2am)*
- [ ] Windows workstation has WinBox, PuTTY, and a **static-IP profile ready**
- [ ] You have physically located: the FortiGate reset button, the Cisco console port, the Pi's monitor/keyboard

---

## Phase 1 — Bootstrap Access

**You have no network. Here is how you talk to each device anyway.**

| Device | How to reach it with nothing | Notes |
|---|---|---|
| **SW01** | **Serial console.** 9600 baud, 8N1, no flow control. | **Not 115200.** The 2960X is 9600. This has bitten before. |
| **MKT01** | 🟢 **WinBox → Neighbors → connect by MAC.** **Cable directly into `ether4`** (or any `bridgeLocal` port). **Select ONE row. Click the MAC, not the IP.** | ✅ **TESTED 2026-07-14.** 🔴 **It had NEVER worked before `CM-0018`** — `026` §12 disabled it while this runbook called it *"your single most important bootstrap tool."* 🔴 **KNOWN LIMIT: connects, then DROPS after ~15 seconds.** **Get in, set an IP, switch to a real session.** Know your commands before you connect. 🔴 **There is NO serial console on this device** (`ADR-0016`). **Run WinBox as Administrator.** |
| **FGT01** | `https://192.168.1.99` on the `internal` hard-switch ports (**internal3–7**). Laptop static `192.168.1.10/24`. | Factory default. If already reset, admin password is blank then forced. Console is the fallback. |
| **PVE01** | **Physical keyboard + monitor FIRST.** iDRAC (`10.10.0.100`) only once SW01 and `Gi1/0/4` are back up. | 🔴 **iDRAC is NOT independent.** It is on the shared LOM — same NIC/cable/port as `eno1` (`Gi1/0/4`). It dies with SW01, which you are about to wipe. **During a teardown it is not available.** Corrected 2026-07-13 (was wrongly listed as independent OOB). See `CM-0011`/`CM-0012`. |
| **Pi01** | Physical keyboard + monitor (HDMI). | SSH is key-only on port 2222 and will not exist yet. |

> 🔴 **CORRECTED 2026-07-14.** This previously read: *"The MikroTik MAC-connect is the keystone. Learn it before you need it."* **It was false when written and false ever since** — `mac-winbox` was `none`, and `026` §12 is what set it that way, **while step 3 of that same guide told you to rely on it.**
>
> 🔴 **A router built from the OLD `026` could not be bootstrapped by this runbook. Nobody found it because nobody has ever rebuilt** (`ADR-0011`). **The first person to discover it would have discovered it mid-teardown, with no way in.**
>
> ✅ **`026` §12 is now fixed and `CM-0018` built the path on the live device.**
>
> 🔴 **It drops after ~15 seconds. Have your commands ready before you click Connect.**

---

## Phase 2 — Physical Layer

Cable per the **corrected** port map. Verify link lights **before** configuring anything.

```
Home Router  --------> FGT01 wan1
FGT01 internal1 -----> MKT01 ether1        (transit 172.16.0.0/29)
MKT01 ether3 --------> SW01 Gi1/0/1        (trunk, native VLAN 999)
SW01 Gi1/0/4 --------> PVE01 eno1          (trunk, native VLAN 10)
SW01 Gi1/0/6 --------> FGT01 internal2     (mgmt, VLAN 10 access)
SW01 Gi1/0/7 --------> Pi01                (VLAN 10 access)
SW01 Gi1/0/2 --------> LabComputer         (VLAN 10 access)
SW01 Gi1/0/5 --------> (SPAN destination — analyzer, usually unplugged)
(no separate cable) ->  iDRAC                 (10.10.0.100 — SHARED LOM on eno1 / Gi1/0/4, NOT a dedicated port)
Admin workstation ---> MKT01 ether4-13     (bridgeLocal — YOUR RECOVERY PATH)
```

> **Plug your workstation into MKT01 `ether4`–`ether13` (`bridgeLocal`, `10.0.0.0/24`).** That is the recovery network. It exists precisely for this. Set a static `10.0.0.20/24`, gateway `10.0.0.1`.
>
> **Do not rely on the VLAN 10 management network during a rebuild.** It doesn't exist yet — that's what you're building.

---

## Phase 3 — Rebuild Order

**Strict. Each layer must be validated before the next is built.**

### 3.1 — SW01 (Layer 2) — *console only, no IP needed yet*

**SW01 is the centre of the star. Everything hangs off it. It goes first.**

Per `027-SW01-Build-Guide.md`:

1. Verify firmware, set hostname/domain, **enable secret (a real value, from the paper)**
2. SSH, local user, VTY ACL
3. **All nine VLANs** — `show vlan brief` (*not* `show vlan`)
4. Management SVI `10.10.0.2/24`, default gateway `10.10.0.1`
5. Spanning tree — rapid-pvst, priority 4096, **confirm "this bridge is the root"**
6. Trunks: **Gi1/0/1 native 999** (MKT01), **Gi1/0/4 native 10** (PVE01) ← *these differ on purpose*
7. Access ports, DHCP snooping, ARP inspection, `STATIC-HOSTS`
8. Shut unused ports

**Validate:** `show interfaces trunk`, `show spanning-tree`, `show vlan brief`

> ⚠️ **`STATIC-HOSTS` and the ARP inspection filter will lock out any static-IP host on VLAN 10 that isn't in the list.** The live ACL has **five** entries — confirmed 2026-07-13 via `show arp access-list STATIC-HOSTS`:
>
> | IP | MAC | Device |
> |---|---|---|
> | `10.10.0.5` | `0000.5e00.5300` | **Pi01** |
> | `10.10.0.10` | `0000.5e00.5313` | PVE01 `eno1` |
> | `10.10.0.50` | `0000.5e00.5316` | Admin workstation |
> | `10.10.0.100` | `0000.5e00.5314` | iDRAC (shared LOM) |
> | `10.10.0.254` | `0000.5e00.5315` | FGT01 `internal2` |
>
> **All five are required.** `DHCP Permits: 0` — there is no snooping fallback, so a host missing from this ACL is dropped, full stop. **`023-SW01-Build-Record.md` was missing Pi01**, which is what created the false "Pi01 should be unreachable" mystery across three handoffs. Build the ACL from this list, not from a stale record.

### 3.2 — MKT01 (Layer 3) — *WinBox via MAC*

Per `026-MKT01-Build-Guide.md`:

1. Password (real value), identity
2. Remove factory defaults **— you will lose IP access here. Stay on the MAC connection.**
3. **`bridge-trunk` on ether3 with `hw=no ingress-filtering=no`** ← **the single most critical line in the entire rebuild.** Get this wrong and the VLAN interfaces receive *zero* traffic while `ether3` shows link — a fault that looks like everything except what it is.
4. Transit `172.16.0.2/29` on ether1, default route to `172.16.0.1`
5. **`bridgeLocal` `10.0.0.1/24`** ← *now your workstation has a route*
6. Nine VLAN interfaces, eight gateway IPs — **no duplicates**
7. DNS (Pi-hole first — but Pi-hole doesn't exist yet, so **public resolvers temporarily**)
8. `VLANs` interface list — **before** any firewall rule that references it
9. **22 firewall rules — including both catch-all drops**
10. Harden services

**Validate:** `/interface bridge port print detail where interface=ether3` → **`hw=no`**. Ping `172.16.0.1`.

### 3.3 — FGT01 (Perimeter)

Per `025-FGT01-Build-Guide.md`:

1. Firmware, VDOM mode, hostname, timezone (**string, not a number**)
2. **Split internal1/internal2 out of the hardware switch** — purge DHCP + policy first, or it fails to parse
3. Interfaces: `wan1` DHCP, `internal1` transit, `internal2` mgmt
4. **Static route `10.0.0.0/8`** — *not /24, or every VLAN silently loses its return path*
5. Firewall policy + **NAT enabled**
6. Trusted hosts (**keep console access first**)
7. DNS/NTP

**Validate:** `execute ping 172.16.0.2`, then `execute ping 1.1.1.1`

### 3.4 — Management plane

**All four reachable from VLAN 10 before you go further:**

```
ping 10.10.0.1     # MKT01
ping 10.10.0.2     # SW01
ping 10.10.0.254   # FGT01
ping 10.10.0.10    # PVE01   (once PVE01 is up)
```

**If any fail, stop.** Do not build on a broken layer.

### 3.5 — Pi01 (Services + restore)

Per `030` (base), then **restore rather than rebuild**:

1. Base OS, static `10.10.0.5/24`, `dnsadmin`, SSH key-only on 2222
2. **UFW — build the whole ruleset while inactive, verify with `ufw show added`, then enable and test a *fresh* SSH session in a second window before closing the first.** This is how it was done successfully. Do it that way again.
3. **Restore `/etc/ssl/lab-ca`** from backup ← **the CA is now alive and every existing certificate is valid again**
4. Restore Pi-hole (`pihole.toml` — **not `custom.list`**), dnscrypt-proxy, the masked socket, the custom unit
5. Restore FreeRADIUS `clients.conf` — **and do not recreate the `testing` account**
6. Restore Vaultwarden data, nginx, port 8443

**Validate:** `dig pihole.lab @10.10.0.5`, `openssl verify` against the chain, `radtest`

### 3.6 — Certificates and RADIUS back on the devices

Because you **restored** the CA, the device certificates are still valid — but the devices were factory-reset, so they must be **re-imported and re-bound**.

- **FGT01:** import the bundle → **bind `admin-server-cert`** → *verify with `get`, not `show`*
- **MKT01:** import → **note RouterOS renamed it** → bind `www-ssl`
- **MKT01 RADIUS:** `/radius add` **and `/user aaa set use-radius=yes`** ← *the second one is not optional and did not persist first time*
- **FGT01 RADIUS:** server entry, test with a real credential

### 3.7 — PVE01

`vmbr0`, `bridge-vlan-aware yes`, `10.10.0.10/24`, native VLAN 10 on Gi1/0/4.
**Add all five `STATIC-HOSTS` entries (see Phase 3.1) — PVE01, iDRAC, Pi01, FGT01, workstation** — or ARP inspection silently drops them. iDRAC's MAC (`…a4`) is the shared LOM address, so it appears on `Gi1/0/4` alongside `eno1` (`…a2`).

---

## Phase 4 — The Real Deliverable

**Keep a running log of every single time you had to leave the documentation.**

Every time you thought *"wait, what was the…"* and reached for a chat log, a memory, or a guess — **that is a documentation defect**, and it is the entire reason for doing this.

At the end, that log becomes a batch of Change Records. **It is worth more than the rebuild.**

---

## What Will Probably Bite You

Ranked by likelihood, drawn from what has already gone wrong once:

1. **`hw=no` on MKT01 ether3.** Forget it and *nothing* works, in a way that looks like everything else.
2. **`STATIC-HOSTS` / ARP inspection.** Any static VLAN 10 host not in the list is silently dropped.
3. **FGT01's `/8` route.** A `/24` works for the flat network and silently breaks every VLAN.
4. **Native VLAN 10 on Gi1/0/4, 999 on Gi1/0/1.** They are *deliberately different*. Making them consistent breaks PVE01.
5. **Console baud 9600, not 115200.**
6. **`use-radius=yes` not persisting on the first `set`.** Re-check. Every time.
7. **The FortiGate Certificates menu is hidden** by default — Feature Visibility, not licensing.

---

## Related Pages

- `Architecture/003-Physical-Topology.md` — **print this**
- `Operations/Build-Order-and-Dependencies.md` — the dependency graph
- `Build-Guides/025`, `026`, `027`, `028`, `030`–`034`
- `Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial runbook. Written because the existing Build Order document assumes a working network and reachable devices — it does not address the bootstrap problem (how to reach a factory-reset device with no network) or the extraction problem (**every credential in the lab is stored on the one host that gets wiped**). |
