# ADR-0034 — PVE01 Networking Config Has One Authoritative Home (the Virtualization Build-Record)

| Item | Value |
|---|---|
| Status | **Accepted** (operator, 2026-07-28). Resolves the `VIRTUALIZATION-PACK-MANIFEST` **Blocking Freeze #2** ("PVE01 networking has three authoritative homes"). |
| Governing Policy | POL-0004 R5 |
| Scope | **Global** — the *principle* is estate-wide (an active book owns live config; a frozen book's copy becomes a pointer, never a co-owner); the *subject* is PVE01 (Lab-01 host, Lab-02-active). |
| Date | 2026-07-28 |
| Supersedes | No prior ADR. Reconciles the three competing PVE01-networking homes; captures Review-Flag-Register **C7** (F47) and closes the manifest's Freeze #2. |
| Related | `ADR-0022` (Book 1 frozen at `a03458f` — why the live owner can't be a Lab-01 doc), `ADR-0018` (silos/ownership), `ADR-0023` (Lab-02 topology), `ADR-0008` (Foundation holds process only; content belongs to its book), `POL-0008` (one source of truth per fact), `POL-0003` (each doc its own tracked change). |
| Evidence Status | **Decision** (operator, 2026-07-28). The authoritative record's *content* is device-grounded (`204-Proxmox-Networking` v1.2, device-verified 2026-07-24); the ownership/redirect is a documentation-governance decision, executed docs-only in this change. |

## Context

PVE01's networking (the `vmbr0` VLAN-aware bridge, the host management interface, the SW01 `Gi1/0/4` uplink, the VLAN tagging model) was documented in **three independent places**, and — worse than mere duplication — they had **drifted into conflict**:

- **`Labs/Lab-01-Mikrotik-Core/Devices/PVE01-Hypervisor/Build-Record-Network.md`** (v2.3, reconciled 2026-07-16) — a thorough *verified* record, but frozen at the **pre-2026-07-24 design**: `vmbr0` holding `10.10.0.10/**24**` **untagged**, relying on SW01 `Gi1/0/4`'s **native VLAN 10**. (Its sibling `Build-Guide-Network.md` is the procedure for that same older design.)
- **`Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides/204-Proxmox-Networking.md`** (v1.2, **device-verified 2026-07-24**) — the **current** design: host management **tagged** on **`vmbr0.10` = `10.10.0.10/27`**, bare `vmbr0` (no L3), `bridge-vids 10–90,999`, and SW01 `Gi1/0/4` **native VLAN → 999** (parking). This *supersedes* the Lab-01 design but the Lab-01 docs were never updated (Book 1 is **frozen**, `ADR-0022`).
- A **Confluence page** in the `Atlas 2.0` space (outside the repo).

No ownership decision was ever recorded — the manifest flagged this as **Freeze Blocker #2** and stated **neither book can freeze until it is settled.** A reader hitting the Lab-01 record today would build the wrong (old, `/24`, native-10-coupled) design.

## Decision

**PVE01's networking has exactly one authoritative home: a Build-Record in the active Virtualization book (Book 2) — `Labs/Lab-02-Cisco-Core/Virtualization/Build-Records/PVE01-Networking.md`. Every other home becomes a pointer to it.**

1. **The new Build-Record is the single source of truth (`POL-0008`)** for PVE01's verified networking state. Its content is the **current** device-verified design (`204` v1.2, 2026-07-24: tagged `vmbr0.10` `/27`, native 999, `bridge-vids`), consolidated with the still-true platform/interface/iDRAC/deviation facts from the Lab-01 record.
2. **`204-Proxmox-Networking.md` stays the build *procedure*** (target-state guide — how to apply it, the recovery-first order, the lessons) and **points to the Build-Record for verified state.** Guide vs Record per the pack's own taxonomy.
3. **The Lab-01 homes become pointers.** `Build-Record-Network.md` and `Build-Guide-Network.md` each get a one-line banner: *no longer the authoritative owner; live state lives in the Book-2 Build-Record.* They are **retained as the frozen historical Lab-01 snapshot** (the pre-07-24 design), not deleted (`ADR-0012` quarantine-not-delete spirit).
4. **The Confluence page** must be **manually redirected** to the Build-Record (out of repo scope — flagged, not executed here).

**Why Book 2 and not the Network book:** Book 1/Lab-01 is **frozen** (`ADR-0022`). Making a frozen doc the *live* owner means reopening a frozen book on every PVE01 networking change — the opposite of what a freeze is for. The Virtualization book is active and is where PVE01 (a virtualization host) is currently documented and built. So the **live owner sits in the active book; the frozen book keeps a pointer to a historical snapshot.**

## The estate-wide principle (why this is Scope: Global)

> **A fact's authoritative home is in an *active* book. When a book freezes, its copy of a still-changing fact becomes a *pointer* to the live owner, never a co-owner.** Frozen means "this snapshot won't change," not "this is where the world reads current truth." Any future frozen-book/active-book ownership collision resolves the same way.

## Alternatives Considered

- **Fold ownership into `204-Proxmox-Networking.md`** (make the guide the record). Rejected — conflates *procedure* (target-state guide) with *verified state* (record); the pack's taxonomy keeps those separate, and 204 already carries a mutable build procedure that shouldn't double as the SoT.
- **Keep the Network book (Lab-01) as owner.** Rejected — Book 1 is frozen (`ADR-0022`); a frozen doc can't be the live owner without a standing freeze-exception, and the Lab-01 copy is already the *stale* one.
- **Leave all three and just cross-link.** Rejected — that is the status quo that produced the conflict; `POL-0008` wants one home, not three linked ones.

## Consequences

- **Freeze Blocker #2 is resolved** — `VIRTUALIZATION-PACK-MANIFEST` updates it to ✅ and drops "Networking Build Record" from its missing-records list (it now exists).
- **A deliberate, bounded freeze-exception on Book 1:** two Lab-01 docs get a **navigation banner only** — no config/design content changes. This is the minimum needed to stop a reader trusting the stale owner; it does not reopen the frozen design.
- **Register C7** moves to ✅ (the freeze-blocking ownership call is made; the residual "thin Build-Records" for storage/auth stay as non-blocking backlog).
- **Confluence** still needs a manual redirect — tracked, not done here.
- **Docs to reconcile (each its own tracked change, `POL-0003`):** the new `Build-Records/PVE01-Networking.md` (created); `204-Proxmox-Networking.md` (SoT banner); Lab-01 `Build-Record-Network.md` + `Build-Guide-Network.md` (pointer banners); `VIRTUALIZATION-PACK-MANIFEST.md`; `Review-Flag-Register.md`; `ADR-Index.md`.

## Review Trigger

- If PVE01 networking changes again, it changes in the **Build-Record** (and the `204` procedure if the steps change) — never in the Lab-01 pointer.
- If a second host develops the same frozen-vs-active ownership split, apply the Global principle above rather than re-deciding.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-28. Accepted. PVE01 networking gets **one authoritative home** — a new **Virtualization Build-Record** (Book 2) carrying the current device-verified design (`204` v1.2: tagged `vmbr0.10` `/27`, native 999, `bridge-vids`). `204` stays the build procedure and points to it; the two **frozen Lab-01** homes (`Build-Record-Network`, `Build-Guide-Network`) become **pointers** to the live owner and are kept as the pre-07-24 historical snapshot; the Confluence page is flagged for manual redirect. Resolves manifest **Freeze #2** and register **C7**. States the estate-wide principle (active book owns live config; a frozen book's copy becomes a pointer) → **Scope: Global**. Bounded Book-1 freeze-exception = navigation banners only, no design change. |
