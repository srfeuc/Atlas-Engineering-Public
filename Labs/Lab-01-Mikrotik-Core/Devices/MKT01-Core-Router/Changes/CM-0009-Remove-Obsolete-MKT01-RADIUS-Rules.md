# CM-0009 — Remove Obsolete Pre-VLAN RADIUS Rules from MKT01

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | **CLOSED — implemented and verified 2026-07-13** |
| Risk | Low |
| Affected systems | MKT01 |
| Date raised | 2026-07-13 |
| **Date executed** | **2026-07-13 (evening)** |
| Evidence Status | **`Verified`** — live device output |

## ✅ Executed and Verified — 2026-07-13

**Every gate passed. The analysis held.**

| Check | Expected | Actual |
|---|---|---|
| Pre-change rule count | 24 | **24** ✅ |
| Backup taken (`/export` + `/system backup`) | — | ✅ Both, pulled off-device |
| Removal **by comment**, never by index | — | ✅ |
| Post-change rule count | **22** | **22** ✅ |
| `EAST-WEST-DENIED:` still last in forward chain | — | ✅ **rule 20** |
| `INPUT-DENIED:` still last in input chain | — | ✅ **rule 21** |
| MKT01 `/user aaa print` | `use-radius: yes` | ✅ |
| **FGT01 → Pi01 RADIUS reachable** | works | ✅ FGT01 Test Connectivity **successful** |
| 🔴 **RADIUS authentication end-to-end** | works | ✅ **`Access-Accept`** |

> **The rollback trigger was: *if RADIUS breaks, the analysis was wrong.* RADIUS did not break.**
>
> **The premise is confirmed.** FGT01 (`10.10.0.254/24`) and Pi01 (`10.10.0.5/24`) are on the same subnet, same VLAN, Layer-2 adjacent via SW01. That traffic **never entered MKT01's forward chain.** Rules 19 and 20 pointed at Pi01's **pre-VLAN** address (`10.0.0.5`) on a path MKT01 was not part of — **they had never done anything at all.** Removing them changed nothing, which is exactly what the analysis predicted and what nothing but execution could prove.

> 🔴 **The authentication test required a new account.** `043` deleted `testing`/`password` — correctly — and **left no way to authenticate against RADIUS at all.** Without `CM-0013`, this change could only have been closed on a *reachability* probe, which would not have detected a wrong shared secret or a broken `users` file. **See `CM-0013`.**

## Purpose

Remove two firewall rules from MKT01 that reference Pi01's pre-VLAN address (`10.0.0.5`) and sit on a traffic path MKT01 is not part of. They match nothing and have no documented purpose.

Live rules 19 and 20:

```text
19  ;;; FortiGate ping to Pi-hole
    chain=forward action=accept protocol=icmp dst-address=10.0.0.5
    in-interface=ether1 out-interface=bridgeLocal

20  ;;; FortiGate RADIUS to Pi-hole
    chain=forward action=accept protocol=udp dst-address=10.0.0.5
    in-interface=ether1 out-interface=bridgeLocal dst-port=1812,1813
```

## Reason

Found during the Book 1 Confluence reconciliation, while resolving a firewall rule count that three documents gave as 22, 23, and 24. The device says **24**. Reading the actual rules surfaced two that are dead for **two independent reasons**:

**1. Wrong address.** `10.0.0.5` is Pi01's **pre-VLAN flat-network** address. Pi01 is at **10.10.0.5** (`030-Pi01-Base-System-Build-Guide.md`). The rules match no host.

**2. Wrong device — correcting the address would not help.** FGT01's `internal2` is `10.10.0.254/24`. Pi01 is `10.10.0.5/24`. **Same subnet, same VLAN 10, Layer-2 adjacent via SW01.** FGT01→Pi01 RADIUS traffic flows FGT01 → SW01 → Pi01. **It never enters MKT01's forward chain.**

This explains an anomaly nobody had questioned: FGT01's RADIUS integration was confirmed working end-to-end (`MC-0002`, `043`) while these rules pointed at a nonexistent host. It works *because MKT01 is not involved*. Pi01's own UFW rule — `allow from 10.10.0.254 to any port 1812/1813` — confirms the same-subnet source.

They are fossils from the flat-network topology, surviving only because nothing depended on them.

Per Network Standards (`NET-005`): *a firewall rule requires a documented purpose.* These have none.

## Prerequisites

None. Removing rules that match no traffic.

## Backup

```routeros
/export hide-sensitive file=mkt01-pre-CM-0009
```

Pull from WinBox → Files before proceeding.

## Implementation

```routeros
/ip firewall filter print
```

Confirm the two rules by comment, **not by index** — indices shift.

```routeros
/ip firewall filter remove [find comment="FortiGate ping to Pi-hole"]
/ip firewall filter remove [find comment="FortiGate RADIUS to Pi-hole"]
```

## Validation

```routeros
/ip firewall filter print count-only
```

Expected: **22** (was 24).

**Then prove RADIUS still works, since these rules nominally carried it:**

On FGT01 — `User & Authentication → RADIUS Servers → Pi01-RADIUS → Test Connectivity`, then a real credential test.

On Pi01:

```bash
sudo journalctl -u freeradius -n 20
```

Confirm the FGT01 request arrives. **If RADIUS breaks, the premise of this change was wrong** — roll back immediately and re-open the analysis.

Confirm both catch-all drops survive and remain last in their chains:

```routeros
/ip firewall filter print
```

## Rollback

```routeros
/import file=mkt01-pre-CM-0009.rsc
```

Or re-add, corrected to VLAN 10 addressing:

```routeros
/ip firewall filter add chain=forward action=accept protocol=udp \
  dst-address=10.10.0.5 in-interface=ether1 out-interface=bridgeLocal \
  dst-port=1812,1813 comment="FortiGate RADIUS to Pi-hole" \
  place-before=[find comment="Drop everything else"]
```

## Documentation updates

- [x] Build Record updated — `022-MKT01-Build-Record.md` **(v2.5, 2026-07-13 — see note below)**
- [ ] Revision History updated
- [ ] Confluence published and reviewed

## Guide Reconciliation — required, not conditional

> **Does any guide now contain an instruction that would recreate this problem, or a claim that this change disproves?**

| Guide | Outcome | Detail |
|---|---|---|
| `026-MKT01-Build-Guide.md` | **Updated** | Step 11 rebuilt from live device. The fossil rules are **not** recreated. Also fixed a **separate, more serious defect found in the same pass: the guide never built an input-chain default deny.** RouterOS defaults to ACCEPT — a rebuild from the old guide produced a router with *no default deny on its input chain at all.* Rule order now matches the device. Target: 22 rules. |
| `033-Pi01-FreeRADIUS-Build-Guide.md` | **Updated** | Step 5 told you to add these MKT01 return-path rules. It no longer does. Note added that FGT01→Pi01 is same-subnet and does not traverse MKT01. |
| `022-MKT01-Build-Record.md` | **Updated** | Claimed *"22 rules verified"* while listing 21 and the device had 24. Rebuilt from live output. |
| `041-MKT01-Troubleshooting-Guide.md` | **Reviewed — no change needed** | Contains no rule-count claim and no instruction to create these rules. |
| `009-Routing-Standards.md`, `011-Packet-Flow.md` | **Reviewed — no change needed** | Neither documents the FGT01→Pi01 path. *Worth noting they also don't document that it bypasses MKT01 — which is why nobody caught this. Candidate for a future addition, not this change.* |

## Closeout

- [x] Implemented
- [x] Validated — **rule count read back off the device as `22`** (`/ip firewall filter print count-only`, 2026-07-13; device re-confirmed `22` on 2026-07-15)
- [x] Build Record updated — `022-MKT01-Build-Record.md` v2.5, firewall table rebuilt from live output (device count `22`)
- [x] Guide reconciliation answered in writing above
- [x] **Closed**

## Note

This is the first change record written under Charter Locked Rule 15. It is also a clean demonstration of Rule 13: three documents said 22, 23, and 24. One command on the device said **24** — and reading the rules themselves revealed that *two of them had never done anything at all.* No amount of document-reading would have found that.

## 🔴 Closeout defect — found 2026-07-13, during the Confluence publication pass

**This record was marked `CLOSED — implemented and verified` while two of its own closeout boxes were unticked.**

| Box | State when found |
|---|---|
| *Validated — rule count read back as 22* | ☐ **Unticked** |
| *Build Record updated — `022-MKT01-Build-Record.md`* | ☐ **Unticked** |

**And the second one was unticked because it was true.** `022-MKT01-Build-Record.md` was still at v2.4, still saying **"Firewall — 24 rules live"**, still listing rules 19 and 20 as *"Removal pending CM-0009."*

**So for a full day, the Build Record — the document whose entire job is to record verified reality — described a firewall that no longer existed.**

The device settled it: `/ip firewall filter print count-only` returns **`22`**. The change had executed. **The record was right and its own paperwork was wrong.**

### The pattern this adds

> **`CM-0013` found that a security fix can create a blind spot.**
> **`CM-0010` found that a procedure with no destroy step leaves debris.**
> **`CM-0014` found that the document defining a rule is not a control.**
>
> 🔴 **This one is the closeout's own failure mode: a record can be marked `Closed` while its closeout is incomplete, because nothing checks the checklist.**

**The closeout was invented to catch exactly this class of defect — and then the closeout itself was not completed.** A checklist that nobody verifies is a checklist that reports success by default.

**Recommendation:** no record moves to `Closed` while any closeout box is unticked. If a box cannot be ticked, the record is not Closed — it is `Implemented, reconciliation open`, which `CM-0010` already uses correctly.
