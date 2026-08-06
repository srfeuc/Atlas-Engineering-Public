---
Title: WAC01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/WAC01-Windows-Admin-Center
Status: 🟢 LIVING — symptom→cause→fix for the WAC gateway. Seeded from the known traps; real incidents append. Verify commands in `Diagnostics.md`.
Version: 0.1
Date: 2026-07-30
---

# WAC01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built).** Symptom → cause → fix. **Never invent output** (`POL-0001`).

## Gateway TLS
- **Symptom:** the console shows a certificate name/trust warning.
  - **Cause:** WAC still on its self-signed cert, wrong **SAN**, or PAW01 doesn't trust the ICA01 chain.
  - **Fix:** bind the **ICA01** cert with the correct SAN (the URL PAW uses); ensure the root/issuing chain is AD-distributed and the CRL is reachable (`ADR-0027`).

## Access / lockdown
- **Symptom:** a non-PAW host can reach the WAC console (or PAW can't).
  - **Cause:** the 443 ACL isn't scoped to PAW01, or the WAC access roles aren't keyed to the Tier-0 group.
  - **Fix:** set gateway admin/user to the **Tier-0 AD group**; ACL **443 → WAC01 only from PAW01** (deny+log); re-run the negative test. WAC is Tier-0 — never broadly exposed (`ADR-0021`).

## Managing a node fails
- **Symptom:** "can't connect" / WinRM errors adding or using a managed node.
  - **Cause:** WinRM not enabled/reachable, TrustedHosts, or a delegation/double-hop issue.
  - **Fix:** `Test-NetConnection <node> -Port 5985/5986`; `Enable-PSRemoting` on the target; prefer **Kerberos** (resource-based constrained delegation) over **CredSSP** — unconstrained CredSSP is a Tier-0 credential-theft risk, avoid it.

## Wrong VLAN / unreachable
- **Symptom:** WAC unreachable from PAW, or reachable from places it shouldn't be.
  - **Cause:** placed on the wrong VLAN, or the management-plane flow isn't scoped.
  - **Fix:** WAC is a Tier-0 admin surface → **VLAN 10 (management)** (operator 2026-07-30); confirm flows-matrix flow #1/#16 scope PAW→WAC 443 + WAC→estate WinRM, deny the rest.

## Related
- `Diagnostics.md` · `Considerations.md` · `Build-Guide.md` · `ADR-0027` (ICA01 TLS) · `ADR-0021` (tiering) · `ADR-0045` (this host) · Academy `Command-Library/PowerShell-Tier0.md`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-30. Seeded from WAC traps (gateway TLS SAN/trust, PAW-only access lockdown, WinRM/delegation node-management, wrong-VLAN reachability). Real incidents append. |
