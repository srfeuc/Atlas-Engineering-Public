# CM-0016 — Correct the Misleading `;;; Legacy flat management` Comment on MKT01

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | ✅ **Closed 2026-07-14 — executed and read back.** Comment changed on the live device; all ten addresses confirmed otherwise unchanged. Guide reconciliation complete (`026`, `022`). |
| Risk | **Low** (comment text only — no addressing, routing, or firewall change) |
| Affected systems | MKT01 (`/ip address` comment on `bridgeLocal`) |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — MKT01 live output, 2026-07-14 |
| Related | `ADR-0013`, `017-Future-Expansion.md` v2.0, `003-Physical-Topology.md`, `016-Network-Lessons-Learned.md` |

## Reason

**MKT01 labels the admin recovery network as *"Legacy."***

```text
/ip address print detail

 1     ;;; Legacy flat management
       address=10.0.0.1/24 network=10.0.0.0 interface=bridgeLocal
```

**That comment is not a cosmetic problem. It is the root cause of a documented near-miss.**

`017-Future-Expansion.md` v1.0 listed *"retirement of the legacy `10.0.0.0/24` network"* as a routine deferred enhancement — **while `003-Physical-Topology.md` and `016-Network-Lessons-Learned.md` both explicitly say *do not remove `bridgeLocal`*.** The word **"legacy"** is almost certainly where `017`'s author got the idea, and it came **from the device.**

> 🔴 **Your recovery path is labelled "Legacy" on the router that owns it.**
>
> **Calling a control "legacy" is how it gets deleted by someone acting entirely in good faith.** They read the comment, check the deferred-work list, find agreement, and pull it. **They find out what it was for at the exact moment they need it.**

**This is `016` lesson 6, inverted.** That lesson says *a guessed value fails loudly; an omitted one fails silently.* **This is a third case: a value that is present, accurate-sounding, and misleading.** `bridgeLocal` *is* flat, and it *is* older than the VLANs. **Every word of the comment is defensible, and its effect is to invite the destruction of the recovery path.**

## Current state — read from the device

```text
/interface bridge port print where bridge=bridgeLocal
Flags: I - INACTIVE; H - HW-OFFLOAD
0 IH ether4   bridgeLocal  yes ...
...
9 IH ether13  bridgeLocal  yes ...
```

**All ten ports are members, hardware-offloaded, and NOT disabled** — no `X` in the legend. **`I` = no cable currently plugged in**, which is the correct resting state for a fallback.

**The network is live, wired, and load-bearing.**

## Implementation

**One command. Comment text only. No addressing, routing, or firewall change.**

```routeros
/ip address set [find address="10.0.0.1/24"] comment="ADMIN RECOVERY NETWORK - DO NOT REMOVE. MAC-WinBox scope (RECOVERY list). Plug into ether4. See 003, 016, ADR-0013, ADR-0014, ADR-0016."
```

> **Find by address, not by index.** RouterOS indices are not stable. `016` (MikroTik): *insert rules before the final catch-all **by comment**, not by hard-coded index* — the same discipline applies to selecting a row to edit.

## Validation — read it back off the device

🔴 **A command completing without an error is not a confirmed change.**

```routeros
/ip address print detail where address="10.0.0.1/24"
```

**Must show the new comment.** Then confirm nothing else moved:

```routeros
/ip address print detail
/interface bridge port print where bridge=bridgeLocal
```

**Expected: ten addresses unchanged, ten bridge ports unchanged, only the comment on entry `10.0.0.1/24` different.**

## Rollback

```routeros
/ip address set [find address="10.0.0.1/24"] comment="Legacy flat management"
```

**Comment text only — there is nothing to roll back beyond the string.**

## Guide Reconciliation — Charter Rule 15

> **Does any guide now contain an instruction that would recreate this problem, or a claim this change disproves?**

| Guide | Outcome | Detail |
|---|---|---|
| `026-MKT01-Build-Guide.md` | 🔴 **Must update** | **A router rebuilt from this guide comes back with the old comment — or with no comment at all.** Whichever it is, the guide must specify the recovery-network comment explicitly. **This is `CM-0015`'s lesson exactly: a guide that does not mention a thing will recreate the thing.** |
| `022-MKT01-Build-Record.md` | 🔴 **Must update** | Record the address comment as part of MKT01's verified state. |
| `017-Future-Expansion.md` | ✅ **Updated (v2.0)** | The *"retire the legacy `10.0.0.0/24`"* line is corrected and the item moved to `ADR-0013`, gated. |
| `003-Physical-Topology.md` | **Reviewed — no change needed** | Already says *"Do not repurpose these ports. Do not remove `bridgeLocal`."* **It was right all along.** |
| `016-Network-Lessons-Learned.md` | **Reviewed — no change needed** | Already says *"It is the recovery path. Do not retire it early."* |
| `048-Teardown-and-Rebuild-Runbook.md` | **Reviewed** | Confirm it still presents `bridgeLocal` as a recovery path. It should. |

## Closeout

- [x] ✅ **Comment updated on MKT01 2026-07-14.** Now reads: `ADMIN RECOVERY NETWORK - DO NOT REMOVE. MAC-WinBox scope (RECOVERY list). Plug into ether4. ...`
- [x] ✅ **Read back on the device** — new comment confirmed
- [x] ✅ **All ten addresses confirmed unchanged** — transit + nine VLAN gateways identical. **Exactly one field on one row changed.**
- [x] ✅ `026` updated — **the comment is now part of the build.** A rebuilt router comes back with it.
- [x] ✅ `022` updated — comment recorded as verified state
- [x] ✅ **Change Management index** — listed in the rebuilt CM README index (`051` / L2 reconciliation; next available `CM-0034`)
- [x] ✅ **Closed 2026-07-14**

> 🔴 **A record does not move to `Closed` while any box is unticked.** If a box cannot be ticked, the status is `Implemented — reconciliation open`.

## Note

**This is the cheapest change in the pack and one of the more valuable.** It costs one command and it removes a landmine that already produced a wrong document (`017` v1.0) proposing the destruction of the lab's last VLAN-independent management path.

> **A comment is documentation that lives on the device — which makes it the documentation people are most likely to believe.** Charter Rule 13 says the device beats the document. **That cuts both ways: when the device says something misleading, it does more damage than a misleading document ever could.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 during the `017` reconciliation. MKT01 comments its admin recovery network `;;; Legacy flat management` — the likely origin of `017` v1.0's proposal to retire it, which `003` and `016` both forbid. Comment-only change; guide reconciliation required on `026` and `022`. |

## Executed — 2026-07-14

**Baseline confirmed before writing** (`/ip address print detail where address="10.0.0.1/24"` → `;;; Legacy flat management`). **The Draft's hypothesis still held.** Then one `set`, then two read-backs.

> 🔴 **The final comment differs from the drafted one, deliberately.** The draft pointed at documents. **The live comment names `ether4` and the `RECOVERY` list**, because someone standing at this router during an outage needs **the socket**, not a reading list. **The device is the documentation people trust most. It should tell them which port to plug into.**

**And `bridgeLocal` is now load-bearing twice:** it is the recovery *network*, **and** the only segment MAC-WinBox answers on (`ADR-0014`). **Deleting it would remove both — and the old label was inviting exactly that.**
