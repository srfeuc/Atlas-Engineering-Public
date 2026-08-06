---
Title: MKT01 — Roadmap (config path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
Status: 🟢 LIVING — the config path for the E-W firewall + inter-VLAN gateway. Pass-1 + gateway + OSPF ✅ device-verified; the E-W policy is deliberately permissive until Phase 7 (from evidence). Status mirrors Build-Checklist + Diagnostics (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# MKT01 — Roadmap (config path + connections)

> **How to read this.** Each row is a **config stage** on the E-W firewall / inter-VLAN gateway (the networking variant — gateways/OSPF/firewall policy, not services). Checkbox = status, evidenced by the `print`-read-backs in `Diagnostics.md` (`POL-0001`). **Needs** = healthy-first; **Unblocks** = what proceeds. Cert objective per stage (`ADR-0044`). 🔴 The **default-deny east-west** stage is built **from evidence at Phase 7**, never during bring-up.

## The config path (in order)

### Phase 2 — Base + hardening — ✅ device-verified
- [x] ✅ **Base + hardening (CIS RouterOS)** — only **ssh + winbox** exposed + scoped; telnet/ftp/www/api disabled; named admin `mikrotikadmin` (`admin` off); NTP synced (source DC01); SNMP off. *(07-22; `../../Architecture/CIS-Hardening-MKT01.md`, `Diagnostics.md` §1/§2/§3.)* *Cert:* MTCNA / Security+ (device hardening).

### Phase 2 — Inter-VLAN gateway + routing
- [ ] 🟡 **VLAN SVIs (the 9 gateways)** — `10.<vlan>.0.1` per VLAN on `bridge-trunk`; transit `10.255.255.6`; loopback `10.255.0.2`. 🔴 **Hardware-offload OFF** on the bridge ports (the RB1100 RTL8367 offload trap — `Troubleshooting.md`). *Needs:* SW01 trunk. *Unblocks:* inter-VLAN reach. *Cert:* CCNA (inter-VLAN routing) · MTCNA.
- [x] ✅ **OSPF area 0 with 1941** — **adjacency FULL** (07-21); advertises the VLAN routes northbound; learns the default via 1941 (`10.255.255.5`). *Unblocks:* estate egress. *Cert:* CCNA (OSPF) · CCNP ENARSI.

### Phase 3h — DHCP relay (gated on DC01 DHCP)
- [ ] 📋 **DHCP relay per served VLAN → DC01** (`10.20.0.2`, `ADR-0030`) — infra stays static; the client/deployment/testing VLANs relay. *Needs:* DC01 DHCP stood up. *Cert:* CCNA (DHCP relay).

### Phase 2 → temporary permissive filter
- [ ] 🟡 **Permissive base filter (temporary)** — bring-up is permissive by design; input-chain mgmt lockdown + logging present. *Unblocks:* connectivity now; the Phase-7 tightening later.

### Phase 2.5 — Pass-2 AD-backed admin auth (gated)
- [ ] ⬜ **RADIUS to NPS01** (`ADR-0029`, flow #14) — admin login moves to Windows NPS; keep **one local break-glass** (never PKI-ify it). *Needs:* DC + AD CS + NPS01. *Cert:* CCNA (AAA) · Security+.

### Phase 6 — Telemetry (the evidence source — deferred)
- [ ] 📋 **rsyslog + NetFlow → MON01** — MKT01's flow export is **what the Phase-7 matrix is built from**. *Needs:* MON01. *Unblocks:* Phase 7. *Cert:* CCNA (syslog) · CCNP ENAUTO (NetFlow).

### Phase 7 — 🔴 Default-deny east-west (from evidence) — the headline
- [ ] 🔴 **Fill the flows matrix from NetFlow, then flip permissive → default-deny + log** — incremental, **one scoped rule at a time, each tested** (`ADR-0041`); Tier-0 `.2–.9` micro-zone (#9) and **OT VLAN 90** (#11–#13, `305`) tightest. Drives: `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` + `Incremental-East-West-Firewall-Build-Worksheet.md`. *Gate:* console break-glass proven (Phase 1) + clocks + **MON01/NetFlow evidence** + the matrix filled. *Verify:* the reachability-matrix **Game Day** (`ADR-0011`) — every allowed flow passes, every denied flow is refused **and logged**. *Cert:* Security+ / CCNP (segmentation, ACLs) · the `305` OT requirement.

### Future / Section K (gated stub)
- [ ] 📋 **E-W matrix depth** — Section K **K4**: how granular the E-W rules go (per-host vs per-zone), its own ADR when decided. *Cert:* CCNP · Security+.

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | 1941 (`10.255.255.5`) | transit /30 + OSPF + egress default |
| ⬆ Depends on | SW01 | 802.1Q trunk (all VLANs to `bridge-trunk`) |
| ⬆ Depends on | console FTDI · MON01/NetFlow · NPS01 | break-glass · Phase-7 evidence · RADIUS (Pass-2) |
| ⬇ Serves | every inter-VLAN flow | route + east-west filter (in-path by construction) |
| ⬇ Serves | DHCP clients · OT VLAN 90 | per-VLAN relay → DC01 · isolation + 1 conduit (`305`) |

## Certification alignment (learning lens)
| MKT01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| Hardening / scoped mgmt | device hardening, secure mgmt | MTCNA · Security+ |
| VLAN SVIs / inter-VLAN | inter-VLAN routing | CCNA (2.x/3.x) · MTCNA |
| OSPF area 0 | OSPF neighbors/areas, redistribution | CCNA (3.x) · CCNP ENARSI |
| DHCP relay | DHCP relay/helper | CCNA (4.x) |
| default-deny E-W (from evidence) | ACLs, zone segmentation, default-deny | CCNA (5.x) · CCNP · Security+ |
| Tier-0 micro-zone + OT conduit | segmentation, OT/ICS isolation | Security+ · `305` (NIST 800-82) |

## Related
- E-W policy owner: `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`. Phase-7 execution: `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` · `Incremental-East-West-Firewall-Build-Worksheet.md`. The how: `Build-Guide.md`. Verify: `Diagnostics.md`. Open risks: `Considerations.md`. As-built: `Build-Record.md`.
- Owners: `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../../Operations/Build-Order-and-Dependencies.md` (Phase 2/6/7) · `../../Operations/Validation-and-Adversarial-Testing.md` · `00-Atlas-Foundation/Company-Profile/305-Atlas-Industrial-Security-Requirements.md` · cert maps in `Atlas-Academy/`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the config-path roadmap for the E-W firewall + inter-VLAN gateway (networking variant): Phase-2 base+hardening ✅ device-verified (07-22) + OSPF FULL with 1941 (07-21); VLAN SVIs/permissive filter 🟡 (offload-off caution); DHCP relay (Phase 3h) + rsyslog/NetFlow→MON01 (Phase 6) deferred; 🔴 the Phase-7 **default-deny-east-west-from-evidence** headline (gated on console break-glass + clocks + NetFlow + the filled matrix; incremental per `ADR-0041`; Game-Day verified); Section K K4 (matrix depth) as a gated stub; Tier-0 micro-zone + OT conduit (`305`). Cert-aligned CCNA/CCNP/MTCNA/Security+. Status mirrors Build-Checklist + Diagnostics (`POL-0001`). |
