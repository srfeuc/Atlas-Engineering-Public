---
Title: Vaultwarden Password Storage Convention
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Vaultwarden Password Storage Convention

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Verified — flat naming confirmed as the final decision |
| Evidence Source | Live Vaultwarden UI; decision recorded 2026-07-13 |
| Last Verified | 2026-07-13 |
| Version | 2.0 |
| Applies To | Vaultwarden at `https://vault.lab:8443` |

A password manager with no convention is just a pile — searchable, but not *scannable*. This defines how entries are named so that in six months, finding "the MikroTik RADIUS secret" is one search, not a hunt.

> ## Revision note — folders were tried and abandoned
>
> **Version 1.0 of this document prescribed a five-folder structure** (`01 - Network Devices`, `02 - Pi01 Services`, `03 - PKI - Lab CA`, and so on) mirroring the repository layout.
>
> In practice it hit real UI friction in Vaultwarden — the Folders control was unavailable — and at the current scale of roughly **15–20 entries**, the folders bought nothing that the naming convention does not already give you.
>
> **Flat naming is the final decision.** Revisit only if the vault grows past the point where a single sorted list stops being scannable. If it does, note that the convention below already sorts **by device**, which is the same grouping the folders were trying to create.
>
> **This rewrite was authored on 2026-07-13 and was never placed into the repository.** The v1.0 folder version remained committed, contradicting both the live vault and the published Confluence page, until this version landed. It is the same failure mode the placement tooling was built to prevent: written, delivered, silently never filed.

## The Convention

```text
<Device> - <Component> - <Purpose>
```

**Device first, always.** That is what makes the list scannable — an alphabetical sort groups everything by system automatically, matching how the Build Records and Build Guides are already organised.

It is the folder structure, without the folders.

## Current Entries

| Entry name | What it is |
|---|---|
| `FGT01 - Admin - GUI Login` | FortiGate admin account |
| `FGT01 - RADIUS - fortigate client secret` | Shared secret; must match Pi01's `clients.conf` |
| `Lab CA - Intermediate CA - Private Key Passphrase` | Signs every device certificate |
| `Lab CA - Root CA - Private Key Passphrase` | **The most sensitive value in Atlas.** No recovery path. |
| `MKT01 - Admin - SethAdmin` | MikroTik named admin |
| `MKT01 - RADIUS - mikrotik client secret` | Must match MKT01's `/radius` entry **and** Pi01's `clients.conf` |
| `Pi01 - FreeRADIUS - localhost client secret` | Rotated off the stock `testing123` |
| `Pi01 - FreeRADIUS - localhost_ipv6 client secret` | **A separate block with its own secret.** Not the same as `localhost`. |
| `Pi01 - SSH - dnsadmin` | Key-only, port 2222 |
| `SW01 - Enable Secret` | Local-only; SW01 has no RADIUS |
| `Vaultwarden - Admin Token` | Argon2id hash; rotated post-HTTPS |
| `iDRAC-PVE01 - Admin` | Out-of-band management |
| `PVE01 - root` | Emergency recovery only |
| `PVE01 - seth-admin (named account)` | Daily administration |

Alphabetically that sorts into FGT01 → Lab CA → MKT01 → Pi01 → PVE01 → SW01 → Vaultwarden → iDRAC. **Which is the grouping the folders were for.**

## What Goes in the Notes Field

Enough context that you never have to open Atlas just to work out what an entry is *for* — and never so much that the entry itself becomes sensitive beyond the password.

- **Where it's documented.** e.g. *"See `033-Pi01-FreeRADIUS-Build-Guide.md`."*
- **Rotation history worth remembering.** e.g. *"Rotated 2026-07-13 — previous value had been exposed in a chat session log."*
- **What breaks if this changes.** This is the one people skip, and the one that matters most for shared secrets.

> ### Shared secrets must name the other end
>
> **Every RADIUS secret exists in two places.** Rotating it in Vaultwarden and on Pi01 but **not on the device** leaves the device unable to authenticate — and the failure looks like a RADIUS problem, not a secrets problem. You will chase it for an hour.
>
> So the `mikrotik` entry's notes must say: *"Must match MKT01's `/radius` entry. Change both."*
> The `fortigate` entry must point at FGT01's RADIUS server object.
>
> **Name the other end.**

## What Does *Not* Go in Vaultwarden

- **Anything that isn't a credential.** API notes, architecture, procedures — that is what Atlas is for. Keep Vaultwarden a password manager, not a second wiki.
- **Placeholder entries.** If a credential does not exist yet, do not create an entry "to reserve the name." **An entry that exists implies a secret that works.**

## Outstanding — Device Password Rotation

Rotation was deliberately deferred until Vaultwarden was production-ready. **It now is.** These still hold their original values:

- [ ] FGT01 admin
- [ ] MKT01 `admin` and `SethAdmin`
- [ ] SW01 enable secret
- [ ] Pi01 `dnsadmin`
- [ ] PVE01 `root` and `seth-admin`
- [ ] iDRAC-PVE01 admin

> **Fill the real values locally. Never paste them into a chat session.**
>
> The four FreeRADIUS secrets had to be rotated precisely because they were exposed in a chat log once already. A `vaultwarden-import-template.csv` with the correct structure exists — populate it on the workstation, import, **delete the CSV.**

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Vaultwarden/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Operations/043-PKI-and-Credential-Security-Overhaul-Session-Summary.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md` — what the Root/Intermediate passphrases protect

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Initial convention — five-folder structure plus naming. |
| 2.0 | **Folders abandoned.** Real UI friction, and no benefit at ~15–20 entries that the device-first naming does not already provide. **Flat naming is final.** Added "name the other end" for shared secrets — a RADIUS secret rotated on one side only fails in a way that looks like a different problem entirely. **This version was authored 2026-07-13 and not placed; the v1.0 folder structure remained committed until it landed.** |
