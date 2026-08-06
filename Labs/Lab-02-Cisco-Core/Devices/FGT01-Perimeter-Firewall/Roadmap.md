---
Title: FGT01 — Roadmap (config path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟢 LIVING — the config path for the N-S perimeter firewall. Pass-1 core ✅ device-verified; UTM + TLS deep-inspection gated on ICA01 + a live subscription. Status mirrors Build-Checklist + Diagnostics (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# FGT01 — Roadmap (config path + connections)

> **How to read this.** Each row is a **config stage** on the perimeter (the networking/security variant — egress/UTM/inspection, not services). Checkbox = status, evidenced by the `get`-read-backs in `Diagnostics.md` (`POL-0001`). **Needs** = healthy-first; **Unblocks** = what proceeds. Cert objective per stage (`ADR-0044`). 🔴 UTM profiles are only trusted with a **verified live subscription** (`get system status`, `ADR-0047`).

## The config path (in order)

### Phase 2 / 2.5 — Base + hardening + egress — ✅ core device-verified
- [x] ✅ **Hardening + egress core** — named admin + `trusthost` scoped (default `admin` → `fortigateadmin` break-glass); **no mgmt on WAN**; egress policy + **NAT**; `logtraffic all`; 1941 transit + internet egress reachable; **FortiToken MFA** (no CA needed). *(07-21; `../../Architecture/CIS-Hardening-FGT01.md`, `Diagnostics.md` §1/§3/§4.)* 🟡 read-backs: firmware/in-support, `strong-crypto`, private-data encryption, NTP. *Cert:* FCP (system/hardening) · Security+.

### Phase 2.5 — Admin auth via direct LDAPS (gated) — `ADR-0028`
- [ ] 📋 **Direct LDAPS to the DCs** (`Build-Guide-2b`) — FGT01 is the **exception**: admin auth binds **straight to AD over LDAPS**, not RADIUS/NPS. *Gate:* the DC LDAPS cert (Phase 8). Keep the `fortigateadmin` local break-glass. *Cert:* FCP (auth) · Security+.

### Phase 8 — UTM + TLS deep-inspection (gated — `ADR-0047`, `Build-Guide-3`)
- [ ] 🔴 **Gate:** the **ICA01 CA cert** (K1 inspection CA) **+** a **verified live FortiGuard subscription** (`get system status`). Until both, profiles stay detached (`ADR-0035` posture survives).
- [ ] 📋 **FortiGuard UTM profiles** — **web filtering · antivirus · IPS · application control** on egress. 🔴 **DNS filtering is OFF** (K2 — Pi-hole owns DNS filtering; see below). *Needs:* the gate. *Unblocks:* N-S content inspection. *Cert:* **FCP §3 (content inspection)**.
- [ ] 📋 **K1 — selective TLS deep-inspection** *(decided, operator 2026-07-30 → its own Section-K ADR):* deep-inspect (decrypt) outbound web for the **client/user zones**, with **exclusions** (banking/health/privacy + certificate-pinned apps → certificate-inspection-only); the FGT **re-signing CA is a subordinate issued by ICA01** and **pushed to domain machines' Trusted Root via GPO**. *Needs:* ICA01 + the GPO trust push. *Cert:* FCP (SSL inspection) · AD cert-distribution. ⚠️ Watch the 60E throughput ceiling.

### Phase 6 — Telemetry (deferred)
- [ ] 📋 **syslog → MON01** (UTM + traffic + admin logs). *Needs:* MON01. *Cert:* FCP (logging) · CCNA (syslog).

## Decided this pass (operator 2026-07-30) — the Section-K calls FGT01 carries
- ✅ **K1 — TLS deep-inspection:** *selective* deep-inspect + **ICA01-issued inspection CA, GPO-trusted** (above). → its own Section-K ADR.
- ✅ **K2 — DNS filtering:** **Pi-hole owns DNS security filtering; FortiGuard DNS filter stays OFF** — DNS control lives in one place (the non-domain Pi-hole forwarder, `Devices/Pi01-DNS-NTP/`). Avoids two overlapping DNS filters. → its own Section-K ADR.
- 🔎 **K3 — FSSO / identity-aware policy — PROPOSED, not a hard decision yet (deferred to the refinement pass).** The insight (operator): it's **not either/or** — **zone/subnet is the structural base (already built: the flows matrix + FGT egress zones), and FSSO layers identity-awareness *on top* — run both together.** Plan: a **two-phase learning lab** — *(1)* stand up **FSSO** to learn the mechanics, *(2)* integrate with **AD** and run it alongside the zone/subnet policy. Written up as an Academy concept + a Backlog item; **no build commitment here.**

## Future / gated stubs
- [ ] 📋 **FSSO identity layer** (K3, proposed) — user/group-aware N-S policy + usernames in logs, *layered on* the zone base. → `Atlas-Academy/Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md` + Backlog. *Cert:* FCP (FSSO) · Security+ (identity-aware policy).
- [ ] 📋 **S2S VPN from FGT01** (Phase 11 / H4 — Azure) — the hybrid-cloud edge. *Cert:* AZ-104 · CCNP.

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | home router → internet | egress + FortiGuard DB/subscription |
| ⬆ Depends on | 1941 (`10.255.255.2`) | `internal` transit /30 |
| ⬆ Depends on | DC (LDAPS) · ICA01 | admin auth (`ADR-0028`) · TLS-inspection CA (K1) |
| ⬇ Serves | estate egress + inbound-deny | the single N-S chokepoint |
| ⬇ Serves | pfSense IPS (transit) · MON01 (syslog) | complementary free IPS (`ADR-0038`) · logs |

## Certification alignment (learning lens)
| FGT01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| Hardening / trusthost / no-WAN-mgmt | system hardening, admin access | FCP · Security+ |
| Egress policy + NAT | firewall policy, NAT | FCP · CCNA (5.x) |
| Direct LDAPS admin auth | remote auth (LDAPS) | FCP · Security+ |
| FortiGuard UTM (web/AV/IPS/app-ctrl) | content inspection, security profiles | **FCP §3** |
| Selective TLS deep-inspection (K1) | SSL/TLS inspection, inspection-CA trust | FCP · AD PKI/GPO |
| FSSO (K3, proposed) | identity-aware policy | FCP · Security+ |
| S2S VPN (H4) | site-to-site IPsec | FCP · AZ-104 · CCNP |

## Related
- The how: `Build-Guide-Index.md` (+ `-1`/`-2`/`-2b`; `-3` gated). Read the logs: `Logging-and-Flow-Tracing-Field-Guide.md`. Verify: `Diagnostics.md`. Open risks + the K1/K2/K3 record: `Considerations.md`. As-built: `Build-Record.md`.
- Owners: `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` (+ `ADR-0047`/`ADR-0038`) · `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../../Operations/Build-Order-and-Dependencies.md` · `Atlas-Academy/Atlas-FortiGate-FCP-Lab-Map.md` · `Atlas-Academy/Concepts/Identity-Aware-vs-Zone-Firewall-Policy.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the config-path roadmap for the N-S perimeter (networking/security variant): Pass-1 core ✅ device-verified (07-21); direct-LDAPS admin auth (`ADR-0028`) gated; **FortiGuard UTM + TLS deep-inspection gated** on ICA01 + a live subscription (`ADR-0047`, the confidence trap); syslog→MON01 deferred. **Recorded the Section-K decisions (operator 2026-07-30):** K1 selective deep-inspect + ICA01 inspection-CA via GPO (decided); K2 Pi-hole owns DNS filtering, FGT DNS filter OFF (decided); K3 FSSO identity-layer PROPOSED (both-together with the zone base; two-phase lab; deferred → concept + Backlog). Cert-aligned FCP/NSE + Security+. Status mirrors Build-Checklist + Diagnostics (`POL-0001`). |
