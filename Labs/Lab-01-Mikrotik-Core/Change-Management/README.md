---
Title: Change Management
Path: Labs/Lab-01-Mikrotik-Core/Change-Management
---

# Change Management — Enterprise Network

## Status

Section landing page. See `019-Change-Management.md` (Operations) for the change *process*. **This page is the index of actual change records for this pack.**

> 🔴 **This index was rebuilt from the records on disk on 2026-07-13, after it was found to be six records out of date.**
>
> It listed **CM-0001 through CM-0008** and said *"Next available number: CM-0009."* **CM-0015 existed.** It did not mention `CM-0014` — a credential exposure — or the two iDRAC records. **A reader of this page would have concluded the pack was finished at CM-0008.**
>
> **Rule 5 below says: *"Update the index table whenever a record is created or its status changes."*** The rule was written on this page, published, and then ignored **by this page.** See `016-Network-Lessons-Learned.md`.
>
> **Reconciled again 2026-07-14 (051 / L2):** it had gone stale a second time (its stated next-free number was still six behind reality — it named CM-0016 while CM-0016 through CM-0033 already existed, and showed `CM-0010`/`CM-0014` as open). Index rebuilt from the records on disk; statuses cross-checked against the manifest.

## How to Use This Section

1. Every change to a live device gets its own record here — **one file per change, never combined.**
2. **Two tiers.** Most changes use the standard `CM-XXXX` template — a port fix, an address correction, disabling an interface. High-risk, multi-system, or complex changes use the `MC-XXXX` **Major Change** template — full planning, phased validation, and a diagnostic narrative. **If unsure, default to standard; escalate only if the single Backup/Implementation/Validation/Rollback flow genuinely isn't enough.**
3. Numbers are **sequential per tier and never reused**, even if a change is abandoned. `CM` and `MC` are separate sequences.
4. Templates: `00-Atlas-Foundation/Templates/Change-Record-Template.md` / `Major-Change-Record-Template.md`.
5. 🔴 **Update the index table below whenever a record is created OR its status changes.** *(This rule was broken for six records. See the banner above.)*
6. Follow the workflow in `019-Change-Management.md`.

## Status Lifecycle

`Draft` → `Implemented` → `Validated` → `Closed`

> 🔴 **A record does NOT move to `Closed` while any closeout box is unticked.** If a box cannot be ticked, the status is **`Implemented — reconciliation open`**, which `CM-0010` uses correctly.
>
> **`CM-0009` was marked `Closed` with its *"Build Record updated"* box unticked — and the Build Record then described a firewall that no longer existed, for a full day.** The closeout exists to catch exactly that. **Nothing checks the checklist except you.**

## Index

| ID | Title | Affected Systems | Status | Risk |
|---|---|---|---|---|
| [CM-0001](../Devices/SW01-Access-Switch/Changes/CM-0001-SW01-Gi1-0-1-Description-Fix.md) | Correct SW01 Gi1/0/1 Port Description | SW01 | ✅ Closed | Low |
| [CM-0002](../Devices/PI01-Services/Changes/CM-0002-Pi01-FreeRADIUS-Client-Correction.md) | Correct Pi01 FreeRADIUS Client Addressing and **Rotate Secrets** | Pi01, FGT01, MKT01 | ✅ Closed | Medium |
| [CM-0003](../Devices/SW01-Access-Switch/Changes/CM-0003-Disable-SW01-Gi1-0-3.md) | Disable SW01 Gi1/0/3 | SW01 | ✅ Closed | Low |
| [CM-0004](../Devices/FGT01-NS-Firewall/Changes/CM-0004-Disable-Unused-FGT01-Interfaces.md) | Disable Unused Factory Interfaces on FGT01 | FGT01 | ✅ Closed — device-verified | Low |
| [CM-0005](../Devices/FGT01-NS-Firewall/Changes/CM-0005-Install-Lab-CA-Certificate-on-FGT01.md) | Install Lab CA Certificate on FGT01 | FGT01 | 🟣 **Superseded by MC-0001** | Low |
| [CM-0006](../Devices/MKT01-Core-Router/Changes/CM-0006-Disable-MikroTik-Reverse-Proxy.md) | Disable MikroTik `reverse-proxy` Service | MKT01 | ✅ Closed — device-verified | Low |
| [CM-0007](../Devices/MKT01-Core-Router/Changes/CM-0007-Install-Lab-CA-Certificate-on-MikroTik.md) | Install Lab CA Certificate on MKT01 `www-ssl` | MKT01, Pi01 | 🟣 **Superseded by MC-0002 / CM-0008** | Low |
| [CM-0008](../Devices/MKT01-Core-Router/Changes/CM-0008-Reissue-MikroTik-Certificate-Correct-SAN.md) | Reissue MikroTik Certificate with Correct SAN + Fix Stale DNS | MKT01, Pi01 | ✅ Closed | Low |
| [CM-0009](../Devices/MKT01-Core-Router/Changes/CM-0009-Remove-Obsolete-MKT01-RADIUS-Rules.md) | Remove Obsolete Pre-VLAN RADIUS Rules from MKT01 | MKT01 | ✅ Closed — implemented and verified | Low |
| [CM-0010](CM-0010-CA-Passphrase-Rotation-and-Exposed-Key-Destruction.md) | **CA Passphrase Rotation and Destruction of Exposed Key Backups** | Pi01 — Lab CA (Root + Intermediate), Vaultwarden | ✅ **Closed** (manifest, 2026-07-14) | **High** |
| [CM-0011](../Devices/PVE01-Hypervisor/Changes/CM-0011-Harden-PVE01-iDRAC-BMC.md) | Harden PVE01 iDRAC/BMC (cipher 0, auth NONE, SNMP) | PVE01 iDRAC (BMC) | 🔴 **CLOSED — substantially FALSE.** Findings disproven on the device. | Void |
| [CM-0012](../Devices/PVE01-Hypervisor/Changes/CM-0012-PVE01-CMOS-Battery-and-BMC-Credential-Findings.md) | **PVE01 CMOS Battery Failing** — BMC settings non-durable | PVE01 hardware, iDRAC, BIOS | 🔴 **OPEN — pending hardware** | Low → conditional |
| [CM-0013](CM-0013-Establish-RADIUS-Validation-Account.md) | Establish a Permanent RADIUS Validation Account (`radtest-verify`) | Pi01 (FreeRADIUS) | ✅ Closed — implemented and verified | Low |
| [CM-0014](CM-0014-Archive-Passphrase-Committed-to-Repository.md) | 🔴 **Backup Archive Passphrase Committed to the Repository** | Lab CA, FreeRADIUS, Vaultwarden, **Git history, GitHub** | ✅ **Closed 2026-07-14** — rotated, history purged, verified from a fresh clone | 🔴 **High** |
| [CM-0015](../Devices/MKT01-Core-Router/Changes/CM-0015-Disable-MKT01-ether2.md) | Disable MKT01 `ether2` (Unused Interface Policy) | MKT01 | ✅ Closed — device-verified (`X` flag) | Low |
| [CM-0016](../Devices/MKT01-Core-Router/Changes/CM-0016-Correct-MKT01-bridgeLocal-Address-Comment.md) | Correct MKT01 `bridgeLocal` Address Comment | MKT01 | ✅ Closed 2026-07-14 — device-verified | Low |
| [CM-0017](../Devices/MKT01-Core-Router/Changes/CM-0017-MKT01-MAC-Server-State-Investigation.md) | MKT01 MAC-Server State Investigation | MKT01 | ✅ Closed 2026-07-14 | Low |
| [CM-0018](../Devices/MKT01-Core-Router/Changes/CM-0018-Establish-MKT01-MAC-WinBox-Recovery-Path.md) | Establish MKT01 MAC-WinBox Recovery Path | MKT01 | ✅ Closed 2026-07-14 — tested (`ether4`); remainder deferred (`ADR-0016`) | Low |
| [CM-0019](../Devices/PI01-Services/Changes/CM-0019-Vaultwarden-Env-File-in-Backup-Directory.md) | Vaultwarden Env File in Backup Directory | Pi01 (Vaultwarden) | 🟡 Implemented — reconciliation open (does not block) | Low |
| [CM-0020](CM-0020-Pre-Commit-Hook-Is-Not-Portable.md) | Pre-Commit Hook Is Not Portable | Repo / tooling | 🟡 Open (does not block) | Low |
| [CM-0021](../Devices/MKT01-Core-Router/Changes/CM-0021-MKT01-Build-Guide-Recovery-Path-Regression.md) | MKT01 Build Guide Recovery-Path Regression | `026` MKT01 Build Guide | ✅ Implemented 2026-07-14 — reconciliation open (`016`) | 🔴 High (rebuild-fatal) |
| [CM-0022](../Devices/SW01-Access-Switch/Changes/CM-0022-SW01-Build-Guide-Rebuilds-a-Switch-That-Drops-Pi01.md) | SW01 Build Guide Rebuilds a Switch That Drops Pi01 | `027` SW01 Build Guide | ✅ Implemented 2026-07-14 — reconciliation open (`023`, `016`) | 🔴 High (rebuild-fatal) |
| [CM-0023](../Devices/SW01-Access-Switch/Changes/CM-0023-Remove-Carried-Over-SW01-v2c-SNMP-Community.md) | Remove Carried-Over v2c `homelab` SNMP Community from SW01 | SW01 (SNMP) | 🟡 Implemented — reconciliation open (removed in Lab-02 rebuild; confirm read-back) | 🟡 Medium |
| [CM-0025](CM-0025-048-Phase-0-Rebuilds-the-Destroyed-Archive.md) | 048 Phase 0 Rebuilds the Destroyed Archive | `048` Teardown/Rebuild Runbook | 🟠 Draft — to apply | 🔴 High (security) |
| [CM-0026](CM-0026-018-Restates-the-Claim-It-Proved-False.md) | 018 Restates the Claim It Proved False | `018` Documentation Standards | 🟠 Draft — to apply | 🔴 High |
| [CM-0027](CM-0027-035-Issues-Certificates-With-No-SAN.md) | 035 Issues Certificates With No SAN | `035` Certificate Issuance Runbook | 🟠 Draft — to apply | 🔴 High |
| [CM-0030](../Devices/SW01-Access-Switch/Changes/CM-0030-SW01-Clock-Has-Never-Synchronised.md) | SW01 Clock Has Never Synchronised | SW01 (NTP) | 🟡 Open | 🔴 Medium |
| [CM-0032](CM-0032-CA-Database-Has-No-Record-of-Two-Certificates.md) | CA Database Has No Record of Two Certificates | Pi01 Lab CA (`index.txt`) | 🟠 Draft | 🔴 High |
| [CM-0033](../Devices/FGT01-NS-Firewall/Changes/CM-0033-FGT01-Five-Live-Undocumented-Ports.md) | FGT01 Five Live Undocumented Ports | FGT01 | 🟠 Draft | 🟡 Medium |
| [CM-0034](../Devices/MKT01-Core-Router/Changes/CM-0034-Disable-MKT01-Default-Admin-User.md) | Disable MKT01 Default `admin` User | MKT01 | ✅ Closed 2026-07-15 — device-verified (`X`) | Low |
| [CM-0035](../Devices/MKT01-Core-Router/Changes/CM-0035-Disable-MKT01-Unused-bridgeLocal-Ports.md) | Disable MKT01 Unused `bridgeLocal` Ports (`ether5`–`ether13`) + relabel comment | MKT01 | ✅ Closed 2026-07-15 — device-verified (`X`) | Low |

**Next available number: `CM-0036`**

### ✅ Book 1 is FROZEN (2026-07-14). Remaining records are post-freeze remediation.

**`NETWORK-PACK-MANIFEST.md` is authoritative and records the freeze. `CM-0010` and `CM-0014` are Closed. No open record blocks the (completed) freeze.**

| Record | State | What is left |
|---|---|---|
| 🟡 **CM-0012** | Deferred by `ADR-0017` (hardware) | Replace the CR2032, power-cycle, prove the board holds config — then `050-PVE01-iDRAC-Onboarding-Runbook.md` unblocks. |
| 🟠 **CM-0025 / CM-0026 / CM-0027** | Draft — the rebuild-fatal guide/runbook fixes | Apply them to `048`, `018`, `035`. Until a clean rebuild works, these are the highest-value fixes in the pack (051 Tier 1). |
| 🟡 **CM-0030 / CM-0032 / CM-0033** | Open / Draft — device-pass findings | SW01's clock has never synced; the CA `index.txt` is blind to two live certificates; FGT01 has five undocumented live ports. |
| 🟡 **CM-0019 / CM-0020** | Open — do not block | Stray Vaultwarden env file; the pre-commit hook is not portable, so a fresh clone is unprotected. |

## Major Change Index

| ID | Title | Affected Systems | Status | Risk |
|---|---|---|---|---|
| [MC-0001](../Devices/FGT01-NS-Firewall/Changes/MC-0001-FGT01-Lab-CA-Certificate-Installation.md) | FGT01 Lab CA Certificate Installation (Full Diagnostic Record) | FGT01, Pi01, admin workstation | ✅ Closed | Low |
| [MC-0002](../Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md) | MikroTik Certificate Reissuance and the CA-Wide `copy_extensions` Fix | MKT01, Pi01 | ✅ Closed | Low |

**Next available number: `MC-0003`**

> 🔴 **Neither MC record carries a `Status` row.** Both are asserted `Closed` **here and in the pack manifest — by documents that are not the record.** The `Major-Change-Record-Template.md` does not require a Status field; that is the defect. **Fixed 2026-07-13:** Status rows added to both, and the template updated. **A status that only exists in an index is a status nobody can verify at the source.**

## Records that found more than they were raised for

**Three of these change records exist because a different change record needed to prove itself.** That is the system working.

| Record | Raised to fix | Actually found |
|---|---|---|
| `CM-0009` | Two dead firewall rules | **The input-chain default deny was never in the build guide.** RouterOS defaults to **ACCEPT** — a router rebuilt from the old guide had **no default deny at all.** |
| `CM-0013` | Nothing — it was raised *because `CM-0009` could not be validated* | **RADIUS had been unauthenticatable for a full day.** The `testing`/`password` account was correctly deleted and **nothing replaced it.** |
| `CM-0015` | An enabled unused interface | **`026-MKT01-Build-Guide.md` did not mention `ether2` at all** — so a rebuild recreated the finding. |

## Related Pages

- Change Management **process** — `00-Atlas-Foundation/Governance/Atlas-Change-Management-Process.md`
- **Network Source of Truth** — `Labs/Lab-01-Mikrotik-Core/Architecture/006-Network-Source-of-Truth.md`
- **Decisions** — `00-Atlas-Foundation/Decisions/`. The *why* lives in an ADR; this index tracks the *how, safely* of applying it.
- **Pack status** — `Labs/Lab-01-Mikrotik-Core/Pack-Manifest.md` is authoritative. **If it disagrees with this page, it wins.**
