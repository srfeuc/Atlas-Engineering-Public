---
Title: PKI and Credential Security Overhaul — Full Session Summary
Path: Labs/Lab-01-Mikrotik-Core/Operations
---

# PKI and Credential Security Overhaul — Full Session Summary

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Area: Operations

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Complete record of a single extended session, 2026-07-12 through 2026-07-13 |
| Version | 1.0 |
| Applies To | Lab CA, FGT01, MKT01, Pi01, Vaultwarden, FreeRADIUS |

## Purpose

This is the single narrative home for everything that happened across an extended session covering the Lab CA, device certificates, Vaultwarden, and credential rotation. Individual Change Records (`CM`/`MC` numbers) and Build Guide/Record updates each hold their own piece — this document exists to tell the whole story in order, so nobody has to reconstruct it from a dozen scattered files. Every fact below is real and happened; nothing here is reconstructed or assumed.

## Why This Session Happened

It started with one flagged concern: the Root CA and Intermediate CA passphrases were sitting in a plaintext text file on the desktop. That single concern expanded naturally into a much larger body of work, because fixing it properly required fixing the tools around it first — you can't securely store a new passphrase if there's no working password manager, and you can't trust a working password manager without real HTTPS in front of it, and so on. What follows is that whole chain, in the order it actually happened.

---

## Part 1 — FGT01 Certificate (MC-0001)

**Goal:** Install a Lab CA-issued certificate on FGT01's admin GUI, replacing the factory self-signed one.

**What actually happened, in order:**
1. `System > Certificates` didn't appear in the FortiGate GUI at all — turned out to be a hidden-by-default Feature Visibility setting, not a licensing restriction as initially suspected.
2. Certificate imported and bound — browser still showed `ERR_CERT_AUTHORITY_INVALID`.
3. Root cause: only the leaf certificate was being served, no chain. Importing the intermediate as a separate "CA Certificate" object didn't fix it — that only affects what FortiGate *trusts*, not what it *presents*.
4. Real fix: built a proper bundle (leaf + intermediate chain concatenated) and imported that as the Local Certificate instead.
5. Chain confirmed correct via `openssl s_client`, but the browser *still* showed the old certificate.
6. Investigated: `get system global | grep admin-server-cert` (using `get`, not `show`, which only displays non-default values) revealed the binding had silently never actually changed — still pointing at the factory `Fortinet_GUI_Server` the whole time, despite the `set` command appearing to succeed earlier.
7. Rebound correctly. Verified via a fresh Incognito browser window (normal windows were showing stale TLS session cache).

**Full detail:** `Labs/Lab-01-Mikrotik-Core/Devices/FGT01-NS-Firewall/Changes/MC-0001-FGT01-Lab-CA-Certificate-Installation.md`

---

## Part 2 — MikroTik Certificate, Round 1 (CM-0007)

**Goal:** Install a Lab CA-issued certificate on MikroTik's `www-ssl` service.

**What happened:** Installed cleanly — RouterOS parsed the bundle into three trusted certificate objects, chain served correctly. Genuinely no drama this time.

**But:** browser test revealed `This server could not prove that it is 10.10.0.1; its security certificate is from mikrotik.lab` — a real, separate finding. The certificate's SAN listed `10.0.0.1` and `172.31.4.144` — both stale, pre-VLAN-migration addresses. The install process worked; the certificate's own data was simply out of date.

**Full detail:** `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0007-Install-Lab-CA-Certificate-on-MikroTik.md`

---

## Part 3 — The Reissuance Guide (042)

Before fixing the stale SAN, wrote `042-Certificate-Reissuance-and-Renewal-Guide.md` — a general reference distinct from the original issuance runbook, covering: why you can't edit a certificate (only replace it), when to reuse a key vs. generate a new one, and the actual reissue process.

---

## Part 4 — MikroTik Certificate, Round 2 — The Real Diagnostic Saga (MC-0002, CA-Wide Fix)

This is the big one. What started as "reissue one certificate with a corrected SAN" uncovered a defect in the Lab CA itself.

**What actually happened, in order:**
1. Generated a new CSR with the correct SAN (`10.10.0.1`) — but left **Common Name blank** at the interactive prompt.
2. Sign attempt failed: `The commonName field needed to be supplied and was missing`. No certificate written — correctly refused, not a bug.
3. Regenerated with CN supplied (`mikrotik.lab`) this time. Sign appeared to succeed cleanly.
4. **Verified the actual file anyway, per habit** — and the SAN was completely empty. Not stale, *missing entirely*.
5. Investigated the CA config directly: `copy_extensions` was **not set anywhere** in `[ CA_default ]`. This is what silently discards any SAN requested via `-addext`, regardless of how correctly the CSR is built.
6. **This meant the defect wasn't new — it's been present since the Lab CA was originally built.** Every certificate this CA has ever issued under the `server_cert` profile may have been affected.
7. Added `copy_extensions = copy` to the config. First attempt landed it in the wrong section (`[ ca ]` instead of `[ CA_default ]`) due to a line-number assumption that turned out wrong. Corrected using a content-anchored edit instead, verified the final placement directly.
8. **Mid-fix, a naming idea surfaced** (using `atlas.lab` as a consistent domain suffix for every device instead of bare `.lab` names). Deliberately **not** implemented then — captured as `ADR-0007`, deferred, so it didn't turn one active fix into two simultaneous ones.
9. Regenerated CSR again, CN supplied correctly this time. Signing failed again — but with a *new*, different error: `ERROR: There is already a certificate for .../CN=mikrotik.lab`. The Step 3 certificate (the broken, SAN-less one) had actually been issued successfully and was sitting in the CA's database as a valid entry — the CA correctly refused to issue a second one for the same identity.
10. **Revoked the broken certificate** (`openssl ca -revoke`, serial `1000`), regenerated the CRL.
11. Reissued successfully — **new serial `1001`**, SAN verified correct on the file: `DNS:mikrotik.lab, IP Address:10.10.0.1`.
12. Rebuilt the bundle, staged for retrieval, moved to `C:\Temp` on the Windows workstation this time (not the Git repo — lesson already learned from MC-0001).
13. WinBox upload failed with a permissions error — fixed by running WinBox as Administrator.
14. Removed the old broken certificate objects before importing the new bundle (avoiding the "two objects, ambiguous binding" trap).
15. Imported successfully — RouterOS renamed it to `mikrotik-bundle.crt_0`, same renaming behavior as predicted from the FGT01 work.
16. Bound to `www-ssl`. **Verified on the live-served connection**, not just the file: `openssl s_client ... | grep SAN` confirmed `DNS:mikrotik.lab, IP Address:10.10.0.1` being actually served.

**Real finding, flagged but not yet resolved:** Pi-hole's and FortiGate's original certificates have never had their SAN independently re-verified against this same `copy_extensions` gap. FortiGate's only "passed" because no browser warning appeared — which isn't the same as directly confirming it.

**Full detail:** `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`

---

## Part 5 — DNS Records Were Also Stale (Folded into CM-0008)

While fixing MikroTik's DNS record, discovered:
1. Editing `/etc/pihole/custom.list` had **no effect at all** — this Pi-hole v6 install actually reads local DNS from an embedded `hosts` array inside `/etc/pihole/pihole.toml`. `custom.list` is inert for this purpose.
2. Once looking at `pihole.toml` directly, found **two more stale records**, not just MikroTik's: `pihole.lab` pointed at its own old pre-VLAN address, and `proxmox.lab` pointed at an address that was never PVE01's real one at all.
3. Corrected all three in `pihole.toml`, confirmed each via `dig`.

**Full detail:** `Labs/Lab-01-Mikrotik-Core/Devices/MKT01-Core-Router/Changes/CM-0008-Reissue-MikroTik-Certificate-Correct-SAN.md`

---

## Part 6 — Pi-hole's Own Certificate Was Never Actually the Lab CA's

While checking Pi-hole's own certificate SAN (part of following up on the `copy_extensions` finding), discovered something bigger: **Pi-hole has never used the Lab CA certificate at all.** `/etc/pihole/tls.crt` has `issuer=CN=pi.hole, O=Pi-hole, C=DE` — Pi-hole's own factory self-signed certificate. Every prior Build Record and Build Guide claim that Pi-hole was "in active use" with the Lab CA cert was wrong, from the original build through this session, until caught and corrected here.

**Corrected in:** `029-Pi01-Build-Record.md`, `031-Pi01-Lab-CA-Build-Guide.md`

---

## Part 7 — Switched the Workstation to Pi-hole DNS

Deliberate, scoped decision: workstation only, Pi-hole as primary DNS, `1.1.1.1` as secondary fallback — not a full network cutover, and specifically not every device on VLAN 10. Reasoning: Pi01 had a hard-hang incident earlier this same session requiring a physical power cycle, so making it a single point of failure for the whole network's DNS wasn't the right call yet. Confirmed working — `nslookup` showed `Server: pi.hole` actually answering queries, all three local records resolving correctly, external resolution still working through Pi-hole's forwarding.

---

## Part 8 — Vaultwarden Made Production-Ready

**Goal:** Get Vaultwarden to a real, usable state, specifically so the CA passphrases (the thing that started this whole session) would have somewhere real to live.

**What actually happened, in order:**
1. Issued `vault.lab` a proper Lab CA certificate (with the now-fixed `copy_extensions` config) — SAN verified correct on the first attempt this time, applying the lesson from Part 4.
2. Added the `vault.lab` DNS record.
3. Installed nginx as a reverse proxy — Vaultwarden's own container stays on `127.0.0.1:8222`, nginx terminates real TLS in front of it.
4. First nginx start failed: `port 80 is already in use` — Pi-hole's own web server (`pihole-FTL`) already owns ports 80 and 443. Confirmed directly via `ss -tulnp` rather than assumed.
5. Moved Vaultwarden's HTTPS to port `8443` instead of contesting Pi-hole for 443 — a deliberate, pragmatic choice; untangling Pi-hole's own web config is separate, bigger work for another time.
6. Second failure: nginx's own **default site** (a leftover from installation, unrelated to Vaultwarden) was also trying to bind port 80. Removed it.
7. nginx confirmed running clean on `8443`.
8. Rebuilt the Vaultwarden container with `DOMAIN=https://vault.lab:8443`.
9. Successfully loaded the real site over real HTTPS.
10. Rotated the admin token — the old one had only ever been valid for a localhost-only setup; generated a fresh Argon2id hash, recreated the container with it, confirmed clean startup with no insecure-token warning.
11. Logged into the admin panel with the new token, confirming the rotation actually took effect.
12. Created a real account, real master password — Vaultwarden is now genuinely in use.

---

## Part 9 — The Actual Original Goal: CA Passphrase Rotation

With Vaultwarden finally ready, re-encrypted both CA private keys:

> 🔴 **CORRECTION — `CM-0010`, 2026-07-14. Step 1 below is the defect, not a precaution.**
>
> ***"Backed up both key files first"*** created **`root/private/ca.key.pem.bak-2026-07-12`** and **`intermediate/private/intermediate.key.pem.bak-2026-07-12`** — **two copies of the CA private keys, still encrypted under the OLD, EXPOSED passphrase**, sitting beside the new ones at `0600`.
>
> **They were never deleted by this session.** They survived **fifteen hours**, and they were **swept into `pi01-full-backup-2026-07-12.tar.gz`** and copied to `E:\` — so the exposed keys went **off-device** before anyone noticed. `CM-0010` found them, verified them, and destroyed them with `shred -u`.
>
> **A third file was found the same way:** `intermediate/openssl.cnf.bak-2026-07-12` — no key material, but the **pre-`copy_extensions`** config. Restoring it would **silently reintroduce the SAN defect** that `MC-0002` exists to fix. **Three `.bak` files from one date is a habit, not an accident.**
>
> 🔴 **The rule this establishes:** **a rotation is not complete until the pre-rotation copies are destroyed.** Backing up a key before re-encrypting it is *correct*. **Leaving the backup is the whole vulnerability, restored.** The narrative in this document is entirely truthful and still left two exposed keys on disk — **because a narrative has no line that asks *"and did you destroy them?"*** That is why `CM-0010` is a Change Record with a closeout, and this is a summary.
>
> **Correct procedure: `031-Pi01-Lab-CA-Build-Guide.md` v0.5 and `049-Root-CA-and-Credential-Backup-Runbook.md`.**

1. Backed up both key files first. 🔴 **← THIS. See the correction above. The `.bak-2026-07-12` files created here were destroyed by `CM-0010` on 2026-07-13.**
2. Root key: decrypted with the old (exposed) passphrase, immediately re-encrypted with a new one (`openssl rsa -aes256`).
3. **Verified the new passphrase actually worked** (`openssl rsa -check -noout`) before replacing the live file — not just assumed the command succeeding meant it was correct.
4. Repeated for the Intermediate key.
5. Both new passphrases stored in Vaultwarden.
6. Old plaintext desktop file — flagged for permanent deletion, not just Recycle Bin.

---

## Part 10 — FreeRADIUS Secret Rotation and the MikroTik RADIUS Investigation (CM-0002)

**Goal:** Rotate the `fortigate`, `mikrotik`, `localhost`, and `localhost_ipv6` RADIUS secrets — all effectively compromised since they'd been exposed in a chat session log previously.

**What actually happened, in order:**
1. Generated four new secrets in Vaultwarden.
2. Discovered the `laptop`/`fortigate`/`mikrotik` client IP addresses in `clients.conf` were **already correct** — that part of the original plan had apparently already been fixed at some point before this session, even though the compromised secrets themselves were still the exact same exposed values from the original incident.
3. Discovered the `testing123` default secret actually belonged to **`localhost_ipv6`**, not plain `localhost` as originally assumed — the two are separate blocks, and the plain `localhost` block's own secret had never actually been directly confirmed until checked properly this session.
4. Updated all four secrets, plus enabled `require_message_authenticator = yes` on the `localhost` block (previously commented out, inconsistent with every other client).
5. Restarted FreeRADIUS, confirmed healthy.
6. **FortiGate side:** created a new RADIUS server entry (`Pi01-RADIUS`), tested connectivity, then tested with real credentials (`testing`/`password`) — full success, confirmed via the actual RADIUS reply payload (`Reply-Message: 'Hello, testing'`).
7. **MikroTik side — the longer investigation:**
   - `/radius print detail` showed **zero entries** — MikroTik had never actually had a RADIUS client configured at all, despite Pi01's `clients.conf` having a `mikrotik` block the whole time. Only one side of the integration had ever been finished.
   - Created a RADIUS entry. Test failed.
   - A second local account (`SethAdmin`) was also failing to log in — investigated separately, turned out to be a genuinely stale/never-set password, unrelated to RADIUS. Fixed independently.
   - Checked `/radius print detail` again — **two** RADIUS entries now existed: the one just created, and an older pre-existing one (commented `;;; PiHole`) that had apparently been sitting there from some earlier point, likely still holding the old, compromised secret.
   - Set the new secret explicitly on the pre-existing entry, removed the redundant duplicate.
   - Test still failed.
   - Checked `/user aaa print` — **`use-radius: no`.** This was the actual root cause the whole time: MikroTik was never configured to consult RADIUS for any login at all, regardless of how correct every other piece was.
   - Set `use-radius=yes`. Checked again immediately after — **still showed `no`**, meaning the first `set` command hadn't actually persisted (echoing the exact same "a command succeeding isn't proof it worked" lesson from MC-0001 and MC-0002).
   - Ran it again, verified immediately after — this time it took.
   - Retested `testing`/`password` — **success.**

**Status:** FreeRADIUS secrets rotated on Pi01, FortiGate integration fully tested and confirmed, MikroTik integration built from scratch (it never actually existed before) and confirmed working. This closes CM-0002.

---

## The Pattern That Shows Up Repeatedly Across This Entire Session

Worth naming directly, since it's the single most valuable lesson across all ten parts above: **a command completing without an error is not the same as a confirmed, active change.** This showed up as the actual root cause at least five separate times tonight — FGT01's unbound admin certificate, MikroTik's empty SAN after an apparently-clean sign, the misplaced `copy_extensions` line, the DNS record that "saved successfully" but wasn't read from the right file, and `use-radius` failing to persist on the first attempt. Every one of these was only caught by directly checking the actual resulting state afterward, not by trusting that a lack of error output meant success.

## Full Index of Everything Touched This Session

**Change Records:**
- `MC-0001-FGT01-Lab-CA-Certificate-Installation.md`
- `CM-0005-Install-Lab-CA-Certificate-on-FGT01.md` (superseded by MC-0001)
- `CM-0004-Disable-Unused-FGT01-Interfaces.md`
- `CM-0006-Disable-MikroTik-Reverse-Proxy.md`
- `CM-0007-Install-Lab-CA-Certificate-on-MikroTik.md`
- `CM-0008-Reissue-MikroTik-Certificate-Correct-SAN.md`
- `MC-0002-MikroTik-Certificate-Reissuance-and-CA-Fix.md`
- `CM-0002-Pi01-FreeRADIUS-Client-Correction.md`
- `CM-0001-SW01-Gi1-0-1-Description-Fix.md`
- `CM-0003-Disable-SW01-Gi1-0-3.md`

**Decisions:**
- `ADR-0003-AD-CS-vs-OpenSSL-Lab-CA.md` — coexist decision, directly informed which CA every device tonight used
- `ADR-0005-FGT01-Firewall-Policy-Scope-Deferred.md`
- `ADR-0007-Adopt-atlas-lab-Domain-Suffix.md` — deferred naming idea, captured mid-session

**Build Guides / Records updated:**
- `031-Pi01-Lab-CA-Build-Guide.md` — `copy_extensions` fix, CN/SAN gotchas, Pi-hole cert correction
- `029-Pi01-Build-Record.md` — CA config change, certificate status corrections, DNS record corrections
- `021-FGT01-Build-Record.md`
- `022-MKT01-Build-Record.md`

**Operations Guides:**
- `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`
- `042-Certificate-Reissuance-and-Renewal-Guide.md`
- `037-FGT01-Troubleshooting-Guide.md`
- `038-Pi01-Troubleshooting-Guide.md`
- `041-MKT01-Troubleshooting-Guide.md`
- This document

## Related Pages

- `00-Atlas-Foundation/Atlas-Charter.md` — `DR-001` and the "Future Seth" completion bar, directly relevant to why this document exists
