> # ✅ DONE — RETIRED 2026-07-31 (this brief has been executed). Kept as history (`ADR-0012` quarantine-not-delete). **The current next-session brief is [`Session-24-Academy-Development-Prompt.md`](Session-24-Academy-Development-Prompt.md).**
>
> **What this brief (#31 + #30) delivered (session 22 + its cont. passes, 2026-07-31):**
> - **#31(a) — the AI-context folder → `00-Atlas-Foundation/AI-Context/` (`ADR-0052`).** `README` · `Pointers` · `Directory-Map` · `What-To-Check-First` · `ADR-Navigation` · `How-To-Document` · `Audit-Playbooks`. The **Standard-vs-Standards duplicate reconciled** — the plural renamed → `Atlas-Documentation-Style-and-Conventions.md` (live refs repointed; frozen `018-` citations left intact).
> - **#31(b/c) — the Academy grown into the operational knowledge base.** `Atlas-Academy/Academy-Vision-and-Scope.md` (the *briefcase principle*) + **`ADR-0053`** (the Academy Documentation Standard: layers · cert-grounded spine · strict 3-click rule · the Playbook template = **Pin-it · granular lists · 📸 captures · Worked-log**). The **`Atlas-Academy/Playbooks/`** action layer stood up — **7 playbooks** incl. the ⭐ golden-standard `Recover-from-a-DNS-Outage` (an `ADR-0011` Game-Day drill) + `Proxmox-Inspect-and-Troubleshoot` (grounded in frozen Lab-01). A **Linux track → CompTIA Linux+** scoped (seed = LPI Linux Essentials + the O'Reilly Linux+ guide). The first **xlsx commissioning checklist** (PVE02).
> - **Handoff archived** (sessions 2–17 → `99-Archive/`); backlog **#32** (offline briefcase + ticketing) + **#33–#36** captured.
> - **Handed forward to Session-24:** **#33** (xlsx checklists) → **#34** (syslog/SNMP tools) → **#35** (services + connectivity) → **#36** (mine Lab-01). Then **#25** (file & storage systems — firmed next major pass). The Academy Linux-content build + **#30** currency fixes ride along.
>
> ---

# Next-Session Prompt — #31 (+ #30): the AI-context "Claude" folder + Atlas-Academy development

*(Lab-02-Cisco-Core / estate-wide. **Docs-only** session. Paste this into the next bot as the task brief. Written 2026-07-31, right after #22 (the estate audit + tailoring) was closed documentation-complete and the owed Section-K K1/K2 ADRs (`ADR-0050`/`ADR-0051`) were written. This starts a **new arc**: making the estate legible to an AI session, and growing the Academy into the teaching layer it's meant to be.)*

---

## Your task

Two joined asks that share a spine — captured as backlog **#31** (with **#30**). 🔴 **The authoritative task definitions are the `#31` and `#30` entries in `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`** — read them in full; this brief operationalizes them.

**(1) Stand up the AI-context folder ("Claude").** A curated "start here" pack that lets a fresh AI session orient in one read instead of spelunking the tree. It sits *above* the per-session `SESSION-HANDOFF` (the living STATE, `ADR-0049`): the handoff is *where we are right now*; this folder is *the durable onboarding map*. Core principle — **pointers, not copies** (`POL-0004` source-of-truth): each entry is a link + a one-line "why this matters to a session" note, never a duplicated doc that will drift.

**(2) Develop the Atlas Academy** — the underdeveloped `Atlas-Academy/README.md`, plus the operator's two specific wants: **tools/scripts developed in the Academy** (runnable helpers, not just prose) and a **very detailed Linux section** (a hands-on "how to do things" reference). 🆕 **The operator will upload a Linux-essentials document to seed the Linux section** — that upload is the concrete kickoff; build the Linux section around it.

🆕 **Expanded vision (operator, 2026-07-31) — the Academy is the estate's *source of truth for knowledge*, not just certs.** A living operational knowledge base. The full capture is **backlog #31(c)** — read it first. In short, the Academy should also hold: **commands that *implement a change*** (per platform); **tons of device-specific `show`/read commands** revealing how each of *our* real devices is configured (Cisco `show` · MikroTik `… print` · FortiOS `get`/`diagnose` · Linux · pfSense); and **scenario-driven troubleshooting playbooks** — port-in-use conflicts (+ how to pick a different port) · connection testing (what each test proves) · **deep Linux networking** (read + configure, with the inspection commands for every net fact/service) · reading **`journalctl`** · **IPS/firewall dropped-traffic** diagnosis (what to check when a connection is blocked → trace it to the rule) · per-appliance guides (**pfSense · FortiGate · MikroTik-as-E-W-firewall**) · **"what to do if one device goes down"** failure runbooks (the operator was mid-list — complete the scenario taxonomy with them). Keep the Academy rule: **every command/guide anchored to a real Atlas device/artifact** (`POL-0008` — the device page owns its facts; the Academy is the cross-device teaching + ops-knowledge layer that deepens the existing `Command-Library/`). This is far bigger than one session — **scope it with the operator, then build in slices** (the Linux section from the upload is the natural first slice).

**This is docs-only.** You run **no** device/AD/git commands — **print PowerShell commit blocks for Seth** (see the commit rule below). Follow the `ADR-0049` protocol: **this arc is design-heavy, so ask design questions at planning**, work **one piece at a time** (never a bulk restructure), and **refresh the handoff after each logical piece**.

> ⚠️ **Plan before you build — this needs an ADR.** Where the folder lives and what it's named is an open decision (top-level `Claude/` vs `AI/` vs `00-Atlas-Foundation/AI-Context/`), as is pointer-vs-copy scope, where tools/scripts live (Academy vs the folder vs the **#19** git/CI capability), and how the folder stays current (a read/refresh rule in the spirit of `ADR-0049`). **Ask these at planning; the answers land in a new ADR** (+ propagate to `ADR-Index`).

---

## Read first (in this order)

1. **`Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md`** — the **📍 CURRENT STATE block + the latest session block** (the `ADR-0049` read rule). #22 + the owed ADRs are closed there; this is your starting line.
2. **`00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`** — the **#31** (AI-context folder + Academy development) and **#30** (Academy improvement + cert-paths) entries in full. Also skim the "Recommended priority — post-#22" block (the owed **#19** git/CI ADR + the still-open **K5/K7/K8** Section-K ADRs are adjacent context, not this pass).
3. **The operator's pointer set** (from #31) — read each so you know what you're pointing at:
   - **Best / core context:** `Atlas-Improvement-Backlog.md` · `Atlas-Roadmap.md` · `POL-0001-Atlas-Audit-Policy.md` · `POL-0004-Source-of-Truth.md` · `POL-0006-Evidence-and-Verification.md` · `00-Atlas-Foundation/Templates/`.
   - **Could be improved (governing/standards docs):** `Atlas-Charter.md` · `Atlas-Documentation-Standard.md` · `Atlas-Documentation-Workflow.md` · `Contributing-Adding-Docs.md` · `Atlas-Documentation-Standards.md`.
   - **Could be developed more:** `Atlas-Academy/README.md` · `Labs/Lab-02-Cisco-Core/Build-Progress-Tracker.md`.
4. **`Atlas-Academy/`** — walk the whole book: the 5 cert lab-maps (CCNA · CCNP-ENCOR/ENARSI · AZ-800/801 · FortiGate-FCP · Security+ Dom5), the `Command-Library/`, the `Concepts/` library (+ its README seed-list), and `Atlas-Cert-Objective-Gap-Analysis`. #30 assessed all of this — read #30's findings before touching anything.
5. **`ADR-0049`** (handoff/planning protocol) + **`ADR-0037`** (the Documentation Standard) — the shape any new folder/doc should respect.

---

## ⚠️ Known thing to reconcile early

**`Atlas-Documentation-Standard.md` (singular) vs `Atlas-Documentation-Standards.md` (plural)** — the operator flagged this pair as a **likely duplicate / split**. Before leaning on either as a pointer, **diff them and decide the single owner** (or the deliberate split), then reconcile (`POL-0008`). Don't cite both as "the standard" until this is settled.

---

## Suggested first-session scope (don't boil the ocean — confirm at planning)

This is a multi-part project; a single session should land a coherent slice, not all of it. A sensible first cut, in order:

1. **Decide + draft the folder's ADR** — home, name, pointer-vs-copy rule, tools/scripts location, refresh rule. Ask the operator the open questions at planning; write the ADR; add the `ADR-Index` row (next free number after `ADR-0051`).
2. **Build the "start here" index** — the folder's front-door README: the operator's categorized pointer list, each as a link + a one-line "why this matters to a session" note. Group by the operator's categories (core context · governing/standards · Academy · build state). Reference the `SESSION-HANDOFF` read rule and the docs-only/Seth-runs-git conventions explicitly (an AI session should learn the house rules here).
3. **Reconcile the Standard-vs-Standards duplicate** (above) so the pointers are clean.
4. **Seed the Academy Linux section** from the operator's uploaded Linux-essentials doc — as a hands-on `Atlas-Academy/` reference (commands · workflows · worked examples anchored to real Atlas artifacts, per the Academy's design principle). Decide its home in the Academy at planning.
5. **Scope (don't yet fully write) the Academy README development** — the underdeveloped `Atlas-Academy/README.md` will be a **big doc**; draft its outline + what belongs in it (tie to #30's A–F findings — start with the **curriculum currency fix** and the **missing device×cert matrix**), and capture the plan so a following session executes it.

Record every non-obvious call at planning (`Considerations`/the new ADR + propagate to owners, `POL-0008`), and **refresh `SESSION-HANDOFF` after each piece**.

---

## The rules (unchanged, estate-wide)

- **Docs-only. You never run git / device / AD commands.** You write files to disk and **print a PowerShell commit block** for Seth to run (repo root `C:\Users\atlas\Atlas\Atlas-Engineering-Repository`; `git add … ; git commit -m "…"`). Seth runs all git.
- **`POL-0001` / `POL-0006` evidence discipline** — nothing is `✅`/"verified" without a read-back; proposed/target state is `📋`/`⬜`.
- **`POL-0002`** — never record a live secret (→ Vaultwarden).
- **`POL-0004` / `POL-0008`** — one source of truth per fact; point, don't duplicate; propagate a change to every doc that asserts it.
- **`ADR-0049`** — ask at planning · one piece at a time · living-STATE handoff refreshed each piece · the DC/Windows template is a *starting* shape, tailor per need.

---

## Adjacent owed work (context, not this pass)

Still un-homed after #22, tracked in the backlog priority block — mention if relevant, don't action unasked:
- **#19 estate-capability ADR** — self-host-vs-GitHub · GitOps model · CI-runner placement (unblocks CNT01; the natural home for estate tools/scripts, so it *touches* #31's tools/scripts question).
- **Section-K K5** (1941 ZBF) · **K7/K8** (pfSense IPS tuning · Suricata↔Wazuh correlation) — the remaining Section-K ADRs (K1/K2 done → `ADR-0050`/`ADR-0051`).
- **Build critical path** is the operator's (on hardware): Phase 3 Identity → AD CS ceremony → NetBox → MON01 → the backup restore-test.

---

*When #31's first slice is done, refresh `SESSION-HANDOFF`, retire this prompt with a ✅ DONE banner (`ADR-0012` pattern), and write the next brief for whatever the operator picks up next.*
