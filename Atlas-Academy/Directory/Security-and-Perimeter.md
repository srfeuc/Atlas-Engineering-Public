---
Title: Security and Perimeter — Full Directory
Path: Atlas-Academy/Directory
Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §1. Every device, decision, and real firewall record, described.
Version: 0.1
Date: 2026-08-03
---

# Security and Perimeter — Full Directory

> **The deep version of [Source-of-Truth §1](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#1-security-and-perimeter).** The router gives you the one-glance answer; this page is the *encyclopedia* — every firewall and IPS in the estate, the segmentation model they enforce, the hardening baselines, the decisions that shaped them, and the **real, device-verified firewall records** the whole design is seeded from. Keep the router in a tab for speed; come here when you want the whole picture.
>
> Each device folder carries the standard page-set (`ADR-0037`): **README** (front door + Services map) · **Build-Guide** (target) · **Build-Record** (verified reality) · **Diagnostics / Troubleshooting** · **Considerations** · **Changes/** · **Automation/**.
>
> 🔒 **The real records here are frozen Lab-01 (`ADR-0022`) — history, not current guidance.** Where a Lab-01 doc disagrees with the live Lab-02 design, the live design wins (`POL-0001`). They are kept because they were made *at the machine*, so they show exactly how a firewall was actually built, broke, and got fixed. Read them for *how it really went*; reconcile to the current build.

## On this page

1. [The security devices](#1-the-security-devices) — perimeter · IPS · east-west · core
2. [The segmentation model](#2-the-segmentation-model) — the pattern, the allowed flows, the zones
3. [Hardening baselines (CIS)](#3-hardening-baselines-cis)
4. [Real firewall records (frozen Lab-01)](#4-real-firewall-records-frozen-lab-01) — the goldmine
5. [Commands — FortiOS, RouterOS, Cisco-IOS](#5-commands--fortios-routeros-cisco-ios)
6. [The decisions (ADRs)](#6-the-decisions-adrs)
7. [Templates, playbooks and the Academy](#7-templates-playbooks-and-the-academy)

---

## 1. The security devices

The estate defends in layers — a perimeter UTM at the edge, an inline IPS behind it, an east-west firewall inside the LAN, and the routed core they sit on. Each live Lab-02 device links to its real frozen-Lab-01 predecessor where one exists.

| Layer | Role | Live device (Lab-02) | Status | Real example (frozen Lab-01) |
|---|---|---|---|---|
| **Perimeter firewall** | North-south edge — egress, NAT, inbound-deny + FortiGuard UTM content inspection | [`FGT01-Perimeter-Firewall`](../../Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall/) | ✅ Pass-1 core verified (07-21); ⬜ UTM + TLS deep-inspect gated | [Lab-01 FGT01](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/) |
| **Inline IPS** | North-south intrusion *prevention* — transparent-bridge Suricata behind the UTM | [`PFSENSE01-IPS`](../../Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS/) | 📋 Proposed — design decided (`ADR-0038` v1.2), hardware not yet acquired | — |
| **East-west firewall** | Intra-LAN segmentation — every VLAN's gateway; routes *and* filters east-west | [`MKT01-East-West-Firewall`](../../Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall/) | ✅ Pass-1 + inter-VLAN + OSPF verified (07-22); 🟡 E-W policy permissive until Phase 7 | [Lab-01 MKT01](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/) — the richest firewall seam |
| **Routed core** | The north-south core between MKT01 and FGT01 — routes only, holds no VLANs, no east-west filtering | [`1941-Core-Router`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/) | ✅ Base + hardening + routing verified (07-22) | — |

> **The build markers are honest (`POL-0001`/`POL-0006`).** ✅ means a read-back proved it; 🟡 is authored-but-lab-unverified or permissive-by-design; ⬜/📋 is gated/planned. The default east-west stance is **DENY, logged** — MKT01 runs a *permissive* policy today on purpose, so NetFlow from MON01 (Phase 6) can show which flows are real before default-deny is cut over (Phase 7). Nothing here is "installed = done."

Adjacent security hosts live in their own domains: the SIEM and telemetry sinks ([`SIEM01-Wazuh`](../../Labs/Lab-02-Cisco-Core/Devices/SIEM01-Wazuh/) · [`MON01-Monitoring`](../../Labs/Lab-02-Cisco-Core/Devices/MON01-Monitoring/)) are in [§6 Monitoring](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#6-monitoring-and-logging); the offensive box [`KALI01`](../../Labs/Lab-02-Cisco-Core/Devices/KALI01/) and the tiered-identity / PKI trust anchors are in [Servers-and-Compute](./Servers-and-Compute.md) and [§2 Identity](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#2-identity-and-access).

## 2. The segmentation model

The devices *enforce*; these docs *own the design*.

- **The pattern** — [`Atlas-Firewall-Architecture`](../../00-Atlas-Foundation/Reference/Atlas-Firewall-Architecture.md) — the estate-wide teaching reference (Charter Rule 17): the north-south vs east-west distinction, the capability catalogue, the east-west design bar, and the reusable **firewall verification method** every device doc and the flows matrix cite as their method-of-record.
- **The allowed flows** — [`Atlas-East-West-Allowed-Flows-Matrix`](../../Labs/Lab-02-Cisco-Core/Architecture/Atlas-East-West-Allowed-Flows-Matrix.md) (v1.7) — the single source of truth for east-west policy that MKT01 renders as forward-chain rules. Default is **DENY between every zone pair**; the doc lists only the exceptions (23 numbered flows across 11 zones). Examples of what it governs: *user internet access* (Clients→Untrusted, 80/443/53); *the only thing that reaches Tier 0* (any tier → Identity, LDAPS/Kerberos/DNS); *the plant floor never initiates into corporate IT* (OT VLAN 90 → any zone: **🔴 DENY**).
- **The topology** — [`ADR-0023`](../../00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) — the 1941-core / MKT01-east-west split (Option B: MKT01 is every VLAN's gateway, so it can filter east-west inline).
- **The rules** — [`POL-0007` Hardening Baseline](../../00-Atlas-Foundation/Policies/POL-0007-Hardening-Baseline.md) · [`POL-0001` Audit](../../00-Atlas-Foundation/Policies/POL-0001-Atlas-Audit-Policy.md) (Security owns the audit — `ADR-0018` silos).

## 3. Hardening baselines (CIS)

Each network device carries a CIS-informed hardening baseline in [`Architecture/`](../../Labs/Lab-02-Cisco-Core/Architecture/); deliberate deviations are documented (`POL-0007`).

| Baseline | Covers | Status |
|---|---|---|
| [`CIS-Hardening-FGT01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-FGT01.md) | FortiGate perimeter — mgmt plane, named-admin LDAPS auth, UTM profiles, unused-port disable | Draft — priority checklist; several gaps open (LDAPS auth, UTM) |
| [`CIS-Hardening-MKT01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-MKT01.md) | MikroTik east-west firewall — services/mgmt plane, SNMP, unused interfaces, recovery | 🟢 Pass-1 verified (07-22); §4 firewall + telemetry open |
| [`CIS-Hardening-1941`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-1941.md) | Cisco 1941 core — SSH crypto ceilings + mitigations, secrets, mgmt | 🟢 Pass-1 verified (07-22) |
| [`CIS-Hardening-SW01`](../../Labs/Lab-02-Cisco-Core/Architecture/CIS-Hardening-SW01.md) | Catalyst 2960X access switch — SSH crypto, secrets→Type-9, NTP, VLAN1 down | 🟢 Pass-1 verified (07-22) |

> 🔧 **Before you harden, enumerate what's live** — the recurring trap is shutting a break-glass path you didn't know was up. Playbook: [Enumerate-Every-Enabled-Interface-Before-Hardening](../Playbooks/Enumerate-Every-Enabled-Interface-Before-Hardening.md) (the real FGT01 "five live undocumented ports" incident, `CM-0033`).

## 4. Real firewall records (frozen Lab-01)

**The goldmine.** Before MKT01 was re-roled as the Lab-02 east-west firewall, it carried a live 22-rule filter set that was tested, rule by rule, *at the machine*. The Lab-02 flows matrix is seeded directly from those rules. Each record below is a real, dated incident with the read-back that proved it — and each teaches a trap. 🔒 Frozen (`ADR-0022`); reconcile to the live design where noted.

**Per-rule firewall testing — the "which rule dropped the flow" seam**

- [`Firewall-Per-Rule-Verification-Tests`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Firewall-Per-Rule-Verification-Tests.md) — one concrete flow-level test per rule, built to prove the **deny** half, not just the permits. It captures a subtle real distinction: a VLAN host that can `ping` the router but can't SSH it is being refused by the *service ACL*, not the firewall —
  > *"rule 5 accepts VLAN-20 traffic to the router (so a `ping 10.20.0.1` succeeds and there's no `INPUT-DENIED` log). SSH is then refused a layer up, by the service address ACL: `/ip service` restricts SSH/WinBox/www-ssl to `10.0.0.0/24` and `10.10.0.0/24` only."*
- [`Firewall-Low-Level-Per-Rule-Isolation-Tests`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Firewall-Low-Level-Per-Rule-Isolation-Tests.md) — proves at packet level that *rule N specifically* acted (per-rule match counters, non-destructive `passthrough` mirrors, and disable-to-prove). The starkest demo —
  > *"`hping3 -S -p 443 -c 1 10.50.0.10` (Servers→Client, unpermitted) … Rule 20 counter; `EAST-WEST-DENIED:` log with the exact `src->dst`. … disable rule 20 → the same flow now passes (RouterOS default-accept) — the starkest proof of what rule 20 is holding back."*
  > 🔁 *Reconcile:* the "no safe way to disable a rule" caveat was a Lab-01 condition (MKT01 then had no serial console); the live design has a proven FTDI console break-glass (`CIS-Hardening-MKT01` §6), so that constraint is superseded.

**Change records — the real firewall changes**

- [`CM-0009` — Remove obsolete MKT01 RADIUS rules](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0009-Remove-Obsolete-MKT01-RADIUS-Rules.md) — the "prove a rule is dead before you remove it" record. Two forward-chain rules pointed at Pi01's *pre-VLAN* address on a path MKT01 was never in — dead for two independent reasons —
  > *"Removing them changed nothing, which is exactly what the analysis predicted and what nothing but execution could prove."*
  > Removal was by comment, not brittle index (`/ip firewall filter remove [find comment="…"]`); validated `/ip firewall filter print count-only` → **22**; the end-to-end RADIUS test still returned `Access-Accept`.
- [`CM-0006` — Disable MikroTik reverse proxy](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0006-Disable-MikroTik-Reverse-Proxy.md) — a `reverse-proxy` service found live on 443 with no source restriction and no cert bound; a doubt about whether it was even a real service object was checked against the live `/ip service print` and disproven —
  > *"`4  X  reverse-proxy  443  tcp  …  none  main` — `X` = disabled … it had exactly the empty `ADDRESS` and `CERTIFICATE: none` the record described, and it is disabled. Closed."*
- [`Troubleshooting`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Troubleshooting.md) — the device's real incident log (cert install, SAN mismatch, and the RADIUS "silently never consulted" trap):
  > *"`/user aaa` has its own separate `use-radius` setting that must explicitly be `yes` … No error was shown on the failed attempt; the only way to catch it was checking the actual live value afterward."*

> The estate-wide lesson these share (from [`016-Network-Lessons-Learned`](../../Labs/Lab-01-Mikrotik-Core/Operations/016-Network-Lessons-Learned.md), 62 KB): *a command that returns no error is not a confirmed change — read the state back.* The full change list for this device is in its [`Changes/`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/) folder.

## 5. Commands — FortiOS, RouterOS, Cisco-IOS

Verify/inspect + troubleshoot commands **for this lab and its target state**, grounded in the real devices:

- 🖥️ [FortiOS](../Command-Library/FortiOS.md) — `get`/`diagnose` for policy, UTM, and session state
- 🖥️ [RouterOS](../Command-Library/RouterOS.md) — `/ip firewall filter print stats`, `/ip service print`, `/interface print`
- 🖥️ [Cisco-IOS](../Command-Library/Cisco-IOS.md) — `show ip route`, `show ip ospf neighbor`, `show run | section`
- 🖥️ [Syslog-and-SNMP](../Command-Library/Syslog-and-SNMP.md) — reading the deny logs centrally once MON01 (Phase 6) is up

> 🔧 **Growing this:** more real `get`/`show`/`print` read-backs get captured **at the machine** as Lab-02's firewall is cut over to default-deny (backlog #36 harvest). For now these are the Lab-01-proven set plus the target-state additions.

## 6. The decisions (ADRs)

- [`ADR-0023`](../../00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) — the 1941-core / MKT01-east-west segmentation topology
- [`ADR-0047`](../../00-Atlas-Foundation/Decisions/ADR-0047-FGT01-FortiGuard-UTM.md) — FortiGuard UTM on FGT01 (reverses the earlier no-UTM decision)
- [`ADR-0050`](../../00-Atlas-Foundation/Decisions/ADR-0050-FGT01-TLS-Deep-Inspection-Scope-and-ICA01-Inspection-CA.md) — selective TLS deep-inspection scope + the ICA01 inspection CA
- [`ADR-0038`](../../00-Atlas-Foundation/Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md) — pfSense/Suricata inline IPS, north-south (defence-in-depth behind the UTM)
- [`ADR-0051`](../../00-Atlas-Foundation/Decisions/ADR-0051-DNS-Filtering-Ownership-Pi-hole-Not-FortiGuard.md) — DNS filtering is owned by Pi-hole; FortiGuard DNS filter off (single owner)
- [`ADR-0028`](../../00-Atlas-Foundation/Decisions/ADR-0028-FGT01-Admin-Auth-Direct-LDAPS.md) — FGT01 admin auth by direct LDAPS (the deliberate RADIUS exception)
- [`ADR-0009`](../../00-Atlas-Foundation/Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) — the incident-response + destroy-step lesson (trust boundary)
- [`ADR-0018`](../../00-Atlas-Foundation/Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) — the operating-model silos (Security owns audit + the flows matrix)

## 7. Templates, playbooks and the Academy

- 📋 **Templates** — [Change-Record](../../00-Atlas-Foundation/Templates/Change-Record-Template.md) · [Major-Change-Record](../../00-Atlas-Foundation/Templates/Major-Change-Record-Template.md) (for a firewall change) · [Build-Record](../../00-Atlas-Foundation/Templates/Build-Record-Template.md) · [Device-Verification-Procedure](../../00-Atlas-Foundation/Templates/Device-Verification-Procedure-Template.md)
- 🔧 **Playbooks** — [Trace-a-Blocked-Flow](../Playbooks/Trace-a-Blocked-Flow.md) · [MikroTik-EastWest-Inspect-and-Troubleshoot](../Playbooks/MikroTik-EastWest-Inspect-and-Troubleshoot.md) · [Prove-Exactly-Which-MikroTik-Rule-Acted](../Playbooks/Prove-Exactly-Which-MikroTik-Rule-Acted.md) · [Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched](../Playbooks/Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched.md) · [Enumerate-Every-Enabled-Interface-Before-Hardening](../Playbooks/Enumerate-Every-Enabled-Interface-Before-Hardening.md) · [Recover-a-Locked-Out-Router-Out-of-Band](../Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md)
- 🛡️ **When a secret leaks** — [Respond-to-a-Committed-Secret](../Playbooks/Respond-to-a-Committed-Secret.md) · [Rotate-a-Leaked-Key-Before-You-Back-It-Up](../Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md)
- 🎓 **Concepts + cert alignment** — [Identity-Aware vs Zone Firewall Policy](../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md) · the [Concepts index](../Concepts/) · the **[FortiGate FCP](../Certification/Atlas-FortiGate-FCP-Lab-Map.md)** + **[Security+ Domain-5](../Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md)** cert maps
- 🔩 **Per-device** — each device's own `Diagnostics.md` / `Troubleshooting.md`

## Related

[Source-of-Truth router §1](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#1-security-and-perimeter) (the quick view) · [§12 Security program & compliance](../../00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md#12-security-program-and-compliance) (IR · risk · privacy) · [Network and Addressing directory](./Network-and-Addressing.md) · [Servers and Compute directory](./Servers-and-Compute.md) · [`POL-0004`](../../00-Atlas-Foundation/Policies/POL-0004-Source-of-Truth.md) · [`POL-0007` Hardening](../../00-Atlas-Foundation/Policies/POL-0007-Hardening-Baseline.md).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-08-03. First cut — the exhaustive twin of Source-of-Truth §1: the layered security-device roster (perimeter FGT01 · inline IPS PFSENSE01 · east-west MKT01 · routed core 1941) with honest build status; the segmentation model (firewall architecture + the 23-flow allowed-flows matrix + topology); the four CIS hardening baselines; the **frozen Lab-01 MKT01 firewall goldmine** (per-rule verification + isolation tests, `CM-0009`/`CM-0006`, the RADIUS-silently-off trap) woven in with real read-backs; the FortiOS/RouterOS/Cisco-IOS command sets; the security ADRs; templates, playbooks + Academy. Built per the `Session-29` brief. |
