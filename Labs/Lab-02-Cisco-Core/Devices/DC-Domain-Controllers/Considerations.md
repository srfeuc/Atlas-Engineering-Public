---
Title: DC01/DC02 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
Status: 🟠 LIVING — the open risks, gates, and not-yet-settled decisions on the identity core. Closed items move to the Build-Record / Change Log.
Version: 1.3
Date: 2026-07-29
---

# DC01 / DC02 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled yet" list for the Tier-0 core — separate from the steps (`*-Build-Guide.md`) and the health checks (`Diagnostics-*.md`). Each item states the risk and its current disposition.

## Open gates
- 🔴 **DC02 read-back outstanding.** DC02 is operator-reported promoted (2026-07-28) but **not device-verified**; until `repadmin /replsummary` = 0 failures + a `dcdiag` pass are captured, treat redundancy as **unproven** (`POL-0001`).
- 🔴 **GPO Wave B (VBS / Credential Guard) gated** on a Proxmox `msinfo32` VBS check — the hypervisor must expose the CPU security features. Not a checkbox; a capability gate (Academy `W4`).
- 🔴 **Tier enforcement (7d) not yet applied.** Until the five cross-tier deny-logon GPOs exist, "tiered from day one" is structurally in place (groups + OUs) but **not enforced** — the flagship "Tier-2 can't touch Tier-0" test cannot pass yet.

- ✅ **Tier accounts — reconciled 2026-07-29 (was a 🔴 flag).** Confirmed **device-verified 07-22**: the accounts (`t0/t1/t2-seth`), off-built-in-Administrator, and Protected Users were built at Stage 8 (owner: `Build-Guide/DC01/Tiered-Admin-and-Groups-Build.md` Part 3; operator-confirmed). The retrofitted `Build-Record`/`Roadmap` had them stale-⬜ and are now corrected; the **live-state owner is `Diagnostics-DC01.md`** (`Get-ADUser`, `POL-0001`).

## Standing risks (design)
- 🔴 **Hypervisor time-sync vs `w32time` on the PDCe.** If the QEMU guest-agent time-sync re-enables and the source reverts to CMOS, domain time drifts and Kerberos/replication break. Standing check on the PDCe.
- 🔴 **Single point of authority.** DC01 currently holds all five FSMO roles (single domain). DC02 adds **directory** redundancy but **not** FSMO redundancy and **not** a second forest — it still depends on replication + time staying healthy (*what a second DC doesn't buy you*).
- **Domain Admins sprawl.** Keep membership near-empty; the "three forgotten temp DAs" lesson (`301`).

## Open decisions (need a call / ADR when reached)
- **DHCP failover topology** — `ADR-0030` puts DHCP on DC01; DC01/DC02 failover is "later." Decide split-scope vs failover mode once DC02 is verified.
- **gMSA rollout order** — which service takes the first gMSA (SQL01 is the natural first — Tier-A A1).
- **Pi01 conditional-forward cutover** — when to move `atlas.lab` resolution fully onto the DCs vs the interim `1.1.1.1` forwarder.

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27). The connections diagram now carries protocol/port on every edge (`Kerberos/88 · DNS/53 · GPO SMB/445`, `LDAPS/636`, `NTP/123`, …); the README carries a 10-row Services map (AD DS · DNS · Kerberos · PDCe/NTP · GPO/SYSVOL · KDS · LAPS · cert auto-enrol · DHCP ⬜ · RADIUS-backing), Status mirroring `Build-Record.md` (`POL-0001`).
- **No separate `Networking-Build-Guide.md` for the DC** *(operator policy — appliances point, hosts get new)*. The DC is a standard **tagged-VLAN-20 VM**; its network reach (PVE01→SW01→MKT01 gateway `10.20.0.1`) is owned by the hypervisor + switch pages (`POL-0008`), not a fiddly per-host bring-up.
- **Canonical-template check (this is the template everything was copied from): it holds.** The DC's deliberate call — the identity build as **flat staged role-docs** (OU · GPO · Tiered-Admin) rather than a `Roles/` subfolder — reads correctly and needs **no Standard tweak**; `Roles/` stays reserved for genuinely separate services (SRV01/MON01).

## Related
- `Roadmap.md` (where these sit in the build path) · `Build-Checklist.md` (line-item status) · `Troubleshooting.md` (incidents) · `../../Operations/Validation-and-Adversarial-Testing.md` (the tier-deny proof).

## Change Log
| Version | Changes |
|---|---|
| 1.3 | 2026-07-30. **#22 audit (canonical-template device):** added a **Decided** section — Services map + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27); no separate `Networking-Build-Guide.md` (standard VLAN-20 VM); canonical-template check passed (flat staged role-docs hold, no Standard tweak). |
| 1.2 | 2026-07-29. **Tier-accounts reconcile RESOLVED** — operator confirmed the accounts were built + secured **device-verified 07-22** (owner `Tiered-Admin-and-Groups-Build.md`); the stale `Build-Record`/`Roadmap` ⬜ were corrected to ✅. The Build-Guides (live during config) are authoritative; Build-Record/Roadmap were retrofitted after the fact. |
| 1.1 | 2026-07-29. Added a 🔴 **doc-state reconcile** gate — the tier **accounts** (`t0/t1/t2-seth`) are 📋 not-created per the DC’s authoritative Build-Checklist/Record/Roadmap, but `SESSION-HANDOFF.md` §3/§7 still call them device-verified (stale v4 carry-forward); flagged for a bench read-back. Audit consolidation. |
| 1.0 | 2026-07-29. Created — open gates, standing design risks, and open decisions for the Tier-0 identity core. |

