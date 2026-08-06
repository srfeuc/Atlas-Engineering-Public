# ADR-0051 — DNS-Filtering Ownership: Pi-hole Owns It, FortiGuard DNS-Filter Off (Section-K K2)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-30) — recorded at the FGT01 #22/Batch-C+D pass. **Refines the earlier Section-K K2 "both, layered" recommendation** (2026-07-29) to a single-owner model. |
| Governing Policy | POL-0004 (+POL-0007) |
| Scope | **Lab-02-Cisco-Core** — DNS-filtering / content-control ownership across the estate's two candidate homes (Pi-hole vs FortiGuard DNS filter). |
| Date | 2026-07-30 |
| Supersedes | **Refines `Pre-Build-Decisions.md` §K2** — the 2026-07-29 recommendation ("both, layered — Pi-hole LAN + FortiGuard edge") is superseded by this single-owner decision (see Context). No ADR superseded. |
| Related | `ADR-0047` (FGT01 FortiGuard UTM — the layer whose DNS-filter is turned **off** here) · `ADR-0003` (AD-DNS vs OpenSSL — the DNS boundary) · `ADR-0007` (`atlas.lab` suffix) · `ADR-0030` (DHCP on DC01, not Pi01) · `ADR-0009` (Pi01 SPOF reduction — crown jewels moved off) · `ADR-0050` (K1 TLS deep-inspection — the sibling Section-K ADR) · `Devices/Pi01-DNS-NTP/` (the DNS-filter home) · `Devices/FGT01-Perimeter-Firewall/Considerations.md` (K2 "Decided") · `Pre-Build-Decisions.md` §K2 · `Atlas-Firewall-Architecture.md`. |
| Governing docs | `Atlas-Firewall-Architecture.md` (inspection division of labor) · `Devices/Pi01-DNS-NTP/` (Pi-hole role) · `Devices/FGT01-*` (Build-Guide-3 — DNS filter left off). |
| Evidence Status | **Decision / plan.** Pi01 is a 📋 rebuild (Pi-hole + chrony); FGT01 UTM is unbuilt. The decision is a *configuration posture* (which box filters DNS) — proven at build by: Pi-hole sinkholes a test domain **and** the FGT DNS-filter profile is confirmed **not attached** (`POL-0001`). |

## Context

Two boxes in the estate can filter DNS: **Pi-hole on Pi01** (the non-domain filtering forwarder, `ADR-0003`/`ADR-0007`) and the **FortiGuard DNS filter** that ships with FGT01's UTM bundle (`ADR-0047`). DNS filtering is a **content-control** layer — block a domain at resolution time — and having *two* independent blocklists on the same traffic path creates a classic operational hazard: **split-brain filtering.** When a site is blocked, which box did it? When a false positive needs an allow, where's the allowlist? Two overlapping filters double the troubleshooting surface and the drift risk for no added coverage the other layers (web-category filtering at the FGT, sinkholing at Pi-hole) don't already give.

The **Section-K cluster** (2026-07-29) initially recommended **"both, layered"** — Pi-hole as the LAN sinkhole/ad-block + logging, FortiGuard DNS filter as the edge category/threat layer, with "documented non-overlapping roles." On working the FGT01 build (2026-07-30), the operator **refined** that: the "non-overlapping roles" split is easy to say and hard to keep — in practice the two *do* overlap (both block domains), and the estate already has **one clear DNS-control home** in Pi-hole. So the refined call is **one owner**, not two layered filters.

The open question K2 closes: **who owns DNS filtering — and is the FortiGuard DNS filter on or off?**

## Decision

**Pi-hole (on Pi01) is the single DNS-filtering / DNS-control home for the estate. The FortiGuard DNS filter (FGT01 UTM) stays OFF.** FGT01's UTM does **web filtering (category), Application Control, Antivirus, and IPS** (`ADR-0047`) — but **not** DNS filtering; that job is Pi-hole's alone.

Load-bearing choices:

1. **One DNS-control home.** Pi-hole owns the estate's DNS blocklists/allowlists and sinkholing. There is exactly one place to ask "why was this domain blocked" and one place to add an allow — no split-brain.
2. **FortiGuard DNS filter profile is left unattached.** It is a real capability the licence includes, deliberately **not used**, to avoid a second overlapping DNS filter. (The *other* FortiGuard UTM profiles — web/AV/IPS/app-control — are still on per `ADR-0047`; only the **DNS-filter** profile is off.)
3. **The layers don't fight — they're different jobs.** DNS filtering (Pi-hole) blocks at *resolution*; FGT **web filtering** blocks at *connection* by category, and **deep inspection** (`ADR-0050`) inspects *payload*. These are complementary at different layers of the same request, not two copies of the same DNS filter. Keeping DNS-control single-homed doesn't weaken the edge — the FGT still category-filters and inspects; it just doesn't *also* re-implement Pi-hole.
4. **Consistent with the Pi01 role decisions.** Pi01's whole current identity is **Pi-hole filtering DNS + chrony NTP** (`ADR-0009` reduced it to exactly these two jobs). Making Pi-hole the DNS-filter owner reinforces that role rather than splitting it with the edge. (Note: domain machines use **AD-DNS on the DCs**, `ADR-0003`; Pi-hole is the non-domain filtering forwarder + the `atlas.lab` conditional-forwarder — the DNS *boundary* is unchanged by this ADR.)

## Alternatives Considered

- **Both, layered (the original Section-K K2 recommendation).** Rejected on refinement — "non-overlapping roles" is hard to keep true in practice (both filter domains), doubles the block-source/allowlist troubleshooting surface, and adds drift risk for coverage the FGT's web-category filter + Pi-hole's sinkhole already provide. Single-home is the cleaner operational posture.
- **FortiGuard DNS filter only (retire Pi-hole's filter role).** Rejected — Pi-hole is an already-built, non-domain-friendly DNS-control home with its own logging/ad-block value and the `ADR-0003` boundary role; the FGT filter only covers traffic crossing the edge, not intra-LAN. Throwing away the Pi-hole home to move DNS control into the licensed edge loses the non-domain coverage and the existing artifact.
- **No DNS filtering at all** (rely on web-category + deep inspection). Rejected — DNS sinkholing catches things category filtering misses (known-bad domains, telemetry, ad/tracker networks) cheaply and early, and it's a real learning artifact. Keep it — just single-homed.

## Consequences

- **Docs to reconcile (`POL-0008` propagation):**
  - **`ADR-Index.md`** → add the ADR-0051 row (Lab-02, Accepted); index Version bump.
  - **`Pre-Build-Decisions.md` §K2** → **update the recommendation** from "both, layered" to the refined **single-owner** decision; Status 🔵→✅; "Lands in" → **`ADR-0051`**. (This is the one Section-K row whose *content* changed, not just its status — record it explicitly.)
  - **`Devices/FGT01-Perimeter-Firewall/Considerations.md`** → K2 "Decided" bullet + the "K1/K2 ADRs owed" line resolve to `ADR-0050` (K1) / **`ADR-0051`** (K2).
  - **`Devices/Pi01-DNS-NTP/`** → note Pi-hole is the single DNS-filter owner (the Services-map / role already says filtering DNS; this ADR confirms *sole* ownership).
  - **`Review-Flag-Register.md`** + **`SESSION-HANDOFF.md`** → close the "K1/K2 Section-K ADRs owed" thread (K2 half).
- **One fewer moving part on the FGT** — the DNS-filter profile stays off, so there's no second blocklist to tune, no split-brain to debug.
- **Pi01's availability matters a bit more** — DNS filtering rides Pi-hole, a single SD-card box (`ADR-0009` reduced-but-not-eliminated SPOF). The mitigation is unchanged (keep it disposable + image-backed; a 2nd resolver is the later fault-tolerance fix); this ADR doesn't add a new dependency, it just doesn't add the FGT as a redundant filter.

## Review Trigger

- **Pi-hole proves an inadequate DNS-control home** (coverage gaps the edge would close, or its SPOF bites) → revisit enabling the FortiGuard DNS filter as a *complement* with an explicit, documented ownership split — i.e. re-open the "both, layered" option deliberately, not by drift.
- **A non-domain / guest / OT population needs DNS control the Pi-hole forwarder doesn't reach** → decide per-segment (point it at Pi-hole, or scope the FGT DNS filter to that segment only).
- **The FGT DNS filter is wanted for a specific FCP §3 lab** → enable it in a scoped, monitor-only, clearly-labelled lab context, then turn it back off — don't leave two live filters in production.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-30 | Created — formalizes **Section-K K2** and **refines** its 2026-07-29 "both, layered" recommendation to a **single-owner** model: **Pi-hole (Pi01) owns DNS filtering; the FortiGuard DNS filter stays OFF** (FGT UTM keeps web/AV/IPS/app-control per `ADR-0047`). Rationale: one DNS-control home avoids split-brain blocklists + halves the troubleshooting surface; reinforces Pi01's reduced role (`ADR-0009`) and the `ADR-0003` DNS boundary. Updates `Pre-Build-Decisions` §K2's recommendation to match. |
