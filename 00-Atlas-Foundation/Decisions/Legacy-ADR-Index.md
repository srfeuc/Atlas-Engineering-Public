---
Title: Legacy ADR Index — the pre-reconciliation trail
Path: 00-Atlas-Foundation/Decisions
Status: 🔒 Signpost to the frozen pre-reconciliation ADR snapshot (`ADR-0012` — preserve, don't delete). The **live** index is [`ADR-Index.md`](./ADR-Index.md); this is the easy-to-reach door to how the ADRs read *before* the #39 reconciliation.
Version: 1.0
---

# Legacy ADR Index — how the ADRs read before the reconciliation

> 🔒 **Nothing is lost.** On **2026-08-03**, immediately before `ADR-0026` was accepted and the #39 / `ADR-0054` reconciliation re-scoped the policy- and standard-shaped ADRs, **every ADR and the index were frozen byte-exact** into a snapshot. This page is the reachable pointer to that dated trail — one click from the live index. The snapshot is never edited (`ADR-0012`).

## The frozen set

- 📁 **`99-Archive/Legacy-ADRs-2026-08-03/`** — all **54 ADRs** (`ADR-0001`…`ADR-0054`) + the frozen index + a README, byte-exact as of 2026-08-03.
- 📇 **The frozen index:** `99-Archive/Legacy-ADRs-2026-08-03/ADR-Index.md` — the pre-reconciliation `ADR-Index` (v1.30), exactly as it read.
- 📄 **The snapshot README:** `99-Archive/Legacy-ADRs-2026-08-03/README.md` — how the freeze was made and why.

## How to read it

The **[live `ADR-Index`](./ADR-Index.md) is current** — always cite it for what a decision says *now*. Come **here** to see how an ADR read *before* it was materialized into a standard or had its rule promoted to a policy — the "before" side of the reconciliation. Use the same number: `ADR-0037` live vs `ADR-0037` frozen.

## What the reconciliation changed (the "after")

The live ADRs now carry the reconciliation result (`ADR-0054`); the frozen copies do not:

- **(B) standard-shaped ADRs → materialized as `STD-####`** (the ADR keeps a `Materialized as STD-000x` row): `ADR-0037`→[`STD-0005`](../Standards/STD-0005-Device-Documentation.md) · `ADR-0053`→`STD-0006` · `ADR-0032`→`STD-0007` · `ADR-0033`→`STD-0008` · `ADR-0049`→`STD-0009` · `ADR-0041`→`STD-0010` · `ADR-0043`→`STD-0011` · `ADR-0048`→`STD-0012`.
- **(C) policy-shaped ADRs → rule promoted to a `POL-####`** (the ADR keeps a `Rule promoted to POL-xxxx` row): `ADR-0008`/`0012`→`POL-0014` · `ADR-0011`→`POL-0005` · `ADR-0019`→`POL-0001` · `ADR-0034`→`POL-0004` R5 · `ADR-0044`→`POL-0016`.
- **(A) decisions** keep their body; every ADR gained a `Governing Policy:` line (the generated policy directories are built from those).

The full working list is the [`Governance-Reconciliation-Triage`](../Governance/Governance-Reconciliation-Triage.md).

## Related

[`ADR-Index`](./ADR-Index.md) (live) · `AI-Context/ADR-Navigation` (the navigator) · [`Governance-Reconciliation-Triage`](../Governance/Governance-Reconciliation-Triage.md) · [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) R2 (preserve, don't delete) · [`ADR-0012`](./ADR-0012-Unverified-Content-Is-Quarantined-Not-Deleted.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. Created the reachable Legacy-ADR signpost (#39/#41 Increment 5) — a one-click door from the live index to the frozen pre-reconciliation snapshot; summarizes the (B)→STD / (C)→POL mapping so a reader can see the before/after. |
