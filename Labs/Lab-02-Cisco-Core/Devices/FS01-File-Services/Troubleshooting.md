---
Title: FS01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/FS01-File-Services
Status: 🟢 LIVING — symptom→cause→fix for the file server. Seeded from the known traps; real incidents append. Verify commands in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-30
---

# FS01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → likely cause → fix. Checks that confirm a fix are in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## Shares offline / data volume missing
- **Symptom:** shares vanish; the data volume isn't there.
  - **Cause:** the **8 TB USB external** disconnected / re-enumerated to a different letter (`ADR-0036` v1.2 — shares live on it).
  - **Fix:** reconnect on stable power; **mount by disk serial/GUID**, not drive-letter; re-share; monitor the volume on MON01. Log a `CM-####` if it recurs — a flaky data disk is a Tier-1 risk.

## Access control wrong
- **Symptom:** HR can reach the IT share (should be denied), or a user is denied a share they should get.
  - **Cause:** a **direct-user ACL** crept in, or the user's **AGDLP group** membership is wrong, or a deny ACE overrides.
  - **Fix:** remove direct-user ACLs (groups only, `ADR-0021`); fix the global→domain-local group membership; re-run the HR→HR ✓ / HR→IT ✗ proof (`Diagnostics.md` §3).

## DFS
- **Symptom:** `\\atlas.lab\<ns>` doesn't resolve, or doesn't fail over.
  - **Cause:** namespace not published / DNS issue / a single target (nothing to fail to) / DFSR not replicating.
  - **Fix:** confirm the namespace + targets (`Get-DfsnFolderTarget`); check DNS; add a 2nd target for real failover; check DFSR backlog/conflict + staging space.

## VSS / previous-versions
- **Symptom:** no previous-versions available, or Shadow Copies stop.
  - **Cause:** VSS storage full / not enabled / schedule off.
  - **Fix:** enable + size the shadow storage; confirm the schedule. 🔴 **Remember VSS is not a backup** — for real recovery use **BKP01** (`POL-0005`).

## Quotas / screens
- **Symptom:** users get "disk full"/write-denied unexpectedly.
  - **Cause:** an **FSRM quota** hit or a **file-screen** blocked the extension.
  - **Fix:** check `Get-FsrmQuota` / the file-screen; adjust the template; distinguish a real quota from a screen block in the FSRM event.

## Related
- `Diagnostics.md` · `Considerations.md` · `Build-Guide.md` · Academy `Command-Library/PowerShell-Tier0.md` + `Concepts/Windows-Logon-Scripts-and-Drive-Mapping.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded from FS01's known traps (8 TB USB disconnect, direct-user-ACL/AGDLP drift, DFS resolve/failover/DFSR, VSS storage + the VSS≠backup reminder, FSRM quota/screen). Real incidents append. |
