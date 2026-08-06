---
Title: SW01 Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch
---

# SW01 Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | 2.0 |
| Applies To | Atlas 2.0 |
| Hardware | Cisco WS-C2960X-48FPS-L |
| IOS | **15.2(2)E6** — 🔴 **device-verified 2026-07-14** (`show version`). *(This guide said `15.2(7)E`. Wrong. `CM-0022`.)* |
| Last Reconciled | 2026-07 |

## Target

Deploy SW01 as the Atlas Layer 2 switch: nine enterprise VLANs, trunk to MKT01, trunk to PVE01 (native VLAN 10), access ports for connected devices, DHCP snooping, ARP inspection, port security, storm control, spanning tree root, SPAN.

SW01 does not perform routing, NAT, DHCP, or DNS.

## Before You Begin

| Item | Value |
|---|---|
| Hostname | **SW01** — 🔴 **device-verified 2026-07-14: `hostname SW01`.** *(Seven documents claim the live hostname is `CoreSwitch` and that a rename is "still open." **It already happened.** `CM-0022`.)* |
| Domain | lab.local |
| Management IP | 10.10.0.2/24 on VLAN 10 SVI |
| Default gateway | 10.10.0.1 (MKT01 vlan10-mgmt) |
| Native VLAN (trunks) | 999 — except Gi1/0/4 which uses native VLAN 10 |
| Console | 9600 baud, 8N1, no flow control |
| SFP ports | Gi1/0/49-52 (not Gi1/1/1-4) |
| SSH | Requires legacy algorithm flags — see Step 3 |

> Console baud is 9600. Using 115200 produces garbled output.

## Port Assignments

| Port | Description | Mode | VLAN(s) |
|---|---|---|---|
| Gi1/0/1 | Trunk-to-MKT01 | Trunk | All tagged, native **999** |
| Gi1/0/2 | LabComputer | Access | 10 |
| Gi1/0/3 | **Disabled — pending device assignment, see `ADR-0002`** | — | 🔴 **SHUTDOWN** |
| Gi1/0/4 | PVE01 | Trunk | All tagged, native **10** |
| Gi1/0/5 | SPAN-Monitor-Port | Monitor | N/A |
| Gi1/0/6 | FortiGate-Management | Access | 10 |
| 🔴 **Gi1/0/7** | 🔴 **Pi01 — Root CA, Intermediate CA, Vaultwarden, Pi-hole, FreeRADIUS** | **Access** | **10** |
| Gi1/0/8-48 | Unused | Access | 999 (shutdown) |
| Gi1/0/49-52 | Unused-SFP | — | shutdown |

> 🔴 **CORRECTED 2026-07-14 (`CM-0022`) — device-verified. The old table was the pre-2026-07-13 layout, and a rebuild from it killed Pi01 FOUR SEPARATE WAYS:**
>
> | This guide said | The device says |
> |---|---|
> | `Gi1/0/2` — **Raspberry-Pi** | **LabComputer.** The Pi was moved to `Gi1/0/7`. **A rebuilder cabling by description put the Pi in the wrong port.** |
> | `Gi1/0/3` — **Windows-Laptop, VLAN 50** + `no shutdown` | 🔴 **`disabled`** — *"Disabled - pending device assignment, see ADR-0002"*. **`ADR-0002` decided it. `CM-0003` executed it. The old guide silently REVERSED BOTH.** |
> | `Gi1/0/7-48` — **Unused, VLAN 999, shutdown** | 🔴 **`Gi1/0/7` is Pi01 — VLAN 10, CONNECTED.** **The old guide shut down the port holding the entire lab PKI.** |
> | *(no row)* | 🔴 **Pi01 appeared NOWHERE in this guide.** |

## 1. Verify Firmware

```text
show version
```

Confirm **WS-C2960X-48FPS-L**, IOS **`15.2(2)E6`** — 🔴 **device-verified 2026-07-14.** *(This guide said `15.2(7)E`. It was never right.)*

## 2. Initial Setup

```text
enable
configure terminal
hostname SW01
ip domain-name lab.local
enable secret YourStrongPassword
no ip http server
no ip http secure-server
no cdp run
service password-encryption
exit
```

> Replace `YourStrongPassword` before running. Pasting the placeholder sets it as the actual password, causing an immediate lockout. If locked out, authenticate with the literal placeholder string, then change it immediately.

## 3. Create Local User and Enable SSH

```text
configure terminal
username cisco privilege 15 secret YourStrongPassword
crypto key generate rsa modulus 2048
ip ssh version 2
ip ssh time-out 60
ip ssh authentication-retries 3
line vty 0 15
 transport input ssh
 login local
 exec-timeout 10 0
exit
exit
```

SSH from Windows requires legacy flags — IOS 15.2 only offers deprecated algorithms:

```text
ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa -oMACs=+hmac-sha1 cisco@10.10.0.2
```

Add to `C:\Users\<username>\.ssh\config` to avoid typing flags every time:

```text
Host sw01
    HostName 10.10.0.2
    User cisco
    KexAlgorithms +diffie-hellman-group14-sha1
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
    MACs +hmac-sha1
```

## 4. Create VLANs

```text
configure terminal
vlan 10
 name Management
vlan 20
 name Servers
vlan 30
 name Web
vlan 40
 name Monitoring
vlan 50
 name Client
vlan 60
 name Deployment
vlan 70
 name Testing
vlan 80
 name DMZ
vlan 999
 name Unused
exit
exit
write memory
```

Verify:

```text
show vlan brief
```

> Use `show vlan brief`. The plain `show vlan` command is not recognized on the 2960X.

## 5. Management SVI and Default Gateway

```text
configure terminal
interface vlan 10
 ip address 10.10.0.2 255.255.255.0
 no shutdown
exit
ip default-gateway 10.10.0.1
exit
write memory
```

> The VLAN 10 SVI shows `line protocol is down` until at least one active port is in VLAN 10. This is expected.

## 6. Management Access Restriction

```text
configure terminal
ip access-list standard MGMT-ACCESS
 permit 10.10.0.0 0.0.0.255
 permit 10.0.0.0 0.0.0.255
 deny any log
exit
line vty 0 15
 access-class MGMT-ACCESS in
exit
exit
write memory
```

## 7. Spanning Tree

```text
configure terminal
spanning-tree mode rapid-pvst
spanning-tree vlan 1-1005 priority 4096
exit
write memory
```

Verify after ports are connected:

```text
show spanning-tree
```

Expected: `This bridge is the root`.

## 8. DHCP Snooping

```text
configure terminal
ip dhcp snooping
ip dhcp snooping vlan 10,20,30,40,50,60,70,80
no ip dhcp snooping information option
interface GigabitEthernet1/0/1
 ip dhcp snooping trust
exit
exit
write memory
```

## 9. ARP Inspection

```text
configure terminal
ip arp inspection vlan 10,20,30,40,50,60,70,80
interface GigabitEthernet1/0/1
 ip arp inspection trust
exit
exit
write memory
```

## 10. Storm Control

```text
configure terminal
interface range GigabitEthernet1/0/1-48
 storm-control broadcast level 20
 storm-control multicast level 20
 storm-control action shutdown
exit
exit
write memory
```

## 11. Trunk Port — Gi1/0/1 (MKT01)

```text
configure terminal
interface GigabitEthernet1/0/1
 description Trunk-to-MKT01
 switchport mode trunk
 switchport trunk native vlan 999
 switchport trunk allowed vlan 10,20,30,40,50,60,70,80,999
 spanning-tree guard root
 ip dhcp snooping trust
 ip arp inspection trust
 no shutdown
exit
exit
write memory
```

## 12. Trunk Port — Gi1/0/4 (PVE01)

> **Native VLAN on Gi1/0/4 is 10, not 999.** PVE01's host management interface (vmbr0) sends untagged frames. Native VLAN 10 classifies those frames into the Management VLAN where PVE01's management IP (10.10.0.10) belongs. VM workloads on other VLANs use tagged virtual NICs — unaffected by the native VLAN setting. Using native VLAN 999 here makes PVE01 management unreachable.

```text
configure terminal
interface GigabitEthernet1/0/4
 description PVE01
 switchport mode trunk
 switchport trunk native vlan 10
 switchport trunk allowed vlan 10,20,30,40,50,60,70,80,999
 spanning-tree portfast trunk
 spanning-tree bpduguard enable
 switchport port-security maximum 16
 switchport port-security violation restrict
 switchport port-security
 no shutdown
exit
exit
write memory
```

## 13. Access Ports

**Gi1/0/2 — LabComputer (VLAN 10):**

> 🔴 **NOT the Raspberry Pi.** The Pi is on **`Gi1/0/7`**. Device-verified: `Gi1/0/2   LabComputer   connected   10`.

```text
configure terminal
interface GigabitEthernet1/0/2
 description LabComputer
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
 switchport port-security maximum 2
 switchport port-security violation restrict
 switchport port-security
 no shutdown
exit
exit
write memory
```

**🔴 Gi1/0/3 — SHUT DOWN. Do NOT enable it.**

> 🔴 **`ADR-0002` DECIDED THIS. `CM-0003` EXECUTED IT.**
>
> Documentation said VLAN 50; the live config said VLAN 10 — **a trust-zone discrepancy on a port with nothing plugged into it.** `ADR-0002`: *"committing to one without knowing why the other was configured would be **a guess dressed up as a decision**."* **Neither was chosen. The port was shut.**
>
> 🔴 **Until 2026-07-14 this guide brought it back up on VLAN 50 — silently reversing an accepted ADR and its executed change record.** **Device-verified: `Gi1/0/3   disabled`.**

> 🔴 **The port stays `shutdown`.** The lines below match the live device (device-verified 2026-07-16): it retains its VLAN-10 membership and port-security/edge config **while administratively down** — so a rebuild reproduces the exact live state. **Do not remove `shutdown`.**

```text
configure terminal
interface GigabitEthernet1/0/3
 description Disabled - pending device assignment, see ADR-0002
 switchport mode access
 switchport access vlan 10
 switchport port-security maximum 2
 switchport port-security violation restrict
 switchport port-security
 spanning-tree portfast
 spanning-tree bpduguard enable
 storm-control broadcast level 20
 storm-control multicast level 20
 storm-control action shutdown
 shutdown
exit
exit
write memory
```

**🔴 Gi1/0/7 — Pi01 (VLAN 10). THE MOST IMPORTANT ACCESS PORT ON THIS SWITCH.**

> 🔴 **Pi01 holds the Root CA, the Intermediate CA, Vaultwarden, Pi-hole and FreeRADIUS.**
>
> 🔴 **This block did not exist in this guide until 2026-07-14 — and Step 15 shut `Gi1/0/7` down as "unused."**

```text
configure terminal
interface GigabitEthernet1/0/7
 description Raspberry-Pi
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
 switchport port-security maximum 2
 switchport port-security violation restrict
 switchport port-security
 no shutdown
exit
exit
write memory
```

**Gi1/0/6 — FortiGate internal2 (VLAN 10):**

```text
configure terminal
interface GigabitEthernet1/0/6
 description FortiGate-Management
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
 no shutdown
exit
exit
write memory
```

## 14. SPAN Session

```text
configure terminal
interface GigabitEthernet1/0/5
 description SPAN-Monitor-Port
 no shutdown
exit
monitor session 1 source interface GigabitEthernet1/0/1 both
monitor session 1 destination interface GigabitEthernet1/0/5
exit
write memory
```

> SPAN `monitor session` commands must be entered inside `configure terminal`. They fail with `% Invalid input detected` at the exec prompt.

> 🔴 **Live-state note (device-verified 2026-07-16):** on the running switch, `show run` contains **only** `monitor session 1 destination interface Gi1/0/5` — **the `source` line is absent.** The SPAN is built here in the guide but is **not present on the device**; the monitor port mirrors nothing until the source is re-added. Rule 13 — the device wins, and the device has no source. **`CM-0036`.**

## 15. Shutdown Unused Ports

```text
configure terminal
interface range GigabitEthernet1/0/8-48
 description Unused
 switchport mode access
 switchport access vlan 999
 spanning-tree bpduguard enable
 shutdown
exit
interface range GigabitEthernet1/0/49-52
 description Unused-SFP
 shutdown
exit
exit
write memory
```

## 16. Static ARP Access List

ARP inspection blocks devices with static IPs — they have no DHCP snooping binding table entry. Add every static-IP device on VLAN 10 to `STATIC-HOSTS`. Confirm MACs directly from each device before adding.

> 🔴🔴 **ALL FIVE ARE REQUIRED. `DHCP Permits: 0` ON THIS SWITCH — THERE IS NO SNOOPING FALLBACK.**
>
> **A host missing from this ACL is DROPPED, FULL STOP.** No error. No warning. **It simply appears to be a broken device.**
>
> 🔴 **This guide built FOUR entries until 2026-07-14. Pi01 was the missing one** — and Pi01 holds the Root CA, the Intermediate CA, Vaultwarden, Pi-hole and FreeRADIUS. **The same omission in `023` produced a false *"Pi01 should be unreachable"* mystery that survived THREE HANDOFFS** (`016` lesson 6).
>
> **Build this from `006-Network-Source-of-Truth.md`. Not from memory. Not from a stale record.**

| Device | IP | MAC (IOS format) |
|---|---|---|
| 🔴 **Pi01** | 🔴 **10.10.0.5** | 🔴 **0000.5e00.5300** |
| PVE01 eno1 | 10.10.0.10 | 0000.5e00.5313 |
| Admin workstation | 10.10.0.50 | 0000.5e00.5316 |
| iDRAC *(shared LOM — **same port** as PVE01 `eno1`)* | 10.10.0.100 | 0000.5e00.5314 |
| FGT01 internal2 | 10.10.0.254 | 0000.5e00.5315 |

```text
configure terminal
arp access-list STATIC-HOSTS
 permit ip host 10.10.0.5 mac host 0000.5e00.5300
 permit ip host 10.10.0.10 mac host 0000.5e00.5313
 permit ip host 10.10.0.50 mac host 0000.5e00.5316
 permit ip host 10.10.0.100 mac host 0000.5e00.5314
 permit ip host 10.10.0.254 mac host 0000.5e00.5315
exit
ip arp inspection filter STATIC-HOSTS vlan 10
exit
write memory
```

**Read it back. Device-verified 2026-07-14 — `show arp access-list STATIC-HOSTS` returns exactly these five.**

> MAC format for IOS: remove colons, insert dot after every four characters. `00:00:5e:00:53:03` → `0000.5e00.5315`. The FGT01 MAC was confirmed via `diagnose hardware deviceinfo nic internal2`. Update entries when hardware changes.

## 17. SNMP and NTP

> 🔴 **DO NOT TYPE A LITERAL COMMUNITY STRING HERE.**
>
> **Charter, *Evidence and secrets*: *"A Build Guide never contains a value you would actually type."*** And, naming this exact string: *"**`snmp-server community homelab`** — **live, and SNMP v2c sends it in cleartext. Redact AND rotate.**"*
>
> 🔴 **Device-verified 2026-07-14: `snmp-server community homelab RO` is LIVE.** **`ADR-0010` gates publication of this repository on *"no live credential anywhere in the working tree."*** **Rotation: `CM-0023`.**

> 🔴 **`10.40.0.52` DOES NOT EXIST.** VLAN 40 is live, routed and **empty**. `006` plans LibreNMS at `10.40.0.20`. **Every trap this switch has ever sent went nowhere.** Point it at a real collector when Book 5 builds one — **not before.**

> 🔴🔴 **`ntp server 10.10.0.5` — PI01 SERVES NO NTP. VERIFIED 2026-07-14:**
>
> ```
> SW01# show ntp status
> Clock is unsynchronized, stratum 16, no reference clock
> reference time is 00000000.00000000 (18:00:00.000 CST Thu Dec 31 1899)
> system poll interval is 8, never updated.
> ```
>
> **`never updated`. Reference time 1899. SW01's clock has NEVER SYNCHRONISED.** `029` records no NTP service on Pi01. MKT01's `/system ntp server` is `enabled: no`.
>
> 🔴 **`045-SW01-CIS-Hardening-Checklist.md` ticks *"[x] NTP configured and synchronized — confirmed live."* THAT TICK IS FALSE.** *(`016` lesson 4 — a tick on a test nobody ran.)*
>
> **Every log line this switch has ever emitted carries a meaningless timestamp — which is the foundation Book 5 is supposed to build on.** **`CM-0030`.**

```text
configure terminal
snmp-server community <GENERATED-VALUE-FROM-VAULTWARDEN> ro
snmp-server contact <ADMIN>
snmp-server host <A-MONITORING-HOST-THAT-EXISTS> traps version 2c <GENERATED-VALUE>
snmp-server enable traps
ntp server <AN-NTP-SERVER-THAT-ACTUALLY-EXISTS>
clock timezone CST -6
clock summer-time CDT recurring
exit
write memory
```

**Then PROVE the clock. Do not tick this from the config:**

```text
show ntp status
```

**Expected: `Clock is synchronized, stratum <n>`.** 🔴 **`stratum 16` / `never updated` means it is syncing to NOTHING.**

> 🔴 **`snmp-server location Home-Lab-California` must be removed — it is STILL LIVE on the device (device-verified 2026-07-16).** A real-world location disclosure on a repository `ADR-0010` intends to publish. *(Same class as `L=Redding` in the certificate subjects — `029`.)* **Removal tracked in `CM-0037`** — this guide corrected the intent, but the device was never changed.

## 18. Final Save

```text
write memory
show startup-config | include hostname
```

Expected: 🔴 **`hostname SW01`**

> 🔴 **This step expected `hostname CoreSwitch` until 2026-07-14.**
>
> **`show run | include hostname` on the live device returns `hostname SW01`.** **The device was renamed. Seven documents — `001`, `006`, `012`, `016`, `019`, `023`, `045` — still say the live hostname is `CoreSwitch` and that a rename is "still open."**
>
> 🔴 **A validation step that states the WRONG expected result is worse than no validation at all — it converts a correct device into a "failure" and invites you to "fix" it.** **This guide contained TWO of them** — this one, and the ACL step, which stated **four** entries as the expected result when the device has **five**. `CM-0022`.

> 🟡 **Note on the count-check (`016` R1): the dangerous strings are deliberately NOT quoted verbatim anywhere in this document, including in these notes.** **A `grep -c` for a wrong value must return a clean `0` — if narrative text repeats it, the check is ambiguous forever, and an ambiguous check is one that gets ignored.**

## Validation

```text
show vlan brief
show interfaces status
show interfaces trunk
show spanning-tree
show port-security
show ip dhcp snooping
show ip arp inspection
show arp access-list STATIC-HOSTS
show monitor session 1
show snmp
show ntp status
show running-config
```

Expected:

- All 9 VLANs active
- 🔴 **`Gi1/0/1,2,4,5,6,7` connected; `Gi1/0/3` DISABLED; `Gi1/0/8-52` disabled**
- Gi1/0/1 trunking native 999; Gi1/0/4 trunking native 10
- `This bridge is the root` in spanning-tree output
- DHCP snooping enabled VLANs 10-80; Gi1/0/1 trusted
- ARP inspection enabled VLANs 10-80; Gi1/0/1 trusted
- 🔴 **`STATIC-HOSTS` has FIVE entries — INCLUDING Pi01 (`10.10.0.5`)** — filter applied to VLAN 10
- SPAN source Gi1/0/1 both; destination Gi1/0/5

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Enable password set to placeholder text | Locked out immediately after setup | Authenticate with literal placeholder, change immediately |
| `show vlan` instead of `show vlan brief` | `% Unrecognized command` | Use `show vlan brief` |
| SPAN commands at exec prompt | `% Invalid input detected` | Enter `configure terminal` first |
| SFP ports named Gi1/1/1-4 | `% Invalid input detected` | Correct names are Gi1/0/49-52 on this model |
| Gi1/0/4 native VLAN 999 | PVE01 management unreachable | Set `switchport trunk native vlan 10` on Gi1/0/4 |
| Static device not in STATIC-HOSTS | ARP inspection drops — device unreachable | Add IP/MAC entry to STATIC-HOSTS; get MAC from device directly |
| Wrong MAC in STATIC-HOSTS | ARP drops continue after adding entry | Read exact MAC from drop log: `SW_DAI-4-DHCP_SNOOPING_DENY` message contains the actual MAC |
| `portfast` on trunk without `trunk` keyword | Warning or not applied | Use `spanning-tree portfast trunk` on trunk ports |
| 🔴 **Pi01 omitted from `STATIC-HOSTS`** | 🔴 **The Root CA, the vault, DNS and RADIUS are silently dropped. It looks like a dead Pi.** | **ALL FIVE entries. This guide built four until 2026-07-14.** `016` lesson 6. |
| 🔴 **`Gi1/0/7` shut down as "unused"** | 🔴 **Pi01's switch port is administratively down, in VLAN 999** | **The unused range is `Gi1/0/8-48`. NOT `7-48`.** |
| 🔴 **`ntp server` pointed at a host that serves no NTP** | 🔴 **`show ntp status` → `stratum 16, never updated`. Every timestamp meaningless.** | **PROVE it. A config line is not a synced clock.** |
| Console baud at 115200 | Garbled output | Set terminal emulator to 9600 baud |
| SSH without legacy flags | `no matching key exchange method found` | Use full flag set — see Step 3 |
| Config pasted into SSH session | Hostname changes mid-session | Verify you are in the correct window before pasting |

## Rollback

```text
copy startup-config running-config
```

Or reload if configuration was never saved. Verify VLAN database, trunk ports, and spanning tree after restore.

## Completion Checklist

- [ ] Firmware verified (IOS 15.2)
- [ ] Hostname **SW01**, domain lab.local
- [ ] SSH configured with 2048-bit RSA key
- [ ] All 9 VLANs created and named
- [ ] Management SVI 10.10.0.2/24 configured
- [ ] Default gateway 10.10.0.1
- [ ] MGMT-ACCESS ACL applied to VTY lines
- [ ] Spanning tree rapid-pvst, priority 4096, this bridge is root
- [ ] DHCP snooping enabled VLANs 10-80; Gi1/0/1 trusted
- [ ] ARP inspection enabled VLANs 10-80; Gi1/0/1 trusted
- [ ] Storm control on all active ports
- [ ] Gi1/0/1 trunk — native 999, all VLANs, root guard
- [ ] Gi1/0/4 trunk — native VLAN 10 (not 999)
- [ ] Gi1/0/2 access VLAN 10 (**LabComputer**)
- [ ] 🔴 **Gi1/0/3 SHUT DOWN** (`ADR-0002` / `CM-0003`) — **do NOT enable it**
- [ ] 🔴 **Gi1/0/7 access VLAN 10 (Pi01) — CONNECTED, not shut down**
- [ ] Gi1/0/5 SPAN destination configured
- [ ] Gi1/0/6 access VLAN 10 (FGT01 internal2)
- [ ] Gi1/0/8-52 shutdown in VLAN 999 — 🔴 **`Gi1/0/7` is NOT in this range**
- [ ] 🔴 **`STATIC-HOSTS` has FIVE entries, including Pi01 (`10.10.0.5` / `0000.5e00.5300`)** — read back with `show arp access-list STATIC-HOSTS`
- [ ] SNMP configured — 🔴 **generated community, NOT `homelab`; trap host must EXIST**
- [ ] 🔴 **NTP PROVEN with `show ntp status` → `Clock is synchronized`. NOT `stratum 16`.**
- [ ] `write memory` confirmed
- [ ] All validation checks pass
- [ ] Build Record updated


---

## Change Log

| Version | Changes |
|---|---|
| 2.0 | Verified build guide. |
| **3.0** | 🔴 **2026-07-14 — `CM-0022`. Every change below was made AFTER reading the live SW01, not from a document.** <br><br>🔴 **A rebuild from v2.0 killed Pi01 FOUR SEPARATE WAYS:** it built a **four-entry `STATIC-HOSTS`** with Pi01 missing (and its Validation section stated *"four entries"* as the **expected result**); it **shut down `Gi1/0/7`** — Pi01's port — in the `7-48` unused range; it put that port in **VLAN 999**; and it labelled **`Gi1/0/2` "Raspberry-Pi"**, so a rebuilder cabling by description put the Pi in the wrong port. **With `DHCP Permits: 0` there is no snooping fallback: Pi01 is dropped silently and simply appears broken.** <br><br>🔴 **It also re-enabled `Gi1/0/3` on VLAN 50** — silently reversing `ADR-0002` and its executed change record `CM-0003`. Neither has a Build Guide reconciliation row; **both predate Charter Rule 15.** <br><br>🔴 **It typed the live SNMP community** the Charter names by string and orders rotated, pointed traps at **`10.40.0.52` — a host that does not exist** — and disclosed the lab's real-world location. <br><br>🔴🔴 **`ntp server 10.10.0.5` was never a working clock. `show ntp status` → `Clock is unsynchronized, stratum 16, never updated`, reference time 1899.** Pi01 serves no NTP; MKT01's NTP server is `enabled: no`. **`045` ticks this as *"configured and synchronized — confirmed live."* The tick is false.** **`CM-0030`.** <br><br>🔴 **Hostname corrected to `SW01`** — device-verified `hostname SW01`. **Seven documents still claim the live hostname is `CoreSwitch` and that a rename is "still open." It already happened.** <br><br>🔴 **IOS corrected to `15.2(2)E6`** — device-verified. This guide said `15.2(7)E`. <br><br>🟢 **Confirmed correct and unchanged:** `Gi1/0/1` trunk native 999, `Gi1/0/4` trunk native 10, DHCP snooping and DAI trusted on `Gi1/0/1` only, storm control, RSTP root, and the five-entry live ACL. |
| 3.1 | 🟢 **2026-07-16 — reconciled against the live `056` run.** Corrected the SNMP note (`Home-Lab-California` is **still live**, not removed — `CM-0037`); added a **SPAN live-state note** (the device has the destination but **no source** — `CM-0036`); and **completed the `Gi1/0/3` block** so a rebuild reproduces the live state (VLAN 10 + port-security + portfast/bpduguard/storm-control, still `shutdown`) instead of a barer port. No target changed — these align the guide with what the device actually runs. |
