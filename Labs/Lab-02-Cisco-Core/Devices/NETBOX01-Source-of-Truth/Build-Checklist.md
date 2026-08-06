---
Title: NETBOX01 Build Checklist (Source of Truth — IPAM/DCIM)
Path: Labs/Lab-02-Cisco-Core/Devices/NETBOX01-Source-of-Truth
Status: Target Design — build checklist. Executable companion: `Build-Guide.md` (native NetBox install). You write the config; NetBox is generated-from, never hand-typed (POL-0004).
Version: 1.1
---

# NETBOX01 — Build Checklist (Source of Truth)

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

> **Role (`Atlas-Service-Architecture` Part 3, `POL-0004`):** 🔴 **the single source of truth (IPAM/DCIM) — the most important host in the estate.** Everything downstream renders **from** it. It's **Phase 4 (Source of truth)** — built before the automation that renders from it (Phase 10). **Ubuntu Server** clone of `TPL-UBUNTU2604` (guide `220`) on PVE01, VLAN 20 (`10.20.0.11`, gw `10.20.0.1`). Sources: [NetBox installation docs](https://netboxlabs.com/docs/netbox/installation/), [CIS Ubuntu Linux Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux).
>
> 🔴 **This is the structural fix for Atlas's most‑repeated defect class** (`006` hand‑typed and wrong; Pi01 missing from `STATIC-HOSTS`, silently dropped, survived three handoffs). It only works if configs are **generated** from it, not typed alongside it.

## Gate
- [ ] `IP-Addressing-Plan-VLSM` and `Cabling-and-Port-Map` open — this is the data you load.
- [ ] Ubuntu clone of `TPL-UBUNTU2604` on PVE01, VLAN 20, sized per the VM Inventory (~2 vCPU / 4 GB).

## Build steps

### 1. VM + OS hardening (CIS Ubuntu — inherited from `TPL-UBUNTU2604`)
- [ ] Ubuntu clone, VLAN 20 (vNIC tag verified on the wire — the Book 2 tagging lesson).
- [ ] Named admin, SSH keys only, host firewall (allow 443 + SSH from mgmt), `unattended-upgrades`.

### 2. Install NetBox (per the official install guide — match the current version)
- [ ] **PostgreSQL + Redis + NetBox** (native install, or the maintained Docker Compose). Confirm steps against the current NetBox install doc — versions shift.
- [ ] 🔴 **Set a strong unique `SECRET_KEY`**, correct `ALLOWED_HOSTS`, and a **superuser with a real password** (no defaults — `POL-0002`).
- [ ] **Reverse proxy (nginx) with HTTPS.** Self‑signed to start; replace with a cert from the new CA once PKI is up (Phase 8). Never plain HTTP (LDAP binds/creds would be cleartext).

### 3. Populate — this IS the source of truth
- [ ] **VLANs 10–90** with names/roles.
- [ ] **IP prefixes = the VLSM plan** — each subnet at its real mask (Clients `/25`, Servers/OT `/26`, etc.), plus the transit `/30`s and loopbacks (`10.255.x`).
- [ ] **Devices** — 1941, MKT01, SW01, FGT01, PVE01, Pi01, and the VMs — with their **interfaces, cables** (`Cabling-and-Port-Map`), and **IP assignments** (gateways `.1` on MKT01; static hosts; the Tier‑0 block `10.20.0.2–.9`).
- [ ] Mark the **Tier‑0 Identity range** and **OT** so the segmentation intent is captured in the data.

### 4. Make it generate (the payoff)
- [ ] Point the render at NetBox: **SW01's `STATIC-HOSTS`/DAI ACL is generated from NetBox**, not hand‑typed (kills the Pi01‑omission defect structurally). `006` becomes a **rendered export**.
- [ ] Later: **LDAPS auth to AD** (Phase 5), **API token for Ansible** (Phase 10).

## Validation
- [ ] HTTPS reachable; login as the **superuser** (not a default).
- [ ] The **VLSM plan is fully loaded** — every prefix/VLAN/gateway present and matches `IP-Addressing-Plan-VLSM` exactly.
- [ ] 🔴 **A generated artifact matches the device** — export the IP list or the `STATIC-HOSTS` ACL and diff it against SW01. That diff being empty is the proof that "generated, not typed" is real.
- [ ] Reconcile the loaded data against the live devices (the audit) — an omission here propagates into every generated config.

## Failure modes
- 🔴 **Treating NetBox as documentation, not source of truth** — if you hand‑type the SW01 ACL *and* NetBox, you've rebuilt the `006` defect with extra steps. The device config must be **generated** from NetBox, or NetBox is just another table that will drift.
- 🔴 **An omission in NetBox** — the Pi01‑missing‑from‑`STATIC-HOSTS` failure, one layer up: a host you forget to enter is a host the generated ACL silently drops. Reconcile against live.
- 🔴 **Default/weak `SECRET_KEY` or default admin creds**; **no HTTPS** (cleartext LDAP bind/creds).
- **Editing a device directly and not updating NetBox** — NetBox goes stale (the `006` failure). Oxidized's drift check (Phase 4) is the backstop; the fix is discipline: change flows through the source of truth.

## Change Log
| Version | Changes |
|---|---|
| 1.1 | 2026-07-23. **OS reconciled Debian → Ubuntu** (`POL-0008`): NETBOX01 is an **Ubuntu Server clone of `TPL-UBUNTU2604`** (guide `220`); CIS-Debian → CIS-Ubuntu; IP pinned `10.20.0.11`. Added the executable companion pointer — `Build-Guide.md` (authored 2026-07-23; native install, current NetBox v4.6.x / Python 3.12+ / PostgreSQL 16 / Redis 7, verified live). Data-load + generate-don't-type intent and failure modes unchanged. |
| 1.0 | 2026-07-17. Build checklist for NETBOX01 as the Lab-02 source of truth (`POL-0004`, `Atlas-Service-Architecture` Part 3) — Phase 3, first service. CIS-Debian VM hardening; NetBox install (Postgres/Redis, strong SECRET_KEY, HTTPS, no default creds); populate from the VLSM plan + cabling doc (VLANs, prefixes, devices, interfaces, cables, Tier-0/OT ranges); make it generate SW01's ACL so `006` becomes a rendered export. Validation proves "generated, not typed" via an empty device diff; failure modes center on the "NetBox-as-documentation" and omission traps that reproduce the `006`/Pi01 defect. |
