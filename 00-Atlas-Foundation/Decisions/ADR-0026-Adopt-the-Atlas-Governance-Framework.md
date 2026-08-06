# ADR-0026 — Adopt the Atlas Governance Framework (Policies Above Decisions)

| Item | Value |
|---|---|
| Status | **Proposed** |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-17 |
| Related | `Atlas-Governance-Framework.md` (the model this adopts), `POL-0001` (Audit — the seed), `Atlas-Charter.md` (the meta-rules above policy), `ADR-0018` (silos — Security owns audit), `016`/`018`/`051` (the buried rules being elevated) |
| Governing Policy | *This ADR is what gives policies force; it is governed by the Charter directly.* |
| Evidence Status | **`Target Design`** |

## Context

Atlas has decisions (ADRs), standards, procedures, and changes — but **no layer of standing requirements that decisions must conform to.** `POL-0001` says it of itself: *"You do not have policies, and no, that is not what ADRs do."* The cost is documented and real: two correct rules ("no secret in git"; "disable unused interfaces") lived *buried inside Standards documents*, un-enumerable and un-auditable, and were violated repeatedly — `CM-0014`, `CM-0015`, `CM-0019`, `CM-0023`, `CM-0033`.

`Atlas-Governance-Framework.md` (Draft, 2026-07-16) designs the fix: a **Charter > Policy > Standard > ADR > Change > Procedure** hierarchy, a core Policy Register, a formal audit process, and an adoption path. It states it "needs an adopting ADR to take force." This is that ADR.

## Alternatives Considered

1. **Leave the rules buried in the Charter/lessons/Standards.** Rejected — that is the exact state that caused the five change-record defects above; a rule that lives only in a document, unenforced, is not a rule.
2. **Put standing requirements into more ADRs.** Rejected — an ADR is a point-in-time choice among options; a policy is a forever-requirement applying to things not yet imagined (`POL-0001`'s `Gi1/0/3`-vs-"every unused port" argument). Different artefact, different job.
3. **Adopt the Governance Framework as the policy layer.** Chosen.

## Decision

**Atlas adopts the Governance Framework as `Atlas-Governance-Framework.md`, in force from this ADR.**

1. **The layer hierarchy is normative:** a Change may not violate an ADR; an ADR may not violate a Standard; a Standard may not violate a Policy; a Policy may not violate the Charter. When two conflict, the higher layer wins and the lower is the defect. *(This is orthogonal to Charter Rule 13's evidence precedence: the hierarchy says which requirement to obey; Rule 13 says which observation to believe.)*
2. **The Policy Register in §2 of the framework is authoritative for policy numbering** — `POL-0002 = Secrets & Credentials`, `POL-0003 = Change Control`, `POL-0004 = Source of Truth`, `POL-0005 = Backup & Recovery`, `POL-0006 = Evidence & Verification`, `POL-0007 = Hardening Baseline`, `POL-0008 = Naming & Addressing`. **This supersedes `POL-0001` §7's earlier ad-hoc numbering** (which proposed `POL-0002 = Unused Interface`, `POL-0003 = Secrets`); unused-interface is absorbed into `POL-0007`.
3. **`POL-0001` (Audit) is adopted** with its skeleton sections (Cadence §5, Failure §6, NIST/CIS §7, Retention §8) filled from the framework's §3; its owner is the **Security silo** (`ADR-0018`).
4. **Every future ADR carries a `Governing Policy:` line** naming the standing requirement it serves or amends. An ADR conforming to no policy is either missing its policy or is really a policy itself.
5. **Policies are written one at a time, each earned by a real defect** — the register grows only when a gap is proven, per the framework's own restraint.

## Rationale

The framework is not new invention — it is *elevation*: half of Atlas's real policy already exists, buried where it can't be cited. Adopting it turns "we wrote it down" into "it is enumerable, ownable, and auditable." It also gives the boundary-crossing rule from `ADR-0018` its policy home (`POL-0003`), the CIS work its governing requirement (`POL-0007`), and the offline-Root/PKI work a future home (the framework's flagged "POL — PKI & Trust"). Keeping the core register small and defect-earned honours `DR-001` (documentation must reduce work, not manufacture it).

## Consequences

- **`Atlas-Governance-Framework.md` status flips** from "proposed model, needs an adopting ADR" to adopted; its Change Log gains an adoption entry pointing here.
- **`POL-0001` status flips** from "DRAFT — NOT IN FORCE" to adopted once §5–§8 are completed from the framework; its "Adopting decision: NONE YET" line points here.
- **Next policies to write** (framework adoption path): `POL-0002` (Secrets) and `POL-0004` (Source of Truth) — the two defect classes that bit hardest. *(Drafted alongside this ADR.)*
- **Existing ADRs backfill `Governing Policy:`** during the next reconcile pass — not urgently, but before the next freeze.
- **`ADR-0018`'s boundary rule is now also `POL-0003`'s requirement** — one is the decision, the other the standing policy; they must stay consistent.

## Review Trigger

- When any new defect class appears that no existing policy covers — that is the signal to add a policy, not to widen an existing one past recognition.
- At each freeze audit, confirm the register still matches the estate and no policy has silently gone stale.

## Appendix — `Governing Policy:` backfill map (starter)

The register requires every ADR to name the standing requirement it serves. Below is the starter mapping to apply at the next reconcile pass (add a `Governing Policy:` row to each ADR). Entries marked *candidate* point at a policy the framework flags but that isn't written yet — assign when it lands. This is a *starter*: confirm each against the ADR's actual text; several map to more than one.

| ADR | Subject | Governing Policy |
|---|---|---|
| 0001 | Parallel PVE01 work before freeze | `POL-0003` (Change Control) |
| 0002 | SW01 Gi1/0/3 VLAN assignment | `POL-0007` (Hardening) / `POL-0008` (Naming) |
| 0003 | AD CS vs OpenSSL CA | *candidate POL — PKI & Trust* |
| 0004 | NPS vs FreeRADIUS | *candidate POL — Access & AAA* |
| 0005 | FGT01 egress scope deferred | `POL-0007` (Hardening) |
| 0006 | Foundation enrichment before freeze | `POL-0003` (Change Control) |
| 0007 | `atlas.lab` domain suffix | `POL-0008` (Naming & Addressing) |
| 0008 | Foundation holds process only | `POL-0004` (Source of Truth) / Charter Rule 4 |
| 0009 | Intermediate CA not compromised | `POL-0002` (Secrets) / *candidate POL — PKI & Trust* |
| 0010 | Repo publication preconditions | `POL-0002` (Secrets) / `POL-0001` (Audit) |
| 0011 | Game-Day failure drills | `POL-0005` (Backup & Recovery) |
| 0012 | Quarantine, not delete | `POL-0006` (Evidence & Verification) |
| 0013 | Retire `bridgeLocal` | `POL-0008` (Naming & Addressing) / `POL-0003` |
| 0014 | MKT01 L2 management posture | `POL-0007` (Hardening) |
| 0015 | Pack sequencing | `POL-0003` (Change Control) |
| 0016 | MKT01 recovery/console deferred | `POL-0007` (Hardening) |
| 0017 | Defer CMOS battery | `POL-0003` (Change Control) |
| 0018 | Operating model / silos | `POL-0003` (Change Control) |
| 0019 | Book-1 audit mandate | `POL-0001` (Audit) |
| 0020 | NTP time-source architecture | `POL-0006` (Evidence) / *candidate POL — Logging & Time* |
| 0021 | AD as tiered identity backbone | *candidate POL — Access & AAA* |
| 0022 | Freeze Book 1 | `POL-0001` (Audit) / `POL-0003` |
| 0023 | Core/segmentation topology | `POL-0007` / *candidate POL — Network Segmentation* |
| 0024 | IT headcount (scenario) | *n/a — scenario decision* |
| 0025 | Lab-02 tandem scope | *n/a — scoping decision* |

## Context — Future Direction (added 2026-08-02): governance built for findability + fast, self-service decisions

The operator's intent for where this framework goes next: **governance should let anyone in a situation quickly find the rule or decision that applies and act on it — without routing through a manager.** The primary audience is engineers, but the same self-service findability should serve everyone. Three moves realize it:

1. **Fewer, clearer standing rules — absorb the policy-/standard-shaped ADRs into Policies** (the reconciliation `ADR-0054` designs; executed at Backlog #39). When the standing rules are a small, enumerable set, "what applies to me here?" has a short answer.
2. **A findability layer keyed to the *situation*, not the doc-type** — a "you are doing X / you are role Y → here is the rule/decision that governs it" router (the human counterpart to `AI-Context/What-To-Check-First.md`). This is the deliverable that makes the layer usable without a gatekeeper.
3. **Preserve the original ADRs as a *legacy ADR index*** — same structure as the current `ADR-Index.md`, holding the ADR pages exactly as they are today, so nothing is lost as ADRs become policy *amendments* (`ADR-0012` preserve-not-delete). The live index carries the current decisions; the legacy index is the dated trail.

This information architecture is also the intended backbone of a **future Atlas website** — the same "find what governs your situation, fast" model, published. Execution + the structural reshape are tracked at **Backlog #41** (Foundation overhaul); the ADR→policy mechanism is `ADR-0054`/#39. This section records the *why* (self-service, situation-based, no-manager-gatekeeping) those items serve.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed 2026-07-17. Adopts `Atlas-Governance-Framework.md` and its Policy Register as normative; makes the layer hierarchy binding; fixes policy numbering (register authoritative, `POL-0001` §7 superseded); adopts `POL-0001` (Audit) under the Security silo; requires `Governing Policy:` on future ADRs. Unblocks `POL-0002` and `POL-0004`. Carries the starter `Governing Policy:` backfill map (appendix) for the reconcile pass. |
