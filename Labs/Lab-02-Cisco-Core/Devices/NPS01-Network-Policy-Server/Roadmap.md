---
Title: NPS01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server
Status: 🟢 LIVING roadmap — the build path for the RADIUS member server + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`); this page is the map, the checklist is the line-item record.
Version: 1.0
Date: 2026-07-29
---

# NPS01 — Roadmap (build path + connections)

> **How to read this.** Each row is a **stage** on the RADIUS host. The checkbox is its status — **dated** and evidence-backed (the record is `Build-Checklist.md`). **Needs** = what must be healthy first; **Unblocks** = what proceeds once it's done.

## The build path (in order)

### Phase 0 — Gate
- [ ] 🔴 **DC healthy** (AD + DNS) — NPS validates against AD; the host domain-joins. *Needs:* DC01 up, VLAN-20 reachability, a working clock.

### Phase 1 — Host stand-up
- [ ] 📋 **Rename a spare Win Server 2025 VM → NPS01**, reboot. *(Reuse, not build-from-scratch.)* Placement: PVE02/EQR6 always-on tier.
- [ ] 📋 **Domain-join `atlas.lab`** → move the computer object to `OU=Servers,OU=Devices` → `gpupdate /force` (server baseline GPO applies). *Unblocks:* the NPS role.
- [ ] 📋 **LAPS** on the local admin — NPS01 is the subject of the deferred **member-server LAPS test** (`ADR-0029` D7). *Unblocks:* closes that test.

### Phase 2 — NPS role + AD registration
- [ ] 📋 **Install NPS** (`Install-WindowsFeature NPAS -IncludeManagementTools`). *Needs:* domain-join.
- [ ] 📋 **Register NPS in AD** (adds NPS01 to **RAS and IAS Servers** so it can read dial-in props). *Unblocks:* policy evaluation against AD.

### Phase 3 — RADIUS clients + policies
- [ ] 📋 **Add RADIUS clients** — MKT01, SW01, 1941 — each with a **shared secret**. 🔴 Secrets → **Vaultwarden** (`POL-0002`); never in a doc/git.
- [ ] 📋 **Network policies** — map **AD group → device admin privilege level**; **deny-by-default** otherwise. *Unblocks:* real device logins.

### Phase 4 — Certificate application (from ICA01)
- [ ] 📋 **RAS-and-IAS-Server cert** from **ICA01** — enrol NPS01 (the AD-CS guide's previously-deferred "NPS server cert"). *Needs:* AD CS ceremony complete + CRL published. *Unblocks:* **PEAP/EAP-TLS** (password RADIUS/PAP/MS-CHAPv2 works without it). *Cert:* CCNA security · 70-741.

### Phase 5 — Hardening + acceptance
- [ ] 📋 Hardening pass (`POL-0007` / the server baseline); confirm **local break-glass** on every RADIUS client with NPS stopped.
- [ ] 🎯 **Acceptance:** one **real device → NPS login** succeeds end-to-end with the correct privilege level, **and** an unknown user is **rejected** (deny-by-default proven). Closes Review-Flag-Register **F14** (RADIUS was only ever localhost-tested under FreeRADIUS).

### Phase 6 — Automation onboarding (`ADR-0048`)
- [ ] 📋 After the manual build: capture DSC/PowerShell to install+configure NPS + **policy-as-code** in `Automation/` (idempotent).

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PVE02 → SW01 → MKT01 (gw `10.20.0.1`) | VLAN-20 reachability |
| ⬆ Depends on | DC01 (AD) | credential validation + group lookup; RAS-and-IAS registration |
| ⬆ Depends on | ICA01 (AD CS) | RAS-and-IAS-Server cert (PEAP) |
| ⬇ Serves | MKT01 · SW01 · 1941 | admin AAA (RADIUS 1812/1813) |
| ⬇ Serves | RDS01 (later) · 802.1X · FortiAP WPA2-Ent (K6) | gateway policy · wired/wireless auth |

## Certification alignment (learning lens)

| NPS01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| RADIUS clients + shared secrets | AAA, RADIUS server/NAS model | CCNA Dom-5 (security) · FortiGate (RADIUS auth) |
| AD-group → privilege policies | NPS network policies, conditions/constraints | 70-741 · AZ-800/801 (→AZ-802 2026-09-30)-adjacent |
| RAS-and-IAS-Server cert (PEAP) | Certificate-based auth, EAP types | CCNA security · 70-741 |
| Deny-by-default + break-glass | Least privilege, availability design | Security+ |
| 802.1X / WPA2-Enterprise (later, K6) | Port-based NAC, wireless enterprise auth | CCNA wireless/security |

## Staged traffic-flow (RADIUS reachability)

> Visualizes `Architecture/Atlas-East-West-Allowed-Flows-Matrix` flow #14 (the fact owner): network devices (MKT01/SW01/1941) → **NPS01 UDP 1812/1813**, permitted; NPS01 → DC (LDAP/Kerberos) for validation; **everything else to NPS01 denied + logged.** NPS01 stays **out** of the `.2–.9` Tier-0 identity micro-zone (it's in the server range).

## Validation
- Prove-it rows: `../../Operations/Validation-and-Adversarial-Testing.md` + this host's `Diagnostics.md`. Key proofs: a **real device login accepted** with the right level; an **unknown user rejected**; **break-glass works with NPS down**.

## Future / later phases
- [ ] 📋 **2nd NPS** for fault tolerance (`ADR-0029` review trigger; Microsoft ≥2-NPS).
- [ ] 📋 **802.1X** wired/wireless for domain machines + **FortiAP WPA2-Enterprise** (register **K6**).
- [ ] 📋 **RDS01 Gateway CAP/RAP** consumes NPS (Batch-A dependency).

## Related
- Line-item status: `Build-Checklist.md`. Front door: `README.md`. Open risks: `Considerations.md`. Verify: `Diagnostics.md`.
- Estate index: `../../Service-Server-Build-Plan.md`. Decision: `ADR-0029`. The CA that issues its cert: `../RCA01-ICA01-ADCS/`.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created — build path + connections for the RADIUS member server (part of the DC-template replication, Batch A). Phased (host → NPS role + AD registration → clients/policies → ICA01 cert → hardening/acceptance → automation), with the two-host-chain break-glass rule, the cert-alignment slice, the flow-#14 staged view, and the future phases (2nd NPS, 802.1X/WPA2-Ent K6, RDS01). |
