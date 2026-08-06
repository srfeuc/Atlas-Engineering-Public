---
Title: Playbook Format-Alignment Audit — bring the pre-standard Playbooks to the locked `ADR-0053` §5 mold (+ device-test flags)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 LIVING work-queue. Audits the **17 Playbooks written before the format was locked** against the current golden mold (`ADR-0053` §5, canonical reference `Read-the-Cert-Not-the-Sign-Log.md`), and **flags which can only be finished on real hardware**. This is the plan, not the edits — align **one page at a time, reviewed** (`ADR-0049`), like the `#36` mining worksheet. Operator ask (2026-08-01): *"go through the old playbooks … make them match the format. If there are ones that actually need to be done at the device level and tested, flag those."* **🔄 Progress: rows 1, 7, 15 aligned 2026-08-01; rows 2, 3, 4 aligned 2026-08-02 (docs-only).** (`Confirm` · `Diagnose-DAI` [+SNMP] · `Trace-a-Blocked-Flow` [+syslog]; then `Enumerate`→CM-0033 · `Respond-to-a-Committed-Secret`→CM-0014 · `Remove-a-MikroTik`→On-this-page.)
Version: 1.2
Date: 2026-08-02
---

# Playbook Format-Alignment Audit (#36 follow-on)

<!-- provenance -->
> **Lab-02 · Operations.** The Playbooks layer grew in waves; the format was only **locked** partway through (`ADR-0053` §5 — the golden template `Read-the-Cert-Not-the-Sign-Log` v1.2 + the `Rotate-a-Leaked-Key` build). Earlier leaves predate one or more of the locked elements. This register audits each against the mold, and separates a **docs-only** fix (bring the format up + quote read-backs from a frozen Lab-01 record) from a **device-needed** one (the real read-backs / 📸 only exist once the scenario is *run* on live or rebuilt kit). Two current leaves (`Read-the-Cert-Not-the-Sign-Log`, `Rotate-a-Leaked-Key-Before-You-Back-It-Up`) are already at the mold and excluded.

## What "aligned" means — the locked mold checklist (`ADR-0053` §5)

A fully-aligned Playbook has: **On this page** (numbered quick-nav) · **Symptoms & search terms** (`#32`, four parts, **verbatim errors one-per-bullet**) · **Cert anchor** · **① Pin it down** · a **command-first** diagnosis path (exact reads as copy-paste blocks, Healthy/Broken on their own lines) with **per-step provenance** to the `CM/MC` that proved each step · **explain-the-mechanism** where a misconception bites · **point-to-the-fix-doc** (link down, don't re-derive) · **Gap / what this closes** (where a real gap exists) · **Worked example → the CM/MC doc** (where a frozen incident exists) · 📸 markers · **Related** (link-down) · **Worked log** · **Change Log**.

## The device-test flag (the operator's ask)

Each leaf is 🟡 (method authored, lab-unverified). To reach ✅ it needs one of:

- **📄 DOCS-ONLY** — can be brought to format-complete **and** its read-backs quoted from an **existing frozen Lab-01 `CM/MC` record** (the real values are already on disk). No hardware run required for the doc to be complete and honest. *(A later real run still adds a Worked-log row, but the doc isn't blocked.)*
- **🔧 DEVICE-NEEDED** — the real read-backs / 📸 can only come from **running the scenario on a live or rebuilt device**. The **format** can be aligned now; the 🟡→✅ waits on the run. Several are further **gated on Lab-02 kit** that isn't stood up yet.

## §1 The register (17 pre-standard Playbooks)

Status: ⬜ not started · 🚧 format-aligned (🟡 read-backs pending) · ✅ aligned + verified.

| # | Playbook | Frozen anchor | Flag | Main format gaps vs the mold | Effort | Status |
|---|---|---|---|---|---|---|
| 1 | `Confirm-a-Config-Change-Actually-Took` | **MC-0001** + `015`/`016` (+`CM-0030`) | 📄 DOCS-ONLY | On-this-page; quote MC-0001 `get`→`Fortinet_GUI_Server` + `s_client` count as the Worked example | light | 🚧 **v1.1** (On-this-page + Worked-example → MC-0001) |
| 2 | `Enumerate-Every-Enabled-Interface-Before-Hardening` | **CM-0033** + `016` L9 | 📄 DOCS-ONLY | On-this-page; Worked example quoting CM-0033's `internal3-7`/`192.168.1.99` enumeration (note Lab-01 addressing) | light | 🚧 **v1.1** (On-this-page + Worked-example → CM-0033) |
| 3 | `Respond-to-a-Committed-Secret` | **CM-0014** (+CM-0010/0019/0020) | 📄 DOCS-ONLY | On-this-page; Worked example quoting CM-0014 fresh-clone `EXIT:1` + gitleaks block (never the secret, `POL-0002`) | light | 🚧 **v1.1** (On-this-page + Worked-example → CM-0014, secret never reproduced) |
| 4 | `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched` | **CM-0009** | 📄 DOCS-ONLY | **On-this-page only** — otherwise essentially at the mold (has Worked example + Gap) | light | 🚧 **v1.1** (On-this-page added — otherwise already at the mold) |
| 5 | `Prove-Exactly-Which-MikroTik-Rule-Acted` | Firewall **Low-Level-Isolation-Tests** + `ADR-0016` | 📄 DOCS-ONLY | On-this-page; Worked example quoting the frozen isolation-test read-backs | medium | ⬜ |
| 6 | `MikroTik-EastWest-Inspect-and-Troubleshoot` | Firewall **Per-Rule-Verification-Tests** + `CM-0009` | 📄 DOCS-ONLY | Worked example from the frozen verification-test doc; **resolve the dangling `CM-0023` ref** (line ~124); label the misconception note (has On-this-page ✅) | medium | ⬜ |
| 7 | `Diagnose-a-Host-Silently-Dropped-by-DAI` | **CM-0022** + `016` L6 | 🔧 DEVICE-NEEDED | **On-this-page only** (already new #32 mold, command-first) — but the `show ip arp inspection`/`ACL Drops` read-backs need an **SW01 run under Lab-02 VLSM** | light | 🚧 **v1.1** (On-this-page + **SNMP cross-link** → `Diagnose-SNMP-Polling`; format done, 🔧 read-backs pending SW01) |
| 8 | `Fix-the-SW01-Clock` | **CM-0030** | 🔧 DEVICE-NEEDED | On-this-page; Worked example quoting CM-0030's `stratum 16` broken side. **The synced "after" never existed** → needs an SW01 run once the `ADR-0020` NTP source is stood up | light–med | ⬜ |
| 9 | `Proxmox-Inspect-and-Troubleshoot` | **CM-0012** (VT-x/RTC) + CM-0011 | 🔧 DEVICE-NEEDED | On-this-page; #32 Symptoms; lift commands into copy-paste blocks. VT-x/RTC quotable from CM-0012; **5 of 6 paths need live PVE01** | medium | ⬜ |
| 10 | `Domain-Join-Fails` | `CM-0030` (time cause only); no join incident | 🔧 DEVICE-NEEDED | On-this-page; **#32 four-part Symptoms** (still old style); empty Worked-example placeholder. **AD never stood up** → join read-backs need a real join on a rebuilt DC+member | medium | ⬜ |
| 11 | `Port-Already-In-Use` | none (generic method) | 🔧 DEVICE-NEEDED | On-this-page; **#32 Symptoms block**. Already command-first; 🟡 clears with a **live-host paste** (trivial host) | medium | ⬜ |
| 12 | `Test-a-Connection` | `015` (concept ladder) | 🔧 DEVICE-NEEDED | On-this-page; **#32 Symptoms**. Strong misconception note already; needs one **real pasted ladder run** | medium | ⬜ |
| 13 | `Read-the-Logs-with-journalctl` | none (generic method) | 🔧 DEVICE-NEEDED | On-this-page; **#32 Symptoms**; restructure numbered narration into command-first blocks w/ Healthy/Broken. Needs a **live-host paste** | medium | ⬜ |
| 14 | `Recover-from-a-DNS-Outage` | `ADR-0011` Game-Day drill (no prior incident) | 🔧 DEVICE-NEEDED | On-this-page; **#32 Symptoms**. Otherwise the strong exemplar (command-first, 📸, Gap). Read-backs + **RTO only from running the drill on Pi01** | light | ⬜ |
| 15 | `Trace-a-Blocked-Flow` | none (`MC-0001` tangential) | 🔧 DEVICE-NEEDED | On-this-page; **#32 Symptoms**; refactor the conceptual four-point overview into command-first blocks; per-step provenance. **Enforcement kit in-build** (PFSENSE01 not built, FGT UTM/TLS gated) | heavy | 🚧 **v2.0** (full command-first rewrite + **syslog fast-path** → `Trace-It-in-the-Logs`; format done, 🔧 read-backs pending the built enforcement kit) |
| 16 | `Recover-a-Locked-Out-Router-Out-of-Band` | **CM-0017/CM-0018** (MAC path) | 🔧 DEVICE-NEEDED | On-this-page; Worked example; restructure the ladder into command-first blocks. **Console rung never proven** (`ADR-0023`) → Test-A/B drill on rebuilt MKT01 | heavy | ⬜ |
| 17 | `Recover-the-Lab-from-a-Bare-Metal-Teardown` | `048` runbook (never executed) | 🔧 DEVICE-NEEDED | **Split the bundled verbatim symptom bullets** (one error per line); On-this-page. Inherently a phase/table DR narrative. **RTO/read-backs gated on running the Game-Day** | heavy | ⬜ |

## §2 Cross-cutting findings

- **On this page** — missing from **16 of 17** (only `MikroTik-EastWest` has it). The single most universal, cheapest add.
- **`#32` Symptoms four-part** — the `#36` batch (rows 1–6) and the MikroTik set already carry it with **verbatim errors one-per-bullet**. The **8 earliest** leaves still use the old "Symptoms / when you'd use this" and need the `#32` conversion (the heavier part of their lift): `Trace-a-Blocked-Flow` · `Port-Already-In-Use` · `Test-a-Connection` · `Read-the-Logs-with-journalctl` · `Fix-the-SW01-Clock` · `Recover-from-a-DNS-Outage` · `Domain-Join-Fails` · `Proxmox-Inspect-and-Troubleshoot`.
- **One-error-per-bullet split still owed** on `Recover-the-Lab-from-a-Bare-Metal-Teardown` (bundles FortiGate/MikroTik/Cisco prompts on one bullet; slash-joins two errors).
- **Per-step provenance** — the biggest recurring gap in the early leaves: steps link *down* to the Command-Library (good, `#6`) but don't cite the specific `CM/MC` that proved each step.
- **Command-first** — prose-heavy / design-doc-ish (the heavy rewrites): `Trace-a-Blocked-Flow` · `Recover-a-Locked-Out-Router-Out-of-Band` · `Recover-the-Lab-from-a-Bare-Metal-Teardown`; partially so: `Test-a-Connection` · `Read-the-Logs-with-journalctl` · `Proxmox-Inspect-and-Troubleshoot`.
- **Worked example → CM/MC** — addable now on the DOCS-ONLY set (frozen records hold the read-backs); the DEVICE-NEEDED set gets it when run.
- **Dangling reference** — `MikroTik-EastWest` line ~124 still carries the unresolved `CM-0023` service-ACL link (operator: skip for now; resolve during this leaf's alignment).

## §3 The device-level testing queue (🔧 — the "flag those" list)

The 11 DEVICE-NEEDED leaves, grouped by **what has to exist first** to capture the real read-backs. Their **format** is aligned in §4 now; the 🟡→✅ is a separate, hardware-gated pass.

**A. Runnable on already-built / trivial kit (no new build needed):**

- `Port-Already-In-Use` · `Test-a-Connection` · `Read-the-Logs-with-journalctl` — any Linux host; paste one real run.
- `Proxmox-Inspect-and-Troubleshoot` — **PVE01 is built**; 5 of 6 symptom paths just need a live read (VT-x/RTC already quotable from `CM-0012`).

**B. Gated on a Lab-02 service being stood up:**

- `Recover-from-a-DNS-Outage` — needs **Pi01** stood up; then run the `ADR-0011` break-and-recover drill (captures the RTO).
- `Fix-the-SW01-Clock` — needs the **AD-anchored NTP source** (`ADR-0020`) before SW01 can reach synced/stratum-3.
- `Diagnose-a-Host-Silently-Dropped-by-DAI` — needs **SW01 under Lab-02 VLSM** + a DAI drop scenario to move the `ACL Drops` counter.
- `Domain-Join-Fails` — needs **AD (DC01/DC02)** + a member to run a real join.
- `Trace-a-Blocked-Flow` — needs **PFSENSE01** built + **FGT01 UTM/TLS** (`ADR-0047`/`ADR-0050`) for the full enforcement trace.

**C. Game-Day drills (execute deliberately, whole-path):**

- `Recover-a-Locked-Out-Router-Out-of-Band` — the **serial-console rung is a new unproven prereq** (`ADR-0023`); run the MAC-WinBox + console Test-A/B drill on the rebuilt MKT01.
- `Recover-the-Lab-from-a-Bare-Metal-Teardown` — the full `ADR-0011` Game-Day; RTO + the leave-the-docs log only exist once run.

> These map to the estate's build/verification backlog — as each device/service reaches "built + verified," run its drill and flip the leaf 🟡→✅ (add the Worked-log row). Track alongside `Build-Progress-Tracker.md` and the Review-Flag-Register.

## §4 Recommended alignment order (one page at a time, reviewed)

Do the **format** alignment top-down; it's docs-only work regardless of the device flag (the flag only decides whether ✅ follows now or later).

1. **DOCS-ONLY, light (fast complete wins) —** rows 1–4: `Confirm-a-Config-Change` · `Enumerate-Every-Enabled-Interface` · `Respond-to-a-Committed-Secret` · `Remove-a-MikroTik-…` (mostly just On-this-page + a Worked example from the frozen record; #4 can approach ✅).
2. **DOCS-ONLY, medium —** rows 5–6: `Prove-Exactly-Which-MikroTik-Rule-Acted` · `MikroTik-EastWest-…` (Worked example from the frozen firewall tests; resolve `CM-0023`).
3. **DEVICE-NEEDED, light —** rows 7–8 + 14: `Diagnose-a-Host-Silently-Dropped-by-DAI` · `Fix-the-SW01-Clock` · `Recover-from-a-DNS-Outage` (On-this-page + #32; align, mark 🔧 pending the run).
4. **DEVICE-NEEDED, medium —** rows 9–13: `Proxmox` · `Domain-Join-Fails` · `Port-Already-In-Use` · `Test-a-Connection` · `Read-the-Logs-with-journalctl` (#32 conversion + command-first tidy).
5. **DEVICE-NEEDED, heavy (real rewrites) —** rows 15–17: `Trace-a-Blocked-Flow` · `Recover-a-Locked-Out-Router-Out-of-Band` · `Recover-the-Lab-from-a-Bare-Metal-Teardown`.

Tick the Status column as each leaf is aligned; refresh the handoff; one page per pass.

## Related

- `00-Atlas-Foundation/Decisions/ADR-0053` §5 (the locked mold) · `Atlas-Academy/Playbooks/Read-the-Cert-Not-the-Sign-Log.md` (the canonical reference) · `Atlas-Academy/Playbooks/README.md` (the index).
- `Labs/Lab-02-Cisco-Core/Operations/Lab-01-Playbook-Mining-Candidates.md` (the `#36` build queue — this is its format-alignment sibling) · `Atlas-Academy/Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md`.
- Device-test gating: `Build-Progress-Tracker.md` · `Review-Flag-Register.md` · `Operations/Build-Order-and-Dependencies.md`.

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.2 | 2026-08-02 | **Aligned rows 2, 3, 4 (docs-only leaves).** `Enumerate-Every-Enabled-Interface` → v1.1 (On-this-page + Worked-example → `CM-0033`: `internal3-7` up while the group is down · the `192.168.1.99` break-glass). `Respond-to-a-Committed-Secret` → v1.1 (On-this-page + Worked-example → `CM-0014`: fresh-clone `EXIT: 1` + the gitleaks default-missed / name-rule-blocked finding, secret never reproduced). `Remove-a-MikroTik-…` → v1.1 (On-this-page — the one missing element). All three DOCS-ONLY complete; 🟡→✅ still waits on a real run for the Worked-log row. Rows 5–6 (docs-only, medium) remain, then the device-needed set. |
| 1.1 | 2026-08-01 | **Aligned rows 1, 7, 15** (operator: row 1 + a syslog-paired + an SNMP-paired leaf). `Confirm-a-Config-Change` → v1.1 (On-this-page + Worked-example → MC-0001; DOCS-ONLY done). `Diagnose-a-Host-Silently-Dropped-by-DAI` → v1.1 (On-this-page + the **SNMP** monitoring hand-off to `Diagnose-SNMP-Polling`; format done, 🔧 read-backs pending SW01). `Trace-a-Blocked-Flow` → v2.0 (full command-first rewrite + a **syslog** fast-path 5.1 → `Trace-It-in-the-Logs`; format done, 🔧 pending the built enforcement kit). Status column ticked 🚧. |
| 1.0 | 2026-08-01 | Created (operator ask — align the pre-standard Playbooks to the locked `ADR-0053` §5 mold + flag the device-level ones). Audited all **17** pre-standard leaves (three parallel read passes) against the mold; per-leaf format gaps + a **docs-only vs device-needed** flag with reason + effort. **6 DOCS-ONLY** (frozen `CM/MC` read-backs quotable): `Confirm` · `Enumerate` · `Respond-to-a-Committed-Secret` · `Remove-a-MikroTik-…` · `Prove-Exactly-…` · `MikroTik-EastWest`. **11 DEVICE-NEEDED**, grouped by gating kit (§3). Cross-cutting: On-this-page missing from 16/17; the 8 earliest still on the old Symptoms heading; `Recover-Bare-Metal` owes the one-error-per-bullet split; per-step provenance the biggest recurring gap. Recommended alignment order (§4), one page at a time. |
