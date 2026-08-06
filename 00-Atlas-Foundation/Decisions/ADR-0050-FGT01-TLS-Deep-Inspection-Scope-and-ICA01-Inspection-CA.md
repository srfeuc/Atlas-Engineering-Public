# ADR-0050 — FGT01 TLS/SSL Deep-Inspection Scope + ICA01 Inspection-CA Distribution (Section-K K1)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-30) — the K1 disposition recorded at the FGT01 #22/Batch-C+D pass, now formalized. Not built; applied + verified when FGT Build-Guide-3 (Security-Profiles) is reached. |
| Governing Policy | POL-0011 (+POL-0007) |
| Scope | **Lab-02-Cisco-Core** — network-security architecture; defines *how far* FGT01's FortiGuard UTM decrypts N-S TLS and *where* the inspection CA is trusted. |
| Date | 2026-07-30 |
| Supersedes | None. Formalizes **Section-K K1** (`Pre-Build-Decisions.md`) — the recommendation and this decision agree. |
| Related | `ADR-0047` (FGT01 runs FortiGuard UTM — the layer this scopes) · `ADR-0027` (AD CS two-tier — ICA01 issues the re-signing CA) · `ADR-0031` (AD CS is the only PKI) · `ADR-0028` (FGT01 admin LDAPS) · `ADR-0023` (1941-core / MKT01 E-W topology) · `ADR-0051` (K2 DNS filtering — the sibling Section-K ADR) · `Devices/FGT01-Perimeter-Firewall/Considerations.md` (K1 "Decided") · `Devices/RCA01-ICA01-ADCS/` (the CA that issues the inspection cert) · `Pre-Build-Decisions.md` §K1 · `Atlas-Firewall-Architecture.md` · `Atlas-Academy/Atlas-FortiGate-FCP-Lab-Map.md` §3 (Content Inspection). |
| Governing docs | `Atlas-Firewall-Architecture.md` (§3 content inspection) · `Devices/FGT01-*` (Build-Guide-3 Security-Profiles) · the FCP lab-map §3. |
| Evidence Status | **Decision / plan.** Nothing built. Gated on: the **ICA01 issuing CA live** (`ADR-0027`) + the FGT re-signing CA issued + **GPO-distributed to domain Trusted Root**, and a verified live FortiGuard subscription (`ADR-0047`). Every deep-inspection `[ ]` stays `[ ]` until a real decrypt is proven on a managed client and a bypass is proven for a pinned app (`POL-0001`). |

## Context

`ADR-0047` turns FGT01 into the estate's **licensed N-S content-inspection layer** (web/AV/IPS/app-control + DNS — DNS split out to `ADR-0051`). Content inspection of **HTTPS** only sees anything if the firewall **decrypts** it, and decryption is a design decision with real trade-offs, not a checkbox:

- **Deep inspection** (full man-in-the-middle: the firewall terminates TLS, inspects cleartext, re-encrypts with its own **re-signing CA**) is what makes AV/IPS/web-filter/app-control actually inspect payloads — but it requires **every client to trust the firewall's re-signing CA**, and it **breaks** certificate-pinned applications and anything the firewall's CA isn't trusted by.
- **Certificate inspection** (SNI / server-cert only, no decrypt) needs no client trust and breaks nothing, but only sees the hostname/cert — enough for coarse web-category filtering, not payload inspection.

The `ADR-0031` PKI decision means the estate has exactly one CA source — **AD CS (ICA01)** — so the FGT re-signing CA must be a **subordinate issued by ICA01**, not a self-signed FortiGate CA (a self-signed inspection CA would be an untrusted, unmanaged trust anchor — the opposite of the tiered-PKI discipline). Distribution to clients is therefore a **GPO** job on domain machines, and an explicit gap for **non-domain** devices.

The open question K1 closes: **how far does FGT01 decrypt, and where is the inspection CA trusted?**

## Decision

**FGT01 runs *selective* TLS deep-inspection — deep only where the ICA01 inspection-CA trust is distributed, certificate-inspection everywhere else, with explicit bypass for pinned apps and non-domain devices.** The re-signing CA is a **subordinate issued by ICA01, pushed to the domain Trusted Root Certification Authorities store via GPO.**

Load-bearing choices:

1. **Deep inspection (decrypt) is scoped to the managed, trust-distributed zones** — the **client/user VLANs** (domain-joined workstations that receive the GPO) and the **server VLAN** where warranted. There the firewall re-signs with the ICA01-issued CA, so browsers trust the chain and payload inspection works.
2. **Certificate inspection (SNI/cert-only) is the default elsewhere** — where the ICA01 trust is *not* distributed (guest/OT/anything non-domain), the firewall filters on hostname/category without decrypting. No client trust required; nothing breaks.
3. **The inspection CA is an ICA01 subordinate, GPO-distributed (`ADR-0027`/`ADR-0031`).** FGT01's re-signing CA is **issued by ICA01** (not self-signed) and pushed to domain machines' **Trusted Root** via a GPO. This keeps the estate's single-PKI discipline: one trust anchor, centrally managed, revocable.
4. **Explicit bypass list for pinned apps + privacy-sensitive categories.** Certificate-pinned applications (which reject any re-signed cert) and **banking / health / privacy** categories are **excluded from decrypt** → certificate-inspection-only. Deep-inspecting them either breaks the app or raises privacy/legal concerns; the exclusion list is a first-class part of the profile.
5. **Non-domain devices are never deep-inspected** — they don't (and by design can't easily) trust the FGT CA, so they get certificate-inspection only. Distributing the inspection CA to a non-domain box is a manual, discouraged exception.
6. **Size the scope to the FGT-60E.** Deep inspection is CPU-expensive; the 60E has a real throughput ceiling. Scope deep-inspect to the zones that need it, prefer flow-mode where it suffices, and treat "decrypt everything everywhere" as out of budget (`ADR-0047` Review Trigger).

## Alternatives Considered

- **Full deep inspection everywhere.** Rejected — breaks pinned apps + non-domain devices, raises privacy exposure on sensitive categories, and overruns the 60E. The learning value (seeing decryption work) is captured by scoping it to the managed zones, not by decrypting the whole estate.
- **Certificate inspection everywhere (never decrypt).** Rejected as the *end state* — it's the safe fallback and the non-managed-zone default, but it never inspects payloads, so AV/IPS/app-control at the edge would be blind to HTTPS content. The FCP §3 deep-inspection objective (and the real security value) needs decrypt *somewhere*.
- **Self-signed FortiGate re-signing CA (skip ICA01).** Rejected — violates `ADR-0031` (AD CS is the only PKI) and creates an unmanaged, non-revocable trust anchor pushed to every client. The inspection CA must chain to ICA01.
- **Manually install the CA per client (no GPO).** Rejected for domain machines — GPO is the scalable, auditable distribution path and the exact enterprise pattern the exam and real estates use. Manual install remains the (discouraged) exception for the rare non-domain box that genuinely needs deep inspection.

## Consequences

- **Docs to reconcile (`POL-0008` propagation):**
  - **`ADR-Index.md`** → add the ADR-0050 row (Lab-02, Accepted); index Version bump.
  - **`Pre-Build-Decisions.md` §K1** → Status 🔵→✅; "Lands in" → **`ADR-0050`**; the recommendation is now the decision.
  - **`Devices/FGT01-Perimeter-Firewall/Considerations.md`** → the K1 "Decided" bullet + the "K1/K2 ADRs owed" line resolve to **`ADR-0050`** (K1) / `ADR-0051` (K2).
  - **`Review-Flag-Register.md`** + **`SESSION-HANDOFF.md`** → close the "K1/K2 Section-K ADRs owed" thread (K1 half).
- **A build dependency chain is made explicit:** FGT deep-inspection is gated on **ICA01 live** → **FGT re-signing CA issued by ICA01** → **GPO Trusted-Root distribution** → **verified live subscription** (`ADR-0047`). Nothing decrypts before that chain is real.
- **A new lab lands in FGT Build-Guide-3:** the inspection-cert-distribution exercise (issue the sub-CA from ICA01, GPO-push it, prove a managed client trusts a re-signed session, prove a pinned app bypasses) — a strong FCP §3 + AD CS + GPO cross-domain artifact.
- **Privacy/scope posture is documented, not implicit:** the exclusion list (pinned apps + banking/health/privacy) is part of the profile from day one.

## Review Trigger

- **Deep inspection breaks relying parties beyond the exclusion list** (more pinned apps than expected) → widen certificate-inspection, narrow decrypt to where it's proven safe.
- **60E throughput hit is unacceptable** → reduce the deep-inspect scope / prefer flow-mode / offload; re-open with a hardware option if the lab outgrows the 60E.
- **A non-domain population grows** (client fleet, OT, guests) that needs inspection → decide a distribution path for its trust or accept certificate-inspection-only for it; do **not** silently deep-inspect boxes that don't trust the CA.
- **ICA01 / the inspection sub-CA is re-keyed or revoked** → re-issue + re-distribute via GPO before deep inspection resumes.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-30 | Created — formalizes **Section-K K1**. **Selective TLS deep-inspection**: decrypt only in the ICA01-trust-distributed zones (domain client/user + server VLANs), **certificate-inspection** elsewhere, explicit **bypass** for pinned apps + banking/health/privacy + all non-domain devices; the FGT **re-signing CA = an ICA01 subordinate, GPO-pushed to domain Trusted Root** (`ADR-0027`/`ADR-0031`); scoped to the FGT-60E budget (`ADR-0047`). Gated on ICA01 live + GPO trust distribution + a verified subscription. Unlocks the FCP §3 deep-inspection + inspection-cert-distribution lab. |
