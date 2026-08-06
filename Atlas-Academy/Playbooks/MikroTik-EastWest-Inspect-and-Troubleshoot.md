---
Title: Playbook — MikroTik East-West: Inspect the Firewall & Find Which Rule Dropped a Flow
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on MKT01. Grounded in the real frozen **Lab-01** MKT01 firewall seam (the per-rule verification/isolation test docs + `CM-0009` + `016`), current-design-reconciled to the Lab-02 E-W firewall (`ADR-0022`/`ADR-0023`). Searchable/ticket-ready per Backlog **#32**.
Version: 1.0
Date: 2026-07-31
---

# Playbook — MikroTik East-West: Inspect the Firewall & Find Which Rule Dropped a Flow

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: per-appliance / blocked-flow. **A flow across MKT01 (inter-VLAN, or to the router itself) isn't getting through — which firewall rule caught it, and is that block correct?** This is the MikroTik-deep companion to `Trace-a-Blocked-Flow.md` (the cross-platform enforcement-point tracer): here you open MKT01's rule set, read the **counters** and **deny-log prefixes**, and name the exact rule — while ruling out the two traps that *look* like a firewall drop but aren't (the L2 offload trap and the service ACL).

**Why MKT01 firewall issues are their own playbook (Backlog `#32`).** MKT01 was the Lab-01 core router and is now the Lab-02 **east-west segmentation firewall** — a default-deny box whose whole job is to block things, so "why is this blocked?" is the most common question you'll ask it. Its rules match on **interface** (`in=vlanX out=vlanY`), it's **first-match-wins**, the **accept** rules don't log, and two catch-all drops (`EAST-WEST-DENIED` in forward, `INPUT-DENIED` in input) are the only thing standing between segmentation and RouterOS's default-ACCEPT. Reading it correctly means reading the *counter*, not guessing.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- `EAST-WEST-DENIED:` in the log (a forward/inter-VLAN drop — rule 20).
- `INPUT-DENIED:` in the log (a drop of traffic *to the router* — rule 21).
- `DROPPED:` in the log (an invalid/out-of-state or rate-limit drop — rules 1/3/6/8).
- `nc: connect ... Connection timed out` / `Test-NetConnection ... TcpTestSucceeded : False` for an inter-VLAN service.
- 🟡 (real read-backs land on-device): `/ip firewall filter print stats` shows a **drop** counter climbing for your flow.

**Plain-language symptom phrases**

- "the MikroTik is blocking my traffic — which rule?"
- "one VLAN can't reach another and I think the firewall is dropping it."
- "inter-VLAN traffic isn't passing / east-west is blocked."
- "SSH to the router works from mgmt but not from another VLAN" (that's the service ACL, not the firewall — see step 4).
- "the VLAN gateways are up but hosts get nothing" (that's the `hw=no` offload trap, not the firewall — see step 1).
- "which firewall rule matched this connection?"
- "is this block correct or a misconfig?"

**Aliases / also-known-as**

- MikroTik east-west firewall · RouterOS `/ip firewall filter` · inter-VLAN segmentation drop · first-match-wins · catch-all deny · default-deny router.
- `print stats` counters · reset-counters · connection tracking · `/ip firewall connection` · `/tool torch` · `/tool sniffer` · deny log prefix.
- service ACL vs firewall drop · `/ip service address=` · the `hw=no` offload trap (RTL8367) · shadowed rule.

**Keywords line**

`MKT01` · RouterOS 7.23.1 · RB1100AHx4 · `/ip firewall filter print stats` · `reset-counters` · `EAST-WEST-DENIED` · `INPUT-DENIED` · `DROPPED` · first-match-wins · `in-interface` · `out-interface` · rule 20 · rule 21 · `/ip service print detail` · `hw=no` · `/ip firewall connection print` · `/tool torch` · E-W flows matrix · `CM-0009` · `016`.

## On this page (jump to what you need)

1. [**① Pin it down**](#-pin-it-down-capture-these-first--theyre-the-ticket) — capture the facts (they're the ticket).
2. [**The diagnosis path**](#the-diagnosis-path--rule-out-the-look-alikes-then-name-the-rule) — rule out the look-alikes, then name the rule:
   - a. [Rule out the `hw=no` L2 offload trap](#the-diagnosis-path--rule-out-the-look-alikes-then-name-the-rule) (whole-VLAN-dark look-alike).
   - b. [Name the rule with counters](#the-diagnosis-path--rule-out-the-look-alikes-then-name-the-rule) (`print stats`, first-match-wins).
   - c. [Confirm with the deny-log prefix](#the-diagnosis-path--rule-out-the-look-alikes-then-name-the-rule) (`EAST-WEST-DENIED` / `INPUT-DENIED` / `DROPPED`).
   - d. [Rule out the service ACL](#the-diagnosis-path--rule-out-the-look-alikes-then-name-the-rule) (SSH-from-a-VLAN look-alike).
   - e. [Go packet-level](#the-diagnosis-path--rule-out-the-look-alikes-then-name-the-rule) (connection tracking · torch · sniffer).
3. [**The fix**](#the-fix--change-the-owner-keep-the-catch-alls-last) — change the owner, keep the catch-alls last.
4. [**Prove it's fixed**](#prove-its-fixed) · 5. [**If still broken**](#if-still-broken) · 6. [**Related**](#related) (siblings · Command-Library · the reconciliation map).

## Cert anchor

- **CCNP Security / MTCNA** (stateful firewall, zone/east-west policy) — the primary anchor.
- CompTIA **Network+ 5.0** (troubleshooting), **Security+** (segmentation).
- *(Grounding index: `../Atlas-Certification-Lab-Map.md` §5 + the CCNP map; `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` for why a rule matches.)*

## Grounded in — MKT01's east-west rule model (know it before you read it)

The facts that make the counters legible (`POL-0008` — the device page + the flows matrix own these; this page links):

- **MKT01** = MikroTik RB1100AHx4, RouterOS 7.23.1 — the **east-west firewall + inter-VLAN gateway** (VLAN gateways `10.<vlan>.0.1`). Owner: `Devices/MKT01-East-West-Firewall/`.
- **The allowed-flows source of truth** is `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` — check it *first*: a flow that isn't in the matrix is **supposed** to be dropped.
- **Rules match on interface** (`in=vlanX out=vlanY`), not address, and RouterOS is **first-match-wins** with the rules disjoint by interface — so a given flow matches exactly **one** rule, and a counter bump on that index *is* the proof it matched.
- **The accept rules don't log; the drops do.** Deny prefixes: **`EAST-WEST-DENIED`** (forward catch-all, the inter-VLAN default-deny) · **`INPUT-DENIED`** (input catch-all, traffic to the router) · **`DROPPED`** (invalid/out-of-state + ICMP rate + home-LAN, rules 1/3/6/8).
- 🔴 **The catch-all drops are load-bearing:** RouterOS defaults an unmatched chain to **ACCEPT**, so the final `drop` in each chain is the only thing enforcing segmentation. If it's missing or not last, "nothing is blocked" is the bug (the old Lab-01 `026` guide never built the input default-deny — `CM-0009`).
- **Established/related (rules 0 & 7) eat most packets** — the specific accept rule only counts the *connection-opening* packet(s). Reset counters and open a fresh connection to see the right index move.

Command detail (link down — `POL-0008`): `../Command-Library/RouterOS.md` §Firewall (`print stats` · `connection print` · deny logs) + §Connectivity + §Mgmt (the service ACL). Why-it-works: `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md`.

## ① Pin it down (capture these first — they're the ticket)

- a. **The flow** — `source IP (and its VLAN) → dest IP : port/proto`, plus the hostnames/roles. The **VLAN** matters most: MKT01 matches on the ingress/egress interface.
- b. **Expected vs actual** — what the flows matrix says should happen vs what you see (timeout? reset? which direction fails?).
- c. **Is it inter-VLAN or to the router itself?** — inter-VLAN → the **forward** chain (rules 7–20); to a router IP (SSH/WinBox/ping the gateway) → the **input** chain (rules 0–6, 21) *and* possibly the service ACL.
- d. **Scope & timing** — one source/VLAN or many? one service or all? when did it start; recent change (a rule edit, a firmware restore, a reboot)?
- e. **Is it even allowed?** — check `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`. **If the flow isn't in the matrix, the block is correct** — this is a policy-change request, not a fault. Stop here.

## The diagnosis path — rule out the look-alikes, then name the rule

Run on MKT01 (read `print detail`/`print stats`, never plain `print` — `016`). Prove the positive case with the *real* protocol, not ICMP (`015`).

**1. Rule out the L2 offload trap first (it looks like a firewall block but isn't).**

- a. If a *whole VLAN* gets nothing and the gateways look configured, check the trunk offload:
  - Command: `/interface bridge port print detail where interface=ether3`
  - Reference: `../Command-Library/RouterOS.md` §VLAN/L2.
  - Healthy: **`hw=no`** on the trunk. Broken: `hw=yes` → the RTL8367 switch chip eats VLAN frames before the firewall ever sees them; VLAN sub-interfaces show **0 RX** while `ether3` shows traffic.
- → If `hw=yes`, that's your problem, not the firewall (`Proxmox`/trunk L2, not `/ip firewall`). Fix: `set hw=no ingress-filtering=no`.

**2. Name the rule with counters (the primary signal).**

- a. Reset the counters so the delta is clean, then send exactly one connection:
  - `/ip firewall filter reset-counters [find]`
  - (from the source host) open one *real* connection to the dest service.
  - `/ip firewall filter print stats`
  - Reference: `../Command-Library/RouterOS.md` §Firewall.
- b. Read which index moved:
  - A **drop** counter climbed (rule 20 forward, rule 21 input, or 1/3/6/8) → that rule dropped your flow.
  - An **accept** counter climbed but traffic still fails → the firewall passed it; the problem is downstream (routing, the far host, or the service ACL — step 4).
- → First-match-wins + interface-disjoint rules means the counter names the rule unambiguously. 📸 the `print stats` row that moved (the finding).

**3. Confirm with the deny-log prefix (which chain / which drop).**

- a. `/log print where message~"DENIED"` (or `~"DROPPED"`):
  - **`EAST-WEST-DENIED`** → the forward catch-all (rule 20) — an inter-VLAN flow that no permit allowed.
  - **`INPUT-DENIED`** → the input catch-all (rule 21) — traffic to the router that no input-accept allowed (e.g. a VLAN not in the `VLANs` interface list).
  - **`DROPPED`** → an invalid/out-of-state packet (1/8), ICMP over the rate limit (3), or a home-LAN→router packet (6).
- b. The **prefix is how you tell two identical-looking drops apart** (rule 6 vs 21 both drop a home-LAN packet — only the prefix differs). Confirm the log timestamp is sane (MKT01's clock syncs; `016`).

**4. Rule out the service ACL (the classic "SSH works from mgmt but not elsewhere").**

- a. If the "blocked" thing is **management to the router** (SSH/WinBox/www-ssl) from a non-mgmt VLAN, the *firewall* rule 5 **accepts** the packet — it's refused a layer up by the service address ACL:
  - Command: `/ip service print detail`
  - Healthy: `address=` scoped to the mgmt subnets (`10.0.0.0/24`, `10.10.0.0/24`).
  - So `ssh 10.20.0.1` fails with **no `INPUT-DENIED` log** and no firewall-drop counter — because the service, not the firewall, refused it.
- → This distinction (firewall drop vs service ACL) is exactly the kind of thing that looks like one rule and is actually another. Check both.
- 📎 **Where this was documented as a solution:** the frozen Lab-01 [`MKT01 Firewall-Per-Rule-Verification-Tests`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Firewall-Per-Rule-Verification-Tests.md) §2 callout works exactly this case (a `10.20.0.x` host SSHing the router: rule 5 accepts, `/ip service address=` refuses) + `../Command-Library/RouterOS.md` §Mgmt. *(🟡 operator flagged a `CM-0023` link — needs confirming: the `CM-0023` spawned by `CM-0022` is the **SW01 SNMP-community rotation**, not a MikroTik service-ACL record; point me to the intended `CM-####` and I'll wire it here.)*

**5. Go packet-level if the counter/log isn't enough.**

- a. See the tracked state: `/ip firewall connection print where dst-address~"<dst>"` (present = a flow was accepted; absent = never matched an accept).
- b. Watch it cross the interface: `/tool torch <vlan-if> src-address=<src> port=any`.
- c. Capture the bytes: `/tool sniffer quick interface=<vlan-if> ip-address=<host>` (or stream TZSP to Wireshark).
- → For proving it was *specifically* one rule (safely, on this console-less router), hand off to `Prove-Exactly-Which-MikroTik-Rule-Acted.md`.

## The fix — change the owner, keep the catch-alls last

- **If the block is correct** (the flow isn't in the matrix): no device change — raise a flows-matrix change request; update `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (the owner) first (`POL-0008`), then the rule.
- **If it's a misconfig** (a permitted flow is being dropped):
  - a. Find why no permit matched — usually the flow's VLAN isn't in the `VLANs` interface list (so the `in/out-list=VLANs` permits skip it), or the permit is **shadowed** by an earlier drop, or the permit's `in/out` interfaces don't match the real path.
  - b. Add/correct the permit **by comment**, placed **before** the catch-all drop: `place-before=[find comment="..."]`.
  - c. 🔴 Confirm the two catch-all drops (`EAST-WEST-DENIED`, `INPUT-DENIED`) are still **last** in their chains — never leave a permit below the drop, and never leave the chain defaulting to ACCEPT.
  - d. Record it as a change (`CM-####`); don't hand-edit a device whose config has an owner (`POL-0004`).
  - The exact commands are MKT01's to run + read back (🟡 until pasted).

## Prove it's fixed

- a. Reset counters; re-run the exact failing connection with the **real protocol** (not ICMP — `Test-a-Connection.md`).
- b. `/ip firewall filter print stats` — the **accept** rule now climbs, the deny does not.
- c. The service completes end-to-end; the `EAST-WEST-DENIED`/`INPUT-DENIED` log stops appearing for this flow.
- d. `/ip firewall filter print` — still the expected rule count, catch-all drops last, none disabled.
- e. 📸 the accept counter moving + the successful service test. Mark ✅ only with the pasted read-backs (`POL-0001`).

## If still broken

- Accept counter climbs but it still fails → not the E-W firewall: check routing/OSPF (`/ip route print`, `/routing ospf neighbor print`), the far host's own firewall, or the **service ACL** (step 4).
- Whole VLAN dark with gateways configured → the **`hw=no` offload trap** (step 1), not a rule.
- A permit's counter stays **zero** after its positive test → a dead or mis-scoped rule (wrong `in/out` interface, or the VLAN isn't in the `VLANs` list) → `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched.md` (prove-it-dead first).
- One end is **outside** the estate (internet/another site) → it's a perimeter problem, start at FGT01 → `Trace-a-Blocked-Flow.md`.
- You need to prove it's *this specific* rule → `Prove-Exactly-Which-MikroTik-Rule-Acted.md` (mirror/disable-to-prove, safely).

## Related

- **Command-Library:** `../Command-Library/RouterOS.md` (§Firewall · §Connectivity · §Mgmt service ACL · §VLAN/L2 for `hw=no`).
- **Concepts:** `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` (why a rule matches by zone/interface).
- **Owners:** `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (the E-W allowed-flows owner) · `Devices/MKT01-East-West-Firewall/` (+ its `Troubleshooting.md`).
- **Sibling playbooks:** `Trace-a-Blocked-Flow.md` (the cross-platform parent — start there if you don't yet know it's MKT01) · `Prove-Exactly-Which-MikroTik-Rule-Acted.md` (low-level per-rule proof) · `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched.md` (a zero-counter rule) · `Test-a-Connection.md` (prove the flow with the real protocol) · `Recover-a-Locked-Out-Router-Out-of-Band.md` (if a rule edit locks you out).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).
- **Real lineage:** frozen Lab-01 `Devices/MKT01-Core-Router/Firewall-Per-Rule-Verification-Tests.md` + `Firewall-Low-Level-Per-Rule-Isolation-Tests.md` (the 22-rule counter/log/first-match-wins method) · `Changes/CM-0009` (the dead-rule + the missing input default-deny) · `016` (read `print stats`, not `print`) — `ADR-0022`-reconciled to the Lab-02 E-W role.

## Worked log

| Date | Who | Time | Flow (src→dst:proto) | Rule that acted | Correct block? | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the `#32` "Symptoms & search terms" element) — fulfils the seeded `MikroTik-EastWest-Inspect-and-Troubleshoot` row. The MikroTik-deep companion to `Trace-a-Blocked-Flow`: find which `/ip firewall` rule dropped a flow via reset-counters + `print stats` (first-match-wins names the rule), the deny-log prefixes (`EAST-WEST-DENIED`/`INPUT-DENIED`/`DROPPED`), and rule out the two look-alikes (the `hw=no` L2 offload trap; the service address ACL). Emphasises the flows matrix as source-of-truth and the load-bearing catch-all drops. Grounded in the frozen Lab-01 MKT01 firewall test docs + `CM-0009`, reconciled to the Lab-02 E-W firewall role. 🟡 until worked on MKT01. |
