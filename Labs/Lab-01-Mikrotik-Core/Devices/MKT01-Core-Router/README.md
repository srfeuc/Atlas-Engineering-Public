# MKT01 — Core Router

| Item | Value |
|---|---|
| Lab / Era | Lab-01 · Mikrotik-Core — FROZEN 2026-07-16 |
| Host · Role | MKT01 (MikroTik RB1100AHx4, RouterOS) · **Core Router** |
| Status | Device-verified; reconciled to live |

## Role this era

VLAN interfaces and gateways, inter-VLAN routing, the east-west stateful firewall, the transit route to FGT01, and the bridgeLocal recovery network. **Does no NAT** (that is FGT01's job), and is not authoritative DNS or production DHCP.

## Documents

- `Build-Guide.md` — how MKT01 is built (was 026)
- `Build-Record.md` — verified current state (was 022)
- `Troubleshooting.md` — real incidents and fixes (was 041)
- `Verification.md` / `Considerations.md` — the read-only verification battery and the open risks (was 054 / 055)
- `Changes/` — MKT01's change records (CM-/MC-), the legacy Lab-01 ledger for this device

## Open items — deferred (ADR-0022)

- **RouterBOOT firmware finding** (`Considerations.md`) — upgrade-or-accept; accepted for now, revisit at the next maintenance window
- **Discovery-leak** (`discover-interface-list`) — recommended to close (one command, zero lockout risk)

> In Lab-02, MKT01 is re-roled to an **east-west firewall** — a different folder under `Labs/Lab-02-Cisco-Core/`. This folder is MKT01-as-core-router only.
