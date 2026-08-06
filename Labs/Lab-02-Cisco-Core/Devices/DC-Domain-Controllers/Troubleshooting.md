---
Title: DC01 Troubleshooting Guide
Path: Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers
---

# DC01 Troubleshooting Guide

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: DC01 - Role: Domain Controller (Tier 0, Windows Server 2025, `atlas.lab`)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Living |
| Version | 1.0 |
| Applies To | DC01 (and DC02) |
| Last Updated | 2026-07-21 |

## Purpose
Real incidents on the DC build with root cause + verified fix. Build steps: `Build-Guide/DC01/DC01-Build-Guide.md`; design/why: `Build-Checklist.md`. Cross-device timeline: `Build-Progress-Tracker.md`. Grows as we build.

## Before You Start
- [ ] **Domain = `atlas.lab`** (NOT `.local`/`.corp`/single-label). A wrong domain name is a **rebuild, not an edit** — verify with `Get-ADDomain` right after promotion.
- [ ] **KDS root key immediately** after promotion (the ~10-hour propagation trap; gMSAs fail later without it).
- [ ] **Tier from day one** (`t0-`/`t1-`/standard); retrofitting never happens.
- [ ] **Time:** the PDC-emulator must take time from an external source, not the hypervisor/CMOS.
- [ ] **Read state back** with `dcdiag` / `repadmin` / `Get-*`, not assumptions (`POL-0001` R-A1).

## Diagnostic Approach
```text
Domain name  — Get-ADDomain shows atlas.lab? (wrong = rebuild)
KDS/gMSA     — Get-KdsRootKey present? 4004 event logged?
Time         — w32tm /query /source = external NTP, not CMOS/VM
Patch        — fully current before promotion (a Tier-0 DC must be)
Health       — dcdiag /v, repadmin /replsummary
```

---

## Incident: DC promoted to the wrong domain (`atlas.local`)
**Symptom:** `Get-ComputerInfo` shows `CsDomain = atlas.local`, `CsDomainRole = PrimaryDomainController` — it's already a DC, on the wrong domain.
**Root cause:** an earlier promotion used `atlas.local` instead of the design's `atlas.lab` (`ADR-0007`). `.local` is also a poor AD choice (mDNS/Bonjour collision). The domain name is fixed at promotion.
**Resolution:** demote (it's the only DC, so this removes the domain), patch, then re-promote to `atlas.lab`:
```powershell
Uninstall-ADDSDomainController -LastDomainControllerInDomain -RemoveApplicationPartitions -Force
#  → set a local Administrator password; reboots to a standalone server
# ... fully patch ...
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "atlas.lab" -DomainNetbiosName "ATLAS" -ForestMode Win2025 -DomainMode Win2025 -InstallDns -Force
```
**Verify fix:** `Get-ADDomain | Select DNSRoot,NetBIOSName` → **`atlas.lab` / ATLAS**.
**Lesson:** do not attempt a domain rename (`rendom`) on a greenfield DC — rebuild is faster and safer when there's nothing to preserve.

---

## Incident: `New-ADServiceAccount` fails — "Key does not exist" (gMSA)
**Symptom:** creating a gMSA fails with a key/KDS error.
**Root cause:** no **KDS root key** in the forest (or it hasn't propagated — production waits ~10 hours after creation).
**Resolution:** create the root key. Single-DC lab → backdate the effective time so it's usable now:
```powershell
Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))   # lab, one DC only
# production: Add-KdsRootKey -EffectiveImmediately  (then wait ~10h)
```
**Verify fix:** `Get-KdsRootKey` returns a key; a **4004** event is logged in the KDS event log; `New-ADServiceAccount` succeeds.
**Lesson:** the KDS root key is the forest-wide seed for all gMSA passwords — create it at forest birth, before you need a service account.

---

## Incident: DC time source is `Local CMOS Clock` / VM provider
**Symptom:** `w32tm /query /status` shows `Source: Local CMOS Clock` (or `VM IC Time Synchronization Provider`).
**Root cause:** the PDC-emulator is taking time from the VM/CMOS instead of an authoritative external source — this drifts domain time and breaks Kerberos/replication.
**Resolution:** point the PDCe at an external NTP source (Microsoft-documented) and stop the hypervisor from overriding it:
```powershell
w32tm /config /manualpeerlist:"time.nist.gov,0x8 pool.ntp.org,0x8" /syncfromflags:manual /reliable:yes /update
Restart-Service w32time
w32tm /resync /rediscover
```
**Verify fix:** `w32tm /query /source` → the external NTP server. If it reverts to a VM/local provider, disable the QEMU guest-agent time sync on the VM.
**Lesson:** only the PDCe points outward; every other DC/member syncs from the domain hierarchy.

---

## Incident: DC is under-patched (golden-image snapshot)
**Symptom:** `Get-HotFix` shows only a handful of updates from the image build date.
**Root cause:** the VM was deployed from a golden image captured mid-patch (`210` doc's noted snapshot) and never updated.
**Resolution:** fully patch via Windows Update **before promotion** (repeat until clean, reboot between cycles). A Tier-0 DC must be current.
**Verify fix:** `Get-HotFix | Sort InstalledOn -Descending` shows recent updates; no pending reboots.

---

## Quick Reference — Common Commands
| Task | Command |
|---|---|
| Confirm the domain name | `Get-ADDomain \| Select DNSRoot,NetBIOSName,DomainMode` |
| Confirm the KDS root key | `Get-KdsRootKey` |
| Confirm time source | `w32tm /query /source` (want external NTP) |
| DC health | `dcdiag /v` ; `repadmin /replsummary` |
| Patch level | `Get-HotFix \| Sort InstalledOn -Descending \| Select -First 10` |
| gMSA usable on a host | `Test-ADServiceAccount <name>` |

## Escalation
1. Wrong domain name → demote/rebuild; do not rename.
2. gMSA failures → check `Get-KdsRootKey` + the KDS 4004 event before anything else.
3. Cross-reference `DC01-Build-Guide.md`, `Build-Checklist.md`, and the tracker log.

## Related Pages
- `Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/DC01-Build-Guide.md`
- `Labs/Lab-02-Cisco-Core/Devices/DC-Domain-Controllers/Build-Checklist.md`
- `Labs/Lab-02-Cisco-Core/Build-Progress-Tracker.md`
