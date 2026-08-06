---
Title: Pi-hole DNS Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/PiHole-DNS
---

# Pi-hole DNS Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: PiHole-DNS

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Verified |
| Evidence Source | Live validation 2026-07-11 and 2026-07-13 |
| Last Verified | 2026-07-13 |
| Version | 0.3 |
| Applies To | Pi01 (Pi-hole v6.4.2) |

## Purpose

Build Pi-hole as the lab's DNS filtering forwarder, layered with DNSSEC validation and DNS-over-HTTPS (via `dnscrypt-proxy`) so DNS is filtered, authenticated, and private.

Interim DNS design until Windows Server AD DNS is deployed (Book 3).

## Design Philosophy

Three layers, each addressing a different threat:

| Layer | Technology | Threat Addressed |
|---|---|---|
| 1 — Filtering | Pi-hole blocklists | Ads, trackers, known-malicious domains |
| 2 — Integrity | DNSSEC | Forged/tampered DNS responses (cache poisoning) |
| 3 — Privacy | DNS-over-HTTPS (dnscrypt-proxy) | ISP/network observers seeing which domains are queried |

Query path:

```text
lab device
  -> Pi-hole            10.10.0.5
  -> dnscrypt-proxy     127.0.0.1:5053  (localhost only)
  -> Cloudflare DoH     1.1.1.1
  -> DNSSEC-validated response back through the chain
```

## Prerequisites

- Base system build complete (`030-Pi01-Base-System-Build-Guide.md`)
- Lab CA built (`031-Pi01-Lab-CA-Build-Guide.md`), with a `pihole` certificate issued — needed for the HTTPS admin dashboard

## 1. Install Pi-hole

```bash
curl -sSL https://install.pi-hole.net | bash
```

Follow the installer prompts. Set the upstream DNS temporarily to any public resolver — this gets replaced in Step 4.

## 2. Install and Configure dnscrypt-proxy

```bash
sudo apt install dnscrypt-proxy -y
```

Edit `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`:

```toml
listen_addresses = ['127.0.0.1:5053']   # localhost only — Pi-hole owns port 53
server_names = ['cloudflare']
ipv6_servers = false                     # IPv6 disabled on this Pi
```

> **Why not `cloudflared`?** Cloudflare **removed the DNS proxy feature from `cloudflared` in version 2026.2.0.** This is not a misconfiguration — the feature was discontinued. `dnscrypt-proxy` is actively maintained and supports DoH/DNSCrypt/DoT.

## 3. Fix the Socket Activation Conflict

The Debian `dnscrypt-proxy` package uses systemd socket activation **hardcoded to `127.0.2.1:53`**, which conflicts with the port 5053 config above.

> 🟡 **Do not try to fix this with a systemd drop-in override on `dnscrypt-proxy.service`.** The `Requires=dnscrypt-proxy.socket` directive cannot be overridden that way once the socket is active. Mask the socket and run a standalone unit instead — a new unit is the clean fix, not a patch on the packaged one.

```bash
sudo systemctl mask dnscrypt-proxy.socket
```

Create `/etc/systemd/system/dnscrypt-proxy-doh.service`:

```ini
[Unit]
Description=DNSCrypt-proxy DoH for Pi-hole
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=_dnscrypt-proxy
ExecStart=/usr/sbin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable dnscrypt-proxy-doh
sudo systemctl start dnscrypt-proxy-doh
```

## 4. Point Pi-hole at dnscrypt-proxy

Pi-hole dashboard → Settings → DNS → uncheck all existing upstreams → Custom DNS (IPv4): `127.0.0.1#5053` → Save.

```bash
sudo systemctl restart pihole-FTL
```

## 5. Enable DNSSEC

Pi-hole dashboard → Settings → DNS → Advanced DNS settings → check **Use DNSSEC** → Save.

```bash
sudo systemctl restart pihole-FTL
```

## 6. Add Local DNS Records

> 🔴 **Do not edit `/etc/pihole/custom.list`. It does nothing.**
>
> On Pi-hole v6, local DNS records are read from an embedded `hosts` array inside **`/etc/pihole/pihole.toml`**. `custom.list` is **inert** for this purpose.
>
> You can edit it, confirm the edit looks correct, restart `pihole-FTL`, and `dig` will still return the old answer — with no error anywhere. **This cost real diagnostic time, and it is how three stale records survived unnoticed** (`mikrotik.lab`, `pihole.lab` pointing at its own pre-VLAN address, and `proxmox.lab` pointing at an address that was never PVE01's).
>
> The previous version of this guide instructed editing `custom.list`.

```bash
sudo nano /etc/pihole/pihole.toml
```

Find the `hosts` array. This is **TOML array syntax** — the quotes and the trailing comma matter, or the file becomes invalid:

```text
"10.10.0.5 pihole.lab",
"10.10.0.5 pi.hole",
"10.10.0.5 vault.lab",
"10.10.0.1 mikrotik.lab",
"10.10.0.10 proxmox.lab",
```

```bash
sudo systemctl restart pihole-FTL
dig pihole.lab @10.10.0.5 +noall +answer
```

> **Verify with `dig`, not by re-reading the file.** A correct-looking edit in the wrong file is exactly the failure mode this warning exists for.

> 🟡 **`fortigate.lab` has no DNS record**, unlike every other device — even though FGT01's certificate SAN includes it. Low priority (FGT01 is reached by IP, which the certificate also covers), but worth adding for consistency.

## 7. Lab CA Certificate for the HTTPS Dashboard

> 🔴 **Pi-hole v6 requires cert + chain + key in a *single* PEM** — `/etc/pihole/tls.pem`. This is unlike every other device in Atlas, which take separate `.crt` and `.key` files.

### 🔴 Step 7.0 — FIRST: is `issued/pihole/pihole.crt` the certificate you actually want?

> 🔴🔴 **THIS STEP DID NOT EXIST UNTIL 2026-07-14, AND IT FAILS ON THIS HOST TODAY.**

```bash
# What is Pi-hole ACTUALLY serving right now?
openssl s_client -connect 10.10.0.5:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -serial -text | grep -A1 "Subject Alternative Name"

# What does the file this step reads from actually contain?
sudo openssl x509 -in /etc/ssl/lab-ca/issued/pihole/pihole.crt \
  -noout -serial -text | grep -A1 "Subject Alternative Name"
```

**Device output, 2026-07-14:**

```
WIRE  (tls.pem):   serial=1003                      DNS:pihole.lab, DNS:pi.hole, IP Address:10.10.0.5   🟢
FILE  (issued/):   serial=740BE5A81FB4906F1A2E...   DNS:pihole.lab, DNS:pi.hole, IP Address:10.0.0.5    🔴 PRE-VLAN
```

> 🔴 **THEY DO NOT MATCH. THE FILE IS A YEAR-OLD CERTIFICATE WITH A PRE-VLAN SAN.**
>
> 🔴 **THE `cat` BELOW READS THAT FILE.** **A rebuild from this guide, today, serves `IP:10.0.0.5` on a host at `10.10.0.5`** — **a browser name-mismatch on the lab's DNS server, during a rebuild, with no DNS to debug it with.**
>
> **This is the `CM-0008` / `MC-0002` incident, pre-loaded into the rebuild path.** **`CM-0032`.**

🔴 **IF THEY DIFFER, STOP. FIX `issued/` FIRST** — `CM-0032` Step 1. **The correct certificate is in `intermediate/newcerts/<serial>.pem`.** **`openssl ca` writes there; it does not update `issued/` unless `-out` points at it.**

> 🔴 **AND THE DEEPER LESSON, WHICH THIS GUIDE IS THE PROOF OF:**
>
> **`031` v0.6, `029`, `MC-0002` and the pack manifest ALL record — TRUTHFULLY — that Pi-hole's SAN was *"verified directly on the live-served connection."* ALL FOUR ARE RIGHT.**
>
> 🔴 **AND ALL FOUR VERIFIED THE ONE ARTEFACT A REBUILD DOES NOT USE.**
>
> **VERIFYING THE WIRE PROVES NOTHING ABOUT THE FILE YOU REBUILD FROM.**

### Step 7.1 — Back up the existing file

```bash
sudo cp /etc/pihole/tls.pem /etc/pihole/tls.pem.bak-$(date +%F)
```

🔴 **DESTROY THIS BACKUP the moment the new one verifies** (`shred -u`). **`CM-0010`: *"a key backup is a rollback with an expiry measured in minutes."*** **`tls.pem` contains the private key.** **Three `.bak` files from one date is a habit, not an accident.**

### Step 7.2 — Build the combined PEM, wrapping the **entire** pipeline in `sudo`:

```bash
sudo sh -c 'cat /etc/ssl/lab-ca/issued/pihole/pihole.crt \
    /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
    /etc/ssl/lab-ca/issued/pihole/pihole.key \
    > /etc/pihole/tls.pem'
```

> 🔴 **Do not use `cat ... | sudo tee`.** `sudo` applies only to `tee`, not to the `cat` reading the inputs. When `cat` hits the root-owned private key it cannot read, it prints `Permission denied` — **and the pipeline keeps running anyway**, writing a certificate-only file with no key.
>
> **That exact mistake put a broken `tls.pem` into production, with no backup taken beforehand.** It was only caught later by an unrelated TLS handshake failure. See `038-Pi01-Troubleshooting-Guide.md`.

### 🔴 Step 7.3 — Verify the result. **Do not assume.**

```bash
sudo grep -c "BEGIN CERTIFICATE"  /etc/pihole/tls.pem   # 🔴 expect 3
sudo grep -c "BEGIN.*PRIVATE KEY" /etc/pihole/tls.pem   # 🔴 expect 1
sudo openssl x509 -in /etc/pihole/tls.pem -noout -serial -dates
```
**Device-verified 2026-07-14: `3`, `1`, `serial=1003`.** 🟢

```bash
sudo systemctl restart pihole-FTL
```

### 🔴 Step 7.4 — Read it back OFF THE WIRE. And check `issuer`.

```bash
openssl s_client -connect 10.10.0.5:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -serial -text | grep -A1 "Subject Alternative Name"
```
🔴 **EXPECT: `issuer=...CN=Home Lab Intermediate CA`, and the serial you just built.**

> 🔴 **CHECK `issuer`, NOT JUST THE SAN.** **Checking `issuer` is what caught Pi-hole serving its FACTORY self-signed certificate** (`issuer=CN=pi.hole, O=Pi-hole, C=DE`) **while THREE documents claimed a Lab CA certificate was "in active use" — from its original build onward.**
>
> **A correct SAN on a self-signed certificate is still a self-signed certificate.**

🔴 **Then run Step 7.0 again.** **The wire and the file must now agree.**

## Validation

```bash
# DNSSEC — valid signature test
dig sigok.verteiltesysteme.net @10.10.0.5
# Expect: flags: qr rd ra ad   (ad = Authenticated Data, DNSSEC passed)

# DNSSEC — invalid signature test. SERVFAIL here is CORRECT.
dig sigfail.verteiltesysteme.net @10.10.0.5
# Expect: status: SERVFAIL, EDE: 6 (DNSSEC Bogus)

# dnscrypt-proxy responding directly
dig @127.0.0.1 -p 5053 google.com

# Full chain
dig google.com @10.10.0.5

# Local records actually in effect
dig pihole.lab @10.10.0.5 +noall +answer
dig mikrotik.lab @10.10.0.5 +noall +answer

# Services
pihole status
sudo systemctl status dnscrypt-proxy-doh
sudo ss -tuln | grep 5053
```

**Confirm the dashboard is serving the right certificate — check the `issuer`, not just the absence of a browser warning:**

```bash
openssl s_client -connect 10.10.0.5:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -text | grep -A1 "Subject Alternative Name"
```

> Checking `issuer` is what caught Pi-hole serving its **factory self-signed certificate** (`issuer=CN=pi.hole, O=Pi-hole, C=DE`) while every document claimed a Lab CA certificate was in active use.

## Common Mistakes

- **Editing `custom.list` and expecting anything to happen.** See Step 6.
- **Using `cat ... | sudo tee` to build `tls.pem`.** See Step 7.
- Leaving Pi-hole's upstream on a public resolver directly instead of `127.0.0.1#5053` — this **silently skips the DoH privacy layer with no error.** It just works differently than intended.
- Trying to fix the socket-activation conflict with a systemd drop-in override rather than a new unit.
- Reading `SERVFAIL` on the `sigfail` domain as a problem — it is the correct, desired result.
- Looking for `setupVars.conf`. It does not exist on v6.

## Lessons Learned from Actual Deployment

- Pi-hole v6 uses `pihole.toml`, not the legacy `setupVars.conf`.
- **`pihole.toml` is also where local DNS records live** — not `custom.list`, which exists and looks right and does nothing.
- `dnsadmin` needed adding to the `pihole` group (`sudo usermod -aG pihole dnsadmin`) before `pihole` CLI commands worked without permission errors — `/etc/pihole/versions` is owned `pihole:pihole` mode 640. Group membership does not apply to an already-open session; log out and back in.
- **Pi-hole's own web server owns ports 80 and 443 on this host.** Any other service wanting a reverse proxy here must use a non-standard port. Vaultwarden uses 8443 for exactly this reason.

## Rollback

Point Pi-hole back at a direct public upstream (Settings → DNS → re-check Cloudflare/Google), then `sudo systemctl restart pihole-FTL`. This drops the DoH privacy layer but keeps filtering and DNSSEC.

For the certificate, restore the backup taken in Step 7.

## Completion Checklist

- [x] Pi-hole installed and blocking — confirmed live (v6.4.2)
- [x] dnscrypt-proxy running as a standalone service on 127.0.0.1:5053 — confirmed live
- [x] Pi-hole upstream set to `127.0.0.1#5053` — confirmed live
- [x] DNSSEC enabled — confirmed live
- [x] Local DNS records corrected in **`pihole.toml`** and confirmed with `dig`
- [x] HTTPS dashboard using a Lab CA certificate — fixed 2026-07-13 (was serving Pi-hole's factory self-signed cert)
- [ ] `fortigate.lab` DNS record added

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Troubleshooting.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Lab-CA/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0008-Reissue-MikroTik-Certificate-Correct-SAN.md`

## Change Log

| Version | Changes |
|---|---|
| 0.2 | Reconciled from source material and 2026-07-11 live verification. |
| **0.4** | 🔴 **2026-07-14 — `CM-0032`.** **Step 7 rebuilt `tls.pem` from `/etc/ssl/lab-ca/issued/pihole/pihole.crt` — a file that carries the PRE-VLAN SAN `IP:10.0.0.5` to this day, on a host at `10.10.0.5`.** **A rebuild served the wrong certificate on the lab's DNS server.** **Added Step 7.0: DIFF THE WIRE AGAINST THE FILE BEFORE THE `cat`.** Added `issuer` to the read-back and a `shred` rule for the `tls.pem` backup *(it contains the private key)*. 🔴 **The lesson: four documents recorded — truthfully — that Pi-hole's SAN was *"verified on the live-served connection."* All four were right. And all four verified the one artefact a rebuild does not use.** |
| 0.3 | **Step 6 rewritten** — the guide instructed editing `custom.list`, which is inert on Pi-hole v6. Local records live in `pihole.toml`. **Step 7 rewritten** — it referenced a lighttpd TLS config path; v6 requires a single combined `tls.pem`, and the guide gave no warning about the `sudo`-pipeline trap that broke it in production, and no backup step. Checklist updated: certificate and DNS records now confirmed. |
