# ADR-0020 — Atlas Time Source: AD-Anchored, an External Bridge Until the Domain Exists

| Item | Value |
|---|---|
| Status | **Accepted — 2026-07-16** |
| Governing Policy | POL-0006 |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-16 |
| Related | `CM-0030` (SW01 clock never synced — the finding that forced this), `ADR-0003`/`ADR-0004` (the same domain-membership boundary, for CA and RADIUS), `ADR-0015` (Pi01 over-trust / sequencing), `013-Internet-Access-Design.md`, `Build-Order-and-Dependencies.md`, `Atlas-Service-Architecture.md` |
| Evidence Status | **`Verified`** for the current-state facts (SW01 stratum 16; FGT01 stratum 2; MKT01 stratum 1); **`Target Design`** for the AD half (DC01 is a stopped VM, never promoted — `ADR-0004`) |
| Supersedes | The un-owned "NTP — Windows Server AD hierarchy / pool.ntp.org (interim)" deviation rows in `001` and `006` — those now point here |

> **This ADR exists because `CM-0030` proved SW01's clock has never synchronised, and Step 1 of its remediation is *"decide where time comes from — this is a design decision, not a config change."* Charter Rule 16 (`ADR-0018`): the design and the failure modes are written down; the operator makes the call. This is the call.**

## Context — one device is broken, and there is no internal source of truth

`CM-0030`, device-verified and re-verified 2026-07-16:

| Device | Clock | How |
|---|---|---|
| **SW01** | 🔴 **stratum 16, `never updated`** | `ntp server 10.10.0.5` points at Pi01, which serves no NTP (`.INIT.`, reach 0) |
| **FGT01** | 🟢 synced, stratum 2 | `pool.ntp.org` over wan1 (`059`) |
| **MKT01** | 🟢 synced, stratum 1 client | `pool.ntp.org` (`/system ntp client`) |
| **Pi01** | 🟢 own clock only | `systemd-timesyncd` **client**; nothing on UDP 123 (`053`) |
| **PVE01** | ⏳ gated | CMOS battery dead (`CM-0012`/`ADR-0017`) |

**Two of the three network devices already discipline their clocks against an external pool and work. One points at an internal host that was never a server. There is no authoritative internal time source anywhere in Atlas — and there will need to be one, because AD is coming.**

## The technical fact that decides this — AD does not *use* NTP, it *is* the time authority

**In a Windows domain, coherent time is not an add-on service you choose to run. It is a property of the domain, and Kerberos makes it mandatory.**

| Fact | Consequence for Atlas |
|---|---|
| **Kerberos rejects tickets with >5 minutes of skew.** | The moment DC01 is promoted (Book 3), every domain member **must** agree on time or authentication fails outright. AD cannot be "mostly working" with a bad clock — it forces a real, correct time hierarchy into existence as a precondition of functioning at all. |
| **The PDC-emulator FSMO role holder is, by design, the domain's authoritative clock.** | You get a single authoritative internal source and a proper stratum hierarchy **for free** — as a role the DC already holds, not as a fifth service bolted onto some other host. Domain members sync to it automatically via `w32time`; no per-client config. |
| **`w32time` is pushed by Group Policy.** | Every domain-joined machine's time config is managed centrally. Non-domain gear (SW01, FGT01, MKT01) simply points at the PDC-emulator's IP. One authoritative source, externally disciplined at the top via `pool.ntp.org`. |
| **It matches the boundary Atlas already chose twice.** | `ADR-0003` (CA) and `ADR-0004` (RADIUS) both split on *"can this thing join the domain?"* Time splits the same way: domain machines get it from AD via `w32time`; non-domain network devices point explicitly at the PDC emulator. **One rule, applied a third time, beats three clever ones.** |

**This is why AD-integrated time is the better end state, not merely the documented one:** it is the only option where the internal source of truth, the stratum hierarchy, and the client configuration all come from infrastructure that has to exist and has to be correct anyway. Anything else is a service we stand up, own, back up, and eventually throw away.

## Decision

**Target (strategic): the AD PDC-emulator is Atlas's single authoritative internal NTP source.** It disciplines itself externally against `pool.ntp.org`; domain members sync via `w32time`; the three non-domain network devices (**SW01, FGT01, MKT01**) point explicitly at the PDC-emulator's management IP. This lands with Book 3.

**Interim (until DC01 is promoted): SW01 points at the same external pool FGT01 and MKT01 already use** — through FGT01's existing outbound path — and the clock is **proven** with `show ntp status`, not a config line. FGT01 and MKT01 are already correct and stay as they are. PVE01 stays gated on `CM-0012`.

**Explicitly NOT done: standing up `chrony` as a server on Pi01.** It is the tempting interim — it would make SW01's existing `ntp server 10.10.0.5` line true with no change to the switch — but it is the wrong move for the same reason `ADR-0004` refused to domain-join Pi01: **it adds a fifth production service to the lab's most over-trusted host** (`ADR-0015`), a host that has hard-hung once with no root cause found, **to build an internal authority that AD will obsolete the day it arrives.** We would own it, back it up, and then migrate off it. The external pool is the honest bridge; AD is the destination.

## Alternatives Considered

**A — chrony server on Pi01 (interim), AD later.** Rejected as interim. Makes the stale config true and gives an internal source today, but piles onto Pi01 exactly against `ADR-0004`/`ADR-0015`, and is throwaway once the PDC emulator exists. If Pi01 is ever re-scoped to a narrower role (as `ADR-0004` notes), this objection weakens — but not today.

**B — point everything at `pool.ntp.org` forever, no internal source.** Rejected as the *end state*. It is exactly the interim, and it works — but it gives no internal authority, no stratum hierarchy to learn (the CCNA/AD syllabus wants one), and it breaks the domain-membership boundary the lab applies everywhere else. Fine as a bridge; wrong as a destination.

**C — wait for AD, change nothing now.** Rejected. Book 3 does not exist and SW01 is broken **now**. "The target is AD" is not a fix for a switch at stratum 16 today. `CM-0030`: *"'The target' is not a fix."*

## Consequences

- **SW01's clock gets fixed now**, against a source already proven in this lab (FGT01, MKT01) — the lowest-risk interim, no new service, no new host dependency.
- **The AD time hierarchy becomes a named Book 3 deliverable**, not an afterthought: promoting DC01 includes configuring the PDC emulator as the authoritative source and re-pointing SW01/FGT01/MKT01 at it. A Change Record executes that when Book 3 lands — **and Kerberos will not let it be skipped.**
- **Pi01 gains nothing new to carry** — consistent with `ADR-0004` and `ADR-0015`.
- **`CM-0030` Step 1 is now answered on the record.** Its config + proof steps remain open until executed on SW01; this ADR does not tick them.
- **The `001`/`006` NTP deviation rows now have an owner** — they reference this ADR instead of floating as "interim until Windows Server."

## Review Trigger

- **When DC01 is actually promoted.** Configure the PDC-emulator as the authoritative source, re-point the three network devices, and **prove each with `show ntp status` / `get system ntp` / the RouterOS client print** before closing. Resolve alongside `ADR-0004` — same domain-membership boundary, same DC.
- **If SW01's interim external sync cannot be proven** (e.g. FGT01 blocks outbound 123 from VLAN 10), fall back to re-evaluating alternative A, and record why.
- **If Pi01 is ever migrated to a VM** with a narrower role, the objection to running an internal `chrony` there weakens — revisit whether an internal source should exist before AD.

## The note

**The instinct after `CM-0030` is "point SW01 at Pi01 for real — just run chrony there."** It is one `apt install` away and it makes the config true. **But the same reasoning that kept RADIUS off a domain-joined Pi (`ADR-0004`) keeps NTP off it too:** the blast radius is wrong, and the payoff is temporary. Time in Atlas belongs to the domain — because Kerberos will demand it, and because the authority comes free with a role the DC already holds. Until the domain exists, we borrow the same external clock the rest of the fleet already trusts, and we **read the status back off the device** rather than believing a line in `show run`.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Accepted 2026-07-16. Answers `CM-0030` Step 1 (Charter Rule 16). **Target = AD PDC-emulator as the authoritative internal source** (Kerberos mandates coherent time; the authority comes free with the FSMO role; matches the `ADR-0003`/`ADR-0004` domain-membership boundary). **Interim = point SW01 at the external pool FGT01/MKT01 already use, proven with `show ntp status`.** Rejected standing up `chrony` on Pi01 (blast radius per `ADR-0004`/`ADR-0015`; throwaway once AD lands). Config + proof on SW01 remain open in `CM-0030`. |
