---
Title: Playbook — Confirm a Config Change Actually Took (read the value back, not the exit code)
Path: Atlas-Academy/Playbooks
Status: 🟡 Method authored, lab-unverified (`POL-0001`) — per-step read-backs land the first time this is worked on a device. Grounded in the real frozen **Lab-01** FGT01 incident (`MC-0001`) + the estate's most-repeated lesson (`016`/`015`). Searchable/ticket-ready per Backlog **#32**. Format-aligned to the locked `ADR-0053` §5 mold.
Version: 1.1
Date: 2026-08-01
---

# Playbook — Confirm a Config Change Actually Took

<!-- provenance -->
> **Book 9 — Atlas Academy · Playbook (`ADR-0053`).** Kind: verification discipline (all platforms). **You ran a `set` / `config` command, it returned no error — but did the change actually take effect?** A command *completing* is a claim, not evidence. This page is the reflex that catches a silent no-op: **read the running value back with the runtime read command, never trust the exit code and never read the config file.**

**Why this is the single most reusable drill in the estate (Backlog `#32`).** It is the lab's most-repeated (7×+) and most expensive lesson (`015`, `016`). In frozen Lab-01 it cost a multi-hour FGT01 diagnosis: every certificate step was done correctly, yet the admin GUI served the **factory** cert the whole time because `set admin-server-cert` had **silently not taken** — and `show` couldn't reveal it (`show` prints only non-default values, so it showed *nothing*). Only `get` exposed that the factory default was still bound (`MC-0001`). Every platform has its own version of this trap.

## On this page

1. **Symptoms & search terms** — find this page by what you're seeing.
2. **Cert anchor** · **the read-back rule, per platform** (the ❌-shows-intent vs ✅-read-the-running-value table).
3. **① Pin it down** — what changed, and do you have a *runtime* read-back.
4. **The diagnosis path** — runtime read → did the `set` apply → wire/cache/reload → survives a reboot.
5. **The fix** (+ prove it took) · **If still broken**.
6. **Worked example → `MC-0001`** · **Related · Worked log · Change Log**.

## Symptoms & search terms (find this page by what you're seeing — `#32`)

**Verbatim / near-verbatim strings you'd see or type**

- "*it ran, no error, but nothing changed*" / "*my change didn't take*."
- "*`show` shows nothing / empty output*" after a `set` (FortiOS `show` prints only non-default).
- "*the GUI still serves the old certificate*" / "*ERR_CERT_AUTHORITY_INVALID after I fixed the cert*."
- "*the config file says X but the device behaves like Y*."
- 🟡 (real read-backs land on-device): `get system global | grep admin-server-cert` → `Fortinet_GUI_Server` **after** you set a custom cert = the change didn't take.

**Plain-language symptom phrases**

- "I set it, it said OK, but it's not working."
- "the change looks applied but the device is acting like the old value."
- "did that command actually do anything?"
- "it works after a reboot but not before" (unsaved / not-applied).
- "the setting is in the config but the service is ignoring it."
- "I trusted the command succeeded and it didn't."

**Aliases / also-known-as**

- silent no-op · change didn't apply · setting didn't stick · phantom change · unconfirmed change.
- `show` vs `get` (FortiOS) · `show run` vs `show … status` (IOS) · `print` vs `print detail` (RouterOS) · config-file vs running-service.
- "read the value back" · "verify the running state" · "prove it took" · exit-code-is-not-evidence.
- browser TLS session cache hiding a server-side cert change (Incognito to confirm).

**Keywords line**

`get not show` · `admin-server-cert` · `MC-0001` · `show ntp status` · `print detail` · `s_client` · `w32tm /query` · `systemctl is-active` · running-config vs startup-config · `write memory` · read-back · `POL-0001` R-A1 · verify-the-change · silent-fail.

## Cert anchor

- CompTIA **ITIL/service-management** discipline (change verification) — the primary anchor.
- **FCP** (FortiOS `get` vs `show`), **CCNA** (`show … status` vs `show run`), **Linux+** (`systemctl`/`ss` vs the unit file), **MTCNA** (RouterOS `print detail`).
- *(Grounding index: every Command-Library platform page carries the read-back rule; this playbook is the cross-platform *why*.)*

## Grounded in — the read-back rule, per platform

The runtime read (not the config, not the exit code) is the only evidence (`POL-0001` R-A1). Each platform's own trap (`POL-0008` — the Command-Library owns the commands; this page links):

| Platform | ❌ shows *intent* / can lie | ✅ read the *running value* | The trap |
|---|---|---|---|
| **FortiOS** (FGT01) | `show …` | **`get …`** (+ `diagnose …`) | `show` prints only **non-default** → a silent-failed `set` shows *nothing*, not the default (`MC-0001`). |
| **Cisco IOS** (SW01, 1941) | `show run` | **`show … status`** | `show run` shows the config line; `show ntp status` showed `stratum 16` while the line was present (`CM-0030`). |
| **RouterOS** (MKT01) | `print` | **`print detail` / `print stats`** | plain `print` hides fields; last-write-wins means a later line can overwrite an earlier one (`016`). |
| **Linux** (Pi01, SRV01, PVE01) | the config file | **`systemctl is-active` / `ss -tlnp` / the tool's own status** | a config edit ≠ a reloaded service; the wrong file gets edited (Pi-hole v6 reads `pihole.toml`, not `custom.list`). |
| **the wire** (any TLS service) | the imported cert object | **`openssl s_client -connect … -showcerts`** | a `CA Certificate` import isn't attached to what the device *presents*; `\| grep -c "BEGIN CERTIFICATE"` must be **3**, not 1 (`MC-0001`). |
| **Windows** (DCs, members) | the GPO / registry intent | **`w32tm /query`, `gpresult`, the cmdlet's `Get-`** | applied ≠ effective; time source can be `Local CMOS` despite config. |

Command detail (link down — `POL-0008`): `../Command-Library/FortiOS.md`, `../Command-Library/Cisco-IOS.md`, `../Command-Library/RouterOS.md`, `../Command-Library/Linux.md`, `../Command-Library/PowerShell-Tier0.md` — each §read-back. Why-it-works: `../Concepts/README.md` (a command completing ≠ a change confirmed).

## ① Pin it down (capture these first — they're the ticket)

- a. **What you changed** — the exact setting, on which **device/platform**, and the command you ran.
- b. **Expected vs actual** — the value/behaviour you intended vs what the device is doing now.
- c. **What told you it "worked"** — the command returned no error? a GUI said "saved"? (That's the claim you're about to test — it is *not* evidence.)
- d. **Runtime vs config** — do you have a **runtime read-back**, or only the config line / your memory of the command? (If only the latter, you don't yet know it took.)
- e. **Saved & surviving a reboot?** — is the change written to startup, and does it need a service reload / process restart to be live?

## The diagnosis path — prove the running state, cheapest first

**1. Read the running value back with the *runtime* read command (not the config).**

- a. Use the ✅ column above for your platform:
  - FortiOS: `get <path> | grep <key>` (never `show`).
  - IOS: `show <feature> status` (never `show run`).
  - RouterOS: `… print detail` (never plain `print`).
  - Linux service: `systemctl is-active <unit>` + the tool's own status; `ss -tlnp` for a listener.
  - Windows: the matching `Get-` cmdlet / `w32tm /query /source` / `gpresult /r`.
  - Reference: the matching `../Command-Library/*` §read-back.
  - Healthy: the read-back shows **your new value**, active.
  - 🔴 Broken: it shows the **old/default** value (FortiOS: empty `show` output is the tell — go straight to `get`). 📸 the read-back that shows old-vs-new.

**2. If it's still the old value — did the `set` even apply, or silently no-op?**

- a. Re-issue the change and immediately re-read (don't assume the first one took).
- b. FortiOS specifically: `show` empty ≠ default set — confirm with `get system global | grep admin-server-cert` (the `MC-0001` command that found it unbound).
- c. RouterOS specifically: `print detail` — check a *later* line didn't overwrite yours (last-write-wins; `Verify-an-Edit-by-Counting-the-Old-Text.md`).

**3. If the running value is right but behaviour is still wrong — is it the wire, the cache, or a reload?**

- a. For a TLS/cert change, verify what's actually *served*, not what's imported:
  - `openssl s_client -connect <host>:<port> -showcerts | grep -c "BEGIN CERTIFICATE"`
  - Healthy: **3** (leaf + intermediate + root). Broken: **1** (bare leaf — the chain isn't attached).
- b. Browser still shows the old cert though the wire is correct → **TLS session cache**; confirm in Incognito / a fresh process (`MC-0001` step 25).
- c. Linux service change not live → the service didn't reload: `systemctl reload/restart <unit>`, then re-read.

**4. Will it survive a reboot? (saved ≠ running, running ≠ saved.)**

- a. IOS: `show archive` / running == startup; `write memory` if not.
- b. FortiOS/RouterOS persist on commit — confirm with the runtime read after a (planned) reload if it's load-bearing.

## The fix — make the change real, then re-prove

- a. Apply the change on the correct object, save/commit it, and reload the service if the platform needs it.
- b. **Re-run step 1's runtime read** — it must now show the new value.
- c. Exercise the actual behaviour (the service works, the cert is trusted, the clock syncs) — not just the config line.
- d. Never mark the task ✅ on the exit code or a config line; ✅ needs the pasted runtime read-back (`POL-0001`).

## Prove it took

- a. The runtime read-back shows the new value, active (📸 it).
- b. The dependent behaviour works end-to-end (the wire chain = 3, the clock = synchronized, the listener is bound, the GUI serves the new cert in a clean session).
- c. It survives a reboot / reload (startup == running).
- d. Mark ✅ only with the pasted read-backs.

## If still broken

- Read-back shows the new value but the feature still misbehaves → the problem is downstream (a dependency, a second setting, the wire/cache) — follow the platform's `diagnose`/status path.
- The value keeps reverting → something re-applies it (a template, GPO, config-management run, or a later line in the same script overwriting it — `Verify-an-Edit-by-Counting-the-Old-Text.md`).
- You can't get a runtime read at all → you cannot claim the change took; treat the task as **unverified 🟡**, not done.

## Worked example — the real Lab-01 case (`MC-0001`, device-verified)

> The estate's origin incident for this drill — FGT01, frozen Lab-01. **Authoritative record: `MC-0001`** (the CM/MC doc owns the incident; this walks it through the steps). Read-backs quoted from the frozen record (`POL-0001`).

- **① Pin it down.** Every certificate step for FGT01's admin GUI was done correctly; the GUI still served the **factory** cert. What said "it worked": `set admin-server-cert <name>` returned cleanly, no error. → `MC-0001`.
- **Step 1 — read the running value.** `show` printed **nothing** (FortiOS `show` prints only non-default) — which *looks* fine. `get system global | grep admin-server-cert` → **`Fortinet_GUI_Server`**: the **factory default was still bound** — the clean `set` had silently not taken. → `MC-0001` (the `get`-not-`show` finding).
- **Step 3 — the wire.** `openssl s_client … | grep -c "BEGIN CERTIFICATE"` exposed a **bare leaf** (`ERR_CERT_AUTHORITY_INVALID`) — a second compounding issue, visible only by reading what was actually *served*. → `MC-0001`.
- **The fix + prove it.** Re-bound the cert to the correct object; re-ran `get` → the new value active; confirmed in a **fresh/Incognito** session (the TLS cache had hidden it). → `MC-0001`.
- **The lesson.** A multi-hour diagnosis collapses to seconds once you read the running value with **`get`, not `show`** — the estate's 7×-repeated rule (`015`/`016`).

## Related

- **Command-Library (the read-back commands):** `../Command-Library/FortiOS.md` · `../Command-Library/Cisco-IOS.md` · `../Command-Library/RouterOS.md` · `../Command-Library/Linux.md` · `../Command-Library/PowerShell-Tier0.md` — each §read-back / §status.
- **Concepts:** `../Concepts/README.md` (a command completing ≠ a change confirmed — the recurring theme).
- **Sibling playbooks:** `Verify-an-Edit-by-Counting-the-Old-Text.md` (the doc/script twin — count what must be *gone*) · `Fix-the-SW01-Clock.md` (`show run` says `ntp server`, `show ntp status` says stratum 16) · `Find-the-Stale-Source-File-You-Edited.md` (the wrong file edited) · `Diagnose-a-Host-Silently-Dropped-by-DAI.md` (another silent-drop that only a read-back reveals).
- **Backlog:** `#32` (the searchable, ticket-ready, offline-briefcase goal).
- **Real lineage:** frozen Lab-01 `Devices/FGT01-NS-Firewall/Changes/MC-0001` (the four-compounding-issues cert diagnosis; the `get`-not-`show` root cause) · `Operations/016-Network-Lessons-Learned.md` + `015-Network-Validation-Guide` (the 7×-repeated read-the-value-back rule) · `CM-0033` (the `get`-not-`show` note reaffirmed) — `ADR-0022`-reconciled.

## Worked log

| Date | Who | Time | Device/setting | Read-back used | Took? | Outcome |
|---|---|---|---|---|---|---|
| _(add a row each time this playbook is actually run — `POL-0001`)_ | | | | | | |

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-08-01 | **Format-aligned to the locked mold** (Playbook Format-Alignment Audit, row 1) — added the **On this page** quick-nav index and a **Worked example → `MC-0001`** section quoting the frozen read-backs (`get` → `Fortinet_GUI_Server`; the bare-leaf `s_client` count). Content unchanged; DOCS-ONLY (the read-backs are quotable from the frozen record — no device run needed for completeness). |
| 1.0 | 2026-07-31 | Created (`ADR-0053` §5, golden mold + the new **Symptoms & search terms** element `#32`). The estate's single most reusable verification drill: a command completing is a claim, not evidence — read the *running value* back with the runtime read (`get` not `show`; `show … status` not `show run`; `print detail` not `print`; `systemctl`/`ss` not the config file; `s_client` on the wire; `w32tm /query` on Windows). Cross-platform read-back table + a four-step path (runtime read → did the set apply → wire/cache/reload → survives reboot). Grounded in the frozen Lab-01 `MC-0001` (silent `set admin-server-cert` no-op found only by `get`) and the 7×-repeated `015`/`016` lesson. 🟡 until worked on a device. |
