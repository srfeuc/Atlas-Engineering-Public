# Atlas — Glossary

<!-- provenance -->
> **The repo-wide glossary.** Acronyms and Atlas-specific terms a reader hits across the docs — expanded, with *what it means in Atlas* where that helps. New here? Start at the root [`README.md`](README.md). The deep "why it works" for many of these lives in [`Atlas-Academy/Concepts/`](Atlas-Academy/Concepts/); the "how to verify" in [`Atlas-Academy/Command-Library/`](Atlas-Academy/Command-Library/).

## Atlas process & documentation

| Term | Meaning | In Atlas |
|---|---|---|
| **Pack / Book** | A complete subsystem's documentation set. | e.g. Lab-01 (Network), Lab-02 (Cisco-Core), the Foundation, Academy. |
| **Charter** | The operating constitution — the rules everything answers to. | `00-Atlas-Foundation/Atlas-Charter.md`. |
| **POL-####** | **Policy** — a standing rule. | `POL-0001` (evidence), `POL-0002` (secrets→Vaultwarden), `POL-0008` (one source of truth). |
| **STD-####** | **Standard** — the concrete requirement a policy mandates. | password/auth, access control, encryption. |
| **ADR-####** | **Architecture Decision Record** — a point-in-time decision + rationale. | indexed in `Decisions/ADR-Index.md`. |
| **CM-#### / MC-####** | **Change Record / Major Change Record** — a tracked change to live state. | risk, backup, rollback, validation before applying. |
| **Build Guide / Build Record** | *How to build it* (target-state) / *what's actually running* (verified). | the Virtualization pack keeps them separate. |
| **Diagnostics.md / Troubleshooting.md** | Per-device *"is it built/connected right?"* (show/verify) / *"it broke, diagnose by symptom."* | `ADR-0032`. |
| **Provenance banner** | The `> **Lab-0x …**` line at the top of a doc marking which pack owns it. | — |
| **Evidence status / markers** | ✅ device-verified · 🟡 operator-reported / lab-unverified · ⏳ in build · 📋 planned. | `ADR-0032`; nothing is ✅ without a pasted read-back. |
| **Charter Rule 13 / 14 / 16 / 17** | 13 = the plan is the reference, note divergences · 14 = honest status lines · 16 = prove a removal by counting the old string to zero · 17 = the operator writes device config, the assistant writes docs. | recurring citations. |
| **Frozen** | A pack whose snapshot won't change; its still-live facts become pointers to the active owner. | Lab-01 (`ADR-0022`); see `ADR-0034`. |

## Identity & Windows (Tier-0)

| Term | Meaning | In Atlas |
|---|---|---|
| **AD / AD DS** | Active Directory / Domain Services. | domain `atlas.lab`. |
| **DC** | Domain Controller. | DC01 (PDCe), DC02 (replica). |
| **PDCe** | PDC Emulator — the FSMO role that is the authoritative time source. | DC01 (`ADR-0020`). |
| **FSMO** | Flexible Single Master Operations — 5 single-holder AD roles. | all on DC01 (single-domain). Concept W1. |
| **GC** | Global Catalog — forest-wide searchable partial replica. | DC01, DC02. |
| **DFSR / SYSVOL** | Distributed File System Replication / the replicated system volume that carries GPOs & scripts. | Concept W2. |
| **GPO** | Group Policy Object — centrally-applied config/policy. | Stage 7 baseline + waves. |
| **OU** | Organizational Unit — the AD container hierarchy. | `Devices`/`Employees` skeleton. |
| **AGDLP** | Account → Global → Domain-Local → Permission — the group-nesting model. | `G-Tier0/1/2-Admins`, `G-IT-Staff`. |
| **Tier 0 / 1 / 2** | The blast-radius admin model: identity control plane / servers / workstations. | `t0/t1/t2-seth`; Concept: Tiered-Admin-Model. |
| **PAW** | Privileged Access Workstation — the clean source Tier-0 admin is done from. | PAW01. |
| **LAPS** | Local Administrator Password Solution — rotates & stores local-admin passwords in AD. | 7c; also rotates DSRM. |
| **DSRM** | Directory Services Restore Mode — the DC's break-glass local mode/password. | rotated by LAPS (Concept W5). |
| **PSO** | Password Settings Object — fine-grained (per-group) password policy. | `PSO-FinanceHR` (min 15). |
| **SCT** | Security Compliance Toolkit — Microsoft's tested baseline GPOs. | Server 2025 v2602 baseline, 8 GPOs. Concept W3. |
| **VBS / CG** | Virtualization-Based Security / Credential Guard. | GPO Wave B (gated on hypervisor VBS). Concept W4. |
| **Protected Users** | AD group that hardens credential handling (no NTLM/caching). | on the admin accounts. |
| **KDS** | Key Distribution Service root key (enables gMSA / LAPS encryption). | created on DC01. |
| **NPS** | Network Policy Server — Windows RADIUS. | NPS01 (`ADR-0029`). |
| **DDNS** | Dynamic DNS — clients/DHCP registering records. | DHCP on DC01 uses a dedicated DDNS account, **not** DnsUpdateProxy (`ADR-0030`). |

## Networking

| Term | Meaning | In Atlas |
|---|---|---|
| **VLAN / 802.1Q** | Virtual LAN / the tag that marks a frame's VLAN. | `10.<vlan>.0.0`; native VLAN **999** (parking). |
| **VLSM** | Variable Length Subnet Masking — right-sized subnets. | `IP-Addressing-Plan-VLSM`. |
| **SVI** | Switched Virtual Interface — a switch's L3 VLAN interface. | SW01 `Vlan10 10.10.0.2`. |
| **Trunk / native VLAN / access port** | Carries many tagged VLANs / the one untagged VLAN on a trunk / a single-VLAN port. | native 999 everywhere. |
| **OSPF** | Open Shortest Path First — the routing protocol. | 1941 ⇄ MKT01 on the transit /30. |
| **`O E2` / redistribute** | An OSPF *external* (type-2) route / injecting non-OSPF routes into OSPF. | MKT01's VLANs are `O E2` via `redistribute=connected`. Concept N1. |
| **DAI** | Dynamic ARP Inspection — drops spoofed ARP on untrusted ports. | SW01; PVE01 trunk is trusted. Concept N2. |
| **DHCP snooping** | Switch filtering of rogue DHCP; builds the binding table DAI uses. | SW01. |
| **STP** | Spanning Tree Protocol — loop prevention. | — |
| **NAT** | Network Address Translation. | at FGT01 (north-south); **never** east-west on MKT01. |
| **East-west / north-south** | Traffic *between internal segments* / *in-and-out of the network*. | MKT01 = east-west firewall; FGT01 = north-south perimeter. |
| **Transit /30 · loopback** | A 2-host point-to-point routed link / a router's stable RID address. | `10.255.255.x/30`, `10.255.0.x/32`. |
| **SSH crypto: KEX / MAC / CTR / CBC** | Key exchange / message-auth / counter-mode & block-cipher-chaining cipher modes. | CTR-only, CBC/3DES removed; older ISRs stuck at SHA1 MAC. |
| **RouterOS: `bridge-trunk` / `bridge-vids` / `hw=no` / vlan-filtering** | MikroTik v7 bridge constructs — the VLAN member set / disabling hardware offload / the (unused-here) filtering model. | MKT01 & PVE01; the `hw=no` offload trap. Concept N3. |
| **iDRAC / LOM** | Integrated Dell Remote Access Controller / LAN-on-Motherboard (shared NIC). | PVE01 iDRAC is shared-LOM — **not** out-of-band. |

## PKI, security & platforms

| Term | Meaning | In Atlas |
|---|---|---|
| **AD CS** | Active Directory Certificate Services — Windows PKI. | `ADR-0027`; RCA01 + ICA01. |
| **CA / RCA / ICA** | Certificate Authority / Root CA / Issuing (subordinate) CA. | RCA01 (offline root), ICA01 (issuing). |
| **CRL / CDP / AIA** | Certificate Revocation List / CRL Distribution Point / Authority Information Access — where revocation & the CA cert are published. | HTTP `pki.atlas.lab` on SRV01; the `ADR-0009` gate. |
| **CSR / CN / SAN** | Certificate Signing Request / Common Name / Subject Alternative Name. | non-domain enrollment, AD-CS Part 3B. |
| **LDAP / LDAPS / Kerberos** | Directory protocol / over TLS (636) / the AD auth protocol (88). | FGT01 admin auth = direct LDAPS (`ADR-0028`). |
| **RADIUS (1812/1813) / PEAP / EAP-TLS** | Network-device AAA / cert-based RADIUS auth methods. | network devices → NPS01 (`ADR-0029`); PEAP needs the NPS server cert. |
| **ESC1–ESC8** | Known AD CS misconfiguration / abuse classes. | hardened in AD-CS guide §3.1. |
| **CIS / NIST / SCAP** | Center for Internet Security benchmarks / NIST control catalog / Security Content Automation Protocol. | `CIS-Hardening-*` docs. |
| **Break-glass** | The emergency local admin/console path kept when central auth is down. | every device keeps one (`fortigateadmin`, `ciscoadmin`, console). |
| **MFA / FortiToken** | Multi-factor auth / Fortinet's token. | FGT01 (deferred to Pass-2). |

## Virtualization & time

| Term | Meaning | In Atlas |
|---|---|---|
| **PVE / Proxmox VE** | The open-source hypervisor platform. | PVE01 (Dell R410). |
| **KVM / VT-x** | The Linux hypervisor / Intel hardware-virtualization CPU feature. | VT-x was BIOS-disabled by a dead CMOS battery. |
| **Golden image / template / sysprep / generalize / cloud-init** | A patched base VM / a clone source / Windows & Linux image-prep tools. | `TPL-WIN2025`, `TPL-UBUNTU2604`. |
| **VMID / vmbr / vNIC** | Proxmox VM id / virtual bridge / virtual NIC. | DC01 = VMID 101; mgmt on `vmbr0.10`. |
| **NTP / chrony / w32tm / DOMHIER** | Time sync / the Linux NTP client / the Windows time tool / "domain hierarchy" time source. | PDCe→external; members → DC (DOMHIER). `ADR-0020`. |

## Atlas devices (hostnames)

| Host | Role |
|---|---|
| **DC01 / DC02** | Domain Controllers — PDCe/DNS/forest root · replica/GC. |
| **RCA01 / ICA01** | AD CS offline root CA · enterprise issuing CA. |
| **NPS01** | Network Policy Server (RADIUS) for network-device admin auth. |
| **SRV01** | Linux services — nginx CRL host, Oxidized, rsyslog. |
| **NetBox / MON01 / Pi01** | IPAM/DCIM · monitoring · Pi-hole DNS + NTP. |
| **PAW01** | Tier-0 Privileged Access Workstation. |
| **PVE01** | Proxmox hypervisor (Dell R410). |
| **MKT01 / SW01 / 1941** | MikroTik east-west firewall+gateway · Cisco L2 switch · Cisco core router. |
| **FGT01** | FortiGate perimeter firewall. |
| **CA01-VAULT01** | 🔴 decommissioned (`ADR-0031`) — the old OpenSSL CA + Vaultwarden host; Vaultwarden survives standalone. |

## Related
- Root [`README.md`](README.md) (front door) · [`00-Atlas-Foundation/README.md`](00-Atlas-Foundation/README.md) (Foundation index) · [`Atlas-Academy/Concepts/README.md`](Atlas-Academy/Concepts/README.md) (the "why") · [`00-Atlas-Foundation/Decisions/ADR-Index.md`](00-Atlas-Foundation/Decisions/ADR-Index.md) (every ADR).

*Living doc — add a term when a reader would hit it without one.*
