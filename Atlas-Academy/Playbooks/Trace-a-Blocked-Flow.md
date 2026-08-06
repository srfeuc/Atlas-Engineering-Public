---
Title: Playbook — Trace a Blocked Flow (which enforcement point + rule is dropping it)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, device-unverified (`POL-0001`) — 🔧 **device-needed**: per-step counters/deny-logs are 🟡 until pasted from a device, and some enforcement points are **in-build** (FGT01 UTM gated `ADR-0047`; PFSENSE01 📋 not built). Current-design method (no single frozen incident); the deny-log discipline is anchored in the MKT01 firewall seam (`CM-0009`) + the silent-drop class (`CM-0022`/`016`). Searchable/ticket-ready per Backlog **#32**; format-aligned to the locked `ADR-0053` §5 mold.
Version: 2.0
Date: 2026-08-01
---

# Playbook — Trace a Blocked Flow

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: connectivity / enforcement — an **action-layer** page. **A connection isn't getting through — find *which enforcement point and which rule* is dropping it, and decide whether that block is correct.** A drop leaves **no error on the client** (`ERR`-nothing, just a timeout or a reset); the deny shows only where it happened — the enforcement point's **rule counter** and its **deny-log**. So the fast path is the logs: search the centralized syslog on MON01 and the deny line **names the device + the rule**. *(That a silent drop is invisible until you read the counter/log is the [`../Concepts/A-Completed-Command-Is-Not-Evidence.md`](../Concepts/A-Completed-Command-Is-Not-Evidence.md) discipline — read the enforcement evidence, not the client's silence.)*

**The one-line problem.** The host and service are up, but the packet doesn't arrive — and the client tells you nothing about *where* on the path it died.

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **the four enforcement points** (where a flow can die, in packet order).
3. **Why the client can't tell you** — the mechanism (a silent drop → read the counter/log).
4. **① Pin it down** — the flow, and is it even *supposed* to be allowed.
5. **The diagnosis path:**
   - 5.1 **Fast path — find the deny in the logs** (centralized syslog on MON01) → it names the device + rule.
   - 5.2 East-west — **MKT01** (counter + `EAST-WEST-DENIED`).
   - 5.3 Perimeter — **FGT01** (`diagnose debug flow` + the deny-log).
   - 5.4 Inline IPS — **PFSENSE01** (📋) · 5.5 Switch/L2 — **SW01** (ACL / DAI).
6. **The fix** (correct block vs misconfig) · **Prove it's fixed** · **If still broken**.
7. **Gap / what this closes** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type** (one per line)

- "*Request timed out*" / "*connection timed out*" reaching a service you know is up — no error saying *why*.
- "*connection refused*" / a TCP **reset** (a reject, not a silent drop — different rule action).
- "*No route to host*" — often an L2/gateway/DAI drop, not a firewall (steps 5.5 / `Diagnose-a-Host-Silently-Dropped-by-DAI.md`).
- 📋 (real read-back — pending the device): a MKT01 `/log` line prefixed **`EAST-WEST-DENIED`** / **`INPUT-DENIED`** naming src/dst.
- 📋 an IOS `%SEC-6-IPACCESSLOGP: list … denied` line for the flow.
- 📋 a FortiGate deny in `diagnose debug flow` / the traffic log naming the policy.

**Plain-language symptom phrases**

- "a connection is being blocked and I don't know where."
- "which firewall / rule is dropping this?"
- "it times out but the server is up — something in the path is silently dropping it."
- "is this supposed to be blocked, or is it a misconfig?"
- "trace the path and find the drop."

**Aliases / also-known-as**

- blocked flow · dropped packet · silent drop · which rule dropped it · deny-log · firewall trace · flow trace · policy lookup · east-west / north-south enforcement · ACL deny · IPS drop · allowed-flows matrix.

**Keywords line**

`/ip firewall filter print stats` · `EAST-WEST-DENIED` · `INPUT-DENIED` · `diagnose debug flow` · `%SEC-6-IPACCESSLOGP` · `show access-lists` · Suricata alert · MON01 syslog · flows matrix · `ADR-0023` · `CM-0009` · `#32`.

## Cert anchor

- **CCNA 5.0** (ACLs, security fundamentals) · **Security+** (segmentation, secure design) — primary.
- FortiGate **FCP** (policy + UTM), **CCNP Security** (zone/east-west policy). *(Grounding index: `../Atlas-Certification-Lab-Map.md` §5.)*

## Grounded in — the four Atlas enforcement points (trace in packet order)

A flow can be dropped in **four** places; know the order it meets them (`POL-0008` — the flows matrix + each device page own the rules; this page links):

| Order | Enforcement point | Device · platform | What it enforces | Deny signal |
|---|---|---|---|---|
| 1 | **Perimeter (N-S)** | **FGT01** · FortiOS 60E | egress/ingress policy + FortiGuard UTM (`ADR-0047`) + selective TLS inspect (`ADR-0050`) | flow-trace / traffic-log deny naming the policy |
| 2 | **Inline IPS (N-S transit)** | **PFSENSE01** · Suricata (`ADR-0038`) 📋 | signature drops on the FGT01↔1941 transit | a Suricata alert/block on the transit |
| 3 | **East-West** | **MKT01** · RouterOS | the inter-VLAN allowed-flows matrix | a `drop` counter climbing + `EAST-WEST-DENIED`/`INPUT-DENIED` log |
| 4 | **Switchport / L2** | **SW01** · Cisco IOS | VTY/port ACLs, port-security, DHCP-snooping/DAI | an ACL deny hit-count + `%SEC`/`%SW_DAI` log |

**Which one first?**

- Source & dest in the **same estate, different VLANs** → **east-west** → start at **MKT01 (5.2)**.
- One end is **outside** (internet / another site) → **perimeter** → **FGT01 (5.3)**, then **PFSENSE01 (5.4)**.
- Same VLAN / can't even ARP → **L2** → **SW01 (5.5)** / `Diagnose-a-Host-Silently-Dropped-by-DAI.md`.
- Always confirm the expected path against the topology (`ADR-0023`) + the flows matrix **before** touching a device.

## Why the client can't tell you (the mechanism)

A `drop` action discards the packet **silently** — the client sees only a timeout, with no ICMP and no log of its own. (A `reject` sends a reset, so you get "connection refused" — a useful tell that it's a *reject* rule, not a silent drop.) The evidence lives at the **enforcement point**, in two forms: the **rule counter** (which rule's `drop` is incrementing) and the **deny-log** (the line the rule writes when it drops, e.g. MKT01's `EAST-WEST-DENIED` prefix). **So you never diagnose a block from the client — you read the counter/log where it happened.** And if those logs are **centralized on MON01**, you read *one* place and it names the device + rule (5.1).

## ① Pin it down (capture these first — they're the ticket)

- a. **The flow** — `source IP → dest IP : port/proto`, plus the hostnames/roles behind the IPs.
- b. **Expected vs actual** — what *should* happen (per the flows matrix) vs what you see: **timeout** (silent drop) or **reset** (reject)? which direction fails?
- c. **Scope & timing** — one source or many? one service or all? when did it start, what still works?
- d. **Recent change** — a deploy, a rule edit, a reboot, a cert rotation?
- e. 🔴 **Is it even allowed?** — check the owner: `Architecture/Atlas-East-West-Allowed-Flows-Matrix` (E-W) or the FGT01 egress policy. **If it's *not* in the matrix, the block is correct** — this is a *policy-change request*, not a fault. Stop here.

## The diagnosis path

> Command-first; read the runtime (never `show run`), and the **evidence is the counter/log**, not the client. Commands link down to the Command-Library (`POL-0008`).

**5.1 Fast path — find the deny in the logs (start here if MON01 is up).**

- Search the **centralized syslog** for a deny naming this flow — it tells you the **device *and* the rule** in one place, before you log into anything:
  - `../Playbooks/Trace-It-in-the-Logs.md` (the how-to-find-it method) → filter by the src/dst IP + the time window.
  - What to grep for, per point: MKT01 **`EAST-WEST-DENIED`**/`INPUT-DENIED` · IOS **`%SEC-6-IPACCESSLOGP … denied`** · FortiGate **traffic-log deny** · Suricata **alert**.
  - Ref: `../Command-Library/Syslog-and-SNMP.md` (collector) + each platform §Logging.
  - Healthy: a deny line names the enforcement point + rule → jump straight to that point below and confirm. 📋 Broken/absent: no central logs yet (MON01 Phase 6 📋) or the rule doesn't log → walk the points in order.
- 🔴 **Clocks-first (`ADR-0020`):** correlate by timestamp only if the clocks agree (`Fix-the-SW01-Clock.md`).

**5.2 East-west — MKT01 (the counter + the deny prefix).**

```
/ip firewall filter print stats
/ip firewall connection print where dst-address~"<dst>"
```
- Ref: `../Command-Library/RouterOS.md` §Firewall.
- Healthy: the flow hits an **`accept`** rule (its counter climbs).
- 🔴 Broken: a **`drop`/`reject`** counter climbs on the deny — that rule is your answer; the matching `/log print where topics~"firewall"` line carries `EAST-WEST-DENIED`/`INPUT-DENIED`. 📸 the `print stats` with the incrementing counter. → deep-dive: `MikroTik-EastWest-Inspect-and-Troubleshoot.md`; lineage `CM-0009`.

**5.3 Perimeter — FGT01.**

```
diagnose debug flow trace start <n>   (then run the flow)   # use get/diagnose, NOT show (MC-0001)
```
- Ref: `../Command-Library/FortiOS.md` §Policy + `Devices/FGT01-Perimeter-Firewall/Logging-and-Flow-Tracing-Field-Guide.md`.
- Healthy: the trace shows the flow **matched an allow policy**, forwarded. 🔴 Broken: the trace names the **denying policy**, or a **UTM** verdict (IPS/AV/web-filter) — the deny also lands in the traffic log (5.1).

**5.4 Inline IPS — PFSENSE01 (📋 not built).**

- When: FGT01 says *allowed* but it still fails north-south → a Suricata signature drop on the transit.
- Ref: `pfSense-Inspect-and-Troubleshoot.md` (📋) + `ADR-0038`. Skip until PFSENSE01 exists.

**5.5 Switch / L2 — SW01.**

```
show access-lists            # hit counts on the denying ACE
show ip arp inspection statistics    # DAI drops (a silent L2 drop)
```
- Ref: `../Command-Library/Cisco-IOS.md` §Security.
- 🔴 Broken: an ACL deny hit-count climbs (logged `%SEC-6-IPACCESSLOGP`), or DAI is dropping ARP → `Diagnose-a-Host-Silently-Dropped-by-DAI.md`.

## The fix

Once you know **which rule** on **which device** dropped it:

- **If the block is correct** (the flow isn't allowed): no device change — raise a flows-matrix / policy change request, update the **owner** doc first (`POL-0008`), then the device.
- **If it's a misconfig:** change the **owning** policy at its source of truth (the flows matrix → the MKT01 rule; the FGT01 policy; the ACL), re-deploy, record it as a `CM-####`. Don't hand-edit a device whose config is rendered from an owner (`POL-0004`).

## Prove it's fixed

- a. Re-run the exact `Test-a-Connection.md` check that failed — same source, dest, port — it now completes.
- b. Re-read the rule counters: the **accept** increments now, not the deny; the deny-log stops naming this flow.
- c. 📸 the accept counter + the passing test. Mark ✅ only with the pasted read-back (`POL-0001`).

## If still broken

- Not a filter drop after all → work the Command-Library **"No / partial connectivity"** index (L1→up: link/ARP/gateway/route **before** firewall): `../Command-Library/README.md`.
- Timeout vs reset changed nothing → check the return path too (asymmetric routing / a one-way rule).
- The deny-log names a rule you didn't expect → a **shadowing** rule matched first (`MikroTik-EastWest-Inspect-and-Troubleshoot.md`).
- Also read the device's own `Troubleshooting.md`.

## Gap / what this closes (`#37`)

- **The gap:** without **centralized logging (MON01, Phase 6 📋)** you must log into each enforcement point in turn and read local counters — slow, and impossible to correlate across devices on skewed clocks. MON01's rsyslog closes it (5.1 becomes the fast path); **designed-only until built** (`POL-0001`). Two enforcement points are also **in-build**: PFSENSE01 (📋) and FGT01 UTM (`ADR-0047`) — until then a north-south trace can only cover the built points. Track in `Devices/MON01-Monitoring/` + the reconciliation map.

## Related

- **Command-Library (link down):** `../Command-Library/README.md` (the "start here when it's broken" index) · `RouterOS.md` §Firewall · `FortiOS.md` §Policy · `Cisco-IOS.md` §Security · **`Syslog-and-SNMP.md`** (the deny-log collector).
- **Concepts:** `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` (why a rule matches by subnet **or** user) · `../Concepts/A-Completed-Command-Is-Not-Evidence.md` (read the enforcement evidence, not the client's silence).
- **Sibling playbooks:** **`Trace-It-in-the-Logs.md`** (the syslog fast path — find the deny centrally) · `MikroTik-EastWest-Inspect-and-Troubleshoot.md` (the MKT01 deep-dive) · `Test-a-Connection.md` (the reachability check) · `Diagnose-a-Host-Silently-Dropped-by-DAI.md` (the L2 silent drop) · `Domain-Join-Fails.md` (a blocked path to the DCs).
- **Owners:** `Architecture/Atlas-East-West-Allowed-Flows-Matrix` (the E-W owner) · `Devices/{FGT01-Perimeter-Firewall,MKT01-East-West-Firewall,SW01-Access-Switch,PFSENSE01-IPS}/Troubleshooting.md`.
- **Checklist (reciprocal, `ADR-0053` §8):** `00-Atlas-Foundation/Templates/New-Windows-Server-Commissioning-Checklist-TEMPLATE.xlsx` — Phase 0 "VLAN/trunk ready" + Phase 5 "domain join" hand off here when a required path is silently dropped.
- **Backlog:** `#32` · `#34` (the MON01 logging this leans on) · `#27` (the Services map).

## Worked log

| Date | Who | Time | Flow (src→dst:port) | Enforcement point + rule | Correct block or misconfig? | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 2.0 | 2026-08-01 | **Format-aligned to the locked mold + the syslog diagnosis path** (Playbook Format-Alignment Audit, row 15; the syslog-paired page). Added **On this page**, the `#32` four-part **Symptoms & search terms** (one-error-per-bullet), the **explain-the-mechanism** note (a silent drop is invisible until you read the counter/log), and a new **5.1 fast path — find the deny in the centralized logs (MON01)** that names the device + rule in one place, cross-linked to `Trace-It-in-the-Logs.md` + `Command-Library/Syslog-and-SNMP.md`; foregrounded the per-point commands with the **deny-log signal** (`EAST-WEST-DENIED` · `%SEC-6-IPACCESSLOGP` · flow-trace) + Healthy/Broken; added the **Gap** note (centralized logging + in-build points) and the **Worked log**. 🔧 device-needed (counters/logs from a run; PFSENSE01/FGT UTM in-build). |
| 1.1 | 2026-07-31 | Reformatted for readability (operator) — one-idea-per-line sub-lists. No method change. |
| 1.0 | 2026-07-31 | Created (`ADR-0053`, first Playbook sample). The four-enforcement-point diagnosis path, problem-first, linking down to the Command-Library. 🟡 — method real, per-step read-backs pending; PFSENSE01 gated. |
