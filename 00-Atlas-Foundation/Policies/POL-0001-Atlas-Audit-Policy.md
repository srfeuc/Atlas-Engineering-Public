---
Title: POL-0001 — Atlas Audit Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-07-17 under `ADR-0026` (framework) via `ADR-0019` (the Book-1 audit mandate). In force.
Version: 2.0
---

# POL-0001 — Atlas Audit

> **At a glance.** A claim is not true because it's written down — it's true when a command's output proves it. Atlas audits itself on a defined cadence; every finding names the exact command it was checked with and ends in a disposition; *"we cannot see"* is a finding, not a pass. This policy is the standing control against the estate's central defect — *the document disagrees with the device* — and it doubles as a directory of the decisions that govern auditing (below).

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement; governs the Standards, ADRs, Changes, and Procedures beneath it |
| Requirement, in one line | Atlas audits itself on a cadence; a claim requires a command + its output; every finding gets a verdict and a disposition; a stale `Verified` is not verified. |
| Owner | 🔴 Security silo ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0019`](../Decisions/ADR-0019-Book-1-Audit-Mandate.md) (the Book-1 audit mandate — the precedent this generalises) → adopted under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (2026-07-17) |
| Builds on | [`POL-0006`](./POL-0006-Evidence-and-Verification.md) (the read-back rule this enforces on a schedule) · [`POL-0004`](./POL-0004-Source-of-Truth.md) (device outranks document) · [`POL-0003`](./POL-0003-Change-Control.md) (a fix is a change) |
| Verified by | **itself** — the audit is the estate's verification control; its *own* compliance is the mandatory **freeze audit** + the automated **stale-`Verified` sweep** (below) |
| Framework mapping | NIST CSF 2.0 **GV.OC** (the `GOVERN` layer) + **DE.CM** (detect) · CIS Controls v8 **8** (Audit Log Management) / **17** (Incident Response) · Security+ 5.x (governance & audit) |

---

## Scope & applicability

**Every device, service, and document in Atlas** — no exceptions, no *"it's just a lab."* The audit checks whether what a document asserts is *actually true right now* against the running estate, and it applies to every session (human or AI) that closes a change, freezes a lab, or reconciles a doc to a device.

**Boundary with [`POL-0006`](./POL-0006-Evidence-and-Verification.md):** POL-0006 sets the rule that *a build/change ends with a read-back* (evidence at the moment of work); POL-0001 is the *standing, scheduled* control that re-checks those claims over time and gates a freeze. POL-0006 is "prove it when you do it"; POL-0001 is "prove it's still true, on a cadence, by someone other than the author." They meet at the read-back.

## Why this is a policy, not a note

Atlas's single most recurring defect is *"the document disagrees with the device,"* and its cause is that **a rule that lives only in a document, with nothing forcing it, is not a rule.** Two correct, written, published rules were violated repeatedly because nothing audited them — the unused-interface rule (`CM-0015` MKT01 `ether2`; `CM-0033` five live undocumented ports on the *perimeter firewall*) and the no-secrets rule (`CM-0014` the committed passphrase). Worse, the checklists that *should* have caught this produced **five false ticks across three checklists** — each ticked in good faith from a config line, a memory, or another document, never from the runtime. *A checklist without a named evidence source is a survey, not an audit.* Raising audit to a policy makes "is this actually true?" a scheduled, evidenced, falsifiable activity with an owner — not a hope.

---

## The standing requirements

Each is citable as `POL-0001 R#`. The decision(s) each absorbs are linked inline; the full trace is in *[Decisions governed by this policy](#decisions-governed-by-this-policy)*.

### R1 — A tick requires a command and its output, never a config line

A finding is trusted only when it states its **evidence source** — the exact command and what it returned — not the config line that *should* produce the result ([`ADR-0019`](../Decisions/ADR-0019-Book-1-Audit-Mandate.md)). > *"`show run` shows INTENT. `show ntp status` shows TRUTH."* `ntp server 10.10.0.5` sat in a config for a switch's whole life, pointed at a host that runs no NTP; the intent read clean, the runtime said `stratum 16`. **If you cannot paste the output, you cannot tick the box.** Each audit finding carries all four fields: **CLAIM · EVIDENCE SOURCE · VERDICT · DISPOSITION.** (This is [`POL-0006`](./POL-0006-Evidence-and-Verification.md) made a standing control; the *why* is the Academy concept [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md).)

### R2 — Verify the artefact the rebuild uses, not only the one in production

The **wire and the file are two different objects — check both** ([`ADR-0019`](../Decisions/ADR-0019-Book-1-Audit-Mandate.md)). Four documents truthfully recorded a cert's SAN *"verified on the live-served connection,"* and were all right — while the **file the rebuild reads** carried a pre-VLAN address the whole time (`CM-0032`). An audit that checks only production passes a rebuild that will fail.

### R3 — An audit is run by someone other than the author, and covers before it threads

An audit may **not** be performed by the author of what it audits ([`ADR-0019`](../Decisions/ADR-0019-Book-1-Audit-Mandate.md)) — > *"re-reading your own reasoning and finding it persuasive is not an audit."* In a one-person lab this is satisfied by the audit being **executable by someone else**: a different session instructed to audit from evidence, running a device's Verification-Procedure command battery (which doesn't depend on the author's memory). And **coverage comes before threads** — > *"the defects clustered where we looked, not where they are"* — finish the table, then rank.

### R4 — Atlas audits on a defined cadence

A policy without a cadence is a wish; these triggers are owned by the Security silo ([`Atlas-Governance-Framework` §7](../Governance/Atlas-Governance-Framework.md)):

- **R4a — Freeze audit (mandatory, gates the freeze):** no lab freezes without a full-coverage audit by a non-author (`ADR-0019` found 8 rebuild-fatal defects). 🔴 The load-bearing check.
- **R4b — Change-Record closeout:** the reconciliation of every doc a change touched is answered in writing before the record closes (Charter Rule 15; [`POL-0003`](./POL-0003-Change-Control.md)).
- **R4c — Reconcile-to-live:** each device/doc walked against the live device (Charter Rule 13), monthly or before a Game Day.
- **R4d — Stale-`Verified` sweep (mechanical):** a scheduled script over the `Last Verified:` field demotes anything > 90 days to `Historical` — *"'Verified' is a claim about a date, not a property of the page"* (Charter Rule 14). The one check that **must** be automated (a CI candidate alongside `gitleaks`/link-check).
- **R4e — Event-driven:** any restore · firmware update · new device · role change · Oxidized-reported drift triggers an audit of what changed.

### R5 — Every finding ends in a disposition; `UNVERIFIABLE` is mandatory

No finding is left open: the verdict maps to an action — `FALSE`→fix the doc that does the work first (or a Change Record if the *device* is wrong, read back before executing); a **control that fails**→test it against the incident that actually happened (the scanner that passed a canary and waved the real secret through 30 seconds later); **`UNVERIFIABLE`→record it as such** (*"we cannot see" is a finding, not a pass* — [`ADR-0009`](../Decisions/ADR-0009-Intermediate-CA-Not-Treated-as-Compromised.md)); a finding nobody will fix→**defer it by an accepted ADR with a trigger.** > *"A deferral you wrote down is engineering. A tick you did not earn is a lie."*

---

## Decisions governed by this policy

> Which decisions serve this policy — **generated** from the ADRs' `Governing Policy:` lines (`tools/Build-Policy-Directories.ps1`). Do not hand-edit.

<!-- BEGIN AUTOGEN:decisions POL-0001 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0019 — The Book 1 Audit Mandate: Coverage, Not Threads](../Decisions/ADR-0019-Book-1-Audit-Mandate.md) | Accepted — 2026-07-14 | POL-0001 |
| [ADR-0054 — Governance Reconciliation: Promote Policy-/Standard-Shape…](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md) | Proposed (operator accepts by moving to Accepted). Drafte… | **`Atlas-Governance-Framework` §4/§5** (the reconcile mandate this executes) · **`POL-0001` (Audit)** — a governance reconcile pass *is* an audit (device/record/doc precedence applied to the doc-type hierarchy). |
<!-- END AUTOGEN:decisions POL-0001 -->

## The amendment model — how these decisions relate to this policy

This policy holds the **current** rule; the decisions behind it are the **dated trail**. No standing rule changes by editing this policy silently.

- **To change a rule, an ADR amends it** — it carries `Governing Policy: POL-0001`, states *"amends `POL-0001` R#"*, and this policy's Change Log gains a row citing that ADR + date ([`ADR-0054`](../Decisions/ADR-0054-Governance-Reconciliation-Promote-Policy-Shaped-ADRs.md)).
- **(C) promotions** — the audit-discipline rule of [`ADR-0019`](../Decisions/ADR-0019-Book-1-Audit-Mandate.md) is promoted here; the ADR is kept as the adopting decision, its original text frozen in the legacy snapshot.

## Verification (how compliance is proven)

The audit is self-referential — it is the control that proves everything, including itself.

- [ ] **R1** — spot-checked findings each paste a command + its output; no tick rests on a config line or a memory.
- [ ] **R2** — a sampled claim is confirmed on **both** the wire and the rebuild file; they agree.
- [ ] **R3** — the freeze audit was run by a non-author; the coverage table was completed before any finding was chased.
- [ ] **R4** — the freeze audit gated the last freeze; the **stale-`Verified` sweep** runs on schedule (script, not human); reconcile-to-live has a dated last run.
- [ ] **R5** — every finding has a verdict and a disposition; every `UNVERIFIABLE` is recorded; every accepted risk carries a trigger.
- [ ] **Meta** — any change to a rule here traces to an amending ADR + a Change Log row.

## What a violation looks like

A checklist tick with no named command · a claim verified on the wire but not in the rebuild file · an audit performed by the author of the thing audited · a "done"/frozen lab with no freeze audit · a `Last Verified:` older than 90 days still presented as current · a failed control never tested against the real incident · a risk accepted verbally with no trigger.

## Related

[`Atlas-Governance-Framework`](../Governance/Atlas-Governance-Framework.md) §7 (the audit process) · [`ADR-0019`](../Decisions/ADR-0019-Book-1-Audit-Mandate.md) (the precedent — 76 docs, 8 rebuild-fatal defects) · [`POL-0006`](./POL-0006-Evidence-and-Verification.md) · [`POL-0004`](./POL-0004-Source-of-Truth.md) · [`Atlas-Charter`](../Governance/Atlas-Charter.md) Rules 13/14/15 · the [Governance & Decisions directory](../../Atlas-Academy/Directory/Governance-and-Decisions.md) · the legacy snapshot.

## Learn it — the Academy (the why + the read-backs)

- 🎓 **Concept (why it works):** [A Completed Command Is Not Evidence](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md) (a green prompt is a claim; the runtime read-back is the evidence — the discipline this whole policy schedules) · [Risk as a Living Register](../../Atlas-Academy/Concepts/Risk-as-a-Living-Register.md) (a finding nobody will fix → an accepted risk *with a trigger*).
- 🖥️ **Commands (run the read-backs):** the per-platform [Command-Library](../../Atlas-Academy/Command-Library/) (`show ntp status`, `get`, `openssl x509`…) + each device's `Diagnostics.md` battery.
- 🏅 **Cert objective:** [Security+ Domain-5](../../Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md) (governance, risk, compliance & audit) · cert-adjacent to CompTIA Project+ / ITIL.
- 📋 **Security program:** [Compliance Program](../Security-Program/Atlas-Compliance-Program.md) (the NIST/CIS control mapping this audit satisfies).

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-07-14. Draft by the Book-1 audit (`ADR-0019`) — the four-artefact model + the buried-policy findings + R-A1. |
| 1.0 | 2026-07-17. Adopted by `ADR-0026`; filled the cadence, failure-handling, NIST/CIS mapping, and retention sections from the Governance Framework §3. |
| 2.0 | 2026-08-04. **Reshaped to the golden `POL-0014` shape** (#42): at-a-glance opener + item table; distilled the argued prose into five citable requirements (`R1` tick-needs-output · `R2` wire-and-file · `R3` non-author + coverage · `R4` the cadence · `R5` disposition/`UNVERIFIABLE`); added the boundary with `POL-0006`, the amendment model, the per-`R#` Verification, and a **Learn it (Academy)** section pointing at the now-built `A-Completed-Command-Is-Not-Evidence` + `Risk-as-a-Living-Register` concepts. The generated AUTOGEN directory is unchanged. No normative change — the rules are the v1.0 rules, made citable. |
