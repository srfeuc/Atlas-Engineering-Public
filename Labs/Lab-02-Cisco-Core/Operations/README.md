---
Title: Lab-02 Operations — run-sheets & working docs
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 Living — the lab's operational + working-doc folder.
---

# Lab-02 — Operations

> 🧭 **What this folder is.** Two kinds of doc live here: reusable **operational run-sheets** the build actually uses, and the lab's **internal working docs** (per-session plans, reconciliation audits, build-queue worksheets). If you're reading Atlas as a portfolio, the polished narrative is the [root `README.md`](../../../README.md) and [`PORTFOLIO.md`](../../../PORTFOLIO.md); this folder is the engine room behind them. The live "where we are now" is the [`SESSION-HANDOFF.md`](../SESSION-HANDOFF.md) one level up, and the **active next-session brief** is `Session-35-Hardware-Evidence-Packet-Tracer-and-Go-Public-Prompt.md`.

## Operational run-sheets (reusable)

| Doc | What it's for |
|---|---|
| [`Build-Order-and-Dependencies.md`](Build-Order-and-Dependencies.md) | The authoritative estate build order + cross-device dependencies (Needs / Unblocks). |
| [`SoT-Evidence-Run-Sheet.md`](SoT-Evidence-Run-Sheet.md) | The source-of-truth evidence-capture commands (feeds NetBox). |
| [`Hardware-Evidence-Run-Sheet-CCNA-Overlay.md`](Hardware-Evidence-Run-Sheet-CCNA-Overlay.md) | The 1941 CCNA-overlay evidence sheet: stage → `SS-##` → the reverse-index objective it flips 🟡→✅. |
| [`Packet-Tracer-Twin-Build-Spec.md`](Packet-Tracer-Twin-Build-Spec.md) | The expanded-twin spec: the multi-device objectives (DR/BDR, HSRP, STP, EtherChannel, DHCP relay) → 🖥️ + drill Playbooks. |
| `Go-Public-Pre-Flight-Checklist.md` | The pre-publish go/no-go gate: secrets (history), copyright, PII, topology exposure, licensing. |
| [`Device-Confirmation-Commands.md`](Device-Confirmation-Commands.md) | The standard per-device verification command set (`POL-0001`). |
| [`Device-Backup-Runbook.md`](Device-Backup-Runbook.md) | The per-device backup procedure. |
| [`Device-Hardening-Standard.md`](Device-Hardening-Standard.md) | The estate hardening-baseline procedure. |
| [`Validation-and-Adversarial-Testing.md`](Validation-and-Adversarial-Testing.md) | The validation / adversarial-test approach. |

## Internal working docs (process record — not build guidance)

These are kept on purpose — Atlas preserves its working process rather than deleting it (`ADR-0012`) — but they are **not** part of the published guide. A first-time reader can skip them.

| Doc(s) | What it is |
|---|---|
| `Session-21` … `Session-35` `*-Prompt.md` | The per-session planning briefs — how each work session was scoped and prioritised. A record of *how the work was run*, not device guidance. The newest, `Session-35`, is the **active** brief; earlier ones carry `ADR-0012` retired banners (sessions 30–34 ran off the Backlog-#44 brief and have no prompt page). |
| [`Playbook-Format-Alignment-Audit.md`](Playbook-Format-Alignment-Audit.md) · [`Lab-01-Playbook-Mining-Candidates.md`](Lab-01-Playbook-Mining-Candidates.md) | The Academy Playbook build queues. |
| [`Doc-Conflict-Audit-2026-07-24.md`](Doc-Conflict-Audit-2026-07-24.md) · [`Foundation-Doc-Conflict-Audit-2026-07-24.md`](Foundation-Doc-Conflict-Audit-2026-07-24.md) | Point-in-time documentation-reconciliation audits. |
| [`Device-Page-Set-Replication-Prompt.md`](Device-Page-Set-Replication-Prompt.md) · [`Compute-Placement-Reconciliation.md`](Compute-Placement-Reconciliation.md) | Working reconciliation docs. |
