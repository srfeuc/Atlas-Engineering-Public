---
Title: Atlas — Next-Lab Design Brief (Enterprise Maturity Roadmap)
Path: 00-Atlas-Foundation/Roadmap
Status: Draft — design brief. Consolidates the answers to the "before I build the next lab" questions.
Version: 1.0
---

# Atlas — Next-Lab Design Brief

> **This brief does not replace `Atlas-Service-Architecture.md` (where services go) or `Atlas-Firewall-Architecture.md` (how firewalls work). It sits on top of them** and answers the questions those two don't: **you already have an AD — how does it fit; how do I actually think about zones and pick rules; how do I use NIST/CIS; what order do I learn syslog/SNMP/NetFlow/SIEM; where does automation start; and what does the phased plan look like once the git restructure lands.**
>
> Your stated goal: **CCNA-focused, but built to grow; enterprise-shaped; NIST/CIS-aligned; you want to know how things are *put together*.** That goal is the through-line below.

---

## 1. What the current lab does that the next lab must not

These are not hypotheticals — every one is a defect Atlas already had, in its own lessons file. The "enterprise-like" version is the column on the right.

| Current-lab pattern | Why it bit | Enterprise fix (carry this forward) |
|---|---|---|
| **Source of truth is a hand-typed Markdown table** (`006`) | Pi01 missing from `STATIC-HOSTS` → silently dropped, survived 3 handoffs | **NetBox** (IPAM/DCIM). The ACL is *generated*, not typed. The omission becomes structurally impossible. |
| **Config lives only on the device** | "The document disagreed with the device" was half this session | **Oxidized** pulls every config to git on a schedule. The config *is* the record; drift is visible the moment it happens. |
| **Services piled on the wrong box** (Pi01 runs DNS + RADIUS + vault + Root CA; proposal to run services on the 1 GiB core router) | One SD-card Pi is a single point of failure for the whole PKI | **The router routes, the switch switches, the firewall filters, services live on hosts.** PVE01 has 62 GiB idle. |
| **Root CA on a networked, multi-service host** | Own Pi01 → own the Root CA → own everything | **Offline Root CA** (encrypted USB, air-gapped signing); online Intermediate only. |
| **Flat east-west** — every VLAN can reach every VLAN because they share a router | Strong perimeter, soft interior = one foothold owns the building | **Segmentation with an east-west firewall**, default-deny between segments (Book 11). |
| **Controls asserted, never tested** — an NTP "tick," a SPAN port never plugged in, a stale UTM profile | A control you didn't test is a hope | **Prove it:** test the deny, plug the tap into an IDS, verify the clock reads synced — not the config line. |
| **No backups; none ever restore-tested** | A backup you haven't restored is a hope | **PBS + restic off-site + Game Days** (`ADR-0011`) — restore something, on purpose. |
| **Flat, contested doc numbering** (Book 1/Book 2 both use 001–014) | The Source of Truth silently wouldn't place | **The git restructure** (`governance/` + `labs/` + `devices/`) — numbering collisions dissolve. |

> The single highest-leverage item on that list is **NetBox**. Nearly every recurring Atlas defect is a source-of-truth failure. Fix the source of truth structurally and most of the rest stop happening.

---

## 2. Active Directory — you have one. Use it as the identity backbone (deliberately).

`Atlas-Service-Architecture.md` Part 6 assumes you have **no** real AD yet, so it scopes `DC01-LAB` to a throwaway RADIUS test and says "destroy it before Book 3." **You have a working AD, so that framing is out of date — and that's good news.** You have two honest paths:

- **Path A — AD is the lab's identity provider, from now.** Deliberate, tiered, in scope. Collapses "the Microsoft lab" into the foundation instead of deferring it. **Recommended, given you have WinServer semesters and want to grow** — but only if you hold the scope with a tiered design (below), or it sprawls exactly the way Part 6 warns.
- **Path B — keep AD scoped** to NPS/RADIUS testing now; build the "real" AD later to Microsoft's reference. Lower risk, slower.

**This is a decision worth an ADR** (it supersedes the `DC01-LAB`-is-a-throwaway stance in Part 6 and extends `ADR-0004`). If you pick A, here's what AD actually plugs into — the "LDAP functions" you mentioned and more:

| AD integration | What it gives you | CCNA / enterprise relevance |
|---|---|---|
| **NPS (RADIUS)** for SW01 / MKT01 / FGT01 admin logins | Network-device admin auth against **AD accounts**, not local users | The CCNA AAA topic, done the enterprise way (`ADR-0004`: NPS for domain, FreeRADIUS for non-domain devices — a real coexistence, not a bake-off) |
| **LDAP / LDAPS** for service auth | NetBox, Grafana, LibreNMS, Proxmox, Vaultwarden all authenticate users against AD | One identity everywhere. **LDAPS, not LDAP** — plain LDAP is cleartext; bind over TLS (this is a CIS/NIST control in itself) |
| **AD-integrated DNS** | Authoritative DNS for the domain; Pi-hole stays the filtering forwarder | The `ADR-0003`/`ADR-0007` boundary: domain machines use AD DNS, non-domain use Pi-hole. Coexistence, not replacement. |
| **PDC-emulator as the NTP authority** | The domain's time source; Kerberos *forces* the hierarchy to be correct | **Already decided in `ADR-0020`.** This is the clean answer to the SW01 clock problem — the AD you have is the target. |
| **GPO** | Push CIS-benchmark hardening to Windows servers/clients; drive WDS/PXE on VLAN 60 | Config-as-policy for the Windows estate; the Deployment VLAN finally has a job |
| **AD CS (decision)** | Enterprise PKI for domain machines | `ADR-0003`: domain machines → AD CS, non-domain → the OpenSSL Lab CA. Same domain-membership boundary as RADIUS and DNS. |

**The security part that matters most: tiering.** Microsoft's tiered admin model is the enterprise pattern and a genuinely important lesson:

- **Tier 0** = identity itself — Domain Controllers, AD CS, the tools that manage them. Highest trust. Put DCs in their **own protected segment** (a dedicated server/identity VLAN), not the general server VLAN.
- **Tier 1** = servers/applications.
- **Tier 2** = user workstations.
- 🔴 **The rule: a credential from a higher tier never logs into a lower tier.** You do not RDP to a workstation with Domain Admin. This is how real breaches escalate, and practicing the discipline is the point.

---

## 3. Security zones — the part you said is rough. Here's the mental model.

**A VLAN and a zone are not the same thing, and conflating them is the usual stumble.**

- A **VLAN** is a broadcast domain / subnet — Layer-2/3 *separation*. It answers "who shares a wire."
- A **zone** is a **trust level that a firewall enforces policy between** — it answers "who is allowed to talk to whom, and who watches." A zone can contain one VLAN or several. Policy is written **between zones**, not between interfaces.

You already have the VLANs. Zoning is grouping them by trust and drawing the firewall policy across the boundaries. A workable starter model for Atlas:

| Zone | VLAN(s) | Trust | Posture |
|---|---|---|---|
| **Untrusted** | Internet (wan) | none | deny inbound; control outbound |
| **DMZ** | 80 | low | reachable from outside for specific services; **must not reach the interior** |
| **Identity (Tier 0)** | DCs (carve from 20, or a new VLAN) | highest | almost nothing talks *to* it except auth; it talks *out* to manage |
| **Servers (Tier 1)** | 20 | high | reached by clients on named ports only |
| **Web/App** | 30 | controlled | talks to Servers; three-tier pattern |
| **Clients (Tier 2)** | 50 | medium | reaches Servers + internet; not each other |
| **Monitoring** | 40 | special | reaches everything read-only (poll/log); **nothing reaches back** |
| **Management** | 10 | highest (infra) | admins reach devices; devices don't initiate to users |
| **Deployment** | 60 | controlled | PXE/WDS to Servers |
| **Testing** | 70 | isolated | internet only, no lab access (already done) |

### How to pick a rule — the reasoning you asked for

The method is small and it always works:

1. **Default is deny, and log the deny.** Every allow is an explicit, named exception. (A firewall whose default is "allow" is a router with opinions.)
2. **Write the rule in the direction the connection is *initiated*.** Stateful inspection handles the replies — you don't write a return rule.
3. **Name source, destination, and *service* (port).** Never `any → any`. If you can't name the port, you don't yet understand the flow.
4. **The justification for every rule is a service dependency.** If you can't say "X needs to reach Y on port Z *because*…", the rule shouldn't exist.
5. **Order matters** — firewalls match top-down and stop at the first hit. A broad allow above a specific deny silently wins. Specific-before-general.

Worked examples (the "good reasons"):

- **`Clients(50) → Servers(20) : 443` — allow.** *Reason:* the app users need lives on the server tier, over HTTPS. Nothing else between those zones.
- **`Monitoring(40) → all : SNMP/161, syslog is inbound-to-40` — allow one-way.** *Reason:* the poller must reach agents to collect; agents must never initiate a session *into* monitoring. One-directional by design — if monitoring is compromised it can read, but a compromised server can't pivot into your telemetry.
- **`DMZ(80) → Servers(20)` — deny (and log).** *Reason:* the DMZ is the zone most likely to be popped (it's internet-facing). A compromised DMZ host reaching the interior is exactly the lateral movement segmentation exists to stop. If a DMZ app genuinely needs one backend call, that becomes a *single* named allow to *one* host on *one* port — not "DMZ → Servers."
- **`Clients(50) → Clients(50)` — deny.** *Reason:* workstations have no business talking to each other; that's how worms and ransomware spread laterally. (This is microsegmentation's entry point.)

> The deep version of all of this — stateful vs stateless, NAT placement, NGFW/UTM, IDS/IPS, the reachability-matrix test — is already in `Atlas-Firewall-Architecture.md`. Read §3 (the capability catalogue) and §4 (the Book 11 design bar). It's written exactly for this question.

**The one discipline that prevents the #1 real-world failure:** don't "allow any-any to make it work during bring-up and never tighten." Build the **allowed-flows matrix** (segment × segment × service) on paper *first*; let the rules fail closed; open one flow at a time and **test that the deny actually denies.**

---

## 4. NIST and CIS — how to actually use them (not just cite them)

They do different jobs; use both:

- **CIS Benchmarks** = per-device hardening config. You already do this (`045`/`046`/`047`). **Extend the pattern to every OS/device** — Windows Server, Debian, Proxmox, FortiOS, IOS. This is the "how do I configure *this box* securely" answer.
- **CIS Controls v8** = a prioritized list of 18 control areas (inventory, secure config, data protection, access control, **log management**, etc.), with **Implementation Group 1 (IG1)** scoped for small environments. Use IG1 as your **coverage checklist** — "am I doing the basics everywhere," not per-device.
- **NIST CSF** (Identify → Protect → Detect → Respond → Recover) = the **umbrella to organize the whole lab's posture.** Map each book to a function: NetBox/inventory = *Identify*; firewall/hardening/PKI = *Protect*; syslog/SNMP/IDS/SIEM = *Detect*; runbooks = *Respond*; backups/Game Days = *Recover*. When someone asks "what's your security program," this is the shape of the answer.
- **NIST 800-207 (Zero Trust)** = the *why* behind east-west segmentation: assume breach, verify explicitly, least privilege per-flow. It's the north star for the Book 11 firewall work.
- **NIST 800-53 / 800-171** = deep control catalogs. Reference material; 800-171 (protecting CUI) is the more digestible subset for a lab.

**Practical stack:** CIS Benchmarks harden the boxes → CIS Controls v8 IG1 checks your coverage → NIST CSF organizes the books → 800-207 guides the segmentation. That's a real, defensible security program at lab scale.

---

## 5. The services you're new to — learn them in this order

They build on each other; do them in sequence, all on **MON01** (VM on PVE01, VLAN 40). **None of them mean anything without synchronized clocks** — so the NTP/`ADR-0020` work comes first.

1. **Syslog** (`rsyslog` → MON01). Centralized logging. The foundation. Every device ships its logs off-box. *Teaches:* log shipping, retention, and the principle that a device must not be the only place its own logs live (a compromised box loses its evidence). *Dependency:* synced clocks, or correlation is impossible.
2. **SNMP** (**v3**, agents → LibreNMS on MON01). Health/metrics polling + traps. *Teaches:* the poller/agent model, thresholds, alerting — and LibreNMS **auto-draws your topology from LLDP**, which is instant visual proof your documentation is right. 🔴 Use **SNMPv3**, never v2c (v2c is the cleartext `homelab` community you already have live).
3. **NetFlow** (RouterOS/IOS **export** → collector like ntopng/nfdump on MON01). Flow accounting — *who* talked to *whom*, how much. *Teaches:* traffic visibility, and critically it **shows you your real east-west flows before you write segmentation rules** — you design the allowed-flows matrix from evidence, not guesses. 🔴 Devices export; the collector must be a real host.
4. **SIEM** (later — Wazuh or Security Onion, Book 6). Correlation + detection across all the above + the IDS. *Teaches:* detection engineering. Heavy (4–8 GB); depends on syslog + clocks + something to detect (the **Suricata IDS on the SPAN port you already built and never plugged in**).

> The through-line: **syslog and SNMP give you operational visibility; NetFlow shows you the flows; the IDS gives you security telemetry; the SIEM correlates it.** Build up, don't start at the top.

---

## 6. Automation — you know nothing yet; here's the gentle on-ramp

The golden rule: **don't automate a mess. Get a source of truth first, then automate *from* it.** Order matters more than tooling:

1. **Oxidized → git.** Not "automation" exactly, but it's the gateway: config-as-record, drift detection, zero risk (read-only pulls). Start here.
2. **NetBox.** The source of truth every later step reads from. Without it, automation just makes mistakes faster.
3. **Ansible, read-only first.** Your first playbook runs `show version` across every device and prints it — that's "hello world," and it's *safe*. Then render device configs **from NetBox** with Jinja templates (the modern pattern). Idempotent, reviewable, revertible.
4. **Terraform** (Proxmox provider). VMs as code. Later — Ansible before Terraform, because your network devices already *exist* (Ansible configures what exists; Terraform creates what doesn't).
5. **CI** (git → validate → apply). The mature end state, once you trust the above.

**First concrete step:** Oxidized backing up configs, plus one Ansible inventory + a `show`-only playbook. That's a weekend, it's low-risk, and it makes every later step possible.

---

## 7. Consolidated phase plan (folds in AD, maps to the restructure + NIST CSF)

This reconciles `Atlas-Service-Architecture.md` Part 8 with "you have an AD" and the git restructure. Do the **restructure at the freeze** (clean `governance/` + `labs/` + `devices/` tree) — then build on it.

```
PHASE 0 — Freeze + restructure           (you're nearly here)
  ├── Close/defer the open device CMs (SW01 clock, SPAN, SNMP; PVE01 RTC; MKT01 firmware)
  ├── git tag pre-restructure; run the restructure on a branch
  └── Buy: UPS, CR2032, FTDI cable (~$170) — highest value per dollar in the lab

PHASE 1 — Foundation of truth            [CSF: Identify]
  ├── NETBOX01  <- source of truth FIRST; 006 becomes a rendered export
  ├── Oxidized -> git (config as record, drift detection)
  └── Pi01 reduced to DNS + NTP

PHASE 2 — Identity backbone (AD)         [CSF: Protect]   <- the "should I have an AD" answer
  ├── Promote your AD deliberately, TIERED (Tier 0 DCs in a protected segment)
  ├── NPS (RADIUS) for device admin  +  LDAPS for service auth (NetBox/Grafana/Proxmox/…)
  ├── PDC-emulator = NTP authority (ADR-0020)  +  AD-integrated DNS (Pi-hole coexist)
  └── Decide AD CS vs Lab CA (ADR-0003); GPO-push CIS hardening to Windows

PHASE 3 — Visibility                     [CSF: Detect]
  ├── MON01: rsyslog -> SNMPv3/LibreNMS -> NetFlow -> Uptime Kuma
  ├── Suricata on the SPAN port (Gi1/0/5) — free east-west telemetry
  └── Point SW01 SNMP at MON01 (it currently points at a host that doesn't exist)

PHASE 4 — Segmentation                   [CSF: Protect, the zero-trust core]
  ├── 1941 = core router; MKT01 = dedicated east-west firewall (Book 11)
  ├── Write the allowed-flows matrix FROM NetFlow evidence; default-deny + log
  └── Reachability-matrix Game Day: prove the denies actually deny

PHASE 5 — Resilience                     [CSF: Recover]
  ├── PBS on BKP01; restic/borg off-site
  └── GAME DAY: restore something. It has never been done.

PHASE 6 — PKI hardening + automation     [CSF: Protect + maturity]
  ├── Root CA offline; Intermediate on CA01; Vaultwarden off Pi01
  └── Ansible (render from NetBox) -> Terraform -> CI

THEN: CCNP depth, MSP/multi-VDOM scenarios (Atlas-Roadmap-Advanced-Scenarios.md)
```

**On scrapping books:** you don't lose the work — Book 5 (Monitoring) folds into Phase 3, Book 7 (Backup) into Phase 5, Book 11 (Core redesign) into Phase 4. The restructure's `labs/` + `devices/` tree is what lets these be *phases of one coherent lab* instead of numbered silos that drift apart.

---

## 8. The five principles, if you keep nothing else

1. **Source of truth is a database, not a document** (NetBox). Everything else is downstream of this.
2. **Separate the planes** — routing, filtering, services, identity each on the box built for it.
3. **Default deny, log the deny, test the deny.** A control you didn't test is a hope.
4. **Synchronized clocks first** — logs, Kerberos, certs, correlation all die without them.
5. **Build up the visibility stack before the security stack** — you can't segment flows you can't see, or detect on logs you don't collect.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-16. Consolidates the "before the next lab" design questions: current-lab anti-patterns to avoid; **using an existing AD as the tiered identity backbone** (updates `Atlas-Service-Architecture.md` Part 6's throwaway-DC stance — warrants an ADR); zones-vs-VLANs and the rule-selection method (with worked examples); how to actually use NIST CSF/800-207 + CIS Benchmarks/Controls v8; the syslog→SNMP→NetFlow→SIEM learning order; the automation on-ramp (Oxidized→NetBox→Ansible→Terraform); and a consolidated CSF-mapped phase plan that folds the old books into the restructured tree. Builds on `Atlas-Service-Architecture.md` and `Atlas-Firewall-Architecture.md`; does not replace them. |
