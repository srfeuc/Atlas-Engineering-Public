---
Title: SRV01 Build Guide (Network Services — nginx CRL/AIA host first) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services
Status: 🟡 Target Design — authored, NOT executed. Runs per POL-0001 (verify on the device; evidence = command + output). GUI-primary for the Proxmox clone; CLI in-guest (Linux). Executable companion to `Build-Checklist.md`.
Version: 0.2
Date: 2026-07-23
---

# SRV01 — Build Guide (Network Services)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — **Ubuntu Server** clone of `TPL-UBUNTU2604` (guide `220`) on PVE01, VLAN 20, `10.20.0.10/26` gw `10.20.0.1` DNS `10.20.0.2` (`IP-Addressing-Plan-VLSM` v1.1). **Role:** the network-services host. This guide stands up the **first and gating** role — the **nginx CRL/AIA host** serving `http://pki.atlas.lab/pki/`, the endpoint the two-tier AD CS build (`ADR-0027`/`ADR-0028`) publishes revocation to. The other services (**Oxidized→git, rsyslog relay, TFTP/SFTP**) are scoped in `Build-Checklist.md` and deferred here (Part 6) — they are not on the PKI critical path. 🔴 **DHCP moved to DC01 (`ADR-0030`) and FreeRADIUS retired (`ADR-0029`)** — neither is an SRV01 role anymore.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 **Target Design — not built.** Nothing here is device-verified. Every `[ ]` becomes `[x]` only with a command + its output (`POL-0001` R-A1). |
| Version | 0.1 |
| Applies To | **SRV01** (Ubuntu Server 26.04 LTS, clone of `TPL-UBUNTU2604`, domain **not** joined — a Linux member of the estate by IP/DNS only) |
| Governs | The `pki.atlas.lab` CRL/AIA web host (this guide's primary deliverable) + the SRV01 service estate (Part 6, deferred). Executable companion to `Build-Checklist.md` (v1.0); reconciles that checklist's OS to **Ubuntu** (see 🔴 note below). |
| Reference | [RFC 2585 (pkix-cert / pkix-crl media types)](https://www.rfc-editor.org/rfc/rfc2585.txt) · [Microsoft — Configure the CDP and AIA extensions](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/configure-the-cdp-and-aia-extensions-on-ca1) · [nginx docs](https://nginx.org/en/docs/) · [Ubuntu Server docs](https://ubuntu.com/server/docs) · [Proxmox Cloud-Init](https://pve.proxmox.com/wiki/Cloud-Init_Support) |
| Governing Policy | `POL-0007` (hardening), `POL-0001` (evidence), `POL-0002` (secrets → Vaultwarden), `POL-0008` (one source per fact) |

> 🔴 **The one job this guide gates (`ADR-0009`).** AD CS puts `http://pki.atlas.lab/pki/…` into every issued certificate's **CDP** (CRL Distribution Point) and **AIA** (Authority Information Access) extension. If this host does not serve those files, **revocation reaches nothing and chains can't be built** — the exact defect the OpenSSL CA shipped (`ADR-0009`: *"a revocation nobody checks is a filing action, not a security control"*). This guide is not "done" until AD CS **Part 4** observes a revoked cert being rejected *through this endpoint*. That gate is mandatory.

> 🔴 **Identity comes from cloud-init, never baked (`220` discipline).** SRV01's hostname / IP / SSH key / user are injected per-clone by cloud-init. Do **not** hand-edit a static IP into the template's netplan — that's the `10.10.0.50` overlap scar. The template is generic; **role config (nginx, the `80/tcp` firewall opening) lives here on the clone**, not in the image.

> ✅ **OS reconciliation RESOLVED (`POL-0008`, #22 audit 2026-07-30).** Every Linux box is standardized on **Ubuntu Server 26.04 LTS** (`TPL-UBUNTU2604`, guide `220`). The stale *Debian / CIS-Debian* wording was reconciled to **Ubuntu** in **`Build-Checklist.md` v1.1 (2026-07-23)** — this guide and the checklist now agree on OS = Ubuntu. (Control intent — CIS-lite, read-only Oxidized creds, the `033` no-`testing`-credential lesson — is unaffected.) Remaining: confirm the clone is Ubuntu at build (`POL-0001`).

> 🔴 **Not Tier 0 — but it serves Tier-0 data.** SRV01 sits in the **server range** (`10.20.0.10`), *not* the Tier-0 carve (`.2–.9` = DCs + CAs only, `IP-Addressing-Plan-VLSM`). It is a Tier-1 service host. What it publishes — CA certificates and CRLs — is **public by design** (anyone validating a cert must fetch them), so serving them over **plain HTTP** is correct and safe (see Part 3). SRV01 never holds a CA private key.

---

## Part 0 — Gate / pre-flight (do this first)

- [ ] **Template exists:** `TPL-UBUNTU2604` is a Proxmox template (`qm config <TPL-VMID>` → `template: 1`) and a throwaway clone came up with a unique machine-id + SSH host keys (guide `220` Part 6). *If `220` isn't device-verified yet, do it first — SRV01 clones from it.*
- [ ] **DNS record (`AD DNS on DC01`):** add `pki.atlas.lab` → **`10.20.0.10`** (A record) in DNS Manager on DC01. This is `AD-CS-Two-Tier-Build-Guide` §0.5 — the CDP/AIA host must resolve for *every* relying party. *(A record preferred over CNAME so it resolves cleanly for non-domain relying parties too.)*
  - ✅ read-back: `Resolve-DnsName pki.atlas.lab` (from a domain member) and `nslookup pki.atlas.lab 10.20.0.2` → `10.20.0.10`.
- [ ] **DC01 reachable** for DNS (`10.20.0.2`) from VLAN 20.
- [ ] **PVE01 capacity** confirmed (guide `220` prereq: ~597 GB free on `local-lvm`, 2026-07-22 — ample).
- [ ] **Break-glass first (`Device-Hardening-Standard` Part A):** SRV01's recovery path is the **Proxmox noVNC/SPICE console** (network-independent). Confirm you can open it *before* any hardening that could lock out SSH.
- 💡 **Snapshot points** (`218-VM-Snapshot-and-Naming-Convention`): `clean-base-<date>` right after the clone boots and identity verifies; `pre-harden-<date>` before Part 5.

---

## Part 1 — Clone the template + assign identity (Proxmox GUI-primary)

> Clone `TPL-UBUNTU2604`, then let **cloud-init** write SRV01's identity on first boot. Nothing per-clone is baked into the template (`220` Part 6).

### 1.1 Full clone
- [ ] **PVE UI:** right-click `TPL-UBUNTU2604` → **Clone** → **Full Clone** → Name `srv01`, target storage `local-lvm`. *(CLI: `qm clone <TPL-VMID> <SRV01-VMID> --name srv01 --full 1`.)*
  - 🔴 **Full**, not Linked — SRV01 is a standing production host, not a throwaway; it must not depend on the template's disk.
- [ ] **NIC on VLAN 20:** VM → Hardware → Network Device → **VLAN Tag = 20**, model **VirtIO (paravirtualized)**, bridge = the PVE trunk (as DC01). *(The `220` template is VirtIO SCSI + VirtIO net — Linux has native drivers.)*

### 1.2 Cloud-Init identity
- [ ] **PVE UI → VM `srv01` → Cloud-Init**, set:
  - **User** `ciuser` = a named admin (e.g. `srvadmin` — document it; `POL-0002` no shared secret in the image).
  - **SSH public key** = your admin key (public only — 🔴 never a private key in the image).
  - **IP Config (net0):** `IP=10.20.0.10/26`, `Gateway=10.20.0.1`.
  - **DNS servers** = `10.20.0.2` ; **DNS domain** = `atlas.lab`.
  - *(CLI equivalent — verify flag spelling against your Proxmox version, the `220` §2.4 caveat: `qm set <SRV01-VMID> --ciuser srvadmin --sshkeys <file> --ipconfig0 ip=10.20.0.10/26,gw=10.20.0.1 --nameserver 10.20.0.2 --searchdomain atlas.lab`.)*
- [ ] Boot the VM.

### 1.3 🔴 Verify the identity regenerated uniquely (POL-0001 — the whole point of `220`)
From the Proxmox console or SSH, capture:

```bash
hostnamectl                 # Static hostname = srv01
ip -br a                    # 10.20.0.10/26 on the VLAN-20 NIC, no leftover template IP
cat /etc/machine-id         # non-empty, DIFFERENT from the template/source machine-id
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub   # a fresh, unique fingerprint
cloud-init status           # done
resolvectl status | grep -i 'DNS Servers\|Current DNS'   # 10.20.0.2
systemctl is-active qemu-guest-agent                     # active (PVE Summary shows the guest IP)
ping -c2 10.20.0.1 ; ping -c2 10.20.0.2                   # gateway + DNS reachable
```

- [ ] Read-back captured: unique `machine-id` + host keys, correct IP/DNS/hostname, agent active, gateway/DNS reachable. **Snapshot `clean-base-<date>`.**

---

## Part 2 — Base state + role firewall (open 80 for CRL fetch)

The template already ships patched, SSH keys-only, `unattended-upgrades`, `qemu-guest-agent` (guide `220` Part 2). Confirm, then add the **role-specific** firewall (this is deliberately *not* in the template).

- [ ] **Confirm inherited baseline:**
  ```bash
  apt list --upgradable            # nothing held back (patched at image time; unattended-upgrades keeps it so)
  systemctl is-enabled ssh unattended-upgrades qemu-guest-agent
  sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin'   # no / prohibit-password
  ```
- [ ] **Host firewall (ufw) — role rule:**
  ```bash
  sudo apt install -y ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow from 10.10.0.0/27 to any port 22 proto tcp   # SSH from the MGMT VLAN only (scope it)
  sudo ufw allow 80/tcp                                       # HTTP CRL/AIA — must be reachable estate-wide
  sudo ufw enable
  sudo ufw status verbose
  ```
  - 🔴 **Scope SSH to the management source subnet** (`Device-Hardening-Standard` Part B, step-3 "access-removing"). **Do NOT scope `80/tcp`** — every relying party that validates a cert (DCs, FortiGate, later MikroTik, clients) must be able to GET the CRL. Public data, open port.
  - 🔴 Include the subnet you are *actually* SSH-ing from in the `port 22` allow, or you lock yourself out — the Proxmox console (Part 0) is the recovery if you do.

---

## Part 3 — 🎯 nginx CRL/AIA host (the gating deliverable)

> Serve the CA certificates and CRLs at `http://pki.atlas.lab/pki/` with the **correct media types** so Windows and non-Windows relying parties both fetch and parse them. **HTTP, not HTTPS** — deliberately (see the note).

> 🔴 **Why plain HTTP (not TLS).** CDP/AIA URLs are fetched *during* certificate validation. Serving them over HTTPS creates a chicken-and-egg (validating the CRL's own server cert would itself need a CRL fetch), so the entire PKI world publishes revocation over **HTTP** — Microsoft's own CDP/AIA example URLs are `http://…` ([Configure the CDP and AIA extensions](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/configure-the-cdp-and-aia-extensions-on-ca1)). The content is integrity-protected by the CA's signature on each CRL/cert, not by transport TLS. This is the one place in the estate where HTTP is the correct answer.

### 3.1 Install nginx + create the web root
```bash
sudo apt install -y nginx
sudo mkdir -p /var/www/pki
sudo chown -R www-data:www-data /var/www/pki
sudo chmod 755 /var/www/pki
```

### 3.2 Server block with the correct media types (RFC 2585)
Create `/etc/nginx/sites-available/pki.atlas.lab`:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name pki.atlas.lab;

    root /var/www/pki;

    # RFC 2585 media types — so relying parties parse the DER correctly.
    # AD CS emits .crl (CRLs) and .crt (CA certs); map both explicitly.
    types {
        application/pkix-crl   crl;
        application/pkix-cert  crt cer;
    }
    default_type application/octet-stream;

    location /pki/ {
        autoindex on;                 # optional: lets you eyeball what's published (safe — public data)
        add_header Cache-Control "no-cache, must-revalidate";   # don't let a stale CRL be cached past its nextUpdate
    }

    access_log /var/log/nginx/pki.access.log;
    error_log  /var/log/nginx/pki.error.log;
}
```

Enable it:
```bash
sudo ln -s /etc/nginx/sites-available/pki.atlas.lab /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default      # drop the stock default vhost
sudo nginx -t                                    # syntax OK
sudo systemctl reload nginx
```

- 🔴 **Media type matters.** `application/pkix-crl` (`.crl`) and `application/pkix-cert` (`.crt`/`.cer`), both DER, are defined by [RFC 2585](https://www.rfc-editor.org/rfc/rfc2585.txt). Serving a CRL as `text/plain` or `octet-stream` makes some relying parties refuse it — set the `types{}` block.
- `Cache-Control: no-cache` avoids an intermediate cache pinning an old CRL past its `nextUpdate` (a subtle revocation-freshness trap).

### 3.3 Publish the CA files (this is AD CS §2.7 landing here)
Copy the files AD CS produces into `/var/www/pki/` (via SFTP/scp — see 🔴 filename note):

- **From RCA01** (`AD-CS-…` §1.5): the **root** CA cert + root CRL.
- **From ICA01** (`AD-CS-…` §2.7): the **issuing** CA cert + its **base** CRL (+ **delta** CRL).

```bash
# after copying the files up (e.g. to /home/srvadmin/pki-drop/):
sudo cp /home/srvadmin/pki-drop/*.crl /home/srvadmin/pki-drop/*.crt /var/www/pki/
sudo chown www-data:www-data /var/www/pki/*
sudo chmod 644 /var/www/pki/*
ls -l /var/www/pki/
```

- 🔴 **Read the real filenames off CertEnroll — don't assume them (`POL-0001`).** AD CS builds names from the CA common name via `certutil` variables `%3` (CaName) `%8` (CRLNameSuffix) `%1` (ServerDNSName) `%4` (CertificateName). With CNs *"Atlas Root CA"* / *"Atlas Issuing CA"* the files will contain **spaces** (e.g. `Atlas Issuing CA.crl`) and the **delta** CRL a `+` (e.g. `Atlas Issuing CA+.crl`). Those are legal filenames; over HTTP the space is `%20` in the URL and nginx serves them literally. **Copy whatever actually appears in `C:\Windows\System32\CertSrv\CertEnroll\`** — match the CDP/AIA strings in the AD CS guide byte-for-byte rather than typing a guessed name. *(If the encoded names bother you, the clean fix is a spaceless CA CN — but that's an AD CS-side decision made before the root ceremony, not here.)*

### 3.4 ✅ Prove it serves correctly (POL-0001)
```bash
# On SRV01:
curl -sI http://localhost/pki/ | head
# From a relying party (e.g. DC01 or a client), fetch a CRL and check the content-type + that it parses:
curl -sI  http://pki.atlas.lab/pki/                       # 200; server reachable by name (DNS + firewall OK)
curl -s   "http://pki.atlas.lab/pki/Atlas%20Issuing%20CA.crl" -o test.crl   # use the REAL filename
```
```powershell
:: On a Windows relying party — the authoritative revocation read-back:
certutil -URL test.crl              :: GUI URL-fetch tool: CDP/AIA "Verified"
certutil -f -urlfetch -verify <a-cert-issued-by-ICA01>.cer   :: chain + revocation reach = OK
```

- [ ] `curl -sI` shows **`Content-Type: application/pkix-crl`** for a `.crl` and **`application/pkix-cert`** for a `.crt`.
- [ ] From a relying party, the CRL/cert **download by the `pki.atlas.lab` name** (proves DNS + firewall + nginx together).
- [ ] `certutil -f -urlfetch -verify` on a real ICA01-issued cert shows the CDP/AIA URLs resolving (**this is the input to AD CS Part 4**).

---

## Part 4 — Publishing workflow + the offline-root CRL refresh (operational)

The endpoint is only as good as the freshness of what's on it. Two publishers land here:

- **ICA01 (online, automatic-ish):** the issuing CA re-publishes its base/delta CRL to its local `CertEnroll` on the `CRLPeriod`/`CRLDeltaPeriod` cadence (base 1 wk / delta 1 day, per the AD CS guide §2.6). Get that CRL onto `/var/www/pki/` — either (a) a scheduled `scp`/SFTP push from ICA01, or (b) map this web root as the CA's HTTP publish target. Document which you chose; verify a fresh CRL's `nextUpdate` advances.
- **RCA01 (offline, manual — 🔴 the trap):** the **root CRL is published every ~26 weeks by hand** (the root is powered off between ceremonies, AD CS §1.4/§2.7). 🔴 **If the root CRL expires and nobody re-copies it, EVERY chain validation fails estate-wide** — the whole PKI goes dark on a silent timer. Set a hard calendar reminder *and* monitor the file's `nextUpdate`.

```bash
# Quick freshness check you can run / alert on (reads nextUpdate off the published CRLs):
for f in /var/www/pki/*.crl; do echo "== $f"; openssl crl -inform DER -in "$f" -noout -lastupdate -nextupdate; done
```

- [ ] Publishing path for the **issuing** CRL chosen + documented; a fresh CRL observed landing here.
- [ ] **Root-CRL refresh reminder** created (calendar/task) with the ~26-week cadence; `nextUpdate` monitored. *(Later: fold this into MON01 alerting, Phase 6.)*

---

## Part 5 — Pass-1 hardening (inherit `Device-Hardening-Standard`)

SRV01 executes the **device-agnostic Pass-1 checklist** in the recovery-first order — it does not re-derive it (`POL-0008`). Recovery path = the **Proxmox console** (proven in Part 0).

- [ ] **Break-glass proven first** (Part 0) — before any access-removing step.
- [ ] **Named admin** (the cloud-init `ciuser`), **SSH keys only** (inherited from `220`); confirm `sudo sshd -T`.
- [ ] **Management scoped:** SSH `22/tcp` allowed **only** from the MGMT subnet (Part 2). `80/tcp` intentionally estate-wide (CRL/AIA is public).
- [ ] **Unused services off:** this is a single-purpose box for now — `sudo ss -tlnp` should show **only** sshd and nginx (:22, :80). Anything else, justify or disable.
- [ ] **Automatic security updates** on (inherited `unattended-upgrades`).
- [ ] **NTP synced** (`ADR-0020`): `timedatectl` → `System clock synchronized: yes`. *(Base image uses `systemd-timesyncd`; if Atlas standardizes chrony→Pi01/DC, apply per role — verify by the runtime clock, not the config line: the `045` false-tick.)*
- [ ] **No secrets in the repo** (`POL-0002`) — nothing on SRV01 that this guide records goes to git as cleartext; admin/key material → Vaultwarden.
- [ ] **Encrypted backup** enrolled once BKP01/PBS exists (Phase 9) — snapshots are not backups (`218`).

*(Full control mapping / *why* belongs in a `CIS-Hardening-SRV01.md` when written — this guide is the *how-order*, matching the FGT01 model in `Device-Hardening-Standard`.)*

---

## Part 6 — Deferred service roles (scoped in `Build-Checklist.md`, not on the PKI critical path)

Authored here as pointers so the sequence is explicit; each gets its own section/guide when built. **Do not** let these block the CRL host (Parts 1–4), which is what AD CS is waiting on.

- **~~Kea DHCP~~ → moved to DC01 (`ADR-0030`).** SRV01 no longer runs DHCP. Windows DHCP runs on **DC01** (fewer VMs; DC02 hot-standby later), with a **RouterOS DHCP relay on MKT01 → `10.20.0.2`** per served VLAN. Scopes live in `IP-Addressing-Plan-VLSM` / `DC01-Build-Guide` (Clients `10.50.0.21–.126`, Deployment, Testing; 🔴 no DHCP on OT; infra static).
- **Oxidized → git** — pull running-configs from SW01/FGT01/MKT01/1941 on a schedule, commit to git (drift = a visible diff). 🔴 **Read-only** device accounts; credentials **vaulted** (Vaultwarden), never cleartext in the Oxidized config (`POL-0002`). Device list ideally from **NetBox** (`POL-0004`) — soft-gated on NetBox (Phase 3).
- **rsyslog relay** — device logs + SRV01's own → **MON01** (Phase 6).
- **TFTP / SFTP** — `tftpd-hpa` for IOS image/config transfer; SFTP as the secure equivalent (prefer it for anything sensitive).
- **~~FreeRADIUS~~ → retired (`ADR-0029`).** SRV01 does not run FreeRADIUS. Network-device RADIUS = **NPS on `NPS01`** (member server); FGT01 = direct LDAPS (`ADR-0028`). *(The `033` `testing`/`testing123` stock-credential lesson moves to the `NPS01` build — do NOT recreate that account there.)*

---

## Validation — read the state back

- [ ] **Identity (Part 1):** unique `machine-id` + SSH host keys; `hostnamectl` = `srv01`; `ip -br a` = `10.20.0.10/26`; `cloud-init status` = done.
- [ ] **Firewall (Part 2):** `ufw status` → `22/tcp` from MGMT only, `80/tcp` open; `ss -tlnp` shows only sshd + nginx.
- [ ] **CRL host (Part 3):** `curl -sI http://pki.atlas.lab/pki/<real>.crl` → `200` + `Content-Type: application/pkix-crl`; a Windows relying party's `certutil -URL`/`-urlfetch -verify` reaches the CDP/AIA.
- [ ] **Freshness (Part 4):** `openssl crl -inform DER -noout -nextupdate` on each published CRL shows an un-expired `nextUpdate`; root-CRL refresh reminder exists.
- [ ] **Hardening (Part 5):** break-glass (Proxmox console) re-verified *after* lockdown; NTP synced; SSH keys-only.
- [ ] 🎯 **The real gate lives in AD CS Part 4** — a revoked test cert is *observed* rejected through this endpoint. SRV01 is "done" for PKI purposes only when that passes.

## Common mistakes

- 🔴 **Serving CRLs over HTTPS** — creates the chicken-and-egg (the CRL server's own cert needs a CRL check). CDP/AIA is HTTP by design; integrity comes from the CA signature, not TLS.
- 🔴 **Wrong media type** — a CRL served as `text/plain`/`octet-stream` is rejected by some relying parties. Set the RFC 2585 `types{}` block (`application/pkix-crl`, `application/pkix-cert`).
- 🔴 **Guessing the CA filenames** — they contain spaces (and a `+` for delta) from the CA CN. Copy exactly what `CertEnroll` emits; match the CDP/AIA strings byte-for-byte (`POL-0001`), or the URL 404s and revocation silently fails (`ADR-0009`).
- 🔴 **Baking a static IP into the clone / editing the template's netplan** — the `10.10.0.50` overlap scar. Identity is cloud-init only (`220`).
- 🔴 **Scoping `80/tcp`** the way you scope SSH — relying parties across every VLAN must fetch the CRL; keep `80` estate-wide (it's public data), scope `22` only.
- 🔴 **Letting the offline root CRL expire** — silent estate-wide validation failure on a 26-week timer. Reminder + `nextUpdate` monitor.
- 🔴 **`pki.atlas.lab` unresolvable / on a box that reboots at the wrong time** — if the name doesn't resolve or the host is down when the root re-publishes, CDP/AIA breaks. Keep SRV01 up; A record in AD DNS.

## Rollback

- **`clean-base-<date>` snapshot** (Part 1) = the fresh, identity-verified clone before any role config. **`pre-harden-<date>`** (Part 5) = pre-lockdown. Roll back to these for a botched role/hardening step (`218`). The **Proxmox console** is the network-independent recovery if SSH is lost.
- SRV01 holds **no CA private key** — losing it is a rebuild-from-template + re-copy-the-published-files, not a trust-anchor event. The CA material lives on RCA01/ICA01 (backed up per `AD-CS-…` Part 5).

## Related

- `Build-Checklist.md` (this device — the service catalog; reconcile its OS to Ubuntu) · `Troubleshooting.md` (later)
- `Virtualization/Build-Guides/220-Prepare-the-Ubuntu-Golden-Image.md` (the template SRV01 clones) · `Reference/218-VM-Snapshot-and-Naming-Convention.md`
- `Devices/RCA01-ICA01-ADCS/AD-CS-Two-Tier-Build-Guide.md` (§0.5 the endpoint, §1.4/§2.6 the CDP/AIA strings, §2.7 what publishes here, **Part 4 the gate**)
- `Architecture/IP-Addressing-Plan-VLSM.md` (`10.20.0.10`; Kea scopes; MKT01 relay) · `Operations/Device-Hardening-Standard.md` (Pass-1 order; VM break-glass = Proxmox console)
- `ADR-0027`/`ADR-0028` (why this host is on the PKI critical path) · `ADR-0009` (the CRL-that-reached-nothing scar) · `ADR-0004` (NPS/RADIUS coexistence for Part 6 FreeRADIUS) · `ADR-0020` (NTP per role) · `Master-Build-Order.md` (SRV01 sequence)

## Sources (official — cited 2026-07-23, POL-0001)

Load-bearing external facts were confirmed live this session; the *sequence* is Atlas's synthesis. Device `[ ]`s remain unverified until run.

- **CRL / cert media types** (`application/pkix-crl` → `.crl`, `application/pkix-cert` → `.cer`, both DER): [RFC 2585 — X.509 PKI Operational Protocols: FTP and HTTP](https://www.rfc-editor.org/rfc/rfc2585.txt) (verified 2026-07-23).
- **HTTP CDP/AIA + the `<CaName><CRLNameSuffix>.crl` / `<ServerDNSName>_<CaName><CertificateName>.crt` filename templates** (matching the AD CS guide's `certutil %3%8` / `%1_%3%4` strings): Microsoft — [Configure the CDP and AIA extensions on CA1](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/configure-the-cdp-and-aia-extensions-on-ca1) (verified 2026-07-23; its example URLs are `http://…`).
- **nginx `types{}` / server block / `sites-enabled`**: [nginx documentation](https://nginx.org/en/docs/).
- **Clone → cloud-init identity injection**: [Proxmox VE Cloud-Init Support](https://pve.proxmox.com/wiki/Cloud-Init_Support) (carried from guide `220`, incl. the `--sshkey`/`--sshkeys` version caveat).
- **Ubuntu Server / ufw / netplan / systemd-timesyncd**: [Ubuntu Server docs](https://ubuntu.com/server/docs).

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.2 | 2026-07-28 | **Reconciled to ADR-0029/0030** (cascade from Master-Build-Order v1.6). Part-6 deferred roles: **Kea DHCP struck** (→ DC01, `ADR-0030`) and **FreeRADIUS struck** (→ retired, `ADR-0029`; RADIUS is NPS on `NPS01`); role summary + Oxidized vault ref (VAULT01→Vaultwarden) updated. nginx-CRL-host critical path (Parts 1–4) unchanged. |
| 0.1 | 2026-07-23 | Authored (not executed). SRV01 build guide, **nginx CRL/AIA host first** (the `ADR-0027`/`ADR-0028` critical-path deliverable): Part 0 gate (`TPL-UBUNTU2604` + the `pki.atlas.lab` A-record + Proxmox-console break-glass), Part 1 full-clone → **cloud-init identity `10.20.0.10`** + unique-identity read-back (`220` discipline), Part 2 base checks + **role firewall** (SSH scoped to MGMT, `80/tcp` estate-wide), Part 3 **nginx serving `http://pki.atlas.lab/pki/` with RFC 2585 media types**, HTTP-not-TLS rationale, and the 🔴 read-the-real-CertEnroll-filenames rule, Part 4 the **publishing workflow + offline-root 26-week CRL-refresh trap**, Part 5 Pass-1 hardening (inherits `Device-Hardening-Standard`; VM break-glass = Proxmox console), Part 6 deferred roles (Kea/Oxidized/rsyslog/TFTP-SFTP/FreeRADIUS as pointers). Reconciles the checklist's OS **Debian → Ubuntu** (`POL-0008`). Load-bearing facts (RFC 2585 media types; MS HTTP CDP/AIA + filename templates) verified live 2026-07-23. GUI-primary for the Proxmox clone; in-guest CLI alongside; every `[ ]` unverified pending the build (`POL-0001`). |
