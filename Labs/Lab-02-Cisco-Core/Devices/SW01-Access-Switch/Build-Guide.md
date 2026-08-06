---
Title: SW01 Build Guide (L2 Access/Distribution Switch) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch
Status: 🟡 LIVING (v0.7). Cisco IOS CLI (**2960X**). Executes Build-Checklist. Read back STATUS, not `show run` (`POL-0001` R-A1). This is a **delta from the existing Lab-01 config**, not a fresh build.
Version: 0.7
Date: 2026-07-23
---

# SW01 — Build Guide (L2 Access / Distribution)

Executes `Build-Checklist.md`. **Role (`ADR-0023`):** pure L2 — carries all VLANs to MKT01 on one trunk, **does not route** (MKT01 is the gateway).

## 🔴 This is a DELTA from the live Lab-01 config (per Lab-01 `SW01-Access-Switch/Build-Guide`)
The 2960X **already has** VLANs 10–80, the trunks, the VLAN-10 SVI, DHCP snooping, DAI, port-security, spanning-tree root, and the SPAN port. So most steps below are **confirm**, and the real Lab-02 work is a short delta:
1. **Add VLAN 90 (OT)** and extend every allowed-VLAN / snooping / DAI list to `10,20,30,40,50,60,70,80,90,999`.
2. **Mgmt SVI mask → Lab-02 VLSM /27**: `interface vlan 10` → `ip address 10.10.0.2 255.255.255.224` (Lab-01 had /24; MKT01's gateway is `10.10.0.1/27`).
3. **Confirm the MKT01 trunk (`Gi1/0/1`) now cables to MKT01 `ether3`** (the `bridge-trunk` port), native VLAN **999**.
4. 🔴🔴 **Preserve the Lab-01 port lessons — do NOT reverse them:**
   - **`Gi1/0/3` stays `shutdown`** (`ADR-0002`/`CM-0003` — a deliberate decision, not an omission).
   - **`Gi1/0/7` = Pi01** (Root CA / Vault / Pi-hole / RADIUS), **VLAN 10, connected — NEVER shut it.**
   - `Gi1/0/2` = LabComputer (VLAN 10), `Gi1/0/6` = FortiGate-mgmt (VLAN 10), `Gi1/0/4` = PVE01 trunk **native VLAN 999** (changed from 10 on 2026-07-23 — PVE01 now tags its own management on `vmbr0.10`; see Step 3 + the coordinated `204-Proxmox-Networking` change), `Gi1/0/5` = SPAN.
   - 🔴 **Access ports are unaffected** — `Gi1/0/2/6/7` stay `switchport access vlan 10`. Native VLAN only concerns *trunks*; an access port carries its VLAN internally and this change does not touch it. VLAN 10 is now a normal tagged VLAN on every trunk, never a native.
5. **For "plug my computer in":** use a **VLAN-10 access port** (e.g. `Gi1/0/2`, or any free port set `switchport access vlan 10`), give the laptop a static `10.10.0.x/27` (DHCP isn't up yet) with gateway `10.10.0.1` — reaches MKT01 and, once the spine's up, the rest.

The steps below are the full target state — run them as **verify-or-add** against what's already there. The genuinely new items are **VLAN 90 + list extensions** and confirming the **SPAN → IDS**.

## Gate
- [ ] Console access (not network-dependent). `show version` → record the IOS train (right CIS benchmark + syntax).
- [ ] `IP-Addressing-Plan-VLSM` open — VLAN 10 = `10.10.0.0/27`, gateway `10.10.0.1` on MKT01.

## Step 1 — Base + SSH (no cleartext mgmt)
```
hostname SW01
ip domain-name atlas.lab
no ip domain lookup
crypto key generate rsa modulus 2048
ip ssh version 2
username <admin> privilege 15 secret <strong>
enable secret <strong>
no ip http server
no ip http secure-server
service password-encryption
banner motd # Admin Access Only #
line vty 0 15
 transport input ssh
 login local
line con 0
 exec-timeout 5 0
 logging synchronous
```
✅ `show ip ssh` (v2), `show run | include http|transport` (ssh-only, no http). 📷

## Step 2 — VLANs 10–90 + native/parking 999
```
vlan 10
 name Mgmt
vlan 20
 name Servers
vlan 30
 name Web
vlan 40
 name Monitoring
vlan 50
 name Clients
vlan 60
 name Deployment
vlan 70
 name Testing
vlan 80
 name DMZ
vlan 90
 name OT
vlan 999
 name NATIVE-PARK
```
✅ `show vlan brief` — nine zone VLANs + 999. 📷

## Step 3 — Trunk to MKT01 (`Gi1/0/1` → MKT01 `ether3`, link #4 — carries everything)
🔴 Native VLAN = **999**, allow 10–90 + 999, no DTP. ⚠️ **The 2960X is 802.1Q-only — do NOT run `switchport trunk encapsulation dot1q`** (it errors "% Invalid input"; encapsulation is dot1q by default).
```
interface GigabitEthernet1/0/1
 description ->MKT01 trunk (link#4, to ether3)
 switchport mode trunk
 switchport trunk native vlan 999
 switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,999
 switchport nonegotiate
 spanning-tree guard root
 ip dhcp snooping trust
```
Second trunk to **PVE01** (`Gi1/0/4`, link #5): **native VLAN 999** (changed from 10 on 2026-07-23), allowed 10–90 + 999. 🔴 **This is a coordinated two-ended change — read the callout below before running it.** PVE01 now tags its own management on `vmbr0.10` (a tagged VLAN-10 subinterface), so native 999 is correct here and there is no longer a native==management coupling anywhere. VLAN 10 is a normal tagged VLAN on this trunk.
```
interface GigabitEthernet1/0/4
 switchport mode trunk
 switchport trunk native vlan 999
 switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,999
 switchport nonegotiate
 ip arp inspection trust
```
🔴 **The PVE01 trunk MUST keep `ip arp inspection trust`** (device-verified 2026-07-21) — DAI is live on VLANs 20–90 and static VMs have no snooping binding, so an untrusted hypervisor uplink drops their ARP (this cut DC01 off entirely until trust was added). Don't drop it while changing the native VLAN.

> ### 🔴 Coordinated change — native 999 on `Gi1/0/4` + PVE01 tagged mgmt (recovery-first)
> Flipping this native alone **strands PVE01's web UI**: PVE01's `vmbr0` currently sends management *untagged*, relying on native 10 to classify it into VLAN 10. With native 999, that untagged traffic lands in the parking VLAN (black hole). So the switch change and the PVE01 change (`204-Proxmox-Networking.md` v1.2 — management moves onto a tagged `vmbr0.10`) happen together, from an **out-of-band** seat.
>
> **Break-glass first (`Device-Hardening-Standard` Part A):** get an actual login on **PVE01's iDRAC/BMC console** before touching anything — that is the recovery path when PVE01's network management drops during the window. SW01's own management is *not* at risk (it rides `Gi1/0/1`→MKT01, already native 999, independent of this trunk).
>
> **Order:**
> 1. Back up both ends — SW01 `show running-config` / export; on PVE01 `cp /etc/network/interfaces /root/interfaces.before-$(date +%F-%H%M%S)`.
> 2. 🔴 Prove the **iDRAC console** to PVE01 (real login).
> 3. On SW01 (from your MKT01-side mgmt session): apply the `Gi1/0/4` native-999 block above. *(PVE01 network mgmt drops here — expected.)*
> 4. **From the iDRAC console**, apply PVE01's `vmbr0.10` tagged-management stanza (`204` §Target Configuration) → `ifreload -a` (or reboot networking). PVE01 mgmt returns on tagged VLAN 10.
> 5. Verify: on PVE01 `ping 10.10.0.1` + web UI reachable at its VLAN-10 IP; on SW01 `show interfaces trunk` → **native 999 on both `Gi1/0/1` and `Gi1/0/4`**; a VM tagged VLAN 10 now reaches its gateway (the v0.6 asymmetry bug is resolved).
> 6. `copy running-config startup-config` (SW01); confirm PVE01 config persisted. Re-verify the iDRAC path still works (`Part A` step 4).
DAI is on for VLANs 20–90, and a statically-addressed VM (e.g. **DC01 on VLAN 20**) has **no DHCP-snooping binding** — so its ARP is dropped on the untrusted trunk and it **can't reach its gateway at all** (this blocked the DC entirely until the trust was added). Trust the hypervisor uplink exactly as the MKT01 trunk is; you can't snoop VM DHCP across a trunk. 🔴 **Also add `ip dhcp snooping trust` here once a VM serves DHCP** (Kea/DC), or snooping drops its offers.
✅ `show interfaces trunk` — Gi1/0/1 trunking, native 999, allowed 10–90(,999); `show interfaces g1/0/1 switchport`. `show ip arp inspection interfaces` — Gi1/0/1 **and** Gi1/0/4 trusted. 📷

## Step 4 — Access ports (+ portfast/bpduguard; park the unused)
```
interface <Gi to Pi01>
 description ->Pi01 (DNS/NTP)
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
!
interface <Gi to LabComputer>
 description ->LabComputer (VLAN10 + IDS)
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
!
! 🔴 park every unused port
interface range <unused>
 shutdown
 switchport access vlan 999
```
✅ `show interfaces status` — hosts in the right VLAN; unused = `disabled`. Count matches your unused list. 📷

## Step 5 — Management SVI (VLAN 10) — the ONLY L3, no routing
```
interface vlan 10
 ip address 10.10.0.2 255.255.255.224
 no shutdown
ip default-gateway 10.10.0.1
!  🔴 do NOT enable 'ip routing' (MKT01 routes, ADR-0023)
line vty 0 15
 access-class <mgmt-ACL> in
```
✅ `show ip interface brief` — SVI10 up; `ping 10.10.0.1` (MKT01) works; `show ip route` shows NO routing (or only connected). 📷

## Step 6 — L2 security (DHCP snooping now; DAI after NetBox)
```
ip dhcp snooping
ip dhcp snooping vlan 10,20,30,40,50,60,70,80,90
interface <Gi to MKT01>
 ip dhcp snooping trust
```
🔴 **DAI is deferred** — build it from the DHCP-snooping bindings + a **NetBox-generated** static ACL (Master-Build-Order Phase 3), not hand-typed (the Pi01-missing-from-`STATIC-HOSTS` defect). Consider `root guard` on the trunk if MKT01 shouldn't be root.
🔴 **Live-state gotcha (07-21):** on the running box DAI is currently **enabled on VLANs 20–90** (OFF on VLAN 10). Until NetBox generates bindings, that means **every static VM host on 20–90 depends on its uplink being DAI-trusted** — which is why the PVE01 trunk (`Gi1/0/4`) and the MKT01 trunk (`Gi1/0/1`) are both `ip arp inspection trust` (Step 3). Access ports stay untrusted. A VM that "can't reach its gateway" with no other cause → check `show ip arp inspection statistics vlan <n>` for a climbing Dropped counter.
✅ `show ip dhcp snooping` — enabled, uplink trusted, access untrusted. 📷

## Step 7 — SPAN → IDS (the new piece; Phase 6)
🔴 The source is the **MKT01 trunk = `Gi1/0/1`** (per Step 3). The 07-20 defect was a session with a destination but **no source** (captured nothing) — set both.
```
monitor session 1 source interface Gi1/0/1
monitor session 1 destination interface Gi1/0/5
```
✅ `show monitor session 1` — source = MKT01 trunk, dest = Gi1/0/5; 🔴 **confirm the IDS host actually receives frames** (SPAN built-but-never-plugged is telemetry you never use). 📷

## Step 8 — Time / logging / SNMP (verify NTP now; MON01 forward Phase 6)
```
ntp server <ADR-0020 source>
```
🔴 **Remove the carried-over Lab-01 v2c community ([`CM-0023`](../../../Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Changes/CM-0023-Remove-Carried-Over-SW01-v2c-SNMP-Community.md) — verified live in the config 07-20):**
```
no snmp-server community homelab RO
no snmp-server host 10.40.0.52 version 2c homelab
```
✅ `show snmp community` / `show run | include snmp-server` → **no `homelab`**, no v2c host.

🔴 `CM-0030`: SW01 has never had a working clock — **verify with `show ntp status` ("Clock is synchronized"), NEVER `show run`** (the `045` false-tick). Syslog → MON01 and SNMPv3 (auth+priv) → MON01 when MON01 exists; **never** re-add the old v2c `homelab` community (`CM-0023`).
✅ `show ntp status` — synchronized, sane stratum. 📷

## Step 9 — Save
`copy running-config startup-config`, then export (`Device-Backup-Runbook`).

## Validation — read STATUS, not config
- [ ] `show vlan brief` — nine VLANs + 999. 📷
- [ ] `show interfaces trunk` — **native 999 on BOTH `Gi1/0/1` and `Gi1/0/4`**, allowed 10–90(,999). 📷
- [ ] `show ip dhcp snooping` — on, uplink trusted. 📷
- [ ] `show monitor session 1` — correct + IDS receives frames. 📷
- [ ] 🔴 `show ntp status` — synchronized (not `show run`). 📷
- [ ] `ping 10.10.0.1` — reaches the gateway (MKT01).
- [ ] `show interfaces status` — unused ports disabled, count matches.

## Failure modes
- 🔴 **`switchport trunk encapsulation dot1q` on a 2960X** — "% Invalid input"; the switch is 802.1Q-only, omit the line (device-verified 2026-07-20).
- 🔴 **Native = VLAN 1 / native mismatch** — VLAN hopping; native 999 both ends.
- 🔴 **Enabling `ip routing`** — steals the gateway role from MKT01, breaks Option B.
- 🔴 **DAI dropping a legit host** absent from the binding/ACL — the Pi01 mystery; generate the ACL from NetBox, don't hand-type (defer DAI).
- 🔴 **DAI on VLANs 20–90 drops a static VM's ARP on the untrusted PVE01 trunk** — DC01 (VLAN 20) couldn't reach its gateway (in *or* out) until `Gi1/0/4` got `ip arp inspection trust` (device-verified 07-21). Trust hypervisor uplinks; you can't snoop VM DHCP across a trunk. Confirm with `show ip arp inspection statistics vlan 20`.
- ✅ **RESOLVED 2026-07-23 — the v0.6 native-VLAN-10 asymmetry.** Previously `Gi1/0/4` native = **10**, so VLAN-10 traffic egressed **untagged** and a VM whose vNIC was tagged VLAN 10 lost its return traffic (the VLAN-aware bridge won't hand an untagged frame to a tag-10 vNIC → gateway unreachable; not DAI, not `STATIC-HOSTS`). Now `Gi1/0/4` native = **999** and PVE01 tags its own management on `vmbr0.10`, so VLAN 10 egresses **tagged** on this trunk and a VM tagged VLAN 10 works normally. The old rule *"VM workloads never on native VLAN 10"* is **retired** — VLAN 10 is a normal tagged VLAN now. (The general native-mismatch caution above — native 999 both ends of every trunk — still stands.)
- 🔴 **SSH won't negotiate from a modern client** — old IOS offers only SHA1 KEX (`diffie-hellman-group14-sha1`/older), which current OpenSSH disables (`no matching key exchange method found`). It's **not** a key-size problem. Connect with `ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 [-o HostKeyAlgorithms=+ssh-rsa] ciscoadmin@10.10.0.2`, or (if the image supports it) set `ip ssh server algorithm kex diffie-hellman-group14-sha256`.
- 🔴 **Ticking NTP from `show run`** — only `show ntp status` proves sync (`CM-0030`/`045`).
- 🔴 **SPAN built, IDS never plugged in** — confirm frames arrive.
- **Telnet/HTTP left on** — cleartext mgmt, CIS fail.

## Related
`Build-Checklist.md` · `IP-Addressing-Plan-VLSM` (VLAN 10) · `Cabling-and-Port-Map` (links #4/#5/#6/#7/#8) · the MKT01 `Build-Guide` (the trunk's other end) · `CIS-Hardening-*` (harden pass) · `Master-Build-Order` (SW01 Phase 2; DAI Phase 3; SPAN Phase 6).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.7 | 2026-07-23 | **PVE01 trunk `Gi1/0/4` native VLAN 10 → 999** (Seth: native-10==mgmt was an oversight). Removes the last native==management coupling — native is now 999 (parking) on **every** trunk, and VLAN 10 is a normal *tagged* VLAN. Coordinated two-ended change: PVE01 moves its host management to a tagged `vmbr0.10` (`204-Proxmox-Networking.md` v1.2). Added the **recovery-first sequence** (iDRAC break-glass; switch-then-PVE-from-OOB) as a Step-3 callout, updated the delta-header `Gi1/0/4` bullet + the "access ports unaffected" note, and set validation to expect **native 999 on both trunks**. **Marked the v0.6 native-VLAN-10 VM asymmetry failure mode RESOLVED** — a VM tagged VLAN 10 now works (VLAN 10 egresses tagged on `Gi1/0/4`); the "VMs never on native 10" rule is retired. `ip arp inspection trust` retained on `Gi1/0/4`. ✅ **Device-verified 2026-07-24:** `show interfaces trunk` → `Gi1/0/4` native **999** (both trunks 999), `copy run start` → `[OK]`; PVE01 `vmbr0.10` = `10.10.0.10/27` with gateway ping 3/3 0% loss from the R410 console (see `Architecture/SW01-PVE01-Native-VLAN-Options.md`). |
| 0.1 | 2026-07-20 | Living draft — base/SSH, VLANs 10–90 + native 999, MKT01 trunk (pruned, no DTP) + PVE01 trunk, access ports (portfast/bpduguard, unused parked), mgmt SVI VLAN10 (no `ip routing`), DHCP snooping (DAI deferred to NetBox), SPAN→IDS, NTP verify-by-status. CLI + status read-backs; capture placeholders. Validate on device. |
| 0.3 | 2026-07-20 | Device fix (2960X): removed `switchport trunk encapsulation dot1q` (802.1Q-only switch — errors), added `999` to the trunk allowed list, pinned Gi1/0/1→MKT01 `ether3` + `guard root`/snooping-trust, and the PVE01 native-VLAN-10 lesson. |
| 0.2 | 2026-07-20 | Reframed as a **delta from the live Lab-01 config** (2960X already has VLANs 10–80/trunks/SVI/snooping/DAI/SPAN). Real Lab-02 work: **add VLAN 90 + extend all lists**, **/27 mgmt SVI**, confirm trunk → MKT01 `ether3` (native 999). 🔴 Carried the Lab-01 port-preservation warnings (Gi1/0/3 stays shut; **Gi1/0/7 = Pi01, never shut**; PVE01 trunk native 10). Added the "plug a laptop into a VLAN-10 access port, static `10.10.0.x/27`" path. |
| 0.4 | 2026-07-21 | **Reconciliation pass — folded verified 07-20 fixes into the step bodies (no new/unverified config).** (1) Step 7 SPAN source resolved to the verified MKT01 trunk `Gi1/0/1` (was a placeholder; the 07-20 defect was a source-less session). (2) Step 8 now carries the explicit removal of the live carried-over v2c `homelab` community + host `10.40.0.52` (`CM-0023`) — was only named, not removed. (3) Step 5 mgmt SVI resolved to the verified `10.10.0.2/27` (matched the delta header + tracker matrix; was a placeholder). Header → v0.4. VLAN 90 + list extensions and DAI-deferral unchanged (already correct). |
| 0.6 | 2026-07-22 | Added the **native-VLAN-10 VM asymmetry** failure mode — a VM tagged VLAN 10 loses return traffic over the PVE01 trunk (native 10 egresses untagged; VLAN-aware bridge won't deliver to a tag-10 vNIC). Not DAI, not `STATIC-HOSTS`. Rule: VM workloads on *tagged* VLANs, VLAN 10 (native) = infra mgmt only. Device-confirmed by moving the stuck VM to VLAN 20. |
| 0.5 | 2026-07-21 | **Device-verified: PVE01 trunk DAI trust + the SSH-KEX gotcha.** (1) `Gi1/0/4` (PVE01 trunk) now documented as **`ip arp inspection trust`** — DAI is live on VLANs 20–90, and DC01 (VLAN 20, static, no snooping binding) was **fully cut off** (no gateway in/out) until the trunk was trusted; added the live-state note in Step 6 and the `show ip arp inspection statistics` diagnostic, plus the forward `ip dhcp snooping trust` note for when a VM serves DHCP. (2) Added the **SSH legacy-KEX** failure mode (modern OpenSSH refuses the 2960X's SHA1 KEX — client `-o KexAlgorithms=+diffie-hellman-group14-sha1` / server `ip ssh server algorithm kex …-sha256`; not a key-size issue). |
