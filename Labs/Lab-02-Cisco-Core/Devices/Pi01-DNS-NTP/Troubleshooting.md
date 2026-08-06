---
Title: Pi01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP
Status: 🟢 LIVING — symptom→cause→fix for the reduced DNS+NTP Pi. Seeded from the known scars; real incidents append here. Verify commands live in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-30
---

# Pi01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 rebuild).** Symptom → likely cause → fix for the reduced DNS+NTP Pi. The checks that confirm a fix are in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## Clock won't sync / "NTP works" but it doesn't
- **Symptom:** time drifts; `chronyc: command not found`; a downstream service breaks on skew though "NTP was ticked."
  - **Cause:** 🔴 **`systemd-timesyncd` stole the clock** — chrony was never really the active daemon (the `046` false-tick scar). Ticking from `systemctl` presence, not from sync state.
  - **Fix:** install chrony; **disable/mask `systemd-timesyncd`**; `systemctl enable --now chrony`; confirm with `systemctl status chrony` **and** `chronyc tracking` (Leap Normal, sane reference). Only `chronyc tracking` proves sync.

## A local DNS record "exists" but never resolves
- **Symptom:** you added a local A record, the file has it, but `dig` returns NXDOMAIN.
  - **Cause:** 🔴 the record is in **`/etc/pihole/custom.list`**, which is **inert on Pi-hole v6** (the `custom.list` trap).
  - **Fix:** move the record to the **v6 config location (`dnsmasq.d`)**; restart the DNS resolver; re-test with `dig @10.10.0.6 <record>`. Test *resolution*, never file contents.

## `atlas.lab` names won't resolve for Pi-hole clients
- **Symptom:** external names resolve but `*.atlas.lab` returns NXDOMAIN/SERVFAIL.
  - **Cause:** the **conditional-forward** for `atlas.lab` → the DCs is missing/misconfigured, or the DC isn't reachable (`ADR-0003`/`ADR-0007`) — Pi-hole is the non-domain forwarder, it is not authoritative for the domain.
  - **Fix:** set/repair the conditional-forward to the DC DNS; confirm the DC is reachable (`dig @<DC-IP> <host>.atlas.lab`); check the host firewall didn't block outbound 53 to the DC.

## Upstream forwarder / filtering broken
- **Symptom:** all lookups fail, or nothing is being filtered.
  - **Cause:** upstream resolvers unset/unreachable; Pi-hole service down; blocklists not applied.
  - **Fix:** `pihole status`; set/verify upstream resolvers; `pihole -g` to rebuild gravity; restart the resolver; re-test an external name + a known-ad domain.

## Reachable, then silently gone (the "Pi01 mystery")
- **Symptom:** Pi01 was reachable, then drops off VLAN 10 with no error logged on the host.
  - **Cause:** 🟡 SW01's **hand-typed `STATIC-HOSTS`/DAI ACL** silently dropped Pi01 (Dynamic ARP Inspection with a stale/missing binding).
  - **Fix:** add/repair Pi01's binding in the switch's static-host list; longer term this is fixed **structurally** by NetBox generating the list. Confirm reachability to the gw (`ping 10.10.0.1`).

## Don't re-pile services back on
- **Symptom:** temptation to re-add RADIUS/Vault/CA "just here for now."
  - **Cause:** forgetting the reduction *is* the design (`ADR-0009` — one SD-card Pi was the PKI's SPOF).
  - **Fix:** don't. Those live on NPS01 / Vaultwarden / offline CA. Keep Pi01 to DNS+NTP.

## Related
- `Diagnostics.md` (the checks that confirm the fix) · `Considerations.md` (why these scars exist) · `Build-Checklist.md` · Academy `Atlas-Academy/Command-Library/Linux.md` · `ADR-0009`/`ADR-0020`/`ADR-0003`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Seeded from Pi01's known scars — the timesyncd-stole-the-clock false-tick, the v6 `custom.list` inert record, the `atlas.lab` conditional-forward failure, the upstream/filtering break, the STATIC-HOSTS/DAI "Pi01 mystery" silent drop, and the don't-re-pile-services rule — each symptom→cause→fix. Real incidents append. |
