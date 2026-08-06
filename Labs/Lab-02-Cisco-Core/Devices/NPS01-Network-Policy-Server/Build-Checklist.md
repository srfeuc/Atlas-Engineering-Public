---
Title: NPS01 — Build Checklist (RADIUS member server)
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server
Status: 📋 Target design — the line-item, dated, evidence-backed action list (`POL-0001`). Mirrors `Roadmap.md`. Nothing ticked until a read-back is captured in `Diagnostics.md`.
Version: 1.0
Date: 2026-07-29
---

# NPS01 — Build Checklist (RADIUS member server)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Role (`ADR-0029` · CSF: **Protect/Identify**): Windows NPS = RADIUS for network-device admin AAA (MKT01/SW01/1941) vs AD. Domain-joined member server (**D7**: not the DC), VLAN 20, `10.20.0.12` *(proposed)*, PVE02/EQR6. NPS is **not** on Server Core → Desktop Experience.

> 🔴 **Two-host chain + break-glass.** Auth now needs NPS01 **and** the DC. Keep a **local break-glass admin** on every RADIUS client; prove it works with NPS down.

## Phase 0 — Gate
- [ ] 🔴 DC healthy (AD + DNS) · VLAN-20 reachable · clock synced.

## Phase 1 — Host stand-up
- [ ] Rename a spare Win Server 2025 VM → **NPS01**; reboot.
- [ ] **Domain-join** `atlas.lab`; move computer object to `OU=Servers,OU=Devices`; `gpupdate /force`.
- [ ] **LAPS** on the local admin (the member-server LAPS test, `ADR-0029` D7).
- **🎯 Gate:** `Get-ComputerInfo` shows domain `atlas.lab`, correct OU; server baseline GPO applied.

## Phase 2 — NPS role + AD registration
- [ ] `Install-WindowsFeature NPAS -IncludeManagementTools`.
- [ ] **Register server in Active Directory** (NPS console) → NPS01 joins **RAS and IAS Servers**.
- **🎯 Gate:** `Get-WindowsFeature NPAS` = Installed; NPS service running; NPS01 in RAS-and-IAS-Servers.

## Phase 3 — RADIUS clients + policies
- [ ] Add RADIUS clients **MKT01 · SW01 · 1941** — each a strong, unique **shared secret**. 🔴 secrets → **Vaultwarden** (`POL-0002`), never in git.
- [ ] Create **network policies**: AD group → device admin privilege level; **deny-by-default** otherwise.
- **🎯 Gate:** a test AD account in the admin group maps to the right level; policy order is deny-last.

## Phase 4 — Certificate application (ICA01)
- [ ] Enrol the **RAS-and-IAS-Server** cert from **ICA01** (for PEAP/EAP-TLS). *Gated on the AD CS ceremony + CRL publish.* Password RADIUS works without it.
- **🎯 Gate:** cert present in the machine store; PEAP offered (if in scope).

## Phase 5 — Hardening + acceptance
- [ ] Hardening pass (`POL-0007` / server baseline).
- [ ] 🔴 Confirm **local break-glass** on MKT01/SW01/1941 with NPS **stopped**.
- [ ] 🎯 **Acceptance (closes F14):** one **real device → NPS login accepted** with the correct privilege level, event logged in NPS; an **unknown user rejected** (deny-by-default proven).

## Phase 6 — Automation onboarding (`ADR-0048`)
- [ ] After the manual build: capture DSC/policy-as-code in `Automation/` (idempotent re-run).

## Failure modes
- 🔴 **NPS/DC down + no break-glass** → locked out of the network core. Prove break-glass first.
- 🔴 **Shared secret in git** → credential leak (`POL-0002`) — Vaultwarden only.
- 🔴 **No deny-by-default** → an unintended account gets device admin. Test the negative case.
- 🟡 **FGT01 added as a RADIUS client by reflex** → wrong; FGT uses LDAPS (`ADR-0028`).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created (DC-template replication, Batch A) — phased to mirror `Roadmap.md` with a 🔴 GATE + 🎯 acceptance per phase (host → NPS role/registration → clients/policies → ICA01 cert → hardening/acceptance → automation), the two-host-chain break-glass rule, and the F14-closing acceptance. Formalizes the outline from the v0.1 `Build-Guide.md` stub. |
