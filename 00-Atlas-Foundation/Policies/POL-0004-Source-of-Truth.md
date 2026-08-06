---
Title: POL-0004 — Source of Truth Policy
Path: 00-Atlas-Foundation/Policies
Status: ✅ Adopted 2026-08-03 under `ADR-0026`. In force.
Version: 2.0
---

# POL-0004 — Source of Truth

> **One fact. One home. Generated, not typed. And when the doc argues with the device — the device wins, every time.**

| Item | Value |
|---|---|
| Layer | **Policy** — a standing requirement |
| The rule, in one line | Exactly one source of truth per fact (target: **NetBox**), **generated not hand-typed**, and the **device outranks the document** (Charter Rule 13). |
| Owner | ⚪ Platform/DevOps (owns NetBox) · 🔴 Security audits it |
| Adopting decision | [`ADR-0026`](../Decisions/ADR-0026-Adopt-the-Atlas-Governance-Framework.md) (2026-08-03) |
| Builds on / near | [`POL-0008`](./POL-0008-Naming-and-Addressing.md) (the addressing/naming sibling) · [`POL-0014`](./POL-0014-Documentation-and-Knowledge-Management.md) (the *doc* version of one-home-per-fact) · Charter Rule 13 |
| Verified by | [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit — the checklist below |
| Framework mapping | NIST CSF 2.0 `ID.AM` · CIS Controls v8 **1 & 2** (Asset & Software Inventory) |

---

## 🔥 The hall of shame — why this policy exists

Every one of these was a hand-typed "source of truth" that quietly lied. This is the damage:

- **The host that vanished.** A 155-line Markdown table swore it was authoritative for every MAC and port. It listed **four** `STATIC-HOSTS` where **five** were required — **Pi01 was just missing**. SW01 dropped it silently (no DAI fallback), producing a phantom *"Pi01 should be unreachable"* mystery that **survived three handoffs.**
- **The server that doesn't exist.** SNMP pointed at `10.40.0.52` — **a host that was never built.**
- **The address from a past life.** RADIUS aimed at a **pre-VLAN** address that stopped being true the day the network was segmented.

> **The pattern:** *nearly every recurring Atlas defect is a source-of-truth failure.* A hand-maintained truth **will** drift — and you find out only when something breaks in a way that makes no sense.

---

## Scope & applicability

- Applies to **every fact about the estate**: devices, interfaces, MACs, IPs, VLANs, cables, ACLs, host placement, service ownership.
- Applies to **every artifact that asserts one**: NetBox, addressing plans, ACLs, configs, device pages, diagrams.
- **Boundary with [`POL-0008`](./POL-0008-Naming-and-Addressing.md):** POL-0008 owns *the addressing plan and naming convention* specifically. POL-0004 owns *the principle underneath* — one home, generated, device-wins — for **all** facts.
- **Boundary with [`POL-0014`](./POL-0014-Documentation-and-Knowledge-Management.md):** POL-0004 = the **data** truth (NetBox / the device). POL-0014 = the **documentation** truth (which *doc* owns which fact). Same DNA, different domain.

---

## The standing requirements

Four rules. Cite them as `POL-0004 R#`.

### R1 — One home per fact

- A fact lives in **exactly one place**. Everything else **links** to it — never restates it.
- Two homes is a **defect**, not redundancy. (The moment there are two, they start to drift — see the hall of shame.)
- Proven in practice by [`ADR-0034`](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md): PVE01's networking had *three* homes that drifted into conflict → collapsed to one. > *"PVE01's networking has exactly one authoritative home… every other home becomes a pointer to it."*
- And by [`ADR-0051`](../Decisions/ADR-0051-DNS-Filtering-Ownership-Pi-hole-Not-FortiGuard.md): DNS filtering has **one** owner (Pi-hole), not two. > *"There is exactly one place to ask 'why was this domain blocked' and one place to add an allow — no split-brain."*

### R2 — Generated, not typed

- The target source of truth is **NetBox** (IPAM/DCIM): devices, interfaces, MACs, IPs, VLANs, cables live there.
- Downstream artifacts are **rendered from it** — SW01's `STATIC-HOSTS` ACL, device configs via Ansible/Jinja.
- A **hand-typed** ACL or address table is a **violation** — it reintroduces the exact omission class NetBox exists to make impossible.
- The old `006` table doesn't get deleted — it **becomes a rendered export of NetBox.** Generated, never hand-edited.

### R3 — The device wins (Charter Rule 13)

- The source of truth states **intent**. The device states **reality**.
- When they disagree: **the device is right, the SoT is the defect.** Read the state back — don't argue with it.
- Fixing the doc to match the device is the job. Fixing the device to match a wrong doc is how you break production.

### R4 — States, not adjectives

- NetBox objects have **states**: `active` · `planned` · `decommissioned`.
- A Markdown table has **adjectives** like *"available"* — which is **not a state**, just a vibe that rots.
- If you can't query it, it isn't truth.

### R5 — Live owns, frozen points

- A fact's authoritative home lives in an **active** book.
- When a book **freezes**, its copy becomes a **pointer** to the live owner — **never a co-owner**.
- *Frozen* means "this snapshot won't change," not "read current truth here."
- **Absorbed from** [`ADR-0034`](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md) — this estate-wide principle was buried in a PVE01 fix; it's a rule now. > *"A fact's authoritative home is in an active book… when a book freezes, its copy… becomes a pointer to the live owner, never a co-owner."*

---

## Sources of truth — where each fact actually lives

The descriptive answer to R1. Go here for the fact; everywhere else should just link.

> ⚠️ **Navigational, not authoritative.** As NetBox comes online it becomes the generated owner of the data facts; until then the interim owners below hold. If any doc disagrees with the **device**, the device wins (R3).

| Kind of fact | Owner (today → target) | Notes |
|---|---|---|
| Device / interface / MAC / IP / VLAN / cable | interim `Architecture/IP-Addressing-Plan-VLSM` → **NetBox** | generated when NetBox lands |
| `STATIC-HOSTS` ACL · DHCP-snooping bindings | **rendered from NetBox** | never hand-typed (R2) |
| PVE01 verified networking state | the Book-2 Build-Record ([`ADR-0034`](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md)) | frozen Lab-01 copies are pointers |
| DNS filtering / blocklists / allowlists | **Pi-hole on Pi01** ([`ADR-0051`](../Decisions/ADR-0051-DNS-Filtering-Ownership-Pi-hole-Not-FortiGuard.md)) | single owner, no split-brain |
| Addresses + names (the plan) | [`POL-0008`](./POL-0008-Naming-and-Addressing.md) / `IP-Addressing-Plan-VLSM` | the addressing sibling |
| Host placement + VM sizing | `Service-Server-Build-Plan` (interim, #20) | |
| **What is actually true, right now** | 🔴 **the device itself** | Rule 13 — reality beats intent |

---

## Decisions governed by this policy

Every decision that carries `Governing Policy: POL-0004`. Follow a link for the decision; come back here for the rule.

<!-- BEGIN AUTOGEN:decisions POL-0004 · generated by tools/Build-Policy-Directories.ps1 — do not hand-edit -->
| Decision | Status | Governing Policy |
|---|---|---|
| [ADR-0034 — PVE01 Networking Config Has One Authoritative Home (the V…](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md) | Accepted (operator, 2026-07-28). Resolves the VIRTUALIZAT… | POL-0004 R5 |
| [ADR-0051 — DNS-Filtering Ownership: Pi-hole Owns It, FortiGuard DNS-…](../Decisions/ADR-0051-DNS-Filtering-Ownership-Pi-hole-Not-FortiGuard.md) | Accepted (operator, 2026-07-30) — recorded at the FGT01 #… | POL-0004 (+POL-0007) |
<!-- END AUTOGEN:decisions POL-0004 -->

> New single-owner / source-of-truth decision? Add its `Governing Policy: POL-0004` line, then re-run the builder — this directory rebuilds itself.

## The amendment model

- The **policy** holds the current rule; the **ADRs** are the dated trail of how it got there.
- Change a rule → an ADR **amends** it (`Governing Policy: POL-0004`, *"amends POL-0004 R#"*, + a Change Log row here).
- Never edit the rule silently. The higher layer wins; the lower one is the defect.
- **Absorbed (C):** [`ADR-0034`](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md)'s estate-wide principle became **R5**; the ADR stays as the PVE01 decision that adopted it — kept, never deleted (original in the legacy snapshot).

## Verification — prove it, don't assume it

The [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) audit runs this list:

- [ ] **R1** — no fact is authoritatively defined in two places (a moved fact resolves to one home).
- [ ] **R2** — deployed `STATIC-HOSTS` / DHCP-snooping data is **rendered from NetBox**; a diff against the live device is empty (or the delta is a tracked change).
- [ ] **R2** — no hand-typed ACL or address table competes with the generated one.
- [ ] **R3** — each device's facts in NetBox match the device on the wire; conflicts resolved **device-wins**.
- [ ] **R3** — Oxidized drift check (once deployed): config-vs-record drift is flagged; a drift is a finding.
- [ ] **Gap report** — anything in the SoT but **not** on the device (or on the device but **not** in the SoT) is surfaced, not assumed benign. *(Orphans are how attackers stay resident.)*
- [ ] **R4** — states, not adjectives: no `"available"` where an object state belongs.

## What a violation looks like

- A **second** authoritative table for the same fact.
- A **hand-typed** ACL or address list.
- A MAC / IP / port that exists **on a device but nowhere in the SoT** — or the reverse.
- A document **"corrected"** while the device it describes still says otherwise.
- `"available"` used where a **state** belongs.

## Related

[`Atlas-Governance-Framework.md`](../Governance/Atlas-Governance-Framework.md) · [`POL-0008`](./POL-0008-Naming-and-Addressing.md) · [`POL-0014`](./POL-0014-Documentation-and-Knowledge-Management.md) · [`POL-0001`](./POL-0001-Atlas-Audit-Policy.md) · `Atlas-Service-Architecture.md` Part 3 (NetBox) · Charter Rule 13 · [`ADR-0034`](../Decisions/ADR-0034-PVE01-Networking-Config-Ownership.md) · [`ADR-0051`](../Decisions/ADR-0051-DNS-Filtering-Ownership-Pi-hole-Not-FortiGuard.md).

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Proposed with the Governance Framework (`ADR-0026`). |
| 2.0 | 2026-08-03. Adopted under `ADR-0026`. Rewritten to the golden shape — punchy at-a-glance, the hall-of-shame, five citable rules (R1–R5), the Sources-of-truth table, and the generated Decisions directory. **Absorbed `ADR-0034`'s estate-wide "live owns / frozen points" principle into R5** (the ADR kept as the adopting decision). Directories generated · AI-Context to refresh · Backlog + SESSION-HANDOFF updated. |
