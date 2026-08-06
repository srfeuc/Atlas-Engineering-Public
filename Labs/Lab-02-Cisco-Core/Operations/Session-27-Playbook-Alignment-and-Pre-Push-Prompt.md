---
Title: Session-27 — Academy Playbooks: finish the alignment + queue, and PUBLISH-PREP (pre-public-push polish). Prioritized · hand-off-ready.
Path: Labs/Lab-02-Cisco-Core/Operations
Status: ✅ SUPERSEDED 2026-08-03 (`ADR-0012`: quarantine, don't delete) — the live brief is `Session-29-Academy-Directory-Pages-Prompt.md`. Publish-prep (#38) is done; the remaining Playbook-queue work is carried in the backlog (#36/#37). Kept for history.
Version: 1.0
Date: 2026-08-01
---

> ✅ **SUPERSEDED 2026-08-03 — retired, not deleted (`ADR-0012`).** After this brief, the governance reconciliation (**#39**) and the Source-of-Truth router took priority; the active brief is now **[`Session-29-Academy-Directory-Pages-Prompt.md`](Session-29-Academy-Directory-Pages-Prompt.md)** (build the per-domain Academy Directory pages — the router's exhaustive twins). This brief's **publish-prep (#38) is ✅ done**; its **remaining Playbook-queue work is carried in the backlog** (`#36`/`#37` · `Operations/Lab-01-Playbook-Mining-Candidates.md`). Kept for history — **don't build from this page.**

# Session-27 — Playbook Alignment, the Queue, and Pre-Push Prep

## What this is

The continuation brief now that the **mold is LOCKED**. The golden template, the mentality Concept, §4 row 7, the #34 observability seeds, and the format-alignment audit were all built in the session-24 arc (see **Already done**). This brief carries the **remaining** Playbook work, prioritized, plus the operator's new goal: **get the repo ready to push to the public/LinkedIn repo** (Backlog **#38** — cosmetic + navigation polish; `ADR-0010` is the security gate).

## 0. Read the setup (before anything)

1. `Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md` — the `📍 CURRENT STATE` block + the latest session block.
2. `00-Atlas-Foundation/Decisions/ADR-0053` **§5** — the LOCKED Playbook mold. Canonical reference = **`Atlas-Academy/Playbooks/Read-the-Cert-Not-the-Sign-Log.md`** (copy its shape).
3. The **two work-queues:** `Operations/Playbook-Format-Alignment-Audit.md` (the alignment register + the docs-only/device-needed flags) · `Operations/Lab-01-Playbook-Mining-Candidates.md` (the #36 build queue).
4. `Atlas-Academy/Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md` — reconcile every Lab-01 anchor (`ADR-0022`).
5. `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md` — **#36 / #37 / #34 / #38**.

## 🔴 RECOMMENDED ORDER

1. **Finish the format-alignment register — the docs-only leaves first (fast, fully-complete).** Register **rows 2–6**: `Enumerate-Every-Enabled-Interface` (CM-0033) · `Respond-to-a-Committed-Secret` (CM-0014) · `Remove-a-MikroTik-Firewall-Rule` (CM-0009 — **On-this-page only**) · `Prove-Exactly-Which-MikroTik-Rule-Acted` (+ a Worked-example from the frozen isolation-test) · `MikroTik-EastWest-Inspect` (+ Worked-example from the frozen verification-test **and resolve the dangling `CM-0023` ref** at ~line 124). Bring each fully to the mold and quote the frozen read-backs. One page per pass; **tick the register Status column.**
2. **The device-needed leaves — align the FORMAT now, `✅` later.** Register rows **8–14** + the heavies **16–17**: add On-this-page, the `#32` four-part Symptoms (one-error-per-bullet), command-first blocks, and cross-links; mark **🔧 device-needed**. The 🟡→✅ waits on a real run — §3 of the register groups them by gating kit (runnable-now on PVE01/any-host · gated-on-a-Lab-02-service · Game-Day drills). `Recover-the-Lab-from-a-Bare-Metal-Teardown` also owes the **one-error-per-bullet split**.
3. **§4 mining-queue rows 8–10** (golden mold): `Reconcile-a-Build-Guide-That-Rebuilds-a-Broken-Device` (CM-0022) · `Verify-an-Edit-by-Counting-the-Old-Text` (CM-0021/CM-0026) · `Trace-Three-Symptoms-to-a-Dead-CMOS-Battery` (CM-0012). Then the rest of the §5 candidate library.
4. **The §3 themes → more `Concepts/`** (the mentality layer, 4-part module): theme 2 *the wire ≠ the file / running-service ≠ config-line* · theme 3 *silent drops* · theme 4 *recovery paths are invisible — hardening deletes them* · theme 5 *verify the negative / count the old text*. Theme 1 (`A-Completed-Command-Is-Not-Evidence`) is built.
5. **The Command-Library `show`-harvest** — expand `Command-Library/Linux.md` by **service role** (operator's call: one `Linux.md` now, split to a `Linux/` folder only when it trips the 3-click / review-trigger).
6. **#34 observability → real** (when the kit exists): fill the read-backs on the 3 seeds once **MON01 (Phase 6)** is built; then **#35** (the services layer + a device→device / client→service connectivity-testing matrix).
7. **Governance — promote policy-/standard-shaped ADRs → POLs (`ADR-0054`).** Some ADRs are now clearly **policy- or standard-shaped** (e.g. `ADR-0037` Documentation Standard · `ADR-0053` Academy Documentation Standard · `ADR-0049` session/handoff process) and should be **promoted to Policies**, with the ADRs becoming amendments and a `Governing Policy` backfilled — per **`ADR-0054`** (Proposed; proposes `POL-0014/0015/0016`; working list `Governance/Governance-Reconciliation-Triage.md`; execution tracked at Backlog #32-governance). **Its own focused governance pass**, not page-work — do it as a dedicated session.
8. **#38 — PRE-PUBLIC-PUSH POLISH (the design sweeps / publish-prep).** Cosmetic + navigation so the repo reads well to a first-time LinkedIn visitor. Work the #38 checklist: **front-door README** (hero architecture diagram + "how to navigate" map + status-marker legend) · navigation & the **3-click rule** · the **link-check CI** (folds in **#10** stale in-prose number refs) · **frontmatter consistency** (#11 / #13 / #14) · **de-noise** the internal working docs for a public reader (`SESSION-HANDOFF`, the `Session-XX` briefs, `Operations/*` queues, `atlas.bundle`, `_delivery-*/` — keep-with-a-note or tuck under `internal/`) · diagrams render on GitHub. 🔒 **BLOCKING before any public push (`ADR-0010`/`POL-0002`):** a real **gitleaks** scan of the whole history — ⚠️ **gitleaks isn't installed on the workstation** (`winget install gitleaks`; ship the committed pre-commit hook, **#20/CM-0020**) — plus a LICENSE + a "personal learning-lab" disclaimer.

## 🔑 Locked principles (every Playbook — `ADR-0053` §5)

Device-verified-first (anchor to a real Lab-01 incident, reconcile `ADR-0022`) · **command-first** (foreground the exact `show`/`get`/`openssl`/`print`/`systemctl` reads as copy-paste blocks, Healthy/Broken on their own lines) · **point-to-the-fix-doc** (link to the `CM/MC`/Build-Guide, don't re-derive) · **explain-the-mechanism where a misconception bites** (plain-language "how it actually works & why the naive assumption fails," grounded in the real standard/default) · **On this page** index · **per-step provenance** to the `CM/MC` step · **Symptoms & search terms** (`#32`, verbatim errors **one-per-bullet**) · optional **Gap** note (`#37`) · **Worked example → the CM/MC** · **one page at a time, reviewed** ("large bulks get me in trouble"). The reference = `Read-the-Cert-Not-the-Sign-Log.md`.

## House rules

**Docs-only.** No git/device/AD commands — write files + **print a PowerShell commit block for Seth** (repo root `C:\Users\atlas\Atlas\Atlas-Engineering-Repository`). Never `git add .` (`CM-0014`); LF endings; **gitleaks clean** (esp. before the public push). Ask at planning (`ADR-0049`); refresh `SESSION-HANDOFF` after each page; newer wins; a gap is "closed" only when device-verified running (`POL-0001`); never a live secret (`POL-0002`).

## ✅ Already done (session-24 arc — don't redo)

- 🥇 **Golden template** `Read-the-Cert-Not-the-Sign-Log` (from `MC-0002`) + **the mold LOCKED** into `ADR-0053` §5 (command-first · point-to-the-fix · explain-the-mechanism · one-error-per-bullet · On-this-page · per-step provenance · Worked-example→CM). `ADR-Index` **v1.30**.
- The first mentality **Concept** `A-Completed-Command-Is-Not-Evidence` (§3 theme 1; the confirmed mentality/machine split).
- §4 queue **row 7** `Rotate-a-Leaked-Key-Before-You-Back-It-Up` (`CM-0010`).
- **#34 seeded:** `Command-Library/Syslog-and-SNMP.md` + Playbooks `Trace-It-in-the-Logs` + `Diagnose-SNMP-Polling-and-a-Missing-LibreNMS-Device` (each with a **"how to find & identify it"** method section; 🔧 read-backs pending MON01 Phase 6).
- **The format-alignment audit** `Operations/Playbook-Format-Alignment-Audit.md` (17 pre-standard leaves; **6 docs-only / 11 device-needed**) + **rows 1/7/15 aligned** (`Confirm-a-Config-Change` · `Diagnose-a-Host-Silently-Dropped-by-DAI` [+SNMP hand-off] · `Trace-a-Blocked-Flow` [+syslog deny-log fast-path]).
- Backlog updated (charter + #34/#36/#37) + **#38 pre-public-push polish** added.
- **Twenty-one Playbooks written.**

## 📋 What still needs doing (the outstanding checklist)

- **Format-alignment:** rows **2–6** (docs-only) → rows **8–14, 16–17** (device-needed — format now) → the **device-test runs** (flip 🟡→✅) as the kit is built.
- **Mining queue:** §4 **rows 8–10** + the rest of the **§5 library** · a later pass over `051` (139 KB) + the retired-PKI runbooks.
- **Concepts:** §3 **themes 2–5**.
- **Command-Library:** the **Linux `show`-harvest** by service role.
- **Observability (#34/#35):** fill the MON01 read-backs when Phase 6 is built; build the services layer + connectivity matrix.
- **Governance (`ADR-0054`):** promote the policy-/standard-shaped ADRs → **POLs** (ADRs become amendments; backfill `Governing Policy`; `POL-0014/0015/0016`) — a dedicated governance pass.
- **Publish-prep (#38):** the cosmetic + navigation design sweeps; the **gitleaks gate** + LICENSE **before** the public push.
- **Device-needed testing queue:** run each drill as Phase-3→6 build lands, then flip the leaf ✅ (add its Worked-log row).

## Each page

anchor to the real Lab-01 incident → reconcile (`ADR-0022`) → build/align in the **locked mold** (command-first, `show`-heavy, indexed, per-step provenance, point-to-the-fix, gap-aware, Worked-example→CM) → tick the register / worksheet → refresh `SESSION-HANDOFF` → print the commit block → **stop for review.** North stars: `#32` (searchable, ticket-ready, offline) · `#37` (gap-aware) · `#38` (public-ready) · device-verified, page by page.
