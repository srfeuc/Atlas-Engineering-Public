# CM-0007 — Install Lab CA Certificate on MikroTik www-ssl

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | **SUPERSEDED by MC-0002 / CM-0008** |
| Risk | Low |
| Affected systems | MKT01, Pi01 |
| Superseded | 2026-07-13 |

> ## The install worked. The certificate was wrong. Do not close this.
>
> This record's plan was **executed and succeeded** — RouterOS parsed the bundle into three trusted objects and served the chain correctly.
>
> **And the certificate was still wrong.** Its SAN listed `10.0.0.1` and `172.31.4.144` — both stale, pre-VLAN-migration addresses. The browser reported *"this server could not prove that it is 10.10.0.1."*
>
> **The install was perfect. The certificate's own data was out of date.** Those are different failures, and this record only covers the first.

## What actually closed it

**`CM-0008`** — reissue with a corrected SAN.
**`MC-0002`** — which is where it got serious.

Reissuing "one certificate with a corrected SAN" **uncovered a defect in the Lab CA that had been present since the day it was built:**

- The reissued certificate signed cleanly. **The SAN was completely empty** — not stale, *missing*.
- Root cause: **`copy_extensions` was not set** anywhere in `[ CA_default ]`. OpenSSL **silently discards** any SAN requested via `-addext` without it.
- **Which meant the defect was not new.** *Every certificate this CA had ever issued may have been affected.*
- The fix landed in the **wrong config section** on the first attempt (`[ ca ]` instead of `[ CA_default ]`).
- Reissue then failed with `There is already a certificate for .../CN=mikrotik.lab` — **the broken, SAN-less certificate had been issued successfully and was sitting in the CA database as valid.** Revoke first, then reissue.
- Final: **serial `1001`**, SAN verified `DNS:mikrotik.lab, IP:10.10.0.1`, confirmed **on the live-served connection**, not just on the file.

## Current live state

Certificate confirmed serving: `issuer=CN=Home Lab Intermediate CA`, object `mikrotik-bundle.crt_0`, serial `1001`.

> **The revocation of serial `1000` is decorative.**
>
> `031-Pi01-Lab-CA-Build-Guide.md` contains **no CRL Distribution Point** configuration. Issued certificates carry no CDP extension, and no CRL is served over HTTP. **Nothing will ever fetch it.**
>
> Serial `1000` was revoked and the CRL regenerated — and **no client in the lab will ever know.** If someone held that certificate and key, it would still be trusted.
>
> Verify:
> ```bash
> openssl x509 -in /etc/ssl/lab-ca/issued/mikrotik/mikrotik.crt -noout -text \
>   | grep -A2 "X509v3 CRL Distribution Points"
> ```
> **Expect nothing.** If it is empty, revocation in this CA is a filing action, not a security control.

## Closeout

- [x] **Superseded by MC-0002 / CM-0008**
- [x] Certificate live and SAN-verified (serial `1001`)
- [ ] ~~Closed~~ — **do not close.** The plan in this record produced a working install of a *wrong certificate*. That is the lesson.

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Raised 2026-07-12. |
| 1.1 | **Status Draft → Superseded.** The certificate is live, but via CM-0008/MC-0002. Closing this record would assert that a clean install of a stale-SAN certificate was a success — when the whole point is that **a perfect install of a wrong certificate looks exactly like a perfect install.** Added the CRL finding: the revocation this change chain performed reaches no client. |
