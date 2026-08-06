---
Title: SRV01 — Diagnostics (show/verify battery)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services
Status: 🟡 Seeded (`ADR-0032`) — host-level checks; per-service checks live in each `Roles/<svc>/`. Not yet run (host unbuilt).
Version: 0.1
Date: 2026-07-29
---

# SRV01 — Diagnostics (show/verify battery)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** Host-level verify commands (identity, network, hardening). Service checks (nginx CRL serves, Oxidized commits, rsyslog reaches MON01) live in the `Roles/<svc>/` docs. Links up to Academy `Command-Library/Linux.md`. Markers: ✅ · 🟡 · ⬜.

## Host / identity
| Check | Command | Expected (healthy) | Verified? |
|---|---|---|---|
| Reachable | `Test-NetConnection 10.20.0.10` (or `ping`) | reachable | ⬜ |
| Identity regenerated uniquely | `hostname` · `hostnamectl` · `cat /etc/machine-id` | `SRV01`, unique machine-id (not the template's) | ⬜ 🔴 the `220` check |
| IP / VLAN | `ip a` · `ip r` | `10.20.0.10/26` gw `10.20.0.1`; VLAN-20 tag on the wire | ⬜ |
| DNS | `resolvectl` / `dig pki.atlas.lab` | resolves via `10.20.0.2` | ⬜ |
| Hardening | SSH keys-only, host firewall, `unattended-upgrades` | enforced | ⬜ |
| Role firewall | port 80 open (CRL), others per role | expected ports only | ⬜ |

## Related
- `Build-Guide.md` · `Roles/<svc>/` (per-service verify) · `Atlas-Academy/Command-Library/Linux.md`.
