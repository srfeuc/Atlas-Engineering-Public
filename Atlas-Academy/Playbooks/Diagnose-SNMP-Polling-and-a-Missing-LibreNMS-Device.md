---
Title: Playbook — Diagnose SNMP Polling (and why a device is missing from LibreNMS)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, device-unverified — **📋 the read-backs land when MON01 is built (Phase 6)**. Grounded in **MON01 / LibreNMS** (SNMPv3 poller `10.40.0.20`) + the device SNMP agents (SW01/FGT01/MKT01/hosts). Command-first, searchable/ticket-ready per Backlog **#32**; the observability slice of Backlog **#34** (`ADR-0053` §5).
Version: 0.1
Date: 2026-08-01
---

# Playbook — Diagnose SNMP Polling (and a Missing LibreNMS Device)

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: SNMP / monitoring health — an **action-layer** page. **A device isn't in LibreNMS, or its data is stale/red — is SNMP polling healthy, and if not, where does it break?** Walk the chain **device up → SNMP answering → LibreNMS polling → data fresh**, identify which link is broken, and fix it at that link. *(Distinguishing "device down" from "SNMP down but device up" is the read-the-actual-state discipline of [`../Concepts/A-Completed-Command-Is-Not-Evidence.md`](../Concepts/A-Completed-Command-Is-Not-Evidence.md).)*

**The one-line problem.** LibreNMS shows a device **missing, down, or stale** — but "down in LibreNMS" can mean the device is fine and only **SNMP** (or the **poller**) is broken. Find the real break.

> 📋 **Seeded (Backlog #34) — MON01 is not built yet (Phase 6).** The *method* (the poll chain + the snmpwalk ladder) is complete; the **read-backs** (LibreNMS `validate.php`, poller-debug, per-device polls) land 🟡→✅ once MON01/LibreNMS + the SNMPv3 agents are stood up (`POL-0001`).

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **the why → down ≠ SNMP-down**.
3. **How SNMP polling works here** — the chain, and where each link breaks.
4. **① Pin it down** — which symptom (missing / down / stale) + the device's SNMPv3 identity.
5. **How to find & identify the break — the ladder** (the core):
   - 5.1 Is the **device up** at all? (`ping`)
   - 5.2 Is the **SNMP agent answering**? (`snmpwalk` from MON01)
   - 5.3 Is **LibreNMS polling** it? (`validate.php` · debug-poll · last-polled)
   - 5.4 Why is it **missing** (never added / added wrong)?
6. **The fix — where it's documented** · **If still broken**.
7. **Gap / what this closes** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type** (one per line)

- "*why is a device not in LibreNMS?*" — the add/discovery question (step 5.4).
- "*is SNMP polling healthy?*" — the poll-chain health check (steps 5.1–5.3).
- 📋 (real read-back — pending MON01): `snmpwalk` → `Timeout: No Response from <device>` (161 blocked / agent off).
- 📋 `snmpwalk` → `Authentication failure (incorrect password, community or key)` (SNMPv3 creds/context wrong).
- 📋 LibreNMS `./validate.php` → a failed check (poller not running / behind).
- "*the device is up but shows down/red in LibreNMS*" — SNMP-down, not device-down (step 5.1–5.2).

**Plain-language symptom phrases**

- "a device isn't showing up in LibreNMS" · "how do I add a device to monitoring."
- "the graphs are flatlined / stale / 'last polled' is old."
- "LibreNMS says it's down but I can ping it."
- "is SNMP even turned on / reachable on this device?"

**Aliases / also-known-as**

- SNMP polling · SNMPv3 · LibreNMS device missing · not discovered · stale RRD · poller stalled · snmpwalk timeout · authPriv · sysDescr · UDP/161 · device-down-vs-SNMP-down.

**Keywords line**

`MON01` · `LibreNMS 10.40.0.20` · `snmpwalk -v3 -l authPriv` · `sysDescr.0` · `./validate.php` · `./poller.php -h <device> -d` · `./addhost.php` · `udp/161` · SNMPv3 user/auth/priv · last-polled · `#34` · the SW01-`.52` mistarget bug.

## Cert anchor

- **CCNA 4.0** (SNMP — versions, communities/v3, `snmp-server`) — primary.
- **CySA+** (monitoring / detection health). *(Grounding index: `../Atlas-Certification-Lab-Map.md`.)*

## How SNMP polling works here (the chain)

MON01/LibreNMS **polls out** (`udp/161`, SNMPv3 authPriv) to each device every interval and stores metrics + the LLDP map. Four links, each a distinct break:

1. **Device up** — reachable at all (L3). Broken → it's a connectivity problem, not SNMP.
2. **SNMP agent answering** — the device runs an SNMP agent, permits MON01 on `161`, and the **v3 creds match**. Broken → device is fine, monitoring is blind.
3. **LibreNMS polling** — the device is *added* and the **poller runs on schedule**. Broken → the agent answers a manual walk but the graphs are stale.
4. **Data fresh** — the RRD/metrics update within the interval. Broken → stale "last polled".

> 🔴 **One-directional (`ADR-0036`):** MON01 initiates; the device never sessions back. So the fix is always *let MON01 reach in* (ACL/agent), never the reverse.

## ① Pin it down (capture these first — they're the ticket)

- a. **Which symptom** — the device is **missing** (never listed) vs **down/red** (listed, not answering) vs **stale** (listed, old data)? Each starts at a different rung.
- b. **The device** — hostname, IP (VLAN), and its **SNMPv3 identity** (user, auth/priv protocols) as configured on both sides.
- c. **Reachability** — can MON01 (`10.40.0.20`) even reach the device's mgmt IP on `udp/161` (ACLs, VLAN)?
- d. **Recent change** — a rebuild, an ACL edit, a creds rotation, a re-IP (e.g. the **SW01 SNMP-mistarget** — polled at the wrong `.52`).

## How to find & identify the break — the ladder (cheapest first)

> Command-first; run from MON01. Commands link down to `../Command-Library/Syslog-and-SNMP.md` (`POL-0008`).

**5.1 Is the device up at all?**

- `ping <device-mgmt-ip>`
- Healthy: replies → go to 5.2 (the problem is SNMP/poller, not the device). 📋 Broken: no reply → it's connectivity — `Test-a-Connection.md` / `Trace-a-Blocked-Flow.md`, not this page.

**5.2 Is the SNMP agent answering? (the key discriminator)**

- `snmpwalk -v3 -l authPriv -u <user> -a SHA -A '<auth>' -x AES -X '<priv>' <device> sysDescr.0`
- Healthy: returns the device's `sysDescr` string → the agent is fine; the break is LibreNMS-side (5.3).
- 📋 Broken:
  - `Timeout: No Response` → agent off, or `udp/161` blocked from MON01 (ACL) → fix at the **agent** (`../Command-Library/Syslog-and-SNMP.md` §SNMP-agents).
  - `Authentication failure` / `authorizationError` → the **SNMPv3 user/auth/priv/context** don't match between LibreNMS and the device → reconcile the creds.
- → this rung is the whole "up but shows down" answer: **device pings, SNMP times out** = monitoring-blind, device healthy.

**5.3 Is LibreNMS polling it?**

- `cd /opt/librenms && ./validate.php` — the self-check (poller running, DB, perms).
- `./poller.php -h <device> -d` — debug-poll this one device: watch it walk the OIDs, or see the exact timeout/auth error.
- The device's **"last polled"** in the UI vs the interval (default 5 min).
- Healthy: `validate.php` green, debug-poll completes, last-polled recent. 📋 Broken: poller stalled/behind (scheduler/cron down) → the agent answers a manual walk but graphs are stale → fix the poller, not the device.

**5.4 Why is it missing (never added, or added wrong)?**

- Not added → add it: `./addhost.php <device> ...` (SNMPv3), or Settings → Add Device (it runs discovery).
- Added at the **wrong target** → the SW01-`.52` mistarget class: LibreNMS points at an IP the device no longer owns → correct the host IP.
- Added but discovery found nothing → SNMP wasn't answering at add-time (fix 5.2 first, then re-discover).

## The fix — where it's documented (point down, don't re-derive)

- **Agent / sender enablement + the per-platform commands:** `../Command-Library/Syslog-and-SNMP.md` (§SNMP-agents, §SNMP-poller).
- **The build (collector):** `Devices/MON01-Monitoring/Roles/LibreNMS/` (Build-Checklist/Guide) + `Devices/MON01-Monitoring/Diagnostics.md`.
- **The known estate bug:** the **SW01 SNMP-mistarget** (`.52`) is tracked in `Devices/MON01-Monitoring/Considerations.md` — a real seed for this page's first ✅ once MON01 is up.
- 📋 Until MON01 Phase 6 exists there is nothing to poll *from*; this is the discipline, ready to run at build time.

## If still broken

- `snmpwalk` works but LibreNMS still red → poller not running or the device's poller-group is wrong (5.3).
- Auth failure only from LibreNMS, not from a manual walk → LibreNMS stored different v3 creds than you're testing with → re-enter them.
- Device answers `sysDescr` but no interfaces/graphs → the SNMP **view/ACL** on the device exposes only part of the MIB tree → widen the view.
- It polls but the LLDP neighbour is missing → LLDP/SNMP not enabled on the *other* device (a two-sided requirement).

## Gap / what this closes (`#34` · `#37`)

- **The gap:** with MON01 unbuilt (Phase 6) there is **no metrics/topology visibility** — no "is it up, what is it doing, is it in the map." LibreNMS (SNMPv3 → auto-LLDP) closes it; **📋 designed-only until Phase 6** (`POL-0001`). A **known open defect** is already logged — the **SW01 SNMP-mistarget** (`.52`) — this Playbook is exactly the procedure to confirm and clear it once MON01 polls. One-directional polling (`ADR-0036`) is the security property to preserve while fixing (open MON01→device `161`, never the reverse). Track in `Devices/MON01-Monitoring/`.

## Related

- **Command-Library (link down):** `../Command-Library/Syslog-and-SNMP.md` (poller + agent commands) · per-platform §SNMP in `Cisco-IOS.md` / `RouterOS.md` / `FortiOS.md` / `Linux.md`.
- **Sibling playbooks:** `Trace-It-in-the-Logs.md` (the syslog twin) · `Test-a-Connection.md` (the 5.1 reachability rung) · `Confirm-a-Config-Change-Actually-Took.md` (confirm the agent config took).
- **Owner:** `Devices/MON01-Monitoring/` (`Roles/LibreNMS` · `Considerations.md` — the SW01-`.52` bug) · Backlog **#34** (observability) + **#27** (Services map — the SNMPv3/161 flow) · `ADR-0032` · `ADR-0036` (one-directional).
- Cert-aligned: **CCNA 4.0** (SNMP) · **CySA+** (monitoring health).

## Worked log

| Date | Who | Time | Device | Symptom (missing/down/stale) | Break found (rung) | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-08-01 | **Seeded (Backlog #34 — SNMP as a first-class troubleshooting tool).** The SNMP-polling health ladder + the missing-LibreNMS-device method, command-first: device-up → SNMP-answering (`snmpwalk`) → LibreNMS-polling (`validate.php`/debug-poll/last-polled) → why-missing (`addhost`/mistarget). The key discriminator — device pings but SNMP times out = monitoring-blind, device healthy. Grounded in MON01/LibreNMS + the per-platform agents + the real SW01-`.52` mistarget seed. **Method authored now; read-backs 📋 until MON01 Phase 6** (`POL-0001`). Command-first mold (`ADR-0053` §5); links down to `Command-Library/Syslog-and-SNMP.md`. Cert: CCNA 4.0 · CySA+. |
