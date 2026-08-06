---
Title: 1941 Troubleshooting Guide
Path: Labs/Lab-02-Cisco-Core/Devices/1941-Core-Router
---

# 1941 Troubleshooting Guide

<!-- provenance -->
> **Lab-02 - Cisco-Core (ACTIVE - in build)** - Host: 1941 - Role: Core Router (Cisco 1941, IOS 15.5(3)M4)

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Living |
| Version | 1.1 |
| Applies To | 1941 |
| Last Updated | 2026-08-04 |

## Purpose
Real incidents on the 1941 with root cause + verified fix. Build steps: `Build-Guide.md`. Cross-device timeline: `Build-Progress-Tracker.md`.

## Before You Start
- [ ] **`conf t` before pasting config** — commands run at the `1941#` exec prompt error out.
- [ ] **`crypto key generate rsa` on its own line** — run it and let it finish; its `[OK]` prompt can eat the next pasted line.
- [ ] **OSPF `network` enables OSPF on a *matching interface*** — it does **not** advertise a subnet. The 1941 owns no VLAN interface, so don't list VLAN subnets.
- [ ] **IOS does NOT auto-save** — `write memory` after changes, or a power loss reverts to startup-config. *(Playbook: [Confirm-a-Config-Change-Actually-Took](../../../../Atlas-Academy/Playbooks/Confirm-a-Config-Change-Actually-Took.md).)*
- [ ] **Old IOS SSH** offers only SHA1 algorithms — a modern client needs legacy-algorithm flags (see the SSH incident).

## Diagnostic Approach
```text
Paste failures — exec vs config mode; crypto-key prompt eating a line
SSH access    — vty login local + transport ssh; then modern-client algorithm flags
OSPF          — network statements = the two /30s + loopback only; Gi0/1 passive
Save state    — write memory ran? (IOS reverts on reboot otherwise)
```

---

## Incident: Pasted config commands rejected (`% Invalid input`)
**Symptom:** lines like `service timestamps log datetime msec` error with `% Invalid input detected`.
**Root cause:** they were pasted at the **exec** prompt (`1941#`), not in config mode; and/or the `crypto key generate rsa` prompt consumed the following line.
**Resolution:** enter config mode first, and run the key generation on its own line:
```
configure terminal
crypto key generate rsa modulus 2048
!  ↑ let this complete before pasting the rest
```
**Verify fix:** the hardening lines apply cleanly; `show ip ssh` → SSH Enabled, version 2.0.

---

## Incident: SSH keyed but login refused on the vty lines
**Symptom:** RSA key generated and `ip ssh version 2` set, but SSH login is refused.
**Root cause:** `line vty 0 4` had `login` (which expects a vty password) instead of `login local` (authenticate against the local user).
**Resolution:**
```
line vty 0 4
 login local
 transport input ssh
line vty 5 15
 login local
 transport input ssh
```
**Verify fix:** `show run | section line vty` → `login local` + `transport input ssh`; actually SSH in as `ciscoadmin` end-to-end.
**Lesson:** the RSA key + `ip ssh version 2` don't let anyone in on their own — the vty lines must be told to accept SSH and authenticate locally (this was the missing Stage 1b step).

---

## Incident: OSPF adjacency won't form / the 1941 has no VLAN routes
**Symptom:** the MKT01 adjacency won't reach Full, and/or the 1941 has no routes to the VLAN subnets.
**Root cause:** the OSPF `network` statements listed VLAN subnets (which the 1941 doesn't own) and omitted the transit `/30`s.
**Resolution:** run OSPF on the two `/30`s + loopback **only**; make the FGT-facing interface passive; the VLANs are *learned* from MKT01:
```
router ospf 1
 network 10.255.0.1 0.0.0.0 area 0
 network 10.255.255.4 0.0.0.3 area 0
 network 10.255.255.0 0.0.0.3 area 0
 passive-interface GigabitEthernet0/1
```
**Verify fix:** `show ip ospf neighbor` → MKT01 **FULL**; `show ip route ospf` → VLAN subnets via `10.255.255.6`.
**Note:** if the adjacency sticks at EXSTART/EXCHANGE it's usually **MTU**; INIT/2-WAY is a **network-type/DR** issue with the RouterOS peer.

---

## Incident: SSH from a modern client fails to negotiate
**Symptom:** `Unable to negotiate ... no matching key exchange method found` (then host-key, then MAC).
**Root cause:** old IOS offers only SHA1 KEX/host-key/MAC; modern OpenSSH disables them by default. **Not** a key-size problem.
**Resolution:**
```
ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa -o MACs=+hmac-sha1 ciscoadmin@<1941-mgmt-ip>
```
Or a permanent `Host` block in `%USERPROFILE%\.ssh\config`. Server-side, check `ip ssh server algorithm kex ?` for SHA2 variants. *(Same pattern as SW01 — see the SW01 Troubleshooting page.)*

---

## Quick Reference — Common Commands
| Task | Command |
|---|---|
| Prove SSH is actually on | `show ip ssh` |
| Confirm vty auth | `show run \| section line vty` |
| OSPF neighbor state | `show ip ospf neighbor` |
| Learned VLAN routes | `show ip route ospf` |
| Save (IOS does not auto-save) | `write memory` |
| SSH in from a modern client | `ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa -o MACs=+hmac-sha1 ciscoadmin@<ip>` |

## Escalation
1. For paste failures, drop to console and apply staged blocks (base → interfaces → OSPF) one at a time. *(Locked out? → Playbook: [Recover-a-Locked-Out-Router-Out-of-Band](../../../../Atlas-Academy/Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md).)*
2. Confirm `write memory` ran before assuming a reboot preserved config.
3. Cross-reference the tracker log + the `Build-Guide.md` (v1.2) staged flow.

## Related Pages
- [`Build-Guide.md`](Build-Guide.md)
- [`Build-Checklist.md`](Build-Checklist.md)
- [`Build-Progress-Tracker.md`](../../Build-Progress-Tracker.md)
- 🎓 **Atlas Academy** — commands: [`Command-Library/Cisco-IOS`](../../../../Atlas-Academy/Command-Library/Cisco-IOS.md); Playbooks: [Recover-a-Locked-Out-Router-Out-of-Band](../../../../Atlas-Academy/Playbooks/Recover-a-Locked-Out-Router-Out-of-Band.md) · [Confirm-a-Config-Change-Actually-Took](../../../../Atlas-Academy/Playbooks/Confirm-a-Config-Change-Actually-Took.md).


## Change Log
| Version | Date | Change |
|---|---|---|
| 1.1 | 2026-08-04 | **#43 Pass B** — added Academy up-links (Command-Library/Cisco-IOS · the *Recover-a-Locked-Out-Router-Out-of-Band* + *Confirm-a-Config-Change-Actually-Took* Playbooks) at the write-memory and console-escalation seams + the Related Pages. No content change. |
| 1.0 | 2026-07-21 | Initial troubleshooting guide (paste/exec-mode · vty login local · OSPF network-statements · modern-client SSH algos). |
