---
Title: SQL01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database
Status: 🟢 LIVING roadmap — the build path for the SQL Server host + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`).
Version: 1.0
Date: 2026-07-30
---

# SQL01 — Roadmap (build path + connections)

> **How to read this.** Each row is a stage. **Needs** = healthy-first; **Unblocks** = what proceeds. Detail: `Build-Guide.md`.

## The build path (in order)

### Phase 0 — Gate
- [ ] 🔴 **DC healthy** (AD + DNS) + the **KDS root key** exists (for gMSA, Tier-A A1). VLAN-20 reachable.

### Phase 1 — Host stand-up
- [ ] 📋 Clone Win Server 2025 → **SQL01** (from the PAW01 golden image); domain-join → `OU=Servers,OU=Devices` → `gpupdate`. Placement PVE01/R410; add a **data/log vdisk**.

### Phase 2 — gMSA service account (Tier-A A1)
- [ ] 📋 Create a **gMSA** (`svc-gmsa-sql`); grant SQL01 retrieval; install it on SQL01. *Needs:* KDS root key. *Unblocks:* running the engine with no stored password (the A1 objective). *Cert:* 70-742 Ch3 · AZ-800/801.

### Phase 3 — SQL Server install
- [ ] 📋 Install **SQL Server** (2022/2025); **Windows authentication** (avoid mixed unless an app forces it); engine + Agent run under the **gMSA**. Set **TempDB** per MS guidance; data/log on the vdisk.
- [ ] 📋 Scope **TCP 1433** on the host firewall (only the app/admin sources). *Unblocks:* app connections.

### Phase 4 — Certificate application (from ICA01)
- [ ] 📋 Enrol a **Server-Auth TLS cert** from **ICA01**; bind it (Force Encryption). *Needs:* AD CS ceremony. *Unblocks:* encrypted client connections. *Cert:* Security+ (TLS) · AZ-800/801.

### Phase 5 — Databases + backups
- [ ] 📋 App databases; **logins mapped to AD groups**; least-privilege roles (no sysadmin sprawl).
- [ ] 🔴 **Native backups + Agent jobs → copy to BKP01**; **test a restore** (`POL-0005`). *Why:* a DB with no tested restore is a Tier-1 risk.

### Phase 6 — Acceptance
- [ ] 🎯 A domain user connects with **Windows auth over TLS** (cert trusted); the engine runs under the **gMSA** (no stored password); a **DB backup restores** from BKP01.

### Phase 7 — Always On AG (later, `ADR-0046`, on-demand cluster)
- [ ] 📋 **SQL01 becomes one replica** of a **SQL Always On Availability Group** (2nd node on the other host; the **listener VIP** + CNO into the IP plan). *Needs:* the failover-cluster lab. *Cert:* AZ-801 (HA).

### Phase 8 — Automation onboarding (`ADR-0048`)
- [ ] 📋 DSC/DBATools for install + config + backup jobs → `Automation/` (idempotent).

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | DC01 (Win-auth · gMSA/KDS) | identity + service account |
| ⬆ Depends on | ICA01 (TLS cert) | encrypted connections |
| ⬆ Depends on | BKP01 | tested DB restore (`POL-0005`) |
| ⬇ Serves | app workloads · (opt) WSUS01 DB | relational data |
| ⬇ Serves | the failover cluster (`ADR-0046`) | one Always On AG replica |

## Certification alignment (learning lens)
| SQL01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| gMSA service account | managed service accounts, Kerberos delegation | 70-742 Ch3 · AZ-800/801 (→AZ-802 2026-09-30) |
| Windows-auth + AD-group logins | least-privilege DB access | Security+ · DBA fundamentals |
| TLS from ICA01 | encryption in transit, PKI consumer | Security+ · AZ-800/801 |
| Native backups → BKP01 + restore | backup/restore, DR (`POL-0005`) | DBA · AZ-801 |
| Always On AG (Phase 7) | HA, availability groups, listener/quorum | AZ-801 · `ADR-0046` |

## Staged traffic-flow
> Visualizes the flows matrix (owner): app/admin sources → SQL01 **1433** (E-W, scoped by the host firewall + the E-W matrix); SQL01 → DC (Kerberos/LDAP) + BKP01 (backup copy); everything else to SQL01 denied + logged. (E-W SMB/1433 is intra-estate — no FGT/UTM N-S penalty.)

## Validation
- Prove-it: `../../Operations/Validation-and-Adversarial-Testing.md` + `Diagnostics.md`. Key proofs: Windows-auth-over-TLS connect (cert trusted); engine under the gMSA (no password); a **restore from BKP01**.

## Future / later phases
- [ ] 📋 **Always On AG** (Phase 7, `ADR-0046`). [ ] 📋 **WSUS01 DB backend** if it moves off WID. [ ] 📋 sizing finalized (#20 + MS min specs).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `README.md` · `Considerations.md`. gMSA/tier: `../DC-Domain-Controllers/...Tiered-Admin-and-Groups-Build.md`. Cluster: `ADR-0046`. Estate index: `../../Service-Server-Build-Plan.md`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Created — build path + connections for the SQL Server host (DC-template replication, Batch A). Phased (host → gMSA/A1 → install/Win-auth/1433 → ICA01 TLS → DBs/backups → acceptance → Always On AG → automation), placement PVE01/R410 (RAM-heavy + AG fold-in), cert alignment, and the `POL-0005` backup gate. |
