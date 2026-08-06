---
Title: Proxmox Authentication and Named Administration
Path: Labs/Lab-02-Cisco-Core/Virtualization/Build-Guides
---

# Proxmox Authentication and `seth-admin`

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)**

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟢 Procedure (target-state). The **verified state** lives in `../Build-Records/PVE01-Authentication.md` (authoritative, `POL-0008`); wired in the #22 audit 2026-07-30. |
| Version | 1.1 |
| Applies To | PVE01 — Proxmox VE 8.4.19 (Debian 12), standalone (not domain-joined) |

## Purpose

Use a named Proxmox administrator for routine GUI administration while retaining `root@pam` for host recovery and Linux-level maintenance.

> 🔴 **Authoritative verified state = `../Build-Records/PVE01-Authentication.md` (`POL-0008`).** This guide is the **procedure**; the record holds the device-verified accounts (`root@pam` recovery + `seth-admin@pve` Administrator at `/`, from `pveum user list` 2026-07-16). 🟡 **Still to read back / decide** (per the record): the **ACL least-privilege review** (`pveum acl list` — confirm no unexpected grants; a scoped role vs `/`-Administrator once multi-user), the **root-login policy** (restrict root SSH/GUI?), and **TFA/TOTP on the named admin**. Secrets → **Vaultwarden**, never in-repo (`POL-0002`/`ADR-0009`).

## Verified Account

```text
seth-admin@pve
```

ACL: Path `/`, Role `Administrator`, Propagate `Yes`.

## Design Philosophy — Important Realm Distinction

- `root@pam` is a Linux PAM account and can use the host shell.
- `seth-admin@pve` is a Proxmox VE realm account.
- A PVE realm account does not automatically exist as a Debian Linux account.
- Do not assume `seth-admin@pve` can SSH or use `sudo`.

## Prerequisites

- Proxmox VE installed and reachable via the web GUI as `root@pam`

## Implementation

### 1. GUI Creation

1. Datacenter → Permissions → Users.
2. Add: User name `seth-admin`, Realm: Proxmox VE authentication server, Enabled: Yes, Comment: Named Atlas administrator.
3. Datacenter → Permissions.
4. Add User Permission: Path `/`, User `seth-admin@pve`, Role `Administrator`, Propagate `Yes`.
5. Log out.
6. Test login as `seth-admin@pve`.

### 2. Root Policy

Use `root@pam` for package management, host networking recovery, storage recovery, low-level Debian maintenance, and emergency access. Use `seth-admin@pve` for routine Proxmox GUI operations.

### 3. Optional Linux Administrator

Create a separate Debian account only through a documented hardening decision. Do not reuse or confuse the PVE realm account with a Linux account.

## Validation

```bash
pveum user list
pveum role list
pveum acl list
```

## Common Mistakes

- Assuming `seth-admin@pve` can SSH into the host — it can't, by design; it's a Proxmox realm account, not a Linux user.
- Creating a Linux account with the same name without a documented reason, creating confusion between the two separate identities.

## Rollback

Remove the ACL entry and disable or delete the `seth-admin@pve` user via Datacenter → Permissions if the account needs to be revoked. `root@pam` remains available regardless.

## Completion Checklist

- [x] `seth-admin@pve` can log into the GUI
- [x] Administrator functions confirmed working
- [x] Root remains available
- [x] No duplicate similarly-named accounts
- [x] ACL documented (Path `/`, Role Administrator, Propagate Yes)

## Change Log

| Version | Changes |
|---|---|
| 1.1 | 2026-07-30. **#22 audit — wired to the authoritative record.** Added the `PVE01-Authentication.md` (`POL-0008`) pointer + the 🟡 ACL-least-privilege / root-login-policy / TFA read-backs still owed, and the secrets-→-Vaultwarden reminder (`POL-0002`/`ADR-0009`). The `seth-admin@pve` (Administrator at `/`, propagate) + `root@pam` facts and the realm-distinction guidance were already correct and unchanged. |
| 1.0 | Initial auth guide — named `seth-admin@pve` admin + `root@pam` recovery; the PVE-realm-vs-Linux-account distinction. |

## Next Guide

Windows Server 2025 VM Creation.
