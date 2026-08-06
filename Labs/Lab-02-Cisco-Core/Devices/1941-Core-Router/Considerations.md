---
Title: 1941 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: 🟠 LIVING — open risks/decisions on the routed core. Closed items → Build-Record / Change Log.
Version: 0.5
Date: 2026-08-05
---

# 1941 — Considerations (open risks & decisions)

> The "what could bite us" list for the routed core — separate from the CLI steps (`Build-Guide.md`) and the `show` checks (`Diagnostics.md`). Facts linked to owners (`POL-0008`).

## Open gates
- 🔴 **Pass-2 AD-RADIUS not yet applied** (`ADR-0029`). Admin auth is still **local named-admin only**; it moves to **NPS01** ([`ADR-0029`](../../../../00-Atlas-Foundation/Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md)) once DC + AD CS (NPS server cert) + NPS01 exist. Keep **one local break-glass** account — never PKI-ify it (the box must stay reachable if AD/RADIUS is down). *(Why-layer: [Out-of-Band-Recovery](../../../../Atlas-Academy/Concepts/Out-of-Band-Recovery.md).)*
- 📋 **Management telemetry deferred** (Phase 4/6): NTP hardening to the `ADR-0020` source, and **SNMPv3 + syslog + NetFlow → MON01**. Until then the 1941 is under-observed and the Phase-7 flow evidence is incomplete.

## Standing risks (design)
- 🔴 **OSPF ↔ RouterOS (MKT01) interop.** The adjacency is Cisco-to-MikroTik; if it sticks it is almost always **MTU** (EXSTART/EXCHANGE → `ip ospf mtu-ignore` both ends or match MTU) or **network-type/DR** (INIT/2-WAY). Currently **FULL** (07-21) — re-check after any MKT01-side change.
- 🔴 **Asymmetric routing breaks MKT01's stateful inspection.** Request and reply must both transit the 1941 ([Firewall-Architecture](../../../../00-Atlas-Foundation/Reference/Atlas-Firewall-Architecture.md) §3.1). A "helpful" second path or a stray static can split a flow and silently drop half of it.
- 🔴 **Never originate VLAN routes here (`ADR-0023`).** No VLAN `network` statement, subinterface, or `switchport` — *in production*. The 1941 *learns* VLANs from MKT01; adding an SVI steals the inter-VLAN gateway role and breaks Option B. **Exception (sanctioned):** the temporary CCNA-lab overlay runs subinterfaces on purpose (see the overlay note below) — that is Option A, and it is reverted on teardown.
- 🔴 **Single-homed egress.** Egress is single-homed to FGT01 — a floating static for the default buys nothing (there is no second path to fail to). The only useful floating static is an AD-250 backup on the MKT01 leg, and it rides the same cable, so it guards an OSPF-*process* failure, not a link failure ([`POL-0013`](../../../../00-Atlas-Foundation/Policies/POL-0013-Business-Continuity.md) — be honest about that).
- 🟡 **Legacy-crypto SSH client.** The CIS ciphers mean a modern SSH client needs the legacy-algo flags in `~/.ssh/config` to connect (see `../../Architecture/CIS-Hardening-1941.md`).

## Open decisions (need a call / ADR when reached)
- **Zone-Based Firewall on the 1941** — Section K **K5** (a CCNP security topic): whether the core router also runs ZBF and how it divides labor with MKT01/FGT01. Its own ADR when decided.
- **OSPF neighbor authentication** — add OSPF auth on the MKT01 /30 (a CCNP/security hardening step) — decide with the Pass-2 wave.

## Decided (audit #22, 2026-07-30)
- **No separate `Networking-Build-Guide.md` for the 1941** *(operator policy, #22 planning — appliances point, hosts get new)*. The 1941 already carries **`Build-Guide.md` (v1.2, device-verified)** as the staged CLI/config procedure (base+hardening → interfaces → OSPF+default → mgmt telemetry); a dedicated **production** networking bring-up guide would duplicate it (`POL-0008`). The existing Build-Guide **is** the router's networking build guide — point to it.
- **Services map added to `README.md`** (Standard v1.7 backfill, Backlog #27) — the routing/control-plane service table (IP routing · OSPF area 0 · static-default→FGT01 · SSH mgmt · NTP · Pass-2 RADIUS · MON01 telemetry), Status mirroring `Build-Record.md` (`POL-0001`).

## Decided (#44, 2026-08-05)
- **A separate CCNA-overlay Build-Guide + Build-Record pair IS sanctioned** — [`Build-Guide-CCNA-Lab-Overlay.md`](./Build-Guide-CCNA-Lab-Overlay.md) + [`Build-Record-CCNA-Lab-Overlay.md`](./Build-Record-CCNA-Lab-Overlay.md) (operator, 2026-08-05). **This does not conflict with the #22 decision above:** #22 forbids a second *production* networking guide (which would duplicate the routes-only `Build-Guide.md`). The overlay pair documents a **different, temporary configuration state** — Option A (router-on-a-stick + ACLs) — that the production guide deliberately does not cover. The operator chose a **full standalone** overlay guide (not a thin pointer), so it carries the same config as the ⭐ [`Set-Up-the-1941-for-the-CCNA-Lab`](../../../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) Playbook **on purpose** — the Playbook is the Academy teaching companion; **keep the two in sync** if either changes.

## CCNA-lab overlay (temporary — router-on-a-stick + ACLs)

🟡 **For the CCNA lab the 1941 runs a *temporary overlay*: router-on-a-stick (a VLAN subinterface/gateway per VLAN on the SW01 trunk) + ACLs** — `ADR-0023` **Option A**, which that ADR explicitly keeps as *the CCNA/IOS learning vehicle*. This is **deliberate, not a violation of the no-VLANs rule** — do **not** "fix" the subinterfaces back out. The executable procedure of record is [`Build-Guide-CCNA-Lab-Overlay.md`](./Build-Guide-CCNA-Lab-Overlay.md) (with its evidence in [`Build-Record-CCNA-Lab-Overlay.md`](./Build-Record-CCNA-Lab-Overlay.md)); the teaching companion (why + exercises + revert) is the ⭐ standard Playbook **[`Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs`](../../../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md)**. **Production target after the CCNA lab = Option B** (1941 routes-only; MKT01 owns inter-VLAN + the east-west firewall) per [`Build-Checklist.md`](Build-Checklist.md). 🔴 One `.1` gateway per VLAN at a time — the 1941 holds them during the lab, MKT01 in production.

## Related
- [`Roadmap.md`](Roadmap.md) · [`Build-Checklist.md`](Build-Checklist.md) (failure modes) · [`Build-Guide.md`](Build-Guide.md) · [`Build-Guide-CCNA-Lab-Overlay.md`](Build-Guide-CCNA-Lab-Overlay.md) · [`Build-Record-CCNA-Lab-Overlay.md`](Build-Record-CCNA-Lab-Overlay.md) · [`Diagnostics.md`](Diagnostics.md) · [`CIS-Hardening-1941`](../../Architecture/CIS-Hardening-1941.md) · [`Validation-and-Adversarial-Testing`](../../Operations/Validation-and-Adversarial-Testing.md) · [`ADR-Index`](../../../../00-Atlas-Foundation/Decisions/ADR-Index.md) · 🎓 Academy: [`Out-of-Band-Recovery`](../../../../Atlas-Academy/Concepts/Out-of-Band-Recovery.md) (why-layer) · cert maps [CCNA](../../../../Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md) · [CCNP](../../../../Atlas-Academy/Certification/Atlas-CCNP-Lab-Map.md).

## Change Log
| Version | Date | Change |
| 0.5 | 2026-08-05 | **#44 — separate CCNA-overlay Build-Guide + Build-Record.** Added a **Decided (#44)** entry sanctioning the overlay pair and reconciling it with the #22 "no separate build guide" policy (that policy governs a *production* guide; the overlay documents the temporary Option-A state the production guide doesn't cover — full standalone, kept in sync with the ⭐ Playbook). Linked the new guide/record from the CCNA-overlay note + Related, and added the sanctioned-exception clause to the never-originate-VLANs standing risk. |
| 0.4 | 2026-08-04 | **#44 — CCNA-lab overlay note.** Recorded that the 1941 runs a *temporary* router-on-a-stick + ACLs overlay for the CCNA lab (`ADR-0023` Option A, the sanctioned learning vehicle) → the ⭐ standard Playbook; production target stays Option B (MKT01 E-W). So a future session doesn't remove the subinterfaces thinking they break the no-VLANs rule. |
| 0.3 | 2026-08-04 | **#43 Pass B** — Academy up-links: the break-glass gate now points at the `Out-of-Band-Recovery` Concept, and Related links the why-layer + CCNA/CCNP cert maps. No content change. |
| 0.2 | 2026-07-30 | **#22 audit:** added a **Decided** section — no separate `Networking-Build-Guide.md` (the existing `Build-Guide.md` v1.2 is the router's networking build guide, `POL-0008`); Services map backfilled into `README.md` (Standard v1.7 / Backlog #27). |
| 0.1 | 2026-07-30 | Created — open gates (Pass-2 RADIUS/NPS01; deferred NTP/SNMP/syslog/NetFlow), standing design risks (OSPF/RouterOS MTU interop; asymmetric routing vs MKT01 stateful; never-originate-VLANs; single-homed egress + honest floating-static; legacy-crypto client), open decisions (ZBF K5/CCNP; OSPF neighbor auth). |
