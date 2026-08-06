---
Title: FGT01 Troubleshooting Guide
Path: Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall
---

# FGT01 Troubleshooting Guide

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: FGT01 - Role: Perimeter Firewall

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft |
| Version | 1.0 |
| Applies To | FGT01 |
| Last Updated | 2026-07-13 |

## Purpose

Every entry below is a real incident, most from the MC-0001 certificate installation, one recovered from an archived prior session. For initial build steps, see `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Build-Guide.md`.

## Before You Start

- [ ] On FortiOS, always double-check with `get`, not `show` — `show` only displays settings that differ from factory default, and can make an unchanged setting look like there's nothing to see.
- [ ] If a GUI menu you expect isn't there, check Feature Visibility before assuming a licensing restriction — most hidden FortiGate features are a visibility toggle, not a paywall.
- [ ] If a browser shows a warning after a server-side fix you've already confirmed is correct, suspect the browser's cache before the server.

## Diagnostic Approach

```text
GUI visibility — Feature Visibility settings
Certificate chain — what's actually served vs. what's imported
Binding — which certificate/setting is actually active, not just imported
Client-side — browser cache, workstation trust store
```

---

## Incident: System > Certificates Menu Missing from GUI

**Symptom:** `System > Certificates` doesn't appear in the FortiGate GUI navigation at all.

**Wrong assumption to avoid:** this is not a FortiCare licensing restriction. Certificate management is never gated behind device registration or a paid subscription.

**Root cause:** FortiOS hides the Certificates feature by default. Confirmed against Fortinet's own current documentation.

**Resolution:**
```text
System > Feature Visibility > enable Certificates > Apply
```

**Verify fix:** `System > Certificates` now appears in the navigation.

---

## Incident: Browser Shows ERR_CERT_AUTHORITY_INVALID After Certificate Import

**Symptom:** A device certificate was imported and bound, but the browser still shows `ERR_CERT_AUTHORITY_INVALID`.

**Root cause:** the certificate chain is incomplete. FGT01 was only presenting its own leaf certificate — no intermediate — so the browser couldn't build a path up to a trusted root even though the root itself was correctly trusted.

**Diagnostic steps (definitive, not guesswork):**
```bash
openssl s_client -connect <fgt01-ip>:443 -showcerts </dev/null 2>/dev/null | grep -c "BEGIN CERTIFICATE"
```
A healthy two-tier chain returns `3` (leaf + intermediate + root). Returning `1` means only the leaf is being served — confirms a missing-chain problem directly, independent of any browser state.

**Wrong fix that looks right but isn't:** importing the intermediate as a separate `CA Certificate` object on FortiGate. This tells FortiGate to *trust* that intermediate for validating other connections — it does **not** get automatically attached to what FortiGate presents as its own server certificate. This will not fix the browser warning, and the `openssl s_client` count will still show `1` afterward.

**Actual resolution:** build a proper bundle (leaf certificate + CA chain, concatenated) and import *that* as the Local Certificate:
```bash
cat device.crt ca-chain.crt > device-bundle.crt
```
Import `device-bundle.crt` as a Local Certificate (not a CA Certificate), then bind it as the admin server certificate.

**Verify fix:**
```bash
openssl s_client -connect <fgt01-ip>:443 -showcerts </dev/null 2>/dev/null | grep -c "BEGIN CERTIFICATE"
```
Should return `3`.

---

## Incident: Certificate Chain Is Confirmed Correct, Browser Still Shows the Old Certificate

**Symptom:** `openssl s_client` confirms the correct chain is being served, `get system global | grep admin-server-cert` confirms the right certificate is bound — but a browser still shows the old certificate's details (wrong issue date, wrong serial).

**Root cause:** Chrome's TLS session caching can outlast simply closing browser windows. This is a client-side caching problem, not a remaining server-side issue — confirmed by the `openssl s_client` output already proving the server is correct.

**Resolution, in order of speed:**
1. Try an Incognito/Private window first — starts with no cached TLS state.
2. If that still shows the old cert, fully kill all browser processes via Task Manager (closing windows alone may not be enough if the browser keeps a background process alive).
3. As an isolation test, try a completely different browser that's never connected to this device before.

---

## Incident: A `set` Command Appeared to Succeed but Never Actually Took Effect

**Symptom:** `config system global / set admin-server-cert "<name>"` ran with no error, but the device kept serving a different certificate than expected — sometimes for a significant amount of troubleshooting time before being caught.

**Root cause:** the `set` command did not actually persist as expected. Nothing about the certificate import, chain, or bundling was wrong — the binding itself was the defect, and nothing about working with the certificate would ever surface it.

**Diagnostic steps:**
```text
show system global | grep admin-server-cert
```
**This can come back empty even when something is genuinely wrong** — `show` only displays non-default values. Empty output is not proof the setting is correct.
```text
get system global | grep admin-server-cert
```
`get` always shows the true current live value. Use this one to actually confirm.

**Resolution:** re-run the `set` command, then confirm with `get` again — don't trust a `set` command's lack of error output as proof it worked.

**The real lesson:** a command running without an error is not the same as a confirmed active configuration. Always verify the live state directly after any binding/assignment change, not just after the initial configuration step.

---

## Incident (Archived Session): VDOM Mode Caused a Lockout

**Symptom:** Interface configuration commands failed or behaved unexpectedly during initial buildout, ultimately causing a lockout.

**Root cause:** FGT01 runs in multi-VDOM mode (`root` VDOM active), which most FortiGate documentation and generic guides don't assume by default. Every interface-level command requires `set vdom "root"` explicitly — omitting it was the actual cause of the lockout during the original build.

**Resolution/prevention:** always confirm VDOM mode before making interface changes:
```text
get system status | grep -i vdom
```
Include `set vdom "root"` explicitly in any interface configuration block, don't assume it's implied.

---

## Quick Reference — Common Commands

| Task | Command |
|---|---|
| Confirm true current value of a global setting | `get system global \| grep <setting>` (not `show`) |
| Count certificates in the served chain | `openssl s_client -connect <ip>:443 -showcerts </dev/null 2>/dev/null \| grep -c "BEGIN CERTIFICATE"` |
| List installed local certificates | `show vpn certificate local` |
| Confirm VDOM mode before interface changes | `get system status \| grep -i vdom` |

## Escalation

1. Capture `get system global` output and `openssl s_client` chain count before further changes.
2. Check `021-FGT01-Build-Record.md` against live state.
3. Check `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md` and `MC-0001-FGT01-Lab-CA-Certificate-Installation.md` for the full certificate diagnostic history before re-diagnosing from scratch.

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Build-Guide.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Operations/035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/MC-0001-FGT01-Lab-CA-Certificate-Installation.md`
