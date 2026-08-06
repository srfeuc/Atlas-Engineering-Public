---
Title: WAC01 — Windows Admin Center Build Guide (phased, gated)
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center
Status: 📋 Target design — phased, gated rebuild contract (`ADR-0043`); mirrors `Roadmap.md`. NOT executed. Author live values + 📸 + gotchas at the bench (`POL-0001`). You write the config (Charter Rule 17).
Version: 0.1
Date: 2026-07-30
---

# WAC01 — Windows Admin Center Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — gateway-mode WAC on Win Server 2025, **PVE02/EQR6 (always-on)**, **VLAN 10** `10.10.0.5` *(proposed)*. Tier-0 management surface — PAW-only. Work **phase by phase, each behind its 🔴 GATE**.

## Phase 0 — Gate 🔴
**GATE — do not start until:** DC healthy (AD+DNS) + a **Tier-0 admin group** · **ICA01 issuing** (TLS cert, `ADR-0027`) · **PAW01** exists (the admin path, `ADR-0021`) · **≥1 member server to manage** (`ADR-0045`).

## Phase 1 — Host stand-up 🔴
**GATE:** Phase 0 ✅.
- **Service-setup:** clone Win Server 2025 → WAC01 → domain-join → `OU=Servers,OU=Devices` → `gpupdate`. Set **VLAN 10** static `10.10.0.5` (gw `10.10.0.1`, DNS `10.20.0.2`). 📸 domain/OU, the IP config.

## Phase 2 — WAC gateway install + certificate 🔴
**GATE:** Phase 1 ✅.
- **Service-setup:** install **Windows Admin Center — gateway mode** (`msiexec /i WindowsAdminCenter.msi /qn SME_PORT=443 SSL_CERTIFICATE_OPTION=generate` first, then swap the cert). 📸 the install + the service listening on 443.
- **Certificate-application:** request a server cert from **ICA01** (SAN = the WAC FQDN); **bind it to the WAC gateway** (WAC settings → certificate, or re-run the installer with the thumbprint). 📸 the bound cert (no name/trust warning). *(Gotcha: the SAN must match the URL PAW uses; the WAC computer cert ≠ the gateway cert.)*

## Phase 3 — Tier-0 lockdown + node onboarding 🔴
**GATE:** Phase 2 ✅.
- **Service-setup (access):** set WAC **gateway-administrator / gateway-user** to a **Tier-0 AD group**; add a network ACL so **TCP 443 → WAC01 is allowed only from PAW01** (deny + log elsewhere). 📸 the role config + the ACL.
- **Service-setup (targets):** **Add connections** for DC01/DC02, member servers, Hyper-V; over **WinRM** (5985/5986). Use **Kerberos**; avoid unconstrained **CredSSP** (Tier-0 credential-theft risk). 📸 a managed node listed.

## Phase 4 — Acceptance 🔴
- 🎯 From **PAW01 only**: console over the **ICA01 TLS cert** (no warning); a **managed action on DC01 succeeds** (e.g. view services/events); a **non-PAW host is refused** 443 (negative test). 📸 each.

## Phase 5 — Azure Arc / hybrid (gated stub — Phase 11) 🔴
**GATE:** Azure tenant + Phase 11. Onboard managed servers to **Azure Arc**; connect WAC → Azure for hybrid management/monitoring. *(Outline only now; full click-steps when the tenant exists.)*

## Phase 6 — Automation-onboarding (`ADR-0048`)
- Capture the gateway install + extension set + node onboarding as DSC/script in `../Automation/` (idempotent), after the manual pass.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Diagnostics.md` · `ADR-0045` (this host) · `ADR-0027` (ICA01 TLS) · `ADR-0021` (tiering) · `Atlas-Academy/Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Created — phased, gated Build-Guide (`ADR-0043`) mirroring `Roadmap.md`: gate (DC+ICA01+PAW01+a-target) → host (VLAN 10) → gateway install + ICA01 cert → Tier-0 lockdown (PAW-only ACL + role) + WinRM node onboarding (Kerberos, not CredSSP) → acceptance (+ negative test) → **Arc gated stub (Phase 11)** → automation. 📸 points; click-by-click at the bench. |
