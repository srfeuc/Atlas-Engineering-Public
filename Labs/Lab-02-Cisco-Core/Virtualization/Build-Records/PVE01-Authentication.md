---
Title: PVE01 Authentication — Build Record
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Records
Status: 🟢 Verified reality (partial) — the authoritative home for PVE01's auth model (POL-0008). Accounts device-verified 2026-07-16; ACL least-privilege + root policy 🟡 to read back. Verify on the device (POL-0001).
Version: 1.0
Date: 2026-07-30
---

# PVE01 Authentication — Build Record

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — in build)** — Host: **PVE01** (Dell R410 hypervisor). Role: **Proxmox VE authentication + named administration.** Created in the `#21` sweep to close `VIRTUALIZATION-PACK-MANIFEST` **Freeze #3** (the missing Authentication Build-Record).

> 🔴 **One authoritative home for PVE01's auth model (`POL-0008`).** The build **procedure** lives in `Build-Guides/206-Proxmox-Authentication-and-Named-Administration.md` (target-state); this is the **verified state**. Records outrank guides (`POL-0001`). **Never record live secrets** (`POL-0002`) — passwords go to Vaultwarden (`ADR-0009`).

## Document Control
| Item | Value |
|---|---|
| Owner | Atlas Engineering (Virtualization book) |
| Status | 🟢 **Verified** — accounts/realms from live `pveum user list` (2026-07-16). 🟡 **Open:** ACL least-privilege review + root-login policy hardening. |
| Version | 1.0 |
| Applies To | **PVE01** — Proxmox VE 8.4.19; **standalone, not domain-joined** (`pve01.lab`) |
| Authoritative for | PVE01 accounts, realms, roles/ACLs, root policy (`POL-0008`). Procedure: `Build-Guides/206-...`. |
| Governing | `POL-0001` (evidence), `POL-0002` (no live secrets), `POL-0008` (one home), `ADR-0009` (secrets custody → Vaultwarden). |

## Accounts + realms (device-verified 2026-07-16)

| Account | Realm | Role / scope | Use | Status |
|---|---|---|---|---|
| `root@pam` | PAM (Linux) | root | **Host recovery + Linux administration only** — not day-to-day PVE admin | ✅ (07-16) |
| `seth-admin@pve` | PVE | **Administrator at `/`, propagation enabled** | The **named administrator** for Proxmox management (GUI/API/SSH) | ✅ (07-16) |

> 🔴 **Naming (`217-Verified-Facts`):** the account is **`seth-admin@pve`** — **not** `sethadmin`, and **not** a Linux user. Do not substitute.

## Design (the standalone-hypervisor auth model)
- **Standalone, not domain-joined.** PVE01 is a hypervisor on the management plane (`pve01.lab`, not `atlas.lab`) — auth is **local PVE/PAM**, not AD. (Contrast the Windows VMs, which are domain-joined.) This is deliberate: the hypervisor must stay administrable even if AD/identity is down.
- **Named admin over root.** Day-to-day management uses `seth-admin@pve` (a PVE-realm named account), reserving `root@pam` for recovery — the least-privilege / accountable-admin pattern (`206`).
- **Secrets custody.** The `seth-admin@pve` password + `root` password are **Vaultwarden** items (`ADR-0009`); never in-repo (`POL-0002`).

## Evidence needed (🟡 — read back to complete this record, `POL-0001`)
- **ACL least-privilege review** — `pveum acl list`: confirm `seth-admin@pve` = Administrator at `/` and no unexpected grants; consider a scoped role instead of `/`-Administrator once multi-user.
- **Root-login policy** — whether root SSH/GUI login is restricted; TFA/2FA on the named admin (Proxmox supports TOTP) — decide + record.
- **Realm inventory** — `pveum realm list` (pam, pve present; no AD/LDAP realm on a standalone host by design).

## Verify (paste read-backs → flip 🟡→✅)
```bash
pveum user list
pveum acl list
pveum realm list
pveum role list
```

## Related
- `Build-Guides/206-Proxmox-Authentication-and-Named-Administration.md` (procedure) · `215-PVE01-Current-State.md` (the 07-16 account snapshot) · `Reference/217-Verified-Facts-and-Reconciliation-Notes.md` (the `seth-admin@pve` naming correction) · `PVE01-Diagnostics.md` · `../../Devices/PVE01-Hypervisor/` (device front-door) · `00-Atlas-Foundation/Decisions/ADR-0009-...` (secrets custody).

## Change Log
| Version | Changes |
| 1.0 | 2026-07-30 (#21). Created as the authoritative PVE01 authentication Build-Record, closing manifest Freeze #3. Records the device-verified `root@pam` (recovery) + `seth-admin@pve` (Administrator at `/`, propagate) accounts from live `pveum user list` (07-16), the `seth-admin@pve` naming correction (`217-Verified-Facts`), the standalone-not-domain-joined named-admin design, secrets-custody→Vaultwarden (`ADR-0009`/`POL-0002`), and the open ACL-least-privilege + root-policy + TFA read-backs (🟡). |
