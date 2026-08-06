---
Title: FS01 — Considerations (open risks & decisions)
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services
Status: 🟠 LIVING — open risks, gates, and unsettled decisions for the file server. Closed items move to the Build-Record / Change Log.
Version: 1.1
Date: 2026-07-30
---

# FS01 — Considerations (open risks & decisions)

> **What this is.** The honest "what could bite us / what's not settled" list for the file server — separate from the steps (`Build-Guide.md`) and the checks (`Diagnostics.md`).

## Open gates
- 🔴 **VSS is not a backup (`POL-0005`).** Shadow Copies give self-service previous-versions, not recoverability from a host/disk loss. **FS01 data is only safe once BKP01 backs it up + a restore is tested.** Do not let "we have Shadow Copies" masquerade as a backup.
- 🔴 **The shares live on the 8 TB *external* (USB) on the EQR6.** Spinning USB is the right capacity/cost call for bulk file data (operator: OK-slow-but-don't-break) — **but a USB disconnect/enumeration glitch takes the shares offline.** Mitigate: a stable powered connection, mount-by-serial (not drive-letter roulette), monitor the volume (MON01), and lean on BKP01 for durability. Flag any flakiness as a `CM-####`.

## Standing risks (design)
- 🔴 **AGDLP only — never direct-user ACLs.** Shares are ACL'd by **domain-local** groups fed by **global** role groups (`ADR-0021`). A direct-user ACL is the drift that breaks the HR→HR ✓ / HR→IT ✗ model and is unauditable. Verify a real share's ACL, don't assume.
- 🟡 **Witness-independence caveat (`ADR-0046`).** If FS01 hosts the cluster's **file-share witness** *and* one cluster node also rides the EQR6, losing the EQR6 loses a node **and** the witness — not true quorum independence. For the on-demand cluster lab it's tolerable; the cleaner answer is the **cloud witness** (H4) or putting the witness on BKP01. Decide at the cluster build.
- 🟡 **Sizing is proposed, not sized.** 2 vCPU / 4 GB / data-on-8TB is a starting guess; dedup + FSRM + DFSR add RAM/CPU. The **capacity pass (Backlog #20)** finalizes it against the real hardware + the "don't break" constraint. SMB is **E-W** traffic (intra-estate) so it does **not** cross FGT/pfSense — no UTM/IPS throughput penalty on shares (unlike N-S services).
- **DFSR staging/conflict.** DFSR needs adequate staging space + a conflict-resolution understanding; a single-target namespace has nothing to replicate yet — DFSR earns its keep with a 2nd target/site (later).

## Open decisions (need a call / ADR when reached)
- 🟡 **Address `10.20.0.14` is proposed** — authoritative in `IP-Addressing-Plan-VLSM` (`POL-0008`); confirm.
- 🟡 **Data dedup on/off** — great space saver for file data, small CPU cost; default **on** for the data volume once stable.
- 🟡 **Does WSUS content or other bulk data co-locate here** vs its own host — TBD when WSUS01 is scoped.
- 🟡 **iSCSI target scope** — only stand it up if the cluster takes the S2D-fallback path (`ADR-0046`); otherwise skip.

## Decided (audit #22, 2026-07-30)
- **Services map + mermaid edge-labels backfilled** (Standard v1.7 / v1.6; Backlog #27) — the SMB/DFS/FSRM/VSS/iSCSI rows + protocol/port on every diagram edge (`SMB/445 · dept shares`, `iSCSI/3260 · witness`, …). All rows honest ⬜ (not built, `POL-0001`).
- **No separate `Networking-Build-Guide.md` for FS01** *(operator policy — appliances point, hosts get new)*. Standard tagged-VLAN-20 VM; the 8 TB USB / SMB-is-E-W subtleties already live in Standing risks, not a network bring-up guide (`POL-0008`).

## Related
- `Roadmap.md` · `Build-Checklist.md` · `Build-Guide.md` · `ADR-0021` (AGDLP) · `ADR-0036` (placement + 8 TB) · `ADR-0042` (client dept access) · `ADR-0046` (cluster fallback) · `POL-0005` (backup) · Backlog #20 (sizing) · `../../Operations/Validation-and-Adversarial-Testing.md` (the HR→IT deny proof).

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit:** added a **Decided** section — Services map + mermaid edge-labels backfilled (Standard v1.7/v1.6, Backlog #27, all ⬜); no separate `Networking-Build-Guide.md` (standard VLAN-20 VM). |
| 1.0 | 2026-07-30. Created — open gates (VSS≠backup, the 8 TB USB dependency), standing risks (AGDLP-only, the witness-independence caveat, proposed sizing + the SMB-is-E-W no-UTM-penalty note, DFSR staging), and open decisions (proposed IP, dedup, WSUS co-location, iSCSI scope). |
