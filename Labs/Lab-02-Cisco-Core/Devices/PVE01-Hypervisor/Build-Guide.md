---
Title: PVE01 — Build Guide (pointer to the Virtualization procedure)
Path: Labs/Lab-02-Cisco-Core/Devices/PVE01-Hypervisor
Status: 🟢 Pointer — the executable build procedure for PVE01 lives in the Virtualization book; this page indexes it. 🔴 The 2xx guides are R410-era carry-over (flagged for #22).
Version: 0.1
Date: 2026-07-30
---

# PVE01 — Build Guide (pointer)

> **This is a front-door index, not a second procedure (`POL-0008`).** PVE01 is **built + device-verified**; its build *procedure* already lives in the **Virtualization book** and its verified *state* in the Virtualization **Build-Records**. This page points to both so a successor knows exactly where the executable steps are — it does not restate them (the 1941/SW01 "point, don't duplicate" pattern).

> 🔴 **Source caveat (`#21`).** The `2xx` Virtualization Build-Guides **predate Atlas conventions — some are pre-Atlas carry-over.** Treat them as *historical procedure*, not current truth. The authoritative **current** state is `../../Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`) + the platform/storage/auth Build-Records. **A clean, device-verified rewrite is deferred to the #22 audit** (per the operator's forward sequence) — this session gets the shape right and flags the carry-over rather than rewriting it.

## The build procedure (Virtualization book — `../../Virtualization/Build-Guides/`)

Executed in this order (the `2xx` series; each is a phase of the R410→Proxmox→DC01 stand-up):

| Stage | Guide | Owns |
|---|---|---|
| Hardware prep | `201-Dell-PowerEdge-R410-Preparation.md` | R410 BIOS/firmware/RAID prep |
| Install | `202-Install-Proxmox-VE.md` | Proxmox VE install |
| Post-install | `203-Proxmox-Post-Installation-Configuration.md` | repos, no-sub patch, updates |
| **Networking** | `204-Proxmox-Networking.md` | the apply **procedure** — points to the `PVE01-Networking` record for verified state (`ADR-0034`) |
| Storage | `205-Proxmox-Storage.md` | `local` / `local-lvm` |
| Authentication | `206-Proxmox-Authentication-and-Named-Administration.md` | `seth-admin@pve`, root scope |
| Windows VM → DC01 | `207`–`214` | Win Svr 2025 VM · VirtIO · base config · Sysprep golden image · template · clone · DC01 deploy |
| Ubuntu golden image | `220-Prepare-the-Ubuntu-Golden-Image.md` (+ `.sh`) | the `TPL-UBUNTU2604` template |

## Verified state (records outrank guides — `POL-0001`)
- **Networking (authoritative):** `../../Virtualization/Build-Records/PVE01-Networking.md` (`ADR-0034`).
- **Platform / current state:** `../../Virtualization/Build-Records/215-PVE01-Current-State.md`.
- **Storage:** `../../Virtualization/Build-Records/PVE01-Storage.md` (new, #21).
- **Authentication:** `../../Virtualization/Build-Records/PVE01-Authentication.md` (new, #21).
- **Golden-image lineage:** `../../Virtualization/Build-Records/216-Windows-Golden-Image-Historical-Record.md`.
- **Reference / corrections:** `../../Virtualization/Reference/217-Verified-Facts-and-Reconciliation-Notes.md`.

## Migration procedure (the spin-up re-tier)
- **`../../Virtualization/Build-Guides/221-PVE02-EQR6-Bring-Up-and-VM-Migration.md`** — stand up PVE02/EQR6 + migrate the always-on tier off this R410 (PBS restore = the Game Day). Teaching companion: `Atlas-Academy/Concepts/Proxmox-VM-Migration-and-Host-Bring-Up.md` (V1).

## Related
- `Roadmap.md` (the stages) · `Build-Record.md` (as-built summary) · `Diagnostics.md` (verify) · `Considerations.md` (risks) · `../../Virtualization/VIRTUALIZATION-PACK-MANIFEST.md` (pack index).

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created (#21) — front-door pointer to the Virtualization `2xx` build procedure + the four PVE01 Build-Records + the `221` migration runbook. Flags the `2xx` R410-era carry-over for the #22 clean rewrite (`POL-0008`; point-don't-duplicate). |
