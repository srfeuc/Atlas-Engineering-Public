# FGT01 — Perimeter Firewall

| Item | Value |
|---|---|
| Lab / Era | Lab-01 · Mikrotik-Core — FROZEN 2026-07-16 |
| Host · Role | FGT01 (FortiGate 60E, FortiOS) · **Perimeter Firewall / NAT** |
| Status | Device-verified (reconciled prior cycle) |

## Role this era

The WAN uplink, perimeter firewall, NAT, and the return route (10.0.0.0/8 via MKT01), with its management interface on VLAN 10. **Does not** do inter-VLAN routing, DHCP, or enterprise DNS.

## Documents

- `Build-Guide.md` (025) · `Build-Record.md` (021) · `Troubleshooting.md` (037)
- `CIS-Hardening.md` (047) · `Verification.md` (058) · `Considerations.md` (059)
- `Changes/` — FGT01 change records (incl. `MC-0001`, the Lab-CA certificate install)

## Notes

`CM-0033` recorded five live undocumented ports found during reconciliation — closed. The firewall-policy scope decision is captured in `ADR-0005`.
