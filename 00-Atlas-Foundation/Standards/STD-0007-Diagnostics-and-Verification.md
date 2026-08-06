---
Title: STD-0007 — Diagnostics & Verification Standard
Path: 00-Atlas-Foundation/Standards
Status: ✅ Adopted 2026-08-03 under `POL-0014` via `ADR-0032`. In force.
Version: 1.0
---

# STD-0007 — Diagnostics & Verification

> **At a glance.** Every device carries a `Diagnostics.md` (the show/verify quick-ref) and a `Troubleshooting.md` (symptom → fix), the reusable commands live once in the Academy Command-Library and are *linked up* to (never copied), and a verify command is authored *as you build* — marked 🟡 until a real read-back flips it ✅.

| Item | Value |
|---|---|
| Layer | **Standard** — the diagnostics/verification doc pattern; binds every device + the Command-Library |
| Governing policy | [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) (+ [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) evidence) |
| Requirement, in one line | Per-device `Diagnostics`/`Troubleshooting` · the Academy is the one command home · author-the-check-as-you-build |
| Owner | Engineering ([`ADR-0018`](../Decisions/ADR-0018-Atlas-Operating-Model-Silos.md) silos) |
| Adopting decision | [`ADR-0032`](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) → under [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) |
| Detailed spec | [`Templates/Diagnostics-Show-Commands-Template`](../Templates/Diagnostics-Show-Commands-Template.md) + [`Troubleshooting-Guide-Template`](../Templates/Troubleshooting-Guide-Template.md) |
| Applies to | every `Devices/<host>/` + the [Academy Command-Library](../../Atlas-Academy/Command-Library/) |
| Feeds / fed by | **feeds** the read-back rows every STD's Verification relies on · **fed by** the Command-Library + [`STD-0005`](./STD-0005-Device-Documentation.md) (the page-set that requires these files) |
| Verified by | [`POL-0001`](../Policies/POL-0001-Atlas-Audit-Policy.md) audit — the *Verification* checks below |
| Framework mapping | NIST 800-137 (ISCM) · the evidence rule `POL-0006` |

---

## Scope & applicability

Binds how a device's *verification* is documented and where reusable commands live. It is the doc-architecture behind "evidence over intent."

**Boundary with adjacent standards:** *the command library's shape* is [`STD-0006`](./STD-0006-Academy-Documentation.md); *what counts as evidence* is [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md); this standard is the *doc pattern* that makes the read-back live on the page.

## Why a standard, not left in a guide

Verification only works if the command and its expected result are written down *before* the device is trusted — and if a ✅ is never a guess. Atlas's scars are green-prompt lies (`016`); this standard makes "author the check, mark it 🟡 until proven" the shape of every device page.

---

## The requirements

Each is citable as `STD-0007 R#`.

### R1 — Every device has a `Diagnostics.md`

A **show/verify quick-reference** — install/role, identity + addressing, service-up, reciprocal inter-device link checks, DNS, log sources — each command with **when-to-run + the expected healthy result**, from [`Diagnostics-Show-Commands-Template`](../Templates/Diagnostics-Show-Commands-Template.md).

### R2 — Every device has a `Troubleshooting.md`

Symptom → scope → likely causes → the diagnostic command → **healthy-vs-broken** read-back → fix → re-verify, from [`Troubleshooting-Guide-Template`](../Templates/Troubleshooting-Guide-Template.md).

### R3 — The Academy Command-Library is the one canonical command home

Reusable verify commands live **once** in the [Command-Library](../../Atlas-Academy/Command-Library/) (by platform/service/failure-category); device `Diagnostics` pages **link up**, never copy (`POL-0008`).

### R4 — Author the check as you build; never assume output

As a session builds a VM / installs a role / sets IP·DNS·mgmt / stands up a service, it MUST author the verification command into `Diagnostics.md`, marked **🟡 lab-unverified** until a **real device read-back** flips it **✅** (`POL-0006`). Output is never assumed or invented.

### R5 — The handoff carries open confirmations

`SESSION-HANDOFF.md` keeps a standing **open-confirmations / solo-work-sync** view so a 🟡 waiting on a read-back is visible, not lost.

---

## Adopting & amending decisions

| Decision | Status | What it did |
|---|---|---|
| [`ADR-0032`](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) | Accepted | the Diagnostics/Troubleshooting pattern + the link-up-to-Academy + anti-assumption rule |

(Originals in the legacy snapshot.)

## Verification (how conformance is proven)

- [ ] **R1/R2** — every `Devices/<host>/` has both `Diagnostics.md` and `Troubleshooting.md` (`git ls-files` count == device count).
- [ ] **R3** — no device `Diagnostics.md` restates a Command-Library block verbatim (it links up).
- [ ] **R4** — no ✅ line in a `Diagnostics.md` lacks a pasted read-back (grep ✅ rows for adjacent evidence; a bare ✅ is a finding → downgrade 🟡).
- [ ] **Meta** — a new device inherits the templates.

## Learn it — the source of truth for the *how*

- 🖥️ **The commands:** the [Academy Command-Library](../../Atlas-Academy/Command-Library/) (the one canonical home)
- 🧩 **The templates:** [`Diagnostics-Show-Commands-Template`](../Templates/Diagnostics-Show-Commands-Template.md) · [`Troubleshooting-Guide-Template`](../Templates/Troubleshooting-Guide-Template.md)
- 🎓 **The why:** [`A Completed Command Is Not Evidence`](../../Atlas-Academy/Concepts/A-Completed-Command-Is-Not-Evidence.md)
- 📋 **Program:** [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) (evidence) · [`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md)

## What a violation looks like

A device with no `Diagnostics.md` · a ✅ with no read-back · a command block copied into a device page instead of linked to the Command-Library · an invented "expected" output · a 🟡 that's been waiting silently with no handoff note.

## Related

[`POL-0014`](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) / [`POL-0006`](../Policies/POL-0006-Evidence-and-Verification.md) (governing) · [`STD-0005`](./STD-0005-Device-Documentation.md) · [`STD-0006`](./STD-0006-Academy-Documentation.md) · [`ADR-0032`](../Decisions/ADR-0032-Diagnostics-and-Verification-Doc-Architecture.md) · the [Standards register](./README.md) · [the framework](../Governance/Atlas-Governance-Framework.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-08-03. **Materialized `ADR-0032` into a testable standard** (#39 (B)→STD): per-device `Diagnostics`/`Troubleshooting`, the Command-Library as the one command home (link-up-not-copy), and the author-the-check-as-you-build / 🟡-until-read-back anti-assumption rule — each with a structure/evidence read-back. Cut from `STD-Template`. |
