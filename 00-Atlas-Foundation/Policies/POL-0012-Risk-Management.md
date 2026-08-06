---
Title: POL-0012 — Risk Management Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force.
Version: 2.0
---

# POL-0012 — Risk Management

> **At a glance.** Atlas identifies risks, assesses them, records each in a **register** with an owner and a treatment decision, and reviews them on a cadence and on trigger — so **an accepted risk is a documented decision, never a forgotten one**. This policy folds the estate's risk discipline into citable requirements (`POL-0012 R1`…), carries the live register + BIA, and doubles as a directory of the decisions that govern risk (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs how Atlas identifies, assesses, treats, and reports risk |
| Requirement, in one line | Identify → assess → treat → review on a register; every High/Critical risk has an owner + a treatment + a reversal trigger; RTO/RPO tested, not asserted. |
| Owner | 🔴 Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)); each risk has its own **risk owner** (register below) |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) — consolidating the accept-with-triggers practice Atlas already runs ([`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md), [`ADR-0005`](../Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md)) |
| Builds on | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) (audits find risks) · [`POL-0009`](./POL-0009-Incident-Response.md) (incidents feed the register) · [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md) (classification sets impact) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 **GV.RM / ID.RA** · NIST SP 800-37/800-30 · CIS v8 · Security+ SY0-701 **5.2** |

---

## Scope & applicability

Governs how every risk to the estate is identified, assessed, treated, reported, and reviewed — from a device role change to a site-loss scenario.

**Boundary with [`POL-0013`](./POL-0013-Business-Continuity.md):** POL-0012 owns the **BIA** (ranks and times the impact) + the risk register; POL-0013 owns the **continuity plan** (the keep-running strategy). **Boundary with [`POL-0005`](./POL-0005-Backup-and-Recovery.md):** POL-0005 owns backup/restore mechanics; the RTO/RPO *targets* those recoveries must meet live here.

## Why this is a policy, not a note

Atlas already does risk management — it just spells it as an ADR. [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) is a textbook risk acceptance: a threat model, a blast-radius assessment, a chosen treatment, and — the part most people skip — **explicit reversal triggers** and a scheduled review. What was missing is the **register** that holds them together, so the whole picture is visible at once instead of scattered across decisions. > *"An accepted risk with no review trigger is not an accepted risk — it is a forgotten one."*

---

## The standing requirements

Each is citable as `POL-0012 R#`.

### R1 — Identify, assess, treat, review — as a process

Risks come from audits ([`POL-0001`](./POL-0001-Atlas-Audit-Policy.md)), incidents ([`POL-0009`](./POL-0009-Incident-Response.md)), the backlog, Game-Day findings, and reconciliation gaps. Each is **assessed** (qualitatively — likelihood × impact; quantitatively where money clarifies — EF/SLE/ARO/**ALE**), given a **treatment** (R3), and **reviewed** on cadence and on trigger.

### R2 — Accept is a decision with an owner and a reversal trigger

The five treatments — **mitigate · transfer · accept · avoid**, plus temporary **exceptions** and standing **exemptions** — are all legitimate; the one that fails is *accept without a trigger*. Every accepted risk names its **reversal/escalation triggers** and a review date. Accept ≠ ignore.

### R3 — The register: every High/Critical risk has an owner, a treatment, a KRI, and a trigger

The living register (below) holds each risk with likelihood, impact, an **owner**, a treatment, a residual rating, a **KRI** (a threshold that re-rates it when crossed), and a **review trigger**. A risk with no register is a set of good calls nobody can see together.

### R4 — Judge each risk against the appetite of what it threatens

Atlas has a **split appetite**: expansionary toward *self-inflicted, contained* risk (the lab exists to break things — [`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md)), conservative for the crown jewels and the **OT line** (availability is sacred — [`305`](../Company-Profile/305-Atlas-Industrial-Security-Requirements.md); a control that risks stopping production is itself a risk). Risk **tolerance** is the concrete threshold each entry is judged against.

### R5 — Report on the register; the BIA feeds it; "we cannot see" is the meta-risk

The register **is** the report, reviewed on cadence and after any incident/Game Day; KRIs are the early-warning signals. The BIA (below) sets RTO/RPO — **tested in Game Days, not asserted** ([`POL-0005`](./POL-0005-Backup-and-Recovery.md)/[`ADR-0011`](../Decisions/ADR-0011-Game-Day-Unannounced-Failure-Drills.md)) — and MTTR is captured from real recoveries. The honest top risk is **observability**: *"no evidence" means "we cannot see," not "we looked."*

---

## The risk register (worked, from real Atlas risks)

Columns: ID · Risk · Owner · L · I · Inherent · Treatment · Residual · KRI (threshold) · Review trigger. *(Full worked version incl. the R-01 SLE/ALE example is the reference detail this section owns.)*

| ID | Risk | Owner | Inherent | Treatment | KRI (threshold) | Trigger |
|---|---|---|---|---|---|---|
| R-01 | Both CA+vault backups in one room | Platform | 🔴 High | Mitigate — off-site copy | # off-site restore-tested copies (≥1) | any backup change |
| R-02 | Intermediate CA possibly compromised | Security | Med | **Accept + triggers** (`ADR-0009`) | a cert not in `index.txt` | any trigger fires |
| R-04 | OT box / PLCs unpatchable | Security | 🔴 High | Mitigate (segmentation — can't Avoid) | corporate→OT flows ≠ the one conduit (0) | OT scope change |
| R-07 | MKT01 no OOB console → lockout | Network | 🔴 High | Mitigate — FTDI cable, tested | console tested this quarter? | before default-deny |
| R-09 | FGT01 SPOF + broad egress (`ADR-0005`) | Network | Med | **Accept (exception)** — until redundancy | HA pair introduced? | redundancy added |
| R-11 | 🔴 No monitoring — "we cannot see" | Security | 🔴 High | Mitigate — Book 5 (Wazuh/LibreNMS) | off-box log coverage % | Book 5 milestone |

*(The full 11-row register + the R-01 quantitative worked example — ALE ≈ $160/yr vs a $55 control — is retained as this policy's reference content; treatments per [`ADR-0005`](../Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md)/[`ADR-0017`](../Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md).)*

## The BIA — critical functions & recovery targets

| Service | Criticality | RTO | RPO |
|---|---|---|---|
| **AtlasERP** | 🔴 Critical — the company stops | Short | Short |
| **OT / production line** | 🔴 Critical (availability) | Minimal | n/a |
| AD / DNS | High | Short | Low |
| CA / PKI | High but downtime-tolerant | Generous | Event-driven |

**RTO/RPO** are *targets you set*; **MTTR/MTBF** are *measurements you take* — where MTTR > RTO, you have a gap. Full BIA + the four metrics defined against real Atlas signals: this section + the CA/PKI RPO-RTO doc.

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0012 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0005 — FGT01 Firewall Policy Scope: Keep Broad Pending Network R…](../Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md) | Accepted | POL-0012 |
| [ADR-0017 — Defer `CM-0012` (PVE01 CMOS Battery) and Freeze Book 1](../Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md) | ✅ Accepted — 2026-07-14 | POL-0012 |
| [ADR-0035 — FGT01 Runs Without UTM (No FortiGuard Subscription)](../Decisions/ADR-0035-FGT01-No-UTM.md) | 🔴 Superseded / Reversed by ADR-0047 (2026-07-29). Was: Ac… | POL-0012 |
<!-- END AUTOGEN:decisions POL-0012 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. To change a rule, an ADR carries `Governing Policy: POL-0012`, states *"amends `POL-0012` R#"*, and a Change Log row is added ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)). Accepted-risk ADRs ([`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md), [`ADR-0005`](../Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md), [`ADR-0017`](../Decisions/ADR-0017-Defer-CM-0012-CMOS-Battery.md)) are the register's dated trail; preserved, never deleted (legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — risks are assessed (qual + quant where it clarifies) and traced to a source.
- [ ] **R2/R3** — every High/Critical risk has an owner, a treatment, and a **reversal trigger**; accept ≠ ignore.
- [ ] **R4** — each entry is judged against the appetite of what it threatens (lab-expansionary vs crown-jewel-conservative).
- [ ] **R5** — the register is reviewed on cadence + after every incident/Game Day; KRIs tracked; RTO/RPO **tested** (Game Days), MTTR captured; the observability gap is on the register.
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

A risk accepted verbally with no trigger (the exact failure `ADR-0009` warns against) · a High risk with no owner · an RTO/RPO number never tested · a register that's a one-time document · treating the lab's expansionary appetite as if it applied to Restricted data or the OT line.

## Related

[`POL-0013` Business Continuity](./POL-0013-Business-Continuity.md) · [`POL-0005` Backup & Recovery](./POL-0005-Backup-and-Recovery.md) · [`POL-0009` Incident Response](./POL-0009-Incident-Response.md) · [`POL-0011`](./POL-0011-Data-Governance-Classification-Privacy.md) · [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) / [`ADR-0005`](../Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md) (accept-with-triggers) · the [Security-Program & Compliance directory](../../Atlas-Academy/Directory/Security-Program-and-Compliance.md) · [`Third-Party-Risk-Management`](../Security-Program/Third-Party-Risk-Management.md) (transfer).

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [Risk as a Living Register](../../Atlas-Academy/Concepts/Risk-as-a-Living-Register.md) (accepted-risk-needs-a-trigger · "we cannot see" is the top risk · a gap isn't closed until the fix is running · a control never needed looks identical to one not needed — grounded in `ADR-0009`/`ADR-0013`).
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (5.2 — SLE/ALE/ARO, treatments, BIA/RTO/RPO/MTTR/MTBF).
- 📋 **Security program:** [Compliance Program](../Security-Program/Atlas-Compliance-Program.md) · [Incident-Response-Playbook](../Security-Program/Incident-Response-Playbook.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First risk-management policy — the process, split appetite, five treatments, the 11-risk register + worked R-01 quant example, the BIA (RTO/RPO/MTTR/MTBF). |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the process distilled into citable `R1–R5`; boundaries with `POL-0013`/`POL-0005`; the register + BIA kept as this policy's reference content (compacted); the amendment model; per-`R#` Verification; a **Learn it (Academy)** section pointing at the now-built [`Risk as a Living Register`](../../Atlas-Academy/Concepts/Risk-as-a-Living-Register.md) concept; status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
