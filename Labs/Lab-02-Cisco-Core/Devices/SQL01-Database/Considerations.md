---
Title: SQL01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database
Status: 🟠 LIVING — open risks + unsettled decisions for the SQL host.
Version: 1.1
Date: 2026-07-30
---

# SQL01 — Considerations (open risks & decisions)

## Open gates
- 🔴 **Backups are not optional (`POL-0005`).** A database with no **tested** restore is a Tier-1 risk. Native backups + Agent jobs → **BKP01**, and *prove a restore* before SQL01 holds anything real.
- 🔴 **TLS cert gated on the AD CS ceremony.** Force-Encryption needs the ICA01 Server-Auth cert. Until then, connections are unencrypted or wait — decide per app; don't ship sensitive data in clear.
- 🔴 **gMSA needs the KDS root key (Tier-A A1).** The KDS root key exists on the DC (✅ from the DC build) — confirm before creating `svc-gmsa-sql`; the account needs the right **SPN** for Kerberos or Windows-auth breaks.

## Standing risks (design)
- 🟡 **RAM-hungry on a constrained estate.** SQL wants memory; on the R410 give it 6–8 GB + a **max-server-memory cap** so it doesn't starve the host. This is a key input to the #20 capacity pass — use **Microsoft's documented minimums**, don't guess (operator's "get professional recommendations").
- 🟡 **Windows-auth, not mixed mode.** Prefer Windows auth (AD-group logins); enable SQL logins only if an app forces it, and then vault the `sa`/app passwords (`POL-0002`) — never in git.
- 🟡 **sysadmin sprawl.** Keep `sysadmin` near-empty; grant least-privilege DB roles by AD group (the same discipline as Domain Admins on the DC).
- 🟡 **Not the NetBox DB.** NetBox uses **Postgres on NETBOX01** — do not consolidate it here; scope SQL01 to real MSSQL app DBs.

## Open decisions (need a call / ADR when reached)
- 🟡 **Edition** — SQL Server **Developer** (free, full-featured, non-prod — ideal for a lab) vs Standard/Express. Default **Developer** for learning; note Express's limits if chosen.
- 🟡 **Always On AG scope (`ADR-0046`).** SQL01 becomes one AG replica when the cluster lab runs; the **listener VIP + CNO** are new IP-plan entries. Confirm at the cluster build; the fallback is a clustered file server if SQL AG licensing/S2D bites.
- 🟡 **Placement (#20).** PVE01/R410 (RAM + AG fold-in); confirm in the capacity pass. **Address `10.20.0.16`** proposed — authoritative in `IP-Addressing-Plan-VLSM` (`POL-0008`).

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27) — the instance / gMSA-logins / TLS / backups / AG-replica rows + protocol/port on every diagram edge (`TDS/1433`, `gMSA/Kerberos`, …). All rows honest ⬜ (not built, `POL-0001`).
- **No separate `Networking-Build-Guide.md` for SQL01** *(operator policy — appliances point, hosts get new)*. Standard tagged-VLAN-20 VM; the AG **listener VIP + CNO** (a new IP-plan address type) is owned by the IP plan + `ADR-0046`, not a per-host bring-up guide (`POL-0008`).

## Related
- `Roadmap.md` · `Build-Checklist.md` · `ADR-0046` (AG) · Tier-A A1 (gMSA) · `POL-0005` (backup) · Backlog #20 (sizing) · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** added a **Decided** section — Services map + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27, all ⬜); no separate `Networking-Build-Guide.md` (standard VLAN-20 VM). |
| 1.0 | 2026-07-30. Created — open gates (backups/`POL-0005`, TLS-cert gate, gMSA/KDS/SPN), standing risks (RAM cap + use MS min specs for #20, Windows-auth-not-mixed, sysadmin sprawl, not-the-NetBox-DB), and open decisions (edition, Always On AG scope + listener VIP, placement/IP #20). |
