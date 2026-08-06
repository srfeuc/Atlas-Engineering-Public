> # ✅ SUPERSEDED — 2026-07-31 (`ADR-0012`: quarantine, don't delete)
> **This brief is retired. The live brief is [`Session-26-Playbook-Building-Prompt.md`](Session-26-Playbook-Building-Prompt.md)** — the prioritized v2 with a **recommended order** (housekeeping → plan with the operator → build the golden template from `MC-0002` → then page-by-page). This file is kept for history: it carries the first capture of the Lab-01 Playbook Project's principles + the operator's rapid-fire design ideas (2026-07-31). **Do not build from this page — use Session-26.**

---

# The Lab-01 Playbook Project — Next-Session Brief (device-verified fixes → very granular, searchable Playbooks) — RETIRED, see Session-26

*(Lab-02-Cisco-Core / Atlas Academy. **Docs-only** session. Paste this into the next bot as the task brief. Written 2026-07-31; **reframed into the "Lab-01 Playbook Project"** from the operator's 2026-07-31 direction. Replaces `Session-24-Academy-Development-Prompt.md` (retired ✅ SUPERSEDED, `ADR-0012`). Meant to run across **several sessions**, **one page at a time**.)*

---

## 🎯 The project (what we're doing and why)

**Turn frozen Lab-01's real, device-verified incidents into a library of tested-and-proven, very granular, searchable Playbooks — so a fix is never re-derived.** The operator's framing (2026-07-31):

> *"Lab-01 docs were all made while at a machine. They are very valuable and I want that as a priority. I wanted it to teach me what to do so I wouldn't have to ask so many questions the 2nd or 3rd time."*

So the Lab-01 seam is the **priority source**: its incidents actually happened on the hardware, so the fixes are proven, not hypothetical. Much of Lab-01 is **the same as Lab-02** (SW01 · MKT01 · FGT01 · PVE01 · the Raspberry Pi), so a reconciled Lab-01 lesson carries into Lab-02 **and the next lab** — the companion map is `Atlas-Academy/Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md`.

## 🔑 Project principles (LOCKED — how every Playbook is made)

1. **Device-verified-first.** Anchor every Playbook to a real, at-the-machine Lab-01 incident (a `CM-####` / device `Troubleshooting` / `016` / the MKT01 firewall test docs). Reconcile to the current design (`ADR-0022` — Lab-01 loses where it disagrees). A proven fix beats a plausible one.
2. **Very granular, very specific — with the real `show` commands foregrounded** (operator: *"the playbooks can get really specific too — it needs to be very granular"* + *"show commands need to be in there more"*). Down to the exact command, the exact read-back (Healthy vs Broken on their own lines), and the exact decision point. **Lean hard on the device-specific `show`/read commands that reveal how each machine is actually configured** — Cisco `show … status`, MikroTik `… print detail`/`print stats`, FortiOS `get`/`diagnose`, Linux `systemctl`/`ss`/`ip`/`journalctl` — because those are what a real operator types at the machine. One idea per line; `a/b/c` sub-steps. Detailed is the goal; dense is not. (Commands the Command-Library owns get **linked down to**, not restated — `POL-0008`; but the *specific* read-back a step turns on is named inline.)
3. **Searchable + ticket-ready (`#32`).** The **filename = the problem in plain words = the ticket title.** Every page carries the required **"Symptoms & search terms"** element (verbatim errors · plain phrases · aliases · keywords) so it surfaces when the operator types *what he's seeing, in his own words*.
4. **One page at a time, reviewed** (operator: *"I want to go page by page for a bit since producing large bulks gets me in trouble sometimes"*). Build a single Playbook, refresh the handoff, print the commit block, stop for review. **No bulk passes.**
5. **Gap analysis is a tool** (`#37`). Where an incident exposed a structural gap, add the optional **"Gap / what this closes"** note (`ADR-0053` §5) — a design weakness the current lab closes, or one still open in the partial build; call out security vulnerabilities. Link to the reconciliation & gap map. Evidence rule holds: a gap is "closed" only when the mitigation is verified running.

## 🧭 Open design ideas (CONFIRM WITH THE OPERATOR before acting — captured 2026-07-31, do not silently build)

The operator is still shaping the project. These are captured so nothing is lost; **ask at planning** (`ADR-0049`) before building any of them:

- **A golden Playbook template cut from a real Lab-01 machine resolution** (operator: *"we'll make another golden template from the actual lab01 machines and what was done to resolve an issue"* — the thought was mid-sentence). Designate (or build) a golden exemplar whose provenance is an actual device-verified Lab-01 fix, so future Playbooks copy a *real* shape, not an abstract one. 🎯 **Operator's suggested candidate: [`MC-0002` — MikroTik Certificate Reissuance & CA Fix](../../Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md)** — a rich, multi-issue device-verified resolution (cert renamed on import · stale SAN `10.0.0.1` vs the live IP · chain/bundle · `get`-not-`show`). Reconcile the OpenSSL-CA specifics to **AD CS** (`ADR-0031`) — the "read the cert not the issuance log / reissue with a correct SAN" discipline is fully current (maps to the §5 worksheet candidate `Reissue-a-Certificate-With-a-Correct-SAN`). **Confirm with the operator: is MC-0002 THE golden template, and what filename/problem-name?**
- **Split "troubleshooting mentality" from "steps for specific machines"** (operator). A **mentality layer** — the recurring disciplines (read the value back · prove the negative · a group's state ≠ its members' · silent-drops-have-no-error · recovery-paths-are-invisible) — likely lives in **`Concepts/`** (route the worksheet §3 themes there). **Machine-specific steps** live in the per-appliance inspect Playbooks (MikroTik/FortiGate/pfSense/Proxmox) + the device `Troubleshooting.md` pages. Confirm the split + where the mentality layer lives.
- **Command-Library harvest → Linux, with `show`/read commands foregrounded** (operator: *"some commands from these belong in the Atlas Academy's Linux commands"* + *"show commands need to be in there more"*). Harvest the real inspection commands from the Lab-01 seam into **`Command-Library/Linux.md`** (marked 🟡 expanding) and the other platform pages — **be generous with the device-specific `show`/`get`/`print`/`systemctl`/`ss`/`ip`/`journalctl` read commands that reveal real configured state** (the Academy Vision's "tons of device-specific `show`/read commands" — a named priority). Page by page; mark retired-tech commands historical/anti-pattern (`ADR-0022`); keep the healthy-vs-broken format (`ADR-0032`).
- **Service-role-organized Linux commands** (operator: *"add a section or folder for specific roles a Linux service has and relevant commands like show commands"*). Per Linux service (Pi-hole · chrony · Vaultwarden · nginx · NPS-adjacent · …): its **role** + the **`show`/verify commands** to inspect it — mirroring the Lab-01 `PI01/Roles/` folder model. **Confirm: a section within `Command-Library/Linux.md`, or a `Command-Library/Linux/` folder** (the 3-click rule / `ADR-0053` review-trigger decides when a section must become a folder).

---

## Read first (in this order)

1. **`Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md`** — the `📍 CURRENT STATE` block + the latest session block (`ADR-0049`).
2. **`Labs/Lab-02-Cisco-Core/Operations/Lab-01-Playbook-Mining-Candidates.md`** — 🎯 the work-list. §4 the build queue · §5 the full library · §2 the reconcile rules · §3 the recurring themes (candidate *mentality*/Concepts pages).
3. **`Atlas-Academy/Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md`** — 🆕 the shared-core + gap map; reconcile each incident here.
4. **`00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md`** — **#36** (the mine) · **#37** (gap analysis + the map + the Command-Library/mentality workstreams) · **#32** (the offline briefcase) · **#30** (Academy currency).
5. **`00-Atlas-Foundation/Decisions/ADR-0053-...md`** — §5 the Playbook template (now incl. **"Symptoms & search terms"** required + **"Gap / what this closes"** optional) · §8 the checklist ↔ Playbook cross-link · the 3-click rule.
6. **`Atlas-Academy/Academy-Vision-and-Scope.md`** — the briefcase principle.
7. **The golden exemplars:** `Atlas-Academy/Playbooks/Recover-from-a-DNS-Outage.md` · `Domain-Join-Fails.md` · the six #36 rows + the three MikroTik firewall Playbooks built 2026-07-31.
8. **`00-Atlas-Foundation/AI-Context/What-To-Check-First.md`** + `Pointers.md` (→ "The Lab-01 incident seam") — the house rules + the seam map.
9. **The real Lab-01 anchor** for whichever candidate you're building (frozen; `ADR-0022`).

---

## Build order (page by page — pick the next, confirm, build ONE)

Worksheet §4 queue, top-down, **unless the operator re-prioritises** (he has, twice — to MikroTik firewall, and to the reconciliation map). Done so far:

- ✅ **Rows 1–6** (2026-07-31): Diagnose-a-Host-Silently-Dropped-by-DAI · Confirm-a-Config-Change-Actually-Took · Enumerate-Every-Enabled-Interface-Before-Hardening · Recover-a-Locked-Out-Router-Out-of-Band · Recover-the-Lab-from-a-Bare-Metal-Teardown · Respond-to-a-Committed-Secret.
- ✅ **MikroTik east-west firewall set** (2026-07-31): MikroTik-EastWest-Inspect-and-Troubleshoot · Prove-Exactly-Which-MikroTik-Rule-Acted · Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched.
- **Remaining §4 rows 7–10:** `Rotate-a-Leaked-Key-Before-You-Back-It-Up` (`CM-0010`) · `Reconcile-a-Build-Guide-That-Rebuilds-a-Broken-Device` (`CM-0022`) · `Verify-an-Edit-by-Counting-the-Old-Text` (`CM-0021`/`CM-0026`) · `Trace-Three-Symptoms-to-a-Dead-CMOS-Battery` (PVE01/`CM-0012`).
- **Plus:** more MikroTik/Lab-01 firewall pages; the §3 themes → `Concepts/` (mentality layer); the Command-Library harvest — **each is its own reviewed page.**

---

## The per-Playbook shape (golden mold — extend the existing template)

**Frontmatter** (`#32`-anchored) · **provenance** · **one-line problem** · **Symptoms & search terms** (verbatim errors · plain phrases · aliases · keywords) · **On this page** 🆕 (a quick-nav index — see below) · **Cert anchor** · **Grounded in** (the real Lab-01 anchor, reconciled) · **① Pin it down** · **the diagnosis path** (very granular: a/b/c; command · reference · Healthy · Broken each on its own line; **📸 capture markers at each read-back that *proves* the answer** — SS-001) · **the fix (+ prove it)** · **If still broken** · **Gap / what this closes** *(optional)* · **Related** (link down to `../Command-Library/`; siblings; `#32`; the checklist cross-link `ADR-0053` §8; the reconciliation map where relevant) · **Worked log** · **Change Log**.

- **Per-step provenance links** (operator: *"each step could include a link to the document that showed when this was a solution"*). Where a specific step traces to a real doc that proved it (a `CM-####` record, a device `Troubleshooting` entry, a firewall-test doc), **link that step to its source** — so every granular step is device-verified-traceable, not just the page as a whole (`POL-0008` — link, don't restate). Verify the link resolves before committing (CI link-check); if the exact record is uncertain, link the doc that *owns* the distinction and flag the `CM-####` to confirm rather than guessing (`POL-0001` — don't invent a citation).
- **"On this page" index** (operator: *"there needs to be an index for each problem-solution in the page"*). Near the top of each Playbook, a short **quick-nav** so a mid-incident reader jumps straight to what they need — the sections (Symptoms · Pin it down · the diagnosis steps · the fix · If still broken · Gap · Related) **and, for a multi-cause page, an index of the causes → their fix** (e.g. `Domain-Join-Fails`' four causes: DNS → §Fix 1 · time skew → §Fix 2 · blocked path → §Fix 3 · credentials → §Fix 4). The very-granular pages especially need this. *(Template-candidate for `ADR-0053` §5 — confirm the exact form with the operator, then formalize.)*
- **Worked example — the real Lab-01 case, pointing to the change-management doc** (operator: *"an actual situation where this was all done — showing an example would be nice"* + *"maybe point to a change management doc"*). Where the Lab-01 anchor is a clean, documented resolution, add a short **"Worked example"** section that walks the *actual* incident through this Playbook's steps — the real symptom, the real `show`/read-backs (quoted from the frozen record, marked as the Lab-01 read-back — honest per `POL-0001`), the real fix, the real proof — and **links straight to the `CM-####` change-management record** as the authoritative source of that resolution (`POL-0008` — the CM doc owns the incident; the Playbook links to it, doesn't restate it). This is the device-verified heart of the page: it shows the procedure *done for real*. (Also the seed of the **golden-template-from-a-real-resolution** idea. Template-candidate for `ADR-0053` §5 — confirm with the operator.)
- **📸 Screenshots belong in the Playbook** (operator: *"screenshots belong in them"*). At each read-back that proves the answer (which rule matched; the fix confirmed), a **📸** marker names what to capture — **healthy vs broken** — as visual reference/rebuild evidence, stored beside the page (an `images/` subfolder). Produced by **running the real `show`/read commands** in the scenario, so they land 🟡→✅ as the page is exercised on the device — **never pre-fabricated, never a live secret** (`POL-0002` / SS-001).

- **Link down, don't restate** (`POL-0008`) — the Command-Library owns commands; the device page owns facts.
- **Never invent output** (`POL-0001`) — 🟡 until a real read-back is pasted.
- **Add each new leaf to `Atlas-Academy/Playbooks/README.md`**, keep the 3-click rule.

## Reconcile rules (frozen Lab-01 — current design wins, `ADR-0022`)

Retired (concept-only): FreeRADIUS → NPS (`ADR-0029`) · OpenSSL Lab CA → AD CS (`ADR-0031`) · Pi01 DoH (`ADR-0009`) · untagged-`vmbr0` → tagged. Still live: R410/PVE01 · SW01 · MKT01 · FGT01 · the CMOS/RTC fault (`CM-0012`). Full detail: the reconciliation & gap map.

## The rules (estate-wide)

- **Docs-only.** No git/device/AD commands — write files + **print a PowerShell commit block** for Seth (repo root `C:\Users\atlas\Atlas\Atlas-Engineering-Repository`). Never `git add .` (`CM-0014`); LF endings; `gitleaks` clean.
- **`POL-0001`/`POL-0006`** evidence — no ✅ without a runtime read-back; authored = 🟡; planned = 📋.
- **`POL-0002`** — never a live secret. **`POL-0004`/`POL-0008`** — one home per fact; link down.
- **`ADR-0049`** — ask at planning (esp. the open design ideas above) · one piece at a time · refresh `SESSION-HANDOFF` after each · newer wins.

## Deferred (tracked in the backlog, not this brief's page-work)

- **#33** new-Linux-server + Pi-hole per-service commissioning checklists · **#34** syslog+SNMP as Academy tools (MON01) · **#35** services layer + connectivity testing · **#32 integration half** (Jira ↔ Confluence — capture-only until there's a body of playbook material, which this project is producing).

---

*When a Playbook is done: tick its worksheet row, add it to the Playbooks index, wire any checklist cross-link + the reconciliation map, refresh `SESSION-HANDOFF`, print the commit block — then stop for review. `#32` is the north star: descriptive, searchable, ticket-ready, offline; `#37`: gap-aware. Page by page.*
