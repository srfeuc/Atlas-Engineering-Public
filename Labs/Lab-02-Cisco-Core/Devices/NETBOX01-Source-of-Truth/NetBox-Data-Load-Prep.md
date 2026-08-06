---
Title: NetBox — Source-of-Truth Data-Load Prep
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: 🟢 Planning — import-ready seed data for NetBox, from the IP plan + cabling map. Design-authoritative fields are filled; device-truth fields (serials, MACs, exact ports) are captured via the SoT Evidence Run-Sheet.
Version: 1.0
Date: 2026-07-28
---

# NetBox — Source-of-Truth Data-Load Prep

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build).** The data to load into **NETBOX01** (`10.20.0.11`) so it becomes the estate source of truth (`POL-0004`/`POL-0008`). Seeded from **design-authoritative** docs (`IP-Addressing-Plan-VLSM`, `Cabling-and-Port-Map`, `ADR-0036` placement). Fields that only the device can answer (serials, MACs, exact port numbers, VM vCPU/RAM) are marked **`<from SoT>`** — capture them with `Operations/SoT-Evidence-Run-Sheet.md`, then fill.

> **Once loaded, NetBox owns these facts.** `SW01 STATIC-HOSTS`/DAI and the `006`-style tables become **exports of NetBox**, not hand-typed (the structural fix for the recurring dropped-record defect).

## Load order (dependencies)
Bulk-import in this order (NetBox **CSV import** per object type, *or* a `pynetbox` script — CSV is simpler and reviewable):
**1** Site → **2** Manufacturers → **3** Device-Types → **4** Device-Roles → **5** Platforms → **6** Clusters (virtualization) → **7** VLANs → **8** Prefixes → **9** Devices → **10** Virtual-Machines → **11** Interfaces (+ VM interfaces) → **12** IP-Addresses → **13** Cables.

---

## 1. Site
```csv
name,slug,status
Atlas Lab,atlas-lab,active
```

## 2. Manufacturers
```csv
name,slug
Cisco,cisco
MikroTik,mikrotik
Fortinet,fortinet
Dell,dell
Raspberry Pi Foundation,raspberry-pi
```

## 3. Device-Types  (part_number/u_height indicative; confirm serials via SoT)
```csv
manufacturer,model,slug,part_number
Cisco,Catalyst 2960X,catalyst-2960x,WS-C2960X
Cisco,ISR 1941,isr-1941,CISCO1941/K9
MikroTik,RB1100AHx4,rb1100ahx4,RB1100AHx4
Fortinet,FortiGate 60E,fortigate-60e,FG-60E
Dell,PowerEdge R410,poweredge-r410,PowerEdge-R410
Raspberry Pi Foundation,Raspberry Pi,raspberry-pi,RPi
```

## 4. Device-Roles
```csv
name,slug,color
Perimeter Firewall,perimeter-firewall,f44336
Core Router,core-router,ff9800
Access Switch,access-switch,ffeb3b
East-West Firewall,eastwest-firewall,ff5722
Hypervisor,hypervisor,673ab7
Domain Controller,domain-controller,2196f3
Certificate Authority,certificate-authority,00bcd4
RADIUS/NPS,radius-nps,009688
Services,services,4caf50
Monitoring,monitoring,8bc34a
Backup,backup,795548
DNS-NTP,dns-ntp,cddc39
Tier-0 Workstation,paw,9c27b0
IPAM/SoT,ipam-sot,607d8b
```

## 5. Platforms
```csv
name,slug
Cisco IOS,cisco-ios
MikroTik RouterOS,routeros
Fortinet FortiOS,fortios
Proxmox VE (Debian),proxmox-ve
Ubuntu 26.04,ubuntu-2604
Windows Server 2025,windows-server-2025
Windows 11,windows-11
Raspberry Pi OS,raspberry-pi-os
```

## 6. Clusters (virtualization — for the VM→host mapping, `ADR-0036`)
```csv
name,type,site,status
PVE01,proxmox,Atlas Lab,active
PVE02,proxmox,Atlas Lab,offline
Home-PC Hyper-V,hyper-v,Atlas Lab,offline
```

## 7. VLANs
```csv
vid,name,slug,status
10,Management,management,active
20,Servers,servers,active
30,Web-App,web-app,reserved
40,Monitoring,monitoring,active
50,Clients,clients,reserved
60,Deployment,deployment,reserved
70,Testing,testing,reserved
80,DMZ,dmz,reserved
90,OT-Isolation,ot-isolation,reserved
999,Parking-Native,parking,active
```

## 8. Prefixes  (from `IP-Addressing-Plan-VLSM` — authoritative)
```csv
prefix,vlan,role,description
10.10.0.0/27,10,management,Management (gw .1 on MKT01)
10.20.0.0/26,20,servers,"Servers + Tier-0 carve .2-.9 (DCs/CA)"
10.30.0.0/28,30,web-app,Web/App
10.40.0.0/28,40,monitoring,Monitoring
10.50.0.0/25,50,clients,Clients
10.60.0.0/27,60,deployment,Deployment
10.70.0.0/28,70,testing,Testing
10.80.0.0/28,80,dmz,DMZ
10.90.0.0/26,90,ot-isolation,OT
10.255.255.0/30,,transit,FGT01<->1941 transit
10.255.255.4/30,,transit,1941<->MKT01 transit
10.255.0.1/32,,loopback,1941 OSPF RID
10.255.0.2/32,,loopback,MKT01 OSPF RID
```

## 9. Devices (physical)
```csv
name,device_role,device_type,site,status,serial
FGT01,Perimeter Firewall,FortiGate 60E,Atlas Lab,active,<from SoT>
1941,Core Router,ISR 1941,Atlas Lab,active,<from SoT>
SW01,Access Switch,Catalyst 2960X,Atlas Lab,active,<from SoT>
MKT01,East-West Firewall,RB1100AHx4,Atlas Lab,active,<from SoT>
PVE01,Hypervisor,PowerEdge R410,Atlas Lab,active,<from SoT>
Pi01,DNS-NTP,Raspberry Pi,Atlas Lab,planned,<from SoT>
PVE02,Hypervisor,,Atlas Lab,planned,
```

## 10. Virtual Machines  (cluster = physical host per `ADR-0036`; vCPU/RAM from SoT `qm config`)
```csv
name,cluster,role,status,vcpus,memory
DC01,PVE01,Domain Controller,active,<SoT>,<SoT>
DC02,PVE02,Domain Controller,staged,<SoT>,<SoT>
ICA01,PVE01,Certificate Authority,active,<SoT>,<SoT>
RCA01,PVE02,Certificate Authority,offline,<SoT>,<SoT>
SRV01,PVE01,Services,planned,<SoT>,<SoT>
NETBOX01,PVE01,IPAM/SoT,active,<SoT>,<SoT>
NPS01,PVE01,RADIUS/NPS,planned,<SoT>,<SoT>
MON01,PVE01,Monitoring,planned,<SoT>,<SoT>
BKP01,PVE02,Backup,planned,<SoT>,<SoT>
Vaultwarden,PVE02,Services,planned,<SoT>,<SoT>
PAW01,PVE02,Tier-0 Workstation,planned,<SoT>,<SoT>
```

## 11. Interfaces  (design shape; MACs from SoT)
Physical (examples — confirm names/MACs via SoT `cdp/lldp`):
```csv
device,name,type,enabled,mode,mac
FGT01,wan1,1000base-t,true,,<SoT>
FGT01,internal,1000base-t,true,,<SoT>
1941,Gi0/0,1000base-t,true,routed,<SoT>
1941,Gi0/1,1000base-t,true,routed,<SoT>
MKT01,ether1,1000base-t,true,routed,<SoT>
MKT01,ether3,1000base-t,true,tagged,<SoT>
SW01,Gi1/0/1,1000base-t,true,tagged,<SoT>
SW01,Gi1/0/4,1000base-t,true,tagged,<SoT>
SW01,Gi1/0/5,1000base-t,true,access,<SoT>
SW01,Gi1/0/7,1000base-t,true,access,<SoT>
PVE01,eno1,1000base-t,true,tagged,00:00:5e:3f:f6:a2
```
> MKT01 also carries 9 `vlanNN` sub-interfaces (VLAN gateways `10.<vlan>.0.1`) on `bridge-trunk` — add each as a virtual interface with its IP. PVE01 mgmt is `vmbr0.10`.

## 12. IP-Addresses  (from the IP-plan host register; device-confirmed via SoT)
```csv
address,device_or_vm,interface,dns_name,status
10.20.0.2/26,DC01,net0,dc01.atlas.lab,active
10.20.0.3/26,DC02,net0,dc02.atlas.lab,active
10.20.0.4/26,ICA01,net0,ica01.atlas.lab,active
10.20.0.10/26,SRV01,net0,srv01.atlas.lab,reserved
10.20.0.11/26,NETBOX01,net0,netbox01.atlas.lab,active
10.20.0.12/26,NPS01,net0,nps01.atlas.lab,reserved
10.20.0.13/26,Vaultwarden,net0,vault.atlas.lab,reserved
10.40.0.10/28,MON01,net0,mon01.atlas.lab,reserved
10.10.0.10/27,PVE01,vmbr0.10,pve01.lab,active
10.10.0.2/27,SW01,Vlan10,sw01.atlas.lab,active
10.255.255.1/30,FGT01,internal,,active
10.255.255.2/30,1941,Gi0/1,,active
10.255.255.5/30,1941,Gi0/0,,active
10.255.255.6/30,MKT01,ether1,,active
10.255.0.1/32,1941,Loopback0,,active
10.255.0.2/32,MKT01,loopback,,active
```
> VLAN gateways `10.<vlan>.0.1` are MKT01 VLAN-interface IPs — add one per VLAN, assigned to the matching `vlanNN` interface. Pi01 (`10.10.0.x/27`) and DHCP pools per the IP plan.

## 13. Cables  (from `Cabling-and-Port-Map`; exact ports confirmed by SoT `cdp/lldp`)
```csv
side_a_device,side_a_interface,side_b_device,side_b_interface,type
FGT01,internal,1941,Gi0/1,cat6
1941,Gi0/0,MKT01,ether1,cat6
MKT01,ether3,SW01,Gi1/0/1,cat6
SW01,Gi1/0/4,PVE01,eno1,cat6
SW01,Gi1/0/7,Pi01,eth0,cat6
```
> 🔴 The SW01 port numbers (`Gi1/0/1`→MKT01, `Gi1/0/4`→PVE01, `Gi1/0/5`=SPAN, `Gi1/0/7`=Pi01) are from the current docs but the cabling map left `Gi1/0/X/Y` open — **confirm the real ports from `show cdp neighbors detail` (SoT) and correct here before loading.**

## After loading — wire the outputs (`POL-0004`)
- [ ] **SW01 `STATIC-HOSTS`/DAI ACL** generated *from* NetBox (script/export), not hand-typed.
- [ ] The `006`-style address tables become **NetBox exports**.
- [ ] NetBox is now the answer to "what's on VLAN X / what IP is free / what's cabled to port Y."

## Related
- `Operations/SoT-Evidence-Run-Sheet.md` (captures the `<from SoT>` fields) · `Architecture/IP-Addressing-Plan-VLSM.md` · `Architecture/Cabling-and-Port-Map.md` · `Build-Guide.md` (NetBox install) · `ADR-0036` (VM→host).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Created — import-ready NetBox seed data (CSV per object, dependency-ordered): site, manufacturers, device-types, roles, platforms, clusters (PVE01/PVE02/Hyper-V per `ADR-0036`), VLANs (10–90,999), prefixes (VLAN subnets + transit /30s + loopbacks), physical devices, VMs (with host mapping), interfaces, the IP-plan host register, and cables. Design-authoritative fields filled; device-truth fields marked `<from SoT>` for capture via the run-sheet. Notes the SW01-port confirmation and the render-outputs-from-NetBox wiring (`POL-0004`). |
