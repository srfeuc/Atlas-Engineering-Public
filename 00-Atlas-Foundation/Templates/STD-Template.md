<!--
  ATLAS STANDARD TEMPLATE  ·  human-readable  ·  cut a new STD from this
  ────────────────────────────────────────────────────────────────────
  A standard is the CONCRETE, TESTABLE *HOW* a policy requires. It is NOT a policy (the "why"/standing
  rule) and NOT a guide (the step-by-step). It names a real Atlas target and a real value, and it can be
  audited with a read-back. If a reader can't APPLY it to a device and PROVE it with a command, it's too
  general — push the specifics in.

  HOW TO USE
  1. Copy to  Standards/STD-XXXX-<Name>.md  and fill every ‹placeholder›. Take the next free STD number.
  2. Write the rules as numbered, citable requirements (R1…Rn) with REAL values on NAMED targets —
     someone should be able to say "STD-XXXX R3" and go set it. Ground every rule in a real artifact
     (a device folder, a CIS-Hardening baseline, an owner doc), like the ADRs do.
  3. Name the governing POLICY (the "why") and the adopting DECISION (the ADR). The ADR keeps its
     `Governing Policy:` line so it still shows in that policy's generated directory.
  4. Verification is a real read-back per rule — the exact command + the value you expect.
  5. Point to the Academy — give the standard a *learn-it* source of truth: a Concept (the why), the
     Command-Library (the how / the read-back commands), the cert map, and the relevant Security-Program page.
  6. On adopt/amend: refresh AI-Context, and log it in the Backlog + SESSION-HANDOFF.
  Delete this comment block in the finished standard.
-->
---
Title: STD-XXXX — ‹Standard Name› Standard
Path: 00-Atlas-Foundation/Standards
Status: ‹Proposed | ✅ Adopted YYYY-MM-DD under `POL-xxxx` via `ADR-xxxx`. In force.›
Version: ‹n.n›
---

# STD-XXXX — ‹Standard Name›

> **At a glance.** ‹One or two plain sentences a reader scans in five seconds: the concrete thing this standard makes uniform across the estate, and where it's applied.›

| Item | Value |
|---|---|
| Layer | **Standard** — the concrete, testable *how* a policy requires; binds real Atlas devices/configs/values |
| Governing policy | [`POL-xxxx`](../Policies/POL-xxxx-‹slug›.md) — the *why* this standard serves |
| Requirement, in one line | ‹the single sentence of what must be configured/true — with the key value(s)› |
| Owner | ‹silo / role› ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-xxxx`](../Decisions/ADR-xxxx-‹slug›.md) → adopted under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Applies to | ‹the real devices/hosts/docs this binds — name them (e.g. SW01 · 1941 · every domain-joined host)› |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* read-backs below |
| Framework mapping | ‹CIS Benchmark · NIST · vendor default · the cert objective it exercises› |

---

## Scope & applicability

‹What this binds, concretely — which devices, which configs, which docs. 2–3 sentences.›

**Boundary with ‹adjacent standard/policy›:** ‹name the nearest neighbour and state the dividing line, so the two never claim the same setting (`POL-0004` — one home per fact).›

## Why a standard, not left in a guide

‹The real defect *uniformity* prevents — cite the incident/baseline (`CM-####`, a `CIS-Hardening-*` doc, a Game-Day). A setting that drifts per device is how the silent-blind bugs and the failed hardening happen; a standard makes "the same, everywhere" auditable.›

---

## The requirements

Each is citable as `STD-XXXX R#`. Concrete + testable — a **real value** on a **named target**, with the owner doc that carries the detail.

### R1 — ‹short rule name›

‹Bold-lead: the exact setting/value that must be true, and on what.› **Applies to:** ‹the real target(s)›. **Owner doc:** [‹the doc that owns the detail›](‹path›). ‹adopting/related decision, linked›

### R2 — ‹short rule name›

‹…› **Applies to:** ‹…›. **Owner doc:** [‹…›](‹…›).

<!-- Add R3, R4… as needed. Split R3a/R3b when a rule has a parent + specifics (e.g. a value that differs by role/platform). Keep each one auditable. -->

---

## Adopting & amending decisions

The dated trail — the decision(s) that adopted or amended this standard (kept, never deleted; originals in the legacy ADR snapshot). A standard usually has one or two.

| Decision | Status | What it did |
|---|---|---|
| [`ADR-xxxx`](../Decisions/ADR-xxxx-‹slug›.md) | ‹Accepted / Superseded› | ‹adopted this standard / amended R#› |

<!-- These ADRs keep their `Governing Policy:` line so they still appear in the governing policy's generated directory. If the generator later learns standards, this table becomes an AUTOGEN block. -->

## Verification (how conformance is proven)

One check per requirement — a **real read-back**, not "should be." The [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit runs this list; the device wins over the doc (Charter Rule 13).

- [ ] **R1** — ‹the exact read-back + the value you expect: e.g. `show ntp status` → `Clock is synchronized, stratum ≤ 4`›
- [ ] **R2** — ‹…›
- [ ] **Meta** — any change to a value here traces to an amending ADR + a Change Log row.

> Markers are honest (`POL-0006`): a control that isn't built yet is 📋/⬜, never ✅. A ✅ needs the read-back.

## Learn it — the Academy (the source of truth for the *why* + the commands)

Every standard names its teaching/reference home. Verification above gives the command; these give the meaning, the how-to-run, and the objective it exercises. The Academy is the cross-cutting *learn-it* layer — link it, don't restate it (`POL-0004`).

- 🎓 **Concept (why it works):** [‹the relevant `Atlas-Academy/Concepts/‹Topic›.md`›] ‹— or 📋 flag a new Concept if this domain has none yet; that gap is real work, name it›
- 🖥️ **Commands (run the read-backs):** [‹the `Atlas-Academy/Command-Library/‹platform›.md` pages the Verification commands come from›]
- 🏅 **Cert objective:** [‹the cert lab-map(s) this standard exercises — e.g. Security+ Domain-5, the CCNA/AZ-800 maps›]
- 📋 **Security program:** [‹the relevant `00-Atlas-Foundation/Security-Program/` page — compliance/control-mapping · awareness · incident response — where the program/human layer applies›]

## What a violation looks like

‹Concrete failure signatures, `·`-separated — what an auditor would actually see on a non-conforming device (e.g. *a `v2c` community string · `stratum 16` · a Type-7 secret · TLS on a self-signed leaf*).›

## Related

‹Linked: the [governing policy](../Policies/POL-xxxx-‹slug›.md) · adjacent standards · the real owner docs / `CIS-Hardening-*` baselines this draws from · [the framework](../Governance/Atlas-Governance-Framework.md) · [the Standards register](../Standards/README.md).›

## Change Log

| Version | Changes |
|---|---|
| ‹n.n› | ‹date. What changed. Note: AI-Context refreshed · Backlog + SESSION-HANDOFF updated.› |
