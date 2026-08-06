---
Title: WAC01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center
Status: 🟢 LIVING roadmap — the build path for the WAC gateway + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`).
Version: 1.0
Date: 2026-07-30
---

# WAC01 — Roadmap (build path + connections)

> **How to read this.** Each row is a stage. **Needs** = healthy-first; **Unblocks** = what proceeds. Detail: `Build-Guide.md`.

## The build path (in order)

### Phase 0 — Gate
- [ ] 🔴 **DC healthy** (AD+DNS, Tier-0 admin groups) + **ICA01 issuing** (gateway TLS cert, `ADR-0027`) + **PAW01 exists** (the only admin path, `ADR-0021`) + **at least one member server to manage** (`ADR-0045` build-order note). *Why:* WAC is pointless with nothing to manage and unsafe without the Tier-0 admin path + TLS.

### Phase 1 — Host stand-up
- [ ] 📋 Clone Win Server 2025 → **WAC01** (from the PAW01 golden image); domain-join → `OU=Servers,OU=Devices` → `gpupdate`. Placement **PVE02/EQR6 (always-on)**, **VLAN 10** `10.10.0.5` *(proposed)*.

### Phase 2 — WAC gateway install + certificate application
- [ ] 📋 Install **Windows Admin Center in gateway mode** (`ADR-0045` — not desktop). *Unblocks:* the console.
- [ ] 📋 **Certificate application:** replace the WAC self-signed cert with an **ICA01-issued** cert (correct SAN = the WAC FQDN); bind it to the gateway (`ADR-0027`). *Unblocks:* trusted TLS from PAW01.

### Phase 3 — Tier-0 lockdown + target onboarding
- [ ] 📋 **Restrict access to PAW01 only** — WAC **gateway-administrator / gateway-user** roles keyed to a **Tier-0 AD group**; a network ACL allowing **443 to WAC01 only from PAW01** (deny elsewhere, log). *Needs:* the Tier-0 group + PAW01.
- [ ] 📋 **Add the managed nodes** (DC01/DC02, member servers, Hyper-V) over **WinRM**; confirm WinRM/TrustedHosts + CredSSP-or-Kerberos-delegation posture (Tier-0-safe). *Unblocks:* administering the estate.

### Phase 4 — Acceptance
- [ ] 🎯 From **PAW01** only, the WAC console opens over **TLS (ICA01 cert, no warning)**; a **managed server appears and an action succeeds** (e.g. read services/events on DC01); a **non-PAW host is denied** 443 to WAC01 (the negative test).

### Phase 5 — Azure Arc / hybrid (gated stub — Phase 11, `ADR-0043`)
- [ ] 📋 🔴 **GATE: Azure tenant + Phase 11.** Onboard WAC-managed servers to **Azure Arc** for hybrid management/monitoring; connect WAC to Azure. *(Outline only now — full steps when the tenant exists.)*

### Phase 6 — Automation onboarding (`ADR-0048`)
- [ ] 📋 DSC/script the WAC gateway install + extension set + node onboarding → `Automation/` (idempotent, after the manual pass).

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PAW01 (`ADR-0021`) | the only admin path — HTTPS 443 browse |
| ⬆ Depends on | ICA01 (`ADR-0027`) | gateway **TLS cert** |
| ⬆ Depends on | DC01 | domain-join · AD auth (Tier-0 group) · GPO |
| ⬇ Manages | Windows estate (DCs · member servers · Hyper-V) | **WinRM 5985/5986** |
| ⬇ On-ramps | Azure Arc (Phase 11) | hybrid management |

## Certification alignment (learning lens)
| WAC01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| WAC gateway install + node onboarding | hybrid/centralized management | AZ-800/801 (→AZ-802 2026-09-30) |
| ICA01 TLS cert on the gateway | PKI-issued service cert, TLS | AZ-800/801 (→AZ-802 2026-09-30) · Security+ (PKI) |
| Tier-0 lockdown (PAW-only, ACL) | privileged-access management | AZ-800/801 (→AZ-802 2026-09-30) · Security+ (access control) |
| WAC monitoring / events | server monitoring | AZ-801 (→AZ-802 2026-09-30) |
| Azure Arc on-ramp (Phase 11) | hybrid management / Arc | AZ-800/801 (→AZ-802 2026-09-30) · AZ-104 |

## Staged traffic-flow
> Visualizes the flows matrix (owner): **PAW01 → WAC01 443/TLS** (admin browse — the *only* inbound); **WAC01 → estate WinRM 5985/5986** (manage); WAC01 → DC (auth/GPO) + ICA01 (cert/CRL). Everything else to WAC01 (incl. non-PAW hosts) **denied + logged**. WAC01 lives on **VLAN 10 (management)** → its management reach is the estate control plane (flow #1, scoped by the new **flow #16**). Arc egress (N-S) only at Phase 11. Drawn stage-by-stage as each unit lands (`ADR-0041`).

## Validation
- Prove-it: `../../Operations/Validation-and-Adversarial-Testing.md` + `Diagnostics.md`. Key proofs: console opens over the ICA01 TLS cert **from PAW01**; a managed action on DC01 succeeds; **a non-PAW host is refused** 443 to WAC01 (negative test); WAC is not reachable from client/DMZ zones.

## Future / later phases
- [ ] 📋 **Azure Arc / hybrid mgmt** (Phase 11 — gated stub). [ ] 📋 Manage the **failover cluster** (`ADR-0046`) once built. [ ] 📋 WAC **extensions** as objectives call (Cluster Manager, Arc, monitoring).

## Related
- `Build-Checklist.md` · `Build-Guide.md` · `README.md` · `Considerations.md`. Estate index: `../../Service-Server-Build-Plan.md`. `ADR-0045` (this host) · `ADR-0027` (ICA01) · `ADR-0021` (tiering) · `ADR-0036` (placement).

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-30. Created — build path + connections for the WAC gateway (replication Batch A, from `ADR-0045`). Phased (gate DC+ICA01+PAW01+a-target → host → gateway install+ICA01 cert → Tier-0 lockdown + node onboarding → acceptance → **Arc gated stub (Phase 11)** → automation). Placement **PVE02/EQR6 always-on**, **VLAN 10** (operator 2026-07-30). Cert alignment AZ-800/801. |
