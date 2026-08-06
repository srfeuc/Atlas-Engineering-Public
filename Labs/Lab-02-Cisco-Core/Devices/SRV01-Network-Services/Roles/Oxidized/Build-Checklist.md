---
Title: SRV01 / Oxidized — Build Checklist (config backup → git)
Path: Labs/Lab-02-Cisco-Core/Devices/SRV01-Network-Services/Roles/Oxidized
Status: 📋 Planned — config-as-record. Host build = `../../Build-Checklist.md`.
Version: 1.0
Date: 2026-07-29
---

# SRV01 / Oxidized — network-config backup → git

> Pulls running configs from the network devices on a schedule and commits to git — **drift becomes a diff you can see**. CCNA Dom-6 (automation/config-mgmt).

## Deps
- [ ] Host built · **read-only device accounts** on SW01/FGT01/MKT01/1941, **creds vaulted** (Vaultwarden, `POL-0002`) · ideally **NetBox** for the device list (`POL-0004`).

## Steps
- [ ] Install Oxidized; targets = **SW01, FGT01, MKT01, 1941**; schedule pulls → **commit to git**.
- [ ] Device inventory from NetBox where possible (static list until NetBox is up).
- [ ] 🔴 Creds **read-only + vaulted**, never cleartext in the Oxidized config or git.

## Accept (`POL-0001`)
- [ ] A commit lands in git; change a device config and confirm the **diff is detected**.
- [ ] `gitleaks` finds **no secrets** in the repo.

## Related
- `../../Build-Checklist.md` §2 · `../../Considerations.md` · `POL-0002`/`POL-0004`.
