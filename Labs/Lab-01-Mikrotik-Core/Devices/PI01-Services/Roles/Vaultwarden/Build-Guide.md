---
Title: Pi01 Vaultwarden Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/Vaultwarden
---

# Pi01 Vaultwarden Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Vaultwarden

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Complete — Phase 1 and Phase 2 both done, confirmed live 2026-07-13 |
| Version | 1.0 |
| Applies To | Atlas 2.0 |

## Purpose

Self-hosted, Bitwarden-compatible password manager for lab credentials, run via Docker on Pi01.

## Design Philosophy

Self-hosted over cloud Bitwarden or a managed service, single-user. Pi01 was chosen as host because it's the only device that was live and capable of running a new service when this was built — long-term home is expected to migrate to a VM once PVE01/Enterprise Virtualization exists.

Two decisions made up front:

| Decision | Choice |
|---|---|
| Final IP | 10.10.0.5 (VLAN 10) — not usable until VLAN 10 exists on the network side |
| Certificate | HTTPS from the start via Lab CA, hostname `vault.lab` — same pattern as every other lab service |

Deliberately staged: get Docker + Vaultwarden running and verified safe (no accidental network exposure) before creating any real vault data. Master password / real entries are **not created** until HTTPS is live — Vaultwarden's own Web Crypto API usage (`importKey`) can fail or behave inconsistently outside an HTTPS context, so rushing this over plain HTTP risks real data loss, not just a warning.

## Prerequisites

- Base system build complete (`030-Pi01-Base-System-Build-Guide.md`)
- Docker installed via the official Docker apt repository, **not** the curl-pipe-bash convenience script — deliberate choice given this Pi already runs production services (Pi-hole, Lab CA, FreeRADIUS)

## Implementation

### 1. Install Docker (official repo)

```bash
sudo apt remove docker docker-engine docker.io containerd runc -y
sudo apt update
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker dnsadmin
```

**Log out and back in** before testing — group membership from `usermod` does not apply to an already-open shell session. Then:

```bash
docker run hello-world
```

### 2. Capture a Pre-Install Firewall Baseline

Docker modifies `iptables` directly, independent of UFW, when containers publish ports. Capture the baseline before running any real container so you have something to diff against:

```bash
sudo ufw status verbose
sudo iptables -L DOCKER -n
sudo ss -tulnp | grep docker
```

### 3. Run the Vaultwarden Container (Localhost-Only)

```bash
docker run -d \
  --name vaultwarden \
  --restart unless-stopped \
  -e ADMIN_TOKEN="<placeholder — replaced with Argon2 hash in Step 4>" \
  -v ~/vaultwarden/data:/data \
  -p 127.0.0.1:8222:80 \
  vaultwarden/server:latest
```

> The correct Docker Hub image is `vaultwarden/server`. `vaultwarden/vaultwarden` does not exist and will fail to pull.

Confirm nothing is exposed beyond localhost:

```bash
docker ps
docker logs vaultwarden --tail 30
curl -I http://127.0.0.1:8222
sudo ss -tulnp | grep 8222      # must show 127.0.0.1:8222, NOT 0.0.0.0:8222
sudo ufw status verbose         # must be unchanged from the Step 2 baseline
```

### 4. Hash the Admin Token (Argon2id)

The startup log flags a plain-text `ADMIN_TOKEN` as insecure. Fix before any real admin panel use:

```bash
docker exec -it vaultwarden /vaultwarden hash
# Enter a password when prompted — this generates the Argon2id PHC string
```

Recreate the container with the hash (single-quote it — the container's `$` characters must not be expanded by bash):

```bash
docker stop vaultwarden
docker rm vaultwarden
docker run -d \
  --name vaultwarden \
  --restart unless-stopped \
  -e ADMIN_TOKEN='<argon2id PHC string from previous step>' \
  -v ~/vaultwarden/data:/data \
  -p 127.0.0.1:8222:80 \
  vaultwarden/server:latest
```

Verify: `docker logs vaultwarden --tail 15` should show no insecure-token warning; `curl -I http://127.0.0.1:8222` should return `200 OK`.

> The plain-text value the hash was generated from is still considered exposed (it appeared in shell history and an earlier command) and should be rotated once the admin panel is first reachable over HTTPS — don't treat the hash as closing that loop by itself.

### 5. Phase 2 — Network Exposure (complete, 2026-07-13)

**Actual steps taken, including a real conflict not anticipated in the original plan:**

1. Issued a `vault.lab` certificate from the Lab CA (`031-Pi01-Lab-CA-Build-Guide.md`), built after the CA-wide `copy_extensions` fix — SAN verified correct on the first attempt: `DNS:vault.lab, IP Address:10.10.0.5`.
2. Added the `vault.lab` DNS record (in `/etc/pihole/pihole.toml`'s `hosts` array — **not** `/etc/pihole/custom.list`, which this Pi-hole version doesn't actually read for local records).
3. Installed nginx as a reverse proxy in front of Vaultwarden:
   ```bash
   sudo apt install nginx -y
   ```
4. **Real conflict found: Pi-hole's own web server (`pihole-FTL`) already owns ports 80 and 443** on this device — confirmed via `sudo ss -tulnp | grep -E ':80 |:443 '`. nginx could not bind either port.
5. **Resolution: moved Vaultwarden's HTTPS to port `8443`** instead of contesting Pi-hole for 443. Untangling Pi-hole's own web server config to free up 443 was deliberately deferred as separate, bigger work — not done as part of this guide.
6. nginx site config (`/etc/nginx/sites-available/vaultwarden`, symlinked into `sites-enabled`):
   ```nginx
   server {
       listen 8443 ssl;
       server_name vault.lab;

       ssl_certificate /etc/ssl/lab-ca/issued/vaultwarden/vaultwarden-bundle.crt;
       ssl_certificate_key /etc/ssl/lab-ca/issued/vaultwarden/vaultwarden.key;

       location /notifications/hub {
           proxy_pass http://127.0.0.1:8222;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
       }

       location / {
           proxy_pass http://127.0.0.1:8222;
           proxy_set_header Host $host;
           proxy_set_header X-Forwarded-Proto https;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```
   The `/notifications/hub` block is required for live sync between devices (WebSocket) — a normal `location /` block alone handles regular requests but silently breaks real-time sync if this is skipped.
7. **A second conflict, unrelated to Vaultwarden:** nginx's own default site (installed automatically, unrelated to this config) was *also* trying to bind port 80, causing a second startup failure after the `8443` fix. Removed:
   ```bash
   sudo rm /etc/nginx/sites-enabled/default
   ```
8. Confirmed nginx running clean on `8443`:
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   sudo ss -tulnp | grep 8443
   ```
9. Rebuilt the container with the real domain (note the port is part of the URL, since this isn't running on the standard HTTPS port):
   ```bash
   docker stop vaultwarden
   docker rm vaultwarden
   docker run -d \
     --name vaultwarden \
     --restart unless-stopped \
     -e DOMAIN="https://vault.lab:8443" \
     -e ADMIN_TOKEN='<Argon2id hash from Step 4>' \
     -v ~/vaultwarden/data:/data \
     -p 127.0.0.1:8222:80 \
     vaultwarden/server:latest
   ```
10. Confirmed reachable at `https://vault.lab:8443` from the admin workstation, with no certificate warning — proving the whole chain (DNS, Lab CA trust, nginx TLS termination, container forwarding) worked end to end.
11. **Rotated the admin token** — generated a fresh Argon2id hash (`docker exec -it vaultwarden /vaultwarden hash`), recreated the container with it, confirmed clean startup with no insecure-token warning, confirmed login to `/admin` with the new value.
12. Created the master password and real vault entries — first entries stored: the Lab CA Root and Intermediate CA passphrases, re-encrypted the same session (see `043-PKI-and-Credential-Security-Overhaul-Session-Summary.md`).

**Permanent, non-standard detail worth remembering:** Vaultwarden on this host is reachable at `https://vault.lab:8443`, not the plain `https://vault.lab` every other Lab CA service uses — the port number is required because Pi-hole already owns 443 on this device.

## Validation

```bash
docker ps                                  # container running, restart policy unless-stopped
docker logs vaultwarden --tail 15          # no insecure-token warning
sudo ss -tulnp | grep 8443                 # nginx listening, port 8443
openssl s_client -connect 10.10.0.5:8443 -showcerts </dev/null 2>/dev/null | grep -c "BEGIN CERTIFICATE"
                                            # confirms the certificate chain being served
```
Then from a workstation that trusts the Lab CA root: `https://vault.lab:8443` should load with no certificate warning.

## Common Mistakes

- Using the wrong image name (`vaultwarden/vaultwarden` instead of `vaultwarden/server`).
- Running `docker exec vaultwarden /vaultwarden hash` without `-it` — no interactive TTY means the password prompt has no stdin to read from and the process panics.
- Testing immediately after `usermod -aG docker` in the same shell session that ran the command — group membership doesn't apply until a new session.
- Rushing master password / real vault entry creation over plain HTTP — Vaultwarden's Web Crypto API usage can fail or behave inconsistently outside HTTPS.
- **Assuming nginx can bind ports 80/443 by default on this specific host.** Pi-hole's own web server already owns both — always check `ss -tulnp` for existing listeners before installing a second web server on this Pi.
- **Forgetting nginx's own default site is a separate config file from whatever you write.** It binds port 80 on its own, independent of any custom site config — remove `/etc/nginx/sites-enabled/default` if it's not needed.

## Lessons Learned from Actual Deployment

- Docker's bridge-network ACCEPT rule for the container's internal IP (e.g. `172.17.0.2:80`) is expected and not a real exposure — the thing that actually matters is what `ss` shows the real listening socket bound to (`127.0.0.1:8222`, not `0.0.0.0:8222`).
- UFW rules stay genuinely unchanged by a localhost-bound Docker container; verify this directly rather than assuming.
- **Pi-hole owning ports 80/443 on this host is a real, permanent constraint** for any future service that wants a reverse proxy here — plan for a non-standard port from the start rather than discovering the conflict mid-build.
- The WebSocket-specific `location /notifications/hub` block in the nginx config is easy to skip and easy not to notice missing — regular login/vault access works fine without it, only live sync between devices silently breaks.

## Rollback

`docker stop vaultwarden && docker rm vaultwarden` — safe at any point before real vault data exists, since the volume can simply be recreated. Once real vault entries exist, back up `~/vaultwarden/data` before any destructive change.

## Completion Checklist

- [x] Docker installed via official repo, `dnsadmin` in `docker` group — confirmed
- [x] Vaultwarden container running, `vaultwarden/server:latest`, v1.36.0 — confirmed
- [x] Admin token Argon2id-hashed — confirmed
- [x] `vault.lab` certificate issued from Lab CA — confirmed, SAN verified correct
- [x] nginx reverse proxy in place — port `8443`, not `443` (Pi-hole owns 443 on this host)
- [x] Rebound to `https://vault.lab:8443` — confirmed reachable with no certificate warning
- [x] Admin token rotated post-HTTPS — confirmed
- [x] Master password and first real vault entries created — confirmed, first entries were the Lab CA Root/Intermediate passphrases
- [x] UFW rules scoped to specific devices/subnets — device-verified 2026-07-16 (`ufw status verbose`): `8443/tcp ALLOW IN 10.10.0.50` — restricted to the admin workstation only, matching `029`. 🔴 **Corrected:** an earlier version of this line said "not yet explicitly restricted"; the live host shows it **is** restricted.

## Next Guide

None — depends on Lab CA guide for Phase 2, no further guides depend on this one.
