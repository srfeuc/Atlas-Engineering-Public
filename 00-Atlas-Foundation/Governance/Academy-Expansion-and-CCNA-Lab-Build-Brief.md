---
Title: Academy Expansion + CCNA-Lab Build — Execution Brief (next session)
Path: 00-Atlas-Foundation/Governance
Status: 🟢 ACTIVE plan (`ADR-0053` · Backlog #44) — **paste this into a fresh session as its task brief.** The turnkey what/where/how for the Academy-as-expansion-layer redesign + the CCNA lab. Retire with a ✅ DONE banner (`ADR-0012`) when the arc completes.
Version: 1.0
Date: 2026-08-04
---

# Academy Expansion + CCNA-Lab Build — Execution Brief

> 🤖 **You are the next session.** This continues **Backlog #44** — the operator reframed the Atlas Academy as **the expansion layer**: *it feeds on all the other docs and expands what they summarise.* Device pages stay terse and **link up**; the Academy holds the full detail. Work **docs-only, one piece at a time, reviewed** (`ADR-0049`); where a device config *is the lesson*, **the operator types it** (Charter Rule 17) — you give the design, the real values, and the validation.

## 0. Orient first (cold start)
1. `AI-Context/README.md` + `What-To-Check-First.md` — estate map + house rules.
2. [`SESSION-HANDOFF.md`](../../Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md) — the 📍 CURRENT STATE + latest block.
3. [`Backlog #44`](../Roadmap/Atlas-Improvement-Backlog.md) — the full design (this brief operationalizes it).
4. The **format is locked** — study the exemplars before writing: the Command-Library **v3 sample shape** and the [`Ch12` cert sub-page](../../Atlas-Academy/Certification/) + the ⭐ **standard** Playbook [`Set-Up-the-1941-for-the-CCNA-Lab`](../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md).

## 1. The three-layer cert stack (how the docs feed each other)
> **map → sub-pages → Command-Library**, all cross-linked; the Academy expands the device docs.

1. **Overview / front-door —** [`Atlas-Certification-Lab-Map`](../../Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md): topic → Atlas lab + *do-it-now / needs-1941 / $500 / theory* priority. **Expand it** (don't replace); **reconcile the stale bits as touched** — §5 still says *FreeRADIUS → 802.1X*; the estate moved to **NPS** (`ADR-0029`).
2. **Deep reverse-index —** `Certification/CCNA/<chapter>` sub-pages (the `Ch12 DHCP-Snooping & DAI` template): each numbered objective → the Command-Library section + the device artifact + the Concept + the Playbook; `📋` marks a gap. Operator supplies each chapter's objective list; **paraphrase, never paste book prose** (Charter Rule 16 / copyright).
3. **The commands —** `Command-Library/<platform>.md`, rebuilt to the **v3 format** (below).

## 2. Command-Library rebuild — the v3 format, sourced from real docs
Rebuild `Command-Library/Cisco-IOS.md` (then `RouterOS.md`, `FortiOS.md`, …) to cover the **whole CCNA 200-301 v1.1 blueprint** — a **top index** + the six domains (1 Fundamentals · 2 Access · 3 Connectivity · 4 IP Services · 5 Security · 6 Automation).

**Per objective (the locked v3 shape):** numbered like the blueprint (`5.7`, `5.7.1`) · **What** · **Config** (every command a **bullet**) · **Verify** (bulleted, with a worked read-back) · 🔴 **Breaks when** · 🔗 **Depends on / Flow** (service interdependencies — e.g. DAI ⇐ snooping's binding table; RADIUS ⇐ NPS ⇐ AD CS ⇐ DC) · 📄 **Expands** (the device doc it deepens) · grounding **✅** device-verified / **🟡** partial / **📘** study-reference (a CCNA command Atlas doesn't run — a build gap). Heavy `━━━` dividers between objectives.

**Sources (in priority):** the operator's **Cisco source library** (their own commands, examples, and Cisco lesson notes) → the device **Build-Guides/Records** (real Atlas values + gotchas → the *Breaks-when* column) → the blueprint (structure). **Build `Cisco-IOS.md` first**, one domain at a time.

> 📒 **Operator source inventory (connect the relevant folder per domain; the lesson PDFs are operator-side — re-provide them for the domain you're building):**
> - **Notepad Stuff** (connected) — ACLs · OSPF · NAT · STP · Trunking/router-on-a-stick · Port-Security · NTP · DHCP · CDP/LLDP · Static · EtherChannel · Basic-Router-Commands.
> - **QOS · Security · Spanning-Tree** folders (connected) — domains 4.7 QoS · 5 Security · 2.5 STP.
> - **Cisco lesson PDFs** (operator uploaded 2026-08-04): *Routing Protocols* (zip) + *Basic Connectivity Troubleshooting* → domain 3 · *DHCP Server / External DHCP / DHCP Client* → 4.3/4.6 · *Network Redundancy / FHRP / HSRP / HSRP Advanced* → 3.5 · *VPN / Leased Lines / MPLS / PPPoE / WAN Topology* → WAN (1.2 / 5.5 VPN; some are CCNP-adjacent — use for the *why*, mark 📘 what Atlas can't run). **Operator note: 'the next bot should include some of these too.'**
> 🔴 **How to use the course material (operator, 2026-08-04):** the folders/PDFs (the **Flackbox** CCNA course + the operator's notes) are a **commands-and-a-little-context reference to fill gaps — NOT a template.** **Atlas adopts its own way:** lift the *factual command* + the `show`-output *pattern*, then write the entry in the estate's **own voice + v3 format, grounded in real Atlas devices/values**. **Paraphrase only — never reproduce the course's slides, prose, or images** (Flackbox is paid material; Charter Rule 16 / copyright).

## 3. CCNA device labs — the 1941 Playbook is THE STANDARD
The [`Set-Up-the-1941-for-the-CCNA-Lab`](../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) Playbook is the **operator-adopted template for every CCNA lab-change**. Match its shape for future CCNA labs: **① a temporary-overlay guardrail** (what the device normally does vs the lab overlay; revert section) · **② real addresses from the [IP plan](../../Labs/Lab-02-Cisco-Core/Architecture/IP-Addressing-Plan-VLSM.md)** (never placeholder) · **③ the config the *operator types*** (Charter Rule 17) · **④ read-back verification + a test matrix** · **⑤ a Learn-it footer** into the Command-Library + cert map + `#23` test stations.

🔴 **The 1941 CCNA overlay is temporary + sanctioned:** for the lab the 1941 runs **router-on-a-stick + ACLs** (`ADR-0023` **Option A**, which keeps the 1941 as "the CCNA/IOS learning vehicle"). **Production target after the lab = Option B** — 1941 routes-only, **MKT01 owns inter-VLAN + the east-west firewall** ([`1941 Build-Checklist`](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Build-Checklist.md)). Recorded on the [1941 Considerations](../../Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router/Considerations.md). **Operator has the router now; the new server arrives ~1 week.** Sequence: ACLs first, then east-west (MKT01) after the CCNA lab.

## 4. The arc (sequence)
> cert map (expand, reconcile) → **Command-Library `Cisco-IOS.md`** (v3, from the notes+Build-Guides) → cert sub-pages (per chapter, operator objective lists) → CCNA lab Playbooks (the 1941 standard; more devices) → **#23 test stations** (VLAN-50 Win11 + Linux boxes — the validation harness that proves the ACL/flow rules).

## 5. Known gaps to mark, not hide
- 📘 **IPv6** — no device runs it (operator's top study concern); mark it 📘 in the library + a 🟡 lab in the map. A dual-stack build on the 1941/SW01 closes objectives 1.8–1.9 / 3.3.
- 📋 **No DHCP-snooping/DAI Concept** — the Command-Library's "N2" reference has no `Concepts/` page (surfaced by the Ch12 sub-page).

## 6. House rules for this arc
Docs-only · operator runs all git (write files + print a PowerShell commit block; `git add -u`) · **operator types lesson-config** (Charter 17) · one piece / one doc at a time, reviewed · **verify every link on disk (0 broken)** · the **Command-Library ↔ cert-sub-page links are mutual — commit them together** · refresh the handoff + backlog after each piece · when the `Certification/<Cert>/` structure lands, refresh the AI-folder `Directory-Map` (structural change).

## Done when
☐ `Command-Library/Cisco-IOS.md` rebuilt to v3, all 6 domains, sourced from the notes+Build-Guides; 0 broken links.
☐ The cert map promoted to the CCNA overview (stale §5 reconciled) + wired to the sub-pages.
☐ Cert sub-pages built per chapter from the operator's objective lists (Ch12 committed as the first).
☐ CCNA lab Playbooks follow the 1941 standard; the 1941 Considerations carries the overlay note.
☐ RouterOS/FortiOS libraries follow, from their Build-Records.
☐ Handoff + backlog refreshed after each piece; this brief retired ✅ DONE (`ADR-0012`) when the arc completes.

## Related
[`Backlog #44`](../Roadmap/Atlas-Improvement-Backlog.md) · [`ADR-0053`](../Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md) (Academy doc/nav) · [`ADR-0023`](../Decisions/ADR-0023-1941-Core-MKT01-East-West-Firewall-Topology.md) (the 1941 role) · the ⭐ standard Playbook [`Set-Up-the-1941-for-the-CCNA-Lab`](../../Atlas-Academy/Playbooks/Set-Up-the-1941-for-the-CCNA-Lab-Router-on-a-Stick-and-ACLs.md) · the retired predecessor [`Foundation-Refinement-and-Academy-Integration-Brief`](./Foundation-Refinement-and-Academy-Integration-Brief.md) (#43).
