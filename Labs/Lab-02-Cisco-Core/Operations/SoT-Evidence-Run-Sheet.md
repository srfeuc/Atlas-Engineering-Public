---
Title: Lab-02 — Source-of-Truth Evidence Run-Sheet
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 LIVING — the "run these, paste the output" capture sheet that sets the authoritative device facts for NetBox / the source of truth. Complements the health-oriented per-device Diagnostics.md.
Version: 1.0
Date: 2026-07-28
---

# Lab-02 — Source-of-Truth Evidence Run-Sheet

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build).** This is the **inventory-capture** sheet: the exact commands that produce **authoritative evidence of what each machine actually is** — model, OS/firmware, every interface + MAC + speed/state, IPs/masks, VLAN/trunk membership, neighbors/cabling, and role. Run them, paste the output, and the answers become the **source of truth loaded into NetBox** (`NETBOX01`, `POL-0004`/`POL-0008`).

> **Why separate from `Diagnostics.md`:** Diagnostics answers *"is it healthy right now?"*; **this answers *"what is it, authoritatively?"*** — the facts NetBox owns. Capture discipline: paste the **real output** (`POL-0001`); read the runtime view (`show`-status / `print detail` / `get` / `ip -br`), never the config file. Mark a field ✅ only once its output is captured.

## How to run this
1. Work device-by-device. For each, run the block, **`tee` the output to a file** (`… | tee <host>-sot.txt`) so nothing is lost.
2. Fill the **NetBox mapping** column note as you go — it says which NetBox object/field each command feeds.
3. When a value disagrees with a doc (IP plan, cabling map), **the device wins** (`POL-0001`) — fix the doc, then load NetBox from the device truth.
4. Feed the results into `Devices/NETBOX01-Source-of-Truth/NetBox-Data-Load-Prep.md`.

---

## Cisco IOS — SW01 (2960X) & 1941 (ISR)
```
show version                      | tee <host>-sot.txt   # model, IOS train, serial, uptime  -> NetBox device-type + serial
show inventory                                            # chassis/module SKUs                -> device-type
show ip interface brief                                   # every L3 iface + IP + up/down       -> interfaces + IP addresses
show interfaces status                                    # port link/speed/duplex/VLAN         -> interface speed + access VLAN (SW01)
show interfaces | include line protocol|Hardware|address  # MAC per interface                   -> interface MAC
show vlan brief                                           # (SW01) VLAN db                      -> VLANs
show interfaces trunk                                     # (SW01) trunk ports + allowed VLANs  -> tagged interfaces + trunk
show cdp neighbors detail                                 # who's on each port (cabling truth)  -> cables (A-side/B-side)
show ip route                                             # (1941) routing table / OSPF        -> role evidence
show ip ospf neighbor                                     # (1941) adjacency                    -> topology
```
**NetBox mapping:** device (name/role/site), device-type (model+serial), interfaces (name/MAC/speed/enabled), IPs (+mask), VLANs, and **cables** — the `cdp neighbors detail` output is the authoritative A↔B port map (resolves the cabling-map `Gi1/0/X` placeholders).

## RouterOS — MKT01
```
/system resource print                     # model (RB1100AHx4), RouterOS version, serial -> device-type
/system routerboard print                  # board serial/firmware                          -> device-type
/interface print detail                    # every iface, MAC, running state                -> interfaces + MAC
/interface vlan print detail               # the 9 VLAN sub-ifaces on bridge-trunk           -> VLAN interfaces
/ip address print detail                   # every IP + mask + interface                     -> IP addresses (VLAN gateways .1)
/interface bridge port print detail        # trunk (ether3) + hw=no                          -> tagged uplink
/interface bridge vlan print               # VLAN member set per port                        -> VLAN tagging
/ip neighbor print detail                  # LLDP/CDP neighbors (cabling)                     -> cables
/routing ospf neighbor print               # 1941 adjacency                                  -> topology
```
**NetBox mapping:** MKT01 device + device-type (RB1100AHx4 + serial); interfaces (ether1 uplink, ether3 trunk, ether2 fallback, the 9 `vlanNN` sub-ifaces) with MACs; the VLAN-gateway IPs (`10.<vlan>.0.1`); cables from `/ip neighbor`.

## FortiOS — FGT01
```
get system status                          # model (FG-60E), FortiOS 7.4.5, serial      -> device-type
get hardware nic <wan1|internal>           # per-port MAC/link                            -> interface MAC/speed
get system interface physical              # interfaces + IP + status                     -> interfaces + IPs
get router info routing-table all          # routes (transit /30 + interior)             -> role evidence
get system arp                             # neighbors on the transit link                -> cabling hint
diagnose netlink brief                     # link states                                  -> interface enabled/speed
```
**NetBox mapping:** FGT01 device + device-type (FG-60E + serial); `wan1` (DHCP) and `internal` (`10.255.255.1/30`) interfaces + MACs; the transit /30. (🔴 read-back with `get`, not `show` — `MC-0001`.)

## Windows / PowerShell — DC01, DC02, ICA01, NPS01 (+ future member servers)
```powershell
Get-ComputerInfo -Property CsName,CsDomain,OsName,OsVersion,CsManufacturer,CsModel | Format-List
Get-NetAdapter | ft Name,MacAddress,LinkSpeed,Status                 # NICs -> interfaces + MAC
Get-NetIPConfiguration | ft InterfaceAlias,IPv4Address,IPv4DefaultGateway
Get-DnsClientServerAddress -AddressFamily IPv4 | ft InterfaceAlias,ServerAddresses
Get-ADDomainController -Identity $env:COMPUTERNAME | fl Name,IPv4Address,IsGlobalCatalog,OperationMasterRoles   # DCs
Get-WindowsFeature | ? Installed | ft Name                           # roles -> device role/services
Get-VM -Name <name> | fl VMId                                        # (on Proxmox: `qm config <vmid>`) -> host mapping
```
**NetBox mapping:** the VM as a device/VM (name/role/cluster=host), its vNIC MAC + IP/mask (VLAN 20), DNS, and the AD roles (DC/CA/RADIUS) as the device role. Record **which Proxmox host** runs it (`ADR-0036`).

## Linux / Proxmox — PVE01 (+ SRV01, NETBOX01, MON01, Pi01 as built)
```
pveversion ; cat /etc/pve/.version 2>/dev/null       # (PVE01) Proxmox version         -> device-type/platform
dmidecode -t system | grep -E 'Manufacturer|Product|Serial'   # hardware model/serial    -> device-type
ip -br link ; ip -br address                          # every iface + MAC + IP/mask     -> interfaces + IPs
bridge vlan show                                      # (PVE01) uplink VLAN membership   -> tagged interface
lldpctl 2>/dev/null || cat /sys/class/net/*/address   # neighbors / MACs                -> cables / interface MAC
qm list ; for v in $(qm list|awk 'NR>1{print $1}'); do echo "== $v =="; qm config $v | grep -E 'name|net0|memory|cores'; done   # VM inventory + which host -> NetBox VMs + host mapping
systemctl list-units --type=service --state=running   # running services                -> device services
```
**NetBox mapping:** PVE01 as the **cluster/host**; each VM (`qm list`) as a VM object with its host, vCPU/RAM, vNIC MAC + VLAN tag; `ip -br` gives the host's own `vmbr0.10` mgmt IP. **This `qm config` sweep is what authoritatively answers "which VM runs on which host."**

## Raspberry Pi — Pi01
```
cat /proc/cpuinfo | grep -E 'Model|Serial' ; vcgencmd version 2>/dev/null
ip -br address ; ip -br link                          # IP + MAC
systemctl is-active pihole-FTL chronyd                # the two services it should run
```

---

## What the SoT must end up owning (NetBox objects)
| NetBox object | Populated from | Authoritative field(s) |
|---|---|---|
| **Sites / Racks** | physical layout | one site (Atlas lab), rack if tracked |
| **Manufacturers / Device-Types** | `show version` / `get system status` / `/system resource` / `dmidecode` | model, part-number, serial |
| **Devices** (physical) | per-device capture | name, role, device-type, serial, status |
| **Virtual machines** | `qm list` / `qm config` (PVE01) | name, host/cluster, vCPU/RAM, status |
| **Interfaces** | interface commands | name, MAC, speed, enabled, 802.1Q mode (access/tagged) |
| **VLANs** | `show vlan` / `/interface vlan` | VID + name (10–90, 999) |
| **Prefixes** | `IP-Addressing-Plan-VLSM` (design) + device IPs (truth) | the VLAN subnets + transit /30s |
| **IP addresses** | interface IP commands | address/mask, assigned interface, DNS name |
| **Cables** | `cdp/lldp neighbors` | A-device/port ↔ B-device/port (resolves the `Gi1/0/X` placeholders) |

> **The point:** once these are captured from the devices and loaded, NetBox — **not** any hand-typed table — is the source of truth. `SW01 STATIC-HOSTS`/DAI and the `006`-style tables become **exports of NetBox** (`POL-0004`), which is the structural fix for the most-repeated Atlas defect (a hand-typed table silently dropped Pi01 and survived three handoffs).

## Related
- `Devices/NETBOX01-Source-of-Truth/NetBox-Data-Load-Prep.md` (the load target) · `Architecture/IP-Addressing-Plan-VLSM.md` (address design) · `Architecture/Cabling-and-Port-Map.md` (physical design — port numbers confirmed here) · `Atlas-Academy/Command-Library/` (what each command means) · per-device `Diagnostics.md` (health).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Created — the inventory-capture run-sheet (distinct from the health `Diagnostics.md`). Per-platform capture blocks (IOS, RouterOS, FortiOS, PowerShell/Windows, Linux/Proxmox, RPi) that produce authoritative device-type/serial/interface/MAC/IP/VLAN/cable/role facts, each mapped to the NetBox object it populates — including the `qm config` sweep that answers "which VM on which host" (`ADR-0036`) and the CDP/LLDP capture that resolves the cabling-map port placeholders. Sets the source of truth NetBox loads (`POL-0004`/`POL-0008`). |
