---
Title: Identity-Aware vs Zone/Subnet Firewall Policy (FSSO) — and why real networks run both
Path: Atlas-Academy/Concepts
Status: 🟢 Academy concept module (Network N4 / `ADR-0032` concept layer). The "why it works" companion to the FGT01 K3 decision. The build is PROPOSED (Backlog) — this explains the reasoning so the decision can be made right.
Version: 1.0
Date: 2026-07-30
---

# Identity-Aware vs Zone/Subnet Firewall Policy (one-pager)

<!-- provenance -->
> **Atlas Academy — Concepts.** A "why it works" module. Every claim points at a **real Atlas artifact**. This one exists because the operator asked the honest question at FGT01 planning (2026-07-30): *"Is FSSO the enterprise standard, or is zone/subnet more popular — and what do I lose if I don't pick one?"* Short answer: **it's not a choice — mature networks run both, layered.** The FGT01 build of the identity layer (FSSO) is **proposed**, not committed — see the Backlog item + `Devices/FGT01-Perimeter-Firewall/Considerations.md` (K3).

> **The gap this closes:** firewall rules can match on **where traffic comes from** (a subnet/zone) or **who is sending it** (a user/group). Newcomers think they must choose. They don't — and knowing *why* is the point.

## The Concept

A firewall rule needs a **source**. There are two ways to express it:

- **Zone/subnet policy (the structural base).** The source is an **address** — a VLAN, a subnet, a zone (`CLIENTS 10.50.0.0/25`, `SERVERS 10.20.0.0/26`). This is the **foundation of every firewall on earth**: it's how you get default-deny between zones, segmentation, and the Purdue/OT isolation. You **always** have this layer; you cannot "not choose" it.
- **Identity-aware policy (the layer on top).** The source is a **user or AD group** — "`G-Sales` may reach the internet but not the finance app," "`G-IT-Staff` gets a looser web-filter profile." The firewall learns *which IP is which user right now* from the directory. On FortiGate that mechanism is **FSSO (Fortinet Single-Sign-On)**; Palo Alto calls the same idea **User-ID**. It **rides on** the zone base — it refines *within* a zone, it doesn't replace the zone.

**So the real enterprise pattern is BOTH, together:** zone/subnet as the structural skeleton (segmentation, default-deny, OT isolation), **plus** identity-awareness layered on for user/group rules and for **usernames in the logs**. Identity-aware NGFW policy is increasingly standard in AD-based organizations — but it is an *enhancement on* the zone base, never a substitute for it.

## The Atlas Example (real artifacts)

- **The zone base already exists in Atlas.** `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` is a **zone→zone** matrix (CLIENTS→SERVERS:443, the Tier-0 micro-zone `#9`, the OT conduit `#11–#13`). **MKT01** renders it east-west; **FGT01** egress zones render it north-south. This is the structural layer — it is not going anywhere.
- **The identity layer is proposed on FGT01.** With **FSSO** reading AD logon events (agentless polling of the DCs, or a DC collector agent), FGT01 egress/UTM policy could become **user/group-aware** — e.g. a stricter web-filter profile for `G-Sales` than `G-IT-Staff`, and every N-S log line carrying a **username** instead of just an IP. It layers on top of the existing egress zones.
- **It ties to the tiered identity Atlas already built.** The AGDLP groups (`G-Tier0/1/2-Admins`, `G-IT-Staff`, dept globals) that drive AD access (`Concepts/Tiered-Admin-Model.md`) become the **same source objects** the firewall matches on — one identity model, reused at the perimeter.

## The Tradeoff — what you gain and lose each way

| | Zone/subnet only | + Identity-aware (FSSO) layered on |
|---|---|---|
| Segmentation / default-deny / OT isolation | ✅ yes (the base) | ✅ yes (unchanged — it's the base) |
| User/group-aware rules ("Sales ≠ IT") | ❌ no — IP/subnet is a *brittle proxy* for identity (DHCP churn, shared/roaming hosts, RDS session hosts where many users share one IP) | ✅ yes — rules match the actual AD user/group |
| **Usernames in firewall logs** (attribution / forensics) | ❌ no — you see an IP and have to correlate to DHCP/AD to find the human | ✅ yes — the log line names the user; incident response is faster |
| Per-user UTM / web-filter profiles | ❌ no | ✅ yes |
| Complexity / dependencies | ✅ lowest — no DC dependency | ⚠️ more — depends on the DC + FSSO agent/polling; another moving part to monitor |

**What you lose by NOT adding FSSO:** user-aware policy, usernames in your logs, and per-user profiles — you fall back to treating an IP as if it were a person, which breaks on DHCP, shared hosts, and RDS. **What you lose by NOT having zone/subnet:** everything — it's the base; this option doesn't really exist.

## The Atlas plan (PROPOSED — two-phase, "both together")

The operator's instinct is right: **run both.** Proposed as a two-phase learning lab (deferred to the refinement pass; Backlog item owns the detail):

1. **Phase 1 — learn FSSO standalone.** Stand up FSSO on FGT01 (agentless AD polling first — least footprint), prove one **user/group-aware egress rule** and a log line that carries a **username**. Goal: understand the mechanism.
2. **Phase 2 — integrate + run alongside the zone policy.** Keep the full zone/subnet flows-matrix policy as the base; layer FSSO group rules on top (e.g. dept web-filter profiles); decide **collector-agent vs agentless polling** for the estate. Goal: the real enterprise pattern, both layers live.

Until then FGT01 stays **zone/subnet-based** (the base, already built) and FSSO is a designed gated stub. Cert-aligned: **FortiGate FCP (FSSO)** + Security+ (identity-aware policy) + the CCNA/CCNP segmentation base.

## How to Explain This in an Interview

*"Firewall rules need a source, and you can express it two ways — by address (zone/subnet) or by identity (user/group). They're not alternatives: zone/subnet is the structural base every firewall has — it's how you do segmentation and default-deny — and identity-awareness, FSSO on FortiGate or User-ID on Palo Alto, layers on top so you can write 'Sales can't reach this, IT can' and get usernames in your logs instead of bare IPs. In my lab the east-west matrix and the perimeter egress are zone-based today, and I've scoped FSSO as a second phase that reads AD logon events and reuses the same AD groups that drive my tiered-admin model — so one identity model runs from the domain all the way to the firewall. The thing you lose without the identity layer is attribution: an IP is a brittle stand-in for a person once you have DHCP, shared hosts, or RDS."*

## Related
- `Devices/FGT01-Perimeter-Firewall/Considerations.md` + `Roadmap.md` (K1/K2/K3 record) · `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (the zone base) · `Concepts/Tiered-Admin-Model.md` (the AD groups reused at the perimeter) · `Atlas-Academy/Atlas-FortiGate-FCP-Lab-Map.md` (FSSO objective) · `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md` (the proposed FSSO lab item) · `Atlas-Academy/Concepts/README.md` (concept index, N4).
