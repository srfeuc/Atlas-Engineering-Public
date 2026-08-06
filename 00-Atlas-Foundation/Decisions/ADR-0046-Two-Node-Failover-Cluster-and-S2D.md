# ADR-0046 — Two-Node Failover Cluster + Storage Spaces Direct: HA Workload, Storage Model, and Witness

| Item | Value |
|---|---|
| Status | **Accepted in principle** (operator, 2026-07-29). ✅ **PVE02-gate LIFTED 2026-07-29** (Beelink EQR6 acquired) — but re-scoped to an **on-demand / spin-up HA lab** (the R410 is mostly-off per `ADR-0036` v1.2), **not continuous HA**. Nothing always-on may depend on it. |
| Governing Policy | POL-0013 (+POL-0005) |
| Scope | **Lab-02-Cisco-Core** |
| Date | 2026-07-29 |
| Supersedes | — **Extends `ADR-0036`** (needs a 2nd physical host so the two nodes aren't one failure domain; PVE02 now = the EQR6). |
| Related | `ADR-0036` (multi-host; nodes on different physical hosts; the QDevice/quorum reasoning), `ADR-0044` (enterprise model; certs anchor), `Atlas-Academy/AZ-800-801-Windows-Server-Hybrid-Lab-Map.md` (the **biggest** HA gap), `ADR-0009` (backup/DR survivability — HA ≠ backup), `Pre-Build-Decisions` I-series (storage/backup = top risk), `ADR-0045` (the other compute additions). |
| Evidence Status | **Decision / plan.** Nothing built. Requires **≥2 nodes** (PVE02 gate) + a **witness**. |

## Context

The single **biggest AZ-801 gap** the sweep found is **Failover Clustering**, and **AZ-800 Storage Spaces Direct (S2D)** rides on it. It is also **real enterprise HA** the estate otherwise lacks. A cluster is a bigger commitment than the `ADR-0045` hosts — two nodes, shared/S2D storage, a witness, and a clustered workload — so it gets its own decision.

## Decision

Stand up a **2-node Windows Server Failover Cluster** as the HA lab, with:

### Workload — *what* gets clustered
Primary candidate: **SQL Server Always On Availability Group**, folding the already-committed **SQL01** in as one replica + a 2nd node. **Recommendation: SQL Always On AG** — it folds SQL01 (already in scope) into the HA story, teaches AG listeners + quorum, and is the higher-value enterprise + AZ-801 pattern. **Fallback: a clustered File Server** (classic role) if S2D/SQL licensing is a hurdle. Operator confirms at build; either satisfies the objective.

### Storage — *how* the nodes share data
**Storage Spaces Direct (S2D)** — hyperconverged, each node contributes local disks — to cover the AZ-800 S2D objective directly, rather than shared iSCSI (which would lean on FS01 as a single point). **Fallback: an iSCSI target on FS01** as shared storage if S2D's constraints (pass-through disks / nested virtualization on Proxmox) bite.

> 🟡 **2026-07-29 (PVE02 = EQR6) — the network nudges the fallback.** S2D replicates over the network and really wants **≥10 GbE**; the EQR6 has **only dual 1GbE** (`ADR-0036` v1.2). So S2D here teaches the *mechanics* but is slow. Options: use the EQR6's **USB-C 10 Gbps** port for a USB→2.5/5GbE storage link, **or lean on the iSCSI-on-FS01 fallback** (FS01 is on the always-on EQR6 with the 8 TB — a natural iSCSI target), **or** accept slow-S2D as a documented lab limitation. Decide at build.

### Witness — *quorum* at 2 nodes
A **file-share witness** on a host **outside the two nodes** (FS01 or BKP01) so 2 nodes can't split-brain. A **cloud witness** (Azure storage account) is the AZ-801-flavored alternative and gets built as the **Azure / H4** phase lands. Two nodes **must** have a witness — the same lesson as `ADR-0036`'s QDevice reasoning for Proxmox quorum.

### Placement — *where* the nodes run
The two cluster nodes **must be on different physical hosts** (`ADR-0036` principle 1 — a host loss cannot take both) → **one on PVE01 (R410), one on PVE02 (EQR6)**. ✅ **PVE02 acquired 2026-07-29 — the gate is lifted.** But because the **R410 is mostly-off** (`ADR-0036` v1.2), the cluster is a **spin-up HA lab**: power both hosts up, run the failover / S2D exercise, then power the R410 back down. It is **not continuous HA**, so the always-on tier (on the EQR6) must **not** depend on it. The heavy cluster node lives on the R410; the EQR6 node must fit within its 64 GB alongside the always-on stack (favor the **fallback clustered-FS + iSCSI** over RAM-hungry SQL AG if headroom is tight).

## Alternatives Considered
- **Shared iSCSI instead of S2D.** Kept as the documented **fallback**; rejected as primary because S2D is the *named* AZ-800 objective and avoids making FS01 the storage SPOF.
- **Cluster a file server (simplest).** Kept as the **fallback workload**; SQL AG preferred for the folding-in-SQL01 value.
- **Build a 2-node cluster on PVE01 now.** Rejected — both nodes on one host is not fault tolerance (`ADR-0036`'s whole point). Wait for PVE02.
- **Skip clustering (S2D standalone / no HA).** Rejected — S2D and the entire AZ-801 HA domain need the cluster; it is the biggest single skills gap.

## Consequences
- **Two node VMs** enter scope (e.g. `SQLN1`/`SQLN2` for the AG, or `CLU01a`/`CLU01b` for a clustered FS) — **build-gated on PVE02**. If SQL AG, **SQL01 becomes one replica** (reconcile SQL01's Roadmap).
- **Witness owner:** FS01 or BKP01 hosts the file-share witness; the plan / NetBox records it.
- **`IP-Addressing-Plan-VLSM` owes:** 2 node addresses + a **Cluster Name Object (CNO)** + (SQL AG) an **AG listener VIP** + (clustered FS) a **role VIP** — cluster VCOs/VIPs are new address types the plan must accommodate.
- **HA ≠ backup:** the cluster still needs **BKP01 + off-site** (`ADR-0009`); note this so HA isn't mistaken for DR. Ties to the I-series top-risk work.
- **Build-order:** a **late phase** (after DC / AD CS / member servers + PVE02); enumerated in `Operations/Build-Order-and-Dependencies`.
- **AZ-800/801 lab-map:** the Failover Clustering + S2D + witness rows move from 🆕-gap to **planned-with-owner**.

## Review Trigger
- If SQL licensing / S2D hardware constraints block → fall back to a **clustered file server + iSCSI-on-FS01** (documented above); still meets the objective.
- ~~If PVE02 doesn't materialize → the cluster stays designed-only.~~ ✅ **PVE02 acquired (EQR6, 2026-07-29)** — gate lifted; cluster re-scoped to on-demand (R410 mostly-off).
- If a **third node** or **real shared storage (SAN)** appears → revisit S2D vs shared storage.

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-29 | **PVE02-gate LIFTED** (Beelink EQR6 acquired, `ADR-0036` v1.1/1.2) — but **re-scoped to an on-demand / spin-up HA lab**, since the R410 is mostly-off (`ADR-0036` v1.2 uptime tiers): power both hosts up for the exercise, not continuous HA; nothing always-on may depend on it. Added the **1GbE storage-network caveat** (S2D wants ≥10 GbE → USB-C 2.5/5GbE adapter, or favor the **iSCSI-on-FS01 fallback**, or accept slow-S2D) and the EQR6-node RAM-headroom note (favor clustered-FS fallback over SQL AG if 64 GB is tight). Status/Placement/Storage/Review-Trigger updated. |
| 1.0 | 2026-07-29 | Created from the AZ-800/801 sweep (biggest HA gap). 2-node Failover Cluster; **workload = SQL Always On AG** (folds in SQL01), clustered file server as fallback; **storage = S2D** (iSCSI-on-FS01 fallback); **witness = file-share** (cloud witness at H4); **nodes on different physical hosts** (PVE01 + PVE02) → **build-gated on PVE02**. Extends `ADR-0036`. |
