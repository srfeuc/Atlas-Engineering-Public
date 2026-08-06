# Atlas — Engineering Portfolio

**Atlas is a self-built, ~150-person enterprise IT environment** — real hardware, real cross-vendor network gear, real Windows infrastructure in progress, documented and version-controlled the way a working engineering team actually documents production systems.

This page is the fast version. The rest of the repository is the real version — every claim below links to the actual evidence.

> 👔 **This is the reviewer / hiring-manager index** — the highlights, each one evidence-linked. Skim the tables, follow any link to the proof.
>
> 🧭 **Engineer?** The full repository index — every subsystem, decision, and command — is the root [`README.md`](README.md). *Where the build is right now* → the [Lab-02 handoff](Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md). Unfamiliar term → [`GLOSSARY.md`](GLOSSARY.md).
>
> 📂 **Want to see everything?** This is a full repository, and it's all browsable right here in your web browser — **click any folder or file name to open and read it** (no downloads, no tools needed; use your browser's Back button to come back). The **[`INDEX.md`](INDEX.md)** page describes what's inside every folder.

> ⚠️ *Atlas is a personal learning & portfolio lab. "Atlas Industrial" is a fictional company used to give the build realistic requirements — not a real organization. All values are lab values. Licensed [CC BY 4.0](LICENSE).*

## What This Demonstrates

| Skill Area | Evidence |
|---|---|
| Cross-vendor network engineering | FortiGate (firewall/NAT/routing), MikroTik RouterOS (VLAN trunking, inter-VLAN routing, firewall), Cisco Catalyst IOS (VLANs, STP, port security, DHCP snooping, ARP inspection) — [`Labs/Lab-01-Mikrotik-Core`](Labs/Lab-01-Mikrotik-Core/) |
| Systems administration, Linux | Raspberry Pi running Pi-hole, FreeRADIUS, Vaultwarden, and a self-built two-tier PKI — [`Labs/Lab-01-Mikrotik-Core/Devices`](Labs/Lab-01-Mikrotik-Core/Devices/) |
| Virtualization | Proxmox VE on physical Dell PowerEdge hardware, golden-image/template workflow — [`Labs/Lab-02-Cisco-Core/Virtualization`](Labs/Lab-02-Cisco-Core/Virtualization/) |
| Windows Server / Active Directory | In progress — see [`Labs/Lab-02-Cisco-Core/Windows-Infrastructure`](Labs/Lab-02-Cisco-Core/Windows-Infrastructure/) |
| Change management discipline | Every deviation between design and live state tracked as a formal change record before being applied — [`Labs/Lab-01-Mikrotik-Core/Change-Management`](Labs/Lab-01-Mikrotik-Core/Change-Management/) |
| Governance & policy | A real Policy → Standard → ADR hierarchy with integrated change control — [`00-Atlas-Foundation`](00-Atlas-Foundation/README.md) (Charter, `POL-####`, `STD-####`, 54 decision records) |
| Teaching / knowledge transfer | The [`Atlas-Academy`](Atlas-Academy/README.md) learning layer — concepts (*why* it works), a verification command library, and problem-named troubleshooting playbooks |
| Root-cause diagnostic work | See below — this is the part a resume bullet can't show, so it's shown here instead |

## Real Diagnostic Work, Not Staged Demos

Everything here happened on the actual hardware, in the order documented.

**Diagnosed a dead CMOS battery from three symptoms that looked unrelated.** A hypervisor host showed disabled VT-x (blocking all VM virtualization), a physically un-seating DIMM socket, and a system clock reset to 2018. Traced all three to the same root cause — a dead CR2032 battery resetting BIOS state and losing the real-time clock on every power cycle — rather than treating them as three separate tickets.

**Resolved a real VLAN tagging mismatch through two-sided root-cause analysis.** A Proxmox host couldn't reach its intended VLAN. Root cause: the host was sending untagged frames while the switch port expected them tagged, with native VLAN pointed at an unused VLAN — two individually valid configurations that disagreed about who owned the 802.1Q tag. Fixed by redesigning the actual traffic-ownership model, not by guessing at settings.

**Forensically reconstructed a VM clone lineage from raw log evidence — and caught my own assumption being wrong.** A golden-image template's build history wasn't documented. Rather than accept "probably cloned from the template," pulled the actual Proxmox `qmclone` task logs, read the task *bodies* (not just labels), and discovered Proxmox's own task-naming convention names the operation after the source VM, not the destination — which had inverted the assumed clone direction. Corrected it with the real evidence.

**Built a documented change-management process before making changes, not after.** Every discrepancy between designed network state and live-verified state gets logged as a numbered change record — risk level, backup step, rollback plan, validation — before being applied to production. [Example](Labs/Lab-01-Mikrotik-Core/Change-Management/).

**Adapted when a planned tool got deprecated mid-build.** `cloudflared`'s DNS proxy feature was removed in a Cloudflare release after the original design was written. Diagnosed the gap and re-architected the DNS-over-HTTPS layer around `dnscrypt-proxy` instead, including working around a systemd socket-activation conflict the replacement tool introduced.

## How to Navigate the Rest of This Repository

This is a working engineering repository, not a demo site — it has the same structure a real team would use. The four top-level areas:

- **[`00-Atlas-Foundation`](00-Atlas-Foundation/README.md)** — the engineering process itself: the Charter, the Policy → Standard → ADR governance hierarchy, workflow rules, templates, and the full decision record (`ADR-Index`).
- **[`Labs/Lab-01-Mikrotik-Core`](Labs/Lab-01-Mikrotik-Core/README.md)** — 🔒 the first lab, now frozen and the most complete end-to-end subsystem: network core, hypervisor, and Linux services, with change records and diagnostics.
- **[`Labs/Lab-02-Cisco-Core`](Labs/Lab-02-Cisco-Core/SESSION-HANDOFF.md)** — 🟢 the active build: Cisco core, Windows/AD, AD CS PKI, virtualization, and east-west segmentation.
- **[`Atlas-Academy`](Atlas-Academy/README.md)** — the learning layer: *why it works* (Concepts), *how to verify* (Command-Library), and *what to do when it breaks* (Playbooks).

Every technical claim in every document is tagged with an evidence status — verified live, historical record, reconstructed-but-plausible, or target design — so nothing is presented as more certain than it actually is.

Recruiters and reviewers: start with [`Labs/Lab-01-Mikrotik-Core/README.md`](Labs/Lab-01-Mikrotik-Core/README.md) for the most complete, most mature part of the environment. Engineers: the root [`README.md`](README.md) is the full index.

## Certifications and Learning Path

The [`Atlas-Academy`](Atlas-Academy/README.md) layer maps this environment to real certification study — using actual Atlas infrastructure as the worked examples, not disconnected practice exercises. The cert-alignment maps:

- **CCNA** — [`Atlas-Certification-Lab-Map`](Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md)
- **CCNP (ENCOR + ENARSI)** — [`Atlas-CCNP-Lab-Map`](Atlas-Academy/Certification/Atlas-CCNP-Lab-Map.md)
- **Microsoft AZ-800/801 (Windows Server Hybrid)** — [`AZ-800-801-Windows-Server-Hybrid-Lab-Map`](Atlas-Academy/Certification/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md)
- **FortiGate FCP** — [`Atlas-FortiGate-FCP-Lab-Map`](Atlas-Academy/Certification/Atlas-FortiGate-FCP-Lab-Map.md)
- **CompTIA Security+** — [`Atlas-Security-Plus-Domain5-Coverage-Map`](Atlas-Academy/Certification/Atlas-Security-Plus-Domain5-Coverage-Map.md)
- **CompTIA Project+** — [`Atlas-CompTIA-Project-Plus-Lab-Map`](Atlas-Academy/Certification/Atlas-CompTIA-Project-Plus-Lab-Map.md)
