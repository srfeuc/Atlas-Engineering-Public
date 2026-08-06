# ADR-0032 — Diagnostics & Verification Documentation Architecture

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-28). |
| Governing Policy | POL-0014 (+POL-0006) |
| Materialized as | [STD-0007 — Diagnostics & Verification](../Standards/STD-0007-Diagnostics-and-Verification.md) · this ADR is the adopting decision; the standing requirements now live in that standard (`ADR-0054` (B)→standard) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-28 |
| Supersedes | — (new architecture). Re-scopes `Operations/Device-Confirmation-Commands.md` from a one-time audit handout to a standing source (see Decision §4). |
| Related | `POL-0001` (verify by device status — a `[x]` needs command + output), `POL-0008` (one home per fact), `ADR-0009` (evidence-over-assumption lineage), **D6** (adopt Atlas Academy), the existing `Templates/Troubleshooting-Guide-Template.md` + per-device `Troubleshooting.md` pages, `Build-Progress-Tracker.md` (Connectivity matrix + Verify-on-resume), `SESSION-HANDOFF.md`. |
| Evidence Status | **Decision** (operator, 2026-07-28). This governs *how* verification is documented; the commands authored under it are **`Target` / 🟡 lab-unverified** until a device read-back confirms each (`POL-0001`). |

## Context

Two recurring failures motivate this:

1. **Decisions and state get lost between sessions.** Work is often done at the lab **solo, without Claude alongside step-by-step**; the next session then can't tell what was actually built, and docs drift from reality. The single handoff doc helps but doesn't scale to "what changed on every device and how do I confirm it."
2. **We are frequently away from the lab** (planning/reconciling only) and must **not assume device state**. `POL-0001` already says a `[x]` requires a command and its output — but the *commands themselves* (the `show`/PowerShell/CLI checks that ground a claim) had no consistent home.

What already exists but is partial or mis-scoped: per-device **`Troubleshooting.md`** pages (symptom → fix, good) and a **`Troubleshooting-Guide-Template`**; a **`Device-Confirmation-Commands.md`** that is exactly the right *pattern* (command + when-to-run + expected + what-it-grounds) but was written as a **one-time 07-24 audit handout** (and has already gone stale); the tracker's **Connectivity verification matrix** and **Verify-on-resume** sections; and an **Atlas Academy** with **no command library yet**. The operator wants a durable structure so the roadmap and checklists stop churning.

## Decision

**Adopt a four-part diagnostics/verification documentation architecture, one home per need (`POL-0008`).**

1. **Per-device `Diagnostics.md` (NEW) — "is it built and connected correctly?"** A device-local quick-reference of **show/verify commands**: installation/role verification, identity + addressing (hostname/IP/DNS/gateway/domain-join), service-up checks, **inter-device link checks** (reciprocal — test both ends when a link is in doubt), DNS tests, IP/L1–L3 troubleshooting entry points, and where the device's **logs/event sources** live. Each command carries **when to run it** and the **expected healthy result**. It is a quick-ref, not the exhaustive list — it **links into Atlas Academy** for the deep set. Built from the `Templates/Diagnostics-Show-Commands-Template.md`.
2. **Per-device `Troubleshooting.md` (EXISTING) — "it broke, diagnose by symptom."** Keep and expand with the failure **categories** (service down, no network connectivity, login failure, cyber-attack indicators, SSH setup issues, …). Symptom → scope → causes → diagnostic → healthy-vs-broken → fix → verify (the existing template).
3. **Atlas Academy = the canonical master command library.** The large cross-device list lives **once**, here — organized on **both axes, cross-linked**: by **service** (SNMP, TFTP, DNS, NTP, SSH, LDAP/LDAPS, RADIUS, …) and **platform** (PowerShell/Tier-0, Cisco IOS, RouterOS, FortiOS, Linux), **and** by **failure-category** (service-down, no-connectivity, login-failure, cyber-attack, …). Device `Diagnostics.md`/`Troubleshooting.md` pages **link into** Academy rather than copying it. Academy also holds the "why it works" concept layer (**D6**).
4. **Continuous-handoff / solo-work verification protocol.** `SESSION-HANDOFF.md` gains a standing **"Solo-work sync / open confirmations"** section: when lab work happened without a session, it records **what changed** (VM built, role/feature installed, IP/DNS/mgmt-interface set) and **points to** the exact read-back — the tracker's **Verify-on-resume** + **Connectivity matrix**, and **`Device-Confirmation-Commands.md`**, which is **promoted from a one-time audit handout to the standing per-device verification source** the handoff references. Handoff says *what changed*; Device-Confirmation-Commands + the device `Diagnostics.md` say *how to confirm it*.

**Operating rule (the anti-assumption guardrail).** Every session, as it **builds a VM, installs a role or feature, sets an IP / DNS / management interface, or stands up a service**, **authors the verification command(s)** into that device's `Diagnostics.md` — command + when-to-run + expected result — and marks the result **🟡 lab-unverified** until a device read-back confirms it (then it flips to ✅, `POL-0001`). **Commands are authored from knowledge and official documentation; their outputs are never assumed or invented.** Where a needed check has no existing command (e.g. a PowerShell one-liner to verify a thing), **we build one** and file it the same way, flagged unverified until run. The **🟡 = operator-reported / lab-unverified** marker (introduced in the 2026-07-28 DC02 reconciliation) is the estate-wide convention for "claimed but not yet device-proven."

## Alternatives Considered

- **One page per device** (fold show/verify into `Troubleshooting.md`). Rejected — mixes "confirm it's right" (steady-state verification) with "it broke" (break-fix); the operator wants a dedicated show-command page. (Two pages chosen.)
- **Commands only in Academy, no per-device quick-ref.** Rejected — a builder standing at a device needs the 5–10 checks *for that device* immediately, not a scroll through the master list. Academy is the deep reference; the device page is the fast path (with links up).
- **Keep relying on the handoff prose + session memory.** Rejected — that is the exact failure this ADR exists to fix. State must be reconstructable from evidence, not memory.
- **A brand-new standalone "session sync" doc instead of reusing the handoff/tracker.** Considered; the operator chose to **extend the handoff + promote Device-Confirmation-Commands** rather than add a competing doc (avoids a fourth "where do we stand" owner — the `POL-0008` risk the register's B5 already flags).

## Consequences

- **Create** `00-Atlas-Foundation/Templates/Diagnostics-Show-Commands-Template.md`; each device gets a `Diagnostics.md` from it — **seeded incrementally** as we touch each device during the Master-Build-Order reconciliation and subsequent builds (not a big-bang authoring pass). `log()` what's still empty so coverage gaps aren't mistaken for "all verified."
- **Re-scope** `Operations/Device-Confirmation-Commands.md` to a **standing** doc (drop the "07-24 audit handout" framing; keep the command + when + expected + grounds pattern; refresh its stale DHCP/DC02/PKI expectations to the current ADRs). It becomes the cross-device confirmation index the handoff points at.
- **Extend** `SESSION-HANDOFF.md` with the standing **Solo-work sync / open confirmations** section, and keep the tracker's **Verify-on-resume** + **Connectivity matrix** as the live checklist it references.
- **Atlas Academy** grows a command library (both axes, cross-linked) — populated opportunistically as commands accumulate; **D6** status bump rides with it.
- **Marker convention:** ✅ device-verified · 🟡 operator-reported / lab-unverified · ⏳ in build · 📋 planned — used consistently across Diagnostics pages, the IP plan register, and build checklists.
- **Scope discipline:** this is documentation architecture; it does not itself verify anything. No `Diagnostics.md` entry is ✅ until a read-back is pasted.

## Review Trigger

- If the per-device `Diagnostics.md` and `Troubleshooting.md` start duplicating each other in practice, revisit the two-page split.
- If the Academy library and device quick-refs drift (the same command maintained in two places with different content), tighten the "device links, Academy owns" rule or generate the quick-refs from Academy.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Accepted. Establishes the diagnostics/verification documentation architecture: **per-device `Diagnostics.md`** (show/verify quick-ref) alongside the existing **`Troubleshooting.md`** (symptom→fix); **Atlas Academy** as the canonical master command library organized by service/platform **and** failure-category (cross-linked); a **continuous-handoff / solo-work verification protocol** (handoff standing "solo-work sync" section + `Device-Confirmation-Commands.md` promoted to the standing per-device verification source). Codifies the **anti-assumption operating rule** — sessions author verification commands as they build (VM/role/feature/IP/DNS/mgmt-interface), mark them **🟡 lab-unverified** until a read-back confirms (`POL-0001`), and never assume or invent output; build a PowerShell/CLI check where none exists. Adopts the estate-wide ✅/🟡/⏳/📋 marker convention. Implementation is incremental (seed pages during the Master-Build-Order reconciliation and subsequent builds). |
