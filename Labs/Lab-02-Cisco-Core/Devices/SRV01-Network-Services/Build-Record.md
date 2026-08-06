---
Title: SRV01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services
Status: 🟡 LIVING — verified as-built state. **Not executed** — the Build-Guide is authored; the VM/services are pending. Records outrank guides (`POL-0001`).
Version: 1.0
Date: 2026-07-29
---

# SRV01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** "What is actually true now" for SRV01 (`POL-0001` evidence home). Markers: ✅ device-verified · 🟡 operator-reported · ⬜ not built.

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| VM clone (`TPL-UBUNTU2604`) + identity | pending | ⬜ | Build-Guide Part 1 |
| IP / VLAN | `10.20.0.10` /26 gw `10.20.0.1` DNS `10.20.0.2`, VLAN 20 | ⬜ (target) | `IP-Addressing-Plan-VLSM` |
| CIS-Ubuntu hardening | pending | ⬜ | Part 2/5 |
| **nginx-CRL** (`pki.atlas.lab`) | pending | ⬜ | `Roles/nginx-CRL/` |
| Oxidized · rsyslog · SFTP/TFTP | pending | ⬜ | `Roles/<svc>/` |

> 🔴 **Nothing device-verified yet** — SRV01's Build-Guide is authored (v0.2), not executed. The gating action is the host clone + the nginx-CRL role (Build-Guide Parts 1–3). Rows flip ✅ as each read-back is captured.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-29. Created — SRV01 authored but not executed; host + all four service roles ⬜ pending. |
