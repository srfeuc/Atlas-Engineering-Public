# Book 9 — Atlas Academy

> 🧭 **What the Academy is *for* — and where new content lands — is the front-door doc [`Academy-Vision-and-Scope.md`](Academy-Vision-and-Scope.md)** (the four layers, the offline "briefcase" principle, the problem-name-keyed `Playbooks/` structure). Read it before adding a command, `show`-example, or troubleshooting playbook. *(This `README`'s "Proposed Curriculum" below still names retired tech as its primary examples — currency fix pending, backlog #30-A.)*

## Status

🟢 **Adopted as the estate's "why it works" layer (D6, `ADR-0032`).** ✅ **D6 ACCEPTED by the operator, 2026-07-28** — Atlas Academy is a standing part of the estate. The `Concepts/` modules + the `Command-Library/` below make the adoption concrete. Numbered 09 rather than inserted mid-sequence, so it doesn't renumber anything already in use.

## Structure

- **`Concepts/`** — the "why it works" modules. `Concepts/README.md` is the index (tiered-admin one-pager written; FSMO / DFSR / SCT / VBS·CG / DSRM / OSPF / DAI / RouterOS-v7 seeded). Device `Diagnostics.md`/`Troubleshooting.md` pages link **up** here.
- **`Atlas-Teaching-Patterns-and-House-Style.md`** — the writing moves worth repeating (register B4).
- **`Command-Library/`** — the master verification command reference (`ADR-0032`), **platform-first** (PowerShell-Tier0 / Cisco-IOS / RouterOS / FortiOS full; Linux expanding) and cross-indexed by service + failure-category. The per-device `Diagnostics.md` quick-refs link **up** into it. `Command-Library/README.md` is the map.
- **`Playbooks/`** 🆕 — the **action layer** (`ADR-0053`): *"it's broken / I need to operate it — what do I do?"* Scenario docs **named for the problem** (searchable, ticket-ready — the briefcase principle), linking **down** into the Command-Library. `Playbooks/README.md` is the index. *(The "how do I do / automate a technique" **Runbooks** sibling arrives with the automation work, `ADR-0048`.)*
- **[`Certification/`](Certification/)** — the **certification tracks**: each maps a cert’s objectives onto the real Atlas builds that prove them (CCNA/CCNP, AZ-800/801, FortiGate FCP, Security+ Domain-5, CompTIA Project+, and the A+/Net+/Sec+ pre-teardown catalogue). `Certification/README.md` is the index. *(A **CompTIA Linux+** track is being added — see the vision doc.)*
- **`Lab-01-to-Lab-02-Reconciliation-and-Gap-Map.md`** 🆕 — the cross-lab resource: **what each machine was in frozen Lab-01, where its services split off to in Lab-02, what carried over, and the gaps the new design closes (plus gaps still open in the partial build).** The Raspberry Pi worked example (four services on one box → split apart) + SW01/MKT01/FGT01/PVE01. "The shared core you'd start a new lab from." Feeds the **Lab-01 Playbook Project** (`#36`/`#37`) and the reconcile step every Playbook does (`ADR-0022`).

> **How Academy docs are made + navigated is governed by [`ADR-0053`](../00-Atlas-Foundation/Decisions/ADR-0053-Atlas-Academy-Documentation-and-Navigation.md)** (the Academy Documentation Standard — the layers above, the cert-grounded spine, the strict 3-click rule, the Playbook template) — distinct from the per-device Standard (`ADR-0037`).

## Purpose

Atlas has three different kinds of documentation, and they answer three different questions. Build Guides answer "how do I build this." Labs (Book 8) answer "can I demonstrate this skill." Neither answers **"why does this work the way it does, and how does it fit with everything else"** — the exact gap named directly this session: knowing individual pieces of MCSA/MCSE material without knowing where they fit or what a real company actually uses them for.

Academy is the missing third piece: short, focused conceptual modules, each one teaching a real underlying concept using an actual, already-built piece of Atlas as the running example — not a generic tutorial, not a textbook chapter about nothing in particular.

## Design Principle

Every Academy module must reference a real Atlas artifact by name. "How VLANs work" is a generic tutorial that exists a thousand times online. "How VLANs work, using SW01's actual Gi1/0/1 trunk and MKT01's actual `bridge-trunk` interface as the worked example" is something only Atlas has, and it's the version that actually sticks — and the version that's defensible in an interview when someone asks "walk me through how you'd explain VLANs to a junior engineer."

## Proposed Curriculum

### Linux Fundamentals, Taught Through Pi01

The module Seth specifically asked for. Not a generic "intro to Linux" — walks through concepts using the actual Pi01 build:

- systemd, using the real `dnscrypt-proxy-doh.service` unit created this session as the worked example of a custom service unit and why the default socket-activation approach had to be abandoned
- The Linux networking stack, using Pi01's actual `nmcli`-based static IP configuration and the real `chattr +i` lock on `/etc/resolv.conf` as the "here's a real problem this solved" example
- Permissions and group membership, using the actual `pihole` group / `dnsadmin` user permission fix from this session as the worked example
- Package management, using the real `apt`/Debian-based install history across Pi01's services

### Networking Fundamentals, Taught Through Atlas's Real Topology

- VLANs, 802.1Q tagging, and native VLAN — using SW01/MKT01's actual configuration, including the real tagged-vs-untagged mismatch bug that happened during the PVE01 VLAN 20 attempt as a worked "here's what goes wrong" example, not a hypothetical
- Routing fundamentals — using MikroTik's real routing table and firewall rule set
- DNS resolution chains — using Pi-hole's actual three-layer design (filtering → DNSSEC → DoH) as the worked example

### PKI, Taught Through Atlas's Two Certificate Authorities

- What a two-tier CA actually is and why the split — using the real OpenSSL Lab CA build (offline root, online intermediate) as the primary worked example
- Once Book 4 exists: the same concepts again through AD CS, explicitly compared side-by-side with the OpenSSL version, since seeing the same concept implemented two different ways is what actually cements it

### AAA, Taught Through Atlas's Real RADIUS Deployment

- RADIUS vs. TACACS+ — what problem each actually solves, using the real FreeRADIUS build (including its real, actually-encountered gotchas: the `==` vs `:=` bug, the InkBridge repo mismatch) as the worked example

### PowerShell for Atlas Administration

- Not "learn PowerShell" in the abstract — task-based modules tied to real Atlas admin work as it comes up in Book 3 (user provisioning scripts, the CSV-driven bulk import from the Windows Roadmap's build order, GPO reporting)

### Virtualization Concepts — Proxmox and the Road Not Taken

- What a hypervisor actually does, taught through Proxmox specifically, with an honest side note on how the same concepts map onto Hyper-V for exam purposes (relevant since AZ-802 tests Hyper-V, not Proxmox) — see Book 8, Section 4

## What Academy Is Not

- Not a replacement for Build Guides — those stay procedural and target-state.
- Not a replacement for Labs — those stay hands-on and gradeable.
- Not generic re-hosted certification study material — every module must earn its place by referencing something real that Atlas actually built.

## Suggested Format Per Module

- **The Concept** — plain explanation, assume no prior knowledge
- **The Atlas Example** — the real artifact, with real config/commands
- **What Went Wrong** (where applicable) — real troubleshooting history is more valuable teaching material than a clean success story
- **How to Explain This in an Interview** — a one-paragraph, spoken-out-loud version, since articulating a concept out loud is a different skill than having built it

## Related Pages

- Every Academy module cross-references the specific Build Guide/Build Record it draws its "real example" from — Academy doesn't duplicate that content, it explains the reasoning behind it.
- `Concepts/README.md` (concept index) · `Concepts/Tiered-Admin-Model.md` (first full module) · `Atlas-Teaching-Patterns-and-House-Style.md` · `00-Atlas-Foundation/Decisions/ADR-0032` (Academy = command library + concept layer).
