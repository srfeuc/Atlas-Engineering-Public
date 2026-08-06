---
Title: PVE01 Networking — Build Record (authoritative)
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Records
Status: 🟢 Verified reality — the SINGLE authoritative home for PVE01 networking (`ADR-0034`, `POL-0008`). Current design device-verified 2026-07-24. Verify on the device before trusting a doc (`POL-0001`).
Version: 1.0
Date: 2026-07-28
---

# PVE01 Networking — Build Record

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **PVE01** (Dell R410 hypervisor, physically a Lab-01 asset; actively used by Lab-02). Role: **Proxmox VE host networking.**

> 🔴 **This is the ONE authoritative home for PVE01's networking (`ADR-0034`, `POL-0008`).** The build **procedure** lives in `Virtualization/Build-Guides/204-Proxmox-Networking.md` (it points here for verified state). The **frozen Lab-01** docs — `Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor/Build-Record-Network.md` and `…/Build-Guide-Network.md` — describe the **pre-2026-07-24 design** (`/24`, untagged native-VLAN-10) and are retained only as a historical snapshot; they now point here. A **Confluence** copy exists and must be manually redirected.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering (Virtualization book) |
| Status | 🟢 **Verified** — current design device-verified **2026-07-24** (R410 console: `ip -br a`, `ping 10.10.0.1` 0% loss). One follow-up item open (permanent `bridge-vids` reconcile — §5). |
| Version | 1.0 |
| Applies To | **PVE01** — Proxmox VE 8.4.19 (Debian 12, kernel 6.8.12-32-pve) |
| Authoritative for | PVE01 host networking: interfaces, `vmbr0` VLAN-aware bridge, management VLAN, SW01 uplink, VM VLAN model (`POL-0008`). |
| Governing | `ADR-0034` (this doc is the SoT), `ADR-0023` (Lab-02 topology), `ADR-0020` (time), `POL-0001` (evidence), `POL-0008` (one home). Procedure: `204-Proxmox-Networking.md`. |

## Platform (context — full record in the Virtualization pack)

| Item | Value |
|---|---|
| Hardware | Dell PowerEdge R410 |
| CPU | 2 × Intel Xeon E5620 — **16 logical CPUs** (`grep -c '^flags.*vmx'` = 16; **not** the `egrep -c '(vmx\|svm)'` = 32, which double-counts on kernel 6.8) |
| RAM | 64 GB physical / **62 GiB usable** |
| Proxmox VE | 8.4.19 · kernel 6.8.12-32-pve |
| Hostname / FQDN | `pve01` / `pve01.lab` (**not domain-joined** — a standalone hypervisor on the management plane, so `.lab`, not `atlas.lab`) |

## Current design (device-verified 2026-07-24) — tagged management, native 999

Host management is a **tagged VLAN-10** presence on a `vmbr0.10` subinterface; the physical uplink carries **nothing untagged**, so SW01 `Gi1/0/4`'s native VLAN is the unused parking VLAN **999**. This *supersedes* the earlier untagged-native-10 design (see History).

### Network interfaces

| Interface | MAC | State | Role |
|---|---|---|---|
| `eno1` | `00:00:5e:3f:f6:a2` | UP — bridge-port of `vmbr0` | Primary NIC → **SW01 `Gi1/0/4`** (trunk, native 999); 1 Gbps full-duplex |
| `eno2` | `00:00:5e:3f:f6:a3` | DOWN | `iface eno2 inet manual`, no `auto` — deliberately unconfigured |
| `vmbr0` | `00:00:5e:3f:f6:a2` | UP — **no L3** | VLAN-aware bridge (`bridge-vids 10–90,999`) |
| `vmbr0.10` | — | UP | **Host management, TAGGED VLAN 10** — `10.10.0.10/27` |
| **iDRAC** | `00:00:5e:3f:f6:`**`a4`** | UP | 🔴 **SHARED LOM — rides `eno1`'s cable on `Gi1/0/4`. NOT a separate port, NOT out-of-band.** |

### `/etc/network/interfaces` (target = current design, `204` v1.2)

```text
auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet manual
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 10,20,30,40,50,60,70,80,90,999

# Host management — TAGGED VLAN 10 (bare vmbr0 holds no L3)
auto vmbr0.10
iface vmbr0.10 inet static
        address 10.10.0.10/27
        gateway 10.10.0.1

iface eno2 inet manual

source /etc/network/interfaces.d/*
```

### IP addressing

| Interface | IP | VLAN | Method | Note |
|---|---|---|---|---|
| `vmbr0.10` | `10.10.0.10/27` | 10 (**tagged**) | Static | Matches `IP-Addressing-Plan-VLSM` Management `/27` (`10.10.0.0/27`, gw `.1`). Was `/24` in the old design — corrected to `/27` on 2026-07-24. |
| iDRAC | `10.10.0.100/24` | 10 (shared LOM) | Static | Reachable **only while SW01 + `Gi1/0/4` are up** — not a teardown bootstrap path. |

> 🔴 **`10.10.0.10` is correct — not `10.10.0.254`** (`.254` belongs to **FGT01**'s management interface; the old `.254` record was a collision, corrected per `217-Verified-Facts`).

### SW01 uplink

| SW01 port | Mode | Native VLAN | Allowed | Purpose |
|---|---|---|---|---|
| `Gi1/0/4` | Trunk | **999** (parking, carries nothing) | 10,20,30,40,50,60,70,80,90,999 | PVE01 `eno1` — host mgmt **tagged** VLAN 10 + VM traffic tagged. Coordinated with `SW01/Build-Guide.md` v0.7. |

### VM VLAN model

VMs are placed on a VLAN by setting the **802.1Q tag on the vNIC** (Proxmox GUI → Network Device → VLAN Tag). 🔴 **The VLAN must also be in `vmbr0`'s `bridge-vids`**, or the bridge tags the frame internally and drops it at the uplink (`eno1` would be a member of VLAN 1 only). `bridge-vlan-aware yes` *enables* tagging; `bridge-vids` is what actually trunks the tags to the wire. Verify with `bridge vlan show` → `eno1` lists every VM VLAN (10–90,999) as a tagged member.

## Verified evidence (`POL-0001`)

- ✅ **2026-07-24 (R410 console):** `vmbr0.10 = 10.10.0.10/27`; bare `vmbr0` + `eno1` no L3; `ping -c4 10.10.0.1` 0% loss; SW01 both trunks native 999, saved.
- ✅ 1 Gbps full-duplex re-confirmed (`ethtool eno1`); gateway + Internet reachable.
- ✅ Tagged-VM path proven: a VLAN-70 VM's cross-VLAN attempt logged `EAST-WEST-DENIED: forward: in:vlan70-testing out:vlan10-mgmt … 10.70.0.50 -> 10.10.0.5` at MKT01 — the tagged frame reached the router.

## Known issues / deviations

| Item | State | Ref |
|---|---|---|
| 🔴 **iDRAC on shared LOM** | Rides `eno1`/`Gi1/0/4` — **not** out-of-band; dies when SW01 is wiped (step 1 of any teardown). The R410 has an unused dedicated iDRAC port. Physical console is the real bootstrap. | `CM-0011` |
| 🔴 **CMOS/RTC durability** | New CR2032 installed 2026-07-16 but **durability RE-TEST FAILED** — RTC resets `2026`→`2018` across a power cycle. Keep on continuous power/UPS; NTP holds the OS clock while running (`ADR-0020`). | `CM-0012` (Open) |
| **`bridge-vids` permanence** | ☐ Ensure `bridge-vids 10,20,30,40,50,60,70,80,90,999` is **persisted** in `/etc/network/interfaces` and reconciled to live (`bridge vlan show`) after `ifreload -a`. | `204` §3 |
| No-subscription patch | Overwritten by `proxmox-widget-toolkit` updates — re-apply after updates. | — |

## History (why the frozen Lab-01 record disagrees)

- **Original:** host management **untagged**, classified by SW01 `Gi1/0/4`'s **native VLAN 10**; `vmbr0` held `10.10.0.10/**24**` directly. Recorded in the (now frozen) Lab-01 `Build-Record-Network.md` v2.3 (2026-07-16).
- 🔴 **Superseded 2026-07-24 (`204` v1.2):** coupling the *native* VLAN to the *management* VLAN was a hygiene problem **and** caused a real bug — a VM tagged VLAN 10 lost return traffic (the switch egressed VLAN 10 untagged on the native; a VLAN-aware bridge won't deliver an untagged frame to a tagged vNIC). Fix: management → **tagged `vmbr0.10`**, native → **999**, mask → **/27**. Apply **both ends from the iDRAC console in one window** (switch-only or PVE-only leaves management unreachable).

## Related

- `Virtualization/Build-Guides/204-Proxmox-Networking.md` — the **build procedure** (recovery-first order, apply steps, lessons); points here for verified state.
- `00-Atlas-Foundation/Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md` — why this is the single home.
- **Device front-door:** `../../Devices/PVE01-Hypervisor/` (the `#21` page-set — points here for this authoritative networking state, does not restate it).
- `Architecture/IP-Addressing-Plan-VLSM.md` (Management `/27`) · `Architecture/SW01-PVE01-Native-VLAN-Options.md` (the two native-VLAN patterns) · `SW01/Build-Guide.md` v0.7 (the switch end).
- **Historical (frozen Lab-01, pre-07-24 design):** `Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor/Build-Record-Network.md` · `…/Build-Guide-Network.md`.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. **Created as the single authoritative home for PVE01 networking (`ADR-0034`, `POL-0008`).** Consolidates the **current device-verified design** (`204-Proxmox-Networking` v1.2, verified 2026-07-24: tagged `vmbr0.10` `/27`, bare `vmbr0`, `bridge-vids 10–90,999`, SW01 `Gi1/0/4` native 999) with the still-true platform / interface / iDRAC-shared-LOM / CMOS facts from the frozen Lab-01 `Build-Record-Network` v2.3. Records the `.254`→`.10` collision correction, the native-10→tagged-`vmbr0.10` migration history, and the open `bridge-vids`-permanence item. Supersedes the three-competing-homes state (manifest Freeze #2); the Lab-01 docs are now pointers, `204` is the procedure, Confluence pending manual redirect. |
