# ADR-0015 — Atlas Pack Sequencing and Scope Expansion

| Item | Value |
|---|---|
| Status | **Accepted** |
| Governing Policy | POL-0014 (+POL-0003) |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-14 |
| Decided by | Operator, 2026-07-14 |
| Related | `ADR-0011` (Game Days), `ADR-0012` (quarantine), `ADR-0013` (`bridgeLocal`), `ADR-0014` (MKT01 L2 posture), `Atlas-Charter.md` (pack lifecycle), `Atlas-Roadmap.md` |
| Evidence Status | **`Target Design`** — sequencing decision. Hardware claims marked **UNVERIFIED** where they are. |

> **This ADR exists because the plan lived in a chat session and nowhere else.** `ADR-0012` says: **write the repo file, then publish. Never the reverse.** This is that file.

## Context

The operator is studying for the **CCNA** and wants Atlas to serve that, then become a Microsoft enterprise lab, then a CCNP lab. New scope raised:

- **Network services:** SNMP, syslog, NetFlow, NTP, SSH hardening, CDP/LLDP, QoS, TFTP/FTP, IOS version management.
- **Topology change:** a **Cisco CISCO1941/K9** becomes the core router; **MKT01 moves to east-west firewall + services host.**
- **Offload Pi01**, which is carrying too much.
- **DevOps:** IaC (YAML, Ansible, Terraform) and a team-silo operating model.

## Decision 1 — Book 1 freezes before new work starts

**Book 1 is the as-built record of the network that exists.** New scope does **not** expand it.

> **If a pack absorbs every new idea, it never freezes, and the freeze criteria become decoration.** That is `016` lesson 10 — *a stale index does not merely fail to help; it actively tells you the work is done.*

**Book 1's remaining blockers — all five must be closed or ADR-deferred:**

| Blocker | Owner | State |
|---|---|---|
| **CM-0010** | Documentation | `043` Part 9 annotation; stale duplicate `Operations/07-Backup-and-Recovery-README.md`; `049` closeout un-staling. |
| **CM-0012** | 🔴 Hardware | **PVE01 CMOS battery.** Same chassis visit as the iDRAC dedicated-NIC move (`050`) and the SW01 `STATIC-HOSTS` update. |
| **CM-0014** | 🔴 Security | **Archive passphrase in Git history at `ac2182f`.** `ADR-0010` forbids making the repo public until purged. |
| **CM-0017** | Documentation | Needs `ADR-0014` accepted. |
| **CM-0018** | 🔴 Device | **MKT01 has no recovery path and no console.** Two live tests. |

## Decision 2 — Network Services first; the migration is designed in parallel, not executed

**The services pack runs on the network that already exists. Zero topology change.** It serves the CCNA directly and it can start the day Book 1 freezes.

**The core-router migration rebuilds the forwarding path of the entire lab.** It is designed in parallel and executed later, gated.

> **The services pack is what the CCNA needs. The migration is what the itch wants.** Doing the migration first means learning SNMP, syslog and QoS **on a network you are simultaneously rebuilding** — every failure ambiguous between "I configured it wrong" and "the topology moved under me."

## Decision 3 — Book structure

**Most of the new scope already has a home. Two new packs are needed.**

| Pack | Status | Contents |
|---|---|---|
| **01 Enterprise Network** | 🔒 **Freeze** | The as-built network. MKT01 as core router. |
| **05 Monitoring and Logging** | **Existing, unstarted** | **Syslog server, SNMP collector, NetFlow collector.** Already flagged *"highest-leverage unbuilt book — blocks nine open items."* |
| 🆕 **10 Network Services and Operations** | **New** | Device-side services: SNMP agents, syslog clients, NetFlow exporters, **NTP**, **SSH hardening**, **CDP/LLDP**, **QoS**, **TFTP/FTP**, **IOS version management**. **No topology change.** |
| 🆕 **11 Core Network Redesign** | **New — design only** | 1941 as core; MKT01 → east-west firewall + services host; Pi01 offload. **Not executed.** |
| **03 Windows Infrastructure** + **04 Identity and PKI** | Existing | **These already ARE the "Microsoft way" enterprise lab.** |
| **08 Labs** | Existing | **This is where the CCNP lab lives.** |
| **06 Security** | Existing | IaC, Ansible, Terraform, and the silo operating model. |

**Books 10 and 11 each require a `PACK-MANIFEST.md` at creation** — per the Charter, and per `016` lesson 10.

## 🔴 Constraints — recorded now so they are not discovered later

### The 1941 is a throughput downgrade, and the repo currently forbids it

**`009-Routing-Standards.md` states: *"Cisco 1941 routing labs remain outside the production forwarding path."*** Moving it in **reverses an accepted standard.** Book 11 must open with an ADR that does so explicitly.

- **The CISCO1941/K9 has two onboard Gigabit ports.** Nine VLANs means **router-on-a-stick** — every inter-VLAN packet hairpins through one subinterfaced link.
- **The 1941 is an ISR G2. Its real forwarding capacity is well below 1 Gbps.** It would replace an **RB1100Dx4** with **13 Gigabit ports** that routes these VLANs today.
- **For a CCNA lab this is an acceptable trade — hands-on IOS is the entire point.** 🔴 **But it is a trade, and it must be written down with numbers, not discovered under load.**

🔴 **UNVERIFIED and blocking Book 11's design:** the 1941's **IOS version, feature set (IP Base vs SEC), DRAM and flash.** **Some of the intended scope may require a licence that is not present.** **Required before Book 11 is designed:** `show version`, `show license`, `show inventory`.

🔴 **Also unverified:** SW01's IOS version. The operator has flagged uncertainty. **Required:** `show version`.

### RouterOS may not host the services we want it to host

🔴 **UNVERIFIED — must be confirmed on the device before Book 11 designs around it.**

| Service | Believed RouterOS capability | Confidence |
|---|---|---|
| **NetFlow** | **Exporter only** (Traffic Flow — v5/v9/IPFIX). **Not a collector.** | High |
| **Syslog** | **Client only** (remote logging). **Not a syslog server.** | High |
| **TFTP** | **Believed absent entirely.** | 🔴 **Medium — verify.** TFTP is what IOS image management needs. |
| **FTP** | Present — **and `026` §12 explicitly disables it.** Re-enabling reverses a hardening decision → ADR. | High |
| **SNMP** | Agent present. **Community `homelab`, v2c, cleartext, already live.** | Verified |

> **If this is right, "MikroTik hosts most of these services" is half true.** It can **export** NetFlow and syslog, serve FTP, and run The Dude. **The collectors need a real host** — which is exactly where the Pi01-offload instinct lands correctly. **Book 05 is the collector.**

**Verify with `/system package print` and `/system resource print` before Book 11 assumes anything.**

### 🔴 MKT01 has a 64 GB SSD that appears in no document

**MKT01 is an `RB1100Dx4`** (marketed as *RB1100AHx4 Dude Edition*), **serial `9BD90AB80B08`, with a 64 GB SATA SSD** — confirmed from `mkt01-pre-CM-0009.rsc`'s `/disk` section.

**The storage is recorded nowhere in the repository.** `022` and `026` correctly say *"Dude Edition"*; `001`, `006` and `016` say plain *"RB1100AHx4"*. **Nobody knew there was a disk.**

> **The single capability that makes the services plan viable was undocumented — and it surfaced from a file uploaded for an unrelated reason.** Corrected in `022` (`CM-0017`).

### Cleartext services must not live on the management plane

**FTP, TFTP, SNMPv2c and syslog-over-UDP are all cleartext.** For the CCNA, **that is the point** — they must be learned.

🔴 **They must not run on VLAN 10.** VLAN 10 holds every management interface in the lab, **plus the Lab CA, Vaultwarden and FreeRADIUS.** VLAN 30 (Web) and VLAN 60 (Deployment) are live, routed and empty. **Put the lab services there.**

### Pi01 is overloaded — and the first thing to move is the CA

**Pi01 runs Pi-hole + FreeRADIUS + Vaultwarden + the Root CA + the Intermediate CA.** Four production services **and the entire PKI**, on one SD-booted Pi that has already had an unexplained hard hang with no root cause.

> 🔴 **The Root CA should not be on a networked, multi-service host at all.** `CM-0014` exists because that CA's backup passphrase leaked. **Offloading is right — but the first thing to move is the CA, and the correct destination is offline, not another server.**

## Sequence

```
1. FREEZE BOOK 1          CM-0010, CM-0012, CM-0014, CM-0017, CM-0018
2. BOOK 10 (services)     runs on the existing topology. CCNA. Starts immediately after freeze.
   BOOK 05 (collectors)   syslog / SNMP / NetFlow collectors. Pairs with Book 10.
   BOOK 11 (design only)  1941 core, MKT01 role change, Pi01 offload. NOT executed.
3. BOOK 11 (execute)      gated: Book 10 complete, restore-tested backups exist, 1941 verified.
4. BOOKS 03 / 04          Microsoft enterprise lab.
5. BOOK 08                CCNP lab.
```

## 🔴 The gate on Book 11 that nothing currently satisfies

**No device configuration has ever been restore-tested. Not SW01, not FGT01, not MKT01, not PVE01.** `049` proved the **CA archive** restores. **Nothing else, ever.**

> **Ripping out the core router of a lab whose devices have no proven backups is the single riskiest thing on this roadmap.** **Book 11 does not execute until at least SW01 and MKT01 have a backup that has been restored and proven** — the same precondition `ADR-0013` sets for retiring `bridgeLocal`, for the same reason.

## Consequences

- **`009-Routing-Standards.md` will be reversed by Book 11.** That reversal is an ADR, not a change record.
- **`026` §12's service hardening will be partially reversed** (FTP). ADR.
- **`ADR-0014`'s discovery scoping will be revisited** — CDP/LLDP are CCNA syllabus and on this roadmap. **A decision that gets deliberately revisited is better than a default nobody chose.**
- **`Atlas-Roadmap.md` must be updated** to v3.0. Its dashboard currently claims Book 1 has *"All CM/MC records closed"* (three are open) and *"7 ADRs"* (there are fourteen). **The page whose own opening warns against exactly this has done it again.**
- **Book 09 Atlas Academy:** the Roadmap says *"do not start until sources are frozen."* **`ADR-0012` uses Academy as a quarantine for unverified content, which is not the same as starting it as a teaching book.** Both hold. Noted so the next reader does not have to work it out.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-14. Records the sequencing decision (freeze Book 1 → services → migration), creates Books 10 and 11, and writes down the constraints — the 1941's throughput and unverified licensing, RouterOS's probable inability to *collect* syslog/NetFlow or serve TFTP, MKT01's undocumented 64 GB SSD, the cleartext-services-off-VLAN-10 rule, and the fact that **no device backup has ever been restore-tested.** |
