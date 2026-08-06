---
Title: SW01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch
Status: 🟠 LIVING — open risks/decisions on the L2 access switch. Closed items → Build-Record / Change Log.
Version: 0.2
Date: 2026-07-30
---

# SW01 — Considerations (open risks & decisions)

> The "what could bite us" list for the access switch — separate from the CLI steps (`Build-Guide.md`) and the `show` checks (`Diagnostics.md`). Facts linked to owners (`POL-0008`).

## Open gates
- 🔴 **Pass-2 AD-RADIUS not yet applied** (`ADR-0029`). Admin auth is still **local named-admin only**; it moves to **NPS01** once DC + AD CS + NPS01 exist. Keep **one local break-glass** account — the switch must stay manageable if AD/RADIUS is down.
- 🟡 **L2-fabric read-backs pending.** VLANs (10–90 + 999), the two trunks, the SPAN, and DAI are applied but not yet `show`-verified — flip 🟡→✅ from `Diagnostics.md` (`show vlan brief`, `show interfaces trunk`, `show monitor`, `show ip dhcp snooping`).

## Standing risks (design)
- 🔴 **Native-VLAN 999 mismatch on the PVE01 trunk.** SW01 and the PVE01 bridge must agree that the trunk's native VLAN is **999** (unused) — a mismatch drops or leaks untagged traffic. Owner of the rationale + options: `../../Architecture/SW01-PVE01-Native-VLAN-Options.md`.
- 🔴 **Hand-typed DAI `STATIC-HOSTS` — the "Pi01 mystery."** A stale/missing binding in the hand-typed Dynamic ARP Inspection list once **silently dropped Pi01** (reachable, then gone, no host-side error). Until the list is **generated from NetBox** (Phase 4, `POL-0004`), treat every hand edit as a drop risk; the structural fix is the NetBox render.
- 🔴 **SW01 is pure L2 (`ADR-0023`).** No `ip routing`, no SVIs beyond `Vlan10` mgmt. Adding an SVI to "route a little" steals the inter-VLAN gateway role from MKT01 and breaks the segmentation design.
- 🟡 **STP root placement.** The access switch should not silently become/represent the STP root in a way that surprises the topology; set the mode + root intentionally and add BPDU/root guard when 802.1X/edge hardening lands.
- 🟡 **OT VLAN 90 rides SW01 at L2 (per `00-Atlas-Foundation/Company-Profile/305-Atlas-Industrial-Security-Requirements.md`).** The switch *carries* VLAN 90, but the **OT isolation + the single IT→OT conduit are enforced at MKT01** (flows-matrix #11–#13), not here. Don't add cross-VLAN reachability at L2 that would undercut 305's Purdue segmentation.

## Open decisions (need a call / ADR when reached)
- **802.1X port-based auth** (with NPS01) — whether access ports authenticate endpoints; decide with the Pass-2 / client-fleet wave.
- **STP hardening** — BPDU guard / root guard / loop guard scope on the edge.
- **DAI-from-NetBox cutover timing** — when the generated binding list replaces the hand-typed one (Phase 4, gated on NetBox load).

## Decided (audit #22, 2026-07-30)
- **No separate `Networking-Build-Guide.md` for SW01** *(operator policy, #22 planning — appliances point, hosts get new)*. SW01 already carries **`Build-Guide.md`** as the staged CLI/config procedure (base+hardening → VLANs → trunks → STP → SPAN → DHCP-snooping/DAI → port-security); a dedicated networking bring-up guide would duplicate it (`POL-0008`). The existing Build-Guide **is** the switch's networking build guide — point to it.
- **Services map added to `README.md`** (Standard v1.7 backfill, Backlog #27) — the interface-bound switch-service table, Status mirroring `Build-Record.md` (`POL-0001`).

## Related
- `Roadmap.md` · `Build-Checklist.md` (failure modes) · `Build-Guide.md` · `Diagnostics.md` · `../../Architecture/CIS-Hardening-SW01.md` · `../../Architecture/SW01-PVE01-Native-VLAN-Options.md` · `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Date | Change |
| 0.2 | 2026-07-30 | **#22 audit:** added a **Decided** section — no separate `Networking-Build-Guide.md` (the existing `Build-Guide.md` is the switch's networking build guide, `POL-0008`); Services map backfilled into `README.md` (Standard v1.7 / Backlog #27). |
| 0.1 | 2026-07-30 | Created — open gates (Pass-2 RADIUS/NPS01; the 🟡 L2-fabric read-backs), standing risks (native-VLAN-999 mismatch; the hand-typed DAI "Pi01 mystery" → NetBox; pure-L2 no-routing; STP root placement; OT VLAN 90 carried per 305 but isolated at MKT01), open decisions (802.1X; STP hardening; DAI-from-NetBox cutover). |
