# SW01 — Access Switch

| Item | Value |
|---|---|
| Lab / Era | Lab-01 · Mikrotik-Core — FROZEN 2026-07-16 |
| Host · Role | SW01 (Cisco Catalyst 2960X, IOS) · **Access Switch** |
| Status | Device-verified; reconciled to live this cycle |

## Role this era

Layer-2 only: switching, the VLAN database, trunk and access ports, spanning-tree root, DHCP snooping, dynamic ARP inspection, port security, storm control, and the SPAN session. **No Layer-3 routing of any kind.**

## Documents

- `Build-Guide.md` (027) · `Build-Record.md` (023) · `Troubleshooting.md` (039)
- `CIS-Hardening.md` (045) · `Verification.md` (056) · `Considerations.md` (057)
- `Changes/` — SW01 change records

## Open items — deferred (ADR-0022)

- **CM-0030** — clock has never synchronised (stratum 16). NTP target defined by ADR-0020; execution waits on Phase-2 AD (or the external pool as interim).
- **CM-0036** — SPAN session built on Gi1/0/5 but nothing is plugged into it — a control that was never tested.
- **CM-0037** — SNMP location string points at MON01, which does not exist yet.
