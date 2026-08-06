---
Title: Network Lessons Learned
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Network Lessons Learned

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | **Draft for Confluence Review** |
| Version | **3.1** |
| Applies To | Atlas |
| Last Reconciled | **2026-07-14** — rebuilt after the Book 1 audit (`ADR-0019`, `051`) and a full device pass on MKT01, SW01, Pi01 and FGT01 |

> **v1.0 was a list of device tips. It had no process lessons at all** — and the device tips were never what cost the time.
>
> 🔴 **v3.0 adds the two rules the full audit produced.** **`051` read all 76 Book 1 documents and found that every rebuild-fatal defect in the pack traces to ONE of TWO mechanical habits.** **They are at the top of this page because they are the only thing on it you must not skip.**

---

# 🔴 PART 0 — THE TWO RULES

> **`ADR-0019` audited all 76 documents in Book 1 and found EIGHT defects that would break a rebuild.**
>
> 🔴 **Every one of them is a consequence of one of the two habits below. Not carelessness. Not ignorance. Two specific, nameable, mechanical habits — each with a one-line fix.**

---

## 🔴 R1 — VERIFY A CORRECTION BY COUNTING THE **OLD** TEXT. NOT BY CONFIRMING THE NEW ONE IS PRESENT.

```powershell
# 🔴 WRONG — this is what was done. TWELVE TIMES.
Select-String -Path .\026-MKT01-Build-Guide.md -Pattern "mac-winbox.*RECOVERY"
# It hits. The fix landed. The document looks correct.

# ✅ RIGHT — the OLD string must be GONE.
(Select-String -Path .\026-MKT01-Build-Guide.md -Pattern "mac-winbox.*=none").Count
# MUST return 0.
```

> 🔴 **A hit on the fix proves the fix landed. IT PROVES NOTHING ABOUT WHETHER THE THING IT REPLACED IS STILL SITTING SIX LINES BELOW IT.**

### 🔴 The habit: **THE CORRECTION IS APPENDED. THE ERROR IS NOT DELETED.**

**Twelve occurrences, found in one audit. Six of them in the change records themselves. Two in the two highest-severity records in Book 1.**

| # | Document | The correction | The error, still standing | Apart |
|---|---|---|---|---|
| 🔴 **1** | **`026` §12** | `mac-winbox = RECOVERY` | 🔴 **`mac-winbox = none`** | **6 lines** |
| 🔴 **2** | **`018` v3.0** | *"BOTH SENTENCES ARE FALSE"* | 🔴 **Both sentences — as the page's own recommendation** | **21 lines** |
| **3** | `021` | *"Interfaces — Disabled"*, `Verified` | *"left at factory defaults **rather than disabled**"* | ~30 |
| 🔴 **4** | **`CM-0009`** | 🔴 **A section titled *"Closeout defect — this record was marked `Closed` with two boxes unticked"*** | 🔴 **Its own closeout — with THREE unticked and `[x] Closed`** | **20 lines** |
| 🔴 **5** | **`CM-0012`** | 🔴 **§3: *"Cipher 0 — the 'proof' here is VOID"*** | 🔴 **Its Note: *"the RIGHT KIND of proof — the exploit failing"*** | **87 lines** |
| 🔴 **6** | **`CM-0016`** | ✅ Status: *"Closed — executed and read back"* | 🔴 **Line 12: *"This is a `Draft`. A Draft record is a hypothesis, not a work order."*** | 🔴 **4 lines** |
| **7** | `CM-0013` | `[x] Closed` | `[ ] 033 and 015 reconciled — open` |  |
| **8** | `CM-0015` | Every closeout box ticked ✅ | Change log: *"reconciliation **remains open**"* |  |
| **9** | `CM-0017` | Status: `✅ Closed` | Foot: *"Status: `Implemented — reconciliation open`"* |  |
| **10** | `CM-0018` | Status: `Closed` | Head: *"A **`Draft`** record is a hypothesis"* |  |
| 🔴 **11** | **`CM-0010`** *(HIGH — Root CA key material)* | Status: `✅ Closed` | 🔴 **`[ ] Mark this record Closed`** |  |
| 🔴 **12** | **`CM-0014`** *(the highest-severity record in Book 1)* | Status: `✅ CLOSED` | 🔴 ***"It does not return it to Closed"*** — **and NO Closeout section exists at all** |  |

> 🔴 **`CM-0009` FOUND the closeout defect. WROTE IT UP. CITED IT IN THIS FILE. AND DID NOT TICK ITS OWN BOXES.**
>
> 🔴 **`CM-0012` DECLARED ITS CIPHER-0 PROOF VOID IN §3 AND RE-ASSERTED IT AS *"the right kind of proof"* 87 LINES LATER.** **Lesson 4 on this page — *a test that cannot fail proves nothing* — WAS DERIVED FROM THAT RECORD. The sentence it was derived from is still in it.**
>
> 🔴 **`026` §12 CARRIES A HEADER SAYING *"✅ REWRITTEN 2026-07-14 to fix the missing recovery path"* — AND IT SET `mac-winbox=none` SIX LINES AFTER SETTING IT TO `RECOVERY`.** **RouterOS `set` is last-write-wins. The block written to BUILD the recovery path DESTROYED it.**

### Why it keeps happening (lesson 13)

**Appending feels safe. Deleting requires certainty.**

🔴 **And the `[chg ]` line-count delta goes UP — which reads as a plausible edit.** **`Tools/README.md` teaches you to catch `496 → 12`.** **This failure goes the OTHER WAY and looks fine.**

### 🔴 The precondition nobody states

🔴 **A count-check only works if the dangerous string appears ONLY where it is dangerous.**

**If your own *"this was wrong"* commentary quotes the bad string verbatim, `(Select-String).Count` returns `1` forever, someone must go and look every single time — and THAT IS HOW A CHECK GETS IGNORED.**

**Paraphrase in commentary. Keep the exact string in ONE place: the thing you are deleting.**

### 🔴 And the failure R1 catches that nothing else does

🔴 **Edit tools fail SILENTLY on a miss.** **`.gitattributes` says `*.md text eol=lf`. Several files in the tree have CRLF anyway** — `025` had **312** CRLF pairs.

🔴 **A multi-line pattern built with `\n` matches ZERO occurrences in a CRLF file. The tool reports nothing. Python's `.replace()` returns the string unchanged.**

> 🔴 **The first edit pass on `027` applied ZERO of 16 edits. `497 → 497` lines. No error. No warning.**
>
> **Every *"is the new string present?"* test would have been meaningless — and a commit message describing sixteen fixes would have shipped an unchanged file.**
>
> 🔴 **ONLY THE COUNT-CHECK FOUND IT.** **Normalise to LF before editing. ALWAYS confirm the line count changed.**

---

## 🔴 R2 — FIX THE DOCUMENT THAT **DOES** THE WORK. NOT ONLY THE ONES THAT DESCRIBE IT.

### 🔴 The habit: **THE CORRECTION REACHES THE DOCUMENT THAT DESCRIBES THE WORK AND MISSES THE ONE THAT PERFORMS IT.**

| Corrected | 🔴 Missed | The missed document is… |
|---|---|---|
| `006`, `012`, `023`, `016` — *the ARP ACL* | 🔴 **`027`** | …the guide that **BUILDS** the ACL. **It built FOUR entries. Pi01 was the missing one.** |
| `031`, `029`, `049`, `043` — *the CA backup* | 🔴 **`048`** | …the runbook that **TAKES** the backup. **It rebuilt the unencrypted archive `CM-0010` destroyed.** |
| `031` — *SAN, bundle, revocation* | 🔴 **`035`, `042`** | …the runbooks that **ISSUE** and **REISSUE**. **`035` set no SAN at all.** |
| `013`, `017` — *"Pi-hole is optional"* | 🔴 **`001`, `Build-Order`** | …the **landing pages**. **The sentence was killed in two documents and left standing in two others.** |

> 🔴 **`031` IS READ ONCE, WHEN THE CA IS BUILT. `035` IS READ EVERY TIME A DEVICE NEEDS A CERTIFICATE.**
>
> 🔴 **`031` WAS CORRECTED FIVE TIMES. `035` WAS NEVER OPENED.**

### The generalisation

**Lesson 8 on this page says: *a guide that does not mention a thing will recreate the thing.***

> 🔴 **R2 IS THAT, ONE LEVEL UP: A RECONCILIATION THAT DOES NOT OPEN THE DOCUMENT THAT PERFORMS THE WORK HAS NOT HAPPENED.**

🔴 **ASK AT EVERY CLOSEOUT: *WHICH DOCUMENT DOES THE WORK?* FIX THAT ONE FIRST.**

**A Build Guide is read ONCE — in the worst hour of the project, when the device is gone.** **It is the last document to get fixed and the first one that matters.**

### 🔴 R2 applies to ARTEFACTS, not just documents

🔴 **`031` v0.6, `029`, `MC-0002` and the pack manifest ALL record — TRUTHFULLY — that Pi-hole's certificate SAN was *"verified directly on the live-served connection."* ALL FOUR ARE RIGHT.**

🔴 **AND `/etc/ssl/lab-ca/issued/pihole/pihole.crt` CARRIES THE PRE-VLAN SAN `IP:10.0.0.5` TO THIS DAY — and `032` Step 7 rebuilds `tls.pem` from EXACTLY that file.**

> 🔴 **THE VERIFICATION CHECKED THE WIRE. THE REBUILD USES THE FILE. NOBODY CHECKED THE FILE.**
>
> **They are two different objects. CHECK BOTH.** (`CM-0032`)

---

# Part 1 — The failures that recur

**Every one of these happened more than once, on different devices, with different technologies.** They are not FortiGate lessons or MikroTik lessons. **They are the lessons.**

## 🔴 1. A command completing without an error is not a confirmed change

**The single most expensive lesson in this project. At least seven independent occurrences.**

| What happened | The command returned |
|---|---|
| FGT01's `admin-server-cert` **never bound** — the device served the wrong certificate for hours | No error |
| MKT01 `use-radius=yes` **did not persist on the first `set`** — RADIUS was never consulted | No error |
| A certificate was signed with **no SAN** — `copy_extensions` was silently discarding it | Clean sign log |
| A DNS record was written to `/etc/pihole/custom.list` — **inert on Pi-hole v6** | No error |
| `cat file1 file2 \| sudo tee out` — `sudo` applied only to `tee`; a **keyless certificate** went into production TLS | Pipeline "succeeded" |
| The Windows certificate wizard reported **"The import was successful"** — and the certificate was not trusted | Success message |
| `ipmitool lan set 1 cipher_privs ...` — **degraded** a correctly-hardened BMC | No error |

**The fix is not "be more careful." It is a read-back.**

> **Every configuration change is followed by reading the resulting state off the device.** Not the exit code. Not the absence of an error. **The value.**
>
> `get`, not `show`, on FortiOS. `/interface print` on RouterOS. `openssl s_client` for a certificate. **The device, not the command's silence.**

## 🔴 2. The closeout's own failure mode: a record marked `Closed` with unticked boxes

**`CM-0009` was marked `Closed — implemented and verified`. Two of its own closeout boxes were unticked** — including *"Build Record updated."*

**And that box was unticked because it was true.** `022-MKT01-Build-Record.md` still said **24 firewall rules** with two "pending removal." **The device had 22.** For a full day, the Build Record — the document whose only job is to record verified reality — **described a firewall that no longer existed.**

> **The closeout was invented to catch exactly this class of defect. Then the closeout itself was not completed.**
>
> 🔴 **A checklist nobody verifies reports success by default.**

**Rule, now in both templates:** a record does **not** move to `Closed` while any box is unticked. If a box cannot be ticked, the status is **`Implemented — reconciliation open`.**

## 🔴 3. The document that defines a rule is not a control

**`018-Atlas-Documentation-Standards.md`, line 29:** *"Never include passwords, API tokens, private keys, or reusable secrets."*

**The rule existed. It was published. It was in force.**

Commit **`ac2182f`** shipped `049-Root-CA-and-Credential-Backup-Runbook.md` — a runbook whose entire Phase 1 is a warning that the archive passphrase must **never** exist digitally — **and shipped the passphrase, in the same commit.** `git add .` staged both halves. The commit message describes only the good one. **It is on GitHub.** (`CM-0014`)

> 🔴 **The commit that publishes a rule can violate it in the same breath, and nothing will notice.**
>
> **The control is a pre-commit secret scanner. Not the standard. Not the author's memory. Not `.gitignore` — which denylists *extensions*, and a passphrase in a `.txt` walks straight through.**

## 🔴 4. A test that cannot fail proves nothing

**`CM-0012` recorded cipher 0 as *"✅ proven by the exploit failing."*** The exploit was:

```bash
ipmitool -I lanplus -H 10.10.0.100 -C 0 -U root -P "" chassis status
# -> Error: Unable to establish RMCP+ session
```

🔴 **IPMI-over-LAN was disabled the whole time** (`Access Mode : disabled`). **That exploit would have failed identically with cipher 0 wide open at ADMIN** — the session dies at a closed channel, before any cipher is evaluated.

**The control was never established, so the negative result was uninterpretable.** A ✅ in a change record, resting on nothing.

**Two more from the same hour:**

| Test | Looked like it proved | Actually proved |
|---|---|---|
| `ping 10.10.0.100` succeeds | "The iDRAC is reachable" | The **NIC** answers ICMP. Nothing about IPMI or HTTPS. |
| `nc -u -z 10.10.0.100 623` → *succeeded* | "UDP 623 is listening" | **Nothing.** UDP is connectionless — `nc -u -z` reports success whenever it doesn't get an ICMP port-unreachable back. |

> 🔴 **Before you trust a negative result, prove the positive case works.** If you cannot make the test *succeed* on purpose, its failure means nothing.

## 🔴 5. Read the device *before* you execute a record built from a stale baseline

**`CM-0011` said the BMC had cipher 0 at ADMIN (`aaaaaaaaaaaaaaa`).** Its `Status` said `Draft — not executed`, so it was treated as a to-do list and run.

**The device was already at `XXXaXXXXXXXXXXX`** — hardened hours earlier. The command **degraded it**, turning suites 1 and 2 (authentication, no encryption) from unused back to ADMIN. Caught only by the read-back, and reverted.

**And `CM-0012`, sitting in the same folder, had `Blocks: CM-0011` in its header and said in its first paragraph:** *"Hardening a BMC that cannot hold its settings is documenting a lie. Fix the battery first."* **It was never opened.**

> 🔴 **Charter Rule 13 says the device beats the document. This was executing a document as if it beat the device.**
>
> **A `Draft` record is a hypothesis, not a work order.** Read the device. Read the records next to it. **Then decide whether the hypothesis still holds.**

## 🔴 6. "Never guess" is not enough. The rule needs a second half: *and never omit.*

**`012-Management-Network.md` said: *"Static VLAN 10 systems require verified IP/MAC entries... Never guess a MAC address."*** Correct rule.

**Nobody guessed Pi01's MAC. It was simply never written down.** `006-Network-Source-of-Truth.md` — the page that **declares itself authoritative for MACs and port assignments** — had **four** `STATIC-HOSTS` entries where **five** are required. Pi01 was missing.

**Its MAC was on the same page**, in the IP table, uncopied into the ARP ACL.

**SW01 has `DHCP Permits: 0`.** A host missing from that ACL is **dropped, full stop** — no error, no warning. It simply appears broken. **The same omission in the SW01 Build Record produced a false "Pi01 should be unreachable" mystery that survived three handoffs.**

> 🔴 **A guessed value fails loudly. An omitted one fails silently, and looks like a broken device.**

## 🔴 7. A flow you have not drawn is a flow you will write firewall rules for on the wrong device

**MKT01 carried two firewall rules permitting FGT01→Pi01 RADIUS.** Both were dead **twice over**: they pointed at `10.0.0.5` (Pi01's *pre-VLAN* address), **and** they sat on a device that is **not on the path.**

FGT01 (`10.10.0.254/24`) and Pi01 (`10.10.0.5/24`) are **the same subnet, same VLAN, Layer-2 adjacent via SW01.** The traffic **never enters MKT01's forward chain.**

**And the anomaly went unquestioned for months:** RADIUS was confirmed working end-to-end *while the rules pointed at a nonexistent host.* **It worked *because* MKT01 was not involved.** Nobody asked why — **because no document said where the traffic actually went.** (`011-Packet-Flow.md` now does.)

## 🔴 8. A guide that does not mention a thing will recreate the thing

**`CM-0015` disabled MKT01's `ether2` — an enabled, idle, undocumented interface.** Guide reconciliation then found that **`026-MKT01-Build-Guide.md` did not mention `ether2` at all.** Not wrongly — *at all*.

**So a router rebuilt from the guide comes back with `ether2` enabled, idle and undocumented: exactly the state the record was raised to fix. The guide recreated the finding.**

**Same shape, twice more:**
- `026` **never built the input-chain default deny.** RouterOS defaults to **ACCEPT** — a router rebuilt from it had **no default deny on its input chain at all.**
- `033-Pi01-FreeRADIUS-Build-Guide.md` listed creating a `testing`/`password` account as a **passing test**. Once RADIUS actually worked, that was a **live admin credential on every network device.**

> 🔴 **Closing a change on the device without fixing the guide makes the record cosmetic.** The device is right; the next rebuild is wrong; nobody knows until someone enumerates again. **This is why guide reconciliation is not conditional** (Charter Rule 15).

## 🔴 9. "Available" is not a state. It is a hope.

`022-MKT01-Build-Record.md` recorded `ether2` as **"Unused — Available."** The device said **enabled**.

**"Available" survives review because it sounds like a decision. It is not one.** A Build Record records **administrative state**: `disabled`, or `enabled with a documented reason`. Nothing else.

## 🔴 10. An index that stops being updated is worse than no index

**`Change-Management/README.md` listed CM-0001 through CM-0008 and said *"Next available number: CM-0009."*** **CM-0015 existed.** The index did not mention `CM-0014` — a credential exposure on GitHub — or either iDRAC record.

**Its own Rule 5 says:** *"Update the index table whenever a record is created or its status changes."* **The rule was written on that page, published, and ignored by that page.**

**Same failure, four more times:** `NETWORK-PACK-MANIFEST.md` ("8 CM records, all Closed"), the Session Handoff (inherited it), `Atlas-Roadmap.md` ("Book 2 needs a manifest" — it had one), `Atlas-Blueprint.md` (pointed the next session at work already finished).

> **A stale index does not merely fail to help. It actively tells you the work is done.**

## 🔴 11. A tool you cannot test is not a tool. It is a wager.

**A PowerShell renumbering script was written, shipped, and run without ever being parse-checked** — because the authoring environment had no PowerShell. It had two defects: a reserved `<` character inside a `Write-Host` string that broke the parser, and `Set-Content -Encoding utf8`, which on Windows PowerShell 5.1 writes a **BOM** and rewrites line endings — churning **every line of every file it touched.**

**The `git mv` commands it was supposed to replace worked first time, pasted by hand, with a perfect rename record.**

> 🔴 **Do not automate a step you cannot verify.** The manual version is slower and it is *checkable*.

## 🔴 12. Every safety net that worked was one that failed loudly

**Everything that hurt this project failed *silently* and looked like success.** Everything that saved it **refused, out loud.**

| Control | Caught |
|---|---|
| `Place-AtlasFiles.ps1` **refuses a dirty tree** | Half-applied batches, three separate times |
| It reports **`[same]`** instead of silently skipping | Stale downloads placed by mistake |
| It **backs up before overwriting** | Every overwrite in this project |
| **`Select-String` on a phrase unique to the new version** | Files that never landed while `git` reported success |
| It **refuses to guess** on an ambiguous filename | Would have misfiled a manifest — twice |

**The two failures that got through both went *around* the tool:** a `Copy-Item` (which overwrote Book 1's manifest into Book 2's folder), and a script that couldn't be tested.

> 🔴 **A control that fails silently is not a control.**

## 🔴 13. A CONFIG LINE IS NOT A WORKING SERVICE

**`ntp server 10.10.0.5` sat in SW01's running-config, looking correct, for the entire life of the switch.**

```text
SW01# show ntp status
Clock is unsynchronized, stratum 16, no reference clock
reference time is 00000000.00000000 (18:00:00.000 CST Thu Dec 31 1899)
system poll interval is 8, never updated.
```

🔴 **`10.10.0.5` is Pi01. Pi01 runs NO NTP SERVER.** *(It runs `systemd-timesyncd` — a **client**.)* **MKT01's `/system ntp server` is `enabled: no`.** **FGT01's NTP is an EMPTY server entry bound to `fortilink` — which is DOWN.**

> 🔴 **THERE IS NO NTP SERVER ANYWHERE IN ATLAS. TWO OF FOUR DEVICES HAVE NEVER HAD A CLOCK.**

🔴 **And THREE CIS hardening checklists tick it:**

| | Ticks | Reality |
|---|---|---|
| `045` | `[x]` *"NTP configured and synchronized — **confirmed live**"* | 🔴 **`stratum 16, never updated`. Reference time 1899.** |
| `046` | `[x]` *"Time synchronization — **chrony** confirmed working"* | 🔴 **`chronyc: command not found`.** |
| `047` | `[x]` NTP | 🔴 **Bound to a DOWN interface.** |

> 🔴 **`show run` SHOWS THE INTENT. `show ntp status` SHOWS THE TRUTH. NOBODY RAN THE SECOND ONE.**
>
> **This is lesson 1 — *a command completing without an error is not a confirmed change* — applied to a SERVICE instead of a command.** **The config was accepted without error. The service never worked.**
>
> 🔴 **AND IT IS LESSON 6'S SHAPE TOO: `029` DOES NOT RECORD THAT PI01 HAS NO NTP SERVER. THAT *ABSENCE* IS WHAT MADE `023`, `027` AND `045` ALL WRONG AT ONCE.**

**Every log SW01 has ever emitted carries a meaningless timestamp. That is the foundation Book 5 is meant to be built on.** (`CM-0030`)

## 🔴 14. A CONTROL IS ONLY AS GOOD AS ITS BASELINE

**`ADR-0009` accepted the risk of a possibly-compromised Intermediate CA — explicitly — on this:**

> *"**`index.txt` becomes a control, not just a file.** **It is the ONLY way to detect an unauthorised issuance.**"*
> Review trigger: *"**A certificate appears that this CA did not knowingly issue** → **replace the Intermediate as an emergency.**"*

```text
$ sudo cat /etc/ssl/lab-ca/intermediate/index.txt
R  1000  CN=mikrotik.lab       R  1001  CN=mikrotik.lab
V  1002  CN=vault.lab          V  1003  CN=pihole.lab
```

🔴 **FOUR ROWS. THIS CA HAS SIGNED SIX CERTIFICATES THAT DEVICES TRUST.**

**FGT01's — live right now — and Pi-hole's original were signed with `openssl x509 -req -extfile`.** 🔴 **That command produces a valid certificate and WRITES NO ROW.** No serial from `serial`. Nothing in `newcerts/`. **`openssl ca -revoke` on either one FAILS: *the CA has no record of it.***

> 🔴 **RUN `ADR-0009`'s REVIEW TRIGGER TODAY AND IT FIRES — ON A LEGITIMATE CERTIFICATE.**
>
> **The certificate is fine. We know exactly where it came from. 🔴 BUT THE CONTROL CANNOT TELL THE DIFFERENCE — and a detection control that cries wolf on known-good input is one you learn to ignore.**
>
> 🔴 **NOBODY EVER RAN `cat index.txt` AND COUNTED THE ROWS AGAINST THE CERTIFICATES IN SERVICE.** **One command. Four rows. Six certificates.** (`CM-0032`)

## 🔴 15. A DISABLED GROUP IS NOT A DISABLED PORT — AND "UNASSIGNED" IS NOT A STATE

**`CM-0004` disabled FGT01's `internal` hard-switch GROUP and closed. `010` marked FGT01 compliant. `021` said *"internal3-7 — Unassigned."***

```text
FGT01 # get system interface
== [ internal3 ]  status: up      == [ internal4 ]  status: up
== [ internal5 ]  status: up      == [ internal6 ]  status: up
== [ internal7 ]  status: up
```

🔴 **FIVE PHYSICAL PORTS ON THE PERIMETER FIREWALL, UP, IN NO DOCUMENT, FOR THE LIFE OF THE LAB.**

🔴 **AND THEY WERE UP FOR A GOOD REASON.** **They carry `192.168.1.99` — FGT01's ONLY IP-based break-glass path** (`003`, `048`). **`trusthost3 192.168.1.0/24` exists for exactly that.**

> 🔴 **THE PIECES WERE ALL THERE. NOTHING JOINED THEM UP.**
>
> 🔴 **A HARDENING PASS WOULD HAVE SHUT THEM AND DESTROYED FGT01's RECOVERY PATH — correctly, by the letter of the policy, because the REASON was written in the runbook and NEVER in the Build Record.**

**Lesson 9 says *"Available" is not a state. It is a hope.*** 🔴 **NEITHER IS "UNASSIGNED." AND A GROUP'S STATE IS NOT ITS MEMBERS' STATE.**

**`015` already says: *enumerate EVERY interface a device has, not just the ones expected to be in use.*** **The instruction was correct. It was never followed on FGT01.** (`CM-0033`)

## 🔴 16. DO NOT CONCLUDE FROM A LISTING

**Four times in this project, a plausible-looking listing produced a confident, wrong conclusion:**

| The listing | The inference | The device |
|---|---|---|
| MKT01 in WinBox **Neighbors** — IP, MAC, version, uptime | *"You can just connect."* 🔴 **Built an ADR and TWO change records on it.** | 🔴 **`mac-winbox` had been `none` since the build. A config export falsified all of it.** (`CM-0017`) |
| `ss -ulnp \| grep :123` → **`UNCONN 0.0.0.0:123`** | *"Pi01 runs an NTP server."* | 🔴 **`systemd-timesyncd`. A CLIENT.** It listens. It does not answer. |
| `/ip service print` → `ntp`, `discover` | *"Two undocumented listening services."* | 🔴 **Both carry the `D` (DYNAMIC) flag — IN THE OUTPUT BEING READ.** Auto-created by the NTP client and neighbour discovery. |
| `/ip service print` → `D c winbox`, no address restriction | *"An unrestricted WinBox service."* **Open in FOUR documents as *"NOT VERIFIED."*** | 🟢 **`print detail` shows `remote=10.10.0.50` — the operator's OWN SESSION.** **Plain `print` hides `remote=`. Nobody ran `detail`.** |

> 🔴 **EVERY SINGLE TIME, THE DEVICE WAS ALREADY TELLING THE TRUTH AND THE READER WAS READING IT WRONG.**
>
> **`ADR-0019`: *The device beats the document. It also beats the ANALYSIS — including a confident one. Including yours.***
>
> 🔴 **BEING LISTED IS NOT BEING REACHABLE. LISTENING IS NOT SERVING. AND A FLAG YOU DID NOT READ IS STILL IN THE OUTPUT.**

## 🔴 17. A VALIDATION STEP THAT STATES THE WRONG EXPECTED RESULT IS WORSE THAN NO VALIDATION

**`027` contained TWO:**

- Its ARP-ACL validation expected **four** entries. **The device has five.** *(The fifth is Pi01 — the Root CA, the vault, DNS and RADIUS.)*
- Its Final Save expected `hostname CoreSwitch`. **The device has been `SW01` for some time.**

> 🔴 **A WRONG EXPECTED RESULT TAKES A CORRECT DEVICE, CALLS IT A FAILURE, AND INVITES YOU TO "FIX" IT.**
>
> **A missing validation step leaves you uncertain. A WRONG one leaves you confidently wrong — and acting on it.**

## 🔴 18. THE THINGS THAT SAVED THIS PROJECT ALL REFUSED, OUT LOUD

**Lesson 12 said it. The audit proved it again — four refusals in a row, in ten minutes, all correct:**

| What refused | What it prevented |
|---|---|
| `Place-AtlasFiles` — `AMBIGUOUS: no rule matches this filename` | **A new artefact type (`POL-`) silently misfiled.** |
| `Place-AtlasFiles` — 🔴 **it aborts the ENTIRE batch on ONE `[FAIL]`** *(not even the files that resolved)* | 🔴 **A half-applied batch with a commit message describing all of it.** |
| `Copy-Item` — `PathNotFound` | **A command written against an invented path.** |
| `Place-AtlasFiles` — `Refusing to place files onto an uncommitted tree` | *"You will not be able to tell what it changed from what you already had."* |
| `git commit` — `nothing to commit` | 🔴 **A commit message describing three documents that were never written.** |

> 🔴 **AND THE ONE THING THAT FAILED SILENTLY WAS THE EDIT ITSELF** — 16 replacements against a CRLF file, **0 applied, no error.** **See R1.**
>
> 🔴 **AFTER EVERY BATCH: `git status --short` AND COUNT THE FILES. IF IT IS EMPTY, NOTHING LANDED — REGARDLESS OF WHAT ANYTHING PRINTED.**

## 🔴 19. A LAYER-2 MANAGEMENT PROTOCOL BYPASSES EVERY IP CONTROL

**MAC-WinBox and MAC-Telnet (RouterOS `/tool mac-server`) speak over Ethernet, not IP.** None of the router's IP controls apply to them — **not the `/ip service` address lists, not the input-chain firewall deny, not the VLAN gateway.** A host that can put a frame on a `bridgeLocal` port can reach `mac-winbox` **even when every IP path to the router is closed.**

**This cuts both ways (`CM-0017`, `CM-0018`, `ADR-0014`):**

- 🟢 **It is the recovery path.** When an addressing mistake makes MKT01 unreachable by IP, MAC-WinBox on `ether4` is the only way in — precisely because it never depended on IP.
- 🔴 **It is an exposure if left open.** At `allowed-interface-list=all`, any host on any advertised segment could manage the router with nothing at the IP layer to stop it. Atlas scopes it to the `RECOVERY` list (`bridgeLocal` only) for exactly this reason.

> 🔴 **When you reason about who can reach the router, `/ip firewall` and `/ip service` are not the whole story — a Layer-2 management plane is invisible to both.** **Check `/tool mac-server` and `/tool mac-server mac-winbox` explicitly. A clean `/ip service print` says nothing about them.**

---

# Part 1b — The lessons the Book 1 audit added (`ADR-0019`, 2026-07-14)

> **The audit read all 76 documents in Book 1 and then read all four devices.** **It found 8 rebuild-fatal defects.**
>
> 🔴 **Not one of them was carelessness.** **Every single one is a consequence of ONE of the two mechanical habits below.**

## 🔴🔴 13. THE CORRECTION IS APPENDED. THE ERROR IS NOT DELETED.

**Twelve occurrences. Six of them in the change records themselves. Two in the two highest-severity records in Book 1.**

| Document | The correction | The error, still standing | Apart |
|---|---|---|---|
| 🔴 **`026` §12** | `mac-winbox = RECOVERY` | 🔴 **`mac-winbox = none`** | **6 lines** |
| 🔴 **`018` v3.0** | *"BOTH SENTENCES ARE FALSE"* | 🔴 **Both sentences — as the recommendation** | 21 lines |
| `021` | *"Interfaces — Disabled"*, `Verified` | *"left at factory defaults **rather than disabled**"* | ~30 lines |
| 🔴 **`CM-0009`** | A section titled *"Closeout defect — marked `Closed` with two boxes unticked"* | 🔴 **Its own closeout — THREE unticked, `[x] Closed`** | 20 lines |
| 🔴 **`CM-0012`** | *"the cipher-0 'proof' here is **VOID**"* | 🔴 ***"the right kind of proof — the exploit failing"*** | 87 lines |
| 🔴 **`CM-0016`** | Status: **`Closed`** | 🔴 ***"This is a `Draft`. A Draft record is a hypothesis, not a work order."*** | **4 lines** |
| `CM-0013` | `[x] Closed` | `[ ] 033 and 015 reconciled — open` | — |
| `CM-0015` | Every closeout box ticked ✅ | Change log: *"reconciliation **remains open**"* | — |
| `CM-0017` | Status: `✅ Closed` | Foot: *"Status: **`Implemented — reconciliation open`**"* | — |
| `CM-0018` | Status: `Closed` | Head: *"A **`Draft`** record is a hypothesis"* | — |
| 🔴 **`CM-0010`** | Status: `✅ Closed` | 🔴 **`[ ] Mark this record Closed`** | — |
| 🔴 **`CM-0014`** | Status: `✅ CLOSED` | 🔴 ***"It does not return it to Closed"*** — and **NO Closeout section exists** | — |

### 🔴 `026` §12 is the one that shows why it is fatal

**`CM-0018`'s reconciliation instruction, verbatim: *"REPLACE `mac-winbox=none` … with the `RECOVERY` list."***

**The `RECOVERY` block was ADDED at line 41. `mac-winbox=none` was left at line 47.**

🔴 **RouterOS `set` is LAST-WRITE-WINS.** **The section rewritten to BUILD the recovery path DESTROYED it** — and a router rebuilt from it came back with **no way in and no serial console.**

> 🔴 **AND THE BOX GOT TICKED.** **`CM-0018` says: `[x] Guide reconciliation complete — `026` §12 REWRITTEN.`** **The rewrite happened. The rewrite was wrong. Nobody opened the diff.**

### Why it keeps happening — and why the tooling will not save you

**Appending feels SAFE. Deleting requires CERTAINTY.**

🔴 **And the `[chg ]` line-count delta goes UP** — which reads as a plausible edit. **`Tools/README.md` teaches you to catch `496 → 12`.** **This defect goes the other way and looks fine.**

> 🔴 **THE REMEDY IS RULE R1. IT IS AT THE FOOT OF THIS DOCUMENT. IT IS NOT OPTIONAL.**

## 🔴🔴 14. THE CORRECTION REACHES THE DOCUMENT THAT *DESCRIBES* THE WORK AND MISSES THE ONE THAT *DOES* IT

**Four occurrences. Every rebuild-fatal defect not caused by lesson 13 was caused by this.**

| Corrected | 🔴 Missed | The missed one is… |
|---|---|---|
| `006`, `012`, `023`, `016` — *the ACL* | 🔴 **`027`** | …**the guide that BUILDS the ACL** |
| `031`, `029`, `049`, `043` — *the CA backup* | 🔴 **`048`** | …**the runbook that TAKES the backup** |
| `031` — *SAN, bundle, revocation* | 🔴 **`035`, `042`** | …**the runbooks that ISSUE and REISSUE** |
| `013`, `017` — *"Pi-hole is optional"* | 🔴 **`001`, `Build-Order`** | …**the landing pages** |

### 🔴 `035` is the sharpest case in the whole project

**`031` (the CA Build Guide) is read ONCE, when the CA is built.**
**`035` (the Issuance Runbook) is read EVERY TIME a device needs a certificate.**

🔴 **`031` was corrected FIVE TIMES** — across `MC-0001`, `MC-0002`, `CM-0008` and `CM-0010`.
🔴 **`035` WAS NEVER OPENED.** `grep -c subjectAltName` on it returned **0**.

> 🔴 **`035` WAS WRITTEN *DURING* THE SESSION THAT DISCOVERED ALL FOUR PKI DEFECTS IT OMITS.**
>
> **`MC-0001` Phase 5 ticked: *"New Operations Guide written: `035` — captures the correct process end-to-end so this sequence doesn't need re-discovering."*** **It captured none of it.**
>
> **`CM-0007` rediscovered them. `MC-0002` rediscovered them again.**

> 🔴 **THE REMEDY IS RULE R2. AT EVERY CLOSEOUT, ASK: *WHICH DOCUMENT DOES THE WORK?* FIX THAT ONE FIRST.**

## 🔴 15. VERIFYING THE WIRE PROVES NOTHING ABOUT THE FILE YOU REBUILD FROM

**`031` v0.6, `029`, `MC-0002` and the pack manifest ALL record — TRUTHFULLY — that Pi-hole's certificate SAN was *"verified directly on the live-served connection."***

🟢 **ALL FOUR ARE RIGHT.** The wire serves `IP:10.10.0.5`, serial `1003`. Correct.

🔴 **AND `/etc/ssl/lab-ca/issued/pihole/pihole.crt` CARRIES `IP:10.0.0.5` — THE PRE-VLAN ADDRESS — TO THIS DAY.**

🔴 **`032` Step 7 rebuilds `tls.pem` from EXACTLY that file. A rebuild serves the wrong certificate on the lab's DNS server — with no DNS to debug it with.**

> 🔴 **THE VERIFICATION CHECKED THE WIRE. THE REBUILD USES THE FILE. NOBODY CHECKED THE FILE.**
>
> **Lesson 1 says: read the state back off the device.** **This adds: reading the state off the RUNNING SERVICE tells you nothing about the ARTEFACT THE REBUILD USES.** **They are two different objects. CHECK BOTH.**
>
> ```bash
> diff <(openssl s_client -connect <ip>:443 </dev/null 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name") \
>      <(sudo openssl x509 -in /etc/ssl/lab-ca/issued/<dev>/<dev>.crt -noout -text | grep -A1 "Subject Alternative Name")
> # EXPECT NO OUTPUT.
> ```

## 🔴 16. A CONFIG LINE IS NOT A WORKING SERVICE

```
SW01# show run | include ntp
ntp server 10.10.0.5                                    <-- looks perfect

SW01# show ntp status
Clock is unsynchronized, stratum 16, no reference clock
reference time is 00000000.00000000 (Thu Dec 31 1899)
system poll interval is 8, never updated.               <-- 🔴 NEVER. NOT ONCE.
```

**`10.10.0.5` is Pi01. 🔴 Pi01 runs `systemd-timesyncd` — a CLIENT. It serves no time. MKT01's `/system ntp server` is `enabled: no`.**

> 🔴 **THERE IS NO NTP SERVER ANYWHERE IN ATLAS. SW01's clock has NEVER SYNCHRONISED. FGT01's NTP is an empty server entry bound to `fortilink` — an interface that is DOWN.**

🔴 **AND THREE CIS CHECKLISTS TICK IT.** `045`: *"[x] NTP configured and **synchronized** — confirmed live."* `046`: *"[x] **chrony** confirmed working"* — **chrony is not installed.** `047` ticks logging on a device with no clock.

> 🔴 **`show run` shows the INTENT. `show ntp status` shows the TRUTH.** **Nobody ran the second one, and three checklists ticked from the first.**
>
> **This is lesson 1 — *a command completing without an error is not a confirmed change* — applied to a SERVICE instead of a command.** **The config was accepted without error. The service never worked.**

## 🔴 17. A DISABLED GROUP IS NOT A DISABLED PORT

**`CM-0004` disabled the `internal` hard-switch GROUP on FGT01 and closed. `010` marked FGT01 compliant. `021` said *"internal3-7 — Unassigned."***

```
FGT01 # get system interface
== [ internal3 ]  status: up
== [ internal4 ]  status: up
== [ internal5 ]  status: up
== [ internal6 ]  status: up
== [ internal7 ]  status: up
```

🔴 **FIVE PHYSICAL PORTS ON THE PERIMETER FIREWALL, UP, IN NO DOCUMENT, FOR THE LIFE OF THE LAB.**

🔴 **AND THEY ARE UP FOR A GOOD REASON — THEY ARE FGT01's ONLY IP-BASED RECOVERY PATH** (`192.168.1.99`, per `003` and `048`). **Written in the runbook. NEVER in the Build Record or the Build Guide.**

> 🔴 **A HARDENING PASS WOULD HAVE SHUT THEM AND DESTROYED FGT01'S RECOVERY PATH.**
>
> **Lesson 9 says *"Available" is not a state.*** 🔴 **This adds: NEITHER IS "UNASSIGNED." AND A GROUP'S STATE IS NOT ITS MEMBERS' STATE.**
>
> **`015` already says: *"enumerate EVERY interface a device has, not just the ones already expected to be in use."*** **The instruction was correct. It was never followed on FGT01.**

## 🔴 18. A CHECKLIST WITHOUT A NAMED EVIDENCE SOURCE IS A SURVEY, NOT AN AUDIT

**Five false ticks across three CIS checklists. 🔴 NOT ONE WAS A LIE.** Every one was ticked in good faith — **from a config line, a memory, or another document.**

| Ticked | Reality |
|---|---|
| `045`: *"NTP configured and **synchronized** — confirmed live"* | 🔴 `stratum 16, never updated`, ref time **1899** |
| `046`: *"**chrony** confirmed working (Leap status: Normal)"* | 🔴 **`chronyc: command not found`** |
| `045`: *"**SNMP configured and verified**"* | 🔴 **A TICK ON THE WRONG QUESTION.** SNMP *exists*. That says nothing about whether it is **safe** — it is `homelab`, v2c, cleartext, aimed at a host that does not exist. |
| `045`: *"MKT01 … **23 rules**"* | 🔴 **The device has 22.** Carried forward from a document, never counted. |
| `047`: *"Local logging confirmed working"* | 🟡 On a device whose clock has never synced. **The logs work. The timestamps are meaningless.** |

> 🔴 **A TICK REQUIRES A COMMAND AND ITS OUTPUT. IF YOU CANNOT PASTE THE OUTPUT, YOU CANNOT TICK THE BOX.**
>
> **See `POL-0001` (draft) — rule R-A1.**

## 🔴 19. A CONTROL IS ONLY AS GOOD AS ITS BASELINE

**`ADR-0009` accepted the risk of a possibly-compromised Intermediate CA — explicitly on the strength of `index.txt`:**

> *"**`index.txt` becomes a control, not just a file.** **It is the ONLY way to detect an unauthorised issuance.**"*

```
$ sudo cat /etc/ssl/lab-ca/intermediate/index.txt
R  1000  CN=mikrotik.lab
V  1001  CN=mikrotik.lab
V  1002  CN=vault.lab
V  1003  CN=pihole.lab
```

🔴 **FOUR ROWS. THIS CA HAS SIGNED SIX CERTIFICATES THAT DEVICES TRUST.**

**FGT01's — LIVE RIGHT NOW — and Pi-hole's original were signed with `openssl x509 -req -extfile`, which writes NO ROW.** **They cannot be revoked. Not even as bookkeeping.**

> 🔴 **RUN `ADR-0009`'s REVIEW TRIGGER TODAY — *"a certificate appears that this CA did not knowingly issue"* — AND IT FIRES. ON A LEGITIMATE CERTIFICATE.**
>
> 🔴 **A DETECTION CONTROL WITH A WRONG BASELINE DOES NOT FAIL SAFE. IT CRIES WOLF ON KNOWN-GOOD ARTEFACTS UNTIL YOU LEARN TO IGNORE IT.**
>
> **Nobody ever ran `cat index.txt` and counted the rows against the certificates in service.** **One command. Four rows. Six certificates.**

## 🔴 20. A VALIDATION STEP THAT STATES THE WRONG EXPECTED RESULT IS WORSE THAN NO VALIDATION

**`027` contained TWO:**

- *"Expected: `STATIC-HOSTS` has **four** entries"* — 🔴 **the device has FIVE, and the fifth is Pi01.**
- *"Expected: `hostname CoreSwitch`"* — 🔴 **the device is `SW01`, and has been for a long time.**

> 🔴 **IT TAKES A CORRECT DEVICE, CALLS IT A FAILURE, AND INVITES YOU TO "FIX" IT.**
>
> **A validation step that cannot fail is useless** (lesson 4). **A validation step that fails on a CORRECT device is actively dangerous.**

## 🔴 21. THE DEVICE BEATS THE ANALYSIS — INCLUDING YOURS. **ESPECIALLY WHEN YOU ARE READING A LISTING.**

**Four times in this project, a confident conclusion was drawn from a LISTING, and the device disproved it:**

| The inference | The listing | The truth |
|---|---|---|
| *"MKT01 has an open MAC-WinBox hole"* | It appeared in WinBox **Neighbors** | 🔴 **FALSE.** `mac-winbox` was `none` all along. **It produced an ADR and TWO change records.** (`CM-0017`) |
| *"Pi01 runs an NTP server"* | `ss -ulnp \| grep :123` returned a listener | 🔴 **FALSE.** `systemd-timesyncd` — a **CLIENT**. |
| *"MKT01 has two undocumented services"* | `ntp` and `discover` in `/ip service print` | 🔴 **FALSE.** **Both carried the `D` (DYNAMIC) flag — IN THE OUTPUT BEING READ.** |
| *"The dynamic WinBox row is an unrestricted service"* | `/ip service print` showed `D c winbox` | 🔴 **FALSE.** `print detail` shows `remote=10.10.0.50` — **the operator's own session.** **Open in FOUR documents as "NOT VERIFIED" because nobody ran `print detail`.** |

> 🔴 **BEING LISTED IS NOT BEING REACHABLE. BEING PRESENT IS NOT BEING ENABLED. A SOCKET IS NOT A SERVICE.**
>
> **Every single time, the device was ALREADY TELLING THE TRUTH, and the reader was reading it wrong.**
>
> **Charter Rule 13 says the device beats the document.** 🔴 **It also beats the ANALYSIS — including a confident one. Including yours.**

## 🔴 22. AN EDIT TOOL THAT FAILS SILENTLY WILL COST YOU THE WHOLE BATCH

**During the audit's own fixes:**

| What happened | Caught by |
|---|---|
| 🔴 **A 16-edit pass applied ZERO of them.** `497 → 497` lines. **The file had CRLF endings; the patterns used `\n`.** **Python's `.replace()` is SILENT on a miss.** | 🔴 **ONLY the count-check.** **Every "is the new string present?" test would have been meaningless — and a commit message describing 16 edits would have shipped an unchanged file.** |
| 🔴 **A batch was built missing 3 of 6 files** (shell brace expansion). | The file count |
| 🔴 **The dangerous string SURVIVED in a quoted code fence** in the "this is what was wrong" note — **a live `set` command, pasteable.** | The count-check |

🔴 **`.gitattributes` says `*.md text eol=lf`. Several files in the working tree had CRLF anyway** — `025` had **312** pairs.

> 🔴 **NORMALISE TO LF BEFORE EDITING. AND ALWAYS CHECK THE LINE COUNT CHANGED.**
>
> **`To-The-Next-Session` §7: *"A `git commit` will happily record a message describing work that did not occur."*** **It nearly did. Three times.**

## 🔴 23. THE COUNT-CHECK HAS A PRECONDITION NOBODY STATES

🔴 **A count-check only works if the dangerous string appears ONLY where it is dangerous.**

**If your own *"this was wrong"* commentary quotes the bad string verbatim, `(Select-String).Count` returns `1` FOREVER.** **Someone has to go look every single time.**

> 🔴 **AND THAT IS EXACTLY HOW A CHECK GETS IGNORED.**
>
> **PARAPHRASE IN COMMENTARY. KEEP THE EXACT STRING IN ONE PLACE: THE THING YOU ARE DELETING.**

## 🔴 25. YOUR CHECK ONLY FINDS WHAT IT LOOKS FOR. **CHECK THE BYTES.**

**The auditor shipped a corrupted Charter — into the document that defines R1. And a duplicate Change Log into `016` AND `042`.**

```python
# Written inside a Python string, to be embedded in a markdown code block:
"Select-String -Path .\026-MKT01-Build-Guide.md"

# 🔴 Python read `\026` as an OCTAL ESCAPE and produced chr(0o26) = 0x16 (SYN).
# A literal control character went into the Charter. It renders as `^V` in git diff.
# It was COMMITTED AND PUSHED.
```

🔴 **A SILENT TRANSFORMATION THAT PRODUCED PLAUSIBLE-LOOKING OUTPUT.**

**And the coherence check PASSED** — because it counted **headings** and **code fences**. **Not bytes.**

| Checked ✅ | 🔴 Did NOT check |
|---|---|
| duplicate headings | 🔴 **control characters** |
| balanced code fences | 🔴 **duplicate TABLE ROWS** *(the Charter had two amendment-history entries)* |
| the new string is present | 🔴 **CRLF** |

> 🔴 **A CHECK THAT PASSES TELLS YOU NOTHING ABOUT WHAT IT DID NOT LOOK AT.**
>
> **Lesson 4 says *a test that cannot fail proves nothing.*** **This is its sibling: A TEST THAT ASKS THE WRONG QUESTION PASSES CONFIDENTLY AND PROVES NOTHING EITHER.**
>
> 🔴 **It was found by `git diff` — by a HUMAN READING THE ACTUAL BYTES.** **Not by any check the auditor wrote.**

### 🔴 And the duplicate Change Log is THE PATTERN — occurrence FOURTEEN

**A Change Log was APPENDED to `016` and to `042`. Both already had one.** **The old one was not deleted.**

🔴 **THAT IS LESSON 13, COMMITTED BY THE PERSON WRITING LESSON 13.**

### Add to EVERY edit sweep

```python
b = open(path, 'rb').read()
ctrl = [x for x in b if x < 0x09 or 0x10 <= x <= 0x1f or x in (0x0b, 0x0c, 0x0e, 0x0f)]
assert not ctrl,                    f"🔴 {len(ctrl)} control characters"
assert b.count(b'\r') == 0,         "🔴 CRLF (.gitattributes: *.md text eol=lf)"

L = b.decode().split('\n')
d = 0
for l in L:
    if l.strip().startswith('```'): d = 1 - d
assert d == 0,                      "🔴 unclosed code fence"

import re, collections
h = [l for l in L if re.match(r'^#{2,3} ', l)]
dup = [k for k, v in collections.Counter(h).items() if v > 1]
assert not dup,                     f"🔴 duplicate headings: {dup}"
```

> 🔴 **AND THE HARDEST LESSON IN THIS DOCUMENT:**
>
> **This audit spent 76 documents establishing that a correction can be appended without deleting the error, that a tick can be made from a config line, and that a clean command is not a correct artefact.**
>
> 🔴 **THEN IT COMMITTED ALL THREE — WHILE WRITING THE RULES AGAINST THEM.**
>
> **`CM-0020`: *the lesson does not stop applying just because you have learned it.***

## 🟢 24. AND THE THING THAT KEPT WORKING — say it out loud

**Six refusals during the audit's own fixes. Every one correct. Every one LOUD.**

| Refused | Would have happened |
|---|---|
| `AMBIGUOUS: no rule matches 'POL-0001'` | A new artefact type placed by guess |
| `Refusing to place files onto an uncommitted tree` | **You could not tell the tool's changes from your own** |
| `[FAIL]` aborts the ENTIRE batch — **not just the failing file** | A half-applied batch with a commit message describing all of it |
| `[same]` | Correctly skipped an identical file |
| `git commit: nothing to commit` | 🔴 **A commit describing three files, with zero files** |
| **The count-check**, three separate times | 🔴 **See lesson 22** |

> 🔴 **LESSON 12, RESTATED AND PROVEN AGAIN:**
>
> **EVERYTHING THAT HURT THIS PROJECT FAILED SILENTLY AND LOOKED LIKE SUCCESS.**
> **EVERYTHING THAT SAVED IT REFUSED, OUT LOUD.**


---

# Part 2 — Device-specific

## FortiGate

- 🔴 **Use `get`, not `show`.** `show` displays only non-default values — an unset or default value looks like "nothing to see." **Empty output is not proof.**
- **FortiOS `grep` is not Linux `grep`** — no `-E`, no alternation. It **does** have `-f`, which prints the containing config block.
- **A missing GUI menu is usually Feature Visibility, not licensing.** Certificate management is never behind a paywall.
- **FGT01 runs multi-VDOM** (`root`). Every interface command needs an explicit `set vdom "root"` — omitting it **caused a lockout** during the original build.
- Match firewall policy to the **actual** ingress interface (`internal1`). A narrow `Lab-Network` object can **silently exclude VLANs.**
- Verify interface MACs with `diagnose hardware deviceinfo nic <interface>`.
- Static-IP management interfaces need **DAI allow-list entries on SW01.**
- 🔴 **FortiOS `grep` has NO `-E` and no alternation. `grep -A5` TRUNCATES** (`set status` sits below `set distance`). **`grep -f "<string>"` prints the CONTAINING CONFIG BLOCK — use it.**
- 🔴 **`get system interface physical` answers the WRONG QUESTION.** It reports *link and IP* state, not *administrative* status. **A disabled interface and an interface with no address look IDENTICAL.** **`CM-0004` ran three commands that each printed plausible output before one answered the question.**
- 🔴 **`Lab-Network` and `Transit-Link` DO NOT EXIST.** `get firewall address` returns FortiOS factory objects only. **`021`'s `Verified` tables were copied from `025` — the Build GUIDE — not read from the device.**
- 🔴 **`internal3`–`internal7` are UP, deliberately** — FGT01's only IP-based recovery path. **See lesson 15. DO NOT DISABLE THEM.**
- 🔴 **The UTM signature databases are 8–11 years stale** (Virus-DB 2018, IPS-DB 2015). **No profiles are applied — so nothing pretends. That is the GOOD branch of Roadmap Critical Risk #2.**
- **Importing an intermediate as a CA Certificate does not attach it to the served chain.** Bundle leaf + chain and import as a **Local Certificate**. Verify: `openssl s_client ... | grep -c "BEGIN CERTIFICATE"` must return **3**.

## MikroTik

- 🔴 **`hw=no` on `ether3` is a functional requirement, not a tuning choice.** On the **RB1100AHx4**, the RTL8367 chip intercepts frames in hardware before RouterOS VLAN sub-interfaces see them. **Verify after every reboot and firmware update.**
- **Keep `ingress-filtering=no`** on the `bridge-trunk` — it is part of the documented design, not an oversight.
- 🔴 **RouterOS defaults to ACCEPT** for a chain with no matching rule. **The input-chain default deny is load-bearing** — and was missing from the build guide.
- 🔴 **`/user aaa` has its own `use-radius` setting.** A configured RADIUS server does **not** mean RADIUS is consulted. **And it may not persist on the first `set`.**
- **`/radius add` does not warn about duplicates.** Check before adding. Secrets cannot be read back — only set — so update **every** entry for a server rather than guessing which is current.
- **RouterOS renames certificates on import.** `device-bundle.crt` becomes `device-bundle.crt_0`. Read `/certificate print detail` before binding.
- **VLAN 70 must stay outside the `VLANs` interface list.** That exclusion **is** the isolation — an absence, not a rule. Adding it silently removes the isolation.
- Insert new allow rules **before the final catch-all by comment**, not by hard-coded index.
- **`bridgeLocal` preserved access during routing failures.** It is the recovery path. **Do not retire it early.**
- 🔴 **RouterOS prints only the flags in use.** No `X` in the legend means **nothing on the device is disabled.**
- 🔴 **`/ip service print` HIDES `local=` and `remote=`. Only `print detail` shows them.** **A `D c` row is a CONNECTION — your own live session.** **This sat "unexplained / NOT VERIFIED" in FOUR documents because nobody typed `detail`.**
- 🔴 **MAC-WinBox is NOT an `/ip service`. It CANNOT appear in `/ip service print`.** **Its only control is `/tool mac-server mac-winbox allowed-interface-list` — and it is Layer 2, so the IP firewall and every `address=` restriction on this router NEVER EVALUATE IT.**
- 🔴 **`/system resource` reports `128 MiB` — that is the internal NAND.** **`/disk print` shows the real storage: a MOUNTED 64 GB FORESEE SSD on `sata1-part1`.** **Do not "correct" a Build Record from `/system resource`.**

## Cisco

- 🔴 **`DHCP Permits: 0` — there is no DAI snooping fallback.** A host missing from `STATIC-HOSTS` is **dropped, full stop.** All five entries are required.
- **`Gi1/0/4` must use native VLAN 10** — PVE01's `vmbr0` sends **untagged** frames. Native 999 put host management in the catch-all and PVE01 was unreachable.
- **The two trunks have different native VLANs on purpose:** `Gi1/0/1` (MKT01) is 999; `Gi1/0/4` (PVE01) is 10.
- WS-C2960X SFP ports are `Gi1/0/49-52`. Console is **9600 baud**.
- Modern SSH clients may need **legacy algorithms explicitly enabled** for this IOS release.
- SPAN commands belong in **global** configuration mode.
- 🔴 **The hostname IS `SW01`. Device-verified 2026-07-14** (`show run | include hostname`). **SEVEN documents said the live hostname was `CoreSwitch` and that a rename was *"still open."* IT ALREADY HAPPENED** — and `027` built `CoreSwitch` as the TARGET, **which is why nothing ever flagged it as a deviation to close.**
- 🔴 **IOS is `15.2(2)E6`.** Device-verified. **`027` said `15.2(7)E`.**
- 🔴 **`show ntp status` → `Clock is unsynchronized, stratum 16, never updated`.** **The clock has NEVER synced.** See lesson 13.
- 🔴 **`Gi1/0/4` is negotiating at 100 Mbps.** **Four documents say *"confirmed 1 Gbps post-reboot — monitor, cable swap if it recurs."*** **IT RECURRED.** The hypervisor uplink is at a tenth of rated speed.
- 🔴 **`snmp-server community homelab RO`, v2c, cleartext — LIVE.** Trap host `10.40.0.52` **does not exist.** **The Charter names this string and orders it rotated.**

## Proxmox / PVE01

- PVE01 management is **`10.10.0.10`**, not `10.10.0.254`.
- 🔴 **`bridge-vlan-aware yes` is required** — without it, per-VM VLAN tags in the GUI **have no effect**, and nothing warns you.
- 🔴 **The iDRAC is on the SHARED LOM**, not a dedicated port. Sequential MACs (`…a2`, `…a3`, `…a4`) prove one card. **It dies with SW01 — step one of any teardown. It is NOT out-of-band.** (`CM-0011`, `050`)
- 🔴 **`sudo` is not installed.** Root-only login. **Every Proxmox guide prefixing commands with `sudo` fails as written.**
- 🔴 **The CMOS battery is dead** (`CM-0012`). BIOS and BMC settings survive **only on continuous power.**
- 🔴 **PVE01 has 16 LOGICAL CPUs and 62 GiB usable — NOT 32 and 32 GB.** **`024` — the Build Record, marked `Verified` — says 32/32. FIVE documents contradict it, including `Atlas-Workflow`, which uses these exact numbers as its WORKED EXAMPLE of a false `Verified`.** **The correction was made in the document ABOUT the defect and never in the document CONTAINING it.**
- The no-subscription GUI patch is **overwritten by `proxmox-widget-toolkit` updates.** Re-apply after `apt upgrade`.
- Verify physical link negotiation before troubleshooting higher layers.

## Windows / workstation

- 🔴 **Certificate import: no UAC prompt means you picked *Current User*, not *Local Machine*.** That is the tell.
- 🔴 **The thumbprint security warning must be ACCEPTED, not dismissed.** Clicking **No** silently cancels the import — **and the wizard may still report success.**
- **Verify in `certmgr.msc` by finding the certificate in the target store.** Do not trust the wizard.
- **Chrome's TLS session cache outlives closing the window.** Use Incognito, then kill every browser process.
- 🔴 **A `.ps1` from `Downloads` carries Mark of the Web.** The *"not digitally signed"* error is **not** a code-signing problem — run `Unblock-File`. **Do not change the execution policy.**



---

---
---

# 🔴 THE TWO RULES

> **Twenty-four lessons above. Twelve of them are symptoms of ONE habit. Four are symptoms of the OTHER.**
>
> 🔴 **EVERY REBUILD-FATAL DEFECT IN BOOK 1 — ALL EIGHT — WAS CAUSED BY ONE OF THESE TWO.**
>
> **Both have a one-line fix. Neither is optional.**

---

## 🔴 R1 — VERIFY A CORRECTION BY **COUNTING THE OLD STRING**. NOT BY CONFIRMING THE NEW ONE IS PRESENT.

```powershell
# 🔴 WRONG. This is what was done, TWELVE TIMES.
Select-String -Path .\026-MKT01-Build-Guide.md -Pattern "mac-winbox.*RECOVERY"
#   -> HIT. The fix landed. Looks correct. Ship it.
#   -> And `mac-winbox=none` is sitting SIX LINES BELOW IT, and on a device the LAST ONE WINS.

# 🟢 RIGHT. The old string must be GONE.
(Select-String -Path .\026-MKT01-Build-Guide.md -Pattern "mac-winbox set allowed-interface-list=none").Count
#   -> MUST RETURN 0.
```

> 🔴 **A HIT ON THE FIX PROVES THE FIX LANDED.**
> 🔴 **IT PROVES NOTHING ABOUT WHETHER THE THING IT REPLACED IS STILL SIX LINES BELOW IT.**

### Why this rule exists, and it is not theoretical

**`CM-0018` instructed: *"REPLACE `mac-winbox=none` with the `RECOVERY` list."***
**The edit APPENDED.** **The line count went UP — a plausible-looking delta.** **The box was ticked.** **Nobody opened the diff.**

🔴 **A router rebuilt from that guide came back with NO RECOVERY PATH — on the one device in Atlas with NO SERIAL CONSOLE.**

**And R1 caught it. It also caught, in this audit alone:**

- 🔴 **A 16-edit pass that applied ZERO of them** (CRLF; the edit tool failed **silently**)
- 🔴 **The dangerous string surviving in a quoted code fence** — a live `set` command, pasteable *(this is exactly how `CM-0017`'s false premise was created: a guide quoted as illustration, pasted into a router)*
- 🔴 **A validation step stating the WRONG expected result** (`Expected: hostname CoreSwitch`)
- 🔴 **A batch missing 3 of 6 files**

### R1's precondition — **state it or the rule rots**

🔴 **The dangerous string must appear ONLY where it is dangerous.**

**If your own *"this was wrong"* commentary quotes it verbatim, the count returns `1` forever, someone has to go look every time — and that is how a check gets ignored.**

**PARAPHRASE IN COMMENTARY. KEEP THE EXACT STRING IN ONE PLACE: THE THING YOU ARE DELETING.**

### And the other half — the tools lie

- 🔴 **`.replace()` / `sed` / `str_replace` are SILENT on a miss.** **No error. No warning. Nothing happens.**
- 🔴 **`.gitattributes` says `*.md text eol=lf` — and files in the tree have CRLF anyway.** **A pattern built with `\n` matches ZERO occurrences in a CRLF file.** *(`025` had 312 pairs.)*
- 🔴 **`git commit` will happily record a message describing work that did not occur.**

> 🔴 **ALWAYS CHECK THE LINE COUNT CHANGED. ALWAYS RUN `git status --short` AND COUNT THE FILES BEFORE YOU COMMIT.**

---

## 🔴 R2 — AT EVERY CLOSEOUT, ASK: **WHICH DOCUMENT DOES THE WORK?** FIX THAT ONE FIRST.

> **Not the one that DESCRIBES it. Not the one that RECORDS it.**
> 🔴 **THE ONE SOMEONE WILL EXECUTE.**

| Corrected | 🔴 Missed | The missed one… |
|---|---|---|
| `006`, `012`, `023`, `016` | 🔴 **`027`** | **BUILDS the ACL** |
| `031`, `029`, `049`, `043` | 🔴 **`048`** | **TAKES the backup** |
| `031` | 🔴 **`035`, `042`** | **ISSUE and REISSUE the certificates** |
| `013`, `017` | 🔴 **`001`, `Build-Order`** | **are the LANDING PAGES** |

### Why it happens

**A Build Record is updated after every incident — because that is where the incident gets written down.**
🔴 **A Build Guide is read ONCE, in the worst hour of the project, when the device is gone.**

> 🔴 **IT IS THE LAST DOCUMENT TO GET FIXED AND THE FIRST ONE THAT MATTERS.**

**`031` was corrected FIVE times. `035` — the runbook used EVERY time a device needs a certificate — was NEVER OPENED.** **And `035` was WRITTEN during the session that found the four defects it omits.**

### R2's corollary — **the wire and the file are two different objects**

🔴 **Four documents recorded — TRUTHFULLY — that Pi-hole's certificate was *"verified on the live-served connection."* ALL FOUR ARE RIGHT.**

🔴 **AND ALL FOUR VERIFIED THE ONE ARTEFACT A REBUILD DOES NOT USE.**

```bash
# The wire is what you CHECK. The file is what you REBUILD FROM. Compare them.
diff <(openssl s_client -connect <ip>:443 </dev/null 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name") \
     <(sudo openssl x509 -in /etc/ssl/lab-ca/issued/<dev>/<dev>.crt -noout -text | grep -A1 "Subject Alternative Name")
# EXPECT NO OUTPUT.
```

---

# 🔴 And the one that governs both

> ## THE DEVICE BEATS THE DOCUMENT.
> ## IT ALSO BEATS THE ANALYSIS — INCLUDING A CONFIDENT ONE.
> ## **INCLUDING YOURS.**

**Four times, a confident conclusion was drawn from a LISTING, and the device disproved it** (lesson 21). **One of them produced an ADR and two change records for a security hole that did not exist.**

🔴 **BEING LISTED IS NOT BEING REACHABLE. BEING PRESENT IS NOT BEING ENABLED. A SOCKET IS NOT A SERVICE. A CONFIG LINE IS NOT A WORKING SERVICE.**

**Every single time, the device was already telling the truth.**

---

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Device tips per platform. |
| **2.0** | 🔴 **Rewritten 2026-07-13.** v1.0 was a device-tips list with **no process lessons** — and the device tips were never what cost the time. Added **Part 1: the twelve failures that recur.** |
| **3.0** | 🔴 **2026-07-14 — rebuilt by the Book 1 audit (`ADR-0019`): 76 of 76 documents read, AND a live device pass on MKT01, SW01, Pi01 and FGT01.** <br><br>**Added Part 1b — lessons 13–24**, and 🔴 **THE TWO RULES at the foot of this document.** <br><br>🔴 **THE CENTRAL FINDING: Book 1 was not wrong because anyone was careless. All EIGHT rebuild-fatal defects were caused by ONE of two mechanical habits — `R1` (the correction is APPENDED and the error is not DELETED — **twelve occurrences**, six of them inside the change records, two inside the two highest-severity records in the book) and `R2` (the correction reaches the document that DESCRIBES the work and misses the one that DOES it — **four occurrences**).** <br><br>**Also added, all device-verified:** the wire-vs-file rule (`CM-0032`) · *a config line is not a working service* — **there is NO NTP server anywhere in Atlas and three CIS checklists tick it** (`CM-0030`) · *a disabled group is not a disabled port* — **five live ports on the perimeter firewall, and they are its ONLY recovery path** (`CM-0033`) · *a checklist without a named evidence source is a survey* — **five false ticks, not one of them a lie** (`POL-0001`) · *a control is only as good as its baseline* — **`index.txt` has four rows and the CA signed six certificates** (`CM-0032`) · *a validation step that states the WRONG expected result is worse than no validation* · **the device beats the ANALYSIS — four confident conclusions drawn from a listing, all four false** · **and the tools lie silently: CRLF, `.replace()` on a miss, and `git commit` recording work that never happened.** <br><br>🟢 **And lesson 24 — proven again, six times, during the audit's own fixes: EVERYTHING THAT HURT THIS PROJECT FAILED SILENTLY AND LOOKED LIKE SUCCESS. EVERYTHING THAT SAVED IT REFUSED, OUT LOUD.** |
| **3.1** | 🟢 **2026-07-15 — `CM-0017` reconciliation.** Added **lesson 19: a Layer-2 management protocol bypasses every IP control** — MAC-WinBox/MAC-Telnet answer over Ethernet, so `/ip service` address lists and the input-chain deny do not apply to them. Both the lab's only recovery path (`ether4`, `CM-0018`) and, if left at `all`, an exposure. This lesson was the one item `CM-0017`'s guide reconciliation had left outstanding. |
