---
Title: Atlas Firewall Architecture, Considerations and Verification
Path: 00-Atlas-Foundation/Reference
Status: Draft — design proposal and teaching reference. Nothing here is a build instruction.
Version: 1.2
---

# Atlas Firewall Architecture, Considerations and Verification

> **This is a teaching reference, written under Charter Locked Rule 17 (the Learning Rule).** It gives you the **design**, the **verification method**, and the **failure modes** for enterprise firewalling — north‑south and east‑west. **It deliberately does NOT hand you paste-ready firewall rules.** On the systems you are trying to learn (FGT01 now, MKT01 as the east‑west firewall in Book 11), *you* write the config. This document is the senior engineer who reviews and explains.
>
> Companion pages: device specifics live in `059-FGT01-Considerations-and-Risks.md` (north‑south, today) and `055-MKT01-Considerations-and-Risks.md` (east‑west, Book 11). The role split is `Atlas-Service-Architecture.md` Book 11; the policy-ownership boundary is `ADR-0018` (Security silo owns firewall *policy*).

---

## 0. The one idea to hold first

> **A firewall's job is to enforce a decision about which conversations are allowed. Everything else — NAT, logging, inspection — is in service of that one job.**

Two questions decide a firewall's whole design:

1. **Which direction of traffic am I controlling?** — north‑south (crossing the trust boundary to/from the outside) or east‑west (moving laterally *inside* the network between segments). They are different jobs with different rules, and enterprises use **different enforcement points** for each.
2. **What is my default answer?** — the only correct enterprise default is **deny, and log the denial.** Everything allowed is an explicit, named, logged exception. A firewall whose default is "allow" is a router with opinions.

Atlas's thesis (`Atlas-Service-Architecture.md`): *the router routes, the switch switches, the firewall filters.* A firewall that is also your only router (MKT01 today) has its **control plane and its policy plane in one failure domain** — which is precisely why Book 11 separates them.

---

## 1. North‑south vs east‑west — the core distinction

| | **North‑South (N‑S)** | **East‑West (E‑W)** |
|---|---|---|
| **What it is** | Traffic crossing the trust boundary — LAN ⇄ Internet, or into/out of the datacenter edge | Traffic moving laterally *between internal segments* — VLAN 20 ⇄ VLAN 40, server ⇄ server |
| **Classic threat** | The outside getting in; data getting out (exfiltration) | An attacker who is *already inside* one segment pivoting to another ("lateral movement") |
| **Atlas enforcement point** | **FGT01** (perimeter firewall, internet edge) | **MKT01 today** (inter‑VLAN gateway) → **dedicated E‑W firewall in Book 11** |
| **Typical volume** | Lower — a chokepoint | **Much higher** — most datacenter traffic is E‑W, which is why it is the harder problem |
| **Default posture** | Deny inbound; control (not just allow) outbound | Deny between segments; allow only the specific flows a service needs |
| **Where it's usually weak** | Usually the *strongest* firewall in the org | 🔴 **Usually the weakest or absent** — this is the #1 real-world gap, and it is Atlas's gap too |

**Why E‑W is the hard, modern problem.** For twenty years "firewall" meant "the box at the internet edge," and inside the LAN everything could talk to everything. Then breaches taught everyone that the attacker rarely comes through the front door standing up — they phish one workstation and then move *sideways*. The perimeter was strong and the interior was flat, so one foothold owned the building. **East‑west segmentation is the fix: make lateral movement require crossing a firewall too.** The extreme form is *microsegmentation* — policy down to the individual host, not just the VLAN.

> 🔴 **Atlas is flat east‑west today.** MKT01 routes between all nine VLANs. Unless a rule says otherwise, VLAN 20 can reach VLAN 40 because they share a router. **That is the exact "strong perimeter, flat interior" pattern the industry spent a decade unlearning.** Book 11's MKT01‑as‑E‑W‑firewall is where Atlas fixes it — and it is a genuinely enterprise-grade thing to learn.

---

## 2. The Atlas mapping — today vs Book 11

### Today (Book 1)

```
        Internet
           │
        [ wan1 ]           N‑S enforcement — FGT01
        FGT01  (perimeter firewall: NAT, one egress policy, srcaddr all per ADR-0005)
           │ internal1  172.16.0.1/29
           │ (transit)
        [ ether1 ]
        MKT01  ← routes AND "filters" ALL east‑west between VLAN 10/20/40/50/60/80…
           │  (control plane + policy plane in one 1 GiB box)
     ┌─────┴─────┐
   SW01        (VLANs)
```

- **N‑S = FGT01.** One outbound policy, `srcaddr all`, NAT to the home router. Deliberately broad per `ADR-0005` (narrowing is deferred until there's redundancy to test it safely). **UTM: a FortiGuard subscription is being licensed (`ADR-0047`, reverses the earlier no-UTM `ADR-0035`)** — web/AV/IPS/app-control/DNS filtering become the licensed N-S content-inspection layer once profiles are applied + DB-verified (`get system status`).
- **E‑W = MKT01, implicitly.** It is the default gateway for every VLAN, so it *is* the only place inter‑VLAN traffic can be filtered. Whether it actually filters depends on its firewall rules — and the operating model (`ADR-0018`) says a *Security* decision (E‑W policy) implemented as a *Network* rule on the wrong device is exactly the class of mistake the silos exist to catch.

### Book 11 target (the next lab) — settled by `ADR-0023` (Option B)

```
        Internet
           │
        FGT01     ← N‑S perimeter firewall (unchanged role)
           │  routed transit /30
        1941      ← CORE ROUTER — the routed backbone (north‑south) between edge and
           │        internal firewall; OSPF/static. Holds NO VLAN gateways.
           │  routed transit /30
        MKT01     ← INTERNAL SEGMENTATION FIREWALL — the L3 gateway for every internal
           │        VLAN; routes inter‑VLAN AND enforces default‑deny east‑west policy.
        SW01 / VLANs
```

> 🔴 **`ADR-0023` corrected an earlier framing here.** This diagram once read *"1941 routes, MKT01 routes little/none"* — the transparent bump‑in‑the‑wire design (its Option A). **That is not what an enterprise does, and it is fragile** (asymmetric paths break stateful inspection). The chosen design (Option B) is: **the east‑west firewall IS the inter‑segment router.** MKT01 keeps inter‑VLAN routing *and* now filters it; the **1941 takes north‑south/core routing.**
>
> 🔴 **The move that matters, restated:** routing and filtering are no longer in the *same failure domain that also carries the core/edge*. A MKT01 policy mistake affects inter‑segment reachability, but **core and edge routing survive on the 1941 + FGT01.** That — not "the firewall never routes" — is the achievable separation, because filtering east‑west inherently means being in the east‑west path.

---

## 3. What an enterprise firewall actually does — the capability catalogue

For each capability: **what it is · how N‑S vs E‑W use it · what "good" looks like · how to verify · how it fails.** (Verification here means *read-only checks and tests* — the validation method. Building it is yours.)

### 3.1 Stateful inspection

- **What:** the firewall remembers *connections*, not just packets. It allows the return traffic of a connection it permitted outbound, automatically, without a second rule. A stateless ACL (like a basic router ACL) does not — you'd need explicit rules both ways.
- **N‑S:** essential — you permit "LAN → Internet" and the replies come back on the same session. **E‑W:** same principle between segments.
- **Good:** you write policy in the *direction the connection is initiated*, and trust the state table for replies.
- **Verify:** on FortiOS, the session table — `diagnose sys session list` / `diagnose sys session stat` — shows live connections and their state. Prove a flow appears when you generate it and ages out when you stop.
- **Fails:** asymmetric routing (reply takes a different path than the request) breaks stateful inspection silently — the firewall never sees the other half of the conversation and drops it. A classic E‑W failure when routing and filtering are on different boxes and paths aren't symmetric.

### 3.2 Zones and the policy model

- **What:** a **zone** is a named group of interfaces/segments with a trust level (e.g. `wan`, `lan`, `dmz`). Policy is written *between* zones (zone-pairs), not per-interface. A **policy** is: source zone → dest zone, source/dest address, service (port), action (allow/deny), and — critically — **log**.
- **The non-negotiable shape:** explicit allows for what's needed, then an **implicit (or explicit) deny‑all at the bottom, logged.** Least privilege: name the flow, scope it, log it.
- **N‑S:** few zones (wan/lan/dmz), egress control + inbound deny. **E‑W:** a zone (or micro-zone) *per segment*, and the interesting policy is segment‑to‑segment.
- **Good:** you can read the policy top‑to‑bottom and say, in English, exactly which conversations are allowed and why each exists.
- **Verify:** read the policy with the tool's *runtime* view (FortiOS: `get firewall policy` / `show firewall policy <id>` — **`get`, not `show`, for state**, per Charter Rule 13's corollary). Count the rules. For each, ask "what would this permit that I didn't intend?"
- **Fails:** 🔴 **rule ordering** — firewalls evaluate top‑down and stop at first match; a broad allow above a specific deny silently wins. 🔴 **the implicit-any** — a policy with `srcaddr all` / `service ALL` (FGT01 today) permits everything in that direction; deliberate here (`ADR-0005`), catastrophic if unintended.

### 3.3 NAT — and the N‑S / E‑W difference that trips people up

- **What:** Network Address Translation rewrites addresses. **Source NAT / PAT** (many private hosts → one public IP) is how a LAN reaches the internet.
- 🔴 **N‑S uses NAT. E‑W generally does NOT.** Between internal segments you *route*, you don't translate — both sides are real, reachable, internal addresses, and you *want* the true source IP visible for policy and logging. NAT east‑west destroys the source identity your segmentation policy depends on.
- **Good:** NAT at the edge (FGT01), routed/transparent east‑west (MKT01/1941).
- **Verify:** FGT01 policy 1 has `set nat enable` (edge, correct). On the E‑W firewall, confirm inter‑VLAN policies do **not** NAT.
- **Fails:** NAT applied east‑west makes every internal host look like the firewall — logs and policy become useless; you can't tell who did what.

### 3.4 NGFW / UTM — application awareness, IPS, AV, web filtering, TLS inspection

- **What:** a "next‑gen"/UTM firewall inspects *above* layer 4 — identifies the application regardless of port (App‑ID), runs an IPS (signature-based intrusion prevention), antivirus, URL/web filtering, and can decrypt TLS to inspect inside (TLS inspection).
- **N‑S:** this is where UTM lives in most orgs — the edge sees internet traffic. **E‑W:** high-security environments run IPS east‑west too, but it's expensive at E‑W volumes.
- 🟡 **Atlas's state (updated `ADR-0047`, 2026-07-29):** FGT01 previously had UTM *capability* but no licence and 8–11-year-old signature databases with no profiles attached (`059`, `CM-0033`, `ADR-0035`) — the *good* branch of the confidence trap (attach nothing rather than pretend). **A FortiGuard UTM subscription is now being licensed (`ADR-0047`, reversing `ADR-0035`)**, so FGT01 becomes a real NGFW/UTM edge: web/AV/IPS/app-control/DNS filtering on the N-S policy set. **The trap discipline survives the reversal** — a profile is trusted only once `get system status` proves the databases are *current* and a positive test fires; a lapsed subscription reverts to detach-don't-run-stale.
- **Good:** licence it and apply profiles **and verify they update** — which is now the plan (`ADR-0047`). The rejected middle ground stays rejected: an *attached-but-stale* profile ("possibly not applied", a green column over 2015 signatures) is not a decision and is never trusted.
- **Verify:** `get system status` (DB dates — are they current?); the policy (are profiles attached?); if attached, prove the IPS actually blocks something (e.g. an EICAR-style test against AV) — an applied profile you never tested is `016` lesson 4.
- **Fails:** 🔴 **the confidence trap** — a UTM column that's green while the signatures are from 2015. It invites you to believe you're covered. Worse than having nothing.

### 3.5 IDS/IPS — inline vs out-of-band, and the tap you already own

- **What:** **IPS** sits *inline* and can drop. **IDS** sits *out‑of‑band* on a mirror/tap and can only alert. Both match traffic against threat signatures/behaviour.
- **Atlas has free E‑W security telemetry it has never used:** `SW01 Gi1/0/5` is a **SPAN port mirroring the MKT01 trunk** — i.e. a copy of all inter‑VLAN traffic — and it's usually unplugged. Plug an IDS (**Suricata** or **Zeek**) into it (`Atlas-Service-Architecture.md` 5.2). **That is east‑west visibility with zero risk — it can't break anything because it's a copy.**
- **Good:** IDS on the SPAN first (visibility, no risk), IPS inline later once you trust it.
- **Verify:** generate known-bad-ish traffic from LabComputer and confirm the IDS alerts. A sensor that has never fired on a test is unproven.
- **Fails:** inline IPS is now in the traffic path — an IPS that fails *closed* takes the network down; one that fails *open* stops protecting. Know which yours does before you rely on it.

### 3.6 Segmentation and microsegmentation — the heart of east‑west

- **What:** **segmentation** = separate VLANs/subnets with a firewall between them (VLAN-level policy). **Microsegmentation** = policy down to the individual workload/host, so even two servers on the *same* segment can't talk unless allowed. Modern datacenters (and zero-trust) push toward the latter.
- **N‑S:** not the point. **E‑W:** *this is the point.* The value of the Book 11 E‑W firewall is that VLAN 20 (Servers) reaching VLAN 40 (Monitoring) becomes an explicit, logged, named allow — and everything else between segments is denied.
- **Good, in Atlas terms:** a written **allowed-flows matrix** — for every pair of segments, the specific services permitted and why (e.g. "VLAN 50 clients → VLAN 10 DNS/53 only"; "VLAN 40 monitoring → all VLANs SNMP/161; nothing back"). Everything not in the matrix is denied and logged.
- **Verify:** 🔴 **the reachability matrix test** — from a host in segment A, attempt each service in segment B; confirm allowed flows succeed and everything else is *refused*, not just silent. Packet-capture on the SPAN to see what's actually crossing. This is the E‑W equivalent of "prove the tenant isolation" in the MSP scenario.
- **Fails:** 🔴 **"allow any any" between VLANs to make it work,** then never tightening — the single most common real-world E‑W failure. And 🔴 **routing without filtering:** segmentation on paper only. Under `ADR-0023` Option B this is closed by construction — **MKT01 is the inter‑VLAN gateway, so every inter‑segment flow crosses policy by definition** — but still confirm it, don't assume it. *(The rejected Option A, a transparent MKT01 bridging the SW01↔1941 trunk, is where this failure and the asymmetric‑path failure of §3.1 actually bite — one reason it was rejected.)*

### 3.7 Logging and telemetry — "prove it," applied to firewalls

- **What:** every allow and (especially) every deny should be logged, timestamped against a *synchronised clock*, and shipped to a collector (syslog → MON01; NetFlow → collector).
- 🔴 **Depends on NTP.** Logs from a firewall whose clock is wrong are near-useless for correlation. Atlas's clock story: FGT01 and Pi01 and MKT01 sync; **SW01 does not** (`CM-0030`). Fix the clock before you trust the logs.
- **Good:** deny logging on by default, logs off-box (a firewall that logs only to itself loses its logs when it's the thing that's compromised), NetFlow for volume/behaviour.
- **Verify:** generate a denied flow and find the deny in the log with a correct timestamp. On FortiOS, `execute log filter` / log view; confirm export to syslog actually arrives at the collector.
- **Fails:** 🔴 logging to local disk only; 🔴 unsynced clock making correlation impossible; 🔴 logging *allows* but not *denies* (the denies are the security signal).

### 3.8 High availability and the management plane

- **HA:** enterprises run firewalls in **pairs** (active/passive or active/active) so one failure doesn't sever the edge. 🔴 **Atlas has one FGT01 and one MKT01 — each a single point of failure.** This is *why* `ADR-0005` defers narrowing FGT01's egress policy: without a redundant path, a bad policy change locks you out with no failover. **Redundancy is the prerequisite for aggressive policy.**
- **Management plane:** the firewall's own administration must be locked down and must have an **out-of-band recovery path** that policy can't sever. FGT01's is real and worth understanding: `trusthost` restrictions scope admin access, **console access bypasses all network restrictions** (the always-there recovery), and `internal3‑7` at `192.168.1.99` is the IP-based break‑glass path (`059`, `CM-0033`) — which is why a hardening pass must never disable them.
- **Verify:** confirm the recovery path works *before* you need it (can you reach console / `192.168.1.99`?); confirm `admin-server-cert` is actually bound with `get`, not `show` (MC‑0001: it silently wasn't, for hours).
- **Fails:** 🔴 a policy/hardening change that locks out management with no console tested; 🔴 an HA pair that never fails over because failover was never tested (Game Day it).

---

## 4. Designing the Book 11 east‑west firewall (MKT01) — what "good" requires

When MKT01 becomes the dedicated E‑W firewall, the design bar is:

1. **A written allowed-flows matrix** (segment × segment × service) *before* a single rule. The matrix is the design; the rules render it. This is a **Security-silo** artefact and crossing into it is a Change Record (`ADR-0018`).
2. **Default deny + log between all segments.** Start denied, open the matrix's flows explicitly.
3. **No NAT east‑west** (§3.3). Real source IPs, for policy and logs.
4. **Routing separated from filtering** — the 1941 routes; MKT01 filters; verify the path actually crosses MKT01.
5. **Symmetric paths** so stateful inspection works (§3.1).
6. **Deny logging → MON01**, clock synced first.
7. **A reachability-matrix verification plan** — the test that *proves* isolation, run as a Game Day (`ADR-0011`). Isolation you didn't test is isolation you don't have.
8. **A tested recovery path** for MKT01's own management (this is what `ADR-0016`'s deferred console gap is about — close it with the FTDI cable in the hardware list before making MKT01 policy-critical).

> 🔴 **The failure to design against, above all others:** making it work by allowing everything, because deny-by-default is annoying during bring‑up, and never going back. Build the matrix first; let the rules fail closed; open flows one proven test at a time.

---

## 5. Atlas firewall gap analysis (today, honest)

| Capability | N‑S (FGT01) | E‑W (MKT01 today) | Gap / next step |
|---|---|---|---|
| Stateful inspection | 🟢 yes | 🟢 yes (RouterOS stateful) | — |
| Default-deny policy model | 🟡 egress `all` (ADR‑0005, deliberate) | 🔴 **flat — verify what actually filters inter‑VLAN** | Book 11: matrix + deny-by-default |
| NAT placement | 🟢 edge only | 🟢 routed internally | — |
| NGFW/UTM | 🟡 **licensing FortiGuard UTM (`ADR-0047`)** — was unlicensed/stale/none-applied | n/a | Build FGT Build-Guide-3 (Security-Profiles); apply + DB-verify (`get system status`) |
| IDS/IPS (N‑S inline) | 🟡 **pfSense inline IPS (`ADR-0038`)** + FGT UTM IPS (`ADR-0047`) | 🔴 **SPAN port built, never used** | Suricata on `Gi1/0/5` — free E‑W visibility; pfSense on the FGT↔1941 transit — free-vs-licensed comparison |
| Segmentation | n/a | 🔴 **flat east‑west** | Book 11 — the core exercise |
| Deny logging → off-box | 🟡 local | 🔴 | MON01 + syslog; fix SW01 clock first |
| HA / redundancy | 🔴 single FGT01 | 🔴 single MKT01 | Gates aggressive policy (`ADR-0005`) |
| Management recovery path | 🟢 console + `192.168.1.99` | 🟡 **console deferred (`ADR-0016`)** | FTDI cable (hardware list #3) |

---

## 6. How to verify a firewall (the method, reusable)

The Atlas "prove it, don't assume it" discipline, applied to firewalls:

1. **Read state with the runtime view, not the config view.** FortiOS `get` not `show`; on RouterOS `/ip firewall filter print stats`. Config shows intent; runtime shows reality (MC‑0001: `set admin-server-cert` ran clean and never took effect).
2. **Count the rules and read every one in English.** If you can't say what a rule permits, you don't know your policy.
3. **Test the allowed flows** — generate the traffic, confirm it passes, find it in the session table.
4. **Test the denied flows** — this is the half everyone skips. Attempt what should be blocked; confirm it's *refused*, and confirm the deny is *logged* with a correct timestamp.
5. **Build a reachability matrix** for east‑west and run it end to end (the tenant-isolation test, generalised).
6. **Watch the wire** — the SPAN port + a packet capture tells you what's *actually* crossing, independent of what the policy says.
7. **Prove the recovery path** before you need it.

> **A firewall rule that has never had its deny tested is a hope, not a control** — the same lesson as an untested backup (`ADR-0011`) and an unproven NTP tick (`016` lesson 4).

---

## 7. Certification and career mapping (why this is worth the depth)

| Topic here | Where it pays off |
|---|---|
| Zones, policy, stateful vs stateless, NAT | CCNA (security fundamentals), Network+ |
| Zone-Based Firewall on IOS | CCNP Security, and the 1941 ZBF scenario (`Atlas-Roadmap-Advanced-Scenarios.md`) |
| FortiGate policy, UTM, multi-VDOM | Fortinet NSE 4 / NSE 7 |
| East‑west segmentation, microsegmentation, zero-trust | Modern security architecture roles; SC‑200 (detection) |
| Tenant isolation + verification | The MSP simulation; NSE 4, CCNP Security |
| IDS/IPS on a SPAN | Blue-team / SOC fundamentals; Security+ |

---

## Related pages

- `Labs/Lab-02-Cisco-Core/Architecture/Atlas-Service-Architecture.md` — the device role split and Book 11 (moved into Lab-02 per `ADR-0008`)
- `00-Atlas-Foundation/Roadmap/Atlas-Roadmap-Advanced-Scenarios.md` — 1941 ZBF, MSP multi-VDOM, tenant isolation
- `00-Atlas-Foundation/Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md` — the Option B topology this document's Book 11 target reflects
- `00-Atlas-Foundation/Decisions/ADR-0018-Atlas-Operating-Model-Silos.md` — Security owns firewall *policy*; the Learning Rule is now Charter Rule 17
- `00-Atlas-Foundation/Decisions/ADR-0005-...` — why FGT01 egress stays `srcaddr all` until redundancy exists
- `058`/`059` (FGT01 verification + considerations, north‑south) · `054`/`055` (MKT01, east‑west, Book 11)

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-16. Created as the expansive firewall teaching reference under the Learning Rule (design/verify/failure-modes, operator writes config). Covers north‑south vs east‑west, the Atlas mapping (FGT01 N‑S today; MKT01 E‑W in Book 11 with the 1941 as core router), the enterprise capability catalogue (stateful inspection, zones/policy, NAT placement, NGFW/UTM, IDS/IPS, segmentation/microsegmentation, logging, HA, management plane), the Book 11 E‑W design bar, an honest Atlas gap analysis, and a reusable firewall verification method. Grounded in `Atlas-Service-Architecture.md`, `Atlas-Roadmap-Advanced-Scenarios.md`, `ADR-0018`, and FGT01's device-verified state (`058`/`059`, `CM-0033`). |
| 1.2 | 2026-07-29. **UTM posture updated to `ADR-0047`** (reverses the earlier no-UTM `ADR-0035`). The "Today" N-S bullet, §3.4 (NGFW/UTM — Atlas's state + the Good branch), and the §5 gap-analysis NGFW/UTM + IDS/IPS rows now reflect that **FGT01 is licensing FortiGuard UTM** as the N-S content-inspection layer and **pfSense (`ADR-0038`) is the free/complementary inline IPS + free-vs-licensed comparison** on the FGT↔1941 transit. The confidence-trap discipline is retained as a verify-the-DBs-update duty. Frontmatter Version trued up 1.0→1.2 to match the change log. |
| 1.1 | 2026-07-17. **Reconciled to `ADR-0023` (Option B).** Book 11 target diagram corrected: the earlier *"1941 routes, MKT01 routes little/none"* framing was Option A (transparent bump‑in‑the‑wire) — replaced with Option B, where **MKT01 is the inter‑VLAN gateway that also filters** and the **1941 is the north‑south/core router**; failure‑domain separation comes from independent core/edge routing, not from forbidding the firewall to route. §3.6's "routing without filtering" failure updated (closed by construction under B). **Learning-Rule citations corrected from Rule 16 to Rule 17** (the Learning Rule was renumbered when `ADR-0018` was accepted; Rule 16 is now count-the-OLD-text). |
