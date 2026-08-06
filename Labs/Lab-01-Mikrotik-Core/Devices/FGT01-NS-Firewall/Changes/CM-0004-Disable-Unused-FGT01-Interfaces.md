# CM-0004 — Disable Unused Factory Interfaces on FGT01

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

| Item | Value |
|---|---|
| Status | **Closed** |
| Risk | Low — all confirmed unconnected during live validation |
| Affected systems | FGT01 |
| Date raised | 2026-07-12 |
| **Date closed** | **2026-07-13 — verified on the live device** |
| Evidence Status | **`Verified`** — `show full-configuration system interface \| grep -f "set status down"` |

> **This record sat at `Status: Draft` while the work was already done.**
>
> The FGT01 Build Record said *"unused interfaces — disabled, per CM-0004."* This record said Draft. **Two documents, opposite claims, for a month.**
>
> **The device settled it. The Build Record was right.** Charter Rule 13.
>
> **In a rebuild, a Draft record gets skipped.** A stale status is not a cosmetic problem — it is a step that does not happen.

## Purpose

Disable `internal` (factory hard-switch group), `wan2`, and `fortilink` — factory-default interfaces found still enabled, admin-reachable, and undocumented during the 2026-07-12 FGT01 validation pass. Implements the Unused Interface Policy (`010-Security-Zones.md`).

## Verification — 2026-07-13

**Do not use `show system interface`** — it hides default values, which is exactly how `MC-0001`'s `admin-server-cert` sat silently unbound while every command appeared to succeed.

**Do not use `get system interface physical`** either — it reports *link and IP* state, not *administrative* status. An interface with no address looks identical to a disabled one.

**FortiOS ships a cut-down `grep`: no `-E`, no alternation. It does have `-f`, which prints the containing config block and marks the match.**

```
show full-configuration system interface | grep -f "set status down"
```

| Interface | Result |
|---|---|
| `wan2` | ✅ `set status down` |
| `internal` | ✅ `set status down` — still holds `192.168.1.99`, the factory bootstrap address |
| `fortilink` | ✅ `set status down` |
| **`modem`** | ✅ `set status down` — **but see below** |

**All three in scope are disabled. Closed.**

## 🔴 Finding — a fourth interface nobody documented

**`modem` is disabled, and appears in no Atlas document at all.**

It was not in this change record, not in the Build Record, not in the Build Guide. **It is disabled — but nobody wrote down that it should be, so in a rebuild there is no instruction either way.** A rebuilt FGT01 would leave it at whatever the factory default is, and nobody would notice.

**It also carries a credential:**

```
edit "modem"
    set mode pppoe
    set password ENC GMzKNYEtyVujrDoyjee/daffELdCpFKUoBExr1s5STXoIsemgSTF42qH...
```

An **encrypted PPPoE credential on an undocumented interface**. Almost certainly factory noise — but it is a credential, it is in the running config, and **it is in every config backup you take.**

**Action:** record `modem` in `021-FGT01-Build-Record.md` alongside the other three, so it stops being a surprise. Done 2026-07-13.

## Closeout

- [x] `wan2` disabled — verified on device
- [x] `internal` disabled — verified on device
- [x] `fortilink` disabled — verified on device
- [x] **`modem` found, disabled, and recorded** — was in no document
- [x] Build Record reconciled
- [x] **Closed**

## Note

**Three commands were tried before one answered the question.** `get system interface physical` (wrong question — reports link, not admin status), `grep -A5` (truncated — `set status` sits below `set distance`), and `grep -E` (**FortiOS grep has no `-E`**).

**Each ran cleanly and printed plausible output.** That is the sibling of the lesson `043` named: *a command completing without an error is not a confirmed change* — and its twin, **a command completing without an error, on the wrong question.**

**`037-FGT01-Troubleshooting-Guide.md` should carry a "FortiOS CLI is not a Linux shell" note.** The next person to type `grep -E` on that box loses the same ten minutes.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-12. |
| 1.1 | **Draft → Closed 2026-07-13.** Verified on the live device; all three interfaces `set status down`. The Build Record had been right and this record stale for a month. **A fourth undocumented interface (`modem`) found, carrying an encrypted PPPoE credential.** |
