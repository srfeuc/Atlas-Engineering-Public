---
Title: Lab-02 Cabling & Port Map
Path: Labs/Lab-02-Cisco-Core/Architecture
Status: Target Design — the physical plan. You cable and address it (Charter Locked Rule 17).
Version: 1.0
---

# Lab-02 — Cabling & Port Map

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> The physical layer for the `ADR-0023` Option B topology. Companion to `Lab-02-Device-Role-Assignments.md` and `Atlas-Firewall-Architecture.md`. Design + addressing plan only — you run the cables and write the config.

## The chain

```
Internet
   │
[wan1] FGT01                              perimeter firewall (N-S, NAT)
[internal] ──── routed /30 ──── [Gi0/1] 1941          core router (routed backbone, NO VLANs)
                                [Gi0/0] ──── routed /30 ──── [etherA] MKT01     east-west firewall + inter-VLAN gateway
                                                             [etherB] ═══ 802.1Q trunk (all VLANs) ═══ [Gi1/0/X] SW01
                                                                                                        │  access + trunk ports
                                                                                          ┌─────────────┼──────────────┐
                                                                                       PVE01(trunk)  Pi01(10)   LabComputer(10)+SPAN
```

`═══` = tagged 802.1Q trunk · `────` = plain routed link (no tags, no VLANs)

## Port / link map

| # | From | To | Type | Carries | Addressing |
|---|---|---|---|---|---|
| 1 | FGT01 `wan1` | home router | routed + NAT | internet | existing |
| 2 | FGT01 `internal` | 1941 `Gi0/1` | **routed /30** | N-S transit | `10.255.255.0/30` (FGT `.1`, 1941 `.2`) — per `IP-Addressing-Plan-VLSM.md` |
| 3 | 1941 `Gi0/0` | MKT01 `etherA` | **routed /30** | N-S transit | `10.255.255.4/30` (1941 `.5`, MKT01 `.6`) — per `IP-Addressing-Plan-VLSM.md` |
| 4 | MKT01 `etherB` | SW01 `Gi1/0/X` | **802.1Q trunk** | VLANs 10–90 | VLAN gateways live on MKT01 |
| 5 | SW01 `Gi1/0/Y` | PVE01 NIC | **802.1Q trunk** | the VLANs PVE01's VMs use | VLAN-aware bridge |
| 6 | SW01 access port | Pi01 | access | VLAN 10 | Pi01 = DNS+NTP |
| 7 | SW01 access port | LabComputer | access | VLAN 10 | + IDS feed |
| 8 | SW01 `Gi1/0/5` | IDS host (LabComputer/VM) | **SPAN** | mirror of link #4 | Suricata |

*(Exact `etherA/B` and `Gi1/0/X/Y` numbers are yours to assign — pick, then record them in NetBox, not just here.)*

## Addressing plan

> **`IP-Addressing-Plan-VLSM.md` is authoritative for all addresses** (`POL-0008`). The values here match it; if they ever differ, that doc wins.

- **The two transit /30s** (links #2, #3) are point-to-point, no hosts, no VLANs. Their only job is to carry routes between FGT01 ⇄ 1941 ⇄ MKT01.
- **The VLAN subnets** (10–90) have their gateways on **MKT01's VLAN interfaces** (e.g. `10.10.0.1` = MKT01 vlan10, `10.20.0.1` = MKT01 vlan20, … a new `…90.1` = OT). Every host's default gateway is a MKT01 address.
- **The 1941 holds no VLAN address** — it only knows the two /30s and the routes beyond them (a summary/route toward MKT01's subnets, a default toward FGT01).

## 🔴 Will the 1941 have any VLANs? No.

In Option B, **MKT01 owns every VLAN gateway**, so all 802.1Q tagging lives on link #4 (MKT01↔SW01). The 1941's two interfaces are **plain routed links** — no `switchport`, no subinterfaces, no `encapsulation dot1q`. The 1941 routes between "inside" (behind MKT01) and "edge" (FGT01); it teaches routed‑core / OSPF, **not** router‑on‑a‑stick. If practicing router‑on‑a‑stick on the Cisco was a goal, that's the one thing this topology trades away (do it as a throwaway lab, or revisit the topology on purpose).

## The two rules that prevent the classic mistakes

1. **Link #4 is a trunk (tagged); links #2 and #3 are routed (untagged /30).** Configuring a VLAN/trunk on the transit links, or a routed IP on the SW01 trunk, is the #1 wiring error.
2. **Both directions of every flow cross MKT01** (it's the gateway), so paths stay symmetric and the stateful firewall works (`Atlas-Firewall-Architecture.md` §3.1).

## What changes from the Lab-01 wiring

- **Today:** FGT01 → MKT01 (transit) → SW01 → hosts. MKT01 is the core router *and* the gateway.
- **Lab-02:** the **1941 is inserted between FGT01 and MKT01.** So:
  - The old **FGT01↔MKT01** link becomes **FGT01↔1941** (link #2).
  - A **new 1941↔MKT01** link is added (link #3).
  - The **MKT01↔SW01 trunk is unchanged** (link #4) — MKT01 keeps the VLAN gateways.
  - MKT01's **default route re-points** from FGT01 to the 1941.
- Net: you add the 1941 as a new hop, move one cable (FGT01's internal), add one cable (1941↔MKT01), and leave the switch side alone.

## Validation
- [ ] Ping across each /30 (links #2, #3) — both routed hops up.
- [ ] From a host, `traceroute` to the internet shows host → MKT01 → 1941 → FGT01 → out.
- [ ] `show interfaces trunk` (SW01) and MKT01's VLAN interfaces confirm link #4 carries all VLANs tagged.
- [ ] The transit links show **no** VLAN tags on capture; the trunk shows tags.
- [ ] SPAN (link #8) delivers mirrored inter-VLAN traffic to the IDS.

## Failure modes
- 🔴 **VLAN/trunk config on a transit link** (or a routed IP on the trunk) — the classic mix-up rule #1 catches.
- 🔴 **Asymmetric path** — only a risk if something other than MKT01 routes inter-VLAN; in Option B MKT01 is the sole gateway, so keep it that way.
- **Forgetting the 1941 default route** → internet-bound traffic blackholes with no obvious error.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Physical cabling and port map for the `ADR-0023` Option B topology: the FGT01→1941→MKT01→SW01 chain, the link table, the two transit /30s vs the all-VLAN trunk, the addressing plan (VLAN gateways on MKT01, no VLANs on the 1941), the "what changes from Lab-01 wiring" delta, and validation/failure modes. |
| 1.1 | 2026-07-17. Transit addresses reconciled to `IP-Addressing-Plan-VLSM.md` (the authoritative `POL-0008` plan): FGT01⇄1941 = `10.255.255.0/30`, 1941⇄MKT01 = `10.255.255.4/30`. Removed the earlier `172.16.0.0/30` example. |
