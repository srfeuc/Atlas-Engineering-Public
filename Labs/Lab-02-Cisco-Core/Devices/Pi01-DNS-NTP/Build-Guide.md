---
Title: Pi01 — DNS & NTP (Pi-hole + chrony) Build Guide
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP
Status: 📋 Target design — the phased, gated rebuild contract (`ADR-0043`); phases mirror `Roadmap.md`. NOT executed. Author live values + 📸 + gotchas at the bench (`POL-0001` — evidence = command + output).
Version: 0.1
Date: 2026-07-30
---

# Pi01 — DNS & NTP (Pi-hole + chrony) Build Guide

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 rebuild)** — Host: **Pi01**, a **physical Raspberry Pi** (bare-metal; `ADR-0036` VM placement does **not** apply) reduced to **Pi-hole filtering DNS + chrony NTP only**. Work **phase by phase, each behind its 🔴 GATE**. The DNS boundary (`ADR-0003`/`ADR-0007`) and time hierarchy (`ADR-0020`) are the point of this box. 🔴 **DHCP is not here** (`ADR-0030`).

> 🔴 **The reduction is the design (`ADR-0009`).** Everything else this Pi once ran — FreeRADIUS, Vaultwarden, the Root + Intermediate CA — moved off because one SD-card Pi was a single point of failure for the PKI. Do **not** re-add them.

## Phase 0 — Migration-off GATE 🔴
**GATE — do not image until:** FreeRADIUS→NPS01, Vaultwarden→Vaultwarden, CA→offline are **all confirmed done** and **nothing still points at Pi01** for them (`ADR-0009`). Prove it on the wire, not from memory.
- 📸 the grep/wire check showing no live dependants for RADIUS/Vault/CA.

## Phase 1 — OS + identity 🔴
**GATE:** Phase 0 cleared.
- **Service-setup:** fresh **Raspberry Pi OS Lite (64-bit)** on a good SD (keep the old SD as backup image); named admin + **disable default `pi` user**; **SSH keys only** (`PermitRootLogin no`, `PasswordAuthentication no`); host firewall (nftables/ufw) inbound **`53`/`123`/`22` only**; `unattended-upgrades` on; hostname `pi01`; **static IP on VLAN 10** (`10.10.0.6` 📋 proposed, gw `10.10.0.1` — value owned by the IP plan).
- 🔎 Watch the **STATIC-HOSTS/DAI silent-drop** ("Pi01 mystery") on the VLAN-10 step.
- 📸 `ip a` + `nft list ruleset` (only 53/123/22); `hostnamectl`.

## Phase 2 — chrony NTP 🔴
**GATE:** Phase 1 cleared (identity + reachability).
- **Service-setup:** install **chrony**; 🔴 **confirm chrony — NOT `systemd-timesyncd` — is the active daemon** (`systemctl status chrony`); configure upstream per the `ADR-0020` hierarchy; serve NTP to the non-domain/infra subnets (scope the `allow` appropriately).
- 🔴 Do **not** tick "NTP works" from `systemctl` presence — only `chronyc tracking` proves sync (the `046` false-tick scar).
- 📸 `chronyc tracking` (synced, sane reference) + `chronyc sources`; `systemctl status chrony` confirming the daemon.

## Phase 3 — Pi-hole DNS 🔴
**GATE:** Phase 2 cleared (valid clock) + DC01 reachable.
- **Service-setup:** install **Pi-hole**; set upstream resolvers; **conditional-forward `atlas.lab` → the DCs** (`ADR-0003`/`ADR-0007`) so clients still resolve domain names; add local records in the **v6 config (`dnsmasq.d`)** — 🔴 **NOT `/etc/pihole/custom.list`** (inert on v6).
- 🔴 **Prove local records resolve** (`dig`), not just that they exist in a file (the `custom.list` trap).
- 📸 `pihole status`; `dig @10.10.0.6 <host>.atlas.lab` (via conditional-forward) **and** an external name; a local-record resolution proving `dnsmasq.d` is live.

## Automation-onboarding (`ADR-0048`) 🔴
**GATE:** the manual build proven.
- Capture **cloud-init/Ansible** to rebuild the Pi (Pi-hole + chrony **config as code**) in `Automation/` (idempotent). The DNS-policy/forwarder **design judgment** stays hand-owned — automation reproduces it, it does not decide it.

## Deferred / future (gated stub)
- **A 2nd resolver / time source** for fault tolerance (the SD-card SPOF mitigation, Backlog #2) — DESIGNED, not built (`ADR-0043`).
- Log2ram to cut SD wear; syslog → MON01 if monitored.

## Related
- `Roadmap.md` (phases) · `Build-Checklist.md` (line-item + scars) · `Diagnostics.md` (verify) · `Build-Record.md` (as-built) · `ADR-0009`/`ADR-0020`/`ADR-0003`/`ADR-0007` · `../../Architecture/IP-Addressing-Plan-VLSM.md` · `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md` · `../../Operations/Device-Backup-Runbook.md` · `Atlas-Academy/Command-Library/Linux.md`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created as the phased, gated rebuild guide (`ADR-0043`) for the reduced DNS+NTP Pi: migration-off GATE → Phase 1 OS+identity → Phase 2 chrony (confirm-not-timesyncd) → Phase 3 Pi-hole (conditional-forward `atlas.lab`, v6 `dnsmasq.d` records), plus the `ADR-0048` automation-onboarding and a gated future stub. 📸 capture points at each confirm screen; the two named scars foregrounded. |
