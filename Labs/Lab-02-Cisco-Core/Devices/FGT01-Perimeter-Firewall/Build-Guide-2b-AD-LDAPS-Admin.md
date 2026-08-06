---
Title: FGT01 Build Guide 2b — AD-Backed Admin Auth over LDAPS (Hardening Pass 2)
Path: Labs/Lab-02-Cisco-Core/Devices/FGT01-Perimeter-Firewall
Status: 🟡 LIVING (v0.1). GUI-first (FortiOS) + CLI alongside. **Pass-2 companion to `Build-Guide-2-Hardening.md`.** 📋 Authored 2026-07-22 — NOT device-executed (POL-0001).
Version: 0.1
Date: 2026-07-22
---

# FGT01 — Guide 2b: AD-Backed Admin Auth over LDAPS

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** — Host: FGT01 (FortiGate 60E) — **Hardening Pass 2**: replace local-only admin login with **AD-backed named admins over LDAPS** (`ADR-0028`), keeping `fortigateadmin` as break-glass. The device-side answer to "the FortiGate needs an AD account to secure it."

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | 🟡 **Target Design.** Part 1 (AD prereqs) is buildable **now**; Parts 2–5 (the FGT LDAPS config) are **gated on the DC LDAPS cert** (AD CS, `ADR-0027`). |
| Version | 0.1 |
| Decision | `ADR-0028` — direct LDAPS (not RADIUS), FGT-specific deviation from `ADR-0004` |
| Depends on | `ADR-0027` AD CS → **DC01 holds an autoenrolled LDAPS cert** (AD CS guide Part 3.4) + the **AD CS root** to import into the FGT |
| Reference | Fortinet Docs — *Configuring LDAP over SSL/TLS (LDAPS)* + *Administrator authentication using LDAP* (confirm exact GUI labels on your FortiOS build) |
| Governing Policy | `POL-0007` (hardening), `POL-0001` (evidence), `POL-0002` (secrets → Vaultwarden) |

> 🔴 **Break-glass (do not skip).** `fortigateadmin` (local super_admin) + the trusthost + the `192.168.1.99` recovery path stay intact **throughout** — never remove the local admin, never make it depend on AD/PKI. If LDAPS breaks (DC down, cert expired, clock skew), the local admin is how you get back in. Test the break-glass path **before** and **after** this change.

> 🔴 **LDAPS only — never plain LDAP/389.** Admin credentials cross this link; it must be TLS (636) with the DC cert validated. If you can't validate the cert yet (AD CS not built), **stop** — do Part 1 now and come back for Parts 2–5 after the DC cert exists.

---

## Part 1 — AD-side prerequisites (buildable NOW, no cert needed)

Do these from the PAW/ADUC as a Tier-0 admin. They don't need AD CS.

### 1.1 The network-admin role group

- [ ] **ADUC/ADAC** → in a tier `Groups` OU (e.g. `Admin\Tier 1\Groups`, or `Groups\Security-Roles`) → **New → Group** → name **`G-Network-Admins`**, scope **Global**, type **Security**. 📸
- [ ] Add the intended admin identity — **`t1-seth`** (or a dedicated net-admin account) — to `G-Network-Admins` (Member Of / Members tab). Tier placement per `ADR-0021`: network-device admin ≈ Tier 1.

### 1.2 The LDAP bind (service) account

- [ ] **New → User** in the **Service Accounts** OU → **`svc-fgt-ldap`** (naming per `303`'s `svc-` convention).
  - **Least privilege / read-only** — a plain domain user is enough to read group membership; grant it **no** admin rights.
  - **Password never expires** *(or a documented rotation plan)*; **User cannot change password**. Strong password → **Vaultwarden** (`POL-0002`), never in git/chat.
  - 🔴 **Deny interactive/RDP logon** — it's a bind account only. (A deny-logon GPO or the tier-deny 7d URA is the clean way; at minimum it should not be in any admin group.)
- [ ] Record its **bind DN** or **UPN** for Part 3, e.g. `CN=svc-fgt-ldap,OU=Service Accounts,OU=…,DC=atlas,DC=lab` or `svc-fgt-ldap@atlas.lab`.

**Evidence (`POL-0001`):** `Get-ADGroup G-Network-Admins`; `Get-ADUser svc-fgt-ldap -Properties MemberOf` (member of nothing privileged).

---

## Part 2 — Trust the DC's cert issuer on the FGT (after AD CS)

> Gate: DC01 has an autoenrolled **LDAPS/Kerberos-Auth cert** (AD CS guide Part 3.3–3.4), and you have the **AD CS root CA** `.cer`.

- [ ] FortiOS GUI → **System → Certificates → Import → CA Certificate** → import the **Atlas Root CA** `.cer` (and the **Issuing CA** cert too, so the full chain validates). 📸
- [ ] Confirm the DC's LDAPS cert **chains** to what you imported (it must, if both come from AD CS).

*(CLI: `config vpn certificate ca` / `edit "Atlas-Root-CA"` / `set certificate "-----BEGIN CERTIFICATE----- …"`.)*

---

## Part 3 — Define the LDAPS server object

FortiOS GUI → **User & Authentication → LDAP Servers → Create New**:

| Field | Value |
|---|---|
| **Name** | `AD-atlas` |
| **Server IP/Name** | `dc01.atlas.lab` *(use the **name**, not the IP — the cert's SAN is the FQDN; an IP will fail cert validation)* |
| **Secondary Server** | `dc02.atlas.lab` (once DC02 exists — redundancy) |
| **Server Port** | **636** |
| **Common Name Identifier** | **`sAMAccountName`** *(so admins log in as `seth`, not the full DN)* |
| **Distinguished Name** | `DC=atlas,DC=lab` (search base) |
| **Bind Type** | **Regular** |
| **Username** | `svc-fgt-ldap` bind DN or `svc-fgt-ldap@atlas.lab` |
| **Password** | (from Vaultwarden) |
| **Secure Connection** | **✅ Enable**, Protocol **LDAPS**, **Certificate = Atlas Root CA** (the CA imported in Part 2) |

- [ ] **Test Connectivity** → *Successful*. 📸
- [ ] **Test User Credentials** → enter a domain user in `G-Network-Admins` → *Successful*.

*(CLI sketch — confirm against your FortiOS version:)*
```
config user ldap
  edit "AD-atlas"
    set server "dc01.atlas.lab"
    set secondary-server "dc02.atlas.lab"
    set port 636
    set cnid "sAMAccountName"
    set dn "DC=atlas,DC=lab"
    set type regular
    set username "svc-fgt-ldap@atlas.lab"
    set password ****
    set secure ldaps
    set ca-cert "Atlas-Root-CA"
  next
end
```

---

## Part 4 — Map the AD group to a FortiGate admin profile

### 4.1 A remote user group matched on `G-Network-Admins`

FortiOS GUI → **User & Authentication → User Groups → Create New**:
- **Name** `grp-network-admins`, **Type** Firewall.
- **Remote Groups → Add** → Remote Server `AD-atlas` → **Group** = the DN of **`G-Network-Admins`** (`CN=G-Network-Admins,OU=…,DC=atlas,DC=lab`). 📸

### 4.2 The admin that trusts that group

FortiOS GUI → **System → Administrators → Create New → Administrator** (or *Match a remote server group*):
- **Type:** *Match all users in a remote server group* (wildcard) **or** a named admin matched to the group.
- **Remote server:** `AD-atlas` · **Group:** `grp-network-admins`.
- **Administrator profile:** `super_admin` *(or a scoped `prof_admin` — least privilege where practical)*.
- Leave **`fortigateadmin` (local) exactly as-is.** 📸

*(CLI sketch:)*
```
config user group
  edit "grp-network-admins"
    set member "AD-atlas"
    config match
      edit 1
        set server-name "AD-atlas"
        set group-name "CN=G-Network-Admins,OU=...,DC=atlas,DC=lab"
      next
    end
  next
end
config system admin
  edit "ad-admins"
    set remote-auth enable
    set remote-group "grp-network-admins"
    set accprofile "super_admin"
    set wildcard enable
  next
end
```

---

## Part 5 — Verify (POL-0001) + prove break-glass still works

- [ ] **Log in to the FGT GUI/SSH as a domain user in `G-Network-Admins`** (e.g. `t1-seth`) → succeeds, lands in the mapped profile. 📸
- [ ] **A domain user NOT in the group is denied.**
- [ ] 🔴 **`fortigateadmin` (local) still logs in** — break-glass proven after the change.
- [ ] Pull an admin **login event** showing the remote (LDAP) auth source (`Log & Report`), as evidence.
- [ ] Confirm you can still reach the box from the **mgmt host** and the **`192.168.1.99`** recovery path.

---

## Gotchas

- 🔴 **Cert name mismatch** — use the DC **FQDN** as the server, matching the cert SAN; an IP address fails LDAPS validation.
- 🔴 **Clock skew** — LDAPS/TLS + Kerberos are time-sensitive; FGT and DC must agree (both should be on the `ADR-0020` NTP hierarchy). FGT NTP → the DC/PDCe.
- 🔴 **Wrong CN identifier** — `sAMAccountName` lets admins log in as `seth`; using the DN forces full-DN logins. Pick `sAMAccountName`.
- 🔴 **Bind account locked/expired** — then *all* AD admin login breaks at once; the local break-glass is the recovery, and this is why the bind account is `password-never-expires` (or has a monitored rotation).
- 🔴 **Removing `fortigateadmin`** — never. It's the only way back if AD/LDAPS is down.
- **Firewall path** — the FGT must reach `dc01/dc02:636`; until east-west deny (Phase 7) it's open, but add the flow to `Atlas-East-West-Allowed-Flows-Matrix` so it survives default-deny.

## Deferred / later

- **DC02** as the secondary LDAPS server (redundancy) — once promoted.
- **Scoped admin profile** instead of `super_admin` (least privilege) — define a `prof_admin` that matches the role.
- **The same LDAPS pattern is NOT auto-applied to MKT01/SW01/1941** — they stay RADIUS-oriented (`ADR-0004`/`ADR-0028`); revisit per-platform if ever wanted.

## Related

- `ADR-0028` (this decision) · `ADR-0027` (AD CS → the DC cert) · `ADR-0004` (the RADIUS boundary this deviates from) · `ADR-0021` (tiering)
- `Build-Guide-2-Hardening.md` (Pass 1 — this is its Pass-2 companion) · `Build-Guide-Index.md` · `RCA01-ICA01-ADCS/AD-CS-Two-Tier-Build-Guide.md` (the cert prerequisite) · `Tiered-Admin-and-Groups-Build.md` (`G-*` groups + `t1-seth`)

## Change Log

| Version | Changes |
|---|---|
| 0.1 | 2026-07-22. Authored (not executed). FGT01 Pass-2 AD-backed admin over **LDAPS** per `ADR-0028`: Part 1 AD prereqs (`G-Network-Admins` + least-priv `svc-fgt-ldap`, buildable now), Part 2 import the AD CS root to trust the DC cert, Part 3 the LDAPS server object (FQDN, 636, `sAMAccountName`, regular bind, LDAPS+CA), Part 4 group→profile mapping (remote user group + matched admin, `super_admin`), Part 5 verify + prove break-glass. Gated on the DC LDAPS cert (`ADR-0027`); GUI-primary + CLI sketches (confirm labels per FortiOS build); `fortigateadmin` break-glass preserved throughout. |
