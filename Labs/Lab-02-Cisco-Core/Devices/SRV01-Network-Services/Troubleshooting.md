---
Title: SRV01 — Troubleshooting (symptom → cause → fix)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services
Status: 🟡 Seeded — expected failure modes; fill with real incidents as the build runs.
Version: 0.1
Date: 2026-07-29
---

# SRV01 — Troubleshooting

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** Symptom → cause → fix for the network-services host. Service-specific issues also live in `Roles/<svc>/`.

| Symptom | Likely cause | Fix / check |
|---|---|---|
| CRL fetch 404 / wrong content-type | nginx web root or **media types (RFC 2585)** misconfigured | Build-Guide §3.2; `.crl`=`application/pkix-crl`; `curl -I` |
| Relying parties can't reach `pki.atlas.lab` | DNS A-record missing, port 80 blocked, or SRV01 down | add the DC01 A-record; role firewall; **PKI-grade availability** |
| Clone has the template's identity | cloud-init didn't regenerate (machine-id/SSH host keys) | the `220` §1.3 check; regenerate; **never ship the template identity** |
| Oxidized pulls fail | device creds wrong/over-privileged, or device unreachable | read-only accounts (vaulted); test SSH to the device |
| Secret found in the config repo | creds committed to git | `gitleaks`; rotate; vault the creds (`POL-0002`) |
| Logs not arriving at MON01 | rsyslog relay target/port, or MON01 collector down | check the `rsyslog` role; confirm MON01 listening |

## Related
- `Build-Guide.md` · `Diagnostics.md` · `Considerations.md` · `Roles/`.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded with expected SRV01 failure modes (CRL content-type/404, DNS/availability, clone identity, Oxidized creds, git secrets, rsyslog). |
