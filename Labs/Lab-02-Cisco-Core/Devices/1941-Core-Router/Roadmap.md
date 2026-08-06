---
Title: 1941 — Roadmap (config path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
Status: 🟢 LIVING — the config path for the routed core. Phase-2 core is ✅ device-verified; status mirrors Build-Checklist + Diagnostics (POL-0001).
Version: 0.2
Date: 2026-07-30
---

# 1941 — Roadmap (config path + connections)

> **How to read this.** Each row is a **config stage** on the core router (the networking variant of the build path — interfaces/OSPF/hardening, not services). Checkbox = status, evidenced by the `show`-read-backs in `Diagnostics.md` (`POL-0001`). **Needs** = healthy-first; **Unblocks** = what proceeds. Cert objective per stage ([`ADR-0044`](../../../../00-Atlas-Foundation/Decisions/ADR-0044-Enterprise-Model-Standard-Certs-Anchor-Skills.md)).

## The config path (in order)

### Phase 2 — Network foundation (base + hardening + routing) — ✅ device-verified
- [x] ✅ **Base + hardening (CIS IOS)** — hostname/domain, `crypto key` 2048, **SSHv2-only**, named admin (Type-9), no http/telnet, `login block-for`, exec-timeouts, `no ip source-route`/`proxy-arp`, CDP off transit. *(07-22; `../../Architecture/CIS-Hardening-1941.md`, `Diagnostics.md` §1/§3.)* *Cert:* CCNA (device hardening, SSH, secure access).
- [x] ✅ **Interfaces — two routed /30s + Lo0** — Gi0/1→FGT01 `10.255.255.2`, Gi0/0→MKT01 `10.255.255.5`, Lo0 `10.255.0.1`; **no VLANs/subinterfaces**. *Needs:* cabling. *Cert:* CCNA (IPv4 addressing, interfaces).
- [x] ✅ **OSPF area 0 + default** — RID `10.255.0.1`, the two /30s in OSPF, `passive-interface Gi0/1`, static default → FGT01, `default-information originate`. **Adjacency with MKT01 FULL** (07-21). *Unblocks:* MKT01 learns the default; estate egress. *Cert:* CCNA (OSPF) · CCNP ENARSI (OSPF depth).
- [x] ✅ **vty `MGMT-SSH` access-class** — mgmt-scoped remote access (07-22). *Cert:* CCNA (secure mgmt).

### Phase 2.5 — Pass-2 AD-backed admin auth (gated)
- [ ] ⬜ **RADIUS to NPS01** ([`ADR-0029`](../../../../00-Atlas-Foundation/Decisions/ADR-0029-Drop-FreeRADIUS-Windows-NPS.md)) — network-device admin login moves to Windows NPS; keep **one local break-glass** (never PKI-ify it). *Needs:* DC + AD CS (NPS server cert) + NPS01 built. *Cert:* CCNA (AAA) · Security+.

### Phase 4/6 — Management telemetry (deferred)
- [ ] 📋 **NTP client** → the [`ADR-0020`](../../../../00-Atlas-Foundation/Decisions/ADR-0020-NTP-Time-Source-Architecture.md) source (temp upstream now → DC PDCe later). *(Diagnostics shows NTP converging 07-22.)* *Cert:* CCNA (NTP/IP services).
- [ ] 📋 **SNMPv3 + syslog + NetFlow → MON01** — the deferred "Phase 6" telemetry (no v2c community). *Needs:* MON01. *Unblocks:* the Phase-7 flow evidence. *Cert:* CCNA (SNMP/syslog) · CCNP ENAUTO (NetFlow).

### Future / CCNP (gated stub)
- [ ] 📋 **Zone-Based Firewall (ZBF) on the 1941** — Section K **K5** (a CCNP security topic); a decision + its own ADR when reached. *Cert:* CCNP ENCOR/ENARSI (ZBF).

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | FGT01 (`10.255.255.1`) | transit /30 + egress default ([`ADR-0005`](../../../../00-Atlas-Foundation/Decisions/ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md)) |
| ⬆ Depends on | MKT01 (`10.255.255.6`) | OSPF area 0 adjacency + VLAN routes |
| ⬆ Depends on | NTP source · NPS01 (Pass-2) | time (`ADR-0020`) · RADIUS admin auth (`ADR-0029`) |
| ⬇ Serves | MKT01 | the default route (via `default-information originate`) |
| ⬇ Serves | estate N-S traffic | host → MKT01 → 1941 → FGT01 → internet |

## Certification alignment (learning lens)
| 1941 stage | Exercises (exam objective) | Cert |
|---|---|---|
| SSH / hardening / vty scoping | secure device access, CIS baseline | CCNA (2.x/5.x) |
| /30s + loopback | IPv4 addressing, interfaces, loopbacks | CCNA (1.x) |
| OSPF area 0 (single-area) | OSPF neighbors/areas, router-id, default-information | CCNA (3.x) · CCNP ENARSI |
| static default + redistribution | static routing, route origination | CCNA · CCNP ENARSI |
| RADIUS admin (Pass-2) | AAA | CCNA (5.x) · Security+ |
| NTP / SNMPv3 / syslog / NetFlow | IP services, network mgmt/telemetry | CCNA (4.x) · CCNP ENAUTO |
| ZBF (future) | zone-based firewall | CCNP ENCOR/ENARSI |

> 🎓 **Cert maps for these objectives:** [CCNA · Certification-Lab-Map](../../../../Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md) · [CCNP · CCNP-Lab-Map](../../../../Atlas-Academy/Certification/Atlas-CCNP-Lab-Map.md).

## Related
- Line-item + failure modes: [`Build-Checklist.md`](Build-Checklist.md). The how: [`Build-Guide.md`](Build-Guide.md). Verify: [`Diagnostics.md`](Diagnostics.md). Open risks: [`Considerations.md`](Considerations.md). As-built: [`Build-Record.md`](Build-Record.md).
- Owners: [`IP-Addressing-Plan-VLSM`](../../Architecture/IP-Addressing-Plan-VLSM.md) · [`Cabling-and-Port-Map`](../../Architecture/Cabling-and-Port-Map.md) · [`Build-Order-and-Dependencies`](../../Operations/Build-Order-and-Dependencies.md) (Phase 2) · cert maps: [CCNA](../../../../Atlas-Academy/Certification/Atlas-Certification-Lab-Map.md) · [CCNP](../../../../Atlas-Academy/Certification/Atlas-CCNP-Lab-Map.md); domain directory: [`Network-and-Addressing`](../../../../Atlas-Academy/Directory/Network-and-Addressing.md).

## Change Log
| Version | Date | Change |
| 0.2 | 2026-08-04 | **#43 Pass B** — Academy up-links: the Certification-alignment table + Related now link the CCNA/CCNP cert maps and the `Network-and-Addressing` domain directory. No content change. |
| 0.1 | 2026-07-30 | Created — the config-path roadmap for the routed core (networking variant): Phase-2 base+hardening+routing ✅ device-verified (07-21/07-22), Pass-2 RADIUS-to-NPS01 gated, Phase-4/6 mgmt telemetry (NTP/SNMPv3/syslog/NetFlow) deferred, ZBF (K5/CCNP) as a gated stub. Cert-aligned CCNA/CCNP. Status mirrors Build-Checklist + Diagnostics (`POL-0001`). |
