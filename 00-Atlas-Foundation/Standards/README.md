---
Title: Standards (STD-####) — the register + how the layer works
Path: 00-Atlas-Foundation/Standards
Status: 🟢 Living register (`ADR-0026` framework · `ADR-0054` reconciliation). The front door to the Standards layer.
Version: 1.3
---

# Standards — `STD-####`

> **A standard is the concrete, testable *how* a policy requires.** A policy says *what must always be true* (the why); a standard pins it to **real Atlas devices, configs, and values** you can set and then **prove with a read-back**; a guide is the step-by-step to get there. If a page here can't be applied to a device and audited with a command, it's too general — the specifics belong in it.

This is the register and the working rules for the layer. Cut a new standard from [`STD-Template`](../Templates/STD-Template.md).

## Where standards sit

```
Charter            the constitution — the operating principles everything answers to
  └─ POLICY        POL-####  · the standing rule (WHY it must be true)          ← governs ↓
      └─ STANDARD   STD-####  · the concrete, testable setting (HOW — real values, named targets)
          └─ ADR    the dated decision that adopted/amended the standard
          └─ GUIDE  the Build-Guide / runbook that walks you through applying it
```

Each standard **names its governing policy** (the *why* it serves) and its **adopting ADR** (the dated decision). The ADR keeps its `Governing Policy:` line, so it still appears in that policy's generated *Decisions* directory — the standard and the policy stay wired together, one home per fact (`POL-0004`).

## The register

Status is honest (`POL-0006`): **✅** in force (grounded + verifiable) · **🟡** exists but thin/generic — rewrite in progress · **📋** planned/materializing.

| Standard | Binds (domain) | Governing policy | Status |
|---|---|---|---|
| [`STD-0001`](./STD-0001-Password-and-Authentication.md) | Password & authentication — PSO-FinanceHR, LAPS, tier accounts, scrypt | `POL-0002` (+`POL-0010`) | ✅ estate-grounded v2.0 (#39/#42) |
| [`STD-0002`](./STD-0002-Access-Control.md) | Access control — AGDLP, the tier-deny GPOs, the PAW boundary | `POL-0010` | ✅ estate-grounded v2.0 |
| [`STD-0003`](./STD-0003-Physical-Security.md) | Physical & console/OOB — break-glass, iDRAC, CA air-gap, OT | `POL-0007` (+`POL-0003`) | ✅ estate-grounded v2.0 |
| [`STD-0004`](./STD-0004-Encryption.md) | Encryption — estate-CA certs, SSH crypto ceilings, BitLocker, key custody | `POL-0002` (+`POL-0007`/`POL-0011`) | ✅ estate-grounded v2.0 |
| [`STD-0005`](./STD-0005-Device-Documentation.md) | Device documentation — the per-device page-set + analytical elements | `POL-0014` | ✅ v1.0 (materialized `ADR-0037`) |
| [`STD-0006`](./STD-0006-Academy-Documentation.md) | Academy documentation — layers · 3-click · the Playbook mold | `POL-0014` | ✅ v1.0 (`ADR-0053`) |
| [`STD-0007`](./STD-0007-Diagnostics-and-Verification.md) | Diagnostics & verification — Diagnostics/Troubleshooting + the command home | `POL-0014` (+`POL-0006`) | ✅ v1.0 (`ADR-0032`) |
| [`STD-0008`](./STD-0008-ADR-Governance-and-Scope.md) | ADR governance — the Scope tag · global numbering · the index | `POL-0014` | ✅ v1.0 (`ADR-0033`) |
| [`STD-0009`](./STD-0009-Session-Planning-and-Handoff.md) | Session planning & handoff — ask-at-planning · the Living-STATE handoff | `POL-0014` | ✅ v1.0 (`ADR-0049`) |
| [`STD-0010`](./STD-0010-Incremental-Test-Gated-Build.md) | Incremental, test-gated build — one unit at a time, a gate per unit | `POL-0015` (+`POL-0006`) | ✅ v1.0 (`ADR-0041`) |
| [`STD-0011`](./STD-0011-Phased-Build-Guides.md) | Phased, dependency-gated Build-Guides — phase GATEs · one build-order owner | `POL-0015` (+`POL-0014`) | ✅ v1.0 (`ADR-0043`) |
| [`STD-0012`](./STD-0012-Automation-and-IaC.md) | Automation & IaC — two homes · learn-then-automate · idempotent | `POL-0015` | ✅ v1.0 (`ADR-0048`) |

**Materializing this stage (#39 / #42):** ✅ the **Documentation family is done** — STD-0005..0009 (above) materialized `ADR-0037`/`0053`/`0032`/`0033`/`0049` under `POL-0014`. ✅ the **Build family is done** — STD-0010..0012 (above) materialized `ADR-0041`/`0043`/`0048` under `POL-0015`. **All 8 standard-shaped ADRs are now materialized (Increment 3 complete) — the layer is 12 STDs.** Each keeps its ADR as the adopting decision (`ADR-0012` — preserved, originals in the legacy snapshot).

## How to write one (the bar: useful, not a stub)

1. **Copy [`STD-Template`](../Templates/STD-Template.md)** to `STD-XXXX-<Name>.md`; take the next free number (currently the next is **STD-0005**).
2. **Requirements are `R1…Rn`** — each a real value on a named target, citable as `STD-XXXX R#`, with the owner doc that carries the detail.
3. **Ground every rule in a real artifact** — a device folder, a `CIS-Hardening-*` baseline, an owner doc. Like an ADR, it should point at the actual estate, not a textbook.
4. **Verification is a read-back** — the exact command + the value you expect (`POL-0001` runs it; the device wins, Charter Rule 13).
5. **Name the governing policy + the adopting ADR.** Refresh AI-Context, and log it in the Backlog + `SESSION-HANDOFF`.

## Related

[`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md) (the Policy > Standard > ADR model) · [`Atlas-Source-of-Truth` §9](../Governance/Atlas-Source-of-Truth.md#9-governance-and-decisions) (the register router) · the [`Policies/`](../Policies/) layer above · [`Governance-Reconciliation-Triage`](../Governance/Governance-Reconciliation-Triage.md) (the ADR→policy/standard working list) · [`STD-Template`](../Templates/STD-Template.md).

## Change Log

| Version | Changes |
|---|---|
| 1.3 | 2026-08-03. +3 rows — the Build-family STDs (STD-0010..0012) materialized from `ADR-0041`/`0043`/`0048` under `POL-0015`; both families done (12 STDs). |
| 1.2 | 2026-08-03. +5 rows — the Documentation-family STDs (STD-0005..0009) materialized from `ADR-0037`/`0053`/`0032`/`0033`/`0049` under `POL-0014`. |
| 1.1 | 2026-08-03. Register statuses → ✅: **STD-0001..0004 rewritten estate-grounded (v2.0)** — real values + read-backs + a Learn-it (Academy) section + feeds/fed-by links; STD-0004 governing corrected to `POL-0002`. |
| 1.0 | 2026-08-03. Established the Standards register + front door (the layer had no README). States the layer model (concrete/testable *how* under a policy), the honest register (STD-0001..0004 flagged thin/rewrite-in-progress), the ADR-standards materializing this stage (#39/#42), and the how-to-write bar. Cuts from the new `STD-Template`. |
