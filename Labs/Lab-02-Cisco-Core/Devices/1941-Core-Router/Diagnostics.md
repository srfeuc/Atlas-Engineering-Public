---
Title: 1941 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: 🟡 Seeded (ADR-0032). 1941 = core router (Cisco 1941 ISR G2, IOS 15.x); no SVI — reached via loopback `10.255.0.1` / transit /30s. Pass-1 device-verified 07-22.
Version: 0.2
Date: 2026-07-28
---

# 1941 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: **1941** — Role: core router (two routed /30s + loopback, OSPF with MKT01, default → FGT01; **no VLANs**). Reached over loopback `10.255.0.1` or transit `10.255.255.2`(FGT)/`10.255.255.5`(MKT).

> **What this is ([`ADR-0032`](../../../../00-Atlas-Foundation/Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md)):** quick "is 1941 built/connected right?" checks. Break-fix → `Troubleshooting.md`; deep set → the **[Atlas Academy Command-Library (Cisco-IOS)](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md)**. 🔴 Evidence = runtime `show` status (`POL-0001` R-A1). 🔴 Legacy-crypto: a modern SSH client needs the `~/.ssh/config` legacy-algo flags (see `CIS-Hardening-1941`). **Markers:** ✅ · 🟡 · ⏳ · 📋.

> 🎓 **Fleshed out in the Academy.** Each command's *healthy-vs-broken* examples live in the estate reference [`Command-Library · Cisco-IOS`](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) (grouped by service); the read-back discipline behind every ✅ is the concept [*A Completed Command Is Not Evidence*](../../../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) (a green prompt is not a confirmed change — `POL-0001`). The per-section pointers below link the matching **Command-Library group** *and* a **Playbook that shows the situation live**.

## 1. Installation / role verification
*› **Academy** — commands fleshed out → [Command-Library §Mgmt — SSH/management plane](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) (healthy-vs-broken) · situation → Playbook [Recover-a-Locked-Out-Router-Out-of-Band](../../../../Atlas-Academy/Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md)*

| Check | Command | Expected (healthy) | Verified? | Grounds |
|---|---|---|---|---|
| SSHv2 + CTR ciphers | `show ip ssh` | v2.0; CTR ciphers; DH min 2048 | ✅ (07-22) | `CIS-Hardening-1941` §1 |
| Named admin, Type-9 secrets | `show run \| i username` | `ciscoadmin` priv 15, `secret 9` | ✅ (07-22) | CIS §2 |
| vty scoped | `show run \| i access-class` | `MGMT-SSH` on vty 0-4 and 5-15 | ✅ (07-22) | CIS §1 |

## 2. Identity & addressing
*› **Academy** — fleshed out → [Command-Library §Time — NTP](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [§Interfaces](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · situation → Playbook [Fix-the-SW01-Clock](../../../../Atlas-Academy/Playbooks/Fix-the-SW01-Clock.md) (the stuck-clock scenario — same `show ntp` reads, `CM-0030`)*

| Check | Command | Expected | Verified? | Grounds |
|---|---|---|---|---|
| Interfaces / IPs | `show ip interface brief` | transit `.2`/`.5`, loopback `10.255.0.1`, up/up | 🟡 | `IP-Addressing-Plan-VLSM` |
| Time synced | `show ntp status` / `show ntp associations` | `synchronized`, `*~10.20.0.2` (DC01), stratum 3 | ✅ converging (07-22) | [`ADR-0020`](../../../../00-Atlas-Foundation/Decisions/ADR-0020-NTP-Time-Source-Architecture.md) (`CM-0030`) |

## 3. Service-up checks
*› **Academy** — fleshed out → [Command-Library §Routing — L3/OSPF](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) (the `O E2` learn-vs-originate read-back) · situation → Playbook [Trace-a-Blocked-Flow](../../../../Atlas-Academy/Playbooks/Trace-a-Blocked-Flow.md); prove a change stuck → [Confirm-a-Config-Change-Actually-Took](../../../../Atlas-Academy/Playbooks/Confirm-a-Config-Change-Actually-Took.md)*

| Service | Command | Expected | Verified? |
|---|---|---|---|
| OSPF process | `show ip protocols` | OSPF up; transit networks only | 🟡 |
| Default route out | `show ip route 0.0.0.0` | default → FGT01 `10.255.255.1` | 🟡 |
| No cleartext mgmt | `show run \| i http\|telnet` | no http/telnet | ✅ (07-22) |

## 4. Inter-device link checks (reciprocal)
*› **Academy** — fleshed out → [Command-Library §Routing](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [§Connectivity](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · situation → Playbook [Test-a-Connection](../../../../Atlas-Academy/Playbooks/Test-a-Connection.md)*

| Link | From 1941 | From the OTHER device | Expected | Verified? |
|---|---|---|---|---|
| ↔ MKT01 (OSPF) | `show ip ospf neighbor` | `/routing ospf neighbor print` on MKT01 | Full both ways; MKT01 VLANs as `O E2` here | ✅ (07-21) |
| ↔ FGT01 (transit /30) | `ping 10.255.255.1` | ping `10.255.255.2` from FGT01 | reachable both ways | ✅ |
| → DC01 (NTP) | `ping 10.20.0.2` | — | replies | 🟡 |

## 5. DNS tests
| Test | Command | Expected | Verified? |
|---|---|---|---|
| Resolver reachable | `ping 10.20.0.2` | replies | 🟡 |

## 6. IP / connectivity entry points
*› **Academy** — fleshed out → [Command-Library §Connectivity (work L1→up)](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · situation → Playbooks [Test-a-Connection](../../../../Atlas-Academy/Playbooks/Test-a-Connection.md) · [Trace-a-Blocked-Flow](../../../../Atlas-Academy/Playbooks/Trace-a-Blocked-Flow.md)*

| Layer | Command | Tells you | Verified? |
|---|---|---|---|
| L1/L2 link | `show interfaces GigabitEthernet0/0` | link/duplex/errors | 🟡 |
| L3 routing table | `show ip route` | connected /30s + `O E2` VLANs + default | 🟡 |
| OSPF detail | `show ip ospf neighbor` | 1 neighbor (MKT01) Full | ✅ |

## 7. Logging & event sources
*› **Academy** — fleshed out → [Command-Library §Logging](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · situation → Playbook [Trace-It-in-the-Logs](../../../../Atlas-Academy/Playbooks/Trace-It-in-the-Logs.md)*

| Source | How to view | Look for | Verified? |
|---|---|---|---|
| Local buffer | `show logging` | interface/OSPF flaps | 🟡 |
| Ships to MON01? | (Phase 6) | syslog once MON01 exists | 📋 |

## If you built or changed 1941 solo (ADR-0032)
Paste the `show` status read-backs (SSH/NTP/OSPF/routes) → flip 🟡→✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync. *(the read-back-proves-it situation → Playbook [Confirm-a-Config-Change-Actually-Took](../../../../Atlas-Academy/Playbooks/Confirm-a-Config-Change-Actually-Took.md).)*

## Related
- [`Troubleshooting.md`](Troubleshooting.md) · [`CIS-Hardening-1941`](../../Architecture/CIS-Hardening-1941.md) · [`Build-Guide.md`](Build-Guide.md) · **Atlas Academy:** [`Command-Library/Cisco-IOS`](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) · [`Concepts/`](../../../../Atlas-Academy/Concepts/README.md) (no dedicated *OSPF learn-vs-originate* concept yet — index) · `ADR-0023`.

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-08-04. **#43 Pass B** — **rich Academy up-links:** a top callout to the [`Command-Library/Cisco-IOS`](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md) reference + the read-back concept [`A-Completed-Command-Is-Not-Evidence`](../../../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md); per-section pointers linking each check-group to its matching Command-Library service group **and** a situation Playbook (Recover-a-Locked-Out-Router · Fix-the-SW01-Clock · Trace-a-Blocked-Flow · Test-a-Connection · Trace-It-in-the-Logs · Confirm-a-Config-Change-Actually-Took); Concepts index noted (no OSPF learn-vs-originate concept yet). No content change to the checks themselves. |
| 0.1 | 2026-07-28. Seeded (`ADR-0032`). ✅ marks Pass-1 device-verified facts (07-22: SSH crypto/vty/secrets, no cleartext, NTP; 07-21: OSPF Full, FGT transit ping); interfaces, routing table, default route left 🟡. Legacy-SSH client-config note carried from CIS. |
