---
Title: BKP01 — Considerations (open gates, risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup
Status: 🟠 LIVING — open gates, standing risks, and unsettled decisions for the backup + secrets host.
Version: 0.2
Date: 2026-07-30
---

# BKP01 — Considerations (open gates, risks & decisions)

> **What this is.** The honest "what could bite us" list for BKP01 — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`).

## Open gates (must clear before the thing they gate)
- 🔴 **The restore Game Day has NEVER been run** (`ADR-0011`/`POL-0005`). A backup you have not restored is a hope, not a control. No PBS job counts as "done" until a VM restores to an isolated VLAN and boots. This is the single most load-bearing gate on the host.
- 🔴 **Off-site copy is MANDATORY** (`ADR-0009` — now hard-required; `ADR-0013`). A datastore on the same tier it protects is not backup. The off-site restic/borg copy must be **encrypted with its key kept offline** (`POL-0002`), and its restore tested too (mount the repo, read a file back).
- 🔴 **`049` — Vaultwarden master-password recovery path is OPEN.** Resolve before trusting Vaultwarden as the estate vault — if the master secret is lost with no recovery path, the whole vault (every credential + CA-passphrase custody) is unrecoverable. *(`049` is a design-question ref, NOT ADR-0049.)*

## Standing risks
- 🔴 **Single datastore / single 8 TB.** The PBS datastore and FS01's shares both live on the one 8 TB external (`ADR-0036` v1.2) — one device failure hits backup *and* file data. The off-site copy is the mitigation; treat the 8 TB as a single point of failure until it exists.
- 🔴 **PBS + Vaultwarden co-location blast radius.** The backup target and the secrets vault share one box — a compromise or loss of BKP01 threatens both recoverability *and* every credential at once. Weigh splitting later; document the risk now.
- 🔴 **ICA compromise posture (`ADR-0009`).** Never *treat ICA as compromised* casually — the Vaultwarden TLS cert chains to ICA01, and CA-passphrase custody lives in the vault. Custody discipline (`POL-0002`, offline key) is what contains a bad day.

## Open decisions
- **Retention + datastore sizing** → **Backlog #20** (the estate capacity pass). How many restore points, prune cadence, and how big the datastore must be are unsettled.
- **Stale target reconcile (`POL-0008`).** `Build-Checklist.md` (now v1.1) previously listed the retired **CA01 / VAULT01** as backup targets — reconciled to **DC01/DC02 · NETBOX01 · ICA01 · Vaultwarden** (`ADR-0031`). Confirm no other doc still names the retired hosts.
- **Encryption-key custody.** Where the restic/borg key + Vaultwarden admin token live (offline, `POL-0002`) — decide and record the offline location before the off-site copy runs.

## Decided (audit #22, 2026-07-30)
- **Services map added to `README.md`** (Standard v1.7 / Backlog #27) — PBS datastore · off-site copy · Vaultwarden (the two `Roles/` + the mandatory off-site), all ⬜ (not built, `POL-0001`). Edges already labelled (v1.6) — Services-map-only.
- **No separate `Networking-Build-Guide.md` for BKP01** *(operator policy — appliances point, hosts get new)*. Standard tagged-VLAN-20 VM; the network path is owned by the hypervisor/switch pages (`POL-0008`).

## Related
- `Roadmap.md` · `Build-Guide.md` · `Roles/PBS/` · `Roles/Vaultwarden/` · `../../Operations/Device-Backup-Runbook.md` · `00-Atlas-Foundation/Decisions/ADR-Index.md`.

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.2 | 2026-07-30 | **#22 audit:** added a **Decided** section — Services map backfilled into `README.md` (Standard v1.7 / Backlog #27, all ⬜); no separate `Networking-Build-Guide.md` (VLAN-20 VM). |
| 0.1 | 2026-07-30 | Created — open gates (049 recovery · restore never-run · off-site mandatory), standing risks (single 8 TB · PBS+vault blast radius · ICA posture), open decisions (retention/sizing #20 · stale CA01/VAULT01 reconcile · key custody). |
