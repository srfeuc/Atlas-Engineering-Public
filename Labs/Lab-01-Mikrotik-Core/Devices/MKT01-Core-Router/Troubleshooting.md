---
Title: MKT01 Troubleshooting Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router
---

# MKT01 Troubleshooting Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | ✅ **Verified against the live device 2026-07-15.** All incidents below were reconciled against MKT01 and are **confirmed resolved on the current device** — retained as history and as the diagnostic playbook. |
| Evidence Status | **`Verified`** — live device output 2026-07-15 |
| Version | 1.1 |
| Applies To | MKT01 |
| Last Updated | 2026-07-15 |

> 🟢 **Reconciled to the device, 2026-07-15.** Each incident below is a *real past event*; the live device now shows the fixed state: the served cert SAN is `IP:10.10.0.1` (not the stale `10.0.0.1`); there is exactly **one** RADIUS entry (no duplicate); `use-radius: yes`; and `SethAdmin`'s `LAST-LOGGED-IN` is current (not blank). The playbook stays because these failure modes recur — but none is currently live.

## Purpose

Every entry below is a real incident from CM-0007/CM-0008 (Lab CA certificate installation on MikroTik). For build steps, see `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Guide.md`.

## Before You Start

- [ ] If a certificate/key upload via WinBox fails with a permissions error, try running WinBox as Administrator before chasing file-location theories.
- [ ] After `/certificate import`, check the actual assigned object name before trying to bind it — RouterOS renames imported certificates, it doesn't keep the original filename.
- [ ] If issuing a new certificate for this device, confirm the SAN includes the *current* management IP — don't assume an existing CSR/key still has the right addressing if the device has been re-IP'd since it was last issued.

## Diagnostic Approach

```text
File transfer — WinBox permissions, local path issues
Certificate object naming — imported name vs. original filename
Certificate content — SAN addressing vs. current live IP
```

---

## Incident: WinBox File Upload Fails with "Not Enough Permissions"

**Symptom:** Dragging a file into WinBox's Files window fails with `error from ros: not enough permissions for file: C:/Users/...`.

**Root cause found:** WinBox needed to be run as Administrator. Not a RouterOS-side permission issue at all, despite the error message referencing a RouterOS-style path.

**Two other things worth ruling out first if elevation doesn't fix it:**
- The file living inside a OneDrive-synced folder, where "Files On-Demand" can leave a file as a cloud-only placeholder that looks present but isn't actually local — check with `Get-ChildItem <file> | Select-Object Name, Length`; a `0` length or missing file confirms this.
- The file sitting inside a Git repository folder that has an open handle from another process (VS Code, Git) — move it to a plain folder like `C:\Temp` as a clean test.

**Resolution:** Right-click WinBox → Run as administrator, then retry the drag-and-drop.

**Security note, not optional:** if a private key was ever staged inside a Git-tracked folder for this kind of transfer, confirm it was never staged with `git status` before deleting it, and delete it from disk for real — "untracked" in Git only means not yet added, not that the file is safely gone.

---

## Incident: Certificate Binding Fails Because the Filename Changed on Import

**Symptom:** `/ip service set www-ssl certificate=<original-filename>` doesn't work, or binds to nothing.

**Root cause:** RouterOS renames certificates on import — it does not keep the original uploaded filename. A file named `device-bundle.crt` typically becomes `device-bundle.crt_0` (and if the file contains multiple certificates, additional objects like `_1`, `_2` for each one).

**Diagnostic steps:**
```
/certificate print detail
```
Read the actual `name=` field of the imported object — don't assume it matches what you uploaded.

**Resolution:** bind using the actual assigned name:
```
/ip service set www-ssl certificate=<actual-name-from-print-detail>
```

---

## Incident: Certificate Chain Serves Correctly but Browser Shows a Name Mismatch

**Symptom:** `openssl s_client` confirms a valid chain is being served, but a browser still shows *"This server could not prove that it is `<ip>`; its security certificate is from `<hostname>`."*

**Root cause:** the certificate's Subject Alternative Name doesn't include the IP actually being browsed to. This is a completely different problem from a broken chain — the chain can be perfect and this error will still occur if the SAN itself is wrong or stale.

**Diagnostic steps:**
```bash
openssl s_client -connect <ip>:443 -showcerts 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"
```
Compare the listed IPs/hostnames against what's actually being browsed to.

**On this device specifically:** the certificate's SAN referenced `10.0.0.1` — a pre-VLAN-migration address — instead of the current `10.10.0.1`. Worth checking for this pattern generally on any device whose IP addressing changed after its certificate was originally issued.

**Resolution:** reissue the certificate with a SAN matching current addressing (see the Lab CA Issuance Runbook, Part A), rebuild the bundle, reimport. Also check for a matching stale DNS record if the certificate's SAN includes a hostname — the same staleness pattern often affects both at once.

## Incident: RADIUS Login Always Fails Despite Correct Server Entry and Secret

**Symptom:** A RADIUS client entry exists (`/radius print detail` shows it), the secret matches what's configured on the RADIUS server, and login still fails for every RADIUS-only account.

**Root cause:** `/user aaa` has its own separate `use-radius` setting that must explicitly be `yes` — having a RADIUS server entry configured does not, by itself, tell MikroTik to actually consult it for logins.

**Diagnostic steps:**
```
/user aaa print
```
If `use-radius: no`, that alone explains every failure — RADIUS is never being asked at all, regardless of how correct the server entry or secret is.

**Resolution:**
```
/user aaa set use-radius=yes
```
**Verify immediately after, don't assume it took:**
```
/user aaa print
```
This setting has been observed not to persist on the first attempt — confirmed by checking again right after setting it and still seeing `no`. Re-running the same `set` command a second time resolved it. No error was shown on the failed attempt; the only way to catch it was checking the actual live value afterward.

---

## Incident: Duplicate RADIUS Client Entries for the Same Server

**Symptom:** `/radius print detail` shows more than one entry pointing at the same RADIUS server address.

**Root cause found:** an entry created fresh (via CLI) coexisted with an older, pre-existing entry (identifiable by an inline comment from an earlier build) that was never noticed until directly inspecting the full list. The older entry likely still held an outdated secret from before a rotation.

**Resolution:** set the new secret explicitly on every existing entry for that server (secrets can't be viewed with `print`, only set — there's no way to compare values directly, so update all of them rather than guessing which one is current), then remove the redundant duplicate:
```
/radius set <index> secret=<new-secret>
/radius remove <index-of-duplicate>
```

**Lesson:** always check for existing entries before adding a new one — `/radius add` doesn't warn about or merge with a pre-existing entry for the same server.

---

## Quick Reference — Common Commands

| Task | Command |
|---|---|
| Check actual imported certificate object names | `/certificate print detail` |
| Check what's actually bound to a service | `/ip service print detail` |
| Check SAN content of a served certificate | `openssl s_client -connect <ip>:443 -showcerts 2>/dev/null \| openssl x509 -noout -text \| grep -A1 "Subject Alternative Name"` |
| Check whether RADIUS is actually being consulted for logins | `/user aaa print` — look for `use-radius: yes` |
| List configured RADIUS servers | `/radius print detail` |
| List local accounts and last login | `/user print` — a blank `LAST-LOGGED-IN` means that account has never once logged in successfully |

## Escalation

1. Check `022-MKT01-Build-Record.md` against live state.
2. Check `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` for the full issuance process this guide's incidents were found during.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Troubleshooting.md` — the parallel certificate chain lessons from FGT01
