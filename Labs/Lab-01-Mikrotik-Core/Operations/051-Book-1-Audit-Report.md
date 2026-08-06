---
Title: Book 1 Audit Report
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# 051 — Book 1 Audit Report

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Mandate | `ADR-0019` — full-coverage audit by a reader who did not write Book 1 |
| Evidence Status | **`Verified`** for document-vs-document findings (read from the files) · **`Unverified`** for every device claim — see the limitation below |
| Evidence Source | Repository files, read in full |
| Last Verified | 2026-07-14 |
| Status | 🟢 **COMPLETE — 76 of 76 audited and RANKED.** |
| Version | **2.0** |

---

## 🔴 The scope limitation, stated before anything else

**`ADR-0019`'s mandate asks three questions per document. This auditor can answer two.**

| Question | Can this audit answer it? |
|---|---|
| Does it contradict another document? | ✅ **Yes.** Read from the files. |
| 🔴 **Does it contradict a device?** | 🔴 **NO. The auditor has no device access.** |
| Is any claim in it untested? | ✅ Yes — but "untested" here means *"no evidence in the repo,"* not *"disproven."* |

**Every device claim below is therefore marked `DEVICE CHECK` with the exact command to run.** The operator runs it. **A `DEVICE CHECK` row is not a finding — it is an unanswered question**, and per Charter Rule 13 the device's answer outranks anything in this report.

> **This is not a workaround. It is the correct division of labour** — `ADR-0018`'s proposed Learning Rule says the operator runs the commands and the assistant supplies the design, the validation method and the failure modes. **This report is the validation method.**

---

## 🔴 Correction to `ADR-0019` itself

**`ADR-0019` states there are 72 documents in Book 1, and that the number was "counted, not estimated."**

**There are 76 Markdown documents.** Counted 2026-07-14:

| Folder | Count |
|---|---|
| `Architecture/` | 6 |
| `Standards/` | 8 |
| `Build-Guides/` | 9 |
| `Build-Records/` | 5 |
| `Change-Management/` | 23 |
| `Operations/` | 23 |
| Root (`README.md`, `NETWORK-PACK-MANIFEST.md`) | 2 |
| **Total** | **76** |

Plus 3 `.mmd` diagrams and 1 `.rsc` evidence export — **80 files.** The "31 of 72 unread" figure in `ADR-0019` and `Session-Handoff` v7.0 should read **35 of 76.**

---

## Progress

| Chunk | Scope | Docs | Status |
|---|---|---|---|
| **1** | **Architecture + Standards** | **14** | ✅ **Complete** |
| **2** | **Build Records `021`–`024`, `029`** | **5** | ✅ **Complete** |
| **3** | **Build Guides `025`–`034`** | **9** | ✅ **Complete** |
| **4** | **Operations** — + `043`, `049` | **26 of 26** | ✅ **Complete** |
| **5** | **Change Management** — `CM-0001`–`0008` read in full | **8 of 23** | 🟡 **Partial** |
| 6 | Manifest, README, Diagrams, Evidence | 2 + 4 | ⬜ Not started |

> 🔴 **Per `ADR-0019`: do not rank until the table is finished.** The "Ranked Findings" section at the foot of this document stays empty until all 76 rows exist.

---

# Chunk 1 — Architecture and Standards (14 documents)

## The coverage table

| # | Document | Contradicts another document? | Contradicts a device? | Untested claim? |
|---|---|---|---|---|
| `001` | Enterprise Network Overview | 🔴 **YES — five contradictions. The stalest document in Book 1.** See A1–A5. | `DEVICE CHECK` — hostnames | 🔴 Marked `Verified`, reconciled `2026-07` (no day) |
| `002` | Enterprise Design Goals | 🟡 **YES — one.** Claims recoverability is a satisfied goal. See A6. | — | 🟡 Goals stated as achieved |
| `003` | Physical Topology | 🟡 **YES — two.** Own change log contradicts own body; authority conflict with `006`. See A7, A8. | `DEVICE CHECK` — `hw=no`, MAC-WinBox | ✅ Reconciled 2026-07-14 |
| `004` | Logical Topology | 🟡 **YES — one.** Forwarding model omits the L2-adjacent flow `011` exists to teach. See A9. | — | 🟡 v1.0, never reconciled |
| `005` | Device Responsibilities | 🔴 **YES — two.** Teaches `show` on FortiOS; 1941 role conflicts with `009`. See A10, A11. | `DEVICE CHECK` — none critical | 🟡 No Evidence Status block |
| `006` | Network Source of Truth | 🟡 **YES — one.** Authority conflict with `003`/`023`. See A8. | 🔴 **`DEVICE CHECK` — high priority.** See D1–D3. | 🔴 Pi01 recorded as 1 interface; device has 5 (`010`) |
| `007` | IP Addressing Strategy | 🔴 **YES — one.** Calls `10.0.0.0/24` "transitional." See A12. | — | 🟡 v1.0, never reconciled |
| `008` | VLAN Standards | 🔴 **YES — one, and it is a live trap.** DNS step will recreate a known defect. See A13. | 🔴 **`DEVICE CHECK`** — east-west rules. See D4. | 🔴 9 permitted flows, never verified |
| `009` | Routing Standards | 🟡 **YES — one (passive).** `001`/`005` contradict *it*. See A11. | `DEVICE CHECK` — routes | ✅ v2.0, reconciled 2026-07-14 |
| `010` | Security Zones | ✅ **No.** Best document in this chunk. | `DEVICE CHECK` — compliance table is 1 day stale | 🔴 **Pi01 `docker0`/`veth` "tracked for a future pass" — nothing tracks it.** See A14. |
| `011` | Packet Flow | ✅ **No.** | `DEVICE CHECK` — none critical | ✅ v2.0 |
| `012` | Management Network | ✅ **No.** | `DEVICE CHECK` — SSH ports | 🔴 SW01 rename "still open" — **no change record exists.** See A15. |
| `013` | Internet Access Design | 🟡 **Passive** — `001` contradicts *it*. See A2. | `DEVICE CHECK` — DoT | ✅ v2.0, reconciled 2026-07-14 |
| `014` | Production vs Lab Networks | ✅ **No.** | — | ✅ v2.0 |

---

## Document-vs-document findings

### 🔴 A1 — `001` says MKT01's hostname is wrong. It was fixed a day earlier.

`001` "Current Known Deviations": *MKT01 hostname — Target `MKT01`, Current `MikroTik`, Change Record required.*

**`006` says: ✅ CLOSED 2026-07-13 — device confirms `MKT01` live (`[SethAdmin@MKT01]`). This deviation was stale.**

`001` is carrying a deviation that the source of truth has already closed.

### 🔴 A2 — `001` repeats the exact sentence `013` v2.0 was rewritten to destroy

| Document | Says |
|---|---|
| `001` Operating Principles | *"Pi-hole will remain as an **optional** upstream filtering forwarder."* |
| `001` Primary Roles | Pi-hole — *"Does not provide: **Authoritative** enterprise DNS"* |
| 🔴 **`013` v2.0** | *"v1.0 said **'Pi-hole is optional later and not authoritative enterprise DNS.'** **That was false on the running system.** Pi-hole **is** authoritative for the lab today… **A reader following v1.0 would have concluded Pi-hole was disposable and removed a load-bearing service.**"* |

**`013` was corrected on 2026-07-14 for saying this. `001` still says it, and `001` is marked `Verified`.**

> **The dangerous sentence was fixed in one document and left standing in another.** This is `ADR-0008`'s failure exactly: *content in the wrong place gets acted on by someone who never knew there was a condition.*

### 🔴 A3 — `001` and `006` disagree about what the lab's DNS actually is

| Document | DNS state |
|---|---|
| `001` | *"1.1.1.1/8.8.8.8 direct"* — interim |
| `006` | *"**Partially transitioned.** Admin workstation → Pi-hole. **Every other device still resolves via 1.1.1.1/8.8.8.8 direct.**"* |
| `013` v2.0 | *"**Pi-hole is the resolver.** It is not temporary and it is not optional."* |

**Three documents, three different answers.** `006` is the most specific and most likely correct — but `013` is the most recent. **`DEVICE CHECK` D2 settles it.**

### 🟡 A4 — `001` lists iDRAC credentials as an open deviation. `CM-0011` closed as **false**.

`001`: *"iDRAC credentials — Hardened / **Factory defaults** / Open item."*

**`NETWORK-PACK-MANIFEST` says `CM-0011` is `Closed — substantially FALSE (iDRAC findings disproven on the device)`.** `001` is repeating a disproven finding. **`DEVICE CHECK` D5.**

### 🔴 A5 — `001` omits Pi01 entirely from the architecture

`001`'s topology diagram runs `Internet → FGT01 → MKT01 → SW01 → PVE01`. **Pi01 does not appear.** Its Primary Roles table lists *"Pi-hole"* as a device — **not Pi01, and not the Lab CA, Vaultwarden, or FreeRADIUS.**

**`010` records:** *"Pi01 is the session's most-omitted device: absent from `005`, `006`'s ARP ACL, `012`'s core addresses, and `014`'s Production Foundation."* **All four of those were fixed. `001` was not — and nobody noticed, because `001` was not on the list.**

### 🟡 A6 — `002` states an unachieved goal as an achieved one

`002`: *"**Recoverability:** backups, console access, fallback management, rollback steps, and validation **are available** before change."*

| Claim | Reality |
|---|---|
| backups | 🔴 **No device backup has ever been restore-tested** (`ADR-0013`, `ADR-0015`, `To-The-Next-Session`) |
| console access | 🔴 **MKT01 has no console.** Three USB-serial adapters failed (`ADR-0016`) |

**`002` is a goals document, so the wording matters:** *"are available"* is a claim of present fact, not an aspiration. **Change to `Target Design`, or reword.**

### 🟡 A7 — `003`'s change log contradicts `003`'s body

**Body:** *"✅ **RESOLVED 2026-07-13** — iDRAC is on the shared LOM via `Gi1/0/4`. There is no separate cable."*

**Change Log v2.0, same page:** *"two connections were missing entirely (`Gi1/0/7`, and **iDRAC — which still has no recorded port**)."*

The change log was written before the resolution and never updated. **Cosmetic, but it is the exact drift class the audit exists to find.**

### 🟡 A8 — Three documents claim authority over the same table

| Document | Claims |
|---|---|
| `006` | *"This page is **the authoritative reference** for all network addresses, MACs, VLANs, and **port assignments**."* |
| `003` Related Pages | *"`023-SW01-Build-Record.md` — **the authoritative port table**"* |
| `048` (per `006`) | *"Build the ACL from **this list**, not from a stale record."* |

**Charter Locked Rule 4: one authoritative home per fact.** Port assignments currently have two claimed homes and the tiebreaker is unwritten. **Charter Rule 13 implies `023` (a Build Record, rank 4) outranks `006` (Architecture, unranked) — but `006` declares itself authoritative.** **This needs a one-line ruling.**

### 🟡 A9 — `004`'s forwarding model is the mental model that caused `CM-0009`

`004`: `Endpoint -> SW01 -> MKT01 -> FGT01 -> Internet`. **Every path goes through MKT01.**

**`011` v2.0 exists precisely because that is not true:** FGT01→Pi01 is Layer-2 adjacent via SW01 and **never enters MKT01.** Believing `004`'s model is what put two dead firewall rules on the wrong device for months.

**`004` is not wrong — it is incomplete, and its incompleteness is the documented root cause of a real defect.** It must cross-reference `011`. **It currently does not link to it at all.**

### 🔴 A10 — `005` teaches a FortiOS command that `016` says is a trap

`005` Troubleshooting Ownership: *"Perimeter and NAT — FGT01 — **`show firewall policy`**"*

**`016`, FortiGate section:** 🔴 *"**Use `get`, not `show`.** `show` displays only non-default values — an unset or default value looks like 'nothing to see.' **Empty output is not proof.**"*

**A troubleshooting table that hands you `show` will hand you an empty result and let you conclude the policy is absent.** `016` lesson 1 is *"a command completing without an error is not a confirmed change"* — this is its sibling.

### 🔴 A11 — `001` and `005` say the 1941 replaces MKT01. `009` forbids it. `ADR-0015` gates it.

| Document | Says |
|---|---|
| `001` | *"The Cisco 1941 is **planned as the future replacement for MKT01**… This is a planned **Phase 1.5** change."* |
| `005` | *"The Cisco 1941 is **the planned successor to MKT01**… requires a **Phase 1.5 Change Record**."* |
| 🔴 **`009`** | *"**Cisco 1941 routing labs remain outside the production forwarding path.**"* |
| 🔴 **`ADR-0015`** | *"**`009` states [the above]. Moving it in REVERSES an accepted standard.** Book 11 must open with an ADR that does so explicitly."* **And: Book 11 does not execute until SW01 and MKT01 have restore-tested backups.** |

**Three problems:**
1. `001`/`005` describe a **Change Record** as sufficient. **`ADR-0015` says it requires an ADR reversing `009`.**
2. `001`/`005` call it **Phase 1.5**. **`ADR-0015` renamed it Book 11** and re-sequenced it *after* Book 10.
3. Neither mentions the **gate** — no restore-tested backups, and the 1941's IOS/licence/DRAM are **unverified**.

> **A reader of `001` or `005` alone would conclude the 1941 migration is a near-term change record. It is a gated book that cannot start.**

### 🔴 A12 — `007` calls the recovery network "transitional." This is how it nearly got deleted.

`007` Reserved Networks: *"`10.0.0.0/24`: **transitional** recovery network."*

**`ADR-0013` exists because `017` v1.0 proposed *retiring the legacy `10.0.0.0/24` network*, and `003` and `016` both forbid removing it.** **`CM-0016` was raised specifically to remove the word *"Legacy"* from the device's own comment**, because — quoting `ADR-0013` — *"calling your recovery path 'Legacy' on the device is how it gets deleted by someone acting in good faith."*

**The device comment was fixed. `007` still says "transitional."** `012` says *"transitional access… Remove it only through Change Management."*

> **`CM-0016` fixed the label on the router and left the same label in two documents.** Charter Rule 15: *a change is not closed until the guides it invalidates are reconciled.* **`CM-0016` did not reconcile `007` or `012`.**

### 🔴 A13 — `008`'s "How to Add a VLAN" will recreate the `custom.list` defect

`008` step 7: *"**DNS** — add any required DNS records to **Pi-hole** or Windows Server AD DNS."*

**It does not say where.** And there are two places, one of which does nothing:

**`013` v2.0, `ADR-0007`, `CM-0008`, `038`:** 🔴 *"Local records live in **`pihole.toml`** — **`/etc/pihole/custom.list` is inert on Pi-hole v6.**"* `016` lesson 1 lists *"A DNS record was written to `custom.list` — inert on Pi-hole v6"* as one of the seven no-error-but-no-change failures. **`ADR-0007` notes it "cost real diagnostic time."**

> 🔴 **This is `016` lesson 8, live and unfixed: *a guide that does not mention a thing will recreate the thing.*** Anyone adding a VLAN by following `008` has a 50% chance of writing the record into a file nothing reads, getting no error, and losing an evening. **`008` is a Standard — one of the most-read documents in Book 1.**

**This is the highest-value single-line fix found in Chunk 1.**

### 🟡 A14 — `010` found a running container on Pi01 and assigned it to nobody

`010`: 🔴 *"**`docker0` — UP — a Docker bridge network mentioned in NO Atlas network document.** **`veth…@if2` — UP, master `docker0` — a running container: this is **Vaultwarden**. The credential vault has its own network namespace, recorded in no source of truth.** … **`006` shows Pi01 as a single `eth0`. The device has five link-layer interfaces. The 'source of truth' describes 20% of Pi01's network reality.** **Tracked for a future pass.**"*

**Nothing tracks it.** There is no CM record, no ADR, and no entry in the manifest's Outstanding Verification. **"Tracked for a future pass" is the same construction as `ADR-0009`'s rejected option: *an accepted risk with no review trigger is not an accepted risk, it is a forgotten one.***

### 🟡 A15 — The SW01 hostname rename is "open" in four documents and has no change record

`001`, `006`, `012` and `016` all state: **live hostname is `CoreSwitch`, target is `SW01`, "rename still open" / "Change Record required."**

**No such change record exists.** `CM-0001` through `CM-0020` contain nothing for it. **A deviation that four documents call open, and that no record owns, will stay open forever.**

---

## Device checks required — Chunk 1

**Run these. The device outranks every row above.**

| # | Question | Command | Settles |
|---|---|---|---|
| **D1** | Is SW01's `STATIC-HOSTS` ACL actually five entries? | `show ip arp inspection`<br>`show arp access-list STATIC-HOSTS` | `006`, `012`, `016` lesson 6 |
| **D2** | 🔴 **What is the lab's DNS, really?** | On PVE01, MKT01, FGT01, SW01: `cat /etc/resolv.conf` · `/ip dns print` · `get system dns` · `show run \| i name-server` | **A3** — settles `001` vs `006` vs `013` |
| **D3** | Does `006`'s MKT01 MAC table match the device? | `/interface ethernet print` | `006` (added 2026-07-14, one source) |
| **D4** | 🔴 **Do MKT01's east-west rules match `008`'s nine permitted flows?** | `/ip firewall filter print stats` | `008`. **Never verified.** `022` said 24 rules; device had 22. |
| **D5** | Are the iDRAC credentials factory or hardened? | `ipmitool user list 1` | **A4** — `001` vs `CM-0011` |
| **D6** | Is `hw=no` still set on `ether3`? | `/interface bridge port print detail where interface=ether3` | `003`, `016` — **"verify after every reboot and firmware update"** |
| **D7** | Is MKT01's SSH really on 2222? | `/ip service print detail` | `012`. **Also settles the dynamic WinBox row** (`Session-Handoff` open item 8) |

---

# Chunk 2 — Build Records (5 documents)

> **`ADR-0019` named this chunk a priority target:** *"This is the 'verified reality' layer, and it has NEVER been audited. The one Build Record that **was** opened (`022`) turned out to be missing an entire category of administrative state **and** a 64 GB SSD."*
>
> 🔴 **The prediction was correct, and it understated the problem.** `021`, `023`, `024` and `029` were never opened. **All four are marked `Verified`. All four are wrong.**

## The coverage table

| # | Document | Contradicts another document? | Contradicts a device? | Untested claim? |
|---|---|---|---|---|
| `021` | FGT01 Build Record | 🔴 **YES — four, and two are self-contradictions.** See B1–B4. | 🔴 **`DEVICE CHECK`** — D8, D9 | 🔴 **Firewall table marked "(verified)" describes a policy that does not exist** |
| `022` | MKT01 Build Record | 🟡 **One** (1941 role, inherits A11). | `DEVICE CHECK` — D7 | ✅ **The best Build Record in Book 1.** Every figure device-read. Version/date fields stale. See B5. |
| `023` | SW01 Build Record | 🔴 **YES — three.** See B6–B8. | 🔴 **`DEVICE CHECK`** — D10, D11 | 🔴 **Live SNMP community in the repo, unrotated** |
| `024` | PVE01 Network Build Record | 🔴 **YES — three. Contains the defect `Atlas-Workflow.md` uses as its worked example of a false `Verified`.** See B9–B11. | 🔴 **`DEVICE CHECK`** — D12 | 🔴 **Hardware spec is off by 2× on RAM and 2× on CPU** |
| `029` | Pi01 Services Build Record | 🔴 **YES — three, and one is a live safety risk.** See B12–B14. | 🔴 **`DEVICE CHECK`** — D13 | 🔴 **Claims an off-site backup copy that three documents say does not exist** |

---

## 🔴 B9 — `024` still asserts the exact numbers `Atlas-Workflow.md` uses to teach you not to trust it

**`024-PVE01-Network-Build-Record.md`, Platform table, marked `Status: Verified`, `Version 2.1`, reconciled 2026-07-13:**

| Item | `024` says | Reality |
|---|---|---|
| **CPU** | **32 vCPUs total** | 🔴 **16 logical CPUs** |
| **RAM** | **32 GB** | 🔴 **64 GB physical / 62 GiB usable** |
| **VT-x** | *"confirmed via `egrep -c '(vmx\|svm)' /proc/cpuinfo` **= 32**"* | 🔴 Should return **16** |

**`Atlas-Workflow.md`, Evidence Status section, verbatim:**

> *"A build record in this project opened with **'all values were confirmed directly from the running system via SSH'** — and asserted **32 GB RAM and 32 vCPUs.** The live host reports **62 GiB and 16.** It was almost certainly true when written."*

**`VM-and-Services-Inventory.md`** — *"Real Capacity Baseline (**confirmed live, 2026-07-11**): Logical CPUs **16** (2× Intel Xeon E5620, 4c/8t each). RAM **64 GB physical, 62 GiB usable**."*

**`Atlas-Service-Architecture.md`** — *"**PVE01 has 62 GiB of RAM.** … That single comparison decides almost everything below."*

> 🔴 **The Workflow document holds this Build Record up as the canonical example of a page that says `Verified` and is not. Four documents carry the corrected figures. `024` was rewritten to v2.1 on 2026-07-13 — to fix the iDRAC — and the wrong numbers were left untouched, three tables above the correction.**
>
> **The correction was made in a document *about* the defect, and never in the document *containing* it.**

**Why it is not cosmetic:** `VM-and-Services-Inventory.md` sizes the entire future VM estate against 62 GiB. **A reader planning capacity from `024` would believe they have half the RAM they have and a quarter of the cores** (32 vCPU vs 16 logical) — and `ADR-0017`'s close condition for `CM-0012` is literally *"`egrep -c` returns **the CPU count**."* **Against `024`, that test passes at 32 and fails at the true value of 16.**

🔴 **`ADR-0017`'s CMOS-battery close test, as written, would be validated against a number this Build Record gets wrong.**

---

## 🔴 B12 — `029` claims an off-site backup exists. Three documents say it does not. This is Roadmap Critical Risk #1.

**`029-Pi01-Build-Record.md`, "Current backup state — verified 2026-07-13":**

| Item | `029` says |
|---|---|
| Copies | Pi01, `E:\` (hash-verified), 🔴 **off-site USB** |
| Restore-tested | ✅ Yes |

And in prose: *"hash-verified on `E:\`, and **held off-site**."*

**Against, all dated 2026-07-14:**

| Document | Says |
|---|---|
| `Session-Handoff` v7.0, open item **#3** | 🔴 *"**No off-site copy of the media.** `049` Phase 5. **Both archive copies are in the same room.** A single fire takes the Root CA, the Intermediate CA, every RADIUS secret and the vault. Roadmap Critical Risk #1. **The biggest unmitigated risk in the lab.**"* |
| `To-The-Next-Session.md`, risk **#1** | 🔴 *"**No off-site copy of the backup media.** Both copies of the archive are **in the same room.**"* |
| `Atlas-Service-Architecture.md` | 🔴 *"**Both copies of your CA archive are in the same room.**"* |
| `Atlas-Roadmap.md` Critical Risk #1 | *"Offline media. **Two copies. One off-site.**"* |

> 🔴 **A Build Record — the "verified reality" layer — asserts that the single biggest unmitigated risk in the lab is already mitigated.**
>
> **One of these is wrong, and it matters which.** If `029` is right, the lab's #1 risk is closed and four documents are scaremongering. If the four are right, **`029` is telling a future engineer that the CA survives a fire when it does not.**

**This is the one finding I am not willing to leave sitting in a table until the audit finishes. It needs an answer today. See `DEVICE CHECK` D13.**

---

## 🔴 B13 — `029` names the archive whose passphrase was leaked, and calls it "the real backup"

**`029`:** *"**The real backup is `atlas-pi01-2026-07-13.tar.gz.gpg`** — AES256-encrypted, **restore-tested end to end**… **Passphrases: Vaultwarden and paper.**"*

**`CM-0014` / `Session-Handoff` v7.0 / `NETWORK-PACK-MANIFEST`, 2026-07-14:**

> 🔴 *"**The CA backup passphrase had NEVER been rotated — three documents said it had.** `git show` confirmed the value on the paper WAS the value in Git history. The passphrase was committed at **14:09:41**; **the archive was written at 14:16 and never rewritten.**"*

**The `2026-07-13` archive that `029` names is the archive that was encrypted with the leaked passphrase.** It was replaced on 2026-07-14 — new passphrase, new archive, *proven by opening it*, both old copies destroyed.

🔴 **`029` still points a future engineer at the destroyed, compromised archive as the recovery artefact.** Its "restore-tested ✅ Yes" refers to a restore of the *superseded* file.

> **`CM-0014` closed with its guide reconciliation answered — but `029` was not on the list.** Charter Rule 15 asks the question *"for every guide touching the affected system."* **`029` is a Build Record, not a guide** — and `ADR-0019`'s own companion rule was written to close exactly this hole: *"reconciliation covers ALL document types."* **It was written the same day and not applied to this record.**

---

## 🔴 B14 — `029` still contains the false "Pi01 is not in STATIC-HOSTS" claim. It is the origin of the three-handoff mystery.

**`029`, Platform table and Note, unchanged:**

> *"MAC | `00:00:5e:00:53:05` (in SW01 STATIC-HOSTS — **not currently present**, see Note)"*
>
> *"**Note:** Pi01's MAC is **not** in SW01's STATIC-HOSTS ARP access list, unlike the other static-IP VLAN 10 devices. **Not flagged as an issue** in this session's validation, but worth confirming intentional."*

**`023-SW01-Build-Record.md`, corrected 2026-07-13:**

> 🔴 *"**There was no mystery. Pi01 is in the ACL and always was.** `show arp access-list STATIC-HOSTS` lists **five** hosts. **The document was wrong; the device was right; nobody ran `show arp access-list` until now.**"*

**`016` lesson 6, `006`, `012` — all corrected.** `016` records: *"the same omission in `023` produced a false 'Pi01 should be unreachable' mystery that **survived three handoffs**."*

> 🔴 **`029` is where the claim actually lives, and `029` was never fixed.** `023`, `006`, `012` and `016` were all reconciled. **The source document was left standing** — so the mystery can be re-imported from `029` by the next reader, and the reconciliation that "closed" it did not touch it.
>
> **Four documents were corrected. The one that was wrong was not.**

---

## `021` — FGT01 Build Record

### 🔴 B1 — `021`'s "Firewall Policies (verified)" table describes a policy that does not exist

| `021` says (marked **verified**) | `021`'s own Known Deviations row says |
|---|---|
| Policy 1 `LAB-to-Internet`, **`srcaddr = Lab-Network, Transit-Link`** | *"Firewall policy scope — Target: `srcaddr` = `Lab-Network`, `Transit-Link`. **Current: `srcaddr` = `all`.** Deliberately deferred — see `ADR-0005`."* |

**`ADR-0005` confirms the live device:** *"Live validation of FGT01 found policy 1 using **`srcaddr all`**, while Build Record `021` documented a scoped design (`Lab-Network`, `Transit-Link` address objects) **that doesn't actually exist on the device.**"*

🔴 **The table marked "(verified)" is the target design. The deviation row two screens down says so. Nobody removed the false table.**

### 🔴 B2 — `021`'s Address Objects table lists objects `ADR-0005` says do not exist

`021` lists `Lab-Network` (10.0.0.0/8) and `Transit-Link` (172.16.0.0/29) as existing address objects, with a note: *"Must be /8 — narrower scope silently breaks VLAN internet access."*

**`ADR-0005`:** those objects *"don't actually exist on the device."* **`ADR-0005`'s Review Trigger even lists recreating them as future work.**

### 🔴 B3 — `021` contradicts itself on whether the unused interfaces are disabled

| Section | Says |
|---|---|
| **"Interfaces — Disabled"** (top, `Evidence Status: Verified`) | `wan2`, `internal`, `fortilink`, `modem` — **all four `set status down`** per `CM-0004` |
| **"Interfaces"** prose note (middle) | *"`internal`, `wan2`, and `fortilink` are all still present at **factory-default configuration**… **Left at factory defaults rather than disabled** — open question whether they should be explicitly disabled."* |

**The prose block is the pre-`CM-0004` text. It was never removed when the top section was added.** `010-Security-Zones.md` confirms all four are down. **One document, two opposite answers, one of them marked `Verified`.**

### 🟡 B4 — `021` says the Lab CA certificate is absent. It was installed on 2026-07-12.

`021` Known Deviations: *"Lab CA certificate — **Confirmed absent as of 2026-07-12.** **`CM-0005` drafted.**"*

**`CM-0005` is `Superseded by MC-0001`** (manifest). **`MC-0001` is `Closed`.** `012` says *"Lab CA certificate installed (`MC-0001`)."* `029` verified the SAN on the live connection: `DNS:fortigate.lab, IP:10.10.0.254, IP:172.16.0.1`, valid to 2027-06-20.

**Also missing from `021` entirely:** the `dmz` interface's disabled state (it is in the Interfaces table at factory `10.10.10.1/24` but is **not** in the disabled list), the `modem` interface row, and **FGT01's 2015–2018 signature databases** (`Atlas-Roadmap.md` Critical Risk #2 — *"either the UTM profiles aren't applied, or they are applied and providing nothing while appearing to"*). **A Build Record that omits Critical Risk #2 for its own device.**

---

## `022` — MKT01 Build Record

### 🟢 B5 — `022` is the best Build Record in Book 1, and its metadata lies about it

**Every figure in `022` is device-read and none is carried forward from a document.** The firewall table, the `mac-server` state, the 64 GB SSD, the `ether2` disable — all sourced. **This is what the other four should look like.**

**But:** Document Control says `Version 2.6`, `Last Verified 2026-07-13`. **The document contains a 2026-07-14 section** (Layer-2 Management State, `CM-0017`/`CM-0018`) and a `Updated 2026-07-14` change-log row. **The version and date fields were not bumped.** Charter Rule 14: *"'Verified' is a claim about a date."* **The date is wrong by a day and understates the work.**

**Change log is also out of order:** `2.3 → 2.4 → 2.6 → 2.5 → Updated 2026-07-14`.

**Inherits A11** (1941 as a "Phase 1.5 Change Record" — `ADR-0015` makes it Book 11, gated, requiring an ADR to reverse `009`).

---

## `023` — SW01 Build Record

### 🔴 B6 — `CM-0001` is `Closed` and `023` still shows the defect it closed

`023` port table: *"`Gi1/0/1` | **Raspberry-Pi** *(mislabeled — see Known Deviations)*"*
`023` Known Deviations: *"`Gi1/0/1` port description — Target `Trunk-to-MKT01`, Current `Raspberry-Pi` (stale) — **`CM-0001` — reconfigure description.**"*

**`CM-0001-SW01-Gi1-0-1-Description-Fix.md` is `Closed`** (manifest, verified against the record files 2026-07-13).

🔴 **Either `CM-0001` closed without executing, or it executed and `023` was never reconciled.** **`016` lesson 2 is precisely this:** *"`CM-0009` was marked `Closed — implemented and verified` with two of its own boxes unticked."* **This is the same failure on change record number one — the first one ever written.** `DEVICE CHECK` D10 settles it.

### 🔴 B7 — `023` carries a live, cleartext SNMP credential that the Charter explicitly says to rotate

`023`: *"SNMP community | **`homelab` (ro)**"*

**`Atlas-Charter.md`, "Evidence and secrets", naming this exact string:**

> 🔴 *"**`snmp-server community homelab`** — **live, and SNMP v2c sends it in cleartext. Redact *and* rotate.**"*

**`Atlas-Service-Architecture.md`:** *"**SNMP `homelab` is live, cleartext, v2c.** It's in `023`. **Rotate it before you point a collector at it, or you will have built a monitoring system whose credential is in a Git repo.**"*

🔴 **The Charter names it, by string, as a thing to redact and rotate. It is still in `023`, unredacted and unrotated. There is no change record for it.**

**`ADR-0010` gates publication on:** *"No live credential, key, token, or **passphrase** exists anywhere in the working tree."* **A live SNMP community string is a reusable credential in the working tree.** **`gitleaks` will not catch it** — it is a bare word with no shape, which is exactly the `CM-0014` finding.

### 🔴 B8 — `023` points SNMP and NTP at hosts that may not exist

| `023` says | Problem |
|---|---|
| **SNMP host** `10.40.0.52` | 🔴 **`Atlas-Service-Architecture.md`: "SW01 points SNMP at `10.40.0.52` — a host that does not exist."** VLAN 40 is live and **empty** (`014`). `006` plans LibreNMS at `10.40.0.20`, not `.52`. |
| **NTP server** `10.10.0.5` (Pi-hole) | 🔴 **Does Pi01 run an NTP server?** `029` does **not** list one. `Atlas-Service-Architecture.md` proposes *"NTP (chrony) — **ADD**"* to Pi01 — i.e. **it is not there.** `013` and `022` say NTP is `pool.ntp.org`. **If Pi01 serves no NTP, SW01's clock is pointed at nothing.** `DEVICE CHECK` D11. |

**Also:** `023` records `Domain: lab.local`. **This is a third domain name.** Devices are `<device>.lab`; `ADR-0007` adopted (unimplemented) `atlas.lab`; `ADR-0012` quarantined a Confluence page for using `atlas.local` on the grounds that *"that domain has never existed."* **`lab.local` appears in exactly one Book 1 document and is on the live switch.**

---

## `024` — PVE01 Network Build Record *(see B9 above for the headline)*

### 🔴 B10 — `024` says `CM-0011` is "Draft, not executed." It was executed, and it degraded hardware.

`024` Known Issues: *"🔴 **iDRAC credentials** — Current: **Factory defaults.** Action: **Open — `CM-0011` (Draft, not executed).**"*

**`016` lesson 5:** *"**`CM-0011`'s `Status` said `Draft — not executed`, so it was treated as a to-do list and run.** The device was **already hardened**. The command **degraded it**… Caught only by the read-back."*

**Manifest:** `CM-0011` — **`Closed — substantially FALSE`** (iDRAC findings disproven on the device).

🔴 **`024` reproduces, word for word, the framing that caused a session to run a command against a stale baseline and damage a BMC.** *"A `Draft` record is a hypothesis, not a work order"* is now a ground rule in three documents. **`024` still presents it as a work order.**

**This is the manifest's dangerous `Next Action` defect, replicated inside a Build Record — and unlike the manifest, nobody has found it until now.**

### 🟡 B11 — `024` calls `eno2` "available"

`024`: *"`eno2` | DOWN | **Unused — available for future use**"*

**`016` lesson 9:** *"**'Available' is not a state. It is a hope.**"* — a lesson derived from `022` recording `ether2` as *"Unused — Available"* while the device had it **enabled**. `022` was fixed. **`024` uses the identical forbidden phrasing, on the identical class of interface.**

*(`010` confirms `eno2` is genuinely `DOWN` / not `auto`, so the state is correct — the wording is the defect, and the wording is what a rebuilder reads.)*

**Also:** `Last Live Verification: 2026-07-09` with `Status: Verified` and a 2026-07-13 correction. Charter Rule 14 — **five days stale and still claiming `Verified`.** Storage figures (`local-lvm` 831 GB) disagree with `VM-and-Services-Inventory.md` (~793 GB).

---

## `029` — Pi01 Services Build Record *(see B12–B14 above for the headlines)*

**Additional:**

- **Revision History lists only `v1.0` (2026-07-11).** Document Control says `Version 2.1`. **Two version bumps, zero revision-history entries.** `020-Network-Revision-History.md` exists to catch this — it did not.
- **`Last Reconciled: Not yet reconciled with Network Source of Truth`** — but `006` *was* reconciled against `029` on 2026-07-13, and `029`'s own Related Pages says so. **The field contradicts the document it sits in.**
- 🟡 **`L=Redding` is embedded in every certificate subject.** `029` flags it: *"worth knowing if this repository is ever made public."* **`ADR-0010` lists four publication preconditions. This is not one of them, and nothing tracks it.** A locality string in a cert is a real-world location disclosure on a portfolio repo.
- 🟡 **`fortigate.lab` DNS record does not exist.** Open, "low priority," **no change record.**
- **`029` records no network interfaces at all** — no `eth0`, `wlan0`, `docker0` or `veth`. `010` enumerated five link-layer interfaces on Pi01 including the vault's container namespace. **The Build Record for the lab's most-loaded host does not describe its network.**

---

## Device checks required — Chunk 2

| # | Question | Command | Settles |
|---|---|---|---|
| **D8** | 🔴 What is FGT01 policy 1's **actual** `srcaddr`, and do `Lab-Network`/`Transit-Link` exist? | `get firewall policy` *(**`get`**, not `show` — `016`)*<br>`get firewall address` | **B1, B2** |
| **D9** | Is `dmz` disabled? Is `modem` disabled? Are FGT01's UTM signature DBs really from 2015–2018? | `get system interface`<br>`get system fortiguard`<br>`diagnose autoupdate versions` | **B4**, Roadmap Critical Risk #2 |
| **D10** | 🔴 What is `Gi1/0/1`'s port description **right now**? | `show run interface Gi1/0/1` | **B6** — did `CM-0001` actually execute? |
| **D11** | 🔴 **Does Pi01 serve NTP at all?** And where does SW01 point SNMP? | Pi01: `systemctl status chrony ntp systemd-timesyncd` · `ss -ulnp \| grep :123`<br>SW01: `show ntp status` · `show run \| i snmp` | **B8** |
| **D12** | 🔴 **PVE01's real CPU/RAM.** | `nproc` · `free -h` · `egrep -c '(vmx\|svm)' /proc/cpuinfo` | **B9** — and it is `ADR-0017`'s close test |
| **D13** | 🔴🔴 **Does an off-site copy of the CA archive physically exist, and which archive is it?** | Not a command — **go and look.** Then: `gpg --list-packets` on it, and hash it against the Pi01 copy. | **B12, B13** — Roadmap Critical Risk #1 |

---

# Chunk 3 — Build Guides (9 documents)

> **A Build Guide is the document you rebuild from. It is only ever read at the moment a device is gone.** `ADR-0011`: *"nobody has ever rebuilt."* **That is why these defects survived.**
>
> 🔴 **Two guides in this chunk would produce a broken lab today, from a clean rebuild, following them exactly.**

## The coverage table

| # | Document | Contradicts another document? | Contradicts a device? | Untested claim? |
|---|---|---|---|---|
| `025` | FGT01 Build Guide | 🔴 **YES — four.** Rebuilds a firewall that never disables the factory interfaces. See C6–C8. | 🔴 **`DEVICE CHECK`** D8, D9 | 🔴 Marked `Verified`. **A guide cannot be `Verified` — it is `Target Design`.** |
| 🔴 `026` | MKT01 Build Guide | 🔴🔴 **CONTRADICTS ITSELF, IN CODE. See C1 — the single worst defect in the audit.** | `DEVICE CHECK` D7 | ✅ **Only guide correctly marked `Target Design`** |
| 🔴 `027` | SW01 Build Guide | 🔴🔴 **YES — five. A rebuild from this guide kills Pi01 four separate ways.** See C2–C5. | 🔴 **`DEVICE CHECK`** D10, D14 | 🔴 Marked `Verified`. **Validation expects the wrong answer.** |
| `028` | PVE01 Network Build Guide | 🟡 **One** (`CM-0011` "not executed"). | `DEVICE CHECK` D12 | ✅ **Good.** iDRAC corrected, both MACs in `STATIC-HOSTS`. |
| `030` | Pi01 Base System Build Guide | 🔴 **YES — two, and one is a build-order trap.** See C9, C10. | `DEVICE CHECK` D15 | 🟡 `Draft`, v0.2 — **honestly labelled** |
| `031` | Pi01 Lab CA Build Guide | 🟡 **One** (circular prerequisite with `034` — see C9). | — | ✅ **Excellent.** Revocation gap stated plainly. Header stale vs. own body. |
| `032` | Pi-hole DNS Build Guide | ✅ **No.** | — | ✅ **Excellent.** `custom.list` trap documented. |
| `033` | Pi01 FreeRADIUS Build Guide | ✅ **No.** | — | ✅ **Excellent.** The `testing`/`password` fix is exemplary. |
| `034` | Pi01 Vaultwarden Build Guide | 🟡 **Two** (circular prereq; UFW scoping). See C9, C13. | — | 🟡 Says `Complete` with an unticked box |

---

## 🔴🔴 C1 — `026` §12 still disables MAC-WinBox. The section rewritten to fix that defect contains the defect.

**`026` §12 carries this header:**

> ✅ **REWRITTEN 2026-07-14 (`CM-0018` / `ADR-0014` / `ADR-0016`).** … 🔴 *"`mac-winbox=none` **DESTROYED the recovery path**… A router built from the old guide had **NO way in** if its addressing broke."*

**The code block in that same rewritten section, in execution order:**

| Line | Command | Effect |
|---|---|---|
| 33 | `/tool mac-server set allowed-interface-list=none` | MAC-**Telnet** off — ✅ correct |
| 36 | `/interface list add name=RECOVERY …` | ✅ |
| 37 | `/interface list member add list=RECOVERY interface=bridgeLocal` | ✅ |
| **41** | `/tool mac-server mac-winbox set allowed-interface-list=RECOVERY` | ✅ **Recovery path ON** |
| 46 | `/ip neighbor discovery-settings set discover-interface-list=static` | (known open disclosure) |
| 🔴 **47** | 🔴 **`/tool mac-server mac-winbox set allowed-interface-list=none`** | 🔴🔴 **RECOVERY PATH BACK OFF** |
| 48 | `/tool bandwidth-server set enabled=no` | |

**`set` is last-write-wins. Line 47 overwrites line 41.**

> 🔴 **A router rebuilt from `026` v2.1 — the current, committed, "rewritten" guide — comes back with `mac-winbox=none`.**
>
> **That is the exact state `CM-0017`, `CM-0018`, `ADR-0014` and `ADR-0016` were written to fix.** The old line was never deleted when the new one was added. **The fix and the bug are four lines apart in the same code block.**

**And nothing in the guide would catch it:**

| Control | Present? |
|---|---|
| §12's own `Verify:` block | 🔴 **`/ip service print` only.** MAC-WinBox is **not** an `/ip service` — it does not appear. |
| Main **Validation** section | 🔴 **No `/tool mac-server mac-winbox print`.** |
| **Completion Checklist** | 🔴 **No MAC-WinBox line at all.** Says only *"Services hardened — telnet/ftp/www/api/api-ssl disabled, SSH on 2222."* |

**The correct verify commands exist — stranded inside a warning blockquote in §3**, where they are formatted as prose and never run.

**The only thing that would catch it is the *"Post-build: PROVE the recovery path"* section — which sits BELOW the Change Log**, after a reader has every reason to think the document has ended.

> **`016` lesson 8: a guide that does not mention a thing will recreate the thing.** **This is worse: the guide mentions it, fixes it, and then un-fixes it.**
>
> **`ADR-0016`: *"a recovery path you have never exercised is a recovery path you do not have."* This guide builds one and then removes it.**

🔴 **This needs a change record today. It is the highest-severity finding in the audit so far.**

---

## 🔴🔴 C2 — `027` builds a `STATIC-HOSTS` ACL with four entries. Pi01 is missing. The validation section expects four.

**`027` Step 16, verbatim — the ACL a rebuild creates:**

```
arp access-list STATIC-HOSTS
 permit ip host 10.10.0.10  mac host 0000.5e00.5313    PVE01
 permit ip host 10.10.0.100 mac host 0000.5e00.5314    iDRAC
 permit ip host 10.10.0.254 mac host 0000.5e00.5315    FGT01
 permit ip host 10.10.0.50  mac host 0000.5e00.5316    workstation
```

🔴 **Pi01 (`10.10.0.5` / `0000.5e00.5300`) is not there.**

**`027` Validation — "Expected":** 🔴 ***"STATIC-HOSTS has four entries."***
**`027` Completion Checklist:** *"STATIC-HOSTS ARP access list created and applied to VLAN 10"* — no count, no Pi01.

**Against:**

| Document | Says |
|---|---|
| `006` | 🔴 *"**All five are required.** `DHCP Permits: 0` on SW01 — **there is no snooping fallback.** A host missing from this ACL is **dropped, full stop.**"* |
| `023` | *"The live ACL lists **five** hosts."* |
| `012` | *"**All five `STATIC-HOSTS` entries**: `10.10.0.5` Pi01 · …"* |
| `016` lesson 6 | *"four `STATIC-HOSTS` entries where **five** are required. **Pi01 was missing.**"* |
| `048` | *"**Build the ACL from this list, not from a stale record.**"* |

> 🔴 **`048` says build it from `006`, not from a stale record. `027` IS the stale record — and `027` is the Build Guide.**
>
> **`006`, `012`, `023` and `016` were all corrected on 2026-07-13. `027` was not.** The correction pass fixed every document that *described* the ACL and missed the one that *builds* it.

**Consequence of a rebuild from `027`:** SW01 comes up with ARP inspection enforcing a four-entry ACL and `DHCP Permits: 0`. **Pi01 — the Root CA, the Intermediate CA, Vaultwarden, Pi-hole, FreeRADIUS — is silently dropped.** No error. No log the operator will look at. It just appears broken. **And the "Pi01 should be unreachable" mystery is re-imported, exactly as `029` still describes it (B14).**

---

## 🔴🔴 C3 — `027` Step 15 shuts down `Gi1/0/7`. That is Pi01's port.

```
interface range GigabitEthernet1/0/7-48
 description Unused
 switchport access vlan 999
 shutdown
```

**`006`, `003`, `023`, `029`, `030` all say: `Gi1/0/7` = **Pi01**, Access VLAN 10.** `023` notes it was *"added this session."*

🔴 **A rebuild from `027` puts Pi01's switch port into VLAN 999 and administratively shuts it down.**

**Combined with C2, a clean rebuild from `027` kills Pi01 four ways:**

| # | What `027` does | Result |
|---|---|---|
| 1 | Omits Pi01 from `STATIC-HOSTS` | ARP inspection drops it |
| 2 | Shuts down `Gi1/0/7` | Its port is administratively down |
| 3 | Puts `Gi1/0/7` in VLAN 999 | Even if enabled, it is in the black-hole VLAN |
| 4 | Labels `Gi1/0/2` *"Raspberry-Pi"* | You cable the Pi into the wrong port chasing the description |

---

## 🔴 C4 — `027`'s port table is the pre-2026-07-13 layout, and it reverses an accepted ADR

| `027` says | Reality |
|---|---|
| `Gi1/0/2` — **Raspberry-Pi**, Access VLAN 10 | **LabComputer.** `003` v2.0 corrected this: *"the Pi was moved."* |
| `Gi1/0/3` — **Windows-Laptop**, Access **VLAN 50** — Step 13 configures it and issues **`no shutdown`** | 🔴 **`ADR-0002` DISABLED this port. `CM-0003` executed it.** *"Neither VLAN 50 nor VLAN 10 gets chosen. The port is shut down."* |
| `Gi1/0/7-48` — Unused, shutdown | 🔴 `Gi1/0/7` is **Pi01** |
| *(no row)* | 🔴 **`Gi1/0/7` appears nowhere as Pi01** |

🔴 **A rebuild from `027` re-enables `Gi1/0/3` on VLAN 50, silently reversing an accepted ADR and its executed change record.** `ADR-0002`'s whole point was that *"committing to one VLAN without knowing why the other was configured would be a guess dressed up as a decision."* **`027` makes that guess.**

---

## 🔴 C5 — `027` Step 17 teaches the live SNMP community. The Charter forbids exactly this.

```
snmp-server community homelab ro
snmp-server location Home-Lab-California
snmp-server contact SethAdmin
snmp-server host 10.40.0.52 traps version 2c homelab
ntp server 10.10.0.5
```

**`Atlas-Charter.md`, "Evidence and secrets":**

> 🔴 *"**A Build Guide never contains a value you would actually type.**"*
> 🔴 *"**`snmp-server community homelab`** — **live, and SNMP v2c sends it in cleartext. Redact and rotate.**"*

**The Charter names this string. The Build Guide types it.** *(And `023` records it — B7. Two documents, one live cleartext credential, no change record.)*

**Also in five lines:** SNMP trap host `10.40.0.52` **does not exist** (B8); NTP points at Pi01, which **appears to run no NTP server** (B8, D11); and `location Home-Lab-California` is a **real-world location disclosure** on a repo `ADR-0010` intends to publish — the same class as `L=Redding` in the certificate subjects (`029`).

---

## 🔴 C6 — `025` never disables the four factory interfaces. `CM-0004` closed without reconciling it.

**`CM-0004` disabled `internal`, `wan2`, `fortilink` and `modem`. `021` and `010` both confirm all four are `set status down`.**

🔴 **`025` contains no `set status down` anywhere.** A rebuild from `025` leaves:

- **`internal`** — enabled, holding **`192.168.1.99`**, the factory bootstrap address, with `allowaccess ping https ssh`
- **`wan2`**, **`fortilink`** — enabled, undocumented
- **`modem`** — untouched, carrying its **encrypted PPPoE credential** (`021`)

**`010-Security-Zones.md`'s Unused Interface Policy exists because of this exact finding.** `CM-0004`'s Charter Rule 15 reconciliation asked *"does any guide now contain an instruction that would recreate this problem?"* — **the answer was yes, and `025` was not touched.**

*(`025` also `set trusthost3 192.168.1.0 255.255.255.0` — it keeps the factory bootstrap network as a trusted admin source.)*

---

## 🔴 C7 — `021`'s "verified" firewall table was copied from `025`, not read from the device

**`025` Step 7 builds:** `set srcaddr "Lab-Network" "Transit-Link"`
**`021` "Firewall Policies (verified)" says:** `srcaddr = Lab-Network, Transit-Link`
**The device (per `ADR-0005`) has:** `srcaddr = all`, and *"the scoped address objects don't actually exist on the device."*

> 🔴 **The Build Record matches the Build Guide exactly, and neither matches the device.** That is not a coincidence — **`021` was populated from `025`.**
>
> **`Atlas-Workflow.md` v2.0 exists because the old source-priority ranked Build Guides ABOVE Build Records.** *"A Build Guide is a plan. A Build Record is an observation. Observations outrank plans."* **Here the plan was written into the observation.**

**And `025` builds a policy `ADR-0005` deliberately decided NOT to build yet** — *"keep `srcaddr all` for now… neither narrowing to the original scoped objects nor retiring broad access happens at this time."* **A rebuild from `025` silently executes a deferred decision.**

---

## 🔴 C8 — `025` rebuilds an FGT01 with no Lab CA certificate, no DNS-over-TLS, and validates with `show`

| Live FGT01 has | `025` builds |
|---|---|
| Lab CA certificate on the admin server (`MC-0001`, closed, SAN verified) | 🔴 **Nothing.** No certificate step. Rebuild = factory self-signed. |
| **DNS-over-TLS** — `set protocol dot`, `globalsdns.fortinet.net` (`021`) | 🔴 **Plain DNS.** `set primary 1.1.1.1` only. Rebuild loses DoT. |

**And `025`'s Validation block uses `show firewall policy`, `show firewall address`** — **`016`, FortiGate section:** 🔴 *"**Use `get`, not `show`.** `show` displays only non-default values… **Empty output is not proof.**"* *(Same defect as `005` — A10.)*

---

## 🔴 C9 — The Pi01 build order is a circular dependency, and `030` says order does not matter

| Guide | States |
|---|---|
| **`030`** "Next Guide" | 🔴 *"Lab CA, Pi-hole/DNS, FreeRADIUS, or Vaultwarden — **any order, no interdependency between them beyond this base guide.**"* |
| **`031`** Prerequisites | 🔴 *"**Vaultwarden already running (`034`)**"* — and: *"🔴 **Build Vaultwarden first.** You are about to generate a passphrase with **no recovery path**… **If you build the CA first, that passphrase ends up in a text file — which is exactly what happened here, and correcting it is what drove the entire 2026-07-13 overhaul.**"* |
| **`034`** "Next Guide" | *"**depends on Lab CA guide for Phase 2**"* — Phase 2 needs a `vault.lab` certificate **from `031`**. |
| **`032`** Prerequisites | *"**Lab CA built (`031`)**, with a `pihole` certificate issued"* |

> 🔴 **`030` is flatly wrong, and the thing it is wrong about is the root cause of `CM-0010` and `CM-0014`.**
>
> **`031` and `034` are circular** — `031` needs `034`; `034` Phase 2 needs `031`. **Neither guide states the resolution.**

**The real order, reconstructed from `034`'s own staging:**

```
030  →  034 Phase 1 (Docker + Vaultwarden, HTTP, no vault data)
     →  031 (build the CA — passphrase goes straight into Vaultwarden)
     →  034 Phase 2 (issue vault.lab cert, nginx on 8443, create master password)
     →  032  →  033
```

**No document says this.** **A rebuilder following `030` builds the CA first, has nowhere to put the passphrase, and writes it to a text file. That text file is `CM-0014`.**

---

## 🔴 C10 — `030`'s UFW baseline is more open than production

| `030` Step 6 builds | `029` records live |
|---|---|
| `ufw allow 443/tcp` — **from anywhere** | `from 10.10.0.0/24 to any port 443` |
| `ufw allow 53/tcp` + `53/udp` — **from anywhere** | `from 10.10.0.0/24` **and** `from 10.0.0.0/24` |

🔴 **A rebuild from `030` exposes Pi01's DNS and admin dashboard to every VLAN**, including VLAN 70 (Testing — *"potentially malicious software"*) and VLAN 80 (DMZ). **The live host is scoped to VLAN 10 + `bridgeLocal`.** The guide builds the weaker firewall.

**`030` also never disables `wlan0`.** `010` flagged this: *"`wlan0` is administratively DOWN… **A reflash brings it back up and no document says to disable it** — the `modem` failure exactly."* **`030` is the document that would say it. It does not.**

---

## 🟡 C11–C16 — the rest

| # | Finding |
|---|---|
| **C11** | 🔴 **`026` Step 2: `/system identity set name=MikroTik`** — with a note that *"a Change Record is required to rename."* **`022` confirms the live device is `MKT01` and the deviation is CLOSED.** A rebuild from `026` names the router `MikroTik` again and re-opens a closed deviation. |
| **C12** | 🔴 **`027` Step 2 sets `hostname CoreSwitch`**, and its Completion Checklist ticks *"Hostname CoreSwitch."* **The target is `SW01`.** The guide enshrines the deviation as the build target — **which is why the rename has never happened, and why no change record exists for it (A15).** |
| **C13** | 🟡 **`034` checklist: *"UFW rules scoped — currently reachable from anywhere… not yet explicitly restricted. Worth a follow-up change record."*** **`029` says: *"Resolved 2026-07-13 — port `8443` specifically restricted to the admin workstation only."*** `034` says `Status: Complete` with that box unticked. |
| **C14** | 🟡 **`027` says IOS `15.2(7)E`. `023` says `15.2(2)E6`.** `ADR-0015` flags SW01's IOS as **UNVERIFIED** — *"the operator has flagged uncertainty."* **`DEVICE CHECK` D14.** |
| **C15** | 🟡 **Change logs out of order** in `026` (2.0 → 2.1, but three whole sections sit *below* it) and `031` (0.3 → 0.7 → 0.6 → 0.5 → 0.4). **`026` in particular puts *"Post-build: PROVE the recovery path"* — the only control that would catch C1 — below its own Change Log.** |
| **C16** | 🟡 **`025` and `027` are marked `Status: Verified`.** Per Charter Rule 14 and `Atlas-Workflow`, **a Build Guide describes target state — its Evidence Status is `Target Design`, never `Verified`.** 🟢 **`026` is the only guide in Book 1 that gets this right.** |

---

## Device checks required — Chunk 3

| # | Question | Command | Settles |
|---|---|---|---|
| **D14** | What IOS is SW01 actually running? | `show version` | **C14**, `ADR-0015`'s unverified flag |
| **D15** | Is Pi01's `wlan0` still down, and what is UFW actually allowing? | `ip link show wlan0` · `sudo ufw status verbose` | **C10** |

*(D7 already covers `/tool mac-server mac-winbox print` on MKT01 — **run it now.** It is the only thing that tells you whether the **live** router still has the recovery path `CM-0018` built, independent of what `026` would rebuild.)*

# Chunk 5 (partial) — the Reconciliation Matrix

> 🔴 **Honest coverage note.** `CM-0001`–`CM-0008` were read **in full**. `CM-0009`–`CM-0020` and `MC-0001`/`MC-0002` have so far been read **only as their Status lines and Guide Reconciliation tables** — which is the *"read only via `grep`"* shortcut `ADR-0019` explicitly criticises. **They are counted as UNREAD.** Chunk 5 completes in the next pass.

## The mechanism, confirmed

**The operator's hypothesis — *"change management happened and the downstream pages were never updated"* — is correct, and it has three distinct mechanisms.**

### Mechanism 1 — ten records have no reconciliation table at all

**`CM-0001`–`CM-0008`, `MC-0001` and `MC-0002` predate Charter Rule 15** (added 2026-07-13) and the Change-Record-Template rewrite. **Four of them have no Build Guide row whatsoever.**

| Record | Build Guide row | Downstream defect it caused |
|---|---|---|
| `CM-0001` | *"not applicable — target already specified this description"* — **truthful** | 🔴 **But `[x] Build Record (023) — confirmed live` was TICKED and `023` was never edited.** → **B6** |
| `CM-0002` | *"not applicable, no target procedure changed"* | `033` did need it. Caught later by `CM-0013`. |
| `CM-0003` | 🔴 **No row exists** | → **C4** — `027` still re-enables `Gi1/0/3` on VLAN 50 |
| `CM-0004` | 🔴 **No row exists** | → **C6** — `025` still never disables the four factory interfaces |
| 🔴 **`CM-0006`** | 🔴 **No row exists** | 🔴 **NEW — E1 below.** `026` never disables `reverse-proxy`. |
| `CM-0008` | 🔴 **No row exists** | Its own Implementation still edits `custom.list` (inert) and uses `cat \| sudo tee` |
| `MC-0001`, `MC-0002` | 🔴 **No row exists** | → **C8** — `025` builds an FGT01 with no Lab CA certificate |

> 🔴 **Charter Rule 15 was written on 2026-07-13 and never applied retroactively.** Nobody went back and asked the first ten records the question. **Every unreconciled guide defect in Chunks 1–3 traces to one of them.**

### Mechanism 2 — records that wrote the table, marked rows 🔴 **Must update**, and closed anyway

| Record | Status | The row it closed over |
|---|---|---|
| `CM-0014` | ✅ **CLOSED** | `048-Teardown-and-Rebuild-Runbook.md` — 🔴 **"Not yet reviewed."** |
| `CM-0015` | ✅ **CLOSED** | Its own change log: *"Guide/Record reconciliation for `026` and `022` **remains open**."* |
| `CM-0018` | ✅ **CLOSED** | `016` — *"Must update at closeout: **MAC-WinBox bypasses every IP control on the router**."* 🔴 **That lesson is NOT in `016`.** Verified by full read. |

**This is `016` lesson 2 — *"a record marked `Closed` with unticked boxes"* — recurring in the records that cite it.**

### 🔴 Mechanism 3 — the instruction said *replace*; the edit *appended*

**`CM-0018` → `026` §12, verbatim:** *"**Replace** `mac-winbox=none` and `discovery=static` with the `RECOVERY` list."*

**The `RECOVERY` block was added at line 41. `mac-winbox=none` was left at line 47.** Last write wins. **The line count went UP — which reads as a plausible edit — and the box was ticked against a diff nobody opened.**

> **`Place-AtlasFiles.ps1` reports a line-count delta precisely so a bad edit is visible.** `tools/README.md` teaches you to look for `496 → 12`. **This edit went the other way and looked fine.**

---

## The two-part authority rule this establishes

🔴 **Charter Locked Rule 13's precedence table has NO ROW FOR CHANGE RECORDS.** That omission is why nobody could tell whether `022` or `CM-0009` won.

**Proposed amendment — Rule 13 gains a row, split in two:**

| Rank | Source |
|---|---|
| 1 | Live device output, captured now |
| 2 | Configuration export from the device |
| 3 | Troubleshooting / incident records written at the time · 🆕 **Change Records — the *executed and read-back* sections** |
| 4 | Build Records |
| 5 | Build Guides |
| 6 | Handoffs, summaries, session narratives · 🆕 **Change Records — the `Status` field and the closeout ticks** |

> 🔴 **A Change Record's OBSERVATION is Rank 3. A Change Record's SELF-ASSESSMENT is Rank 6.**
>
> **The observation is a device read-back, written by someone looking at the device.** It outranks the Build Record and settles disagreements — `CM-0004` settles **B3**, `CM-0001` settles **B6**, `CM-0006` settles **E1**.
>
> **The `Status` field is a claim about work.** It has been wrong five times: `CM-0009`, `CM-0011`, `CM-0014`, `CM-0015`, `CM-0018`. **A ticked box is not evidence that an edit exists. Grep the file.**

---

## 🔴 E1 — NEW: `026` never disables `reverse-proxy`

**`CM-0006` found `reverse-proxy` on MKT01 enabled, with `address=""` (no source restriction) and `CERTIFICATE: none`.** Disabled and verified on the device (`/ip service print`, `X` flag).

🔴 **`026` §12 disables `telnet`, `ftp`, `www`, `api`, `api-ssl` — and NOT `reverse-proxy`.**

**`CM-0006` has no Build Guide row.** A router rebuilt from `026` comes back with an unrestricted, uncertificated reverse proxy listening on 443. **Folded into `CM-0021`.**

## 🟡 E2 — `CM-0008`'s Implementation section still teaches two known-broken patterns

Its **Backup** and **Part 3** both say `sudo nano /etc/pihole/custom.list` — **inert on Pi-hole v6.** Its bundle rebuild uses `cat … | sudo tee` — **the pipeline that wrote a keyless certificate into production.**

**`CM-0008`'s own closeout explains both failures in detail.** The Implementation section above it was never corrected. **A reader executing the record as written repeats both.**

## 🟡 E3 — `CM-0005` carries an open item that was closed elsewhere

`CM-0005`: *"**Still open and NOT closed by `MC-0001`:** FGT01's certificate SAN was never independently verified against the CA-wide `copy_extensions` defect."*

**It was.** `031` v0.6, `029`, and the manifest all record FGT01's SAN verified on the wire, 2026-07-13 evening — *"`-extfile` bypasses `copy_extensions` entirely; it was never affected."*

## 🟡 E4 — `006` and `003` disagree about `Gi1/0/2`

| Document | `Gi1/0/2` is |
|---|---|
| `003`, `023`, `027` | **LabComputer** |
| 🔴 **`006`** (IP table) | 🔴 **Admin workstation** — `10.10.0.50`, `0000.5e00.5316`, `Gi1/0/2` |
| `003` (recovery row) | Admin workstation → **`bridgeLocal`**, `ether4`–`ether13` |

**`CM-0003` says it *"tightened the admin workstation port reference to `Gi1/0/2`."*** **Are LabComputer and the admin workstation the same machine?** `006`'s MAC table calls it *"Admin workstation — **Ethernet 2**"*, which suggests a second NIC. **Unresolved. `DEVICE CHECK` D16.**

---

## Device checks — Chunk 5

| # | Question | Command | Settles |
|---|---|---|---|
| **D16** | Is `Gi1/0/2` LabComputer, the admin workstation, or both? | `show mac address-table interface Gi1/0/2` | **E4** |
| **D17** | Is `reverse-proxy` still disabled on the live MKT01? | `/ip service print` | **E1** — confirm the device is still right even though the guide is wrong |

# Chunk 4 (partial) — Operations, 10 of 23

> **Read in full:** `015`, `016`, `017`, `019`, `020`, `039`, `045`, `048`. **Still unread:** `018`, `035`–`038`, `040`–`044`, `046`, `047`, `049`, `050`, `Build-Order-and-Dependencies`, `README`.
>
> 🟢 **`048`, `015`, `017` and `019` are strong documents.** The failures here are **reconciliation misses**, not bad writing.

## The coverage table

| # | Document | Contradicts another document? | Contradicts a device? | Untested claim? |
|---|---|---|---|---|
| `015` | Network Validation Guide | 🔴 **YES — two.** Its own command block contradicts its own warning. See F2. | — | 🔴 **No `radtest` check. `CM-0013` demanded one and closed without it.** |
| `016` | Network Lessons Learned | 🔴 **YES.** `CM-0018` owed it a lesson that is not there. See F3. | — | ✅ Excellent otherwise |
| `017` | Future Expansion | ✅ **No.** 🟢 v2.0 corrected the `bridgeLocal` proposal. | — | ✅ Gated items carry their gates |
| `019` | Change Management | 🟡 **One.** Still lists the MKT01 rename as open. See F4. | — | ✅ **Step 11 is the fix for everything this audit found.** |
| 🔴 `020` | Network Revision History | 🔴 **It is a stub with NO revision history in it.** See F5. | — | 🔴 **Empty** |
| `039` | SW01 Troubleshooting Guide | 🟡 **One** (points at `027`). | — | 🔴 **Omits SW01's most expensive incident.** See F6. |
| `045` | SW01 CIS Hardening Checklist | 🔴 **YES — two.** See F7, F8. | 🔴 **`DEVICE CHECK`** D14 | 🔴 **Marks as "Unverified" a fact two documents state plainly** |
| 🔴 `048` | Teardown and Rebuild Runbook | 🔴 **YES — it does not know `049` exists.** See **F1** and **`CM-0025`**. | — | 🟢 **Bootstrap table, `STATIC-HOSTS` and iDRAC warning ALL CORRECT** |

---

## 🔴 F1 — `048` Phase 0 rebuilds the archive `CM-0010` destroyed → **`CM-0025`**

**`048` Phase 0.3** runs a plain `tar -czvf pi01-full-$(date +%F).tar.gz` over `/etc/ssl/lab-ca`, `~/vaultwarden/data` and `/etc/freeradius`. **Unencrypted. Both CA keys, the whole vault, every RADIUS secret.**

**That is `pi01-full-backup-2026-07-12.tar.gz`** — which `029` records as *"never a valid recovery point… **it could not save you, and it could hurt you**"* and which `CM-0010` destroyed.

**`048` has no pre-archive `ls -la`** — the check `031` v0.5 and `049` Phase 0.2 both mandate, **which exists because of that exact tarball.**

```
grep -c "049" 048-Teardown-and-Rebuild-Runbook.md   →   0
```

🔴 **`048` references `049` ZERO times.** Two incompatible backup schemes; the teardown runbook teaches the destroyed one.

> 🔴 **`CM-0014` listed `048` as *"Not yet reviewed"* and CLOSED. This is that review. The answer is worse than the question.**

**🟢 What `048` gets RIGHT — and this clears both blockers:**

| `CM` | Its `048` row | Verdict |
|---|---|---|
| `CM-0017` / `CM-0018` | *"Bootstrap table must say MKT01 has no path / `ether4` only"* | ✅ **DONE.** `048` Phase 1 is current: tested, `ether4`, 15-second drop, **no serial console**, `ADR-0016`. |
| `CM-0012` | *"Phase 1 lists iDRAC as PVE01's bootstrap path"* | ✅ **DONE.** `048` says physical console first; **"iDRAC is NOT independent… it dies with SW01."** |
| — | `STATIC-HOSTS` | ✅ **FIVE entries, Pi01 included**, with *"build the ACL from this list, not from a stale record."* |

🔴 **`CM-0021`'s and `CM-0022`'s `048` blockers are therefore CLEARED.**

**But:** `048` §3.1 step 7 says *"Per `027-SW01-Build-Guide.md`"* — **and `027` builds four.** **The runbook warns you about the stale record and then hands it to you.** The warning is a callout; `027` is the procedure. **`CM-0022` remains correct and necessary.**

## 🔴 F2 — `015`'s FGT01 command block uses `show`. Its own warning says don't.

`015` FGT01 core commands: `show system interface wan1`, **`show firewall policy`**.

**Directly beneath, in the same document:** 🔴 *"**Use `get`, not `show`**, when you need to confirm a value actually holds. `show` displays only non-default values… **Empty output is not proof.**"*

**The guide states the rule and then hands you the commands that violate it.** *(Same defect as `005` — **A10** — and `025` — **C8**. Three documents.)*

## 🔴 F3 — `CM-0013` and `CM-0018` both owed `016`/`015` content and closed without it

| Record | Row | Reality |
|---|---|---|
| `CM-0013` | *"`015` — 🔴 **Must update.** Add the `radtest` check as the standing RADIUS validation."* | 🔴 **`015` v2.0 has no `radtest`.** RADIUS has **no standing validation** — the exact gap `CM-0013` was raised to close. |
| `CM-0013` | *"`033` — add `radtest-verify` as the final mandatory validation step"* | 🟡 **Partial.** `033` has `radtest` in Validation, but no mandatory closing step. |
| `CM-0018` | *"`016` — Must update at closeout: **MAC-WinBox bypasses every IP control on the router**."* | 🔴 **Not in `016`.** Confirmed by full read. |

**Both records are `Closed`.** **This is Mechanism 2, verified against the target documents rather than against the records' own claims.**

## 🟡 F4 — `019` still lists the MKT01 rename as open

> *"Initial Required Changes — carried forward, **still open**: **Rename live MikroTik identity to `MKT01`.**"*

**`022` confirms the device is `MKT01` and the deviation is CLOSED.** ✅ **`019` correctly still lists the SW01 rename** — which supports **`CM-0024`**.

## 🔴 F5 — `020-Network-Revision-History.md` contains no revision history

**It is 895 bytes.** It says *"Version 1.0 Draft — initial Confluence review edition"* and lists Freeze Criteria. **There are no revision entries. None. Ever.**

**Book 1 has 25 change records, 19 ADRs and dozens of document versions.** `020` records **zero**.

> 🔴 **And this explains a pattern.** `CM-0001`, `CM-0002`, `CM-0003` and `CM-0008` all carry an **unticked** `[ ] Revision History` box. **They are unticked because the document they point at has never been written.** **Four records could not close cleanly, and nobody asked why.**

**`020` also still describes the freeze as a future event. Book 1 is frozen.**

## 🔴 F6 — `039` omits SW01's most expensive incident

`039` documents five real incidents: the placeholder-password lockout, `show vlan`, SFP numbering, console baud, and the native-VLAN design.

🔴 **It does not mention `STATIC-HOSTS` / DAI silent-drop at all.**

**That is SW01's single most likely failure mode** — `DHCP Permits: 0`, no snooping fallback, **a missing host is dropped with no error and simply appears broken.** It produced the false *"Pi01 should be unreachable"* mystery that **survived three handoffs** and is recorded as `016` lesson 6.

> **The troubleshooting guide for SW01 does not contain the SW01 problem that cost the most time in the project's history.** **Folded into `CM-0022`.**

## 🔴 F7 — `045` marks the SNMP exposure "Unverified." Two documents state it plainly.

`045` §1.5:
- `[x]` *"SNMP configured and verified — confirmed live"*
- `[ ]` *"SNMP community strings are non-default, **SNMPv3** in use rather than v1/v2c — **Unverified.** Worth confirming which SNMP version is actually in use."*

🔴 **It is not unverified.** `023` records `community homelab (ro)`, host `10.40.0.52`. `027` Step 17 **types** `snmp-server host 10.40.0.52 traps **version 2c** homelab`. **The Charter names the string and orders it rotated.**

> 🔴 **And `[x] SNMP configured and verified` is a tick on the wrong question.** It confirms SNMP **exists**. It says nothing about whether it is **safe**. **`015`'s own rule: *if you cannot make the test succeed on purpose, its failure means nothing* — and the corollary, a test that answers a different question than the one you asked.**

**`045` ranks this #3. It is the live cleartext credential `ADR-0010` gates publication on.** → **`CM-0023`**.

## 🔴 F8 — `045` says MKT01 has 23 firewall rules. The device has 22.

> *"Real routing security lives on MKT01, which has its own confirmed firewall rule set (validated earlier this session, **23 rules**)."*

**`022` v2.5, read from `/ip firewall filter print count-only`: **22**.** `022`'s own historical note lists *"three earlier documents claimed **22**, **23**, **24**."* 🔴 **`045` is one of the three, and `CM-0009` never reconciled it.**

**`CM-0009`'s reconciliation table covered `026`, `033`, `022`, `041`, `009`, `011`. It did not list `045`.**

*(`045` does confirm SW01's IOS as `15.2(2)E6`, matching `023` and contradicting `027`'s `15.2(7)E` — **C14**. `027` is the outlier.)*

---

## Device checks — Chunk 4

| # | Question | Command | Settles |
|---|---|---|---|
| **D18** | 🔴 **Does an off-site copy of the `049` archive physically exist?** *(restated — still the biggest open question in the lab)* | **Go and look.** Then `sha256sum` it against the Pi01 copy. | **B12**, `CM-0025` |
| **D19** | Does SW01 have a login banner and a VTY access-class? | `show run \| i banner` · `show run \| s line vty` | `045` §1.2, §1.3 |

# Chunk 4 (cont.) — `018`, `037`, `041`, `044`, Book 1 `README`

## 🔴🔴 G1 — `018` v3.0 declares two sentences FALSE, then reprints both as its own recommendation

**Line 49:** 🔴 **"BOTH SENTENCES ARE FALSE. Tested 2026-07-14 against the exact file and the exact leaked value."**

**Lines 69–70 — twenty-one lines below, in the table titled *"The control is mechanical, or it does not exist"*:**

> *"`.gitignore` — … **A backstop, not a control.**"*
> 🔴 *"**Pre-commit secret scan** — **This is the control.** … **Nothing else in this list would have stopped `ac2182f`.**"*

**Verbatim. Both of them. As the page's own recommendation.**

**And `018`'s own test table, in the same document, says:**

| Control | Would it have stopped the real leak? |
|---|---|
| **Gitleaks default (content) ruleset** | 🔴 **NO.** Scanned all 25 bytes. **"no leaks found."** |
| **A NAME-based rule** | ✅ **YES.** Blocked immediately. |

> 🔴 **The content scanner is not "the control." It is the control that FAILED.**
> 🔴 **The name-based rule is not "a backstop." It is the only thing that worked.**
>
> 🔴 **`ADR-0010` gates publication of this repository on the control `018` names. `018` names the wrong one — and knows it.**

*(🟢 `.gitleaks.toml` and `.gitignore` **already carry the correct name-based rules.** The config is right. **The document describing it is wrong.**)*

→ **`CM-0026`**

## 🔴🔴 G2 — THE PATTERN, NAMED: the correction is appended; the error is not deleted

**Three occurrences, all found in this audit:**

| Document | Correction added | Error left standing | Which one wins |
|---|---|---|---|
| **`026` §12** | `mac-winbox = RECOVERY` — line 41 | `mac-winbox = none` — line 47 | 🔴 **The error.** Last write wins on a device. |
| **`018` v3.0** | *"BOTH SENTENCES ARE FALSE"* — line 49 | Both sentences — lines 69–70 | 🔴 **The error.** It is in the recommendation table. |
| **`021`** | *"Interfaces — Disabled"*, `Verified` | *"left at factory defaults **rather than disabled**"* | 🔴 Coin-flip. |

> 🔴 **In every case the author knew the truth, wrote the truth, and did not delete the lie.**
>
> **Appending feels safe. Deleting requires certainty.** And the `[chg ]` line-count delta **goes UP** — which reads as a plausible edit, and is the opposite of the `496 → 12` shape `tools/README.md` teaches you to catch.

**The remedy is a verification habit, not a rule:**

> 🔴 **Verify a correction by COUNTING how many times the OLD text appears — not by confirming the NEW text is present.**
>
> A `Select-String` hit on the fix proves the fix landed. **It proves nothing about whether the thing it replaced is still sitting twenty lines below it.**

## 🔴 G3 — `CM-0004` required a note in `037`. It closed without it.

**`CM-0004` closeout:** *"**`037` should carry a 'FortiOS CLI is not a Linux shell' note.** The next person to type `grep -E` on that box loses the same ten minutes."*

```
grep -ci "grep -E|not a Linux shell|FortiOS grep" 037-FGT01-Troubleshooting-Guide.md   →   0
```

🔴 **Not there. `CM-0004` is `Closed`.** *(Otherwise `037` is good — Feature Visibility, leaf-vs-bundle, the silently unbound `admin-server-cert`, the VDOM lockout, and it correctly opens with `get` vs `show`.)*

## 🔴 G4 — `041` omits MKT01's two worst failure modes

`041` documents WinBox permissions, certificate renaming, SAN mismatch, `use-radius`, and duplicate RADIUS entries. **All real, all good.**

🔴 **It contains NOTHING about:**

| Missing | Why it matters |
|---|---|
| 🔴 **`hw=no` on `ether3`** | **`026` calls it *"the single most critical step in the build."*** `016` and `048` both say the symptom *"looks like everything except what it is"* — `ether3` shows RX while every VLAN interface shows zero. **The MKT01 troubleshooting guide does not contain MKT01's hardest fault.** |
| 🔴 **MAC-WinBox / the recovery path** | **MKT01 has no serial console.** If you are locked out, `041` tells you nothing — not the `RECOVERY` list, not `ether4`, not the 15-second drop. **`CM-0017` and `CM-0018` reconciled `026`, `003`, `048`, `016` and `022`. Neither listed `041`.** |

> **A troubleshooting guide is read when something is broken. `041` covers certificate installation — which is not when things break.**

## 🔴 G5 — `044`: every device admin password in the lab is still the original

**`044` "Outstanding — Device Password Rotation" — SEVEN unticked boxes:**

`[ ]` FGT01 admin · `[ ]` MKT01 `admin` and `SethAdmin` · `[ ]` SW01 enable secret · `[ ]` Pi01 `dnsadmin` · `[ ]` PVE01 `root` and `seth-admin` · `[ ]` iDRAC-PVE01 admin

> *"Rotation was deliberately deferred until Vaultwarden was production-ready. **It now is.** These still hold their original values."*

🔴 **Vaultwarden went production-ready on 2026-07-13. Nothing has rotated. There is no change record.** It is an orphan checklist in an Operations document with no owner and no gate.

🔴 **And `024`/`CM-0011` record the iDRAC as being on *factory* credentials** — so `iDRAC-PVE01 - Admin` in the vault is a **factory default**, not merely un-rotated.

🟡 **Also:** `CM-0014` reviewed `044` as *"no change needed — `044`'s rule (archive passphrase never goes in Vaultwarden) **held perfectly**."* 🔴 **`044` does not contain that rule.** Its *"What Does Not Go in Vaultwarden"* section names *"anything that isn't a credential"* and *"placeholder entries."* **The archive passphrase is not mentioned.** The rule lives in `049` Phase 1 only. **`CM-0014` credited `044` with a rule it does not state.**

## 🔴 G6 — Book 1's `README.md` is the landing page, and it is two weeks stale

> *"**Status:** Draft repository assembled. Next milestone: publish to Confluence and reconcile."*
> *"The repository currently contains the **28-page** Network draft."*
> *"…before Network v1.0 is **frozen**."*

🔴 **Book 1 is FROZEN. It has 76 documents, not 28.** **`Atlas-Repository-Structure-and-Navigation.md` designates `README.md` as *"THE LANDING PAGE — links to everything below by NAME."*** **This one links to nothing and describes a book that no longer exists.**

# Chunk 4 (cont.) — `035`, `036`, `040`, `042`

## 🔴🔴 H1 — `035` issues certificates with **no SAN**. It is the runbook used every time.

**`035` says of itself:** *"This document covers **the task you'll actually repeat** every time a new device or service needs HTTPS."*

```
grep -c "addext|subjectAltName"       035   →   0
grep -ci "Subject Alternative Name"   035   →   0
grep -ci "bundle"                     035   →   0
```

**Three zeroes. Each is a documented incident.**

| `035` does | Every other PKI document says | The incident |
|---|---|---|
| 🔴 `openssl req -new -sha256 -out csr/…` — **no `-addext`** | `031`, `042`: *"**`-addext` is what sets the SAN.**"* **Browsers ignore Common Name entirely. No SAN = rejected.** | 🔴 **`mikrotik.lab` serial `1000` — the SAN-less certificate `MC-0002` had to revoke and reissue.** |
| 🔴 **No SAN verification after signing** | `031`, `042`, `016`: *"**Always verify the SAN after signing. A clean sign log proves nothing.**"* | 🔴 **`copy_extensions` was unset from the CA's build until 2026-07-13 — every certificate silently issued without a SAN, and the log looked clean.** |
| 🔴 **Installs the BARE LEAF** — *"upload the `.crt` as certificate, `.key` as key"* | `037`, `MC-0001`, `042`: *"build a **bundle** (leaf + chain) and import **that**. `s_client \| grep -c` must return **3**."* | 🔴 **`ERR_CERT_AUTHORITY_INVALID`. The `MC-0001` incident, verbatim.** |
| 🔴 **No binding verification** | `037`: *"`get system global \| grep admin-server-cert` — **`get`, not `show`**."* | 🔴 **`set admin-server-cert` ran, returned no error, and never took effect. This is the ORIGIN of Charter Rule 13's corollary.** |

> 🔴 **`MC-0001`, `MC-0002` and `CM-0008` all fixed `031`. Not one of them opened `035`.**
>
> **`031` is read once, when the CA is built. `035` is read every time a device needs a certificate.**

→ **`CM-0027`**

## 🔴 H2 — `042` still teaches a revocation that reaches nobody

**`042` "When to Reissue" — for an exposed key:** 🔴 *"**Yes — revoke. Do not just let it expire.**"* Step 5 gives `openssl ca -revoke`.

```
grep -ci "crlDistributionPoints|CRL Distribution|does not work|decorative"   042   →   0
```

**`031` v0.7 and `ADR-0009`, both `Verified`:**

> 🔴 *"**REVOCATION DOES NOT WORK IN THIS CA.** `grep -r crlDistributionPoints` returns **zero**. No client is ever told where to look, so no client ever looks. **`MC-0002` revoked serial `1000` — and it remains fully trusted by every device holding the Root CA.** **A revocation nobody checks is a filing action, not a security control.**"*

🔴 **`042` is the document you open when a key has been exposed** — the worst possible moment to be told to run a command that does nothing.

*(🟢 `042` is otherwise excellent: the `sudo sh -c` fix, `-issuer` in validation, the key-reuse decision, the CA-uniqueness trap. **One section is the defect.**)*

## 🔴🔴 H3 — THE SECOND PATTERN: the correction reaches the GUIDE and misses the RUNBOOK

**Three instances, identical shape, all found in this audit:**

| Corrected | 🔴 Missed | The missed document is… |
|---|---|---|
| `006`, `012`, `023`, `016` — *the ACL* | 🔴 **`027`** | …the guide that **BUILDS** the ACL |
| `031`, `029`, `049`, `043` — *the CA backup* | 🔴 **`048`** | …the runbook that **TAKES** the backup |
| `031` — *SAN, bundle, revocation* | 🔴 **`035`, `042`** | …the runbooks that **ISSUE** and **REISSUE** |

> 🔴 **The correction pass finds the document that DESCRIBES the thing and misses the one that DOES it.**
>
> **And the one that does it is the only one anybody executes.**

**This is `016` lesson 8 one level up.** Lesson 8 says *a guide that does not mention a thing will recreate the thing.* **The generalisation: a reconciliation that does not open the document that performs the work has not happened.**

**Ask, at every closeout: *which document does the WORK?* Fix that one first.**

*(Together with **G2** — *the correction is appended and the error is not deleted* — these two patterns account for **every rebuild-fatal defect in this audit.**)*

## 🟢 H4 — `036` and `040` are clean, and `036` settles **B9**

**`036-PVE01-Troubleshooting-Guide.md`** v1.1 — 🟢 **correct, current, and it knows the right hardware numbers:**

> *"Expected if healthy: count returns **the logical CPU count (16 on this host)**"*

🔴 **`024` says 32 vCPUs and 32 GB.** **`036` says 16.** `VM-and-Services-Inventory`, `Atlas-Service-Architecture` and `Atlas-Workflow` all say **16 / 62 GiB**.

> **Five documents say 16. `024` — the Build Record, the "verified reality" layer — says 32.** **B9 confirmed from a fifth source.**

**`036` also carries the `sudo`-is-not-installed warning, the CMOS-battery-explains-three-symptoms entry, and the DIMM socket fault. `040` (Remote Access) is clean.** 🟢 **Both are good documents.**

# Chunk 4 (cont.) — `038`, `046`, `047`, `050`, `Build-Order-and-Dependencies`

## The coverage table

| # | Document | Contradicts another document? | Untested claim? |
|---|---|---|---|
| `038` | Pi01 Troubleshooting Guide | 🟡 **One — and it is a live credential.** See J1. | 🟢 **Excellent otherwise** |
| `046` | Pi01 CIS Hardening Checklist | ✅ **No.** | 🔴 **Omits Pi01's three biggest risks.** See J2. |
| `047` | FGT01 CIS Hardening Checklist | ✅ **No.** | 🔴 **Omits the FGT01 hardening finding.** See J3. |
| 🟢 `050` | PVE01 iDRAC Onboarding Runbook | 🔴 **One — it depends on `035`.** See J4. | 🟢 **The best-reasoned document in Book 1.** |
| 🔴 `Build-Order` | Build Order and Dependencies | 🔴 **YES — five, incl. the *third* "Pi-hole is optional."** See J5. | 🔴 **No Document Control block at all** |

---

## 🟡 J1 — `038`'s FreeRADIUS fix recreates the `testing`/`password` account

**`038`, "FreeRADIUS Test User Always Returns Access-Reject" — the *Resolution* block, copy-pasteable:**

```text
testing Cleartext-Password := "password"
    Reply-Message := "Hello, %{User-Name}"
```

🔴 **That is the deleted account.** It became *"a real, working, publicly-documented credential capable of authenticating to network device admin logins"* the moment RADIUS worked (`033` v1.1, `CM-0013`, `029`).

**The Charter's *Evidence and secrets* section carves this out explicitly:**

> *"`testing` / `password` — **deleted.** **Keep it, named, in the Build Record and Troubleshooting Guide.** It is the best lesson in the project. **Remove it only from any guide that instructs you to *create* it.**"*

> 🟡 **So this is a judgement call, and it is the operator's, not the auditor's.** **`038` is a Troubleshooting Guide — the Charter says keep it there.** **But `038` does not merely *name* it. It presents it as a Resolution, in a code block, to a reader who is currently getting `Access-Reject` and will paste it.**
>
> **The Charter's carve-out assumed the credential would appear as a *lesson*. In `038` it appears as a *fix*.**

**Suggested:** keep the incident, keep the `:=` vs `==` lesson (which is the actual finding), and **change the example to `<testuser>` / `<generated-value>` with the removal step — matching `033` v1.1.** **Your call.**

*(🟢 `038` is otherwise one of the strongest documents in Book 1: the `custom.list` trap, the `sudo`-pipeline failure, persistent logging, and an honest *"root cause was not conclusively identified"* on the hard hang.)*

## 🔴 J2 — `046` omits Pi01's three biggest risks

**`046` is the Pi01 hardening checklist. It does not mention:**

| Missing | Where it is recorded |
|---|---|
| 🔴 **`wlan0` is not disabled by any document** | **`010`:** *"`wlan0` is administratively DOWN… **A reflash brings it back up and no document says to disable it** — the `modem` failure exactly."* **`046` is the document that would say it.** |
| 🔴 **`docker0` + a running `veth` — the Vaultwarden container's network namespace** | **`010`:** *"in NO Atlas network document… **`006` describes 20% of Pi01's network reality.**"* Flagged *"tracked for a future pass."* **Nothing tracks it. `046` doesn't either.** |
| 🔴 **The Root CA lives on this networked, multi-service host** | **Roadmap Critical Risk #1. `ADR-0015`. `Atlas-Service-Architecture`:** *"The Pi is not underpowered. **It is over-trusted.**"* |

> **A hardening checklist that ranks `/tmp` mount options above *"the Root CA private key is on a networked Docker host that has already hard-hung once"* is ranking by benchmark, not by risk.**

## 🔴 J3 — `047` omits the FGT01 hardening finding

**`047` is the FGT01 hardening checklist. `CM-0004` — the FGT01 hardening change record — found four factory interfaces enabled and admin-reachable, including `internal` holding `192.168.1.99` and `modem` carrying an encrypted PPPoE credential.**

🔴 **`047` does not mention any of them.** No unused-interface item, no `modem`, no `192.168.1.99`.

*(✅ `047` correctly flags the 2015–2018 UTM signature databases as a **confirmed gap** — Roadmap Critical Risk #2 — and correctly notes there is no named, scoped admin account.)*

## 🔴 J4 — `050` is excellent, and it depends on `035`

🟢 **`050` is the best-reasoned document in Book 1.** It correctly reframes `CM-0011` (*"you cannot harden what was never built"*), blocks itself on `CM-0012`, orders the steps so **nothing is configured on a surface that cannot be verified**, and understands that **the cipher-0 test only becomes meaningful once the channel is open.**

🔴 **And its Step 4 says: *"Issue it a Lab CA certificate per `035`."***

**`035` issues certificates with NO SAN** (**H1**, `CM-0027`).

**`050` Step 4 even says, in the next line:** *"**SAN must include the current management IP and the hostname** (`042` / the MKT01 SAN lesson)."*

> 🔴 **`050` knows the SAN matters, states it explicitly, and hands you a runbook that does not set one.** **A correctly-executed `050` produces a SAN-less iDRAC certificate — a browser name-mismatch on the one interface you reach for when everything else is down.**
>
> **`CM-0027` is a prerequisite for `050`.**

## 🔴 J5 — `Build-Order-and-Dependencies` is the THIRD document to call Pi-hole "optional"

**`048`'s Related Pages calls this *"the dependency graph."*** It has **no Document Control block** — no version, no status, no Evidence Status, no change log.

| `Build-Order` says | Contradicts |
|---|---|
| 🔴 Phase 2.3: *"DNS cutover… **Pi-hole becomes optional upstream forwarder for dc01.**"* | 🔴 **`013` v2.0 and `017` v2.0 were BOTH rewritten on 2026-07-14 to kill this exact wording.** *"A reader following v1.0 would have concluded Pi-hole was disposable and **removed a load-bearing service**."* **`001` still says it too (A2). This is the third.** |
| Phase 2: *"TrueNAS — VM on VLAN 20, `10.20.0.20`"* as a required step | `VM-and-Services-Inventory`: **"Explicitly Deferred, Not Sized Yet."** |
| Phase 2: *"DNS resolves **`lab.local`** records"* | **`ADR-0007` adopted `atlas.lab`.** Devices are `<device>.lab`. **`ADR-0012` quarantined a Confluence page for using `atlas.local` on the grounds that *"that domain has never existed."*** **`lab.local` is now the third domain name in play.** |
| Phase 2 validation: *"`nslookup pve01.lab` returns `10.10.0.10`"* | **The Pi-hole record is `proxmox.lab`, not `pve01.lab`** (`032`, `CM-0008`). **The validation step fails as written.** |
| Phase 4: *"ADCS — two-tier PKI"* with no mention of coexistence | **`ADR-0003`: AD CS is scoped to domain-joined resources ONLY. The OpenSSL Lab CA is NOT deprecated.** |

> 🔴 **The "Pi-hole is optional" sentence has now been found in three separate documents, corrected in two of them, and left standing in `001` and `Build-Order`.**
>
> **This is `G2` (append, don't delete) at the repository level: the correction was made where it was noticed, and the same sentence elsewhere was never searched for.**
>
> 🔴 **The remedy is one command:** `grep -ril "pi-hole is optional\|optional upstream\|optional filtering" Labs/Lab-01-Mikrotik-Core/` — **and nobody ran it.**

# Chunk 4 (complete) — `043`, `049`

## ✅ K1 — **B12 IS SETTLED.** There is no off-site copy. `049` says so in its own header.

**`049-Root-CA-and-Credential-Backup-Runbook.md`, `Evidence Status: **Verified** — "every command below was executed on the live device on 2026-07-13 and its real output recorded. **This is not a plan. It is a transcript.**"**

**Its second heading, verbatim:**

> ## 🔴 OPEN — This Backup Is Not Finished
>
> | Copy | Location | Survives |
> |---|---|---|
> | `~/atlas-backup/` on Pi01 | The desk | **Nothing. It is *on* the machine it protects.** |
> | `E:\` on the workstation | **The same room** | A dead SSD. **Not a fire, a flood, or a theft.** |
> | **Off-site** | ❌ **DOES NOT EXIST** | — |
>
> **Two copies in one room is redundancy, not a backup.** **Phase 5 is the whole point. It is ten minutes. Do it.**

**The tally:**

| Document | Off-site copy? |
|---|---|
| 🔴 **`029`** (Build Record) | *"Copies: Pi01, `E:\` (hash-verified), **off-site USB**"* — *"held off-site"* |
| ✅ **`049`** (Runbook — verified transcript) | ❌ **DOES NOT EXIST** |
| ✅ `Session-Handoff` v7.0 #3 | *"Both archive copies are in the same room."* |
| ✅ `To-The-Next-Session` risk #1 | *"Both copies of the archive are in the same room."* |
| ✅ `Atlas-Service-Architecture` | *"Both copies of your CA archive are in the same room."* |
| ✅ `Atlas-Roadmap` Critical Risk #1 | *"Offline media. Two copies. **One off-site.**"* — as a **requirement**, not a fact |

> 🔴 **Five documents against one. `029` is wrong.**
>
> **`029` — the Build Record, the "verified reality" layer — asserts that the single biggest unmitigated risk in the lab is already mitigated. It is not.** **B12 confirmed. `029` must be corrected.**
>
> **D18 is no longer a question of "which document is right." It is: `049` Phase 5 takes ten minutes. Do it.**

🟢 **`049` is the best security document in Book 1.** The circular-dependency diagram, *"Vaultwarden is a convenience store, not a recovery store,"* rotate-before-you-back-up, the ASCII-passphrase rule (*"you could hold a perfect backup and a correct paper passphrase and still be locked out, permanently, by a currency symbol"*), the SQLite WAL discovery, and a *"What Went Wrong When We Ran This"* section that preserves its own v1.0 errors. **Nothing in this audit improves on it.**

## 🔴 K2 — `049` names a decision that is owed and that nothing tracks

> **"Decision you still owe."** *"**The Vaultwarden master password exists only in your head.** The archive contains the vault; the vault is useless without it. The CA is now covered by paper — **the rest of the vault is not.** … **It should be a decision, not an oversight.** **Worth an ADR either way.**"*

🔴 **No such ADR exists.** **`ADR-0009`'s own rule applies: *an accepted risk with no review trigger is not an accepted risk. It is a forgotten one.***

## 🔴🔴 K3 — `043` makes an OPEN credential exposure look closed

**`043` Part 9, step 6:** *"Old plaintext desktop file — **flagged for permanent deletion**, not just Recycle Bin."*

**`Session-Handoff` v7.0 open item #5 and `To-The-Next-Session` §5, both 2026-07-14:**

> 🔴 *"**The OneDrive desktop hunt was never validly performed.** The original search used `$env:USERPROFILE\Desktop` = **`C:\Users\Seth\Desktop`**. **The real desktop is `C:\Users\Seth\OneDrive\Desktop`.** **The clean result proved nothing** — and if that plaintext passphrase file was ever there, **it synced to Microsoft's servers**, and a local delete did not touch the cloud recycle bin or version history."*

> 🔴 **`043` is the narrative everyone reads to understand what happened. It says the plaintext passphrase file was dealt with.**
>
> **It was searched for in the wrong folder, found nothing, and that nothing was read as an answer.** **This is `016` lesson 4 — *a test that cannot fail proves nothing* — applied to the original exposure that started the entire session.**
>
> **The old CA passphrases have since been rotated (`CM-0010`), so the file's value is inert. But nobody has established whether it existed, whether it synced, or whether it is still in a Microsoft cloud recycle bin.** **`043` should not read as if it were handled.**

## 🔴 K4 — `035` was WRITTEN during the session that found the defects it omits

**`043`'s index lists, under *"Operations Guides"* touched that session:** `035`, `042`, `037`, `038`, `041`.

**`035`'s own header:** *"written from the live FGT01/MikroTik certificate work **this session**."*

🔴 **`035` was authored during the very session that discovered — in this order — the leaf-vs-bundle failure (`MC-0001`), the silently unbound `admin-server-cert` (`MC-0001`), the stale SAN (`CM-0007`), and the CA-wide missing SAN (`MC-0002`).**

🔴 **It contains none of them.** No `-addext`. No bundle. No SAN check. No `get system global`. *(**H1** / `CM-0027`.)*

> **The session that found four PKI defects wrote a PKI runbook that reproduces all four.** **The narrative captured them. The runbook did not.**
>
> **This is `H3` at its sharpest: the correction reached the document that DESCRIBES the work and missed the one that DOES it — on the same day, in the same session, by the same author.**

## 🟡 K5 — `043` carries an open item that was closed elsewhere

**`043` Part 4:** *"**Real finding, flagged but not yet resolved:** Pi-hole's and FortiGate's original certificates have never had their SAN independently re-verified against this same `copy_extensions` gap."*

**It was resolved.** `031` v0.6, `029`, and `NETWORK-PACK-MANIFEST` all record it: both verified on the wire 2026-07-13 evening; **FGT01's predates the fix and was correct anyway because `-extfile` bypasses `copy_extensions` entirely.** *(Same defect as `CM-0005` — **E3**.)*

# Chunk 5 (cont.) — the Change Records turn out to have the disease they diagnose

## 🔴🔴 L1 — THE PATTERN, at SIX occurrences. Three are in the change records themselves.

**`G2`: *the correction is APPENDED; the error is not DELETED.*** **It is not a documentation habit. It is the project's dominant failure mode.**

| # | Document | The correction | The error, still standing | Distance |
|---|---|---|---|---|
| 1 | `026` §12 | `mac-winbox = RECOVERY` | `mac-winbox = none` | **6 lines** |
| 2 | `018` v3.0 | *"BOTH SENTENCES ARE FALSE"* | Both sentences, as the recommendation | **21 lines** |
| 3 | `021` | *"Interfaces — Disabled"*, `Verified` | *"left at factory defaults rather than disabled"* | ~30 lines |
| 🔴 **4** | **`CM-0009`** | 🔴 **A section titled *"Closeout defect — this record was marked `Closed` with two boxes unticked"*** | 🔴 **Its own closeout, 20 lines above, with THREE boxes unticked and `[x] Closed`** | **20 lines** |
| 🔴 **5** | **`CM-0012`** | 🔴 **§3: *"Cipher 0 — the 'proof' here is VOID."*** | 🔴 **Its Note: *"Cipher 0 was hardened tonight, and it is **the right kind of proof** — the exploit failing."*** | **87 lines** |
| 🔴 **6** | **`CM-0016`** | ✅ **Status: *"Closed 2026-07-14 — executed and read back."*** | 🔴 **The next line: *"**This is a `Draft`.** A Draft record is a hypothesis, not a work order."*** | 🔴 **4 lines** |

### 🔴 L1a — `CM-0009` documents its own closeout defect and does not fix its own closeout

**Its Closeout, as committed:**

```
- [ ] Implemented                                    ← UNTICKED
- [x] Validated — rule count read back as 22
- [ ] Build Record updated                           ← UNTICKED
- [ ] Guide reconciliation answered in writing above ← UNTICKED
- [x] Closed
```

**And 20 lines below, a section headed *"🔴 Closeout defect — found 2026-07-13":***

> *"**This record was marked `CLOSED — implemented and verified` while two of its own closeout boxes were unticked.** … **The closeout was invented to catch exactly this class of defect — and then the closeout itself was not completed.** **A checklist that nobody verifies reports success by default.**"*

> 🔴 **It found the defect. It wrote the defect up. It cited the defect in `016`. It did not tick the boxes.**
>
> **There are now THREE unticked, not two.** And its *Documentation updates* section ticks *"Build Record updated"* while its *Closeout* leaves the same item unticked — **the same document, two answers, ten lines apart.**

### 🔴 L1b — `CM-0016` is `Closed` and `Draft` in the same header

**Line 5:** `| Status | ✅ **Closed 2026-07-14 — executed and read back.** |`
**Line 12:** `> 🔴 **This is a `Draft`. A Draft record is a hypothesis, not a work order.** Read the device before executing it. **`CM-0011` was run as a to-do list against a stale baseline and degraded a BMC.**`

> 🔴 **Four lines apart.** The Draft warning was written when the record *was* a Draft, and never removed at closeout.
>
> 🔴 **This is not cosmetic. `CM-0011` was executed *because it said `Draft`* and was read as a to-do list — and it degraded a BMC.** **`CM-0016` now says both things.** **The next reader gets whichever one they land on.**

### 🔴 L1c — `CM-0012` voids its cipher-0 proof, then re-asserts it

**§3, line 59:** 🔴 *"**Cipher 0 — the 'proof' here is VOID.** … this exploit would have failed identically with cipher 0 wide open at ADMIN — the RMCP+ session dies at a **disabled channel**, before any cipher is evaluated."*

**Note, line 146:** 🔴 *"**Cipher 0 was hardened tonight, and it is the right kind of proof — the exploit failing, from a second host.**"*

**`016` lesson 4 — *a test that cannot fail proves nothing* — was DERIVED from this record.** **And the sentence it was derived from is still in it, unamended.**

---

## 🔴🔴 L2 — The Change-Management README index is stale again. It documents its own failure to update, in a red banner, at the top.

```
README says:    "Next available number: CM-0016"
Records on disk: CM-0016, CM-0017, CM-0018, CM-0019, CM-0020  (+ CM-0021, 0022, 0025, 0026, 0027)
```

**The README's own banner, lines 11–17:**

> 🔴 *"**This index was rebuilt from the records on disk on 2026-07-13, after it was found to be six records out of date.** It listed **CM-0001 through CM-0008** and said *'Next available number: CM-0009.'* **CM-0015 existed.** … **Rule 5 below says: 'Update the index table whenever a record is created or its status changes.'** **The rule was written on this page, published, and then ignored by this page.**"*

> 🔴 **It was rebuilt on 2026-07-13. Five more records were created on 2026-07-14. The index was not touched.**
>
> **The page that warns you it went six records stale, and explains exactly why, went five records stale the following day — by the identical mechanism.**

**It is also wrong about the freeze:**

| README says | Reality |
|---|---|
| `CM-0010` — 🟡 *"Implemented — reconciliation OPEN"* | ✅ **Closed** |
| `CM-0014` — 🔴 *"**OPEN — remediation not started**"* | ✅ **Closed 2026-07-14.** Rotation proven, history purged, verified from a fresh clone. |
| *"🔴 **Open records — these block the Book 1 freeze**"* | 🔴 **Book 1 IS FROZEN.** |

🟢 **The README does state the right tiebreaker:** *"`NETWORK-PACK-MANIFEST.md` is authoritative. **If it disagrees with this page, it wins.**"* **It does disagree. It wins. The README is stale.**

---

## 🟢 L3 — `CM-0011`, `CM-0013`, `CM-0019` and `CM-0020` are the best change records in Atlas

| Record | Why |
|---|---|
| 🟢 **`CM-0011`** | **Closed as *substantially FALSE*, and records the execution error that degraded the BMC — including the one accidental improvement (MD2 removal) that it kept.** *"A change record is a hypothesis about the device. This one was falsified on every count — and the correct response is to record the falsification, not to delete the record."* |
| 🟢 **`CM-0013`** | *"**A security fix created a blind spot.** Deleting `testing`/`password` was unambiguously correct. **But the deletion had no closeout** — nothing asked *'and how do we test RADIUS now?'*"* |
| 🟢 **`CM-0019`** | **Verified the severity DOWN rather than inflating it** — the token is Argon2-hashed, and the record says so. Correctly uses `Implemented — reconciliation open`. |
| 🟢 **`CM-0020`** | *"**`CM-0014` spent a night establishing that a control must be tested, not assumed. Then it closed on a control installed in one directory on one laptop.** **The lesson does not stop applying just because you have learned it.**"* |

🔴 **But `CM-0013` is `[x] Closed` with `[ ] 033 and 015 reconciled — open` on its own checklist** — and I confirmed `015` still has no `radtest`. **The seventh occurrence.**

## 🔴 L4 — `CM-0012` and `CM-0011` both owe Book 2 a document nobody has written

**Both name `201-Dell-PowerEdge-R410-Preparation.md` as 🔴 *Must update*** — *"prepares the R410 with **no CMOS check, no iDRAC password, no BMC hardening.** A rebuild from it produces this exact exposed, non-durable state."* **`050`'s completion list names it too.**

**`CM-0011` is `Closed`. `201` was never touched.** *(Book 2 — out of Book 1's audit scope, but it is a Book 1 record's unfulfilled row.)*

✅ **`CM-0012`'s `048` row is now SATISFIED** — `048` Phase 1 correctly says the iDRAC is not out-of-band and not a bootstrap path.

# Chunk 5 (complete) — `CM-0010`, `CM-0014`, `CM-0015`, `CM-0017`, `CM-0018`, `MC-0001`, `MC-0002`

## 🔴🔴 M1 — `CM-0014` has NO CLOSEOUT SECTION. It is the highest-severity record in Book 1.

```
grep -c "^## Closeout"  CM-0014-Archive-Passphrase-Committed-to-Repository.md   →   0
```

**Its section headings, in full:** *What the value is · Reason · The compounding failure · Blast radius · Why `.gitignore` did not catch it · The rule already existed · Remediation · Guide Reconciliation · The pattern · ROTATION — COMPLETED · HISTORY PURGE — COMPLETED · THE FINDING · **`## Original Closeout`** · Change Log*

🔴 **`Original Closeout` is the pre-execution PLAN. There is no post-execution closeout.** **15 unticked boxes. 11 ticked.**

**And its own Risk row says:**

> 🔴 *"**High** — v2.0 raised it to Critical on the assumption of a public repo; v3.0 confirms private and returns it to High. 🔴 **It does not return it to Closed.**"*

**While the Status row, four lines above, says:** ✅ **`CLOSED 2026-07-14`**

> 🔴 **The record that established *"a checklist nobody verifies reports success by default"* was closed without a checklist.**

## 🔴🔴 M2 — `CM-0010` is `Closed`, and its last closeout box is `[ ] Mark this record Closed`

**`CM-0010` — Risk: HIGH, Root CA key material — Status: ✅ *"Closed — implemented, verified, and reconciled."***

**Its Closeout, verbatim, as committed:**

```
- [x] Both passphrases verified against live keys before any change
- [x] Root key re-encrypted, ASCII-only passphrase, verified
- [x] Intermediate key re-encrypted, separate passphrase, verified
- [x] Both .bak-2026-07-12 files destroyed with shred -u
- [x] Round-trip test — both passphrases read back out of Vaultwarden. RSA key ok ×2.
- [x] E:\ tarball tested — CONFIRMED it contains all four key files
- [x] Destroy pi01-full-backup-2026-07-12.tar.gz — CONFIRMED DESTROYED
- [x] Guide reconciliation executed — 031, 029, 049, 07-Backup, 043
- [ ] Passphrases written to PAPER, two copies, ONE OFF-SITE (049 Phase 1)   ← UNTICKED
- [ ] Backup taken and RESTORE-TESTED (049 Phases 3–4)                       ← UNTICKED
- [ ] Mark this record Closed                                                ← 🔴 UNTICKED
```

> 🔴 **The box that says *"Mark this record Closed"* is unticked. The Status row says Closed.**
>
> 🔴 **And the unticked *"one off-site"* box is unticked because it is TRUE.** `049`: *"Off-site: ❌ **DOES NOT EXIST**."* **Third independent confirmation of B12/K1.**

## 🔴🔴 M3 — `MC-0001` ticked a box saying `035` captures the bundle requirement. `035` has no bundle.

**`MC-0001` Phase 5, as committed:**

- `[x]` *"New Operations Guide written: **`035`** — **captures the correct process end-to-end so this sequence doesn't need re-discovering** for MikroTik (`CM-0007`) or any future device"*
- `[x]` *"Runbook's Common Mistakes section updated with **the binding-verification lesson and the bundle requirement**"*

**`MC-0001` Phase 6:** *"The new Runbook (`035`) exists **specifically so `CM-0007` and any future device don't have to rediscover any of these four issues.**"*

```
grep -ci "bundle"            035   →   0
grep -ci "get system global" 035   →   0
grep -c  "subjectAltName"    035   →   0
```

> 🔴 **`035` has none of them. Both boxes were ticked against a document that does not contain what they claim.**
>
> 🔴 **And `CM-0007` DID rediscover them. And `MC-0002` rediscovered them again. And `050` still points at `035` today.**

**This is the smoking gun for `CM-0027`.** **`MC-0001` believed it had written the lessons into the runbook. It had not — and it never looked.**

## 🔴 M4 — `MC-0002` says its follow-up is closed in the header and open in the body

| Location | Says |
|---|---|
| **Status row** | ✅ *"**Follow-up closed 2026-07-13:** FGT01 and Pi-hole certificates independently re-verified on the wire — both correct."* |
| **Phase 5** | 🔴 `[ ]` *"**Open action, not yet done:** verify whether Pi-hole's and FortiGate's existing certificates have the same defect"* |
| **Phase 6** | 🔴 *"Final Status — Production Accepted, **with one open follow-up action… not yet scheduled.**"* |

**Also:** `MC-0002` Phase 2 ticks *"`035` reviewed."* **It reviewed `035` and did not notice it has no SAN step.**

## 🔴 M5 — `CM-0018` ticked "Guide reconciliation complete." That is how `026` §12 survived.

🟢 **`CM-0018` is exemplary in one specific way, and it says so:** four boxes unticked, `Closed` anyway, **because every one is explicitly deferred by an accepted ADR.** *"A deferral you wrote down is engineering. A tick you did not earn is a lie."* **That is correct, honest, and it is what let Book 1 freeze without pretending.**

🔴 **And then it ticked two it had not earned:**

| Box | Reality |
|---|---|
| `[x]` *"Guide reconciliation complete — **`026` §12 REWRITTEN with rationale**"* | 🔴 **The rewrite was performed and it left `mac-winbox=none` in place.** `CM-0021`. |
| `[x]` *"…`003`, `048`, **`016`** corrected"* | 🔴 **`016` has NO MAC-WinBox lesson.** Its own reconciliation table demanded one. |

> 🔴 **`CM-0018` ticked the box against a rewrite that happened and was wrong.**
>
> **This is the complete causal chain for the audit's worst defect:** *the instruction said **replace**; the edit **appended**; the line count went **up**; the box got **ticked**; nobody opened the diff.*

*(Also: `Blocked by: 🔴 ADR-0014` and `[ ] ADR-0014 Accepted` — **`ADR-0014` v2.1 IS Accepted.** Stale.)*

## 🔴 M6 — the pattern, final count: **TWELVE**

| # | Document | The correction | The error, still standing |
|---|---|---|---|
| 1 | `026` §12 | `mac-winbox = RECOVERY` | `mac-winbox = none`, 6 lines below |
| 2 | `018` v3.0 | *"BOTH SENTENCES ARE FALSE"* | Both sentences, as the recommendation |
| 3 | `021` | *"Interfaces — Disabled"* | *"left at factory defaults rather than disabled"* |
| 4 | `CM-0009` | A section on its own closeout defect | Its closeout — **three** unticked, `[x] Closed` |
| 5 | `CM-0012` | *"the 'proof' here is VOID"* | *"the right kind of proof"* |
| 6 | `CM-0016` | Status: `Closed` | Line 12: *"This is a `Draft`"* |
| 7 | `CM-0013` | `[x] Closed` | `[ ] 033 and 015 reconciled — open` |
| 8 | `CM-0015` | Every closeout box ticked ✅ | Change log v1.1: *"reconciliation **remains open**"* |
| 9 | `CM-0017` | Status: `✅ Closed` | Foot: *"Status: **`Implemented — reconciliation open`**"* |
| 10 | `CM-0018` | Status: `Closed` | Head: *"A **`Draft`** record is a hypothesis"* |
| 11 | 🔴 **`CM-0010`** | Status: `✅ Closed` | 🔴 **`[ ] Mark this record Closed`** |
| 12 | 🔴 **`CM-0014`** | Status: `✅ CLOSED` | 🔴 **`It does not return it to Closed`** — and **no Closeout section exists** |

> 🔴 **Twelve. Six of them in the change records. Two in the two highest-severity records in the book.**
>
> **This is not carelessness and it is not a documentation-quality problem. It is a single, specific, mechanical habit:**
>
> > 🔴 **THE CORRECTION IS APPENDED. THE ERROR IS NOT DELETED.**
>
> **Every rebuild-fatal defect in this audit is a consequence of it.**

## 🟢 M7 — and `CM-0015` is still the best change record in Atlas

**Every closeout box ticked before `Closed`. The device comment set so the router documents itself. The read-back that proves it — *"the flags legend gained `X - DISABLED`; it had none before."*** And the line that should be carved over the door:

> *"Every device in this lab was found compliant with a policy that nobody had ever checked — **except the one that wasn't.**"*

---

## Ranked findings

> 🟢 **The table is finished. All 76 documents were read in full. Nothing was skipped and nothing was read by `grep` alone.**
>
> **`ADR-0019`: *"Do not follow interesting threads. FINISH THE TABLE FIRST, THEN RANK."*** **This is the ranking.**

---

## 🔴 The one-sentence finding

> 🔴 **Book 1 is not wrong because anyone was careless. It is wrong because of TWO mechanical habits, and every rebuild-fatal defect in it is a consequence of one or the other.**
>
> | # | The habit | Occurrences |
> |---|---|---|
> | **P1** | 🔴 **The correction is APPENDED. The error is not DELETED.** | **12** |
> | **P2** | 🔴 **The correction reaches the document that DESCRIBES the work, and misses the one that DOES it.** | **4** |
>
> **Neither is a writing problem. Both are verification problems, and both have a one-line fix** (§ *The two rules that would have prevented all of this*).

---

# TIER 1 — REBUILD-FATAL

> **A clean rebuild from Atlas today, followed exactly, produces a broken and less secure lab.** **`ADR-0011`: *"nobody has ever rebuilt."* That is the only reason these are still here.**

| # | Finding | Consequence of a rebuild | Record |
|---|---|---|---|
| 🔴 **1** | **`026` §12 sets `mac-winbox=RECOVERY` on line 41 and `none` on line 47.** Last write wins. | **The core router comes back with NO recovery path — and MKT01 has NO serial console.** This is the exact state `CM-0017`, `CM-0018`, `ADR-0014` and `ADR-0016` were written to fix. | **`CM-0021`** |
| 🔴 **2** | **`027` builds a four-entry `STATIC-HOSTS` ACL** (Pi01 missing), **shuts down `Gi1/0/7`** (Pi01's port), **puts it in VLAN 999**, and **labels `Gi1/0/2` "Raspberry-Pi."** Its Validation expects *"four entries."* | 🔴 **Pi01 — Root CA, Intermediate CA, Vaultwarden, Pi-hole, FreeRADIUS — is killed FOUR independent ways, silently.** `DHCP Permits: 0`; no error, no warning. **It just appears broken.** | **`CM-0022`** |
| 🔴 **3** | **`035` issues certificates with NO SAN, installs the BARE LEAF, and never verifies the binding.** `grep -c subjectAltName` → **0**. | **Every certificate issued from the repeatable runbook is rejected by browsers.** **`050` (iDRAC onboarding) depends on `035` — it would produce a SAN-less cert on the one interface you reach for when everything is down.** | **`CM-0027`** |
| 🔴 **4** | **`048` Phase 0 rebuilds `pi01-full-backup-2026-07-12.tar.gz`** — an **unencrypted** tar of both CA keys, the whole vault and every RADIUS secret. **No pre-archive `.bak` check. Zero references to `049`.** | **A teardown today recreates the artefact `CM-0010` destroyed as *"it could not save you, and it could hurt you"* — and ships a plaintext vault export off-site.** | **`CM-0025`** |
| 🔴 **5** | **`026` never disables `reverse-proxy`.** `CM-0006` found it **enabled, `address=""`, no certificate.** No Build Guide row (pre-Rule-15). | **An unrestricted, uncertificated reverse proxy on port 443 of the core router.** | **`CM-0021`** |
| 🔴 **6** | **`025` never disables the four factory interfaces** (`CM-0004` had no Build Guide row). **No Lab CA certificate. No DNS-over-TLS.** | **`internal` comes back at `192.168.1.99`, admin-reachable, with `ping https ssh`.** `modem` returns with its encrypted PPPoE credential. Factory self-signed cert. Plain DNS. | *Reconciliation batch* |
| 🔴 **7** | **`030` says the Pi01 guides have *"no interdependency — any order."*** `031` says **build Vaultwarden FIRST**, and `031`↔`034` are **circular**. | 🔴 **A rebuilder builds the CA first, has nowhere to put the passphrase, and writes it to a text file. THAT IS `CM-0014`.** **The root cause of the worst incident in Atlas is a sentence in a Build Guide.** | *Reconciliation batch* |
| 🔴 **8** | **`018` names the WRONG control** — and says so, and recommends it anyway. | **Anyone who builds the control `018` describes builds the content scanner that PROVABLY FAILED.** **`ADR-0010` gates publication of this repository on it.** | **`CM-0026`** |

---

# TIER 2 — LIVE, UNMITIGATED

> **These are true right now, on the running lab.**

| # | Finding | Why it matters | Cost to fix |
|---|---|---|---|
| 🔴 **1** | 🔴 **THERE IS NO OFF-SITE COPY OF THE CA ARCHIVE.** `049`'s own header: *"Off-site: ❌ **DOES NOT EXIST**."* **Both copies are in the same room.** | **A single fire takes the Root CA, the Intermediate CA, every RADIUS secret and the entire vault — in one event.** Roadmap Critical Risk #1. **`029` claims this is already done. It is the only document that does.** | 🟢 **TEN MINUTES.** `049` Phase 5. **The highest-value ten minutes available to you.** |
| 🔴 **2** | **SNMP community `homelab`** — live, **v2c, cleartext on the wire**, recorded in `023` and **typed into `027`**. **The Charter names this exact string and orders it *"redact AND rotate."*** | **`ADR-0010` gates publication on *"no live credential anywhere in the working tree."* This is one.** **`gitleaks` will not catch it — it is a bare word with no shape**, exactly like `CM-0014`. **No change record has ever existed for it.** | **`CM-0023`** — to raise |
| 🔴 **3** | **All SEVEN device admin passwords still hold their original values** (`044`). **The iDRAC's is a FACTORY DEFAULT** (`024`). | *"Rotation was deferred until Vaultwarden was production-ready. **It now is.**"* — **that was 2026-07-13. Nothing has rotated. There is no change record and no gate.** | **`CM-0028`** — to raise |
| 🔴 **4** | **The plaintext CA-passphrase file on the desktop was NEVER validly searched for.** The search ran against `C:\Users\Seth\Desktop`. **The real desktop is `C:\Users\Seth\OneDrive\Desktop`.** | **The clean result proved NOTHING** (`016` lesson 4). **If that file was ever there, it synced to Microsoft** — and a local delete never touched the cloud recycle bin or version history. **`043` presents this as handled.** *(Values are inert post-`CM-0010`. The unknown is not.)* | One `Get-ChildItem` |
| 🔴 **5** | **The pre-commit secret scanner exists on ONE MACHINE.** `.git/hooks/` is not tracked. | **`CM-0014` closed on *"the scanner is installed and proven."* It is proven on one laptop.** **Any clone is unprotected, silently.** | **`CM-0020`** — open |
| 🔴 **6** | 🔴 **`mkt01-pre-CM-0009.rsc` IS NOT IN GIT.** `.gitignore:11` (`*.rsc`) excludes it; `git log --all` returns nothing. | **That export is the ONLY artefact that has ever falsified a NARRATIVE rather than a document.** It disproved an invented security hole, and it is the sole source for MKT01's 64 GB SSD and serial — **cited by `ADR-0014`, `ADR-0015` and `CM-0017`.** **It exists on one machine and `049` does not back it up.** | **`CM-0029`** — to raise |
| 🔴 **7** | **NO DEVICE BACKUP HAS EVER BEEN RESTORE-TESTED.** Not SW01, FGT01, MKT01 or PVE01. | **Gates `ADR-0011` (Game Days), `ADR-0013` (retiring `bridgeLocal`) and Book 11.** **A backup you have not restored is a hope.** | Book 7 |
| 🟡 **8** | **`045` marks the live cleartext SNMP exposure *"Unverified"*** — and ticks *"SNMP configured and verified."* | **A tick on the wrong question.** SNMP **exists**. That says nothing about whether it is **safe**. | Folded into `CM-0023` |

---

# TIER 3 — FALSE `Verified` CLAIMS

> **Charter Rule 14: *"The most dangerous page in Atlas is one marked `Verified` that no longer is."*** **All five below are marked `Verified`.**

| # | Document | The false claim | Contradicted by |
|---|---|---|---|
| 🔴 **1** | **`024`** | **"32 vCPUs. 32 GB RAM."** | 🔴 **The live host is 16 / 62 GiB. FIVE documents say so** — `Atlas-Workflow` (which uses these exact numbers as its **worked example of a false `Verified`**), `VM-and-Services-Inventory`, `Atlas-Service-Architecture`, `036`, and `ADR-0017`. **`024` was rewritten to v2.1 to fix the iDRAC and the numbers were left three tables above the correction.** 🔴 **`ADR-0017`'s CMOS close-test is *"`egrep -c` returns the CPU count"* — against `024` that test passes at 32 and the truth is 16.** |
| 🔴 **2** | **`029`** | **(a)** an off-site backup exists · **(b)** `atlas-pi01-2026-07-13.tar.gz.gpg` is *"the real backup"* · **(c)** Pi01 is not in `STATIC-HOSTS` | **(a)** `049` + four others: **it does not.** · **(b)** That is the archive encrypted with the **leaked, never-rotated** passphrase — **destroyed 2026-07-14.** · **(c)** 🔴 **This is the ORIGIN of the false "Pi01 should be unreachable" mystery that survived three handoffs.** `006`, `012`, `016` and `023` were all corrected. **The document the claim actually lives in was not.** |
| 🔴 **3** | **`021`** | **"Firewall Policies (verified)"** lists a scoped policy. **Address objects `Lab-Network`/`Transit-Link` exist.** | **`ADR-0005`: the device has `srcaddr all` and *"the scoped address objects don't actually exist."*** 🔴 **`021`'s table is IDENTICAL to `025`'s Step 7 — the Build Record was populated from the Build GUIDE, not the device.** **That is the precise inversion `Atlas-Workflow` v2.0 exists to prevent.** *(`021` also contradicts itself on whether the factory interfaces are disabled.)* |
| 🔴 **4** | **`001`** | Marked `Verified`. **Pi-hole is *"optional."*** MKT01 hostname is wrong. iDRAC creds are factory. **Pi01 does not appear in the architecture at all.** | 🔴 ***"Pi-hole is optional"* is the EXACT sentence `013` v2.0 and `017` v2.0 were both rewritten to kill** — *"a reader would have removed a load-bearing service."* **`Build-Order` says it too. THREE documents; corrected in two; never grepped for.** |
| 🔴 **5** | **`023`** | `Gi1/0/1` description is *"Raspberry-Pi (mislabeled)"*, deviation open. | **`CM-0001` ticked `[x] Build Record — confirmed live: `Gi1/0/1` shows `Trunk-to-MKT01`.`** 🔴 **The observation was real. The edit was imaginary.** **This is the FIRST change record ever written in Atlas.** |

---

# TIER 4 — THE MECHANISMS

## 🔴 P1 — The correction is APPENDED. The error is not DELETED. **(12 occurrences)**

**Six are in the change records. Two are in the two highest-severity records in Book 1.**

`026` §12 · `018` v3.0 · `021` · `CM-0009` · `CM-0012` · `CM-0013` · `CM-0015` · `CM-0016` · `CM-0017` · `CM-0018` · **`CM-0010`** · **`CM-0014`**

> **Why it keeps happening:** appending feels safe; **deleting requires certainty.** And the `[chg ]` line-count delta goes **UP**, which reads as a plausible edit — **the opposite of the `496 → 12` shape `tools/README.md` teaches you to catch.**

## 🔴 P2 — The correction reaches the document that DESCRIBES the work and misses the one that DOES it. **(4 occurrences)**

| Corrected | 🔴 Missed | The missed one… |
|---|---|---|
| `006`, `012`, `023`, `016` — *the ACL* | **`027`** | …**BUILDS** the ACL |
| `031`, `029`, `049`, `043` — *the CA backup* | **`048`** | …**TAKES** the backup |
| `031` — *SAN, bundle, revocation* | **`035`, `042`** | …**ISSUE** and **REISSUE** |
| `013`, `017` — *"Pi-hole is optional"* | **`001`, `Build-Order`** | …are the **landing pages** |

> **`031` is read ONCE. `035` is read EVERY TIME. `031` was corrected five times. `035` was never opened.**

## 🔴 P3 — Ten records predate Charter Rule 15 and were never reconciled retroactively

**`CM-0001`–`0008`, `MC-0001`, `MC-0002`.** 🔴 **FOUR have no Build Guide row at all** (`CM-0003`, `CM-0004`, `CM-0006`, `CM-0008`). **Every Tier-1 guide defect traces to one of them.** **Rule 15 was written on 2026-07-13 and never applied backwards.**

## 🔴 P4 — Records closed with their own rows marked 🔴 **Must update**

| Record | The row it closed over | Verified today |
|---|---|---|
| `MC-0001` | `[x]` *"`035` captures the bundle requirement"* | 🔴 **`grep -ci bundle` on `035` → 0** |
| `CM-0018` | `[x]` *"`026` §12 REWRITTEN"* · `[x]` *"`016` corrected"* | 🔴 **The rewrite left the bug. `016` has no MAC-WinBox lesson.** |
| `CM-0013` | `[ ] 033 and 015 reconciled — open` + `[x] Closed` | 🔴 **`015` still has no `radtest`.** |
| `CM-0004` | *"`037` should carry a FortiOS-grep note"* | 🔴 **Not there.** |
| `CM-0014` | `048` — *"Not yet reviewed"* | 🔴 **Reviewed now. The answer is worse than the question.** |
| `CM-0009` | Three unticked boxes, `[x] Closed` | 🔴 **Still three unticked.** |

## 🔴 P5 — Orphans: real items that no record owns

- 🔴 **`020-Network-Revision-History.md` contains NO revision history.** Zero entries, ever. **This is why `CM-0001`, `0002`, `0003` and `0008` all carry an unticked `[ ] Revision History` box.** **Four records cannot close cleanly and nobody asked why.**
- 🔴 **The Change-Management README says *"Next available number: CM-0016."*** `CM-0016`–`CM-0020` all exist. **Its own red banner explains that it went six records stale on 2026-07-13 by this exact mechanism.** **It went five stale the next day.**
- **SW01 rename** (`CoreSwitch` → `SW01`) — open in four documents, **no record.** *(Because `027` builds `CoreSwitch` as the target.)* → **`CM-0024`**
- **Pi01's `docker0` + `veth`** (the vault's namespace) — `010`: *"tracked for a future pass."* **Nothing tracks it.**
- **Pi01's `wlan0`** — `010`: *"a reflash brings it back up and **no document says to disable it**."* **`046` is that document. It doesn't.**
- **Vaultwarden master password exists only in your head** — `049`: *"**worth an ADR either way.**"* **No ADR.**
- **`lab.local`** is a **third** domain name, after `.lab` and `ADR-0007`'s `atlas.lab`.

---

# 🔴 The two rules that would have prevented ALL of this

> ### R1 — Verify a correction by COUNTING the OLD text. Not by confirming the NEW text is present.
>
> ```powershell
> # WRONG - this is what was done, twelve times:
> Select-String -Path .\026...md -Pattern "mac-winbox.*RECOVERY"      # hits. Looks fine.
>
> # RIGHT - the old string must be GONE:
> (Select-String -Path .\026...md -Pattern "mac-winbox.*=none").Count  # MUST be 0
> ```
>
> **A hit on the fix proves the fix landed. It proves NOTHING about whether the thing it replaced is sitting six lines below it.**

> ### R2 — At every closeout, ask: **WHICH DOCUMENT DOES THE WORK?** Fix that one first.
>
> **Not the one that describes it. Not the one that records it. The one someone will EXECUTE.**
>
> **A Build Guide is read once, in the worst hour of the project, when the device is gone. It is the last document to get fixed and the first one that matters.**

---

# The fix list, in order

| # | Do this | Why first |
|---|---|---|
| 🟢 **1** | 🔴 **`049` Phase 5. Take the archive off-site.** | **Ten minutes. It is the difference between a lab and a fire.** |
| **2** | **Apply `CM-0021`, `CM-0022`, `CM-0025`, `CM-0026`, `CM-0027`.** | **The five rebuild-fatal guides. Nothing else in Book 1 can be trusted until a rebuild works.** |
| **3** | **Raise `CM-0023`** (rotate SNMP) — **it gates publication** (`ADR-0010`). | A live cleartext credential in the tree. |
| **4** | **Raise `CM-0028`** (rotate all seven device passwords + the factory iDRAC). | Vaultwarden has been ready since 2026-07-13. |
| **5** | **Raise `CM-0029`** — **`git add -f` the Evidence directory.** | The one file that has ever falsified a narrative is on one machine. |
| **6** | **The reconciliation batch** — `001`, `021`, `023`, `024`, `025`, `029`, `030`, `Build-Order`, Book 1 `README`, the CM README, `020`, `016`. | Fixes Tier 3 and the orphans. |
| **7** | **Charter Rule 13 amendment** — the precedence table has **no row for Change Records.** *(A Change Record's OBSERVATION is Rank 3. Its `Status` field is Rank 6 — it has been wrong twelve times.)* | The rule that resolves every doc-vs-doc conflict this audit found. |
| **8** | **`016` gains R1 and R2.** | **The two habits. Everything else is a symptom.** |
| **9** | **The status-hygiene pass** — `CM-0009`, `0010`, `0011`, `0013`, `0014`, `0015`, `0016`, `0017`, `0018`. | **Deferred by the operator. `CM-0011` genuinely gates on the CR2032.** |
| **10** | 🔴 **Then run `ADR-0011`. Game Day. Rebuild SW01 from the documentation alone.** | **This audit read the documents. It cannot tell you whether they WORK.** **Only a rebuild can, and nobody has ever done one.** |

---

# What this audit could not do

> 🔴 **`ADR-0019` asked three questions per document. This audit answered two.**
>
> **"Does it contradict a DEVICE?" was never answered — the auditor has no device access.** **19 `DEVICE CHECK` items (D1–D19) are raised and unanswered.** **Per Charter Rule 13, the device outranks every single row above.**
>
> **And a deeper limit:** **reading 76 documents tells you they disagree with each other. It cannot tell you whether ANY of them works.**
>
> **`ADR-0011` is the only thing that can. It is gated on Book 1 being frozen — which it is — and on `CM-0014` being closed — which it is.**
>
> 🔴 **The gates are open. The drill has never been run. That is now the single most valuable unperformed action in this project.**


---

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-07-14. Chunk 1 (Architecture + Standards, 14 documents) complete. **Corrects `ADR-0019`'s own count: 76 documents, not 72.** Records the auditor's device-access limitation explicitly. 15 document-vs-document findings, 7 device checks raised. **No ranking — the table is not finished.** |
| **2.0** | 2026-07-14. 🟢 **RANKED. The audit is complete.** **Tier 1 — 8 REBUILD-FATAL defects.** **Tier 2 — 8 live unmitigated exposures, the first of which is TEN MINUTES of work.** **Tier 3 — 5 documents marked `Verified` that are false.** **Tier 4 — the mechanisms.** 🔴 **THE FINDING: Book 1 is not wrong because anyone was careless. It is wrong because of TWO mechanical habits — P1 (the correction is appended, the error is not deleted — 12 occurrences) and P2 (the correction reaches the document that DESCRIBES the work and misses the one that DOES it — 4 occurrences). Every rebuild-fatal defect is a consequence of one or the other. Both have a one-line fix: R1 — verify a correction by COUNTING the OLD text, not by confirming the NEW text is present. R2 — at every closeout, ask WHICH DOCUMENT DOES THE WORK.** 🔴 **And the honest limit: this audit read the documents. It cannot tell you whether any of them WORK. Only `ADR-0011` can, and its gates are now open.** |
| **1.0** | 2026-07-14. 🟢 **COVERAGE COMPLETE — ALL 76 DOCUMENTS READ IN FULL.** 🔴🔴 **M1: `CM-0014` — the highest-severity record in Book 1 — has NO `## Closeout` section at all (only an `## Original Closeout` plan, with 15 unticked boxes), and its own Risk row says *"It does not return it to Closed"* four lines below a Status row saying `CLOSED`. The record that established *"a checklist nobody verifies reports success by default"* was closed without a checklist.** 🔴🔴 **M2: `CM-0010` (HIGH, Root CA key material) is `Closed` — and its last closeout box is `[ ] Mark this record Closed`, unticked. So is `[ ] one off-site` — because it is TRUE.** 🔴🔴 **M3: `MC-0001` ticked *"`035` captures the bundle requirement and the binding-verification lesson."* `grep -ci bundle` on `035` returns 0. It ticked the box against a document that does not contain what it claims — and `CM-0007` and `MC-0002` both rediscovered the lessons.** 🔴 **M5: `CM-0018` ticked *"`026` §12 REWRITTEN"* against a rewrite that happened and was wrong. That is the complete causal chain for the audit's worst defect.** 🔴🔴 **M6: THE PATTERN, FINAL COUNT — TWELVE. Six in the change records. Two in the two highest-severity records in the book. Every rebuild-fatal defect in this audit is a consequence of one mechanical habit: THE CORRECTION IS APPENDED; THE ERROR IS NOT DELETED.** **Ranking follows in v2.0.** |
| **0.10** | 2026-07-14. **Chunk 5 partial — 9 of 15 Change Records (71 of 76 overall).** 🔴🔴 **L1 — THE PATTERN IS AT SIX OCCURRENCES, and three are in the change records themselves. `CM-0009` writes a section titled *"Closeout defect — this record was marked Closed with two boxes unticked"* and leaves THREE boxes unticked, twenty lines above it. `CM-0012` declares its cipher-0 proof VOID in §3 and calls it *"the right kind of proof"* in its Note. `CM-0016` says `Closed` on line 5 and *"This is a Draft — a Draft record is a hypothesis, not a work order"* on line 12 — and a Draft record read as a work order is what degraded the BMC.** 🔴🔴 **L2 — the Change-Management README index went stale AGAIN. It says "Next available number: CM-0016" while CM-0016 through CM-0020 all exist — and its own red banner at the top explains that it went six records stale on 2026-07-13 by exactly this mechanism. It also still lists CM-0014 as OPEN and says three records "block the Book 1 freeze." Book 1 is frozen.** 🟢 **L3 — `CM-0011`, `CM-0013`, `CM-0019` and `CM-0020` are the best change records in Atlas.** **Still no ranking — 5 records to go.** |
| **0.9** | 2026-07-14. 🟢 **CHUNKS 1–4 COMPLETE (62 of 76). Only the Change Records remain.** ✅ **K1 — B12 IS SETTLED: `049`'s own header says *"Off-site: ❌ DOES NOT EXIST."* Five documents against one. `029` — the Build Record — asserts the lab's biggest unmitigated risk is already mitigated. It is not. `049` Phase 5 takes ten minutes.** 🔴🔴 **K3: `043` says the plaintext passphrase file was *"flagged for permanent deletion"* — but the search ran against `C:\Users\Seth\Desktop` when the real desktop is `C:\Users\Seth\OneDrive\Desktop`. The clean result proved nothing, and if the file was there it synced to Microsoft. `043` makes an OPEN exposure look closed.** 🔴 **K4: `035` was WRITTEN during the session that discovered all four PKI defects it omits. The narrative captured them; the runbook did not.** 🔴 **K2: `049` says the Vaultwarden master password decision is *"worth an ADR either way."* No ADR exists.** 🟢 **`049` is the best security document in Book 1 — nothing in this audit improves on it.** **Still no ranking. 14 Change Records to go.** |
| **0.8** | 2026-07-14. **Chunk 4 cont. — `038`, `046`, `047`, `050`, `Build-Order` (60 of 76).** 🔴 **J5: `Build-Order` is the THIRD document to call Pi-hole an "optional upstream forwarder" — the exact sentence `013` v2.0 and `017` v2.0 were both rewritten to kill because *"a reader would have removed a load-bearing service."* `001` is the second. Corrected where noticed; never grepped for elsewhere.** 🔴 **J4: `050` — the best-reasoned document in Book 1 — depends on `035`, which issues certificates with no SAN. `CM-0027` is a prerequisite for `050`.** 🔴 **`046` omits Pi01's three biggest risks (`wlan0`, `docker0`, the Root CA on a networked multi-service host). `047` omits `CM-0004`'s entire finding.** 🟡 **`038`'s FreeRADIUS Resolution block recreates the deleted `testing`/`password` account — the Charter carves out Troubleshooting Guides, but `038` presents it as a FIX, not a lesson. Operator's call.** 🔴 **`Build-Order` has no Document Control block at all, and `lab.local` is now the third domain name in play.** **Still no ranking.** |
| **0.7** | 2026-07-14. **Chunk 4 cont. — `035`, `036`, `040`, `042` (55 of 76).** 🔴🔴 **H1/`CM-0027`: `035` — the runbook used EVERY time a device needs a certificate — sets NO SAN (`grep -c subjectAltName` → 0), never verifies one, and installs the BARE LEAF instead of a bundle. All three are documented incidents (`MC-0001`, `MC-0002`, `CM-0008`) and all three fixes went to `031` and never to `035`.** 🔴 **H2: `042` still teaches `openssl ca -revoke` as the remedy for an exposed key — while `031` v0.7 and `ADR-0009` establish this CA has no CRL Distribution Point and that `MC-0002`'s revocation reached nobody.** 🔴🔴 **H3 — THE SECOND PATTERN: the correction reaches the GUIDE and misses the RUNBOOK (`027`, `048`, `035`/`042`). Together with G2 (the correction is appended, the error is not deleted), these two patterns account for every rebuild-fatal defect in this audit.** 🟢 **`036` and `040` are clean — and `036` independently confirms PVE01 has 16 CPUs, making it the fifth document to contradict `024`'s 32.** **Still no ranking.** |
| **0.6** | 2026-07-14. **Chunk 4 cont. — `018`, `037`, `041`, `044`, Book 1 `README` (51 of 76).** 🔴🔴 **G1/`CM-0026`: `018` v3.0 declares two sentences "BOTH SENTENCES ARE FALSE" at line 49 — and reprints both, verbatim, as its own recommendation at lines 69–70. `ADR-0010` gates publication on the control `018` names, and `018` names the one that provably FAILED.** 🔴🔴 **G2 — THE PATTERN, NAMED: the correction is APPENDED and the error is not DELETED. Three occurrences (`026` §12, `018` v3.0, `021`). In every case the author knew the truth, wrote the truth, and did not delete the lie. Remedy: verify a correction by COUNTING the OLD text, not by confirming the NEW text is present.** 🔴 **`CM-0004` required a FortiOS-grep note in `037` and closed without it.** 🔴 **`041` omits `hw=no` and MAC-WinBox — MKT01's two worst failure modes.** 🔴 **`044`: all seven device admin passwords still hold their original values; the iDRAC's is a factory default. No change record exists.** 🔴 **Book 1's `README` still says "28-page draft" and "before Network is frozen." It is frozen, with 76 documents.** **Still no ranking.** |
| **0.5** | 2026-07-14. **Chunk 4 partial — 10 of 23 Operations documents.** 🔴 **F1 / `CM-0025`: `048` Phase 0 rebuilds `pi01-full-backup-2026-07-12.tar.gz` — the UNENCRYPTED archive holding both CA keys, the whole vault and every RADIUS secret, which `CM-0010` destroyed as *"it could not save you, and it could hurt you."* `048` references `049` ZERO times and has no pre-archive `.bak` check. `CM-0014` marked `048` "Not yet reviewed" and closed.** 🟢 **But `048`'s bootstrap table, five-entry `STATIC-HOSTS` and iDRAC warning are all CORRECT — `CM-0021`'s and `CM-0022`'s `048` blockers are CLEARED.** 🔴 **`020-Network-Revision-History.md` contains NO revision history — which is why four change records carry an unticked "Revision History" box.** 🔴 **`045` says MKT01 has 23 firewall rules; the device has 22 — `CM-0009` never reconciled it.** 🔴 **`045` marks the live cleartext SNMP community "Unverified" when two documents state it plainly.** 🔴 **`039` omits SW01's most expensive incident (DAI silent-drop).** 🔴 **`015` has no `radtest` — `CM-0013` demanded it and closed without it; `016` has no MAC-WinBox lesson — `CM-0018` demanded it and closed without it.** **Still no ranking.** |
| **0.4** | 2026-07-14. **Chunk 5 partial — `CM-0001`–`CM-0008` read in full. THE MECHANISM IS CONFIRMED.** 🔴 **Ten records (`CM-0001`–`0008`, `MC-0001`, `MC-0002`) predate Charter Rule 15 and were never reconciled — four have NO Build Guide row at all.** Every unreconciled guide defect in Chunks 1–3 traces to one of them. 🔴 **`CM-0018` said *replace*; the edit *appended* — that is `026` §12's proximate cause, in writing.** 🔴 **NEW (E1): `026` never disables `reverse-proxy` — `CM-0006` had no guide row.** Establishes the two-part authority rule: **a Change Record's OBSERVATION is Rank 3; its `Status` field is Rank 6** — the latter has been wrong five times. **Proposes a Charter Rule 13 amendment: the precedence table has no row for Change Records.** Raised **`CM-0021`** (`026` recovery-path regression) and **`CM-0022`** (`027` rebuilds a switch that drops Pi01). **Still no ranking.** |
| **0.3** | 2026-07-14. **Chunk 3 (Build Guides, 9 documents) complete.** 🔴🔴 **`026` §12 — the section REWRITTEN on 2026-07-14 to fix the missing recovery path — sets `mac-winbox=RECOVERY` on line 41 and back to `none` on line 47. Last write wins. A router rebuilt from the current guide has NO recovery path, which is the exact defect `CM-0017`/`CM-0018`/`ADR-0014`/`ADR-0016` were written to fix.** 🔴🔴 **`027` builds a four-entry `STATIC-HOSTS` ACL (Pi01 missing), shuts down `Gi1/0/7` (Pi01's port), puts it in VLAN 999, and labels `Gi1/0/2` "Raspberry-Pi" — a clean rebuild kills Pi01 four separate ways, and the Validation section expects "four entries."** 🔴 `027` also re-enables `Gi1/0/3`, reversing `ADR-0002`/`CM-0003`, and types the live SNMP community the Charter forbids in guides. 🔴 `025` never disables the four factory interfaces (`CM-0004` never reconciled it), builds no Lab CA cert and no DoT. 🔴 `021`'s "verified" firewall table was copied from `025`, not read from the device. 🔴 `030` says the Pi01 guides have "no interdependency" — `031` and `034` are circular, and getting that order wrong is the root cause of `CM-0014`. 🟢 `031`, `032`, `033` are excellent. **Still no ranking.** |
| **0.2** | 2026-07-14. **Chunk 2 (Build Records, 5 documents) complete — the `ADR-0019` priority target.** `021`, `023`, `024`, `029` had never been opened; **all four are marked `Verified` and all four are wrong.** 🔴 **`024` still asserts 32 GB / 32 vCPU — the exact figures `Atlas-Workflow.md` uses as its worked example of a false `Verified` claim.** 🔴 **`029` claims an off-site backup copy that four documents say does not exist, and names the passphrase-leaked archive as "the real backup."** 🔴 **`029` still contains the false "Pi01 not in STATIC-HOSTS" claim — the origin of the three-handoff mystery that was corrected in four other documents and never in this one.** 🔴 **`023` carries the live cleartext SNMP community the Charter names by string and orders rotated.** 6 further device checks raised (D8–D13). **Still no ranking.** |
