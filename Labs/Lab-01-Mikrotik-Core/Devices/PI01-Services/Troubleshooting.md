---
Title: Pi01 Troubleshooting Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services
---

# Pi01 Troubleshooting Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 1.0 |
| Applies To | Pi01 |
| Last Updated | 2026-07-13 |

## Purpose

Every entry below is a real incident encountered on Pi01. For initial build steps, see the five Pi01 Build Guides (`030`-`034`).

## Before You Start

- [ ] `journalctl -b -1` — check this **first** for any hang/crash investigation. If it returns "no persistent journal was found," see the Persistent Logging entry below before doing anything else; without it, evidence of what happened is permanently gone once the system reboots.
- [ ] Confirm which machine's shell you're actually in before running `ssh pihole` again — see the cross-cutting Remote Access Troubleshooting Guide.
- [ ] Check `df -h` and `vcgencmd get_throttled` early in any "system acting strange" investigation — both rule out entire categories of cause in one command each.

## Diagnostic Approach

```text
Power/Hardware — undervoltage, storage health
OS — disk space, filesystem state, persistent logging
Services — permissions, socket conflicts, third-party package mismatches
```

---

## Incident: `pihole` Commands Fail with Permission Denied

**Symptom:** Running `pihole` CLI commands as `dnsadmin` produces permission errors.

**Root cause:** `dnsadmin` was not a member of the `pihole` group. `/etc/pihole/versions` (and similar files) are owned `pihole:pihole`, mode `640`.

**Resolution:**
```bash
sudo usermod -aG pihole dnsadmin
```
Log out and back in — group membership doesn't apply to an already-open session.

**Verify fix:** `pihole -v` returns real version numbers instead of permission errors.

---

## Incident: dnscrypt-proxy Won't Start on the Intended Port

**Symptom:** dnscrypt-proxy configured for `127.0.0.1:5053` fails to bind, or a systemd conflict appears.

**Root cause:** the Debian `dnscrypt-proxy` package uses systemd socket activation hardcoded to `127.0.2.1:53`, which conflicts with any custom listen address configured in the `.toml` file.

**Wrong fix that looks reasonable but doesn't work:** a systemd drop-in override on `dnscrypt-proxy.service` — the `Requires=dnscrypt-proxy.socket` directive can't be overridden that way once the socket is active.

**Actual resolution:** mask the socket and run a standalone service unit instead:
```bash
sudo systemctl mask dnscrypt-proxy.socket
```
Then create a new unit file (see `032-Pi-hole-DNS-Build-Guide.md` Step 3 for the full unit) rather than patching the packaged one.

---

## Incident: cloudflared No Longer Proxies DNS

**Symptom:** A DNS-over-HTTPS setup built around `cloudflared` stops working, or the DNS proxy functionality can't be found in current `cloudflared` documentation.

**Root cause:** Cloudflare removed the DNS proxy feature from `cloudflared` in version 2026.2.0. This isn't a misconfiguration — the feature was actually discontinued.

**Resolution:** migrate to `dnscrypt-proxy` instead — actively maintained, supports DoH/DNSCrypt/DoT. See the dnscrypt-proxy incident above for its own setup gotcha.

**Lesson:** when a previously-working tool's documented feature can't be found anymore, check the changelog for a removed feature before assuming a local config problem.

---

## Incident: FreeRADIUS Test User Always Returns Access-Reject

**Symptom:** A test user is defined in `/etc/freeradius/3.0/users` with what looks like correct syntax, but `radtest` always fails.

**Root cause:** using `==` instead of `:=` in the users file. `==` performs a direct comparison only and silently never matches, producing a rejection even when everything else is configured correctly. There's no error — it just quietly doesn't match.

**Resolution:** use `:=` for assignment in the users file:
```text
testing Cleartext-Password := "password"
    Reply-Message := "Hello, %{User-Name}"
```
Also confirm this line is uncommented in `mods-available/files` — easy to miss, and the module loads fine but silently never matches a username if skipped:
```text
key = "%{%{Stripped-User-Name}:-%{User-Name}}"
```

---

## Incident: FreeRADIUS Dictionary/Package Errors After Installing from a Third-Party Repo

**Symptom:** FreeRADIUS fails to start or produces dictionary-parsing errors after installing from a non-Debian repository (e.g., InkBridge/NetworkRadius).

**Root cause:** a Debian release mismatch — `freeradius-common` pulled from a different release codename than the rest of the system.

**Resolution:** use the Debian-packaged FreeRADIUS unless a specific unavailable feature genuinely requires a third-party repo. It's version-matched to the OS and sufficient for standard AAA use.

---

## Incident: Static IP Configuration Doesn't Match Expected Tooling

**Symptom:** Following older guides that reference `dhcpcd` for static IP configuration doesn't work — the file or service doesn't exist.

**Root cause:** modern Raspberry Pi OS / DietPi use NetworkManager, not `dhcpcd`.

**Resolution:** use `nmcli` instead:
```bash
nmcli con show                                    # confirm the actual connection name first, don't assume
sudo nmcli con mod "<connection-name>" ipv4.addresses <ip>/<prefix>
sudo nmcli con mod "<connection-name>" ipv4.gateway <gateway>
sudo nmcli con mod "<connection-name>" ipv4.method manual
sudo nmcli con up "<connection-name>"
```
If `/etc/resolv.conf` keeps getting overwritten: `sudo chattr +i /etc/resolv.conf` to lock it.

---

## Incident: Basic Commands (ping, shutdown) Stop Working, Requires Hard Power Cycle

**Symptom:** Commands that should work stop responding; system requires physically unplugging and reconnecting power to recover.

**Full diagnostic path used to rule out causes systematically:**
```bash
df -h                                              # disk space
mount | grep " / "                                 # filesystem read-only check
dmesg | grep -iE "read-only|remount|EXT4-fs error|I/O error"
vcgencmd get_throttled                              # power/undervoltage — 0x0 means clean
sudo smartctl -a /dev/sda | grep -iE "reallocated|pending|health"   # storage health (install smartmontools first if missing)
```

**On this host, all four checked clean** — disk space fine, filesystem healthy, `throttled=0x0` (no undervoltage ever recorded), SMART overall-health PASSED. Root cause was not conclusively identified — but see the Persistent Logging entry below, which is the actual fix for *next time* this happens.

**If checking a USB-attached SSD/NVMe specifically:** standard `smartctl` may need `-d sat` forced for some USB-to-SATA bridge chips to pass through SMART data; some enclosures don't expose it at all regardless, which is inconclusive rather than a red flag.

---

## Incident: Editing `/etc/pihole/custom.list` Doesn't Change What Pi-hole Actually Resolves

**Symptom:** A local DNS record is edited in `custom.list`, the file itself confirms the edit is correct, `pihole-FTL` is restarted — and `dig` against Pi-hole still returns the old, stale answer.

**Root cause:** on this Pi-hole v6 install, local DNS records are actually read from an embedded array inside `/etc/pihole/pihole.toml`, not from `custom.list`. The two can disagree, and `pihole.toml` wins. `custom.list` may be legacy, unused, or lower-priority in this version — editing it alone does nothing if `pihole.toml` has its own copy of the same record.

**Diagnostic steps:**
```bash
grep -i "<hostname>" /etc/pihole/pihole.toml
```
If this returns a matching entry, that's the one actually in effect — regardless of what `custom.list` says.

**Resolution:** edit the entry directly in `pihole.toml`. Note this is TOML array syntax, not a plain text line — quotes and trailing comma matter for the file to stay valid:
```text
"10.10.0.1 mikrotik.lab",
```
Then:
```bash
sudo systemctl restart pihole-FTL
dig <hostname> @10.10.0.5 +noall +answer
```

**Lesson:** don't assume a config file is the active source of truth just because it exists and looks right — verify by checking what's actually in effect (`pihole.toml` here) before spending a restart cycle wondering why a correct-looking edit had no effect.

---

## Incident: A Piped Command with `sudo` Only on Part of It Fails Silently

**Symptom:** A command combining multiple files with `cat` and root-owned input (like a private key), piped into `sudo tee` to write the output, appears to succeed — but the resulting file is incomplete, missing whatever `cat` couldn't actually read.

**Root cause:** `sudo` was only applied to the final command in the pipeline (`tee`), not to `cat` reading the earlier files. When `cat` hits a file it can't read (e.g. a private key owned `root`, mode restrictive), it prints a `Permission denied` error to the terminal — but the pipeline **keeps running anyway** with whatever content `cat` did manage to read. `tee` still writes successfully; it just writes an incomplete file, with no indication in the final output that anything went wrong. Applying `sudo` to only one command in a pipe does not extend root access to the other commands in that same pipe.

**Real consequence observed:** this exact pattern was used to build a combined certificate+key file, silently produced a certificate-only file with no key, and that broken file was copied into production before being caught by an unrelated downstream check (a TLS handshake test that failed).

**Resolution — wrap the whole pipeline in a single `sudo` context, not just the last command:**
```bash
sudo sh -c 'cat file1 file2 file3 > output_file'
```
Every command inside the `sh -c '...'` runs as root, including the reads.

**Prevention:** always scroll up and read the *entire* output of a multi-command pipeline before trusting the result, not just the final line — a `Permission denied` error easily scrolls past unnoticed among successful output from the rest of the pipe. Verify the actual resulting file's contents directly (e.g. `grep -c "BEGIN CERTIFICATE"` and `grep -c "BEGIN.*PRIVATE KEY"` for a combined PEM) rather than assuming a command completing without a hard failure means the output is correct.

---

## Incident: No Log History Available After a Reboot

**Symptom:** `journalctl -b -1` (previous boot's log) returns "Specifying boot ID or boot offset has no effect, no persistent journal was found" — meaning whatever caused a crash or hang is now permanently unrecoverable.

**Root cause:** this system only kept logs in memory by default, wiped on every reboot.

**Resolution (do this now, before it's needed again):**
```bash
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald
```
This switches to persistent logging — from this point forward, `journalctl -b -1` will actually have data after any future incident.

---

## Quick Reference — Common Commands

| Task | Command |
|---|---|
| Check disk space | `df -h` |
| Check for undervoltage/throttling | `vcgencmd get_throttled` (`0x0` = clean) |
| Check filesystem read-only state | `mount \| grep " / "` |
| Check previous boot's logs | `journalctl -b -1 -p err` |
| Check storage health | `sudo smartctl -a /dev/sda \| grep -iE "reallocated\|pending\|health"` |

## Escalation

1. Capture `df -h`, `vcgencmd get_throttled`, and `journalctl -b -1` output before further changes (now meaningful, post persistent-logging fix).
2. Check `029-Pi01-Build-Record.md` against live state.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Build-Guide-Base.md` through `034`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Build-Record.md`
