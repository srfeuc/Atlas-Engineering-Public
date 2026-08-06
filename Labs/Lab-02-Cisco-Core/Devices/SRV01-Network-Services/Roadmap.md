---
Title: SRV01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services
Status: 🟢 LIVING roadmap — the host + per-service build path with dependencies. Status mirrors the host `Build-Checklist.md` + `Roles/<svc>/`. (`POL-0001`.)
Version: 1.0
Date: 2026-07-29
---

# SRV01 — Roadmap (build path + connections)

> **How to read this.** The host comes up first, then the services (roles). **Needs** = prerequisite; **Unblocks** = what proceeds. 🔴 **nginx-CRL is on the PKI critical path** — build it first among the roles.

## Host build
- [ ] 📋 **Clone `TPL-UBUNTU2604`** → cloud-init identity (`10.20.0.10`, VLAN 20). *Needs:* the golden image + PVE01. → Build-Guide Part 1.
- [ ] 📋 **Verify identity regenerated uniquely** (`POL-0001` — the whole point of guide `220`). → Part 1.3.
- [ ] 📋 **CIS-Ubuntu hardening** (named admin, SSH-keys-only, host firewall, `unattended-upgrades`) + role firewall (open 80). → Parts 2/5.

## Services (roles) — in priority order
- [ ] 🔴 📋 **nginx-CRL** (`Roles/nginx-CRL/`) — the `pki.atlas.lab` CRL/AIA host. *Needs:* host up + `pki.atlas.lab` DNS + **ICA01** producing a CRL. *Unblocks:* the **PKI revocation gate** + all estate cert validation. → Build-Guide Part 3.
- [ ] 📋 **Oxidized** (`Roles/Oxidized/`) — pull SW01/FGT01/MKT01/1941 configs → git. *Needs:* device read-only accounts (vaulted) + ideally NetBox for the device list. *Unblocks:* config-drift detection.
- [ ] 📋 **rsyslog relay** (`Roles/rsyslog/`) — device + own logs → MON01. *Needs:* MON01 up.
- [ ] 📋 **SFTP/TFTP** (`Roles/SFTP-TFTP/`) — `tftpd-hpa` + SFTP for IOS transfer.

## Certification alignment

| Role | Exercises | Cert |
|---|---|---|
| nginx-CRL | PKI revocation infra (CDP/AIA) | Security+ (PKI) · 70-742 Ch8 |
| Oxidized | config-as-code, git diffs, IaC | CCNA Dom-6 (automation) |
| TFTP/SFTP | IOS image/config transfer | CCNA IP-services |
| rsyslog | centralized logging | CCNA (syslog) · Security+/CySA+ (SecOps) |
| Host | CIS-Ubuntu hardening | Security+ (Linux) |

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PVE01 → SW01 → MKT01 · DC01 DNS | VLAN-20 reach · `pki.atlas.lab` |
| ⬆ Depends on | ICA01 · NetBox · Vaultwarden | CRL source · device list · creds |
| ⬇ Serves | 🔴 ICA01/PKI + all relying parties | revocation (`pki.atlas.lab`) |
| ⬇ Serves | SW01/FGT01/MKT01/1941 · MON01 | config backup/transfer · log relay |

## Related
- Host `Build-Checklist.md` · `Build-Record.md` · `README.md` · `Considerations.md` · `Build-Guide.md` · `Roles/`. Estate index: `../../Service-Server-Build-Plan.md`.
