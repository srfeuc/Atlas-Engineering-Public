---
Title: Playbook — Remove a MikroTik Firewall Rule That Has Never Matched (prove it's dead first)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on MKT01. Grounded in the real frozen **Lab-01** `CM-0009`, current-design-reconciled (`ADR-0022`; the RADIUS specifics move to NPS `ADR-0029`, the discipline is unchanged). Searchable/ticket-ready per Backlog **#32**.
Version: 1.1
Date: 2026-08-02
---

# Playbook — Remove a MikroTik Firewall Rule That Has Never Matched

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: firewall hygiene / change. **You've found a firewall rule with no documented purpose, or a permit whose counter never moves — is it safe to delete?** Not until you've *proven it's dead*: a zero counter **and** an understanding of why (it's off the device's actual traffic path, or points at a stale address). Then remove it **by comment, never by index**, keep the catch-all drops last, and verify the new count off the device. A firewall rule requires a documented purpose; one that matches nothing and explains nothing is debris — but "looks unused" is a guess until the counter and the path agree.

**Why this earns a playbook (Backlog `#32`).** In frozen Lab-01, three documents gave MKT01's rule count as 22, 23, and 24; the device said **24**. Reading the rules revealed **two had never done anything at all** — they pointed at Pi01's *pre-VLAN* address (`10.0.0.5`) on a path (FGT01→Pi01, same subnet, Layer-2 adjacent via SW01) that **never entered MKT01's forward chain** (`CM-0009`). They were fossils that survived only because nothing depended on them. No amount of document-reading found that — reading the *device* did (Charter Rule 13). This is the *prove-it-before-you-touch-it* procedure so you don't delete a live rule or keep a dead one.

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **why "unused" is a guess until proven** — the two independent ways a rule is dead (wrong address / off-path).
3. **① Pin it down** — the rule + counter, its claimed purpose, the real traffic path, a falsifiable rollback trigger.
4. **The diagnosis path** — prove it's dead two ways (zero counter *and* off-path), then rule out shadowing.
5. **The fix** (remove by comment, never by index; keep the catch-all drops last) · **Prove it's done** · **If still broken**.
6. **Worked example → `CM-0009`** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- a rule comment referencing a stale/old address (a pre-VLAN `10.0.0.x`) or a device that moved.
- 🟡 (real read-backs land on-device): `/ip firewall filter print stats` shows a permit with a **zero** packet/byte counter.
- three docs disagreeing on the rule count while `/ip firewall filter print count-only` gives one number.

**Plain-language symptom phrases**

- "is this firewall rule doing anything / can I delete it?"
- "this rule's counter is zero — is it safe to remove?"
- "a rule points at an old IP / a device that isn't there anymore."
- "the docs disagree on how many firewall rules there are."
- "clean up dead / obsolete / fossil firewall rules."
- "prove a rule is dead before removing it."

**Aliases / also-known-as**

- dead firewall rule · obsolete rule · fossil rule · never-matched rule · zero-counter rule · stale pre-VLAN rule · orphaned rule.
- rule requires a documented purpose · remove by comment not index · rule-count reconciliation · off-path traffic · Charter Rule 13 (device wins).
- falsifiable removal · rollback trigger · keep the catch-all drops last.

**Keywords line**

`MKT01` · `/ip firewall filter print stats` · zero counter · `/ip firewall filter print count-only` · `remove [find comment="..."]` · not-by-index · `CM-0009` · pre-VLAN `10.0.0.5` · off-path · `NET-005` documented-purpose · `/export` backup · rollback · catch-all drop last · `016`/Rule 13.

## Cert anchor

- CompTIA **ITIL / change management** (a change needs a purpose, a test, and a rollback) — the primary anchor.
- **MTCNA / CCNP Security** (firewall rule lifecycle), CompTIA **Security+** (least-privilege, config hygiene).
- *(Grounding index: `../Atlas-Certification-Lab-Map.md` + the change-management discipline in `POL-0003`.)*

## Grounded in — why "unused" is a guess until proven

Know the two independent ways a rule can be dead (`POL-0008` — the device page + the flows matrix own the rules; this page links):

- **Wrong address** — the rule matches a host that no longer has that IP (a pre-VLAN `10.0.0.x` fossil). It matches nothing.
- **Wrong device / off-path** — even with a corrected address it would do nothing, because the traffic it describes **never traverses this router**. The Lab-01 case: FGT01→Pi01 RADIUS is same-subnet, Layer-2 adjacent via SW01 (FGT01 → SW01 → Pi01) — it never enters MKT01's forward chain, so MKT01 rules for it were always inert.
- **The proof is the device, not the docs** — three docs said 22/23/24; the device said 24; the counters + the path said two were dead (Charter Rule 13, `016`). A rule's *counter* plus *where the traffic actually flows* is the evidence; a doc's rule list is a claim.
- **Reconciliation (`ADR-0022`):** the Lab-01 rules were RADIUS return-path rules; in Lab-02 RADIUS moves to **NPS** (`ADR-0029`), so those exact rules don't exist — but the discipline (prove-dead-by-counter-and-path, remove-by-comment, keep-catch-alls-last, verify-the-count) is identical and carries across labs. It's a rule *requires a documented purpose* (`NET-005`-style); one without a purpose *and* a live counter is a deletion candidate, not an automatic delete.

Command detail (link down — `POL-0008`): `../Command-Library/RouterOS.md` §Firewall (`print stats`, `print count-only`, `connection print`) + §Logging/backup (`/export`). Why-it-works: `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md`.

## ① Pin it down (capture these first — they're the ticket)

- a. **The rule** — its comment, its match tuple (`in`/`out`/proto/port/address), and its **current counter** (`print stats`).
- b. **Its claimed purpose** — what does the comment/doc say it's for? Does an owner doc (the flows matrix) reference it?
- c. **The real path of that traffic** — does the flow it describes actually traverse MKT01, or is it same-subnet / handled elsewhere (SW01, FGT01)? Draw the path.
- d. **A falsifiable rollback trigger** — "if I remove this and *X* breaks, my analysis was wrong." Name *X* (the thing that would prove the rule was live after all) before you touch anything.
- e. **Backup + recovery ready** — an `/export` pulled off the device; a way back in if you're wrong (`Recover-a-Locked-Out-Router-Out-of-Band.md`).

## The diagnosis path — prove it's dead, two independent ways

Read `print stats`/`print detail`, never plain `print` (`016`).

**1. Is the counter zero — over a meaningful window?**

- a. `/ip firewall filter print stats` — read the rule's packet/byte counter.
  - Reference: `../Command-Library/RouterOS.md` §Firewall.
  - Zero is a signal, not a verdict — a rule that matches rare traffic can be zero *now*. Let it run, or reset counters and exercise the flow it claims to carry.
- b. If the flow it claims to carry is exercisable, run it and re-read: a still-zero counter after the traffic that *should* hit it means the rule isn't on that path.

**2. Does the traffic it describes even traverse this router?**

- a. Trace the real path of the flow (source → dest): is it inter-VLAN (through MKT01) or same-subnet / handled by SW01 or FGT01?
- b. Confirm the addressing is current — a rule matching a **pre-VLAN** address (`10.0.0.x` where the host is now `10.<vlan>.0.x`) matches nothing.
- c. Cross-check the far end: e.g. if a host's own firewall shows the traffic arriving from a *same-subnet* source, this router was never in the path.
- → A rule is provably dead when the counter is zero **and** the path analysis explains why. Either alone is weaker; together they're conclusive.

**3. Confirm it isn't shadowed (a different reason for a zero counter).**

- a. A permit can read zero because an **earlier** rule already matched (first-match-wins), not because it's dead. Check nothing above it claims the same tuple — if it's shadowed, the fix is re-ordering, not removal (`MikroTik-EastWest-Inspect-and-Troubleshoot.md`).

## The fix — remove it safely and falsifiably

- a. **Back up first:** `/export hide-sensitive file=mkt01-pre-<change>` and **pull it off the device** (a backup on the box you might lock yourself out of isn't a backup).
- b. **Remove by comment, never by index** (indices shift as rules change):
  - `/ip firewall filter remove [find comment="<the exact comment>"]`
- c. 🔴 **Confirm the catch-all drops survive and stay last** — `EAST-WEST-DENIED` last in forward, `INPUT-DENIED` last in input. Never let a removal expose the chain's default-ACCEPT.
- d. **Verify the count read-back:** `/ip firewall filter print count-only` = the expected new number (e.g. 24 → 22). The device's number is the evidence, not the doc's.
- e. **Prove the rollback trigger didn't fire:** exercise *X* from Pin-it (d) — if the thing you predicted would break *doesn't* break, the analysis held; if it breaks, roll back immediately (`/import file=...`) and re-open the analysis.
- f. Record it as a change (`CM-####`) and update the owner (the flows matrix / Build-Record) — don't leave a doc describing a firewall that no longer exists (the `CM-0009` closeout defect).

## Prove it's done

- a. `/ip firewall filter print count-only` = the new expected count; `/ip firewall filter print` shows the rule gone, catch-all drops last.
- b. The rollback-trigger behaviour (*X*) still works — the removal changed nothing that mattered, exactly as predicted.
- c. The Build-Record / flows matrix updated to the real count (no doc left claiming the old number).
- d. 📸 the before/after count + the rollback-trigger still passing. Mark ✅ only with the pasted read-backs (`POL-0001`).

## If still broken

- The rollback trigger fired (the flow broke) → the rule *was* live; `/import` the backup, re-add it (corrected to current addressing if that was the issue), and re-analyse.
- The counter was zero because the rule is **shadowed**, not dead → re-order instead of removing (`MikroTik-EastWest-Inspect-and-Troubleshoot.md`).
- Removing it exposed the chain's default-ACCEPT (segmentation broke) → the catch-all drop wasn't last / was removed → restore it immediately.
- You're not sure the traffic bypasses MKT01 → prove it at packet level before deleting (`Prove-Exactly-Which-MikroTik-Rule-Acted.md` — mirror the position; if nothing ever hits it, it's dead).

## Worked example — the real Lab-01 case (`CM-0009`, device-verified 2026-07-13)

> This is the actual situation this Playbook is drawn from — the procedure carried out on the live MKT01. **Authoritative record: [`Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0009-Remove-Obsolete-MKT01-RADIUS-Rules.md`](../../Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0009-Remove-Obsolete-MKT01-RADIUS-Rules.md)** — the CM doc owns the incident; this walks it through the steps above. (Read-backs are quoted from the frozen record — `POL-0001`.)

- **① Pin it down.** Three docs disagreed on MKT01's rule count (22 / 23 / 24); the device said **24**. Two rules pointed at Pi01's **pre-VLAN** address (`10.0.0.5`) on a path MKT01 wasn't on. Rollback trigger named up front: *"if RADIUS breaks, the analysis was wrong."* → `CM-0009` §Purpose/§Reason.
- **Step 1 — counter zero.** The two rules (`;;; FortiGate ping to Pi-hole`, `;;; FortiGate RADIUS to Pi-hole`) had **never matched** — off-path fossils. → `CM-0009` §Reason.
- **Step 2 — path analysis.** FGT01 (`10.10.0.254`) → Pi01 (`10.10.0.5`) is **same-subnet, Layer-2 adjacent via SW01** — it never enters MKT01's forward chain. Confirmed by Pi01's own UFW rule (same-subnet source). → `CM-0009` §Reason.
- **The fix — remove by comment.** `/ip firewall filter remove [find comment="FortiGate ping to Pi-hole"]` (and the RADIUS one). Backup `/export hide-sensitive file=mkt01-pre-CM-0009` pulled off-device first. → `CM-0009` §Implementation.
- **Prove it.** `/ip firewall filter print count-only` → **`22`** (was 24); both catch-all drops still last (`EAST-WEST-DENIED` rule 20, `INPUT-DENIED` rule 21). **Rollback trigger held:** FGT01 → Pi01 RADIUS re-tested end-to-end → **`Access-Accept`**. → `CM-0009` §Validation/§Closeout.
- **Gap / what this closed.** A firewall rule with no documented purpose (`NET-005`) — a small attack-surface + audit-integrity gap — removed, and the rule-count docs reconciled to the device. *(Reconcile: the RADIUS flow itself moves to NPS in Lab-02, `ADR-0029`; the prove-dead discipline is unchanged.)*

## Related

- **Command-Library:** `../Command-Library/RouterOS.md` (§Firewall — stats/count/connections · §Logging/backup — `/export`).
- **Concepts:** `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` (how a rule matches — why an off-path rule is inert).
- **Owners:** `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` (the allowed-flows owner) · `Devices/MKT01-East-West-Firewall/` (the live rule set + Build-Record).
- **Sibling playbooks:** `MikroTik-EastWest-Inspect-and-Troubleshoot.md` (find/read the rules) · `Prove-Exactly-Which-MikroTik-Rule-Acted.md` (mirror a position to prove nothing hits it) · `Confirm-a-Config-Change-Actually-Took.md` (read the new count back) · `Recover-a-Locked-Out-Router-Out-of-Band.md` (if a change bites).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).
- **Real lineage:** frozen Lab-01 `Devices/MKT01-Core-Router/Changes/CM-0009` (two pre-VLAN RADIUS rules that had never matched — removed by comment, count read back 24→22, RADIUS rollback trigger confirmed unbroken) · `016` (read the device, not the doc — Rule 13) — `ADR-0022`-reconciled (RADIUS → NPS `ADR-0029`; the discipline unchanged).

## Worked log

| Date | Who | Time | Rule removed | Proven dead (counter + path)? | Rollback trigger held? | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-08-02 | **Format-alignment (audit register row 4):** added the **On this page** quick-nav — the one locked-mold element this leaf was missing; otherwise already at the mold (command-first, per-step `CM-0009` provenance, Worked example → the CM, Gap note). DOCS-ONLY complete; 🟡→✅ still waits on a real MKT01 run. |
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the `#32` "Symptoms & search terms" element). Prove a firewall rule is dead before removing it — a zero counter **and** a path analysis showing why (off-path / stale address), not one alone; remove by comment not index; keep the catch-all drops last; verify the count read-back; name a falsifiable rollback trigger. Grounded in the frozen Lab-01 `CM-0009` (two pre-VLAN RADIUS fossils on a path MKT01 wasn't part of; device said 24, two were dead). Reconciled (`ADR-0022`): the RADIUS specifics move to NPS (`ADR-0029`), the prove-dead discipline is unchanged and common across labs. 🟡 until worked on MKT01. |
