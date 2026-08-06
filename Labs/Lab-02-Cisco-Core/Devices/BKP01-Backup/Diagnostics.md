---
Title: BKP01 — Diagnostics (show/verify battery)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup
Status: 🟡 Seeded — host + PBS + Vaultwarden checks. Not yet run (host unbuilt). Links up to Academy `Command-Library/Linux.md`.
Version: 0.1
Date: 2026-07-30
---

# BKP01 — Diagnostics (show/verify battery)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** 📋 verify commands for the backup + secrets host. Nothing here is device-verified — all ⬜/📋 (`POL-0001`). Links up to `Atlas-Academy/Command-Library/Linux.md`.

## Host / identity
| Check | Command | Expected (healthy) | Verified? |
|---|---|---|---|
| Reachable | `ping 10.20.0.18` | reachable | ⬜ |
| Identity regenerated uniquely | `hostnamectl` · `cat /etc/machine-id` | `bkp01`, unique machine-id (not the template's) | ⬜ 🔴 |
| IP / VLAN | `ip -br a` · `ip r` | `10.20.0.18/26` gw `10.20.0.1`, VLAN 20 | ⬜ |
| DNS / time | `resolvectl status` · `timedatectl` | DNS `10.20.0.2`; clock synchronized | ⬜ |

## PBS (backup target)
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Service + node status | `proxmox-backup-manager versions` · `systemctl status proxmox-backup` | active; version reported | ⬜ 📋 |
| Datastore (on the 8 TB) | `proxmox-backup-manager datastore list` | the datastore present, backed by the 8 TB mount | ⬜ 📋 |
| Verify-job status | `proxmox-backup-manager verify-job list` (+ task log) | last verify **OK**, no failed chunks | ⬜ 📋 |
| Prune / retention | `proxmox-backup-manager prune-job list` | retention set matches policy | ⬜ 📋 |
| 🔴 Restore check | `proxmox-backup-client restore <snapshot> <file>` (to a scratch/isolated target) | restore completes + data reads back | ⬜ 📋 🔴 never run |

## Off-site (restic/borg)
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Snapshot list | `restic -r <repo> snapshots` / `borg list <repo>` | recent snapshots present; repo reachable | ⬜ 📋 |
| Integrity | `restic check` / `borg check` | no errors; key valid | ⬜ 📋 |

## Vaultwarden
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Service | `systemctl status vaultwarden` | active (running) | ⬜ 📋 |
| TLS (ICA01 cert) | `openssl s_client -connect 10.20.0.13:443 -servername <fqdn> </dev/null` | ICA01-chained cert, not expired | ⬜ 📋 |

## Related
- `Build-Guide.md` · `Roles/PBS/` · `Roles/Vaultwarden/` · `Atlas-Academy/Command-Library/Linux.md`.

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-07-30 | Created — seeded host/PBS/off-site/Vaultwarden verify battery (all ⬜/📋; restore check flagged never-run). |
