---
Title: SRV01 Build Checklist (Network Services)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services
Status: Target Design — **host build + service index**. Per-service executable detail now lives in `Roles/<svc>/`; this page owns the **host** build (clone/identity/harden) + a service summary. Executable how: `Build-Guide.md`. `POL-0001` R-A1.
Version: 1.3
---

# SRV01 — Build Checklist (Network Services)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`Atlas-Service-Architecture` 5.1):** the network‑services host — the **nginx CRL/AIA host** (`pki.atlas.lab`, the AD CS critical-path deliverable), **Oxidized** (config‑as‑record → git), **TFTP/SFTP**, **rsyslog relay**. 🔴 **No DHCP** (moved to DC01 — `ADR-0030`) and **no FreeRADIUS** (retired — `ADR-0029`; network-device RADIUS is **NPS on `NPS01`**). **Ubuntu Server** clone of `TPL-UBUNTU2604` (guide `220`) on PVE01, VLAN 20 (`10.20.0.10`, gw `10.20.0.1`). Sources: [CIS Ubuntu](https://www.cisecurity.org/benchmark/ubuntu_linux), [Oxidized](https://github.com/ytti/oxidized), [nginx](https://nginx.org/en/docs/).

## Roles (per-service executable checklists — the `Roles/` pattern)
> The host owns the box (below); each **service** owns its own checklist under `Roles/`:
> - 🔴 **`Roles/nginx-CRL/`** — the `pki.atlas.lab` CRL/AIA host (gating; PKI critical path).
> - **`Roles/Oxidized/`** — config backup → git · **`Roles/rsyslog/`** — log relay → MON01 · **`Roles/SFTP-TFTP/`** — IOS transfer.
> Sections §2/§3/§6 below are the **summary**; the executable steps live in those role folders.

## Gate
- [ ] NetBox up (Phase 3) — Oxidized ideally takes its device list from NetBox.
- [ ] Ubuntu clone of `TPL-UBUNTU2604`, VLAN 20 tag verified on the wire.

## Build steps
### 1. OS hardening (CIS Ubuntu — inherited from `TPL-UBUNTU2604`)
- [ ] Named admin, SSH keys only, host firewall, `unattended-upgrades`.

### 2. Oxidized (the highest‑value service after NetBox)
- [ ] Pull running configs from **SW01, FGT01, MKT01, 1941** on a schedule → **commit to git** (drift is a diff you can see).
- [ ] **Read‑only device accounts**, credentials **vaulted** (Vaultwarden), never in the Oxidized config in cleartext (`POL-0002`).
- [ ] Device inventory sourced from NetBox where possible (`POL-0004`).

### 3. TFTP / SFTP
- [ ] **`tftpd-hpa`** for IOS image/config transfer (CCNA + device backups). **SFTP** as the secure equivalent — prefer it for anything sensitive.

### 4. ~~Kea DHCP~~ → moved to DC01 (`ADR-0030`)
- [ ] **SRV01 no longer runs DHCP.** Windows DHCP runs on **DC01** (fewer VMs; DC02 hot-standby later), with a **RouterOS DHCP relay on MKT01 → `10.20.0.2`**. Scopes live in `IP-Addressing-Plan-VLSM` / `DC01-Build-Guide`. *(Historical: SRV01 was the planned Kea host until 2026-07-28.)*

### 5. ~~FreeRADIUS~~ → retired (`ADR-0029`)
- [ ] **SRV01 does not run FreeRADIUS.** Network-device admin auth (MKT01/SW01/1941) = **Windows NPS on `NPS01`** (`ADR-0029` v1.1); FGT01 = direct LDAPS (`ADR-0028`). *(The `033` `testing`/`testing123` stock-credential lesson moves to the `NPS01` build.)*

### 6. rsyslog relay / logging
- [ ] Relay device logs to **MON01** (the collector); SRV01's own logs → MON01 too.

## Validation
- [ ] Oxidized: a commit lands in git; change a device config and confirm the **diff is detected**.
- [ ] TFTP/SFTP: a transfer succeeds.
- [ ] nginx CRL host: `http://pki.atlas.lab/pki/` serves the CRL/AIA files (see `Build-Guide.md`).
- [ ] No secrets in the git repo (`gitleaks`, `POL-0002`).

## Failure modes
- 🔴 **Over‑privileged Oxidized accounts** — read‑only is enough; a config‑puller doesn't need write.
- 🔴 **The `testing`/`password` credential** (`033`) — deleted for a reason; don't recreate it.
- 🔴 **Oxidized / device creds in git** (`POL-0002`) — read-only accounts, vaulted, never cleartext.

## Change Log
| Version | Changes |
|---|---|
| 1.3 | 2026-07-29. **Reframed to the `Roles/` pattern** (Documentation Standard): this page is now the **host build + service index**; created `Roles/nginx-CRL`, `Roles/Oxidized`, `Roles/rsyslog`, `Roles/SFTP-TFTP` (each its own Build-Checklist). Added the full host page-set (README+connections, Roadmap, Considerations, Build-Record, Diagnostics, Troubleshooting, Changes/). §2/§3/§6 kept as the summary; detail moved to the roles. |
| 1.2 | 2026-07-28. **Reconciled to ADR-0029/0030** (cascade from Master-Build-Order v1.6). **Dropped Kea DHCP** (§4 → moved to DC01, `ADR-0030`) and **FreeRADIUS** (§5 → retired, `ADR-0029`; RADIUS is NPS on `NPS01`) from SRV01's role, sources, validation, and failure modes; role line now leads with the **nginx CRL/AIA host**. Vault reference VAULT01 → Vaultwarden. SRV01 = nginx-CRL/Oxidized/TFTP-SFTP/rsyslog only. |
| 1.1 | 2026-07-23. **OS reconciled Debian → Ubuntu** (`POL-0008`): SRV01 is an **Ubuntu Server clone of `TPL-UBUNTU2604`** (guide `220`), not a Debian VM; CIS-Debian → CIS-Ubuntu; IP pinned `10.20.0.10`. Added the executable companion pointer — `Build-Guide.md` (authored 2026-07-23; nginx CRL/AIA host `pki.atlas.lab` first, then the deferred service roles below). Service catalog + failure modes unchanged. |
| 1.0 | 2026-07-17. Build checklist for SRV01 (Oxidized→git config backup/drift, TFTP/SFTP, Kea DHCP, FreeRADIUS coexisting with NPS, rsyslog relay) on CIS-Debian. Foregrounds read-only Oxidized creds + vaulted secrets and the `033` `testing`/`password` deleted-credential lesson. |
