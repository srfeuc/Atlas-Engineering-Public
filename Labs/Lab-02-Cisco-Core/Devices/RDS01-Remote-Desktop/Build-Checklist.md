---
Title: RDS01 — Build Checklist (Remote Desktop Services)
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop
Status: 📋 Target design — line-item, dated, evidence-backed (`POL-0001`). Mirrors `Roadmap.md`. Supersedes the v0.1 stub.
Version: 1.1
Date: 2026-07-30
---

# RDS01 — Build Checklist (Remote Desktop Services)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** RD Session Host + Gateway/Web for published desktops/apps (standard users only). Placement **PVE02/EQR6 (always-on)**, VLAN 20 `10.20.0.17` *(proposed)*. Every `[ ]` → `[x]` only with a command + its output (`POL-0001`). Detail: `Build-Guide.md`.

## Phase 0 — Gate
- [ ] 🔴 **NPS01 built** (CAP/RAP home, `ADR-0029`) · **ICA01 issuing** (TLS cert, `ADR-0027`) · **DC healthy** (AD+DNS) + access groups exist.

## Phase 1 — Host stand-up
- [ ] Clone Win Server 2025 → **RDS01**; domain-join → `OU=Servers,OU=Devices` → `gpupdate`.
- **🎯 Gate:** domain-joined, correct OU, VLAN 20 addressing.

## Phase 2 — RDS roles + collection + licensing
- [ ] `Install-WindowsFeature RDS-RD-Server, RDS-Licensing, RDS-Gateway, RDS-Web-Access -IncludeManagementTools` *(Gateway/Web included — operator 2026-07-30)*.
- [ ] Create a **session collection**; grant access to a **standard-user AD group** (dept role global / `G-IT-Staff`) — **exclude `G-Tier0-Admins`** (`ADR-0021`).
- [ ] Activate the **license server**; install **RDS CALs** (per-user/device) — **before the 120-day grace expires**.
- **🎯 Gate:** RDS roles installed; collection exists; license server activated + CALs installed.

## Phase 3 — Publishing + certificate application
- [ ] Publish a **RemoteApp / full desktop** to the collection.
- [ ] Enrol a **TLS cert from ICA01**; bind to the **RD Gateway / RD Web / RDP listener** (`ADR-0027`).
- **🎯 Gate:** a published app is visible; the deployment shows the ICA01 cert bound (no name/trust warning).

## Phase 4 — Gateway authorization (NPS01)
- [ ] Point RD Gateway at **NPS01** (central policy store); add RDS01 as a **RADIUS client** (shared secret → Vaultwarden, `POL-0002`).
- [ ] Author **CAP** (who may connect) + **RAP** (to what), **deny-by-default**, keyed to **AD group** (`ADR-0029`).
- **🎯 Gate:** a test connection authorizes via NPS (CAP/RAP hit logged on NPS01).

## Phase 5 — Session lockdown + tier separation
- [ ] Apply session/security **GPOs** (redirection policy, idle/session limits, RDS host hardening per `Architecture/CIS-Hardening-*`).
- [ ] Confirm **no Tier-0 access via RDS** (Tier-0 accounts excluded from the collection + CAP).
- **🎯 Gate:** session GPOs applied; a Tier-0 account is denied.

## Phase 6 — Acceptance
- [ ] 🎯 A domain user launches a **published desktop/app through the gateway over TLS**; **NPS01 logs the CAP/RAP authorization**; **tier separation holds** (a Tier-0 account cannot reach T0 systems from RDS).

## Phase 7 — Automation onboarding (`ADR-0048`)
- [ ] DSC RDS role + scripted collection/RemoteApp publishing → `Automation/`.

## Failure modes
- 🔴 **CALs not installed before the grace expires** → the session host stops accepting connections at day 121. Activate licensing + install CALs in Phase 2.
- 🔴 **Tier-0 reachable via RDS** → tier collapse. Exclude T0 from the collection + CAP; prove the denial (negative test).
- 🔴 **Gateway cert self-signed / wrong name** → client TLS warnings, broken RD Web SSO. Use the **ICA01** cert with the correct SAN (`ADR-0027`).
- 🟡 **Authorization built locally, not on NPS** → drifts from the estate policy model. Keep CAP/RAP on **NPS01** (`ADR-0029`).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **Operator decisions folded in:** placement → **PVE02/EQR6 always-on**; **Gateway/Web included** in the role install (no longer "if chosen"); collection access grounded to a standard-user dept global / `G-IT-Staff`, excluding `G-Tier0-Admins`. |
| 1.0 | 2026-07-30. Rebuilt to the standard (DC-template replication, Batch A) — phased with 🎯 gates (gate NPS+ICA+DC → host → roles+collection+licensing → publishing+cert → gateway CAP/RAP → session lockdown+tier-separation → acceptance → automation), plus the CALs-before-grace / Tier-0-separation / gateway-cert / NPS-not-local failure modes. Supersedes the v0.1 stub. |
