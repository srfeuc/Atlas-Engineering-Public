---
Title: MKT01 Flat-Network (bridgeLocal 10.0.0.0/24) Decommission — Test Plan
Path: Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router
Status: Target procedure — disable-to-prove test. You run it (Charter Rule 17); read state back off the device (POL-0001 R-A1). Rule indices below are point-in-time (Build-Record v2.9 / the per-rule doc) and MUST be reconciled to `/ip firewall filter print` before executing (Rule 13).
Version: 1.0
Date: 2026-07-20
---

# MKT01 Flat-Network Decommission — Test Plan

## The question this answers

*Which MKT01 firewall rules can be removed if the flat network is removed — and how do we prove it without locking ourselves out?*

The "flat network" is **`bridgeLocal` = the legacy `10.0.0.0/24`** management/recovery segment. It is one object, not a separate dead network. Lab-02 does **not** recreate it (`ADR-0013`); recovery moves to the **console break-glass** path (FTDI cable, `ADR-0016`). This plan is the pre-teardown test that (a) proves which rules only ever serve the flat net, and (b) removes them safely.

## Scope

- **In scope:** the `/ip firewall filter` rules that reference `bridgeLocal` / `10.0.0.0/24`, plus the **service ACL** that gates management by source subnet.
- **Adjacent (verify, but a separate teardown step):** the `bridgeLocal` interface/address, its DHCP server, and any `10.0.0.0/24` NAT — these are the *network* objects, removed as part of `ADR-0013` execution, not part of the firewall-rule test. Flagged below so they aren't missed.
- **Explicitly out:** FGT01's north-south `10.0.0.0/8` return route — a perimeter routing concern, not an MKT01 east-west rule. Do not touch it here.

## The candidate objects (from the docs — reconcile to live first)

| Object | What it is | Chain | Removable? | Why / gate |
|---|---|---|---|---|
| **Rule 4** | accept `bridgeLocal → router` | input | ⚠️ **Only after re-homing management** | This is your live SSH/WinBox path to the router. Low-level doc marks it 🔴 don't-disable. Removable once admin access is on the **Management VLAN (10.10.0.x)** and the console cable exists (`ADR-0016`). |
| **Rule 17** | `bridgeLocal → all VLANs` | forward | ✅ **Yes — clean** | Forward-chain, source `10.0.0.20` only. Low-level doc marks 🟢 safe to disable. |
| **Rule 18** | `bridgeLocal → internet` | forward | ✅ **Yes — clean** | Forward-chain, source `10.0.0.20` only. Low-level doc marks 🟢 safe to disable. |
| **Service ACL** | `/ip service address=` includes `10.0.0.0/24` **and** `10.10.0.0/24` | (not a filter rule) | ✅ drop the `10.0.0.0/24` entry | Keep `10.10.0.0/24` or you lock yourself out. Do this **after** confirming a 10.10.0.x seat works. |
| bridgeLocal interface / address | `10.0.0.1/24` on the bridge | — | `ADR-0013` teardown step | Verify absent post-decommission (`/ip address print`, `/interface bridge print`). |
| bridgeLocal DHCP / NAT | any DHCP server or `10.0.0.0/24` masquerade | — | `ADR-0013` teardown step | **Check live** — not visible in the per-rule summary; needs `/ip dhcp-server print` and `/ip firewall nat print`. |

> **Not a flat-network rule:** Rule 6 (drop home-LAN `172.31.4.0/22` → router via ether1). Leave it.

## Prerequisites / safety gates — do NOT start without these

- [ ] **Console break-glass ready** — the FTDI cable path (`ADR-0016`, now speced) present and **tested while healthy**. This is the net under the whole exercise.
- [ ] **A Management-VLAN seat works** — you can reach the router for admin from **10.10.0.x** (not just from `10.0.0.20`). Prove it before removing anything, because rule 4 and the service ACL are how you're connected.
- [ ] **Full backup + export first** — `/export file=pre-flatnet-decommission` and `/system backup save name=pre-flatnet`. A reversible test starts with a known-good snapshot.
- [ ] **Reconcile indices to live** — `/ip firewall filter print` and confirm the 22-rule set + which rules carry the bridgeLocal comments/log-prefixes. Indices shift; **address rules by comment/log-prefix, not by number.**

## Test procedure (disable-to-prove — never "remove and see")

Run every destructive step from a **Management (10.10.0.x)** seat, whose path to the router does not depend on the rule you're toggling.

**1 — Baseline.**
`/ip firewall filter print stats` — record `packets`/`bytes` counters for rules 4, 17, 18 (find them by comment, e.g. `[find comment~"bridgeLocal"]`).

**2 — Prove positive (they DO serve flat traffic).**
From `10.0.0.20`: `ping 10.0.0.1` (→ rule 4), `ping 10.20.0.x` (→ rule 17), `ping 1.1.1.1` (→ rule 18). Watch each counter increment. A rule you can't make count is a rule you don't understand — confirm it before you trust removing it.

**3 — Prove nothing else needs 17/18.**
With normal lab traffic running but **no flat host active**, re-read stats over a representative window. Rules 17/18 counters must stay **flat**. If either moves with no `10.0.0.x` source, something else depends on it — **stop and investigate** before removal.

**4 — Disable (reversible), not delete.**
`/ip firewall filter disable [find comment~"bridgeLocal → all VLANs"]` and the `→ internet` one (rules 17, 18). **Leave rule 4 enabled.** Then confirm from a 10.10.0.x seat that every legitimate flow still works — inter-VLAN (rules 9–19) and internet — and that only *flat-network* reachability is gone.

**5 — Negative test (the one that makes it a control).**
Source a packet from a `10.0.0.x` address (or toward one). Confirm it now falls to the **default deny** — rule 20 `EAST-WEST-DENIED:` (forward) / rule 21 `INPUT-DENIED:` (input) — and is **logged with a timestamp**, not silently accepted. `/log print where message~"DENIED"`. A retired network with a leftover permit is a hole with history.

**6 — Rule 4 + service ACL (only if re-homing management now).**
Only after Step (Prereq) proves the 10.10.0.x seat: `/ip service set [find] address=10.10.0.0/24` (drop `10.0.0.0/24`), reconnect on the Mgmt seat to confirm, then `disable` rule 4. If anything feels wrong, you still have the console cable.

**7 — Commit or revert.**
- Test-only: re-enable everything (`disable=no`), remove any test artifacts, re-read `print stats`, confirm you're back to the full clean rule set.
- Commit the decommission: `remove` rules 17/18 (and 4 if re-homed), record a Change Record (`CM-00xx`), and proceed to the network-object teardown (`ADR-0013`).

## Acceptance criteria (count to zero — don't eyeball)

- [ ] Legacy string check: exported ruleset `10.0.0.` count = **0** for the removed rules (Charter Rule 16 — prove removal by counting the old string to zero).
- [ ] A `10.0.0.x` packet is **denied + logged** (Step 5), not accepted.
- [ ] All legitimate inter-VLAN / internet flows still pass (rules 9–19 unaffected).
- [ ] Management still reachable — from the **Management VLAN** if rule 4 / the `10.0.0.0/24` service entry were removed.
- [ ] `/ip firewall filter print` count matches the expected post-removal total; no disabled leftovers, no test mirrors (`016`: a config left non-default is a defect waiting for the next person — here, you, mid-teardown).

## Rollback

Restore is immediate at any point: re-enable disabled rules, or `/import file=pre-flatnet-decommission` / restore the backup. The console cable covers the worst case (management path lost).

## Where to run it

1. **CHR sandbox first (recommended).** Stand up the current 22-rule set on a **MikroTik CHR** node in the GNS3 lab (see `Virtualization/Build-Guides/GNS3-Lab-Simulation-Build-Guide.md`) and rehearse this whole procedure with **zero lockout risk**. The free CHR tier runs the real `/ip firewall filter` engine.
2. **Live MKT01 second,** with the console cable as the safety net.

## Open dependency

Exact rule indices and any hidden flat-net dependency (a `10.0.0.0/24` masquerade, a DHCP server, address-list membership) need the live exports: `/ip firewall filter print`, `/ip firewall nat print`, `/ip address print`, `/interface bridge print`, `/ip dhcp-server print`, `/ip service print detail`. Capturing these also **closes audit item 5**.

## Related / closes

- `ADR-0013` — legacy bridgeLocal retirement (this is its pre-teardown proof).
- `ADR-0016` — console break-glass (the safety net this plan depends on).
- `ADR-0023` — gates MKT01's default-deny east-west role.
- `Firewall-Per-Rule-Verification-Tests.md` (rules 4/17/18 = the recovery-network rules) · `Firewall-Low-Level-Per-Rule-Isolation-Tests.md` (disable-safety classes; the input-chain don't-disable set) · `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` §6 (Lab-02 never recreates the flat net) · `Atlas-Firewall-Architecture.md` §6 · `POL-0005` (log this as a recovery-adjacent Game Day result).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First plan. Identifies rules 4/17/18 + the service ACL as the flat-network firewall objects; 17/18 clean-removable, 4 gated on re-homing management to the Mgmt VLAN + the console cable. Disable-to-prove procedure with prove-positive, negative-test, and count-to-zero acceptance. CHR-sandbox-first. Flags the live exports still needed (also closes audit item 5). |
