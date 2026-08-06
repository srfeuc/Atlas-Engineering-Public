# CM-0030 — SW01's Clock Has NEVER Synchronised. It Is Pointed at a Host That Serves No Time.

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: SW01 - Role: Access Switch

| Item | Value |
|---|---|
| Status | **Open** |
| Risk | 🔴 **Medium — and it is the foundation Book 5 is supposed to be built on.** |
| Affected systems | **SW01** (confirmed). FGT01 checked → **syncs** (`pool.ntp.org` stratum 2, `059`/`CM-0033`); MKT01 checked → **syncs** (client, stratum 1); PVE01 still unverified (CMOS battery, `036`). |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — live device output, SW01, 2026-07-14; **re-verified 2026-07-16** (`056` reconcile: stratum 16 + `show ntp associations` `.INIT.` reach 0) |
| Related | **`ADR-0020`** (time-source decision), `CM-0022`, `045`, `056`, `057`, `023`, `027`, `029`, `013`, `015`, `016` lesson 4 |
| Found by | The Book 1 audit (`ADR-0019`), running `show ntp status` because `026`'s device pass raised the question |

---

## 🔴 The finding

```
SW01# show ntp status
Clock is unsynchronized, stratum 16, no reference clock
nominal freq is 286.1023 Hz, actual freq is 286.1023 Hz
reference time is 00000000.00000000 (18:00:00.000 CST Thu Dec 31 1899)
clock offset is 0.0000 msec, root delay is 0.00 msec
loopfilter state is 'FSET' (Drift set from file), drift is 0.000000000 s/s
system poll interval is 8, never updated.
```

```
SW01# show run | include ntp
ntp server 10.10.0.5
```

🔴 **`never updated`. Stratum 16 (= unsynchronised). Reference time: 1899.**

> 🟢 **Re-verified 2026-07-16 (`056` reconcile).** Still stratum 16, `never updated`. And `show ntp associations` now names the reason from the switch's own side of the wire:
>
> ```
> SW01# show ntp associations
>   address         ref clock       st   when   poll reach  delay  offset   disp
>  ~10.10.0.5       .INIT.          16      -   1024     0  0.000   0.000 15937.
> ```
>
> 🔴 **`.INIT.`, `reach 0`, no `*`.** The peer has **never answered once** — not a sync that drifted, a sync that never began. This is the SW01-side confirmation of the Pi01-side fact below.

## 🔴 Why — `10.10.0.5` is Pi01, and Pi01 serves no time

| Device | NTP **server**? | Evidence |
|---|---|---|
| **Pi01** (`10.10.0.5`) | 🔴 **NO** | `029-Pi01-Build-Record.md` lists **no NTP service.** `Atlas-Service-Architecture.md` proposes *"NTP (chrony) — **ADD**"* to Pi01 — i.e. **it is not there.** `046` §2.3 ticks *"time synchronization configured"* — that is **`systemd-timesyncd` as a CLIENT.** 🟢 **`053` row 4 (2026-07-16) confirms: `systemd-timesyncd` active, nothing LISTENING on UDP 123.** |
| **MKT01** | 🔴 **NO** | `/system ntp server print` → **`enabled: no`** *(device-verified 2026-07-14)*. Its `/system ntp client` is `pool.ntp.org`, synced, stratum 1 — **a client.** |

> 🔴 **There is no NTP server anywhere in Atlas. SW01 has been asking a Raspberry Pi for the time, and the Pi has never been listening.**

## 🔴 The false tick — and it is the pack's own lesson, again

**`045-SW01-CIS-Hardening-Checklist.md` §2.3, as originally committed:**

> `[x]` **NTP configured and synchronized** — *"confirmed live during original SW01 validation."*

🔴 **It is not synchronised. It has never been synchronised. The device says `never updated`.**

> 🟢 **CORRECTED 2026-07-16.** `045` v1.1 §2.3 now reads *unticked*, with the `show ntp status` / `show ntp associations` evidence and a pointer here. The false tick is closed; the underlying clock is still broken (that is the rest of this record).

> **`016` lesson 4: *a test that cannot fail proves nothing.*** **This is its sibling: a test nobody ran, ticked from a config line.**
>
> **`015-Network-Validation-Guide.md` v2.0 says it in its own words:** *"A command completing without an error is not a confirmed change. **Read the resulting state off the device.**"*
>
> 🔴 **`ntp server 10.10.0.5` is a config line. `show ntp status` is the state.** **Nobody read it back.**

**`047` (FGT01) and `046` (Pi01) both tick NTP too.** 🟢 **Both now checked: FGT01 syncs (`059`/`CM-0033`); Pi01 is a client, not a server (`053`).**

## 🔴 Why this matters more than it looks

**A wrong clock does not fail loudly. It corrupts everything that depends on it, silently.**

| Depends on the clock | What breaks |
|---|---|
| 🔴 **Syslog / SIEM correlation** (Book 5) | **Events from SW01 cannot be ordered against events from anything else.** **This is the entire premise of centralised logging** — and the Roadmap calls Book 5 *"the highest-leverage unbuilt book, blocking nine open items."* **It would be built on a switch whose timestamps are meaningless.** |
| **Certificate validity** | `notBefore`/`notAfter` are evaluated against the local clock. **A switch at 1899 considers every Lab CA certificate not-yet-valid.** *(SW01 has no TLS today — so this is latent, not live.)* |
| **Kerberos** (Book 3/4) | **>5 minutes of skew and authentication fails outright.** `Build-Order` names this explicitly. |
| **Log forensics** | 🔴 **`038` records Pi01's unexplained hard hang with "root cause never found."** **Correlating that against SW01's logs is impossible** — one of the two has no clock. |
| **`ADR-0009`'s review trigger** | *"Book 5 goes live and shows anything anomalous **in the 2026-07-12/13 window**."* 🔴 **You cannot query a window on a device that does not know what time it is.** |

## Remediation

### 🔴 Step 0 — Find out how far this goes. Do NOT assume it is only SW01.

```text
SW01:   show ntp status                        # ✅ done — stratum 16 (re-verified 2026-07-16)
FGT01:  get system ntp                          # ✅ done — SYNCS, stratum 2 (059 / CM-0033)
MKT01:  /system ntp client print                # ✅ done — SYNCS, stratum 1 (client)
PVE01:  timedatectl                             # ⏳ pending — CMOS battery makes this its own story (036)
Pi01:   timedatectl ; ss -ulnp | grep :123      # ✅ done — timesyncd client, NOTHING on :123 (053)
```

> 🟢 **Step 0 is now substantially answered.** Only SW01 is actually broken. The others either sync as clients (FGT01, MKT01, Pi01's own clock) or are gated (PVE01). **The problem is one device pointed at a non-server — not a fleet-wide outage.**

### Step 1 — Decide where time comes from. **This is a design decision, not a config change.**

| Option | For | Against |
|---|---|---|
| **A — Point every device at `pool.ntp.org` directly** | **Zero new infrastructure. Works today.** MKT01 already does this and is stratum 1. | Every device needs outbound 123. **No internal source of truth.** No stratum hierarchy to learn. |
| 🟢 **B — Add `chrony` as a SERVER on Pi01** *(`Atlas-Service-Architecture` already proposes this)* | **A real lab stratum source. Directly on the CCNA syllabus.** **`023`/`027` already point SW01 at Pi01 — the config becomes TRUE instead of aspirational.** | **Adds a fifth production service to a Pi that `ADR-0015` says is *"over-trusted"* and has hard-hung once.** |
| **C — Wait for Windows AD** | The documented target (`013`, `Build-Order`). | 🔴 **Book 3 does not exist. This is broken NOW.** **"The target" is not a fix.** |

> 🟢 **DECIDED 2026-07-16 — `ADR-0020`** (the operator's call, Rule 16). **Target: the AD PDC-emulator is Atlas's authoritative internal source.** **Interim: point SW01 at the external pool FGT01 and MKT01 already use** — *not* a chrony server on Pi01. Option B (chrony on Pi01) was considered and rejected as interim: it piles a fifth service onto the over-trusted Pi (`ADR-0015`/`ADR-0004`) to build an authority AD obsoletes the day it lands.
>
> 🔵 **Why AD is the better end state:** Kerberos mandates <5-min skew fleet-wide, so promoting DC01 *forces* a correct time hierarchy into existence; and the PDC-emulator *is* the authoritative source as a role it already holds — the internal source, the stratum hierarchy and the client config all come from infrastructure that must exist and be correct anyway, instead of a service we stand up, back up and throw away. Full reasoning in `ADR-0020`.

### Step 2 — Configure, then **PROVE it**

```text
show ntp status
```

🔴 **Expected: `Clock is synchronized, stratum <n>`.**
🔴 **`stratum 16` / `never updated` means it is syncing to NOTHING — regardless of what `show run` says.**

```text
show ntp associations
```
**A `*` next to a server means it is the chosen sync peer. No `*` = no sync.** *(Today: `~10.10.0.5 .INIT. reach 0` — no `*`.)*

---

## Reconciliation — all document types (`ADR-0019`)

| Document | Outcome | Detail |
|---|---|---|
| ✅ **`027`** | **Updated** | **`CM-0022`.** NTP now carries a **proof step**, and the guide states plainly that Pi01 serves no NTP. |
| ✅ **`045`** | **Updated 2026-07-16** | 🟢 **Its false `[x] NTP configured and synchronized` tick is now unticked** (`045` v1.1 §2.3), with the status/associations evidence and a pointer here. |
| ✅ **`056`/`057`** | **Created 2026-07-16** | SW01 verification battery (`056`, Batch B) captures the clock check; `057` row 1 tracks the clock as the top device-gated risk. |
| 🔴 **`046`, `047`** | **checked** | Both ticked NTP. 🟢 Now verified: Pi01 is a client (`053`); FGT01 syncs (`059`). Update the tick wording in each to say *client* / *syncs*, not "synchronized server". |
| 🔴 **`023`** | **MUST UPDATE** | Records `NTP server: 10.10.0.5 (Pi-hole, interim)` as verified state. **The device has never synced to it.** Its Known-Deviations NTP row should say *never syncs* (`CM-0030`), and its `Live hostname CoreSwitch` field is disproven — device is `SW01` (`CM-0022`). |
| 🔴 **`029`** | **MUST UPDATE** | **Record explicitly that Pi01 runs NO NTP server** — its absence is what makes three other documents wrong. 🟢 `053` now states it; carry it into `029` too. |
| 🔴 **`015`** | **MUST UPDATE** | **Add `show ntp status` / `get system ntp` to the standing validation.** **`015` v2.0 has no clock check at all** — and its own opening rule is *"read the resulting state off the device."* |
| 🔴 **`013`** | **MUST UPDATE** | *"NTP — public NTP today (`pool.ntp.org`)."* **True for MKT01 and FGT01. FALSE for SW01, which is synced to nothing.** |
| **`016`** | 🔴 **MUST UPDATE** | 🔴 **New lesson: A CONFIG LINE IS NOT A WORKING SERVICE. `ntp server <ip>` was present, correct-looking, and pointed at a host that does not run NTP — for the entire life of the switch. `show run` showed the intent. `show ntp status` showed the truth. Nobody ran the second one.** |
| **Book 5 (`05-Monitoring-and-Logging`)** | 🔴 **BLOCKED — named** | 🔴 **Do not build centralised logging on devices whose clocks are unsynchronised.** **Timestamps are the ONLY thing that makes correlated logs mean anything.** **This record is a prerequisite.** |

---

## The lesson

> 🔴 **`ntp server 10.10.0.5` sat in SW01's running-config, looking correct, for the entire life of the switch — pointed at a host that does not run NTP.**
>
> **`show run` showed the INTENT. `show ntp status` showed the TRUTH.** **Nobody ran the second one, and a checklist ticked the box from the first.**

**This is `016` lesson 1 — *"a command completing without an error is not a confirmed change"* — applied to a **service** rather than a command.** **The config was accepted without error. The service never worked.**

> **And it is `016` lesson 6's shape too: *"never guess" needed a second half — and never omit."*** **`029` does not record that Pi01 has no NTP server. That ABSENCE is what made `023`, `027` and `045` all wrong at once.**

---

## Closeout

- [x] 🔴 **Step 0** — `show ntp status` / `get system ntp` / `timedatectl` across the fleet. **Answered 2026-07-16: only SW01 is broken** (FGT01/MKT01/Pi01 sync as clients; PVE01 gated on CMOS, `036`).
- [x] 🔴 **`ss -ulnp \| grep :123` on Pi01** — 🟢 **nothing listening (`053` row 4).** Pi01 is not an NTP server.
- [x] **Design decision made and RECORDED** — 🟢 **`ADR-0020`** (2026-07-16): AD PDC-emulator target, **external-pool interim for SW01**, chrony-on-Pi01 explicitly rejected. *(Config + proof below still open.)*
- [ ] Configured on SW01
- [ ] 🔴 **PROVEN** — `show ntp status` returns **`Clock is synchronized`**. **Not a config line. The status.**
- [x] `045`'s false tick corrected *(2026-07-16, `045` v1.1)* · [ ] `046`/`047` tick wording tightened to *client/syncs*
- [ ] `023`, `029`, `013`, `015` reconciled
- [ ] `016` updated with the lesson
- [ ] **Book 5 unblocked** — or the block recorded
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.** The clock itself is still broken — only the *documentation* false-tick and the *scope* question have closed.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`). 🔴 **`show ntp status` on SW01: `Clock is unsynchronized, stratum 16, no reference clock`, reference time 1899, `never updated`.** It is pointed at `10.10.0.5` (Pi01) — **and Pi01 runs no NTP server.** Neither does MKT01 (`/system ntp server` → `enabled: no`). **There is no NTP server anywhere in Atlas.** 🔴 **`045` ticks *"NTP configured and synchronized — confirmed live."* The tick is false — it was read from a config line, never from the device.** 🔴 **Book 5 (centralised logging) cannot be built on devices with meaningless timestamps. This record is a prerequisite.** |
| 1.1 | **2026-07-16 — SW01 reconcile-to-live pass (`056`).** Re-verified stratum 16 / `never updated`, and added the SW01-side proof via `show ntp associations`: peer `10.10.0.5` is `.INIT.`, `reach 0`, no `*` — never answered once. **Step 0 substantially closed:** only SW01 is broken (FGT01 syncs stratum 2 per `059`; MKT01 syncs stratum 1 client; Pi01 confirmed no `:123` listener per `053`; PVE01 still gated on the CMOS battery, `036`). **`045`'s false tick corrected** in v1.1 and the clock seeded as `057` row 1. Design decision (A/B/C), the SW01 config, and the proven `Clock is synchronized` remain open — **record stays Open.** |
| 1.2 | **2026-07-16 — design decision recorded.** `ADR-0020` accepts the **AD PDC-emulator as the authoritative time target** with an **external-pool interim for SW01** (rejecting a chrony server on Pi01 per `ADR-0004`/`ADR-0015`; AD is better because Kerberos forces coherent time and the authority comes free with the FSMO role). Step 1 closed. **Step 2 — configure SW01's interim source and prove `Clock is synchronized` — remains open, so the record stays Open.** |
