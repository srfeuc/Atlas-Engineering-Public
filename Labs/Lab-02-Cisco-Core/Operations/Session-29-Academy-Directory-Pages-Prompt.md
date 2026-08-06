---
Title: Session-29 — Academy Directory Pages (the per-domain "exhaustive twins" of the Source-of-Truth router)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: ✅ DONE 2026-08-03 (`ADR-0012` — retired with a banner, not deleted). All four per-domain Academy Directory pages built (Security · Identity · Backup · Monitoring) + wired to the Source-of-Truth router. Kept for history. (v1.1: +§0 cold-start orientation — read-order + the house-rules digest.)
Version: 1.1
Date: 2026-08-03
---

# Session-29 — Build the per-domain Academy Directory pages

> ✅ **DONE 2026-08-03 — retired, not deleted (`ADR-0012`).** All four per-domain Academy Directory pages are built and wired to the Source-of-Truth router: **[Security-and-Perimeter](../../../Atlas-Academy/Directory/Security-and-Perimeter.md)** (§1) · **[Identity-and-Access](../../../Atlas-Academy/Directory/Identity-and-Access.md)** (§2) · **[Backup-Recovery-and-Continuity](../../../Atlas-Academy/Directory/Backup-Recovery-and-Continuity.md)** (§5) · **[Monitoring-and-Logging](../../../Atlas-Academy/Directory/Monitoring-and-Logging.md)** (§6) — joining the pre-existing Servers (§4) · Network (§3). The router reached v0.9 (a 📖 Full directory callout per twinned section). **Don't build from this page — kept for history.**

> 🤖 **You are the next session.** The Source-of-Truth router (`00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md`, **v0.5**) is the fast tab — one glance, one link. This session builds its **exhaustive twins**: the per-domain **Directory pages** under `Atlas-Academy/Directory/` that hold the *whole picture* for a domain. Two already exist as the golden shape — **[`Network-and-Addressing.md`](../../../Atlas-Academy/Directory/Network-and-Addressing.md)** and **[`Servers-and-Compute.md`](../../../Atlas-Academy/Directory/Servers-and-Compute.md)**. Replicate that shape for the rest, one page at a time.

## 0. Orient yourself first (cold start)

> 📋 **This brief is meant to be pasted into a fresh bot as its task brief.** Do the read-order below before you touch anything — the estate reverses decisions often, so *where the build is right now* outranks any older doc.

**Read-order (do this first):**

1. **`00-Atlas-Foundation/AI-Context/README.md`** — the estate map + the house rules (digest below; the README + `What-To-Check-First.md` are the authority).
2. **[`SESSION-HANDOFF.md`](../SESSION-HANDOFF.md)** — the `📍 CURRENT STATE` block + the most recent session block, **in full** (`ADR-0049`). This is *where the build actually is*; nothing you do should contradict it without saying so.
3. **This brief** (§1–§7) — the task. It operationalizes Backlog **#41** — read that item in full too ([`Atlas-Improvement-Backlog.md`](../../../00-Atlas-Foundation/Roadmap/Atlas-Improvement-Backlog.md)).
4. **The golden shape** — [`Atlas-Academy/Directory/Servers-and-Compute.md`](../../../Atlas-Academy/Directory/Servers-and-Compute.md) + [`Network-and-Addressing.md`](../../../Atlas-Academy/Directory/Network-and-Addressing.md), and **`ADR-0053`** (the Academy doc standard). Copy their shape.

**The house rules, in one breath** (full text: `AI-Context/README.md`):

- **Docs-only · Seth runs git.** You *write files* and *print a PowerShell commit block* — you never run git, and never `git add .` (that is how `CM-0014` shipped a secret). LF endings. Repo root on his machine: `C:\Users\atlas\Atlas\Atlas-Engineering-Repository`.
- **Evidence over intent** (`POL-0001`/`POL-0006`) — a ✅ needs a command *and its output*; never upgrade a marker you can't prove. Markers: ✅ verified · 🟡 authored/unverified · 📋 planned · ⬜ gated · 🔴 blocker.
- **One home per fact; point, don't copy** (`POL-0004`/`POL-0008`) — a Directory page *links* the owner, it never restates a device's facts.
- **Newer usually wins** — on a conflict check the `Version`/`Date`; but the designated fact-owner beats a newer non-owner, and the **device beats every doc** (Charter Rule 13).
- **Never record a live secret** (`POL-0002`) — a dead value may be kept, named, as a lesson; a working one never.
- **Plan → ask at planning → one piece at a time → refresh the handoff after each** (`ADR-0049`); **preserve history** (`ADR-0012` — retire with a banner, never delete).
- **Bridge-down = say so loudly** (house rule 6) and keep drafts flowing via chat.

**You are here:** the governance reconciliation (#39) landed and the Source-of-Truth router is at **v0.5** (a 📚 Academy pointer per section). The next section is the per-domain Academy **Directory pages** — the router's exhaustive twins. Two exist (Servers, Network); build the rest.

---

## 1. The north star (say it back before you start)

> **Lean router (quick tab) → per-domain Academy encyclopedia (the whole picture).** Anyone in a situation finds the one-glance answer in the router, then clicks **📖 Full directory** to the Academy page when they want everything — every device, every doc, every decision, every real record for that domain. Fast, self-service, nothing lost.

This is the **findability payoff** of #41 (`AI-Context/Foundation-Restructure-Playbook.md` Phase 3), delivered as Academy pages governed by `ADR-0053`.

## 2. The batch order (one page at a time — refresh the handoff after each)

Build in this order (richest real-record seam first):

1. ⬜ **`Security-and-Perimeter.md`** — the twin of router **§1**. The richest seam: MKT01 east-west firewall, FGT01 FortiGuard UTM, pfSense inline IPS, the `CIS-Hardening-*` baselines, the allowed-flows matrix. Mine the **frozen Lab-01 MKT01 firewall records** (the `Firewall-*-Tests` docs + `CM-0009`) for the real "which rule dropped the flow" material.
2. ⬜ **`Identity-and-Access.md`** — the twin of router **§2**. AD tiered identity (`ADR-0021`), two-tier PKI (`ADR-0027`/`0031`), AAA/NPS (`ADR-0029`/`0028`/`0040`); the DC / PAW01 / RCA01-ICA01 / NPS01 device folders.
3. ⬜ **`Backup-Recovery-and-Continuity.md`** — the twin of router **§5**. BKP01, `POL-0005`/`POL-0013`, the `ADR-0011` Game-Day discipline; the recovery playbooks (DNS-outage, bare-metal-teardown).
4. ⬜ **`Monitoring-and-Logging.md`** — the twin of router **§6**. MON01 / SIEM01, `POL-0006`, the syslog/SNMP tooling (#34), the log-tracing playbooks.

**Optional / lower priority (decide with the operator):** `Automation-and-IaC.md` (§11) and `Security-Program.md` (§12) — thinner or Foundation-native. **No separate page** for router §7 (Make a change), §8 (Document), §9 (Governance), §10 (Troubleshooting/Academy) — those *are* the encyclopedia already (the Workflow, the Documentation Standard, the Governance Framework, the Playbooks index).

## 3. The golden shape to replicate

Open `Directory/Servers-and-Compute.md` and `Directory/Network-and-Addressing.md` and match them. Every Directory page has:

- **Frontmatter** — `Status: 🟢 Living — the exhaustive twin of the Source-of-Truth router's §N.` · `Version: 0.1`.
- **A lead blockquote** — "The deep version of [Source-of-Truth §N](...#n-...). The router gives you the one-glance answer; this page is the *encyclopedia*." + the standard page-set reminder (`ADR-0037`).
- **An `## On this page` numbered index** (house format).
- **Roster tables** — every device/host/appliance in the domain, its role, and its docs (link the device folders; don't restate their facts — `POL-0004`).
- **A placement / topology / rules section** — the owner docs (architecture, policies).
- **A "The decisions (ADRs)" section** — the governing ADRs, linked.
- **A "Templates and how-tos" section.**
- **A "Troubleshooting and the Academy" section** — the domain's Playbooks · Command-Library pages · Concepts · cert map.
- **Real records woven in** where the frozen Lab-01 seam has them (the `CM`/`MC` change-management goldmine — §1 especially).

## 4. Per-page recipe

For each page in the batch:

- [ ] Open the matching **router section** — it already lists the authoritative docs, the 🔧 playbooks, and the 📚 Academy line. That's your inventory seed.
- [ ] List the **real devices** for the domain (`Labs/Lab-02-Cisco-Core/Devices/`), the **owner docs** (`Architecture/`, `Policies/`), and the **governing ADRs**.
- [ ] Mine the **frozen Lab-01 incident seam** for this domain's real records (`Labs/Lab-01-Mikrotik-Core/` — device `Troubleshooting`, `CM-####`, `016`, the MKT01 firewall test docs). Reconcile to the current design — **frozen Lab-01 loses where it disagrees** (`ADR-0022`).
- [ ] Build the page in the **golden shape** (§3 above).
- [ ] Add the **`📖 Full directory` callout** to the router section (copy the §3/§4 pattern: a blockquote line right under the section's "Go here for:" intro). Bump the router `Version` + add a Change Log row.
- [ ] **Propagate + refresh** (see §5).

## 5. Propagation checklist (after each page)

- [ ] Router section wired to the new page (`📖 Full directory` callout) + router Change Log row + `Version` bump.
- [ ] `SESSION-HANDOFF.md` refreshed — `📍 CURRENT STATE` + a new session block (`ADR-0049`).
- [ ] Backlog **#41** ticked for the page (the per-domain-pages checklist).
- [ ] AI-Context `Directory-Map.md` — the `Atlas-Academy/Directory/` list updated.
- [ ] Verify on disk (`Select-String`/grep each file landed; every new link target exists).
- [ ] Commit block printed for Seth (docs-only; never `git add .`; LF).

## 6. Guardrails (house rules — do not skip)

- **Docs-only · Seth runs git.** Write files + a PowerShell commit block. Never run git; never `git add .`; LF endings.
- **One home per fact (`POL-0004`/`POL-0008`).** A Directory page **points**, it never restates a device's facts — link the owner.
- **Academy standard (`ADR-0053`).** These are Academy pages: 3-click rule, searchable, keyed to real artifacts.
- **Evidence markers (`POL-0001`/`POL-0006`).** ✅ verified · 🟡 authored/unverified · 📋 planned · ⬜ gated · 🔴 blocker. Never upgrade a marker you can't prove.
- **Preserve history (`ADR-0012`).** Frozen Lab-01 citations stay exactly as written.
- **One page at a time; refresh the handoff after each** (`ADR-0049`).

## 7. Done when

- [ ] The four core Directory pages exist (Security · Identity · Backup · Monitoring), each in the golden shape.
- [ ] Every router section that has a twin links to it (`📖 Full directory`).
- [ ] The handoff, backlog #41, and `Directory-Map` reflect the finished set.
- [ ] This prompt retired with a ✅ DONE banner (`ADR-0012`).

## Related

`00-Atlas-Foundation/Governance/Atlas-Source-of-Truth.md` (the router these twin) · `Atlas-Academy/Directory/Servers-and-Compute.md` + `Network-and-Addressing.md` (the golden shape) · `ADR-0053` (Academy doc standard) · `AI-Context/Foundation-Restructure-Playbook.md` (Phase 3 findability) · `AI-Context/Pointers.md` → "The Lab-01 incident seam" · Backlog **#41**.
