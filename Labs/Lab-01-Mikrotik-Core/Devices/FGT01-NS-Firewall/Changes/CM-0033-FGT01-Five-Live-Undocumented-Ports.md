# CM-0033 — FGT01: Five Live Undocumented Ports, a Factory DMZ, NTP Bound to a Dead Interface, and Address Objects That Do Not Exist

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

| Item | Value |
|---|---|
| Status | **Draft** |
| Risk | 🟡 **Medium.** No live exposure found. 🔴 **But six facts about the perimeter firewall appear in no Atlas document, and `025` rebuilds four of them wrong.** |
| Affected systems | **FGT01.** *(Documentation: `021`, `025`, `010`, `047`, `013`, `015`.)* |
| Date raised | 2026-07-14 |
| Evidence Status | **`Verified`** — live device output, FGT01, 2026-07-14. **`get`, not `show`** (`016`). |
| Related | `CM-0004`, `ADR-0005`, `CM-0030`, `010`, `047`, `051` (findings B1–B4, C6–C8) |

> **`CM-0004` disabled the four factory interfaces it knew about. This record is about the ones it did not.**
>
> 🔴 **`016` lesson 9: *"an undocumented enabled interface is not low-risk — it is UNASSESSED."*** **Five of them.**

---

## 🔴 Finding 1 — `internal3`–`internal7` are UP. They are in no document.

```
FGT01 # get system interface
== [ internal3 ]  name: internal3   status: up    type: physical
== [ internal4 ]  name: internal4   status: up    type: physical
== [ internal5 ]  name: internal5   status: up    type: physical
== [ internal6 ]  name: internal6   status: up    type: physical
== [ internal7 ]  name: internal7   status: up    type: physical
```

**`CM-0004` disabled `internal`, `wan2`, `fortilink` and `modem`. Device-confirmed, all four `status: down`.** ✅

🔴 **`internal` is the hard-switch GROUP. It is down. Its five MEMBER PORTS are up.**

**`021`'s Interfaces table records:** *"`internal3-7` — Unassigned"*. **It does not say enabled. It does not say disabled. It says nothing.**

**`010-Security-Zones.md`, Unused Interface Policy:**

> *"Any interface, port, or logical connection with **no assigned purpose and nothing connected to it** must be **administratively disabled**, not merely left undocumented at its default state."*
> *"This applies uniformly: switch ports, **firewall interfaces**, router interfaces, **hard-switch groups**…"*

🔴 **`010`'s compliance table lists FGT01 as ✅ compliant, based on the four `CM-0004` interfaces. It never enumerated the hard-switch members.**

### 🔴 But there is a REASON they are up — and it is load-bearing

**`003-Physical-Topology.md` and `048` Phase 1, FGT01's bootstrap row:**

> *"**`https://192.168.1.99`** on the `internal` hard-switch ports (**internal3–7**). Laptop static `192.168.1.10/24`."*

🔴 **That is FGT01's break-glass path. It requires these ports to be up.**

> 🔴 **So this is `010`'s SECOND clause, not its first:**
>
> *"If an interface must stay enabled for a reason that isn't 'actively passing production traffic today', **that reason is written down in the device's Build Record.** An enabled-but-idle interface **without a documented reason** is the exact gap this rule exists to prevent."*
>
> 🔴 **The reason exists. It is real. It is written in `003` and `048` — and NOWHERE in `021`, `025`, `010` or `047`.**
>
> 🔴 **Nobody assessed these ports, because nobody knew they were on.** **A future hardening pass would have disabled them — and destroyed FGT01's only IP-based recovery path.**

**This is `CM-0016`'s lesson inverted.** *There, a correct-sounding label (`;;; Legacy flat management`) invited deletion of a load-bearing control. Here, an UNMENTIONED state leaves a load-bearing control one hardening pass from destruction.*

## 🔴 Finding 2 — `dmz` is UP at the factory address, in no document

```
== [ dmz ]  name: dmz   mode: static   ip: 10.10.10.1 255.255.255.0   status: up
```

🔴 **A live Layer-3 interface on the perimeter firewall, at a factory address, that:**

- is **not** in `CM-0004` *(which disabled four — this is a fifth)*
- is **not** in `010`'s compliance table
- **is** in `021`'s Interfaces table — as *"Factory default (10.10.10.1/24)"* — **with no state and no action**
- is **not** in `025` — **so a rebuild leaves it exactly like this**

**`10.10.10.1/24` overlaps nothing in Atlas** *(VLAN 10 is `10.10.0.0/24`)* — **but it is one typo away from doing so**, and `007-IP-Addressing-Strategy` never reserves it.

**And VLAN 80 IS the DMZ**, routed by MKT01 at `10.80.0.1`. **This interface is a factory relic with a confusable address and no purpose.**

## 🔴🔴 Finding 3 — FGT01's NTP is bound to `fortilink`, and `fortilink` is DOWN

> 🟢 **CORRECTION — device-verified 2026-07-16. THIS FINDING'S CONCLUSION WAS WRONG. Recorded, not hidden.**
>
> This finding was inferred from `get system ntp` alone and **never ran `diagnose sys ntp status`.** The follow-up reads disprove it:
> - `show full-configuration system ntp` → `config ntpserver / edit 1 / set server "pool.ntp.org"` with per-server `set interface-select-method auto`. **The server IS set** — the `get` runtime view had truncated it.
> - `diagnose sys ntp status` → **`synchronized: yes`**, `pool.ntp.org` selected at **stratum 2**; `execute time` → last sync minutes earlier.
>
> 🔴 **FGT01's clock WORKS.** It egresses via `wan1` (per-server `auto`), not the down `fortilink`. The global `set interface "fortilink"` is a harmless leftover the per-server method overrides; `server-mode enable` is a cleanup item, not a break. **`021`'s plain "NTP: pool.ntp.org" was right, and this finding was the confident config-inference the device disproves — Charter Rule 13's corollary in the flesh.** The original text is preserved below for the audit trail; its *conclusion* is superseded. Remaining work is NTP *cleanup*, not a broken-clock fix.

```
FGT01 # get system ntp
ntpsync    : enable
type       : custom
ntpserver:
    == [ 1 ]
    id: 1                          <-- 🔴 NO SERVER ADDRESS
server-mode: enable
interface  : "fortilink"           <-- 🔴 THIS INTERFACE IS status: down
```

**`025` Step 9 builds `set server pool.ntp.org`. The device has an EMPTY server entry, bound to a DEAD interface.**

🔴 ~~**FGT01's clock is as broken as SW01's — by a different mechanism.**~~ **← SUPERSEDED (correction banner above): device-verified 2026-07-16, the clock synchronises. Only SW01 is broken.**

| Device | The clock | Why |
|---|---|---|
| **SW01** | 🔴 `stratum 16, never updated`, ref time **1899** | Points at Pi01. **Pi01 serves no NTP.** |
| **FGT01** | 🟢 **Synchronized, stratum 2** (device-verified 2026-07-16) | `pool.ntp.org` via `wan1` (per-server `auto`). *(The `fortilink` binding is a harmless leftover, not a break.)* |
| **MKT01** | 🟢 **Synchronized, stratum 1** | `pool.ntp.org`, working. |
| **Pi01** | 🟢 Synchronized | `systemd-timesyncd` — a **client**. 🔴 **`046` ticks "chrony." Chrony is not installed.** |

🔴 **`047-FGT01-CIS-Hardening-Checklist.md` §7.1 ticks `[x] Local logging confirmed working`. `045` ticks NTP. `046` ticks chrony.**

> 🔴 **THREE FALSE TICKS ACROSS THREE HARDENING CHECKLISTS — on the one control that makes every log in the lab mean anything.**
>
> 🟡 **`CM-0030` still matters, but device reads narrow it: only SW01 has no working clock** — Pi01, MKT01 and (device-verified 2026-07-16) FGT01 all synchronise. There is still no dedicated NTP *server* others point at; SW01 points at Pi01, which serves none. *(FGT01 now has a valid stratum-2 clock and `server-mode enable` — pointing SW01 at FGT01 is one way to fix SW01; see `CM-0030`.)*

**`server-mode: enable` means FGT01 offers to serve time — and (device-verified 2026-07-16) it now HAS a valid stratum-2 clock to serve.** *(No client points at it today. Decide: turn it off, or point SW01 here to fix SW01's clock — `CM-0030`.)*

## 🔴 Finding 4 — `Lab-Network` and `Transit-Link` DO NOT EXIST

```
FGT01 # get firewall address
== [ all ] == [ dmz ] == [ internal ] == [ internal1 address ] == [ internal2 address ]
== [ EMS_ALL_UNKNOWN_CLIENTS ] == [ FABRIC_DEVICE ] == [ SSLVPN_TUNNEL_ADDR1 ] ...
```

🔴 **No `Lab-Network`. No `Transit-Link`. Every object listed is a FortiOS factory default.**

**`ADR-0005` was right:** *"Build Record `021` documented a scoped design (`Lab-Network`, `Transit-Link` address objects) **that doesn't actually exist on the device**."*

| Document | Says |
|---|---|
| 🔴 **`021`** — *"Address Objects"* table, marked **`Verified`** | `Lab-Network` = `10.0.0.0/8`; `Transit-Link` = `172.16.0.0/29` |
| 🔴 **`021`** — *"Firewall Policies (**verified**)"* | Policy 1 `srcaddr` = `Lab-Network, Transit-Link` |
| 🔴 **`025`** Step 6 + Step 7 | **BUILDS both objects and the scoped policy** |
| 🟢 **The device** | 🔴 **Neither object exists.** Policy 1 is `srcaddr all` *(per `ADR-0005`)*. |

> 🔴 **`021` was populated from `025`. Not from the device.** **Confirmed. `051` finding C7.**
>
> **That is the precise inversion `Atlas-Workflow` v2.0 exists to prevent: *"A Build Guide is a plan. A Build Record is an observation. Observations outrank plans."*** **Here the plan was written into the observation and stamped `Verified`.**
>
> 🔴 **And a rebuild from `025` SILENTLY EXECUTES A DEFERRED DECISION.** **`ADR-0005` deliberately chose to keep `srcaddr all` until network redundancy exists.** **`025` narrows it anyway — with the `/24`-vs-`/8` outage from the original build waiting on the other side.**

## 🔴 Finding 5 — Roadmap Critical Risk #2, CONFIRMED — and it is the good branch

```
Virus-DB:  1.00000 (2018-04-09)     🔴 8 years stale
IPS-DB:    6.00741 (2015-12-01)     🔴 11 years stale
APP-DB:    6.00741 (2015-12-01)     🔴 11 years stale
AV Engine: 7.00031 signed
```

**`Atlas-Roadmap.md` Critical Risk #2:**

> *"Either the UTM profiles aren't applied, or **they are applied and providing nothing while appearing to. The second is worse — it invites you to believe you're covered.**"*

🟢 **It is the FIRST, and that is the good outcome.** **Policy 1 is `srcaddr all`, `service ALL`, with NO UTM profiles attached** *(`021`, `ADR-0005`, `047` §4)*. **Nothing pretends to protect anything.**

🔴 **But `047` §4 calls it *"Confirmed gap — consistent with these profiles not being actively maintained **or possibly not applied at all**."*** **"Possibly" is not an answer.** **Settle it: no licence, no profiles, no protection. Say it plainly and turn `server-mode` and the UTM menus off so nothing suggests otherwise.**

## 🟢 What is CORRECT — so nobody over-corrects

| | Device | Status |
|---|---|---|
| `admin-server-cert` | **`fortigate-bundle`** | 🟢 **`MC-0001` holds.** *(`get`, not `show` — the command that found it unbound.)* |
| `CM-0004`'s four | `internal`, `wan2`, `fortilink`, `modem` — **all `status: down`** | 🟢 **Confirmed** |
| DNS | `protocol: dot`, `globalsdns.fortinet.net` | 🟢 **DNS-over-TLS. `021` is right.** 🟡 **Validated against `Fortinet_Factory`, not the Lab CA — recorded nowhere.** |
| `internal1` / `internal2` | `172.16.0.1/29`, `10.10.0.254/24` | 🟢 |
| VDOM | `root`, 1 in NAT mode | 🟢 |
| Hostname / Serial / FortiOS | `FGT01` / `FGT60ETK18099YR2` / `v7.4.5 build2702` | 🟢 |
| 🟡 `naf.root`, `l2t.root`, `ssl.root` | `status: up`, `type: tunnel` | 🟡 **FortiOS internal tunnel interfaces. Benign — but `021` records none of them.** |

---

## Implementation

> 🔴 **THIS RECORD IS `Draft`. A DRAFT RECORD IS A HYPOTHESIS, NOT A WORK ORDER.** **`CM-0011` was executed as a to-do list against a stale baseline and DEGRADED A BMC.** **Read the device. Then decide.**

### 🔴 Step 1 — DOCUMENT `internal3`–`internal7`. Do NOT disable them.

**They are FGT01's break-glass path.** **Record the REASON in `021`, per `010`'s second clause:**

> **`internal3`–`internal7` — `status: up`, DELIBERATELY.** They are the members of the `internal` hard-switch group *(which is itself `down`)*, and they carry FGT01's factory bootstrap address **`192.168.1.99/24`**. **This is the ONLY IP-based recovery path to FGT01 when `internal2` is unreachable** (`003`, `048` Phase 1). **DO NOT DISABLE THEM. A hardening pass that shuts these ports removes FGT01's recovery path.**

🔴 **`trusthost3 192.168.1.0/24` exists for exactly this** — and `025` Step 8 sets it. **The pieces were all there. Nothing joined them up.**

### 🟡 Step 2 — `dmz`: decide, then act

| Option | |
|---|---|
| 🟢 **Disable it** | **Recommended.** It has no purpose. **VLAN 80 is the DMZ**, routed by MKT01. **`010`'s policy says disable.** `set status down`. |
| **Keep it, documented** | Only if a real future use exists. **Then `007` must reserve `10.10.10.0/24`.** |

**Either way: it goes in `021`, `010`'s compliance table, and `025`.** **A factory L3 interface on a perimeter firewall is not a "leave it" item.**

### 🔴 Step 3 — NTP. **Do not fix this in isolation.** → **`CM-0030`**

```text
config system ntp
    set type custom
    unset interface                      # 🔴 fortilink is DOWN. NTP cannot egress through it.
    set server-mode disable              # 🔴 FGT01 is offering to serve time it cannot get.
    config ntpserver
        edit 1
            set server "<a real NTP server>"
        next
    end
end
```

**Then PROVE it — `025` does not:**

```text
get system ntp | grep -A3 ntpserver
diagnose sys ntp status
execute time
```
🔴 **A config line is not a synced clock.** **`CM-0030` is now LAB-WIDE and this is part of it.**

### 🔴 Step 4 — Address objects: **DO NOTHING ON THE DEVICE. Fix the documents.**

🔴 **`ADR-0005` deliberately deferred narrowing policy 1.** **Creating `Lab-Network`/`Transit-Link` now would execute a deferred decision by accident.**

- **`021`** — 🔴 **DELETE the Address Objects table and the scoped "Firewall Policies (verified)" table.** Record what the device has: **`srcaddr all`, no custom objects, deferred by `ADR-0005`.**
- **`025`** — 🔴 **Steps 6 and 7 must build what the device HAS**, with the scoped design preserved as a clearly-marked *future* target under `ADR-0005`, **and the `/24`-vs-`/8` outage named as the trap.**

### Step 5 — UTM: state the truth

**`047` §4 and `021`:** **No licence. No profiles applied. No signature-based protection. Databases are 8–11 years stale.** **Formally accept it (an ADR) or licence it. `047`'s "possibly" is not an answer.**

---

## Reconciliation — all document types (`ADR-0019`)

| Document | Outcome | Detail |
|---|---|---|
| 🔴 **`021`** (Build Record) | **MUST UPDATE** | **Delete the two false `Verified` tables.** Add: `internal3-7` up **and why**, `dmz` state, NTP's real state, the tunnel interfaces, the stale UTM databases. |
| 🔴 **`025`** (Build Guide) | **MUST UPDATE** | 🔴 **It builds address objects that do not exist, a policy `ADR-0005` deferred, no Lab CA certificate, no DNS-over-TLS, and it never disables the factory interfaces** (`CM-0004` has no Build Guide row). **Its Validation uses `show`, not `get`.** **Next fix.** |
| 🔴 **`010`** (Standard) | **MUST UPDATE** | Its compliance table marks FGT01 ✅ on four interfaces. **It never enumerated the hard-switch members or `dmz`.** **`015` requires enumerating EVERY interface — the enumeration was never done on FGT01.** |
| 🔴 **`047`** (Checklist) | **MUST UPDATE** | **Add the unused-interface finding — `047` does not mention `CM-0004` AT ALL.** **Its NTP/logging ticks are unverified.** **Settle the UTM question.** |
| **`CM-0030`** | 🟡 **SCOPE CLARIFIED** | Device reads settled it: **only SW01 is unsynchronised** (2026-07-16 — FGT01 and Pi01 both sync). `045`'s SW01 NTP tick is the false one; `046`'s Pi01 tick named the wrong daemon (chrony vs `systemd-timesyncd`) but sync works, and was corrected. |
| 🔴 **`003`, `048`** | **Reviewed — no change needed** | 🟢 **Both correctly document `192.168.1.99` on `internal3-7` as FGT01's bootstrap path.** **They were right. `021` and `025` never carried it across.** |
| 🔴 **`013`** (Standard) | **MUST UPDATE** | *"NTP — public NTP today."* **True for MKT01. FALSE for SW01 and FGT01.** |
| 🔴 **`015`** (Validation) | **MUST UPDATE** | **Add `get system ntp` + `diagnose sys ntp status`, and `get firewall address`.** **`015`'s FGT01 block still uses `show`, contradicting its own `get`-not-`show` warning.** |
| **`016`** | 🔴 **MUST UPDATE** | **New lesson below.** |

---

## The lesson — for `016`

> 🔴 **A DISABLED GROUP IS NOT A DISABLED PORT.**

**`CM-0004` disabled the `internal` hard-switch group and closed. `010` marked FGT01 compliant. `021` said *"internal3-7 — Unassigned."***

**Five physical ports on the perimeter firewall stayed UP, in no document, for the life of the lab.**

**And they were up for a GOOD REASON — they are FGT01's only recovery path.** 🔴 **Which nobody knew, because it was written in `003` and `048` and never in the Build Record or the Build Guide.**

> **`016` lesson 9: *"'Available' is not a state. It is a hope."*** 🔴 **This adds: NEITHER IS "UNASSIGNED." AND A GROUP'S STATE IS NOT ITS MEMBERS' STATE.**
>
> **`015` already says: *"enumerate EVERY interface a device has, not just the ones already expected to be in use."*** **The instruction was correct. It was never followed on FGT01.**

---

## Closeout

- [ ] 🔴 **`internal3`–`internal7` DOCUMENTED as deliberately up** — the bootstrap path. **NOT disabled.**
- [ ] `dmz` decided and actioned; recorded in `021`, `010`, `025`
- [ ] **NTP: FGT01 already synchronises** (device-verified 2026-07-16, stratum 2). Remaining = *cleanup* only — `unset interface` (stale `fortilink` binding), decide `server-mode`. **Not a broken clock.**
- [ ] 🔴 **`021`'s two false `Verified` tables DELETED** — address objects and the scoped policy
- [ ] 🔴 **`025` rebuilt against the device** — **next fix**
- [ ] `010`'s compliance table re-enumerated for FGT01 — **every interface, not the four we knew about**
- [ ] `047` updated — unused interfaces, the UTM decision, the false ticks
- [ ] UTM formally accepted (ADR) or licensed
- [ ] 🔴 **`016` updated** — **BLOCKS CLOSURE**
- [ ] Closed

> 🔴 **Does NOT move to `Closed` while any box is unticked.**

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-14 by the Book 1 audit (`ADR-0019`), from a device pass on FGT01. 🔴 **`internal3`–`internal7` are UP and in no document — they are FGT01's ONLY IP-based recovery path (`192.168.1.99`), written in `003` and `048` and never in `021` or `025`. A hardening pass would have destroyed it.** 🔴 **`dmz` is UP at factory `10.10.10.1/24`, in no policy, in no guide.** 🔴🔴 **FGT01's NTP is an EMPTY server entry bound to `fortilink` — which is DOWN. Its clock has never synced. `CM-0030` is LAB-WIDE: two of four devices unsynchronised, no NTP server anywhere in Atlas, three false ticks across three CIS checklists.** 🔴 **`Lab-Network` and `Transit-Link` DO NOT EXIST — `021`'s `Verified` tables were copied from `025`, not read from the device, and a rebuild from `025` silently executes the decision `ADR-0005` deferred.** 🟢 **`admin-server-cert: fortigate-bundle` (`MC-0001` holds); `CM-0004`'s four interfaces confirmed down; DNS-over-TLS confirmed. UTM databases are 8–11 years stale — Roadmap Critical Risk #2 confirmed, and it is the GOOD branch: no profiles are applied, so nothing pretends to protect anything.** |
| 1.1 | 🟢 **2026-07-16 — device correction.** A fresh FGT01 read (`get system interface`, `show full-configuration system ntp`, `diagnose sys ntp status`, `show firewall policy 1`) **confirms `021` and disproves Finding 3's NTP conclusion:** the server IS `pool.ntp.org` and the clock **synchronises at stratum 2** (egress via `wan1`; the `fortilink` binding is a harmless leftover). `CM-0030`'s scope narrows to **SW01 only**. Interfaces, `dmz` (admin-up), `srcaddr all`/no-UTM, and cert binding all reconfirmed. Remaining NTP work is *cleanup*, not a broken-clock fix. Findings 1, 2, 4, 5 stand. |
