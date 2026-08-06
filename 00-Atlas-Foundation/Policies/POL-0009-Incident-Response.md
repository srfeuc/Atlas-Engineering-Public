---
Title: POL-0009 — Incident Response Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026` (framework). In force. Companion procedure: `Security-Program/Incident-Response-Playbook.md`.
Version: 2.0
---

# POL-0009 — Incident Response

> **At a glance.** Every suspected incident is handled through a defined lifecycle — prepare · detect · analyze · contain · eradicate · recover · learn — with the same evidence discipline Atlas applies to changes: a claim needs a command and its output, and the write-up closes with a **lesson that reaches the document that does the work**. This policy folds the estate's IR practice into citable requirements (`POL-0009 R1`…) and doubles as a directory of the decisions that govern IR (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the IR playbook, runbooks, and Changes beneath it |
| Requirement, in one line | A defined IR lifecycle; declare don't drift; change-management evidence discipline; contain before eradicate (preserve evidence); a lesson that reaches the doing-doc. |
| Owner | 🔴 Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)) |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) — elevating the IR Atlas already runs ad hoc ([`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md), `CM-0014`, `CM-0032`) |
| Builds on | [`POL-0006`](./POL-0006-Evidence-and-Verification.md) (evidence discipline) · [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) (exposure incidents) · [`POL-0005`](./POL-0005-Backup-and-Recovery.md) (the recover phase) · [`POL-0012`](./POL-0012-Risk-Management.md) (residual risk) |
| Companion procedure | [`Incident-Response-Playbook`](../Security-Program/Incident-Response-Playbook.md) (the phase-by-phase lifecycle) |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checklist below |
| Framework mapping | NIST CSF 2.0 **RS** / **DE** · CIS Controls v8 **17** · NIST SP **800-61** (phases) |

---

## Scope & applicability

Governs every suspected security incident in the estate — from a committed secret to a possibly-compromised CA to a failed detection control — and the write-up, containment, and prevention that follow.

**Boundary with [`POL-0012`](./POL-0012-Risk-Management.md):** POL-0012 owns the *risk register and accept-with-triggers* model; POL-0009 owns the *response lifecycle* when a risk becomes an incident. **Boundary with [`POL-0010`](./POL-0010-Acceptable-Use.md):** a user's reporting duty is POL-0010; the responder's process is POL-0009.

## Why this is a policy, not a note

Atlas **already runs incident response to a high standard** — it just calls the output an ADR or a CM record. [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) is a full incident analysis (a 15-hour key+passphrase convergence: threat model, blast radius, containment, scheduled remediation with reversal triggers); `CM-0014` is a real exposure handled with rotation + copy-destruction + a blast-radius note; `CM-0032` is a detection-control failure found and reconciled. **What's missing is the standing requirement that makes it repeatable, ownable, and complete** — so the next incident isn't handled from memory.

---

## The standing requirements

Each is citable as `POL-0009 R#`.

### R1 — A defined lifecycle; declare, don't drift

Every incident moves through the playbook phases (prepare → detect → analyze → contain → eradicate → recover → post-incident); **skipping a phase is a recorded decision, not a default.** A suspected incident is **declared** (even by the one operator wearing the Security hat) so it's handled as an incident, not quietly worked; touching identity/PKI/firewall during response crosses a boundary and is recorded ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md)).

### R2 — Evidence discipline carries over from change management

A finding needs a command and its output ([`POL-0006`](./POL-0006-Evidence-and-Verification.md)/`POL-0001` R-A1); the device outranks the record (Charter Rule 13); a negative result proves nothing unless you can make the positive succeed (`015`). An incident write-up that asserts without evidence is a story, not a report.

### R3 — Contain before eradicate; preserve evidence first

Do **not** wipe the thing you haven't captured — snapshot/export state before you change it (the reboot-loop root cause was found only because the scheduled task was *read off* the workstation, not guessed).

### R4 — Detection is in scope; "we cannot see" is an incident finding

An incident you cannot see is not handled. [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md)'s *"no evidence of compromise means we cannot see, not we looked,"* and `CM-0032`'s finding that `index.txt` was 2-of-6 blind, put **detection capability** (Book 5 monitoring, `index.txt` reconciliation, off-box logs on a synced clock) in scope of this policy, not just response.

### R5 — Every incident ends in a lesson that reaches the doing-doc, with a trigger

Prevention is the deliverable: the remedy for `ADR-0009` was not *"be more careful"* — it was a **destroy step added to `049` and [`POL-0002`](./POL-0002-Secrets-and-Credentials.md)** ([`POL-0003`](./POL-0003-Change-Control.md) R4 — fix the doc that does the work). Any accepted residual risk carries a **reversal/escalation trigger** ([`POL-0012`](./POL-0012-Risk-Management.md)); secret-bearing incidents also satisfy [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) (rotation + copy-destruction + blast-radius).

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0009 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0009 — Intermediate CA Not Treated as Compromised](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) | Proposed | POL-0009 (+POL-0002) |
| [ADR-0014 — MKT01 Layer-2 Management Posture: MAC-WinBox, MAC-Telnet,…](../Decisions/ADR-0014-MKT01-Layer2-Management-Posture.md) | ✅ ACCEPTED — operator, 2026-07-14. Option C: MAC-WinBox s… | POL-0007 (+POL-0009) |
| [ADR-0016 — MKT01 Recovery Posture: Serial Console Deferred, MAC-WinB…](../Decisions/ADR-0016-MKT01-Recovery-Posture-Console-Deferred.md) | ✅ Accepted — operator, 2026-07-14 | POL-0009 |
| [ADR-0038 — pfSense as a Transparent Inline IPS on the North-South Ed…](../Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md) | Accepted (operator, 2026-07-29). Reshaped by ADR-0047 (20… | POL-0007 (+POL-0009) |
| [ADR-0047 — FGT01 Runs FortiGuard UTM (Reverses ADR-0035; Reshapes AD…](../Decisions/ADR-0047-FGT01-FortiGuard-UTM.md) | Accepted in principle (operator, 2026-07-29) — the FortiG… | POL-0007 (+POL-0009) |
<!-- END AUTOGEN:decisions POL-0009 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. To change a rule, an ADR carries `Governing Policy: POL-0009`, states *"amends `POL-0009` R#"*, and a Change Log row is added ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)); worked incidents (`ADR-0009`/`CM-0014`/`CM-0032`) are the dated trail, preserved not deleted (legacy snapshot).

## Verification (how compliance is proven)

- [ ] **R1** — every declared incident has a write-up covering all phases (or a recorded reason a phase was skipped); boundary-crossing response steps are recorded.
- [ ] **R2** — each finding carries evidence (command + output).
- [ ] **R3** — containment preserved evidence before changing state (a snapshot/export exists).
- [ ] **R4** — detection gaps surfaced by the incident are logged as follow-ups (an unseeable event → a monitoring backlog item).
- [ ] **R5** — the post-incident section names a **document or control changed** to prevent recurrence, reaching the doing-doc; residual risks carry a trigger; secret-bearing incidents satisfy `POL-0002`.
- [ ] **Meta** — every change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

An incident worked quietly and never written up · a remediation that fixed the device but left the guide teaching the same failure · a wipe that destroyed the evidence before it was captured · a "resolved" with no lesson and no prevention · an accepted risk with no reversal trigger · a response that touched the CA/identity/firewall with no Change Record.

## Related

[`Incident-Response-Playbook`](../Security-Program/Incident-Response-Playbook.md) (the procedure) · [`POL-0002`](./POL-0002-Secrets-and-Credentials.md) · [`POL-0005`](./POL-0005-Backup-and-Recovery.md) · [`POL-0012`](./POL-0012-Risk-Management.md) · [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md) / `CM-0014` / `CM-0032` (worked incidents) · the [Security-Program & Compliance directory](../../Atlas-Academy/Directory/Security-Program-and-Compliance.md).

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [Risk as a Living Register](../../Atlas-Academy/Concepts/Risk-as-a-Living-Register.md) (accepted-risk-needs-a-trigger; "we cannot see" is a finding) · [Secrets & Credential Custody](../../Atlas-Academy/Concepts/Secrets-and-Credential-Custody.md) (the `CM-0014` exposure response) · [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md).
- 🔧 **Playbooks:** [Respond-to-a-Committed-Secret](../../Atlas-Academy/Playbooks/Respond-to-a-Committed-Secret.md) · [Rotate-a-Leaked-Key-Before-You-Back-It-Up](../../Atlas-Academy/Playbooks/Rotate-a-Leaked-Key-Before-You-Back-It-Up.md).
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (incident response) · CIS 17.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-20. First IR policy (defined lifecycle · declare-don't-drift · evidence discipline · preserve-before-eradicate · detection-in-scope · lesson-reaches-the-doing-doc). |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance + item table; the requirement-in-detail distilled into citable `R1–R5`; boundaries with `POL-0012`/`POL-0010`; the amendment model; per-`R#` Verification; a **Learn it (Academy)** section (Risk / Secrets / A-Completed-Command concepts + the IR playbooks); status flipped to ✅ Adopted. AUTOGEN directory unchanged. No normative change. |
