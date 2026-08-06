---
Title: FGT01 — Build Record (verified as-built state)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟢 LIVING — the verified as-built state of the N-S perimeter. Pass-1 core device-verified (07-21); UTM/TLS-inspection gated. Records outrank guides (POL-0001). 🔴 Read back with get, not show.
Version: 0.1
Date: 2026-07-30
---

# FGT01 — Build Record (verified as-built state)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** The "what is actually true right now" snapshot for the perimeter. It **outranks the Build-Guides** (guides = target; this = reality). Each row cites where the evidence lives (`POL-0008`). Markers: ✅ device-verified · 🟡 lab-unverified · ⬜ not built. 🔴 `get`, not `show`.

## FGT01 — FortiGate-60E · FortiOS 7.4.5  (N-S perimeter, `ADR-0047`)

| Attribute | As-built | Status | Evidence |
|---|---|---|---|
| Named admin / trusthost | named admin + `trusthost` scoped; default `admin` → `fortigateadmin` break-glass | ✅ core (07-21) | `Diagnostics.md` §1 · `ADR-0028` |
| No mgmt on WAN | `wan1 allowaccess ping` only (no https/ssh) | ✅ | `Diagnostics.md` §1 (CIS 1.3) |
| Egress policy + NAT | egress policy present, `nat enable` | ✅ (07-21) | `Diagnostics.md` §3 |
| Traffic logging | `logtraffic all` | ✅ (07-21) | `Diagnostics.md` §3 |
| Interfaces | `internal 10.255.255.1/30`; `wan1` DHCP | 🟡 read-back pending | `Diagnostics.md` §2 |
| Transit + egress reachability | ping 1941 `10.255.255.2` ✓; internet egress ✓ | ✅ (07-21) | `Diagnostics.md` §4 |
| FortiToken MFA | enabled (no CA needed) | ✅ core (07-21) | `CIS-Hardening-FGT01` |
| Firmware / strong-crypto / private-data / NTP | 7.4.5; `strong-crypto`; private-data key offline; NTP | 🟡 read-back pending | `Diagnostics.md` §1/§2/§3 |
| Direct-LDAPS admin auth | not applied | 📋 | — (gated on DC cert, `ADR-0028`/`Build-Guide-2b`) |
| FortiGuard UTM (web/AV/IPS/app-ctrl) | not applied — **gated** | ⬜ | — (`ADR-0047`; ICA01 cert + live subscription; `Build-Guide-3`) |
| TLS deep-inspection (K1) | not applied — **gated** | ⬜ | — (ICA01 inspection CA + GPO trust) |
| DNS filtering (K2) | **off on FGT — Pi-hole owns it** | ✅ decided | K2 (operator 2026-07-30) |
| FSSO (K3) | proposed — not built | 🔎 | — (deferred; concept + Backlog) |
| syslog → MON01 | not built | 📋 | — (Phase 6) |

> 🔴 **Outstanding read-backs to flip 🟡→✅:** `get system status` (firmware/subscription), `get system interface physical`, `get system global | grep strong-crypto|private-data`, `get system ntp`. 🔴 **Before trusting any UTM profile:** `get system status` shows an active subscription + fresh signatures (`ADR-0047`).

## Related
- `Diagnostics.md` · `Build-Guide-Index.md` (+ `-1`/`-2`/`-2b`; `-3` gated) · `Build-Checklist.md` · `Roadmap.md` · `Considerations.md`.

## Change Log
| Version | Date | Change |
| 0.1 | 2026-07-30 | Created — consolidated FGT01's Pass-1 core device-verified state from the Build-Guides/Diagnostics (named admin/trusthost, no-WAN-mgmt, egress+NAT, traffic logging, 1941 transit + internet egress, FortiToken — 07-21) into the single as-built snapshot; interfaces/crypto/NTP 🟡 pending read-back; **direct-LDAPS ⬜ gated, UTM + TLS deep-inspection ⬜ gated** (`ADR-0047`, ICA01 + subscription); K2 DNS-filter-off ✅ decided; K3 FSSO 🔎 proposed; syslog→MON01 📋. Records outrank guides (`POL-0001`); `get`-not-`show`. |
