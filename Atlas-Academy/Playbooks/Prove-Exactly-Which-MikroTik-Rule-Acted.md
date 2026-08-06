---
Title: Playbook — Prove Exactly Which MikroTik Rule Acted (safely, on a router with no console)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on MKT01. Grounded in the real frozen **Lab-01** MKT01 low-level per-rule isolation tests, current-design-reconciled (`ADR-0022`). Searchable/ticket-ready per Backlog **#32**.
Version: 1.0
Date: 2026-07-31
---

# Playbook — Prove Exactly Which MikroTik Rule Acted

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: verification / firewall. **You think rule N is the one that accepted or dropped a flow — now *prove* it's specifically that rule, at packet level, and do it without locking yourself out of a router that has no console.** `MikroTik-EastWest-Inspect-and-Troubleshoot.md` finds *a* rule by its counter; this page proves it was *that* rule (not a neighbour) using two techniques — a non-destructive mirror, or disable-to-prove — with a hard safety rule about which rules you may never disable.

**Why this is its own playbook (Backlog `#32`).** "The counter moved" tells you a rule matched; it doesn't always tell you *which*, and the obvious way to check — disable the rule and see what changes — can strand you. MKT01 has **no serial console** and its MAC-WinBox break-glass **drops after ~15 seconds** (`ADR-0016`), so disabling a rule that carries your own management session is a physical-trip-and-rebuild mistake. This is the *do-it-once-correctly-so-you-don't-rediscover-it* procedure: the safe technique per chain, and the discipline of reverting everything and reading the rule table back.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- `TEST-R12:` / `MIRROR-R12:` (your own per-rule log/mirror prefixes while testing).
- `EAST-WEST-DENIED:` flips to a *pass*, or a permit's flow flips to `EAST-WEST-DENIED`, when you toggle a rule.
- 🟡 (real read-backs land on-device): `/ip firewall filter print stats` shows a specific index incrementing by exactly your stimulus.

**Plain-language symptom phrases**

- "which rule *exactly* matched this — is it rule N or its neighbour?"
- "how do I prove it's this firewall rule without breaking access?"
- "I want to test one MikroTik rule in isolation."
- "can I disable a rule to see what it's doing — or will I lock myself out?"
- "how do I watch a single rule fire at packet level?"
- "two drops look identical — how do I tell them apart?"

**Aliases / also-known-as**

- per-rule isolation · single-rule verification · disable-to-prove · passthrough mirror · non-destructive rule test · prefix-flip.
- first-match-wins proof · match signature · connection tracking · `/tool torch` · `/tool sniffer` · `hping3` crafted packet.
- console-less router safety · MAC-WinBox 15-second drop · don't-disable-the-input-chain.

**Keywords line**

`MKT01` · `/ip firewall filter set N log=yes log-prefix` · `action=passthrough` · `place-before` · `disabled=yes` · `reset-counters` · `print stats` · `/ip firewall connection print` · `/tool torch` · `/tool sniffer quick` · `hping3` · `nmap -sA/-sF` · `EAST-WEST-DENIED` · `INPUT-DENIED` · `ADR-0016` no-console · revert-and-read-back.

## Cert anchor

- **MTCNA / CCNP Security** (firewall rule analysis, connection tracking) — the primary anchor.
- CompTIA **Network+ 5.0** (methodical troubleshooting; test-one-thing), **Security+** (change safety).
- *(Grounding index: `../Atlas-Certification-Lab-Map.md` §5 + the CCNP map; `015` negative-test discipline.)*

## Grounded in — the two ideas, and the one hard constraint

The method (`POL-0008` — the device page + the Lab-01 isolation-test doc own the detail; this page links):

- **A per-rule match signature.** Every rule has an exact tuple — ingress interface, egress interface, protocol, port(s), connection-state — that *only it* matches (first-match-wins + interface-disjoint). Craft a packet with that tuple and exactly one rule can claim it (`hping3` is the workhorse; `nmap -sA` for invalid/ACK, `-sF` for out-of-state).
- **Isolation by mirror or by removal.** Confirm which rule acted **non-destructively** (a temporary `passthrough`+`log` twin placed at the rule's position — counts the exact traffic reaching there, behaviour unchanged) or **destructively** (disable the rule and watch behaviour change — a permit's flow falls through to the catch-all drop; a drop's traffic starts passing). Destructive is definitive but can lock you out.
- 🔴 **The hard constraint — MKT01 has no safe recovery path.** No serial console; MAC-WinBox drops after ~15 s (`ADR-0016`). So **never disable a rule that could carry your own management session.** Do destructive tests from a **Management (`10.10.0.x`)** or **bridgeLocal** seat whose path to the router doesn't depend on the rule you're toggling. (This constraint is common across Lab-01 and Lab-02 — MKT01 is the same box in the same posture; the console-recovery cable is the standing fix, `Recover-a-Locked-Out-Router-Out-of-Band.md`.)

**Safe-to-disable map (from the Lab-01 isolation tests, reconcile to the live rule set before trusting indices):**

| Chain / rule class | Disable-to-prove? | Use instead |
|---|---|---|
| **input** established/related, bridgeLocal, VLANs→router, the input catch-all | 🔴 **NO** — can drop your live session | `log=yes` + `passthrough` mirror + counters |
| **forward** established/related | 🔴 **NO** — breaks return traffic for every flow | mirror + counters |
| **forward** Mgmt→all | ⚠️ only from the router seat directly | prefer mirror |
| **forward** the other permits + drops, the forward catch-all, the input invalid/rate/home-LAN drops | 🟢 **Yes** — safe (they don't carry your session) | disable-to-prove is fine — revert immediately |

Command detail (link down — `POL-0008`): `../Command-Library/RouterOS.md` §Firewall + §Connectivity. Why-it-works: `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md`.

## ① Pin it down (capture these first — they're the ticket)

- a. **The rule you're testing** — its index/comment and its exact match tuple (`in`, `out`, proto, port, state).
- b. **Which chain** — input (to the router) or forward (through it)? This decides whether disable-to-prove is even allowed (see the map).
- c. **Your management seat** — which VLAN/port are you connected from, and does your path to the router depend on the rule you're about to touch? (If yes → mirror only.)
- d. **The stimulus you can craft** — a host in the rule's `in` VLAN that can emit exactly the matching packet (`hping3`/`nmap`/`nc`).
- e. **Recovery ready?** — is the console-recovery cable in hand / a second session open, in case a destructive test bites (`Recover-a-Locked-Out-Router-Out-of-Band.md`)?

## The diagnosis path — one rule, isolated

Read `print stats`/`print detail`, never plain `print` (`016`). Prove the positive case first (`015`).

**1. Baseline.**

- a. `/ip firewall filter reset-counters [find]`
- b. Optionally make the target announce itself: `/ip firewall filter set <n> log=yes log-prefix="TEST-R<n>:"`.

**2. Single stimulus with the only-this-rule tuple.**

- a. From the correct source host/VLAN, emit **one** flow matching only the target (e.g. `hping3 -S -p 443 -c 1 <dst>` for a specific `in→out` permit; `nmap -sA` for an invalid-state drop).
- b. One connection, not a flood — so the counter delta is legible.

**3. Read the match three ways (low level).**

- a. **Counter:** the target index incremented by the expected number (a new TCP connection = a few handshake packets on the specific accept; the bulk/return rides established/related).
- b. **Log line:** `TEST-R<n>:` shows `in:<iface> out:<iface>, proto, src:port->dst:port, len` — the packet-level proof of which interfaces/tuple matched.
- c. **State / crossing:** `/ip firewall connection print` (for accepts) shows the tracked flow; `/tool torch <if>` shows it crossing the egress interface; `/tool sniffer quick` captures the bytes.

**4. Prove it was *this* rule, not a neighbour — pick the safe technique.**

- a. **Mirror (safe on any rule, incl. the ones you must not disable).** Insert a counting-only twin just above the target with the identical match + `action=passthrough log=yes log-prefix="MIRROR-R<n>:"` and `place-before=<n>`. Your stimulus hits the mirror first (counts + logs the tuple), then `passthrough` continues to the real rule — behaviour unchanged, but you've proven the traffic reaches that position with that match.
- b. **Disable-to-prove (definitive; safe rules only, per the map).** `set <n> disabled=yes`, re-run the stimulus, confirm the **behaviour changes** — a permit's flow now falls to the forward catch-all (`EAST-WEST-DENIED`) / input catch-all (`INPUT-DENIED`); a drop's traffic now passes. If disabling rule N changes the outcome and nothing else did, rule N is provably the actor. `set <n> disabled=no` to restore.
- c. **Prefix-flip (distinguish two identical-looking drops).** Rules that both `drop` the same packet differ only by log prefix (e.g. the home-LAN drop vs the input catch-all). Watch `/log print follow`, disable the more-specific one, resend: if the prefix flips (`DROPPED`→`INPUT-DENIED`), you've proven which rule was catching it. Re-enable.

**5. Revert — then read the table back off the device.**

- a. Undo every temporary change: `log=no`, remove every `MIRROR-*` passthrough, `disabled=no` on anything you toggled.
- b. `/ip firewall filter print` — confirm the expected rule count, indices contiguous, **none disabled, no stray `log-prefix`**, `/ip firewall filter print stats` back to the Build-Record shape.
- c. `/ip firewall nat print` still empty; nothing permanent added.

## Prove it's clean (the most important step)

- a. The rule table read back off the device matches the Build-Record: right count, catch-all drops last, none disabled, no leftover mirror/log.
- b. 🔴 A test harness you forget to remove is a policy change you didn't mean to make (`016`) — and a `passthrough log` mirror left behind silently fills the log. Revert-and-read-back *is* the acceptance test.
- c. 📸 the before/after rule table + the per-rule log/counter that proved the match. Mark ✅ only with the pasted read-backs (`POL-0001`).

## If still broken

- The counter moves but you can't tell it from a neighbour → use the **mirror** (works on any rule); if the rule is safe, **disable-to-prove** is definitive.
- You disabled a rule and lost your session → recover out-of-band (`Recover-a-Locked-Out-Router-Out-of-Band.md`) — this is the exact scenario the safety map exists to prevent.
- The tuple matches two rules → your stimulus isn't specific enough; tighten the `hping3` flags/ports so only the target can claim it.
- You just want to know *which* rule dropped a real flow (not prove a specific one) → `MikroTik-EastWest-Inspect-and-Troubleshoot.md` (counters + deny prefixes).

## Related

- **Command-Library:** `../Command-Library/RouterOS.md` (§Firewall — counters/connections/logs · §Connectivity — torch/sniffer).
- **Concepts:** `../Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` (why a rule matches).
- **Owners:** `Devices/MKT01-East-West-Firewall/` (the live rule set + `Troubleshooting.md`) · `Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`.
- **Sibling playbooks:** `MikroTik-EastWest-Inspect-and-Troubleshoot.md` (find the rule) · `Recover-a-Locked-Out-Router-Out-of-Band.md` (if a destructive test bites) · `Remove-a-MikroTik-Firewall-Rule-That-Has-Never-Matched.md` (a rule that never fires) · `Confirm-a-Config-Change-Actually-Took.md` (read the reverted state back).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).
- **Real lineage:** frozen Lab-01 `Devices/MKT01-Core-Router/Firewall-Low-Level-Per-Rule-Isolation-Tests.md` (the mirror/disable/prefix-flip method + the console-less safety map) + `Firewall-Per-Rule-Verification-Tests.md` · `ADR-0016` (no console — the reason input-chain rules are log-only) — `ADR-0022`-reconciled.

## Worked log

| Date | Who | Time | Rule tested | Technique (mirror/disable) | Proven? | Reverted & read back? |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the `#32` "Symptoms & search terms" element). Prove a *specific* MikroTik rule acted, at packet level, without locking yourself out of a console-less router: the per-rule match signature (`hping3`/`nmap`), the non-destructive `passthrough` mirror vs destructive disable-to-prove, the safe-to-disable map (never the input/established rules — `ADR-0016`), the prefix-flip to separate identical-looking drops, and the load-bearing revert-and-read-the-table-back acceptance. Grounded in the frozen Lab-01 MKT01 low-level isolation-test doc; the console-less constraint is common to Lab-01 and Lab-02's MKT01. 🟡 until worked on MKT01. |
