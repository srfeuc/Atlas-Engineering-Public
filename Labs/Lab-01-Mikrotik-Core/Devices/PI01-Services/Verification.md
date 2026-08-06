---
Title: Pi01 Verification Procedure
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services
---

# Pi01 Verification Procedure

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Verified |
| Version | 1.0 |
| Applies To | Pi01 (10.10.0.5, VLAN 10 — Pi-hole / Lab CA / FreeRADIUS / Vaultwarden) |
| Evidence Status | **Verified** — full read-only battery run against the live device 2026-07-16 |
| Last Run | 2026-07-16 |

## Purpose

The **reconcile-to-live** procedure for Pi01: prove the running device matches `029` (Build Record) and `030`–`034` (Build Guides), walking each from 🟡 (doc-consistent) to 🟢 (device-verified). Run it before a Game Day (`ADR-0011`), after any change, or whenever a document is in doubt.

**Read-only checks only.** Risks and open items live in `053-Pi01-Considerations-and-Risks.md`.

## How to run

```bash
bash Tools/scripts/pi01-recon.sh 2>&1 | tee ~/pi01-recon-$(date +%F).txt
```

Run as `dnsadmin` (not `sudo bash …`); it elevates per-line and prompts for the sudo password once. `tee` keeps a copy; the run ends with `PI01 RECON END`.

> 🔴 **Empty output is not a pass** — it means the capture failed (Rule 13; `016`). Re-run until you see real content.
> 🔴 **No secrets printed.** `radtest` is the one manual step (needs two Vaultwarden values) — run it by hand, paste only `Access-Accept`/`Access-Reject`.

## Verification battery

### Batch A — Base system + health (`030`, `038`, `046`)

| Check | Command | Expected |
|---|---|---|
| Hostname / OS | `hostnamectl` | `pihole`, Debian 13 (trixie), arm64 |
| Address / gateway | `ip -4 -br a` ; `ip route` | eth0 `10.10.0.5/24`, default via `10.10.0.1` |
| Admin groups | `id dnsadmin` | `sudo pihole docker` (+ DietPi defaults) — **not** `freerad` |
| SSH hardening | `sudo sshd -T \| grep -Ei '^(port\|permitrootlogin\|passwordauthentication\|maxauthtries\|logingracetime\|maxsessions\|banner) '` | 2222 / no / no / 3 / 20 / 3 / **banner none** |
| Firewall | `sudo ufw status verbose` | default deny in; 13 scoped rules per `029`; `8443 → 10.10.0.50` |
| Persistent journal | `ls -ld /var/log/journal` | exists |
| Storage / power | `df -h /` ; `vcgencmd get_throttled` | SSD, `throttled=0x0` |
| Time sync | `timedatectl` ; `systemctl is-active systemd-timesyncd chrony` | `synchronized: yes` via **systemd-timesyncd**; chrony **inactive** |

### Batch B — Lab CA / PKI (`031`, `035`, `042`) — highest value

| Check | Command | Expected |
|---|---|---|
| Key hygiene | `sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/` | exactly one `0600` `.key` each, no `.bak` |
| copy_extensions | `sudo sed -n '1,12p' /etc/ssl/lab-ca/intermediate/openssl.cnf` | `copy_extensions = copy` in `[ CA_default ]` |
| CA database | `sudo cat /etc/ssl/lab-ca/intermediate/index.txt` | 4 rows: 1000 R, 1001/1002/1003 V 🔴 *(only 4 — see `053`)* |
| Pi-hole wire | `openssl s_client -connect 10.10.0.5:443 </dev/null 2>/dev/null \| openssl x509 -noout -issuer -serial -ext subjectAltName` | issuer `Home Lab Intermediate CA`, serial `1003`, SAN `IP:10.10.0.5` |
| Pi-hole file (rebuild source) | `sudo openssl x509 -in /etc/ssl/lab-ca/issued/pihole/pihole.crt -noout -serial -ext subjectAltName` | 🔴 **stale** serial `740BE5…`, `IP:10.0.0.5` — mismatch vs wire (`CM-0032`) |
| tls.pem structure | `sudo grep -c "BEGIN CERTIFICATE" /etc/pihole/tls.pem` ; `… "BEGIN.*PRIVATE KEY" …` | `3` and `1`, serial `1003` |
| Wire vs database | `for d in 10.10.0.5 10.10.0.1 10.10.0.254; do s=$(openssl s_client -connect $d:443 </dev/null 2>/dev/null \| openssl x509 -noout -serial \| cut -d= -f2); sudo openssl ca -config /etc/ssl/lab-ca/intermediate/openssl.cnf -status "$s"; done` | 1003/1001 Valid; 🔴 FGT01 "not in database" (`CM-0032`) |

### Batch C — Pi-hole / DNS (`032`)

| Check | Command | Expected |
|---|---|---|
| Versions | `pihole -v` | core 6.4.2 / web 6.5 / FTL 6.6.2 |
| Services | `systemctl is-active pihole-FTL dnscrypt-proxy-doh` ; `systemctl is-enabled dnscrypt-proxy.socket` | active / active ; socket `masked` |
| Listeners | `sudo ss -tulnp \| grep -E ':53 \|:5053 \|:80 \|:443 '` | dnscrypt `127.0.0.1:5053`; FTL owns 53/80/443 |
| DNSSEC | `dig +dnssec sigok.verteiltesysteme.net @10.10.0.5` ; `dig sigfail… @10.10.0.5` | `ad` flag ; `SERVFAIL` (correct) |
| Local records | `for h in pihole.lab pi.hole vault.lab mikrotik.lab proxmox.lab fortigate.lab; do dig +short $h @10.10.0.5; done` | all resolve; **fortigate.lab empty** (open, low-pri) |

### Batch D — FreeRADIUS (`033`) — secret-safe

| Check | Command | Expected |
|---|---|---|
| Version / service | `freeradius -v` ; `systemctl is-active freeradius` | 3.2.7 / active |
| Clients (no secrets) | `sudo grep -E '^[[:space:]]*client \|ipaddr\|ipv6addr\|require_message_authenticator' /etc/freeradius/3.0/clients.conf` | 5 blocks: fortigate/mikrotik/laptop/localhost/localhost_ipv6 |
| Accounts | `sudo grep -cE '^radtest-verify' …/users` ; `sudo grep -cE '^testing' …/users` | `1` and `0` |
| **Functional (manual)** | `radtest radtest-verify '<pw>' 127.0.0.1 0 '<localhost secret>'` | **Access-Accept** |

### Batch E — Vaultwarden (`034`) + interfaces

| Check | Command | Expected |
|---|---|---|
| Container | `docker ps` | vaultwarden, healthy, `127.0.0.1:8222` |
| Listeners | `sudo ss -tulnp \| grep -E ':8443 \|:8222 '` | nginx `8443`; container `127.0.0.1:8222` |
| Interfaces | `ip -br link` | five: lo, eth0, wlan0(down), docker0, veth |
| Vault cert wire=file | `openssl s_client -connect 10.10.0.5:8443 …` vs `sudo openssl x509 -in /etc/ssl/lab-ca/issued/vaultwarden/vaultwarden.crt …` | both serial `1002`, `vault.lab`, `IP:10.10.0.5` (match) |

## Interpreting results

- **Device wins** (Rule 13). A mismatch is a finding for `053`, not licence to edit the device to match a doc.
- **A clean command is not a correct artefact.** Where a rebuild reads a *file* (Pi-hole's `tls.pem` from `issued/pihole/pihole.crt`), check the file, not just the wire — that is the whole `CM-0032` lesson.

## Last-run record

| Date | Run by | Result | Output |
|---|---|---|---|
| 2026-07-16 | Seth | 🟢 All batches match the docs **except** the known divergences tracked in `053` (CM‑0032 stale `issued/` + `index.txt`; no NTP server per CM‑0030; SSH banner absent). `radtest` → Access-Accept. | `~/pi01-recon-2026-07-16.txt` |

## Related pages

- Build Record: `029` · Build Guides: `030`–`034`
- **Considerations & Risks: `053-Pi01-Considerations-and-Risks.md`**
- Troubleshooting: `038` · CIS: `046`
- Script: `Tools/scripts/pi01-recon.sh`
