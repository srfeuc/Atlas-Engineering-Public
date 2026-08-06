---
Title: PAW01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin
Status: ⬜ NOT BUILT — authored plan. The `POL-0001` evidence home; every row ⬜ until a real read-back. Records outrank guides.
Version: 0.1
Date: 2026-07-29
---

# PAW01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** The "what is actually true now" snapshot for the golden image + the Tier-0 PAW (`POL-0001`; outranks the Build-Guide). Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

## Golden image
| Attribute | As-built target | Status | Evidence |
|---|---|---|---|
| Win11 VM (UEFI/SecureBoot/TPM2.0) | built, Audit-Mode customized, patched | ⬜ | Build-Guide Part 1 |
| Sealed (`sysprep /generalize`) | generalized + shut down | ⬜ | `Test-SysprepReadiness` GO |
| Proxmox template | `tmpl-win11-<date>`; test clone → OOBE | ⬜ | Part 1f |

## PAW01
| Attribute | As-built target | Status | Evidence |
|---|---|---|---|
| Clone | full clone, 2 vCPU / 8 GB | ⬜ | Part 2a |
| Placement | PVE02/EQR6 (🟡 or R410 spin-up) | ⬜ | `ADR-0036` v1.2 |
| Computer object / OU | pre-staged in `Admin\Tier 0\PAW` | ⬜ | ADUC |
| Network | VLAN 20 tagged · `10.20.0.10–.55` · gw `.1` · DNS `.2` | ⬜ | `Get-NetIPConfiguration` |
| Domain-join | member of `atlas.lab`, in the PAW OU | ⬜ | `Diagnostics.md` §2 |
| Win11 SCT baseline | GPO linked + applied | ⬜ | `gpresult /h` |
| PAW-Tier0-Hardening GPO | CredGuard · AppLocker · firewall · standard-user | ⬜ | `Diagnostics.md` §3 |
| Credential Guard running | VBS + CredGuard active | ⬜ (gated on VBS check) | `msinfo32` |
| RSAT installed | ADUC/GPMC/DNS + AD PS | ⬜ | `Get-WindowsCapability` |
| 7d cross-tier deny | Tier-1/2 denied logon here | ⬜ (gated on 7d) | `Diagnostics.md` §4 |
| Acceptance | RDP as `t0-seth` (Kerberos+clipboard); ADUC vs DC | ⬜ | `Diagnostics.md` §4 |

> 🔴 **Nothing here is built yet.** As each stage lands, capture the read-back in `Diagnostics.md`, flip the row ✅, tick the `Build-Checklist.md` gate (`POL-0001`).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `Diagnostics.md` · `Roadmap.md` · `Considerations.md` · `Scripts/`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Created as the (empty) as-built record for the golden image + Tier-0 PAW — all rows ⬜; fills in as each stage is device-verified. |
