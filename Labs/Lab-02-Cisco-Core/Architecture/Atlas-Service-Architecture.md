---
Title: Atlas Service Architecture and Device Role Plan
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Draft — design proposal. Nothing here is built. Seated as the Lab-02 architecture spine 2026-07-17. **Reconciled 2026-07-28 (see the CURRENT DESIGN banner).**
Version: 1.3
---

# Atlas Service Architecture and Device Role Plan

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **This document is a proposal, not a record.** Every device figure below was read off a device or out of a Build Record. Every recommendation is argued. **Disagree with any of it — but disagree with the argument, not the conclusion.**

> 🔴 **CURRENT DESIGN (2026-07-28) — reconciled to the settled ADRs; supersedes any conflicting detail in the narrative below.** This spine still argues the *why* well, but several concrete calls are now decided. Read these as authoritative and treat the older narrative (Pi01's four roles, the CA01/OpenSSL split, the "DC01-LAB throwaway NPS box") as historical context:
> - **DHCP → DC01** (Windows DHCP, `ADR-0030`; **not** Kea on SRV01); MKT01 relay → `10.20.0.2`; DC02 hot-standby later.
> - **PKI = AD CS only** — issuing **ICA01** (`10.20.0.4`) + offline **RCA01**; the **OpenSSL Lab CA is retired** (`ADR-0031`), **CA01 is not built**, and the **CA01-VAULT01 joint host is decommissioned** (Vaultwarden survives standalone — web console, AD CS cert).
> - **Network-device RADIUS → NPS on a dedicated `NPS01` member server** (`10.20.0.12`, `ADR-0029` v1.1; FreeRADIUS retired, **not** on SRV01/DC). FGT01 = direct LDAPS (`ADR-0028`).
> - **SRV01** = nginx CRL host + Oxidized + TFTP/SFTP + rsyslog (**no DHCP, no FreeRADIUS**); **NTP = Pi01/PDCe**, not SRV01.
> - **Identity** = full **DC01 + DC02** on `atlas.lab` (`ADR-0021`/`ADR-0025`) — the "DC01-LAB throwaway RADIUS box" framing in Part 6 is superseded (already flagged there).

> **Scope (2026-07-29, `POL-0008`).** This is the **design** doc — *why* each service exists and *where* it lands (roles, silos, blast-radius, hardware). It is **not** the build order: the estate sequence + gates + dependency map live in `../Operations/Build-Order-and-Dependencies.md` (`ADR-0043` / register E2). **Part 8 — Sequencing** below is superseded by that owner (kept for its rationale). Addresses → the IP plan; decisions → the ADRs.

## The one-sentence thesis

> 🔴 **The router routes. The switch switches. The firewall filters. Services live on hosts.**
>
> **PVE01 has 62 GiB of RAM. MKT01 has 1 GiB and is the default gateway for every VLAN you own. That single comparison decides almost everything below.**

---

# Part 1 — The correction I owe you

**You said: *"I think the mikrotik should host most of these services for now."***

🔴 **I think that is the wrong call, and I want to make the case plainly before we build anything on it.**

| Device | RAM | Role |
|---|---|---|
| **MKT01** (RB1100AHx4 Dude Ed.) | 🔴 **1 GiB total, 830 MiB free** | **Default gateway for all nine VLANs.** East-west firewall. Every packet in the lab. |
| **PVE01** (Dell R410) | 🟢 **62 GiB usable**, 16 logical CPUs, ~793 GB thin storage | Hypervisor. **Currently near-idle.** |

**Running services on MKT01 means:** a memory leak in a syslog collector takes out **inter-VLAN routing for the entire lab.** A disk-full on the config archive takes out **your default gateway.** A container update reboots **the device every VLAN depends on.**

> **You would be putting your control plane and your services plane in the same failure domain, on the box with 1 GiB of RAM, when a 62 GiB hypervisor sits next to it doing nothing.**

**And there is a second reason, which matters more for the CCNA:** **an enterprise does not run its syslog server on its core router.** If Atlas is a rehearsal for real infrastructure, this is one of the things it should rehearse correctly.

### What MKT01's 64 GB SSD IS good for

**It is not useless — it is just not a services platform.** Legitimate uses:

- **Local config export archive** — `/export` files on the box, pulled off by Oxidized. Survives a reboot; costs nothing.
- **Firmware/`.npk` staging** for upgrades.
- **The Dude** (MikroTik's own monitoring) — *if* you want it. **I would not.** LibreNMS is better, vendor-neutral, and teaches transferable skills. **The Dude teaches you The Dude.**
- **Container host — technically possible** (RouterOS 7 has containers) and 🔴 **I recommend against it on the core router.** Try it on the 1941-era spare hardware or a second MikroTik if you ever get one. **Not on the box every VLAN routes through.**

---

# Part 2 — Where every service actually goes

## The platform: PVE01

**62 GiB usable, working budget ~54 GiB after host reserve.** The service estate below fits in **~20 GiB.** You have room to spare, and you do **not** need to buy hardware to run any of it.

## The hosts

| Host | Where | VLAN | RAM | Purpose |
|---|---|---|---|---|
| **Pi01** *(existing)* | Raspberry Pi | 10 | — | 🔴 **REDUCED to DNS + NTP only.** See below. |
| 🆕 **SRV01** | VM on PVE01 | **20 Servers** | 4 GB | **Network services:** TFTP, SFTP, NTP, Oxidized, rsyslog relay |
| 🆕 **MON01** | VM on PVE01 | **40 Monitoring** | 8 GB | **LibreNMS, Grafana, NetFlow collector, syslog** |
| 🆕 **NETBOX01** | VM on PVE01 | **20 Servers** | 4 GB | 🔴 **Source of truth. The most important host on this list.** |
| 🆕 **VAULT01** | VM on PVE01 | **20 Servers** | 2 GB | Vaultwarden — **moved off Pi01** |
| 🆕 **ICA01 / RCA01** | ICA01 = VM on PVE01; RCA01 offline | ICA01 `10.20.0.4` | 2 GB | 🔴 **AD CS: issuing `ICA01` + offline root `RCA01`. OpenSSL `CA01` retired — `ADR-0031`.** |
| 🆕 **BKP01** | VM (later: bare metal) | 20 | 4 GB | **Proxmox Backup Server** |
| 🆕 **DC01 / DC02** | VMs on PVE01 | 20 (Tier-0) | 4 GB ea | 🔴 **Full AD (`atlas.lab`) — `ADR-0021`/`ADR-0025`. The old "DC01-LAB throwaway NPS box" framing is superseded (Part 6).** |
| **LabComputer** *(existing)* | Physical | 10 | — | **Analyzer.** Wireshark on the SPAN port, `iperf3`, packet crafting. **No production services on a desktop.** |

## 🔴 Pi01 — cut it down to almost nothing

**Today Pi01 runs:** Pi-hole **+** FreeRADIUS **+** Vaultwarden **+** the Root CA **+** the Intermediate CA. **Four production services and your entire PKI, on one SD-card-booted Pi that has already had an unexplained hard hang with no root cause.**

**Proposed Pi01: DNS and NTP. That's it.**

| Service | Verdict |
|---|---|
| **Pi-hole (DNS)** | 🟢 **KEEP.** Latency-sensitive, tiny, and the Pi is genuinely the right box for it. |
| **NTP (chrony)** | 🟢 **ADD.** Trivial footprint. Gives you a lab stratum source, which the CCNA wants. |
| **FreeRADIUS** | 🔴 **RETIRED (`ADR-0029`).** Network-device RADIUS = **NPS on `NPS01`** (member server, `10.20.0.12`) — not SRV01, not the DC. FGT01 = direct LDAPS (`ADR-0028`). |
| **Vaultwarden** | 🔴 **MOVE off Pi01 — standalone** (web console, AD CS cert). Holds the CA/DSRM/break-glass passphrases; not co-located with a CA (`ADR-0031` — CA01-VAULT01 joint host decommissioned). |
| **Root CA** | 🔴 **MOVE OFFLINE.** Not to another server. **Offline.** See Part 4. |
| **Intermediate / Issuing CA** | 🔴 **AD CS `ICA01`** (enterprise issuing) — not a separate OpenSSL `CA01` (retired, `ADR-0031`). |

> **The Pi is not underpowered. It is over-trusted.** Everything on it is a single point of failure for something else, and one of those things is your entire PKI.

---

# Part 2A — Who owns what: the estate mapped to the silos (`ADR-0018`)

`ADR-0018` is now **Accepted**, and the service estate above maps onto its five silos almost one-to-one. This is not decoration — it sets which silo owns each host, which Ansible service account may configure it, and (per the boundary rule) which builds cross a boundary and therefore need a Change Record.

| Silo | Owns in this lab | Boundary notes |
|---|---|---|
| 🔵 **Network Infrastructure** | The 1941 core, MKT01 (re-roled to east-west firewall), SW01, FGT01, the VLANs, the IT/OT conduit (`305` Part 2) | The firewall *box* is 🔵; the firewall *policy* on it is 🔴. Silos own functions, not boxes. |
| 🟢 **Systems / Compute** | PVE01, every VM's lifecycle, Proxmox, storage, BKP01 | Owns the hosts SRV01/MON01/CA01 *run on* — not the services inside them. |
| 🔴 **Security / PKI** | CA01 (Intermediate), the offline Root, VAULT01, firewall *policy*, RADIUS, IDS/Suricata, the CIS baselines, data classification (`305` Part 1) | May audit Network and Systems; the Tier-0 identity carve-out (`305` Part 4) is its boundary. |
| 🟡 **Network Services** | Pi01 (DNS/NTP), SRV01 (nginx-CRL/TFTP/SFTP/Oxidized/rsyslog), MON01 (LibreNMS/Grafana/NetFlow/syslog), **DHCP on DC01** (`ADR-0030`) | Owns the services; not the devices they monitor, not the network they run on. |
| ⚪ **Platform / DevOps** | NETBOX01 (source of truth), Ansible, Terraform, Oxidized-to-git, CI, the repo | Production changes flow *through* automation. NetBox's schema is its to change; live state is not. |

> **Read this next to the build order in Part 8.** Each phase there is owned by a silo in this table, and the phases that cross into 🔴 Security — PKI, firewall policy, the Tier-0 boundary — are the ones that carry a Change Record. That is `ADR-0018` doing real work on this lab, not a poster on a wall.

---

# Part 3 — 🔴 The single most important recommendation in this document

## NetBox

**`006-Network-Source-of-Truth.md` is a 155-line Markdown file that declares itself authoritative for every MAC address and port assignment in the lab.**

**It has already been wrong.** `016` lesson 6 records it: **four `STATIC-HOSTS` entries where five are required. Pi01 simply missing.** SW01 runs `DHCP Permits: 0` with no DAI fallback, so a host missing from that ACL is **dropped, silently** — and it produced a false *"Pi01 should be unreachable"* mystery that survived **three handoffs.**

> 🔴 **A source of truth that a human maintains by hand is a source of truth that will be wrong, and you will not find out until something is silently dropped.**

**NetBox is the industry answer to exactly this problem.** It is a DCIM/IPAM database: devices, interfaces, MACs, IPs, VLANs, cables, racks. **It has an API.** It is what Ansible and Terraform *pull from*.

**What it buys you, concretely:**

1. **One place that knows every MAC.** SW01's `STATIC-HOSTS` ACL gets **generated** from it, not hand-typed. **The Pi01 omission becomes structurally impossible.**
2. **The iDRAC problem disappears.** When you move the iDRAC to its dedicated NIC (`050`), its MAC changes — and today, if you forget SW01's `STATIC-HOSTS`, **DAI drops it silently.** With NetBox, the MAC is a field; the ACL is generated; the change propagates.
3. **It is the foundation of every IaC ambition you have.** Ansible playbooks that render device configs from NetBox is *the* modern network-automation pattern. **You cannot do meaningful IaC without a source of truth, and a Markdown table is not one.**
4. **It teaches the thing employers actually want.** NetBox is on job descriptions.

🔴 **Nearly every recurring defect in Atlas is a source-of-truth failure.** Four devices where five exist. RADIUS rules pointing at a pre-VLAN address. SNMP pointing at `10.40.0.52`, a host that does not exist. `022` never recording `mac-server`. **NetBox is the structural fix.**

> **`006` doesn't get deleted — it becomes a rendered export of NetBox, generated, never hand-edited.**

---

# Part 4 — 🔴 The Root CA goes offline. Properly.

**Today:** the Root CA private key sits on a networked Raspberry Pi that also runs DNS, RADIUS, a password vault, and Docker. **That Pi has had an unexplained hard hang.** `CM-0014` exists because that CA's backup passphrase leaked.

**The correct enterprise pattern — and a genuinely great learning exercise:**

| Tier | Where it lives | When it's used |
|---|---|---|
| 🔴 **Root CA** | **Encrypted removable media. In a drawer. Powered off.** | **Only to sign a new Intermediate.** Roughly: once. |
| **Issuing CA** | **`ICA01`** — a VM, online (AD CS; OpenSSL `CA01` retired, `ADR-0031`) | Signs every device certificate |
| **Issued certs** | The devices | Always |

**How you actually use an offline Root:**

1. Root key lives on an encrypted USB stick (LUKS). **Two copies. One off-site.**
2. To sign an Intermediate, you boot a **live Debian USB** on an air-gapped machine, mount the key, sign, unmount.
3. **The Root key never touches a networked machine again.**

> **This is a weekend project, it is exactly what real PKI looks like, and it turns `CM-0014` from an embarrassment into the reason you learned to do it right.**

**And it makes the Root CA's compromise radius finite:** an attacker who owns Pi01 today owns your Root CA. **After this, they own an Intermediate you can revoke.**

---

# Part 5 — The service catalogue

## 5.1 Network services (Book 10 — the CCNA layer)

| Service | Where | Why it earns its place |
|---|---|---|
| 🔴 **Oxidized** | SRV01 | **Config version control.** Pulls the running config off SW01, FGT01, MKT01, the 1941 — on a schedule — and **commits it to git.** You said *"I'm not sure we have the current IOS of the switch."* **Oxidized answers that permanently, and it will tell you the moment a config drifts.** **Given how much of tonight was "the document disagreed with the device," this is the highest-value service on the list after NetBox.** |
| **TFTP** (`tftpd-hpa`) | SRV01 | IOS image transfer, config backup. **Pure CCNA.** |
| **SFTP** | SRV01 | The grown-up version. **Use TFTP because the exam wants it; use SFTP because production does.** |
| **NTP** (`chrony`) | Pi01 | Stratum source. All devices become clients. **CCNA topic, and it fixes PVE01's clock drift symptom.** |
| **rsyslog** | MON01 | Every device ships logs here. |
| **SNMP** | agents on devices → **LibreNMS** on MON01 | 🔴 **Rotate the `homelab` community first — it is live and cleartext.** Then move to **SNMPv3**, which is the CCNP answer. |
| **NetFlow** | MKT01/1941 export → **ntopng** or **nfdump** on MON01 | **RouterOS exports. It does not collect.** Same for IOS. **The collector must be a real host.** |
| **CDP/LLDP** | devices → LibreNMS | 🔴 **LibreNMS draws an automatic topology map from LLDP.** That map is the visual proof your documentation is right. **Instant payoff.** |
| **QoS** | SW01, MKT01, 1941 | 🔴 **You cannot demonstrate QoS without congestion.** Install **`iperf3`** on LabComputer and a VM. **Generate the congestion, then prove the policy changed the outcome.** Otherwise you have configured QoS and proven nothing — `016` lesson 4. |
| **DHCP** (Windows) | **DC01** (`ADR-0030`) | **VLAN 50 (Client) is empty and static.** SW01 already runs **DHCP snooping with `DHCP Permits: 0`** — so introducing DHCP is a *real* exercise in a *real* constraint. **This is a superb lab.** |
| **PXE boot** | SRV01 | 🔴 **VLAN 60 (Deployment) exists, is routed, and is completely empty.** PXE + TFTP is what it was built for. |

## 5.2 Monitoring and logging (Book 5)

| Service | Where | Note |
|---|---|---|
| **LibreNMS** | MON01 `10.40.0.20` | 🔴 **The address is ALREADY in `006`.** Someone planned this and never built it. |
| **Grafana** | MON01 `10.40.0.30` | Same. |
| **ntopng / nfdump** | MON01 | NetFlow collection |
| **Uptime Kuma** | MON01 | **Trivial to run, disproportionately satisfying.** Up/down for everything. |
| **Wazuh** | MON01 `10.40.0.10` | Planned in `006`. **Heavy (4-8 GB). Defer to Book 6.** |
| 🔴 **Suricata or Zeek** | LabComputer or a VM | **SW01 `Gi1/0/5` is a SPAN port mirroring the MKT01 trunk, and it is usually unplugged.** **You have a tap and nothing on it.** Plug an IDS in. **This is free security telemetry you already built and never used.** |

🔴 **Fix `023`'s SNMP target while you're here:** SW01 points SNMP at **`10.40.0.52` — a host that does not exist.** Point it at MON01.

## 5.3 Backup and replication (Book 7 — currently 🔴 *"there are no backups of anything, anywhere"*)

| Layer | Tool | Why |
|---|---|---|
| **VM backup** | **Proxmox Backup Server** on `BKP01` | Dedup, incremental, **verify jobs**. Native to Proxmox. |
| **Device configs** | **Oxidized → git** | Continuous. **Every config, every version, diffable.** |
| 🔴 **Off-site** | **restic** or **borgbackup** → an external drive **and/or** Backblaze B2 / rsync.net | **This is Roadmap Critical Risk #1.** Both copies of your CA archive are **in the same room.** **A single fire takes the Root CA, the Intermediate CA, every RADIUS secret and the vault, in one event.** |
| **VM replication** | **Proxmox ZFS replication** → PVE02 | Needs a second node. See Part 7. |
| 🔴 **RESTORE TESTING** | **`ADR-0011` Game Days** | **No device backup in this lab has ever been restored. Not one.** A backup you have not restored is a hope. |

**The NAS question.** You asked. My answer:

- **Not TrueNAS.** It's excellent, and it's an *appliance* — you'd learn TrueNAS, not Linux.
- **Not Mint.** Desktop distro on a server.
- 🟢 **Debian + ZFS + Samba/NFS.** **Proxmox is Debian. Raspberry Pi OS is Debian.** One distro family across the estate = one set of habits, one package manager, one init system. **You asked to learn Linux. This is how you learn it — by building the thing, not installing the appliance.**

---

# Part 6 — 🔴 The Domain Controller trap, and how to avoid it

> ⚠️ **Reconciliation note (2026-07-17).** The operating decision has since changed: **Lab-02 holds both the network/segmentation track and the Windows/identity track, built in tandem** — one lab, driven by the bound `301`/`305` scenario. That **supersedes this Part's "separate, later lab" framing and its "DC01-LAB is DESTROYED" throwaway stance** — `DC01`/`DC02` are built for real here. The scope-creep risk this Part names is real and still worth respecting; it is now managed with eyes open rather than by deferral. Because this reverses an argued position, it is being captured in its own ADR (pending). **Until that ADR lands, read Part 6 below as historical context for *why* the trap exists — not as current scope.**

**You said: *"maybe we should have at least a domain controller to test radius"* — and also *"I don't want to start the Microsoft thing since that will be another lab."***

**Those two are in tension, and the tension is exactly how scope creep starts.** One DC becomes DNS. DNS becomes DHCP. Then GPO. Then a second DC for redundancy. **Then you are doing the Microsoft lab, badly, six months early, and Book 3's teardown is now a migration.**

**The resolution — and it needs an ADR to hold:**

> 🔴 **`DC01-LAB` is a single-purpose test appliance, not the beginning of the Microsoft environment.**
>
> **It may:** run AD DS **only** as a prerequisite for NPS, and serve **NPS/RADIUS** so you can compare it against FreeRADIUS on the same switch ports (`ADR-0004` explicitly anticipates this coexistence).
>
> 🔴 **It may NOT:** become the lab's DNS. Become the lab's DHCP. Hold GPOs. Gain a second DC. Have anything joined to it that isn't a test client.
>
> **When Book 3 begins, `DC01-LAB` is DESTROYED. It is not migrated. It is not promoted. It is deleted, and the Microsoft environment is built from Microsoft's own reference architecture, verbatim, as you said.**

**Write that down, or it will not hold.** Every homelab that ever sprawled did it exactly this way.

---

# Part 7 — Hardware. What to buy, in priority order.

| # | Item | Cost | Why |
|---|---|---|---|
| 🔴 **1** | **UPS** | ~$100–150 | **PVE01's CMOS battery is dead. It loses BIOS settings and its RTC on every full power loss.** `ADR-0017` names continuous power as the mitigation — **a UPS *is* that mitigation.** It also protects everything else. **Highest value per dollar in the entire lab, and it is not close.** |
| 🔴 **2** | **CR2032** | **$2** | Closes `CM-0012`. Unblocks `050`. **Unblocks nested virtualisation** (VT-x reverts on power loss) — **which you need for Hyper-V labs later.** |
| 🔴 **3** | **An FTDI-chipset USB-serial cable** | ~$20 | **You have bought three and none worked. That is not bad luck — it is almost certainly counterfeit Prolific PL2303 chips** (Windows drivers deliberately brick clones) **or CH340 driver issues.** **Buy one with a genuine FTDI FT232R.** It will work. **This closes the MKT01 console gap that `ADR-0016` had to defer.** |
| **4** | **External USB drive** for off-site rotation | ~$60 | **Roadmap Critical Risk #1.** Rotate it to work / a relative's house. |
| **5** | **Second Proxmox node (PVE02)** | varies | 🟢 **This is the purchase that unlocks replication, live migration and clustering.** **Not "more services" — you have 62 GiB doing nothing.** **Replication.** |
| **6** | **A cheap Raspberry Pi** | ~$40 | 🔴 **Corosync QDevice.** A two-node Proxmox cluster **cannot achieve quorum** (2 nodes, split brain). A tiny third voter fixes it. **A Pi is the canonical answer.** Elegant, cheap, and a genuinely satisfying piece of engineering. |
| **7** | **Disks for a NAS** | varies | ZFS on Debian. Mirror or RAIDZ1. |

**Note what is *not* on this list: a server to run services.** **You already have one, and it is 90% idle.**

---

# Part 8 — Sequencing

> 🔴 **Superseded as the order (2026-07-29).** The authoritative build sequence + gates now live in `../Operations/Build-Order-and-Dependencies.md` (`ADR-0043` / E2). This section is kept for its **rationale**; do not treat it as the live order.


> **Book-number reconciliation (2026-07-17).** The phase labels below use the **old global book numbers** the restructure retired when books became device-centric labs. They map to Lab-02 as follows — the *sequence* is unchanged, only the labels are reconciled. **Also:** the diagram's closing *"TEARDOWN → Book 3, DC01-LAB destroyed"* step is superseded by the tandem decision (see the Part 6 note) — the Windows track is built here, now, not after a teardown.
>
> | Old global label | Lab-02 home | Status |
> |---|---|---|
> | Book 2 — Virtualization | `Lab-02/Virtualization/` (201–217) | Exists, as-is, not reconciled to live |
> | Book 3 — Windows Infrastructure | `Lab-02/Windows-Infrastructure/` (302–304) | Exists, plan-only — built in tandem |
> | Book 10 — Network Services | Lab-02 services phase (SRV01, MON01, NETBOX01, Pi01-reduced) | Unbuilt — first build target |
> | Book 5 — Monitoring | folds into the services phase (MON01) | Unbuilt |
> | Book 7 — Backup | Lab-02 backup phase (BKP01, off-site, Game Day) | Unbuilt — Tier-1 risk |
> | Book 4 — PKI hardening | Lab-02 PKI phase (offline Root, CA01, VAULT01) | Unbuilt — greenfield, CRL from day one |
> | Book 11 — Core redesign | Lab-02 network re-arch (1941 core, MKT01 east-west, IT/OT boundary) | Unbuilt — the lab's headline |
> | Book 6 — Security / IaC | Lab-02 IaC phase (Ansible-from-NetBox, Terraform) | Unbuilt |

```
NOW (Book 1 frozen)
  └── Buy: UPS, CR2032, FTDI cable.        ~$170. Closes CM-0012, unblocks 050, gives MKT01 a console.

BOOK 10 — Network Services (CCNA)          No topology change. Runs on what exists.
  ├── NETBOX01     <- FIRST. Everything else pulls from it.
  ├── SRV01        <- nginx CRL, TFTP, SFTP, Oxidized, rsyslog  (NTP->Pi01, DHCP->DC01)
  ├── MON01        <- LibreNMS, Grafana, NetFlow, syslog, Uptime Kuma
  ├── Pi01 reduced <- DNS + NTP only
  ├── SNMPv3, CDP/LLDP, QoS + iperf3
  └── Suricata on the SPAN port you already built

BOOK 5 — Monitoring                        Folds into the above. It was never a separate book.

BOOK 7 — Backup                            🔴 The real risk.
  ├── BKP01 (Proxmox Backup Server)
  ├── restic/borg -> off-site
  ├── Oxidized -> git (already running from Book 10)
  └── 🔴 GAME DAY: restore something. Anything. It has never been done.

BOOK 4 — PKI hardening
  ├── Root CA -> OFFLINE (encrypted USB, air-gapped signing)
  ├── ICA01 (AD CS issuing, online) + RCA01 (offline root)   (OpenSSL CA01 retired)
  └── Vaultwarden (standalone, off Pi01, web console)

BOOK 11 — Core Redesign                    Gated: restore-tested backups + 1941 verified.
  ├── 1941 -> core router
  ├── MKT01 -> east-west firewall
  └── DC01-LAB -> NPS vs FreeRADIUS bake-off

BOOK 6 — Security / IaC
  ├── Ansible (rendering configs FROM NetBox)
  ├── Terraform (Proxmox provider — VMs as code)
  └── Wazuh

THEN: TEARDOWN. Book 3 — the Microsoft environment, built to Microsoft's reference
      architecture, verbatim. DC01-LAB is DESTROYED, not migrated.

THEN: Book 8 — CCNP.
```

---

# Part 9 — Things you didn't ask for and should have

**1. 🔴 `iperf3` is not optional.** You want QoS. **QoS without generated congestion is a config you have never tested.** Two endpoints and one command.

**2. 🔴 You already own a network tap and have never used it.** SW01 `Gi1/0/5`, SPAN, mirroring the MKT01 trunk. *"Usually unplugged."* **Plug it into an IDS.**

**3. Self-hosted git (Gitea/Forgejo) — worth considering.** You'd have a local origin **and** GitHub as an off-site mirror. **But you already have `CM-0020` open** — the pre-commit hook doesn't survive a clone. **Fix the control before you multiply the remotes.**

**4. 🔴 SNMP `homelab` is live, cleartext, v2c.** It's in `023`. **Rotate it before you point a collector at it, or you will have built a monitoring system whose credential is in a Git repo.**

**5. ~~Kea over ISC DHCP.~~** → **Superseded (`ADR-0030`): DHCP is Windows DHCP on DC01**, not Kea on SRV01 (driver: fewer VMs; AD-integrated DDNS). Kea rationale kept for history.

**6. Ansible before Terraform.** Ansible configures things that exist. Terraform creates them. **Your network devices exist. Start where the value is.**

---

# Part 10 — What this fixes

| Recurring Atlas defect | Structural fix |
|---|---|
| **Documents disagree with devices** | 🔴 **Oxidized** — the config *is* the record, pulled hourly |
| **Source of truth is wrong** (Pi01 missing from `STATIC-HOSTS`) | 🔴 **NetBox** — generated, not typed |
| **"Available" is not a state** | NetBox has states. Markdown has adjectives. |
| **No backups of anything** | **PBS + restic + Oxidized** |
| **Backups never restore-tested** | 🔴 **Game Days (`ADR-0011`) — and there is finally something to restore** |
| **Root CA on a networked multi-service Pi** | **Offline Root. Online Intermediate.** |
| **SNMP points at a host that doesn't exist** | **MON01 exists** |
| **The SPAN port has never been used** | **Suricata** |

> **Every one of these is a defect this project has already had, written down in its own lessons file. The architecture above is the shape of not having them again.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-14. Proposes the service estate, the device role split, the offline Root CA, the DC scope-creep firewall, and the hardware priority list. 🔴 **Argues against running services on MKT01** (1 GiB RAM, core router) when PVE01 has 62 GiB and is idle. **Names NetBox as the structural fix for Atlas's most-repeated defect class.** |
| 1.2 | 2026-07-28. **Reconciled to ADR-0029 v1.1 / 0030 / 0031** (cascade from Master-Build-Order v1.6). Added the **CURRENT DESIGN banner** (authoritative, supersedes conflicting narrative). Fixed the concrete rows: VM table `CA01`→**ICA01/RCA01** and `DC01-LAB`→**DC01/DC02**; "move FreeRADIUS to SRV01"→**retired, NPS on NPS01**; "move Intermediate to CA01"→**AD CS ICA01**; Vaultwarden→**standalone** (web console, AD CS cert); silo/service-map/tree **DHCP Kea/SRV01→DC01** and **CA01→ICA01**; Kea-vs-ISC rationale marked superseded. The DC01-LAB "throwaway NPS box" narrative (Part 6) remains under its 2026-07-17 superseded flag (`ADR-0025`). |
| 1.1 | 2026-07-17. **Seated as the Lab-02-Cisco-Core architecture spine** — moved from `00-Atlas-Foundation/` per `ADR-0008` (a document naming NetBox/LibreNMS/Oxidized/Kea/Suricata/PBS is technology, not process, and belongs to its lab). Added the provenance banner; **Part 2A** mapping the estate to the `ADR-0018` silos; a Part 8 reconciliation of the retired global book numbers to Lab-02 phases; and a Part 6 note recording the *"one Lab-02, both tracks in tandem"* decision that supersedes its defer-the-Microsoft-env / throwaway-DC01 stance (scope ADR pending). Content of the technical proposal itself is unchanged. |
