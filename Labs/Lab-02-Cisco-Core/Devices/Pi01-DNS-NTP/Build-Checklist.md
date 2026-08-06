---
Title: Pi01 Build Checklist (DNS + NTP)
Path: Labs/Lab-02-Cisco-Core/Devices/Pi01-DNS-NTP
Status: Target Design — build checklist. You write the config; verify with the service's own status command (POL-0001 R-A1).
Version: 1.0
---

# Pi01 — Build Checklist (DNS + NTP, reduced)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`Atlas-Service-Architecture` Part 2):** 🔴 **reduced to two jobs — Pi‑hole DNS (filtering forwarder) + NTP (chrony).** Everything else it used to run — RADIUS, Vaultwarden, the Root CA, the Intermediate CA — **moves off** (to SRV01, VAULT01, offline media, CA01). Fresh OS; VLAN 10 (`10.10.0.x/27`, gw `10.10.0.1`). Sources: [CIS Debian Linux Benchmark](https://www.cisecurity.org/benchmark/debian_linux), [Pi‑hole docs](https://docs.pi-hole.net/), [chrony docs](https://chrony-project.org/documentation.html).
>
> 🔴 **Two Atlas scars live on this exact box** — read the failure modes before you tick anything.

## Gate
- [ ] Fresh Raspberry Pi OS Lite (64‑bit) on a good SD card; keep the old SD as the backup image (`Device-Backup-Runbook`).
- [ ] Confirm the migrations OFF Pi01 are done first (Vault→VAULT01, RADIUS→SRV01, CA→offline/CA01) — nothing should still depend on Pi01 for them.

## Build steps

### 1. Base OS hardening (CIS Debian)
- [ ] **Named admin, disable the default `pi` user**; **SSH keys only**, `PermitRootLogin no`, `PasswordAuthentication no`.
- [ ] **Host firewall** (nftables/ufw): allow only **DNS (53), NTP (123), SSH (22 from mgmt)** inbound; drop the rest.
- [ ] **`unattended-upgrades`** on; disable unused services (bluetooth, avahi, triggerhappy).
- [ ] Hostname `pi01`, timezone, static IP on VLAN 10.

### 2. DNS — Pi‑hole as the filtering forwarder
- [ ] Install Pi‑hole; set upstream resolvers (DoT/DoH or the lab resolvers).
- [ ] **The `ADR-0003`/`ADR-0007` boundary:** domain machines use **AD DNS on the DCs**; Pi‑hole is the **non‑domain** filtering forwarder. **Conditional‑forward `atlas.lab` → the DC DNS** so Pi‑hole clients can still resolve domain names.
- [ ] 🔴 **Local DNS records go in the v6 config location, NOT `/etc/pihole/custom.list`** — `custom.list` is **inert on Pi‑hole v6**. Put records where v6 actually reads them (`dnsmasq.d` / the v6 config), and **test that they resolve** (see validation).

### 3. NTP — chrony (`ADR-0020`)
- [ ] 🔴 **Install `chrony` and confirm it's the active daemon — NOT `systemd-timesyncd`.** (`046` ticked "chrony confirmed working" when `chronyc: command not found` and the box actually ran timesyncd.)
- [ ] Configure per the `ADR-0020` hierarchy: upstream source(s), and **serve NTP to the lab subnets** (`allow 10.0.0.0/8` scoped appropriately).

### 4. Monitoring & backup
- [ ] **Syslog → MON01**; SNMPv3 if monitored.
- [ ] **SD‑card image + config tar** per `Device-Backup-Runbook`; consider log2ram to cut SD wear.

## Validation — the service's own status, not a config line
- [ ] `dig @10.10.0.<pi> atlas-lab-host.atlas.lab` **and** an external domain — both resolve; ad‑blocking works. 🔴 **Prove the local records resolve** (not just that they're in a file — the `custom.list` trap).
- [ ] 🔴 `chronyc tracking` + `chronyc sources` — **actually synchronized**, reference sane. And `systemctl status chrony` confirms chrony (not timesyncd) is running (`046`).
- [ ] Host firewall: only 53/123/22 open (`nft list ruleset`).
- [ ] Confirm **nothing still points at Pi01** for RADIUS/Vault/CA (grep configs; check the wire).

## Failure modes
- 🔴 **The `046` trap** — ticking "NTP works" from memory or `systemctl` presence. Only `chronyc tracking` proves sync, and only after confirming chrony (not timesyncd) is the daemon.
- 🔴 **The `custom.list` trap** — DNS records in a file Pi‑hole v6 ignores. They do nothing; the record "exists" and never resolves. Test resolution, not file contents.
- 🔴 **Over‑piling services back on** — the reduction *is* the point (`ADR-0009`: one SD‑card Pi was a single point of failure for the whole PKI). Don't re‑add the CA/vault/RADIUS.
- **SD‑card wear → corruption** — keep the image backup; the box is disposable by design now.
- **A self‑signed/stale cert on the Pi‑hole admin TLS** (if enabled) — verify the issuer *on the wire*, the Pi‑hole‑cert lesson.

## Change Log
| Version | Changes |
|---|---|
| 1.0 | 2026-07-17. Build checklist for Pi01 reduced to DNS (Pi-hole filtering forwarder) + NTP (chrony) per `Atlas-Service-Architecture` Part 2. CIS-Debian base hardening; the `ADR-0003`/`ADR-0007` DNS boundary (AD DNS for domain, Pi-hole conditional-forwards `atlas.lab`); chrony under `ADR-0020`. Foregrounds the two scars on this box — the `046` chrony-vs-timesyncd false-tick and the `custom.list`-inert-on-v6 record trap — with status-command validation and the "don't re-pile services" reduction rationale. |
