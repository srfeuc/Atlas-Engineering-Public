---
Title: BKP01 — Roadmap (build path + connections)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup
Status: 🟢 LIVING roadmap — host + per-service (PBS · Vaultwarden) build path. Mirrors the host `Build-Checklist.md` + `Roles/<svc>/`. (`POL-0001`.)
Version: 0.1
Date: 2026-07-30
---

# BKP01 — Roadmap (build path + connections)

> **How to read this.** The host comes up first, then the two services. **Needs** = prerequisite; **Unblocks** = what proceeds. 🔴 **Phase 9 = the top live risk** — a backup isn't real until a restore succeeds, and the restore Game Day has never run.

## Host build
- [ ] 📋 **Clone the golden image / PBS ISO** → identity (host `10.20.0.18`, VLAN 20). *Needs:* PVE02/EQR6 acquired (EQR6 already bought). *Unblocks:* everything below. → Build-Guide Part 1. *Cert:* AZ-800 (deploy).
- [ ] 📋 **Verify identity regenerated uniquely** (machine-id / host keys, `POL-0001`). → Part 1.
- [ ] 📋 **Harden** (named admin, SSH-keys-only, host firewall, auto-updates) + DNS/time from DC01. → Part 3.

## Services (roles) — in order
- [ ] 🔴 📋 **PBS install + datastore on the 8 TB** (`Roles/PBS/`) — the deduplicating backup target. *Needs:* host up + the 8 TB external attached (`ADR-0036` v1.2). *Unblocks:* all backup jobs. → Build-Guide Part 4. *Cert:* AZ-800/801 (backup/storage).
- [ ] 📋 **Backup jobs** — DC system-state (**KDS root key** / SYSVOL), the VMs, the golden templates, device configs. *Needs:* PVE hosts as clients; DCs reachable. *Unblocks:* verify + off-site. → `Roles/PBS/`.
- [ ] 📋 **Verify + prune/retention** — PBS re-reads backups; retention per 3-2-1. *Needs:* jobs running. *Unblocks:* trustworthy restores. *Cert:* AZ-800/801.
- [ ] 🔴 📋 **Off-site copy (mandatory, `ADR-0009`/`ADR-0013`)** — restic/borg → external/cloud, **encrypted, key offline** (`POL-0002`). *Needs:* datastore populated + an off-site target. *Unblocks:* backup independence. → `../../Operations/Device-Backup-Runbook.md`. *Cert:* Security+ (3-2-1).
- [ ] 🔴 📋 **Restore Game Day (`ADR-0011`/`POL-0005`)** — restore a VM to an isolated VLAN; confirm it boots. **Never run in Atlas.** *Needs:* a completed+verified backup. *Unblocks:* "backup is real". *Cert:* Security+ (recovery). → `Roles/PBS/`.
- [ ] 📋 **Vaultwarden install + ICA01 TLS** (`Roles/Vaultwarden/`) — the standalone secrets vault. *Needs:* host up + **ICA01** issuing a cert + DNS. *Unblocks:* CA-passphrase custody + all credential storage (`ADR-0009`, `ADR-0031`, `POL-0002`). *Cert:* Security+ (secrets custody). → Build-Guide Part 6.
- [ ] 🔴 📋 **`049` — Vaultwarden master-password recovery path (GATED)** — resolve **before** trusting it as the vault. *Needs:* the `049` design question answered (this is a design-ref, NOT ADR-0049). *Unblocks:* production trust of the vault. → `Considerations.md`.
- [ ] 📋 **Automation onboarding (Phase 10, `ADR-0048`)** — PBS install + backup-job-as-code + off-site sync cron; Vaultwarden deploy. The restore-Game-Day judgment stays manual. → `Automation/`.

## Connections at a glance

| Direction | Who | Over what |
|---|---|---|
| ⬆ Depends on | PVE02/EQR6 + 8 TB → SW01 → MKT01 | hosts VM · datastore · VLAN-20 gw |
| ⬆ Depends on | DC01 · ICA01 · off-site target | DNS/time · Vaultwarden TLS · restic/borg |
| ⬇ Serves | 🔴 whole-estate recoverability | AD system-state/KDS/SYSVOL · VMs · templates · configs |
| ⬇ Serves | every credential + CA-passphrase | Vaultwarden vault (HTTPS 443) |

## Certification alignment

| Area | Exercises | Cert |
|---|---|---|
| PBS datastore · verify · prune | backup + storage discipline | AZ-800/801 (→AZ-802 2026-09-30) |
| Off-site 3-2-1 · encryption keys | recovery + key custody | Security+ |
| Restore Game Day | DR proof | Security+ (recovery) · AZ-801 |
| Vaultwarden secrets custody | PKI/secret handling | Security+ (secrets) |

## Related
- Host `Build-Checklist.md` · `Build-Guide.md` · `Considerations.md` · `Build-Record.md` · `README.md` · `Roles/`. Estate index: `../../Service-Server-Build-Plan.md`. Build order: `../../Operations/Build-Order-and-Dependencies.md`.
