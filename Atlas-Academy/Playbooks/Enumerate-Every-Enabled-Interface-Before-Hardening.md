---
Title: Playbook — Enumerate Every Enabled Interface Before Hardening (don't shut the break-glass path)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on a device. Grounded in the real frozen **Lab-01** FGT01 incident (`CM-0033`), current-design-reconciled (`ADR-0022`). Searchable/ticket-ready per Backlog **#32**.
Version: 1.1
Date: 2026-08-02
---

# Playbook — Enumerate Every Enabled Interface Before Hardening

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: pre-hardening / change-safety. **Before you disable "unused" ports on a device, enumerate every physically-enabled interface and find out *why* each one is up — because one of them may be the only way back in.** Correct-by-policy hardening ("disable anything unused") deletes break-glass recovery paths when an enabled-but-idle interface has no documented reason on record.

**Why this is a first-tier playbook (Backlog `#32`).** In frozen Lab-01, FGT01's ports `internal3`–`internal7` were **UP** and appeared in *no* document — yet they carried FGT01's factory bootstrap address **`192.168.1.99`**, its **only IP-based recovery path** when the management interface is unreachable. A routine hardening pass that shut "the unused ports" would have destroyed the recovery path (`CM-0033`, `016` lesson 9). The trap is subtle: the *group* (`internal` hard-switch) was correctly disabled, so everyone believed the ports were too — **a group's state is not its members' state.**

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **the Unused-Interface Policy (both clauses)** and the real scar.
3. **① Pin it down** — the device + hardening intent, your live management path, the break-glass path, groups-vs-members.
4. **The diagnosis path** — enumerate every interface → classify each up one (in-use / documented / **unassessed**) → locate & protect the recovery path → decide + document.
5. **The fix** (disable the genuinely-unused, document the load-bearing) · **Prove it's safe** · **If still broken**.
6. **Worked example → `CM-0033`** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- "*internal3-7 status: up*" while the `internal` group is `status: down`.
- "*an undocumented enabled interface is not low-risk — it is UNASSESSED*" (`016` lesson 9).
- 🟡 (real read-backs land on-device): `get system interface` shows ports `up` that appear in no Build Record.
- an interface table row that reads "*Unassigned*" / "*Available*" / "*Factory default*" with **no state and no action**.

**Plain-language symptom phrases**

- "I'm about to harden this box and want to disable unused ports safely."
- "which ports are actually on, and why?"
- "is this 'unused' interface actually load-bearing?"
- "I disabled the unused ports and now I can't get back into the firewall."
- "the recovery path was a port nobody documented."
- "the group is down but the member ports are still up."

**Aliases / also-known-as**

- break-glass path · out-of-band recovery interface · bootstrap address · factory recovery IP (`192.168.1.99`).
- unused-interface policy · disable unused ports · interface hardening · attack-surface reduction.
- "disabled group is not a disabled port" · hard-switch members up · undocumented enabled interface · unassessed interface.
- pre-change enumeration · document-the-reason-before-disabling.

**Keywords line**

`get system interface` · `CM-0033` · `192.168.1.99` · break-glass · `internal3-7` · hard-switch group · unused-interface policy · `010` Security-Zones · trusthost · FGT01 · `show ip interface brief` · `/interface print` · enumerate-every-interface · `016` lesson 9.

## Cert anchor

- CompTIA **Security+** (attack-surface reduction; secure configuration) — the primary anchor.
- **FCP / NSE4** (FortiGate interface & trusthost hardening), **CCNA Security** (disabling unused ports).
- CompTIA **ITIL** (change safety — read the device before the change-order).
- *(Grounding index: the CIS-Hardening docs + `010-Security-Zones` Unused-Interface Policy; `../Concepts/README.md` — recovery paths are load-bearing and invisible.)*

## Grounded in — the Unused-Interface Policy (both clauses) and the real scar

Hardening is correct — *with* the second clause (`POL-0008` — the device pages + CIS docs own the facts; this page links):

- **The policy (first clause):** any interface with *no assigned purpose and nothing connected* must be **administratively disabled**, not left at its default state. Applies uniformly to switch ports, firewall interfaces, router interfaces, and **hard-switch groups**.
- 🔴 **The policy (second clause — the one that saves you):** if an interface must **stay enabled for a reason that isn't "passing production traffic today"**, that reason is **written down in the device's Build Record**. An enabled-but-idle interface *without* a documented reason is the exact gap the rule exists to prevent.
- **The real incident (frozen Lab-01, `CM-0033`):** `internal3`–`internal7` were up, carrying `192.168.1.99` (FGT01's only recovery path), documented in the topology/teardown runbook but **not** in the Build Record — so nobody assessed them and a hardening pass would have shut them. Also live in that record: a factory `dmz` interface up at `10.10.10.1`, in no policy. The current design keeps FGT01 (FortiGate 60E) and the same recovery model; addressing is Lab-02's plan (`ADR-0022`).

Command detail (link down — `POL-0008`): `../Command-Library/FortiOS.md` §Interfaces (`get system interface`) · `../Command-Library/Cisco-IOS.md` §Interfaces (`show ip interface brief` / `show interfaces status`) · `../Command-Library/RouterOS.md` §Interfaces (`/interface print`). Why-it-works: `../Concepts/README.md` (recovery paths are load-bearing and invisible; a disabled group ≠ disabled ports).

## ① Pin it down (capture these first — they're the ticket)

- a. **The device + the hardening intent** — which box, and what you're about to disable ("all unused ports", "shut internal3-7", a CIS pass).
- b. **The management path you're using right now** — which interface/IP are you connected through? (Never disable your own path.)
- c. **The break-glass path** — what is the *documented* out-of-band / recovery interface for this device (console? a bootstrap IP like `192.168.1.99`? MAC-WinBox?) — and is it one of the ports on your "disable" list?
- d. **Groups vs members** — for hard-switch / bridge / aggregate interfaces: is the *group* down but its *member ports* still up? (The `CM-0033` trap.)
- e. **Where "the reason" lives** — does each enabled-but-idle interface have a documented reason in the Build Record? An undocumented one is **unassessed**, not safe to shut.

## The diagnosis path — enumerate first, disable last

Run the read on the device. Read the runtime, never the config (`POL-0001`; FortiOS: `get`, not `show`).

**1. Enumerate EVERY interface the device has — physical, logical, group, member, tunnel.**

- a. FortiOS: `get system interface`
  - Reference: `../Command-Library/FortiOS.md` §Interfaces.
  - List **everything `status: up`** — including hard-switch **member** ports even when the group is down, and factory interfaces (`dmz`, tunnel interfaces `ssl.root`/`naf.root`).
- b. IOS: `show ip interface brief` + `show interfaces status`; RouterOS: `/interface print`.
- c. 🔴 The point: your "unused" list must be built from the **device's** full enumeration, not from the doc's expected list. `015`'s rule: *enumerate every interface a device has, not just the ones already expected to be in use.* 📸 the full interface list with the `up` ones marked.

**2. For each enabled interface, answer: why is it up?**

- a. Cross-check the source-of-truth (Build Record, topology, teardown runbook, IP plan).
- b. Classify each `up` interface:
  - **passing production traffic** → keep, it's in use.
  - **enabled for a documented reason** (break-glass / bootstrap / management) → **keep, and confirm the reason is in the Build Record.**
  - **enabled, no documented reason** → 🔴 **UNASSESSED** — do *not* blind-disable; investigate before acting (it may be a recovery path nobody wrote down).
- c. 🔴 Watch the group/member trap: a `down` group (e.g. `internal`) can have `up` members (`internal3-7`). Assess the **members**, not just the group.

**3. Specifically locate the recovery path and confirm it's *not* on the disable list.**

- a. Identify this device's break-glass: console (baud!), a factory bootstrap IP (`192.168.1.99` on FGT01's `internal3-7`), MAC-WinBox (MKT01), or an OOB management port.
- b. Confirm the trusthost/allow rule for that path still exists (FGT01 `trusthost 192.168.1.0/24`).
- c. 🔴 If your hardening step would shut the recovery interface, **stop** — either exclude it or establish an alternative recovery path *first* (`Recover-a-Locked-Out-Router-Out-of-Band.md`).

**4. Only now decide, and document the reason for anything staying up.**

- a. Truly-unused + nothing connected + no reason → disable (the policy's first clause).
- b. Enabled-but-idle-with-a-reason → keep, and **write the reason into the Build Record** (the second clause) so the next hardening pass doesn't re-raise it.

## The fix — disable the genuinely-unused, document the load-bearing

- a. Disable only the interfaces that are unused *and* have no documented reason:
  - FortiOS: `config system interface / edit <if> / set status down / next / end`.
  - IOS: `interface <if> / shutdown`; put unused access ports in the black-hole VLAN.
- b. For every interface that **stays up without passing traffic**, add the reason to the Build Record now (per `010`'s second clause) — e.g. *"internal3-7 up, DELIBERATELY: FGT01's `192.168.1.99` break-glass path; do not disable."*
- c. Re-enumerate (`get system interface`) and confirm only the intended interfaces are up.
- d. The exact commands are the device's to run + read back (🟡 until pasted).

## Prove it's safe

- a. `get system interface` (re-run) shows exactly the intended set up; every remaining `up`-but-idle interface has a documented reason.
- b. The recovery path still works — test it (reach the bootstrap IP / console / MAC-WinBox) *before* you consider the pass done.
- c. Your live management session is unaffected.
- d. 📸 the before/after enumeration + the Build-Record reason lines. Mark ✅ only with the pasted read-backs (`POL-0001`).

## If still broken

- You already disabled a port and lost access → recover out-of-band (`Recover-a-Locked-Out-Router-Out-of-Band.md` / the device's console-recovery doc), then re-enable and document it.
- A factory L3 interface (`dmz` at `10.10.10.1`) is up with a confusable address → disable it *and* reserve/deconflict the subnet in the IP plan (don't just leave it).
- An interface you can't explain is up → treat it as **unassessed**: leave it, and raise it for investigation rather than disabling on a guess (`CM-0011`: a draft run as a work-order degraded a device).

## Worked example — the real Lab-01 case (`CM-0033`, device-verified)

> The FGT01 finding this Playbook is drawn from — enumerated on the live FGT01 during the Book-1 audit. **Authoritative record: [`Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/CM-0033-FGT01-Five-Live-Undocumented-Ports.md`](../../Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/CM-0033-FGT01-Five-Live-Undocumented-Ports.md).** Read-backs quoted from the frozen record (`POL-0001`). *(Addressing is Lab-01's; the current design keeps FGT01 + the same recovery model, `ADR-0022`.)*

- **① Pin it down.** The intent was a routine "disable the unused ports" hardening pass on FGT01. The `internal` hard-switch **group** read `status: down`, so the ports were believed off. → `CM-0033` §finding.
- **Step 1 — enumerate every interface.** `get system interface` (the runtime read — `get`, not `show`) showed **`internal3`–`internal7` `status: up`** while the `internal` group was down — **a group's state is not its members' state.** Also up: a factory **`dmz`** interface at **`10.10.10.1`**, in no policy. None appeared in the Build Record. → `CM-0033` §enumeration.
- **Step 2 — why is each up?** The five ports carried FGT01's factory bootstrap address **`192.168.1.99`** — its **only IP-based recovery path** when the management interface is unreachable. Documented in the topology/teardown runbook but **not** the Build Record → **UNASSESSED**, not safe to shut. → `CM-0033` §reason + `016` L9.
- **Step 3 — protect the recovery path.** `192.168.1.99` (allowed by `trusthost 192.168.1.0/24`) is the break-glass — and it was on the naive "disable" list. A blind pass would have destroyed it. → `CM-0033`.
- **Step 4 — decide + document.** Keep `internal3`–`internal7` up with the reason written into the Build Record (*"DELIBERATELY up: FGT01's `192.168.1.99` break-glass path; do not disable"*); disable/deconflict the stray factory `dmz` `10.10.10.1`. → `CM-0033` §resolution.
- **Gap / what this closed.** An enabled-but-undocumented recovery path — an audit-integrity + availability gap, because a correct-by-policy hardening pass would have shut it — closed by writing the reason into the Build Record so the port is *assessed*, not merely *up*.

## Related

- **Command-Library:** `../Command-Library/FortiOS.md` (§Interfaces `get system interface`) · `../Command-Library/Cisco-IOS.md` (§Interfaces) · `../Command-Library/RouterOS.md` (§Interfaces).
- **Concepts:** `../Concepts/README.md` (recovery paths are load-bearing and invisible; a disabled group ≠ disabled ports).
- **Decisions / owners:** `Devices/FGT01-Perimeter-Firewall/` (+ its `Considerations`) · the CIS-Hardening docs (`Architecture/CIS-Hardening-FGT01.md` etc.) · `010`-style Unused-Interface Policy · the IP-Addressing plan.
- **Sibling playbooks:** `Recover-a-Locked-Out-Router-Out-of-Band.md` (what you use if you *did* shut the path) · `Disable-Unused-Ports-Without-Cutting-the-Break-Glass-Path.md` (the switch-port sibling) · `Confirm-a-Config-Change-Actually-Took.md` (`get` not `show` — how `CM-0033` was even found) · `Recover-the-Lab-from-a-Bare-Metal-Teardown.md` (the recovery paths this protects).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).
- **Real lineage:** frozen Lab-01 `Devices/FGT01-NS-Firewall/Changes/CM-0033` (five live undocumented ports = the only recovery path) · `Operations/016-Network-Lessons-Learned.md` lesson 9 (*"an undocumented enabled interface is not low-risk — it is UNASSESSED"*; *"a group's state is not its members' state"*) — `ADR-0022`-reconciled.

## Worked log

| Date | Who | Time | Device | Interfaces enumerated | Recovery path confirmed | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-08-02 | **Format-alignment (audit register row 2):** added the **On this page** quick-nav and a dedicated **Worked example → `CM-0033`** section quoting the frozen read-backs (`internal3-7 status: up` while the group is down · the `192.168.1.99` break-glass · the stray factory `dmz` `10.10.10.1`), with the Lab-01-addressing note. DOCS-ONLY complete. |
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the new **Symptoms & search terms** element `#32`). Pre-hardening safety: enumerate every enabled interface (`get system interface` — physical, logical, group *and* member, tunnel) and establish *why* each is up before disabling anything, so a correct-by-policy hardening pass doesn't shut the break-glass recovery path. Diagnosis path: full enumeration → classify each up interface (in-use / documented-reason / **unassessed**) → locate & protect the recovery path → decide + document. Grounded in the frozen Lab-01 `CM-0033` (FGT01 `internal3-7` up carrying `192.168.1.99`, the only recovery path, in no Build Record) + `016` lesson 9. 🟡 until worked on a device. |
