---
Title: WSUS01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/WSUS01-Patch-Management
Status: 🟢 LIVING — symptom→cause→fix for WSUS. Seeded from the known traps; real incidents append. Verify commands in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-30
---

# WSUS01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → cause → fix. **Never invent output** (`POL-0001`).

## Sync
- **Symptom:** first sync fails / stalls.
  - **Cause:** no FGT01 egress to Microsoft Update, DNS, or (later) UTM deep-inspection breaking the TLS to MS endpoints.
  - **Fix:** confirm egress + DNS; if `ADR-0047` UTM breaks the MS TLS, add an inspection **exception** for the Update endpoints (a known deep-inspection gotcha). Expect it slow (OK per operator).

## Clients not reporting
- **Symptom:** clients don't appear / wrong target group.
  - **Cause:** the WSUS GPO isn't applied, wrong WUServer URL/port, or client-side targeting name ≠ the WSUS group.
  - **Fix:** `gpresult` on the client; confirm WUServer + target-group string; `wuauclt /resetauthorization /detectnow` (or `UsoClient StartScan`); check the group name matches exactly.

## Content store fills the disk
- **Symptom:** the volume fills; sync/downloads fail.
  - **Cause:** content store on the OS disk, or no cleanup/decline-superseded.
  - **Fix:** move content to its own vdisk; run the **Server Cleanup Wizard**; decline superseded updates (after the first full sync).

## A bad patch hit everything
- **Symptom:** an update broke hosts broadly.
  - **Cause:** auto-approve / no ring hold.
  - **Fix:** restore the **pilot → broad** ring with a hold; decline the bad update; use the pilot group to catch it next time.

## Related
- `Diagnostics.md` · `Considerations.md` · `Build-Guide.md` · `ADR-0047` (the UTM-inspection exception note) · Academy `Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded from WSUS traps (sync egress/UTM-TLS exception, clients-not-reporting GPO/targeting, content-store fills, bad-patch/ring-discipline). Real incidents append. |
