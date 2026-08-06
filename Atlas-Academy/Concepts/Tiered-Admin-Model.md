---
Title: The Tiered Administration Model — taught through Atlas's own Tier-0/1/2 build
Path: Atlas-Academy/Concepts
Status: 🟢 Academy concept module (D6 / `ADR-0032` concept layer). The "why it works" companion to `303` Part 5.
Version: 1.0
Date: 2026-07-28
---

# The Tiered Administration Model (one-pager)

<!-- provenance -->
> **Atlas Academy — Concepts.** A "why it works" module. Every claim points at a **real Atlas artifact** (`Academy/README` design principle). Build/target-state detail lives in `303` Part 5 and `ADR-0021`; this page explains the *reasoning* so the tier model is understood, not just followed.

> **The gap this closes (register B2/F17):** the tiered-admin material assumes concepts a reader may not have — *why* three tiers, *what* a "clean source" is, *why* a Tier-2 login on a DC is the whole ballgame. This is the plain-language version.

## The Concept

**Tiered administration splits identities and the machines they log into by blast radius, and forbids a higher tier from ever exposing its credential on a lower-tier machine.** Three tiers:

- **Tier 0 — the identity control plane.** Anything that *controls identity*: Domain Controllers, the CA (AD CS — RCA01/ICA01), and the admin workstation used to manage them (PAW). Own Tier 0 and you own the domain.
- **Tier 1 — servers / server admins.** The member servers and the accounts that run them (NPS01, SRV01, NetBox, app servers).
- **Tier 2 — workstations / users.** Day-to-day clients and standard users.

The rule that makes it work is **one-directional**: a Tier-0 credential is used **only** on a Tier-0 machine. The moment a Domain Admin types their password into a Tier-2 workstation, a keylogger or an LSASS dump on that workstation harvests a credential that unlocks *everything* — the "clean source" principle is broken and the tier boundary is gone. Tiering exists because **credential theft moves laterally and then vertically**; the tiers cap how far a single compromised machine can reach.

## The Atlas Example (real artifacts)

- **Three account sets, built in Stage 8 (device-verified 2026-07-22):** `t0-seth` (Tier 0), `t1-seth` (Tier 1), `seth` (Tier 2 / daily). One human, three identities — you log in as the *lowest* tier that can do the job.
- **AGDLP role groups:** `G-Tier0-Admins` / `G-Tier1-Admins` / `G-Tier2-Admins` + `G-IT-Staff` (→ `Security-Roles`), so rights are granted to groups, not people.
- **Protected Users** on the admin accounts (`t0-seth`/`t1-seth`) — blocks NTLM/credential caching so a stolen hash is far less useful.
- **The PAW (`PAW01-Tier0-Admin`)** — the *only* place `t0-seth` is meant to touch ICA01/DC01/DC02. RCA01 is administered from its own console (it's never even on the network).
- **The 7d tier-deny logon GPOs** (unblocked, pending) — the *enforcement*: `Deny log on locally` / `…through RDS` / `…from the network` so a Tier-2 credential is physically refused at a Tier-0 box, not just discouraged.
- **`ADR-0021`** — the decision that made AD the tiered identity backbone; **`ADR-0027`** keeps the CA off the DCs (same blast-radius logic, applied to PKI).

## What Went Wrong (real troubleshooting history — the best teacher)

- **The member-server LAPS test was deferred** because there was no Tier-1 member server yet to prove the boundary on — you can't prove "Tier-2 can't read a Tier-1 LAPS password" without a Tier-1 box. That gap is exactly why `NPS01` (a dedicated member server, `ADR-0029` D7) doubles as the host for the deferred member-server LAPS test.
- **DSRM was pulled into the model:** the DC's break-glass DSRM password is now rotated by **Windows LAPS** (7c-DSRM, device-verified) instead of a hand-recorded secret — a Tier-0 recovery credential that no longer sits in a doc.
- **The built-in Administrator was rotated and parked in Vaultwarden** as break-glass — a Tier-0 credential taken out of daily reach, not left at its install-time value.

## How to Explain This in an Interview

*"Tiering is about blast radius. I split admin identities into three tiers — domain controllers and the CA are Tier 0, member servers are Tier 1, workstations are Tier 2 — and the hard rule is that a Tier-0 credential is only ever used on a Tier-0 machine, from a privileged access workstation. The reason is credential theft: if a Domain Admin ever logs into a normal workstation, malware on that box can scrape the credential and now owns the domain. In my lab I built three accounts for one person, put the admin ones in Protected Users, and I'm enforcing the boundary with deny-logon GPOs so a lower-tier account is physically refused at a domain controller — not just told not to."*

## Related

- `Windows-Infrastructure/303-Windows-Design-Standards.md` Part 5 (tiered administration — the build/target-state) · Part 4 (AGDLP groups).
- `00-Atlas-Foundation/Decisions/ADR-0021` (AD as tiered identity backbone) · `ADR-0027` (CA off the DCs — same logic) · `ADR-0029` D7 (NPS01 = the member server that unblocks the Tier-1 LAPS test).
- `Devices/PAW01-Tier0-Admin/Build-Guide.md` (the clean source) · `Atlas-Academy/Concepts/README.md` (the concept index).
