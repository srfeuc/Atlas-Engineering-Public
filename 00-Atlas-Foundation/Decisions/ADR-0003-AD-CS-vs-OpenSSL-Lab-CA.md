# ADR-0003 — AD CS vs. the Existing OpenSSL Lab CA: Coexist or Replace

| Item | Value |
|---|---|
| Status | Accepted |
| Governing Policy | POL-0007 |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-12 |

## Context

A working two-tier OpenSSL CA already exists on Pi01 (`Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md`), issuing certificates to Pi-hole (in active use), MikroTik, and FortiGate. Book 4 (Identity and PKI) plans a Windows-native AD CS two-tier PKI, architecturally identical in pattern (offline root, online issuing CA), just built with different tooling. This raises a real design question before Book 4 implementation starts.

## Alternatives Considered

1. **Coexist.** OpenSSL Lab CA continues serving non-Windows infrastructure (Pi-hole, MikroTik, FortiGate, SW01 if it ever needs TLS). AD CS serves only domain-joined Windows resources, where it earns its keep specifically (autoenrollment, NPS integration, future smart cards — none of which apply to non-domain devices regardless of which CA issues their certs).
2. **Replace.** Stand up AD CS as the single lab-wide CA; reissue MikroTik/Pi-hole/FortiGate certs from it instead of OpenSSL. More closely mirrors how many real single-PKI shops operate.

## Decision

**Coexist (Option 1).** Confirmed 2026-07-12 — the FortiGate certificate installation (CM-0005) uses the Pi01 OpenSSL Lab CA, not a future AD CS certificate, resolving what had been an open question about which CA FGT01 should actually use.

## Rationale

Two CAs for two genuinely different trust domains (Windows-integrated identity vs. everything else) is a legitimate, defensible pattern — not a compromise. Replacing already-working, already-validated infrastructure (the OpenSSL Lab CA is live and in active use by Pi-hole today) to satisfy a "one PKI" aesthetic isn't worth the rework, and doesn't teach anything additional that building AD CS standalone wouldn't already teach.

## Consequences

- Book 4's AD CS implementation should be scoped to domain-joined resources only.
- The OpenSSL Lab CA Build Guide/Record continue to be maintained independently, not deprecated.
- If this decision is later reversed, MikroTik/FortiGate/Pi-hole certificate reissuance becomes a real, scoped project, not a side effect of "just switching."

## Review Trigger

Revisit if a real use case emerges that only a single unified PKI can satisfy (e.g., a compliance requirement, or genuine operational pain from running two CAs).
