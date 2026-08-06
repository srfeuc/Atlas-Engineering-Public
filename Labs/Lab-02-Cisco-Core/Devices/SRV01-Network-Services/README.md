# SRV01 — Network Services (Ubuntu)  ·  folder front-door

> **How to read this folder.** Front door for the network-services host — the roles it runs, the host build, its connections, and which doc answers which question. Status: `Roadmap.md` · `Build-Checklist.md` · `Build-Record.md`. The *how*: `Build-Guide.md` + each `Roles/<svc>/`.

| Item | Value |
|---|---|
| Lab / Era | Lab-02 · Cisco-Core — ACTIVE (in build) |
| Host · Role | **SRV01** (Ubuntu 26.04, `TPL-UBUNTU2604` clone) · network-services host — **nginx CRL/AIA · Oxidized · TFTP/SFTP · rsyslog** |
| Placement | PVE01 · `10.20.0.10` /26 gw `10.20.0.1` DNS `10.20.0.2` · VLAN 20 |
| Silo | 🟡 Services |
| Status | Authored (Build-Guide v0.2), **not executed**. **nginx-CRL is the gating role** (PKI critical path). See `Roadmap.md` |
| Governs | `Atlas-Service-Architecture` §5.1 · `ADR-0030` (no DHCP → DC01) · `ADR-0029` (no FreeRADIUS → NPS01) · `ADR-0027`/`ADR-0028` (the PKI it publishes revocation for) |

## Role this era

The estate's **network-services host**, running four separate services — most importantly the 🔴 **nginx CRL/AIA host** (`pki.atlas.lab`) that the two-tier AD CS publishes revocation to (**the estate's revocation endpoint**). Plus **Oxidized** (config-as-record → git), **TFTP/SFTP** (IOS image/config transfer), and an **rsyslog relay** (→ MON01). It does **not** run DHCP (→ DC01, `ADR-0030`) or FreeRADIUS (→ NPS01, `ADR-0029`).

## Connections — what this touches

**Depends on (upstream):** PVE01 (hosts the VM) → SW01/MKT01 (VLAN 20) · **DC01 DNS** (`pki.atlas.lab` record) · **ICA01** (publishes the CRL SRV01 serves; SRV01's own TLS cert) · **NetBox** (Oxidized device list, `POL-0004`) · **Vaultwarden** (Oxidized creds, `POL-0002`) · `TPL-UBUNTU2604` golden image.

**Depended on by (downstream):** 🔴 **ICA01/PKI + every relying party** — revocation checking (`pki.atlas.lab`) for the whole estate rides on SRV01 being up · **network devices** (SW01/FGT01/MKT01/1941 — Oxidized backup + TFTP/SFTP) · **MON01** (the rsyslog relay feeds it).

**Services provided:** nginx CRL/AIA · Oxidized (config→git) · TFTP/SFTP · rsyslog relay.

## Services map — what runs here and how it's used

> 🆕 **Services map (Standard v1.7).** One row per `Roles/` service. Status mirrors `Build-Record.md` (`POL-0001`) — authored, **not executed**, so every row is 📋.

| Service | Purpose | Consumed by · port | Depends on | Status |
|---|---|---|---|---|
| **nginx CRL/AIA host** (`pki.atlas.lab`) | The estate **revocation endpoint** — the gating PKI deliverable | every relying party · HTTP/80 | ICA01 publishes the CRL | 📋 authored, not built (gating) |
| **Oxidized** (config → git) | Network-config backup + drift-as-diff | SW01 · 1941 · MKT01 · FGT01 · git | NetBox device list + Vaultwarden creds | 📋 not built |
| **rsyslog relay** | Network-device log relay to MON01 | network devices → MON01 · syslog/514 | MON01 | 📋 not built |
| **TFTP / SFTP** | IOS image / config transfer | network devices · TFTP/69 · SFTP/22 | host up | 📋 not built |

## Roles (multi-service — the `Roles/` pattern)

Per the Documentation Standard, each service is its own unit under `Roles/`; the **host folder owns the box** (OS/identity/IP/hardening), each **role folder owns its service**:
- **`Roles/nginx-CRL/`** — 🔴 the gating deliverable (`pki.atlas.lab` CRL/AIA).
- **`Roles/Oxidized/`** — network-config backup → git (drift as a diff).
- **`Roles/rsyslog/`** — log relay → MON01.
- **`Roles/SFTP-TFTP/`** — IOS image/config transfer.

## Documents in this folder

**Host:** `README` · `Roadmap` · `Considerations` · `Build-Checklist` (host build + service index) · `Build-Record` · `Diagnostics` · `Troubleshooting` · `Changes/`.
**Build (the how):** `Build-Guide.md` (host clone + the nginx-CRL role, Parts 0–6).
**Services:** `Roles/<svc>/Build-Checklist.md` (the per-service executable detail).

## Single source
- Estate index: `../../Service-Server-Build-Plan.md` · Role/silo: `../../Architecture/Lab-02-Device-Role-Assignments.md` · Addressing: `../../Architecture/IP-Addressing-Plan-VLSM.md` (`POL-0008`).
