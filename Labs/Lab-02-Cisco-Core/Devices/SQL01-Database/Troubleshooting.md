---
Title: SQL01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/SQL01-Database
Status: 🟢 LIVING — symptom→cause→fix for SQL Server. Seeded from the known traps; real incidents append. Verify commands in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-30
---

# SQL01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → cause → fix. **Never invent output** (`POL-0001`).

## Auth / gMSA
- **Symptom:** the SQL service won't start under the gMSA, or Windows-auth logins fail with Kerberos errors.
  - **Cause:** `Test-ADServiceAccount` False (retrieval not granted / not installed on SQL01), or a **missing/duplicate SPN** (`MSSQLSvc/sql01.atlas.lab:1433`).
  - **Fix:** re-grant + `Install-ADServiceAccount`; set/verify the SPN on the gMSA (`setspn -L`); no duplicate SPNs (they break Kerberos → NTLM fallback → Protected-Users issues).

## TLS
- **Symptom:** clients can't connect with encryption / cert not trusted.
  - **Cause:** no ICA01 cert bound, wrong cert (not Server-Auth / wrong subject), or the client doesn't trust the ICA01→RCA01 chain.
  - **Fix:** enrol the Server-Auth cert; bind it in SQL Config Manager + Force Encryption; distribute the RCA01 trust; `certutil -verify`.

## Connectivity
- **Symptom:** an app can't reach SQL.
  - **Cause:** TCP 1433 blocked by the host firewall, SQL Browser off (named instance), or the E-W matrix denies the source.
  - **Fix:** confirm 1433 (or the named-instance port) permitted from that source; `Test-NetConnection sql01 -Port 1433`; check the E-W matrix flow.

## Performance / stability
- **Symptom:** SQL starves the host / the R410 thrashes.
  - **Cause:** no **max-server-memory cap** — SQL takes everything.
  - **Fix:** set a memory cap sized to leave the host + other VMs headroom (a key #20 capacity input). Operator's "slow is OK, don't break" → cap conservatively.

## Backups
- **Symptom:** can't recover a DB.
  - **Cause:** backups ran but a **restore was never tested** (or the copy to BKP01 failed).
  - **Fix:** test-restore regularly (`POL-0005`); verify the BKP01 copy job; a backup you can't restore isn't a backup.

## Related
- `Diagnostics.md` · `Considerations.md` · `Build-Guide.md` · Tier-A A1 (gMSA) · `ADR-0046` (AG) · Academy `Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded from SQL traps (gMSA/SPN, TLS cert/trust, 1433/firewall/E-W, no-memory-cap starvation, untested-restore). Real incidents append. |
