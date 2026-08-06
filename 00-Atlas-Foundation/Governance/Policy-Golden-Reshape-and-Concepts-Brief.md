---
Title: Policy Golden-Reshape + Academy Concepts — Execution Brief (next session)
Path: 00-Atlas-Foundation/Governance
Status: ✅ DONE (2026-08-04) — retired (`ADR-0012`). Both follow-ons complete, and the operator expanded the arc: (1) all 12 pre-golden policies `POL-0001..0013` reshaped to the golden shape (16/16 ★ in `Policies/README`); (2) the two standards-flagged Concepts built (`Encryption-and-PKI-in-Atlas` ⭐ nailed as the golden reference, #30-F; `Out-of-Band-Recovery`, #31). **Plus the expanded scope the operator approved:** 3 more policy why-layer Concepts (Secrets · Backup · Risk) + the SCT/hardening Concept + the `STD-0001`/`STD-0002` why-pages + the completed Academy Directory (§9/§11/§12 twins — the SoT router is now fully twinned). See the `SESSION-HANDOFF` session-32 blocks.
Version: 1.1
Date: 2026-08-04
---

> ✅ **DONE — retired 2026-08-04 (`ADR-0012`; preserve, don't delete).** Everything below is the historical execution plan, kept as the record. The work is complete: all 12 policies reshaped (16/16 ★), the 2 flagged Concepts built + the golden image nailed, and the operator-expanded scope (3 more concepts · the SCT + STD-0001/0002 why-pages · the 3 Directory twins) all landed and committed, 0 broken links throughout.

# Policy Golden-Reshape + Academy Concepts — Execution Brief

> 🤖 **You are the next session.** #41 (the Foundation structural overhaul) is **done** — its brief is retired in [`Foundation-Overhaul-Plan.md`](./Foundation-Overhaul-Plan.md). Two operator-queued follow-ons remain; this is their turnkey plan. Both are **content-quality passes, not structural moves** — go one policy / one Concept at a time, refresh the handoff after each.

## 0. Orient first (cold start)

**Read-order (before touching anything):**
1. `AI-Context/README.md` + `What-To-Check-First.md` — the estate map + the house rules.
2. [`SESSION-HANDOFF.md`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) — the `📍 CURRENT STATE` + latest block.
3. **This brief** — it operationalizes Backlog **#42** (the policy/standard layer) + **#30-F / #31** (the Academy Concepts).

**House rules in one breath:** docs-only · **Seth runs all git** (you write files + print a PowerShell block; never `git add .`; **LF**; on this git build a `git mv` destination dir must be `mkdir`'d first, and stage with `git add -u` + a `git status` re-check to beat the write-propagation lag). Evidence over intent. **One home per fact; point, don't copy.** Never a live secret. **Plan → ask at planning → one piece at a time → refresh the handoff after each.** Bridge-down = say so loudly.

## 1. Task A — reshape `POL-0001..0013` to the golden shape

**Why:** the governance layer is in force, but only `POL-0004/0014/0015/0016` carry the **★ golden shape**; `POL-0001..0013` are correct but still read flatter. Bring each up to the encryption-page look so every policy is at-a-glance usable and its precedence is grep-able.

**The golden shape to match** (copy the *structure*, not the content):
- Exemplars: [`Standards/STD-0004-Encryption.md`](../Standards/STD-0004-Encryption.md) (the "encryption page" the operator reviewed) + the golden policies [`POL-0004`](../Policies/POL-0004-Source-of-Truth.md) · [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) · [`POL-0015`](../Policies/POL-0015-Engineering-and-Build-Discipline.md) · [`POL-0016`](../Policies/POL-0016-Realism-and-Learning.md), and the skeleton [`Templates/POL-Template.md`](../Templates/POL-Template.md).
- Each reshaped policy gets: an **at-a-glance** opener · numbered **R# clauses** · each clause wired **down to its materialized `STD-####`** (the *how*) and **out to the adopting/amending `ADR-####`** (the *why*, detail pulled up) · a **Sources-of-truth** map · a **Learn-it (Academy)** source-of-truth section · the amendment model · and the **generated `AUTOGEN:decisions` directory kept intact** (never hand-edit generated blocks; the generator is [`tools/Build-Policy-Directories.ps1`](../../tools/Build-Policy-Directories.ps1)).

**The list (12 — `POL-0004` is already ★):** `POL-0001` Audit · `POL-0002` Secrets · `POL-0003` Change-Control · `POL-0005` Backup · `POL-0006` Evidence · `POL-0007` Hardening · `POL-0008` Naming/Addressing · `POL-0009` Incident-Response · `POL-0010` Acceptable-Use · `POL-0011` Data-Governance · `POL-0012` Risk · `POL-0013` Business-Continuity. Register + ★ status: [`Policies/README.md`](../Policies/README.md).

**Per-policy recipe:** one policy at a time → reshape → wire its clauses to the real `STD-####`/`ADR-####` (and to the device evidence a standard names) → flip its **★** in [`Policies/README`](../Policies/README.md) → verify links on disk (0 broken) → refresh the handoff → commit block for Seth.

## 2. Task B — build the standards-flagged Academy Concepts (#30-F / #31)

**Why:** Stage 1's Learn-it links point at two Concepts that don't exist yet. Build them in the Academy Concepts layer.

**Build:**
- **`Atlas-Academy/Concepts/Encryption-and-PKI-in-Atlas.md`** — the "why it works" module behind `STD-0004` (Encryption) + the two-tier PKI (`RCA01`→`ICA01`, `ADR-0027`/`ADR-0031`). Ground every point in a real Atlas artifact (the CTR ciphers · the DH-2048 floor · the documented SHA1-MAC ceiling from STD-0004; the get-not-show cert sagas `MC-0001`/`MC-0002`; the SAN reissue `CM-0007`/`CM-0008`).
- **`Atlas-Academy/Concepts/Out-of-Band-Recovery.md`** (name to taste) — the module behind console / out-of-band recovery, grounded in the real `Recover-a-Locked-Out-Router-Out-of-Band` Playbook + `STD-0003` (console break-glass) + the `CM-0017`/`CM-0018` MKT01 lockout history.

**Model to match:** the Academy Documentation Standard (`ADR-0053`) + the first full golden module [`Concepts/Tiered-Admin-Model.md`](../../Atlas-Academy/Concepts/Tiered-Admin-Model.md) + the [`Concepts/README.md`](../../Atlas-Academy/Concepts/README.md) index. Module shape (ADR-0053): The Concept → The Atlas Example (real config/commands) → What Went Wrong (real troubleshooting) → How to Explain This in an Interview.

**🔴 Ask at planning:** whether to nail a **Concept "golden image"** (the canonical module shape) off these two — the operator raised it (#30-F).

**Per-Concept recipe:** one Concept at a time → write it grounded in the named real artifacts → wire it into [`Concepts/README`](../../Atlas-Academy/Concepts/README.md) + the **Learn-it** sections of the standards/policies that point at it → verify links → refresh handoff → commit block.

## 3. Done when
- [ ] `POL-0001..0013` reshaped to the golden shape; each **★** in `Policies/README`; 0 broken links.
- [ ] `Encryption-and-PKI-in-Atlas` + the out-of-band-recovery Concept built + wired into `Concepts/README` and their Learn-it back-links; the Concept golden-image question decided with the operator.
- [ ] Handoff + backlog refreshed after each piece; **this brief retired with a ✅ DONE banner** (`ADR-0012`).

## Related
Backlog **#42** (Standards/Policy layer) · **#30-F / #31** (Academy Concepts) · [`Foundation-Overhaul-Plan.md`](./Foundation-Overhaul-Plan.md) (the retired #41 brief — the predecessor) · [`Governance-Reconciliation-Triage.md`](./Governance-Reconciliation-Triage.md) · [`Atlas-Governance-Framework.md`](./Atlas-Governance-Framework.md) · `ADR-0053` (Academy Standard) · `ADR-0012` (preserve).
