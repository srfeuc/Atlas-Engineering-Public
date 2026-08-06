---
Title: Atlas Academy — Command Library (index)
Path: Atlas-Academy/Command-Library
Status: 🟢 LIVING master command library (`ADR-0032`). Platform-first deep pages (+ a tool-domain page for observability); cross-indexed by service and by failure-category. Per-device `Diagnostics.md` quick-refs link **up** here.
Version: 1.1
Date: 2026-08-01
---

# Atlas Academy — Command Library

<!-- provenance -->
> **Book 9 — Atlas Academy.** The **master verification command reference** (`ADR-0032`): *how to use each command to confirm a service, a link, or a device is healthy — and how to read the output.* The per-device `Diagnostics.md` pages are the fast 5–10-check quick-refs; **this is the deep set they link up into.** Concepts (the "why") live in `../Concepts/`; this is the "how do I check it."

> **The discipline that governs every command here (`POL-0001`):** a `[x]` needs the **command and its output**. Read the **runtime** view, never the config: PowerShell cmdlet / `show … status` (IOS) / `print detail`·`print stats` (RouterOS) / `get` not `show` (FortiOS) / `systemctl`·`ip -br` (Linux). Every page gives **healthy vs broken** so the output is interpretable, not guessed. **Never invent output** — mark 🟡 until a real read-back is pasted.

## Primary spine — by platform (deep pages)

| Platform | Devices | Read-back rule | Page |
|---|---|---|---|
| **PowerShell / Tier-0** | DC01, DC02, ICA01, NPS01, member servers | cmdlets + `certutil`/`dcdiag`/`repadmin`/`w32tm` | `PowerShell-Tier0.md` ✅ |
| **Cisco IOS** | SW01 (2960X), 1941 (ISR) | `show … status`, **not** `show run` (`POL-0001` R-A1) | `Cisco-IOS.md` ✅ |
| **RouterOS** | MKT01 (RB1100AHx4, v7.23.1) | `print detail` / `print stats`, **not** plain `print` (`016`) | `RouterOS.md` ✅ |
| **FortiOS** | FGT01 (60E, 7.4.5) | **`get`, not `show`** (`MC-0001`) | `FortiOS.md` ✅ |
| **Linux** | PVE01 (Proxmox/Debian); Pi01/SRV01/NetBox/MON01 (forthcoming) | `systemctl`/`ip -br`/`journalctl` | `Linux.md` 🟡 expanding |

## Secondary index — by service (which page/section)
| Service | Where to look |
|---|---|
| **SSH / management plane** | IOS §Mgmt · RouterOS §Mgmt · FortiOS §Admin · PowerShell §WinRM/PSRemoting · Linux §SSH |
| **NTP / time (`ADR-0020`)** | every platform §Time — expected: source = DC01 `10.20.0.2` (DOMHIER on the DCs) |
| **DNS** | PowerShell §DNS (AD-DNS) · Linux §DNS (Pi01 resolver) · every §Connectivity |
| **LDAP / LDAPS (636)** | PowerShell §AD + §PKI · FortiOS §Admin-auth (`ADR-0028`) |
| **RADIUS (1812/1813)** | PowerShell §NPS (NPS01) · IOS/RouterOS/FortiOS §Admin-auth (client side, `ADR-0029`) |
| **Routing / OSPF** | IOS §Routing · RouterOS §Routing · FortiOS §Routing |
| **VLAN / L2 / trunk** | IOS §Interfaces · RouterOS §VLAN · Linux §Bridge (PVE01) |
| **Firewall / east-west** | RouterOS §Firewall · FortiOS §Policy |
| **PKI / certificates (AD CS)** | PowerShell §PKI (`certutil`/`pkiview`) |
| **DHCP (DC01, `ADR-0030`)** | PowerShell §DHCP (forthcoming) |
| **Syslog / SNMP / observability (MON01, `#34`)** | **`Syslog-and-SNMP.md`** 📋 (collector: rsyslog + LibreNMS; senders/agents per platform) — the tool-domain page; senders also in IOS/RouterOS/FortiOS §Logging/§SNMP |

## Tertiary index — by failure category (start here when it's broken)
| "It's broken…" | Approach | Cross-refs |
|---|---|---|
| **No / partial connectivity** | Work **L1 → up**: link/speed → VLAN/ARP → gateway/route → firewall → service. | every platform §Connectivity; MKT01 E-W matrix |
| **A service is down** | Confirm the process is running + listening, then its dependency (DNS/time/cert). | each platform §Service-up |
| **Login / auth failure** | Which auth path? local break-glass vs AD (LDAPS/RADIUS) vs cert. Check the DC + the auth server. | PowerShell §AD/§NPS; FortiOS §Admin-auth |
| **Cyber-attack indicators** | Failed-logon spikes (4625/4771), new admin accounts, config drift, unexpected flows. | PowerShell §Logging; device `Troubleshooting.md` |
| **Name resolution** | Resolver reachable → zone/forwarder → record. | PowerShell §DNS; Linux §DNS |

## How each command entry is written
**Purpose** (what it confirms) → **Command** → **Healthy output** → **Broken looks like** → **Grounds / cross-ref** (the doc-claim it verifies + the device `Diagnostics.md`/`Concepts` link). Marker: ✅ device-verified · 🟡 lab-unverified · 📋 planned (`ADR-0032`).

## Related
- `../Concepts/README.md` (the "why it works" layer) · `../Atlas-Teaching-Patterns-and-House-Style.md`.
- Per-device quick-refs: `Devices/*/Diagnostics.md`, `DC-Domain-Controllers/Diagnostics-DC01.md`/`-DC02.md`, `RCA01-ICA01-ADCS/Diagnostics-ICA01.md`, `Virtualization/Build-Records/PVE01-Diagnostics.md`.
- `00-Atlas-Foundation/Decisions/ADR-0032` (this library's mandate) · `Operations/Device-Confirmation-Commands.md` (the standing cross-device confirmation index).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-08-01. **Seeded the observability tool-domain page `Syslog-and-SNMP.md`** (Backlog **#34**) — rsyslog + LibreNMS collector on MON01 + the per-platform senders/agents (IOS/RouterOS/FortiOS/Linux); a deliberate tool-domain page (observability spans platforms). Added the by-service row. 📋 method authored; read-backs land when MON01 (Phase 6) is built. Serves the two new Playbooks `Trace-It-in-the-Logs` + `Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device`. |
| 1.0 | 2026-07-28. Created (`ADR-0032`). Platform-first deep library (PowerShell-Tier0, Cisco-IOS, RouterOS, FortiOS full; Linux expanding) + the by-service and by-failure-category indexes. Establishes the per-entry format (purpose → command → healthy → broken → grounds) and the per-platform read-back discipline. |
