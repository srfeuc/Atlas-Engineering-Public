---
Title: PAW01 Diagnostics — Show Commands & Verification
Path: Labs/Lab-02-Cisco-Core/Devices/PAW01-Tier0-Admin
Status: 📋 Seeded (`ADR-0032`). PAW01 = Tier-0 Win11 PAW, VLAN 20 (`10.20.0.10–.55`). Commands authored from docs; **📋 not built** — every row 🟡/📋 until a read-back is pasted. **Never assume output** (`POL-0001`).
Version: 0.1
Date: 2026-07-29
---

# PAW01 — Diagnostics: Show Commands & Verification

<!-- provenance -->
> **Lab-02 · Cisco-Core (ACTIVE — 📋 not built)** — Host: **PAW01** (Windows 11 Enterprise) — Role: Tier-0 Privileged Access Workstation + the Win11 golden-image source.

> **What this is (`ADR-0032`):** the quick "is PAW01 built + does the tier model actually hold?" checks. The distinctive PAW discipline is proving **RDP-as-Tier-0 works** *and* **cross-tier logon is denied**. Break-fix → `Troubleshooting.md`; deep set → Academy `Command-Library/PowerShell-Tier0.md`.

## 1. Golden image
| Check | Command / where | Expected | Verified? |
|---|---|---|---|
| Template exists | Proxmox → the VM shows as a **template** | can't start directly; icon changed | 📋 |
| Generalize worked | full-clone boots to OOBE | "let's set up" screen | 📋 |

## 2. Identity & addressing (PAW01)
| Check | Command | Expected | Verified? |
|---|---|---|---|
| Domain / OU | `Get-ComputerInfo -Property CsDomain` + `Get-ADComputer PAW01 -Properties DistinguishedName` | `atlas.lab` · `OU=PAW,OU=Tier 0,OU=Admin` | 📋 |
| IP / VLAN | `Get-NetIPConfiguration` | VLAN 20 tagged · `10.20.0.10–.55` · gw `.1` · DNS `.2` | 📋 |
| Not on native VLAN 10 | (config) | tagged VLAN 20, return traffic OK | 📋 |

## 3. Hardening
| Check | Command | Expected | Verified? |
|---|---|---|---|
| SCT baseline applied | `gpresult /h paw.html` | Win11 baseline GPO(s) applied | 📋 |
| Credential Guard running | `msinfo32` → *Virtualization-based security* / `Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard` | VBS Running; CredGuard active | 📋 (gated on VBS check) |
| AppLocker enforcing | `Get-AppLockerPolicy -Effective` | allow-list enforced; non-listed binary blocked | 📋 |
| Firewall deny-by-default | `Get-NetFirewallProfile` | inbound block; RDP only from mgmt source | 📋 |
| Standard user (no local admin) | `Get-LocalGroupMember Administrators` | only intended Tier-0 admins | 📋 |

## 4. The tier-0 admin proof (works AND denies)
| Test | Expected | Verified? |
|---|---|---|
| RDP in as `ATLAS\t0-seth` | Kerberos succeeds; **clipboard works** (the reason the PAW exists) | 📋 |
| Run ADUC / `Get-ADDomainController` from PAW01 | administers the DC via RSAT | 📋 |
| 🔴 Tier-1/Tier-2 account logon to PAW01 | **denied** (7d cross-tier deny) | 📋 (gated on 7d) |
| 🔴 `t0-seth` logon to a Tier-1/2 box | **denied** (7d, reciprocal) | 📋 |
| RSAT present | `Get-WindowsCapability -Online -Name Rsat* \| ? State -eq Installed` | AD DS / GPMC / DNS tools | 📋 |

## If you built or changed PAW01 solo (`ADR-0032`)
Paste the read-backs (template exists, domain/OU, `gpresult`, CredGuard state, the RDP-as-t0 success + the cross-tier deny) so the next session flips 📋 → ✅; mirror into `SESSION-HANDOFF.md` → Solo-work sync.

## Related
- `Troubleshooting.md` · Academy `Command-Library/PowerShell-Tier0.md` · `Roadmap.md` · `../../Operations/Validation-and-Adversarial-Testing.md` (the 7d cross-tier-deny proof) · the tier model build.

## Change Log
| Version | Changes |
|---|---|
| 0.1 | 2026-07-29. Seeded (`ADR-0032`) for the PAW01 replication: golden-image checks, identity/addressing (incl. the not-native-VLAN-10 check), hardening (SCT baseline, Credential Guard, AppLocker, firewall, standard-user), and the **RDP-as-Tier-0-works + cross-tier-deny** proof. All 📋; flips to ✅ on read-back (`POL-0001`). |
