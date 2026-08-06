---
Title: VLAN Standards
Path: Labs/Lab-01-Mikrotik-Core/Standards
---

# VLAN Standards

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Standards

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | 2.0 |
| Applies To | Atlas 2.0 |
| Last Reconciled | 2026-07 |

## VLAN Reference

| VLAN | Name | Subnet | Gateway | Trust | Current Hosts |
|---:|---|---|---|---|---|
| 10 | Management | 10.10.0.0/24 | 10.10.0.1 | Highest | Pi-hole (10.10.0.5), PVE01 (10.10.0.10), iDRAC (10.10.0.100), SW01 (10.10.0.2), FGT01 mgmt (10.10.0.254) |
| 20 | Servers | 10.20.0.0/24 | 10.20.0.1 | High | Windows Server AD DCs (planned), TrueNAS, Proxmox Backup Server |
| 30 | Web | 10.30.0.0/24 | 10.30.0.1 | Controlled | Web/application tier — no hosts yet |
| 40 | Monitoring | 10.40.0.0/24 | 10.40.0.1 | High visibility | Wazuh (10.40.0.10 planned), LibreNMS (10.40.0.20), Grafana (10.40.0.30) |
| 50 | Client | 10.50.0.0/24 | 10.50.0.1 | Medium | Workstations — DHCP from Windows Server when deployed |
| 60 | Deployment | 10.60.0.0/24 | 10.60.0.1 | Controlled | WDS, PXE boot |
| 70 | Testing | 10.70.0.0/24 | 10.70.0.1 | Low | Isolated — internet only, no lab VLAN access |
| 80 | DMZ | 10.80.0.0/24 | 10.80.0.1 | Low | Future public-facing services — no hosts yet |
| 999 | Unused | None | None | None | Native VLAN catch-all — no IP, no hosts, no routing |

---

## Trunk Port Rules

### MKT01 ether3 → SW01 Gi1/0/1

- Mode: trunk (802.1Q)
- Native VLAN: **999**
- Tagged: 10, 20, 30, 40, 50, 60, 70, 80, 999
- All production VLANs are tagged. Untagged frames arriving on this trunk land in VLAN 999 (unused catch-all) and have no routing path.

### SW01 Gi1/0/4 → PVE01 eno1

- Mode: trunk (802.1Q)
- Native VLAN: **10**
- Tagged: 10, 20, 30, 40, 50, 60, 70, 80, 999
- Native VLAN 10 is the exception to the standard native VLAN 999 rule. PVE01 host management (vmbr0) sends untagged frames — native VLAN 10 classifies them into the Management VLAN where PVE01's management IP belongs. VM workloads use tagged virtual NICs and are unaffected by this setting.

> This exception is documented here because it will cause PVE01 to be unreachable if Gi1/0/4 is ever reconfigured with native VLAN 999. Any rebuild of SW01 must preserve native VLAN 10 on Gi1/0/4.

---

## Native VLAN Design Decision

Atlas standardizes native VLAN **999** on all trunk ports except Gi1/0/4.

VLAN 999 has no IP address, no gateway, and no firewall path to any production network. An untagged frame arriving on a trunk port — from a misconfigured device, a cabling mistake, or an unauthorized connection — is silently dropped with no network access.

This prevents the classic native VLAN attack (VLAN hopping) and makes misconfigurations immediately visible: if a device is unreachable and its trunk port has native VLAN 999, the device is either misconfigured or not tagging its traffic.

---

## East-West Traffic Policy

MKT01 enforces east-west segmentation between VLANs. The default posture is deny. The following inter-VLAN flows are explicitly permitted:

| Source VLAN | Destination | Permitted Because |
|---|---|---|
| 10 Management | All VLANs | Admins need full access to manage all segments |
| 40 Monitoring | All VLANs | Monitoring agents and SNMP polling require visibility into all segments |
| 20 Servers | Internet (ether1) | Servers need updates, external APIs |
| 50 Client | 20 Servers | Users access applications on Servers |
| 50 Client | Internet | Standard user internet access |
| 60 Deployment | 20 Servers | WDS/PXE pushes images to Servers |
| 30 Web | 20 Servers | Web tier communicates with backend Servers (three-tier pattern) |
| 70 Testing | Internet only | Isolated — no lab VLAN access, internet permitted for tool downloads |
| bridgeLocal | All VLANs + Internet | Admin recovery network — full access |

All other inter-VLAN traffic is dropped and logged with prefix `EAST-WEST-DENIED:`.

---

## How to Add a New VLAN

Adding a VLAN touches multiple devices. Do not add a VLAN to one device without completing all steps — a partial deployment creates asymmetric routing or firewall gaps.

**Required changes — in this order:**

1. **Source of Truth** (`006-Network-Source-of-Truth.md`) — add the VLAN to the VLAN reference table with subnet, gateway, and purpose before touching any device

2. **MKT01** — create the VLAN sub-interface and assign the gateway IP:
   ```routeros
   /interface vlan add name=vlanXX-name vlan-id=XX interface=bridge-trunk comment="Purpose"
   /ip address add address=10.X0.0.1/24 interface=vlanXX-name
   ```
   If the VLAN needs internet and inter-VLAN access, add it to the VLANs interface list:
   ```routeros
   /interface list member add list=VLANs interface=vlanXX-name
   ```
   If it needs isolation (like VLAN 70), do NOT add it to the VLANs list — add a specific internet-only forward rule instead.

3. **SW01** — add the VLAN to the database and to all relevant trunk ports:
   ```text
   configure terminal
   vlan XX
    name Name
   exit
   interface GigabitEthernet1/0/1
    switchport trunk allowed vlan add XX
   exit
   interface GigabitEthernet1/0/4
    switchport trunk allowed vlan add XX
   exit
   exit
   write memory
   ```

4. **MKT01 firewall** — add explicit forward rules for the new VLAN's permitted traffic before the catch-all drop rule. Use `place-before=[find comment="Drop everything else"]`.

5. **PVE01** — no host-level changes needed. Place VMs on the new VLAN by setting the VLAN tag on each VM's virtual NIC in the Proxmox GUI.

6. **DHCP** — if the VLAN needs DHCP, configure a scope on Windows Server and add a DHCP relay on MKT01:
   ```routeros
   /ip dhcp-relay add name=relay-vlanXX interface=vlanXX-name dhcp-server=10.20.0.X local-address=10.X0.0.1
   ```

7. **DNS** — add any required DNS records to Pi-hole or Windows Server AD DNS.

8. **Change Record** — commit a Change Record documenting what was added and why.

9. **Validation** — confirm routing works from the new VLAN: ping the gateway, ping another VLAN (if permitted), ping internet. Confirm blocked traffic is denied and logged.

---

## How to Remove a VLAN

Removing a VLAN is the reverse of adding one — but check for dependencies first.

Before removing:
- Confirm no active hosts are using the subnet
- Check MKT01 firewall rules for references to the VLAN interface name
- Check FGT01 address objects for references to the subnet
- Check DHCP scopes and DNS records

Remove in this order: DHCP relay → firewall rules → gateway IP → VLAN interface → SW01 trunk allowed list → SW01 VLAN database → Source of Truth update → Change Record.

---

## VLAN 70 — Testing Isolation

VLAN 70 is explicitly excluded from the MKT01 `VLANs` interface list. This is a design decision, not an oversight.

A device on VLAN 70 can reach the internet. It cannot reach any other lab VLAN. This provides a safe environment for testing potentially malicious software, misconfigured VMs, or security research tools without risk to production systems.

If inter-VLAN access is ever needed from Testing, it must be added as an explicit, time-limited firewall rule with a Change Record — not by adding VLAN 70 to the VLANs list.
