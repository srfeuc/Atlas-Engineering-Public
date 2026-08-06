---
Title: WSUS01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management
Status: 🟠 LIVING — open risks + unsettled decisions for the WSUS host.
Version: 1.1
Date: 2026-07-30
---

# WSUS01 — Considerations (open risks & decisions)

## Open gates
- 🔴 **First-sync egress is large.** The initial WSUS sync pulls a lot from Microsoft Update (N-S). Confirm FGT01 egress is open to the MS endpoints; note the throughput will be **UTM-inspected once `ADR-0047` is live** — a slow first sync is expected (operator: OK-slow). Don't decline-superseded until after the first full sync completes.
- 🔴 **Content-store storage.** Updates are large + grow; the content store **must be its own vdisk** on the R410, sized with headroom, not the OS disk. Schedule cleanup/decline-superseded to keep it bounded.

## Standing risks (design)
- 🟡 **Uptime tradeoff (deliberate).** On the mostly-off R410, clients only pull updates when it's up. Acceptable (patch during lab sessions); the risk is *forgetting* to run patch cycles. Mitigate by pairing patch cycles with R410 spin-ups + tracking compliance. Revisit in #20 if continuous patching is wanted.
- 🟡 **WSUS is being de-emphasized by Microsoft** in favour of cloud/Intune update management. For the lab it's still the right on-prem learning artifact (AZ-800/801); the modern path is **Intune co-management** (Phase H2). Document both; don't over-invest in WSUS-only tooling.
- **Approval discipline.** Auto-approving everything defeats the ring model; keep **pilot → broad** with a hold, or a bad update hits everything at once.

## Open decisions (need a call / ADR when reached)
- 🟡 **WID vs SQL01 backend** — WID is fine at lab scale; point at SQL01 only if reporting/scale needs it. Default **WID**.
- 🟡 **Placement (#20).** PVE01/R410 recommended (storage + non-critical); confirm in the capacity pass.
- 🟡 **Address `10.20.0.15`** is proposed — authoritative in `IP-Addressing-Plan-VLSM` (`POL-0008`).

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27) — the sync/approval/reporting rows + protocol/port on every diagram edge (`updates · 8530/8531`, `N-S egress · HTTPS/443`, …). All rows honest ⬜ (not built, `POL-0001`).
- **No separate `Networking-Build-Guide.md` for WSUS01** *(operator policy — appliances point, hosts get new)*. Standard tagged-VLAN-20 VM; the one N-S subtlety (first-sync egress crossing FGT UTM) already lives in Open gates (`POL-0008`).

## Related
- `Roadmap.md` · `Build-Checklist.md` · `ADR-0047` (UTM inspects the sync) · Backlog #18 (SCAP) / #20 (sizing/placement) · `../../Operations/Device-Hardening-Standard.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** added a **Decided** section — Services map + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27, all ⬜); no separate `Networking-Build-Guide.md` (standard VLAN-20 VM). |
| 1.0 | 2026-07-30. Created — open gates (first-sync egress + the FGT-UTM cost, content-store storage), standing risks (the deliberate uptime tradeoff, WSUS-vs-Intune direction, approval discipline), and open decisions (WID-vs-SQL, placement #20, proposed IP). |
