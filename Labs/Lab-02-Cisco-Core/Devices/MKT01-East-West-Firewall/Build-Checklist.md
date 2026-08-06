---
Title: MKT01 Build Checklist (East-West Segmentation Firewall)
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
Status: Target Design — build checklist. You write the config; read state back with `print detail`/`print stats` (016 lesson).
Version: 1.0
---

# MKT01 — Build Checklist (Internal East-West Segmentation Firewall)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`ADR-0023`):** the **internal** east‑west segmentation firewall **and** the L3 gateway for every VLAN. RouterOS **7.x** on the RB1100AHx4. Companion: `Cabling-and-Port-Map`, `IP-Addressing-Plan-VLSM`, `Atlas-East-West-Allowed-Flows-Matrix`, `CIS-Hardening-MKT01`.
>
> **Sources:** MikroTik [Securing your router](https://help.mikrotik.com/docs/spaces/ROS/pages/328353/Securing+your+router) (authoritative), and firewall concepts from the [MonoVM MikroTik firewall guide](https://monovm.com/blog/) (chains, connection-state, address-lists). ⚠️ **RouterOS v6→v7 syntax drifts — confirm your version** (`/system resource print`); the commands here are v7.
>
> 🔴 **Rule 13 / `016`:** read state back with **`print detail`** and **`print stats`**, never plain `print` — plain `print` hid a dynamic WinBox row that was misread as an open service. A tick needs the output (`POL-0001` R‑A1).

## 🔴 Three ways MKT01 is NOT a normal MikroTik edge router
Every MikroTik tutorial assumes the box is the internet edge doing NAT. Yours isn't. So:
1. 🔴 **NO NAT east‑west.** Generic guides say "hide the LAN behind one IP." MKT01 must **not** NAT inter‑VLAN traffic — you need real source IPs for policy and logs (`ADR-0023`, Firewall‑Arch §3.3). NAT stays at the edge (FGT01) only.
2. 🔴 **Be careful with `fasttrack`.** FastTrack bypasses the firewall for established connections — great for edge throughput, but on a **segmentation** firewall it means inter‑VLAN flows **skip your inspection and logging**. Don't fasttrack the flows you're trying to segment/see. (Fine for the router's own management traffic; not for the east‑west policy.)
3. 🔴 **The threat isn't "the internet" — it's lateral movement.** MKT01's `forward` chain **is** the east‑west policy (the allowed‑flows matrix); its `input` chain protects the management plane from the internal zones. There's no WAN here — the "north" side is the routed `/30` to the 1941.

## 🔴 Gate before you start
- [ ] **Serial console recovery tested** (FTDI cable, `ADR-0016`). MKT01 becomes the gateway for the whole interior — a bad forward‑chain rule with no console is a total lockout. **This gates the Phase‑7 default‑deny**, not the initial build.
- [ ] `/system resource print` — record the RouterOS version.

## Build steps

### 1. Base + service hardening (MikroTik "Securing your router")
- [ ] **Create a named admin, disable `admin`:** `/user add name=… group=full` + `/user disable admin`; 12+ char password (`POL-0002`).
- [ ] **Disable unused IP services:** `/ip service` → disable `telnet, ftp, www, api, api-ssl`; keep `ssh` (+ `winbox` if used) and **scope them to the Management subnet** (`set … address=10.10.0.0/27`).
- [ ] **`/ip ssh set strong-crypto=yes`.**
- [ ] **Disable MAC access off the mgmt path:** `/tool mac-server set allowed-interface-list=none` (or a mgmt-only list), `mac-server mac-winbox set allowed-interface-list=none`, `mac-server ping set enabled=no`. 🔴 If you keep a `mac-winbox` recovery path, set it **once** — `026` set `mac-winbox=RECOVERY` then `none` six lines later (last-write-wins destroyed it). Verify the live value.
- [ ] **Neighbor discovery to mgmt only:** `/ip neighbor discovery-settings set discover-interface-list=…` (not `all`).
- [ ] **Turn off what you don't use:** `/tool bandwidth-server`, `/ip proxy`, `/ip socks`, `/ip upnp`, `/ip cloud` (ddns), `/ip dns set allow-remote-requests=no` (Pi‑hole/AD do DNS, not MKT01). LCD PIN if applicable.

### 2. Interfaces, VLAN gateways, routing
- [ ] **Trunk to SW01** (`Cabling` link #4): a VLAN interface per subnet, each with its gateway `10.<vlan>.0.1` from `IP-Addressing-Plan-VLSM` (VLANs 10–90, incl. OT 90).
- [ ] **Routed `/30` uplink to the 1941** (`Cabling` link #3): `10.255.255.6/30` on the uplink `ether`.
- [ ] **Default route → the 1941** (`10.255.255.5`). *(Its default route now points at the 1941, not FGT01 — that's the re‑role.)*
- [ ] **Disable every unused `ether`/`sfp`** (`POL-0007`/`CM-0015` — `ether2` was found enabled and undocumented). Record any kept up.

### 3. Input chain (protect the router itself)
- [ ] Accept `connection-state=established,related,untracked`; **drop `invalid`**; accept scoped ICMP.
- [ ] **Allow management (SSH/Winbox) only from the Management zone** (`src-address=10.10.0.0/27`); **drop all other input to the router**.
- [ ] **Brute‑force / scan protection with address‑lists** (MonoVM pattern): `add-src-to-address-list` on scan/auth‑fail patterns → `drop src-address-list=…` with a timeout.

### 4. Forward chain (the EAST‑WEST policy)
- [ ] 🔴 **Bring‑up = PERMISSIVE.** During the network build (Master‑Build‑Order Phase 2), forward is open so you can get everything talking. **Write "TEMPORARY — tighten in Phase 7" on it** so it isn't forgotten.
- [ ] **Phase 7:** render `Atlas-East-West-Allowed-Flows-Matrix` as forward rules — **default‑deny + log**, service‑scoped, Tier‑0 and OT micro‑zones tightest. **No `fasttrack` on inspected east‑west flows** (see the box above).
- [ ] 🔴 **Confirm NO `masquerade`/`src-nat` on inter‑VLAN** (`/ip firewall nat print` should have nothing east‑west).

### 5. Services off MKT01, and the rest
- [ ] **RADIUS does NOT come back on MKT01** — it moves to SRV01/NPS (`ADR-0004`).
- [ ] **SNMPv3 → MON01** (never recreate the old v2c `homelab` community, `CM-0023`).
- [ ] **Syslog → MON01**; **NTP client** to the `ADR-0020` source.
- [ ] `/export file=…` + `/system backup save …` (`Device-Backup-Runbook`).

## Validation — read the state back
- [ ] `/ip service print detail` — only ssh/winbox enabled, scoped to mgmt (`print detail` shows `address=`; plain `print` hides it — `016`).
- [ ] `/ip address print` + `/ip route print` — every VLAN gateway present; default route via `10.255.255.5` (the 1941).
- [ ] `/ip firewall filter print stats` — count the rules, read each; input drops non‑mgmt; forward is permissive now / default‑deny after Phase 7.
- [ ] `/ip firewall nat print` — **empty for east‑west** (no inter‑VLAN NAT).
- [ ] `/tool mac-server print` + `/ip neighbor discovery-settings print` — scoped, not `all`.
- [ ] `/system ntp client print` + `/system clock print` — synced (the *status*, not the config).
- [ ] `/interface print` — unused interfaces disabled.
- [ ] From a host: gateway pings; inter‑VLAN reachability matches the matrix (reachability Game Day, Phase 7).

## Failure modes
- 🔴 **NAT applied east‑west** — every internal host looks like MKT01; logs and policy become useless.
- 🔴 **FastTrack on inspected flows** — inter‑VLAN traffic skips the firewall; your segmentation and logging silently miss it.
- 🔴 **Default‑deny at bring‑up with no console** — lockout of the box the whole interior depends on. Permissive first; console tested before Phase 7.
- 🔴 **Reading `print` not `print detail`** — the dynamic-row misread that produced a false "open service" (`016`).
- 🔴 **`mac-winbox` last‑write‑wins** — set the recovery value once; verify live (`026`).
- **Recreating the `homelab` SNMP community** — live cleartext secret (`CM-0023`).
- **v6 vs v7 syntax mismatch** — confirm the version; commands here are v7.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Build checklist for MKT01 as the Lab-02 internal east-west segmentation firewall + inter-VLAN gateway (`ADR-0023`), grounded in MikroTik's official "Securing your router" doc + MonoVM firewall concepts. Foregrounds the three ways MKT01 differs from a normal MikroTik edge (no east-west NAT, fasttrack undermines segmentation, threat is lateral not internet). Covers service hardening, VLAN gateways + routed uplink to the 1941, input-chain mgmt protection with address-list brute-force defense, the forward-chain east-west policy (permissive→default-deny from the matrix in Phase 7), RADIUS-leaves/SNMPv3/NTP, with `print detail`/`print stats` read-back and the `016`/`026`/`CM-0023` failure modes. Console-recovery gate (`ADR-0016`) before policy-critical. |
