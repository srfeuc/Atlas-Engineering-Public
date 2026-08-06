---
Title: Pi01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP
Status: 🟢 LIVING roadmap — the rebuild path for the reduced DNS+NTP Pi + what each stage needs/unblocks. Status mirrors `Build-Checklist.md` (`POL-0001`); this page is the map, the checklist is the line-item record.
Version: 0.1
Date: 2026-07-30
---

# Pi01 — Roadmap (build path + connections)

> **How to read this.** Each row is a **stage** on the reduced DNS+NTP Pi. The checkbox is its status — dated and evidence-backed (the record is `Build-Checklist.md`). **Needs** = what must be healthy first; **Unblocks** = what proceeds once it's done. Build-order home: `../../Operations/Build-Order-and-Dependencies.md` (**Phase 5 — Core services**, after MON01).

## The build path (in order)

- [ ] ⬜ 🔴 **Migration-off gate.** Confirm FreeRADIUS→NPS01, Vaultwarden→Vaultwarden, CA→offline are **all done** and nothing still points at Pi01 for them. *Needs:* those hosts live. *Unblocks:* the whole rebuild — you rebuild to the reduced role, not alongside the old one. → `ADR-0009`. *Cert:* Security+ (blast-radius reduction).
- [ ] 📋 **Image + harden the Pi.** Fresh Raspberry Pi OS Lite (64-bit); named admin, SSH keys only, host firewall to **53/123/22** only; keep the old SD as a backup image. *Needs:* migration-off gate. *Unblocks:* a clean base. → `../../Operations/Device-Backup-Runbook.md`. *Cert:* Linux/Security+.
- [ ] 📋 **Static VLAN-10 identity.** Hostname `pi01`; static address on VLAN 10 (`10.10.0.6` 📋 proposed, gw `10.10.0.1`). *Needs:* SW01 VLAN-10 port + MKT01 gateway. *Unblocks:* reachability + DAI (see the STATIC-HOSTS scar). → owner: `../../Architecture/IP-Addressing-Plan-VLSM.md`. *Cert:* CCNA (addressing/VLANs).
- [ ] 📋 🔴 **chrony NTP (`ADR-0020`).** Install **chrony** and **confirm it — not `systemd-timesyncd` — is the active daemon** (`chronyc tracking`); set upstream per the hierarchy; serve NTP to non-domain/infra clients. *Needs:* static identity + an upstream time source. *Unblocks:* correct clock (DNS/PKI/Kerberos all depend on time). → `ADR-0020`. *Cert:* CCNA (IP services: NTP).
- [ ] 📋 🔴 **Pi-hole filtering DNS.** Install Pi-hole; set upstream resolvers; **conditional-forward `atlas.lab` → the DCs** (`ADR-0003`/`ADR-0007`); put local records in the **v6 config (`dnsmasq.d`), NOT `/etc/pihole/custom.list`**, and prove they resolve. *Needs:* chrony (valid time), DC01 reachable. *Unblocks:* non-domain filtering DNS + domain-name resolution for its clients. → `ADR-0003`. *Cert:* CCNA (IP services: DNS) · Linux.
- [ ] 📋 🎯 **Acceptance.** `dig @10.10.0.6 <host>.atlas.lab` **and** an external name both resolve; ad-blocking works; `chronyc tracking` shows real sync. → proofs in `Diagnostics.md`.
- [ ] 📋 **Automation onboarding (`ADR-0048`).** After the manual pass: cloud-init/Ansible to rebuild the Pi (Pi-hole + chrony as code) in `Automation/`. *Needs:* the manual build proven. *Cert:* CCNP ENAUTO-adjacent.

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | physical Pi (SD + power) → SW01 → MKT01 (gw `10.10.0.1`) | VLAN-10 reachability (bare-metal) |
| ⬆ Depends on | DC01 | `atlas.lab` conditional-forward target |
| ⬆ Depends on | upstream time source | NTP sync up the `ADR-0020` chain |
| ⬇ Serves | non-domain devices | filtering DNS (`53`) + NTP (`123`) |
| ⬇ Serves | Pi-hole clients | `atlas.lab` conditional-forward resolution path |

## Certification alignment (learning lens)

| Pi01 stage | Exercises (objective) | Cert |
|---|---|---|
| chrony NTP + serve subnets | IP services: NTP, time hierarchy | CCNA (IP services) |
| Pi-hole DNS + conditional-forward | IP services: DNS, forwarders | CCNA (IP services) |
| Pi-hole filtering + Linux service admin | DNS filtering, Linux daemon/firewall admin | Linux / Security+ adjacent |
| Host hardening + SPOF reduction | least privilege, availability design | Security+ |

## Validation
- Prove-it rows: `../../Operations/Validation-and-Adversarial-Testing.md` + this host's `Diagnostics.md`. Key proofs: a **local record actually resolves** (not just present in a file — the `custom.list` trap); **chrony** (not timesyncd) is the synced daemon; an **external** name resolves + is filtered.

## Related
- Line-item status: `Build-Checklist.md`. Front door: `README.md`. Open risks: `Considerations.md`. Verify: `Diagnostics.md`.
- Estate index: `../../Service-Server-Build-Plan.md`. Flows: `../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`. Decisions: `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-30 | Created — rebuild path for the reduced DNS+NTP Pi (Phase 5 core services): migration-off gate → image/harden → VLAN-10 identity → chrony (confirm not timesyncd) → Pi-hole (conditional-forward `atlas.lab`, v6 `dnsmasq.d` records) → acceptance → automation. Connections-at-a-glance + cert-alignment tables, with the DNS boundary and NTP hierarchy foregrounded. |
