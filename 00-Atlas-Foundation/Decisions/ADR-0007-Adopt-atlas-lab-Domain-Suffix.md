---
Title: ADR-0007 — Adopt atlas.lab as the Consistent Internal Domain Suffix
Path: Atlas Foundation/Decisions
---

# ADR-0007 — Adopt `atlas.lab` as the Consistent Internal Domain Suffix

| Item | Value |
|---|---|
| Status | Proposed — captured mid-session, not yet scheduled |
| Governing Policy | POL-0008 |
| Scope | **Global** — estate-wide principle (applies across labs) |
| Date | 2026-07-13 |

> ## 🟡 Implementation Status — NOT IMPLEMENTED (2026-07-13)
>
> **This decision is committed. The infrastructure has never heard of it.**
>
> Verified on the live-served certificates:
>
> ```text
> issuer  = O=Home Lab, OU=Home Lab CA, CN=Home Lab Intermediate CA
> subject = CN=fortigate.lab
> subject = CN=pihole.lab
> ```
>
> Every device is `<device>.lab`. The CA itself is branded **Home Lab**, not Atlas.
>
> **Deliberate decision, 2026-07-13: not implementing now.** Reissuing four certificates and re-subjecting the CA for a naming change is real work for a cosmetic gain. All certificates are valid into 2027.
>
> **Revisit when a certificate comes up for renewal anyway, or the CA is rebuilt. Not before.**
>
> **The decision stands. Only the schedule changed.** Recorded here so the next person does not assume `atlas.lab` resolves — it does not.

## Context

Current Lab CA certificates use bare `.lab` names per device (`mikrotik.lab`, `pihole.lab`, `vault.lab`, and `fortigate.lab` on the certificate SAN) with no consistent project-level namespace.

Raised while mid-fixing a separate CA configuration bug (missing `copy_extensions`). Worth adopting `atlas.lab` as the root domain for every internal certificate and matching DNS record going forward, so names are self-explanatory as belonging to *this project* rather than following a generic homelab convention.

## Alternatives Considered

**Keep bare `.lab` names as-is.** No work required, but doesn't tie naming to the Atlas project, and the current inconsistency stays unaddressed.

**Adopt `<device>.atlas.lab` for every device**, retroactively reissuing every existing certificate and updating every matching Pi-hole DNS record. **Chosen, not yet scheduled.**

## Decision

Adopt `<device>.atlas.lab` (e.g. `mikrotik.atlas.lab`, `pihole.atlas.lab`, `fortigate.atlas.lab`) as the standard going forward.

**Not implemented yet.** This is a real, multi-device project of its own, not a quick edit.

## Rationale

Deferred implementation specifically because the session in which it surfaced was already mid-fix on a CA-wide configuration bug (`copy_extensions` missing, causing every certificate issued under `server_cert` to potentially lack a SAN). Combining a naming-scheme redesign with an active emergency config fix risks doing both poorly.

Per the Charter's "no rabbit holes" rule (Locked Rule 10) and the session's own established pattern: a good idea surfacing mid-task gets written down, not executed mid-task.

## Consequences

- Every currently-issued certificate (Pi-hole, FortiGate, MikroTik, Vaultwarden) will eventually need reissuing again under the new naming. **Batch this as one deliberate pass once decided** — not piecemeal, certificate by certificate.
- Matching Pi-hole DNS records need updating in the same pass. **These live in the embedded `hosts` array inside `/etc/pihole/pihole.toml` — not in `custom.list`.** On Pi-hole v6, `custom.list` is inert for this purpose; editing it has no effect on resolution. See `038-Pi01-Troubleshooting-Guide.md` and `043` Part 5, where this cost real diagnostic time.
- Each reissue is a full reissue, not an edit — new CSR with the corrected SAN, new serial, and the old certificate revoked first if the CA database still holds a valid entry for that identity. See `042-Certificate-Reissuance-and-Renewal-Guide.md`.
- The CA config fix that prompted this ADR proceeded under the current naming (`mikrotik.lab`). Correct call — don't block an active fix on a deferred decision.

## Review Trigger

Revisit once the CA config bug is fully resolved and the MikroTik certificate is confirmed working. Treat the `atlas.lab` migration as its own scheduled piece of work, likely paired with the Foundation-reconciliation work already planned.

## Note on This Record's History

This ADR was referenced by number in `043-PKI-and-Credential-Security-Overhaul-Session-Summary.md`, the Pack Manifest, and the session handoff — but the file itself was never written. Created 2026-07-13 from the decision as recorded, with the `custom.list` reference corrected to `pihole.toml`.
