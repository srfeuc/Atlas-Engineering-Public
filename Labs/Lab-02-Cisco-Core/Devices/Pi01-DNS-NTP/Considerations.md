---
Title: Pi01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP
Status: 🟠 LIVING — open gates, standing risks, and not-yet-settled decisions on the reduced DNS+NTP Pi. Closed items move to the Build-Record / Change Log.
Version: 0.2
Date: 2026-07-30
---

# Pi01 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled" list for the reduced DNS+NTP Pi — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`).

## Open gates
- 🔴 **Migrations OFF must be confirmed BEFORE the rebuild.** FreeRADIUS→NPS01, Vaultwarden→Vaultwarden, and the CA→offline must all be done and **nothing should still point at Pi01** for them (`ADR-0009`). You rebuild to the *reduced* role — not alongside the old one. Prove it (grep configs, check the wire) before imaging.
- 🔴 **chrony must be the active daemon, not `systemd-timesyncd`.** Do not tick "NTP works" until `chronyc tracking` proves sync — see the false-tick scar below.

## Standing risks (design)
- 🔴 **SPOF — one SD-card box (Backlog #2).** Even reduced to two services, Pi01 is a single bare-metal Pi on a single SD card. **The reduction *is* the mitigation** (`ADR-0009` moved the crown jewels off so a Pi loss no longer takes the PKI with it). Keep the SD image backup; treat the box as disposable; do **not** re-pile RADIUS/Vault/CA back on. A 2nd resolver/time source is the later fault-tolerance fix.
- 🔴 **The `046` chrony-vs-timesyncd false-tick scar.** `046` ticked "chrony confirmed working" when `chronyc: command not found` and the box actually ran `systemd-timesyncd`. Only `chronyc tracking` + `systemctl status chrony` proves the right daemon is the synced one.
- 🔴 **The Pi-hole v6 `custom.list` inert trap.** On Pi-hole v6, `/etc/pihole/custom.list` is **ignored**. Local DNS records must go where v6 reads them (`dnsmasq.d` / the v6 config) — and be **tested for resolution**, not just presence in a file.
- 🟡 **The "Pi01 mystery" — silent DAI drop.** Pi01 was once silently dropped by SW01's hand-typed `STATIC-HOSTS`/DAI ACL. NetBox fixes this structurally (it *generates* the list). Watch for it on the VLAN-10 identity step; symptom is "reachable then not, no error."

## Open decisions (need a call / ADR when reached)
- 🔎 **VLAN-10 (Management) DNS/NTP-ingress placement.** Pi01 serves DNS/NTP *into* the management VLAN, yet the E-W matrix rule is "nothing initiates into MGMT." Flag whether Pi01 belongs on VLAN 10 at all, or whether serving other zones argues for a different placement. **Operator call — IPs/VLANs can be deliberated; raise it, don't resolve it here.** → `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`.
- 🔎 **Deconflict `.6` against WAC01 `.5`** and the other VLAN-10 mgmt hosts (SW01/PVE01). `10.10.0.6` is 📋 proposed; the exact octet is the **IP plan's** call. → owner: `../../Architecture/IP-Addressing-Plan-VLSM.md` (`POL-0008`).

## Decided (audit #22, 2026-07-30)
- **Services map added to `README.md`** (Standard v1.7 / Backlog #27) — filtering DNS · `atlas.lab` conditional-forward · chrony NTP, all ⬜/📋 (rebuild, `POL-0001`). Edges already labelled (v1.6) — Services-map-only.
- **No separate `Networking-Build-Guide.md` for Pi01** *(operator policy — appliances point, hosts get new)*. Bare-metal single-NIC VLAN-10 host; the VLAN-10 identity step is already covered by `Build-Guide.md` (the reduced-role rebuild), and the VLAN-10 DNS/NTP-ingress placement question above is an **IP-plan/flows** decision, not a bring-up procedure (`POL-0008`).

## Related
- `Roadmap.md` (where these sit) · `Build-Checklist.md` (line-item) · `Build-Guide.md` (steps) · `ADR-0009` (SPOF reduction) · `ADR-0020` (time) · `ADR-0003`/`ADR-0007` (DNS boundary) · `../../Operations/Validation-and-Adversarial-Testing.md`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.2 | 2026-07-30 | **#22 audit:** added a **Decided** section — Services map backfilled into `README.md` (Standard v1.7 / Backlog #27, all ⬜/📋); no separate `Networking-Build-Guide.md` (VLAN-10 identity step already in `Build-Guide.md`). |
| 0.1 | 2026-07-30 | Created — open gates (migrations-off before rebuild, chrony-is-active), standing risks (the SD-card SPOF with reduction-as-mitigation, the `046` false-tick scar, the v6 `custom.list` trap, the STATIC-HOSTS/DAI "Pi01 mystery"), and open decisions (the VLAN-10 DNS/NTP-ingress placement question for operator deliberation, the `.6`/`.5` deconflict → the IP plan). |
