---
Title: POL-0013 — Business Continuity
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force. Sibling to POL-0005 (Recovery).
Version: 2.0
---

# POL-0013 — Business Continuity

> **At a glance.** Atlas can keep its critical functions running — **or degrade them gracefully and knowingly** — through a disruption, and the plan to do so is **written and tested, not assumed**. Atlas is honest that it has little true HA today, so its continuity story is mostly graceful degradation + fast, proven recovery. This policy folds continuity into citable requirements (`POL-0013 R1`…) and doubles as a directory of the decisions that govern it (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement |
| Requirement, in one line | Critical functions keep running or degrade knowingly; a manual fallback where there's no HA; the dependency traps are mitigated or accepted; the plan is offline + tested. |
| Owner | 🔴 Platform/Operations silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)) |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) — elevating [`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) (Game Days) + the `048` rebuild premise + `305` (OT availability) |
| Builds on | [`POL-0005`](./POL-0005-Backup-and-Recovery.md) (recovery mechanics) · [`POL-0012`](./POL-0012-Risk-Management.md) (the BIA / RTO/RPO) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 **RC** · NIST SP 800-34 · Security+ SY0-701 **5.1** |

---

## Scope & applicability

Governs how the estate keeps critical functions available (or degrades them knowingly) through a disruption — the continuity strategy, the manual fallbacks, and the dependency traps that break continuity.

**Boundary with [`POL-0005`](./POL-0005-Backup-and-Recovery.md):** POL-0005 owns *recovery* (getting it back after it's gone) + 3-2-1; POL-0013 owns *continuity* (keeping running *during*). **Boundary with [`POL-0012`](./POL-0012-Risk-Management.md):** RTO/RPO and the BIA live in POL-0012 + the CA/PKI RPO-RTO doc; this policy *uses* them and links there — it does not restate them.

## Why this is a policy, not a note

Continuity (keeping running *during* a disruption) and recovery (restoring *after*) are different jobs, and Atlas is honest that it has **little true continuity today** — single FGT01, single MKT01, single Pi01, single PVE01, every one a SPOF. Its real story is **graceful degradation + fast recovery**, and *saying so* is the point: assuming continuity that doesn't exist (counting a single firewall or the shared-LOM iDRAC as resilient) is the failure this policy prevents.

---

## The standing requirements

Each is citable as `POL-0013 R#`.

### R1 — Every critical function has a continuity posture, and a manual fallback where it has no HA

For each critical function (from the BIA in [`POL-0012`](./POL-0012-Risk-Management.md)): a stated posture — **redundancy / failover / manual fallback / graceful degradation**. AtlasERP → paper/spreadsheet fallback; the OT line → *isolate, don't interrupt* (availability outranks confidentiality, `305`); identity → cached credentials + local break-glass; the order portal → a static "back soon" page + phone orders.

### R2 — The dependency traps are mitigated or an accepted risk

The Atlas-specific traps each carry a mitigation or a recorded accepted risk ([`POL-0012`](./POL-0012-Risk-Management.md)): the **circular dependency** (the vault runs on the host that dies — broken by the **paper** passphrase, `049`); **credentials live on the host you wipe** (`048` — extract *before*); the **iDRAC is not truly out-of-band** (shared LOM — don't count it); MKT01's **console** is now the continuity control ([`ADR-0016`](../Decisions/ADR-0016-MKT01-Recovery-Posture-Console-Deferred.md)); **both backups in one room** (no continuity survives losing the room until the off-site copy exists, [`POL-0005`](./POL-0005-Backup-and-Recovery.md)).

### R3 — Availability outranks confidentiality on the OT line

A security control that risks stopping production is **itself a continuity risk** (`305`, NIST 800-82) — isolate the OT floor rather than interrupt it (the segmentation is its compensating control, [`STD-0003`](../Standards/STD-0003-Physical-Security.md) R4).

### R4 — The plan and its contacts live offline, and continuity is tested

The plan + crisis contacts are reachable **offline** (on nothing the disruption takes down); the paper passphrase and off-site backup exist ([`POL-0005`](./POL-0005-Backup-and-Recovery.md)). Continuity is **proven, not assumed** ([`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md)): the full teardown-and-rebuild-from-docs drill is the ultimate BC test; tabletop the AtlasERP-down and OT-line scenarios; capture the MTTR ([`POL-0012`](./POL-0012-Risk-Management.md)). In the `301` org, name who continuity decisions escalate to and who is notified on a material disruption (Exec, Legal, the cyber-insurer).

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0013 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0011 — Game Days: Unannounced Failure Drills That Test the Docum…](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) | Proposed — captured 2026-07-13, deliberately NOT scheduled | POL-0005 (+POL-0013, +POL-0016) |
| [ADR-0036 — Atlas Compute Topology: A Second Proxmox Host + VM Placem…](../Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md) | Accepted as the target topology (operator, 2026-07-28). ✅… | POL-0008 (+POL-0013) |
| [ADR-0046 — Two-Node Failover Cluster + Storage Spaces Direct: HA Wor…](../Decisions/ADR-0046-Two-Node-Failover-Cluster-and-S2D.md) | Accepted in principle (operator, 2026-07-29). ✅ PVE02-gat… | POL-0013 (+POL-0005) |
<!-- END AUTOGEN:decisions POL-0013 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. To change a rule, an ADR carries `Governing Policy: POL-0013`, states *"amends `POL-0013` R#"*, and a Change Log row is added ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)); preserved, never deleted (legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — each critical function has a stated posture + a manual fallback where it has no HA.
- [ ] **R2** — each dependency trap has a mitigation or a recorded accepted risk (register, [`POL-0012`](./POL-0012-Risk-Management.md)).
- [ ] **R3** — no OT security control risks halting the line; segmentation is the compensating control.
- [ ] **R4** — the plan + contacts exist **offline**; the paper passphrase + off-site backup exist; a continuity/rebuild drill has run and its MTTR is captured ([`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md)).
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

Assuming continuity that doesn't exist (counting the iDRAC or a single firewall as resilient) · a critical function with no manual fallback and no HA · a plan that lives only online (on the systems it's meant to survive) · a BC doc that re-states RTO/RPO instead of linking the BIA.

## Related

[`POL-0005` Backup & Recovery](./POL-0005-Backup-and-Recovery.md) · [`POL-0012` Risk (BIA/RTO/RPO)](./POL-0012-Risk-Management.md) · [`ADR-0011` Game Days](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md) · `305` (OT availability) · `048` (rebuild) · the [Backup, Recovery & Continuity directory](../../Atlas-Academy/Directory/Backup-Recovery-and-Continuity.md).

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [A Backup Is Not a Backup Until a Restore Proves It](../../Atlas-Academy/Concepts/A-Backup-Is-Not-a-Backup-Until-a-Restore-Proves-It.md) (continuity vs recovery · the rebuild-from-docs Game Day · the circular-dependency trap) · [Out-of-Band Recovery](../../Atlas-Academy/Concepts/Out-of-Band-Recovery.md) (the console as the continuity control).
- 🔧 **Playbooks:** [Recover-the-Lab-from-a-Bare-Metal-Teardown](../../Atlas-Academy/Playbooks/Recover-the-Lab-from-a-Bare-Metal-Teardown.md) · [Recover-from-a-DNS-Outage](../../Atlas-Academy/Playbooks/Recover-from-a-DNS-Outage.md).
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (5.1 BC) · [AZ-800/801](../../Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md) (failover cluster / S2D).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First BC policy — continuity vs recovery, critical-function postures, the dependency traps, offline plan + tested drill; defers RTO/RPO/BIA to POL-0012 and backup mechanics to POL-0005. |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the rules distilled into citable `R1–R4`; boundaries with `POL-0005`/`POL-0012`; the amendment model; per-`R#` Verification; a **Learn it (Academy)** section (A-Backup-Is-Not-a-Backup + Out-of-Band concepts); status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
