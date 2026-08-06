---
Title: PAW01 — Automation (scripts + how-tos)
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin/Automation
Status: 🟡 Partial (`ADR-0048`). The golden-image finalize is **already scripted** (`../Scripts/`); the rest is designed, authored after the manual first pass. 🟡 until each artifact runs idempotently.
Version: 0.1
Date: 2026-07-29
---

# PAW01 — Automation (`ADR-0048`)

> **The rule (`ADR-0048`).** This folder holds PAW01's automation **slice** — how-tos + the index of its scripts — authored **after** the manual first pass. Runnable shared code = the estate capability (`Operations/Automation/` + self-hosted git, Backlog #7/#19). 🟡 until idempotent (`ADR-0041`). Note: PAW01 is deliberately **AppLocker-allow-listed**, so any automation agent/tool that runs *on* the PAW must be explicitly allow-listed (`Considerations.md`).

## Already scripted — the golden-image finalize (`../Scripts/`)
These exist and are the automation for the reusable Win11 image (they also serve the future VLAN-50 client fleet):

| Script | What it automates | Learning boundary (does NOT automate) |
|---|---|---|
| `Prep-GoldenImage.ps1` | Generic machine settings + build-cruft cleanup (WinSxS reset, logs, DO cache, TRIM) — **generic only**, no name/IP/domain/RSAT/baseline | The *choice* of what's generic vs per-clone (image-design judgment) |
| `Test-SysprepReadiness.ps1` | Non-destructive GO/NO-GO (BitLocker, pending reboot, unprovisioned appx, disk) | Fixing what it flags — you read the `[FAIL]`/`[NOTE]` and decide |
| `Invoke-SysprepGeneralize.ps1` | Guarded seal (readiness check → dry-run → `/generalize` only with `-Execute`) | The decision to seal (irreversible for that image) |

> These live in `../Scripts/` (referenced by `Build-Guide.md` Part 1d). Kept there so the Build-Guide's existing links stay valid (`POL-0008`); this page is their index + the how-to.

## Planned automation (designed, phased — `ADR-0048` ladder)

| Task | Tool | What it automates | Learning boundary |
|---|---|---|---|
| **Baseline + PAW hardening as code** | PowerShell **DSC** / GPO backups in git | Reproduce the Win11 SCT baseline + `PAW-Tier0-Hardening` (CredGuard/AppLocker/firewall) | The **hardening review** (Tier-0 security judgment — manual) |
| **RSAT install** | PowerShell (`Add-WindowsCapability`) | Install the RSAT feature set idempotently | — |
| **Clone → join → OU placement** | PowerShell / unattend | Pre-stage the object + a scripted join into the PAW OU | The tier-model design |
| **Cloud PAW (Phase 3)** | Intune config / Autopilot | Enrolment, compliance, Conditional Access, Defender for Endpoint | Lands with H1/H2 (MD-102); designed stub now |

## How this fits the estate
- **Phase alignment:** golden-image scripts = Roadmap Phase 1 (done); the rest at Phase 4 after the manual PAW build. Estate sequencing: Build-Order **Phase 10** (`ADR-0048`).
- **Cert anchor:** DSC/baseline-as-code (AZ-800/801), the Intune path (MD-102), scripting (CCNA Dom-6-adjacent).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the `Automation/` slice for PAW01 (`ADR-0048`) — **indexes the already-present `../Scripts/`** golden-image finalize automation (with learning boundaries) + the planned baseline-as-code, RSAT install, scripted clone/join, and the cloud PAW (Phase 3). Notes the AppLocker constraint on on-box automation. |
