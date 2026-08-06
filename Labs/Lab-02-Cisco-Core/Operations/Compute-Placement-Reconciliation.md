---
Title: Lab-02 — Compute-Placement & Sizing Reconciliation (#20 decision record)
Path: Labs/Lab-02-Cisco-Core/Operations
Status: 🟢 Decision record (point-in-time, 2026-07-30, session 18). NOT an ongoing authority — the live table lives in `Service-Server-Build-Plan.md`.
Version: 1.0
Date: 2026-07-30
---

# Lab-02 — Compute-Placement & Sizing Reconciliation (the #20 sweep)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).**

> **What this is.** The point-in-time record of the **#20 compute-placement + VM-sizing reconciliation** (operator, 2026-07-30). It captures *what was decided and why*; it is **not** a live table. The **authoritative, kept-current** homes are: **`Service-Server-Build-Plan.md`** (physical-host placement + VM sizing), **`Architecture/IP-Addressing-Plan-VLSM.md`** (addresses), and **`Decisions/ADR-0036`** (the placement *principle*). When those disagree with this record, they win — this is history.

## Why the sweep was needed

The handoff and several owner docs were authored **before** the recent network/compute ADRs landed, so a few "estate-wide rules" still assumed the old shape:

- **`ADR-0036` v1.2 (2026-07-29)** *inverted* the placement model — the low-power **EQR6 (PVE02)** became the **always-on critical tier** and the **R410 (PVE01)** the **mostly-off spin-up heavy tier**. Docs written earlier still read "R410 = primary" and "every VM on PVE01".
- **`ADR-0034`** made the Virtualization Build-Record the single owner of PVE01 networking.
- The estate grew a **second hypervisor**, but the IP plan's VLAN-10-vs-20 rule still named only "the PVE01 host".

The result was three kinds of drift: a **stale estate-wide rule** (one hypervisor assumed), an **ambiguous authority** (two docs carried a host column and disagreed), and **three wrong per-VM host cells**.

## Decisions (operator, at planning — `ADR-0049`)

1. **DC02 stays on PVE01/R410** as a cold-standby. `ADR-0036` principle 1 requires the two DCs on *different physical hosts*; the index had briefly put DC02 on PVE02, co-locating both DCs (the exact "two eggs in one basket" the ADR exists to prevent). The index was reconciled **to** the ADR — with the accepted trade-off that an EQR6 loss while the R410 is off means no live DC until the R410 powers on (the off-site backup is the recovery guarantee).
2. **The placement + sizing single source is `Service-Server-Build-Plan.md`** (interim, until NetBox renders it). `ADR-0036` states the *principle*; the plan records the per-VM decision. **`VM-and-Services-Inventory.md` is RETIRED** — PVE01-only, generic names, no host column.
3. **Estate-wide rules are updated first**, then the per-VM cells and address rows.

## The drift that was corrected

| VM | `ADR-0036` v1.2 (principle) | Index *was* (v1.5) | Reconciled to | Kind |
|---|---|---|---|---|
| **DC02** | PVE01/R410 (cold-standby; DCs on different hosts) | **PVE02** | **PVE01/R410** | 🔴 contradiction (blast-radius) |
| **ICA01** | PVE02/EQR6 (always-on Tier-0 CA) | **PVE01** | **PVE02/EQR6** | stale cell |
| **SRV01** | PVE02/EQR6 (CRL/AIA must stay reachable) | **PVE01** | **PVE02/EQR6** | stale cell |
| VLAN-10 rule | two hypervisor hosts now | "the PVE01 host" only | both hosts on VLAN 10 | 🔴 stale estate rule |

## Reconciled placement (authoritative snapshot)

**PVE02 / EQR6 — always-on critical tier** (64 GB prereq): DC01 · **ICA01** · NPS01 · **SRV01** · Vaultwarden (rides BKP01) · BKP01 · FS01 · MON01 *light probe* · RDS01 · WAC01 · PAW01 (🟡 swing) · CNT01 *Linux git/CI slice*.

**PVE01 / R410 — spin-up heavy tier** (mostly off): **DC02** (cold-standby) · MON01 *heavy stack* · NETBOX01 · the `ADR-0046` cluster node + S2D · WSUS01 · SQL01 · KALI01 · big-RAM labs · CNT01 *Windows-container slice*.

**Physical (not VMs):** Pi01 (Raspberry Pi) · 1941 · SW01 · MKT01 · FGT01 · PFSENSE01 (2-NIC transparent-bridge appliance).
**Home-PC Hyper-V:** lab clients/test VMs · AD FS + WAP (Tier B) · MSP-sim tenants · AZ-802 Hyper-V.
**SIEM01:** dedicated host — VLAN (40-vs-20) + indexer RAM still open (residual #20).

## Sizing — the EQR6 always-on RAM budget

Full detail + the per-VM table live in `Service-Server-Build-Plan.md`. Headline: the core always-on stack is ~30 GB (matching `ADR-0036`), and adding **RDS01 (6) + WAC01 (4) + PAW01 (4)** brings the always-on total to **~44 GB**. **64 GB holds it with ~20 GB headroom** — so the expanded always-on list fits, and the `ADR-0036` 64 GB prerequisite stands. This **resolves the open "RDS01 RAM on the always-on EQR6" question: it fits.** Swing-to-R410 order if a heavy session squeezes RAM: **PAW01**, then **RDS01**.

🔴 **Single-8 TB SPOF (→ Phase 9 build):** FS01 shares + the BKP01 datastore + Vaultwarden's store all sit on one external USB drive on the EQR6. Mitigations: the **mandatory encrypted off-site copy** (`ADR-0009`) is the real recovery and must be **restore-tested** (the never-run Game Day, `POL-0005`); and strongly consider putting the **BKP01 datastore on a dedicated 2nd NVMe** (`ADR-0036` already suggests adding one) to separate the backup failure domain from the file-share one.

## The address deconflict — DONE in the same sweep (operator decisions)

The address/VLAN residuals were then resolved in a second pass:

- **PAW01 → VLAN 10 `10.10.0.8`** — moved off the VLAN-20 `.2–.9` Tier-0 carve onto the management plane with WAC01 (`305` Part 4: the admin path exists only from Management). New **flows-matrix #23** — PAW01 (MGMT) → IDENTITY/Tier-0 admin (RDP/WinRM/RSAT), the only interactive Tier-0 admin path.
- **SIEM01 → VLAN 40 `10.40.0.11`, dedicated host, 16 GB** OpenSearch indexer (the Monitoring plane, with MON01, which it ingests).
- **Pi01 DNS/NTP MGMT-ingress → a scoped, logged exception** (flows-matrix **#19** resolved): only the DCs (forwarded DNS) + infra/network devices reach Pi01 on 53/123; domain clients resolve via AD-DNS, keeping the ingress minimal — the same pattern as flows #14/#21.
- **VLAN-10 static map firmed** (no collisions): `.1` MKT01 · `.2` SW01 mgmt · `.5` WAC01 · `.6` Pi01 · `.7` PFSENSE01 · `.8` PAW01 · `.10` PVE01 · `.11` PVE02.

**Docs touched by the deconflict:** IP plan **v1.10** · estate index **v1.7** · flows matrix **v1.7** · this record · handoff.

## #20 close-out — residuals resolved (session 18, cont.)

- **CNT01 sizing — DONE (provisional).** Linux git/CI slice ~4 GB / 2 vCPU on the EQR6 (Gitea; GitLab ~8 GB) + Windows-container slice ~6 GB / 2 vCPU on the R410 spin-up tier. The **always-on-vs-spin-up** and **Gitea-vs-GitLab** calls ride with the **still-owed #19 estate-capability ADR**, not pre-empted here. Budget re-checked: the EQR6 always-on total stays within 64 GB even if the Linux slice runs always-on (~48 GB Gitea / ~52 GB GitLab). Recorded in `Service-Server-Build-Plan` v1.8.
- **KALI01 address — DONE.** `10.70.0.5` (VLAN 70 Testing static range). The remaining 📋 addresses (BKP01 `.18`, Vaultwarden `.13`, CNT01 `.19`) are **intended values held until each device is built**, not floating — no deconflict outstanding.

**#20 is now fully closed** — the only forward-carry is the #19-owned CNT01 platform detail.

Then **#21** (PVE01/PVE02 as `Devices/` folders + `Virtualization/` tidy) as a separate session — teaching companion `Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` + the `221` runbook.

## Related
- `Service-Server-Build-Plan.md` — the live placement + sizing owner (v1.6).
- `Architecture/IP-Addressing-Plan-VLSM.md` — addresses (v1.9; both hypervisor mgmt rows).
- `Decisions/ADR-0036-Compute-Topology-and-VM-Placement.md` — the placement principle (v1.3).
- `Operations/Build-Order-and-Dependencies.md` — build sequence + dependency map.

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-30 | Created (session 18). The #20 compute-placement + sizing reconciliation decision record: DC02 → R410 (reaffirm principle 1), placement/sizing authority → `Service-Server-Build-Plan`, `VM-and-Services-Inventory` retired, ICA01/SRV01 → EQR6, the EQR6 RAM budget (64 GB holds ~44 GB always-on), the two-hypervisor VLAN-10 rule. **Address deconflict folded in the same session:** PAW01 → VLAN 10 `.8` (+ flows #23), SIEM01 → VLAN 40 `.11`/16 GB, Pi01 ingress = scoped exception (flows #19), the VLAN-10 static map. CNT01 sizing + KALI01 `10.70.0.5` firmed in the session-18 continuation; **#20 fully closed** bar the #19-owned CNT01 platform detail. |
