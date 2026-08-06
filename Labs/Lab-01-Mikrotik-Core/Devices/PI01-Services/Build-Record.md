---
Title: Pi01 Services Build Record
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services
---

# Pi01 Services Build Record

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified — FreeRADIUS reconciliation and secret rotation complete, Vaultwarden production-ready. Backup state and `STATIC-HOSTS` membership reconciled 2026-07-14 (`CM-0014`, `023`); re-confirm the ACL via DEVICE CHECK D1. |
| Version | 2.2 |
| Applies To | Atlas 2.0 |
| Last Live Verification | 2026-07-13 |
| Last Reconciled | 2026-07-13 (Network Source of Truth `006` — see Related Pages); backup state + `STATIC-HOSTS` membership reconciled 2026-07-14 |

## Purpose

Records the verified current state of the Raspberry Pi (Pi01) at 10.10.0.5, which hosts Pi-hole DNS filtering, FreeRADIUS, Vaultwarden, and the lab certificate authority.

## Platform

| Item | Value |
|---|---|
| Hostname | pihole (device: Pi01) |
| Management IP | 10.10.0.5 (VLAN 10) |
| Access | `ssh pihole` (`-p 2222`, user `dnsadmin`) |
| SW01 Port | Gi1/0/7 (Access, VLAN 10) — moved here this session; SW01 and SOT port tables updated to match |
| MAC | 00:00:5e:00:53:05 — **present in SW01 STATIC-HOSTS** (five-host ACL; confirmed live per `023`, 2026-07-13). See Note. |

> 🔴 **Note — corrected 2026-07-14.** An earlier version of this record asserted Pi01's MAC was absent from SW01's `STATIC-HOSTS` ARP access list. **That claim was false, and it was the origin of the "Pi01 should be unreachable" mystery that survived three handoffs.** `023` (corrected 2026-07-13) records the live ACL as **five** hosts with Pi01 (`10.10.0.5`) present; `006`, `012` and `016` (lesson 6) were reconciled to match. Charter Rule 13 — the device settled it. Operator: re-confirm with `show arp access-list STATIC-HOSTS` (DEVICE CHECK D1).

## Pi-hole

| Item | Value |
|---|---|
| Core version | v6.4.2 |
| Web version | v6.5 |
| FTL version | v6.6.2 |
| Config format | `pihole.toml` (v6 format — `setupVars.conf` does not exist in v6) |
| Config location | `/etc/pihole/` |
| DNSSEC | Enabled |
| Blocking | Enabled |
| TLS | Using its own certificate (`/etc/pihole/tls.crt`), issued by the lab CA |
| Boot | `pihole-FTL` enabled at boot |

### Upstream DNS Chain (verified)

```text
Pi-hole
  -> 127.0.0.1#5053  (dnscrypt-proxy DoH, primary)
  -> 1.1.1.1          (fallback)
  -> 1.0.0.1           (fallback)
```

Confirmed and now reflected in the Network Source of Truth (previously listed stale interim wording).

## FreeRADIUS

| Item | Value |
|---|---|
| Version | 3.2.7 |
| Status | Active, processing requests, enabled at boot |
| Config | `/etc/freeradius/3.0/clients.conf` |

### Configured Clients (confirmed 2026-07-13 — all secrets rotated, all addresses correct)

| Client name | IP | Status |
|---|---|---|
| laptop | 10.10.0.50 | Correct, secret rotated |
| fortigate | 10.10.0.254 | Correct, secret rotated; FortiGate-side confirmed working via a real `testing`/`password` login through the `Pi01-RADIUS` server entry |
| mikrotik | 10.10.0.1 | Correct, secret rotated; MikroTik-side RADIUS integration was found never to have actually been completed at all — built from scratch this session, see MKT01 Build Record and `043-PKI-and-Credential-Security-Overhaul-Session-Summary.md` |
| localhost | 127.0.0.1 | Default secret (`testing123`) replaced with a generated one, `require_message_authenticator` enabled (previously commented out, inconsistent with every other client) |
| localhost_ipv6 | ::1 | **Previously mislabeled in this Build Record as sharing `localhost`'s entry** — it's a separate block with its own default `testing123` secret. Corrected and rotated to its own distinct secret. |

Secrets are not reproduced in this document — generated fresh via Vaultwarden's password generator and stored there, labeled per client.

### `users` File — `testing` Account Removed (2026-07-13)

The `testing` account (username `testing`, password `password`, defined in `/etc/freeradius/3.0/users`) was originally created purely for validating the RADIUS integration during initial build. Once RADIUS became fully functional on both FGT01 and MKT01 this session, that same account became a real, working, publicly-documented credential capable of authenticating to network device admin logins — no longer a harmless diagnostic tool. Removed (commented out) and confirmed via `radtest`, which now correctly returns `Access-Reject`.

## 🟡 Divergence from ADR-0007 — Recorded, Not Fixed

**`ADR-0007` adopted the `atlas.lab` domain suffix. The infrastructure does not use it.**

Confirmed on the live-served certificates, 2026-07-13:

```text
issuer  = C=US, ST=California, O=Home Lab, OU=Home Lab CA, CN=Home Lab Intermediate CA
subject = CN=fortigate.lab
subject = CN=pihole.lab
```

The CA is branded **Home Lab**, not Atlas. Every device is `<device>.lab`, not `<device>.atlas.lab`.

**Deliberate decision, 2026-07-13: not fixing this.** Reissuing four certificates and the CA's own subject for a naming change is real work for a cosmetic gain, and every certificate is valid into 2027. **Recorded here so the divergence is known rather than silently discovered later.**

**Revisit when:** a certificate comes up for renewal anyway, or the CA is ever rebuilt. Not before.

*(Note: certificate subjects also embed `L=Redding` — worth knowing if this repository is ever made public.)*

## Vaultwarden

| Item | Value |
|---|---|
| Version | 1.36.0 |
| Deployment | Docker container, behind an nginx reverse proxy |
| Status | Production-ready — HTTPS live, admin token rotated, real vault entries created |
| Reachable at | `https://vault.lab:8443` — note the non-standard port; Pi-hole's own web server owns 443 on this host |
| Certificate | Lab CA-issued, `vault.lab`, SAN verified correct |
| First real vault entries | Lab CA Root and Intermediate CA passphrases, re-encrypted the same session |

See `034-Pi01-Vaultwarden-Build-Guide.md` for the full Phase 2 implementation detail, including the real port-conflict story.

## Lab Certificate Authority

| Item | Value |
|---|---|
| Root CA | `/etc/ssl/lab-ca/root/certs/root-ca.crt` |
| Intermediate CA | `/etc/ssl/lab-ca/intermediate/certs/intermediate-ca.crt` |
| Chain | `/etc/ssl/lab-ca/intermediate/certs/ca-chain.crt` |
| `copy_extensions` | **`copy` — added 2026-07-13.** Was missing from `[ CA_default ]` since the CA's original build, meaning every certificate issued before this date may be missing a proper SAN or have an incomplete one. Found and fixed during `MC-0002`. **CLOSED 2026-07-13 (evening): all live-served certificates verified directly.** MikroTik, FortiGate, and Pi-hole all serve correct SANs from `CN=Home Lab Intermediate CA`. FortiGate's predates the fix and was never affected — built via `-extfile`, which bypasses `copy_extensions` entirely. |

### Issued Certificates

| Device | Installed? |
|---|---|
| Pi-hole | **Yes — fixed 2026-07-13.** Was previously the factory self-signed certificate (`issuer=CN=pi.hole, O=Pi-hole, C=DE`); this Build Record incorrectly stated "in active use" from the original build through earlier this session. Real Lab CA certificate issued (`DNS:pihole.lab, DNS:pi.hole, IP:10.10.0.5`), combined with the intermediate chain and private key into a single PEM (`/etc/pihole/tls.pem` — Pi-hole's webserver requires cert+chain+key in one file, unlike every other device tonight which used separate cert/key files), and confirmed on the live-served connection. **Real mistake worth recording:** the first attempt at building this combined file used `cat` without `sudo` to read the private key, which failed silently with a permission error and produced a certificate-only file with no key — that broken file was copied into production before being caught. Rebuilt correctly with `sudo sh -c '...'` wrapping the entire pipeline. No backup of the previous `tls.pem` was taken before the first (broken) overwrite — a real process gap, not just a technical one. |
| MikroTik | Yes — installed and correctly reissued with verified SAN (`DNS:mikrotik.lab, IP:10.10.0.1`, serial `1001`) as of `MC-0002`, 2026-07-13. |
| FortiGate | Yes — installed via `MC-0001`, 2026-07-12. **SAN verified on the live-served connection 2026-07-13 (evening):** `DNS:fortigate.lab, IP:10.10.0.254, IP:172.16.0.1`, `issuer=CN=Home Lab Intermediate CA`, valid to 2027-06-20. **Issued 2026-06-20 — three weeks before the `copy_extensions` fix — and correct anyway**, because `-extfile` supplies extensions at signing time and never consults `copy_extensions`. |
| Vaultwarden | Yes — issued 2026-07-13, after the `copy_extensions` fix. SAN verified correct on the first attempt: `DNS:vault.lab, IP Address:10.10.0.5`. |

## Firewall (UFW)

| Item | Value |
|---|---|
| Status | **Active, as of 2026-07-13.** Previously inactive with zero rules configured — every port on this host was unfiltered until this session. |
| Default policy | Deny incoming (implicit via UFW's own default) |

### Rule Set

| Rule | Purpose |
|---|---|
| `from 10.10.0.0/24 to any port 2222 proto tcp` | SSH, VLAN 10 |
| `from 10.0.0.0/24 to any port 2222 proto tcp` | SSH, legacy flat network |
| `from 10.10.0.0/24 to any port 443 proto tcp` | Pi-hole dashboard HTTPS |
| `from 10.10.0.50 to any port 80 proto tcp` | Pi-hole dashboard HTTP, admin workstation only |
| `from 10.10.0.0/24 to any port 53` | DNS, VLAN 10 |
| `from 10.0.0.0/24 to any port 53` | DNS, legacy flat network |
| `from 10.10.0.254 to any port 1812/1813 proto udp` | FreeRADIUS, FGT01 |
| `from 10.10.0.1 to any port 1812/1813 proto udp` | FreeRADIUS, MKT01 |
| `from 10.10.0.50 to any port 1812/1813 proto udp` | FreeRADIUS, admin workstation |
| `from 10.10.0.50 to any port 8443 proto tcp` | Vaultwarden, admin workstation only |

**Process note worth keeping on record:** before enabling, the full rule set was built and reviewed while UFW was still inactive (safe — no rule takes effect until enabled), then verified via `ufw show added`, then enabled with a fresh SSH connection tested in a separate window *before* closing the original session — specifically to guarantee an immediate rollback path (`sudo ufw disable`) was available if the new ruleset had locked out access. No lockout occurred.

> 🔴 **CORRECTED 2026-07-13 (evening). `pi01-full-backup-2026-07-12.tar.gz` no longer exists and was never a valid recovery point.**
>
> It was taken *before* the `043` Part 9 passphrase rotation, so its CA keys were wrapped in the **old, exposed** passphrase. `tar -tzf` also confirmed it contained **both `.bak-2026-07-12` key copies** — four copies of the CA private keys in total, all openable with a credential that had leaked. **It could not save you, and it could hurt you.** Destroyed after its replacement was proven.
>
> **The current recovery artefact is `atlas-pi01-2026-07-14.tar.gz.gpg`** — AES256-encrypted under a rotated, paper-only passphrase, **restore-proven on 2026-07-14 by decrypting it and listing `intermediate-ca.key`** (`CM-0014`), and hash-verified on `E:\`.
>
> 🔴 **The earlier `atlas-pi01-2026-07-13.tar.gz.gpg` was sealed with the leaked, never-rotated passphrase and was `shred -u`'d on both Pi01 and `E:\` on 2026-07-14. It is not a recovery point — do not rely on it.** Its "restore-tested" status referred to that superseded file.
>
> 🔴 **There is NO copy outside this room: both current copies (Pi01, `E:\`) are in the same room. Roadmap Critical Risk #1 is NOT yet mitigated — `049` Phase 5 is the ten-minute fix.**
>
> **Procedure: `049-Root-CA-and-Credential-Backup-Runbook.md` v2.0. Records: `CM-0010`.**

**Current backup state — verified 2026-07-14 (`CM-0014`):**

| Item | Value |
|---|---|
| Archive | `atlas-pi01-2026-07-14.tar.gz.gpg` (the `2026-07-13` archive was destroyed 2026-07-14 — leaked passphrase, `CM-0014`) |
| Covers | `/etc/ssl/lab-ca` (whole tree, incl. `index.txt`/`serial`/`crlnumber`/`openssl.cnf`), `~/vaultwarden/data`, `/etc/pihole/pihole.toml`, **`/etc/freeradius/3.0/clients.conf`**, nginx site, container env |
| Restore-tested | ✅ Yes — this is what makes it a backup |
| Copies | Pi01, `E:\` (hash-verified) — 🔴 **both in the same room; NO copy outside this room exists** (`049` Phase 5 pending) |
| Passphrases | **Paper only** (rotated 2026-07-14, `CM-0014`) — deliberately **not** in Vaultwarden, per `049` Phase 1. *(The Root/Intermediate CA key passphrases are separately held in Vaultwarden; the GPG archive passphrase is not.)* |

> **`docker stop` before archiving is mandatory.** Vaultwarden's SQLite runs in **WAL mode** — recent vault writes live in `db.sqlite3-wal`, not `db.sqlite3`. Archiving a running container captures a vault that predates your latest changes. See `049`.

## Known Deviations from Target Design

| Item | Target | Current Reality | Action |
|---|---|---|---|
| Base OS | Confirmed and documented | **Resolved 2026-07-13 — Debian 13 ("Trixie").** Confirmed via two independent pieces of evidence already in hand rather than a fresh `/etc/os-release` check: the `dig` version banner seen throughout this session's DNS work (`DiG 9.20.23-1~deb13u1-Debian`), and the `DietPi_RPi234-ARMv8-Trixie.img.xz` image found among the original build files — "Trixie" is Debian 13's actual codename, matching exactly. | Closed |
| Pi-hole certificate | Lab CA-issued, in use | **Resolved 2026-07-13** — see Lab Certificate Authority section above | Closed |
| Pi-hole / FortiGate certificate SAN correctness | Verified directly | **Resolved 2026-07-13.** FortiGate confirmed already correct (`DNS:fortigate.lab, IP:10.10.0.254, IP:172.16.0.1`) — built via an older `-extfile` method predating the `copy_extensions` gap, so it was never actually affected. Pi-hole was genuinely wrong (factory cert) and has been fixed. | Closed |
| `fortigate.lab` DNS record | Exists, matching the certificate's SAN | **Does not exist** — FGT01 has no Pi-hole DNS record at all, unlike every other device. Not currently causing a problem since FGT01 is reached by IP, which the certificate does cover. | Add for consistency, low priority |
| Vaultwarden UFW scoping | Restricted to specific devices/subnets | **Resolved 2026-07-13** — full UFW baseline built and enabled on Pi01 (SSH, DNS, Pi-hole dashboard, FreeRADIUS per-client, Vaultwarden all scoped appropriately), verified via a fresh connection test before trusting it. Port `8443` specifically restricted to the admin workstation only. | Closed |
| MikroTik DNS resolution | Points to Pi-hole with fallback | **Resolved 2026-07-13** — `/ip dns set servers=10.10.0.5,1.1.1.1,8.8.8.8`. Confirmed via `:put [:resolve mikrotik.lab]` returning the correct local answer, proving MikroTik is actually querying Pi-hole, not just falling through to public DNS. | Closed |

## Access Methods

| Method | Address | Notes |
|---|---|---|
| SSH | `ssh pihole` (10.10.0.5, port 2222, user dnsadmin) | Primary access |

## Validation

`dnsadmin` was not in the `pihole` group, causing permission errors on `pihole -v` and related commands (`/etc/pihole/versions` owned `pihole:pihole`, mode 640). Fixed via `sudo usermod -aG pihole dnsadmin`; confirmed working after re-login.

## Related Pages

- Network Source of Truth (`006-Network-Source-of-Truth.md`) — DNS deviation and SW01 port table updated to match this record
- SW01 Build Record (`023-SW01-Build-Record.md`) — Gi1/0/7 addition reflected there
- FGT01 Build Record — needs update once FortiGate certificate is installed
- Build Guides: `030-Pi01-Base-System-Build-Guide.md`, `031-Pi01-Lab-CA-Build-Guide.md`, `032-Pi-hole-DNS-Build-Guide.md`, `033-Pi01-FreeRADIUS-Build-Guide.md`, `034-Pi01-Vaultwarden-Build-Guide.md`

## Revision History

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-11 | Initial Build Record created from live Pi verification |
| 2.2 | 2026-07-14 | Reconciliation batch (051 Tier 3, B12–B14). Corrected the false STATIC-HOSTS-absence claim (Pi01 **is** in the five-host ACL per `023`); replaced the destroyed `2026-07-13` archive reference with the restore-proven `2026-07-14` archive (`CM-0014`) and removed the false off-site-copy claim (no copy outside the room exists — `049` Phase 5 pending); archive passphrase corrected to paper-only. *(v2.0/2.1 predate a recorded revision history; entries reconstructed from the change log going forward.)* |
