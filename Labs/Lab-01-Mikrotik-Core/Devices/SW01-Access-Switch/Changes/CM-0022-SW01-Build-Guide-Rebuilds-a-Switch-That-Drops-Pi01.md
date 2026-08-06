# CM-0022 — `027` Rebuilds a Switch That Silently Drops Pi01, and Reverses `ADR-0002`

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

| Item | Value |
|---|---|
| Status | ✅ **Implemented 2026-07-14 — `027` edited and verified by count-check. Reconciliation open (`023`, `016`).** |
| Risk | 🔴 **HIGH — rebuild-fatal.** *(No live device change. See below.)* |
| Affected systems | **Documentation.** `027-SW01-Build-Guide.md`, `023-SW01-Build-Record.md`. **SW01 itself is CORRECT and is not touched by this record.** |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — `027`/`023` read as committed, **AND every claim re-tested against the live SW01 on 2026-07-14 before a single line was edited** |
| Related | `CM-0001`, `CM-0003`, `ADR-0002`, `ADR-0019`, `006`, `012`, `016` lesson 6, `048`, `051-Book-1-Audit-Report.md` (findings C2–C5, B6, B7) |

> 🔴 **The switch is fine. The guide is not.**
>
> `023` records the live `STATIC-HOSTS` ACL as **five** entries, confirmed by `show arp access-list STATIC-HOSTS`. **That is correct.**
>
> **`027` — the document you rebuild from — builds four.**

---

## 🔴 Finding 1 — `027` builds a four-entry `STATIC-HOSTS` ACL. Pi01 is missing.

**`027` Step 16, as committed:**

```
arp access-list STATIC-HOSTS
 permit ip host 10.10.0.10  mac host 0000.5e00.5313    PVE01
 permit ip host 10.10.0.100 mac host 0000.5e00.5314    iDRAC
 permit ip host 10.10.0.254 mac host 0000.5e00.5315    FGT01
 permit ip host 10.10.0.50  mac host 0000.5e00.5316    workstation
```

🔴 **Pi01 (`10.10.0.5` / `0000.5e00.5300`) is absent.**

**And `027`'s own Validation section states the wrong expected result:**

> *"Expected: … **STATIC-HOSTS has four entries**; filter applied to VLAN 10"*

**Against — every other document in Book 1:**

| Document | Says |
|---|---|
| `006` | *"**All five are required.** `DHCP Permits: 0` — **there is no snooping fallback.** A host missing from this ACL is **dropped, full stop.**"* |
| `023` | *"The live ACL lists **five** hosts."* |
| `012` | *"**All five `STATIC-HOSTS` entries**: `10.10.0.5` Pi01 · …"* |
| `016` lesson 6 | *"four entries where **five** are required. **Pi01 was missing.**"* |
| `048` | *"**Build the ACL from this list, not from a stale record.**"* |

> 🔴 **`048` says build it from `006`, not from a stale record. `027` IS the stale record — and `027` is the Build Guide.**
>
> **`006`, `012`, `023` and `016` were all corrected on 2026-07-13. `027` was not.** The pass fixed every document that *describes* the ACL and missed the one that *builds* it.

**Consequence:** SW01 comes up enforcing a four-entry ACL with `DHCP Permits: 0`. **Pi01 — Root CA, Intermediate CA, Vaultwarden, Pi-hole, FreeRADIUS — is silently dropped.** No error. It simply appears broken. **And the false "Pi01 should be unreachable" mystery is re-imported.**

## 🔴 Finding 2 — `027` Step 15 shuts down `Gi1/0/7`. That is Pi01's port.

```
interface range GigabitEthernet1/0/7-48
 description Unused
 switchport access vlan 999
 shutdown
```

**`003`, `006`, `023`, `029` and `030` all record `Gi1/0/7` = **Pi01**, Access VLAN 10.**

## 🔴 Finding 3 — `027`'s port table is the pre-2026-07-13 layout

| `027` says | Reality |
|---|---|
| `Gi1/0/2` — **Raspberry-Pi**, VLAN 10 | **LabComputer.** `003` v2.0: *"the Pi was moved."* |
| `Gi1/0/3` — **Windows-Laptop**, VLAN **50**, Step 13 issues **`no shutdown`** | 🔴 **`ADR-0002` DISABLED this port. `CM-0003` executed it.** |
| `Gi1/0/7-48` — Unused, VLAN 999, shutdown | 🔴 `Gi1/0/7` is **Pi01** |
| *(no row)* | 🔴 **Pi01 appears nowhere in `027`** |

> 🔴 **A rebuild from `027` re-enables `Gi1/0/3` on VLAN 50 — silently reversing an accepted ADR and its executed change record.**
>
> **`ADR-0002`'s entire point:** *"committing to one VLAN without knowing why the other was configured would be a guess dressed up as a decision."* **`027` makes that guess.**
>
> **`CM-0003` has no Build Guide row.** It predates Charter Rule 15. **Nobody ever asked `027` the question.**

**Together, a clean rebuild from `027` kills Pi01 four separate ways:**

| # | What `027` does | Result |
|---|---|---|
| 1 | Omits Pi01 from `STATIC-HOSTS` | ARP inspection drops it |
| 2 | Shuts down `Gi1/0/7` | Its port is administratively down |
| 3 | Puts `Gi1/0/7` in VLAN 999 | Even if enabled, it lands in the black hole |
| 4 | Labels `Gi1/0/2` *"Raspberry-Pi"* | You cable the Pi into the wrong port chasing the description |

## 🔴 Finding 4 — `027` Step 17 types the live SNMP community. The Charter forbids it.

```
snmp-server community homelab ro
snmp-server location Home-Lab-California
snmp-server host 10.40.0.52 traps version 2c homelab
ntp server 10.10.0.5
```

**`Atlas-Charter.md`, "Evidence and secrets":**
> 🔴 *"**A Build Guide never contains a value you would actually type.**"*
> 🔴 *"**`snmp-server community homelab`** — **live, and SNMP v2c sends it in cleartext. Redact and rotate.**"*

**Four defects in five lines:**
1. 🔴 **Live cleartext credential, in a Build Guide, named by the Charter.**
2. 🔴 **SNMP trap host `10.40.0.52` does not exist.** VLAN 40 is live and empty. `006` plans LibreNMS at `10.40.0.20`.
3. 🔴 **NTP points at Pi01 — which appears to run no NTP server.** `029` lists none; `Atlas-Service-Architecture.md` proposes *adding* chrony.
4. 🟡 **`location Home-Lab-California`** — a real-world location disclosure on a repo `ADR-0010` intends to publish.

**Rotation is a device change and is OUT OF SCOPE for this record.** It gets its own change record — see below. **This record redacts the guide.**

## 🟡 Finding 5 — `027` builds `CoreSwitch` as the target hostname

Step 2 sets `hostname CoreSwitch`; the Completion Checklist ticks *"Hostname CoreSwitch."* **The target is `SW01`.**

🔴 **This is why the rename never happens.** Four documents call it an open deviation. **No change record exists for it — because the guide says `CoreSwitch` is correct.**

## 🔴 Finding 6 — `023`'s `Gi1/0/1` description is stale. `CM-0001` already fixed the device.

**`CM-0001`, Documentation updates:** `[x]` *"Build Record (`023`) — **confirmed live: `Gi1/0/1` shows `Trunk-to-MKT01`**"*

**That is a Rank-3 device observation. It wins.**

**`023` still says:** *"`Gi1/0/1` | Raspberry-Pi *(mislabeled — see Known Deviations)*"* — with an open deviation row: *"`CM-0001` — reconfigure description."*

> 🔴 **`CM-0001` ticked the box for updating `023`, and `023` was never touched.** **The observation was real. The edit was imaginary.** **This is the first change record ever written in Atlas.**

---

## Implementation — documentation only

### Edit 1 — `027` Port Assignments table: replace entirely

| Port | Description | Mode | VLAN(s) |
|---|---|---|---|
| Gi1/0/1 | Trunk-to-MKT01 | Trunk | All tagged, native **999** |
| Gi1/0/2 | LabComputer | Access | 10 |
| Gi1/0/3 | **Disabled — pending device assignment, see `ADR-0002` / `CM-0003`** | — | **Shutdown** |
| Gi1/0/4 | PVE01 | Trunk | All tagged, native **10** |
| Gi1/0/5 | SPAN-Monitor-Port | Monitor | — |
| Gi1/0/6 | FortiGate-Management | Access | 10 |
| 🔴 **Gi1/0/7** | 🔴 **Pi01 — Root CA, Vaultwarden, Pi-hole, FreeRADIUS** | **Access** | **10** |
| Gi1/0/8-48 | Unused | Access | 999 (shutdown) |
| Gi1/0/49-52 | Unused-SFP | — | shutdown |

### Edit 2 — `027` Step 13: fix the access ports

- **`Gi1/0/2`** — description `LabComputer` (was `Raspberry-Pi`)
- 🔴 **`Gi1/0/3` — REPLACE the entire block.** Delete the VLAN 50 / `no shutdown` config. Replace with:

```text
interface GigabitEthernet1/0/3
 description Disabled - pending device assignment, see ADR-0002
 shutdown
exit
```

- 🔴 **`Gi1/0/7` — ADD the block that does not exist:**

```text
interface GigabitEthernet1/0/7
 description Raspberry-Pi
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 spanning-tree bpduguard enable
 switchport port-security maximum 2
 switchport port-security violation restrict
 switchport port-security
 no shutdown
exit
```

### Edit 3 — `027` Step 15: change the unused range

```text
interface range GigabitEthernet1/0/8-48      <-- was 1/0/7-48
```

🔴 **`Gi1/0/7` must NOT be in the shutdown range.**

### Edit 4 — `027` Step 16: the ACL gets five entries

```text
arp access-list STATIC-HOSTS
 permit ip host 10.10.0.5   mac host 0000.5e00.5300     <-- Pi01. WAS MISSING.
 permit ip host 10.10.0.10  mac host 0000.5e00.5313     <-- PVE01 eno1
 permit ip host 10.10.0.50  mac host 0000.5e00.5316     <-- Admin workstation
 permit ip host 10.10.0.100 mac host 0000.5e00.5314     <-- iDRAC (SAME PORT as eno1 - shared LOM)
 permit ip host 10.10.0.254 mac host 0000.5e00.5315     <-- FGT01 internal2
exit
ip arp inspection filter STATIC-HOSTS vlan 10
```

**Add above it:**

> 🔴 **ALL FIVE ARE REQUIRED. `DHCP Permits: 0` on this switch — there is NO snooping fallback.** A host missing from this ACL is **dropped, full stop**, with no error and no warning. It simply appears broken.
>
> 🔴 **Pi01 was missing from this list until 2026-07-14.** A rebuild without it silently drops the Root CA, the Intermediate CA, Vaultwarden, Pi-hole and FreeRADIUS — **and produces a phantom "Pi01 should be unreachable" mystery that has already survived three handoffs.** `016` lesson 6.
>
> **Build this from `006-Network-Source-of-Truth.md`, not from memory.**

### Edit 5 — `027` Validation: correct the expected results

- `STATIC-HOSTS` has **five** entries *(was: "four")*
- `Gi1/0/1,2,4,5,6,7` connected; **`Gi1/0/3` disabled**; `Gi1/0/8-52` disabled

### Edit 6 — `027` Step 17: redact the SNMP community

```text
snmp-server community <GENERATED-VALUE-FROM-VAULTWARDEN> ro
snmp-server host <MON01-IP> traps version 2c <GENERATED-VALUE>
ntp server <NTP-SERVER-IP>
```

**Add:**

> 🔴 **Do not type a literal community string here.** A Build Guide never contains a value you would actually type (Charter, *Evidence and secrets*). **The live value is `homelab`, it is v2c, it is cleartext on the wire, and it must be rotated** — see `CM-0023`.
>
> 🔴 **`10.40.0.52` does not exist.** VLAN 40 is live and empty. Do not point SNMP traps at it. **Book 5/10 stands up the collector; point it there then.**
>
> 🔴 **Confirm Pi01 actually serves NTP before pointing a client at it.** `029` records no NTP service on Pi01.

### Edit 7 — `027` Step 2 and Completion Checklist: `SW01`, not `CoreSwitch`

Set the target hostname to `SW01`, and note that the **live** device is currently `CoreSwitch` pending `CM-0024` (below).

### Edit 8 — `023` Build Record: `Gi1/0/1` description

- Port table: `Gi1/0/1` → **`Trunk-to-MKT01`** *(per `CM-0001`, confirmed live)*
- Known Deviations: **remove** the `Gi1/0/1 port description` row — **it is closed.**

---

## Records this record spawns

| New record | Scope | Why not here |
|---|---|---|
| 🔴 **`CM-0023`** | **Rotate the SNMP community `homelab` off `homelab`.** v2c cleartext, live, named by the Charter, present in `023` and `027`, **no record has ever existed for it.** | **Device change.** Different risk profile. **`ADR-0010` gates publication on no live credential in the tree — this is one.** |
| **`CM-0024`** | **Rename SW01: `CoreSwitch` → `SW01`.** | **Device change.** Four documents call it open; **no record has ever existed.** Touches the SSH config, the VTY ACL, and every document naming it. |

---

---

# 🟢 DEVICE VERIFICATION — SW01, 2026-07-14, BEFORE any edit

## ✅ Every claim in this record is confirmed. And the device found three more.

```
SW01# show arp access-list STATIC-HOSTS
    permit ip host 10.10.0.10  mac host 0000.5e00.5313
    permit ip host 10.10.0.50  mac host 0000.5e00.5316
    permit ip host 10.10.0.100 mac host 0000.5e00.5314
    permit ip host 10.10.0.254 mac host 0000.5e00.5315
    permit ip host 10.10.0.5   mac host 0000.5e00.5300      <-- 🟢 Pi01. FIVE entries.
```

| | Device | `027` built |
|---|---|---|
| `STATIC-HOSTS` | 🟢 **FIVE, Pi01 present** | 🔴 **FOUR. Pi01 missing.** Validation expected *"four."* |
| `Gi1/0/7` | 🟢 `Raspberry-Pi`, VLAN 10, **connected**, port-sec max 2 | 🔴 **Shut down, VLAN 999** (`7-48` range) |
| `Gi1/0/3` | 🟢 **`disabled`** — *"pending device assignment, see ADR-0002"* | 🔴 **`no shutdown`, VLAN 50** |
| `Gi1/0/2` | 🟢 **`LabComputer`** | 🔴 **`Raspberry-Pi`** |
| `Gi1/0/1` | 🟢 **`Trunk-to-MKT01`** — **`CM-0001` DID execute** | ✅ correct — **but `023` is stale** |
| IOS | 🟢 **`15.2(2)E6`** | 🔴 **`15.2(7)E`** |
| DAI trust | 🟢 `Gi1/0/1` only | ✅ |
| VLANs | 🟢 All nine active | ✅ |

**🔴 Every single defect in this record is confirmed on the device. `027` was rebuild-fatal, exactly as scoped.**

---

## 🔴🔴 DEVICE FINDING 1 — SW01's clock has NEVER synchronised

```
SW01# show ntp status
Clock is unsynchronized, stratum 16, no reference clock
reference time is 00000000.00000000 (18:00:00.000 CST Thu Dec 31 1899)
system poll interval is 8, never updated.

SW01# show run | include ntp
ntp server 10.10.0.5
```

🔴 **`never updated`. Stratum 16. Reference time 1899.**

**`10.10.0.5` is Pi01. `029-Pi01-Build-Record.md` records NO NTP service on Pi01. MKT01's `/system ntp server print` → `enabled: no`.**

> 🔴 **SW01 has been pointed at a host that serves no time, since it was built. Every log line it has ever emitted carries a meaningless timestamp.**
>
> 🔴 **`045-SW01-CIS-Hardening-Checklist.md` §2.3 ticks: `[x] NTP configured and synchronized — confirmed live during original SW01 validation.`** **THAT TICK IS FALSE.**
>
> **`016` lesson 4, again: a tick on a test nobody ran.** **And `015`'s own rule: *"if you cannot make a test succeed on purpose, its failure means nothing."*** **Nobody ran `show ntp status`. They read the config line and ticked the box.**

**This is Book 5's foundation.** Syslog, SIEM correlation, certificate validity, Kerberos — **all of it assumes a clock.** → 🔴 **`CM-0030`**

## 🔴 DEVICE FINDING 2 — `Gi1/0/4` is running at 100 Mbps RIGHT NOW

```
Gi1/0/4   Proxmox-Server   connected   trunk   a-full  a-100
```

**Four documents — `003`, `023`, `024`, `036` — all say the same thing:**

> *"Gi1/0/4 link speed — **Confirmed 1 Gbps post-reboot** (was transient 100 Mbps). **Monitor — cable swap if it recurs.**"*

🔴 **IT RECURRED.** **The hypervisor uplink — every VM, every backup, every future live migration — is at one tenth of its rated speed, and four documents say it is fine.**

*(The port description also reads `Proxmox-Server`. `006`, `023` and `027` all say `PVE01`.)*

**Cheapest first: swap the cable.** `036` and `048` both say *"verify physical link negotiation before troubleshooting higher layers."* → 🔴 **`CM-0031`**

## 🟢 DEVICE FINDING 3 — the SW01 rename ALREADY HAPPENED. `CM-0024` is dead.

```
SW01# show run | include hostname
hostname SW01
```

**Seven documents — `001`, `006`, `012`, `016`, `019`, `023`, `045` — state that the live hostname is `CoreSwitch` and that a rename is *"still open"* / *"Change Record required."* And `027` built `CoreSwitch` as the TARGET.**

> 🟢 **`CM-0024` (SW01 rename) was planned by this audit and is now UNNECESSARY.** **It is a documentation correction, not a device change.**
>
> 🔴 **And it explains why the rename "never happened": the Build Guide said `CoreSwitch` was correct.** **Nothing ever flagged it as a deviation to close — because the guide had already accepted it.**

---

# 🟢 EDITS APPLIED — verified by COUNT-CHECK (rule R1)

**16 edits.** Port table · Step 1 IOS · Step 2 hostname · `Gi1/0/2` relabelled · **`Gi1/0/3` shut down** · **`Gi1/0/7` block ADDED** · unused range `8-48` · **`STATIC-HOSTS` gets Pi01** · SNMP redacted · **NTP proof step** · Validation · Checklist · Common Mistakes · Change Log.

## 🔴 THE COUNT-CHECK CAUGHT THREE THINGS THE EDIT PASS MISSED

| # | What | How it was found |
|---|---|---|
| 🔴 **1** | **The FIRST edit pass applied ZERO of 16 edits.** `497 → 497` lines. The file had **CRLF** endings; the patterns didn't match. **Python's `.replace()` is silent on a miss.** | 🔴 **Only the count-check.** **Every "is the new string present?" test would have been meaningless — and I would have shipped an unchanged file with a commit message describing work that never happened.** *(`To-The-Next-Session` §7, verbatim.)* *(Also: `.gitattributes` says `*.md text eol=lf`. This file should never have had CRLF. Normalised.)* |
| 🔴 **2** | Step 1 still said *"IOS **15.2(7)E** or later."* | Count-check |
| 🔴🔴 **3** | **Step 18's Final Save: `Expected: hostname CoreSwitch`.** | Count-check |

> 🔴 **Finding 3 is the same species as `STATIC-HOSTS has four entries`: A VALIDATION STEP THAT STATES THE WRONG EXPECTED RESULT.**
>
> **That is worse than no validation.** **It takes a correct device, calls it a failure, and invites you to "fix" it.** **`027` contained TWO of them.**

## Final verification

```
STATIC-HOSTS has four entries        ->  0   🟢 GONE
GigabitEthernet1/0/7-48              ->  0   🟢 GONE
community homelab ro                 ->  0   🟢 GONE
description Windows-Laptop           ->  0   🟢 GONE
switchport access vlan 50            ->  0   🟢 GONE
host 10.40.0.52                      ->  0   🟢 GONE
IOS 15.2(7)E or later                ->  0   🟢 GONE
Expected: `hostname CoreSwitch`      ->  0   🟢 GONE

10.10.0.5 mac host 0000.5e00.5300    ->  1   🟢 Pi01 is in the ACL
interface GigabitEthernet1/0/7       ->  1   🟢 Pi01's port is built
GigabitEthernet1/0/8-48              ->  1   🟢 Pi01's port is NOT in the shutdown range
hostname SW01                        ->  3   🟢
15.2(2)E6                            ->  2   🟢

CRLF: 0  |  code fences: EVEN  |  lines: 497 -> 594
```

---

## Validation

**This record changes no device.**

```powershell
# Pi01 must now be in the guide's ACL — expect ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Build-Guides\027-SW01-Build-Guide.md `
              -Pattern "10.10.0.5   mac host 0000.5e00.5300"

# The wrong expected result must be GONE — expect ZERO hits:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Build-Guides\027-SW01-Build-Guide.md `
              -Pattern "STATIC-HOSTS has four entries"

# Gi1/0/7 must be OUT of the shutdown range — expect ZERO hits:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Build-Guides\027-SW01-Build-Guide.md `
              -Pattern "GigabitEthernet1/0/7-48"

# The live community string must be GONE from the guide — expect ZERO hits:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Build-Guides\027-SW01-Build-Guide.md `
              -Pattern "community homelab"
```

**On the LIVE device — confirm the switch is what `023` and `006` say it is:**

```text
show arp access-list STATIC-HOSTS      # expect FIVE entries, including 10.10.0.5
show interfaces description            # expect Gi1/0/1 = Trunk-to-MKT01, Gi1/0/7 = Raspberry-Pi
show interfaces status                 # expect Gi1/0/3 disabled, Gi1/0/7 connected
```

## Rollback

`git checkout -- Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Guide.md Labs/Lab-01-Mikrotik-Core/Devices/SW01-Access-Switch/Build-Record.md`

---

## Guide Reconciliation — required, not conditional

> **Does any guide now contain an instruction that would recreate this problem, or a claim that this change disproves?**

| Document | Outcome | Detail |
|---|---|---|
| 🔴 **`027-SW01-Build-Guide.md`** | **Updated** | **This record is that reconciliation.** Edits 1–7. |
| 🔴 **`023-SW01-Build-Record.md`** | **Updated** | Edit 8. `Gi1/0/1` description — stale since `CM-0001`. **Still carries the live SNMP community (`homelab`) and the nonexistent trap host `10.40.0.52` — handed to `CM-0023`.** |
| **`006-Network-Source-of-Truth.md`** | **Reviewed — no change needed** | 🟢 **`006` was right.** Five-entry ACL, correct port table. **It is the source `027` should have been built from.** |
| **`012-Management-Network.md`** | **Reviewed — no change needed** | 🟢 Correct. All five entries listed. |
| **`003-Physical-Topology.md`** | **Reviewed — no change needed** | 🟢 Correct. `Gi1/0/7` = Pi01, `Gi1/0/2` = LabComputer, `Gi1/0/3` disabled. |
| **`016-Network-Lessons-Learned.md`** | 🔴 **MUST UPDATE** | Lesson 6 says the omission was *in the Build Record*. **It was ALSO in the Build Guide, and the guide was never fixed.** Add: **when a fact is corrected, correct the document that BUILDS it, not only the documents that DESCRIBE it.** |
| **`048-Teardown-and-Rebuild-Runbook.md`** | 🔴 **NOT YET REVIEWED — blocking** | Chunk 4. `048` says *"build the ACL from this list."* **Confirm which list it points at.** |
| **`039-SW01-Troubleshooting-Guide.md`** | 🔴 **NOT YET REVIEWED** | Chunk 4. |
| **`045-SW01-CIS-Hardening-Checklist.md`** | 🔴 **NOT YET REVIEWED** | Chunk 4. **Likely holds the SNMP item — check before raising `CM-0023`.** |

---

## The lesson

> 🔴 **When a fact is corrected, the correction pass finds the documents that DESCRIBE it and misses the one that BUILDS it.**

`006`, `012`, `023` and `016` were all corrected on 2026-07-13. **`027` was not** — and `027` is the only one of the five that actually creates the ACL.

**A Build Guide is read once, in the worst hour of the project, when the device is gone.** It is the last document to get fixed and the first one that matters. **`016` lesson 8, generalised:** *a guide that does not mention a thing will recreate the thing* — **and a correction pass that does not open the guide will leave it not mentioning the thing.**

---

## Closeout

- [x] ✅ **Device read FIRST** — every claim re-tested on live SW01 before a line was edited
- [x] ✅ Port table replaced; `Gi1/0/2` relabelled; **`Gi1/0/3` SHUT DOWN**; 🔴 **`Gi1/0/7` block ADDED**
- [x] ✅ Unused range `1/0/8-48` — **`Gi1/0/7` is out of it**
- [x] ✅ 🔴 **`STATIC-HOSTS` gets its FIFTH entry — Pi01**
- [x] ✅ Validation expects **FIVE**, not four
- [x] ✅ SNMP community redacted; trap host flagged as nonexistent; location disclosure removed
- [x] ✅ 🔴 **NTP: a PROOF step (`show ntp status`) added — a config line is not a synced clock**
- [x] ✅ Hostname → `SW01`; IOS → `15.2(2)E6`
- [x] ✅ **VALIDATED BY COUNT-CHECK (R1)** — it caught **three** things the edit pass missed, **including a first pass that applied ZERO of 16 edits**
- [x] ✅ Live device confirms five ACL entries, `Gi1/0/7` connected, `Gi1/0/3` disabled
- [x] 🟢 **`CM-0024` (SW01 rename) — NOT NEEDED. The device is ALREADY `SW01`.** Documentation correction only.
- [ ] 🔴 **`023` corrected** — `Gi1/0/1` description, hostname, IOS, SNMP, NTP — **BLOCKS CLOSURE**
- [ ] 🔴 **`CM-0023` raised** (rotate SNMP — **gates publication**, `ADR-0010`) — **BLOCKS CLOSURE**
- [ ] 🔴 **`CM-0030` raised** (SW01 clock has NEVER synced) — **BLOCKS CLOSURE**
- [ ] 🔴 **`CM-0031` raised** (`Gi1/0/4` at 100 Mbps — it recurred) — **BLOCKS CLOSURE**
- [ ] 🔴 **`016` updated** with R1 and the wrong-expected-result lesson — **BLOCKS CLOSURE**
- [ ] 🔴 **`039`, `045` reconciled** — `045`'s NTP tick is FALSE; `045` says 23 firewall rules (device: 22) — **BLOCKS CLOSURE**
- [ ] Closed

> 🔴 **Status is `Implemented — reconciliation open`, NOT `Closed`.** **Six boxes are unticked and every one is unticked because it is TRUE.**

> 🔴 **Does NOT move to `Closed` while any box is unticked.** Status is `Implemented — reconciliation open` until they are.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`), findings C2–C5, B6, B7. 🔴 **`027` builds a four-entry `STATIC-HOSTS` ACL with Pi01 missing, shuts down `Gi1/0/7` (Pi01's port), puts it in VLAN 999, and labels `Gi1/0/2` "Raspberry-Pi" — four independent ways a clean rebuild kills the host holding the Root CA, the vault, DNS and RADIUS.** Its Validation section states *"four entries"* as the expected result. 🔴 **It also re-enables `Gi1/0/3` on VLAN 50, reversing `ADR-0002` and `CM-0003` — neither of which has a Build Guide reconciliation row, because both predate Charter Rule 15.** 🔴 **And it types the live SNMP community the Charter names by string.** `023`'s `Gi1/0/1` description corrected — `CM-0001` ticked that box and never made the edit. |
