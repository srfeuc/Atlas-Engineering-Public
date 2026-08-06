---
Title: Governance Reconciliation Triage — the per-ADR working list
Path: 00-Atlas-Foundation/Governance
Status: 🟢 EXECUTING (session 28, 2026-08-03) — `ADR-0026` accepted; the layer is in force. Applied one policy at a time in the golden-image shape. ✅ Line-backfill + all 16 generated directories DONE (see the Execution record below). Pending: the (C) body re-scopes.
Version: 1.0
Date: 2026-08-03
---

# Governance Reconciliation Triage

> The checklist behind **`ADR-0054`**. One row per ADR, tagged with its **disposition** and its proposed **`Governing Policy:`**. A future coordinated single-writer session (**Backlog #32**) works down this list, applies the `Governing Policy:` line, and — for the policy-shaped rows — absorbs the standing rule into its policy while keeping the ADR as the adopting/amending decision (`ADR-0012`: never deleted).

## The three dispositions (from `ADR-0054` §3)

- **(A) Decision** — a genuine chose-X-over-Y. *Action:* add the `Governing Policy:` line; otherwise leave as-is. (The majority.)
- **(B) Standard-in-effect** — defines *how*, estate-wide + testable. *Action:* recognize in place as the estate standard for its domain; add the `Governing Policy:` line; add a "Doc-type: Standard-in-effect" note. **No renumber.**
- **(C) Policy-shaped** — a standing rule that must always be true. *Action:* promote the rule into a `POL-xxxx`; keep + re-scope the ADR as the decision that adopted/amended it.

> **Adoption gate CLEARED (2026-08-03):** `ADR-0026` accepted → the layer is in force. **`POL-0014` adopted** (v1.0, golden shape); **`POL-0004` re-adopted** (v2.0, golden shape). **`POL-0015`/`POL-0016` still to fold** — rows pointing at them land when those policies are folded.

## Progress (session 28, 2026-08-03)

- ✅ **`ADR-0026` → Accepted** (operator, the `ADR-0054` §1 gate). Framework + `POL-0001` status gap closed; `Atlas-Governance-Framework` rebuilt to **v2.0** (grounding doc + `Governance/` front door).
- ✅ **`POL-0014` (Documentation & Knowledge Management)** — folded its 9 rows: `ADR-0008`/`ADR-0012` **(C)** rules promoted; `ADR-0032`/`0033`/`0037`/`0043`/`0049`/`0053` **(B)** standards-in-effect; `ADR-0052` **(A)** pointer rule. Golden shape, generated Decisions directory.
- ✅ **`POL-0004` (Source of Truth)** — golden rewrite (v2.0); `ADR-0034` **reclassified A → C** (principle absorbed into R5); `ADR-0051` **(A)**.
- ✅ **`Templates/POL-Template.md`** built (the golden shape) + **`tools/Build-Policy-Directories.ps1`** designed (generates each policy's Decisions directory from `Governing Policy:` lines).
- ⏭️ **Next:** the legacy ADR snapshot (freeze-first) → the (C) re-scopes of `ADR-0008`/`0012`/`0034` → `POL-0015` (Build Discipline) → `POL-0016` (Realism & Learning) → the (A) `Governing Policy:` backfill sweep.
- ✅ **Increment 4 (session 30, 2026-08-03):** `POL-0015` + `POL-0016` **folded to full policies in force** (v1.0) — each requirement wired to its materialized STD + a Learn-it section. The **(C) re-scopes** annotated with a `Rule promoted to` row: `ADR-0008`/`0012`→`POL-0014` · `ADR-0011`→`POL-0005` · `ADR-0019`→`POL-0001` · `ADR-0044`→`POL-0016` (the rule now lives in the policy, `ADR-0054` (C)→policy). `ADR-0034` was already done → `POL-0004` R5.
- ✅ **Increment 5 (session 30, 2026-08-03) — Stage-1 governance-content COMPLETE.** Built the **`Legacy-ADR-Index`** (reachable door to the frozen snapshot), the **`Policies/README`** register (parity with Standards), upgraded **`AI-Context/ADR-Navigation`** into the navigator (the policy/standard map + legacy pointer), and registered the 12-STD layer in the **Framework** + **Source-of-Truth §9**. The #39 content half is done; the `#41` structural reorg (`09-` rename · loose-file folders · README redo) remains its own deferred pass.

## Execution record (commit trail)

The `#39` reconciliation, executed **session 28 (2026-08-03)** — the dated trail (`ADR-0012` preserve):

| Commit | What landed |
|---|---|
| `810a528` | Froze the pre-reconciliation ADR set → `99-Archive/Legacy-ADRs-2026-08-03/`. |
| `4a4a89d` | Grounded the governance layer — Framework v2 (front door), `POL-0014`/`POL-0004` folds, Build-Record family; `ADR-0026` accepted. |
| `00067c0` | The Source-of-Truth router + first Academy directory pages (Servers, Network). |
| `d9ac2b0` | The `tools/Build-Policy-Directories.ps1` generator. |
| `2642239` | `Governing Policy:` backfilled across the ADR set + all 16 policy directories generated. |

**Done:** the `Governing Policy:` line-backfill (49 added + 3 pre-existing) + the generated directories. **Still pending:** the **(C) body re-scopes** (`ADR-0008`/`0012`/`0034`/`0011`/`0019`/`0044` rewritten as the adopting decision), reviewed one at a time.

## Proposed policy homes referenced below

`POL-0001` Audit · `POL-0002` Secrets · `POL-0003` Change Control · `POL-0004` Source of Truth · `POL-0005` Backup & Recovery · `POL-0006` Evidence & Verification · `POL-0007` Hardening Baseline · `POL-0008` Naming & Addressing · `POL-0009` Incident Response · `POL-0010` Acceptable Use · `POL-0011` Data Governance/Privacy · `POL-0012` Risk Management · `POL-0013` Business Continuity · **`POL-0014` Documentation & Knowledge Management** (proposed) · **`POL-0015` Engineering & Build Discipline** (proposed) · **`POL-0016` Realism & Learning** (proposed).

> **Owed policy domains** the framework §2 already anticipates, surfaced again here: **PKI & Trust** (would own `ADR-0003`/`0027`/`0031`/`0050`), **Access & AAA** (would own `ADR-0004`/`0021`/`0028`/`0029`/`0040`), **Logging & Time** (would own `ADR-0020`). Until written, those rows point at the nearest existing policy and carry a 🔎 "PKI/AAA/Time policy owed" note.

## Global — process / governance / standards

| ADR | Title (short) | Disposition | Proposed `Governing Policy` | Note |
|---|---|---|---|---|
| ADR-0003 | AD CS vs OpenSSL (coexist) | A (superseded by 0031) | POL-0007 | 🔎 PKI policy owed |
| ADR-0004 | NPS vs FreeRADIUS | A (superseded by 0029) | POL-0010 / STD-0002 | 🔎 AAA policy owed |
| ADR-0007 | Adopt `atlas.lab` suffix | A | POL-0008 | naming |
| **ADR-0008** | **Foundation holds process only** | **C** | **POL-0014** | standing repo-structure rule → absorb into POL-0014 |
| ADR-0009 | Intermediate CA not compromised | A | POL-0009 (+POL-0002) | the IR + destroy-step lesson |
| ADR-0010 | Publication preconditions | A | POL-0011 (+POL-0010) | sanitization/data-governance gate |
| **ADR-0011** | **Game Days: unannounced drills** | **C** | **POL-0005** (+POL-0013/POL-0016) | rule already half-lives in POL-0005; ADR = the adopting decision |
| **ADR-0012** | **Quarantine, not delete** | **C** | **POL-0014** | textbook standing rule → absorb into POL-0014 |
| ADR-0015 | Pack sequencing & scope | A | POL-0014 (+POL-0003) | process decision |
| ADR-0018 | Operating model: silos | **Constitutional** | Charter | leave — every POL cites it as the owner authority; Charter-level, not a POL |
| ADR-0019 | Book-1 audit mandate | C (frozen) | POL-0001 | rule already in POL-0001; ADR frozen (Lab-01) |
| ADR-0020 | NTP time-source architecture | A | POL-0006 | 🔎 Logging & Time policy owed |
| ADR-0024 | Industrial IT headcount | A | POL-0016 | scenario realism |
| ADR-0026 | Adopt the Governance Framework | **Meta-adopting** | Charter | ⚠️ flip Proposed→Accepted (`ADR-0054` §1) — gates everything |
| **ADR-0032** | **Diagnostics/verification doc architecture** | **B** | **POL-0014** (+POL-0006) | standard-in-effect |
| **ADR-0033** | **ADR scope field + index** | **B** | **POL-0014** | meta-doc standard |
| **ADR-0037** | **Atlas Documentation Standard** | **B** | **POL-0014** | THE documentation standard, in effect |
| **ADR-0041** | **Incremental, test-gated implementation** | **B** | **POL-0015** (+POL-0006) | build discipline |
| **ADR-0043** | **Phased, dependency-gated Build-Guides** | **B** | **POL-0015** (+POL-0014 doc-type) | build + doc-type |
| **ADR-0044** | **Enterprise model; certs anchor skills** | **C** | **POL-0016** | standing realism principle |
| **ADR-0048** | **Automation & IaC model** | **B** | **POL-0015** | standard-in-effect |
| **ADR-0049** | **Session planning & handoff protocol** | **B** | **POL-0014** | doc process standard |

## Lab-01-Mikrotik-Core (frozen — annotate only, don't re-open)

| ADR | Title (short) | Disposition | Proposed `Governing Policy` | Note |
|---|---|---|---|---|
| ADR-0001 | PVE01 parallel work before freeze | A | POL-0003 | retroactive; frozen |
| ADR-0002 | SW01 Gi1/0/3 VLAN | A | POL-0008 | frozen |
| ADR-0005 | FGT01 policy scope kept broad | A | POL-0012 | accepted residual risk |
| ADR-0006 | Foundation enrichment before freeze | A | POL-0003 | retroactive; frozen |
| ADR-0013 | Retire `bridgeLocal` | A | POL-0007 | frozen |
| ADR-0014 | MKT01 L2 management posture | A | POL-0007 (+POL-0009) | frozen |
| ADR-0016 | MKT01 recovery posture | A | POL-0009 | frozen |
| ADR-0017 | Defer CM-0012 CMOS battery | A | POL-0012 | risk acceptance; frozen |
| ADR-0022 | Freeze Book 1 | A | POL-0003 | frozen |

> Lab-01 ADRs are frozen (`ADR-0022`). They get a `Governing Policy:` line for completeness but their content is **not** re-scoped — the freeze is preserved (`ADR-0012`).

## Lab-02-Cisco-Core (active — nearly all genuine decisions)

| ADR | Title (short) | Disposition | Proposed `Governing Policy` | Note |
|---|---|---|---|---|
| ADR-0021 | AD as tiered identity backbone | A | POL-0010 / STD-0002 | 🔎 AAA policy owed |
| ADR-0023 | Core & segmentation topology | A | POL-0008 (+POL-0007) | |
| ADR-0025 | Both tracks in tandem | A | POL-0016 | |
| ADR-0027 | AD CS two-tier PKI | A | POL-0007 | 🔎 PKI policy owed |
| ADR-0028 | FGT01 admin auth via LDAPS | A | STD-0002 / POL-0010 | 🔎 AAA policy owed |
| ADR-0029 | Drop FreeRADIUS → NPS | A | STD-0001 / POL-0010 | 🔎 AAA policy owed |
| ADR-0030 | DHCP on DC01 | A | POL-0008 | |
| ADR-0031 | Retire OpenSSL CA (unify on AD CS) | A | POL-0007 | 🔎 PKI policy owed |
| ADR-0034 | PVE01 networking ownership | **C** (principle promoted) | POL-0004 | ✅ 2026-08-03 — estate-wide "live-owns / frozen-points" principle absorbed into **POL-0004 R5**; ADR kept as the adopting decision |
| ADR-0035 | FGT01 no-UTM | A (superseded by 0047) | POL-0012 | |
| ADR-0036 | Compute topology + VM placement | A | POL-0008 (+POL-0013) | |
| ADR-0038 | pfSense inline IPS | A | POL-0007 (+POL-0009) | |
| ADR-0039 | Commit to full hybrid scope | A | POL-0016 | scope/realism |
| ADR-0040 | Entra Connect PHS | A | STD-0002 / POL-0010 | 🔎 AAA policy owed |
| ADR-0042 | Client workstation fleet | A | POL-0007 (+POL-0010) | |
| ADR-0045 | AZ-800/801 compute additions | A | POL-0008 | |
| ADR-0046 | Failover cluster + S2D | A | POL-0013 (+POL-0005) | HA/continuity |
| ADR-0047 | FGT01 FortiGuard UTM | A | POL-0007 (+POL-0009) | reverses 0035 |
| ADR-0050 | FGT01 TLS deep-inspection scope | A | POL-0011 (+POL-0007) | privacy carve-outs → data governance |
| ADR-0051 | DNS filtering: Pi-hole owns it | A | POL-0004 (+POL-0007) | single-owner |
| ADR-0052 | AI-Context folder | A | POL-0014 | structure decision |
| **ADR-0053** | **Academy Documentation Standard** | **B** | **POL-0014** | standard-in-effect (Academy) |

## Tally

- **(A) Decision — leave, add the line:** ~38 (all of Lab-01 + most of Lab-02 + a few Global).
- **(B) Standard-in-effect — recognize in place:** `ADR-0032`, `ADR-0033`, `ADR-0037`, `ADR-0041`, `ADR-0043`, `ADR-0048`, `ADR-0049`, `ADR-0053` (8).
- **(C) Policy-shaped — promote the rule, keep the ADR as adopter:** `ADR-0008`, `ADR-0011`, `ADR-0012`, `ADR-0019`, `ADR-0034` (→ POL-0004 R5), `ADR-0044` (6).
- **Special:** `ADR-0018` (constitutional → Charter), `ADR-0026` (meta-adopting → ✅ **Accepted 2026-08-03**).

> These are **proposed** dispositions for the operator to confirm. The (B)/(C) rows are the ones worth a second look — everything in (A) is mechanical.
