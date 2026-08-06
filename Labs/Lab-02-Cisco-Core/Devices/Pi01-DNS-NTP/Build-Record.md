---
Title: Pi01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP
Status: ⬜ NOT BUILT — Pi01 is a planned rebuild to the reduced role. The `POL-0001` evidence home; every row ⬜/🟡 until a real read-back is captured. Records outrank guides.
Version: 0.1
Date: 2026-07-30
---

# Pi01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 rebuild).** The single "what is actually true right now" snapshot for the reduced DNS+NTP Pi — the `POL-0001` evidence home. **Records outrank guides** (guide = target; this = reality). Each row cites where the evidence lives (`POL-0008`). Markers: 🟡 operator-reported · ⬜ not built (nothing device-verified yet, so no verified marker appears here).

| Attribute | As-built target | Status | Evidence (when built) |
|---|---|---|---|
| Host / OS | Pi01 · Raspberry Pi OS Lite (64-bit) | ⬜ | `Diagnostics.md` §1 |
| Form factor | physical Raspberry Pi (bare-metal, not a VM) | ⬜ | `Diagnostics.md` §1 |
| Addressing | `10.10.0.6` /27 · VLAN 10 · gw `10.10.0.1` *(📋 proposed)* | ⬜ | `IP-Addressing-Plan-VLSM` |
| Silo | 🟡 Services | 🟡 | role assignment |
| Migrations OFF | FreeRADIUS→NPS01 · Vault→Vaultwarden · CA→offline all done | ⬜ | `ADR-0009` · wire check |
| chrony (NTP) | `chrony` installed **and the active daemon** (not timesyncd) | ⬜ | `chronyc tracking` |
| NTP hierarchy | syncs upstream per `ADR-0020`; serves non-domain/infra | ⬜ | `chronyc sources` |
| Pi-hole (DNS) | installed; upstream resolvers set; filtering active | ⬜ | `pihole status` |
| Conditional-forward | `atlas.lab` → the DCs (`ADR-0003`/`ADR-0007`) | ⬜ | `dig @10.10.0.6 <h>.atlas.lab` |
| Local DNS records | in v6 `dnsmasq.d` (**not** `custom.list`) + resolve | ⬜ | `Diagnostics.md` §3 |
| Host firewall | inbound `53`/`123`/`22` only | ⬜ | `nft list ruleset` |
| SD backup image | image + config tar kept (disposable box) | ⬜ | `Device-Backup-Runbook` |

> 🔴 **Nothing here is built yet.** As each stage lands, capture the read-back in `Diagnostics.md`, advance the row as evidence allows (🟡 once operator-reported), and tick the `Build-Checklist.md` gate (`POL-0001`). 🔴 **DHCP is not on this box** (`ADR-0030`) — do not add a DHCP row.

## Related
- `Build-Checklist.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md` · `ADR-0009` · `ADR-0020` · `ADR-0003`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the (empty) as-built record for the Pi01 reduced-role rebuild — all rows ⬜/🟡 (not built); fills in as each stage is device-verified. Foregrounds the bare-metal form factor, the migrations-off gate, chrony-as-active-daemon, and the v6 `dnsmasq.d` records. |
