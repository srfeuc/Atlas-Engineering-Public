---
Title: Pi01 Base System Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services
---

# Pi01 Base System Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft — reconciled from pre-VLAN source material, needs live re-verification |
| Version | 0.2 |
| Applies To | Atlas 2.0 |
| Hardware | Raspberry Pi 4 |
| Storage | SSD (not SD card) |

## Purpose

Base OS, network, and hardening configuration for Pi01 before any service (Pi-hole, FreeRADIUS, Vaultwarden, Lab CA) is installed. Every other Pi01 Build Guide assumes this is done first.

## Design Philosophy

Hardened headless server: key-only SSH on a non-default port, default-deny host firewall, no default `pi` account, dedicated `dnsadmin` admin account. This mirrors the pattern used on every other Atlas device — least-privilege access, explicit allow rules, no implicit trust from network position alone.

> **Resolved, 2026-07-13: Debian 13 ("Trixie").** Source material previously disagreed — the original setup guide (June 2026) used Raspberry Pi OS Lite / Debian 11 (Bullseye), while a `DietPi_RPi234-ARMv8-Trixie.img.xz` image (Debian 13) also existed among the source files. Confirmed via two independent pieces of evidence rather than a fresh check: the `dig` version banner used throughout this session's DNS work (`DiG 9.20.23-1~deb13u1-Debian`), and the DietPi image's own filename — "Trixie" is Debian 13's actual codename, matching exactly.

## Prerequisites

| Item | Value |
|---|---|
| Management IP | 10.10.0.5/24 (VLAN 10) — **not** the 10.0.0.5 flat-network address used in original source docs |
| Gateway | 10.10.0.1 (MKT01 vlan10-mgmt) |
| SW01 Port | Gi1/0/7 (Access, VLAN 10) |
| SSH Port | 2222 |
| Admin user | `dnsadmin` (source docs capitalize this `DNSAdmin` in one early step — live system confirmed lowercase; use lowercase) |
| Hostname | pihole |

## Required Information

Before starting, generate an SSH key pair on the administrating machine (`ssh-keygen -t ed25519`) — do this before disabling password authentication, or you will lock yourself out.

## Implementation

### 1. Set a Static IP

Modern Raspberry Pi OS / DietPi use NetworkManager, not `dhcpcd`. Confirm the connection name first — don't assume it:

```bash
nmcli con show
```

Then set the static address (VLAN 10 addressing):

```bash
sudo nmcli con mod "Wired connection 1" ipv4.addresses 10.10.0.5/24
sudo nmcli con mod "Wired connection 1" ipv4.gateway 10.10.0.1
sudo nmcli con mod "Wired connection 1" ipv4.dns "1.1.1.1 1.0.0.1"
sudo nmcli con mod "Wired connection 1" ipv4.method manual
sudo nmcli con up "Wired connection 1"
```

Verify:

```bash
ip a
ip route
ping 10.10.0.1
ping 1.1.1.1
```

If `/etc/resolv.conf` keeps getting overwritten by NetworkManager, lock it: `sudo chattr +i /etc/resolv.conf`.

### 2. Initial Hardening

```bash
passwd                                  # change from any default credentials
sudo apt update && sudo apt upgrade -y
sudo adduser dnsadmin
sudo usermod -aG sudo dnsadmin
```

Log out, log back in as `dnsadmin`, then remove any default account (e.g. `pi`):

```bash
sudo deluser --remove-home pi
```

### 3. SSH Key Authentication

On the admin machine: `ssh-keygen -t ed25519`. Copy the **public** key only to the Pi:

```bash
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys      # paste the public key
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Test key login before touching `PasswordAuthentication`:

```bash
ssh -p 2222 dnsadmin@10.10.0.5
```

### 4. Harden sshd_config

```bash
sudo nano /etc/ssh/sshd_config
```

| Setting | Value | Reason |
|---|---|---|
| PermitRootLogin | no | No direct root login over SSH |
| PasswordAuthentication | no | Key-only — **only after key login is confirmed working** |
| Port | 2222 | Off default port |
| LoginGraceTime | 20 | Reduces window for incomplete logins |
| MaxAuthTries | 3 | Limits failed attempts per connection |
| MaxSessions | 3 | Limits concurrent sessions |
| Banner | /etc/issue.net | Login warning banner |

Add the banner text to `/etc/issue.net`: `Authorized access only. All activity is monitored and logged.`

```bash
sudo systemctl restart ssh
```

### 5. Set Hostname

```bash
sudo hostnamectl set-hostname pihole
```

### 6. UFW Baseline Firewall

```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp                          # SSH
sudo ufw allow 443/tcp                           # HTTPS — Pi-hole admin, other lab TLS services
sudo ufw allow 53/tcp                            # DNS (TCP)
sudo ufw allow 53/udp                            # DNS (UDP)
sudo ufw enable
```

Port 80 is intentionally **not** opened broadly — restrict it to the specific admin workstation IP when Pi-hole's dashboard needs it:

```bash
sudo ufw allow from 10.10.0.50 to any port 80
```

(Admin workstation is `10.10.0.50` under current VLAN 10 addressing — the original doc used `10.0.0.20`, a flat-network address that predates the workstation's current assignment.)

Rules added later by service-specific guides:

| Service | Rule |
|---|---|
| FreeRADIUS | `sudo ufw allow 1812/udp` / `1813/udp` — scoped per client IP, not the whole subnet |
| Lab CA (if serving OCSP/CRL) | Add as needed |

Verify: `sudo ufw status verbose`

## Validation

```bash
ip a                              # confirm 10.10.0.5/24
ssh -p 2222 dnsadmin@10.10.0.5    # confirm key auth works, password auth rejected
sudo ufw status verbose           # confirm default-deny + expected allow rules
hostnamectl                       # confirm hostname = pihole
```

## Common Mistakes

- Setting `PasswordAuthentication no` before confirming key login works — locks you out with no console access in most home lab setups.
- Assuming the NetworkManager connection is named "Wired connection 1" without checking — it varies.
- Opening port 80 to the whole subnet instead of scoping it to the admin workstation.

## Lessons Learned from Actual Deployment

- `dhcpcd` is not present on current Raspberry Pi OS / DietPi builds — `nmcli` is required, which surprised whoever wrote the original guide enough to warn about it explicitly.
- A locked `/etc/resolv.conf` (`chattr +i`) was needed to stop NetworkManager from silently overwriting DNS settings.

## Rollback

Re-enable password auth temporarily via console/physical access if locked out: edit `/etc/ssh/sshd_config`, set `PasswordAuthentication yes`, `sudo systemctl restart ssh`. Re-secure once key access is restored.

## Completion Checklist

- [ ] Static IP 10.10.0.5/24 confirmed
- [ ] `dnsadmin` account created, in `sudo` group, default account removed
- [ ] SSH key auth working, password auth disabled
- [ ] SSH on port 2222, banner active
- [ ] Hostname set to `pihole`
- [ ] UFW enabled with baseline rules
- [x] Base OS confirmed as Debian 13 ("Trixie") — resolved 2026-07-13, see Design Philosophy

## Next Guide

Pi01 Lab Certificate Authority Build Guide, Pi-hole/DNS Build Guide, FreeRADIUS Build Guide, or Vaultwarden Build Guide — any order, no interdependency between them beyond this base guide.
