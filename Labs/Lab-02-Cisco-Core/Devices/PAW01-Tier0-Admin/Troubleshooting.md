---
Title: PAW01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin
Status: 🟢 LIVING — symptom→cause→fix for the golden image + Tier-0 PAW. Seeded from the known traps; real incidents append. Verify commands in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-29
---

# PAW01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → likely cause → fix. Checks that confirm a fix are in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## Golden image
- **Symptom:** `sysprep /generalize` fails ("installed for a user, but not provisioned for all users").
  - **Cause:** a per-user **Store app**. **Fix:** remove/deprovision the offending appx (or don't touch Store apps in Audit Mode); `Test-SysprepReadiness.ps1` flags risky ones.
- **Symptom:** generalize fails on an encrypted volume (Win11 24H2+).
  - **Cause:** BitLocker on. **Fix:** `manage-bde -status`; suspend/disable before sealing.
- **Symptom:** can't reach Audit Mode — the key chord is eaten by noVNC.
  - **Cause:** noVNC/browser intercepts `Shift+F10`/`Ctrl+Shift+F3`. **Fix:** try `Ctrl+Shift+F3` first; else noVNC Fullscreen, or switch the VM Display to **SPICE** + remote-viewer for full key passthrough.

## Network
- **Symptom:** PAW01 has no return traffic / can't be reached.
  - **Cause:** put on **native VLAN 10** (untagged on the PVE trunk) with a tag-10 vNIC. **Fix:** use **VLAN 20 tagged**, static `10.20.0.10–.55`.

## Domain / tier
- **Symptom:** PAW01 landed in `Devices\Staging`, not the PAW OU.
  - **Cause:** joined **without pre-staging** the computer object (`redircmp` sends unstaged joins to Staging). **Fix:** move the object to `Admin\Tier 0\PAW`; `gpupdate /force`; reboot. (Pre-stage next time.)
- **Symptom:** `t0-seth` can't RDP a DC by IP.
  - **Cause:** `t0-seth` is in **Protected Users** (no NTLM). **This is expected** — that's *why* PAW01 exists: RDP the PAW (Kerberos + clipboard), then admin the DC via RSAT from it.
- **Symptom:** a Tier-1/Tier-2 account can log on to PAW01 (should be denied).
  - **Cause:** **7d** deny-cross-tier not applied/linked. **Fix:** build + link the 7d GPOs (DC roadmap); re-test (`Diagnostics.md` §4).

## Hardening
- **Symptom:** Credential Guard not running.
  - **Cause:** the Proxmox **VBS** features aren't exposed to the VM (`msinfo32` shows VBS not running). **Fix:** confirm host CPU virtualization/VBS support + the Proxmox CPU type=`host`; this is the same gate as the DC Wave-B GPOs.
- **Symptom:** an admin tool won't run.
  - **Cause:** **AppLocker allow-list** blocks it (by design). **Fix:** add the tool to the allow-list GPO if it's legitimately needed; don't disable AppLocker.

## Related
- `Diagnostics.md` · `Considerations.md` · `Build-Guide.md` (the detailed steps + the device-learned noVNC note) · Academy `Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded from PAW01's known traps (sysprep Store-app/BitLocker/noVNC, native-VLAN-10, staging-OU, Protected-Users-can't-RDP-by-IP [expected], 7d-not-applied, Credential-Guard-VBS, AppLocker-blocks-a-tool). Real incidents append. |
