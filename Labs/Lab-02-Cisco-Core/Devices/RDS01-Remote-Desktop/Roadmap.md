---
Title: RDS01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop
Status: 🟢 LIVING roadmap — the build path for the RD Session Host + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`).
Version: 1.1
Date: 2026-07-30
---

# RDS01 — Roadmap (build path + connections)

> **How to read this.** Each row is a stage. **Needs** = healthy-first; **Unblocks** = what proceeds. Detail: `Build-Guide.md`.

## The build path (in order)

### Phase 0 — Gate
- [ ] 🔴 **NPS01 built** (RD Gateway CAP/RAP home, `ADR-0029`) + **ICA01 issuing** (gateway/RDP TLS cert, `ADR-0027`) + **DC healthy** (AD+DNS, access groups). *Why:* the gateway authorization, its TLS cert, and domain-join all gate the build. *(Estate slot: after NPS01 — `Service-Server-Build-Plan.md`.)*

### Phase 1 — Host stand-up
- [ ] 📋 Clone Win Server 2025 → **RDS01** (from the PAW01 golden image); domain-join → `OU=Servers,OU=Devices` → `gpupdate`. Placement **PVE02/EQR6 (always-on)** (`ADR-0036` v1.2), VLAN 20 `10.20.0.17` *(proposed)*.

### Phase 2 — RDS roles + collection
- [ ] 📋 Install **RD Session Host** + **RD Gateway / RD Web Access** + **RD Licensing** *(Gateway/Web included — operator 2026-07-30)*. Create a **session collection**; grant access to a **standard-user AD group** (dept role global / `G-IT-Staff`), **not** `G-Tier0-Admins` (`ADR-0021`). *Unblocks:* publishing.
- [ ] 📋 Install the **license server** + activate; add **RDS CALs** (per-user/device) — **before the 120-day grace expires**. *Needs:* CALs procured.

### Phase 3 — Publishing + certificate application
- [ ] 📋 Publish a **RemoteApp / full desktop** to the collection.
- [ ] 📋 **Certificate application:** enrol a TLS cert from **ICA01**; bind it to the **RD Gateway / RD Web / RDP listener** (`ADR-0027`). *Unblocks:* TLS access.

### Phase 4 — Gateway authorization (NPS)
- [ ] 📋 Point RD Gateway at **NPS01** as the central policy store; author **CAP** (who) + **RAP** (to what), **deny-by-default**, keyed to **AD group** (`ADR-0029`). *Needs:* NPS01 + a RADIUS client entry for RDS01 (shared secret → Vaultwarden, `POL-0002`).

### Phase 5 — Session lockdown + tier separation
- [ ] 📋 Apply session/security **GPOs** (drive/clipboard/printer redirection policy, idle/session limits, RDS host hardening). Confirm **no Tier-0 access via RDS**.

### Phase 6 — Acceptance
- [ ] 🎯 A domain user launches a **published desktop/app through the gateway over TLS**; **NPS01 logs the CAP/RAP authorization**; **tier separation holds** (a Tier-0 account cannot reach T0 systems from RDS).

### Phase 7 — Automation onboarding (`ADR-0048`)
- [ ] 📋 DSC RDS role + scripted collection/RemoteApp publishing → `Automation/` (idempotent, after the manual pass).

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | DC01 (join + access groups + session/gateway GPOs) | AD group → collection + CAP/RAP |
| ⬆ Depends on | ICA01 (`ADR-0027`) | gateway/RDP **TLS cert** |
| ⬆ Depends on | NPS01 (`ADR-0029`) | RD Gateway **CAP/RAP** (RADIUS) |
| ⬆ Depends on | RDS CALs / license server | licensing (before grace expires) |
| ⬇ Serves | standard (non-Tier-0) users | published desktop / RemoteApp over TLS |

## Certification alignment (learning lens)
| RDS01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| RD Session Host + collection | RDS role deploy/config | AZ-800/801 (→AZ-802 2026-09-30) · 70-741 |
| RD Gateway + CAP/RAP on NPS | secure remote access, policy-based auth | AZ-800/801 (→AZ-802 2026-09-30) · Security+ (secure remote access) |
| TLS cert from ICA01 (gateway/RDP) | PKI-issued service cert, TLS binding | AZ-800/801 (→AZ-802 2026-09-30) · Security+ (PKI) |
| Session GPOs + tier separation | GPO hardening, least privilege | AZ-800/801 (→AZ-802 2026-09-30) · Security+ (access control) |
| RD Licensing (CALs) | RDS licensing model | AZ-800/801 (→AZ-802 2026-09-30) · 70-741 |

## Staged traffic-flow
> Visualizes the flows matrix (owner): user → **RD Gateway 443/TLS** → **session host 3389** (E-W, intra-estate); RDS01 → **NPS01 RADIUS 1812/1813** for CAP/RAP; RDS01 → DC (auth/GPO) + ICA01 (cert enrol/CRL); everything else to RDS01 denied + logged. **No N-S** this era (not external-facing). Drawn stage-by-stage as each unit (collection → gateway TLS → CAP/RAP → session GPO) is applied (`ADR-0041`).

## Validation
- Prove-it: `../../Operations/Validation-and-Adversarial-Testing.md` + `Diagnostics.md`. Key proofs: a standard user launches a published app **through the gateway over TLS**; **NPS logs the CAP/RAP hit**; a **Tier-0 account is denied** T0 reach from RDS (the negative test).

## Future / later phases
- [ ] 📋 **External-facing publishing** — only behind FGT01 + a hardened, published RD Gateway (own gate). [ ] 📋 **RD Connection Broker + a second session host** (HA / farm) if load warrants. [ ] 📋 **Azure Virtual Desktop** comparison (Phase H2 cloud). [ ] 📋 **FSLogix / profile containers** if profiles grow.

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `README.md` · `Considerations.md`. Estate index: `../../Service-Server-Build-Plan.md`. `ADR-0029` (NPS) · `ADR-0027` (ICA01 PKI) · `ADR-0021` (tiering).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **Operator decisions folded in:** placement → **PVE02/EQR6 always-on** (user-facing availability, `ADR-0036` v1.2); **RD Gateway/Web included** (no longer "if chosen"); collection access grounded in the AGDLP model (standard-user dept global / `G-IT-Staff`, never `G-Tier0-Admins`). VLAN confirmed **20 (Servers)** — a client-reached service workload (the NetBox pattern), reached via flows-matrix **flow #3** + the new RD-Gateway flow. |
| 1.0 | 2026-07-30. Created — build path + connections for the RD Session Host (DC-template replication, Batch A). Phased (gate NPS+ICA+DC → host → roles+collection+licensing → publishing+cert → gateway CAP/RAP → session lockdown+tier-separation → acceptance → automation), placement PVE01/VLAN 20, cert alignment, the TLS/CAP-RAP staged flow, and future external-facing / broker / AVD phases. Sourced from the Wave-B stub + `Service-Server-Build-Plan.md`. |
