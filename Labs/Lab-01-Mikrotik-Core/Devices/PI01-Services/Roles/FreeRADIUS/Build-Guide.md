---
Title: Pi01 FreeRADIUS Build Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Roles/FreeRADIUS
---

# Pi01 FreeRADIUS Build Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: FreeRADIUS

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Evidence Status | Verified |
| Evidence Source | Live validation on FGT01 and MKT01, 2026-07-13 |
| Last Verified | 2026-07-13 |
| Version | 1.2 |
| Applies To | Pi01 (FreeRADIUS 3.2.7) |

> ### 🔴 Read before Step 3
>
> The previous version of this guide instructed you to create a test account — username `testing`, password `password` — and its completion checklist listed *"Test user (`testing`) authenticates successfully"* as a **ticked success criterion**.
>
> **That account has been deliberately deleted.** Once RADIUS actually became functional on FGT01 and MKT01, `testing`/`password` stopped being a harmless diagnostic tool and became **a real, working, publicly-documented credential capable of authenticating to network device admin logins.** It was created, used to verify the integration, and removed.
>
> **Following the old guide recreated the vulnerability.** Step 3 below is rewritten.

## Design Philosophy

Use **Debian's own FreeRADIUS package**. A third-party repository (InkBridge/NetworkRadius) was tried during initial buildout and caused a real dictionary-parsing failure from a release mismatch — `freeradius-common` pulled from `bullseye` while everything else was on `trixie`. Stick to the Debian repo unless a specific unavailable feature genuinely requires otherwise.

**Local device accounts remain functional after RADIUS is enabled.** RADIUS is an *additional* auth path, not a replacement — devices fall back to local accounts if FreeRADIUS is unreachable. This is what makes the rollback safe at any time.

## Prerequisites

- Base system build complete (`030-Pi01-Base-System-Build-Guide.md`)

## 1. Install

```bash
sudo apt-get install freeradius -y
sudo apt-get install libtalloc-dev -y
```

Confirm it runs:

```bash
sudo freeradius -X
# Ctrl+C once you see 'Ready to process requests'
```

## 2. Key Paths

| Path | What it is |
|---|---|
| `/etc/freeradius/3.0/` | Main config dir — named "3.0" even on FreeRADIUS 3.2.x. Normal Debian packaging. |
| `/etc/freeradius/3.0/clients.conf` | Allowed devices (NAS clients) and their shared secrets |
| `/etc/freeradius/3.0/mods-config/files/authorize` | The user file (also reachable via the `users` symlink) |
| `/etc/freeradius/3.0/mods-available/files` | Controls how usernames are matched |
| `/var/run/freeradius/` | Runtime dir, PID file — created automatically by systemd |

Config is owned `freerad:freerad`. To read without `sudo` every time (edits still need it):

```bash
sudo usermod -aG freerad dnsadmin
```

## 3. Username Matching — and Test Accounts

Uncomment this line in `/etc/freeradius/3.0/mods-available/files`. **Easy to miss, and the module loads fine but silently never matches a username without it:**

```text
key = "%{%{Stripped-User-Name}:-%{User-Name}}"
```

### If you need a temporary test account

Use a **real generated password**, never a placeholder, and **delete the account the moment the integration works.**

```bash
sudo nano /etc/freeradius/3.0/users
```

```text
<testuser> Cleartext-Password := "<generated-value>"
    Reply-Message := "Hello, %{User-Name}"
```

> 🟡 **`:=`, not `==`.** `==` performs a direct comparison only. It silently never matches and produces `Access-Reject` even when everything else is configured correctly — **with no error anywhere.** Indent the second line with an actual Tab.

```bash
sudo systemctl restart freeradius
radtest <testuser> <generated-value> localhost 0 <localhost-secret>
```

Expect `Access-Accept` and the Reply-Message.

**When you are done, remove the account and confirm the removal:**

```bash
# comment out or delete the entry, then:
sudo systemctl restart freeradius
radtest <testuser> <generated-value> localhost 0 <localhost-secret>
# expect: Access-Reject
```

> 🔴 **Why this matters more than it looks.**
>
> **A test credential becomes a real credential the moment the thing it was testing starts working.** The account does not change. Its blast radius does.
>
> `testing`/`password` sat harmlessly in this lab for weeks while RADIUS was half-built. The instant MKT01's integration was completed, it became a live admin login for a network device — and it was documented publicly in this very guide. It was deleted on 2026-07-13 and confirmed via `radtest` returning `Access-Reject`.

## 4. Add Real Clients

Generate a genuinely random secret per client. **Never hand-write one:**

```bash
dd if=/dev/random bs=1 count=24 | base64
```

```bash
sudo nano /etc/freeradius/3.0/clients.conf
```

```text
client fortigate {
    ipaddr = 10.10.0.254
    secret = <generated secret>
    require_message_authenticator = yes
}

client mikrotik {
    ipaddr = 10.10.0.1
    secret = <generated secret>
    require_message_authenticator = yes
}

client laptop {
    ipaddr = 10.10.0.50
    secret = <generated secret>
    require_message_authenticator = yes
}
```

> 🔴 **`require_message_authenticator = yes` on every client block** is the documented mitigation for **BlastRADIUS** — a 2024 protocol-level vulnerability, not a FreeRADIUS-specific one. **Not optional.**

> 🔴 **There are two localhost blocks, not one.** `clients.conf` defines `client localhost` (`ipaddr = 127.0.0.1`) **and** `client localhost_ipv6` (`ipv6addr = ::1`) as entirely separate blocks. **Both ship with their own default `testing123` secret.** Both need rotating independently.
>
> This guide and the Pi01 Build Record both previously referred to "the `localhost` secret" as one thing. It is two. `testing123` is FreeRADIUS's *published* stock default — it is not a secret, and that is precisely the problem.

Store every generated secret in Vaultwarden. Per `044-Vaultwarden-Password-Storage-Convention.md`, **the notes field must name the other end** — a RADIUS secret rotated on one side only fails in a way that looks like a RADIUS problem, not a secrets problem.

### Firewall

**UFW needs one explicit rule per client source IP.** A subnet-wide rule does not implicitly cover a narrower one.

```bash
sudo ufw allow from 10.10.0.254 to any port 1812 proto udp
sudo ufw allow from 10.10.0.254 to any port 1813 proto udp
sudo ufw allow from 10.10.0.1   to any port 1812 proto udp
sudo ufw allow from 10.10.0.1   to any port 1813 proto udp
sudo ufw allow from 10.10.0.50  to any port 1812 proto udp
sudo ufw allow from 10.10.0.50  to any port 1813 proto udp
sudo ufw status verbose

sudo systemctl restart freeradius
```

## 5. Connect MKT01

```routeros
/radius add service=login address=10.10.0.5 secret=<mikrotik client secret> timeout=2s
/user aaa set use-radius=yes
/user aaa set accounting=yes
```

> 🔴 **Two traps, both hit for real:**
>
> **1. `/radius add` alone does nothing.** MikroTik has a *separate* `/user aaa` setting — `use-radius` — that must explicitly be `yes`. A perfectly configured RADIUS server entry is inert without it. **This was the actual root cause of MKT01's integration never working**, despite Pi01 having a correct `mikrotik` client block the whole time. **Only one side had ever been finished.**
>
> **2. `use-radius=yes` did not persist on the first attempt** and returned no error. Re-check immediately:
>
> ```routeros
> /user aaa print
> /radius print detail
> ```
>
> `/radius print detail` also catches **duplicate entries** — RouterOS does not warn about or merge them. A stale duplicate (commented `;;; PiHole`) was found holding an old compromised secret.

> 🔵 **No MKT01 firewall rules are needed for FGT01→Pi01 RADIUS.** Earlier versions of this guide told you to add them. They were wrong.
>
> FGT01's `internal2` (`10.10.0.254/24`) and Pi01 (`10.10.0.5/24`) are on the **same subnet, same VLAN 10, Layer-2 adjacent via SW01.** That traffic flows FGT01 → SW01 → Pi01 and **never enters MKT01's forward chain.** Pi01's own UFW rule (`allow from 10.10.0.254`) confirms the same-subnet source.
>
> MKT01 carried two such rules pointing at Pi01's **pre-VLAN address `10.0.0.5`** — dead twice over. Removed via `CM-0009`.
>
> **If VMs on VLANs 20–80 ever need Pi01 as a RADIUS or DNS target, that traffic *does* cross MKT01** and will need real forward rules. Add them then, against a real requirement.

## 6. Connect FGT01

FortiGate GUI: **User & Authentication → RADIUS Servers → Create New.**

| Field | Value |
|---|---|
| Name | Any label — cosmetic only |
| IP/Hostname | 10.10.0.5 |
| Secret | The `fortigate` client secret from `clients.conf` |
| Authentication Port | 1812 |

If **Test Connectivity** fails despite `execute ping 10.10.0.5` succeeding from the FortiGate CLI, check UFW on the Pi — a rule scoped to the wrong source IP won't match FGT01's actual management IP.

## Validation

```bash
sudo systemctl status freeradius
sudo ss -tulnp | grep 1812
radtest <user> <password> 10.10.0.5 0 <secret>
```

Confirmed live: FreeRADIUS 3.2.7 running, processing requests, enabled at boot.

### Standing validation account — `radtest-verify` (mandatory, `CM-0013`)

The test account in Step 3 is **removed** at the end of that step. Removing the only test with no replacement leaves a build that **cannot prove authentication works** — which is exactly the state `CM-0013` was raised to fix. Create a permanent, privilege-less validation account so RADIUS stays testable:

`/etc/freeradius/3.0/users`:

```text
radtest-verify   Cleartext-Password := "<generated in Vaultwarden>"
```

```bash
sudo systemctl restart freeradius
radtest radtest-verify <password> 127.0.0.1 0 <localhost-secret from clients.conf>
# expect: Access-Accept
```

> 🔴 **`Access-Accept` is the only pass — "the service is running" is not "authentication works."** A wrong shared secret or an unparseable `users` file returns `Access-Reject` while `systemctl status` looks perfectly healthy. That gap is why every RADIUS change went unvalidated for a day (`CM-0013`).
>
> **Rules, so this never becomes `testing`/`password` again (`CM-0013`):** name it exactly `radtest-verify`; password **generated in Vaultwarden**, never a dictionary word; **never grant it device privileges** — validation only; keep it (do not delete it), and it is documented in `CM-0013`.

## Common Mistakes

- **Recreating the `testing`/`password` account** because this guide used to tell you to.
- Using `==` instead of `:=` in the users file — looks more "correct," silently fails every auth attempt.
- Assuming a UFW rule for one client IP covers another IP on the same subnet. It doesn't.
- **Assuming `client localhost` is the only block with a default secret.** There are two.
- Mixing a third-party FreeRADIUS repo with the Debian base install.
- **Assuming a MikroTik `set` command took effect because it returned no error.**

## Lessons Learned from Actual Deployment

- **Debug with `sudo freeradius -X` in the foreground in one session and run `radtest` in a second session simultaneously.** Running them sequentially shows the test result but not FreeRADIUS's real-time decision process — which is the part you actually need.
- If FreeRADIUS won't start with no clear config error, check for a leftover process still holding port 1812 (`sudo ss -tulnp | grep 1812`) before assuming the config is wrong. A stray foreground debug session is the usual culprit.
- **A correct server-side config does not mean the client side was ever finished.** Pi01 had a correctly-addressed `mikrotik` client block for a long time while MKT01 had no RADIUS configuration at all.
- Once Windows AD exists, move from the static `users` file to LDAP bind (`rlm_ldap`) so FreeRADIUS authenticates against real AD accounts. The static file becomes fallback/testing only.

## Rollback

`/user aaa set use-radius=no` on MKT01, or remove the RADIUS server entry on FGT01. Reverts to local-account-only auth — safe at any time, since local accounts are never disabled by this build.

## Completion Checklist

- [x] FreeRADIUS installed, service running — confirmed live
- [x] `fortigate` client configured with correct IP — confirmed live
- [x] `laptop` client IP corrected (10.0.0.50 → 10.10.0.50) — confirmed 2026-07-13
- [x] `mikrotik` client IP corrected (10.0.0.1 → 10.10.0.1) — confirmed 2026-07-13
- [x] `localhost` **and** `localhost_ipv6` client secrets both rotated off default; `require_message_authenticator` enabled on `localhost` — confirmed 2026-07-13
- [x] MKT01 RADIUS login confirmed working end-to-end — built from scratch this session; the integration had never actually existed
- [x] FGT01 RADIUS login confirmed working end-to-end — verified via the actual RADIUS reply payload
- [x] **`testing`/`password` account removed** — confirmed via `radtest` returning `Access-Reject`
- [x] **`radtest-verify` standing validation account present** — privilege-less, password in Vaultwarden, `radtest` → `Access-Accept` (`CM-0013`, verified 2026-07-13)
- [ ] **SW01 has no AAA/RADIUS at all** — open decision, see `045-SW01-CIS-Hardening-Checklist.md`

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Guide.md` — Step 14
- `Labs/Lab-01-Mikrotik-Core/Operations/044-Vaultwarden-Password-Storage-Convention.md`
- `00-Atlas-Foundation/Decisions/ADR-0004-NPS-vs-FreeRADIUS.md`

## Change Log

| Version | Changes |
|---|---|
| 1.0 | Full RADIUS integration confirmed on FGT01 and MKT01; all secrets rotated. |
| 1.1 | **Step 3 rewritten.** The guide still instructed creating the `testing`/`password` account, and its checklist still listed that account working as a success criterion, after the account had been deliberately deleted for being a live network-device credential. Following it recreated the exact vulnerability that was closed. Test accounts now require a generated value and an explicit removal step. SW01's missing AAA added to the checklist as a visible open item. |
| **1.2** | 🟢 **2026-07-15 — `CM-0013` reconciliation.** Added the permanent **`radtest-verify`** standing validation account as a mandatory final validation step. Step 3's test account is ephemeral and removed, which left the build with **no way to prove authentication works** — the exact gap `CM-0013` was raised to close. Placeholders only; the password lives in Vaultwarden. |
