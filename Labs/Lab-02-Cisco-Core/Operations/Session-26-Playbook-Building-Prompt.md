> ✅ **SUPERSEDED 2026-08-01 (`ADR-0012`).** This brief's goal — **set up the project, build the golden template, and lock the mold** — is **DONE**: `Atlas-Academy/Playbooks/Read-the-Cert-Not-the-Sign-Log.md` (from `MC-0002`) is the golden reference and `ADR-0053` §5 now carries the confirmed shape (command-first · point-to-the-fix · explain-the-mechanism · one-error-per-bullet · On-this-page · per-step provenance · Worked-example→CM). **Continue from `Session-27-Playbook-Alignment-and-Pre-Push-Prompt.md`** (the alignment register + the mining-queue remainder + the observability seeds + the pre-public-push polish). Kept for history.

# The Lab-01 Playbook Project — Next-Session Brief (v2, prioritized)

*(Lab-02-Cisco-Core / Atlas Academy. **Docs-only** session. Paste this into the next bot as the task brief. Written 2026-07-31. **Supersedes `Session-25-Playbook-Building-Prompt.md`** — retired with a ✅ SUPERSEDED banner, `ADR-0012`. Runs across **several sessions, one page at a time.**)*

---

## What this is

Turn frozen **Lab-01**'s real, **device-verified** incidents (its docs were *made at the machine* — the fixes are proven) into a library of **tested, very granular, searchable** Playbooks — *"so I wouldn't have to ask the same question the 2nd or 3rd time."* Much of Lab-01 is the same hardware + discipline as Lab-02 (SW01 · MKT01 · FGT01 · PVE01 · the Pi), so a reconciled lesson carries into Lab-02 **and the next lab.**

---

## 🔴 RECOMMENDED ORDER — do these first, in this order

**0. Read the setup (before anything).**
   1. `Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md` — the `📍 CURRENT STATE` block + the latest session block (`ADR-0049`).
   2. **This brief** (the principles + the per-Playbook shape below).
   3. `Atlas-Academy/Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md` — 🆕 what each machine was, where its services split, gaps closed vs still-open. **Reconcile every incident here.**
   4. `00-Atlas-Foundation/Decisions/ADR-0053` §5 — the Playbook template (now: **Symptoms & search terms** required · **Gap / what this closes** optional).
   5. `Labs/Lab-02-Cisco-Core/Operations/Lab-01-Playbook-Mining-Candidates.md` — the #36 queue (§4 order · §5 library · §2 reconcile · §3 themes).

**1. Housekeeping (quick — do it first, it's overdue).**
   - **Archive the oldest `SESSION-HANDOFF` blocks** — it's ~120 KB; past ~8 blocks / ~80 KB, move the oldest to `99-Archive/` leaving a pointer (`ADR-0049`). A fresh bot shouldn't wade through 120 KB.
   - Note any **still-pending prior commits** (`git status` will show them) so nothing is lost.

**2. Plan with the operator (`ADR-0049` — ASK before building; these shape the format).**
   - **The golden template:** is it **`MC-0002`** (MikroTik cert reissuance + CA fix — the operator's pick)? What filename / problem-name? *(See step 3.)*
   - **The `CM-0023` link** for the MikroTik service-ACL step — which record did the operator mean? *(The `CM-0023` spawned by `CM-0022` is the **SW01 SNMP-community rotation**, not a MikroTik service-ACL record; the step is currently linked to the `Firewall-Per-Rule-Verification-Tests` §2 callout with a 🟡 to-confirm.)*
   - **The "mentality vs machine-steps" split:** do the recurring disciplines (§3 themes) become **`Concepts/`** pages (the *troubleshooting mentality* layer), separate from the per-appliance/device *machine-specific steps*? Confirm the split + where the mentality layer lives.
   - **The Command-Library Linux shape:** the real `show`/read commands harvested from the seam — a **section in `Command-Library/Linux.md`** or a **`Command-Library/Linux/` folder**, organized **by service role** (per service: role + `show` commands, mirroring the Lab-01 `PI01/Roles/` model)? The 3-click rule / `ADR-0053` review-trigger decides when a section must become a folder.

**3. Build the GOLDEN TEMPLATE first — from a real Lab-01 machine resolution (`MC-0002`, if confirmed).**
   - **Why first:** it sets *how every later Playbook is made.* Get the shape right on a real, device-verified fix before mass-producing. (Operator: *"we'll make another golden template from the actual lab01 machines and what was done to resolve an issue."*)
   - Anchor: [`Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`](../../Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md) — cert renamed on import · stale SAN (`10.0.0.1` vs the live IP) · chain/bundle · `get`-not-`show`.
   - Reconcile OpenSSL-CA → **AD CS** (`ADR-0031`); the *read-the-cert-not-the-issuance-log / reissue-with-a-correct-SAN* discipline is fully current (worksheet §5 `Reissue-a-Certificate-With-a-Correct-SAN`).
   - Apply **every** format element (so it's the reference): **On-this-page index · Symptoms & search terms · granular a/b/c steps with the real `show` commands · per-step provenance links to `MC-0002` · a "Worked example → the CM doc" section · 📸 screenshot markers · the optional Gap note.**

**4. Then build page-by-page — ONE page, reviewed, then stop (never bulk).**
   - §4 queue **rows 7–10:** `Rotate-a-Leaked-Key-Before-You-Back-It-Up` (`CM-0010`) · `Reconcile-a-Build-Guide-That-Rebuilds-a-Broken-Device` (`CM-0022`) · `Verify-an-Edit-by-Counting-the-Old-Text` (`CM-0021`/`CM-0026`) · `Trace-Three-Symptoms-to-a-Dead-CMOS-Battery` (PVE01/`CM-0012`).
   - Plus, as the operator directs: more MikroTik/Lab-01 firewall · the §3 themes → `Concepts/` (mentality) · the **Command-Library Linux `show`-command harvest.**

---

## 🔑 Locked principles (every Playbook)

1. **Device-verified-first.** Anchor to a real Lab-01 incident (`CM-####` / device `Troubleshooting` / `016` / the firewall test docs); reconcile to today (`ADR-0022`). A proven fix beats a plausible one.
2. **Very granular — real `show` commands foregrounded.** Down to the exact command, the exact read-back (Healthy vs Broken on their own lines), the exact decision point. Lean on the device-specific `show`/`get`/`print`/`systemctl`/`ss`/`journalctl` reads that reveal real state. *(Operator: "the playbooks can get really specific" · "show commands need to be in there more.")*
3. **Searchable + ticket-ready (`#32`).** Filename = the problem in plain words = the ticket title. The required **Symptoms & search terms** element (verbatim errors · plain phrases · aliases · keywords).
4. **One page at a time, reviewed.** *"Large bulks get me in trouble."* Build one, refresh the handoff, print the commit block, stop.
5. **Gap-aware (`#37`).** Where an incident exposed a structural gap, add the optional **Gap / what this closes** note (design gap closed vs still-open; security-vuln angle); link the reconciliation & gap map. A gap is "closed" only when the mitigation is device-verified running (`POL-0001`).
6. **Screenshots belong in it (📸, SS-001).** A 📸 marker at each read-back that *proves* the answer (healthy vs broken), stored in an `images/` subfolder — real captures, never pre-fabricated, never a live secret (`POL-0002`).

## The per-Playbook shape (`ADR-0053` §5, extend the template)

**Frontmatter** (`#32`-anchored) · **provenance** · **one-line problem** · **Symptoms & search terms** · **On this page** (a short numbered quick-nav — sections + a multi-cause page's causes→fix) · **Cert anchor** · **Grounded in** (the real Lab-01 anchor, reconciled) · **① Pin it down** · **the diagnosis path** (very granular a/b/c; command · reference · Healthy · Broken each on its own line; **📸** at each proof; **per-step provenance links** to the doc that proved that step) · **the fix (+ prove it)** · **If still broken** · **Gap / what this closes** *(optional)* · **Worked example** *(where a clean Lab-01 case exists — walk the real incident, quote the real read-backs, **link to the `CM-####` doc**)* · **Related** (link down to `../Command-Library/`; siblings; `#32`; the checklist cross-link `ADR-0053` §8; the reconciliation map) · **Worked log** · **Change Log**.

- **Link down, don't restate** (`POL-0008`) — the Command-Library owns commands; the device page owns facts; the CM doc owns the incident.
- **Never invent output** (`POL-0001`) — 🟡 until a real read-back is pasted. **Verify every link resolves** before committing (CI link-check); don't guess a `CM-####` citation.
- **Add each new leaf to `Atlas-Academy/Playbooks/README.md`**; keep the 3-click rule.

> **Note (`ADR-0053` §5 candidates):** the **"On this page" index**, the **per-step provenance links**, and the **Worked example → the CM doc** are demonstrated (on `MikroTik-EastWest-Inspect-and-Troubleshoot` and `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched`) but not yet *formalized* into `ADR-0053` §5. Once the operator confirms their form (step 2), amend §5 + bump the `ADR-Index`.

## Reconcile rules (`ADR-0022` — current design wins)

Retired (concept-only): FreeRADIUS → NPS (`ADR-0029`) · OpenSSL Lab CA → AD CS (`ADR-0031`) · Pi01 DoH (`ADR-0009`) · untagged-`vmbr0` → tagged. Still live: R410/PVE01 · SW01 · MKT01 · FGT01 · the CMOS/RTC fault (`CM-0012`). Full detail: the reconciliation & gap map.

## House rules

- **Docs-only.** No git/device/AD commands — write files + **print a PowerShell commit block** for Seth (repo root `C:\Users\atlas\Atlas\Atlas-Engineering-Repository`). Never `git add .` (`CM-0014`); LF endings; `gitleaks` clean.
- **`POL-0001`/`POL-0006`** evidence — no ✅ without a runtime read-back; authored = 🟡; planned = 📋. **`POL-0002`** — never a live secret. **`POL-0004`/`POL-0008`** — one home per fact; link down.
- **`ADR-0049`** — ask at planning (step 2) · one piece at a time · refresh `SESSION-HANDOFF` after each page · newer wins.

## Already done (don't redo)

**Seventeen Playbooks written** (all 🟡): the six #36 rows 1–6 (DAI silent-drop · confirm-change-took · enumerate-interfaces · OOB-router-recovery · bare-metal-teardown · committed-secret) + the MikroTik firewall set (E-W-inspect · prove-which-rule · remove-a-dead-rule) + the earlier eight (DNS-outage · Domain-Join · Trace-a-Blocked-Flow · Port-Already-In-Use · Test-a-Connection · journalctl · Fix-SW01-Clock · Proxmox-Inspect). `ADR-0053` §5 carries **Symptoms & search terms** (`#32`) + **Gap** (`#37`). The **reconciliation & gap map** is built. AI-Context routes through Lab-01 (`Pointers` · `What-To-Check-First` · `Directory-Map`).

## Deferred (backlog, not this brief's page-work)

**#33** new-Linux-server + Pi-hole per-service commissioning checklists · **#34** syslog+SNMP as Academy tools (MON01) · **#35** services layer + connectivity testing · **#32 integration half** (Jira ↔ Confluence — capture-only until there's a body of playbook material, which this project is producing).

---

*Each page: anchor to the real Lab-01 incident → reconcile (`ADR-0022`) → build in the shape above (granular, `show`-heavy, indexed, gap-aware, worked-example-with-CM-link, 📸) → add to the Playbooks index → tick the worksheet row → refresh `SESSION-HANDOFF` → print the commit block → **stop for review.** North stars: `#32` (searchable, ticket-ready, offline) · `#37` (gap-aware) · device-verified, page by page.*
