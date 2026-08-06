# CM-0011 — Harden PVE01 iDRAC/BMC: Disable Cipher 0, Auth NONE, and Default SNMP

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PVE01 - Role: Hypervisor

| Item | Value |
|---|---|
| Status | 🔴 **CLOSED — substantially FALSE. Real work superseded by iDRAC onboarding (a build, not a change).** |
| Risk | **Void** — the vulnerability this record describes does not exist. See "What the device actually showed." |
| Affected systems | PVE01 iDRAC (BMC), VLAN 10 |
| Date raised | 2026-07-13 |
| Date closed | 2026-07-13 — **disproven on the live device the same session it was written** |
| Evidence Status | **`Verified`** — every claim re-tested against the BMC over KCS (`ipmitool channel info 1`) and the network (RMCP+ attempts from Pi01) |

> 🔴 **This record was executed against a device that had already moved, and executing it made things worse. Both facts are recorded below, because that is the whole point of a change record.**
>
> **CM-0012, in this same folder, carried `Blocks: CM-0011` in its header and stated in its first paragraph: *"Hardening a BMC that cannot hold its settings is documenting a lie. Fix the battery first."* That record was not read before this one was executed.**

---

## Why this record is Closed as false

CM-0011 proposed fixing **three** iDRAC findings from a single `ipmitool lan print 1`. Re-verified against the live BMC, **all three collapse.**

| CM-0011 finding | The device actually showed | Verdict |
|---|---|---|
| 🔴 Cipher Suite 0 at ADMIN (`aaaaaaaaaaaaaaa`) | `Cipher Suite Priv Max : XXXaXXXXXXXXXXX` — **suites 0/1/2 already unused**, only suite 3 (AES-CBC-128) at ADMIN. **Already hardened** by an earlier session, recorded in `CM-0012`. | ❌ **False** |
| 🔴 Auth Type `NONE` enabled | **Misread.** `Auth Type Support` is the firmware's *capability* list (what the BMC can speak). `Auth Type Enable` — the actual setting — showed `MD2 MD5`, **never `NONE`**. | ❌ **Misread** |
| 🔴 SNMP community `public` | **True** — but unreachable (channel disabled), and no SNMP collector exists. | 🟡 **Real but inert** |

### And the exposure premise itself is void

CM-0011's severity rested on *"an attacker on VLAN 10 can issue privileged IPMI commands with no password."* **Tested on the device:**

| Test (from Pi01, VLAN 10) | Result |
|---|---|
| `ipmitool channel info 1` (local, over KCS) | 🔴 **`Access Mode : disabled`** — in **both** Volatile and Non-Volatile settings |
| `-C 0 / -C 1 / -C 2 -U root -P ''` | All rejected — **RMCP+ session cannot be established** |
| `-C 3 -U root -P calvin` | Rejected |
| `-C 3 -U root -P ''` | Rejected |
| Web UI `https://10.10.0.100` | **Not reachable** |

🔴 **IPMI-over-LAN is DISABLED. It was never on.** The channel will not carry an IPMI session for anyone, with any credential, at any cipher.

**So every RMCP+ rejection above proves nothing about ciphers or passwords — the session dies at a closed channel before authentication is evaluated.** There is no IPMI attack surface. There never was.

---

## 🔴 The execution error — recorded, not hidden

**This record was acted on. It should not have been.**

Reading `Status: Draft — proposed, not executed`, the operator treated it as a to-do list and ran its Implementation section:

```text
ipmitool lan set 1 cipher_privs Xaaaaaaaaaaaaaa
```

**That command was built from CM-0011's baseline of `aaaaaaaaaaaaaaa` (all suites ADMIN). The device was already at `XXXaXXXXXXXXXXX`.** So it hardened nothing — it **degraded a correctly-hardened BMC**, turning suites 1 and 2 (authentication, no encryption) from `unused` back to `ADMIN`.

| | Before the command | After the command |
|---|---|---|
| `Cipher Suite Priv Max` | `XXXaXXXXXXXXXXX` ✅ | `Xaaaaaaaaaaaaaa` 🔴 **worse** |

**Caught by reading the state back, and reverted:**

```text
ipmitool lan set 1 cipher_privs XXXaXXXXXXXXXXX
```

Read-back confirmed `XXXaXXXXXXXXXXX` restored.

> 🔴 **The lesson is not "read the state back after." That was done, and it caught the error. The lesson is *read the device before executing a record built from a stale baseline* — and read the record next to it that says the whole thing is blocked.**
>
> **Charter Rule 13 says the device beats the document. This record was executed as if the document beat the device.**

### One accidental improvement, and it stands

The operator also ran the auth commands:

```text
ipmitool lan set 1 auth ADMIN MD5   (+ OPERATOR / USER / CALLBACK)
```

`Auth Type Enable` went from `MD2 MD5` to **`MD5`**. **MD2 is a broken hash.** Removing it from every privilege level is a genuine, if unplanned, improvement — and it is *not* what CM-0011 claimed to be doing (it was "fixing" a `NONE` that was never set). **Kept, and recorded as the one real outcome of an otherwise-void record.**

---

## What was actually true, and where it goes

| Finding | Reality | Handled now by |
|---|---|---|
| Cipher 0 | Already hardened (`XXXa`) before this ran | `CM-0012` (durability control sample) |
| Auth `NONE` | Never existed — capability list misread as a setting | — |
| MD2 enabled | Real, minor. **Removed this session.** | Recorded here |
| SNMP `public` | Real, but **inert** (channel disabled, no collector) | iDRAC onboarding build |
| 🔴 **iDRAC never onboarded** | **The actual finding.** No Lab CA cert, no vault entry, no named account, no build-guide section, not out-of-band, IPMI-over-LAN off. | 🔴 **iDRAC onboarding — a build guide, not a change** |

---

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| `201-Dell-PowerEdge-R410-Preparation.md` | 🔴 **Must update** | Has **no iDRAC section at all.** That absence — not cipher 0 — is the real gap. A rebuild produces an iDRAC with an IP and nothing else. |
| `CM-0012` | 🔴 **Must update** | Its cipher-0 ✅ is **void** — the exploit "failing" proved nothing, because the channel was disabled. Corrected in the CM-0012 rewrite. |
| `003-Physical-Topology.md` | **Reviewed — already corrected** | iDRAC shared-LOM correction landed separately (`006`/`024`/`028` v2.1). |

## Closeout

- [x] All three findings re-tested — **all void or misread**
- [x] IPMI-over-LAN confirmed **disabled** (`Access Mode : disabled`, Volatile + Non-Volatile)
- [x] Cipher degradation caused by executing this record — **reverted and verified** (`XXXa` restored)
- [x] MD2 removal — real improvement, retained
- [x] Real work (onboarding) **moved to a build guide** — there is nothing to *change*; there is nothing there
- [x] **Closed — substantially false**

## Note

**This is the cleanest example in the pack of the failure the pack exists to prevent — and it happened while closing the pack.**

A record said the BMC was wide open. The device said the channel was shut, the ciphers were already hardened, and "auth NONE" was a misreading of a capability list. **Three findings, zero real.** And the one action taken on the record's strength *degraded* the device, until a read-back caught it.

> **A change record is a hypothesis about the device. This one was falsified on every count — and the correct response is to record the falsification, not to delete the record.** The wrong hypotheses are as instructive as the right ones. More so, tonight.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-13 from a single `ipmitool lan print 1`. Proposed disabling cipher 0, auth NONE, default SNMP. |
| **2.0** | 🔴 **Closed as substantially FALSE, 2026-07-13.** Re-tested on the device: **IPMI-over-LAN is disabled** — no remote path exists. Cipher 0 was **already** `XXXa`, not `aaaa`. Auth `NONE` was a **misread** of the firmware capability list. Only SNMP `public` was real, and it is inert. **Recorded the execution error:** run against a stale baseline, it *degraded* the cipher config to `Xaaaa` before being reverted; MD2 removal kept as an accidental real gain. The actual finding — **the iDRAC was never onboarded** — moved to a build guide. Risk **Void**. |
