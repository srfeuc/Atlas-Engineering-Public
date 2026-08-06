---
Title: Foundation Refinement + Academy↔Labs Integration + Charter Currency — Execution Brief (next session)
Path: 00-Atlas-Foundation/Governance
Status: 🟢 ACTIVE plan (`ADR-0049`) — **paste this into a fresh session as its task brief.** The turnkey what/where/how for three operator-queued refinement passes. Retire with a ✅ DONE banner (`ADR-0012`) when complete.
Version: 1.0
Date: 2026-08-04
---

# Foundation Refinement + Academy↔Labs Integration + Charter Currency — Execution Brief

> 🤖 **You are the next session.** The big content arcs are done — the governance layer is golden (16/16 ★ policies, 12 STDs, every policy/standard with a real Academy why-layer), and the Academy Directory is the complete expanded Source-of-Truth (predecessor briefs retired: [`Policy-Golden-Reshape-and-Concepts-Brief`](./Policy-Golden-Reshape-and-Concepts-Brief.md), [`Foundation-Overhaul-Plan`](./Foundation-Overhaul-Plan.md)). This brief is **three refinement passes** the operator queued — all *wiring & currency*, not new structure. Go one doc / one device at a time; refresh the handoff after each logical piece.

## 0. Orient first (cold start)

**Read-order (before touching anything):**
1. `AI-Context/README.md` + `What-To-Check-First.md` — the estate map + the house rules.
2. [`SESSION-HANDOFF.md`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) — the 📍 CURRENT STATE + latest block.
3. This brief — it operationalizes Backlog **#43**.

**House rules in one breath:** docs-only · Seth runs all git (you write files + print a PowerShell block; never `git add .`; LF; on this git a `git mv` destination dir must be `mkdir`'d first, and stage with `git add -u` + a `git status` re-check to beat the write-propagation lag). Evidence over intent. One home per fact; point, don't copy. Never a live secret. Plan → ask at planning → one piece at a time → refresh the handoff after each. Bridge-down = say so loudly. **Verify links on disk after every batch (0 broken).**

---

## 1. Pass A — Integrate templates + wire the Foundation process docs

**Why.** The Foundation process/governance docs *describe* processes that have templates and policies, but reference them in **bare backtick text**, not links. Concrete: [`Atlas-Change-Management-Process.md`](./Atlas-Change-Management-Process.md) (v2.1) says *"the Change Record template carries a `Silo(s) / boundary crossed` field"* and *"the Change Record templates now carry…"* — but **links neither** [`Templates/Change-Record-Template.md`](../Templates/Change-Record-Template.md) nor [`Templates/Major-Change-Record-Template.md`](../Templates/Major-Change-Record-Template.md), nor the policy it operationalizes ([`POL-0003`](../Policies/POL-0003-Change-Control.md)), nor the Academy why-layer ([`A-Completed-Command-Is-Not-Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md)).

**Do.** A pass over the Foundation *process/governance* docs to turn bare references into real links and make each template discoverable from the doc that uses it:
- **`Atlas-Change-Management-Process.md`** first (the operator's example): link the two Change-Record templates, `POL-0003`, `ADR-0018` (silos), the Charter rules it cites, and the `A-Completed-Command` concept; add a small **"Templates & governing rule"** callout near the top (the template you fill · the policy that governs · the concept that explains the *why*).
- Then sweep the sibling process docs — [`Atlas-Workflow.md`](./Atlas-Workflow.md), [`Documentation/Contributing-Adding-Docs.md`](../Documentation/Contributing-Adding-Docs.md), [`Documentation/Atlas-Documentation-Standard.md`](../Documentation/Atlas-Documentation-Standard.md), [`Documentation/Atlas-Documentation-Workflow.md`](../Documentation/Atlas-Documentation-Workflow.md) — for bare template/policy/standard references and link them (each `Build-Record`/`Build-Guide`/`ADR`/`POL`/`STD` template → [`Templates/`](../Templates/)).
- **Model:** the golden policies already do this (`POL-0014`'s item table + Related links its template + framework). Match that density; don't restate, link (`POL-0004`).

**Per-doc recipe:** one doc → add the template/policy/concept links (+ a small callout where it helps) → verify links on disk (0 broken) → refresh handoff → commit block.

## 2. Pass B — Academy ↔ Labs integration (device docs link UP into the Academy)

**Why.** The Academy is meant to be the layer device pages **link up into** ([`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md); [`Academy-Vision-and-Scope`](../../Atlas-Academy/Academy-Vision-and-Scope.md): *"device `Diagnostics.md`/`Troubleshooting.md` pages link up into the Academy"*) — but they don't yet. 🔎 **Measured 2026-08-04:** across **265 `.md` files** under [`Labs/Lab-02-Cisco-Core/Devices/`](../../Labs/Lab-02-Cisco-Core/Devices/) there are **6 markdown links total** and **zero** to the Academy. The device docs reference the Academy in **bare backtick text** — e.g. [`1941-Core-Router/Roadmap.md`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Roadmap.md) names CCNA/CCNP per stage and says *"cert maps in `Atlas-Academy/`"* with **no link**. That's the "broken links" the operator sees: references that don't resolve because they were never made links. (One genuine broken link also exists — `MKT01-East-West-Firewall/Build-Guide.md` — fix it in the pass.)

**Do.** Add real, relative Academy links to the device docs, following the standard page-set's natural seams:
- **`Roadmap.md`** — the **Certification alignment** table's CCNA/CCNP/AZ/FCP names → link the cert maps ([`Certification/`](../../Atlas-Academy/Certification/)); the "Related" line → link the device's **per-domain Directory page** ([`Directory/`](../../Atlas-Academy/Directory/) — e.g. a router → [`Network-and-Addressing`](../../Atlas-Academy/Directory/Network-and-Addressing.md) / [`Security-and-Perimeter`](../../Atlas-Academy/Directory/Security-and-Perimeter.md)).
- **`Diagnostics.md`** — the `show`/verify commands → link **up** into the matching [`Command-Library/`](../../Atlas-Academy/Command-Library/) platform page (`POL-0008`: the device page owns *its* facts; the Command-Library is the cross-device reference).
- **`Troubleshooting.md`** — each real symptom → link the matching [`Playbooks/`](../../Atlas-Academy/Playbooks/) leaf.
- **`README.md` / `Considerations.md`** — link the relevant **Concept** why-layer (e.g. a firewall device → [`Identity-Aware-vs-Zone-Firewall-Policy`](../../Atlas-Academy/Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md); an identity/CA device → [`Encryption-and-PKI-in-Atlas`](../../Atlas-Academy/Concepts/Encryption-and-PKI-in-Atlas.md) / [`Tiered-Admin-Model`](../../Atlas-Academy/Concepts/Tiered-Admin-Model.md)).

**Scale + order.** ~24 device folders. This is a big pass — **start with the networking core** (`1941` · `SW01` · `MKT01-East-West-Firewall` · `FGT01-Perimeter-Firewall`), then identity (`DC` · `RCA01-ICA01-ADCS` · `NPS01` · `PAW01`), then the rest. **One device at a time**, all its page-set docs, then verify + commit. Where a device has no matching Academy page yet, link the Concepts/Directory index (don't invent a target — a link to a nonexistent page is the exact "broken link" this pass fixes). 🔴 **Do not bulk-rewrite** — the operator's cadence is one-at-a-time, reviewed.

**Per-device recipe:** one device → add the up-links across its Roadmap/Diagnostics/Troubleshooting/README → verify links on disk (0 broken) → refresh handoff → commit block.

## 3. Pass C — Charter currency (bring it up to the governance layer)

**Why.** [`Atlas-Charter.md`](./Atlas-Charter.md) (v1.0, 2026-08-02) is **strong on the Book-1-derived Locked Rules** (17 of them, each from a real defect) — but it predates the mature governance layer and never connects to it. It has **no reference** to the Policy>Standard>ADR framework ([`Atlas-Governance-Framework`](./Atlas-Governance-Framework.md) / `ADR-0026` / `ADR-0054`), the 16 `POL-####`, or the 12 `STD-####` that now carry many of its rules; and it is **Confluence-centric** (Rules 3/11: "three-click in Confluence," "Confluence review is required") while [`POL-0014` R2](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) made the **repository the source of record** (*"Confluence is the published copy"*).

**Do — a currency reconciliation, not a rewrite** (the rules are good; connect them):
- Add a **"How the Charter relates to the governance layer"** section: the Charter is the constitution *above* Policy>Standard>ADR ([`Atlas-Governance-Framework` §1](./Atlas-Governance-Framework.md)); where a Locked Rule is now a standing requirement, the **policy carries it and the Charter references the policy** (Framework §9). Add a **Rule → Policy map**: Rule 4 (one home) → [`POL-0004`](../Policies/POL-0004-Source-of-Truth.md)/[`POL-0008`](../Policies/POL-0008-Naming-and-Addressing.md); Rule 7 (change records) → [`POL-0003`](../Policies/POL-0003-Change-Control.md); Rule 8 (verify) + 13/14 (evidence) → [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md); Rule 15/15a/15b (guide reconciliation) → [`POL-0003`](../Policies/POL-0003-Change-Control.md)/[`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md); Rule 16 (count-to-zero) → [`POL-0003` R3](../Policies/POL-0003-Change-Control.md); Rule 17 (operator writes the config that is the lesson) → [`POL-0016`](../Policies/POL-0016-Realism-and-Learning.md).
- **Reconcile the Confluence-centric language to repo-first** ([`POL-0014` R2](../Policies/POL-0014-Documentation-and-Knowledge-Management.md)): the repo is the source of record; the 3-click rule now lives in the Academy ([`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md)) + the Foundation findability router. Keep the rules; update *where* they apply.
- Refresh the **"Documentation types"** list to the current doc-type set (add POL/STD, the Academy layers) and link the governing docs.
- 🔴 **Preserve history** (`ADR-0012`): the Book-1 numbered citations (`026`/`031`/`035`/`048`/`051`…) are the audit trail — **do not "fix" them.** Bump the Charter version + amendment history; the locked-rule *text* stays, the *connections* are added.

🔴 **Ask at planning:** whether the Charter refresh should also **renumber/deduplicate** any Locked Rule that is now fully a policy, or leave all 17 in place with the cross-map (recommended: leave in place — the Charter is the constitution, the policy is the elaboration; `ADR-0012` favors preserve).

**Recipe:** plan the Rule→Policy map with the operator → edit the Charter (add the governance-layer section + map + repo-first reconciliation; version bump) → verify links → refresh handoff → commit block.

## 4. Done when

- ☐ Pass A — the Foundation process docs link their templates/policies/concepts (Change-Management first); 0 broken links.
- ☐ Pass B — device docs link up into the Academy (cert maps · Directory · Command-Library · Playbooks · Concepts), networking-core-first then the rest; the one genuine broken link fixed; 0 broken links.
- ☐ Pass C — the Charter carries the governance-layer section + the Rule→Policy map + the repo-first reconciliation; history preserved; version bumped.
- ☐ Handoff + backlog refreshed after each piece; this brief retired with a ✅ DONE banner (`ADR-0012`).

## Related

Backlog **#43** (this arc) · [`Atlas-Governance-Framework`](./Atlas-Governance-Framework.md) · [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) (Academy links-up model) · [`ADR-0037`](../Decisions/ADR-0037-Atlas-Documentation-Standard.md) (the device page-set) · [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (repo-is-source-of-record) · the retired predecessors [`Policy-Golden-Reshape-and-Concepts-Brief`](./Policy-Golden-Reshape-and-Concepts-Brief.md) · [`Foundation-Overhaul-Plan`](./Foundation-Overhaul-Plan.md).
