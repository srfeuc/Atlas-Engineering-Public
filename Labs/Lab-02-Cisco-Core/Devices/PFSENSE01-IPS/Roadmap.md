---
Title: PFSENSE01 — Roadmap (gated build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/PFSENSE01-IPS
Status: 📋 PROPOSED / gated — the design is decided (ADR-0038 v1.2); the build path is a designed stub (hardware pending). Mirrors Build-Checklist (POL-0001).
Version: 0.1
Date: 2026-07-30
---

# PFSENSE01 — Roadmap (gated build path + connections)

> **How to read this.** Each row is 📋 proposed and behind a 🔴 gate — the **design is settled** (`ADR-0038` v1.2), only the build waits on hardware. **Needs** = healthy-first; **Unblocks** = what proceeds. Cert objective per stage (`ADR-0044`). 🔴 **Fail-closed + monitor-first** shape the order: never enable inline-drop before the rules are tuned.

## The build path (in order — Phase 7)

### 🔴 GATE-0 — hardware + the transit exist
- [ ] 🔴 **Acquire the physical 2-NIC low-power appliance** (`ADR-0038` D2a) + confirm the **FGT01↔1941 transit** is up (Phase 2). *Why:* it is a physical bump-in-the-wire; nothing proceeds without the box + the cable to bridge. *Cert:* Security+ (architecture).

### Phase 7 — Stand up the transparent bridge
- [ ] 📋 **Install pfSense; configure a transparent (filtering) bridge** across the two NICs on the FGT01↔1941 /30 — **no data-plane IP, no OSPF** (bump-in-the-wire). Assign a **mgmt IP** (📋 proposed VLAN 10). *Needs:* GATE-0. *Unblocks:* inspection. → `../../Architecture/IP-Addressing-Plan-VLSM.md`. *Cert:* Security+/CCNP (transparent firewall/bridge).
- [ ] 🔴 **Wire the fail-CLOSED behaviour + the manual transit-bypass break-glass.** Confirm that on a pfSense fault the bridge blocks (fail-closed, `ADR-0038` v1.2) **and** that the documented **direct FGT01↔1941 re-cable** restores internet fast. *Needs:* bridge up. *Unblocks:* safe operation. *Cert:* Security+ (availability/HA tradeoffs).

### Phase 7 — Suricata: monitor-only → tuned → blocking
- [ ] 📋 **Suricata in monitor-only (IDS) mode** — alerts, no drops; baseline the traffic; reuse MON01's rule sets. *Needs:* bridge up. *Unblocks:* tuning. *Cert:* Security+ (IDS/IPS) · FCP/NSE (free-vs-licensed comparison).
- [ ] 📋 **Tune out false positives**, then **enable inline blocking per rule category** — incremental, one category tested at a time (`ADR-0041`). 🔴 Especially important under fail-closed (an untuned drop would cut the internet). *Needs:* a clean monitor-only baseline. *Unblocks:* real N-S prevention. *Cert:* Security+/CySA+ (tuning) · FCP/NSE.
- [ ] 📋 **Ship alerts → MON01 / SIEM01-Wazuh** (syslog) — one detection pane; correlate with the SPAN Suricata + host events (Section K **K8**). *Needs:* MON01/Wazuh. *Cert:* Security+/CySA+ (correlation).

### Phase 10 — Automation onboarding (`ADR-0048`)
- [ ] 📋 **Config-backup + Suricata-rules-as-code** → `Automation/` (after the manual build; idempotent). *Needs:* the manual build proven. → `Automation/README.md`.

### Future / Section K (gated stub)
- [ ] 📋 **Per-segment IPS** (in front of the DMZ VLAN 80 / OT VLAN 90) — deferred; revisit once the N-S IPS is proven (`ADR-0038` review trigger). *Cert:* Security+/CCNP.

## Connections at a glance
| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | 2-NIC appliance (TBD) + the FGT01↔1941 transit | the bridged data path |
| ⬆ Depends on | DC/NTP/DNS · Suricata rules (MON01) | mgmt plane (VLAN 10) · rule sets |
| ⬇ Serves | estate internet path (fail-closed) | N-S prevention (defence-in-depth behind FGT UTM) |
| ⬇ Serves | MON01 / SIEM01-Wazuh | Suricata alerts (syslog) — one detection pane |

## Certification alignment (learning lens)
| PFSENSE01 stage | Exercises (exam objective) | Cert |
|---|---|---|
| Transparent bridge / bump-in-the-wire | transparent firewall, L2 inspection | Security+ · CCNP security |
| Fail-closed + break-glass | availability/HA tradeoffs, resilience | Security+ |
| Suricata monitor-only → tuned → inline | IDS vs IPS, rule tuning | Security+ · CySA+ |
| Free-vs-licensed IPS comparison | pfSense/Suricata vs FortiGate IPS | **FortiGate FCP/NSE** |
| Alert correlation → MON01/Wazuh | SIEM correlation | Security+ · CySA+ |

## Related
- Decision: `00-Atlas-Foundation/Decisions/ADR-0038-pfSense-Inline-IPS-North-South.md` (v1.2). The how: `Build-Guide.md` (gated stub). Line-item: `Build-Checklist.md`. Open risks: `Considerations.md`. Verify: `Diagnostics.md`.
- Owners: `00-Atlas-Foundation/Atlas-Firewall-Architecture.md` · `../../Operations/Build-Order-and-Dependencies.md` (Phase 7) · `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../MON01-Monitoring/` + `../SIEM01-Wazuh/` (correlation) · `Atlas-Academy/Atlas-FortiGate-FCP-Lab-Map.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — the gated build path for the proposed PFSENSE01 inline IPS (`ADR-0038` v1.2 decisions baked in): 🔴 GATE-0 (acquire the 2-NIC appliance + the transit exists) → transparent bridge (no data-plane IP) + the fail-closed wiring + the manual transit-bypass break-glass → Suricata monitor-only → tune → enable blocking per category (`ADR-0041`) → alerts to MON01/Wazuh (K8) → automation (config + rules-as-code). Per-segment IPS (DMZ/OT) as a gated stub. Cert-aligned Security+/CySA+/FCP. All 📋/gated (hardware pending). |
