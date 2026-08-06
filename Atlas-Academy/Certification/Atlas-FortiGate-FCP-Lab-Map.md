---
Title: Atlas FortiGate FCP Lab Map — FCP_FGT_AD-7.6 (FortiGate 7.6 Administrator, checkable study plan)
Path: Atlas-Academy/Certification
Status: 🟢 LIVING — the FortiGate certification study plan (register G5: formal FCP/NSE target). Objective rows are **checkable** ([ ] → [x]) as each is proven on FGT01 (`POL-0001`). The Content-Inspection domain (§3) is governed by **`ADR-0047`** (FortiGuard UTM — reverses `ADR-0035`, reshapes `ADR-0038`); it unlocks as the subscription lands.
Version: 1.1
Date: 2026-07-29
Scope: Global
---

# Atlas FortiGate FCP Lab Map — FCP_FGT_AD-7.6

<!-- provenance -->
> **What this is.** The FortiGate counterpart to the CCNA/CCNP maps: every **FCP — FortiGate 7.6 Administrator** (`FCP_FGT_AD-7.6`) objective mapped to the Atlas lab that teaches it, with a **checkbox to tick when you've proven it on FGT01.** Under Charter Rule 16 — the lab + objective + verification; **you** type the config. Objectives from Fortinet's exam description + the FortiGate 7.6 Administrator curriculum — **validate against the live blueprint before you sit** (Sources).

> 🎯 **Two operator priorities baked in:** (1) *"I am bad at reading logs for firewalls"* → the **Logging & Diagnostics** block (§6) is called out as a **primary focus area** — practise it across FGT01 **and** MKT01 **and** pfSense. (2) *"willing to buy the firmware upgrade / FortiGuard UTM"* → the **Content Inspection** domain (§3) is **unlocked by the FortiGuard UTM subscription** you're buying; that purchase **reverses `ADR-0035`** (no-UTM) and **reshapes `ADR-0038`** — now recorded in **✅ `ADR-0047`** (accepted in principle 2026-07-29; §3 goes live once the subscription lands + the profiles DB-verify, `POL-0001`).

## 0. Status key

🟢 **do now** (FGT01 exists, no licence needed) · 🟡 **needs a build/dependency** (a cert, an AD/FSSO integration, a 2nd device) · 🛡️ **needs FortiGuard UTM** (the paid subscription — live web/AV/IPS/app-control signatures; **decided in `ADR-0047`**, unlocks as the subscription lands) · ⚪ **theory / topology Atlas lacks** (a 2nd FortiGate for HA, a 2nd WAN uplink for SD-WAN).

## 1. Deployment & system configuration

- [ ] **Initial setup** (interfaces · DNS · admin access · FortiGuard connectivity · firmware) — FGT01 ✅ 🟢
- [ ] **NAT-mode deployment in the topology** (zones · interfaces · VLANs) — FGT01 = the N-S edge (`ADR-0023`) ✅ 🟢
- [ ] **Administrator accounts + profiles** (admin-profile scoping · trusted hosts) — FGT01 🟢 · **admin auth via direct LDAPS** to AD (`ADR-0028`) 🟡 *(gated on the DC LDAPS cert)*
- [ ] **Security Fabric** (root FortiGate · fabric connectors · FortiAP/FortiAnalyzer) — FGT01 + FortiAP 🟢 · FortiAnalyzer/full fabric 🟡
- [ ] **High Availability (FGCP cluster)** — needs a **2nd FortiGate** ⚪ *(concept only; Atlas has one FGT)*

## 2. Firewall policies & authentication

- [ ] **Firewall policies** (policy types · policy lookup · order/consolidation) — FGT01 policy set ✅ 🟢
- [ ] **NAT** (SNAT / central SNAT · DNAT / VIP · PAT) — FGT01 PAT-to-internet ✅; **add a VIP/DNAT** 🟢
- [ ] **Firewall authentication** (local · LDAP · RADIUS · captive portal) — **LDAP → DC** 🟡 · **RADIUS → NPS01** 🟡
- [ ] **FSSO** (Fortinet Single Sign-On to AD) — needs the DC + FSSO collector agent 🟡
- [ ] **Identity-/device-based policies** — 🟢 / 🟡

## 3. Content inspection (security profiles) — *the FortiGuard-UTM domain*

> Most of this domain needs **live FortiGuard signatures** (🛡️) — now decided in **`ADR-0047`** (subscription being purchased; §3 goes from theory to labs as it lands). The **pfSense inline IPS** (`ADR-0038`, reshaped by `ADR-0047`) is the *free, complementary* IPS on the N-S transit and the **free-vs-licensed comparison** — do **not** confuse it with FortiGate's licensed IPS; the FCP grades the **FortiGate** one. Trust a profile only once `get system status` shows current DBs (`POL-0001`).

- [ ] **Certificate operations + SSL/TLS deep inspection** (cert deployment · inspection modes) — FGT01 + a CA cert from **ICA01** 🟡
- [ ] **Web filtering** (FortiGuard categories · overrides) — 🛡️ FortiGuard UTM
- [ ] **Application control** — 🛡️ FortiGuard UTM
- [ ] **Antivirus** (flow/proxy inspection) — 🛡️ FortiGuard UTM
- [ ] **IPS (intrusion prevention)** (signatures · sensors) — 🛡️ FortiGuard UTM
- [ ] **DNS filter / anti-spam** — 🛡️ FortiGuard UTM

## 4. Routing

- [ ] **Static + policy routes · ECMP** — FGT01 ✅ 🟢
- [ ] **Dynamic routing on FortiOS** (OSPF · BGP) — **OSPF FGT01↔MKT01 now** 🟢 · BGP 🟡
- [ ] **SD-WAN** (members · performance SLA · rules) — needs a **2nd WAN uplink** ⚪ / 🟡
- [ ] **Reverse-path-forwarding + route-lookup troubleshooting** — FGT01 🟢

## 5. VPN (IPsec)

- [ ] **IPsec site-to-site** — FGT01 ✅; the **Azure S2S** later (`AZ-104`/H4) 🟢 / 🔵
- [ ] **IPsec dial-up / remote-access** — 🟡
- [ ] **SSL-VPN → ZTNA note** — FortiOS **7.6 deprecates SSL-VPN** on many models in favour of **ZTNA**; learn ZTNA as the modern remote-access path 🟡 / ⚪
- [ ] **VPN monitoring & troubleshooting** (phase-1/2 · tunnel status) — FGT01 🟢

## 6. Logging & diagnostics — 🎯 PRIMARY FOCUS (operator: "bad at reading firewall logs")

Deliberately its own block because it's the stated weak spot. Practise the *same skill* on all three firewalls so the concept sticks across syntax:

- [ ] **Log types + settings** (traffic · event · security · disk vs FortiAnalyzer vs syslog) — FGT01 → **syslog to MON01** 🟢 / 🟡
- [ ] **Reading the traffic log** — trace one allowed and one denied session end-to-end; correlate to the policy ID 🟢
- [ ] **`diagnose debug flow`** — the single most useful FortiGate troubleshooting tool; watch a packet get allowed/denied live 🟢
- [ ] **Session table** (`diagnose sys session list`) + the **packet sniffer** (`diagnose sniffer packet`) 🟢
- [ ] **Cross-device log reading** — do the same on **MKT01** (RouterOS log/torch) and **pfSense** (IPS/firewall log) so "reading firewall logs" becomes device-agnostic 🟢
- [ ] **Feed logs to the estate SIEM** — FGT01 + MKT01 + pfSense → MON01 / Wazuh; read them *there* too 🟡

## 7. Start now (before the UTM licence lands)
1. **Trace a session through the traffic log + `diagnose debug flow`** — the focus-area rep; needs no licence.
2. **Add a VIP/DNAT** (publish an internal service) — Firewall/NAT domain, free.
3. **OSPF FGT01↔MKT01** — Routing domain, shared with the CCNA/CCNP maps.
4. **Wire FGT01 admin auth to AD LDAPS** once the DC cert exists (`ADR-0028`) — Authentication domain.
5. **Ship FGT01 logs to MON01** and read them there — the focus area, estate-wide.

## 8. Honest gaps (what Atlas can't fully give)
- **HA (FGCP)** — one FortiGate only; concept/CLI via docs, not a real failover.
- **SD-WAN** — one WAN uplink; needs a 2nd (a cheap secondary/LTE) to be real.
- **The whole content-inspection domain** is **licence-gated** — the FortiGuard UTM purchase is what turns §3 from theory into labs (decided in `ADR-0047`; live once the subscription lands + profiles DB-verify).
- **NSE progression:** FCP FortiGate is the associate-professional anchor; the estate's E-W/segmentation (`Atlas-Firewall-Architecture`) + multi-VDOM MSP-sim feed the higher NSE/solution-specialist tracks later.

## Related
- `Atlas-Certification-Lab-Map.md` (CCNA) · `Atlas-CCNP-Lab-Map.md` · `AZ-800-801-Windows-Server-Hybrid-Lab-Map.md` · `Atlas-Firewall-Architecture.md` (N-S/E-W — the FortiGate's role) · **`ADR-0047`** (FGT FortiGuard UTM — governs §3; reverses `ADR-0035`, reshapes `ADR-0038`) · `ADR-0035` (FGT no-UTM — **reversed** by `ADR-0047`) · `ADR-0038` (pfSense inline IPS — the free/complementary IPS + comparison) · `ADR-0028` (FGT admin LDAPS) · `ADR-0044` (enterprise model, certs anchor) · register **G5** (formal FCP/NSE target).
- **Sources (validate against current):** Fortinet certification (FCP FortiGate) — https://www.fortinet.com/support/training-and-certification/certification-program/fcp-certification · FCP_FGT_AD-7.6 exam description — search Fortinet Training Institute for the current exam blueprint.

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-29 | **§3 Content-Inspection domain now governed by `ADR-0047`** (FortiGuard UTM — reverses `ADR-0035`, reshapes `ADR-0038`). Resolved every "pending FortiGuard-UTM ADR" pointer (Status line, operator-priorities note, §3 intro, status key, honest-gaps, Related) to the accepted `ADR-0047`; the 🛡️ rows unlock as the subscription lands + profiles DB-verify (`POL-0001`). No objective rows ticked (nothing device-proven yet). |
| 1.0 | 2026-07-29 | Created — the FortiGate counterpart to the CCNA/CCNP maps (register G5). `FCP_FGT_AD-7.6` objectives (Deployment · Policies/Auth · Content Inspection · Routing · VPN) → Atlas lab (FGT01/MKT01/pfSense/FortiAP) + status + a **[ ] checkbox**. Status key adds **🛡️ FortiGuard-UTM-gated** (the paid sub being purchased → the pending FortiGuard-UTM ADR that reverses `ADR-0035`/reshapes `ADR-0038`). **Logging & Diagnostics broken out as the operator's PRIMARY focus** ("bad at reading firewall logs") + practised across all three firewalls. |
