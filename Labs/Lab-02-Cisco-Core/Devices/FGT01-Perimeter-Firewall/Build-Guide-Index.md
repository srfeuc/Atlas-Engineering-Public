---
Title: FGT01 Build Guides — Index (tiered)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟡 LIVING index. Points to the per-domain guides; tracks which are runnable now vs blocked on a subscription.
Version: 0.3
Date: 2026-07-28
---

# FGT01 — Build Guides (tiered index)

**Role (`ADR-0023`):** north-south **perimeter** firewall — NAT, egress, inbound-deny. Its internal link faces the **1941** (`10.255.255.0/30`, FGT01 = `.1`). FortiOS **7.4.5**. These guides **execute** `Build-Checklist.md` and `CIS-Hardening-FGT01.md` (the design/why) — GUI-primary with CLI for the record, `get`-not-`show` read-backs (`MC-0001`).

## 🔴 Licensing reality (so you buy the right thing)
- **The GUI needs no licence** — it's built in. Don't buy "support" to get the GUI.
- **FortiCare** = firmware + support + RMA.
- **FortiGuard** subscriptions (bundles: **UTP** / ATP / Enterprise) = the *dynamic* services: **web/DNS filtering, antivirus, IPS, application control**. Web filtering needs a FortiGuard bundle, **not** bare support.
- ⇒ Networking + Hardening below need **neither**. Security-Profiles needs the **FortiGuard bundle** active.

## 🔴 Gate (before any guide)
- **Prove the break-glass FIRST** — console + the `192.168.1.99` / `internal3-7` recovery (`CM-0033`, `ADR-0016`). **Every** hardening step must preserve it; test it *after* the local-in policy. A mgmt lockout with no tested recovery is the top failure mode.
- Register with FortiCare; `get system status` (firmware level).

## The tiered set (build in this order)

| # | Guide | Scope | Needs FortiGuard? | Status |
|---|---|---|---|---|
| 1 | **`Build-Guide-1-Networking.md`** | interfaces (`wan1`, the 1941 /30), routing (default→wan1, static→interior), egress policy + NAT (broad per `ADR-0005`), traffic logging | No | 🟡 draft — build now |
| 2 | **`Build-Guide-2-Hardening.md`** | admin access (rename/ports/trusthost/local-in break-glass exempt), MFA, admin profiles, strong-crypto/TLS, SNMPv3/LDAPS, private-data-encryption key, encrypted backup, NTP, DoS policy, cli-audit-log, firmware | No | 🟡 draft — build now |
| 2b | **`Build-Guide-2b-AD-LDAPS-Admin.md`** | **Hardening Pass 2** — AD-backed named admin over **LDAPS** (`ADR-0028`): `G-Network-Admins` + least-priv `svc-fgt-ldap` bind, group→profile map, `fortigateadmin` break-glass kept | No (but needs the **DC LDAPS cert** — AD CS `ADR-0027`) | 🟡 authored — AD prereqs buildable now; FGT config gated on the DC cert |
| 3 | **`Build-Guide-3-Security-Profiles.md`** | web/DNS filter, AV, IPS, app control, SSL inspection — attach to the egress policy | **Yes (UTP)** | ⬜ not created — **after** the FortiGuard bundle. 🔴 Never attach a *stale* profile (`CM-0033` confidence trap) |

## Deferred / later (not in the initial set)
- Logging depth to MON01 / retention (Phase 6), VPN, HA/redundancy (also the trigger to tighten egress, `ADR-0005`).

## Operational guides (reference — not build steps)
Once FGT01 is built, its day-to-day operational docs (previously missing from this index):

| Guide | Use |
|---|---|
| **`Troubleshooting.md`** | symptom → root-cause → verified fix (real incidents on FGT01) |
| **`Logging-and-Flow-Tracing-Field-Guide.md`** | reading FortiGate logs + flow/session tracing (the diagnostics field guide) |

## Related
`Build-Checklist.md` · `CIS-Hardening-FGT01.md` · `Troubleshooting.md` · `Logging-and-Flow-Tracing-Field-Guide.md` · `Cabling-and-Port-Map.md` · `IP-Addressing-Plan-VLSM.md` · `Console-Recovery-Cable-and-Settings`-equivalent break-glass (`ADR-0016`/`CM-0033`) · `Master-Build-Order.md` (FGT01 in Phase 2).

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.3 | 2026-07-28 | **C5** — added an **Operational guides** section + Related links for the existing **`Troubleshooting.md`** and **`Logging-and-Flow-Tracing-Field-Guide.md`** (the index previously omitted both). No change to the tiered build set. |
| 0.2 | 2026-07-22 | Added **Guide 2b — AD-LDAPS admin auth** (Hardening Pass 2, `ADR-0028`) to the tiered set — the device side of "the FortiGate needs an AD account"; gated on the DC LDAPS cert (AD CS `ADR-0027`). |
| 0.1 | 2026-07-20 | Index created; tiered set defined (Networking + Hardening now, Security-Profiles after FortiGuard). Licensing clarified (GUI free; web filtering needs a FortiGuard/UTP bundle, not bare support). |
