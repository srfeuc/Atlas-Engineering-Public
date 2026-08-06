---
Title: VM Snapshot & Naming Convention (Standard)
Path: Labs/Lab-02-Cisco-Core/Virtualization/Reference
---

# VM Snapshot & Naming Convention (Standard)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — applies to all Proxmox VMs (PVE01)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Standard |
| Version | 1.0 |
| Applies To | All PVE01 VMs |
| Last Updated | 2026-07-21 |

## Purpose
One consistent way to name and use VM snapshots so a restore point's *meaning* is obvious at a glance, and so we don't misuse snapshots as backups or corrupt AD by rolling a DC back carelessly.

## The naming pattern

**`<state>-<YYYYMMDD>`** — lowercase, ISO date (sorts chronologically), describing the state you can roll back **to**. Put the real detail in Proxmox's **Description** field; the name is just the handle.

> Proxmox rules the name must obey: starts with a letter, only letters/digits/`-`/`_`, no spaces, ~40 chars.

Two intents, named so you can tell them apart:

| Intent | Pattern | Example |
|---|---|---|
| **Before a risky change** (the "undo" point) | `pre-<action>-<date>` | `pre-dcpromo-20260721`, `pre-harden-20260721`, `pre-caenroll-20260721` |
| **A verified known-good milestone** (the "checkpoint") | `<milestone>-<date>` | `clean-base-20260721`, `dc-atlaslab-20260721`, `kds-done-20260721` |

If you take more than one in a day, add a short suffix: `-2` or a 24h time `-1430`.

**Description field** (always fill it): what state this captures, what change is about to happen (for `pre-`) or what was just verified (for a milestone), and any reference (guide stage / change ID). Example — name `dc-atlaslab-20260721`, description: *"atlas.lab promoted + KDS root key created, Get-ADDomain verified; before OU/GPO/time."*

## How to take one (Proxmox GUI)
1. Select the VM ▸ **Snapshot** tab ▸ **Take Snapshot**.
2. **Name** = the pattern above. **Description** = the detail.
3. **Include RAM**: leave **off** for a clean cold/consistent restore point (VM can stay running for a crash-consistent disk snapshot); tick it only if you specifically need the live memory state.

*(CLI equivalent, if you prefer: `qm snapshot <vmid> <name> --description "<detail>"`.)*

## 🔴 Cautions by VM type

- **Domain Controllers** — the one VM type where *rolling back* is dangerous. Reverting a DC that has replicated causes a **USN rollback** (AD replication corruption). Modern Windows + the **VM-GenerationID** (`vmgenid`, which Proxmox/QEMU provides — confirm the DC VM has that device, it's default) detects a revert and recovers safely, but the rule stands: snapshot DCs **sparingly**, prefer **cold** snapshots (VM shut down), and never make rolling a live DC back a habit. Single-DC lab = lower blast radius (no replication partners), but know the risk.
- **Certificate Authorities** — a CA that has issued certificates shouldn't be casually reverted; you can reuse serial numbers / desync the CRL. Snapshot **before** changes; be deliberate about reverting after it has issued anything.

## 🔴 Snapshots are NOT backups
They live on the **same storage** as the VM, so a datastore failure loses both. Use them for **near-term rollback** (hours/days), don't let them pile up (they grow and drag performance — prune old ones), and rely on **real backups** (PBS / BKP01, Phase 9) for retention and off-box recovery.

## Good default snapshot points (this build)
- `clean-base-<date>` on a fresh, fully-patched template clone **before** any role/domain-join.
- `pre-dcpromo-<date>` before promoting a DC; `dc-atlaslab-<date>` right after a verified promotion.
- `pre-harden-<date>` before a CIS/GPO hardening pass.
- `pre-caenroll-<date>` on a CA before it issues its first certificate.

## Related
- `Labs/Lab-02-Cisco-Core/Virtualization/README.md`
- `Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Guide/DC01/DC01-Build-Guide.md` (DC snapshot cautions)
- `Master-Build-Order.md` Phase 9 (backups — the real retention layer)

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-21 | Created — snapshot naming pattern (`<state>-<YYYYMMDD>` + Description field, pre-/milestone intents), Proxmox GUI + CLI steps, DC USN-rollback / CA CRL cautions, snapshots≠backups, and default snapshot points for the build. |
