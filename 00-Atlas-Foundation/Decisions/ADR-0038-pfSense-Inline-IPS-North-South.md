# ADR-0038 — pfSense as a Transparent Inline IPS on the North-South Edge Transit

> 🟡 **RESHAPED by `ADR-0047` (2026-07-29) — pfSense is KEPT, its role redrawn.** When this ADR was written FGT01 ran no UTM (`ADR-0035`), so pfSense was the **sole** N-S prevention. The operator is now buying the FortiGuard UTM subscription (`ADR-0047`), so **FGT01 UTM becomes the licensed N-S content-inspection layer** and pfSense is retained as the **free/complementary inline IPS + the free-vs-licensed comparison** for the FCP/NSE track — no longer the only thing dropping on the N-S path. The placement (transparent bridge on FGT01↔1941) and everything below are unchanged; only the "sole prevention" framing is superseded. This settles the Review-Trigger overlap question (below) in favour of **keep, don't retire**.

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-29). **Reshaped by `ADR-0047`** (2026-07-29) — kept as free/complementary IPS + comparison; no longer sole N-S prevention. Not built. **Build sub-decisions RESOLVED 2026-07-30 (v1.2): physical 2-NIC appliance · fail-CLOSED · monitor-only-first rollout · Suricata engine.** |
| Governing Policy | POL-0007 (+POL-0009) |
| Scope | **Lab-02** (Cisco-Core) — network security architecture; defines the estate's IDS/**IPS** division of labor. |
| Date | 2026-07-29 |
| Supersedes | — |
| Related | `ADR-0047` (FGT01 FortiGuard UTM — the licensed N-S layer this now complements) · `ADR-0035` (FGT01 no-UTM — the gap this originally filled; reversed by `ADR-0047`) · `ADR-0023` (1941-core / MKT01 east-west topology) · `ADR-0032` (Diagnostics + the Suricata monitoring architecture) · `SIEM01-Wazuh` (host SIEM) · `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` · `Pre-Build-Decisions.md` D1/D2. |
| Governing docs | `Service-Server-Build-Plan.md` (estate) · future `Devices/PFSENSE01-IPS/` · `Architecture/IP-Addressing-Plan-VLSM.md`. |
| Evidence Status | **Decision** (operator, 2026-07-29). Governs design; nothing built yet. |

## Context

The estate has strong **detection** but no inline **prevention** on the internet-facing path:

- **Suricata on the SW01 SPAN** (MON01) is **passive** — it sees a mirror of the MKT01 trunk and *alerts*, but it cannot *drop*.
- **FGT01 deliberately runs without UTM** (`ADR-0035` — no FortiGuard licence; the stale 2015–2018 signatures are never attached). So nothing on the north-south path can actively block an exploit, a C2 callback, or a known-bad payload.
- **East-west is already handled:** MKT01 is the east-west segmentation firewall with **default-deny** (`ADR-0023`), so lateral movement is policy-blocked, and Suricata + Wazuh detect it.

The operator wants **pfSense added as an IDS/IPS**, and — via `Pre-Build-Decisions` D1 — chose **inline (true IPS)** over passive. The learning goal (Security+, CCNA/CCNP security, and a **free-vs-licensed** comparison against FortiGate's IPS for the **FCP/NSE** track) makes an inline IPS high-value. The open question this ADR closes is **where in the path it sits** (D2).

## Decision

Deploy **pfSense as a transparent (bridging) inline IPS on the north-south edge transit — the FGT01 ↔ 1941 link** — running **Suricata (or Snort) in inline IPS mode**. It becomes the estate's **prevention** layer for north-south (internet-facing) traffic.

Load-bearing choices:

1. **Inline, not passive** (D1). Passive duplicates the existing Suricata SPAN and cannot drop; the point is prevention. pfSense sits in the traffic path so it can block.
2. **Transparent bridge, not a routed hop** (D2). pfSense **bridges the FGT01↔1941 /30 transit** and inspects+drops at L2 — it takes **no IP in the routed path**, runs no OSPF, and changes no topology. The 1941 core routing and the FGT↔1941 adjacency are untouched; pfSense is a **bump-in-the-wire**.
3. **North-south, not east-west** (D2). It sits on the single N-S **choke point** — all internet-bound traffic from every internal VLAN crosses FGT↔1941 — filling exactly the gap FGT01's absent UTM leaves. East-west prevention stays with MKT01's default-deny.
4. **Complements the detection stack** — the division of labor is: **pfSense = N-S prevention (drop)** · **MKT01 = E-W prevention (policy default-deny)** · **Suricata-on-SPAN (MON01) = network detection** · **Wazuh (SIEM01) = host detection/SIEM**. pfSense's own alerts ship to MON01/Wazuh so detection stays one pane. *(🟡 `ADR-0047` update: with FGT01 now running licensed UTM, the N-S prevention row reads **FGT01 UTM = licensed N-S content inspection at the edge** · **pfSense = free/complementary inline IPS on the transit + the free-vs-licensed comparison**. pfSense is defence-in-depth behind the licensed edge, not the sole dropper.)*

## Alternatives Considered

- **Passive IDS on a SPAN (like Suricata).** Rejected — detection-only, redundant with the existing Suricata SPAN; no prevention (the stated goal).
- **Inline east-west (on the MKT01↔SW01 trunk / as the inter-VLAN gateway).** Rejected — MKT01 already owns east-west with default-deny; a second inline device there duplicates policy, complicates the inter-VLAN path, and risks a lockout on the segmentation core.
- **pfSense in front of FGT01 (the very edge).** Rejected — makes pfSense the perimeter device, competing with FGT01's designated N-S role (`ADR-0023`) and inspecting pre-NAT internet noise. FGT stays the edge; pfSense inspects behind it.
- **Routed hop (pfSense as an L3 device on the transit).** Rejected in favor of the transparent bridge — a routed pfSense inserts another routing domain, another next-hop/OSPF concern, and more failure surface; a filtering bridge gives the same inspection with no topology change.
- **License FortiGate UTM instead.** ~~Rejected for now (`ADR-0035` stands).~~ 🟡 **Now decided by `ADR-0047`** (2026-07-29): the operator is buying FortiGuard UTM, so FGT01 **does** run licensed UTM as the N-S content-inspection layer — *and* pfSense is kept, because pfSense-free IPS is the better *learning* artifact and the **free-vs-licensed comparison** point for FCP/NSE. Not either/or: both run, one licensed edge + one free complementary inline IPS.
- **Per-segment IPS (in front of the server VLAN / DMZ).** Deferred — more granular, more complex; revisit for the DMZ (VLAN 80) or OT (VLAN 90) once the N-S IPS is proven.

## Consequences

- A new device enters the estate: **PFSENSE01 (inline IPS)** — gets its own `Devices/PFSENSE01-IPS/` folder + Roadmap in the definition pass; only a **management IP** is needed (the data path is a transparent bridge), owned by the IP plan.
- ✅ **Physical deployment — DECIDED (operator 2026-07-30, `Pre-Build-Decisions` D2a): a small low-power physical appliance with 2 NICs** bridging the transit cable (option a) — keeps PVE01 off the N-S/internet path (an edge IPS should not depend on the hypervisor). The pfSense-VM-on-PVE01 option (b) was **rejected** (adds PVE01 as a failure point on the internet path). 📋 Hardware to acquire (a 2+ NIC mini-PC / SFF box); `Devices/PFSENSE01-IPS/` gets a gated stub until it exists. Only a **management IP** is needed — 📋 proposed **VLAN 10 (mgmt)**; the data path is a transparent bridge with **no data-plane IP** (owned by the IP plan).
- ✅ **Fail mode — DECIDED (operator 2026-07-30): fail-CLOSED** (block on failure) — the enterprise-strict posture: no traffic passes uninspected. 🔴 **Tradeoff (accepted):** a pfSense fault cuts the estate's internet until it recovers — an availability hit a homelab normally avoids. **Mitigations required by this choice:** (i) a documented **manual transit-bypass break-glass** — re-cable the FGT01↔1941 transit **directly** to restore internet fast while pfSense is down; (ii) the **monitor-only-first rollout** (below) so blocking is only enabled once tuned; (iii) the Review-Trigger fallback to **fail-open / monitor-only** if fail-closed causes real outages. Box reliability matters *more* under fail-closed — keep the appliance simple + its config backed up.
- ✅ **Rollout — DECIDED (operator 2026-07-30): monitor-only (IDS) first → enable inline blocking per rule category after tuning** (incremental, `ADR-0041`) — baseline traffic + tune out false positives passively, *then* flip to inline-drop category-by-category. Especially important under fail-closed (an untuned drop rule would otherwise cut the internet).
- ✅ **IPS engine — Suricata** (consistency with MON01's Suricata-on-SPAN — reuse the same rule sets + tuning skills; Snort was the alternative). pfSense's Suricata alerts ship to MON01/Wazuh so detection stays one pane.
- **No routing/OSPF impact** — the transparent bridge does not participate in L3; the 1941 core + FGT adjacency are unchanged.
- **Certification value:** inline-IPS concepts (Security+, CCNA/CCNP security) + a free (pfSense/Suricata) vs licensed (FortiGate IPS) comparison for the **FCP/NSE** track.

## Review Trigger

- If the inline IPS adds latency/instability on the internet path: fall back to fail-open + tuned rule categories, or run **monitor-only (IDS mode)** until tuned, then re-enable blocking.
- If east-west threats become the priority: revisit a **per-segment** inline IPS in front of the DMZ/OT rather than widening this N-S box's scope.
- ~~If a FortiGate UTM bundle is ever purchased (revisits `ADR-0035`): reconcile the overlap — likely keep pfSense as the learning/comparison artifact, or retire it.~~ ✅ **Fired + resolved by `ADR-0047`** (2026-07-29): bundle purchased; overlap reconciled → **keep pfSense** as the free/complementary IPS + free-vs-licensed comparison.

## Change Log

| Version | Changes |
|---|---|
| 1.2 | 2026-07-30. **Build sub-decisions RESOLVED (operator; `ADR-0049` ask-at-planning).** D2a → **physical low-power 2-NIC appliance** (option a; PVE01 off the internet path); **fail-CLOSED** (enterprise-strict — mitigated by a required **manual transit-bypass break-glass** + the monitor-first rollout + the fail-open Review-Trigger fallback); **rollout = monitor-only (IDS) first → enable blocking per category after tuning** (`ADR-0041`); **engine = Suricata** (MON01 consistency). Only a mgmt IP needed (📋 proposed VLAN 10). Feeds `Devices/PFSENSE01-IPS/`. Placement/topology from v1.0 unchanged. |
| 1.1 | 2026-07-29. **Reshaped by `ADR-0047`.** The operator is buying FortiGuard UTM (reverses `ADR-0035`), so FGT01 UTM becomes the licensed N-S content-inspection layer and pfSense is **kept, role redrawn** — the **free/complementary inline IPS + the free-vs-licensed comparison** for FCP/NSE, no longer the sole N-S prevention. Added the reshape banner + Status/Related annotations; annotated the "License FortiGate UTM instead" alternative (now decided) + the fired-and-resolved Review Trigger (keep, don't retire) + the division-of-labor note. Placement/topology unchanged. |
| 1.0 | 2026-07-29. Accepted. pfSense as a **transparent inline IPS** (Suricata/Snort) on the **FGT01↔1941 north-south transit** — the estate's prevention layer, filling the gap left by FGT01's no-UTM (`ADR-0035`). Division of labor with MKT01 (E-W policy) + Suricata-SPAN/Wazuh (detection). Chose inline over passive (D1), transparent-bridge over routed, N-S over E-W (D2). Flagged physical-appliance-vs-VM (D2a) + fail-open/closed as build-time sub-decisions. |
