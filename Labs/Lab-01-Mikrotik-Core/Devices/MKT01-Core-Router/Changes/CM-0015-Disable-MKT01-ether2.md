# CM-0015 — Disable MKT01 `ether2` (Unused Interface Policy)

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | ✅ **CLOSED — implemented and verified 2026-07-13** |
| Risk | **Low** — no IP, no bridge membership, no route. See "Why this is Low and still matters." |
| Affected systems | MKT01 |
| Date raised | 2026-07-13 |
| Evidence Status | **`Verified`** — `/interface print` on the live device, **before and after** |
| Date closed | **2026-07-13** |
| Found during | Book 1 Confluence publication pass, reconciling `010-Security-Zones.md` |

> **The policy that this record enforces was written because of `CM-0004`. It has never been applied to MKT01.**

## Finding

`/interface print` on MKT01 (RouterOS 7.23.1, 2026-07-13):

```text
Flags: R - RUNNING; S - SLAVE
 #    NAME      TYPE    ACTUAL-MTU  L2MTU  MAX-  MAC-ADDRESS
 0 R  ether1    ether         1500   1592  9578  00:00:5e:00:53:06
 1    ether2    ether         1500   1592  9578  00:00:5e:00:53:07
 2 RS ether3    ether         1500   1592  9578  00:00:5e:00:53:08
 3  S ether4    ether         1500   1592  9578  00:00:5e:00:53:09
 ...
```

**Read the flags legend.** RouterOS prints only the flags actually in use. **`X - DISABLED` does not appear.**

> 🔴 **Not one interface on MKT01 is administratively disabled.**

`ether2` carries **no `R`** (no link — nothing is plugged in) and **no `S`** (not a bridge member). It is **enabled, idle, and at factory default** — with no assigned purpose recorded anywhere.

## Reason — this violates a policy Atlas already wrote

`010-Security-Zones.md`, **Unused Interface Policy**:

> *"Any interface, port, or logical connection with no assigned purpose and nothing connected to it **must be administratively disabled**, not merely left undocumented at its default state."*
>
> *"This applies uniformly: switch ports, firewall interfaces, **router interfaces**, hard-switch groups, fabric/management interfaces."*

**`ether2` is a router interface with no assigned purpose and nothing connected to it.** The policy names it explicitly and it has never been applied.

### Compliance across the lab

| Device | Unused interfaces | Compliant? |
|---|---|---|
| **SW01** | `Gi1/0/8-48`, `Gi1/0/49-52` | ✅ `Shutdown, BPDU Guard` — **and it was compliant by accident**, before the rule existed |
| **SW01** | `Gi1/0/3` | ✅ Shut down deliberately (`ADR-0002`) |
| **FGT01** | `internal`, `wan2`, `fortilink`, `modem` | ✅ All four `set status down` (`CM-0004`, device-verified) |
| **PVE01** | `eno2` | ✅ `DOWN` — not in `/etc/network/interfaces` as `auto` |
| 🔴 **MKT01** | **`ether2`** | 🔴 **NO — enabled, idle, undocumented** |

**Every device in the lab complies except the one hosting the east-west firewall.**

## 🔴 Why this is Low risk and still matters

**The honest assessment first.** `ether2` has:

- **No IP address**
- **No bridge membership** — it is in neither `bridgeLocal` nor `bridge-trunk`
- **No route** — nothing forwards to or from it
- **No link** — nothing is physically plugged in

And MKT01's **input chain has a default deny** (rule 21, `INPUT-DENIED:`). A host plugged into `ether2` could not reach the router itself, and has no path anywhere else.

**So the realistic exploit today is: nothing.** This record does not pretend otherwise.

> **But "low risk" was equally true of FGT01's `internal`, `wan2` and `fortilink` — right up until someone enumerated them.**
>
> `internal` was still holding `192.168.1.99`, the factory bootstrap address. `modem` was carrying an **encrypted PPPoE credential**. Nobody knew either fact, because nobody had looked.
>
> 🔴 **The policy's entire point is that you do not get to assess the risk of an interface you did not know was enabled.** Risk assessment requires an inventory. **An undocumented enabled interface is not low-risk — it is unassessed.**

**And the specific future failure is easy to name:** someone plugs a cable into `ether2` during a rebuild or a troubleshooting session, gets link, and now there is a live port on the core router that appears in no document, belongs to no VLAN, and was never reasoned about.

## Implementation

```text
/interface set [find name=ether2] disabled=yes comment="Unused - disabled per 010 Unused Interface Policy, CM-0015"
```

## ✅ Validation — read back from the device, 2026-07-13

```text
/interface print
Flags: X - DISABLED; R - RUNNING; S - SLAVE
 #     NAME      TYPE    ACTUAL-MTU  L2MTU  MAX-  MAC-ADDRESS
 0  R  ether1    ether         1500   1592  9578  00:00:5e:00:53:06
;;; Unused - disabled per 010 Unused Interface Policy, CM-0015
 1 X   ether2    ether         1500   1592  9578  00:00:5e:00:53:07
 2  RS ether3    ether         1500   1592  9578  00:00:5e:00:53:08
```

**Three independent confirmations in one output:**

| Evidence | Why it counts |
|---|---|
| **The flags legend changed** — `X - DISABLED` now appears | RouterOS prints **only the flags actually in use.** Before this change the legend read `R - RUNNING; S - SLAVE` — **no `X` anywhere on the device.** The legend itself is proof that *something* is now disabled. |
| **`1 X   ether2`** | The flag is on the interface. |
| **The comment persisted** — `;;; Unused - disabled per 010 Unused Interface Policy, CM-0015` | The device is now **self-documenting.** Anyone running `/interface print` in three years sees *why* it is off and *which record to read* — without opening Atlas at all. |

> ✅ **It persisted on the first `set`.** Worth recording, because `use-radius=yes` on **this same device** did **not** — and returned no error either way (`043`). **The read-back is what distinguishes those two outcomes. Nothing else does.**

## Rollback

```text
/interface set [find name=ether2] disabled=no
```

**Nothing depends on `ether2`.** Rollback is instant and carries no risk.

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| `026-MKT01-Build-Guide.md` | 🔴 **Must update** | The guide **never disables `ether2`.** A router rebuilt from it comes back with an enabled, purposeless interface — **recreating this finding exactly.** Add the disable step. |
| `010-Security-Zones.md` | 🔴 **Must update** | The Unused Interface Policy is stated but has **never been applied to MKT01.** Add MKT01 to the compliance table so the gap is visible rather than implied. |
| `022-MKT01-Build-Record.md` | 🔴 **Must update** | Records `ether2` as *"Unused — Available."* **"Available" is not a state. It is a hope.** The device says *enabled*. Record the real administrative state, and update it when this record closes. |
| `015-Network-Validation-Guide.md` | **Reviewed** | Already requires enumerating **every** interface a device has, not just the expected ones. **That instruction is correct and it worked** — this finding came from following it. |

## Closeout

- [x] `ether2` disabled on the device — **persisted on the first `set`**
- [x] `/interface print` read back — **`X` flag confirmed on `ether2`; the flags legend now includes `X - DISABLED`**
- [x] **Comment set on the interface** — the device carries its own justification and record number
- [x] `026-MKT01-Build-Guide.md` updated — **the guide had NO mention of `ether2` at all.** Disable step + read-back added.
- [x] `022-MKT01-Build-Record.md` v2.6 — real state recorded: **DISABLED**, `X` flag verified (was *"Unused — Available"*)
- [x] `010-Security-Zones.md` updated — MKT01 added to the compliance table
- [x] **Closed**

> ✅ **Every box ticked before this record was marked Closed.** `CM-0009` was marked `Closed` with its "Build Record updated" box unticked — and the Build Record then described a firewall that no longer existed **for a full day.** **That is the defect this closeout exists to prevent, and it was not repeated here.**

### 🔴 What the guide reconciliation actually found

**`026-MKT01-Build-Guide.md` did not mention `ether2` at all.**

Not wrongly — **at all.** So a router rebuilt from it comes back with `ether2` **enabled, idle and undocumented** — *precisely the state this record was raised to fix.* **The guide recreated the finding.**

> **Closing the change on the device without fixing the guide would have made this record cosmetic.** The device would be right and the next rebuild would be wrong, and nobody would know until someone enumerated the interfaces again. **That is Charter Rule 15, and it is why guide reconciliation is not conditional.**

## Note — how this was found

**Not by looking for it.** It surfaced while reconciling `010-Security-Zones.md` for Confluence publication: the document defines a policy, so the obvious question was *"is it actually enforced?"* — and the Build Record's answer (*"ether2 — Unused — Available"*) did not say **disabled**.

**The Build Record did not lie. It just never said.** `Available` is the kind of word that survives review because it sounds like a decision. It is not one.

> **Every device in this lab was found compliant with a policy that nobody had ever checked — except the one that wasn't.**

## Change Log

| Version | Changes |
|---|---|
| **1.1** | ✅ **Executed and CLOSED 2026-07-13.** `/interface set [find name=ether2] disabled=yes` with a comment naming the policy and this record. Read back: flags legend gained `X - DISABLED` (it had none before), `ether2` carries `X`, comment persisted. **Took on the first `set`** — unlike `use-radius` on this same device. Guide/Record reconciliation (`026`, `022`, `010`) **completed 2026-07-13** — see Closeout: `026` gained the `ether2` disable step (device-verified `X` on 2026-07-14), `022` records `DISABLED`, `010` added MKT01 to the compliance table. |
| 1.0 | Raised 2026-07-13 during the Book 1 publication pass. `/interface print` confirms **no interface on MKT01 is administratively disabled** — the flags legend has no `X`. `ether2` is enabled, idle and undocumented, violating the Unused Interface Policy in `010-Security-Zones.md`. Risk assessed **Low** and stated honestly; raised anyway, because an unassessed interface is not a safe one. |
