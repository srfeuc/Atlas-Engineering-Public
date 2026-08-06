---
Title: RDS01 — Remote Desktop Services Build Guide (phased, gated)
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop
Status: 📋 Target design — phased, gated rebuild contract (`ADR-0043`); mirrors `Roadmap.md`. NOT executed. Author live values + 📸 + gotchas at the bench (`POL-0001`). You write the config (Charter Rule 17).
Version: 0.2
Date: 2026-07-30
---

# RDS01 — Remote Desktop Services Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — RD Session Host on Win Server 2025, **PVE02/EQR6 (always-on)**, VLAN 20 `10.20.0.17` *(proposed)*. Work **phase by phase, each behind its 🔴 GATE**.

## Phase 0 — Gate 🔴
**GATE — do not start until:** **NPS01 built** (CAP/RAP home, `ADR-0029`) · **ICA01 issuing** (gateway/RDP TLS cert, `ADR-0027`) · **DC healthy** (AD+DNS) with the **access groups** created.

## Phase 1 — Host stand-up 🔴
**GATE:** Phase 0 ✅.
- **Service-setup:** clone Win Server 2025 → RDS01 → domain-join → `OU=Servers,OU=Devices` → `gpupdate`. 📸 domain/OU, the IP config.

## Phase 2 — RDS roles + collection + licensing 🔴
**GATE:** Phase 1 ✅.
- **Service-setup:** `Install-WindowsFeature RDS-RD-Server, RDS-Licensing, RDS-Gateway, RDS-Web-Access -IncludeManagementTools` *(Gateway/Web included — operator 2026-07-30)*. Create a **session collection**; grant access to a **standard-user AD group** (dept role global / `G-IT-Staff`; **exclude `G-Tier0-Admins`**, `ADR-0021`). 📸 the collection + its access group.
- **Licensing:** activate the license server; install **RDS CALs** (per-user/device). 📸 the licensing diagnoser (green). *(Gotcha: 120-day grace — don't skip this.)*

## Phase 3 — Publishing + certificate application 🔴
**GATE:** Phase 2 ✅.
- **Service-setup:** publish a **RemoteApp / full desktop** to the collection. 📸 the published resource.
- **Certificate-application:** enrol a server cert from **ICA01** (correct SAN for the gateway/RDWeb FQDN); bind it to the **RD Gateway / RD Web / RDP listener** via Deployment Properties → Certificates. 📸 the bound cert (no name/trust warning). *(Gotcha: the SAN must match the name clients use.)*

## Phase 4 — Gateway authorization (NPS01) 🔴
**GATE:** Phase 3 ✅. *(RD Gateway is in scope — operator 2026-07-30.)*
- **Service-setup:** point RD Gateway at **NPS01** (central policy store); on NPS add RDS01 as a **RADIUS client** (shared secret → **Vaultwarden**, `POL-0002`); author **CAP** (who) + **RAP** (to what), **deny-by-default**, keyed to **AD group** (`ADR-0029`). 📸 the CAP/RAP + a test authorization on NPS.

## Phase 5 — Session lockdown + tier separation 🔴
**GATE:** Phase 4 ✅.
- **Service-setup:** apply session/security **GPOs** (drive/clipboard/printer redirection policy, idle/session limits, RDS host hardening per `Architecture/CIS-Hardening-*`). Confirm **no Tier-0** access. 📸 the applied GPO (RSoP) + the T0-denied result.

## Phase 6 — Acceptance + automation-onboarding (`ADR-0048`) 🔴
- 🎯 a standard user launches a **published desktop/app through the gateway over TLS**; **NPS logs the CAP/RAP hit**; a **Tier-0 account is denied** T0 reach from RDS. 📸 each.
- Then capture DSC + collection/RemoteApp publishing automation in `../Automation/`.

## Future / cloud (gated stub)
- **External-facing publishing** (behind FGT01 + hardened gateway) · **Connection Broker + 2nd host** (farm/HA) · **Azure Virtual Desktop** comparison — full steps when the gate is reached.

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Diagnostics.md` · `ADR-0029` (NPS CAP/RAP) · `ADR-0027` (ICA01 TLS) · `ADR-0021` (tiering) · `Atlas-Academy/Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.2 | 2026-07-30. **Operator decisions folded in:** placement → **PVE02/EQR6 always-on**; **Gateway/Web included** (Phase 4 no longer conditional; role install adds RDS-Gateway/Web); collection access grounded to a standard-user dept global / `G-IT-Staff`, excluding `G-Tier0-Admins`. |
| 0.1 | 2026-07-30. Created — phased, gated Build-Guide (`ADR-0043`) mirroring `Roadmap.md`: gate (NPS+ICA+DC) → host → roles+collection+licensing → publishing+ICA01 cert → gateway CAP/RAP on NPS → session lockdown+tier-separation → acceptance+automation, with the external-facing/broker/AVD future stub. 📸 points; click-by-click at the bench. |
