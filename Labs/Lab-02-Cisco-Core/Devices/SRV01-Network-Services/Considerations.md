---
Title: SRV01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services
Status: 🟠 LIVING — open risks, gates, and unsettled decisions for the network-services host.
Version: 1.1
Date: 2026-07-29
---

# SRV01 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us" list for SRV01 — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`).

## Standing risks
- 🔴 **SRV01 is on the PKI critical path.** The nginx CRL host is the estate's **revocation endpoint** — if SRV01 is down or `pki.atlas.lab` is unreachable, revocation checking can fail estate-wide (fail-open = accept revoked certs, fail-closed = break auth). Treat its availability as PKI-grade; keep the CRL fresh (nextUpdate alarms).
- 🔴 **Oxidized credentials** must be **read-only + vaulted** (Vaultwarden, `POL-0002`) — never in the Oxidized config in cleartext, never in git. The `033` `testing`/`password` stock-credential lesson: don't recreate it.
- 🔴 **No secrets in git** — run `gitleaks`; a config-backup repo is a juicy target.

## Open items
- **OS confirmation** — ✅ **reconciled (#22 audit):** the Debian→Ubuntu drift is closed — `Build-Checklist.md` v1.1 (2026-07-23) already says **Ubuntu Server 26.04** (matching the Build-Guide; the guide's stale "checklist still says Debian" note was updated). Only remaining: confirm the clone is Ubuntu **at build** (`POL-0001`).
- **NetBox dependency** — Oxidized ideally sources its device list from NetBox (`POL-0004`); if NetBox isn't up yet, run Oxidized on a static list and switch later.
- **SRV01's own TLS cert** — optional cert from ICA01 (if the CRL host or SFTP should be TLS-fronted); decide at build.
- **Not domain-joined** — SRV01 is standalone Ubuntu using DC DNS; no AD identity (intentional).

## Decided (audit #22, 2026-07-30)
- **Services map added to `README.md`** (Standard v1.7 / Backlog #27) — one row per `Roles/` service (nginx-CRL · Oxidized · rsyslog · TFTP/SFTP), all 📋 (authored, not executed, `POL-0001`). SRV01's compact README has no mermaid diagram (predates v1.5) — the Services map is the connections view; no edge-label backfill applies.
- **Debian→Ubuntu drift RECONCILED** — the checklist was already Ubuntu (v1.1); updated the Build-Guide's stale "checklist still says Debian" note to reflect it. Guide + checklist now agree (Ubuntu 26.04).
- **No separate `Networking-Build-Guide.md` for SRV01** *(operator policy — appliances point, hosts get new)*. Standard tagged-VLAN-20 Ubuntu host; the cloud-init identity/netplan bring-up is already covered by `Build-Guide.md` (Part 1, the `220` discipline) — a second doc would duplicate it (`POL-0008`).

## Related
- `Roadmap.md` · `Build-Guide.md` · `Roles/` · `../../Operations/Validation-and-Adversarial-Testing.md` (revocation + logging tests).

## Change Log
| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-07-30 | **#22 audit:** added a **Decided** section — Services map backfilled into `README.md` (Standard v1.7 / Backlog #27, all 📋); **Debian→Ubuntu drift reconciled** (checklist already Ubuntu v1.1; Build-Guide note updated); no separate `Networking-Build-Guide.md` (bring-up already in `Build-Guide.md`). |
| 1.0 | 2026-07-29 | Created — standing risks (PKI-critical-path availability, read-only vaulted Oxidized creds, no-secrets-in-git) + open items (OS confirmation, NetBox dependency, optional TLS cert, not-domain-joined). |
