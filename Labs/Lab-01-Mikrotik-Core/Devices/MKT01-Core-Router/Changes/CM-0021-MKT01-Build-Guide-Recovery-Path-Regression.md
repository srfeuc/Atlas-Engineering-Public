# CM-0021 — `026` §12 Rebuilds a Router With No Recovery Path, and No Reverse-Proxy Disable

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | ✅ **Implemented 2026-07-14 — `026` edited and verified by count-check. Reconciliation open (`016`).** |
| Risk | 🔴 **HIGH — rebuild-fatal.** *(No live device change. See below.)* |
| Affected systems | **Documentation only.** `026-MKT01-Build-Guide.md`. **MKT01 itself is CORRECT and is not touched by this record.** |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — `026` §12 read as committed, **AND every claim re-tested against the live MKT01 on 2026-07-14 before a single line was edited** |
| Related | `CM-0006`, `CM-0017`, `CM-0018`, `ADR-0014`, `ADR-0016`, `ADR-0019`, `051-Book-1-Audit-Report.md` (finding C1) |

> 🔴 **The device is fine. The guide is not.**
>
> `CM-0018` scoped MAC-WinBox to `RECOVERY` **on the live router and tested it** — MAC-connect from `ether4` connected. **That work is real and is not in question.**
>
> **This record fixes the Build Guide, which did not receive that change correctly** — and which would therefore rebuild the exact router `CM-0017` and `CM-0018` existed to fix.

---

## 🔴 Finding 1 — §12 enables the recovery path, then disables it four lines later

**`026` §12 carries the header:** *"✅ **REWRITTEN 2026-07-14 (`CM-0018` / `ADR-0014` / `ADR-0016`)**"*.

**Its code block, in execution order:**

| Line | Command | Effect |
|---|---|---|
| 33 | `/tool mac-server set allowed-interface-list=none` | MAC-**Telnet** off — ✅ correct, keep |
| 36 | `/interface list add name=RECOVERY …` | ✅ |
| 37 | `/interface list member add list=RECOVERY interface=bridgeLocal` | ✅ |
| **41** | `/tool mac-server mac-winbox set allowed-interface-list=RECOVERY` | ✅ **Recovery path ON** |
| 46 | `/ip neighbor discovery-settings set discover-interface-list=static` | Known open disclosure — **deferred by `ADR-0016`**, correct as written |
| 🔴 **47** | 🔴 **`/tool mac-server mac-winbox set allowed-interface-list=none`** | 🔴🔴 **RECOVERY PATH BACK OFF** |
| 48 | `/tool bandwidth-server set enabled=no` | ✅ |

**RouterOS `set` is last-write-wins. Line 47 silently overwrites line 41.**

> 🔴 **A router rebuilt from the current, committed guide comes back with `mac-winbox=none` — no recovery path, and MKT01 has no serial console.**

### 🔴 The proximate cause is in `CM-0018`, in writing

**`CM-0018`'s reconciliation instruction, verbatim:**

> 🔴 **`026` §12 — MUST REWRITE at closeout** — ***"Replace `mac-winbox=none` and `discovery=static` with the `RECOVERY` list, and state WHY. Keep `mac-server=none`."***

**The instruction said REPLACE. The execution APPENDED.** The `RECOVERY` block was added; the old line was never deleted. **The box was then ticked and `CM-0018` closed.**

**The `[chg ]` line-count delta went UP** — which reads as a plausible edit. **A diff nobody opened.**

### And nothing in the guide would catch it

| Control | State |
|---|---|
| §12's own `Verify:` block | 🔴 **`/ip service print` only.** MAC-WinBox is **not** an `/ip service` object — **it cannot appear in that output.** |
| Main **Validation** section | 🔴 **No `mac-server` command at all.** |
| **Completion Checklist** | 🔴 **No MAC-WinBox line.** Only *"Services hardened — telnet/ftp/www/api/api-ssl disabled, SSH on 2222."* |
| *"Post-build: PROVE the recovery path"* | 🟡 **Would catch it — but it sits BELOW the Change Log**, after the document appears to have ended. |

**The correct verify commands exist in `026` — stranded inside a warning blockquote in §3, formatted as prose, where they will never be run.**

---

## 🔴 Finding 2 — `026` never disables `reverse-proxy`. `CM-0006` had no guide reconciliation.

**`CM-0006` found `reverse-proxy` on MKT01 enabled with `address=""` (no source restriction) and `CERTIFICATE: none`.** It was disabled and verified on the device (`/ip service print`, `X` flag).

**`CM-0006` predates Charter Rule 15. It has no Build Guide row.**

🔴 **`026` §12 disables `telnet`, `ftp`, `www`, `api`, `api-ssl` — and not `reverse-proxy`.**

**A router rebuilt from `026` comes back with `reverse-proxy` enabled and unrestricted on port 443** — precisely the state `CM-0006` was raised to remove. **`016` lesson 8: a guide that does not mention a thing will recreate the thing.**

---

## 🟡 Finding 3 — `026` Step 2 rebuilds the wrong identity

```routeros
/system identity set name=MikroTik
```

With the note: *"Target identity is `MKT01`. A Change Record is required to rename the live device."*

**`022` confirms the live device is `MKT01` (`[SethAdmin@MKT01]`) and records the deviation as CLOSED.** The guide rebuilds `MikroTik` and re-opens a closed deviation.

---

## What is NOT changing, and why

| Item | Decision | Authority |
|---|---|---|
| `discover-interface-list=static` | 🟡 **STAYS.** The disclosure leak remains open. | **`ADR-0016` deferred it deliberately.** Book 10's first job. **Do not "fix" it here** — that would execute a deferred decision without a decision. |
| `ether5`–`ether13` enabled | 🟡 **STAYS.** All ten `bridgeLocal` ports remain enabled. | **`ADR-0016` deferred it deliberately**, and recorded the accepted attack-surface increase explicitly. |
| MAC-Telnet (`/tool mac-server`) | ✅ **STAYS `none`.** | `ADR-0014`. Operator: no Telnet. |

> 🔴 **`CM-0018`'s reconciliation instruction also demanded the `ether5`–`ether13` disable and the discovery scoping. `ADR-0016` — accepted AFTER `CM-0018` was written — deferred both.**
>
> **The Change Record is the authority on the device. The ADR is the authority on the decision.** Following `CM-0018`'s instruction literally today would execute two decisions that were subsequently deferred.

---

## Implementation — documentation only

### Edit 1 — `026` §12: DELETE the stale line

**Find, in the §12 code block:**

```routeros
/ip neighbor discovery-settings set discover-interface-list=static
/tool mac-server mac-winbox set allowed-interface-list=none
/tool bandwidth-server set enabled=no
```

**Replace with:**

```routeros
/ip neighbor discovery-settings set discover-interface-list=static
/tool bandwidth-server set enabled=no
```

🔴 **One line deleted. That is the entire fix for Finding 1.**

### Edit 2 — `026` §12: add the `reverse-proxy` disable

**Find:**

```routeros
/ip service set api-ssl disabled=yes
```

**Add immediately after:**

```routeros
# reverse-proxy: found ENABLED, address="" (no restriction), certificate=none. CM-0006.
/ip service set reverse-proxy disabled=yes
```

### Edit 3 — `026` §12: replace the Verify block

**`/ip service print` cannot show MAC-WinBox. Replace §12's `Verify:` block with:**

```routeros
/ip service print
# Expect: telnet, ftp, www, api, api-ssl, reverse-proxy all X (disabled).
#         SSH 2222; winbox + www-ssl restricted to 10.0.0.0/24, 10.10.0.0/24.

# --- MAC-WinBox is NOT an /ip service. It will not appear above. Check it separately. ---
/tool mac-server mac-winbox print
# Expect: allowed-interface-list: RECOVERY      <-- NOT none. If none, the recovery path is GONE.

/tool mac-server print
# Expect: allowed-interface-list: none          <-- MAC-Telnet stays off.

/interface list member print where list=RECOVERY
# Expect: exactly one member — bridgeLocal.
```

### Edit 4 — `026` Validation section: add the same three commands

Append to the main `## Validation` code block:

```routeros
/tool mac-server mac-winbox print
/tool mac-server print
/interface list member print where list=RECOVERY
```

And to its Expected list:

- `mac-winbox allowed-interface-list: RECOVERY` — **not `none`**
- `mac-server allowed-interface-list: none`
- `RECOVERY` list has exactly one member: `bridgeLocal`

### Edit 5 — `026` Completion Checklist: add the missing lines

```markdown
- [ ] 🔴 **`mac-winbox allowed-interface-list = RECOVERY`** — verified with `/tool mac-server mac-winbox print`. **Not `none`.**
- [ ] `mac-server` (MAC-Telnet) = `none` — verified
- [ ] `reverse-proxy` disabled (`CM-0006`)
- [ ] 🔴 **MAC-connect TESTED from `ether4` — it CONNECTED.** Reading the config string is not the test.
```

### Edit 6 — `026` Step 2: correct the identity

```routeros
/system identity set name=MKT01
```

Delete the note about a rename change record. **The device is already `MKT01`.**

### Edit 7 — `026`: move *"Post-build: PROVE the recovery path"* ABOVE the Change Log

**It is the only control that catches this class of defect and it currently sits below the document's apparent end.**

---

## Validation

**This record changes no device.** Validation is that the guide now produces the router the device already is.

```powershell
# The stale line must be GONE — expect ZERO hits:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Build-Guides\026-MKT01-Build-Guide.md `
              -Pattern "mac-winbox set allowed-interface-list=none"

# The correct line must be present — expect ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Build-Guides\026-MKT01-Build-Guide.md `
              -Pattern "mac-winbox set allowed-interface-list=RECOVERY"

# reverse-proxy — expect ONE hit:
Select-String -Path .\Labs/Lab-01-Mikrotik-Core\Build-Guides\026-MKT01-Build-Guide.md `
              -Pattern "reverse-proxy disabled=yes"
```

**Then, on the LIVE device — confirm the router still has what `CM-0018` built** *(this is independent of the guide; run it anyway)*:

```routeros
/tool mac-server mac-winbox print     # expect: RECOVERY
/ip service print                     # expect: reverse-proxy shows X
```

## Rollback

`git checkout -- Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Guide.md`, or restore from `99-Archive\replaced\<timestamp>\`.

**There is no device rollback because there is no device change.**

---

## Guide Reconciliation — required, not conditional

> **Does any guide now contain an instruction that would recreate this problem, or a claim that this change disproves?**

| Document | Outcome | Detail |
|---|---|---|
| 🔴 **`026-MKT01-Build-Guide.md`** | **Updated** | **This record is that reconciliation.** Seven edits above. |
| **`022-MKT01-Build-Record.md`** | **Reviewed — no change needed** | Already records `mac-winbox: RECOVERY`, `mac-server: none`, `discovery: static (OPEN)`, `reverse-proxy: Disabled via CM-0006`. 🟢 **`022` was right the whole time. The Build Record was correct and the Build Guide was wrong — exactly the inversion `Atlas-Workflow` v2.0 exists to prevent.** *(Version/date fields need a bump — folded into the audit's reconciliation batch.)* |
| **`003-Physical-Topology.md`** | **Reviewed — no change needed** | Bootstrap table already correct: MAC-connect via `ether4`, 15-second drop, no serial console. |
| **`048-Teardown-and-Rebuild-Runbook.md`** | 🔴 **NOT YET REVIEWED — blocking** | `CM-0017` and `CM-0018` both list `048` as reconciled. **`048` has not been read by this audit** (Chunk 4). **This record does not close until it has been.** |
| **`016-Network-Lessons-Learned.md`** | 🔴 **MUST UPDATE** | **`CM-0018` required a new lesson — *"MAC-WinBox bypasses every IP control on the router"* — and it is NOT in `016`.** `CM-0018` closed with that row unfulfilled. **Add it, plus this record's own lesson (below).** |
| **`041-MKT01-Troubleshooting-Guide.md`** | 🔴 **NOT YET REVIEWED** | Chunk 4. |

---

## The lesson

> 🔴 **A rewrite that ADDS the correct line without DELETING the wrong one produces a document that contains both — and on a device, the last one wins.**

`CM-0018` said **"replace."** The edit **appended.** The line count went **up**, which looks like a plausible change. **The closeout box was ticked against a diff nobody opened.**

> **`016` lesson 12: every safety net that worked was one that failed loudly.** `Place-AtlasFiles.ps1` reports a line-count delta precisely so a bad edit is visible — **and `496 → 494` is the shape it teaches you to look for.** **This edit went the other way, and looked fine.**

**New lesson for `016`:**

> **Verify a guide edit by grepping for the string that must be GONE, not only for the string that must be present.** A `Select-String` hit on the new text proves the addition landed. **It proves nothing about whether the thing it was meant to replace is still sitting four lines below it.**

---

---

# 🟢 DEVICE VERIFICATION — MKT01, 2026-07-14, BEFORE any edit

> 🔴 **`CM-0011` degraded a BMC because a record built from a stale baseline was executed without reading the device.** **`CM-0018`: *"a Build Guide must not describe a device that does not exist."*** **So the device was read first. Every command was read-only.**

## ✅ The live router is CORRECT. Only the guide is wrong.

```
/tool mac-server mac-winbox print          -> allowed-interface-list: RECOVERY   ✅
/tool mac-server print                     -> allowed-interface-list: none       ✅
/interface list member print (RECOVERY)    -> 1 member: bridgeLocal              ✅
/ip service print detail                   -> 4  X  reverse-proxy  443  cert=none ✅ (CM-0006 holds)
/system identity print                     -> name: MKT01                        ✅
/interface bridge port (ether3)            -> hw=no  ingress-filtering=no         ✅
/interface ethernet print                  -> ether2 = X; ether4-13 enabled       ✅
/ip firewall filter print count-only       -> 22                                  ✅
/ip address print detail (bridgeLocal)     -> ";;; ADMIN RECOVERY NETWORK - DO NOT REMOVE..."  ✅
/user aaa print                            -> use-radius: yes                     ✅
/ip dns print                              -> 10.10.0.5, 1.1.1.1, 8.8.8.8         ✅
/disk print                                -> FORESEE 64GB SSD, sata1-part1, MOUNTED ✅
/ip neighbor discovery-settings print      -> discover-interface-list: static     🟡 (open, ADR-0016)
```

🔴 **`CM-0021` is therefore DOCUMENTATION-ONLY, exactly as scoped. No device change was made or is required.**

## 🟢 The firewall needed NO change — verified rule by rule

**`/ip firewall filter print` returned 22 rules in EXACTLY the order `026` §11 builds them** — same chains, same comments, same `log-prefix` values (`DROPPED:`, `EAST-WEST-DENIED:`, `INPUT-DENIED:`), both catch-all drops last (`20` forward, `21` input).

🔴 **This settles a count three documents gave as 22, 23 and 24.** **`045-SW01-CIS-Hardening-Checklist.md` says *"23 rules"* — it is WRONG.** *(→ reconciliation batch.)*

## 🟢 SOLVED — the dynamic WinBox row. Open in FOUR documents.

```
9 D c  name="winbox"  port=8291  proto=tcp  local=10.10.0.1  remote=10.10.0.50:8761
```

🔴 **`remote=10.10.0.50` is the admin workstation. It is the operator's own live session**, connection-tracked (`c` = CONNECTION). **It is not an unrestricted service.**

**It sat "unexplained / NOT VERIFIED" in `Session-Handoff` v7.0 open item #8, `To-The-Next-Session` §5, `CM-0017` and `022`.**

> 🔴 **Nobody could settle it because `/ip service print` does not show `local=` or `remote=`. Only `print detail` does — and nobody ran it.**
>
> **`016` lesson 1's twin: the command was right and the FLAG was missing.** **The inference was correct; the proof took one word.**

**✅ CLOSED. Reconcile `022`, `Session-Handoff`, `To-The-Next-Session` and `CM-0017`.**

## 🔴 I was WRONG about two "undocumented services" — the device corrected me

**The audit flagged `ntp` (123) and `discover` (5678) in `/ip service print` as *"two listening services in no Atlas document."***

🔴 **Both carry the `D` (DYNAMIC) flag. `/system ntp server print` → `enabled: no`.**

- **`ntp`** is the NTP **client**'s socket (`/system ntp client`: `pool.ntp.org`, `synchronized`, stratum 1). **MKT01 serves no time.**
- **`discover`** is **MNDP**, auto-created by `/ip neighbor discovery-settings`. **It is the mechanism of the disclosure leak `ADR-0016` already tracks — not a separate service.**

> 🔴 **The auditor inferred a service from a listing. That is `CM-0017`'s exact error, in miniature.** **The `D` flag was in the output being read.** **Recorded, not hidden** — per `ADR-0012` and `CM-0017`'s own precedent.

## 🔴 NEW FINDING — what is SW01's clock actually synced to?

**MKT01's NTP server is `enabled: no`. `029` records NO NTP service on Pi01.**

**But `023` sets SW01's NTP server to `10.10.0.5` (Pi01), and `027` Step 17 teaches you to.**

🔴 **If Pi01 serves no NTP, SW01 has been pointed at nothing.** **`DEVICE CHECK`: `show ntp status` on SW01 — expect `Clock is unsynchronized`.** Raised in the audit as **D11**.

---

# 🟢 EDITS APPLIED — 2026-07-14, verified by COUNT-CHECK (rule R1)

| Edit | Result |
|---|---|
| 1 — Delete the stale `mac-winbox=none` line | ✅ |
| 2 — Add the `reverse-proxy` disable (`CM-0006`) | ✅ |
| 3 — §12 Verify block replaced *(MAC-WinBox is not an `/ip service` and CANNOT appear in `/ip service print`)* | ✅ |
| 4 — Validation section extended | ✅ |
| 5 — Completion Checklist: 4 new lines, incl. **a LIVE MAC-CONNECT test, not a config read** | ✅ |
| 6 — Step 2 identity → `MKT01` | ✅ |
| 7 — *"Post-build: PROVE the recovery path"* moved **ABOVE** the Change Log | ✅ |
| 🔴 **8 — UNPLANNED, found by the count-check** | ✅ **See below** |

## 🔴 The count-check found an eighth problem the audit had missed

```
grep -c "mac-winbox set allowed-interface-list=none"   ->   1     🔴 STILL THERE
```

**After all seven edits, the dangerous string survived — on line 338, inside §3's warning blockquote, in a code fence, quoted as *"the previous version of this section ended with three unexplained lines."***

**It is a legitimate historical record. It is also a live `set` command in a pasteable code block.**

> 🔴 **`CM-0017`'s root cause, verbatim:** *"A build guide was quoted, in a chat message, as illustrative text. **It contained live `set` commands. The operator pasted it.**"* **It was harmless only by luck — the commands happened to be idempotent.**
>
> **Ground rule (`To-The-Next-Session` §7): *any block of device commands, in any medium, will eventually be pasted into a device. Assume it will be.***

**Fixed:** the history is kept, **as a prose table, not a code fence.** **The record survives; the paste hazard does not.**

> 🟢 **THIS IS RULE R1 EARNING ITS KEEP ON ITS FIRST USE.**
>
> **Every "new string present?" check passed. The fix had landed. The document looked correct.**
>
> 🔴 **Only the COUNT of the OLD string found it.**
>
> **That is the entire finding of this audit, demonstrated on the first document it fixed.**

## Final verification

```
mac-winbox set allowed-interface-list=none       ->  0    🟢 GONE
mac-winbox set allowed-interface-list=RECOVERY   ->  1    🟢 EXACTLY ONCE
reverse-proxy disabled=yes                       ->  1    🟢
system identity set name=MikroTik                ->  0    🟢 GONE
system identity set name=MKT01                   ->  1    🟢
code fences                                      -> 72    🟢 EVEN (balanced)
lines                                            476 -> 668
```

---

## Closeout

- [x] ✅ **Device read FIRST** — every claim re-tested on live MKT01 before a line was edited
- [x] ✅ Edit 1 — stale `mac-winbox=none` line **DELETED** from §12
- [x] ✅ Edit 2 — `reverse-proxy` disable added (`CM-0006`)
- [x] ✅ Edit 3 — §12 Verify block replaced (MAC-WinBox is not an `/ip service`)
- [x] ✅ Edit 4 — Validation section extended
- [x] ✅ Edit 5 — Completion Checklist extended, **demanding a live MAC-connect**
- [x] ✅ Edit 6 — Step 2 identity corrected to `MKT01`
- [x] ✅ Edit 7 — *"PROVE the recovery path"* moved above the Change Log
- [x] 🔴 ✅ **Edit 8 — UNPLANNED.** The count-check found the string surviving in §3's quote block, **in a pasteable code fence.** Converted to prose.
- [x] ✅ **VALIDATED BY COUNT-CHECK (R1)** — old string returns **0**, not merely "new string present"
- [x] ✅ Live device re-confirmed: `mac-winbox = RECOVERY`, `reverse-proxy` = `X`, 22 rules, `hw=no`
- [x] ✅ **`048` read and reconciled** — **its bootstrap table is CORRECT and current.** `CM-0017`/`CM-0018` reconciled it properly. *(Separately, `048` Phase 0 has its own defect — `CM-0025`.)*
- [ ] 🔴 **`016` updated** with R1 + the MAC-WinBox lesson `CM-0018` never delivered — **BLOCKS CLOSURE**
- [ ] 🔴 **`022`, `Session-Handoff`, `To-The-Next-Session`, `CM-0017` reconciled** — the dynamic WinBox row is **SOLVED** — **BLOCKS CLOSURE**
- [ ] Closed

> 🔴 **Status is `Implemented — reconciliation open`, NOT `Closed`.** Two boxes are unticked and **they are unticked because they are true.**
>
> **`CM-0018` ticked *"guide reconciliation complete"* against a rewrite that was wrong. `CM-0009` ticked `Closed` with three boxes open. `CM-0010` is `Closed` with `[ ] Mark this record Closed` unticked.** **Not here.**

> 🔴 **This record does NOT move to `Closed` while any box above is unticked.** If a box cannot be ticked, the status is **`Implemented — reconciliation open`**.
>
> **`CM-0018` ticked its `026` box and this defect is the result. Do not repeat it here.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`), finding C1. 🔴 **`026` §12 — the block rewritten on 2026-07-14 to FIX the missing recovery path — sets `mac-winbox=RECOVERY` and then back to `none` four lines later.** `CM-0018` said *replace*; the edit *appended*. 🔴 **Also found: `026` never disables `reverse-proxy` — `CM-0006` predates Rule 15 and has no Build Guide row.** Discovery scoping and the `ether5`–`ether13` disable are **deliberately NOT changed** — `ADR-0016` defers both. |
