# ADR-0035 — FGT01 Runs Without UTM (No FortiGuard Subscription)

> 🔴 **SUPERSEDED / REVERSED by `ADR-0047` (2026-07-29).** The operator is buying the FortiGuard UTM subscription, so FGT01 **now runs UTM** (web/AV/IPS/app-control/DNS filtering) as the licensed north-south content-inspection layer. This ADR is retained as the historical record (`ADR-0012`). **Two things carry forward from it, unchanged:** (1) the **confidence-trap rule** — never trust a profile over a stale database; under `ADR-0047` this becomes a *verify-the-DBs-update* duty rather than a *never-attach* rule, and (2) it remains the **fallback posture** if the subscription lapses (detach profiles; do not run them stale). See `ADR-0047`.

| Item | Value |
|---|---|
| Status | 🔴 **Superseded / Reversed by `ADR-0047`** (2026-07-29). Was: Accepted (operator, 2026-07-28). |
| Governing Policy | POL-0012 |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-28 |
| Supersedes | — (settles the long-open "UTM: license or accept" question flagged in `Build-Checklist` §6, `Build-Guide-Index` Guide-3, `CIS-Hardening-FGT01` §4, register **C5**). |
| Related | `ADR-0005` (FGT01 egress broad, deferred), `ADR-0028` (FGT01 admin LDAPS), `CM-0033` (the stale-signature finding), `POL-0007` (hardening). |
| Evidence Status | **Decision.** The device state ("no FortiGuard licence; AV/IPS/App-Control DBs stale 2015–2018") is device-observed (`021`/`MC-0001`). |

## Context

FGT01 (FortiGate-60E, FortiOS 7.4.5) has **no active FortiGuard subscription**, and its UTM signature databases (Antivirus, IPS, Application Control) were found **years stale (2015–2018)** during validation (`CM-0033`). Every FGT doc that touches UTM left the same open choice: **license and maintain it, or formally accept it's off** — and warned that the real danger is the middle ground, **attaching a stale profile** so the GUI shows a green "protected" column over signatures that protect nothing (the confidence trap).

The operator has made the call: **do not license UTM; run FGT01 without it, and record that as the deliberate posture** so no future pass silently attaches a stale profile or re-opens the question.

## Decision

**FGT01 operates as a stateful perimeter firewall *without* UTM.** No FortiGuard bundle is purchased; **IPS / Antivirus / Application Control / Web-DNS filtering are not enabled.** The security value FGT01 provides is **NAT + stateful policy + logging** (north-south), complemented by MKT01's east-west segmentation.

1. **No stale profiles, ever.** A UTM profile is **never** attached to a policy while its databases are out of date (`CM-0033`). Better no profile than a green column over 2015 signatures.
2. **The FGT Build-Guide-3 (Security-Profiles) is not built** — it stays out of the tiered set until/unless a bundle is bought.
3. **Layered defence still holds:** perimeter deny-by-default + egress control (`ADR-0005`), east-west default-deny (MKT01 + the allowed-flows matrix), IDS visibility via the **SW01 SPAN → Suricata** tap (MON01, Phase 6) — so "no UTM on the edge" is not "no detection."

## Alternatives Considered

- **License a FortiGuard/UTP bundle**, apply IPS/AV/AppControl/web-filter, verify DB updates (`get system status`). Rejected **for now** — a real recurring cost for a lab whose detection need is better served by the free Suricata SPAN tap; revisit if the bundle is acquired (Review Trigger).
- **Leave it open.** Rejected — it has churned across four docs; an accepted "no" ends the churn and, crucially, forbids the stale-profile trap explicitly.

## Consequences

- **Docs to reconcile (`POL-0003`):** `FGT01/Build-Checklist.md` §6 and `Build-Guide-Index.md` Guide-3 → "**no UTM, `ADR-0035`; do not attach stale profiles**"; `CIS-Hardening-FGT01.md` §4 UTM item → resolved-as-accepted; register **C5** UTM sub-item → closed. `Build-Guide-3` is removed from the "to build" set.
- **Detection is not abandoned:** the Suricata SPAN tap (SW01 `Gi1/0/5`) on MON01 becomes the estate's IDS, and is where "did we catch it?" is answered — note this in the MON01 plan.
- **Validation:** `get system status` should show **no UTM profiles attached** and no licence assumed; the FGT Diagnostics/Command-Library "UTM" rows read "n/a by `ADR-0035`."

## Review Trigger

- If a **FortiGuard/UTP bundle is purchased**, re-open: build `Build-Guide-3`, apply IPS/AV/AppControl, and **verify the databases update** before trusting any profile.
- If the scenario grows a real edge-inspection requirement UTM uniquely meets.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-29. **Superseded / reversed by `ADR-0047`.** The operator is buying the FortiGuard UTM subscription — the ADR-0035 review trigger ("if a bundle is purchased, re-open") fired. FGT01 now runs UTM as the licensed N-S content-inspection layer; `Build-Guide-3` (Security-Profiles) re-enters the build set. Added the reversal banner + Status change. The **confidence-trap rule survives** (now a *verify-the-DBs-update* duty under `ADR-0047`) and this posture remains the **fallback if the subscription lapses**. Content otherwise retained (`ADR-0012`). |
| 1.0 | 2026-07-28. Accepted. FGT01 runs **without UTM** (no FortiGuard subscription; stale 2015–2018 signatures never attached). Security value = NAT + stateful policy + logging at the edge, east-west segmentation on MKT01, and Suricata SPAN visibility on MON01. `Build-Guide-3` (Security-Profiles) stays unbuilt; the middle-ground stale-profile attach is explicitly forbidden (`CM-0033` confidence trap). Settles the UTM question across the FGT docs + register C5. Review trigger = buying a bundle. |
