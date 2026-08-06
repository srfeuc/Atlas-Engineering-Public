---
Title: MKT01 Build Record
Path: Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router
---

# MKT01 Build Record

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Verified |
| Evidence Source | Live CLI output — `/ip firewall filter print` (**re-read 2026-07-13, post-CM-0009**), `/user aaa print`, `/radius print detail` |
| Last Verified | 2026-07-16 (`054` verification run) |
| Version | **2.9** |

## Platform

| Item | Value |
|---|---|
| Hardware | **MikroTik RouterBOARD RB1100AHx4 Dude Edition** (device `board-name`; order code `RB1100Dx4` names the same product). **Serial `9BD90AB80B08`.** 13 × Gigabit Ethernet. 🔴 **Onboard 64 GB `FORESEE` SATA SSD (`/disk`, `sata1-part1`, MOUNTED; disk serial `I31214J006375`) — device-confirmed `/disk print`, 2026-07-15.** |
| RouterOS | 7.23.1 (stable) |
| RouterBOOT firmware | 🔴 **`6.42.10` — behind RouterOS `7.23.1`** (`/system routerboard print`, 2026-07-16). Run `/system routerboard upgrade` + reboot to sync (`055` row 12). |
| Architecture | ARM, 4-core |
| RAM | 1024 MiB |
| Identity | **MKT01** — confirmed live (`[SethAdmin@MKT01]` prompt, 2026-07-13) |

> **Corrected 2026-07-13.** The Platform table previously recorded the live identity as `MikroTik` with `MKT01` as the target, while the Known Deviations table on the same page recorded the rename as *already resolved*. The device confirms **MKT01**. The Platform table was stale.

## Physical Interfaces

| Interface | Role | IP | Notes |
|---|---|---|---|
| ether1 | Transit to FGT01 | 172.16.0.2/29 | Connected to FGT01 internal1 |
| **ether2** | Unused | — | ✅ **DISABLED** (`X` flag, verified `/interface print` 2026-07-13, `CM-0015`). Comment on the device: *"Unused - disabled per 010 Unused Interface Policy, CM-0015"*. **Previously recorded as "Available" — which is not a state, it is a hope.** |
| ether3 | Trunk to SW01 | No IP | bridge-trunk member, `hw=no`, `ingress-filtering=no` |
| ether4-13 | bridgeLocal | 10.0.0.1/24 via bridge | Recovery management network |

## Bridge Configuration

| Bridge | Members | hw setting | ingress-filtering | Purpose |
|---|---|---|---|---|
| bridgeLocal | ether4-ether13 | yes (default) | default | Recovery management |
| bridge-trunk | ether3 | **no** | **no** | SW01 trunk — RTL8367 software path required |

> `hw=no` on ether3 is a **functional requirement, not a tuning choice.** The RTL8367 chip intercepts frames at hardware level before RouterOS VLAN sub-interfaces see them if `hw=yes`. **Verify after every reboot and firmware update.**

## VLAN Interfaces

| Interface | VLAN ID | IP | In VLANs List |
|---|---|---|---|
| vlan10-mgmt | 10 | 10.10.0.1/24 | Yes |
| vlan20-servers | 20 | 10.20.0.1/24 | Yes |
| vlan30-web | 30 | 10.30.0.1/24 | Yes |
| vlan40-monitoring | 40 | 10.40.0.1/24 | Yes |
| vlan50-client | 50 | 10.50.0.1/24 | Yes |
| vlan60-deployment | 60 | 10.60.0.1/24 | Yes |
| vlan70-testing | 70 | 10.70.0.1/24 | **No** — isolated by design |
| vlan80-dmz | 80 | 10.80.0.1/24 | Yes |
| vlan999-unused | 999 | None | **No** — no IP, catch-all only |

## Routing

| Network | Gateway | Interface |
|---|---|---|
| 0.0.0.0/0 | 172.16.0.1 | ether1 |
| 172.16.0.0/29 | Connected | ether1 |
| 10.0.0.0/24 | Connected | bridgeLocal |
| 10.10.0.0/24 | Connected | vlan10-mgmt |
| 10.20.0.0/24 | Connected | vlan20-servers |
| 10.30.0.0/24 | Connected | vlan30-web |
| 10.40.0.0/24 | Connected | vlan40-monitoring |
| 10.50.0.0/24 | Connected | vlan50-client |
| 10.60.0.0/24 | Connected | vlan60-deployment |
| 10.70.0.0/24 | Connected | vlan70-testing |
| 10.80.0.0/24 | Connected | vlan80-dmz |

## Firewall — 22 rules live, verified 2026-07-13 (post-`CM-0009`)

Read directly from `/ip firewall filter print`. **Indices are the device's own, re-read after `CM-0009` executed.** No figure is carried forward from any document.

| # | Chain | Action | Match | Log prefix | Comment |
|---|---|---|---|---|---|
| 0 | input | accept | `connection-state=established,related` | — | Allow return traffic to router |
| 1 | input | **drop** | `connection-state=invalid` | `DROPPED:` | Drop malformed packets input |
| 2 | input | accept | `protocol=icmp limit=50,25:packet` | — | Allow ping rate limited |
| 3 | input | **drop** | `protocol=icmp` | `DROPPED:` | Drop excess ping |
| 4 | input | accept | `in-interface=bridgeLocal` | — | Allow LAN full access to router |
| 5 | input | accept | `in-interface-list=VLANs` | — | Allow VLAN devices to reach router |
| 6 | input | **drop** | `src-address=172.31.4.0/22 in-interface=ether1` | `DROPPED:` | Block home network from router |
| 7 | forward | accept | `connection-state=established,related` | — | Allow return traffic through router |
| 8 | forward | **drop** | `connection-state=invalid` | `DROPPED:` | Drop malformed packets forward |
| 9 | forward | accept | `in=vlan10-mgmt out-list=VLANs` | — | Management full access to all VLANs |
| 10 | forward | accept | `in=vlan40-monitoring out-list=VLANs` | — | Monitoring read access to all VLANs |
| 11 | forward | accept | `in=vlan20-servers out=ether1` | — | Servers to internet |
| 12 | forward | accept | `in=vlan50-client out=vlan20-servers` | — | Clients to Servers |
| 13 | forward | accept | `in=vlan50-client out=ether1` | — | Clients to internet |
| 14 | forward | accept | `in=vlan60-deployment out=vlan20-servers` | — | Deployment to Servers |
| 15 | forward | accept | `in=vlan30-web out=vlan20-servers` | — | Web tier to Servers |
| 16 | forward | accept | `in=vlan70-testing out=ether1` | — | Testing internet only — isolated from lab |
| 17 | forward | accept | `in=bridgeLocal out-list=VLANs` | — | Admin laptop bridgeLocal to VLANs |
| 18 | forward | accept | `in=bridgeLocal out=ether1` | — | Flat network to internet |
| 19 | forward | accept | `in=vlan10-mgmt out=ether1` | — | Management to internet |
| **20** | forward | 🔴 **drop** | **catch-all** | `EAST-WEST-DENIED:` | Drop everything else |
| **21** | input | 🔴 **drop** | **catch-all** | `INPUT-DENIED:` | Drop all other traffic to router |

> 🔴 **Rules 20 and 21 are load-bearing.** RouterOS defaults to **ACCEPT** for a chain with no matching rule. **Rule 21 is the only thing stopping unmatched traffic from reaching the router itself.**
>
> **`026-MKT01-Build-Guide.md` never built the input-chain default deny.** A router rebuilt from the old guide had **no default deny on its input chain at all.** Fixed 2026-07-13.

### The two dead rules — removed, and why they were instructive

**Old rules 19 and 20 no longer exist.** Both referenced **`10.0.0.5`** — Pi01's **pre-VLAN flat-network address.** Pi01 is at **10.10.0.5**. They matched no host.

**And correcting the address would not have helped, because MKT01 is not on that path.** FGT01 `internal2` (`10.10.0.254/24`) and Pi01 (`10.10.0.5/24`) are on the **same subnet, same VLAN 10, Layer-2 adjacent via SW01**. FGT01→Pi01 RADIUS flows FGT01 → SW01 → Pi01. **It never entered MKT01's forward chain.**

**They were dead twice over, and they had never done anything at all.** Removing them changed nothing — which is exactly what the analysis predicted, and what nothing but execution could prove.

**This resolved an anomaly nobody had questioned:** FGT01's RADIUS was confirmed working end-to-end while these rules pointed at a nonexistent host. **It worked *because* MKT01 was not involved.**

### 🔴 Historical note on the count — four documents, four figures

| Source | Claimed |
|---|---|
| Three earlier documents | **22**, **23**, **24** |
| This Build Record at v2.3 | *"22 rules verified"* — **while listing only 21** |
| This Build Record at v2.4 | **24** — correct at the time |
| This Build Record at v2.4, *after `CM-0009` executed* | 🔴 **Still said 24. The device had 22.** |
| **The device, 2026-07-13** | **22** |

**v2.4 was correct when written and wrong within hours.** `CM-0009` removed the two rules, was marked `Closed`, and **its closeout box for "Build Record updated" was never ticked** — so this page kept describing a firewall that no longer existed.

**Every figure here is now read from the device. None is carried forward from any document, including this one.**

## Management Services

| Service | Status | Port | Restriction |
|---|---|---|---|
| SSH | Enabled | 2222 | 10.0.0.0/24, 10.10.0.0/24 |
| WinBox | Enabled | 8291 | 10.0.0.0/24, 10.10.0.0/24 |
| www-ssl | Enabled | 443 | 10.0.0.0/24, 10.10.0.0/24 |
| Telnet | Disabled | — | — |
| FTP | Disabled | — | — |
| www | Disabled | — | — |
| API | Disabled | — | — |
| API-SSL | Disabled | — | — |
| reverse-proxy | Disabled | 443 | Disabled via `CM-0006` |

> `reverse-proxy` was found **enabled and unrestricted** (`address=""`) during 2026-07-13 live validation — undocumented until that point.

## RADIUS and Local Accounts

| Item | Value |
|---|---|
| RADIUS server | Single entry, `address=10.10.0.5`, `authentication-port=1812`, `require-message-auth=yes-for-request-resp` |
| `/user aaa use-radius` | **`yes`** — confirmed via `/user aaa print` |
| `/user aaa accounting` | `yes` |
| Integration test | Confirmed working via WinBox login after `use-radius` was enabled |

> **The `testing`/`password` account used for that test has since been deleted** — once RADIUS became functional it was a live network-device admin credential, not a diagnostic tool. Confirmed removed via `radtest` returning `Access-Reject`. See `033-Pi01-FreeRADIUS-Build-Guide.md`.

**History worth keeping on record.** As of the start of the 2026-07-13 session, **RADIUS integration had never actually been completed on this device.** `/radius print detail` returned **zero entries**, despite Pi01's `clients.conf` carrying a correctly-addressed `mikrotik` client block for some time. **Only one side of the integration had ever been finished.**

A **duplicate RADIUS entry** was also found mid-fix — one freshly created, one pre-existing with an inline `;;; PiHole` comment, likely holding the old compromised secret. RouterOS does not warn about or merge duplicates. Resolved by setting the new secret on the pre-existing entry and removing the redundant one.

**`use-radius` did not take effect on the first `set` attempt** and returned no error. Caught only by re-checking immediately after. See `043-PKI-and-Credential-Security-Overhaul-Session-Summary.md`.

### Local Accounts

| Account | Group | Status |
|---|---|---|
| `admin` | full | Default system account, in active use |
| `SethAdmin` | full | Existed but had **never successfully logged in** (blank `LAST-LOGGED-IN`) as of 2026-07-13 — password stale/never properly set. Corrected and confirmed working same session. |

> Local accounts remain functional with RADIUS enabled. RADIUS is an *additional* auth path — MKT01 falls back to local accounts if Pi01 is unreachable.

## DNS and NTP

| Item | Value |
|---|---|
| DNS servers | **10.10.0.5 (Pi-hole, primary), 1.1.1.1, 8.8.8.8 (fallback)** — changed 2026-07-13 |
| Verification | `:put [:resolve mikrotik.lab]` returns `10.10.0.1` — **proving Pi-hole is actually being queried**, not just falling through to public DNS |
| allow-remote-requests | no |
| NTP | pool.ntp.org (interim) |

## Known Deviations

| Item | Target | Current | Action |
|---|---|---|---|
| Inter-VLAN routing | Cisco 1941 (Phase 1.5) | MikroTik | Change Record required for cutover. Not yet deployed. |
| DNS | Windows Server AD DNS | Pi-hole primary + public fallback | Update after Windows Server deployed (Book 3) |
| NTP | Windows Server AD time hierarchy | pool.ntp.org | Update after Windows Server deployed (Book 3) |

### Closed

| Item | Resolution |
|---|---|
| Identity | **Closed** — `MKT01` confirmed live. |
| www-ssl certificate | **Closed** — `CM-0007` / `CM-0008` / `MC-0002`. Object `mikrotik-bundle.crt_0`, serial `1001`, SAN `DNS:mikrotik.lab, IP:10.10.0.1` — confirmed on the file *and* on the live-served connection. |
| `mikrotik.lab` DNS record | **Closed.** Previously recorded here as *"still stale in Pi-hole `custom.list`."* **Doubly wrong:** the record was corrected on 2026-07-13, and `custom.list` is **inert** on Pi-hole v6 — local records live in `/etc/pihole/pihole.toml`. Confirmed via `dig`. |
| RADIUS integration | **Closed** — built from scratch and confirmed working. |
| Firewall rules 19/20 (dead pre-VLAN RADIUS rules) | **Closed** — `CM-0009`. Removed and **verified on the device 2026-07-13**: `/ip firewall filter print count-only` returns **`22`**. |
| `reverse-proxy` enabled and unrestricted | **Closed** — `CM-0006`. |

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Troubleshooting.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0009-Remove-Obsolete-MKT01-RADIUS-Rules.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`

## Layer-2 Management State — recorded 2026-07-14 (`CM-0017`)

🔴 **This section did not exist before `CM-0017`. `mac-server` is administrative state that was set deliberately by `026-MKT01-Build-Guide.md` §12 and that NO record has ever captured.**

> *"Available" is not a state* (`016` lesson 9). **Neither is unmentioned.**

| Setting | Verified state (2026-07-14, post-`CM-0018`) | Source |
|---|---|---|
| `/interface list` | **`RECOVERY`** — exactly one member: **`bridgeLocal`** | `/interface list member print where list=RECOVERY` |
| `/tool mac-server mac-winbox allowed-interface-list` | ✅ **`RECOVERY`** | `/tool mac-server mac-winbox print` |
| `/tool mac-server allowed-interface-list` (MAC-Telnet) | **`none`** — *a recorded decision, not a default. Operator: no Telnet.* | `/tool mac-server print` |
| `/ip neighbor discovery-settings discover-interface-list` | 🔴 **`static`** — **the disclosure leak is OPEN.** Deferred (`ADR-0016`). | `/ip neighbor discovery-settings print` |
| `ether4`–`ether13` (`bridgeLocal`) | 🔴 **ALL TEN ENABLED** — flags `S` (slave), no `X`. **Deliberate (`ADR-0016`).** | `/interface ethernet print` |
| `ether2` | **Disabled** (`X`) — `CM-0015` | `/interface ethernet print` |
| `10.0.0.1/24` (`bridgeLocal`) comment | ✅ **`ADMIN RECOVERY NETWORK - DO NOT REMOVE. MAC-WinBox scope (RECOVERY list). Plug into ether4. ...`** — `CM-0016`, 2026-07-14. **Was `;;; Legacy flat management` — the label that caused `017` v1.0 to propose retiring the recovery network.** | `/ip address print detail` |
| Board (device-reported) | **`RB1100AHx4 Dude Edition`** — *`/system resource print`. The `model = RB1100Dx4` in the export is the same product's model ID. **This record was right all along.*** | `/system resource print` |
| Storage | ✅ **64 GB `FORESEE` SATA SSD — `sata1-part1`, MOUNTED.** *(`/system resource print` shows `128 MiB` — that is the internal NAND, not the SSD.)* **Recorded in no document before 2026-07-14.** | `/disk print` |

### 🟢 MAC-connect: BUILT AND TESTED — and it had never worked before

**`CM-0018`, 2026-07-14.** MAC-WinBox scoped to `bridgeLocal`. **Tested from a direct cable into `ether4`: it CONNECTED.** `/system resource print`, `/system identity print` and `/interface list member print` all returned over the MAC session.

🔴 **KNOWN LIMIT — the session drops after roughly 15 seconds.** Reproduced with a minimal config (one list member), static addressing, a direct cable, and **read-only commands only**. **It is the transport, not the configuration.**

> **MAC-WinBox is a break-glass transport, not a management session.** **The bar is: get in, set an IP, switch to a real session.** It clears that bar. **It clears nothing else.**

🔴 **NEVER modify the `RECOVERY` interface list while riding a MAC-WinBox session bound to it. It kills the session instantly.** Learned the hard way, 2026-07-14.

### 🔴 MKT01 still has NO serial console

**Three USB-serial adapters purchased; none worked. Deferred by `ADR-0016`.**

| Device | Out-of-band path |
|---|---|
| SW01 | ✅ Serial, 9600 8N1 |
| FGT01 | ✅ Serial **+** `192.168.1.99` fallback |
| PVE01 | ✅ Physical console |
| 🔴 **MKT01** | 🔴 **MAC-WinBox only — and it drops after 15 seconds.** **No console. The only Atlas device with no path that survives a RouterOS that will not boot.** |

**Before `CM-0018` it had *nothing*.** `026` §12 set `mac-winbox=none` while `048` called MAC-connect *"your single most important bootstrap tool"* and **step 3 of `026` itself depended on it.** **A router rebuilt from the old guide could not be bootstrapped by the runbook.** Nobody found it because nobody has ever rebuilt (`ADR-0011`).

### The discovery disclosure

`discover-interface-list=static` means MKT01 advertises its **identity, RouterOS version, board model, uptime and port on every static interface — including every VLAN.** A host on VLAN 50 (Client) or VLAN 20 (Servers) can read the router's patch level for free.

**It provides no recovery benefit — MAC-WinBox refuses the connection anyway.** **The disclosure without the capability.**

**Remediation:** `ADR-0014` (posture decision) → `CM-0018` (scoped `RECOVERY` list, with a live MAC-connect test as proof).

### 🟢 Resolved — the dynamic WinBox row is a live-session artefact (2026-07-16)

`/ip service print detail` returns a **dynamic** WinBox row (`D c`) alongside the restricted static one. The `054` verification run (2026-07-16) captured it carrying **`remote=10.10.0.50`** — the admin workstation's own connected session. It is a per-connection artefact, **not** an unrestricted listener. Settled.

## Change Log

| Version | Changes |
|---|---|
| 2.3 | RADIUS, certificate, DNS reconciliation. |
| 2.4 | **Firewall table rebuilt from live output.** Previously claimed "22 rules verified" while listing 21 and omitting both the dead rules 19/20 *and* the input-chain catch-all drop; the device has 24. Two findings recorded: the input default deny was never in the Build Guide (RouterOS defaults to ACCEPT), and rules 19/20 are pre-VLAN fossils on a path MKT01 isn't in. **Identity corrected** to `MKT01` — the Platform table contradicted the Known Deviations table on the same page. **`mikrotik.lab` DNS deviation closed** — it referenced `custom.list`, which is inert on Pi-hole v6. Evidence Status block added per Charter Rule 14. |
| **2.5** | 🔴 **Firewall table rebuilt AGAIN, from live output re-read after `CM-0009` executed.** v2.4 said **24 rules** with 19/20 *"removal pending"* — **but `CM-0009` had already removed them and been marked `Closed`.** Its closeout box for *"Build Record updated"* was never ticked, so this page described a firewall that no longer existed **for a full day.** The device says **22** (`/ip firewall filter print count-only`). Table rebuilt from `/ip firewall filter print`, now including the **`log-prefix` values** (`DROPPED:`, `EAST-WEST-DENIED:`, `INPUT-DENIED:`) that no previous version captured. Deviation moved to **Closed**. |
| **2.6** | `ether2` state corrected. Previously *"Unused — Available."* **"Available" is not an administrative state.** The device said **enabled**; it is now **disabled** with an on-device comment (`CM-0015`). Recorded from `/interface print`, not from the previous record. |
| **2.7** | 🟢 **2026-07-14** — `CM-0017` / `CM-0018` / `ADR-0016`. Added the **Layer-2 Management State** section — `mac-server`, `mac-winbox` and neighbour discovery had **never been recorded**, despite being set by `026` §12. **MAC-connect was found NON-FUNCTIONAL (it had never worked), then BUILT and TESTED — it now connects from `ether4` and drops after ~15s.** Recorded the **64 GB `FORESEE` SATA SSD** (`/disk print` — MOUNTED), which appeared in **no document** before today. **Board name confirmed `RB1100AHx4 Dude Edition` — this record was right, and an earlier "correction" to `RB1100Dx4` was unnecessary; both strings name the same product.** Open and deferred (`ADR-0016`): serial console, discovery scoping, `ether5`–`ether13` port states. |
| **2.8** | 🟢 **2026-07-15 — full device reconciliation** (`026`/`022`/`041`). Read the entire config surface off the live device and reconciled it: firewall 22 (unchanged), all services hardened, **cert `mikrotik-bundle.crt_0` SAN = `IP:10.10.0.1`** (correct, not the stale `10.0.0.1`), single RADIUS entry (Pi01), `use-radius: yes`, NTP synced to `pool.ntp.org` (client-only, serves no time), DNS `10.10.0.5/1.1.1.1/8.8.8.8`. **Two changes executed and read back:** default `admin` user **disabled** (`CM-0034`); **`ether5`–`ether13` disabled**, `ether4` kept as sole recovery port, and the `bridgeLocal` interface comment relabelled off "Legacy" (`CM-0035` — which also corrected `ADR-0014`/`CM-0018`'s premature "disabled, executed" claim). Platform lead corrected to the device `board-name` **`RB1100AHx4 Dude Edition`**. |
| **2.9** | 🟢 **2026-07-16 — `054` live verification run.** Re-confirmed the full config surface against v2.8: firewall **22**, `ether3` `hw=no`, hardened services, cert SAN `IP:10.10.0.1`, `use-radius: yes`, `admin` disabled, DNS `10.10.0.5/1.1.1.1/8.8.8.8`, NTP synced (stratum 1), **no NAT** (`/ip firewall nat print` empty), SNMP **off**. **Resolved** the "unexplained dynamic WinBox row" — it is the operator's own session (`remote=10.10.0.50`). **New finding:** RouterBOOT firmware `6.42.10` is behind RouterOS `7.23.1` — `/system routerboard upgrade` pending (`055` row 12). `054`/`055` promoted to device-verified. |
