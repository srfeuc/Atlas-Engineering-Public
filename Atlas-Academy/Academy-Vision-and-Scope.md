---
Title: Atlas Academy — Vision & Scope
Path: Atlas-Academy
Status: 🟢 LIVING vision/scope doc — the front door for what the Academy is *for*. Adopted as the estate's knowledge source-of-truth (operator, 2026-07-31, expanding `ADR-0032` D6). **How Academy docs are made + navigated = `ADR-0053` (the Academy Documentation Standard).** Backlog **#31(c)** / **#30** own the build.
Version: 0.4
Date: 2026-08-05
---

# Atlas Academy — Vision & Scope

> **What this doc is.** The Academy's front door: *what it's for, what belongs in it, and how it's organized* — so any session (human or AI) knows where a new command, `show`-example, or troubleshooting playbook goes without guessing. It is the scope; the modules under `Concepts/`, `Command-Library/`, and the cert-maps are the content. Backlog **#31** (the AI-context "Claude" folder + Academy development) and **#30** (Academy currency + cert-path pass) own the build work; this doc holds the target.

## The vision (operator, 2026-07-31)

**Atlas Academy is the estate's single source of truth for knowledge.** Not only a certification track — a **living operational knowledge base** for the whole estate. It answers the question no other doc-type answers: Build Guides say *how I built this*, Labs say *can I demonstrate this skill*, device pages say *what this device's facts are* — the Academy says **"why does this work the way it does, how do I operate and troubleshoot it, and how does it fit with everything else."**

This expands the original `ADR-0032` D6 adoption (Academy = the "why it works" concept layer + the command library) with an explicit **operational** half: the commands that change things, the `show`/read commands that reveal how our real devices are configured, and the scenario-driven playbooks for when something breaks.

## The design principle (unchanged — the thing that makes it Atlas's)

**Every Academy entry references a real Atlas artifact by name.** "How VLANs work" is a generic tutorial that exists a thousand times online. "How VLANs work, using SW01's actual `Gi1/0/1` trunk and MKT01's actual `bridge-trunk` interface" is something only Atlas has — and it's the version that sticks, and the version that's defensible in an interview. The `show`-command examples show *our* devices' real config; the troubleshooting uses *our* topology; the failure runbooks name *our* devices.

**The ownership boundary (`POL-0008`).** The Academy does not duplicate a device's authoritative facts — those live on the device page (`Build-Record.md` / `Diagnostics.md` / `Troubleshooting.md`). The Academy is the **cross-device teaching + operational-knowledge layer** that *links to* those facts and explains the reasoning, the patterns, and the cross-device scenarios a single device page can't. When in doubt: a fact about one device → that device's page; a concept, a command pattern, or a scenario that spans devices → the Academy.

## The briefcase principle — offline · shareable · searchable by problem (operator, 2026-07-31)

The Academy is meant to be a **standalone operational briefcase** — the go-to reference *when AI is not available*, not just study material. That puts five hard requirements on the operational-knowledge layer:

- **Offline-first.** The knowledge is plain Markdown in the repo (and its Confluence copy), fully usable with **no AI and no internet**. Nothing load-bearing depends on a running assistant.
- **Shareable.** Each entry is a self-contained page a colleague — or a ticket — can be pointed at directly.
- **Searchable by problem name.** Problems are found by the *name you'd type into a search box or a ticket title* ("port already in use", "trace a blocked flow"). **Filenames and headings are the problem names**, so the right page is one search away.
- **Kept current by use.** Every time a troubleshooting method is actually used, it is captured/updated here — the library grows from **real incidents**, not a one-time authoring pass (`POL-0006`: the real commands + output that worked).
- **Ticket-ready.** Because problems are named and self-contained, the library maps **1:1 onto a ticket queue** (a problem page ↔ a ticket type). A free ticketing system (Jira free tier) linked to the Confluence copy is a **future capability — backlog `#32`**; the knowledge is structured for it now, not retrofitted later.

## What lives here (scope)

The Academy has **five layers** today — the original three below (Concepts · Command-Library · cert-maps), the operational **Playbooks** layer this vision added (layer 4), and the per-domain **`Directory/`** layer (layer 5, added since v0.3 — described below).

**1. Concepts — the "why it works" modules** (`Concepts/`). Short, focused modules, each teaching a real underlying concept through an already-built piece of Atlas. Format per module: *The Concept · The Atlas Example · What Went Wrong · How to Explain This in an Interview* (see `Atlas-Teaching-Patterns-and-House-Style.md`).

**2. Command-Library — the master command reference** (`Command-Library/`). Platform-first (`PowerShell-Tier0` · `Cisco-IOS` · `RouterOS` · `FortiOS` · `Linux` · `Syslog-and-SNMP`), cross-indexed by service + failure-category. Per-device `Diagnostics.md` quick-refs link **up** into it. **This is where the expanded vision's command content deepens** — see layer 4.

**3. Cert-mapping docs — the certification tracks.** `Atlas-Certification-Lab-Map` (CCNA) · `Atlas-CCNP-Lab-Map` (ENCOR+ENARSI) · `AZ-800-801` · `Atlas-FortiGate-FCP-Lab-Map` · `Atlas-Security-Plus-Domain5` · `CompTIA-Pre-Teardown-Exercise-Catalogue`. (Currency + gaps = backlog **#30**.) 🆕 **Since v0.3 the CCNA track gained a per-chapter *reverse index*** — `Certification/CCNA/Vol1/` + `Vol2/` (30 chapter pages), each mapping an exam-guide chapter to the Atlas artifact that demonstrates it (#44); and a **CompTIA Project+** map (`Atlas-CompTIA-Project-Plus-Lab-Map`) was added to the track list. 🆕 **A Linux track is being added — anchored to CompTIA Linux+** (operator, 2026-07-31), with the **LPI Linux Essentials** list (the operator's book) as the hands-on **seed** for the Linux section. **Cert-map structure comes from the operator's real exam-book TOCs** — Linux Essentials TOC provided; the **Linux+ track seeds from the O'Reilly CompTIA Linux+ guide** (operator, 2026-07-31 — TOC to come). The map is built from that TOC, anchored to real Atlas Linux hosts (Pi01 · SRV01 · NETBOX01 · BKP01). New track owner = **#30-E**.

**4. 🆕 Operational knowledge — the source-of-truth layer (the 2026-07-31 expansion).** The half that makes the Academy an operations knowledge base, not just a study aid:

- **Commands that *implement a change*** — the actual per-platform config commands, not just theory. "Here's the command that does it," per platform, anchored to a real Atlas change.
- **Tons of device-specific `show` / read commands** — commands that reveal *how each device we actually have is configured*, across **all** our devices: Cisco IOS `show …`, MikroTik `/… print`, FortiOS `get …` / `diagnose …`, Linux (`ip`, `ss`, `systemctl`, …), pfSense. Not a generic reference — the examples show *our* running config.
- **Scenario-driven troubleshooting playbooks:**
  - **Port conflicts** — how to check whether a port is already in use by a service on one device when another device needs that port, and **how to suggest/pick a different port**.
  - **Connection testing** — how to test connectivity end-to-end (ping / traceroute / `Test-NetConnection` / `nc` / curl) and **what each test actually proves**.
  - **Linux networking, deeply** — how to *read* the Linux networking commands and **all the ways to configure networking on a Linux (or any networking) device**, with worked examples + the **inspection commands that reveal every networking fact and service** (interfaces, routes, listening sockets, DNS, firewall state).
  - **Reading logs** — how to read **`journalctl`** (and syslog): units, filters, time windows, and what to look for.
  - **IPS / firewall dropped traffic** — what to do when the **IPS or firewall shuts down / blocks traffic**: what to check on a device when a connection is failing or is being **blocked**, and how to trace it to the responsible policy/rule.
- **Per-device firewall/appliance guides** — each with its own "how to inspect / how to troubleshoot a blocked flow" playbook:
  - **pfSense** (the inline IPS)
  - **FortiGate** (the perimeter UTM firewall)
  - **MikroTik** (the east-west firewall)
- **Failure-scenario runbooks — "what to do if one device goes down."** Per-scenario: what breaks, how you'd notice, what to check, how to recover or work around it. *(The operator's list was mid-thought when captured — the scenario taxonomy below is a starting set to complete together.)*

### Failure-scenario taxonomy — TO COMPLETE WITH THE OPERATOR

Candidate "one device goes down" scenarios (draft — confirm/extend with Seth):

- **Pi01 down** — DNS filtering + `atlas.lab` conditional-forward + chrony NTP go with it (single box, `ADR-0009`). What still resolves (AD-DNS on the DCs), what doesn't, and the recovery path.
- **A DC down** — Kerberos / GPO / DNS for domain machines; FSMO-role impact; RODC/second-DC behaviour.
- **The perimeter (FGT01) down** — egress + inbound + UTM; the `192.168.1.99` / console break-glass recovery path.
- **The east-west firewall (MKT01) down** — inter-VLAN routing + the E-W policy matrix; fail-open vs fail-closed.
- **A hypervisor down** — PVE01 (R410, mostly-off spin-up tenants) vs PVE02 (EQR6, always-on critical tier); which VMs are affected per the placement plan (#20).
- **A link / trunk down** — a trunk between SW01 and a device; native-VLAN / tagged-VLAN symptoms; STP behaviour.
- *(+ whatever else the operator wants — this list is deliberately open.)*

**5. 🆕 Directory — the per-domain exhaustive twins** (`Directory/`, added since v0.3). Nine per-domain pages, each the *exhaustive twin* of the Source-of-Truth router — the whole picture for one domain in a single page: `Servers-and-Compute` · `Network-and-Addressing` · `Security-and-Perimeter` · `Identity-and-Access` · `Backup-Recovery-and-Continuity` · `Monitoring-and-Logging` · `Governance-and-Decisions` · `Automation-and-IaC` · `Security-Program-and-Compliance`. The router is the quick tab; a Directory page is the full domain view. They **point, never restate** (`POL-0004`).

## What the Academy is *not*

- **Not a replacement for Build Guides** — those stay procedural and target-state.
- **Not a replacement for Labs** — those stay hands-on and gradeable.
- **Not a duplicate of device pages** — the device page owns its own facts (`POL-0008`); the Academy links up and explains across devices.
- **Not generic re-hosted study material** — every entry earns its place by referencing something real Atlas actually built or runs.

## How it's organized (where new content lands)

- A **concept** (why it works) → a module under `Concepts/` (index: `Concepts/README.md`).
- A **command** (change or `show`) → the matching platform file under `Command-Library/`, cross-indexed by service + failure-category.
- A **troubleshooting playbook / scenario** → a file in **`Atlas-Academy/Playbooks/`, named for the problem** — `Trace-a-Blocked-Flow.md`, `Port-Already-In-Use.md`, `Test-a-Connection.md`, `Read-the-Logs-with-journalctl.md`, … — plus a `Playbooks/README.md` index. **DONE (2026-07-31, `ADR-0053`):** the standard is written, the folder + index exist, and the first two real leaves (`Trace-a-Blocked-Flow`, `Port-Already-In-Use`) are in. Filenames = problem names → searchable + 1:1 to a ticket title (the briefcase principle). Write-when-real (`ADR-0049`). *(The "how do I do / automate a technique" set — **Runbooks** — is a **separate, deferred layer that arrives with the automation work**, `ADR-0048`; Playbooks are fix/operate only.)*
- A **per-appliance guide** (pfSense / FortiGate / MikroTik) → a `Playbooks/` doc (e.g. `FortiGate-Trace-a-Blocked-Flow.md`) that links into that device's own `Diagnostics.md`/`Troubleshooting.md` and the `FortiOS`/`RouterOS` command files (`POL-0008`).
- A **cert mapping** → the relevant cert lab-map; a **per-chapter reverse-index entry** (which Atlas artifact proves this exam objective) → the matching chapter page under `Certification/CCNA/Vol1|Vol2/`.
- A **whole-domain view** (the exhaustive twin of the router) → a page under `Directory/` (one per domain).

## Build status (was a "proposed sequence" in v0.3 — most of it is now built)

Updated 2026-08-05; statuses reflect the current tree. Still built in slices, each anchored to real Atlas artifacts.

1. **Linux section** — 🟡 partial. `Command-Library/Linux.md` is built and deepening; the **CompTIA Linux+ cert map** is **not yet** created (awaiting the O'Reilly Linux+ guide TOC). Anchored to real Atlas Linux hosts (Pi01 · SRV01 · NETBOX01 · BKP01).
2. **Per-appliance troubleshooting guides** — 🟡 mostly done. Built: `MikroTik-EastWest-Inspect-and-Troubleshoot`, `Proxmox-Inspect-and-Troubleshoot`, and the cross-appliance `Trace-a-Blocked-Flow`; a dedicated **pfSense** inspect/troubleshoot guide is the main remaining gap.
3. **Cross-cutting playbooks** — ✅ done. `Port-Already-In-Use`, `Test-a-Connection`, `Read-the-Logs-with-journalctl`, `Trace-It-in-the-Logs`, plus ~19 more — the `Playbooks/` layer now holds **23 leaves** (v0.3 had 2).
4. **Failure-scenario runbooks** — 🟡 in progress. Built: `Recover-from-a-DNS-Outage`, `Recover-a-Locked-Out-Router-Out-of-Band`, `Recover-the-Lab-from-a-Bare-Metal-Teardown`, `Diagnose-a-Host-Silently-Dropped-by-DAI`. The full "one device goes down" taxonomy above is still open to complete with the operator.
5. **README currency fix (#30-A)** — 📋 **still pending.** The Academy `README.md` "Proposed Curriculum" still names retired tech as its **primary** worked examples (OpenSSL Lab CA → now AD CS `ADR-0031`; FreeRADIUS → NPS `ADR-0029`; Pi01's `dnscrypt-proxy-doh` three-layer DoH → the reduced Pi-hole + chrony). Reconcile to the current build (keep the retired version as an explicit "v1 → v2 / road-not-taken" comparison where it teaches well).

> 🆕 **Built since v0.3 and beyond the original sequence:** the **`Directory/` layer** (9 per-domain router twins) and the **CCNA per-chapter reverse-index** (`Certification/CCNA/Vol1`+`Vol2`, 30 pages, #44) + the CompTIA Project+ map.

## Related

- **Backlog:** `00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md` — **#31** (AI-context "Claude" folder + Academy development; **#31(c)** is the source-of-truth vision this doc expands) · **#30** (Academy improvement + cert-paths — the README currency fix, the missing device×cert matrix) · **#19** (self-hosted git/CI — the home for runnable scripts) · **#28** (per-device `Considerations` cert-tracking cross-links) · **#16** (the estate device×cert matrix) · **#32** (the Academy as an offline briefcase + ticketing integration — Jira free tier / Confluence).
- **Governance:** `00-Atlas-Foundation/Decisions/ADR-0032` (Academy = command-library + concept layer) · `POL-0008` (fact ownership — device page vs Academy) · `POL-0006` (evidence) · `ADR-0049` (build one piece at a time).
- **Inside the Academy:** `README.md` (Book 9 overview) · `Atlas-Teaching-Patterns-and-House-Style.md` · `Command-Library/README.md` · `Concepts/README.md`.
- **Where the build is right now:** `Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md` (the living state owner, `ADR-0049`) — session prompts go stale, so this points at the handoff rather than a specific (now-superseded) session brief.

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.4 | 2026-08-05 | **Currency pass.** Reconciled the doc to the built Academy: added the **`Directory/` layer** (layer 5 — 9 per-domain router twins) and the **CCNA per-chapter reverse-index** (`Certification/CCNA/Vol1`+`Vol2`, 30 pages, #44) + the **CompTIA Project+** map; added `Syslog-and-SNMP` to the Command-Library list; converted the build "sequence" to **status-marked** (Playbooks 2→23 ✅; per-appliance + cross-cutting largely done; failure runbooks in progress; **#30-A README currency fix still pending 📋**); repointed the stale `Session-23` brief to the living `SESSION-HANDOFF`. Vision + principles unchanged. |
| 0.3 | 2026-07-31 | The Academy now has its **own documentation standard — `ADR-0053`** (the layers · the cert-grounded spine · the strict 3-click rule · the Playbook template). The **`Playbooks/`** action layer is built: index + the first two real leaves (`Trace-a-Blocked-Flow`, `Port-Already-In-Use`). Clarified (operator): **Playbooks now** (fix/operate); **Runbooks** (how-to/automate techniques — JSON/Python/PowerShell/IaC/Linux-CLI) are a **deferred sibling that arrives with the automation work** (`ADR-0048`). |
| 0.2 | 2026-07-31 | Added the **briefcase principle** (offline · shareable · searchable-by-problem-name · kept-current-by-use · ticket-ready — operator, from the "atlas acad delete" braindump). **Decided the operational-knowledge home:** a `Atlas-Academy/Playbooks/` folder **keyed by problem name** (searchable + 1:1 to ticket titles), replacing the "decide-later" open item. Added the **Linux cert track → CompTIA Linux+** (seeded by the LPI **Linux Essentials** list; the Linux+ map from the **O'Reilly Linux+ guide** TOC to come) anchored to real Atlas Linux hosts. Pointed to new backlog **#32** (offline briefcase + ticketing / Jira-Confluence integration). |
| 0.1 | 2026-07-31 | Created — the Academy front-door vision/scope doc. Captures the operator's 2026-07-31 expansion (Academy = the estate's source of truth for knowledge, not just certs): the operational-knowledge layer (change-commands · device-specific `show`/read commands · scenario troubleshooting playbooks · per-appliance guides for pfSense/FortiGate/MikroTik · "device down" failure runbooks), on top of the existing Concepts / Command-Library / cert-map layers. Draft failure-scenario taxonomy (to complete with the operator). Points to backlog #31(c)/#30/#19 for the build. |
