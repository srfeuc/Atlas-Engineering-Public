---
Title: SW01 — Roadmap (config path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/SW01-Access-Switch
Status: 🟢 LIVING — the config path for the L2 access switch. Pass-1 + core L2 ✅ device-verified; status mirrors Build-Checklist + Diagnostics (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# SW01 — Roadmap (config path + connections)

> **How to read this.** Each row is a **config stage** on the switch (the networking variant — VLANs/trunks/STP/SPAN/DAI, not services). Checkbox = status, evidenced by the `show`-read-backs in `Diagnostics.md` (`POL-0001`). **Needs** = healthy-first; **Unblocks** = what proceeds. Cert objective per stage (`ADR-0044`).

## The config path (in order)

### Phase 2 — Base + hardening — ✅ device-verified
- [x] ✅ **Base + hardening (CIS IOS)** — SSHv2-only + CTR ciphers, named admin (no generic `cisco`), no http/telnet, no v2c SNMP, `Vlan1` admin-down, **`Vlan10` mgmt SVI `10.10.0.2` up**, NTP stratum-3. *(07-22; `../../Architecture/CIS-Hardening-SW01.md`, `Diagnostics.md` §1/§2/§3.)* *Cert:* CCNA (device hardening, mgmt SVI, SSH).

### Phase 2 — L2 fabric (applied; read-backs pending 🟡)
- [ ] 🟡 **VLANs 10–90 + native 999** — define the VLAN database; **DTP off**; unused access ports shut; **Pi01 on `Gi1/0/7`** (never shut). *Needs:* base up. *Unblocks:* trunks + access. *Cert:* CCNA (VLANs, port security).
- [ ] 🟡 **Trunks** — **`Gi1/0/1` → MKT01** (all VLANs) + **`Gi1/0/4` → PVE01** (native **999**, VM VLANs tagged; DAI-trusted). *Needs:* VLANs. *Unblocks:* inter-VLAN reach (via MKT01) + the VM plane. → `../../Architecture/SW01-PVE01-Native-VLAN-Options.md`. *Cert:* CCNA (802.1Q trunking, native VLAN).
- [ ] 🟡 **STP** — mode + root-bridge placement for the access layer; edge/portfast on access ports. *Cert:* CCNA (STP) · CCNP ENCOR (STP depth).
- [ ] 🟡 **SPAN `Gi1/0/5` → MON01** — a monitor session mirroring the MKT01 inter-VLAN trunk into the Suricata sensor (`ADR-0032`). One-directional. *Needs:* MON01 (Phase 6). *Unblocks:* network detection + the Phase-7 flow evidence. *Cert:* CCNA (SPAN).

### Phase 2 — Access-layer L2 security
- [ ] 🟡 **DHCP snooping + Dynamic ARP Inspection** — snooping enabled; DAI trusts the trunks; the **`STATIC-HOSTS` binding list** protects the access edge. 🔴 Today it is **hand-typed** (the "Pi01 mystery" — a stale binding silently dropped Pi01); it becomes **generated from NetBox** at Phase 4 (`POL-0004`). *Cert:* CCNA (DHCP snooping, DAI) · Security+.
- [ ] 🟡 **Port security** — MAC limits on access ports; unused shut. *Cert:* CCNA.

### Phase 2.5 — Pass-2 AD-backed admin auth (gated)
- [ ] ⬜ **RADIUS to NPS01** (`ADR-0029`) — admin login moves to Windows NPS; keep **one local break-glass**. *Needs:* DC + AD CS (NPS cert) + NPS01. *Cert:* CCNA (AAA) · Security+.

### Phase 4/6 — Management telemetry + generated DAI (deferred)
- [ ] 📋 **SNMPv3 + syslog → MON01** (no v2c). *Needs:* MON01. *Cert:* CCNA (SNMP/syslog).
- [ ] 📋 **DAI `STATIC-HOSTS` generated from NetBox** (Phase 4) — replaces the hand-typed list (`POL-0004`; fixes the Pi01-drop defect structurally). *Cert:* CCNP ENAUTO.

### Future / CCNP (gated stub)
- [ ] 📋 **802.1X port-based auth** (with NPS01) + **STP hardening** (BPDU guard / root guard) — Section-K-adjacent; own ADR when reached. *Cert:* CCNP ENCOR · Security+.

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | MKT01 (`Gi1/0/1`) | 802.1Q trunk — all VLANs to the inter-VLAN gw |
| ⬆ Depends on | NTP source · NPS01 (Pass-2) | time (`ADR-0020`) · RADIUS (`ADR-0029`) |
| ⬇ Serves | PVE01 (`Gi1/0/4`, native 999) | VM VLAN trunk |
| ⬇ Serves | wired hosts/devices · Pi01 (`Gi1/0/7`) | access ports per VLAN |
| ⬇ Serves | MON01 Suricata (`Gi1/0/5` SPAN) | one-way mirror of the MKT01 trunk (`ADR-0032`) |

## Certification alignment (learning lens)
| SW01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| SSH/hardening/mgmt SVI | secure access, mgmt-plane | CCNA (2.x/5.x) |
| VLANs + access ports + port security | VLANs, port security | CCNA (2.x) |
| 802.1Q trunks + native VLAN | trunking, native-VLAN hygiene | CCNA (2.x) |
| STP + edge/portfast | spanning tree | CCNA (2.x) · CCNP ENCOR |
| SPAN → MON01 | port mirroring/monitoring | CCNA (4.x) |
| DHCP snooping + DAI | L2 security | CCNA (5.x) · Security+ |
| RADIUS / 802.1X (later) | AAA, port-based auth | CCNA (5.x) · CCNP · Security+ |

## Related
- Line-item + failure modes: `Build-Checklist.md`. The how: `Build-Guide.md`. Verify: `Diagnostics.md`. Open risks: `Considerations.md`. As-built: `Build-Record.md`.
- Owners: `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../../Architecture/Cabling-and-Port-Map.md` · `../../Architecture/SW01-PVE01-Native-VLAN-Options.md` · `../../Operations/Build-Order-and-Dependencies.md` (Phase 2) · cert maps in `Atlas-Academy/`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the config-path roadmap for the L2 access switch (networking variant): Phase-2 base+hardening ✅ device-verified (07-22); the L2 fabric (VLANs 10–90+999, trunks to MKT01/PVE01, STP, SPAN→MON01) + access-layer L2 security (DHCP snooping/DAI, port security) 🟡 read-back pending; Pass-2 RADIUS gated; Phase-4/6 SNMP/syslog→MON01 + DAI-generated-from-NetBox deferred; 802.1X/STP-hardening as a gated stub. Cert-aligned CCNA/CCNP. Status mirrors Build-Checklist + Diagnostics (`POL-0001`). |
