---
Title: SW01 Build Checklist (Access/Distribution Switch)
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch
Status: Target Design — build checklist. You write the config; read every state back (POL-0001 R-A1).
Version: 1.0
---

# SW01 — Build Checklist (L2 Access / Distribution Switch)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`ADR-0023`):** Layer‑2 access/distribution. Carries all VLANs to MKT01 on one trunk; **does not route** (MKT01 is the gateway). Companion: `Cabling-and-Port-Map.md`, `IP-Addressing-Plan-VLSM.md`, and the hardening pass `CIS-Hardening-*` (this is the *build*; harden after). **Authoritative hardening source:** CIS Cisco IOS Benchmark matched to this switch's IOS train — confirm your version with `show version` first, because commands and defaults differ across trains.
>
> 🔴 **Rule 17 / Rule 13:** the commands are yours to write; every `[x]` below needs the **read‑back output**, not the config line (`POL-0001` R‑A1). `show run` shows intent; the *status* command shows truth.

## Gate before you start
- [ ] Console access to SW01 (not dependent on the network).
- [ ] `show version` — record the IOS train, so you pull the right CIS benchmark and the right syntax.
- [ ] `IP-Addressing-Plan-VLSM.md` open (VLAN 10 = `10.10.0.0/27`, gateway `10.10.0.1` on MKT01).

## Build steps (what to configure, and why)

### 1. Base
- [ ] **Hostname `SW01`**, domain name `atlas.lab`, and a login banner.
- [ ] **Generate RSA keys and enable SSH v2; disable Telnet and the HTTP/HTTPS server.** *Why:* management must not be cleartext (CIS; `POL-0007`).
- [ ] **Named local admin + enable secret** (RADIUS/NPS comes later — `ADR-0004`); no shared/default creds (`POL-0002`).

### 2. VLANs
- [ ] **Create VLANs 10,20,30,40,50,60,70,80,90** with names matching the zones (Mgmt, Servers, Web, Mon, Clients, Deploy, Test, DMZ, OT).
- [ ] **Pick an unused VLAN (e.g. 999) as the trunk native VLAN** and as the "parking" VLAN for disabled ports. *Why:* never leave native = VLAN 1 (VLAN‑hopping surface).

### 3. The trunk to MKT01 (the one uplink that carries everything)
- [ ] **802.1Q trunk** on the port to MKT01 (`Cabling-and-Port-Map` link #4): `switchport mode trunk`, **allowed VLANs = 10–90 only** (prune the rest), **native VLAN 999**, nonegotiate (no DTP).
- [ ] **A second trunk to PVE01** (link #5) allowing only the VLANs PVE01's VMs use.

### 4. Access ports
- [ ] **Assign host ports to their VLAN** (Pi01 → 10, LabComputer → 10, etc.) as `switchport mode access`.
- [ ] **`spanning-tree portfast` + `bpduguard enable`** on access ports. *Why:* fast host bring‑up, and a switch plugged into an access port is shut instead of melting your topology.
- [ ] 🔴 **Disable every unused port:** `shutdown` + `switchport access vlan 999`. *Why:* `POL-0007` / `CM-0015` — an enabled, unassigned port is a finding. Record any port left up and why.

### 5. Management
- [ ] **SVI on VLAN 10** with SW01's mgmt IP (from the plan), and **`ip default-gateway 10.10.0.1`** (MKT01) — this is the *only* L3 on the switch. **Do NOT enable `ip routing`** (MKT01 routes, `ADR-0023`).
- [ ] **Scope management** to the Management zone (`access-class` on the vty lines).

### 6. L2 security controls
- [ ] **DHCP snooping** enabled globally + on the client VLANs; **trust the MKT01 trunk uplink**, untrust access ports, set a rate limit. *Why:* stops rogue DHCP.
- [ ] **Dynamic ARP Inspection (DAI)** on the same VLANs — 🔴 **built from the DHCP‑snooping bindings + a static ACL generated from NetBox**, not hand‑typed. *(This is the Pi01‑missing‑from‑`STATIC-HOSTS` defect; do it after NetBox, Master‑Build‑Order Phase 3.)*
- [ ] **BPDU guard** (done in §4), and consider **root guard** on the trunk if MKT01 shouldn't be root.

### 7. SPAN → IDS
- [ ] **`monitor session 1`** — source = the MKT01 trunk (link #4), destination = `Gi1/0/5` (the IDS host). *Why:* east‑west visibility for Suricata (Master‑Build‑Order Phase 6).

### 8. Time, logging, SNMP
- [ ] 🔴 **NTP client** to the `ADR-0020` source — this fixes `CM-0030` (SW01 has never had a working clock). **Verify with `show ntp status`, never `show run`** (this is the exact `045` false‑tick).
- [ ] **Syslog → MON01**; **SNMPv3** (auth+priv) → MON01. Do **not** configure the old v2c `homelab` community (`CM-0023`).

### 9. Save
- [ ] `copy running-config startup-config`, then export a copy (`Device-Backup-Runbook.md`).

## Validation — read the state back (not the config)
- [ ] `show vlan brief` — all nine VLANs present, ports in the right VLAN.
- [ ] `show interfaces trunk` — trunk up, native 999, allowed 10–90 only.
- [ ] `show ip dhcp snooping` — enabled, uplink trusted, access untrusted.
- [ ] `show ip arp inspection` — DAI active on the VLANs (after NetBox).
- [ ] `show monitor session 1` — source/dest correct; confirm the IDS host actually receives frames.
- [ ] 🔴 `show ntp status` — "Clock is synchronized", stratum sane. *(Not `show run`.)*
- [ ] `ping 10.10.0.1` — the switch reaches its gateway (MKT01).
- [ ] `show interfaces status` — count the `disabled` ports; matches your unused‑port list.

## Failure modes
- 🔴 **Native VLAN mismatch / native = VLAN 1** — VLAN hopping; set native to the unused 999 on both ends.
- 🔴 **DAI dropping a legitimate host** absent from the binding/ACL — the Pi01 mystery that survived three handoffs. Generate the ACL from NetBox; don't hand‑type.
- 🔴 **Ticking NTP from `show run`** — the config line pointed at a dead server for the switch's entire life. Only `show ntp status` proves sync.
- 🔴 **SPAN configured, IDS never plugged in** — telemetry you built and never used. Confirm frames arrive.
- **Enabling `ip routing`** — steals the gateway role from MKT01 and breaks the Option B segmentation model.
- **Telnet/HTTP left enabled** — cleartext management; a CIS fail.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Build checklist for SW01 as the Lab-02 L2 access/distribution switch (`ADR-0023`): base/SSH, VLANs 10–90, the MKT01 trunk (native 999, pruned), access ports (portfast+bpduguard, unused disabled), management SVI on VLAN 10 with no `ip routing`, DHCP snooping + DAI (NetBox‑generated), SPAN→IDS, NTP/syslog/SNMPv3, with read‑back validation and failure modes. Hardening companion: CIS Cisco IOS Benchmark (match the IOS train). |
