---
Title: FGT01 Build Checklist (Perimeter Firewall)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: Target Design — build checklist. You write the config; read state back with `get`, not `show` (MC-0001).
Version: 1.1
---

# FGT01 — Build Checklist (Perimeter / Edge Firewall)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`ADR-0023`):** north‑south perimeter firewall — NAT, egress, inbound deny. Its internal link now faces the **1941** (not MKT01). FortiOS **7.4.5**. Companion: `Cabling-and-Port-Map`, `IP-Addressing-Plan-VLSM`, `CIS-Hardening-FGT01` (this is build+harden combined).
>
> **Authoritative sources (grounded in these):** Fortinet [Hardening best practices](https://docs.fortinet.com/document/fortigate/7.4.0/best-practices/555436/hardening), the [FortiGate compliance checklist Technical Tip](https://community.fortinet.com/), and the [CIS FortiGate 7.4.x Benchmark](https://www.cisecurity.org/benchmark/fortinet). ⚠️ The best‑practices doc pasted is **8.0** — items marked **[7.6.1+]** don't apply to 7.4.5; confirm each against your build.
>
> 🔴 **Rule 13 / MC-0001:** read state back with **`get`, not `show`** (`set admin-server-cert` once ran clean and silently didn't take effect for hours). A tick needs the output (`POL-0001` R‑A1).

## 🔴 Gate before you touch anything
- [ ] **Prove the break‑glass path FIRST** — console access and the IP‑based recovery (`192.168.1.99`, `internal3-7`, `CM-0033`/`ADR-0016`). Every hardening step below must **preserve** it. A mgmt lockout with no tested recovery is the top failure mode.
- [ ] **Register with FortiCare** and check firmware/patch level (`get system status`).

## Build steps

### 1. Topology (the Lab-02 change)
- [ ] **`wan1`** → home router (NAT egress, existing).
- [ ] **`internal`** → the **1941** transit `/30` = `10.255.255.0/30`, FGT01 = `.1` (`IP-Addressing-Plan-VLSM`). Update the route/next‑hop from the old MKT01 link to the 1941.
- [ ] Static route (or OSPF) so the internal subnets (behind the 1941/MKT01) are reachable; default toward `wan1`.

### 2. Egress policy + NAT
- [ ] **Edge NAT on the egress policy** (`set nat enable`).
- [ ] 🔴 **Egress stays `srcaddr all` for now — `ADR-0005`.** The compliance checklist says "delete all default‑allow policies"; here that is **deferred by an accepted ADR** (no redundant path yet to test a tighter policy safely). Record it as deferred with the trigger (redundancy), not as an open finding. Tighten when a second path exists.

### 3. Administrator access (from the Hardening guide → *Administrator access*, *Non‑standard admin ports*)
- [ ] 🔴 **Admin-auth model (`ADR-0028`):** daily named admins authenticate by **direct LDAPS to the DC** — build them via **`Build-Guide-2b-AD-LDAPS-Admin.md`** (`G-Network-Admins` → scoped profile, least-priv `svc-fgt-ldap` bind), gated on the DC LDAPS cert (AD CS `ADR-0027`). FGT01 does **not** use RADIUS/RADSEC (that's the network devices → NPS, `ADR-0029`).
- [ ] **Rename the default `admin` account** → **`fortigateadmin`, kept as the sole *local* break-glass** (`ADR-0028`), and **change the default admin ports** to non‑standard (both are "known and targeted first").
- [ ] **`allowaccess`** interface‑level: management interface = `ping https ssh` only; 🔴 **nothing on `wan1`** (already confirmed correct — CIS 1.3). No HTTP, no Telnet.
- [ ] **`trusthost`** on each admin account scoped to the Management zone; and a **local‑in policy denying mgmt from anywhere except the authorised mgmt IP** — 🔴 **exempt the `192.168.1.99` break‑glass and console** so you can't lock yourself out.
- [ ] **MFA on every admin** (FortiToken/Duo) — *Administrator access*.
- [ ] **Role‑based admin profiles** beyond the single `super_admin` (the CIS 2.4 gap) — the LDAPS **group→profile** mapping is built in `Build-Guide-2b` (`ADR-0028`).

### 4. Encrypted protocols & strong ciphers (*Encrypted protocols*, *Strong ciphers*)
- [ ] **`strong-crypto enable`**, `ssl-static-key-ciphers disable`, raise `dh-params` (available on 7.4).
- [ ] **`ssl-min-proto-version TLSv1.2`** (or higher); disable SSLv3/DTLSv1.0.
- [ ] **SNMPv3** (not v2c — never the old `homelab` community), **LDAPS** (least‑privilege bind, not a Domain Admin — the admin-auth path, `ADR-0028`) and **NTP auth** where used. *(No **RADSEC** — FGT01 uses LDAPS, not RADIUS; network-device RADIUS lives on NPS01, `ADR-0029`.)*

### 5. Password / config storage (*Secure password storage*, *Configuration backup*)
- [ ] **`private-data-encryption enable`** — on **7.4.5 you set a manual 32‑hex key** (the auto‑generated random key is **[7.6.1+]**). 🔴 **Record the key offline** (`POL-0002`) — a config backed up with it can only restore to a FortiGate with the same key. Note the RMA implication.
- [ ] **Encrypted config backup after every change** (`execute backup config` with encryption) → `E:\` per `Device-Backup-Runbook`. Never share a full unredacted config (`POL-0002`).

### 6. UTM / security profiles (*FortiGuard databases* — with the Atlas reconciliation)
- [ ] 🔴 **Decide UTM explicitly.** The compliance tip says "enable IPS + AppControl on all policies." FGT01 has **no licence and stale signatures** (`CM-0033`). So: **either** licence it, apply IPS/AV/AppControl, and *verify the databases update* (`get system status` DB dates), **or** formally accept "no UTM" in an ADR. 🔴 **Never attach a stale profile** — a green UTM column over 2015 signatures is worse than none (the confidence trap).

### 7. Logging (*Logging and reporting*)
- [ ] **`config log setting → set logtraffic all`** — log every traversing flow, **especially denies**.
- [ ] **Forward to MON01** (syslog; no FortiAnalyzer in inventory). Clock synced first or timestamps are useless.

### 8. Time (*System time*)
- [ ] **NTP** to the `ADR-0020` source (authenticated if supported), correct timezone. Verify with `get system ntp`/status, not the config line.

### 9. DoS protection (*Denial of service*)
- [ ] Create a **DoS policy**, start anomalies in **monitor** mode to learn normal traffic, then enforce `tcp_syn_flood`, `tcp_port_scan`, `ip_src/dst_session`, tuning thresholds. Enable ASIC/NP offload if supported.

### 10. Firmware & operational hygiene (*Firmware*, *Day‑to‑day operations*)
- [ ] Firmware current and **in support** (not EOS); read release notes before upgrading.
- [ ] **`cli-audit-log enable`** for change control (verify it exists on 7.4.5).
- [ ] **USB auto‑install disabled** (`config system auto-install` — default disabled; confirm) — physical‑security control.

## Validation — read back with `get`
- [ ] `get system status` — firmware in support; UTM DB dates current *if* you licensed it (else confirm none attached).
- [ ] `get firewall policy` — count the rules, read each; confirm egress has `nat enable`; confirm **no interior‑facing default‑allow** beyond the deliberate `ADR-0005` egress.
- [ ] `diagnose sys session list` — a flow appears when generated, ages out when stopped.
- [ ] 🔴 **Break‑glass still works** — reach `192.168.1.99`/console *after* the local‑in policy is applied.
- [ ] `get system global` — `strong-crypto enable`, `cli-audit-log enable`.
- [ ] A denied flow shows in the log **on MON01** with a correct timestamp.

## Failure modes
- 🔴 **Local‑in mgmt‑deny severs the break‑glass** — the #1 self‑inflicted lockout. Exempt `192.168.1.99`/console, and test it before you trust it.
- 🔴 **Narrowing egress with no redundancy** (`ADR-0005`) — a bad policy change locks the lab out with no failover. Don't, until there's a second path.
- 🔴 **Attaching stale UTM** — the confidence trap; licence+verify or accept‑none.
- 🔴 **Losing the `private-data-encryption` key** — the encrypted backup can never be restored.
- 🔴 **Ticking from `show`/`config` not `get`** — MC-0001: `admin-server-cert` was silently unbound for hours.
- **Assuming an 8.0 command exists on 7.4.5** — verify the version‑gated items.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-28. **C5 reconciliation to `ADR-0028`.** §3 now leads with the **direct-LDAPS admin-auth model** (named admins via `Build-Guide-2b`, `fortigateadmin` the sole local break-glass) instead of implying a local named account; §4 **struck the `RADSEC` leftover** (FGT01 uses LDAPS, not RADIUS — network-device RADIUS is on NPS01, `ADR-0029`). No config/device changes. |
| 1.0 | 2026-07-17. Build + harden checklist for FGT01 as the Lab-02 perimeter firewall (`ADR-0023`), grounded in the Fortinet Hardening best-practices guide + the compliance Technical Tip + CIS FortiGate 7.4.x, with the FortiOS 8.0→7.4.5 version reconciliation. Reconciles the generic compliance guidance with Atlas's argued decisions: egress stays broad (deferred by `ADR-0005`), UTM is a licence-or-accept decision not a stale-profile attach (`CM-0033`), and every mgmt-hardening step preserves the `192.168.1.99`/console break-glass (`ADR-0016`). Read-back with `get` (MC-0001). |
