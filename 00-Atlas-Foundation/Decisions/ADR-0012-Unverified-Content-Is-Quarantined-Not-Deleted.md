# ADR-0012 — Unverified Published Content Is Quarantined, Not Deleted

| Item | Value |
|---|---|
| Status | **Accepted** |
| Governing Policy | POL-0014 R2 |
| Rule promoted to | [POL-0014 — Documentation & Knowledge Mgmt](../Policies/POL-0014-Documentation-and-Knowledge-Management.md) · this ADR is the adopting decision; the standing rule now lives in that policy (`ADR-0054` (C)→policy) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-14 |
| Related | `ADR-0008` (Foundation holds process only), `ADR-0010` (publication preconditions), `016-Network-Lessons-Learned.md`, `018-Atlas-Documentation-Standards.md` |
| Evidence Status | **`Verified`** — every defect listed below was read off the live Confluence page or the live repo file, and the moves were confirmed by a read-back of the page tree |

> **Raised because a Confluence reconciliation pass had no rule for what to do with a page that is wrong.**

## Context

The `Atlas` Confluence space holds **125 pages**. Roughly a third of them are **early scaffolding** — written before the devices were enumerated, never reconciled, and in several cases **actively wrong**.

They fall into two groups:

| Group | Example | Problem |
|---|---|---|
| **Superseded** | `FortiGate Complete Build Guide` | A repo document now covers the same ground, correctly. Two homes for one fact. |
| **Orphan** | `Wireshark`, `Monitoring`, `DNS` | No repo counterpart exists at all. Nothing to reconcile *against*. |

**The Charter's definition of done requires *"exactly one Confluence home per fact."*** These pages violate it. But **deleting them is the wrong instinct**, and this ADR records why.

## 🔴 The finding that forced the decision

**The unverified pages are not merely stale. Several would actively break a rebuild.**

| Page | Defect found |
|---|---|
| **`FortiGate Complete Build Guide`** | 🔴 **No `set vdom "root"` on any interface command.** FGT01 runs multi-VDOM. **Omitting it caused a lockout during the original build.** A rebuild from this page reproduces that lockout. *(The repo's `025-FGT01-Build-Guide.md` has it correctly, in all four places — the defect is confined to the unverified copy.)* |
| **`FortiGate Quick CLI Guide`** | Uses `port1` / `port2` — **FortiGate-VM interface names that do not exist on a physical 60E** — directly contradicting its own sibling page. |
| **`FortiGate Validation Guide`** | Declares itself *"the authoritative FortiGate validation checklist."* **It is not.** `015-Network-Validation-Guide.md` is. **A page that claims authority it does not have is worse than a page with no claim at all.** |
| **`DNS`** | Refers to `atlas.local`. **That domain has never existed.** Devices are `<device>.lab`; `atlas.lab` is *proposed and unimplemented* (`ADR-0007`). |
| **`Lab Inventory`** | Omits **Pi01 entirely** — the host holding the Root CA, Intermediate CA, Vaultwarden, Pi-hole and FreeRADIUS. Names *"Managed switch"* rather than SW01. |
| **`Switching`** | *"Use VLAN 999 for native parking **where appropriate**."* **`Gi1/0/4` is native VLAN 10 deliberately** — native 999 there makes PVE01 unreachable. **It already did, once.** |
| **`Communications Matrix`** | Written entirely against `DC01`, which is **stopped and not promoted.** Describes no flow that exists and omits every flow that does. |
| **`Physical Topology`** *(rewritten, not quarantined)* | Listed **four devices** — Home Router, FortiGate, MikroTik, PVE01. **No SW01, no Pi01, no iDRAC.** |

**This is `016` lesson #8 at the wiki layer:** *a guide that does not mention a thing will recreate the thing* — and its sibling, *a guide that mentions a thing wrongly will recreate it wrongly.*

## Decision

**Unverified published content is moved to `Atlas Academy → <Topic> — Unverified Study Notes`, annotated with its specific defect, and kept.**

### Rules

1. **A page is never deleted for being wrong.** It is moved, and the reason is written **on the page**, naming the defect — not "this is old," but *"this omits `set vdom "root"`, which caused a lockout."*
2. **A page that has a repo counterpart is rewritten from the repo, not quarantined.** Quarantine is for content with **no source of record**. If a source exists, the page is a stale *copy*, and the fix is to republish — not to bury it.
3. **A page with no repo counterpart and no defect is still quarantined**, because *"nothing has disproved it yet"* is not the same as *"it is verified."*
4. 🔴 **The quarantine parent page lists the defects.** A folder of bad pages with no index is how the original problem happened.
5. **If a quarantined page contains something true and useful that exists nowhere else, that content is promoted into a repo document first, and the page is quarantined second.**

## Consequences

**Accepted:**

- The `Atlas` space keeps a visible record of **what was believed before the devices were read.** That history is worth keeping — it is the same reason `CM-0011` was closed as *false* rather than deleted.
- **A reader who lands on a bad page via search now sees why it is bad**, at the top, instead of trusting it.

**Rejected — "just delete them":**

🔴 **Deletion destroys the evidence and does not prevent the recurrence.** The `FortiGate Complete Build Guide` is the clearest case: its missing `set vdom "root"` is the *record of a real lockout.* Deleted, the lesson is gone and the next person writes the same guide. Quarantined and annotated, it teaches.

**Rejected — "leave them where they are and fix them later":**

🔴 **"Later" is what created this.** A wrong page sitting in the live tree is indistinguishable from a right one at a glance, and **search does not know the difference.** `016` lesson #10: *a stale index does not merely fail to help — it actively tells you the work is done.*

## 🔴 The rule this ADR also establishes

> **The repository is the source of record. Confluence is the published copy.**

**This was violated during the very pass that produced this ADR.** Six corrections — the `CM-0009` packet-path lesson, the read-back rules, the DNS reconciliation, the `sudo` warning, and the quarantine decision itself — were **written to Confluence first and existed nowhere in git.** For a short time, **the published copy was more correct than the source of record**, which means a rebuild from the repo would have silently lost them.

**They were pulled back into the repo as `009` v2.0, `013` v2.0, `015` v2.0, `036` v1.1, and this ADR.**

> **Charter Rule 13 says the device beats the document. `CM-0014` added: the repository is also a device.** This adds the third: **Confluence is a *publication*, not a *record*. Anything written there and nowhere else is one wiki outage away from never having existed.**
>
> **Write the repo file. Then publish it. Never the reverse.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-14. Raised during the Book 1 Confluence publication pass, after 15 unverified pages were found — several of which would break a rebuild — and no rule existed for what to do with them. Establishes quarantine-not-delete, the annotate-with-the-defect requirement, and the repo-is-authoritative rule that this same pass had violated. |
