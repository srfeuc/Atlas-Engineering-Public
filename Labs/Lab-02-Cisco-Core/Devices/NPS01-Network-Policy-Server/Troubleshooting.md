---
Title: NPS01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/NPS01-Network-Policy-Server
Status: 🟢 LIVING — symptom→cause→fix for the RADIUS host. Seeded from the known traps; real incidents append here. Verify commands live in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-29
---

# NPS01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → likely cause → fix for the RADIUS member server. The checks that confirm a fix are in `Diagnostics.md`. **Never invent output** (`POL-0001`).

## Login rejected that should succeed
- **Symptom:** a valid admin is rejected by a device.
  - **Cause:** account not in the mapped AD group · a broad **deny** policy sits above the allow · NPS not registered in AD (can't read dial-in props) · time skew breaking Kerberos.
  - **Fix:** check NPS **event 6273** for the reason code; verify group membership; reorder policies (allow before the deny-all); confirm NPS01 ∈ **RAS and IAS Servers**; check `w32tm`.

## Login accepted that should fail
- **Symptom:** an unauthorized account gets device admin.
  - **Cause:** missing/last-position **deny-by-default**, or an over-broad allow condition.
  - **Fix:** add an explicit deny-all at the bottom; tighten the allow's group/condition; re-run the reject test (`Diagnostics.md` §4).

## No response from NPS at all
- **Symptom:** the device times out contacting RADIUS.
  - **Cause:** wrong **shared secret** (mismatch device↔NPS) · wrong client IP registered · firewall blocking **UDP 1812/1813** · NPS service (`IAS`) stopped.
  - **Fix:** re-set matching secrets (from Vaultwarden); confirm the client's source IP matches the RADIUS-client entry; permit 1812/1813; `Start-Service IAS`.

## Locked out of the network core
- **Symptom:** can't log into MKT01/SW01/1941 (NPS or DC down).
  - **Cause:** the two-host auth chain failed and break-glass wasn't in place/known.
  - **Fix:** use the **local break-glass** admin (Pass-1 standard) — this is *why* it exists; never remove it. Longer term: a 2nd NPS (`ADR-0029` review trigger).

## PEAP fails (cert-based auth)
- **Symptom:** PEAP/EAP-TLS negotiation fails though password RADIUS works.
  - **Cause:** no/expired **RAS-and-IAS-Server cert**, or the client doesn't trust the ICA01→RCA01 chain.
  - **Fix:** enrol/renew the cert from ICA01; distribute the RCA01 trust to the supplicant; `certutil -verify`. (Password RADIUS is the fallback until the cert lands.)

## Related
- `Diagnostics.md` (the checks that confirm the fix) · `Considerations.md` (why these traps exist) · Academy `Command-Library/PowerShell-Tier0.md` · `ADR-0029` · `../../Operations/Device-Hardening-Standard.md` (break-glass).

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded from NPS01's known traps (reject-should-succeed / accept-should-fail / no-response / locked-out-of-core / PEAP-cert), each symptom→cause→fix with the 6272/6273 events + break-glass. Real incidents append. |
