# PVE01 — Hypervisor

| Item | Value |
|---|---|
| Lab / Era | Lab-01 · Mikrotik-Core — FROZEN 2026-07-16 |
| Host · Role | PVE01 (Proxmox VE on Dell PowerEdge R410) · **Hypervisor** |
| Status | Device-verified; one hardware fault deferred |

## Role this era

Hypervisor host management on VLAN 10, the VLAN-aware bridge (vmbr0), and per-VM VLAN assignment via virtual NIC tags. **No** physical routing, perimeter security, DHCP, or DNS.

## Documents

- `Build-Guide-Network.md` (028) · `Build-Record-Network.md` (024) · `Troubleshooting.md` (036)
- `Verification.md` (060) · `Considerations.md` (061)
- `Changes/` — PVE01 change records (incl. `CM-0011` iDRAC/BMC hardening, `CM-0012`)

## 🔴 Open item — deferred (ADR-0017 / ADR-0022)

**CM-0012 — the RTC will not hold time.** Re-tested this cycle with a new CMOS battery and it still failed: the fault is the **board, not the cell.** BIOS settings (including VT-x) and the clock reset on any full power loss. This **blocks `050` (iDRAC onboarding)** and is why PVE01 must stay on continuous power (UPS). Deferred, said out loud, not ticked.

> In Lab-02, PVE01 is the virtualization *platform* (Proxmox + Windows golden image + DC01) — `Labs/Lab-02-Cisco-Core/Virtualization/`. This folder is PVE01's Lab-01 networking role only.
