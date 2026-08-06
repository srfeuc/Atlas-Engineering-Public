---
Title: NETBOX01 Build Guide (Source of Truth — IPAM/DCIM) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: 🟡 Target Design — authored, NOT executed. Runs per POL-0001 (verify on the device; evidence = command + output). GUI-primary for the Proxmox clone; CLI in-guest (Linux). Executable companion to `Build-Checklist.md`.
Version: 0.1
Date: 2026-07-23
---

# NETBOX01 — Build Guide (Source of Truth)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — **Ubuntu Server** clone of `TPL-UBUNTU2604` (guide `220`) on PVE01, VLAN 20, `10.20.0.11/26` gw `10.20.0.1` DNS `10.20.0.2` (`IP-Addressing-Plan-VLSM` v1.1). **Role (`Atlas-Service-Architecture` Part 3, `POL-0004`):** 🔴 **the single source of truth (IPAM/DCIM) — Phase 4 (Source of truth), built before the automation that renders from it (Phase 10).** Every downstream config renders **from** it. This is the structural fix for Atlas's most-repeated defect class (`006` hand-typed and wrong; Pi01 silently dropped from `STATIC-HOSTS`). It only works if configs are **generated** from NetBox, not typed alongside it.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 **Target Design — not built.** Nothing here is device-verified. Every `[ ]` becomes `[x]` only with a command + its output (`POL-0001` R-A1). |
| Version | 0.1 |
| Applies To | **NETBOX01** (Ubuntu Server 26.04 LTS, clone of `TPL-UBUNTU2604`, domain **not** joined; LDAPS-to-AD is a later phase) |
| Governs | The NetBox IPAM/DCIM host — install, the source-of-truth data load, and the "make it generate" payoff. Executable companion to `Build-Checklist.md` (v1.0); reconciles that checklist's OS to **Ubuntu** (see 🔴 note). |
| Reference | [NetBox installation docs](https://netboxlabs.com/docs/netbox/installation/) · [Proxmox Cloud-Init](https://pve.proxmox.com/wiki/Cloud-Init_Support) · [Ubuntu Server docs](https://ubuntu.com/server/docs) · [nginx docs](https://nginx.org/en/docs/) |
| Governing Policy | `POL-0004` (source of truth / generate-don't-type), `POL-0007` (hardening), `POL-0001` (evidence), `POL-0002` (secrets → Vaultwarden), `POL-0008` (one source per fact) |

> 🔴 **The one thing this host exists to get right (`POL-0004`).** NetBox is only a source of truth if **device configs are generated from it**. If you hand-type SW01's `STATIC-HOSTS`/DAI ACL *and* enter it in NetBox, you've rebuilt the `006` defect with extra steps. The proof it's real (Part 5) is an **empty diff** between a NetBox-rendered artifact and the live device. Until that diff exists, NetBox is just another table that will drift.

> 🔴 **Version drift is the norm here — pin, don't trust memory (`POL-0001`).** Verified **2026-07-23**: current NetBox is **v4.6.5**; requires **Python 3.12+**, **PostgreSQL 14+** (14 is deprecated and removed in v4.7 → **use PostgreSQL 16**), **Redis 5+** (<6 deprecated → **use Redis 7**). The official docs are "tested on Ubuntu 24.04"; we're on 26.04 LTS (same `apt` family — confirm package names resolve). 🔴 **Re-check [the install docs](https://netboxlabs.com/docs/netbox/installation/) for the newest stable at build time and pin that tag** — the `vX.Y.Z` below is a placeholder for whatever is current when you run this.

> 🔴 **Identity from cloud-init, never baked (`220` discipline).** Hostname / IP / SSH key / user injected per-clone; no static IP in the template netplan (the `10.10.0.50` overlap scar). Role packages (Postgres/Redis/NetBox/nginx) live here on the clone, not in the image.

> ✅ **OS reconciliation RESOLVED (`POL-0008`, #22 audit 2026-07-30).** Every Linux box is standardized on **Ubuntu Server 26.04 LTS** (`TPL-UBUNTU2604`, guide `220`). The stale *Debian / CIS-Debian* wording was reconciled to **Ubuntu** in **`Build-Checklist.md` v1.1 (2026-07-23)** — this guide and the checklist now agree on OS = Ubuntu (only the historical changelog rows still mention Debian). Data / `POL-0004` intent is unaffected.

> **Native install vs Docker (decision + why native).** This guide uses the **native install** (Postgres + Redis + a NetBox venv + gunicorn + nginx) — consistent with SRV01's hand-built nginx and the repo's build-to-understand ethos, and it makes the moving parts visible for the CCNA/homelab learning goal. The maintained **[netbox-docker](https://github.com/netbox-community/netbox-docker)** Compose stack is the supported alternative (easier upgrades, more moving parts hidden); if you'd rather run that, say so and I'll swap Part 3 for the Compose path. Everything else (identity, data load, make-it-generate, hardening) is identical.

---

## Part 0 — Gate / pre-flight (do this first)

- [ ] **Template exists:** `TPL-UBUNTU2604` verified per guide `220` (a test clone came up with unique machine-id + host keys).
- [ ] **Data on hand — this is what you load:** `IP-Addressing-Plan-VLSM.md` (v1.1) and `Cabling-and-Port-Map.md` open. NetBox is *populated from* these; they are the authoritative inputs until NetBox renders from itself.
- [ ] **DNS (AD DNS on DC01):** add `netbox.atlas.lab` → **`10.20.0.11`** (A record) for `ALLOWED_HOSTS` + the nginx `server_name`.
  - ✅ read-back: `Resolve-DnsName netbox.atlas.lab` / `nslookup netbox.atlas.lab 10.20.0.2` → `10.20.0.11`.
- [ ] **Sizing:** ~2 vCPU / 4 GB / ~40 GB (checklist VM inventory) — bump RAM if the UI feels heavy after data load.
- [ ] **Break-glass first (`Device-Hardening-Standard` Part A):** the **Proxmox console** is the recovery path; confirm you can open it before Part 6 hardening.
- 💡 **Snapshots** (`218`): `clean-base-<date>` after the clone verifies; `pre-netbox-<date>` before the Part 3 install; `netbox-loaded-<date>` after the data load verifies.

---

## Part 1 — Clone the template + assign identity (Proxmox GUI-primary)

> 🔴 **Superseded by `Networking-Build-Guide.md` (device-verified 2026-07-24).** The clone → Cloud-Init identity → reachable-at-`10.20.0.11` bring-up — **including** the two golden-image gotchas hit on the real box (add a Cloud-Init drive; disable the `00-atlas-dhcp.yaml` netplan fallback) — now lives on its own page. Do the network bring-up there, then **resume this guide at Part 2** with the box reachable over SSH. The steps below are kept for context.

### 1.1 Full clone
- [ ] **PVE UI:** right-click `TPL-UBUNTU2604` → **Clone** → **Full Clone** → Name `netbox01`, storage `local-lvm`. *(CLI: `qm clone <TPL-VMID> <NETBOX-VMID> --name netbox01 --full 1`.)* 🔴 Full, not Linked.
- [ ] **NIC on VLAN 20:** VirtIO model, **VLAN Tag = 20**, PVE trunk bridge.

### 1.2 Cloud-Init identity
- [ ] **PVE UI → VM `netbox01` → Cloud-Init:** `ciuser` = named admin (e.g. `nbadmin`), SSH **public** key, **IP `10.20.0.11/26`, gw `10.20.0.1`**, DNS `10.20.0.2`, search domain `atlas.lab`.
  - *(CLI — verify flag spelling per your Proxmox version, the `220` §2.4 caveat: `qm set <NETBOX-VMID> --ciuser nbadmin --sshkeys <file> --ipconfig0 ip=10.20.0.11/26,gw=10.20.0.1 --nameserver 10.20.0.2 --searchdomain atlas.lab`.)*
- [ ] Boot.

### 1.3 🔴 Verify identity regenerated uniquely (POL-0001)
```bash
hostnamectl                 # netbox01
ip -br a                    # 10.20.0.11/26, no leftover template IP
cat /etc/machine-id         # non-empty, DIFFERENT from the template
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub   # fresh unique fingerprint
cloud-init status           # done
ping -c2 10.20.0.1 ; ping -c2 10.20.0.2            # gw + DNS
```
- [ ] Unique identity + correct IP/DNS captured. **Snapshot `clean-base-<date>`.**

---

## Part 2 — Base state + role firewall

Template ships patched, SSH keys-only, `unattended-upgrades`, `qemu-guest-agent` (`220`). Confirm, then add NetBox's firewall.

- [ ] **Confirm inherited baseline:** `apt list --upgradable` (nothing held); `systemctl is-enabled ssh unattended-upgrades qemu-guest-agent`; `sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin'`.
- [ ] **Host firewall (ufw):**
  ```bash
  sudo apt install -y ufw
  sudo ufw default deny incoming ; sudo ufw default allow outgoing
  sudo ufw allow from 10.10.0.0/27 to any port 22 proto tcp   # SSH from MGMT VLAN only
  sudo ufw allow 443/tcp                                       # HTTPS UI/API
  # (leave 80 for a redirect-to-443 only; do NOT expose Postgres 5432 / Redis 6379 — localhost only)
  sudo ufw enable ; sudo ufw status verbose
  ```
  - 🔴 **Never expose PostgreSQL (5432) or Redis (6379)** — both bind localhost; the app talks to them locally. Only 443 (+ optional 80→443 redirect) and scoped SSH are open.

---

## Part 3 — Install NetBox (native: PostgreSQL + Redis + app + gunicorn + nginx)

> Grounded in the official [install docs](https://netboxlabs.com/docs/netbox/installation/) (verified 2026-07-23). 🔴 Replace every `vX.Y.Z` with the current stable tag and re-confirm each step against the live doc — NetBox's install steps shift by version.

### 3.1 PostgreSQL ([step 1](https://netboxlabs.com/docs/netbox/installation/1-postgresql/))
```bash
sudo apt update && sudo apt install -y postgresql
psql --version        # confirm 14+ (prefer 16 — 14 is deprecated, removed in NetBox v4.7)
```
```sql
sudo -u postgres psql
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD '<STRONG-RANDOM-PASSWORD>';   -- 🔴 NOT the doc's example password
ALTER DATABASE netbox OWNER TO netbox;
\connect netbox;
GRANT CREATE ON SCHEMA public TO netbox;
\q
```
- 🔴 **DB password → Vaultwarden (`POL-0002`), never in git.** Ensure the DB is **UTF8** (default) — never `SQL_ASCII`.

### 3.2 Redis ([step 2](https://netboxlabs.com/docs/netbox/installation/2-redis/))
```bash
sudo apt install -y redis-server
redis-server --version        # 6+ (prefer 7); redis-cli ping → PONG
```

### 3.3 NetBox application ([step 3](https://netboxlabs.com/docs/netbox/installation/3-netbox/))
```bash
sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential \
  libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev git
python3 -V        # 3.12+

sudo mkdir -p /opt/netbox && cd /opt/netbox
sudo git clone -b vX.Y.Z --depth 1 https://github.com/netbox-community/netbox.git .   # pin the current tag
sudo adduser --system --group netbox
sudo chown --recursive netbox /opt/netbox/netbox/media/ /opt/netbox/netbox/reports/ /opt/netbox/netbox/scripts/
```

Configure:
```bash
cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py
python3 ../generate_secret_key.py     # copy the output into SECRET_KEY
sudo nano configuration.py
```
Set in `configuration.py`:
- `ALLOWED_HOSTS = ['netbox.atlas.lab', '10.20.0.11']`
- `DATABASE = { NAME: 'netbox', USER: 'netbox', PASSWORD: '<from Vaultwarden>', HOST: 'localhost', PORT: '' }`
- `REDIS` — `tasks` DB 0 + `caching` DB 1 on `localhost:6379`
- `SECRET_KEY = '<generated above>'` 🔴 (≥50 chars, unique; → Vaultwarden)

Run the installer + create the admin:
```bash
sudo /opt/netbox/upgrade.sh
source /opt/netbox/venv/bin/activate
cd /opt/netbox/netbox
python3 manage.py createsuperuser        # 🔴 a REAL password (→ Vaultwarden), never a default
python3 manage.py runserver 0.0.0.0:8000 --insecure   # smoke test, then Ctrl-C
```

### 3.4 gunicorn + systemd services ([step 4](https://netboxlabs.com/docs/netbox/installation/)) 
> The canonical NetBox steps — confirm the contrib filenames against the current step-4 page:
```bash
sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py
sudo cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now netbox netbox-rq
systemctl status netbox netbox-rq        # both active/running
```

### 3.5 nginx reverse proxy + HTTPS ([step 5](https://netboxlabs.com/docs/netbox/installation/))
```bash
sudo apt install -y nginx
# self-signed to start (replace with a CA-issued cert in Phase 8, once AD CS/ICA01 issues server certs):
sudo openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout /etc/ssl/private/netbox.key -out /etc/ssl/certs/netbox.crt \
  -subj "/CN=netbox.atlas.lab"
sudo cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
# edit server_name = netbox.atlas.lab and the ssl_certificate paths above:
sudo nano /etc/nginx/sites-available/netbox
sudo ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx
```
- 🔴 **HTTPS only** — NetBox carries LDAP binds/API tokens; plain HTTP would send them cleartext (checklist failure mode). Self-signed now → **replace with an ICA01-issued cert once PKI is up (Phase 8)**; that cert's chain validates via the CRL host you built on SRV01.

**Evidence (Part 3):** `systemctl status netbox netbox-rq nginx postgresql redis-server` all active; `curl -skI https://netbox.atlas.lab/ | head` → `200`; browser login as the **superuser** (not a default).

---

## Part 4 — Populate: this IS the source of truth (`POL-0004`)

Load from `IP-Addressing-Plan-VLSM` v1.1 + `Cabling-and-Port-Map`. Enter it **once, here** — everything else renders from it.

- [ ] **VLANs 10–90** with names/roles (Management, Servers, Web/App, Monitoring, Clients, Deployment, Testing, DMZ, OT).
- [ ] **Prefixes = the VLSM plan** at real masks: Clients `10.50.0.0/25`, Servers/OT `/26`, Management/Deployment `/27`, Web/Mon/Test/DMZ `/28`, plus transit `/30`s and loopbacks in `10.255.x`.
- [ ] **Mark the intent in data:** the **Tier-0 Identity range `10.20.0.2–.9`** (DCs + CAs) and **OT** (no DHCP) — so segmentation is captured, not just implied.
- [ ] **Devices + interfaces + cables + IPs:** 1941, MKT01, SW01, FGT01, PVE01, Pi01, and the VMs — gateways `.1` on MKT01; the live register from `IP-Addressing-Plan-VLSM` (DC01 `.2`, DC02 `.3`, ICA01 `.4`, **SRV01 `.10`**, **NETBOX01 `.11`**, MON01 `10.40.0.10`, Pi01 VLAN 10).
- [ ] 🔴 **Reconcile against live devices as you enter** — an omission here (the Pi01-missing-from-`STATIC-HOSTS` failure, one layer up) propagates into every generated config. Enter Pi01. Enter SRV01. Enter everything.

**Evidence:** the loaded prefixes/VLANs/gateways match `IP-Addressing-Plan-VLSM` **exactly** (diff the export against the doc). **Snapshot `netbox-loaded-<date>`.**

---

## Part 5 — Make it generate (the payoff) + hardening

### 5.1 Generate, don't type
- [ ] Render **SW01's `STATIC-HOSTS`/DAI ACL from NetBox** (export/API + a template), not by hand — this structurally kills the `006`/Pi01-omission defect. `006`-style tables become **rendered exports** of NetBox.
- [ ] 🔴 **The proof:** export the generated artifact and **diff it against the live SW01** config. An **empty diff** is the evidence that "generated, not typed" is real (checklist validation). Capture it (`POL-0001`).

### 5.2 Pass-1 hardening (inherit `Device-Hardening-Standard`)
- [ ] Break-glass (Proxmox console) proven first; named admin; SSH keys-only; SSH scoped to MGMT; only 443 (+80→443) exposed; Postgres/Redis localhost-only.
- [ ] `unattended-upgrades` on; NTP synced (`timedatectl`); no secrets in git (SECRET_KEY, DB password, superuser password → Vaultwarden).
- [ ] Encrypted backup once BKP01/PBS exists (Phase 9) — **and** a NetBox DB dump (`pg_dump netbox`) in the backup set; snapshots are not backups (`218`).

---

## Part 6 — Deferred (later phases)

- **LDAPS auth to AD** (Phase 5) — NetBox authenticates against `atlas.lab` over **LDAPS (636)**, which is gated on the DC LDAPS cert from AD CS Part 3. Cleartext LDAP is why HTTPS is non-negotiable now.
- **API token for Ansible** (Phase 10) — automation reads the source of truth via the API; scope the token, store it in Vaultwarden.
- **Oxidized integration** — Oxidized (on **SRV01**) sources its device list from NetBox (`POL-0004`); that's why NetBox (**Phase 4**) is built *before* the automation that renders from it (Phase 10), and SRV01's Oxidized role is gated on this host.

---

## Validation — read the state back

- [ ] **Identity (Part 1):** unique machine-id + host keys; `hostnamectl` = `netbox01`; `ip -br a` = `10.20.0.11/26`.
- [ ] **Services (Part 3):** `systemctl status netbox netbox-rq nginx postgresql redis-server` all active; `curl -skI https://netbox.atlas.lab/` → `200`; superuser login works (not a default).
- [ ] **Security:** HTTPS only (no plain-HTTP UI); `ss -tlnp` shows 5432/6379 on `127.0.0.1` only; strong unique `SECRET_KEY`; SSH scoped.
- [ ] **Data (Part 4):** the full VLSM plan loaded — every prefix/VLAN/gateway present and matching `IP-Addressing-Plan-VLSM`; Tier-0 + OT ranges marked.
- [ ] 🎯 **The real gate (Part 5):** a NetBox-**generated** artifact (SW01 `STATIC-HOSTS`/ACL) **diffs empty** against the live device. That empty diff = "source of truth" is real, not aspirational.

## Common mistakes

- 🔴 **Treating NetBox as documentation, not source of truth** — if the device config isn't *generated* from it, you've rebuilt `006` with extra steps. The empty diff (Part 5) is the whole point.
- 🔴 **An omission at load time** — a host you forget to enter is a host the generated ACL silently drops (the Pi01 failure, one layer up). Reconcile against live as you go.
- 🔴 **Default/weak `SECRET_KEY` or default superuser creds** — generate a unique key; a real password; both → Vaultwarden (`POL-0002`).
- 🔴 **Plain HTTP** — LDAP binds + API tokens in cleartext. HTTPS from the start (self-signed → CA cert Phase 8).
- 🔴 **Exposing Postgres/Redis** — keep them localhost; only 443 + scoped SSH open.
- 🔴 **Un-pinned / mismatched versions** — install from a pinned tag against the current doc (Python 3.12+, PG 16, Redis 7); NetBox's steps shift by release.
- 🔴 **Baking a static IP into the clone** — identity is cloud-init only (`220`).

## Rollback

- Snapshots `clean-base-<date>` (post-clone), `pre-netbox-<date>` (pre-install), `netbox-loaded-<date>` (post-data-load). The **Proxmox console** is the network-independent recovery. For data, a **`pg_dump netbox`** is the real backup — snapshots aren't (`218`); a datastore loss takes the VM and its snapshots together.

## Related

- `Build-Checklist.md` (this device — reconcile OS to Ubuntu) · `Architecture/Atlas-Service-Architecture.md` Part 3 (the source-of-truth role) · `Architecture/IP-Addressing-Plan-VLSM.md` (the data to load; NETBOX01 `10.20.0.11`) · `Architecture/Cabling-and-Port-Map.md`
- `Virtualization/Build-Guides/220-Prepare-the-Ubuntu-Golden-Image.md` (the template) · `Reference/218-VM-Snapshot-and-Naming-Convention.md`
- `Devices/SRV01-Network-Services/Build-Guide.md` (Oxidized sources its device list from here; NetBox is Phase 4) · `Devices/SW01-Access-Switch/*` (the first "generate-don't-type" target — `STATIC-HOSTS`/DAI ACL)
- `Operations/Device-Hardening-Standard.md` (Pass-1; VM break-glass = Proxmox console) · `POL-0004` (generate, don't type) · `Operations/Build-Order-and-Dependencies.md` **Phase 4** (the build-order owner; `Master-Build-Order.md` is superseded)

## Sources (official — cited 2026-07-23, POL-0001)

Versions/commands confirmed live this session; the *sequence* is Atlas's synthesis. Device `[ ]`s remain unverified until run.

- **Current version + requirements** (NetBox **v4.6.5**; **Python 3.12+**, **PostgreSQL 14+** [16 recommended, 14 removed in v4.7], **Redis 5+** [7 recommended]; tested on Ubuntu 24.04): [NetBox installation overview](https://netboxlabs.com/docs/netbox/installation/) (verified 2026-07-23).
- **PostgreSQL DB/user creation + UTF8 requirement**: [NetBox install — PostgreSQL](https://netboxlabs.com/docs/netbox/installation/1-postgresql/) (verified 2026-07-23).
- **App install (deps, `/opt/netbox`, `netbox` system user, git clone/tag, `configuration.py`, `generate_secret_key.py`, `upgrade.sh`, `createsuperuser`)**: [NetBox install — NetBox](https://netboxlabs.com/docs/netbox/installation/3-netbox/) (verified 2026-07-23).
- **gunicorn/systemd + nginx**: [NetBox installation docs](https://netboxlabs.com/docs/netbox/installation/) (steps 4–5 — confirm contrib filenames at build time).
- **Docker alternative**: [netbox-community/netbox-docker](https://github.com/netbox-community/netbox-docker).
- **Clone → cloud-init identity**: [Proxmox VE Cloud-Init](https://pve.proxmox.com/wiki/Cloud-Init_Support) (via guide `220`).

## Change Log

| Version | Date | Change |
|---|---|---|
| 0.1 | 2026-07-23 | Authored (not executed). NETBOX01 build guide as the Lab-02 source of truth (`POL-0004`, Phase 3 first): Part 0 gate (`TPL-UBUNTU2604` + `netbox.atlas.lab` A-record + sizing + Proxmox-console break-glass), Part 1 full-clone → **cloud-init identity `10.20.0.11`** + unique-identity read-back (`220`), Part 2 base + role firewall (SSH→MGMT, 443 only, Postgres/Redis localhost), Part 3 **native install** (PostgreSQL 16 / Redis 7 / NetBox **v4.6.x** venv / gunicorn+systemd / nginx HTTPS self-signed→CA Phase 8) grounded in the official docs with exact current commands, Part 4 **populate from the VLSM plan** (the source-of-truth data load; Tier-0/OT intent; reconcile-against-live), Part 5 **make-it-generate** (SW01 `STATIC-HOSTS`/ACL rendered → **empty diff** = the proof) + Pass-1 hardening, Part 6 deferred (LDAPS Phase 5, API token Phase 10, Oxidized dependency). Native-install default; **netbox-docker** noted as the alternative. Reconciles the checklist OS **Debian → Ubuntu** (`POL-0008`). Current version/requirements/commands verified live 2026-07-23 (NetBox v4.6.5; Python 3.12+, PG 14+/16, Redis 5+/7). GUI-primary for the Proxmox clone; in-guest CLI alongside; every `[ ]` unverified pending the build (`POL-0001`). |
