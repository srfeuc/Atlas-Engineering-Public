---
Title: Pi01 Considerations and Risks
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services
---

# Pi01 Considerations and Risks

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 0.1 |
| Applies To | Pi01 (10.10.0.5 — Pi-hole / Lab CA / FreeRADIUS / Vaultwarden) |
| Last Reviewed | 2026-07-16 |

## Purpose

What could bite you on Pi01 — design risks, weak spots, and unverified assumptions — each with a way to check it. Read before you trust, rebuild, or harden this device. Complements `038` (Troubleshooting, reactive) and `046` (CIS, hardening posture).

## How to read this

- 🟩 **Recommendation** — best practice to adopt; makes it better/safer.
- 🟨 **Hole** — unverified assumption or weak spot; run the check to settle it.
- 🟥 **Device-gated** — confirmed issue whose fix needs a live device read/write (usually a change record). Not fixable by editing docs.

**Verify, don't assume.** Run the command in each row; don't trust the status column (Rule 13).

## Considerations & Risks

| # | Consideration / Risk | Type | How to verify | Current status | Ref |
|---|---|---|---|---|---|
| 1 | **CA database is 2-of-6 blind.** `index.txt` has 4 rows but the CA signed 6 trusted certs — FGT01's and Pi-hole's original were signed with `openssl x509 -req -extfile`, which writes no row. `ADR-0009`'s only compromise-detection control is degraded, and its Review Trigger fires on legitimate FGT01. | 🟥 Device-gated | `sudo cat /etc/ssl/lab-ca/intermediate/index.txt` (4 rows) ; `sudo ls /etc/ssl/lab-ca/issued/*/ \| grep '\.ext'` (the `-extfile` tell) | **Confirmed open 2026-07-16.** Fix = reconstruct `index.txt` + amend `ADR-0009`. | `CM-0032`, `ADR-0009` |
| 2 | **Pi-hole rebuild reads a stale cert.** `issued/pihole/pihole.crt` carries pre-VLAN `IP:10.0.0.5`; the wire serves correct `1003`/`10.10.0.5`. `032` Step 7 rebuilds `tls.pem` from that stale file → a rebuild serves a name-mismatched cert on the DNS server. | 🟥 Device-gated | `diff <(openssl s_client -connect 10.10.0.5:443 </dev/null 2>/dev/null \| openssl x509 -noout -serial) <(sudo openssl x509 -in /etc/ssl/lab-ca/issued/pihole/pihole.crt -noout -serial)` → must be empty | **Confirmed open 2026-07-16** (differs). Fix = write serial 1003 into `issued/`. | `CM-0032`, `032` |
| 3 | **Revocation does not work in this CA.** No cert carries a CRL Distribution Point; no CRL is served. `openssl ca -revoke` updates `index.txt` and reaches no client — serial 1000 is revoked and still trusted everywhere. | 🟥 Device-gated | `grep -rc crlDistributionPoints /etc/ssl/lab-ca/` → 0 | **Confirmed** — bookkeeping only. Real fix needs a CDP + reissue-all. | `031` v0.7, `042`, `ADR-0009` |
| 4 | **No NTP server anywhere in Atlas.** Pi01's clock is kept by `systemd-timesyncd` (SNTP **client**) to `debian.pool.ntp.org` — it serves NO NTP. SW01 is pointed at `10.10.0.5` as a server and gets nothing (stratum 16). | 🟥 Device-gated | `systemctl is-active systemd-timesyncd` (active) ; `sudo ss -ulnp \| grep ':123 '` (no listener) | **Confirmed 2026-07-16.** `046` §2.3 corrected same day. | `CM-0030` |
| 5 | **SSH login banner absent.** `030` §4 specifies a `/etc/issue.net` banner; the live host has `banner none`. | 🟨 Hole | `sudo sshd -T \| grep -i '^banner '` → `banner none` | **Confirmed absent 2026-07-16.** Low priority; add to close. | `030`, `046` §1.6 |
| 6 | **`localhost_ipv6` may lack `require_message_authenticator`.** BlastRADIUS mitigation is confirmed on the four other client blocks; the `::1` block did not visibly show it. Loopback-only, low risk. | 🟨 Hole | `sudo awk '/client localhost_ipv6/{f=1} f&&/require_message_authenticator/{print; f=0}' /etc/freeradius/3.0/clients.conf` | **Unconfirmed.** | `033` |
| 7 | **Pi-hole updates available.** core 6.4.2→6.4.3, web 6.5→6.6, FTL 6.6.2→6.7. No documented patch cadence for this host. | 🟨 Hole | `pihole -v` | Updates pending; `046` §7 patch cadence unverified. | `046` §7 |
| 8 | **No off-site backup copy.** The current recovery archive and its `E:\` copy are in the same room; `049` Phase 5 (off-site) is pending. Roadmap Critical Risk #1. | 🟨 Hole | *(process, not a device read)* — confirm a third copy exists off-site | Open — `049` Phase 5 pending. | `029`, `049` |
| 9 | **`tls.pem` and the combined bundles contain the private key.** Any `.bak` of them is live key material — destroy after the new one verifies (`shred -u`). | 🟩 Recommendation | `sudo ls -la /etc/pihole/tls.pem*` → no lingering `.bak` | Habit, not a defect. | `CM-0010`, `032` |
| 10 | **Pi-hole owns 80/443 on this host** — a permanent constraint. Any future reverse-proxied service here needs a non-standard port (Vaultwarden uses 8443). | 🟩 Recommendation | `sudo ss -tlnp \| grep -E ':80 \|:443 '` → pihole-FTL | By design. | `032`, `034` |

## Open holes — summary (most consequential first)

1. **CM‑0032 (rows 1–2)** — the CA's detection control is blind and a Pi-hole rebuild serves the wrong cert. Device-write remediation queued.
2. **No NTP server (row 4)** — blocks anything that depends on Atlas time (Book 5 monitoring, SW01's clock). Needs a real NTP server decision.
3. **Revocation is decorative (row 3)** — acceptable for a home lab per `ADR-0009`, but know it before relying on it.
4. **No off-site backup (row 8)** — ten-minute fix still pending.

## For the next build (Device Role Plan / Service Architecture)

Do these right from the start so the holes never exist:

- **Always sign with `openssl ca`, never `openssl x509 -req -extfile`** — so `index.txt` stays a complete record and revocation/detection actually works.
- **Decide revocation up front:** if you want it, set `crlDistributionPoints` and serve a CRL *before* issuing any cert (a CDP can't be added later).
- **Write every issued cert into `issued/<device>/`** — the tree rebuilds read from; `newcerts/` is not that.
- **Stand up one real NTP server** for the lab and point everything at it — don't let a client-only host masquerade as a server.
- **Off-site backup is part of "done,"** not a follow-up.
- **Separate the reverse-proxy host from Pi-hole** so services aren't forced onto non-standard ports by the 80/443 conflict.

## Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-16 | Created from the 2026-07-16 live Pi01 verification run. Seeds the CM‑0032 / CM‑0030 device-gated items and the SSH-banner / patch-cadence / off-site-backup holes. |

## Related pages

- **Verification Procedure: `052-Pi01-Verification-Procedure.md`**
- Build Record: `029` · Build Guides: `030`–`034` · Troubleshooting: `038` · CIS: `046`
- Change records: `CM-0032`, `CM-0030`, `CM-0010`
