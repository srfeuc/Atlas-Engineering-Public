# ADR-0047 — FGT01 Runs FortiGuard UTM (Reverses ADR-0035; Reshapes ADR-0038)

| Item | Value |
|---|---|
| Status | **Accepted in principle** (operator, 2026-07-29) — the **FortiGuard UTM subscription is being purchased**. Not built; profiles are applied + DB-verified at build. |
| Governing Policy | POL-0007 (+POL-0009) |
| Scope | **Lab-02-Cisco-Core** — network security architecture; redraws the N-S content-inspection layer. |
| Date | 2026-07-29 |
| Supersedes | **Reverses `ADR-0035`** (FGT01 no-UTM). **Reshapes `ADR-0038`** (pfSense inline IPS → free/complementary IPS + the free-vs-licensed comparison; it is no longer the *sole* N-S prevention). |
| Related | `ADR-0035` (the no-UTM posture this reverses) · `ADR-0038` (pfSense inline IPS — reshaped, not retired) · `ADR-0005` (FGT01 egress broad, deferred) · `ADR-0028` (FGT01 admin LDAPS) · `ADR-0027` (AD CS — the CA cert TLS deep-inspection needs) · `ADR-0023` (1941-core / MKT01 E-W topology) · `ADR-0032` (Diagnostics + Suricata monitoring) · `CM-0033` (the stale-signature finding) · `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` · `Atlas-Academy/Atlas-FortiGate-FCP-Lab-Map.md` (§3 — unlocked by this) · `Pre-Build-Decisions` G5. |
| Governing docs | `Atlas-Firewall-Architecture.md` (§3.4 NGFW/UTM · §5 gap analysis) · `Devices/FGT01-*` (Build-Guide-3 Security-Profiles — now built) · the FCP lab-map §3. |
| Evidence Status | **Decision / plan.** Nothing built. The *device* fact that will change — current FortiGuard DBs + attached profiles — is **not yet verified**; every UTM `[ ]` stays `[ ]` until a `get system status` read-back shows current databases (`POL-0001`). |

## Context

`ADR-0035` accepted **FGT01 with no UTM** — no FortiGuard licence, its Antivirus/IPS/App-Control databases years stale (2015–2018, `CM-0033`), and **no profile ever attached** (better nothing than a green column over dead signatures — the confidence trap). That was the right call *for an unlicensed box*, and it drove `ADR-0038`: **pfSense as a transparent inline IPS on the FGT01↔1941 N-S transit**, added specifically to fill the **prevention** gap the absent UTM left.

Two things now change the premise:

1. **The operator is buying the FortiGuard UTM subscription.** With a live licence, FGT01 gets **current** signatures — so the `ADR-0035` reason to stay off UTM (stale DBs, real recurring cost with no payoff) no longer holds, and the no-UTM posture becomes internally contradictory with the purchase.
2. **The certification track needs it.** The **FCP — FortiGate 7.6 Administrator** exam's entire **Content Inspection** domain (`Atlas-FortiGate-FCP-Lab-Map.md` §3 — web filtering, application control, antivirus, IPS, DNS filter, TLS deep inspection) is `🛡️`-gated on exactly this subscription (register **G5** — formal FCP/NSE target). Without the licence §3 is theory; with it, it becomes labs.

The open question this ADR closes: **does FGT01 now run UTM (reversing `ADR-0035`), and what happens to pfSense (`ADR-0038`) once its reason-for-being — the missing N-S prevention — is filled by a licensed edge?**

## Decision

**FGT01 runs FortiGuard UTM as the estate's licensed north-south content-inspection layer**, and **pfSense is kept — reshaped — as the free/complementary inline IPS and the free-vs-licensed learning comparison.**

Load-bearing choices:

1. **Reverse `ADR-0035`.** FGT01 operates as a **UTM/NGFW** perimeter firewall: **Web filtering (FortiGuard categories), Application Control, Antivirus, IPS, and DNS filtering** are enabled on the north-south policy set, backed by a **live FortiGuard subscription**. FGT01's security value grows from "NAT + stateful policy + logging" to that **plus** application-aware content inspection at the edge.
2. **The `ADR-0035` confidence-trap rule survives the reversal — inverted into an upkeep duty.** A UTM profile is still **never** trusted on a stale database; the difference is the databases are now *expected current* and that must be **proven**: `get system status` shows current FortiGuard DB dates **before** any profile is relied on, and a profile is only "on" once a positive test fires (e.g. an **EICAR** hit for AV, a known IPS signature trigger). A lapsed subscription reverts to the `ADR-0035` discipline — **detach the profiles, don't run them stale** (see Review Trigger).
3. **Reshape `ADR-0038` — keep pfSense, redraw its role.** pfSense stays as the **transparent inline IPS on the FGT01↔1941 transit**, but its purpose is now (a) a **free/open (Suricata/Snort) complementary IPS** layered behind the licensed edge, and (b) the **free-vs-licensed comparison artifact** the FCP/NSE track wants — *pfSense-free IPS* vs *FortiGate-licensed IPS* on the same N-S path. It is **no longer the sole N-S prevention** (FGT UTM now leads); it is defence-in-depth + a teaching control. pfSense is **not retired** (this settles `ADR-0038`'s "reconcile the overlap — keep or retire" review trigger in favour of *keep*).
4. **Division of labor (updated):** **FGT01 UTM = licensed N-S content inspection at the edge** (the layer the FCP §3 grades) · **pfSense = free/complementary inline IPS on the N-S transit + the comparison** (`ADR-0038`) · **MKT01 = E-W prevention** (default-deny, `ADR-0023`) · **Suricata-on-SPAN (MON01) = network detection** · **Wazuh (SIEM01) = host detection/SIEM**. FGT01 + pfSense UTM/IPS logs ship to MON01/Wazuh so detection stays one pane.
5. **Build-Guide-3 (FGT Security-Profiles) is now built.** `ADR-0035` had removed it from the tiered set; it re-enters as a **phased, gated Build-Guide phase** (`ADR-0043`) — the standard Certificate-application (the ICA01 CA cert + FortiGuard trust) / Service-setup (per-profile enable + verify) / Automation-onboarding sections; each profile is a test-gated unit (`ADR-0041`).

## Alternatives Considered

- **Keep `ADR-0035` (no UTM); do not buy.** Rejected — the operator is purchasing the subscription (fact on the ground) and the FCP §3 domain needs it. Leaving the no-UTM ADR standing against a bought licence is the contradiction this ADR exists to remove.
- **Buy UTM and retire pfSense** (the licensed edge makes the free IPS redundant). Rejected — pfSense's value is now **learning** (the free-vs-licensed comparison the FCP/NSE track wants) and **defence-in-depth**, not just filling a gap. Retiring it throws away the comparison artifact. Kept, reshaped.
- **Buy UTM but run profiles in monitor/IDS-only mode.** Kept as the **bring-up default** (Review Trigger) — enable profiles in monitor mode, tune, then flip to blocking — but not the end state; the point of a licensed edge is inline prevention.
- **Attach profiles without verifying the DBs update** (assume the licence "just works"). Rejected hard — this is the `CM-0033`/`ADR-0035` confidence trap in a new costume. A licence you didn't prove is refreshing signatures is no better than stale ones. `get system status` is the gate.

## Consequences

- **Docs to reconcile (`POL-0003` / the 5-step propagation):**
  - **`ADR-0035`** → status **Superseded/Reversed by ADR-0047**; reversal banner + Change Log entry (content retained per `ADR-0012` — ADRs are a historical record).
  - **`ADR-0038`** → **reshape note** at top + Change Log: pfSense kept as free/complementary IPS + comparison; no longer sole N-S prevention; its "License FGT UTM instead — rejected for now (`ADR-0035` stands)" alternative annotated as **now decided** by this ADR.
  - **`ADR-Index.md`** → add the ADR-0047 row (Lab-02); annotate the ADR-0035 row (superseded) + ADR-0038 row (reshaped); index Version bump.
  - **`Atlas-Firewall-Architecture.md`** → §3.4 (NGFW/UTM) "Atlas's honest state" + the "Today" mapping "no UTM (unlicensed)" + §5 gap-analysis NGFW/UTM row: **now licensed per `ADR-0047`** (with the "verify DBs update" discipline intact); link out.
  - **`Atlas-FortiGate-FCP-Lab-Map.md`** → §3 unlocks: the `🛡️`-gated rows become **buildable** (the subscription is landing); the pending-ADR pointer resolves to `ADR-0047`.
  - **`Review-Flag-Register.md`** + **`SESSION-HANDOFF.md`** → record the reversal + close the "pending FortiGuard-UTM ADR" thread.
- **A new build phase enters FGT01's plan** — Build-Guide-3 (Security-Profiles), gated on the ICA01 CA cert (for TLS deep inspection, `ADR-0027`) + a verified live subscription.
- **Recurring cost accepted** — the FortiGuard bundle is now an operating cost the estate carries; a lapse triggers the Review action, not silent stale-running.
- **Certification value unlocked:** FCP §3 (the whole Content Inspection domain) becomes labs, plus the free-vs-licensed IPS comparison (pfSense vs FortiGate) for the FCP/NSE track and the SSL/TLS deep-inspection lab (needs the ICA01 cert on clients — the inspection-cert-distribution exercise).
- **No topology change** — FGT01 keeps its N-S edge role (`ADR-0023`); pfSense keeps its transparent-bridge placement (`ADR-0038`). Only the *inspection* posture changes.

## Review Trigger

- **Subscription lapses / is not renewed** → revert to the `ADR-0035` discipline: **detach the UTM profiles** (never run stale signatures), fall back to pfSense-free IPS as the N-S prevention, and re-open this decision.
- **UTM inline inspection adds unacceptable latency / throughput hit on the FGT-60E** → run profiles in **monitor-only (IDS) mode**, tune rule sets / disable proxy-mode where flow-mode suffices, then re-enable blocking (mirrors `ADR-0038`'s IPS tuning fallback).
- **TLS deep inspection breaks relying parties** (pinned apps, non-domain devices) → scope deep inspection to where the ICA01 trust is distributed; leave certificate-inspection (SNI/cert-only) elsewhere.
- **The pfSense/FGT overlap proves redundant in practice** (not for learning) → revisit retiring pfSense; until then it stays as the comparison + defence-in-depth artifact.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-29 | Created. Operator is **buying the FortiGuard UTM subscription** → **reverses `ADR-0035`** (FGT01 now runs UTM: web/AV/IPS/app-control/DNS filtering as the **licensed N-S content-inspection layer**) and **reshapes `ADR-0038`** (pfSense **kept** as the free/complementary inline IPS + the **free-vs-licensed comparison**, no longer the sole N-S prevention). The `ADR-0035` confidence-trap rule survives as an **upkeep duty** — profiles are only trusted once `get system status` proves current DBs + a positive test fires (`POL-0001`). Re-enables FGT **Build-Guide-3** (Security-Profiles) as a gated phase (`ADR-0043`/`ADR-0041`). **Unlocks FCP lab-map §3** (register G5). Recurring cost accepted; a lapse reverts to the `ADR-0035` detach-don't-run-stale posture. |
