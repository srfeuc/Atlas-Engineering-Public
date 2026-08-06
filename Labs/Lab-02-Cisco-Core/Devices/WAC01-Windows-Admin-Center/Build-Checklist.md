---
Title: WAC01 — Build Checklist (Windows Admin Center gateway)
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center
Status: 📋 Target design — line-item, dated, evidence-backed (`POL-0001`). Mirrors `Roadmap.md`.
Version: 1.0
Date: 2026-07-30
---

# WAC01 — Build Checklist (Windows Admin Center gateway)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Gateway-mode WAC — the Tier-0 management surface (`ADR-0045`). Placement **PVE02/EQR6 (always-on)**, **VLAN 10** `10.10.0.5` *(proposed)*. Every `[ ]` → `[x]` only with a command + its output (`POL-0001`). Detail: `Build-Guide.md`.

## Phase 0 — Gate
- [ ] 🔴 DC healthy (AD+DNS) + **Tier-0 admin group** exists · **ICA01 issuing** (TLS cert) · **PAW01** exists (admin path) · **≥1 member server to manage** (`ADR-0045`).

## Phase 1 — Host stand-up
- [ ] Clone Win Server 2025 → **WAC01**; domain-join → `OU=Servers,OU=Devices` → `gpupdate`.
- **🎯 Gate:** domain-joined, correct OU, **VLAN 10** `10.10.0.5` addressing.

## Phase 2 — WAC gateway install + certificate
- [ ] Install **Windows Admin Center — gateway mode** (msi, `SME_PORT=443`); confirm the service is listening.
- [ ] Enrol an **ICA01** server cert (SAN = WAC FQDN); **bind it to the WAC gateway** (replace the self-signed) (`ADR-0027`).
- **🎯 Gate:** the console loads over **HTTPS with the ICA01 cert** (no trust/name warning) from PAW01.

## Phase 3 — Tier-0 lockdown + node onboarding
- [ ] **Access = PAW01 only:** WAC **gateway-administrator/user** roles keyed to a **Tier-0 AD group**; network ACL **443 → WAC01 only from PAW01** (deny + log elsewhere).
- [ ] **Add managed nodes** (DC01/DC02, member servers, Hyper-V) over **WinRM**; Tier-0-safe delegation (Kerberos; avoid unconstrained CredSSP).
- **🎯 Gate:** a managed node is reachable from the console; a non-PAW host is refused 443.

## Phase 4 — Acceptance
- [ ] 🎯 From **PAW01 only**, console over the ICA01 TLS cert; a **managed action on DC01 succeeds**; a **non-PAW host is denied** 443 to WAC01 (negative test); WAC unreachable from client/DMZ zones.

## Phase 5 — Azure Arc / hybrid (gated stub — Phase 11)
- [ ] 🔴 GATE: Azure tenant. Onboard managed servers to **Azure Arc**; connect WAC → Azure. *(Outline only until Phase 11.)*

## Phase 6 — Automation onboarding (`ADR-0048`)
- [ ] DSC/script the gateway install + extensions + node onboarding → `Automation/`.

## Failure modes
- 🔴 **WAC reachable from beyond PAW01** → a Tier-0 console exposed. Lock to PAW01 (roles + ACL); prove the denial.
- 🔴 **Self-signed / wrong-SAN gateway cert** → TLS warnings, broken trust. Use the ICA01 cert with the correct SAN.
- 🔴 **Unconstrained CredSSP delegation** → Tier-0 credential theft risk. Prefer Kerberos; scope delegation.
- 🟡 **On the wrong VLAN** → WAC is a Tier-0 admin surface → **VLAN 10 (management)**, not a client/server-app VLAN (operator 2026-07-30; see `Considerations.md`).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Created to the standard (replication Batch A, from `ADR-0045`) — phased with 🎯 gates (gate → host → gateway install+ICA01 cert → Tier-0 lockdown + node onboarding → acceptance → Arc stub → automation), plus the exposure / cert / delegation / VLAN failure modes. Placement PVE02/EQR6 always-on, VLAN 10. |
