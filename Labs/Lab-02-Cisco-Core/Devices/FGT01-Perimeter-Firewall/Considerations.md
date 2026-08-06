---
Title: FGT01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟠 LIVING — open risks/decisions on the N-S perimeter. Closed items → Build-Record / Change Log. Records the Section-K K1/K2/K3 dispositions.
Version: 0.2
Date: 2026-07-30
---

# FGT01 — Considerations (open risks & decisions)

> The "what could bite us" list for the perimeter — separate from the FortiOS steps (`Build-Guide-*`) and the `get` checks (`Diagnostics.md`). Facts linked to owners (`POL-0008`).

## Decided (operator 2026-07-30) — the Section-K calls FGT01 carries
- ✅ **K1 — TLS/SSL deep-inspection = *selective* + ICA01 inspection-CA via GPO.** Deep-inspect (decrypt) outbound web for the **client/user zones** with **exclusions** (banking/health/privacy + certificate-pinned apps → certificate-inspection-only); the FGT re-signing CA is a **subordinate issued by ICA01**, pushed to domain machines' Trusted Root via **GPO**. **Formalized → `ADR-0050`** (2026-07-30); `Pre-Build-Decisions` §K1 → ✅. ⚠️ 60E throughput ceiling — size the scope.
- ✅ **K2 — DNS filtering stays on Pi-hole; FortiGuard DNS filter OFF.** One DNS-control home (the non-domain Pi-hole forwarder, `../Pi01-DNS-NTP/`); FGT UTM does web/AV/IPS/app-control, **not** DNS filtering — avoids two overlapping filters + the split-brain of two blocklists. **Formalized → `ADR-0051`** (2026-07-30; refines the earlier "both, layered" Section-K rec to single-owner); `Pre-Build-Decisions` §K2 → ✅.
- 🔎 **K3 — FSSO / identity-aware policy = PROPOSED (deferred to the refinement pass; no build commitment).** **Not either/or:** zone/subnet is the structural base (already built), FSSO layers identity-awareness on top — **run both together**. Plan = a two-phase learning lab (learn FSSO → integrate with AD, alongside the zone policy). Fully written up: `Atlas-Academy/Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` + a Backlog item. Decide firmly in the #22 refinement pass.

## Open gates
- 🔴 **The confidence trap (`ADR-0047`/`ADR-0035`).** A UTM profile is worthless with a stale DB or a lapsed subscription. **`get system status`** must confirm an active subscription + fresh signatures **before any profile is trusted**; a lapse reverts to *detach the profile, don't run it stale.* This is a standing verify-duty, not a one-time check (`POL-0001`).
- 🔴 **UTM + TLS deep-inspection gated** on the **ICA01 CA cert** (K1) **+** a verified live subscription (`Build-Guide-3`, Phase 8). Nothing to inspect-decrypt until the inspection CA exists and is GPO-trusted.
- 🔴 **Direct-LDAPS admin auth gated** on the DC LDAPS cert (`ADR-0028`, `Build-Guide-2b`) — keep the `fortigateadmin` local break-glass regardless.

## Standing risks (design)
- 🔴 **Single N-S chokepoint (blast radius).** All egress + the inbound perimeter ride FGT01; a bad local-in policy or UTM change can cut the estate off or lock mgmt out — the **`192.168.1.99` / console break-glass** is the recovery path; test it before risky changes.
- 🔴 **`get`, not `show`.** FortiOS `set admin-server-cert` once silently didn't take (`MC-0001`) — always read state back with `get` (`POL-0001`).
- 🟡 **Inspection division of labor (context — decided elsewhere).** FGT01 UTM = **N-S content inspection** (`ADR-0047`); **pfSense** = the free **inline IPS** on the FGT↔1941 transit (`ADR-0038`); **MON01 Suricata** = network *detection*; **MKT01** = east-west prevention. FGT01 is not the east-west filter and not the only inspector — keep the planes distinct.
- 🟡 **TLS deep-inspection breakage.** Even selective, decryption breaks certificate-pinned apps + can raise privacy/legal questions — hence the exclusion list (K1). Tune the exempt categories carefully.

## Open decisions (need a call / ADR when reached)
- ~~**K1/K2 ADRs**~~ — ✅ **written 2026-07-30:** K1 → `ADR-0050`, K2 → `ADR-0051`; `Pre-Build-Decisions` §K1/§K2 → ✅; `ADR-Index` v1.22.
- **K3 FSSO** — the firm decision + the two-phase build, in the refinement pass (concept + Backlog own the context).
- **FSSO collector-agent vs agentless polling** — a K3 sub-choice, when K3 is built.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Build-Guide-Index.md` (+ `-1`/`-2`/`-2b`; `-3` gated) · `Logging-and-Flow-Tracing-Field-Guide.md` · `Diagnostics.md` · `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` · `ADR-0047`/`ADR-0050`/`ADR-0051`/`ADR-0038`/`ADR-0028` · `Atlas-Academy/Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` · `Atlas-Academy/Atlas-FortiGate-FCP-Lab-Map.md`.

## Change Log
| Version | Date | Change |
| 0.2 | 2026-07-30 | Section-K **K1/K2 ADRs written** — resolved the owed thread: K1 → **`ADR-0050`** (selective TLS deep-inspect + ICA01 inspection-CA GPO distribution), K2 → **`ADR-0051`** (Pi-hole owns DNS filtering, FGT DNS-filter OFF — refines the earlier "both, layered" rec). `Pre-Build-Decisions` §K1/§K2 → ✅; `ADR-Index` → v1.22. |
| 0.1 | 2026-07-30 | Created — recorded the **Section-K decisions** (K1 selective deep-inspect + ICA01 inspection-CA via GPO ✅; K2 Pi-hole owns DNS filtering, FGT DNS filter OFF ✅; K3 FSSO identity-layer PROPOSED — both-together, two-phase, deferred → concept + Backlog); open gates (the confidence trap; UTM/TLS gated on ICA01 + live subscription; LDAPS admin gated); standing risks (single-chokepoint blast radius; `get`-not-`show`; the inspection division of labor; TLS-inspection breakage). Section-K ADRs for K1/K2 owed. |
