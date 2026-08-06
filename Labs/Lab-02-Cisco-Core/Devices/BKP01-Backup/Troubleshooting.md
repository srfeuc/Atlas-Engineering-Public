---
Title: BKP01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup
Status: 🟡 Seeded — expected failure modes; fill with real incidents as the build runs.
Version: 0.1
Date: 2026-07-30
---

# BKP01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** Symptom → cause → fix for the backup + secrets host. Service-specific issues also live in `Roles/PBS/` and `Roles/Vaultwarden/`.

| Symptom | Likely cause | Fix / check |
|---|---|---|
| **Verify job fails** (bad/missing chunks) | corrupt datastore, failing 8 TB media, or interrupted backup | `proxmox-backup-manager verify-job` task log; SMART on the 8 TB; re-run backup; a verify failure means **do not trust that restore point** |
| **Datastore full / prune not reclaiming** | retention too long, prune job not running, or GC not run | check prune-job + run garbage-collection; revisit retention/sizing → **Backlog #20** |
| **Off-site sync fails** | repo unreachable, wrong/lost key, or target full | `restic/borg check`; confirm the **offline key** (`POL-0002`); 🔴 off-site is mandatory (`ADR-0009`) — a failed sync means no independence |
| **Vaultwarden TLS error / browser warning** | cert expired, wrong SAN, or not chained to ICA01 | re-issue from **ICA01**; verify `openssl s_client`; confirm the `pki.atlas.lab` chain |
| **Vaultwarden login / can't unlock** | admin token lost or 🔴 **master-password with no recovery path (`049`)** | the `049` gate is OPEN — resolve the recovery path *before* trusting the vault; token kept offline |
| **Restore fails** | untested job, wrong snapshot, or no isolated target | 🔴 this is the whole point (`ADR-0011`/`POL-0005`) — restore to isolated VLAN 70; a backup that won't restore is not a backup |

## Related
- `Build-Guide.md` · `Diagnostics.md` · `Considerations.md` · `Roles/` · `../../Operations/Device-Backup-Runbook.md`.

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-07-30 | Seeded with expected BKP01 failure modes (verify fail, datastore full/prune, off-site sync, Vaultwarden TLS/login, restore fails). |
