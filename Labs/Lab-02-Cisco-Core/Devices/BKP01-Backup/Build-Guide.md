---
Title: BKP01 Build Guide (PBS + Vaultwarden — the phased/gated host spine) — LIVING guide
Path: Labs/Lab-02-Cisco-Core/Devices/BKP01-Backup
Status: 🟡 Target Design — authored, NOT executed. Runs per POL-0001 (verify on the device; evidence = command + output). Executable companion to `Build-Checklist.md`; per-service detail in `Roles/<svc>/`.
Version: 0.1
Date: 2026-07-30
---

# BKP01 — Build Guide (PBS + Vaultwarden)

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build).** A **Linux backup appliance** on **PVE02/EQR6** (`ADR-0036` v1.2), VLAN 20, host `10.20.0.18` (📋 proposed — `../../Architecture/IP-Addressing-Plan-VLSM.md` owns it). **Two services:** **Proxmox Backup Server** (the datastore on the 8 TB) and **Vaultwarden** (the secrets vault). This guide is the **host spine**; each `🔴 GATE` must pass before the next phase, then it points into `Roles/PBS/` and `Roles/Vaultwarden/`.

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 **Target Design — not built.** Nothing device-verified. Every `[ ]` → `[x]` only with a command + its output (`POL-0001`). No device-verified status anywhere yet. |
| Applies To | **BKP01** (Linux — PBS ISO / golden-image clone; **domain not joined**, a Linux member by IP/DNS) |
| Governs | The PBS backup target + the mandatory off-site copy + Vaultwarden. Companion to `Build-Checklist.md` (host, v1.1); per-service steps in `Roles/<svc>/`. |
| Governing Policy | `POL-0005` (3-2-1 / restore-real) · `POL-0002` (secrets offline) · `POL-0001` (evidence) · `POL-0008` (one home per fact) |

> 🔴 **The one rule this guide gates (`POL-0005`/`ADR-0011`).** A backup is not real until a **restore succeeds**. This guide is not "done" at "a job ran green" — it is done when a VM restores to an isolated VLAN and boots (Phase 5). That Game Day has **never** been run in Atlas.
> 🔴 **Off-site is mandatory (`ADR-0009`/`ADR-0013`).** The datastore alone is not backup — an encrypted off-site copy with an **offline key** (`POL-0002`) is hard-required.

---

## Part 0 — Gate / pre-flight
- [ ] 🔴 **GATE: PVE02/EQR6 acquired** (EQR6 already bought) and the **8 TB external** attached — the datastore has nowhere to live otherwise.
- [ ] **Break-glass first:** the recovery path is the **Proxmox noVNC/SPICE console** (network-independent) — confirm access before any hardening that could lock out SSH.
- [ ] DNS + time from **DC01** reachable on VLAN 20; `pki.atlas.lab`/ICA01 reachable (for the later Vaultwarden cert).

## Part 1 — Clone + identity
- [ ] Clone the **golden Linux image / PBS ISO** on PVE02; NIC on **VLAN 20**.
- [ ] Assign identity via cloud-init: host `10.20.0.18/26`, gw `10.20.0.1`, DNS `10.20.0.2`, domain `atlas.lab`.
- [ ] 🔴 **Verify identity regenerated uniquely** (`hostnamectl`, `/etc/machine-id`, SSH host keys — the golden-image discipline, `POL-0001`). Snapshot `clean-base-<date>`.
- [ ] 🔴 **GATE:** identity unique + reachable before proceeding.

## Part 2 — Base state + role firewall
- [ ] Confirm inherited baseline (patched, SSH keys-only, auto-updates, guest agent).
- [ ] Host firewall: SSH `22/tcp` scoped to the MGMT subnet; open **PBS `8007/tcp`** and (later) **Vaultwarden `443/tcp`** per the flows matrix (`../../Architecture/Atlas-East-West-Allowed-Flows-Matrix.md`).

## Part 3 — Pass-1 hardening
- [ ] Named admin · SSH keys only · management scoped · unused services off (`ss -tlnp` = only what PBS/Vaultwarden need) · NTP synced (`timedatectl`) · **no secrets in git** (`POL-0002`).
- [ ] 🔴 **GATE:** hardening read-backs captured before the box holds real backups.

## Part 4 — 🎯 PBS datastore (into `Roles/PBS/`)
- [ ] Install **Proxmox Backup Server**; create the **datastore on the 8 TB external** (not PVE's VM storage). Steps: `Roles/PBS/Build-Checklist.md`.
- [ ] Add the **PVE hosts** as clients; schedule jobs — **DC01/DC02 · NETBOX01 · ICA01 · Vaultwarden** first (system-state / **KDS root key** / SYSVOL), then VMs + golden templates.
- [ ] Enable **verify** jobs + **prune/retention**.
- [ ] 🔴 **GATE: off-site copy (`ADR-0009`)** — restic/borg → external/cloud, **encrypted, key offline** (`POL-0002`). Runbook: `../../Operations/Device-Backup-Runbook.md`.
- [ ] 🔴 **GATE: restore Game Day (`ADR-0011`)** — restore a VM to isolated VLAN 70; confirm boot. **Never run — the load-bearing step.**

## Part 5 — Certificate application (Vaultwarden TLS from ICA01)
- [ ] Request/install the **Vaultwarden web cert from ICA01** (`10.20.0.13`, `pki.atlas.lab` chain). This is the standard estate cert-application step; HTTPS-only for the vault.

## Part 6 — Service setup (Vaultwarden, into `Roles/Vaultwarden/`)
- [ ] Install **Vaultwarden**; bind the ICA01 TLS cert; set the **admin token** (offline, `POL-0002`). Steps: `Roles/Vaultwarden/Build-Checklist.md`.
- [ ] 🔴 **GATE: `049` master-password recovery path** — resolve before trusting it as the vault (design-ref, NOT ADR-0049). Then back the **vault itself into PBS**.
- [ ] Stand Vaultwarden up **before any CA-passphrase handling** (`ADR-0009`, `ADR-0031`).

## Part 7 — Automation onboarding (future, gated stub — `ADR-0048`)
- [ ] DESIGNED stub (Phase 10). PBS install + backup-job-as-code + off-site sync cron + Vaultwarden deploy → `Automation/README.md`. Backup/off-site is *plumbing* → automate; the **restore-Game-Day judgment stays manual**.

## Validation — read the state back
- [ ] **Identity (Part 1):** unique machine-id/host keys; `10.20.0.18/26`.
- [ ] **PBS (Part 4):** a job completes; the **verify job passes**; prune leaves the retention set.
- [ ] 🔴 **A restore completes** — the VM comes up in Testing and functions.
- [ ] 🔴 **Off-site copy exists** + its restore tested (mount the repo, read a file back).
- [ ] **Vaultwarden (Part 6):** HTTPS via the ICA01 cert; the vault is itself backed up by PBS.

## Related
- `Build-Checklist.md` · `Roles/PBS/` · `Roles/Vaultwarden/` · `Diagnostics.md` · `Considerations.md` · `../../Operations/Device-Backup-Runbook.md`.

## Change Log
| Version | Date | Changes |
|---|---|---|
| 0.1 | 2026-07-30 | Created — the phased/gated BKP01 host spine (clone → identity → harden → PBS datastore on the 8 TB → off-site → restore Game Day → Vaultwarden + ICA01 TLS → `049` gate → automation stub). |
