---
Title: Network Validation Guide
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Network Validation Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Published to Confluence** — page: *Validation Guide*. |
| Version | **2.1** |
| Applies To | Atlas |
| Last Reconciled | 2026-07-15 |

## 🔴 The rule this whole guide rests on

> **A command completing without an error is not a confirmed change.**
>
> **Every configuration change is followed by reading the resulting state off the device.** Not the exit code. Not the absence of an error. **The value.**

**This is not a stylistic preference. It is the single most expensive lesson in the project — at least seven independent occurrences**, including a FortiGate that served the wrong certificate for hours, a MikroTik whose `use-radius=yes` did not persist, and an `ipmitool` command that *degraded* a correctly-hardened BMC. **Every one of them returned no error.** See `016-Network-Lessons-Learned.md`.

## 🔴 And before you trust a *negative* result

**A test that cannot fail proves nothing.**

`CM-0012` recorded cipher 0 as *"✅ proven by the exploit failing."* **IPMI-over-LAN was disabled the whole time** — the exploit would have failed identically with cipher 0 wide open at ADMIN, because the session dies at a closed channel before any cipher is evaluated. **The control was never established, so the negative result was uninterpretable.**

> **If you cannot make a test *succeed* on purpose, its failure means nothing.** Prove the positive case first.

Two more from the same hour: `ping 10.10.0.100` succeeding proved the **NIC** answers ICMP, nothing more. `nc -u -z <host> 623` "succeeding" proved **nothing at all** — UDP is connectionless, and `nc -u -z` reports success whenever it doesn't get an ICMP port-unreachable back.

## Validation Order

1. Physical link, speed, duplex, and errors.
2. VLAN and trunk state.
3. STP, DHCP snooping, DAI, and port security.
4. IP addresses and gateways.
5. Connected, static, and default routes.
6. Firewall policy and NAT.
7. IP connectivity.
8. DNS, NTP, authentication, monitoring, and applications. 🔴 **For NTP, read the *clock state* back — `show ntp status` / `get system ntp` / `timedatectl` — never a config line** (`CM-0030`).

## Core Commands

### FGT01
```text
get system status
show system interface wan1
show system interface internal1
show system interface internal2
get router info routing-table all
show firewall policy
execute ping 1.1.1.1
execute ping 172.16.0.2
get system ntp
diagnose sys ntp status
```

> 🔴 **Use `get`, not `show`, when you need to confirm a value actually holds.** `show` displays only **non-default** values — an unset or default value looks like *"nothing to see."* **Empty output is not proof.**
>
> **FortiOS `grep` is not Linux `grep`** — no `-E`, no alternation. It **does** have `-f`, which prints the containing config block.

**Certificate chain — must return `3`:**
```text
openssl s_client -connect 10.10.0.254:443 </dev/null | grep -c "BEGIN CERTIFICATE"
```
Importing an intermediate as a *CA Certificate* does **not** attach it to the served chain (`MC-0001`).

### MKT01
```text
/interface bridge port print detail where interface=ether3
/interface vlan print detail
/interface list member print
/ip address print detail
/ip route print detail
/ip firewall filter print detail
/ip firewall nat print detail
/ip service print
/user aaa print
/system ntp client print
/tool ping 172.16.0.1 count=5
/tool ping 1.1.1.1 count=5
```

> 🔴 **`hw=no` on `ether3` is a functional requirement, not a tuning choice.** Verify it after every reboot and firmware update.
>
> 🔴 **RouterOS prints only the flags in use.** **No `X` in the legend means nothing on the device is disabled** — not that you failed to look.
>
> 🔴 **`/user aaa` has its own `use-radius` setting.** A configured RADIUS server does **not** mean RADIUS is consulted — and it **may not persist on the first `set`.** Read it back.

### SW01
```text
show vlan brief
show interfaces status
show interfaces trunk
show spanning-tree
show ip dhcp snooping
show ip arp inspection
show arp access-list STATIC-HOSTS
show monitor session 1
show ntp status
show ntp associations
```

> 🔴 **`DHCP Permits: 0` — there is no DAI snooping fallback.** A host missing from `STATIC-HOSTS` is **dropped, full stop** — no error, no warning. **It simply appears to be a broken device.** **All five entries are required.** The omission of Pi01 produced a false *"Pi01 should be unreachable"* mystery that survived three handoffs.

> 🔴 **The clock is a standing check now.** `show ntp status` must read `Clock is synchronized`. SW01 has read `stratum 16, never updated` for its entire life because `ntp server 10.10.0.5` points at a host that serves no NTP — **a config line is not a synced clock** (`CM-0030`; time-source decision `ADR-0020`). In `show ntp associations`, a `*` marks the chosen peer; **no `*` = no sync** (today: `~10.10.0.5 .INIT. reach 0`).

### PVE01
```text
ip -br address
ip route
cat /etc/network/interfaces
bridge vlan show
ethtool eno1
timedatectl
ping -c 4 10.10.0.1
ping -c 4 1.1.1.1
```

> 🔴 **`sudo` is not installed on PVE01.** Root-only login. **Every guide that prefixes these with `sudo` fails as written.**
>
> 🔴 **`bridge-vlan-aware yes` is required.** Without it, per-VM VLAN tags in the GUI **have no effect — and nothing warns you.**

### Pi01 — RADIUS

```text
sudo systemctl is-active freeradius
sudo ss -tulnp | grep 1812
radtest radtest-verify <password> 127.0.0.1 0 <localhost-secret from clients.conf>
```

> 🔴 **`Access-Accept` is the only pass — and it is the whole point.** `radtest-verify` is the permanent, privilege-less validation account (`CM-0013`); its password lives in Vaultwarden and it is never a device credential. **"FreeRADIUS is active" is not "authentication works":** a wrong shared secret or an unparseable `users` file returns `Access-Reject` while the service looks perfectly healthy — that gap left every RADIUS change unvalidated for a day. **Never restore `testing`/`password` "just to check RADIUS is up."**

## Acceptance

All expected links are up, **PVE01 negotiates 1 Gbps / full duplex**, trunks carry the intended VLANs, routes are active, management is reachable, **VLAN 70 remains isolated**, and internet access works through FGT01 NAT.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Validation order and per-device command set. |
| **2.0** | 🔴 **2026-07-14.** v1.0 listed the right commands and **never said what to do with the output** — which is the entire failure mode this pack exists to prevent. Added: **the read-back rule**; **the negative-result rule** (a test that cannot fail proves nothing — `CM-0012`); `get` vs `show` and the FortiOS `grep` limitation; the certificate-chain check; `DHCP Permits: 0`; `/user aaa use-radius`; RouterOS flag legend; PVE01 `sudo` and `bridge-vlan-aware`. Every addition is a defect that actually occurred. |
| **2.1** | 🟢 **2026-07-15 — `CM-0013` reconciliation.** Added a **Pi01 — RADIUS** check: `radtest` against the standing `radtest-verify` account, `Access-Accept` as the only pass. RADIUS authentication had no standing validation entry here at all, so "the service is running" was the closest thing to a check — the exact gap `CM-0013` exists to close. |
| **2.2** | 🟢 **2026-07-16 — `CM-0030` reconciliation.** Added the **clock/NTP read-back** the guide lacked entirely: `show ntp status` + `show ntp associations` (SW01), `get system ntp` + `diagnose sys ntp status` (FGT01), `/system ntp client print` (MKT01), `timedatectl` (PVE01), plus the read-back rule on Validation-Order item 8. The rule: **read the clock state off the device — a `Clock is synchronized` line, not `ntp server <ip>` in `show run`.** SW01 read `stratum 16, never updated` for its whole life against exactly such a config line (`CM-0030`); the time-source decision is `ADR-0020`. |
