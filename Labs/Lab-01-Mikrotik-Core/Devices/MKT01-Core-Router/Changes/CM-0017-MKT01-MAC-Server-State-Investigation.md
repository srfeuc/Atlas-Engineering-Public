---
Title: CM-0017 MKT01 MAC-Server State Investigation
---

# CM-0017 — MKT01 Has Never Had a Working MAC-Connect Recovery Path

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | ✅ **Closed 2026-07-14.** Investigation complete; guide reconciliation complete (`026` rewritten; `003`/`048`/`016`/`022` corrected; `001`/`006` model + SSD corrected 2026-07-15). **Remaining items (serial console) explicitly deferred by `ADR-0016`.** |
| Risk | **Informational.** 🔴 **No change was made to the device.** The finding is that a documented recovery path **does not exist and never did.** |
| Affected systems | MKT01 — `/tool mac-server`, `/tool mac-server mac-winbox`, `/ip neighbor discovery-settings` |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — live device output, a live MAC-connect test, **and a configuration export predating the investigation** |
| Related | `ADR-0014`, `CM-0018`, `003-Physical-Topology.md`, `026-MKT01-Build-Guide.md`, `048-Teardown-and-Rebuild-Runbook.md`, `016-Network-Lessons-Learned.md` |

> **v1.0 of this record was WRONG, and it is retained below rather than deleted, because how it was wrong is the most useful thing in it.**

## 🔴 What v1.0 claimed, and why it was false

**v1.0 stated that a `026` §12 hardening block was accidentally pasted into MKT01, disabling MAC-WinBox, destroying the prior state, and breaking the recovery path. It recorded the prior state as *"UNKNOWN and unrecoverable."***

**Then the operator produced `mkt01-pre-CM-0009.rsc` — an export from `2026-07-13 16:06:49`, the day before:**

```text
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
```

**MAC-WinBox was already `none`. The paste set `none` to `none`. It was a no-op. Nothing was changed, nothing was destroyed, and there was never a Layer-2 exposure to close.**

### How the false conclusion was built

1. The operator observed MKT01 in WinBox's **Neighbors** list — with IP, MAC, identity, RouterOS version, board model, uptime — and reported that one *"can just connect to the WinBox GUI."*
2. **That was an assumption, not an observation.** Being *listed* in Neighbors is `discover-interface-list=static` advertising. **It is not evidence that a MAC connection is accepted.**
3. The analysis took the report as fact, inferred `allowed-interface-list=all`, and **reasoned confidently from the inference** — producing a security finding, an ADR, and a remediation record for a hole that did not exist.
4. **The live test refused the connection.** That result was *correct*, and it was misread as *"the paste broke it"* rather than *"it was never open."*

> 🔴 **The device was telling the truth the entire time. The narrative was not.**
>
> **`016` lesson 4 is *a test that cannot fail proves nothing.* This is its mirror image: an observation that was never made cannot support a conclusion.** *"It shows up in Neighbors, so you can connect"* is a plausible inference, and it is not a reading.
>
> **Charter Rule 13 says the device beats the document. This record adds: the device also beats the analysis — including a confident one, including this one.**

## The findings that survive — and they are the important ones

### 🔴 1. `026` builds a router that `048` cannot recover

| Document | Line | Says |
|---|---|---|
| `026-MKT01-Build-Guide.md` | 73 | *"Stay connected via **MAC address** in WinBox's Neighbors tab. IP access will be interrupted."* — **the build depends on MAC-connect** |
| `026-MKT01-Build-Guide.md` | §12 | `/tool mac-server mac-winbox set allowed-interface-list=none` — **and then turns it off** |
| `048-Teardown-and-Rebuild-Runbook.md` | 123, 128 | *"WinBox → Neighbors → connect by MAC… **your single most important bootstrap tool**… **the keystone.**"* |
| `003-Physical-Topology.md` | 69, 74 | **MKT01's only listed bootstrap method.** *"The keystone of any recovery."* |

> 🔴 **A router rebuilt from `026` cannot be bootstrapped by `048`.** The build guide leaves the device in exactly the state the rebuild runbook declares impossible.
>
> **This has been true since both documents were written. Nobody found it, because nobody has ever rebuilt** — which is the entire premise of `ADR-0011`.

### 🔴 2. MKT01 has no out-of-band path of any kind

**A repository-wide search finds no serial console documented for MKT01.** Every occurrence of *"serial"* in Book 1 is a certificate serial number.

| Device | Out-of-band path |
|---|---|
| SW01 | ✅ Serial console, 9600 8N1 |
| FGT01 | ✅ Serial console **and** `https://192.168.1.99` on the hard-switch ports |
| PVE01 | ✅ Physical console/keyboard *(iDRAC is shared-LOM and **not** independent)* |
| 🔴 **MKT01** | 🔴 **NOTHING.** |

**The RB1100 has a physical console port. It has never been wired, documented, or tested.** **The lab's core router — the device that owns every VLAN gateway — is one addressing mistake away from requiring a factory reset.**

### 3. The discovery disclosure is real

`discover-interface-list=static` — **the router advertises its identity, RouterOS version, board model, uptime and port on every static interface, including every VLAN.** A host on VLAN 50 (Client) or VLAN 20 (Servers) can read MKT01's patch level and board model for free.

**It provides no recovery benefit** — MAC-WinBox refuses the connection anyway. **We have the disclosure without the capability.**

### 4. Two facts the Build Record has never recorded

- 🔴 **`022-MKT01-Build-Record.md` does not mention `mac-server` at all.** An administrative state, set deliberately in the build guide, **that no record has ever captured.** *"Available" is not a state* (`016` lesson 9) — **and neither is unmentioned.**
- 🔴 **MKT01 is an `RB1100Dx4` with a 64 GB SATA SSD.** Confirmed from the export header and its `/disk` section. **The SSD appears in no document in the repository.** `022` and `026` correctly say *"RB1100AHx4 Dude Edition"*; `001`, `006` and `016` say plain *"RB1100AHx4"*. **The storage — the capability that makes this device a viable services host — is undocumented everywhere.**

## Current state — verified

```text
/tool mac-server print                → allowed-interface-list: none
/tool mac-server mac-winbox print     → allowed-interface-list: none
/ip neighbor discovery-settings print → discover-interface-list: static
```

| Test | Result |
|---|---|
| WinBox → IP `10.10.0.1` | ✅ **Works.** Management access intact. |
| WinBox → Neighbors → **MAC** | 🔴 **Refused** — and has been all along |
| MKT01 visible in Neighbors from a VLAN, with version/board/uptime | 🔴 **Yes** |

**Unchanged and confirmed correct:** `/ip service` (`ftp`, `telnet`, `www`, `api`, `api-ssl` disabled; `reverse-proxy` disabled per `CM-0006`; `ssh` 2222, `winbox` 8291, `www-ssl` 443 all restricted to `10.0.0.0/24` + `10.10.0.0/24`); `www-ssl` cert `mikrotik-bundle.crt_0`; **`vlan70-testing` absent from the `VLANs` list — the isolation is real.**

## 🟡 Unexplained — do not assume

`/ip service print` returns **two** WinBox rows:

```text
 8     winbox   8291  tcp   10.0.0.0/24, 10.10.0.0/24
 9 D c winbox   8291  tcp   (no address restriction)
```

Row 9 is `D` (dynamic) + `c` (connection). **Most likely an artefact of the live administrative session — but that is an inference, and this record exists because of an inference.** **Verify with `/ip service print detail`, and confirm it disappears when no WinBox session is connected.**

## 🔴 Do NOT restore `mkt01-pre-CM-0009.backup`

**It is a time machine to before two closed change records.**

| In the export | Restoring would |
|---|---|
| `dst-address=10.0.0.5`, `"FortiGate RADIUS to Pi-hole"` — **the dead RADIUS rules** | **Undo `CM-0009`** |
| **24 firewall filter rules** | Re-add both dead rules (current: 22) |
| **No `ether2` disable** | **Undo `CM-0015`** — `ether2` returns enabled, idle, undocumented |

**And there is nothing to restore.** The device was never changed. **Keep the export as evidence — it is `hide-sensitive` and safe to commit — but do not apply it.**

> **This export is the most valuable artefact in the repository right now.** It is the only thing that has been able to falsify a *narrative* rather than a *document*. **`016` lesson 12 says every safety net that worked was one that failed loudly. This one failed loudly at the right moment.**

## Root cause of the v1.0 error

**A build guide was quoted, in a chat message, as illustrative text. It contained live `set` commands. The operator pasted it, reasonably.**

**Prevention, adopted:** configuration blocks quoted for discussion are described in prose or explicitly marked non-executable. **Any block of device commands, in any medium, will eventually be pasted into a device. Assume it will be.**

**This remains a real lesson even though the paste was harmless.** It was harmless by luck — the commands happened to be idempotent. **Had `026` §12 contained a destructive line, the outcome would have been identical in every respect except the damage.**

## Guide Reconciliation — Charter Rule 15

| Guide | Outcome | Detail |
|---|---|---|
| ✅ `026-MKT01-Build-Guide.md` | **Done** (`CM-0021`) | §12 rewritten to build the `RECOVERY` path; `mac-winbox=RECOVERY` verified on the device. No longer contradicts line 73. |
| ✅ `048-Teardown-and-Rebuild-Runbook.md` | **Done** (2026-07-14) | Phase 1 corrected: connect by MAC into `ether4`, ~15 s drop, **no serial console** — the bootstrap claim now matches reality (`CM-0018`, `ADR-0016`). |
| ✅ `003-Physical-Topology.md` | **Done** (2026-07-14) | Bootstrap corrected to MAC-connect into `bridgeLocal`, built and tested (`CM-0018`); now records that MKT01 has **no console**. |
| ✅ `016-Network-Lessons-Learned.md` | **Done** (v3.1, 2026-07-15) | Lesson 19 added: a Layer-2 management protocol bypasses every IP control — `/ip service` address lists and the input-chain deny do not apply to MAC-WinBox. |
| ✅ `022-MKT01-Build-Record.md` | **Done** (v2.7) | Layer-2 Management State section records `mac-server`, `mac-winbox`, discovery, and the **64 GB SATA SSD**. |
| ✅ `001`, `006` | **Done** (v2.2, 2026-07-15) | Model corrected to `RB1100Dx4` (AHx4 Dude Edition) with the **64 GB SATA SSD**, transcribed from `022`'s device-verified Platform table. |

## Closeout

- [x] Live state read back off the device
- [x] MAC-connect refusal **confirmed by test**, not assumed
- [x] **Prior state RECOVERED** from `mkt01-pre-CM-0009.rsc` — `none` since at least 2026-07-13 16:06
- [x] v1.0's false premise identified, corrected, and retained
- [x] Confirmed **no device change occurred**
- [x] Export confirmed `hide-sensitive` — no secrets
- [x] ✅ `ADR-0014` **Accepted** 2026-07-14 (Option C)
- [x] ✅ `CM-0018` executed — **MAC-connect from `ether4` TESTED AND CONNECTED.** Drops after ~15s (`ADR-0016`).
- [x] 🔴 **Serial console DEFERRED by `ADR-0016`** — three USB-serial adapters bought, none worked. **Recorded as a decision, not an omission.**
- [x] 🟡 Dynamic WinBox service row — **still unexplained. Carried to Book 10.** Almost certainly a live-session artefact; **not verified, and labelled as such.**
- [x] ✅ **Guide reconciliation complete** — `026` §12 **rewritten** (not annotated); `003`, `048`, `022` corrected to the device; `016` gained lesson 19 (v3.1); `001`/`006` model + 64 GB SSD corrected (v2.2). **All six targets done — the last three completed 2026-07-15.**
- [x] ✅ **Closed 2026-07-14**

> 🔴 **A record does not move to `Closed` while any box is unticked.** All boxes above are now ticked and all six guide-reconciliation targets are complete (2026-07-15) — the `Closed` status is accurate.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14. **Claimed an accidental paste disabled MAC-WinBox and destroyed the prior state.** |
| **2.0** | 🔴 **2026-07-14 — v1.0 was FALSE.** `mkt01-pre-CM-0009.rsc` (2026-07-13 16:06) shows `mac-winbox: none` **already set.** The paste was a **no-op**; no change occurred; no Layer-2 exposure ever existed. The conclusion was built on an inference from an assumption. **Retained rather than deleted, per `ADR-0012`** — how it was wrong is the most useful part. **The surviving findings are larger than the false one:** `026` builds a router `048` cannot bootstrap; MKT01 has **no out-of-band path of any kind**; the discovery disclosure is real; and the Build Record has never recorded `mac-server` **or the 64 GB SSD.** |
