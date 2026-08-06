# ADR-0023 — Lab-02 Core & Segmentation Topology: 1941 as Core Router, MKT01 as Internal East-West Firewall

| Item | Value |
|---|---|
| Status | **Proposed** |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-17 |
| Related | `Atlas-Service-Architecture.md` (Lab-02 spine), `Atlas-Firewall-Architecture.md` (Book 11 design bar), `ADR-0018` (Security silo owns firewall *policy*), `ADR-0005` (FGT01 egress / redundancy gates aggressive policy), `ADR-0016` (MKT01 console recovery deferred), `ADR-0020` (NTP authority), `ADR-0021` (tiered identity), `305-Atlas-Industrial-Security-Requirements.md` (OT zone, data classification) |
| Governing Policy | `POL-0007` (Hardening Baseline) · candidate *POL — Network Segmentation* (framework, not yet written) |
| Evidence Status | **`Target Design`** — nothing here is built. The device config is the operator's to write (Charter Locked Rule 17). |

> **This ADR fixes the physical topology of the Lab-02 re-architecture so it stops living in a chat.** The high-level intent — *the 1941 takes over core routing, MKT01 becomes the east-west firewall* — was clear; the **insertion topology** (how those two boxes physically relate, and therefore what role each device actually holds) was not, and three genuinely different designs fit the same one-line intent.

## Context

Lab-01 is flat east-west: **MKT01 is the default gateway for all nine VLANs, so it both routes and (implicitly) filters every inter-VLAN flow** — control plane and policy plane in one 1 GiB box. That is the "strong perimeter, flat interior" pattern the industry spent a decade unlearning (`Atlas-Firewall-Architecture.md` §1).

Lab-02 introduces a **Cisco 1941** and re-roles the estate. The one-line intent (*1941 = core router, MKT01 = east-west firewall*) hides a real design question: **inter-VLAN routing and east-west filtering both happen at the same L3 boundary**, so whichever box is the VLAN default gateway does the routing *and* is the natural enforcement point. Handing routing to the 1941 while making MKT01 the filter requires deciding *how traffic is physically forced through MKT01* — and the 1941's two GigE ports make that concrete.

The operator's stated goal: **the real-world, enterprise-standard, most-secure design** — complexity is acceptable if it is the correct way. This ADR answers against that bar, not against minimum effort.

## Alternatives Considered

### A — Transparent bump-in-the-wire
1941 does all inter-VLAN routing (router-on-a-stick, every VLAN gateway on the 1941). MKT01 runs in **bridge/transparent mode on the SW01↔1941 trunk**, filtering inter-VLAN traffic as it hairpins to the router and back. This is the literal reading of Firewall-Arch's *"MKT01 filters, routes little/none."*

**Rejected.** Transparent-mode firewalling is a niche skill, not the transferable enterprise pattern; **all** inter-VLAN traffic hairpins through MKT01 (throughput); and it is the topology **most exposed to asymmetric routing** — request and reply on different paths, which breaks stateful inspection silently (Firewall-Arch §3.1). It optimises for a doctrinal purity ("the firewall never routes") at the cost of the thing that actually matters (a symmetric, stateful, standard enforcement point).

### C — Split gateways / protected segments
1941 routes most VLANs (router-on-a-stick); only the sensitive segments (Tier-0 Identity, Servers, OT) gateway on MKT01, so only protected-zone traffic is filtered.

**Rejected as a target design** (retained as a *migration step* — see Consequences). Two routing brains is more complexity for **less** security: east-west between the non-protected zones stays unfiltered, and the split path reintroduces the asymmetric-routing exposure. It is a legitimate *phased rollout* of B ("firewall the crown jewels first, expand to all"), not a destination.

### Status quo — MKT01 remains the all-in-one gateway
Keep MKT01 routing and filtering everything; add the 1941 only as an edge/transit helper.

**Rejected.** It preserves the Lab-01 single-failure-domain problem the whole re-architecture exists to fix, and wastes the 1941.

## Decision

**Option B — MKT01 is the internal segmentation firewall and the L3 default gateway for every internal VLAN; the 1941 is the routed core between MKT01 and the perimeter.**

```
Internet
  │
FGT01     ← perimeter / edge firewall — N-S, NAT, egress (role unchanged, ADR-0005)
  │  routed transit link (e.g. /30)
1941      ← CORE ROUTER — routed backbone between edge and internal firewall;
  │        OSPF or static; the IOS routing learning vehicle
  │  routed link
MKT01     ← INTERNAL SEGMENTATION FIREWALL — L3 gateway for all internal VLANs;
  │        default-deny east-west, stateful, NO east-west NAT, deny → MON01
  │  802.1Q trunk (all VLANs)
SW01      ← L2 access/distribution; DHCP snooping + DAI; SPAN (Gi1/0/5) → Suricata IDS
  └── 10 Mgmt · 20 Servers (+ Tier-0 Identity carve-out) · 30 Web · 40 Mon ·
      50 Clients · 60 Deploy · 70 Test · 80 DMZ · 90 OT
```

**Within B, the Tier-0 Identity carve-out (DCs, CA — `ADR-0021`) and the OT zone (`305` Part 2 / NIST 800-82) are tightened micro-zones**, not equal peers of the other VLANs. They carry the most explicit, most-scoped policy on MKT01. (Adopting C's protected-segment idea *inside* B's single enforcement point — as policy, not as a second routing brain.)

## Rationale

**Why the firewall is the gateway (B), not a bridge (A) or a partial filter (C):**

1. 🔴 **Symmetric by construction → stateful inspection actually works.** Because MKT01 is the gateway, request and reply traverse it on the same path. A and C create hairpinned/asymmetric paths where MKT01 sees half a flow and drops it silently — the nastiest east-west failure mode (Firewall-Arch §3.1).
2. 🔴 **No "segmentation on paper only."** Firewall-Arch §3.6's headline failure is *routing without filtering*. B makes it impossible: MKT01 **is** the L3 boundary, so nothing crosses between segments without hitting policy. There is no separate path to forget to secure.
3. **It is the transferable, real-world skill.** "Firewall as the L3 segmentation gateway, default-deny between zones" is what mid-size enterprises run and what NSE / CCNP-Security expect. Transparent inline bridging is a tool, not the pattern.
4. **Failure-domain separation is preserved where it counts.** The concern behind Atlas's *"the router routes, the firewall filters"* thesis is that a policy change must not take down core routing. B keeps the **core/edge routing (1941 + FGT01) independent of the segmentation policy** — a MKT01 policy mistake affects inter-segment reachability, but edge/WAN routing survives. Perfect separation is impossible (filtering east-west *means* being in the east-west path); B gets the achievable version.

**On the 1941 (honest):** a segmentation firewall plus an edge firewall is a complete design; MKT01 could cable straight to FGT01. The 1941 is kept deliberately for three real reasons — it is the **CCNA/IOS learning vehicle** (OSPF, routing, router-on-a-stick), a **legitimate routed core** that isolates backbone routing from security policy, and the **growth path** to multiple distribution firewalls or sites. This is the "router between two firewalls" pattern; part of its justification here is pedagogical, and that is stated rather than hidden.

## Consequences

- 🔴 **This revises `Atlas-Firewall-Architecture.md`.** Its Book 11 diagram says *"1941 routes, MKT01 routes little/none"* — which, taken literally, is Option A. That doc's Book 11 target and gap-analysis rows must be updated to reflect B: **the east-west firewall is the inter-segment router; failure-domain separation comes from independent core/edge routing, not from forbidding the firewall to route.**
- **MKT01's role changes from "router" to "routing segmentation firewall."** It keeps inter-VLAN routing, but now every inter-VLAN flow is subject to a default-deny policy. Its RADIUS function leaves it (to SRV01/NPS) per `Atlas-Service-Architecture.md`.
- **The design bar (Firewall-Arch §4) is now binding on MKT01:** a written **allowed-flows matrix before a single rule** (a Security-silo artefact — crossing into it is a Change Record, `ADR-0018`); **default-deny + log**; **no NAT east-west** (real source IPs); **deny-logging → MON01 with clocks synced first** (SW01's clock, `CM-0030`, must be fixed before its logs are trustworthy); and a **reachability-matrix Game Day** (`ADR-0011`) that proves the denies deny.
- 🔴 **Hard prerequisite before MKT01 becomes policy-critical: a tested out-of-band console recovery path.** `ADR-0016` deferred this; the FTDI cable (Service-Arch hardware list #3) closes it. A default-deny firewall with no proven recovery path is one bad rule from locking out the box that now gates the entire interior.
- **`305`'s OT zone (VLAN 90) and the Tier-0 Identity carve-out become the two highest-stakes policies on MKT01.** In a larger shop the OT plant would earn its own dedicated firewall/conduit; at Atlas scale it is a strict micro-zone here, and that limit is acknowledged, not hidden.
- **A phased rollout is available and blessed:** stand up B's enforcement on the crown-jewel zones first (the Option-C shape), prove them with the reachability test, then expand default-deny to all segments. This is a migration path *to* B, not a different destination.
- **Per-device role/config-design docs follow** under `Labs/Lab-02-Cisco-Core/Devices/` (1941 core, MKT01 east-west, and the re-cabled SW01/FGT01), in the design + validation + failure-modes format — the operator writes the config (Rule 17).

## Review Trigger

- **If the 1941 proves inadequate** as the routed core (throughput, feature, or reliability), revisit — collapsing it (MKT01 → FGT01 directly) or replacing it are both valid.
- **If an HA pair is ever introduced** for MKT01 or FGT01, revisit `ADR-0005`'s deferral of aggressive egress policy — redundancy is the prerequisite for it.
- **If the OT footprint grows** beyond what a MKT01 micro-zone can safely isolate, promote the OT boundary to its own enforcement point (NIST 800-82 conduit).
- **On any change to what the lab hosts or connects to** that alters the trust model.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-17. Fixes the Lab-02 core/segmentation topology as **Option B** — MKT01 as the internal L3 segmentation firewall (default-deny east-west, stateful, no NAT), the 1941 as the routed core between MKT01 and FGT01, FGT01 unchanged at the perimeter, SW01 as L2 access with the SPAN finally feeding an IDS. Rejects transparent bump-in-the-wire (A, asymmetric-path fragility, non-standard) and split-gateways (C, retained only as a migration step). Records that this revises `Atlas-Firewall-Architecture.md`'s Book 11 diagram, names the Tier-0 and OT micro-zones as the highest-stakes policy, and gates MKT01 policy-criticality on the `ADR-0016` console recovery path. |
