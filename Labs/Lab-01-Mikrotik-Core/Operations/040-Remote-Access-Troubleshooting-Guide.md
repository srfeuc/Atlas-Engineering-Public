---
Title: Remote Access and Workflow Troubleshooting Guide
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# Remote Access and Workflow Troubleshooting Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 1.0 |
| Applies To | Any device accessed via SSH/SCP from a Windows workstation |
| Last Updated | 2026-07-13 |

## Purpose

Every entry below is a real, repeated mistake from this session — not device-specific, but a pattern that cost time across multiple devices. Worth its own guide precisely because it isn't about any one system.

## Before You Start

- [ ] **Look at your prompt before typing a command.** This single habit prevents the most common mistake in this whole guide.

---

## Incident: Running `ssh <alias>` From Inside the Target Device's Own Shell

**Symptom:** `ssh: connect to host pihole port 22: Connection refused` (or similar) when trying to SSH somewhere, despite the same command working moments earlier.

**Root cause:** already inside the target device's own shell, and running `ssh pihole` again — but SSH aliases (like `pihole`, configured with a custom port and user in `~/.ssh/config`) only exist on the *workstation* that config file lives on. The device itself has no idea what that alias means, and tries a plain SSH to a host literally named "pihole" on the default port 22.

**How to tell which shell you're actually in, at a glance:**
```text
PS C:\...>  or  C:\Windows\...>     = Windows, on your workstation
dnsadmin@pihole:~ $                  = already on the Pi
```

**Resolution:** if you see the device's own prompt and are about to SSH again, run `exit` first to return to your workstation, then run the SSH command there.

---

## Incident: `scp` Fails with Permission Denied Pulling from a Protected Path

**Symptom:** `scp: Connection closed` or `Permission denied` when pulling a file (commonly certificates/keys) directly from its original, permission-restricted location.

**Root cause:** the SSH user (e.g., `dnsadmin`) doesn't have read access to the original path (e.g., files under `/etc/ssl/lab-ca/`, owned by root or a service account).

**Resolution — stage a copy first, don't try to change the original file's permissions:**
```bash
ssh <device>
sudo cp <protected-path>/<file> /tmp/
sudo chown <your-user>:<your-user> /tmp/<file>
exit
```
Then from the workstation:
```powershell
scp <device>:/tmp/<file> .
```
**Clean up afterward**, especially for private keys:
```bash
ssh <device>
rm /tmp/<file>
```
Don't leave sensitive files sitting in a world-readable temp location longer than needed.

---

## Incident: Root/CA-Signed Certificate Import "Succeeds" but the Certificate Isn't Actually Trusted

**Symptom:** Windows shows "The import was successful," but the certificate isn't actually trusted, or a later check shows it's not in the expected store.

**Two specific silent failure points in the Windows Certificate Import Wizard:**

1. **Store Location defaults matter.** If you double-click a `.crt` file and click through quickly, or pick **Current User** instead of **Local Machine**, the certificate only becomes trusted for your Windows login, not system-wide — and no UAC prompt appears at all if this happens, which is itself the tell. **If you don't see a UAC prompt during the import, you likely picked Current User by mistake.**
2. **The security warning popup must be accepted, not dismissed.** A popup asking to confirm the certificate's thumbprint and whether to install it looks like a "you're being warned, stop" dialog — but clicking **No** silently cancels the import even though the wizard's final message may still claim success.

**Resolution — the careful, correct sequence:**
1. Right-click the `.crt` file → **Install Certificate** (not double-click, which can skip the store-choice step).
2. Store Location: **Local Machine** — confirm a UAC prompt actually appears.
3. **Place all certificates in the following store** → Browse → the specific correct store (e.g., **Trusted Root Certification Authorities**) → OK.
4. When the security warning appears, click **Yes**.
5. Verify afterward in `certmgr.msc` by actually finding the certificate in the target store — don't trust the wizard's success message alone.

---

## Incident: A Server-Side Fix Is Confirmed Correct, but the Browser Still Shows the Old State

**Symptom:** Direct verification (e.g., `openssl s_client` against the server) proves a change took effect, but a browser still shows old certificate details or an old error.

**Root cause:** browser TLS session caching. Chrome specifically can resume a previous encrypted session without a full fresh handshake, and this can outlast simply closing browser windows if a background process stays alive.

**Resolution, in order of speed:**
1. Try an **Incognito/Private window** first.
2. If still stale, fully kill all browser processes via Task Manager, not just close windows.
3. As a clean isolation test, try a different browser entirely that's never connected to that host before.

**The general lesson:** when a client (browser) disagrees with a direct server-side check, trust the direct server-side check and go looking for client-side caching — don't assume the server-side fix must be wrong just because the browser still shows a problem.

## Quick Reference

| Symptom | Likely Real Cause |
|---|---|
| `ssh` "Connection refused" to an alias that worked before | You're already inside that device's shell |
| `scp` Permission Denied on a protected path | Need to stage via `/tmp` with `sudo cp` + `chown` first |
| Cert import "successful" but not actually trusted | Wrong store location, or the security warning was dismissed instead of accepted |
| Server confirmed fixed, browser still shows old state | Browser TLS session cache — try Incognito |

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` — where several of these were first encountered
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Troubleshooting.md`
