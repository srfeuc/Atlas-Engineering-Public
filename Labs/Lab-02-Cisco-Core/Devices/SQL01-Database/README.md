# SQL01 — SQL Server (database host)  ·  folder front-door

> **How to read this folder.** Front door: *what this host is*, *what it connects to*, *which doc answers which question*. Live status: **`Roadmap.md`** + **`Build-Checklist.md`** (`POL-0001`).

| Item | Value |
|---|---|
| Lab / Era | Lab-02 · Cisco-Core — ACTIVE (📋 not built) |
| Host · Role | **SQL01** (Windows Server 2025 + **SQL Server 2022/2025**) · database host for Windows app workloads + hands-on MSSQL |
| Placement | **PVE01/R410** (spin-up heavy tier, `ADR-0036` v1.2) — RAM-heavy + it **folds into the on-demand failover cluster** (SQL Always On AG, `ADR-0046`), whose nodes live on the R410. VLAN 20, **`10.20.0.16`** *(proposed)*, gw `10.20.0.1`, `OU=Servers,OU=Devices`. 🟡 placement is a Backlog #20 candidate. |
| Proposed sizing 🟡 | 2 vCPU · **6–8 GB** RAM (SQL is RAM-hungry; 4 GB floor, more is better) · 60 GB OS · a **data/log vdisk** · TempDB sizing per MS guidance. *Proposed — capacity pass (#20) + vendor minimums finalize.* |
| Silo | 🟡 Services / ⚪ Platform (data platform) |
| Governs / related | Tier-A **A1** (gMSA/Kerberos delegation — the SQL service account) · `ADR-0027` (ICA01 → the TLS cert) · `ADR-0046` (SQL Always On AG — SQL01 = one replica) · `POL-0002` (secrets) · `POL-0005` (backups → BKP01) |

## Role this era

A Microsoft **SQL Server** instance for Windows line-of-business / reporting workloads and hands-on MSSQL (auth modes, TLS, backups, **gMSA** service accounts, later **Always On AG**). Logins are by **AD group**; the engine runs under a **gMSA** (no stored password); connections are **TLS** (ICA01 cert); native backups ship to **BKP01**. **Not** the NetBox DB (that's **Postgres on NETBOX01**), **not** a DC, **not** a shared "everything" box — scope it to real app DBs.

## Connections — what this host touches (the map)

**Depends on (upstream):**
- **DC01** — domain-join, **Windows auth** (logins by AD group), and a **gMSA** service account (KDS root key on the DC; Tier-A **A1**). Kerberos + a correct SPN for the gMSA.
- **ICA01** (AD CS) — a **server TLS cert** (Server-Auth template) for encrypted connections. *Gated on the AD CS ceremony.*
- **BKP01** — a **tested restore path** for the DB backups (`POL-0005`).
- **PVE01/R410** (+ a data/log vdisk) → SW01 → MKT01 (VLAN-20 gw `10.20.0.1`). Addressing: `../../Architecture/IP-Addressing-Plan-VLSM.md` (`POL-0008`).

**Depended on by (downstream):**
- **App workloads** that need a relational DB (line-of-business / reporting — scoped per app).
- **The failover cluster** (`ADR-0046`) — **SQL01 becomes one replica** of a **SQL Always On Availability Group** (the 2nd node on the other host); the AG **listener VIP** is a new address type the IP plan must accommodate.
- *(optional)* **WSUS01** if it points its DB here instead of WID at scale.

**Services provided:** SQL Server instance(s), app databases, AD-group logins, TLS connections, native backups; (later) an Always On AG replica.

## Connections diagram

```mermaid
flowchart LR
  subgraph up[⬆ Depends on]
    direction TB
    dc[DC01 · Win-auth + gMSA/KDS]
    ica[ICA01 · TLS cert]
    bkp[BKP01 · tested restore]
  end
  subgraph down[⬇ Depended on by]
    direction TB
    apps[App workloads · DBs]
    ag[Failover cluster · Always On AG replica]
    wsus[opt · WSUS01 DB backend]
  end
  sql[["SQL01<br/>SQL Server"]]:::me
  dc -->|join · Win-auth · gMSA/Kerberos| sql
  ica -->|TLS cert enrol| sql
  bkp -->|backup/restore · POL-0005| sql
  sql -->|TDS/1433| apps
  sql -->|AG replication (later)| ag
  sql -->|opt DB backend · 1433| wsus
  classDef me fill:#1f6feb,stroke:#0b3d91,color:#fff;
```

> 🔴 BKP01 upstream = the *tested restore* (`POL-0005`). The `ag` edge is the later `ADR-0046` fold-in.

## Services map — what runs here and how it's used

> 🆕 **Services map (Standard v1.7).** What SQL01 runs + how each is consumed. Status mirrors `Build-Record.md` (`POL-0001`) — 📋 not built, so every row is ⬜.

| Service | Purpose | Consumed by · port | Depends on | Status |
|---|---|---|---|---|
| **SQL Server instance(s)** | Relational DBs for Windows app / reporting workloads | app workloads · TDS/1433 | DC (Win-auth) | ⬜ not built |
| **AD-group logins + gMSA engine** | Logins by AD group; engine runs under a gMSA (no stored password) | admins / apps · Kerberos | DC KDS root key (Tier-A A1) | ⬜ not built |
| **TLS connections** | Encrypted client connections (Force Encryption) | clients · TDS/1433 (TLS) | ICA01 Server-Auth cert | ⬜ gated on AD CS |
| **Native backups → BKP01** | DB backups with a **tested** restore (`POL-0005`) | BKP01 · backup path | BKP01 built | ⬜ not built |
| **Always On AG replica** (later) | One replica of the `ADR-0046` AG (listener VIP + CNO) | failover cluster · AG listener | cluster build | ⬜ not built (later) |

## Documents in this folder
- **`Roadmap.md`** · **`Build-Checklist.md`** · **`Build-Guide.md`** (phased/gated) · **`Considerations.md`** (gMSA/A1, TLS gate, AG fold-in, sizing, backups) · **`Build-Record.md`** (⬜) · **`Diagnostics.md`** · **`Troubleshooting.md`** · **`Automation/`** (`ADR-0048`) · **`Changes/`**.

## Single source
- Estate index: `../../Service-Server-Build-Plan.md`. gMSA/tier: `../DC-Domain-Controllers/...Tiered-Admin-and-Groups-Build.md`. Cluster: `ADR-0046`. Addressing/listener VIP: `../../Architecture/IP-Addressing-Plan-VLSM.md`. Sizing: `00-Atlas-Foundation/VM-and-Services-Inventory.md` + Backlog #20.
