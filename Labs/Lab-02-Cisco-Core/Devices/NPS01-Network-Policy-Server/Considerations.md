---
Title: NPS01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server
Status: 🟠 LIVING — open risks, gates, and not-yet-settled decisions on the RADIUS host. Closed items move to the Build-Record / Change Log.
Version: 1.1
Date: 2026-07-29
---

# NPS01 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled" list for the RADIUS host — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`).

## Open gates
- 🔴 **Two-host auth chain (availability).** Network-device admin login now needs **NPS01 *and* the DC** both up. **Every RADIUS client must keep a local break-glass admin** (Pass-1 standard) — verify it works with NPS stopped *before* relying on RADIUS. Mitigate later with a 2nd NPS (Microsoft ≥2).
- 🔴 **Server cert gated on the AD CS ceremony.** PEAP/EAP-TLS needs the RAS-and-IAS-Server cert from ICA01, which is gated on the AD CS ceremony + CRL publish. Until then, use password RADIUS (PAP/MS-CHAPv2) or wait — decide per client.
- 🔴 **Shared-secret hygiene.** RADIUS client secrets are secrets — **Vaultwarden only** (`POL-0002`), never in a doc or git; strong + unique per device.

## Standing risks (design)
- 🟡 **RADIUS scope creep.** NPS is tempting to overload (VPN, 802.1X, RDS, wireless). Keep the initial build to **network-device admin AAA** (MKT01/SW01/1941); add 802.1X/RDS/WPA2-Ent as *separate, later* policies (Roadmap future) so each is test-gated (`ADR-0041`).
- 🟡 **FGT01 is NOT a RADIUS client.** FGT01 uses direct LDAPS (`ADR-0028`) — do not add it as an NPS client by reflex. MKT01/SW01/1941 are RADIUS; FGT01 is LDAPS.
- 🟡 **Deny-by-default must be proven, not assumed.** A network policy set that never rejected an unknown user is unproven — test the negative case (`ADR-0041`).

## Open decisions (need a call / ADR when reached)
- 🟡 **Address `10.20.0.12` is *proposed*.** Authoritative value lives in `IP-Addressing-Plan-VLSM` (`POL-0008`) — confirm the row there; NPS sits in the server range, **out** of the `.2–.9` Tier-0 carve.
- 🟡 **PEAP vs EAP-TLS vs password-only** for the first cutover — password RADIUS to get real logins working, then add PEAP once the ICA01 cert lands. Decide per client at build.
- 🟡 **Source VM** — reuse an existing spare Windows VM (rename → join → role), per the stub. Confirm which spare.

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27) — the RADIUS-service rows (admin AAA · RD Gateway policy · 802.1X) + protocol/port on every diagram edge (`RADIUS/1812-1813`, `LDAP/389 · Kerberos`, …). All rows honest ⬜/📋 (not built, `POL-0001`).
- **No separate `Networking-Build-Guide.md` for NPS01** *(operator policy — appliances point, hosts get new)*. Standard tagged-VLAN-20 VM; network reach owned by the hypervisor/switch pages (`POL-0008`).

## Related
- `Roadmap.md` (where these sit) · `Build-Checklist.md` (line-item) · `Build-Guide.md` (steps) · `ADR-0029` (the decision + D7) · `../../Operations/Device-Hardening-Standard.md` (break-glass) · `../../Operations/Validation-and-Adversarial-Testing.md` (the deny-by-default + break-glass proofs).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** added a **Decided** section — Services map + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27, all ⬜/📋); no separate `Networking-Build-Guide.md` (standard VLAN-20 VM). |
| 1.0 | 2026-07-29. Created — open gates (the two-host availability chain + break-glass, the cert-gated PEAP, shared-secret hygiene), standing risks (scope creep, FGT-is-not-RADIUS, prove deny-by-default), and open decisions (proposed IP, PEAP-vs-password cutover, which spare VM). |
