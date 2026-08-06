---
Title: RDS01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/RDS01-Remote-Desktop
Status: 🟢 LIVING — symptom→cause→fix for RDS. Seeded from the known traps; real incidents append. Verify commands in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-30
---

# RDS01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → cause → fix. **Never invent output** (`POL-0001`).

## Licensing
- **Symptom:** connections refused after ~120 days ("no Remote Desktop License Servers available").
  - **Cause:** the grace period expired; no license server / CALs.
  - **Fix:** deploy + activate RD Licensing; install **RDS CALs**; set the licensing mode (per-user/device) on the collection; confirm with the Licensing Diagnoser.

## Gateway TLS
- **Symptom:** clients get a certificate name/trust warning, or RD Web SSO breaks.
  - **Cause:** a self-signed cert, wrong **SAN**, or the client doesn't trust the ICA01 chain.
  - **Fix:** bind the **ICA01** cert with the correct SAN (`ADR-0027`); ensure the root/issuing chain is trusted (AD-distributed) and the CRL is reachable.

## Authorization (CAP/RAP)
- **Symptom:** authenticated users still can't connect through the gateway.
  - **Cause:** no matching **CAP/RAP** on NPS, wrong RADIUS shared secret, or the user's AD group isn't in the policy.
  - **Fix:** confirm the RDS01 RADIUS client + shared secret on **NPS01**; author/repair CAP (who) + RAP (to what) keyed to the AD group (`ADR-0029`); check the NPS event log for the reject reason.

## Tier separation (security)
- **Symptom:** a Tier-0 account can log on / reach T0 systems via RDS.
  - **Cause:** T0 accounts weren't excluded from the collection / CAP.
  - **Fix:** remove T0 from the collection access group + the CAP; re-run the **negative test**; Tier-0 admin is the **PAW01** path (`ADR-0021`), not RDS.

## Session experience
- **Symptom:** redirection (clipboard/drive/printer) or session limits behave unexpectedly.
  - **Cause:** conflicting RDS **GPOs** or collection properties.
  - **Fix:** `gpresult`/RSoP on RDS01; reconcile the session GPO vs the collection settings (one owner); apply the hardening baseline (`Architecture/CIS-Hardening-*`).

## Related
- `Diagnostics.md` · `Considerations.md` · `Build-Guide.md` · `ADR-0029` (NPS CAP/RAP) · `ADR-0027` (ICA01 TLS) · `ADR-0021` (tiering) · Academy `Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded from RDS traps (licensing grace/CALs, gateway TLS SAN/trust, CAP/RAP authorization, Tier-0 separation negative test, session redirection/GPO conflicts). Real incidents append. |
