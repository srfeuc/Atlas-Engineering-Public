# BKP01 — Roles (per-service build units)

> BKP01 is a **multi-service host**, so each service is its own build unit (`Roles/` pattern — like SRV01/MON01). The **host** folder owns everything true of the box (OS, VLAN-20 identity, hardening, placement on PVE02/EQR6 + the 8 TB); each **role** folder owns everything true of that one service. A fact lives in exactly one place (`POL-0008`). These two are **genuinely separate** — a backup target and a secrets vault that merely co-locate.

| Role | What it owns | Build phase |
|---|---|---|
| `PBS/` | the backup target — datastore on the 8 TB, backup jobs, verify, prune/retention, off-site restic/borg, 🔴 the restore Game Day | Roadmap: PBS + off-site + Game Day (Phase 9) |
| `Vaultwarden/` | the secrets vault — install, ICA01 TLS, admin token, 🔴 the `049` master-password recovery gate, vault-backed-into-PBS | Roadmap: Vaultwarden (after PBS, Phase 9) |

Each role folder holds a `Build-Checklist.md`; `Build-Guide`/`Diagnostics` are added as the role is built (checklist-first). The host spine that sequences these is `../Build-Guide.md`.
