---
Title: SW01 Trunk + PVE01 Host-Management VLAN Tagging — Design & Options (native-VLAN patterns)
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: 🟢 Reference / design doc. Option B is **chosen + device-verified 2026-07-24**. The two executable docs (`SW01/Build-Guide.md`, `204-Proxmox-Networking.md`) build the chosen option; this doc is the *why*, the *alternative*, and the *migration* (POL-0008: one execution source, this is the decision/comparison).
Version: 1.1
Date: 2026-07-24
---

# SW01 Trunk + PVE01 Host-Management — Native-VLAN Tagging Options

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — covers the one link where a switch trunk meets a hypervisor: **SW01 `Gi1/0/4` ⇄ PVE01 `eno1`** (link #5, `Cabling-and-Port-Map`). PVE01 is a VLAN-aware bridge carrying tagged VM VLANs; the open question this doc settles is **how PVE01's *own* management reaches VLAN 10** — untagged via the switch's native VLAN, or tagged by the host. Both patterns work; this documents both and records which Atlas runs and why.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 Reference. **Chosen = Option B** (tagged mgmt / native 999), device-verified 2026-07-24. |
| Version | 1.1 |
| Applies To | SW01 (`Gi1/0/4`) + PVE01 (`vmbr0`) — link #5 |
| Governs | The design choice only. **Executable authorities:** `Devices/SW01-Access-Switch/Build-Guide.md` (v0.7, the switch config) + `Virtualization/Build-Guides/204-Proxmox-Networking.md` (v1.2, the PVE config). This doc must not duplicate their step-by-step — it explains the two patterns and points there. |
| Reference | [Cisco native VLAN / 802.1Q trunking], [Proxmox VLAN-aware bridge](https://pve.proxmox.com/wiki/Network_Configuration), `IP-Addressing-Plan-VLSM` (VLAN 10 = `10.10.0.0/27`) |
| Governing Policy | `POL-0007` (hardening — native-VLAN hygiene), `POL-0001` (evidence), `POL-0008` (one execution source) |

---

## The concept in one paragraph

A trunk carries most VLANs **tagged** (an 802.1Q header names the VLAN). Exactly one VLAN can be **untagged** — the **native VLAN** — and any frame that arrives without a tag is classified into it. The design question for PVE01's management traffic is simply **who owns the tag**: let the **switch** own it (PVE sends management untagged, the switch's native VLAN puts it in VLAN 10 — *Option A*), or let the **host** own it (PVE tags its own management on a `vmbr0.10` subinterface, so the native VLAN can be an unused parking VLAN — *Option B*). Either way management lives on VLAN 10; only the tag ownership differs — and that difference has real security-hygiene and behavior consequences.

## 🔴 Decision: Option B (tagged management, native VLAN 999)

Atlas runs **Option B**. Reasons, in priority order:

1. **Native-VLAN hygiene (`POL-0007`).** The native (untagged) VLAN should be an **unused parking VLAN**, never a VLAN that carries real traffic — least of all the management VLAN. Coupling native to management means any device that falls back to untagged (a misconfigured access port, a bad tag) lands directly in management. Native 999 (a black-hole VLAN with no gateway, no SVI, no members) carries nothing.
2. **It fixes a real bug.** Under Option A, a VM whose vNIC is tagged **VLAN 10** loses its return traffic (the *asymmetry* below). Option A effectively makes VLAN 10 unusable for VM workloads. Option B makes VLAN 10 a normal tagged VLAN.
3. **Uniformity.** With Option B, **every** trunk in the estate is native 999 — one rule, no exceptions to remember.

The cost is one extra line of host config (`vmbr0.10`). That's the whole tradeoff.

## Quick comparison

| | **Option A — untagged mgmt (native 10)** | **Option B — tagged mgmt (native 999)** ✅ chosen |
|---|---|---|
| Who tags host mgmt | The **switch** (native VLAN) | The **host** (`vmbr0.10`) |
| SW01 `Gi1/0/4` native | `10` | `999` (parking) |
| PVE mgmt IP lives on | `vmbr0` (untagged) | `vmbr0.10` (tagged) |
| Native == management? | **Yes** (coupled) | No (decoupled) |
| VM tagged on VLAN 10 | ❌ breaks (asymmetry) | ✅ works |
| Native-VLAN hygiene | Weaker (mgmt is native) | Stronger, CIS-aligned |
| Host config complexity | Slightly simpler (no subinterface) | One subinterface |
| Changing it | Both ends, recovery-first | Both ends, recovery-first |

---

## Option A — Untagged host management (native VLAN 10)

**Concept.** PVE01 puts its management IP directly on the VLAN-aware bridge `vmbr0` and sends those frames **untagged**. SW01 `Gi1/0/4` has **native VLAN 10**, so it classifies the untagged frames into VLAN 10. The host never has to understand 802.1Q for its own management. VM VLANs are still tagged individually via `bridge-vids`.

**SW01 `Gi1/0/4`:**
```
interface GigabitEthernet1/0/4
 description Proxmox-Server
 switchport mode trunk
 switchport trunk native vlan 10
 switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,999
 ip arp inspection trust
 ! (+ port-security, storm-control, portfast trunk, bpduguard as live)
```

**PVE01 `/etc/network/interfaces`:**
```text
auto vmbr0
iface vmbr0 inet static
        address 10.10.0.10/27
        gateway 10.10.0.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 10,20,30,40,50,60,70,80,90,999
```

**Pros:** one fewer host interface; a very common enterprise pattern; the host is "VLAN-unaware" for its own management.
**Cons:** native == management (hygiene); **VLAN 10 is unusable for tagged VM workloads** (the asymmetry); "native 999" is not uniform across trunks.

---

## Option B — Tagged host management (native VLAN 999) ✅ chosen

**Concept.** PVE01 tags its own management on a **`vmbr0.10`** subinterface, exactly as each VM owns its tag. Nothing rides the wire untagged, so SW01 `Gi1/0/4`'s native VLAN is the unused parking **999**. Management is still VLAN 10 — the host just carries the tag itself.

**SW01 `Gi1/0/4`:**
```
interface GigabitEthernet1/0/4
 description Proxmox-Server
 switchport mode trunk
 switchport trunk native vlan 999
 switchport trunk allowed vlan 10,20,30,40,50,60,70,80,90,999
 ip arp inspection trust
 ! (+ port-security, storm-control, portfast trunk, bpduguard as live)
```

**PVE01 `/etc/network/interfaces`:**
```text
auto vmbr0
iface vmbr0 inet manual
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 10,20,30,40,50,60,70,80,90,999

auto vmbr0.10
iface vmbr0.10 inet static
        address 10.10.0.10/27
        gateway 10.10.0.1
```

**Pros:** native is a true parking VLAN (hygiene); **VLAN 10 works for tagged VMs**; uniform native-999 on every trunk.
**Cons:** one extra host interface (`vmbr0.10`); the host must be VLAN-aware for its own management (it already is, for VMs).

> 🔴 `bridge-vids` **must** include `10` (it does) so the uplink `eno1` is a tagged member of VLAN 10 — otherwise the host's own `vmbr0.10` frames are dropped at egress, the same way a VM VLAN would be. `bridge-vlan-aware yes` enables tagging; `bridge-vids` is what actually trunks the tag to the wire.

---

## 🔎 The asymmetry — why a VM tagged VLAN 10 breaks under Option A (the teaching bit)

This is the failure that motivated the switch to Option B (`SW01/Build-Guide.md` v0.6 → v0.7). Under **Option A** (native 10):

- A VM whose Proxmox vNIC is set to **VLAN Tag 10** sends frames **tagged 10**. The switch accepts them (10 is allowed) and forwards into VLAN 10. **Outbound works.**
- The return traffic from the VLAN-10 gateway egresses SW01 `Gi1/0/4` on **VLAN 10 — which is the native**, so it leaves **untagged**.
- On PVE01, a VLAN-aware bridge **will not hand an untagged frame to a vNIC that is tagged VLAN 10**. The frame arrives on the native/PVID path, not the tagged-10 path the VM's tap expects. **Return traffic is silently dropped** → the VM can't reach its gateway, even though its config looks perfect.

It is **not** DAI and **not** the `STATIC-HOSTS` filter — it is pure native-VLAN asymmetry: outbound tagged, inbound untagged, and the two don't meet. The only Option-A workaround is "never put VM workloads on the native VLAN 10" (the old rule). **Option B removes the asymmetry** because VLAN 10 is no longer native anywhere — it egresses **tagged** on `Gi1/0/4`, so a tagged VLAN-10 VM's return traffic arrives tagged and is delivered. VLAN 10 becomes an ordinary usable VLAN.

---

## Host subinterfaces on other VLANs — when to add them (usually: don't)

Adding a `vmbr0.X` gives the **hypervisor host itself** an IP on VLAN X. It is **not** how VMs get connectivity — a VM gets its VLAN from its vNIC's **VLAN Tag** on the VLAN-aware bridge (carried by `bridge-vids`), with no host interface involved. That's why the DCs (VMs tagged VLAN 20) reach the network with no `vmbr0.20`: `bridge vlan show` shows their `tapXi0` on VLAN 20 and `eno1` trunking 20 to the wire. **Do not create host subinterfaces for VM VLANs** — it doesn't help the VMs, and it puts the host where it shouldn't be.

**Default: the host keeps exactly one L3 leg — management (`vmbr0.10`).** Two reasons:

- 🔴 **Segmentation (`ADR-0023`).** A host leg on VLAN X is a directly-connected route on VLAN X, so host↔VLAN-X traffic rides the local bridge and **never crosses MKT01** — a hole punched straight through the east-west firewall. The hypervisor management plane belongs on **one** VLAN; to reach another zone the host routes through the gateway like anything else, so the firewall sees it.
- **Attack surface / Tier-0 hygiene.** PVE01 is a Tier-0-class box; every extra leg is another reachable interface to defend.

**The only legitimate host subinterfaces** are for infrastructure the *host itself* runs on a dedicated network — a backup network (PBS/BKP01), storage (NFS/iSCSI), or live-migration/cluster. Best practice puts those on a **separate physical NIC** (`eno2`, currently `DOWN`) rather than more tagged legs on `eno1`, and even then they segment deliberately. None apply today (local-LVM storage, single node, no separate backup fabric), so **the host correctly needs VLAN 10 only.** Revisit only when you add one of those services — and add the *one* subinterface that service needs, never a leg per VLAN.

## Migrating between the options (coordinated, recovery-first)

Both ends must change **together** — one end alone strands PVE01's management (untagged-into-999 black hole, or tagged-vs-native mismatch). Follow `Device-Hardening-Standard` Part A.

> 🔴 **Break-glass first.** PVE01's management path is what drops during the change; SW01's own management is **not** affected (it rides `Gi1/0/1`→MKT01, already native 999). So drive SW01 from your normal session and apply the PVE01 side from an **out-of-band seat** — the R410 **physical console** (chosen 2026-07-24; no iDRAC needed) or iDRAC if set up.

**A → B (untagged → tagged, native 10 → 999):**
1. Back up both ends (`show run` / export on SW01; `cp /etc/network/interfaces /root/interfaces.good.$(date +%F-%H%M%S)` on PVE01).
2. Prove the PVE01 out-of-band console (real login).
3. **Stage** the PVE01 Option-B file (bare `vmbr0` + `vmbr0.10`) but do **not** apply — management still up.
4. On SW01: `interface Gi1/0/4` → `switchport trunk native vlan 999`. *(PVE01 network mgmt drops here — expected.)*
5. From the console: `ifreload -a` (or `reboot` for a guaranteed clean apply). Management returns on `vmbr0.10`.
6. Verify (below), then **save**: SW01 `copy running-config startup-config`; PVE01 config already persisted.

**B → A (reverse, if ever needed):** restore the Option-A files, `switchport trunk native vlan 10` on SW01, apply PVE from the console. Same recovery-first discipline; same both-ends rule.

🔴 **Save the switch.** The native change lives in running-config until `copy run start`. If SW01 loses power unsaved under Option B, it reverts to native 10 and PVE (tagged-only) loses management until you re-apply or reboot the switch onto the saved config.

---

## Verification — the chosen option (device-verified 2026-07-24, `POL-0001`)

**SW01:**
```
SW01# show interfaces trunk
Port        Mode   Encapsulation  Status     Native vlan
Gi1/0/1     on     802.1q         trunking   999
Gi1/0/4     on     802.1q         trunking   999          <- was 10
  Vlans allowed on trunk: 10,20,30,40,50,60,70,80,90,999
SW01# copy running-config startup-config   -> [OK]   (persisted)
```

**PVE01 (from the R410 console after `ifreload -a`):**
```
root@pve01:~# ip -br a
vmbr0            UP             fe80::...           # no IPv4 — mgmt no longer here
vmbr0.10@vmbr0   UP             10.10.0.10/27       # host mgmt now tagged VLAN 10
root@pve01:~# ping -c3 10.10.0.1
3 packets transmitted, 3 received, 0% packet loss   # gateway reachable => switch is native 999
```
The successful **tagged-VLAN-10 round-trip** is itself the proof the switch is native 999 — under native 10 the untagged return would never reach the tagged `vmbr0.10`. Web UI confirmed reachable at `https://10.10.0.10:8006`.

- [x] SW01 `Gi1/0/4` native 999 (both trunks 999), saved to startup-config. ✅ 2026-07-24
- [x] PVE01 `vmbr0.10` = `10.10.0.10/27`; bare `vmbr0` no L3; gateway ping 0% loss. ✅ 2026-07-24
- [ ] *(optional, closes the teaching loop)* a VM tagged VLAN 10 reaches its gateway — the Option-A asymmetry now gone.

## Recovery / break-glass

| Device | Path this change risks | Break-glass |
|---|---|---|
| **SW01** | none (mgmt rides `Gi1/0/1`, native 999) | serial console 9600 8N1 |
| **PVE01** | web UI/SSH (VLAN 10 over `Gi1/0/4`) | **R410 physical console** (chosen); or iDRAC if set up |

Revert is one line per end (native → 10 on SW01; restore the backed-up `interfaces` on PVE01), both reachable via the seats above — no lockout, since SW01 never leaves.

## Common mistakes

- 🔴 **Changing one end only.** Switch-only → untagged PVE mgmt into the 999 black hole. PVE-only → tagged `vmbr0.10` vs the switch still egressing VLAN 10 untagged (the asymmetry). Both ends, one window.
- 🔴 **Applying the PVE side over the network.** You cut the very path you're on. Use the out-of-band console.
- 🔴 **Forgetting `copy run start` on SW01.** A power loss reverts native to 10 and breaks Option B mgmt.
- 🔴 **`vmbr0.10` without VLAN 10 in `bridge-vids`.** The host's own tagged mgmt is dropped at `eno1` — the same failure as a VM VLAN missing from `bridge-vids`.
- 🔴 **Leaving the IP on `vmbr0` after going to Option B.** With native 999 the untagged host frames go to parking; the IP must be on the tagged `vmbr0.10`.
- 🔴 **Treating native 999 as a "real" VLAN.** It is a black hole — no SVI, no gateway, no members; unused ports parked there. That is the point.

## Related

- `Devices/SW01-Access-Switch/Build-Guide.md` v0.7 (executable — the switch config + the recovery-first callout) · `Virtualization/Build-Guides/204-Proxmox-Networking.md` v1.2 (executable — the PVE config)
- `Architecture/Cabling-and-Port-Map.md` (link #5) · `Architecture/IP-Addressing-Plan-VLSM.md` (VLAN 10 = `10.10.0.0/27`) · `Architecture/CIS-Hardening-SW01.md` (native-VLAN hygiene)
- `Operations/Device-Hardening-Standard.md` (recovery-first; VM break-glass = console) · `ADR-0023` (SW01 = pure L2, MKT01 the gateway)

## Sources

- Native VLAN / untagged classification on an 802.1Q trunk — standard Cisco IOS trunk behavior (`switchport trunk native vlan`).
- Proxmox VLAN-aware bridge + host mgmt on a tagged VLAN via `vmbr0.<vid>` — [Proxmox VE Network Configuration](https://pve.proxmox.com/wiki/Network_Configuration) (the wiki's own example places the host IP on `vmbr0.X`).
- Device evidence (2026-07-24): SW01 `show interfaces trunk` + `copy run start [OK]`; PVE01 `ip -br a` + `ping 10.10.0.1` from the R410 console.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-24 | Added **"Host subinterfaces on other VLANs — when to add them (usually: don't)"** — VMs get VLANs from the vNIC tag + `bridge-vids` (no host interface), so the DCs work with no `vmbr0.20`; a host leg per VLAN would bypass MKT01 (`ADR-0023`) and enlarge the Tier-0 attack surface. Host keeps one L3 leg (`vmbr0.10`); dedicated host service networks (backup/storage/migration) go on `eno2`, only if/when built. |
| 1.0 | 2026-07-24 | Created — the two host-management-over-trunk patterns for SW01 `Gi1/0/4` ⇄ PVE01, side by side: **Option A** (untagged mgmt, native VLAN 10) and **Option B** (tagged mgmt `vmbr0.10`, native 999). Records **Option B as chosen + device-verified 2026-07-24** (SW01 both trunks native 999 saved; PVE `vmbr0.10` `10.10.0.10/27`, gateway ping 0% loss). Full config for each end of each option, comparison table, the tagged-VLAN-10 **asymmetry** deep-dive (why Option A breaks VM-on-VLAN-10), the coordinated recovery-first **A↔B migration**, verification with the live read-backs, recovery/break-glass table, and common mistakes. Points to `SW01/Build-Guide.md` v0.7 + `204-Proxmox-Networking.md` v1.2 as the executable authorities (POL-0008: this is the decision/comparison, not a second build source). |
