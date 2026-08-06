---
Title: MKT01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/MKT01-East-West-Firewall
Status: 🟠 LIVING — open risks/decisions on the E-W firewall + inter-VLAN gateway. Closed items → Build-Record / Change Log.
Version: 0.2
Date: 2026-07-30
---

# MKT01 — Considerations (open risks & decisions)

> The "what could bite us" list for the estate's segmentation box — separate from the RouterOS steps (`Build-Guide.md`) and the `print` checks (`Diagnostics.md`). Facts linked to owners (`POL-0008`).

## Open gates
- 🔴 **Phase-7 default-deny is not yet applied — and its gate is strict.** The E-W policy is **permissive by design** until: **console (FTDI) break-glass proven** (Phase 1) **+** synced clocks **+** **MON01/NetFlow evidence** (Phase 6) **+** the flows matrix filled from that evidence. Only then flip permissive → default-deny + log, **one scoped rule at a time** (`ADR-0041`). Drives: `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` + `Incremental-East-West-Firewall-Build-Worksheet.md`.
- 🔴 **Console break-glass before any deny.** MKT01 is the inter-VLAN gateway *and* the filter — a bad rule can lock everyone (including the admin) out. The FTDI console recovery path must be proven **before** MKT01 becomes policy-critical.
- 🔴 **Pass-2 AD-RADIUS not yet applied** (`ADR-0029`, flow #14). Admin auth is still local `mikrotikadmin`; moves to **NPS01** once DC + AD CS + NPS01 exist. Keep **one local break-glass** — never PKI-ify it.
- 🟡 **Gateway/SVI read-backs pending** — the 9 VLAN gateways + transit + loopback are applied but not yet `print`-verified.

## Standing risks (design)
- 🔴 **The permissive-forever trap (the #1 real-world failure).** "Allow any-any to make it work, then never tighten." The entire **Phase 2 → 6 → 7** sequence exists to defeat exactly this — bring up permissive, make flows *visible*, write default-deny **from evidence**. Do not skip the evidence step.
- 🔴 **RTL8367 hardware-offload trap.** On the RB1100, leaving hardware offload **on** for the bridge/VLAN ports breaks the software VLAN/firewall path — set **`hw=no`** on the bridge ports (`Troubleshooting.md`). Symptom: VLANs "configured" but traffic behaves wrongly.
- 🔴 **`print` vs `print detail`/`print stats`.** RouterOS hides dynamic rows in plain `print`; a dynamic row was misread once (`016`). Always read state back with `print detail` / `print stats` (`POL-0001`).
- 🔴 **Asymmetric routing breaks stateful inspection.** Request and reply must both transit MKT01 (Firewall-Arch §3.1) — a stray path or static splits the flow and half is silently dropped. Keep symmetric with the 1941.
- 🔴 **Single point for all inter-VLAN (blast radius).** Every east-west + internet-bound flow rides MKT01 by construction (`ADR-0023` Option B). It has no HA peer — its console recovery + config backup (Oxidized) are the mitigations.
- 🔴 **OT VLAN 90 is availability-first (`305` / NIST 800-82).** The OT isolation (#11–#13) must never let a deny risk the plant line — the un-patchable box is *why* segmentation is the compensating control. Prefer passive monitoring over active polling into OT; the single IT→OT conduit is the only allowed inbound.

## Open decisions (need a call / ADR when reached)
- **E-W matrix depth** — Section K **K4**: per-host vs per-zone granularity for the E-W rules; its own ADR.
- **DHCP failover topology** — DC01/DC02 relay/failover once DC02 is verified (with `ADR-0030`).
- **Inspection division of labor (context, decided elsewhere).** MKT01 = **east-west prevention**; **pfSense** = the free **N-S inline IPS** on the FGT01↔1941 transit (`ADR-0038`); **FGT01 UTM** = N-S content inspection (`ADR-0047`); **MON01 Suricata** = network *detection*. MKT01 does not do N-S content inspection — keep the planes distinct.

## Decided (audit #22, 2026-07-30)
- **No separate `Networking-Build-Guide.md` for MKT01** *(operator policy, #22 planning — appliances point, hosts get new)*. MKT01 already carries **`Build-Guide.md` (v0.8)** for the RouterOS bring-up (VLAN SVIs → OSPF → DHCP relay → base filter) **plus** the two Phase-7 execution worksheets (`Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` + `Incremental-East-West-Firewall-Build-Worksheet.md`); a dedicated networking bring-up guide would duplicate them (`POL-0008`). Those existing docs **are** MKT01's networking build guide — point to them.
- **Services map added to `README.md`** (Standard v1.7 backfill, Backlog #27) — the routing/firewall/gateway service table (inter-VLAN routing · OSPF · E-W policy · OT isolation · DHCP relay · mgmt · NTP · Pass-2 RADIUS · MON01 telemetry), Status mirroring `Build-Record.md` (`POL-0001`).

## Related
- `Roadmap.md` · `Build-Checklist.md` (failure modes) · `Build-Guide.md` · `Diagnostics.md` · `Firewall-Rebuild-and-Per-Rule-Verification-Plan.md` · `Incremental-East-West-Firewall-Build-Worksheet.md` · `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` · `../../Architecture/CIS-Hardening-MKT01.md` · `../../Operations/Validation-and-Adversarial-Testing.md` · `00-Atlas-Foundation/Company-Profile/305-Atlas-Industrial-Security-Requirements.md`.

## Change Log
| Version | Date | Change |
| 0.2 | 2026-07-30 | **#22 audit:** added a **Decided** section — no separate `Networking-Build-Guide.md` (the existing `Build-Guide.md` v0.8 + the two Phase-7 worksheets are MKT01's networking build guide, `POL-0008`); Services map backfilled into `README.md` (Standard v1.7 / Backlog #27). |
| 0.1 | 2026-07-30 | Created — open gates (the strict Phase-7 default-deny gate + console break-glass; Pass-2 RADIUS; gateway read-backs), standing risks (the permissive-forever trap; the RTL8367 offload trap; `print`-vs-`print detail`; asymmetric routing; single-point blast radius; OT-availability-first per `305`), open decisions (Section K K4 matrix depth; DHCP failover; the E-W-vs-N-S inspection division of labor). |
